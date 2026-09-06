#!/usr/bin/env python3
"""Inspect rollout dependencies without rewriting conversation history."""

import hashlib
import json
from pathlib import Path
import re
import sys


def metadata(path, expected_id=None):
    with path.open('rb') as stream:
        record = json.loads(stream.readline())
    if record.get('type') != 'session_meta':
        raise ValueError(f'{path}: first record is not session_meta')
    value = record['payload']
    ident = value.get('id') or value.get('session_id')
    if not isinstance(ident, str) or not re.fullmatch(r'[A-Za-z0-9_-]+', ident):
        raise ValueError(f'{path}: invalid session id')
    if expected_id is not None and ident != expected_id:
        raise ValueError(f'{path}: expected session {expected_id}, found {ident}')
    base = value.get('history_base')
    if base is not None:
        if value.get('history_mode') != 'paginated' or not isinstance(base, dict):
            raise ValueError(f'{path}: invalid paginated history_base')
        parent = base.get('thread_id')
        if not isinstance(parent, str) or not re.fullmatch(r'[A-Za-z0-9_-]+', parent):
            raise ValueError(f'{path}: invalid history source id')
        for key in ('end_byte_offset', 'end_ordinal_exclusive'):
            if type(base.get(key)) is not int or base[key] < 0:
                raise ValueError(f'{path}: invalid history {key}')
    return ident, base


def prefix_digest(path, size):
    digest = hashlib.sha256()
    remaining = size
    with path.open('rb') as stream:
        while remaining:
            chunk = stream.read(min(remaining, 1024 * 1024))
            if not chunk:
                raise ValueError(f'{path}: truncated required history prefix ({size} bytes)')
            digest.update(chunk)
            remaining -= len(chunk)
    return digest.hexdigest()


def manifest(directory, selected_id):
    files = {}
    for path in directory.glob('*.jsonl'):
        ident, base = metadata(path)
        if ident in files:
            raise ValueError(f'duplicate staged source rollout: {ident}')
        files[ident] = path, base
    chain = []
    required = {}
    ident = selected_id
    while ident:
        if ident in chain:
            raise ValueError(f'history dependency cycle: {ident}')
        if ident not in files:
            raise ValueError(f'missing source rollout: {ident}')
        chain.append(ident)
        path, base = files[ident]
        if base is None:
            break
        parent = base['thread_id']
        required[parent] = base['end_byte_offset']
        ident = parent
    rows = []
    for ident in reversed(chain):
        path, _ = files[ident]
        size = required.get(ident)
        digest = '-'
        if size is not None:
            digest = prefix_digest(path, size)
            if size:
                with path.open('rb') as stream:
                    stream.seek(size - 1)
                    if stream.read(1) != b'\n':
                        raise ValueError(f'{path}: required history ends inside a JSONL record')
        rows.append((path.name, '-' if size is None else str(size), digest))
    for row in rows:
        print('\t'.join(row))


def check_existing(path, size, expected_digest):
    path = path.expanduser()
    if not path.exists():
        print('missing')
        return
    if prefix_digest(path, size) != expected_digest:
        raise ValueError(f'{path}: existing history conflicts with required source; not overwritten')
    print('present')


def main():
    command, *args = sys.argv[1:]
    if command == 'parent':
        _, base = metadata(Path(args[0]), args[1])
        print(base['thread_id'] if base else '')
    elif command == 'manifest':
        manifest(Path(args[0]), args[1])
    elif command == 'check-existing':
        check_existing(Path(args[0]), int(args[1]), args[2])
    else:
        raise ValueError(f'unknown history operation: {command}')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, KeyError) as error:
        print(f'Error: {error}', file=sys.stderr)
        sys.exit(1)
