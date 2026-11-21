"""Checks the notes: that every path they mention exists, and that no file has grown too long.

Run from the library's root:

    python tools/notes.py

The notes are CLAUDE.md, which is loaded into every session and so must stay short, README.md, and the
files under docs/. A path is a name in backticks that starts with docs/, src/, tests/, demos/ or tools/,
or that is a bare file ending in .md, or a bare folder ending in a slash.
"""
import glob
import io
import os
import re
import sys

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

ROOT_LIMIT = 60
TOPIC_LIMIT = 140
NUMBERED = re.compile(r'[\\/]\d\d-[^\\/]*\.md$')

problems = []
notes = ['CLAUDE.md', 'README.md']
notes += [path for path in glob.glob('docs/**/*.md', recursive=True) if not NUMBERED.search(path)]

for path in sorted(notes):
    if not os.path.exists(path):
        continue
    lines = io.open(path, encoding='utf-8').read().split('\n')
    limit = ROOT_LIMIT if path == 'CLAUDE.md' else TOPIC_LIMIT
    if len(lines) > limit:
        problems.append(f'{path}: {len(lines)} lines, over {limit}. Split it.')
    folder = os.path.dirname(path)
    for number, line in enumerate(lines, 1):
        for mentioned in re.findall(r'`((?:docs|src|tests|demos|tools|build)/[\w./-]+|[\w-]+\.md|[\w-]+/)`', line):
            candidates = [mentioned, os.path.join(folder, mentioned)]
            exists = any(os.path.exists(candidate) or glob.glob(candidate + '*') for candidate in candidates)
            if not exists and not mentioned.startswith('build/'):
                problems.append(f'{path}:{number}: `{mentioned}` does not exist')

for problem in problems:
    print(problem)
print(f'{len(notes)} notes checked, {len(problems)} problem(s)')
sys.exit(1 if problems else 0)
