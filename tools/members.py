"""Checks that every function, constant and type that src uses from one of its own modules exists.

Run from the repository root: python tools/members.py
The server's and the client's scripts are not type-checked, so a misspelt or renamed member there
would only be found by running the game. This finds it by reading: for every `Module.member` in a
file that requires Module, the module must define that member. It also checks that every message
the two Main scripts send or listen for by name is one that exists.
"""
import os
import re
import sys

REQUIRE = re.compile(r'^local (\w+) = require\((.*)\)\s*$', re.MULTILINE)
LAST_WORD = re.compile(r'(\w+)\W*$')


def code_of(text):
    """The text with comments and the insides of strings removed, so that only code is searched."""
    text = re.sub(r'--\[=*\[.*?\]=*\]', '', text, flags=re.DOTALL)
    lines = []
    for line in text.split('\n'):
        line = re.sub(r'"(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'', '""', line)
        cut = line.find('--')
        lines.append(line if cut < 0 else line[:cut])
    return '\n'.join(lines)


modules = {}
texts = {}
for root, _, names in os.walk('src'):
    for name in names:
        if not name.endswith('.luau'):
            continue
        path = '/'.join(os.path.join(root, name).split(os.sep))
        text = open(path, encoding='utf-8').read()
        texts[path] = text
        stem = name.split('.')[0]
        members = set(re.findall(r'^function ' + stem + r'\.(\w+)', text, re.MULTILINE))
        members |= set(re.findall(r'^' + stem + r'\.(\w+)\s*=', text, re.MULTILINE))
        members |= set(re.findall(r'^export type (\w+)', text, re.MULTILINE))
        modules[path] = (stem, members, re.search(r'^local ' + stem + r' = \{\}', text, re.MULTILINE) is not None)


def module_for(user_path, required_name):
    """The module a file means by a name: one on its own side if there is one, else one in shared."""
    side = user_path.split('/')[1]
    found = [path for path, (stem, _, _) in modules.items() if stem == required_name]
    same_side = [path for path in found if path.split('/')[1] == side]
    return (same_side or [path for path in found if path.split('/')[1] == 'shared'] or [None])[0]


problems = []
for path, text in texts.items():
    code = code_of(text)
    for local_name, expression in REQUIRE.findall(text):
        word = LAST_WORD.search(expression.replace('"', ' ').replace("'", ' '))
        target = module_for(path, word.group(1)) if word else None
        if target is None or not modules[target][2]:
            continue
        defined = modules[target][1]
        for member in set(re.findall(r'\b' + local_name + r'\.(\w+)', code)):
            if member not in defined:
                problems.append(f'{path[4:]} uses {local_name}.{member}, which {target[4:]} does not define')

messages = set(re.findall(r'"(\w+)"', texts['src/shared/requests/Messages.luau']))
for requests in ('src/shared/requests/InventoryRequests.luau', 'src/shared/requests/PlotRequests.luau'):
    messages |= modules[requests][1]
for path in ('src/server/Main.server.luau', 'src/client/Main.client.luau'):
    for name in set(re.findall(r'\bremotes\.(\w+)', code_of(texts[path]))):
        if name not in messages:
            problems.append(f'{path[4:]} uses the message {name}, which does not exist')

if problems:
    print('\n'.join(sorted(problems)))
    sys.exit(1)
print('Every member and message that src uses exists.')
