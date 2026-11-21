# What comes next

The work that is approved or owed, in the order Claude means to do it. What is only a question is in `asked-of-the-user.md`. How the work is done is in `docs/working/with-the-user.md`.

On 2026-11-20 items and placed objects were split into two systems, and then, after the user's tenth review, each thing was given a script of its own and the clicks on the world moved to Roblox's input actions (`history/2026-11-20-scripts-and-input.md`). The user has read none of it yet.

## 0. When the user confirms it: a plot is placed objects on one body
Their direction of 2026-11-21, in the fifteenth review (`docs/working/code-reviews/2026-11-21-1-grids-on-bodies.md`): "In minecraft terms id think of it as "VoxelGrids on PhysicsBodies"." A tree is placed objects that hold each other up, and a cut through its foot makes what is above "a physics object" that falls. "I think the same could apply for vehicles. Or buildings." And: "who said we cant place things mid air? Or that Y is always up?" It is decided, and not designed (`docs/game/decisions.md`). What follows is Claude's reading, given to them the same day. It waits on their word (`asked-of-the-user.md`).

- **Today:** a world has one plot. The plot is a flat grid of tiles, fixed in the world by `World.plotCorner`. A placed object stands on one tile of the ground, named by `tileX` and `tileZ`. Nothing moves and nothing falls.
- **The reading:** a plot is a set of placed objects that hold together, on one body. A place on a plot is a position in the plot's own space, on three axes, so up is the plot's own up. Where the plot is in the world is its body's to say. A world has many plots.
  - The plot of today is the case where the body is anchored.
  - A tree, a vehicle, and a piece broken off a building are plots on bodies that are not anchored.
  - A floor is a placed object. No layer of a plot is a floor or a level.
  - A thing may be placed in mid-air. Whether it stays there is its plot's body's to say: on an anchored body it does.
- **What Roblox has:** parts joined by `WeldConstraint`s are one assembly, which moves as one rigid body, and one anchored part anchors its whole assembly (`docs/roblox/facts.md`). So the body is Roblox's own. The rules simulate nothing: they keep which placed object is joined to which, and Roblox's physics owns where a body is, as it already owns where a ground item is.
- **To measure in Studio first:** that a group of welded parts cut off from its anchored part falls as one assembly, and what a tree of a few hundred welded parts costs. Roblox's page on assemblies says neither.
- **Choices in it, which are the user's:**
  - What joins two placed objects: touching, or a join that the placing makes.
  - What breaking one placed object does to what it held up. They named two answers and chose neither: it breaks off "into its own grid/plot", as in Scrap Mechanic, or "for simplicity and bug exploits" it drops as items.
  - Whether a plot that falls keeps its placed objects whole, or sheds them as items when it lands.
  - Who owns a body that a player set moving, and how the rules learn where it came to rest. Ground items already answer that one way.
- **The first step, when they say yes:** a place on a plot becomes one value, a position in the plot's own space, in whole numbers on three axes for now, which only `Plot` makes and reads. A plot is given where it stands in the world, in place of `World.plotCorner`. Nothing changes in play. The step Claude offered on 2026-11-20 was a tile with a height. It kept the flat floor and added levels to it, which is the contract they then asked about.
- **Free placement, snapping, helpers and neighbours** stand as Claude gave them on 2026-11-20. A grid is a help for the hand, and an index the code may keep for speed. Things that work together snap to sockets, and the snap is the link that the code keeps: nothing searches for a neighbour as time passes. `PathfindingService` makes its paths from the parts in the world, at any angle. Their worry was helpers and machines that work on their neighbours: "expensive and confusing".

## 0a. When there is art: how an item looks
Their design of 2026-11-21 (`docs/game/decisions.md`): an item looks like a 2D texture or a 3D model. Not built: there is no art.
- **What it should leave:** each item says how it looks, in a piece of its own, as each kind of placed object has a piece that makes its Model. General code asks the item's piece for what to show in a slot, in the hand and on the ground, and knows nothing of what is in it.
- **What Roblox has:** an `ImageLabel` shows a texture in a slot, and a `ViewportFrame` shows parts there through a camera of its own. `EditableImage` reads a texture's pixels and `EditableMesh` builds a mesh while the game runs (`docs/roblox/facts.md`). So a rule can give a texture depth: a face for each side of each solid pixel that has no solid pixel beside it.
- **Needed from the user:** one texture and one model to build with, uploaded by them, and the specifics they offered (`asked-of-the-user.md`).

## 0b. If the user says so: what a character holds is a Roblox `Tool`
Their proposal of 2026-11-20. Items stay a system of their own; the held tool is another; glue says which tool a selected stack puts in the hand.
- **First, measure in Studio** the five things Roblox's documentation leaves unsaid (`docs/roblox/input.md`). It takes the mouse for a few minutes.
- It would give a thing shown in the hand to every player, and `Activated` on a mouse, a touch screen and a gamepad, which the game's own input does not cover.

## 1. The keys onto Roblox's input actions
The clicks on the world are input actions; E, Q, 1 to 9 and the mouse on the inventory screen still go through `UserInputService` (`docs/roblox/input.md`).
- **What it should leave:** an action for each thing the keys do, declared in `default.project.json`; `Main.client` connecting to them; and, on the way, a name for `InventoryControls` that the user can read.
- **To settle first:** whether the inventory screen is a second context that takes the keys while it is open, which is what Roblox's guide means by a mode, and whether a held Ctrl is a modifier on a binding or an action of its own.
- **Add to the play test:** a click on the world in first person, which nothing tries.

## 2. Prediction on the player's machine
The user chose it on 2026-11-20, as our own and not Roblox's Server Authority (`docs/research/18-client-first.md`), asked that it sit on top as pieces of its own, and said yes to this plan: "Ah prediction sounds great the way you architected it! ... As long as its following the rest of the codebases standards good."

- **One new piece on the player's machine, `Prediction`.** It keeps the last snapshot the server sent and the requests sent since. It gives the screen what to draw: the server's snapshot, with the unanswered requests carried out on it by the same `Requests.carryOut` the server uses.
- **Each request goes up with a number,** and each snapshot comes down with the number of the last request it includes. The server sends when either has changed, so a request it refused is still answered.
- **What changes in what exists:** `Main.client` sends through `Prediction` and draws what it gives. `Main.server` reads the number and sends it back. `PlayerState` gets a way to be made from a snapshot. Nothing else in the rules changes.
- **Order:** the hotbar; then the nine inventory requests that touch nothing but the player's own inventories; then the inventory half of a drop; then a look-alike part for a thrown stack.
- **Not predicted at first:** placing, interacting with a placed object, breaking one, and picking up from the ground.
- **It is shared machinery,** so each piece is shown to the user as it is made, and it gets turns of its own.
- **Two faults from the coupling review are fixed on the way,** because prediction rewrites the code they are in: request names spelled as strings in `Main.client`, and `Main.client` reading the slot under the pointer from a drawing piece.

## 3. The user reads the code, then gives their feedback on the game
They are holding the feedback until the code is checked. Their read comes first, and what they find outranks everything below.

## 4. What they have said they want, not yet designed
Each starts with one precise question to them, and is built as small pieces. The order is theirs to choose. Their words are in `docs/game/decisions.md` and `docs/game/placed-objects.md`.
- **Saving, and a plot for each owner:** "multiple plots with associated owners", where the owner is not always a player. Saving needs two things only they can do (`asked-of-the-user.md`). With more than one plot, what the world keeps by a placed object's id needs the plot's id too.
- **A second kind of process,** very unlike the furnace: one worked on by what stands over it, or one that works on what is in front of it. Building it is what will show what the kinds share. It is also what makes a screen a kind's own: today every screen is a pack, another inventory and a furnace's gauges. `Station`, `world.stations` and the furnace's slots in the screen's drawing code wait for it.
- **An item that is used on something other than a bare tile:** a wand cast at the open air, a bucket used on a placed object. Each item has a script now, and the script is told of a bare tile only. Each new sort of target is one new request and one new function of the script. Minecraft's order is the one to copy unless the user says otherwise: the thing pointed at answers first, then the item.
- **Walls and floors,** with the grid as a guide and not a boundary.
- **Helpers:** people who can do what a player can, with a different brain.

## 5. Small things owed to the rules
- **The server's and the client's scripts in `lune run tools/check`.** They can be type-checked now, and a run on 2026-11-20 found nothing new: seven reports in two places, both older (`docs/roblox/studio.md`). Mend those two, then add the check.
- **A pass over the names the audit of 2026-11-20 found,** in what was not rewritten: `Main.server`, `Main.client`, `PlaceholderWorld` and the private helpers. The list is in `docs/code/reviews/17-audit-after-the-eighth-review-2026-11-20.md`.
- **`PlaceholderWorld`'s starting crate, stove and items** belong with the game's things in `src/shared/content`, or go with the placeholder map.
- **Three comments in the systems and the glue that use the game's own things as examples:** `ItemRegistry`, `Plot` and `PlayerSnapshot`.
- **A phone.** Whether a tap also fires the input action bound to the left mouse button, which would interact twice.
- `Stove.getProgress` should check the fire before it says a stove is working. A few lines.
- A mutation run over every piece at once stalls on `Stove`: some of the bugs it plants make the loop in `advance` run until the tool's 60-second limit, one after another. `tools/mutate.py` wants a shorter limit, or a way to give one.
- What the audits left is listed in `now.md`. None of it is urgent. The screen's drawing code is best left until the user decides whether screens are made in Studio.

- **A pass over every comment and note against Godot's writing guidelines** (`docs/code/conventions.md`, "Comments"), and for the defined words: 131 places say "player's machine" where the word is client, 13 of them in files of `src`. It is one kind of change in many places, so it is one commit.
- **The word `piece` in three type names:** `PlacedObjectPiece` in `PlotParts`, and `SelectedItemPiece` and `PlacedObjectScreenPiece` in `Main.client`. A reviewer counted it as one word for three things. The user's word for a table of one thing's functions is script, and Roblox has a `Script` of its own, so it wants their ruling.
- **The reference on readthedocs.org,** if they want it there: it needs the repository on a host that site can read, which is theirs to set up, and a small config file. The notes would have to stay out of it: `docs/roblox/studio.md` names their account.
- **One function for an item that places a kind,** when a third item does it. `CrateItem.interactWithTile` and `StoveItem.interactWithTile` are the same four lines.
- **The id of the item that a broken crate leaves is written twice:** in `CrateItem` and in `Crate.ITEM_ID_WHEN_BROKEN`. The two files cannot require each other. The same holds for the stove.

## 6. Later
First things to prototype on a real phone: the inventory screen by touch; handling and carrying; walking on a moving deck; an intercepted delivery becoming a real object; demonstrating a route by touch; a deck of a few hundred welded pieces.
