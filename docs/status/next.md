# What comes next

The work that is approved or owed, in the order Claude means to do it. What is only a question is in `asked-of-the-user.md`. How the work is done is in `docs/working/with-the-user.md`.

On 2026-11-20 items and placed objects were split into two systems, and then, after the user's tenth review, each thing was given a script of its own and the clicks on the world moved to Roblox's input actions (`history/2026-11-20-scripts-and-input.md`). The user has read none of it yet.

## 0. A plot is placed objects on one body
The user's direction of 2026-11-21: "In minecraft terms id think of it as "VoxelGrids on PhysicsBodies"." Claude drew its reading, and they confirmed it the same day: "Yes! That physics diagram is what I mean." Their words are in `docs/game/decisions.md`. Not built.

- **Today:** a world has one plot. The plot is a flat grid of tiles, fixed in the world by `World.plotCorner`. A placed object stands on one tile of the ground, named by `tileX` and `tileZ`. Nothing moves and nothing falls.
- **The model:** a plot is a set of placed objects that hold together, on one body. A place on a plot is a position in the plot's own space, on three axes, so up is the plot's own up. Where the plot is in the world is its body's to say. A world has many plots. The plot of today is the case where the body is anchored. A tree, a vehicle, and a piece broken off a building are plots on bodies that are not anchored. A floor is a placed object.
- **Building and physics are two systems, and glue joins them.** Their rule: "Being able to build and physics are two unrelated things. Were basically just gluing them together. (This is important to note so it stays decoupled)".
  - **Building** is the rules' own, in plain Luau: which placed objects a plot has, where each is in the plot's own space, and which are joined to which. It knows nothing of bodies, welds, or falling.
  - **Physics** is Roblox's: parts joined by `WeldConstraint`s are one assembly, and one anchored part anchors its assembly.
  - **The glue** is on the server. It makes a weld for each join and hears the building system's signals. Neither system requires the other.
- **What is cut loose becomes a plot of its own.** Their contract: "I think it should almost always break it off into its own plot." So when a placed object goes and leaves a group that nothing joins to the rest, the building system makes that group a new plot and says so with a signal. The glue gives the new plot a body.
- **Measured in Studio on 2026-11-21** (`docs/roblox/facts.md`): destroying one weld left the loose group as one assembly, which fell at once, and a chain of 300 welded parts fell as one body with no change in the server's frame time. Many trees at once, and a body that breaks up when it lands, are not measured.
- **Still theirs to choose** (`asked-of-the-user.md`): what joins two placed objects, touching or a join that the placing makes; whether a thing placed in mid-air starts a plot of its own; whether a plot that falls keeps its placed objects whole; who owns a body that a player set moving; and what to call the thing, since they asked whether "Plot" is the best word.
- **The first step:** a place on a plot becomes one value, a position in the plot's own space, in whole numbers on three axes for now, which only `Plot` makes and reads. A plot is given where it stands in the world, in place of `World.plotCorner`. Nothing changes in play. It is shared machinery, so its shape is shown to them first.
- **Free placement, snapping, helpers and neighbours** stand as Claude gave them on 2026-11-20. A grid is a help for the hand, and an index the code may keep for speed. Things that work together snap to sockets, and the snap is the link that the code keeps: nothing searches for a neighbour as time passes. `PathfindingService` makes its paths from the parts in the world, at any angle. Their worry was helpers and things that work on their neighbours: "expensive and confusing".

## 0a. How an item looks
Their design of 2026-11-21 (`docs/game/decisions.md`): an item looks like a 2D texture or a 3D model, the same in the hand and on the ground. Claude draws primitive stand-ins of its own until there is art, by their word. Not built. Claude showed them this shape on 2026-11-21, and it waits on their word.
- **One ModuleScript for each item says how the item looks,** as each kind of placed object has a ModuleScript that makes its Model. It has two functions: one returns what a slot shows, and one returns what the world shows, in the hand and on the ground. General code calls them and knows nothing of what they make. Claude first called this "a look piece", and the user asked what that was.
- **Three small pieces that an item's look may use, and none must:** a texture shown flat in a slot; a texture given depth by rule, with a face for each side of each solid pixel that has no solid pixel beside it; and a Model shown in a slot at an angle.
- **What Roblox has:** an `ImageLabel` shows a texture in a slot, and a `ViewportFrame` shows parts there through a camera of its own. `EditableImage` holds pixels that a script writes, and `EditableMesh` builds a mesh while the game runs. Neither needs an uploaded asset when it starts blank (`docs/roblox/facts.md`).
- **Needed from the user:** "Allow Mesh / Image APIs" switched on, under Security in Studio's Experience Settings. Measured on 2026-11-21: without it, a script in Studio cannot write a pixel or add a vertex. A look made only of parts needs no setting.
- **Where the pieces live is new:** the server shows an item on the ground and the client shows it in a slot, so one piece for each item must reach both. Today no folder of Roblox-side code does.

## 0c. What the sixteenth review left
Their words are in `docs/working/code-reviews/2026-11-21-2-what-is-a-side.md`. None of this is built.
- **Nine functions of `InventoryScreen` still take a `side`,** and two more take a list of `ScreenSlot`s, each of which names one. The user, 2026-11-21: "I kinda hate SIDE as a concept as a whole i just dont understand where it came from." A client cannot send an inventory, so a request must take a word for one. Below the requests nothing needs the word: each function of `InventoryScreen` could take the `Inventory` itself, as `Inventory.takeFromSlot` does, and the requests would turn `"pack"` or `"other"` into the inventory once, where the client's values come in. Not built, and asked of them (`asked-of-the-user.md`). It changes those eleven signatures, and 147 lines of `tests/inventory/InventoryScreen.test.luau` name a side.
- **Whether the server should choose the slots for a quick move,** which Claude proposed and they did not follow, is left until they ask.
- **The other comments, written as three pages now are** (`docs/code/comments.md`): each noun an argument, a field, a type, or a value, and each argument said to be what it is. The user said yes to finishing them. They are done a module at a time, each page opened and read, and `InventoryScreen` waits for their word on `side`.
- **The words `screen` and `side`.** `InventoryScreen` is what a player has open: their pack, perhaps another inventory, and the stack they carry. It is kept on the server and draws nothing, and its name reads as a GUI. `side` says which of its inventories a slot is in, `"pack"` or `"other"`, and reads as a side of the player. Roblox and Godot have no word for the thing. Bukkit's `InventoryView` is the same thing, with a top and a bottom inventory. The words are theirs to choose.
- **The pages, by the cold readers' measure** (`now.md`): a page that explains the words every page uses, such as pack, hotbar, slot, stack and carried stack, which each page links to; shorter sentences in `Stove.advance` and `InventoryScreen.spreadCarriedStackOverSlots`; and an example for each module that has none.


## 0b. If the user says so: what a character holds is a Roblox `Tool`
Their proposal of 2026-11-20. Items stay a system of their own; the held tool is another; glue says which tool a selected stack puts in the hand.
- **First, measure in Studio** the five things Roblox's documentation leaves unsaid (`docs/roblox/input.md`). It takes the mouse for a few minutes.
- It would give a thing shown in the hand to every player, and `Activated` on a mouse, a touch screen and a gamepad, which the game's own input does not cover.

## 1. The keys onto Roblox's input actions
The clicks on the world are input actions; E, Q, 1 to 9 and the mouse on the inventory screen still go through `UserInputService` (`docs/roblox/input.md`).
- **What it should leave:** an action for each thing the keys do, declared in `default.project.json`; `Main.client` connecting to them; and, on the way, a name for `InventoryControls` that the user can read.
- **To settle first:** whether the inventory screen is a second context that takes the keys while it is open, which is what Roblox's guide means by a mode, and whether a held Ctrl is a modifier on a binding or an action of its own.
- **Add to the play test:** a click on the world in first person, which nothing tries.

## 2. Prediction on the client
The user chose it on 2026-11-20, as our own and not Roblox's Server Authority (`docs/research/18-client-first.md`), asked that it sit on top as pieces of its own, and said yes to this plan: "Ah prediction sounds great the way you architected it! ... As long as its following the rest of the codebases standards good."

- **One new piece on the client, `Prediction`.** It keeps the last snapshot the server sent and the requests sent since. It gives the screen what to draw: the server's snapshot, with the unanswered requests carried out on it by the same `Requests.carryOut` the server uses.
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

- **What the comment pass left** (`history/2026-11-21-the-comment-pass.md`): the three faults it found in the code, which are listed in `now.md`; an example on the pages that want one; the comments in `tests`; and the `---` comments over local values in `Main.client` and `StoveScreen`, which the guide does not allow and which hold facts.
- **The word `piece` in three type names:** `PlacedObjectPiece` in `PlotParts`, and `SelectedItemPiece` and `PlacedObjectScreenPiece` in `Main.client`. A reviewer counted it as one word for three things. The user's word for a table of one thing's functions is script, and Roblox has a `Script` of its own, so it wants their ruling.
- **The reference on readthedocs.org,** if they want it there: it needs the repository on a host that site can read, which is theirs to set up, and a small config file. The notes would have to stay out of it: `docs/roblox/studio.md` names their account.
- **One function for an item that places a kind,** when a third item does it. `CrateItem.interactWithTile` and `StoveItem.interactWithTile` are the same four lines.
- **The id of the item that a broken crate leaves is written twice:** in `CrateItem` and in `Crate.ITEM_ID_WHEN_BROKEN`. The two files cannot require each other. The same holds for the stove.

## 6. Later
First things to prototype on a real phone: the inventory screen by touch; handling and carrying; walking on a moving deck; an intercepted delivery becoming a real object; demonstrating a route by touch; a deck of a few hundred welded pieces.
