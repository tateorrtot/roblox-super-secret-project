"""Writes the public face of Luau modules to one text file, for a reader test: each module's
comments, types and function signatures, with no function bodies.

A reader test checks that a piece makes sense with no context. A reader who has never seen the
code is given the faces and a list of calls, and predicts what each call returns. Where they are
wrong, the names or the comments need work. See docs/working/code-reviews/2026-11-19-the-first-piece.md.

Run it from the repository root:

    python tools/faces.py <out.txt> <module.luau> [<module.luau> ...]

For a reader who is to have names and types only, strip the comments from the output.
"""
import io, sys, os

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')


def face(path):
    lines = io.open(path, encoding='utf-8').read().split('\n')
    out, pending = [], []
    i, n = 0, len(lines)
    while i < n:
        line = lines[i]
        if line.startswith('--[=['):
            block = []
            while i < n:
                block.append(lines[i])
                if ']=]' in lines[i]:
                    break
                i += 1
            pending += block
        elif line.startswith('--'):
            pending.append(line)
        elif line.startswith('local function'):
            while i < n and lines[i] != 'end':
                i += 1
            pending = []
        elif line.startswith('function '):
            signature = [line]
            if ')' not in line:
                i += 1
                while i < n:
                    signature.append(lines[i])
                    if lines[i].startswith(')'):
                        break
                    i += 1
            out += pending + signature + ['']
            pending = []
            while i < n and lines[i] != 'end':
                i += 1
        elif line.startswith('export type') or line.startswith('type '):
            block = [line]
            if line.rstrip().endswith('{'):
                i += 1
                while i < n:
                    block.append(lines[i])
                    if lines[i] == '}':
                        break
                    i += 1
            if line.startswith('export type'):
                out += pending + block + ['']
            pending = []
        elif line.strip() == '':
            if pending:
                out += pending + ['']
                pending = []
        else:
            if pending and not out:
                out += [l for l in pending if not l.startswith('--!')] + ['']
            if 'require(' in line:
                out.append(line)
            pending = []
        i += 1
    return '\n'.join(out).rstrip() + '\n'


parts = []
for path in sys.argv[2:]:
    name = os.path.basename(path)
    parts.append('=' * 30 + ' ' + name + ' ' + '=' * 30 + '\n\n' + face(path))
text = '\n'.join(parts)
io.open(sys.argv[1], 'w', encoding='utf-8', newline='\n').write(text)
print(len(text), 'chars written to', sys.argv[1])
