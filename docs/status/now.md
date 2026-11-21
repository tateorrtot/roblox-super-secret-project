# Where things stand

As of 2026-11-21. This file holds only what is true now. What is over is in `history/`. What comes next is in `next.md`.

## At a glance
| | |
|---|---|
| **Playable** | A first loop on grey boxes, for PC |
| **Code** | On the branch `placed-objects`, cut from `dropped-items`, which was cut from `first-pieces`. None is merged, and nothing is pushed |
| **Checked** | `lune run tools/check` passes, with 2,285 test checks. The play test passed 93 of 93 in Studio on the last commit that touched the server or the client |
| **Not checked** | A phone. A gamepad. Two players. A real server. How a thrown item looks from another client |
| **Waiting on the user** | To read the code. Then their feedback on the game. The open questions are in `asked-of-the-user.md` |
| **Approved, not built** | Prediction on the client (`next.md`) |

## With the user
- **They have reviewed the code eighteen times,** thirteen of them on 2026-11-20. Their words are in `docs/working/code-reviews/`, and the page there lists what to check before showing them code.
- **The seventeenth was of the comment Claude had just rewritten:** "I think you might've just done it again." Its nouns pointed at nothing: "What is one slot? [Didnt you literally define it as an argument!]" One comment is written again as the sample, with each noun an argument, a field, a type, or a value, and the rest wait on their word. They then said the function under it was two jobs baked into one. It is taken apart: the request calls `Inventory.takeFromSlot` and `Inventory.addStack`, "the pattern for code im looking for". In the eighteenth they asked who said a player has only two inventories open, and named a hopper that moves items with no player. `side` is out of the rules: only the requests take the word. They then gave the rule for a system: "an inventory has *no* idea it has anything to do with a backpack. Or a chest. Or a stove", and it can be pulled out into another game. `Inventory` passes that; `Hotbar` and `InventoryScreen`, in its folder, do not (`next.md`).
- **The sixteenth was of one page of the class reference,** the first they opened: `InventoryRequests.moveFromSlotToInventory`. They could not read it: "what the hell is a side", code that looked like broken links, each word said twice, and a signature of seven values. Nor could they tell what Claude meant by "a look piece". Mended the same day: how a page is drawn, 138 repeated words, "Raises an error" for "Fails", and four examples that run. Theirs to rule on: `screen` and `side`, Claude's words for a thing of the rules, which sound like UI (`asked-of-the-user.md`).
- **The fifteenth, and their message after it,** took the colour out of the content, said how an item looks, and gave the model for plots: placed objects that hold together on a body, with building and physics as two systems joined by glue. Claude's reading is theirs: "Yes! That physics diagram is what I mean." What is cut loose becomes a plot of its own. They asked whether "Plot" is the best word, and Claude answered (`asked-of-the-user.md`).
- **The tenth to the fourteenth reviews** gave the shape the code has now: strong systems, and content that glues them, one thing to a script; a script for each item and each kind of placed object, content in one folder that no system requires, one table for each item, and a crate and a stove that carry what they are made of (`docs/working/code-reviews/README.md`). The shared machinery of the tenth was written without being shown first; the names and shapes that are Claude's are in `claudes-calls.md`.
- **`World` stays one piece of glue,** by their word, and is smaller: 384 lines, from 408. It keeps nothing for what stands on its plot.
- **They said yes to prediction on the client,** "As long as its following the rest of the codebases standards".
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
- **The rules:** `lune run tools/check` passes: format, lint, strict types, requires, members, notes, 2,285 test checks in 29 files, and the demo.
- **The folders are systems, glue and things** (`docs/code/pieces.md`). `python tools/delete_directory_test.py`: deleting `content` breaks none of the rules, and deleting a system breaks only the glue and the things built on it. `python tools/lift_out_test.py`: each of the five systems passes its own tests in a folder that holds only it and what it requires.
- **A script is held to its functions by the type checker.** A stove whose `interact` took a string was refused at the line that registers it.
- **Mutation testing** of each piece changed on 2026-11-20 leaves only changes no caller could see. The last run of each: `Stove` 187 of 193, `Crate` 33 of 33, `CrateItem` 10 of 10, `StoveItem` 10 of 10, `Items` 10 of 10, `ItemRegistry` 34 of 41, `Content` 5 of 5, `Plot` 80 of 81, `GroundItems` 140 of 141, `World` 146 of 148, `PlacedObjectScripts` 29 of 29, `PlayerSnapshot` 35 of 38, `PlotRequests` 46 of 46, `ItemScripts` 14 of 14, `InventoryRequests` 136 of 140, `PlayerState` 36 of 36, `Inventory` 202 of 209, `Direction` 13 of 13, `PlotCollision` 80 of 81, `Signal` 22 of 22.
- **The play test** (`python tools/playtest.py`) passed 93 of 93 in Studio on 2026-11-21, after `moveFromSlotToInventory` was taken apart. It drives a test character through every action in the list above, checks what the item in hand shows and what the outline is around, and reads the velocity a thrown block starts with in third person and in first (`docs/code/checks.md`).
- **Six classes were read by helpers shown nothing but their names,** and three reviewers read the work. 28 findings: 14 mended, 1 corrected in the notes, 13 left. What was left is below, and the whole account is in `history/2026-11-20-scripts-and-input.md`. The user is stricter than any reader: the names are for their read.
- **The crate and the pick-up were reviewed by two helpers, and three classes read cold:** 16 findings, 7 mended, 8 left, 1 not agreed with (`history/2026-11-20-crate-and-pick-up.md`).
- **The item tables and the stove were reviewed by three helpers, and four classes read cold:** 27 findings, 12 mended, 11 left, 4 not agreed with (`history/2026-11-20-item-tables-and-the-stove.md`).
- **The Models were reviewed by two helpers:** 19 findings, 5 mended, 12 left, 2 not agreed with (`history/2026-11-20-models-and-the-reference.md`). What was left is below.
- **The colour's removal was reviewed by one helper:** 1 finding, a comment, mended. 2 notes left: the stand-in grey is written in four places, and one comment could name `PlaceholderBlock.COLOR` in full.
- **The split was reviewed by two helpers,** one for the code and one for the comments of three pages: 23 findings, 21 mended, 1 left, 1 not agreed with. Left: the client sends an empty list where it once sent nothing. Not agreed with: that an argument's line may not say "the player". One mend is in part: the real stove's slots are reached by the request only in the play test.
- **The class reference** is made by `python tools/reference.py` from the comments in the code: 53 modules, and the four notes on the code as its contributing pages.
- **Every comment in `src` follows the comment guide** (`docs/code/comments.md`), and `lune run tools/check` fails for a missing comment, a banned word, or a word followed by an argument of the same name (`history/2026-11-21-the-comment-pass.md`). A page of the reference links each module, member and type it names, and `Plot`, `Inventory`, `InventoryScreen` and `InventoryRequests` each have an example that runs. Three pages are written to the stricter standard that the user set on 2026-11-21, in which every noun is an argument, a field, a type, or a value: `InventoryRequests`, `PlotRequests`, and four functions of `Inventory`. The other modules are not.
- **The pages are still hard to read cold.** On 2026-11-21 four fresh readers each read one page and said what each function does. Of 47 functions on the pages of `Plot`, `Stove`, `InventoryScreen` and `InventoryRequests`, they were sure of 31 and guessed at 16. After the day's mends four more readers were sure of 29 and guessed at 18, which is no better. A guess is a failure. They guessed at words that another page explains, such as pack and carried stack, at long sentences with several conditions, and at names that say something else, such as `screen`.
- **The server's and the client's scripts** were type-checked by hand with Roblox's definitions: six reports in one place, all older than this work (`docs/code/checks.md`).
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
- **An item's script is told of one thing: a bare tile interacted with.** An item used on the open air, or on a placed object, needs a new request and a new function of the script. That is one change for each new sort of target, and none for each new item.
- **An item's script can say only how many of itself were used up.** A bucket that fills, or a tool that wears, needs more.
- **How far a character reaches is one number in the request, for every thing.**
- **The two ghosts on the client each ask reach for themselves,** while the server asks it once in the request. `Main.client` already works out what is in reach, for the outline.
- **A plot is one flat grid, fixed in the world.** A tile is two loose numbers, `tileX` and `tileZ`, in twelve files, and a placed object stands on one whole-numbered tile of the ground. Nothing can be placed on top of another thing or in mid-air, the plot cannot move or turn, and nothing falls. The user has pointed at this four times, and on 2026-11-21 said what they want in its place (`next.md`).
- **Nothing lets an item say how it looks.** General code draws every item as one plain grey block with its name: `StackIcon` in a slot, and `GroundItemParts` on the ground. The user has said what an item's look is (`docs/game/decisions.md`), and it needs art to build.
- **The stand-in grey is written in four places:** `PlaceholderBlock`, `GroundItemParts`, `PlacementGhost` and `StackIcon`. Two are on the server and two on the client, and each goes when its thing has art.
- **A kind's Model stands on one tile.** `PlotParts` puts its pivot on the tile's middle, and nothing lets a kind be larger, or turned.
- **A ghost is a see-through block,** not the kind's own Model.
- **The id of the item that a broken crate leaves is written twice:** in `CrateItem` and in `Crate.ITEM_ID_WHEN_BROKEN`. The two files cannot require each other. The same holds for the stove.
- **Hand-written lists name the content on each side:** `Items.ALL` and `PlacedObjectKinds.ALL` in the rules, a table in `Main.server` of the pieces that make each kind's Model, and two in `Main.client`. `Main.server` fails at the start if a kind has no piece.
- **`CrateItem.interactWithTile` and `StoveItem.interactWithTile` are the same four lines,** and so are the two ghosts but for the kind. One shared function, when a third item places.
- **A stove cooks only if whoever makes a world connects `timePassed`** to `PlacedObjectScripts.advancePlacedObjects`. `Main.server` does, and a test says what happens without it.
- **A placed object of the stove's kind with no fire on it stops the world's tick,** loudly, on every pass. Only a mistake in the code can make one: `Stove.place` is the one way a stove is made.
- **What a script's `getScreenData` returns is carried as it is,** and the client trusts its shape.
- **A misspelled function on an item's table is no longer refused.** The registry used to refuse a field it did not know.
- **Picking up is eight private lines of `World`,** which grew by them.
- **`GroundItems` holds how near a picker must be, and how long a ground item waits.** A second thing that picks up, with a reach of its own, would need them handed in.
- **`World` decides when a screen on any placed object closes:** when the object is taken off the plot, and when the player walks away.
- **`PlayerState` is a pack, a hotbar, an open screen and a character's position in one record.**
- **`PlaceholderWorld`, on the server, names the crate, the stove and five items.** It goes when there is a real map.
- **What each item shows while selected is a table in `Main.client`,** asked every frame. It is a second list of the game's things, beside `Content.register`.
- **Three comments in the systems and the glue use the game's own things as examples.**

## Known problems
- **The hotbar's highlight, every click in the inventory, and a throw each wait for the server.** In Studio that is a frame or two. On a real server it is the player's ping, and nobody has measured it. Prediction on the client is the fix.
- **A request is sent for every click on the world,** at any distance and with any item in hand, and the server's script decides. The server allows each client 60 requests a second.
- **The keys and the inventory screen's mouse still go through `UserInputService`,** while the clicks on the world are input actions.
- **The play test is spoiled by someone using the PC.** It drives Studio with the mouse and the keyboard for about five minutes, and Studio losing focus lets go of held keys.
- **A thrown block that clips the edge of a step as it falls can tumble about 20 studs,** where on flat ground it stops after 7.6. Roblox's physics does that with a cube; nothing of ours is involved (`docs/code/checks.md`).
- **About sixty names have a word that should not be there:** an invented one, an `And`, `Or` or `If`, a noun that reads two ways, or one word for several ideas. Most are in the Roblox-side scripts and in private helpers (`docs/code/reviews/17-audit-after-the-eighth-review-2026-11-20.md`).
- **A ground item pushed out of a tile is not checked where it lands.** One that lay across a corner of the tile can land partly inside a placed object on the tile diagonally across that corner.
- **An object placed where a thrown item is flying can miss it.** The world knows where each ground item was at the last tenth of a second.
- **The faint block shows on tiles the server will refuse,** such as the one the player stands on.
- **A ground item's block that falls out of the world is not noticed.** Roblox destroys the part, and the ground item stays in the rules until its five minutes are up. It cannot happen on the placeholder map.
- **Merging compares every ground item that was spawned or moved with every other,** ten times a second, and one that lies still every two seconds. Measured in Lune on 2026-11-20 with every item moving: 0.3 milliseconds a pass at 100 items, 2.4 at 300, and 27 at 1,000 (`build/merge_pass_cost.luau`).
- **Left from the coupling review** (`docs/code/reviews/16-coupling-review-2026-11-20.md`), with when each is due in `next.md`: request names spelled as strings in `Main.client`; `Stove.getProgress` not checking the fire; `Main.client` reading the slot under the pointer from a drawing piece.
- **Left from the audits:** `PlaceholderWorld` keeps a timer in a module variable; `Plot.getTileAt` and `Plot.getTileCenter` take a corner where they could take the plot; `Inventory.addItems` returns how many went in while `Inventory.addStack` returns what did not fit.
- **Found while every comment was read against its function, and not mended:**
  - `Inventory.takeFromSlot`, and the three functions built on it, do not check that `count` is a whole number of 0 or more. `docs/code/conventions.md` says `Inventory` refuses such a count.
  - `ScreenScale.applyTo` keeps every `UIScale` it has made, also after its GuiObject is destroyed.

## Not built
- **Prediction on the client.** Approved.
- **Plots as placed objects on a body that physics can move, and an item's own look.** Both are the user's direction of 2026-11-21 (`next.md`). Neither is designed.
- **Saving.** A player's pack lasts until they leave. The shape of a save exists (`SaveData`), but nothing stores it (`docs/roblox/studio.md`). Ground items are never saved, by the user's choice.
- **A plot for each owner.** There is one plot, shared, and nobody owns what stands on it.
- **Touch controls,** and break on a phone.
