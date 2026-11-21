"""Checks the comments in `src` against the rules in `docs/code/comments.md` that a script can check.

Run from the repository root:

    python tools/comments.py                      every module in src
    python tools/comments.py src/shared/plots     the modules under one folder, or one file
    python tools/comments.py --report             also counts the sentences that look passive

It fails if a module has no description or a brief description of more than 200 characters, if a public
function, an exported type, a field of an exported type or a constant has no comment, if a function that
returns a value never says "Returns", or if a comment uses a word the rules ban. Whether a comment is true,
complete and well put is for a reader to judge: this only catches what can be matched.
"""
import io
import os
import re
import sys

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NEWLINE = chr(10)
BRIEF_LIMIT = 200

# A word or phrase that no comment uses, and what the rules say of it.
BANNED = [
    (r'\b(obvious|obviously|simple|simply|basic|basically|easy|easily|actual|actually|just|clear|clearly|however)\b',
     'a word that adds nothing'),
    (r'\bthe (former|latter)\b', 'name the thing again'),
    (r"\bplayer'?s'? (own )?machines?\b|\b(their|other|another|each|every) machines?\b", 'the word is client'),
    (r"\bgame's (own )?things\b", 'the word is content'),
    (r'\bfurnaces?\b', 'the word is stove'),
    (r'\b(Fired|Emitted) (when|after|once)\b', 'a signal fires: "Fires after ..."'),
    (r'\b20\d\d-\d\d-\d\d\b|\bused to\b', 'a comment says what is, never what was'),
    (r'\bthe \w+ of the \w+ of\b', "use 's"),
    (r'\b(Minecraft|Godot|Factorio|Terraria)\b', 'a comment never points at another game or engine'),
]
PASSIVE = r'\b(is|are|was|were|be|been) (\w+ed|given|taken|put|made|sent|kept|told|shown|drawn|thrown|left|held|set)\b'


def without_code(text):
    """A comment's words with whatever stands in backticks taken out."""
    return re.sub(r'`[^`]*`', '`code`', text)


def words_of(lines):
    return ' '.join(line.strip()[3:].strip() for line in lines)


def check(path):
    relative = os.path.relpath(path, REPO).replace(os.sep, '/')
    module = os.path.basename(path).split('.')[0]
    lines = io.open(path, encoding='utf-8').read().split(NEWLINE)
    problems, passive, sentences = [], 0, 0

    start = 1 if lines and lines[0].startswith('--!') else 0
    header = []
    while start + len(header) < len(lines) and lines[start + len(header)].startswith('---'):
        header.append(lines[start + len(header)])
    if not header:
        problems.append((start + 1, 'the module has no description'))
    else:
        brief = []
        for line in header:
            if line.strip() == '---':
                break
            brief.append(line)
        if len(words_of(brief)) > BRIEF_LIMIT:
            problems.append((start + 1, f'the brief description is {len(words_of(brief))} characters, over {BRIEF_LIMIT}'))

    pending, in_type, depth = [], False, 0
    for number, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped.startswith('--') and not stripped.startswith('--!'):
            text = without_code(stripped.lstrip('-'))
            for pattern, why in BANNED:
                for found in re.finditer(pattern, text, re.IGNORECASE if 'Fired' not in pattern else 0):
                    problems.append((number, f'"{found.group(0)}": {why}'))
            passive += len(re.findall(PASSIVE, text))
        if stripped.startswith('---'):
            pending.append(line)
            continue
        comment = words_of(pending)
        sentences += len(re.findall(r'[.!?:](\s|$)', comment))
        named = None
        if re.match(r'^function ' + module + r'\.\w+', line):
            named = 'the function ' + re.match(r'^function \w+\.(\w+)', line).group(1)
            signature, index = line, number
            while signature.count('(') > signature.count(')') and index < len(lines):
                signature += lines[index]
                index += 1
            returns = re.search(r'\)\s*:\s*\S', signature[signature.index('('):]) is not None
            if pending and returns and not re.search(r'\b[Rr]eturns?\b', comment):
                problems.append((number, f'{named} returns a value, and its comment never says "Returns"'))
        elif line.startswith('export type '):
            named = 'the type ' + re.match(r'export type (\w+)', line).group(1)
            in_type = stripped.endswith('{')
            depth = 0
        elif re.match(r'^' + module + r'\.[A-Z][A-Z0-9_]* = ', line):
            named = 'the constant ' + line.split(' = ')[0]
        elif in_type and depth == 1 and re.match(r'^\t(read )?\w+: ', line):
            named = 'the field ' + re.match(r'^\t(?:read )?(\w+)', line).group(1)
        if named and not pending:
            problems.append((number, f'{named} has no comment'))
        if in_type:
            code = re.sub(r'"[^"]*"', '', line)
            depth += code.count('{') - code.count('}')
            if depth <= 0 and not line.startswith('export type '):
                in_type = False
        pending = []
    return relative, problems, passive, sentences


arguments = [argument for argument in sys.argv[1:] if not argument.startswith('--')]
report = '--report' in sys.argv
roots = arguments or ['src']
paths = []
for root in roots:
    full = os.path.join(REPO, root)
    if os.path.isfile(full):
        paths.append(full)
        continue
    for folder, _, names in os.walk(full):
        paths += [os.path.join(folder, name) for name in names if name.endswith('.luau')]

total, total_passive, total_sentences = 0, 0, 0
for path in sorted(paths):
    relative, problems, passive, sentences = check(path)
    total += len(problems)
    total_passive += passive
    total_sentences += sentences
    for number, problem in problems:
        print(f'{relative}:{number}: {problem}')
    if report and passive:
        print(f'{relative}: {passive} of about {sentences} sentences look passive')

if report:
    print(f'{total_passive} of about {total_sentences} sentences look passive')
print(f'{len(paths)} modules, {total} problems' if total else f'{len(paths)} modules, no problems')
sys.exit(1 if total else 0)
