"""Prints the outline of the code: every file in src with its public functions and constants.

Run from the repository root:

    python tools/outline.py            each function with its arguments
    python tools/outline.py --names    bare names only
    python tools/outline.py --sheet    the sheet for a names test: each file's first line of
                                       comment, then the bare names of its functions

A names test checks that a name says what its function acts on. A reader who has never seen the
code is given the sheet and nothing else, and writes what each function takes and does. See
docs/code/conventions.md.
"""
import glob
import io
import os
import re
import sys

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
MODE = sys.argv[1] if len(sys.argv) > 1 else ''


def signatures(lines):
    found = []
    for index, line in enumerate(lines):
        if not line.startswith('function '):
            continue
        signature = line
        if line.rstrip().endswith('('):
            parts = [line.strip()]
            for following in lines[index + 1:]:
                parts.append(following.strip())
                if following.startswith(')'):
                    break
            signature = ' '.join(parts)
        found.append(signature[len('function '):])
    return found


def first_paragraph(lines):
    """The file's opening comment, up to its first blank comment line."""
    paragraph = []
    for line in lines:
        if line.startswith('--- '):
            paragraph.append(line[4:])
        elif paragraph:
            break
    return ' '.join(paragraph)


for path in sorted(glob.glob('src/**/*.luau', recursive=True)):
    lines = io.open(path, encoding='utf-8').read().split('\n')
    functions = signatures(lines)
    constants = [line.split(' = ')[0] for line in lines if re.match(r'^[A-Z][A-Za-z]+\.[A-Z_]+ = ', line)]
    if not functions:
        continue
    name = os.path.basename(path)[:-len('.luau')]
    if MODE == '--sheet':
        side = path.replace(os.sep, '/').split('/')[1]
        print(f'{name} ({side}): {first_paragraph(lines)}')
        print('  ' + ', '.join(signature.split('(')[0].split('.')[1] for signature in functions))
        print()
        continue
    print(path.replace(os.sep, '/'))
    for constant in constants:
        print('  ' + constant)
    for signature in functions:
        print('  ' + (signature.split('(')[0] if MODE == '--names' else signature))
