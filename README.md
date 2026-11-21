# The game

A sandbox game for Roblox, written in Luau. This folder is its own git repo. `CLAUDE.md` holds the rules for whoever changes the code. This page says what is here and how to run it.

## What is built, and what is only planned
| | |
|---|---|
| **Built, and playable in Roblox Studio** | One shared plot of tiles on grey boxes, for a PC. A pack and a hotbar. Stacks that are thrown and land. A crate that holds stacks. A stove that cooks |
| **Built, and not used by the game** | The libraries `inventory` and `ground-items`, in folders beside this one. `gyms/items` joins them. `src` still has an older inventory of its own |
| **Tried in a gym only** | A vehicle: a body of welded blocks on hinge wheels (`gyms/vehicles`) |
| **Not built** | Saving. A plot for each player. Any NPC. Any art. A phone or a gamepad. Anything a second player would need |

## Where the code is
```
src\shared\     the game's rules: plain Luau that never calls Roblox. 3,540 lines
src\server\     one Script, `Main.server.luau`, and the modules that draw the rules' world as parts
src\client\     one LocalScript, `Main.client.luau`, and the GUI
tests\          one test file for each file of src\shared. They run outside Roblox
gyms\           experiments. Nothing in src refers to them
tools\          the checks, and the driver for Roblox Studio
docs\           notes. `docs/README.md` says which folder holds what
```
`python tools/outline.py` prints every public function of every file.

## How to run it
The command-line tools (`lune`, `stylua`, `selene`, `luau-lsp`, `rojo`) are listed in `rokit.toml`. `rokit install` fetches them.

| To do this | Run this, in this folder |
|---|---|
| Check everything that runs outside Roblox: format, lint, strict types, which module requires which, every test | `lune run tools/check` |
| Send `src` to the place that is open in Roblox Studio | `python tools/studio.py sync` |
| Play the game | Press Play in Studio, after a sync |
| Run the play test: a script that plays the game in Studio, step by step, and checks each step | `python tools/playtest.py` |
| Run the items gym: the two libraries, joined by glue | `lune run gyms/items/loop`, then `lune run gyms/items/probe` |

- **The two commands that touch Studio need Roblox Studio open,** with its MCP server switched on (`docs/roblox/studio.md`).
- **`default.project.json` is a Rojo project,** so `rojo serve` also sends `src` to Studio. The play test was only ever run after `tools/studio.py sync`.
