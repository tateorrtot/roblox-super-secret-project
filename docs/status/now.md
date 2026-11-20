# Where things stand

As of 2026-11-20. This file holds only what is true now. What is over is in `history/`.

## At a glance
| | |
|---|---|
| **Playable** | A first loop on grey boxes, for PC |
| **Code** | Rewritten and renamed on 2026-11-20 to the user's standard, on the branch `first-pieces`. Dropped items were rebuilt the same day on the branch `dropped-items`, which is not merged. Nothing pushed |
| **Checked** | On `dropped-items`: `lune run tools/check` passes, with 1,935 test checks, and the play test passes, 71 of 71 |
| **Not checked** | A phone. Two players. A real server. How a thrown item looks from another player's machine |
| **Waiting on the user** | To play with dropped items and read their code. Their read of the rewritten code. Then their feedback on the game |

## With the user
- **They reviewed the code three times on 2026-11-20,** and everything they asked for is done and committed. Their words are in `docs/working/code-reviews/`. The story of the day is `history/2026-11-20-code-rewrite.md`.
- **They have not yet read the result.**
- **They approved an outline of dropped items on 2026-11-20 and said to build it.** It is built, on the branch `dropped-items`. They have neither played nor read it. `git checkout first-pieces` goes back to the game without it.
- **They corrected how Claude works twice that day:** say an idea beyond what was asked and let them choose, while they are here; and use the engine before writing anything of our own (`docs/working/with-the-user.md`).
- **They are holding their feedback on the game until they have checked the code.** They played the first build on 2026-11-19 and said there is "a LOT of feedback and little issues / tweaks". Ask for their read of the code first, and then for that feedback.

## What a player can do
Press Play in Studio and you appear on a grey plot, with a hotbar along the bottom. It is all grey boxes, laid out for a PC.

- **Ground items.** Stacks of items lie about, and walking over one picks it up, also off the top of a block beside you. Q throws one of what is in hand out in front of you: it falls, lands and comes to rest as any Roblox part does, about 7 studs ahead. Items pass through each other and through players. A stack that lands by its own kind joins it. A stack is gone after five minutes.
- **The pack.** E opens it. The inventory screen works as Minecraft's does:
  - a left click picks a stack up or puts it down, and a right click takes half or puts one down;
  - a double click fills the carried stack from every slot holding its kind;
  - dragging a carried stack across slots spreads it over them, in equal shares with the left button and one in each with the right;
  - Shift and a click sends a stack to the other inventory, or between the hotbar and the rest of the pack;
  - a number key over a slot swaps it with that hotbar slot;
  - a click outside the screen drops what is carried.
- **The plot** is marked out in tiles, and is shared by everyone. With a crate or a stove in hand, a faint block shows the tile it would stand on, and a left click places it. Items lying on that tile are pushed out of the nearest side with nothing against it. A placed thing in reach gets a white outline under the pointer.
- **A crate.** Clicking it opens it above the pack. Walking away closes it.
- **A stove** works as a Minecraft furnace does. Fish or apples go in the top slot and logs in the bottom one, and a cooked fish or a baked apple comes out on the right. One gauge shows the fire and another the work. A lit stove glows.
- **Hit.** A short right click on a placed thing knocks it off the plot. It spills out as an item, upwards and a little outwards, and so does each stack that was in a crate.

## What has been checked
- **The rules:** `lune run tools/check` passes: format, lint, strict types, requires, members, notes, 1,935 test checks and the demo.
- **Mutation testing** of the pieces the dropped-items work touched catches 543 of 558 deliberate bugs (`python build/mutate_some.py`; the survivors are in `build/mutate-dropped-items.txt`, which is not kept in git). The survivors change nothing a caller can see, or sit exactly on an edge that no real position lands on. Every plain-Luau piece was last run together before this work, at 1,475 of 1,527 (`python build/mutate_all.py`).
- **The names** were tested on readers given nothing but the names. See `history/2026-11-20-code-rewrite.md`.
- **The play test** (`python tools/playtest.py`) passed 71 of 71 in Studio on 2026-11-20, on the code as it now stands. It drives a test character through every action in the list above, waits for thrown stacks to land, places a crate on a log to see it pushed out, and counts what a player watching a lit stove is sent.
- **The server's and the client's scripts were read by four reviewers** on 2026-11-20, since they are not type-checked: every name that crosses a file, every request against the function that answers it, every call from the server into the rules, and every comment. They found nothing that breaks or misbehaves, and a handful of comments that no longer matched the code, which are fixed.
- **The dropped-items pieces were read by readers with no context and by two reviewers** on 2026-11-20. What they found is in `history/2026-11-20-dropped-items.md`.
- **By hand, on 2026-11-19,** driving a test character through Studio's connector: that a player keeps their pack when their character dies; that ground items vanish after five minutes and fresh ones turn up; that a player who leaves while carrying a stack causes no error.

## What has not been checked
- **A phone, or any touch screen.**
- **Two players at once.** The crate is shared and each player is sent its changes, but nobody has watched two screens.
- **A real server.** In Studio there is no delay. On a real server the screen waits for the server's answer after each click, and will feel a little late.

## Known problems
- **The faint block shows on tiles the server will refuse,** such as the one the player stands on. Found by reading the code (`docs/code/reviews/15-code-double-check-2026-11-20.md`), and not fixed.
- **A ground item's block that falls out of the world is not noticed.** Roblox destroys the part, and the ground item stays in the rules, out of reach, until its five minutes are up. It cannot happen on the placeholder map, whose ground is 1,024 studs across.
- **Many items moving at once are compared pair by pair.** Each moving stack is checked against every other for joining, ten times a second. Nobody has measured where that gets slow; a reviewer put it at hundreds of items moving together.
- **`World.setPlayerPosition` does more than its name says.** It also takes the way the character faces, and works out how the player's drops set off. A reader with no context said so. The user's to decide.

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
