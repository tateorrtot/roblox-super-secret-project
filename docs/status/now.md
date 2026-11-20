# Where things stand

As of 2026-11-20. This file holds only what is true now. What is over is in `history/`.

## At a glance
| | |
|---|---|
| **Playable** | A first loop on grey boxes, for PC |
| **Code** | Rewritten and renamed on 2026-11-20 to the user's standard, on the branch `first-pieces`. Dropped items were rebuilt the same day on the branch `dropped-items`, and untangled there after the user's fifth review. It is not merged. Nothing pushed |
| **Checked** | On `dropped-items`: `lune run tools/check` passes, with 1,946 test checks, and the play test passes, 71 of 71 |
| **Not checked** | A phone. Two players. A real server. How a thrown item looks from another player's machine |
| **Waiting on the user** | One choice: whether merging moves into `World.advanceTo` (`asked-of-the-user.md`). To read the untangled code. Then their feedback on the game |

## With the user
- **They have reviewed the code five times,** four of them on 2026-11-20. Their words are in `docs/working/code-reviews/`.
- **Everything from the first four is done.** The story is `history/2026-11-20-code-rewrite.md`.
- **The fifth came from playing dropped items.** They felt a delay when throwing, called `World.setPlayerPosition` spaghetti, could make nothing of the class `Throw` out of context, and asked for a review of the coupling. They then approved four things, and all four are done: the untangle of `setPlayerPosition`, handing ground items back to Roblox's ownership, and faults 2 to 4 of the review. The story is `history/2026-11-20-dropped-items.md`.
- **They have not read the untangled code.**
- **They judge code by two tests of their own:** a class must make sense from its bare names with no context at all, and deleting one directory must not break the one beside it (`docs/code/names.md`, `docs/code/conventions.md`). Their words: "maintainable straightforward easy to understand with no context decoupled code is much. much. much. more important than getting it to work right now."
- **They corrected how Claude works that day:** say an idea beyond what was asked and let them choose, while they are here; use the engine before writing anything of our own; and put the cost of a changed default to them first (`docs/working/with-the-user.md`).
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
- **The rules:** `lune run tools/check` passes: format, lint, strict types, requires, members, notes, 1,946 test checks and the demo.
- **Mutation testing** of the nine pieces the untangle touched catches 841 of 870 deliberate bugs (`python build/mutate_some.py`; the survivors are in `build/mutate-untangled.txt`, which is not kept in git). The survivors change nothing a caller can see, or sit exactly on an edge that no real position lands on. Every plain-Luau piece was last run together before this work, at 1,475 of 1,527 (`python build/mutate_all.py`).
- **The delete test** (`python tools/delete_directory_test.py`): `players`, `plots` and `stations` do not break one another. Only `world`, `requests` and the Roblox side need them.
- **The names** were tested on readers given nothing but the names. See `history/2026-11-20-code-rewrite.md`.
- **The play test** (`python tools/playtest.py`) passed 71 of 71 in Studio on 2026-11-20, on the code as it now stands. It drives a test character through every action in the list above, waits for thrown stacks to land, places a crate on a log to see it pushed out, and counts what a player watching a lit stove is sent.
- **The server's and the client's scripts were read by four reviewers** on 2026-11-20, since they are not type-checked: every name that crosses a file, every request against the function that answers it, every call from the server into the rules, and every comment. They found nothing that breaks or misbehaves, and a handful of comments that no longer matched the code, which are fixed.
- **The dropped-items pieces were read by readers with no context and by two reviewers** on 2026-11-20, and again after the untangle. What they found is in `history/2026-11-20-dropped-items.md`.
- **By hand, on 2026-11-19,** driving a test character through Studio's connector: that a player keeps their pack when their character dies; that ground items vanish after five minutes and fresh ones turn up; that a player who leaves while carrying a stack causes no error.

## What has not been checked
- **A phone, or any touch screen.**
- **Two players at once.** The crate is shared and each player is sent its changes, but nobody has watched two screens.
- **A real server.** In Studio there is no delay. On a real server the screen waits for the server's answer after each click, and will feel a little late.

## Known problems
- **Two functions of `World` do more than their names say.** `World.spawnStack` also merges the new stack into a ground item of its kind beside it, and can return that one's id. `World.setGroundItemPosition` also merges, so the ground item it was given can be gone afterwards. Claude wrote both in the untangle, and a reviewer caught them. Claude's proposal is that merging happens in `World.advanceTo`. That changes when stacks merge and what merging costs, so it is the user's to choose (`asked-of-the-user.md`).
- **The hotbar's highlight waits for the server.** Fix 4 of the coupling review made the server the one keeper of the selected slot, so a number key moves the highlight when the server's answer arrives: one trip there and back. In Studio that is a frame or two. On a real server it is the player's ping, and nobody has measured it. For that long, a click on a tile is judged by the player's machine against the slot it still shows.
- **The coupling review's other six faults are not fixed** (`docs/code/reviews/16-coupling-review-2026-11-20.md`). `World` also holds rules that could be pieces of their own: the push out of a tile, and which placed items are stations.
- **A ground item pushed out of a tile is not checked where it lands.** One that lay across a corner of the tile can land partly inside a placed item on the tile diagonally across that corner. It takes two placed items around that corner already.
- **A block placed where a thrown item is flying can miss it.** The world knows where each ground item was at the last tenth of a second.
- **A character looking exactly straight up or down is not told to the world,** which keeps what it last knew. A Roblox character does not do that by walking about.
- **The faint block shows on tiles the server will refuse,** such as the one the player stands on. Found by reading the code (`docs/code/reviews/15-code-double-check-2026-11-20.md`), and not fixed.
- **A ground item's block that falls out of the world is not noticed.** Roblox destroys the part, and the ground item stays in the rules, out of reach, until its five minutes are up. It cannot happen on the placeholder map, whose ground is 1,024 studs across.
- **Every ground item that moved is compared with every other for merging,** ten times a second. Measured in Lune on this machine with every item moving: 0.3 milliseconds a pass at 100 items, 2.4 at 300, and 27 at 1,000, which is a quarter of a core (`build/merge_pass_cost.luau`).

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
