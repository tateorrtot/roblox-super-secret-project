# Conventions for the code

How code is written in this project. Read it before changing anything in `src` or `tests`.

The rules come from Godot's class reference, from FoxFabric's `adder.gd` (the user's own standard for the shape of a piece), and from the user's reviews of the code (`docs/working/code-reviews/`). The user has not reviewed this list as a whole.

## Names
Names have a file of their own, `names.md`. In short: a function's name says what it acts on and where, every function starts with a verb, and a name is a promise the function keeps.

## Data
- **Empty is empty.** Where there is nothing there is `nil`: no placeholder value, no sentinel and no empty record stands in for it. How many places a thing has (`slotCount`) and what is in them are separate facts.
- **A value never changes,** and its functions return new values: `ItemStack`, an item definition, a `Position`. It is frozen, and its fields are typed `read`.
- **A thing changes in place, through its own module's functions:** `Inventory`, `InventoryScreen`, `Hotbar`, `World`. Only a thing's own module assigns its fields, and it offers a function for each change that keeps the thing whole: `PlayerState.openPackScreen`, not `player.screen = ...` from somewhere else. A field its module assigns is a plain field. Only fields that never change after the thing is made are `read`.
- **A function that moves items returns what the caller is left holding,** and no item is made or lost.
- **Keep the facts, and work the rest out where it is used.** A value worked out from others is not stored. A player's state holds where their character is; the throw of a dropped stack is worked out when the stack is dropped, from the direction the request brings. Claude once stored it, in a function named for a position, and the user called that spaghetti.

Plain fields on things are Claude's call of 2026-11-20, for the user to veto. The earlier rule typed every field `read`, which made each module write its own fields through a cast to `any`.

## Check, then act
The user's rule, 2026-11-20: "if you say "jump" dont have a check inside that method. Check before you call the method like "can_jump" THEN "jump". A method should always do as it says so its intuitive. ... Sometimes we may never care about "can_jump" and just force a jump."
- **A function does what its name says, every time it is called.** It does not look first and quietly do nothing.
- **The check is a function of its own,** named `can...` or `is...`, and the caller asks it first. A request from a player's machine asks; a caller that means to force the thing does not.
- **The same goes for a tool.** `python tools/studio.py sync` syncs. Whether the code passed its checks is another command's to say.
- **An action that cannot be carried out fails loudly,** where going on would spoil the data, and its comment says so as Godot does: "Fails if ...". It never quietly does nothing.
- **The pairs in the rules:** `Plot.canPlaceObject` and `World.canPlaceObject` before `Plot.placeObject` and a kind's `place`; `PlayerState.canOpenScreen` before `PlayerState.openScreen`; `InventoryScreen.canSwapCarriedStackWithSlot` and `canSwapSlots` before the two swaps.
- **A function of a script is told that something happened, and what follows is its own to say.** `CrateItem.interactWithTile` is told that someone holding a crate item interacted with a tile. It asks `World.canPlaceObject`, and places a crate or does nothing. That is not a hidden check: its name promises that it is told, not that anything is placed.
- A function that is asked to remove a thing that is not there has nothing to do, and that is not a check: `removeCharacter`, `closeScreen`.
- **A rule of the game is not a check.** `GroundItems.moveNearbyStacksToInventory` leaves alone a ground item that is too new to pick up, and `GroundItems.mergeItems` looks only at the ground items whose turn it is. Each says so in its comment.

## Simple things, and what joins them
The user's rule, in three messages on 2026-11-20. Of items and placed objects: "they are two v e r y different systems that shouldnt rely on or mention eachother i feel. Glue code for them should exist outside of them." Of an item that places an object: "Theres items. Theres the event of having the item selected. --> Causes some code to get ran ... Theres the event of "interacting" while having the item selected --> causes some code to get ran ... Just keep it generic." And of the whole: "Systems shouldnt know about eachother. Dont pull out abstractions. ... You compose simple things and systems together and use glue code." Their words in full are in `docs/working/code-reviews/2026-11-20-9-simple-things-and-glue.md`.
- **A system does one job and knows no other system.** Items and stacks. Inventories. Plots and the objects placed on them. Stations. Each is what Unix calls a program: `ls` lists, `grep` searches, and nobody writes `catgrep`. The test is the user's: could it be lifted out and shipped as a FoxFabric addon? `python tools/delete_directory_test.py` shows what breaks when each directory goes.
- **The general code never asks what sort of thing a thing is.** No table, flag or type says that an item places, burns or is eaten, or that a placed object holds things. Claude kept such a table, `PlaceableItems`, and the user: "Youve coupled the idea of items and placing together still with PlaceableItem. Now youve shot yourself in the foot and cant make a wand." A fact that one system needs about an item is that system's own, keyed by the item's id, as `FuelRegistry` is the stations'.
- **Each thing has a script of its own, and the general code calls it.** `ItemScripts` holds the script of each item, and `PlacedObjectScripts` the script of each kind of placed object. A request finds the script of the thing the player acted with or on, and calls the function for what they did: `interactWithTile`, `interact`, `breakPlacedObject`. The user: "Placed items kinda each get their own class / script. That contains the spaghettiii. its basically the mediator pattern."
- **A script has only the functions its thing has a use for.** "It CAN have an inventory. It CAN have a process. It CAN have giant explosion when clicked." Nothing happens for a thing with no script, or with a script that lacks the function. Luau has no `interface` keyword: a table type that lists functions is one, and the type checker refuses a script whose function takes the wrong arguments, at the line where it is registered.
- **A thing's script is where systems meet.** `Crate.place` calls `Plot.placeObject` and `World.addPlacedObjectInventory`. `CrateItem.interactWithTile` asks `World.canPlaceObject` and calls `Crate.place`. The systems it calls never hear of each other.
- **Things stay dumb.** The user, 2026-11-20: "Things staying "DUMB" is the absolute best way to keep things decoupled. You cant anticipate everything so dont. Just make the spaghetti contained." A thing's script is handed only what it uses, and requires only what its one job needs. Of `CrateItem`, which had required `Hotbar` and `PlayerState`: "who said an item was always going to be tied to a player. Or a hotbar?" Their words are in `docs/working/code-reviews/2026-11-20-10-who-said.md`.
- **A script answers whoever called it, and the caller acts on the answer.** `CrateItem.interactWithTile` returns how many crate items were used up. It does not know where the item was held, and whoever called it takes that many away. An answer for the one who asked is a return value. News for whoever cares, when the sender does not know who that is, is a signal.
- **Nothing is pulled out before there is a pattern.** `CrateItem` and `StoveItem` are written out alike, on purpose. The user: "You cant pull out and abstract a very specifics wand implenetation until you have a pattern of it. Its the same with the placeable item!" When several things have shown the same shape, what is pulled out is a function that their scripts call. It is never a category that the general code knows.
- **The game's own things are in `src/shared/content`,** and `Content.register` is the one list of them. To add a thing: write its script there, add it to `Content.register`, and give it a look. If it shows something in the world while selected, write its piece in `src/client/content` and add it to the table in `Main.client`.
- **That changes no system and no request, as long as the thing answers what a request already tells of:** a bare tile interacted with, or a placed object interacted with or broken. It does not hold for a thing that needs more. An item used on the open air or on a placed object needs a new request and a new function of `ItemScript`. A placed object that keeps or does something new over time needs a new store in `World`, which still has one for each sort of thing an object can be given (`docs/game/placed-objects.md` lists what is left).
- **What is about the player is the request's. What is about the thing is its script's.** A request is what a player did, so it settles what only a player has: a character, how far that character reaches, and the hotbar slot that what they hold is in. The script says what the thing does. Claude first had the request ask reach for a placed object and the script ask it for a tile; then, on a reviewer's finding of the two owners, moved it into every script, which is why every script was handed a player. The user asked why an item knew about players, and it moved to the request.
- **What a kind gives its objects is kept by the world,** by the placed object's id: `World.addPlacedObjectInventory`, `World.addStation`. The world drops both when the object is taken off the plot. A kind's `place` is the one way its objects are made; one put on the plot by `Plot.placeObject` alone has nothing, and its kind's other functions fail for it.

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
- **Deleting one directory of the rules must not break the one beside it.** `players`, `plots` and `stations` know nothing of one another, and `plots` knows nothing of `items` or `inventory`. `python tools/delete_directory_test.py` shows what breaks when each directory goes. This is the user's test, 2026-11-20.
- **One rule tells another with a signal.** A thing that changes says so by firing a `Signal` it holds, as a plot fires `placedObjectAdded`, and each piece that cares connects to it. The function that makes the change does not know who listens. The user asked for this of removing a placed item: "the placedItem itself should signal / event "hey im getting deleted!" and that end up cascading into the items splling and the inventory closing elsewhere."
- **Roblox's own events are for where the engine speaks to us:** input, a player joining, a message from the other machine. The user asked why we would have two systems. A `BindableEvent` is an Instance, copies the tables passed through it, and runs what is connected to it later and in no promised order, so it cannot carry the rules' own values or keep their order (`docs/research/19-roblox-events.md`). The user, having heard that: "Okay I stand corrected. Signals are good."
- **Break it up.** When a piece does more than one thing, split it: a directory, a file, a function, a block. Decide which layer each part belongs on, and build the higher on the lower.
- **On the Roblox side** (`src/server`, `src/client`):
  - A piece that draws is named for what it draws, ending in `Gui` on a player's machine (`SlotGui`, `HotbarGui`) and `Parts` on the server (`GroundItemParts`). It is told what to show, reports clicks through callbacks it was given, and never changes the game's state.
  - What the player does to the world is two of Roblox's input actions, `Interact` and `Break`, declared in `default.project.json` with the button each is bound to (`docs/roblox/input.md`). `Main.client` connects to them. The class that read those clicks by hand, `UseAndHit`, is gone.
  - A piece that turns input on the inventory screen into requests has no settled name yet. `InventoryControls` failed the user's reading, as `PlotControls` did: "controling a plot? ... isnt that the plots job?" Roblox's own scripts call such a module by what it reads, as `CameraInput`.
  - What an item shows in the world while it is selected is a piece of its own in `src/client/content`, with `update` and `hide`.
  - `Main.server.luau` and `Main.client.luau` are the only scripts that run by themselves, and they join the pieces.
  - A piece that will be deleted when the real thing exists has `Placeholder` in its name (`PlaceholderWorld`). A piece that stays, and only draws stand-in shapes for now, does not (`GroundItemParts`, `PlotParts`): its comment says that the shapes are placeholders.

## Tests
- Tests are plain scripts in `tests/`, mirroring `src/shared`, using `tests/Check.luau`. The plain-Luau pieces on the player's machine (`SlotGestures`, `InventoryControls`) are tested the same way, in `tests/client`.
- A check's message says what should be true, and starts with the name of the function it is about.
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
Godot never wrote down what its verbs mean, and its inconsistencies come from that, so these are written down. They were rewritten three times on 2026-11-20, once after each of the user's first reviews that day. The first version had asked for long comments and for checks in every function, which contradicted `adder.gd`. The second leaned on outside knowledge. The third fixed the rule for names. Check, then act, and the two rules about signals, came from the reviews after those. All of the code was brought to each rule on the day it was written.
