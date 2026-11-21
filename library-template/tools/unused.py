"""Lists the public functions in src that nothing in src calls.

Run from the library's root: python tools/unused.py
A function a test or a demo calls but nothing in src calls is still listed: it was built ahead of need.
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFINITION = re.compile(r'^function (\w+)\.(\w+)\(', re.MULTILINE)

sources = {}
for root, _, names in os.walk(os.path.join(ROOT, 'src')):
    for name in names:
        if name.endswith('.luau'):
            path = os.path.join(root, name)
            text = open(path, encoding='utf-8').read()
            sources[path] = '\n'.join(line for line in text.split('\n') if not line.strip().startswith('--'))

unused = []
for path, text in sources.items():
    for module, function in DEFINITION.findall(text):
        use = re.compile(r'\b' + module + r'\.' + function + r'\b')
        uses = sum(len(use.findall(other)) for other in sources.values()) - 1
        if uses == 0:
            unused.append(f'{os.path.relpath(path, ROOT)[4:]}: {module}.{function}'.replace(os.sep, '/'))

print('\n'.join(sorted(unused)) or 'Every public function in src has a caller in src.')
