# Where things stand

As of the end of 2026-11-20. This file holds only what is true now. What is over is in `history/`. What comes next is in `next.md`.

## At a glance
| | |
|---|---|
| **Playable** | A first loop on grey boxes, for PC |
| **Code** | On the branch `dropped-items`, cut from `first-pieces`. Neither is merged, and nothing is pushed |
| **Checked** | `lune run tools/check` passes, with 2,054 test checks. The play test passes 83 of 83 in Studio, on the last code commit |
| **Not checked** | A phone. Two players. A real server. How a thrown item looks from another player's machine |
| **Waiting on the user** | To read the code. Then their feedback on the game. The open questions are in `asked-of-the-user.md` |
| **Approved, not built** | Prediction on the player's machine (`next.md`) |

## With the user
- **They have reviewed the code nine times,** eight of them on 2026-11-20. Their words are in `docs/working/code-reviews/`, and the page there lists what to check before showing them code.
- **The eighth found a fault in the shape, not in a name:** the game decides what every item does, where the item should. "Shouldnt it be the item itself that determines what happens when it breaks?" An audit the same day found twelve such promises with one root, and about sixty names with a word that should not be there (`docs/code/reviews/17-audit-after-the-eighth-review-2026-11-20.md`). Nothing is rebuilt yet: the shape is shown to them first.
- **The ninth set the direction:** items and placed objects are two systems that do not know each other, and what joins them is glue outside both. They also said to keep the code in Roblox's style, and that Claude may fetch the tools and skills it needs.
- **Everything they asked of the code in those reviews is done,** except prediction on the player's machine, which is next, and what they said to leave: `World` stays one big piece of glue, and `Station` stays a furnace until a second process shows what the kinds share. The stories are in `history/`.
- **Their last message of 2026-11-20 was answers, not a review.** Done from it that day:
  - seven functions brought to check, then act (`docs/code/conventions.md`);
  - a `Signal` piece, with the plot saying when an item is placed or taken off, and the world listening;
  - merging of ground items copied from Minecraft (`docs/game/dropped-items.md`);
  - a throw that goes up and down with the view in first person;
  - the notes and the memory cleaned up, which they said to do regularly.
- **They said yes to prediction on the player's machine,** "As long as its following the rest of the codebases standards".
- **Quality comes before speed.** Their words that day are at the top of `docs/working/engineering-rules.md`.
- **They have not read the code since the rewrite.** They judge it by two tests of their own: a class must make sense from its bare names with no context, and deleting one directory must not break the one beside it.
- **They are holding their feedback on the game until they have checked the code.** They played the first build on 2026-11-19 and said there is "a LOT of feedback and little issues / tweaks".

## What a player can do
Press Play in Studio and you appear by a grey plot, with a hotbar along the bottom. It is all grey boxes, laid out for a PC.

- **Ground items.** Stacks of items lie about, and walking over one picks it up, also off the top of a block beside you. Q throws one of what is in hand: along the ground the way the camera looks, or in first person the way the view looks, up and down as well. It falls, lands and comes to rest as any Roblox part does, about 7 studs ahead on flat ground. Items pass through each other and through players. Two stacks of one kind that lie close merge, the bigger taking in the smaller. A stack is gone after five minutes.
- **The pack.** E opens it. The inventory screen works as Minecraft's does:
  - a left click picks a stack up or puts it down, and a right click takes half or puts one down;
  - a double click fills the carried stack from every slot holding its kind;
  - dragging a carried stack across slots spreads it over them, in equal shares with the left button and one in each with the right;
  - Shift and a click sends a stack to the other inventory, or between the hotbar and the rest of the pack;
  - a number key over a slot swaps it with that hotbar slot;
  - a click outside the screen drops what is carried. A carried stack that does not fit the pack when the screen closes drops at the feet.
- **The plot** is marked out in tiles, and is shared by everyone. With a crate or a stove in hand, a faint block shows the tile it would stand on, and a left click places it. Items lying on that tile are pushed out of the nearest side with nothing against it. A placed thing in reach gets a white outline under the pointer.
- **A crate.** Clicking it opens it above the pack. Walking away closes it.
- **A stove** works as a Minecraft furnace does. Fish or apples go in the top slot and logs in the bottom one, and a cooked fish or a baked apple comes out on the right. One gauge shows the fire and another the work. A lit stove glows.
- **Hit.** A short right click on a placed thing knocks it off the plot. It spills out as an item, upwards and a little outwards, and so does each stack that was in a crate.

## What has been checked
- **The rules:** `lune run tools/check` passes: format, lint, strict types, requires, members, notes, 2,054 test checks and the demo.
- **Mutation testing** of each piece changed on 2026-11-20 leaves only changes no caller could see: `GroundItems` 133 of 136, `Direction` 13 of 13, `PlotCollision` 80 of 81, `InventoryRequests` 136 of 140, `World` 160 of 163, `Signal` 22 of 22. Every plain-Luau piece was last run together before the dropped-items work, at 1,475 of 1,527.
- **The delete test** (`python tools/delete_directory_test.py`): `players`, `plots` and `stations` do not break one another.
- **The play test** (`python tools/playtest.py`) passed 83 of 83 in Studio on 2026-11-20, on the last code commit. It drives a test character through every action in the list above, and reads the velocity a thrown block starts with in third person and in first (`docs/code/checks.md`).
- **The names** of seven classes were tested on 2026-11-20 on readers given nothing but the names, after the last code change: `GroundItems`, `Signal`, `Direction`, `Plot`, `PlayerState`, `InventoryScreen` and `World`. Every member of `Signal` read clear, and so did four of the five `can...` functions. One new name was doubted and changed: `movedIds` became `idsMovedSinceMerge`. `mergeItems` was read rightly, with a doubt about whether it merges every ground item or only some; it stands, and its comment says which. Older names that readers would not bet on are for the user's read of the code: `PlacedItem.itemId`, and a tile's `x` and `z` beside a position's.
- **Two reviewers read the merge and the first-person throw** on 2026-11-20 and found no bug. What they found is fixed: two comments that left a case out, two private functions named without a verb, a constant whose name did not say what it measured, and two gaps in the tests.
- **The server's and the client's scripts were read by four reviewers** on 2026-11-20, since they are not type-checked. The client's throw has changed since, and is covered by the play test.
- **By hand, on 2026-11-19,** driving a test character through Studio's connector: that a player keeps their pack when their character dies; that ground items vanish after five minutes; that a player who leaves while carrying a stack causes no error.

## What has not been checked
- **A phone, or any touch screen.**
- **Two players at once.** The crate is shared and each player is sent its changes, but nobody has watched two screens.
- **A real server.** In Studio there is no delay. On a real server the screen waits for the server's answer after each click.
- **The edge between first and third person.** The play test throws at a camera distance of half a stud and of twelve and a half. Exactly one stud, where the two meet, is checked by nothing: the choice sits in `Main.client`, which the tests in `tests/` cannot reach.

## Known problems
- **The hotbar's highlight, every click in the inventory, and a throw each wait for the server.** In Studio that is a frame or two. On a real server it is the player's ping, and nobody has measured it. Prediction on the player's machine is the fix, and is next.
- **The play test is spoiled by someone using the PC.** It drives Studio with the mouse and the keyboard for about four minutes, and Studio losing focus lets go of held keys.
- **A thrown block that clips the edge of a step as it falls can tumble about 20 studs,** where on flat ground it stops after 7.6. Roblox's physics does that with a cube; nothing of ours is involved. Seen from the spawn pad on 2026-11-20 (`docs/code/checks.md`).
- **The game decides what every item does.** A hit takes any placed item off the plot and drops it with every stack inside it; using one opens its inventory; a click on a tile with a placeable item in hand places it. An item cannot say otherwise: it is a row of flags that the rest of the code reads. The user's eighth review, and the first thing in `next.md`.
- **About sixty names have a word that should not be there:** an invented one, an `And`, `Or` or `If`, a noun that reads two ways, or one word for several ideas. Most are in the Roblox-side scripts and in private helpers. `throwPlacedItemAndContents` and `UseAndHit` are the two the user has met.
- **`World` still names stations,** and `Station` is a furnace under a general name (`docs/game/placed-items.md`). The user said to leave both for now.
- **A ground item pushed out of a tile is not checked where it lands.** One that lay across a corner of the tile can land partly inside a placed item on the tile diagonally across that corner.
- **A block placed where a thrown item is flying can miss it.** The world knows where each ground item was at the last tenth of a second.
- **The faint block shows on tiles the server will refuse,** such as the one the player stands on.
- **A ground item's block that falls out of the world is not noticed.** Roblox destroys the part, and the ground item stays in the rules until its five minutes are up. It cannot happen on the placeholder map.
- **Merging compares every ground item that was spawned or moved with every other,** ten times a second, and one that lies still every two seconds. Measured in Lune on 2026-11-20 with every item moving, which is the worst case: 0.3 milliseconds a pass at 100 items, 2.4 at 300, and 27 at 1,000 (`build/merge_pass_cost.luau`).
- **Left from the coupling review** (`docs/code/reviews/16-coupling-review-2026-11-20.md`), with when each is due in `next.md`: request names spelled as strings in `Main.client`; the furnace's three slots written into the screen's drawing code; `world.stations` kept in step with the plot by hand; `StationProgress` not checking the fire; `Main.client` reading the slot under the pointer from a drawing piece.
- **Left from the audits:** the inventory screen's drawing code does two jobs, the screen and the stove's panel; `PlaceholderWorld` keeps a timer in a module variable; `Plot.getTileAt` and `Plot.getTileCenter` take a corner where they could take the plot; `UseAndHit.startListening` both marks what the pointer is over and listens; `Inventory.addItems` returns how many went in while `Inventory.addStack` returns what did not fit.

## Not built
- **Prediction on the player's machine.** Approved, and next.
- **Saving.** A player's pack lasts until they leave. The shape of a save exists (`SaveData`), but nothing stores it (`docs/roblox/studio.md`). Ground items are never saved, by the user's choice.
- **A plot for each owner.** There is one plot, shared, and nobody owns what stands on it.
- **Touch controls,** and Hit on a phone.
