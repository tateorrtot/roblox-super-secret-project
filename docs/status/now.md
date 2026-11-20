# Where things stand

As of 2026-11-20. This file holds only what is true now. What is over is in `history/`.

## At a glance
| | |
|---|---|
| **Playable** | A first loop on grey boxes, for PC |
| **Code** | Rewritten and renamed on 2026-11-20 to the user's standard. Branch `first-pieces`, nothing pushed |
| **Checked** | `lune run tools/check` passes, with 1,786 test checks. Mutation testing catches 1,437 of 1,487 deliberate bugs |
| **Not checked** | The Roblox side of the final code has not been run. A phone. Two players. A real server |
| **Waiting on the user** | To open Studio. Their read of the rewritten code. Then their feedback on the game |

## With the user
- **They reviewed the code three times on 2026-11-20,** and everything they asked for is done and committed. Their words are in `docs/working/code-reviews/`. The story of the day is `history/2026-11-20-code-rewrite.md`.
- **They have not yet read the result.**
- **They are holding their feedback on the game until they have checked the code.** They played the first build on 2026-11-19 and said there is "a LOT of feedback and little issues / tweaks". Ask for their read of the code first, and then for that feedback.

## What a player can do
Press Play in Studio and you appear on a grey plot, with a hotbar along the bottom. It is all grey boxes, laid out for a PC.

- **Ground items.** Stacks of items lie about, and walking over one picks it up. Q drops one of what is in hand. A stack on the ground is gone after five minutes.
- **The pack.** E opens it. The inventory screen works as Minecraft's does:
  - a left click picks a stack up or puts it down, and a right click takes half or puts one down;
  - a double click fills the carried stack from every slot holding its kind;
  - dragging a carried stack across slots spreads it over them, in equal shares with the left button and one in each with the right;
  - Shift and a click sends a stack to the other inventory, or between the hotbar and the rest of the pack;
  - a number key over a slot swaps it with that hotbar slot;
  - a click outside the screen drops what is carried.
- **The plot** is marked out in tiles, and is shared by everyone. With a crate or a stove in hand, a faint block shows the tile it would stand on, and a left click places it. A placed thing in reach gets a white outline under the pointer.
- **A crate.** Clicking it opens it above the pack. Walking away closes it.
- **A stove** works as a Minecraft furnace does. Fish or apples go in the top slot and logs in the bottom one, and a cooked fish or a baked apple comes out on the right. One gauge shows the fire and another the work. A lit stove glows.
- **Hit.** A short right click on a placed thing knocks it off the plot. It lies on the ground as an item, and what was in a crate spills around it.

## What has been checked
- **The rules:** `lune run tools/check` passes: format, lint, strict types, requires, members, notes, 1,786 test checks and the demo.
- **Mutation testing** on every plain-Luau piece catches 1,437 of 1,487 deliberate bugs (`python build/mutate_all.py`). The 50 that survive are listed in `build/mutate-names.txt`, which is not kept in git. They are the wording of `ItemRegistry`'s error messages, changes that alter nothing a caller can see, exactly where each stack lands around a crate that is knocked over, and one guard against two requests sharing a name.
- **The names** were tested on readers given nothing but the names. See `history/2026-11-20-code-rewrite.md`.
- **By play, on 2026-11-19 and 2026-11-20,** driving a test character through Studio's connector: every action in the list above; that a player keeps their pack when their character dies; that ground items vanish after five minutes and fresh ones turn up; that a player who leaves while carrying a stack causes no error.

## What has not been checked
- **The Roblox side of the final code has not been run.** The play test passed 61 of 61 on the restructured code. The last audit's fixes and all of the renaming came after that, and Studio had been closed. Until it runs, the renames there rest on `tools/members.py` (every member and message the server's and client's scripts use exists) and on a one-off check that every request name the client and the play test send is one the rules define. **Run `python tools/playtest.py` first thing when Studio is open.**
- **A phone, or any touch screen.**
- **Two players at once.** The crate is shared and each player is sent its changes, but nobody has watched two screens.
- **A real server.** In Studio there is no delay. On a real server the screen waits for the server's answer after each click, and will feel a little late.

## Known problems
Three bugs found by reading, not yet reproduced in Studio and not fixed (`docs/code/reviews/15-code-double-check-2026-11-20.md`):
- A stack dropped while facing a placed block lands on top of it, out of reach from the ground.
- The faint block shows on tiles the server will refuse, such as the one the player stands on.
- A lit stove held open resends the whole pack about ten times a second.

Left from the audits and not done (`build/audit.json` has the full list, and is not kept in git):
- The inventory screen's drawing code does two jobs, the screen and the stove's panel, and finds the stove's parts by their place in a list.
- `PlaceholderWorld` keeps a timer in a module variable, and works out the plot's corner a second time.
- `Plot.getTileAt` and `Plot.getTileCenter` take a corner where they could take the plot.
- `UseAndHit.startListening` both marks what the pointer is over and listens for the two actions.
- `Inventory.addItems` returns how many went in, while `Inventory.addStack` returns what did not fit. Readers expected the same of both.

## Not built
- **Saving.** A player's pack lasts until they leave. The shape of a save exists (`SaveData`), but nothing stores it. In Studio the server's data store calls are refused until the user turns on a switch, and the storage library is not chosen (`docs/roblox/studio.md`). Ground items are never saved, by the user's choice.
- **Touch controls,** and Hit on a phone.
- **A plot of one's own.** There is one plot, shared, and nobody owns what stands on it.
- **Applying a click on the player's own machine before the server answers,** which is the fix for the delay on a real server (`next.md`).
