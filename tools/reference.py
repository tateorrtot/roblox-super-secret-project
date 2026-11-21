"""Writes a browsable class reference, one page for each module, from the comments in the code itself.

Needs Python 3 and MkDocs (`python -m pip install mkdocs`). Run it from the repository root:

    python tools/reference.py
    python -m mkdocs serve -f build/reference/mkdocs.yml

The first command reads every module in `src` and writes a page for it under `build/reference/docs`, laid
out as a page of Godot's class reference is: a brief description, what the module requires and what requires
it, the description, the properties, the methods, the constants, and then each method's description. Every
word on a page is the comment that stands over that thing in the code. Where a comment names a module or a
member in backticks, the page links to it. The notes on how the code is written, in `docs/code`, are copied
in as the contributing pages. The second command serves the pages at http://127.0.0.1:8000, with a search
box, in the theme of Read the Docs. `python -m mkdocs build -f build/reference/mkdocs.yml` writes them as
plain HTML instead. Nothing it writes is kept in git: the code is the source.
"""
import io
import os
import re
import shutil
import sys

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(REPO, 'build', 'reference')
NEWLINE = chr(10)

# The three folders of `src`. Each is a section, and each folder inside it is a section within that.
FOLDERS = ['shared', 'server', 'client']


def strip_comment(line):
    """The words of one `---` comment line."""
    text = line.strip()[3:]
    return text[1:] if text.startswith(' ') else text


def as_paragraphs(comment_lines):
    """Comment lines as Markdown: a bare `---` starts a new paragraph, a list stays a list, and a Note stands out."""
    out = []
    for line in comment_lines:
        text = strip_comment(line)
        if text.startswith('Note:'):
            out.append('')
            text = '**Note:**' + text[5:]
        if text.startswith('- ') and out and not out[-1].startswith(('- ', '  ')):
            out.append('')
        out.append(text)
    return re.sub(r'\n{3,}', NEWLINE * 2, NEWLINE.join(out)).strip()


def read_block(lines, index):
    """The lines of a statement that begins at `index` and ends where its brackets close, and the index after it."""
    depth, block = 0, []
    while index < len(lines):
        line = lines[index]
        block.append(line)
        code = re.sub(r'"[^"]*"|`[^`]*`', '', line.split('--')[0])
        depth += sum(code.count(c) for c in '({[') - sum(code.count(c) for c in ')}]')
        index += 1
        if depth <= 0:
            break
    return block, index


def read_fields(block, prefix=''):
    """The fields written one to a line inside a table: (name, what follows the name, the comment over it).

    A field that is itself a table written over several lines is followed by its own fields, named `field.inner`.
    """
    fields, pending, index = [], [], 1
    while index < len(block) - 1:
        line = block[index]
        if line.startswith('\t---'):
            pending.append(line)
            index += 1
            continue
        found = re.match(r'^\t(?:read )?(\w+)(: | = )(.*)$', line)
        if found:
            nested, index = read_block(block, index)
            name, comment = prefix + found.group(1), as_paragraphs(pending)
            if len(nested) > 1 and found.group(3).rstrip() == '{':
                fields.append((name, 'table', comment))
                fields += read_fields([inner[1:] for inner in nested], name + '.')
            else:
                written = NEWLINE.join([found.group(3)] + [inner[1:] for inner in nested[1:]]).rstrip(',')
                fields.append((name, written, comment))
        else:
            index += 1
        pending = []
    return fields


def split_signature(signature):
    """The parameters of a function as written, brackets and all, and what it returns: '' for nothing."""
    start, depth = signature.index('('), 0
    for index in range(start, len(signature)):
        depth += (signature[index] == '(') - (signature[index] == ')')
        if depth == 0:
            return signature[start:index + 1], signature[index + 1:].lstrip(': ')
    return signature[start:], ''


def in_cell(text):
    """Text made safe to stand in one cell of a Markdown table."""
    return text.replace(NEWLINE, ' ').replace('|', '&#124;')


# Every module by its top folder and name: its page, its members' anchors, and the modules it requires.
MODULES = {}


def scan(path, folder):
    """Records what other pages need to know of one module: its page, its members, and what it requires."""
    top = folder.split('/')[0]
    module = os.path.basename(path).split('.')[0]
    members, requires = {}, []
    for line in io.open(path, encoding='utf-8').read().split(NEWLINE):
        for kind, pattern in [('method', r'^function ' + module + r'\.(\w+)'), ('type', r'^export type (\w+)'),
                              ('constant', r'^' + module + r'\.([A-Z][A-Z0-9_]*) = ')]:
            found = re.match(pattern, line)
            if found:
                members.setdefault(found.group(1), f'{kind}-{found.group(1)}')
        required = re.match(r'^local \w+ = require\((.+)\)\s*$', line)
        if required:
            argument = required.group(1)
            requires.append(('shared' if not argument.startswith('script') else top, re.findall(r'\w+', argument)[-1]))
    page_name = f'{folder.replace("/", "-")}-{module}.md'
    MODULES[(top, module)] = {'page': page_name, 'members': members, 'requires': requires, 'folder': folder}


def find_module(name, top):
    """The key of the module called `name` as a module in the folder `top` would mean it, or None."""
    for key in [(top, name), ('shared', name)]:
        if key in MODULES:
            return key
    return None


def link(text, top, module, own=None):
    """A comment with each backticked module or member that has a page or an anchor made into a link to it."""
    def replace(found):
        first, second = found.group(1), found.group(2)
        key = find_module(first, top)
        if key and not (key == (top, module) and second is None):
            info = MODULES[key]
            if second is None:
                return f'[`{first}`]({info["page"]})'
            if second in info['members']:
                target = '' if key == (top, module) else info['page']
                return f'[`{first}.{second}`]({target}#{info["members"][second]})'
            return found.group(0)
        members = MODULES[(top, module)]['members']
        if second is None and first != own and first in members:
            return f'[`{first}`](#{members[first]})'
        return found.group(0)
    return re.sub(r'`(\w+)(?:\.(\w+))?`', replace, text)


def module_links(keys):
    """A list of modules as links to their pages, by name, or the word nothing."""
    names = sorted(set(keys), key=lambda key: (key[1].lower(), key[0]))
    shared_names = [name for _, name in MODULES]
    return ', '.join(
        f'[{name} ({top})]({MODULES[(top, name)]["page"]})' if shared_names.count(name) > 1 else f'[{name}]({MODULES[(top, name)]["page"]})'
        for top, name in names
    ) or 'nothing'


def page_for(path, folder):
    """The Markdown page of one module, and its brief description."""
    lines = io.open(path, encoding='utf-8').read().split(NEWLINE)
    module = os.path.basename(path).split('.')[0]
    top = folder.split('/')[0]
    anchors = MODULES[(top, module)]['members']

    def linked(text, own=None):
        return link(text, top, module, own)
    index = 1 if lines and lines[0].startswith('--!') else 0
    header = []
    while index < len(lines) and lines[index].startswith('---'):
        header.append(lines[index])
        index += 1
    brief, _, description = as_paragraphs(header).partition(NEWLINE * 2)
    types, constants, functions, fields, pending = [], [], [], [], []
    while index < len(lines):
        line = lines[index]
        if line.startswith('---'):
            pending.append(line)
            index += 1
            continue
        comment = as_paragraphs(pending)
        pending = []
        if line.startswith('export type '):
            block, index = read_block(lines, index)
            name = re.match(r'export type (\w+)', line).group(1)
            types.append((name, NEWLINE.join(block), comment, read_fields(block)))
        elif re.match(r'^' + module + r'\.[A-Z][A-Z0-9_]* = ', line):
            block, index = read_block(lines, index)
            constants.append((line.split(' = ')[0][len(module) + 1:], NEWLINE.join(block).split(' = ', 1)[1], comment))
        elif line.startswith('function ' + module + '.'):
            block, index = read_block(lines, index)
            functions.append((re.match(r'function \w+\.(\w+)', line).group(1), ' '.join(b.strip() for b in block)[9:], comment))
        elif line == 'local ' + module + ' = {':
            block, index = read_block(lines, index)
            fields = read_fields(block)
        else:
            index += 1

    requires = [key for key in (find_module(name, where) for where, name in MODULES[(top, module)]['requires']) if key]
    required_by = [key for key, info in MODULES.items()
                   if (top, module) in [find_module(name, where) for where, name in info['requires']]]
    out = [f'# {module}', '', f'**File:** `{os.path.relpath(path, REPO).replace(os.sep, "/")}`', '', linked(brief), '',
           f'**Requires:** {module_links(requires)}', '', f'**Required by:** {module_links(required_by)}', '']
    if description:
        out += ['## Description', '', linked(description), '']
    if fields:
        out += ['## Properties', '', '| Property | Value |', '|---|---|']
        out += [f'| `{name}` | `{in_cell(written)}` |' for name, written, _ in fields] + ['']
    if types:
        out += ['## Types', '']
        for name, written, comment, type_fields in types:
            out += [f'### {name} {{#{anchors[name]}}}', '', linked(comment, name), '']
            if type_fields:
                out += ['| Type | Property | Description |', '|---|---|---|']
                out += [f'| `{in_cell(kind)}` | `{field}` | {in_cell(linked(about))} |' for field, kind, about in type_fields]
                out.append('')
            else:
                out += ['```lua', written, '```', '']
    if functions:
        out += ['## Methods', '', '| Returns | Method |', '|---|---|']
        for name, signature, _ in functions:
            parameters, returns = split_signature(signature)
            out.append(f'| `{in_cell(returns) or "nothing"}` | [{name}](#{anchors[name]}) `{in_cell(parameters)}` |')
        out.append('')
    if constants:
        out += ['## Constants', '']
        for name, value, comment in constants:
            out += [f'### {name} {{#{anchors[name]}}}', '', '```lua', f'{module}.{name} = {value}', '```', '', linked(comment, name), '']
    if functions:
        out += ['## Method Descriptions', '']
        for name, signature, comment in functions:
            out += [f'### {name} {{#{anchors[name]}}}', '', '```lua', signature, '```', '', linked(comment, name), '']
    return module, NEWLINE.join(out), in_cell(linked(brief))


def modules_in(folder):
    """The Luau files directly inside a folder of `src`, by name."""
    path = os.path.join(REPO, 'src', folder)
    return [os.path.join(path, name) for name in sorted(os.listdir(path)) if name.endswith('.luau')]


def folders_in(folder):
    """The folders directly inside a folder of `src`, by name."""
    path = os.path.join(REPO, 'src', folder)
    return [name for name in sorted(os.listdir(path)) if os.path.isdir(os.path.join(path, name))]


shutil.rmtree(OUT, ignore_errors=True)
os.makedirs(os.path.join(OUT, 'docs'))
home = ['# Class reference', '', 'Every module in `src`, by folder. `python tools/reference.py` reads each page from the code.', '']
nav = ['  - Home: index.md']
count = 0


def add_modules(folder, indent):
    """Writes the page of each module in a folder, and lists each in the menu. Returns their rows for the home page."""
    global count
    rows = []
    for path in modules_in(folder):
        module, page, brief = page_for(path, folder)
        page_name = f'{folder.replace("/", "-")}-{module}.md'
        io.open(os.path.join(OUT, 'docs', page_name), 'w', encoding='utf-8').write(page)
        rows.append(f'| [{module}]({page_name}) | {brief} |')
        nav.append(f'{indent}- {module}: {page_name}')
        count += 1
    return rows


for top in FOLDERS:
    for folder in [top] + [f'{top}/{inner}' for inner in folders_in(top)]:
        for path in modules_in(folder):
            scan(path, folder)

for top in FOLDERS:
    home += [f'## {top}', '']
    nav.append(f'  - {top}:')
    sections = [(top, add_modules(top, '    '))]
    for inner in folders_in(top):
        nav.append(f'    - {inner}:')
        sections.append((f'{top}/{inner}', add_modules(f'{top}/{inner}', '      ')))
    for name, rows in sections:
        if rows:
            home += [f'### {name}', '', '| Module | Description |', '|---|---|'] + rows + ['']

# The notes on how the code is written stand beside the reference, as Godot's contributing pages do.
home += ['## Contributing', '', '| Page | File |', '|---|---|']
nav.append('  - Contributing:')
for source in ['docs/code/names.md', 'docs/code/conventions.md', 'docs/code/comments.md', 'docs/code/pieces.md', 'docs/code/checks.md']:
    text = io.open(os.path.join(REPO, source), encoding='utf-8').read()
    title = text.split(NEWLINE)[0].lstrip('# ')
    page_name = 'contributing-' + os.path.basename(source)
    io.open(os.path.join(OUT, 'docs', page_name), 'w', encoding='utf-8').write(text)
    home.append(f'| [{title}]({page_name}) | `{source}` |')
    nav.append(f'    - "{title}": {page_name}')
home.append('')

io.open(os.path.join(OUT, 'docs', 'index.md'), 'w', encoding='utf-8').write(NEWLINE.join(home))
io.open(os.path.join(OUT, 'mkdocs.yml'), 'w', encoding='utf-8').write(NEWLINE.join([
    'site_name: Class reference', 'theme: readthedocs', 'docs_dir: docs', 'site_dir: site',
    'use_directory_urls: false', 'markdown_extensions:', '  - attr_list', 'nav:'] + nav) + NEWLINE)
print(f'wrote {count} pages to build/reference/docs')
