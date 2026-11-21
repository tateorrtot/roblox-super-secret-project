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
- **A rule of the game is not a check.** `GroundItems.getIdsInPickupReach` leaves out a ground item that is too new to pick up, and `GroundItems.mergeItems` looks only at the ground items whose turn it is. Each says so in its comment.

## Simple things, and what joins them
The user's rule, in three messages on 2026-11-20. Of items and placed objects: "they are two v e r y different systems that shouldnt rely on or mention eachother i feel. Glue code for them should exist outside of them." Of an item that places an object: "Theres items. Theres the event of having the item selected. --> Causes some code to get ran ... Theres the event of "interacting" while having the item selected --> causes some code to get ran ... Just keep it generic." And of the whole: "Systems shouldnt know about eachother. Dont pull out abstractions. ... You compose simple things and systems together and use glue code." Their words in full are in `docs/working/code-reviews/2026-11-20-9-simple-things-and-glue.md`.
- **A system does one job and knows no other system.** Items and stacks. Inventories. Plots and the objects placed on them. Ground items. Each is what Unix calls a program: `ls` lists, `grep` searches, and nobody writes `catgrep`. The test is the user's: could it be lifted out and shipped as a FoxFabric addon? `python tools/delete_directory_test.py` shows what breaks when each directory goes.
- **The general code never asks what sort of thing a thing is.** No table, flag or type says that an item places, burns or is eaten, or that a placed object holds things. Claude kept such a table, `PlaceableItems`, and the user: "Youve coupled the idea of items and placing together still with PlaceableItem. Now youve shot yourself in the foot and cant make a wand." A fact that one thing needs about an item is that thing's own, keyed by the item's id, as `Stove.FUEL_SECONDS` is the stove's.
- **Each thing has a script of its own, and the general code calls it.** `ItemScripts` holds the script of each item, and `PlacedObjectScripts` the script of each kind of placed object. A request finds the script of the thing the player acted with or on, and calls the function for what they did: `interactWithTile`, `interact`, `breakPlacedObject`. The user: "Placed items kinda each get their own class / script. That contains the spaghettiii. its basically the mediator pattern."
- **A script has only the functions its thing has a use for.** "It CAN have an inventory. It CAN have a process. It CAN have giant explosion when clicked." Nothing happens for a thing with no script, or with a script that lacks the function. Luau has no `interface` keyword: a table type that lists functions is one, and the type checker refuses a script whose function takes the wrong arguments, at the line where it is registered.
- **A thing's script is where systems meet.** `Crate.place` makes an `Inventory` and hands `Plot.placeObject` a placed object with it on. `CrateItem.interactWithTile` asks `World.canPlaceObject` and calls `Crate.place`. The systems it calls never hear of each other.
- **Things stay dumb.** The user, 2026-11-20: "Things staying "DUMB" is the absolute best way to keep things decoupled. You cant anticipate everything so dont. Just make the spaghetti contained." A thing's script is handed only what it uses, and requires only what its one job needs. Of `CrateItem`, which had required `Hotbar` and `PlayerState`: "who said an item was always going to be tied to a player. Or a hotbar?" Their words are in `docs/working/code-reviews/2026-11-20-10-who-said.md`.
- **A script answers whoever called it, and the caller acts on the answer.** `CrateItem.interactWithTile` returns how many crate items were used up. It does not know where the item was held, and whoever called it takes that many away. An answer for the one who asked is a return value. News for whoever cares, when the sender does not know who that is, is a signal.
- **Strong systems, and content that glues them.** The user, 2026-11-20: "Id much prefer a strong robust collection of systems that have content that glues them all together in a messy frenzy. As long as its contained to each contents script - it doesnt matter! The code spaghetii is contained". A system is pulled out of a thing's script when a second thing needs it: recipes, when a second thing cooks. Mess inside one thing's script is not a fault.
- **How a thing looks is the thing's own, and a black box.** The user, of a table that gave every kind of placed object a colour: "who said colour? Are you coupling visuals to logic? ... it could be replaced with a model scene with who knows what in it, animation players, imported meshes, text hovering above etc. Its an unknown black box and it sounds like you just make a contract that placedobjects are a cube with a colour." No rule holds what a placed object looks like, and no general drawing piece decides it. In Roblox the black box is a `Model`, as a scene is in Godot. No item has a colour either, since 2026-11-21. Where a thing has no art, a drawing piece shows one plain grey block with the thing's name, and the grey is that piece's own. A stand-in is never written into the content, where it reads as a rule of the game: "why is there a colour..? Im confused".
- **Nothing is pulled out before there is a pattern.** `CrateItem` and `StoveItem` are written out alike, on purpose. The user: "You cant pull out and abstract a very specifics wand implenetation until you have a pattern of it. Its the same with the placeable item!" When several things have shown the same shape, what is pulled out is a function that their scripts call. It is never a category that the general code knows.
- **The game's content is in `src/shared/content`,** each thing in one place. `Items.ALL` lists every item and `PlacedObjectKinds.ALL` every kind of placed object, and `Content.register` hands both lists to the registries. To add an item: add its table to `Items.ALL`, as a row if it only lies in a slot, or as a file of its own if it does something. To add a kind of placed object: write its file, add it to `PlacedObjectKinds.ALL`, and write the piece in `src/server/content` that makes its Model. If an item shows something in the world while selected, write its piece in `src/client/content` and add it to the table in `Main.client`.
- **That changes no system and no request, as long as the thing answers what a request already tells of:** a bare tile interacted with, or a placed object interacted with or broken. It does not hold for a thing that needs more. An item used on the open air or on a placed object needs a new request and a new function of `ItemScript`. A placed object that does something as time passes has an `advance` in its script, and one that tells a player's machine more than its inventory has a `getScreenData`. Neither changes general code (`docs/game/placed-objects.md` lists what is left).
- **What is about the player is the request's. What is about the thing is its script's.** A request is what a player did, so it settles what only a player has: a character, how far that character reaches, and the hotbar slot that what they hold is in. The script says what the thing does. Claude first had the request ask reach for a placed object and the script ask it for a tile; then, on a reviewer's finding of the two owners, moved it into every script, which is why every script was handed a player. The user asked why an item knew about players, and it moved to the request.
- **A kind makes its own objects, with what they have on them.** `Crate.place` builds a placed object with an inventory on it and hands it to `Plot.placeObject`. The plot keeps that table and reads only its tile. The type `Crate.Crate` is a `Plot.PlacedObject` and an `inventory`. The user, 2026-11-20: "a crate basically being composed to have an inventory is fantastic." A kind's `place` is the one way its objects are made, and its other functions fail for a placed object without what `place` puts on it. `Stove.place` builds a stove the same way, with its slots, its fire and its work on it.
- **Glue joins two systems, and neither requires the other.** Picking up was a function of `GroundItems` that took an `Inventory`, so one system's module required another's. The user: "Glue code that connects the ground items and inventories is perfectly okay as long as its not straight up coupling directories/modules together". Now `GroundItems` says what is in pickup reach and lets items be taken out of a ground item, and `World` puts them in the pack.
- **A category is not named in the code before there are things in it.** Claude named one furnace `Station`: a folder, a type and two registries keyed by a kind of station. The user: "A station is more so something that happens to fall out rather than a defined list. A crafting table might be a station. That doesnt have 3 slots, fire, or work. The stove is more so code spaghetii that youve now contracted all "stations" to have its spaghetii." It is the stove's own code now, in `Stove`. A piece is named for what it is.
- **Systems are decoupled, and a piece of content is in one place.** The user, 2026-11-20: "Systems being decoupled - fantastic. Pieces of content being scattered - not great." An item is one table: its id, its stack size, its name, and what it does. The stove's slots, recipes, fuels, fire and cooking are all in `Stove`. Such a file may be long, and coupled to whatever the thing needs: "Its more coupled - but that doesnt really matter here. It being more intuitive and unified feels better." Their words are in `docs/working/code-reviews/2026-11-20-12-content-in-one-place.md`.

## Failure
- **What can happen in play is a return value.** No room, nothing there.
- **What comes from outside is checked once, where it comes in:**
  - a player's machine, in `InventoryRequests` and `PlotRequests`;
  - stored data, in `decode`;
  - what the Roblox scripts report, in `World`;
  - a hand-written item, when it is registered. The stove's own rows of recipes and fuels are checked by its tests.
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
- **The comments are the class reference.** `python tools/reference.py` makes a page for each module from them, laid out as a page of Godot's class reference is, and the user reads those pages before they read a script. The first paragraph of a file's comment is the page's brief description: what the thing is and does, in 200 characters or fewer.
- **Godot's writing guidelines hold for every comment and every note.** The user sent them on 2026-11-20 (https://contributing.godotengine.org/en/latest/development/documentation/docs_writing_guidelines.html). In short:
  - the active voice, with the thing described as the subject;
  - a precise verb, and not the function's own name said again;
  - no verb in `-ing` for a change that happens at once;
  - no adverb or adjective that adds nothing, and never `obvious`, `simple`, `basic`, `easy`, `actual`, `just` or `clear`;
  - the thing named again wherever `it`, `the former` or `the latter` could be doubted;
  - `the stove's fire`, not `the fire of the stove`;
  - a comma before the `and` that ends a list;
  - `Returns ...` for what a function returns, and `If true, ...` for a boolean.
- **The defined word, and one word for one thing.** Godot's guidelines: "always use them instead of synonyms, so the users know what you're talking about." The words are in `names.md`. Claude wrote "the player's machine" for the client and "the game's own things" for content, and gave the reference's sections titles of its own. The user: "Youre... again making up a lot of words to say other simple already defined things no?"
- **The comments and notes written before this do not all follow it.** A pass over them is owed (`docs/status/next.md`).

## Layers
- **The rules know nothing of the mouse, the keyboard or a touch screen.** They offer operations named for what they do to the game (`pickUpFromSlot`, `putDownInSlot`, `swapSlots`). Which operation a click or a tap asks for is decided on the player's machine, by a piece named for that device's controls, and the request it sends names the operation.
- **The server sends when something happens, not as time passes.** A thing that moves with time alone, such as a stove's gauges, is sent as the times that decide it, and drawn on the player's machine from its own clock (`Stove.Progress`). Before adding anything to what a player is told, ask whether it changes while nothing happens. This is Claude's rule, from a stove that had the server sending a player's whole pack ten times a second.
- **Deleting one directory of the rules must not break the one beside it.** `players`, `plots` and `groundItems` know nothing of one another, `plots` knows nothing of `items` or `inventory`, and `groundItems` knows nothing of `inventory`. `python tools/delete_directory_test.py` shows what breaks when each directory goes, and `python tools/lift_out_test.py` runs each system's tests with only what it requires beside it. Both are the user's tests, 2026-11-20.
- **One rule tells another with a signal.** A thing that changes says so by firing a `Signal` it holds, as a plot fires `placedObjectAdded` and a world fires `timePassed` when time has passed, and each piece that cares connects to it. The function that makes the change does not know who listens. The user asked for this of removing a placed item: "the placedItem itself should signal / event "hey im getting deleted!" and that end up cascading into the items splling and the inventory closing elsewhere."
- **Roblox's own events are for where the engine speaks to us:** input, a player joining, a message from the other machine. The user asked why we would have two systems. A `BindableEvent` is an Instance, copies the tables passed through it, and runs what is connected to it later and in no promised order, so it cannot carry the rules' own values or keep their order (`docs/research/19-roblox-events.md`). The user, having heard that: "Okay I stand corrected. Signals are good."
- **Break it up.** When a piece does more than one thing, split it: a directory, a file, a function, a block. Decide which layer each part belongs on, and build the higher on the lower.
- **On the Roblox side** (`src/server`, `src/client`):
  - A piece that draws is named for what it draws, ending in `Gui` on a player's machine (`SlotGui`, `HotbarGui`) and `Parts` on the server (`GroundItemParts`). It is told what to show, reports clicks through callbacks it was given, and never changes the game's state.
  - What the player does to the world is two of Roblox's input actions, `Interact` and `Break`, declared in `default.project.json` with the button each is bound to (`docs/roblox/input.md`). `Main.client` connects to them. The class that read those clicks by hand, `UseAndHit`, is gone.
  - A piece that turns input on the inventory screen into requests has no settled name yet. `InventoryControls` failed the user's reading, as `PlotControls` did: "controling a plot? ... isnt that the plots job?" Roblox's own scripts call such a module by what it reads, as `CameraInput`.
  - What an item shows in the world while it is selected is a piece of its own in `src/client/content`, with `update` and `hide`.
  - How a kind of placed object looks is a piece of its own in `src/server/content`, with `make`, which returns the kind's `Model`, and `update` if the look changes: `CrateModel`, `StoveModel`. `Main.server` keeps the table of them by the kind's id and hands it to `PlotParts.update`, which knows only that each is a Model standing on its pivot. Until there is art, each is a `PlaceholderBlock`.
  - How a kind's screen is laid out, when it is more than rows of slots, is a piece of its own in `src/client/content`, with `place`, `hide` and `update`: `StoveScreen`. `Main.client` keeps the table of them by the kind's id, and hands the piece to `InventoryGui.show`, which knows nothing of stoves.
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
