"""Regression checks for complete, byte-preserving Codex session imports."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import uuid


SCRIPTS = Path(__file__).resolve().parents[1]


class SessionImportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='codex-lineage-test-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / 'source with spaces'
        self.target = self.root / 'target with spaces'

    def rollout(self, ident, date, parent=None, **extra):
        payload = dict(id=ident, history_mode='paginated', **extra)
        if parent is not None:
            payload['history_base'] = dict(thread_id=parent.stem.rsplit('-', 1)[1],
                                           end_byte_offset=parent.stat().st_size,
                                           end_ordinal_exclusive=1)
        path = self.source / date / f"rollout-{date.replace('/', '-')}T12-00-00-{ident}.jsonl"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(dict(type='session_meta', payload=payload)) + '\n')
        return path

    def chain(self):
        root = self.rollout('root', '2026/08/31')
        parent = self.rollout('parent', '2026/09/01', root)
        child = self.rollout('child', '2026/09/05', parent)
        return root, parent, child

    def run_import(self, source=None, target=None, ident='child', title=None, ok=True, env=None):
        command = ['bash', str(SCRIPTS / 'import_codex_session.sh'),
                   str(source or self.source), str(target or self.target), ident]
        if title:
            command.append(title)
        result = subprocess.run(command, capture_output=True, text=True, timeout=20, env=env)
        if ok:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def assert_copied(self, paths, target=None):
        target = target or self.target
        for path in paths:
            self.assertEqual(path.read_bytes(), (target / path.relative_to(self.source)).read_bytes())

    def test_complete_chain_across_dates(self):
        paths = self.chain()
        self.run_import()
        self.assert_copied(paths)

    def test_explicit_date_source_and_target(self):
        paths = self.chain()
        self.run_import(source=paths[-1].parent, target=self.target / '2026/09/05')
        self.assert_copied(paths)

    def test_remote_transport_does_not_consume_remaining_manifest(self):
        paths = self.chain()
        binaries = self.root / 'transport'
        binaries.mkdir()
        for name in ('ssh', 'rsync'):
            destination = binaries / name
            shutil.copyfile(SCRIPTS / 'tests/session_transfer_stub.py', destination)
            destination.chmod(0o755)
        environment = dict(os.environ)
        environment['PATH'] = str(binaries) + os.pathsep + environment['PATH']
        self.run_import(source='testhost:' + str(self.source),
                        target='testhost:' + str(self.target), env=environment)
        self.assert_copied(paths)

    def test_missing_ancestor_does_not_publish_child(self):
        root, _, _ = self.chain()
        root.unlink()
        result = self.run_import(ok=False)
        self.assertIn('Missing source rollout', result.stderr)
        self.assertFalse(self.target.exists())

    def test_cyclic_history_does_not_publish_child(self):
        path = self.rollout('child', '2026/09/05')
        record = json.loads(path.read_text())
        record['payload']['history_base'] = dict(thread_id='child', end_byte_offset=0,
                                                 end_ordinal_exclusive=0)
        path.write_text(json.dumps(record) + '\n')
        result = self.run_import(ok=False)
        self.assertIn('cycle', result.stderr)
        self.assertFalse(self.target.exists())

    def test_truncated_ancestor_does_not_publish_child(self):
        root, _, _ = self.chain()
        root.write_bytes(root.read_bytes().rstrip(b'\n'))
        result = self.run_import(ok=False)
        self.assertIn('truncated', result.stderr)
        self.assertFalse(self.target.exists())

    def test_inconsistent_session_id_is_rejected(self):
        path = self.rollout('child', '2026/09/05')
        record = json.loads(path.read_text())
        record['payload']['id'] = 'different'
        path.write_text(json.dumps(record) + '\n')
        result = self.run_import(ok=False)
        self.assertIn('expected session child', result.stderr)
        self.assertFalse(self.target.exists())

    def test_legacy_fork_does_not_require_source_rollout(self):
        path = self.rollout('child', '2026/09/05', forked_from_id='unavailable')
        record = json.loads(path.read_text())
        del record['payload']['history_mode']
        path.write_text(json.dumps(record) + '\n')
        self.run_import()
        self.assert_copied([path])

    def test_longer_existing_ancestor_is_preserved(self):
        root, _, _ = self.chain()
        target_root = self.target / root.relative_to(self.source)
        target_root.parent.mkdir(parents=True)
        original = root.read_bytes() + b'{"type":"event_msg","payload":{}}\n'
        target_root.write_bytes(original)
        self.run_import()
        self.assertEqual(target_root.read_bytes(), original)

    def test_conflicting_existing_ancestor_is_not_overwritten(self):
        root, _, _ = self.chain()
        target_root = self.target / root.relative_to(self.source)
        target_root.parent.mkdir(parents=True)
        original = root.read_bytes().replace(b'root', b'evil')
        target_root.write_bytes(original)
        result = self.run_import(ok=False)
        self.assertIn('conflicts', result.stderr)
        self.assertEqual(target_root.read_bytes(), original)
        self.assertEqual(list(self.target.rglob('*.jsonl')), [target_root])

    def test_named_archive_exports_complete_history(self):
        paths = self.chain()
        title = 'codex-import-regression-' + uuid.uuid4().hex
        archive = Path.home() / 'codex_saved_sessions' / title
        self.assertFalse(archive.exists())
        self.addCleanup(lambda: shutil.rmtree(archive) if archive.exists() else None)
        self.run_import(title=title)
        self.assertTrue((archive / paths[-1].name).is_file())
        target = self.root / 'export destination'
        result = subprocess.run(['bash', str(SCRIPTS / 'export_codex_session.sh'),
                                 title, str(target)], capture_output=True, text=True, timeout=20)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assert_copied(paths, target)


if __name__ == '__main__':
    unittest.main()
