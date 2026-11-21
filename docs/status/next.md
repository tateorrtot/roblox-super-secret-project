# What comes next

The work that is approved or owed, in the order Claude means to do it. What is only a question is in `asked-of-the-user.md`. How the work is done is in `docs/working/with-the-user.md`.

On 2026-11-20 items and placed objects were split into two systems, and then, after the user's tenth review, each thing was given a script of its own and the clicks on the world moved to Roblox's input actions (`history/2026-11-20-scripts-and-input.md`). The user has read none of it yet.

## 0. When the user decides it: where a placed object stands
On 2026-11-20 they said they lean to free placement: "I think the freeform placement is generally better with optional grid snapping." And they named their worry: "NPCs and doing things like complex automation or checking neighbouring cells sounds expensive and confusing." They had already said the grid should be "a pure guideline rather than a set boundary" (`docs/game/decisions.md`). Claude asked whether to take the first step (`asked-of-the-user.md`). Claude's thoughts, as given to them:
- **Free placement is the rule, and a grid is a help.** A placed object has a position, a turn and a size, and it can stand where its box overlaps no other. Snapping to a grid, to a neighbour's edge or to a socket happens on the player's machine while they choose the spot. The server asks only whether the box is free.
- **It is not expensive if nothing searches as time passes.** A neighbour is looked for when something is placed, moved or taken off, and the link is kept. A machine reads its link when it works. One placement is checked against the other objects of one plot: a few hundred comparisons.
- **It is confusing only if "over" and "in front of" are left to be guessed.** Things that work together have sockets, as in ARK and in the Create mod: a basin has one above it, and a mixer set down near it snaps on. The snap is the link. The player sees it, and the code keeps it. A thing that works with nothing goes anywhere.
- **Helpers:** Roblox's `PathfindingService` makes its paths from the parts in the world, at any angle, so free placement does not stand in its way. Whether it is cheap enough for many helpers is to be measured when helpers are built. The other way is a coarse grid worked out from the boxes, which the player never sees.
- **So the grid stays, in two new jobs:** a help for the hand, and an index the code may keep for speed. It stops being the rule for where a thing may stand.
- **What Roblox has:** every part has a `CFrame` and a `Size`, and `Workspace:GetPartBoundsInBox` says what a box overlaps. The rules are plain Luau with no Roblox calls, so either the overlap test is ours, about thirty lines for boxes turned about the vertical, or the server's Roblox side answers it.
- **The first step, if they say yes:** where a placed object stands becomes one value that only `Plot` looks inside, with a height. Today `tileX` and `tileZ` pass through twelve files and there is no `tileY`. They have pointed at the flat grid three times.

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

- **A kind's name and colour into the kind's own file.** They are rows in `PlacedObjectLooks`, as an item's were in `ItemLooks`.
- **One function for an item that places a kind,** when a third item does it. `CrateItem.interactWithTile` and `StoveItem.interactWithTile` are the same four lines.
- **The id of the item that a broken crate leaves is written twice:** in `CrateItem` and in `Crate.ITEM_ID_WHEN_BROKEN`. The two files cannot require each other. The same holds for the stove.

## 6. Later
First things to prototype on a real phone: the inventory screen by touch; handling and carrying; walking on a moving deck; an intercepted delivery becoming a real object; demonstrating a route by touch; a deck of a few hundred welded pieces.
