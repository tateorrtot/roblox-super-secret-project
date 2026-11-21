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
| `lune run tools/requires --chart` | Draws what requires what as a chart, `docs/code/requires.svg`. The check fails if the chart no longer matches the code |
| `python tools/reference.py` | Writes the class reference: a page for each module, from the comments in the code. `python -m mkdocs serve -f build/reference/mkdocs.yml` then serves it to a browser |
| `python tools/delete_directory_test.py` | Deletes each directory of the rules in a scratch copy, and lists what else stops working |
| `python tools/lift_out_test.py` | Copies each system into an empty folder with only what it requires, and runs its tests there. On 2026-11-20 all five passed alone: `items` with nothing, `inventory` with `items`, `plots` with `Position` and `Signal`, `groundItems` with `items` and `Position`, `players` with `inventory`, `items` and `Position` |
| `python tools/faces.py <out.txt> <modules...>` | The public face of modules: comments, types and signatures, with no bodies |
| `lune run tools/requires` | What requires what in `src`, read from the code |
| `python tools/members.py` | That every member and message the server's and client's scripts use exists |
| `python tools/notes.py` | That every path the notes mention exists, and that no notes file has grown too long |
| `python tools/studio.py <command>` | Drives Roblox Studio. `sync` does what `default.project.json` says. See `docs/roblox/studio.md` |

The user's PowerShell may need `~/.rokit/bin/lune` in place of `lune`.

## What is type-checked, and what is not
- **`src/shared`, `tests` and `demos` are type-checked** with `luau-lsp analyze --platform=standard --flag:LuauSolverV2=true`. That means no Roblox globals, and the new solver only, because read-only fields (`read`) are a syntax error under the old one. The two plain-Luau pieces in `src/client`, `SlotGestures` and `InventoryControls`, are checked through their tests.
- **`src/server` and `src/client` are formatted and linted, and not type-checked by `lune run tools/check`.** They can be checked by hand: Roblox's type definitions are downloaded, and `docs/roblox/studio.md` has the command. A run on 2026-11-20 gave seven reports in two places, none of them new. Until the check is part of the rest, mistakes there are found by `tools/members.py`, by that command and by the play test.

## The requires check
`lune run tools/requires` prints what requires what, folder by folder and module by module. It fails if:
- the rules require anything from the server or the client;
- the server and the client require each other;
- a folder or a module requires itself through others. The two `Main` scripts are left out of the folder rule, since they join everything.

Use it when the user asks which scripts and directories are coupled to which, and draw the diagram from its output, not from memory.

## The play test
`python tools/playtest.py` copies `src/` into Studio and makes the input actions, starts a play test, and drives the test character with keys, clicks and walking through the whole loop: the pack, dropping, picking up, the crate, placing, interacting and breaking, what the item in hand shows, dragging a stack across slots, reach, and baking an apple in the stove. After each step it checks what the screen shows and what is in the world. Then it stops the play test.

- 93 checks, in about five minutes. The last clean run was on 2026-11-20, after the clicks on the world moved to Roblox's input actions.
- It checks what marks the pointer's place: the see-through block of the item in hand, and the white outline. Each such check also asks the game's own `PlotPointer` what the pointer is over, so that "no outline" cannot pass because the pointer missed.
- Break is tried three ways on one crate: the right button held too long, a right click during which a script turns the camera, and a plain right click. Only the last breaks it.
- It first stands the test character on open ground, 10 studs past the spawn pad. A player spawns at a random spot on the pad, which is a stud high, and a block thrown from some of those spots clips the pad's edge as it falls and tumbles about 20 studs, where on open ground it comes to rest after 7.6. That spoiled one run on 2026-11-20 with four failures that had nothing to do with the code (`build/throw_from_places.py` shows it on demand).
- One step sends every request with nonsense, as a tampered machine might, and checks that nothing breaks.
- Another asks the server outright to interact with a crate and to break it from out of reach, checks that it refuses, and checks that the same request from within reach is carried out.
- A third counts how many times a player watching a lit stove is told what they hold, in three seconds. It was 27 before the gauges were sent as times, and must be 3 or fewer.
- It waits for thrown stacks to come to rest before it looks at them, and places a crate on a log to see the log pushed out.
- Its last steps tilt the camera and read the velocity a thrown block starts with: along the ground in third person however the camera is tilted, and the way the view looks in first person, up and then down. The camera's look is read at the moment Q goes down, so a mouse that moves cannot spoil the check.
- It is PC only.
- **Run it after any change to `src/server` or `src/client`.**

## The toolchain
- Rokit 1.2.0, in `~/.rokit/bin`. It is on the user's PATH; older shells need it prepended.
- Pinned in `rokit.toml`: Rojo 7.7.1, StyLua 2.6.0, Selene 0.32.0, luau-lsp 1.70.1 and Lune 0.11.1.
- In a non-interactive shell, run `rokit trust <tool>` before `rokit add`.
- Rokit's tools only run from inside the project directory.
- Python 3 is needed for the tools written in Python.

## Git
- Three branches, each cut from the one before and none merged: `first-pieces`, `dropped-items` and `placed-objects`, all of 2026-11-19 and 2026-11-20. `main` has no commits. The scripts and the input of 2026-11-20 are on `placed-objects` too.
- Work is committed as it is done. The user, 2026-11-19: "Yes, commit as you go".
- Nothing is pushed anywhere. Push only when the user asks.
