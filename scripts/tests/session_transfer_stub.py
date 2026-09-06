#!/usr/bin/env python3
"""Local SSH/rsync stand-ins, including SSH's consumption of standard input."""

from pathlib import Path
import shutil
import subprocess
import sys


args = sys.argv[1:]
if Path(sys.argv[0]).name == 'ssh':
    no_stdin = args[0] == '-n'
    if no_stdin:
        args.pop(0)
    args.pop(0)  # Test endpoint, executed locally.
    standard_input = b'' if no_stdin else sys.stdin.buffer.read()
    result = subprocess.run(args[0], shell=True, input=standard_input)
    sys.exit(result.returncode)

if Path(sys.argv[0]).name == 'rsync':
    source, target = args[-2:]
    source = Path(source.split(':', 1)[-1])
    target = Path(target.split(':', 1)[-1])
    if target.is_dir():
        target = target / source.name
    if '--ignore-existing' not in args or not target.exists():
        shutil.copyfile(source, target)
else:
    raise RuntimeError('Unknown test transport')
