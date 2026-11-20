"""Measures every Luau file in src: how much is comment, how long its functions are, and how deep they nest.

Run from the repository root: python tools/metrics.py [--functions]
Nesting is counted from keywords (function, if, for, while, repeat), not from indentation.
"""
import os
import re
import sys

OPENERS = re.compile(r'\b(function|if|for|while|repeat)\b')
STRING = re.compile(r'"(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'|`(?:[^`\\]|\\.)*`')


def classify(lines):
    """Yields (kind, text) per line, kind one of blank, comment, code. Block comments are comments."""
    in_block = None
    for line in lines:
        stripped = line.strip()
        if in_block is not None:
            yield 'comment', line
            if in_block in stripped:
                in_block = None
            continue
        if stripped == '':
            yield 'blank', line
            continue
        match = re.match(r'--\[(=*)\[', stripped)
        if match:
            closer = ']' + match.group(1) + ']'
            if closer not in stripped[match.end():]:
                in_block = closer
            yield 'comment', line
            continue
        if stripped.startswith('--'):
            yield 'comment', line
            continue
        yield 'code', line


def strip_code(line):
    line = STRING.sub('""', line)
    cut = line.find('--')
    if cut >= 0:
        line = line[:cut]
    return line


def functions_of(lines):
    """Returns a list of (name, first line number, code lines, deepest control nesting)."""
    found = []
    stack = []  # entries: ['function', name, start, code lines, deepest] or ['block']
    for number, (kind, raw) in enumerate(classify(lines), start=1):
        if kind != 'code':
            continue
        line = strip_code(raw)
        for entry in stack:
            if entry[0] == 'function':
                entry[3] += 1
        tokens = re.findall(r'\b(function|if|then|elseif|else|for|while|repeat|until|do|end)\b', line)
        named = re.search(r'function\s+([\w.:]+)', line) or re.search(r'local\s+function\s+(\w+)', line)
        index = 0
        while index < len(tokens):
            token = tokens[index]
            if token == 'function':
                name = named.group(1) if named else '(anonymous)'
                named = None
                stack.append(['function', name, number, 1, 0])
            elif token in ('for', 'while'):
                stack.append(['block'])
            elif token == 'repeat':
                stack.append(['block'])
            elif token == 'if':
                # an if expression (if a then b else c) has no end; a statement does
                rest = line[line.find('if'):]
                is_statement = re.match(r'\s*if\b', line) is not None
                if is_statement:
                    stack.append(['block'])
            elif token == 'do':
                previous = tokens[index - 1] if index > 0 else None
                if previous not in ('for', 'while') and not re.search(r'\b(for|while)\b', line):
                    stack.append(['block'])
            elif token == 'until':
                if stack and stack[-1][0] == 'block':
                    stack.pop()
            elif token == 'end':
                if stack:
                    closed = stack.pop()
                    if closed[0] == 'function':
                        found.append((closed[1], closed[2], closed[3], closed[4]))
            index += 1
        depth = 0
        for entry in reversed(stack):
            if entry[0] == 'function':
                entry[4] = max(entry[4], depth)
                break
            depth += 1
    return found


def measure(path):
    with open(path, encoding='utf-8') as source:
        lines = source.read().split('\n')
    if lines and lines[-1] == '':
        lines.pop()
    kinds = [kind for kind, _ in classify(lines)]
    functions = functions_of(lines)
    return {
        'path': path.replace('\\', '/'),
        'total': len(lines),
        'comment': kinds.count('comment'),
        'blank': kinds.count('blank'),
        'code': kinds.count('code'),
        'functions': functions,
    }


def main():
    show_functions = '--functions' in sys.argv
    rows = []
    for root, _, names in os.walk('src'):
        for name in names:
            if name.endswith('.luau'):
                rows.append(measure(os.path.join(root, name)))
    rows.sort(key=lambda row: -row['total'])
    print(f"{'file':44} {'lines':>5} {'code':>5} {'comment':>7} {'%cmt':>5} {'funcs':>5}  longest function (code lines)      deepest nesting")
    totals = {'total': 0, 'code': 0, 'comment': 0}
    for row in rows:
        for key in totals:
            totals[key] += row[key]
        named = [f for f in row['functions'] if f[0] != '(anonymous)'] or row['functions']
        longest = max(named, key=lambda f: f[2], default=None)
        deepest = max(row['functions'], key=lambda f: f[3], default=None)
        share = 100 * row['comment'] / max(1, row['comment'] + row['code'])
        longest_text = f"{longest[0]} ({longest[2]})" if longest else '-'
        deepest_text = f"{deepest[3]} in {deepest[0]}" if deepest else '-'
        print(f"{row['path'][4:]:44} {row['total']:5} {row['code']:5} {row['comment']:7} {share:5.0f} {len(named):5}  {longest_text:34} {deepest_text}")
    share = 100 * totals['comment'] / (totals['comment'] + totals['code'])
    print(f"{'ALL OF src':44} {totals['total']:5} {totals['code']:5} {totals['comment']:7} {share:5.0f}")
    if show_functions:
        print()
        print('Functions of 25 code lines or more, or nesting 3 deep or more:')
        for row in rows:
            for name, start, length, depth in sorted(row['functions'], key=lambda f: f[1]):
                if length >= 25 or depth >= 3:
                    print(f"  {row['path'][4:]}:{start:<4} {name:40} {length:3} lines, nesting {depth}")


main()
