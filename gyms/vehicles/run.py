"""Runs the vehicle gym in Studio and prints what each body did.

Run from the repository's root, with Studio open on the place:  python gyms/vehicles/run.py
It starts a play test, builds two bodies, drives each through phases, takes a screenshot of each into
build/gyms, and stops the play test. It does not take the mouse.
"""
import io
import json
import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(REPO, 'build', 'gyms')
LF = chr(10)


def studio(*arguments):
    """Runs tools/studio.py with `arguments` and returns what it printed."""
    done = subprocess.run([sys.executable, os.path.join(REPO, 'tools', 'studio.py'), *arguments],
                          capture_output=True, text=True, cwd=REPO, encoding='utf-8', errors='replace')
    return (done.stdout + done.stderr).strip()


def read(name):
    return io.open(os.path.join(HERE, name), encoding='utf-8').read()


def run(name, datamodel, header=''):
    """Runs one script of this folder in Studio, with `header` put above it, and returns the result."""
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, 'vehicles_' + name)
    io.open(path, 'w', encoding='utf-8', newline=LF).write(header + LF + read(name))
    return studio('run', path, datamodel)


def drive_module():
    """The text of Drive.luau as it can stand inside a script: no `export`, and no `return` at its end."""
    lines = [line.replace('export type', 'type') for line in read('Drive.luau').split(LF)]
    lines = [line for line in lines if line.strip() != 'return Drive']
    return LF.join(lines)


def phases(rows):
    """Luau source for a list of phases."""
    parts = []
    for row in rows:
        cut = ', cut = "%s"' % row['cut'] if 'cut' in row else ''
        parts.append('{ name = "%s", seconds = %s, command = { throttle = %s, steer = %s }%s }'
                     % (row['name'], row['seconds'], row['throttle'], row['steer'], cut))
    return 'local PHASES = { ' + ', '.join(parts) + ' }'


PLANS = {
    'A': [
        {'name': 'rest', 'seconds': 1, 'throttle': 0, 'steer': 0},
        {'name': 'straight ahead', 'seconds': 3.5, 'throttle': 1, 'steer': 0},
        {'name': 'turn right', 'seconds': 3, 'throttle': 0.6, 'steer': 1},
        {'name': 'cut the cargo loose', 'seconds': 1.5, 'throttle': 0.6, 'steer': 0, 'cut': 'Cargo'},
        {'name': 'reverse', 'seconds': 2.5, 'throttle': -0.7, 'steer': 0},
        {'name': 'stop', 'seconds': 2, 'throttle': 0, 'steer': 0},
    ],
    'B': [
        {'name': 'rest', 'seconds': 1, 'throttle': 0, 'steer': 0},
        {'name': 'straight ahead', 'seconds': 3, 'throttle': 0.8, 'steer': 0},
        {'name': 'turn right as a tank', 'seconds': 3, 'throttle': 0.3, 'steer': 0.8},
        {'name': 'spin on the spot', 'seconds': 2, 'throttle': 0, 'steer': 1},
        {'name': 'stop', 'seconds': 2, 'throttle': 0, 'steer': 0},
    ],
}

if __name__ == '__main__':
    print(studio('play'))
    time.sleep(6)
    results = {'built': run('build.server.luau', 'Server')}
    for vehicle in sys.argv[1:] or ['A', 'B']:
        name = 'local VEHICLE = "%s"' % vehicle
        results['camera before ' + vehicle] = run('camera.client.luau', 'Client', name)
        studio('shot', os.path.join(OUT, 'vehicle_%s_before.png' % vehicle))
        results[vehicle] = run('drive.server.luau', 'Server', drive_module() + LF + name + LF + phases(PLANS[vehicle]))
        results['camera after ' + vehicle] = run('camera.client.luau', 'Client', name)
        time.sleep(0.5)
        studio('shot', os.path.join(OUT, 'vehicle_%s_after.png' % vehicle))
    print(studio('stop'))
    for key, value in results.items():
        print('=== ' + key)
        try:
            print(json.dumps(json.loads(value), indent=1))
        except ValueError:
            print(value)
