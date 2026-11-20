# Checks and tools

How the code is checked. Every command runs from the top of the repository.

| Command | What it does |
|---|---|
| `lune run tools/check` | Everything that needs no Studio: format, lint, strict types, the requires check, the members check, the notes check, every test and the demo |
| `lune run tests/inventory/Inventory.test.luau` | One test file alone |
| `python tools/playtest.py` | The end-to-end test of the Roblox side. Needs Studio open on the place, in Edit mode |
| `python tools/mutate.py <module> <tests...>` | Mutation testing: makes small deliberate bugs in one module and counts how many its tests catch |
| `python tools/metrics.py --functions` | For every file in `src`: how much is comment, its longest function and its deepest nesting |
| `python tools/unused.py` | The public functions nothing in the game calls |
| `python tools/outline.py` | Every public function and constant, with `--names` for bare names |
| `python tools/bare_names.py <Module>` | One class as a names test shows it: its name and its members' names, and nothing else |
| `python tools/delete_directory_test.py` | Deletes each directory of the rules in a scratch copy, and lists what else stops working |
| `python tools/faces.py <out.txt> <modules...>` | The public face of modules: comments, types and signatures, with no bodies |
| `lune run tools/requires` | What requires what in `src`, read from the code |
| `python tools/members.py` | That every member and message the server's and client's scripts use exists |
| `python tools/notes.py` | That every path the notes mention exists, and that no notes file has grown too long |
| `python tools/studio.py <command>` | Drives Roblox Studio. See `docs/roblox/studio.md` |

The user's PowerShell may need `~/.rokit/bin/lune` in place of `lune`.

## What is type-checked, and what is not
- **`src/shared`, `tests` and `demos` are type-checked** with `luau-lsp analyze --platform=standard --flag:LuauSolverV2=true`. That means no Roblox globals, and the new solver only, because read-only fields (`read`) are a syntax error under the old one. The two plain-Luau pieces in `src/client`, `SlotGestures` and `InventoryControls`, are checked through their tests.
- **`src/server` and `src/client` are formatted and linted, and not type-checked.** luau-lsp needs Roblox's type definitions file for that, and it is not downloaded (`docs/roblox/studio.md`). Until it is, mistakes there are found by `tools/members.py` and by the play test.

## The requires check
`lune run tools/requires` prints what requires what, folder by folder and module by module. It fails if:
- the rules require anything from the server or the client;
- the server and the client require each other;
- a folder or a module requires itself through others. The two `Main` scripts are left out of the folder rule, since they join everything.

Use it when the user asks which scripts and directories are coupled to which, and draw the diagram from its output, not from memory.

## The play test
`python tools/playtest.py` copies `src/` into Studio, starts a play test, and drives the test character with keys, clicks and walking through the whole loop: the pack, dropping, picking up, the crate, placing, using and hitting, dragging a stack across slots, reach, and baking an apple in the stove. After each step it checks what the screen shows and what is in the world. Then it stops the play test.

- 71 checks, in about two minutes.
- One step sends every request with nonsense, as a tampered machine might, and checks that nothing breaks.
- Another asks the server outright to use and to hit a crate from out of reach, checks that it refuses, and checks that the same request from within reach is carried out.
- A third counts how many times a player watching a lit stove is told what they hold, in three seconds. It was 27 before `StationProgress`, and must be 3 or fewer.
- It waits for thrown stacks to come to rest before it looks at them, checks that a throw goes the way the character faces, and places a crate on a log to see the log pushed out.
- It is PC only.
- **Run it after any change to `src/server` or `src/client`.**

## The toolchain
- Rokit 1.2.0, in `~/.rokit/bin`. It is on the user's PATH; older shells need it prepended.
- Pinned in `rokit.toml`: Rojo 7.7.1, StyLua 2.6.0, Selene 0.32.0, luau-lsp 1.70.1 and Lune 0.11.1.
- In a non-interactive shell, run `rokit trust <tool>` before `rokit add`.
- Rokit's tools only run from inside the project directory.
- Python 3 is needed for the tools written in Python.

## Git
- Branch `first-pieces`, and `dropped-items` cut from it on 2026-11-20 and not merged. `main` has no commits.
- Work is committed as it is done. The user, 2026-11-19: "Yes, commit as you go".
- Nothing is pushed anywhere. Push only when the user asks.
