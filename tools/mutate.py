"""Mutation testing: makes one small deliberate bug at a time in a module and reports the ones the tests miss.

Needs Python 3 and the project's tools (run it from the repository root):

    python tools/mutate.py src/shared/inventory/Inventory.luau tests/inventory/Inventory.test.luau [more test files]

It works on a copy of `src` and `tests` in a temporary folder, never on the repository itself. For every
small change it can make to the module (a flipped comparison, a changed number, `and` for `or`, a deleted
line, and so on) it runs the given test scripts. A change the tests do not notice is a "survivor".

Each survivor is one of two things, and telling them apart takes a person:
- A gap in the tests. Add the check that would have caught it.
- A change no caller could ever see, such as `math.ceil` for `math.floor` in a test for a whole number.
"""
import io, os, re, shutil, subprocess, sys, tempfile, time

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
if len(sys.argv) < 3:
    print(__doc__)
    sys.exit(2)

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
module = sys.argv[1].replace('\\', '/')
tests = [t.replace('\\', '/') for t in sys.argv[2:]]

work = tempfile.mkdtemp(prefix='mutate-')
shutil.copytree(os.path.join(REPO, 'src'), os.path.join(work, 'src'))
shutil.copytree(os.path.join(REPO, 'tests'), os.path.join(work, 'tests'))
shutil.copy(os.path.join(REPO, 'rokit.toml'), work)  # so that the `lune` command works in the copy

path = os.path.join(work, module)
original = io.open(path, encoding='utf-8').read()
lines = original.split('\n')


def tests_notice():
    """Runs the tests in the copy. Returns True if any of them fails."""
    for test in tests:
        try:
            result = subprocess.run(['lune', 'run', test], cwd=work, capture_output=True, timeout=60)
        except subprocess.TimeoutExpired:
            return True
        if result.returncode != 0:
            return True
    return False


# Only code is changed: not comments, and not the insides of strings.
code_lines, in_block = [], False
for number, line in enumerate(lines):
    text = line.strip()
    if in_block:
        in_block = ']=]' not in text
        continue
    if text.startswith('--[=['):
        in_block = ']=]' not in text
        continue
    if text and not text.startswith('--'):
        code_lines.append(number)


def without_strings(line):
    """The line with the insides of its strings and any trailing comment blanked out, at the same length."""
    out, i, quote = [], 0, None
    while i < len(line):
        ch = line[i]
        if quote:
            if ch == '\\':
                out.append('  ')
                i += 2
                continue
            out.append(ch if ch == quote else ' ')
            if ch == quote:
                quote = None
        elif ch in '"\'':
            quote = ch
            out.append(ch)
        elif line.startswith('--', i):
            out.append(' ' * (len(line) - i))
            break
        else:
            out.append(ch)
        i += 1
    return ''.join(out)


CHANGES = [
    (r'<=', ['<']), (r'>=', ['>']), (r'(?<![<>=~])<(?![=])', ['<=']), (r'(?<![<>=~\-])>(?![=])', ['>=']),
    (r'==', ['~=']), (r'~=', ['==']),
    (r' \+ ', [' - ']), (r' - ', [' + ']), (r' \+= ', [' -= ']), (r' -= ', [' += ']),
    (r'math\.min', ['math.max']), (r'math\.max', ['math.min']),
    (r'math\.ceil', ['math.floor']), (r'math\.floor', ['math.ceil']),
    (r'\band\b', ['or']), (r'\bor\b', ['and']),
    (r'\btrue\b', ['false']), (r'\bfalse\b', ['true']),
    (r'\bnot ', ['']),
    (r'(?<![\w.])0(?![\w.])', ['1']), (r'(?<![\w.])1(?![\w.])', ['0', '2']), (r'(?<![\w.])2(?![\w.])', ['1', '3']),
    (r'\bnil\b', ['false']),
]
KEEP = ('function', 'local function', 'if ', 'elseif ', 'for ', 'while ', 'export type', 'type ', ')')

mutants = []
for number in code_lines:
    line = lines[number]
    code = without_strings(line)
    for pattern, replacements in CHANGES:
        for match in re.finditer(pattern, code):
            for replacement in replacements:
                changed = line[:match.start()] + replacement + line[match.end():]
                mutants.append((number, '%s -> %s' % (match.group(0).strip(), replacement.strip() or 'nothing'), changed))
    text = line.strip()
    structural = (text.startswith(KEEP) or text in ('end', 'else', 'end)', '}', '})', 'then', 'do')
                  or text.endswith(('{', '(', ',')) or ('= require(' in text))
    if not structural:
        mutants.append((number, 'line deleted', None))

print('%s: %d changes to try, against %s' % (module, len(mutants), ', '.join(os.path.basename(t) for t in tests)))
if tests_notice():
    print('The tests already fail on the unchanged copy. Fix that first.')
    shutil.rmtree(work, ignore_errors=True)
    sys.exit(1)

survivors, started = [], time.time()
for number, what, changed in mutants:
    mutated = lines[:]
    if changed is None:
        del mutated[number]
    else:
        mutated[number] = changed
    io.open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(mutated))
    if not tests_notice():
        survivors.append((number + 1, what, lines[number].strip()))
shutil.rmtree(work, ignore_errors=True)

caught = len(mutants) - len(survivors)
print('The tests caught %d of %d (%.0f%%) in %.0f seconds. %d survived:' % (
    caught, len(mutants), 100.0 * caught / max(1, len(mutants)), time.time() - started, len(survivors)))
for number, what, text in survivors:
    print('  line %3d  %-22s | %s' % (number, what, text[:110]))
