"""Prints the bare names of modules in src, for the names test: each module's name, the fields of
the types it exports, its public constants and its public functions. No comments, no arguments, no
paths, and nothing that says what the program is.

Run from the repository root:

    python tools/bare_names.py                     every module
    python tools/bare_names.py World PlayerState   only those

docs/code/names.md says how the test is run and what counts as passing.
"""
import io
import os
import re
import sys

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
only = set(sys.argv[1:])


def sheet_for(path):
    text = io.open(path, encoding='utf-8').read()
    module = os.path.basename(path).split('.')[0]
    lines = [module]
    # A type may take type parameters, as `Signal<T...>` does, and may be written on one line or on several.
    types = []
    for found in re.finditer(r'^export type (\w+)(?:<[^>\n]*>)? = \{\n(.*?)^\}', text, re.MULTILINE | re.DOTALL):
        types.append((found.start(), found.group(1), re.findall(r'^\t(?:read )?(\w+): ', found.group(2), re.MULTILINE)))
    for found in re.finditer(r'^export type (\w+)(?:<[^>\n]*>)? = \{ (.*) \}$', text, re.MULTILINE):
        types.append((found.start(), found.group(1), re.findall(r'(?:^|, )(?:read )?(\w+): ', found.group(2))))
    # A type may also be another type with more fields: `export type Crate = Plot.PlacedObject & {`.
    extended = r'^export type (\w+)(?:<[^>\n]*>)? = ([\w.]+) & \{\n(.*?)^\}'
    for found in re.finditer(extended, text, re.MULTILINE | re.DOTALL):
        fields = re.findall(r'^\t(?:read )?(\w+): ', found.group(3), re.MULTILINE)
        types.append((found.start(), f'{found.group(1)} is a {found.group(2)}, and', fields))
    for _, name, fields in sorted(types):
        if fields:
            lines.append(f'  a {name} has: ' + ', '.join(fields))
    constants = re.findall(r'^' + module + r'\.([A-Z][A-Z0-9_]*) = ', text, re.MULTILINE)
    if constants:
        lines.append('  constants: ' + ', '.join(constants))
    functions = re.findall(r'^function ' + module + r'\.(\w+)(?:<[^>\n]*>)?\(', text, re.MULTILINE)
    if functions:
        lines.append('  functions: ' + ', '.join(functions))
    return module, '\n'.join(lines)


paths = []
for root, _, names in os.walk('src'):
    for name in sorted(names):
        if name.endswith('.luau') and 'Definitions' not in name and 'Looks' not in name:
            paths.append(os.path.join(root, name))

for path in sorted(paths, key=lambda p: os.path.basename(p)):
    module, sheet = sheet_for(path)
    if module in ('Main',):
        continue
    if not only or module in only:
        print(sheet)
        print()
