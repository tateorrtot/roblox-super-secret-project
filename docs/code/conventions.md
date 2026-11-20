# Conventions for the code

How code is written in this project. Read it before changing anything in `src` or `tests`.

The rules come from Godot's class reference, from FoxFabric's `adder.gd` (the user's own standard for the shape of a piece), and from the user's four reviews of the code (`docs/working/code-reviews/`). The user has not reviewed this list as a whole.

## Names
Names have a file of their own, `names.md`. In short: a function's name says what it acts on and where, every function starts with a verb, and a name is a promise the function keeps.

## Data
- **Nothing is `nil`.** No placeholder values and no empty records. How many places a thing has (`slotCount`) and what is in them are separate facts.
- **A value never changes,** and its functions return new values: `ItemStack`, an item definition, a `Position`. It is frozen, and its fields are typed `read`.
- **A thing changes in place, through its own module's functions:** `Inventory`, `InventoryScreen`, `Hotbar`, `World`. A field its module assigns is a plain field. Only fields that never change after the thing is made are `read`. Code outside the module does not assign a thing's fields.
- **A function that moves items returns what the caller is left holding,** and no item is made or lost.
- **Keep the facts, and work the rest out where it is used.** A value worked out from others is not stored. A player's state holds where their character is and which way it faces; the throw of a dropped stack is worked out when the stack is dropped. Claude once stored it, in a function named for a position, and the user called that spaghetti.
- **Only a thing's own module assigns its fields,** and it offers a function for each change that keeps the thing whole: `PlayerState.openPackScreen`, not `player.screen = ...` from somewhere else.

Plain fields on things are Claude's call of 2026-11-20, for the user to veto. The earlier rule typed every field `read`, which made each module write its own fields through a cast to `any`.

## Failure
- **What can happen in play is a return value.** No room, nothing there.
- **What comes from outside is checked once, where it comes in:**
  - a player's machine, in `InventoryRequests` and `PlotRequests`;
  - stored data, in `decode`;
  - what the Roblox scripts report, in `World`;
  - a hand-written item or recipe row, when it is registered.
- **Below that a function trusts its arguments.** It does not check them again or build error messages.
- **Three plain guards stay at the bottom,** because Luau would otherwise make or lose items without an error:
  - `ItemStack.new` refuses a stack that could not exist;
  - `Inventory` refuses a slot number that is not one of its slots;
  - `Inventory` refuses a count that is not a whole number of 0 or more.
- **A piece keeps one more guard only where a mistake would lose an item or corrupt its own data,** as `Hotbar.selectSlot` refuses a slot the hotbar lacks.
- The type checker vouches for types and for nothing else. A count of 0 is allowed and does nothing.

## Comments
Comments are written as Godot's class reference is. Read `doc/classes/Timer.xml` in Godot's repository before writing any; the user named it as the model.
- **A file opens with what the thing is, in a phrase** ("A countdown timer."), then at most a few sentences on how its main members work together.
- **Each public function, type, field and constant says what it does or is, completely and in the piece's own words:** what changes, what is returned, and what happens in each case a caller can meet ("Starts the timer, or resets the timer if it was started already."). That is usually one to three sentences.
- **A comment never defines behaviour by pointing outside the file.** Not at another game ("as in Minecraft"), not at a device ("what a double click does"), not at who calls it ("for the caller to put on the ground"), not at another comment. It refers to the piece's own members by name.
- **"Note:" is for a trap.** A guard that is kept is stated as Godot states it: "Fails if ...".
- **No comment inside a function,** and no explanation of the language. Private helpers get clear names, not comments.

## Layers
- **The rules know nothing of the mouse, the keyboard or a touch screen.** They offer operations named for what they do to the game (`pickUpFromSlot`, `putDownInSlot`, `swapSlots`). Which operation a click or a tap asks for is decided on the player's machine, by a piece named for that device's controls, and the request it sends names the operation.
- **The server sends when something happens, not as time passes.** A thing that moves with time alone, such as a stove's gauges, is sent as the times that decide it, and drawn on the player's machine from its own clock (`StationProgress`). Before adding anything to what a player is told, ask whether it changes while nothing happens. This is Claude's rule, from a stove that had the server sending a player's whole pack ten times a second.
- **Deleting one directory of the rules must not break the one beside it.** `players`, `plots` and `stations` know nothing of one another. `python tools/delete_directory_test.py` shows what breaks when each directory goes. This is the user's test, 2026-11-20.
- **Break it up.** When a piece does more than one thing, split it: a directory, a file, a function, a block. Decide which layer each part belongs on, and build the higher on the lower.
- **On the Roblox side** (`src/server`, `src/client`):
  - A piece that draws is named for what it draws, ending in `Gui` on a player's machine (`SlotGui`, `HotbarGui`) and `Parts` on the server (`GroundItemParts`). It is told what to show, reports clicks through callbacks it was given, and never changes the game's state.
  - A piece that turns input into requests is named for the controls it is (`InventoryControls`, `UseAndHit`).
  - `Main.server.luau` and `Main.client.luau` are the only scripts that run by themselves, and they join the pieces.
  - Anything that is there only until the real thing exists has `Placeholder` in its name.

## Tests
- Tests are plain scripts in `tests/`, mirroring `src/shared`, using `tests/Check.luau`. The plain-Luau pieces on the player's machine (`SlotGestures`, `InventoryControls`) are tested the same way, in `tests/client`.
- A check's message says what should be true.
- `Check.raises` also requires the error to blame the calling script.
- A corner copied from Minecraft is stated by a test.

## A piece is done when
1. Every check passes: `lune run tools/check`.
2. A mutation run (`python tools/mutate.py`) leaves only changes no caller could see.
3. `python tools/metrics.py --functions` shows no function nesting more than two deep.
4. `python tools/unused.py` lists no function built ahead of need.
5. Its names pass the names test in `names.md`.
6. On the Roblox side, `python tools/playtest.py` passes, with a step added for what the piece does.

## Where these came from
Godot never wrote down what its verbs mean, and its inconsistencies come from that, so these are written down. They were rewritten three times on 2026-11-20, once after each of the user's reviews. The first version had asked for long comments and for checks in every function, which contradicted `adder.gd`. The second leaned on outside knowledge. The third fixed the rule for names. All of the code was brought to them that day.
