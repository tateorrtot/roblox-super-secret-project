"""Lists the public functions in src that no case of the page needs.

Run from the library's root: python tools/unused.py

A library's public functions are called by whoever uses the library, so most have no caller in src.
A function is needed if something calls it in src, in a demo, or in tests/Cases.test.luau, which
holds the cases that README.md says the library serves. A function that only its own unit test calls
is listed: it was built ahead of need.
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFINITION = re.compile(r'^function (\w+)\.(\w+)(?:<[^>\n]*>)?\(', re.MULTILINE)


def read_code(path):
    """Returns the text of the file at `path` with its comment lines left out."""
    text = open(path, encoding='utf-8').read()
    return '\n'.join(line for line in text.split('\n') if not line.strip().startswith('--'))


def find_luau_files(folder):
    """Returns the path of every .luau file under `folder`, at any depth."""
    found = []
    for root, _, names in os.walk(folder):
        found.extend(os.path.join(root, name) for name in names if name.endswith('.luau'))
    return found


sources = {path: read_code(path) for path in find_luau_files(os.path.join(ROOT, 'src'))}
users = [read_code(path) for path in find_luau_files(os.path.join(ROOT, 'demos'))]
cases = os.path.join(ROOT, 'tests', 'Cases.test.luau')
if os.path.exists(cases):
    users.append(read_code(cases))

unused = []
for path, text in sources.items():
    for module, function in DEFINITION.findall(text):
        use = re.compile(r'\b' + module + r'\.' + function + r'\b')
        uses = sum(len(use.findall(other)) for other in sources.values()) - 1
        uses += sum(len(use.findall(other)) for other in users)
        if uses == 0:
            unused.append(f'{os.path.relpath(path, ROOT)[4:]}: {module}.{function}'.replace(os.sep, '/'))

print('\n'.join(sorted(unused)) or 'Every public function in src is called in src, in a demo, or in a case.')
