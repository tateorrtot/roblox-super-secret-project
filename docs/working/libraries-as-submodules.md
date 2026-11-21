# A library inside the game, as a git submodule

For the user to read before deciding how the game holds its libraries. Their rule, 2026-11-21: "The main project should keep clones of the libraries in itself not point to some other folder by climbing up a chain of directories", and "If you dont have the same code/directories/scripts as the library. Youre not using the library youre using some weird fork inspired by it." Of a submodule: "That sounds interesting ... I think I got some learning to do." Nothing here is decided or built in the game. Every command below was run that night in a scratch folder, `build\submodule-trial`.

## What a submodule is
A git repo held inside another git repo, at one fixed commit. The Godot counterpart is an addon's folder under `addons`, when that folder is its own clone and not a pasted copy.
- **The game's repo does not store the library's files.** It stores one line: which commit of the library it uses. In the trial that line was `160000 commit 33ff69f... src/shared/libraries/inventory`.
- **The folder on disk is a full clone of the library.** Its files are the library's own, at that commit. Nothing is copied by hand, so nothing can drift without git saying so.
- **A file named `.gitmodules`,** in the game's repo, says where each library comes from.

## What the game's folder would look like
```
main-project\
├─ .gitmodules                          where each library comes from
├─ default.project.json
└─ src\shared\
   ├─ libraries\
   │  ├─ inventory\                     a clone of the inventory library, at one commit
   │  │  ├─ src\  Inventory.luau, Slot.luau, Stack.luau
   │  │  ├─ tests\, demos\, docs\, tools\, README.md
   │  └─ ground-items\                  the same
   └─ systems\
      └─ Items.luau                     require("../libraries/inventory/src/Inventory")
```
The require goes up one folder and down again, and never leaves the game's own folder. It does climb out of `systems`. By the folder guideline that is a system reaching a lower layer, which is allowed.

## The commands
| To do this | Run this, in `main-project` |
|---|---|
| Add a library | `git -c protocol.file.allow=always submodule add C:/Users/tate/Documents/dev/roblox/inventory src/shared/libraries/inventory`, then commit |
| See which commit each library is at | `git submodule status` |
| Take the library's newest commit | `git -C src/shared/libraries/inventory pull`, then commit the game: the one line changes |
| Clone the game somewhere new, with its libraries | `git clone --recurse-submodules <the game's address>` |
| After pulling the game | `git submodule update --init` |

- **`-c protocol.file.allow=always` is needed** because the library is a folder on this PC and not an address on the internet. Git refuses that for a submodule unless it is told to allow it.
- **The address in `.gitmodules` is a path on this PC.** Once the libraries are on GitHub, it becomes their address there, and the flag is not needed.

## What was tried, and what happened
1. **Adding it worked,** and the game's repo recorded the library's commit, `33ff69f`, the same one the library's own repo was at.
2. **`lune` ran a system that requires the library** by `../libraries/inventory/src/Inventory`: "logs in the bag: 100".
3. **Rojo built a place with the library in it.** With the library's project file as the template writes it, the place held `Shared.libraries.inventory.Inventory`, with no `src` folder between. The path in Roblox then differs from the path on disk, and one require cannot serve both.
4. **With a project file in the library that keeps the `src` folder,** the place held `Shared.libraries.inventory.src.Inventory`: the same path as on disk. The library's `tests`, `tools`, and `docs` were not sent to the place in either build.
5. **A change to a library's file inside the game shows up** in the game's `git status`, as ` m src/shared/libraries/inventory`. So a library that was edited in place cannot pass unnoticed.

## What it costs
- **Two commits for one change to a library:** one in the library, and one in the game to move the line.
- **A plain `git clone` of the game leaves the library folders empty.** It needs `--recurse-submodules`, or `git submodule update --init` after it.
- **GitHub Desktop** shows a submodule as one changed entry, and commits made inside it are made in the library's own repo.
- **The library's whole repo sits inside `src\shared`,** with its tests, docs, and tools. The game's own checks must leave those folders alone.

## The other ways, and why they are weaker for your rule
| Way | What it is | Against your rule |
|---|---|---|
| A copy that one command refreshes | The library's `src` is copied into the game and committed there | The copy can be edited, and nothing says so unless a check compares it with the library |
| `git subtree` | The library's files and history are merged into the game's repo | The files are the game's own from then on, so they can drift in the same way |
| Wally, the package manager for Roblox | The game names a version, and a tool downloads it into `Packages` | It wants a published package. For a folder on this PC it has nothing documented (`docs/research/23-roblox-first-local-libraries.md`) |

## Not tried
- **The place was built and not run.** No script was run inside Studio from a submodule.
- **`python tools/studio.py sync`,** the game's own way of sending code to Studio, reads `default.project.json` itself. Whether it follows a project file inside a library is not checked.
- **The game's `lune run tools/check`** was not run with a library inside `src\shared`.
- **A library's own project file would change** to the one of step 4, in the template and in each library. Not done.
