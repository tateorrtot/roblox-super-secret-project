"""Lists the public functions in src that nothing in src calls.

Run from the repository root: python tools/unused.py
A function a test calls but the game does not is still listed: it was built ahead of need.
The request functions are called by name through Requests, so they are left out. So are the
functions of the scripts of the game's own things, which the requests call through ItemScripts and
PlacedObjectScripts, and the two functions of what an item shows while selected, which Main.client
calls through its table of those pieces.
"""
import os
import re

DEFINITION = re.compile(r'^function (\w+)\.(\w+)\(', re.MULTILINE)
CALLED_BY_NAME = {'InventoryRequests', 'PlotRequests'}
CALLED_THROUGH_A_TABLE = {
    'src/shared/content/': {'interact', 'breakPlacedObject', 'interactWithTile'},
    'src/client/content/': {'update', 'hide'},
}

sources = {}
for root, _, names in os.walk('src'):
    for name in names:
        if name.endswith('.luau'):
            path = os.path.join(root, name).replace('\\', '/')
            text = open(path, encoding='utf-8').read()
            sources[path] = '\n'.join(line for line in text.split('\n') if not line.strip().startswith('--'))

unused = []
for path, text in sources.items():
    for module, function in DEFINITION.findall(text):
        if module in CALLED_BY_NAME or function in CALLED_THROUGH_A_TABLE.get(os.path.dirname(path) + '/', ()):
            continue
        use = re.compile(r'\b' + module + r'\.' + function + r'\b')
        uses = sum(len(use.findall(other)) for other in sources.values()) - 1
        if uses == 0:
            unused.append(f'{path[4:]}: {module}.{function}')

print('\n'.join(sorted(unused)) or 'Every public function in src has a caller in src.')
