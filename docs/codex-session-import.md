# Importing Codex conversation history

`scripts/import_codex_session.sh` must transfer a resumable conversation,
including every rollout referenced through `session_meta.payload.history_base`.
Copying only the selected JSONL fails for Codex's paginated history: a resume
then reports `invalid paginated history lineage ... missing source rollout`.

Before publishing the selected session, stage and validate its entire dependency
chain. Read the first metadata record with Python's standard JSON parser; never
rewrite metadata or concatenate histories. Follow `history_base.thread_id`, not
the informational `forked_from_id` in self-contained older sessions. Reject
missing or ambiguous source files, inconsistent IDs, dependency cycles and
truncated required prefixes before changing the target.

An explicit source date directory selects the requested session there; its
dependencies are resolved from the enclosing session tree, including other dates.
Saved named archives must retain the entire dependency chain so the existing
export command can import them again. Preserve each rollout's own date.

Install source histories before the selected session. Existing source histories
must match the required byte prefix and remain unchanged; a conflicting or
incomplete existing source must fail clearly rather than overwrite another
conversation's history. The selected session retains the importer's existing
replacement behavior.

The repair uses the existing Bash/SSH/rsync transport and Python 3, already
installed on the Mac and installer. No Codex upgrade, history flattening or
robot application build is involved.

Validation covers cross-date lineage, legacy self-contained forks, broken and
cyclic histories, archive round trips and existing ancestor preservation. SSH
commands that do not need input use `-n`, so they cannot consume the remaining
history manifest from a surrounding read loop.

## Validation and installation, 2026-09-06

All 11 regression tests passed on macOS and installer1's Linux environment:

```sh
python3 -m unittest discover -s scripts/tests -p test_codex_session_import.py -v
```

A real Mac-to-installer import into a separate repair directory transferred the
selected rollout plus all three ancestors, totaling 24,283,897 bytes. Each
destination file matched the source prefix of exactly its captured length.
The selected source session was still appending, so its later whole-file hash
was not used as the comparison. No conversation bytes or metadata were rewritten.

The original session's app-server resume check reported `already has an active
writer`. That is not recorded as a successful new resume. The running session
was left alone; no inference turn or second writer was started.

The tested importer and JSON helper are installed in `~/scripts/` on both the
Mac and installer1, with matching SHA256 hashes. Originals were backed up under
`~/.codex/session-repairs/importer-fix-20260906/`. The script hash is
`db6c38e12f454916eff28ded5b3b32060e77a0bdcfbb70724fb3b90f80107e26`;
the helper hash is
`736c970324039320ae19ac75d088375435fb525ee44bcfcd6fd60a700cbf4a2c`.

Audit: changes are `scripts/import_codex_session.sh`, the new
`scripts/codex_session_history.py`, the regression test and SSH/rsync test
stand-in under `scripts/tests/`, this page and its terminal-command index link.
Implementation used the isolated `dotfiles-codex-session-lineage` worktree on
`fix/codex-session-lineage`; no agents, robot builds or ROS changes were needed.
Live dotfiles checkouts retain unrelated pre-existing edits. Test failures
exposed macOS `cp -n` exit semantics and SSH consuming the read loop's input;
both were fixed and verified before installation. Bash syntax and whitespace
checks passed. Human follow-up is to use the normal import command and resume
the imported conversation when it is not already open. No robopilot wiki update
is needed because this is personal dotfiles tooling; this page is its durable
specification and audit.
