"""The user's test of coupling: delete one directory of the rules, and see what else stops working.

Run from the repository root: python tools/delete_directory_test.py

Works on a copy of src in a temporary folder, never on the repository. For each directory under
src/shared it deletes that directory from the copy, runs the strict type check on what is left of
src/shared, and lists which other directories now have errors, with the first error as the checker
words it. For the Roblox side (src/server and src/client, which are not type-checked) it lists the
scripts that require the deleted directory.

A directory may break the ones built on it. It must not break one beside it.
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
directories = sorted(name for name in os.listdir(SHARED) if os.path.isdir(os.path.join(SHARED, name)))


def luau_files(root):
    found = []
    for folder, _, names in os.walk(root):
        for name in names:
            if name.endswith('.luau'):
                found.append(os.path.join(folder, name))
    return sorted(found)


def requires_of(path):
    text = io.open(path, encoding='utf-8').read()
    found = set()
    for target in re.findall(r'require\(([^)]*)\)', text):
        target = target.strip()
        string = re.match(r'^"(.*)"$', target)
        if string:
            resolved = os.path.normpath(os.path.join(os.path.dirname(path), string.group(1)))
            relative = os.path.relpath(resolved, os.path.join(REPO, 'src')).replace('\\', '/')
            found.add(relative)
        else:
            dotted = re.sub(r':WaitForChild\("(\w+)"\)', r'.\1', target)
            shared = re.search(r'Shared\.([\w.]+)', dotted)
            if shared:
                found.add('shared/' + shared.group(1).replace('.', '/'))
    return found


roblox_side = {}
for side in ('server', 'client'):
    for path in luau_files(os.path.join(REPO, 'src', side)):
        relative = os.path.relpath(path, os.path.join(REPO, 'src')).replace('\\', '/')
        roblox_side[relative] = requires_of(path)

print('%-12s %-46s %s' % ('delete', 'rules that stop type-checking', 'Roblox-side scripts that require it'))
samples = {}
for directory in directories:
    work = tempfile.mkdtemp(prefix='delete-')
    try:
        shutil.copytree(os.path.join(REPO, 'src'), os.path.join(work, 'src'))
        shutil.copy(os.path.join(REPO, 'rokit.toml'), work)
        shutil.rmtree(os.path.join(work, 'src', 'shared', directory))
        files = [os.path.relpath(path, work).replace('\\', '/') for path in luau_files(os.path.join(work, 'src', 'shared'))]
        result = subprocess.run(['luau-lsp', 'analyze', '--platform=standard', '--flag:LuauSolverV2=true'] + files,
                                cwd=work, capture_output=True, text=True, encoding='utf-8', errors='replace')
        broken = {}
        for line in (result.stdout + result.stderr).splitlines():
            found = re.match(r'^src/shared/([\w/]+?)(?:/(\w+))?\.luau\((\d+),\d+\): (.*)$', line)
            if found and 'TypeError' in line:
                where = found.group(1) if found.group(2) else '(top level)'
                broken.setdefault(where, []).append(line)
        for lines in broken.values():
            samples.setdefault(directory, lines[0])
        scripts = sorted(script for script, targets in roblox_side.items()
                         if any(target.startswith('shared/' + directory + '/') for target in targets))
        print('%-12s %-46s %s' % (directory, ', '.join(sorted(broken)) or 'nothing', ', '.join(scripts) or 'none'))
    finally:
        shutil.rmtree(work, ignore_errors=True)

print()
print('What the first error looks like:')
for directory, line in samples.items():
    print('  delete %-10s %s' % (directory + ':', line))
