# What comes next

The work that is approved or owed, in the order Claude means to do it. What is only a question is in `asked-of-the-user.md`. How the work is done is in `docs/working/with-the-user.md`.

## First, if the user agrees: items and placed objects as two systems
The user, 2026-11-20: "we should have a "inventory items hotbar storage" etc module and a "placed objects, plots" etc modules that dont know about eachother. if they can be broken up further great." Glue between them lives outside both. Claude's advice is to do this before prediction, because it changes the requests that prediction numbers and replays. The steps have been shown to the user, and none is started.

- **Today** `plots` requires `items` and `inventory`: a plot looks up an item's flags to decide what may stand on it, and gives the placed thing an inventory. The audit of that day found twelve things the game decides for every item alike (`docs/code/reviews/17-audit-after-the-eighth-review-2026-11-20.md`).
- **One step at a time, each shown before it is written:**
  1. **The inventory comes out of the placed thing.** A piece of glue keeps the inventory that belongs to a placed object, by the object's id, and hears the plot's two signals. After it, `plots` no longer requires `inventory`.
  2. **The item comes out.** A placed object has a kind of its own, and the table that says which item puts down which object is glue. The flags `placeable` and `slotCount` leave the item's definition. The placed thing gets its new name. After it, `plots` no longer requires `items`.
  3. **What interacting with a placed object does, and what breaking it leaves, is said for each kind,** by the glue for that kind. `World.throwPlacedItemAndContents` and the three fixed requests go. In the user's words: `interact` and `break`.
  4. **Input through Roblox's Input Action System,** in which an action such as "interact" is an Instance with its keys, buttons and touches bound to it. `UseAndHit` goes. Roblox's own skill on it is read first (`docs/roblox/studio.md`).
  5. **The furnace,** when a second kind of process is wanted, as the user said.
- **The names that readers doubted in this code are mended as it is rewritten:** a tile's `x` and `z` beside a position's, `Plot.width` and `depth`, `itemId` on a placed thing, `World.REACH`.
- **A small thing on the way:** the server's and the client's scripts can now be type-checked. The definitions are downloaded, and a first run found seven reports in two places (`docs/roblox/studio.md`). The check is not yet part of `lune run tools/check`.

## 1. Prediction on the player's machine
The user chose it on 2026-11-20, as our own and not Roblox's Server Authority (`docs/research/18-client-first.md`), asked that it sit on top as pieces of its own, and said yes to this plan: "Ah prediction sounds great the way you architected it! ... As long as its following the rest of the codebases standards good."

- **One new piece on the player's machine, `Prediction`.** It keeps the last snapshot the server sent and the requests sent since. It gives the screen what to draw: the server's snapshot, with the unanswered requests carried out on it by the same `Requests.carryOut` the server uses.
- **Each request goes up with a number,** and each snapshot comes down with the number of the last request it includes. The server sends when either has changed, so a request it refused is still answered.
- **What changes in what exists:** `Main.client` sends through `Prediction` and draws what it gives. `Main.server` reads the number and sends it back. `PlayerState` gets a way to be made from a snapshot. Nothing else in the rules changes.
- **Order:** the hotbar; then the nine inventory requests that touch nothing but the player's own inventories; then the inventory half of a drop; then a look-alike part for a thrown stack.
- **Not predicted at first:** placing, opening a placed item, and picking up from the ground.
- **It is shared machinery,** so each piece is shown to the user as it is made, and it gets turns of its own.
- **Two faults from the coupling review are fixed on the way,** because prediction rewrites the code they are in: request names spelled as strings in `Main.client`, and `Main.client` reading the slot under the pointer from a drawing piece.

## 2. The user reads the code, then gives their feedback on the game
They are holding the feedback until the code is checked. Their read comes first, and what they find outranks everything below.

## 3. What they have said they want, not yet designed
Each starts with one precise question to them, and is built as small pieces. The order is theirs to choose. Their words are in `docs/game/decisions.md` and `docs/game/placed-items.md`.
- **Saving, and a plot for each owner:** "multiple plots with associated owners", where the owner is not always a player. Saving needs two things only they can do (`asked-of-the-user.md`).
- **A second kind of process,** very unlike the furnace: one worked on by what stands over it, or one that works on what is in front of it. Building it is what will show what the kinds share. `Station`, `world.stations` and the furnace's slots in the screen's drawing code wait for it.
- **Walls and floors,** with the grid as a guide and not a boundary.
- **Helpers:** people who can do what a player can, with a different brain.

## 4. Small things owed to the rules
- **A pass over the names the audit of 2026-11-20 found,** in what the steps above do not rewrite: `Main.server`, `Main.client`, `PlaceholderWorld` and the private helpers. The list is in `docs/code/reviews/17-audit-after-the-eighth-review-2026-11-20.md`.
- `StationProgress` should check the fire before it says a station is working. A few lines, with the next change to stations.
- A mutation run over every piece at once stalls on `Station`: some of the bugs it plants make a loop run until the tool's 60-second limit, one after another. Each piece changed on 2026-11-20 was run by itself. `tools/mutate.py` wants a shorter limit, or a way to give one.
- What the audits left is listed in `now.md`. None of it is urgent. The screen's drawing code is best left until the user decides whether screens are made in Studio.

## 5. Later
First things to prototype on a real phone: the inventory screen by touch; handling and carrying; walking on a moving deck; an intercepted delivery becoming a real object; demonstrating a route by touch; a deck of a few hundred welded pieces.
