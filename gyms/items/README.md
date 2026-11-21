# The items gym

Tried on the night of 2026-11-21, after two libraries were built by sessions that were told nothing of this game.

## What it tries
Whether the `inventory` and `ground-items` libraries, which know nothing of this game or of each other, join into the game's first loop with glue alone. If they do, the game's rules for items can be rebuilt as short functions that call one library and then another.

## How to run it
`lune run gyms/items/loop`, from the repository's root. It needs no Studio. `gyms/.luaurc` gives the two libraries the names `@inventory` and `@drops`, which `lune` reads and Roblox does not: a gym is not sent to Studio. `lune run gyms/items/probe` probes the two libraries for the faults that their review found.

## What is in `loop.luau`
| Part | Lines | What it is |
|---|---|---|
| Content | 15 | The kinds of item: each one's limit, and whether it is fuel. Neither library holds this list |
| A character's items | 4 | `newActor`: a pack of 36 slots, a hotbar that is a list of the pack's first nine slots, the number of the selected slot, and a held stack. A player and a helper are both made by it |
| What a person asks for | 42 | Seven functions: `pickUp`, `pickUpHalf`, `putDown`, `putDownOne`, `swap`, `spread`, `gather`. Each is one or two calls of the library, and each takes the slot itself |
| A mover | 11 | `moveStack`: asks how much fits, takes that much, adds it. A person's quick move, a hopper, and a helper's hands all call it |
| Dropping and picking up | 38 | `dropFromSlot`, `pickUpNear`, and `mergeStacks`, the rule that is handed to the ground. The one place where the two libraries meet |
| The loop | 150 | A script that plays the loop and checks each step |

## What was found
- **Every step held:** 36 checks, and at six points a count of every item in the pack, the crate, the stove, the helper's pack, both hands, and the ground showed that none was made or lost.
- **About 95 lines of glue do the jobs of three of the game's modules.** `InventoryScreen.luau` (335 lines), `Hotbar.luau` (57), and the picking up and dropping in `World.luau`. The glue does not check what a client sent, which `InventoryRequests.luau` (482 lines) does, so the two are not the same size of job.
- **A stove's rule holds for a mover.** The hopper moved no stone into the stove and sent coal to the fuel slot, by the slots' own rules. In the game's own code, a mover put 5 stone into the stove's input slot, because the rule was kept on a player's screen.
- **A helper needs no code of its own.** It took planks out of the stove and carried them to the crate with `moveStack`, the function that a player's quick move uses.
- **Any number of inventories.** A held stack was spread over slots of the pack and of the crate in one call. No type pairs an inventory with a number, and nothing counts how many are open.
- **Mended and probed:** of the faults that the review found, six were probed here and are mended: a merge that missed near drops, a drop at an infinite place, a list with a gap that was saved short, a rule for a slot that does not exist, a mover that lost items, and a limit that is a fraction. A seventh, a reach with an infinite component, raised no error, and this probe could not tell whether it merges.

## What was not tried
- **Roblox.** The libraries and this gym ran under `lune` only. Nothing was synced to Studio, and no client or server took part.
- **The door.** Nothing here checks a value from a client, and nothing tells a client what changed.
- **Drawing.** No slot was drawn.
- **Items with data of their own,** such as a worn tool. The library has none, and lists it as open.
