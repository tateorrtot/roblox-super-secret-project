"""Lifts each system of src/shared out by itself, with only what it requires, and runs its tests there.

Needs Python 3 and the project's tools (run it from the repository root):

    python tools/lift_out_test.py

A system is meant to be a piece that could be copied into another game. For each one this copies its folder,
the folders and loose modules it requires, and its tests into an empty temporary folder, and runs the tests
there. It prints what had to come with the system, and whether its tests pass with nothing else beside it.
`tools/delete_directory_test.py` asks the opposite question: what breaks when a folder goes.
"""
import io
import os
import re
import shutil
import subprocess
import sys
import tempfile

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHARED = os.path.join(REPO, 'src', 'shared')
SYSTEMS = ['items', 'inventory', 'plots', 'groundItems', 'players']


def requires_of(path):
    """The modules that the file at `path` requires, as paths relative to src/shared without the extension."""
    found = []
    text = io.open(path, encoding='utf-8').read()
    for target in re.findall(r'require\("([^"]+)"\)', text):
        full = os.path.normpath(os.path.join(os.path.dirname(path), target))
        found.append(os.path.relpath(full, SHARED).replace('\\', '/'))
    return found


def unit_of(module):
    """The folder a module is in, or the module itself for one that lies loose in src/shared."""
    return module.split('/')[0] if '/' in module else module


def files_of(unit):
    folder = os.path.join(SHARED, unit)
    if os.path.isdir(folder):
        return [os.path.join(folder, name) for name in sorted(os.listdir(folder))]
    return [os.path.join(SHARED, unit + '.luau')]


def closure(unit):
    needed, todo = [], [unit]
    while todo:
        current = todo.pop()
        if current in needed:
            continue
        needed.append(current)
        for path in files_of(current):
            for module in requires_of(path):
                todo.append(unit_of(module))
    return needed


for system in SYSTEMS:
    needed = closure(system)
    work = tempfile.mkdtemp(prefix='lift-' + system + '-')
    shutil.copy(os.path.join(REPO, 'rokit.toml'), work)
    for unit in needed:
        for path in files_of(unit):
            target = os.path.join(work, os.path.relpath(path, REPO))
            os.makedirs(os.path.dirname(target), exist_ok=True)
            shutil.copy(path, target)
    os.makedirs(os.path.join(work, 'tests', system))
    shutil.copy(os.path.join(REPO, 'tests', 'Check.luau'), os.path.join(work, 'tests'))
    results = []
    for name in sorted(os.listdir(os.path.join(REPO, 'tests', system))):
        shutil.copy(os.path.join(REPO, 'tests', system, name), os.path.join(work, 'tests', system))
        run = subprocess.run(['lune', 'run', f'tests/{system}/{name}'], cwd=work, capture_output=True, text=True,
                             encoding='utf-8', errors='replace', shell=(os.name == 'nt'))
        lines = [line for line in (run.stdout + run.stderr).splitlines() if line.strip()]
        results.append((name, run.returncode == 0, lines[-1] if lines else '(no output)'))
    with_it = [unit for unit in needed if unit != system]
    lines_of_code = sum(len(io.open(p, encoding='utf-8').read().splitlines()) for u in needed for p in files_of(u))
    print(f'{system}: comes with {", ".join(sorted(with_it)) if with_it else "nothing"} ({lines_of_code} lines in all)')
    for name, ok, last in results:
        print(f'   {"ok  " if ok else "FAIL"} {name}: {last}')
    shutil.rmtree(work, ignore_errors=True)
