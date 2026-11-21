# Where things stand

As of the end of 2026-11-20. This file holds only what is true now. What is over is in `history/`. What comes next is in `next.md`.

## At a glance
| | |
|---|---|
| **Playable** | A first loop on grey boxes, for PC |
| **Code** | On the branch `placed-objects`, cut from `dropped-items`, which was cut from `first-pieces`. None is merged, and nothing is pushed |
| **Checked** | `lune run tools/check` passes, with 2,247 test checks. The play test passed 93 of 93 in Studio one commit before the last. The last commit changed only the rules, and it was not run again |
| **Not checked** | A phone. A gamepad. Two players. A real server. How a thrown item looks from another player's machine |
| **Waiting on the user** | To read the code. Then their feedback on the game. The open questions are in `asked-of-the-user.md` |
| **Approved, not built** | Prediction on the player's machine (`next.md`) |

## With the user
- **They have reviewed the code twelve times,** eleven of them on 2026-11-20. Their words are in `docs/working/code-reviews/`, and the page there lists what to check before showing them code.
- **The twelfth was of Claude's answers to the eleventh.** They approved a crate carrying its own inventory, which is built. They asked what a station is and why the word is in the code; why `CrateItem` does not hold the crate item's id, stack size and look; whether picking up could leave the ground items' module, which it has; and how free placement would work. Claude proposed two next pieces and asked which comes first (`asked-of-the-user.md`).
- **The eleventh was of one script, `CrateItem`:** "who said an item was always going to be tied to a player. Or a hotbar?" It now knows neither. In the same message they proposed that what a character holds be a Roblox `Tool`, apart from the items, and asked who said tiles were flat. Neither is built, and each waits on their word (`asked-of-the-user.md`).
- **The tenth was about how Claude breaks a problem up:** "Systems shouldnt know about eachother. Dont pull out abstractions. ... You compose simple things and systems together and use glue code." It began with a table Claude had kept, `PlaceableItems`, which let an item in the hand do one thing only.
- **What was built in answer** is in `history/2026-11-20-scripts-and-input.md`: a script for each item and for each kind of placed object, the game's own things in a folder that no system requires, and the clicks on the world on Roblox's input actions. They have read none of it. Its shared machinery was written without being shown first, on their "Just keep it generic" and "Yes that sounds good": the names and shapes that are Claude's are in `claudes-calls.md`.
- **`World` stays one piece of glue,** by their word, and is getting smaller: it no longer keeps a crate's inventory. `Station` was to stay a furnace until a second process showed what the kinds share; they have since asked why the word is in the code.
- **They said yes to prediction on the player's machine,** "As long as its following the rest of the codebases standards".
- **Quality comes before speed.** Their words are at the top of `docs/working/engineering-rules.md`.
- **They judge the code by tests of their own:** a class must make sense from its bare names with no context; deleting one directory must not break the one beside it; each piece could be a decoupled FoxFabric addon.
- **They are holding their feedback on the game until they have checked the code.** They played the first build on 2026-11-19 and said there is "a LOT of feedback and little issues / tweaks".

## What a player can do
Press Play in Studio and you appear by a grey plot, with a hotbar along the bottom. It is all grey boxes, laid out for a PC. None of it changed on 2026-11-20 when the code under it was split twice.

- **Ground items.** Stacks of items lie about, and walking over one picks it up, also off the top of a block beside you. Q throws one of what is in hand: along the ground the way the camera looks, or in first person the way the view looks, up and down as well. It falls, lands and comes to rest as any Roblox part does, about 7 studs ahead on flat ground. Items pass through each other and through players. Two stacks of one kind that lie close merge, the bigger taking in the smaller. A stack is gone after five minutes.
- **The pack.** E opens it. The inventory screen works as Minecraft's does:
  - a left click picks a stack up or puts it down, and a right click takes half or puts one down;
  - a double click fills the carried stack from every slot holding its kind;
  - dragging a carried stack across slots spreads it over them, in equal shares with the left button and one in each with the right;
  - Shift and a click sends a stack to the other inventory, or between the hotbar and the rest of the pack;
  - a number key over a slot swaps it with that hotbar slot;
  - a click outside the screen drops what is carried. A carried stack that does not fit the pack when the screen closes drops at the feet.
- **The plot** is marked out in tiles, and is shared by everyone. With a crate or a stove in hand, a faint block shows the tile it would stand on, and a left click places it. Items lying on that tile are pushed out of the nearest side with nothing against it. A placed object in reach gets a white outline under the pointer.
- **A crate.** Clicking it opens it above the pack. Walking away closes it.
- **A stove** works as a Minecraft furnace does. Fish or apples go in the top slot and logs in the bottom one, and a cooked fish or a baked apple comes out on the right. One gauge shows the fire and another the work. A lit stove glows.
- **Break.** A short right click on a crate or a stove breaks it. It comes off the plot and leaves a crate or a stove on the ground as an item, thrown upwards and a little outwards, and so is each stack that was in it. Holding the right button, or turning the camera with it, breaks nothing.

## What has been checked
- **The rules:** `lune run tools/check` passes: format, lint, strict types, requires, members, notes, 2,247 test checks in 33 files, and the demo.
- **The folders are systems, glue and things** (`docs/code/pieces.md`). `python tools/delete_directory_test.py`: deleting `content` breaks none of the rules; deleting a system breaks only the glue and the things built on it; and deleting `inventory` no longer breaks `groundItems`.
- **A script is held to its functions by the type checker.** A stove whose `interact` took a string was refused at the line that registers it.
- **Mutation testing** of each piece changed on 2026-11-20 leaves only changes no caller could see. The last run of each: `Crate` 32 of 32, `CrateItem` 10 of 10, `Stove` 27 of 27, `StoveItem` 10 of 10, `Plot` 80 of 81, `GroundItems` 140 of 141, `World` 153 of 155, `PlotRequests` 46 of 46, `ItemScripts` 14 of 14, `PlacedObjectScripts` 10 of 10, `Content` 9 of 9, `PlayerState` 36 of 36, `RecipeRegistry` 38 of 38, `PlayerSnapshot` 25 of 27, `Inventory` 202 of 209, `Direction` 13 of 13, `PlotCollision` 80 of 81, `InventoryRequests` 136 of 140, `Signal` 22 of 22.
- **The play test** (`python tools/playtest.py`) passed 93 of 93 in Studio on 2026-11-20, on the commit that moved picking up into the world. The commit after it changed only the rules. It drives a test character through every action in the list above, checks what the item in hand shows and what the outline is around, and reads the velocity a thrown block starts with in third person and in first (`docs/code/checks.md`).
- **Six classes were read by helpers shown nothing but their names,** and three reviewers read the work. 28 findings: 14 mended, 1 corrected in the notes, 13 left. What was left is below, and the whole account is in `history/2026-11-20-scripts-and-input.md`. The user is stricter than any reader: the names are for their read.
- **The crate and the pick-up were reviewed by two helpers, and three classes read cold:** 16 findings, 7 mended, 8 left, 1 not agreed with (`history/2026-11-20-crate-and-pick-up.md`). What was left is below.
- **The server's and the client's scripts** were type-checked by hand with Roblox's definitions: seven reports in two places, all older than this work (`docs/code/checks.md`).
- **What Roblox's input actions do** was measured in Studio before they were used (`docs/roblox/input.md`).
- **By hand, on 2026-11-19,** driving a test character through Studio's connector: that a player keeps their pack when their character dies; that ground items vanish after five minutes; that a player who leaves while carrying a stack causes no error.

## What has not been checked
- **A phone, or any touch screen.** A tap is read from `UserInputService`, and whether it also fires the input action bound to the left mouse button is not known. If it does, a tap interacts twice.
- **A gamepad.** No button is bound: there is no pointer to say what is interacted with.
- **A click on the world in first person.** The play test throws there and does not click.
- **Two players at once.** The crate is shared and each player is sent its changes, but nobody has watched two screens.
- **A real server.** In Studio there is no delay. On a real server the screen waits for the server's answer after each click.
- **The edge between first and third person.** The play test throws at a camera distance of half a stud and of twelve and a half. Exactly one stud is checked by nothing.

## Where general code still decides for every kind of thing
Found by the reviewer who applied the user's test, and left. Each is a place where adding a thing would mean changing a system or the glue.
- **`World` keeps a station for each stove, and advances every one.** A crate carries its own inventory; a stove does not yet carry what it is made of. A kind that does something new as time passes needs `World` changed. It is the next piece (`next.md`).
- **The word `station` is in the code for one furnace:** a folder, a type, two registries keyed by a kind of station, `Stove.STATION_KIND_ID`, a store in `World`, and a field in what a player's machine is told. The user asked why.
- **What a player's machine is told has a field for a station's progress,** and the inventory screen draws the furnace's gauges for any other inventory of three slots. A second kind of screen needs the screens to be the kind's own.
- **The server's `PlotParts` makes any station that burns glow.**
- **An item's script is told of one thing: a bare tile interacted with.** An item used on the open air, or on a placed object, needs a new request and a new function of the script. That is one change for each new sort of target, and none for each new item.
- **An item's script can say only how many of itself were used up.** A bucket that fills, or a tool that wears, needs more.
- **How far a character reaches is one number in the request, for every thing.**
- **The two ghosts on the player's machine each ask reach for themselves,** while the server asks it once in the request. `Main.client` already works out what is in reach, for the outline.
- **A tile is two loose numbers, `tileX` and `tileZ`, in twelve files,** and a placed object is a cube on one whole-numbered tile. The user asked who said tiles were flat: Claude did. They had said the grid should be a guide and not a boundary (`docs/game/decisions.md`).
- **An item's facts are in three files, joined by its id as a string:** its row in `ItemDefinitions`, its look in `ItemLooks`, and its script. `Crate.ITEM_ID_WHEN_BROKEN` spells the id again. The user looked for them in `CrateItem`.
- **Picking up is eight private lines of `World`,** which grew by them.
- **`GroundItems` holds how near a picker must be, and how long a ground item waits.** A second thing that picks up, with a reach of its own, would need them handed in.
- **`World` decides when a screen on any placed object closes:** when the object is taken off the plot, and when the player walks away.
- **`PlaceholderWorld` casts a placed object to a crate** to reach its inventory. A lookup in `Crate` would spare it, with the next change to the server's scripts.
- **`PlayerState` is a pack, a hotbar, an open screen and a character's position in one record.**
- **`PlaceholderWorld`, on the server, names the crate, the stove and five items.** It goes when there is a real map.
- **What each item shows while selected is a table in `Main.client`,** asked every frame. It is a second list of the game's things, beside `Content.register`.
- **Five comments in the systems use the game's own things as examples.**

## Known problems
- **The hotbar's highlight, every click in the inventory, and a throw each wait for the server.** In Studio that is a frame or two. On a real server it is the player's ping, and nobody has measured it. Prediction on the player's machine is the fix.
- **A request is sent for every click on the world,** at any distance and with any item in hand, and the server's script decides. The server allows each machine 60 requests a second.
- **The keys and the inventory screen's mouse still go through `UserInputService`,** while the clicks on the world are input actions.
- **The play test is spoiled by someone using the PC.** It drives Studio with the mouse and the keyboard for about five minutes, and Studio losing focus lets go of held keys.
- **A thrown block that clips the edge of a step as it falls can tumble about 20 studs,** where on flat ground it stops after 7.6. Roblox's physics does that with a cube; nothing of ours is involved (`docs/code/checks.md`).
- **About sixty names have a word that should not be there:** an invented one, an `And`, `Or` or `If`, a noun that reads two ways, or one word for several ideas. Most are in the Roblox-side scripts and in private helpers (`docs/code/reviews/17-audit-after-the-eighth-review-2026-11-20.md`).
- **A ground item pushed out of a tile is not checked where it lands.** One that lay across a corner of the tile can land partly inside a placed object on the tile diagonally across that corner.
- **An object placed where a thrown item is flying can miss it.** The world knows where each ground item was at the last tenth of a second.
- **The faint block shows on tiles the server will refuse,** such as the one the player stands on.
- **A ground item's block that falls out of the world is not noticed.** Roblox destroys the part, and the ground item stays in the rules until its five minutes are up. It cannot happen on the placeholder map.
- **Merging compares every ground item that was spawned or moved with every other,** ten times a second, and one that lies still every two seconds. Measured in Lune on 2026-11-20 with every item moving: 0.3 milliseconds a pass at 100 items, 2.4 at 300, and 27 at 1,000 (`build/merge_pass_cost.luau`).
- **Left from the coupling review** (`docs/code/reviews/16-coupling-review-2026-11-20.md`), with when each is due in `next.md`: request names spelled as strings in `Main.client`; `StationProgress` not checking the fire; `Main.client` reading the slot under the pointer from a drawing piece.
- **Left from the audits:** the inventory screen's drawing code does two jobs, the screen and the stove's panel; `PlaceholderWorld` keeps a timer in a module variable; `Plot.getTileAt` and `Plot.getTileCenter` take a corner where they could take the plot; `Inventory.addItems` returns how many went in while `Inventory.addStack` returns what did not fit.

## Not built
- **Prediction on the player's machine.** Approved.
- **Saving.** A player's pack lasts until they leave. The shape of a save exists (`SaveData`), but nothing stores it (`docs/roblox/studio.md`). Ground items are never saved, by the user's choice.
- **A plot for each owner.** There is one plot, shared, and nobody owns what stands on it.
- **Touch controls,** and break on a phone.
