# What comes next

The work that is approved or owed, in the order Claude means to do it. What is only a question is in `asked-of-the-user.md`. How the work is done is in `docs/working/with-the-user.md`.

Items and placed objects were split into two systems on 2026-11-20 (`history/2026-11-20-placed-objects.md`). The user had approved its three steps, and has not yet read the result.

## 1. Input for the world, so that `UseAndHit` goes
The user has asked about this class three times. On 2026-11-20: "so have you actually changed UseAndHit yet". It has not been changed, and it is next unless they say otherwise.
- **Today** `UseAndHit` finds what the pointer is over, draws two markers and tells two clicks apart, by reading `UserInputService` by hand. No noun fits it, because it is three things.
- **Roblox has a way of its own:** the Input Action System, in which an action such as "interact" is an Instance with its keys, buttons and touches bound to it. Roblox's own skill on it is read first (`docs/roblox/studio.md`). Roblox also has `ProximityPrompt`, for interacting with a thing nearby: say what each offers, and why it does or does not fit, before proposing anything of ours.
- **What it should leave:** two actions, interact and break, bound for a mouse, a touch screen and a gamepad; a piece that draws the markers; and `PlotPointer`, which stays. `InventoryControls` may go the same way.
- **It is shared machinery,** so its shape is shown to the user before it is written.

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
- **What an item in the hand does, said for each item:** a wand that casts a spell where a log places itself. Today the one thing is placing, in `PlaceableItems`.
- **Walls and floors,** with the grid as a guide and not a boundary.
- **Helpers:** people who can do what a player can, with a different brain.

## 5. Small things owed to the rules
- **The server's and the client's scripts in `lune run tools/check`.** They can be type-checked now, and a run on 2026-11-20 found nothing new: seven reports in two places, both older (`docs/roblox/studio.md`). Mend those two, then add the check.
- **A pass over the names the audit of 2026-11-20 found,** in what was not rewritten: `Main.server`, `Main.client`, `PlaceholderWorld` and the private helpers. The list is in `docs/code/reviews/17-audit-after-the-eighth-review-2026-11-20.md`.
- **`can...` for a kind's `interact` and `breakPlacedObject`,** when the first kind refuses one: obsidian that needs the right tool.
- `StationProgress` should check the fire before it says a station is working. A few lines, with the next change to stations.
- A mutation run over every piece at once stalls on `Station`: some of the bugs it plants make a loop run until the tool's 60-second limit, one after another. `tools/mutate.py` wants a shorter limit, or a way to give one.
- What the audits left is listed in `now.md`. None of it is urgent. The screen's drawing code is best left until the user decides whether screens are made in Studio.

## 6. Later
First things to prototype on a real phone: the inventory screen by touch; handling and carrying; walking on a moving deck; an intercepted delivery becoming a real object; demonstrating a route by touch; a deck of a few hundred welded pieces.
