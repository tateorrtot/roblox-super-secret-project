# The tenth review: simple things and glue (2026-11-20)

The user read Claude's report on the split into two systems and wrote twice. The first message was about the table `PlaceableItems`. The second came while Claude was working on the first, and was about how Claude breaks a problem up. Their words, and what Claude took from them.

## "why do PlaceableItems still exist"
> right so why do PlaceableItems still exist.

> its just a specific item that happens to have this component on it that "when i happen to have it selected and hover over a placeable grid/plot" it shows a ghost and "when i do interaction with on a valid grid" it happens to place it. thats also two jobs - not one.

> so a PlaceableItem sounds like this weird class youve invented that does not job - but three.

> Theres items.
> Theres the event of having the item selected. --> Causes some code to get ran -- --> in this case the ghost outline
> Theres the event of "interacting" while having the item selected --> causes some code to get ran -- --> in this case it checks if you can place and then does place

> Am I misunderstanding?

- **They were not misunderstanding.** `PlaceableItems` was a table of two rows, from an item's id to the id of the kind of placed object it placed. The server's `PlotRequests.interactWithTile` read it to place, and `Main.client` read it to draw the ghost. So the general code asked of every item "does this one place something?", and placing was the one thing an item in the hand could do.
- **Claude kept it on purpose, for a wrong reason.** It judged a script for each item to be building ahead of need. The generic hook is the simple thing. What waits for a pattern is a helper shared between scripts.
- **There are items, and there are events that code is attached to.** The item being selected is one, and its code runs on the player's machine. Interacting while it is selected is another, and its code runs in the rules. Those are two jobs.

## "cant make a wand"
Claude's report had said: "An item in the hand can only place: a wand has nowhere to say 'cast'."
> Right. so my proposal changes that. Stop coupling things and writing contracts with inheritance. Inheritance is stupid. Youve coupled the idea of items and placing together still with PlaceableItem. Now youve shot yourself in the foot and cant make a wand.

> Its the strategy pattern all over. Just keep it generic. You cant pull out and abstract a very specifics wand implenetation until you have a pattern of it.

> Its the same with the placeable item!

- **The hook is generic and the thing is specific.** The general code calls the selected item's own script. It does not know what the script does.
- **Nothing is abstracted before there is a pattern, the item that places included.** So the crate item and the stove item are each written out in full, alike.

To "Shall I rebuild the world's input next, so that UseAndHit goes?" they answered: "Yes that sounds good."

## How Claude breaks a problem up
> Let me put it like this. Youre seeing a very complex problem. "Make a game with a high player count that retains its high player count for as long as possible." The way youre breaking up this problem is subpar and needs work. Were deep into the problem. We need to be able to do things like make stoves, magic wands, swords, potions, backpacks, mixers, fermenters, fabrication benches, smithing anvils, wizard armor, skills, vehicles, helpers - this all together is very complex.

> You seem to be noticing the grander pattern and using tried and true ways to immeditally organize and understand this problem with my help. We need an inventory system. We need a way to hold items. We need a way to place items. We need a way to interact with the world and manipulate it. But then we get deep into the problem and you seem to just... couple it all together. No! Systems shouldnt know about eachother. Dont pull out abstractions. You make what would be many. many. many. simple things into some intermediate things and advanced things. Those sound good - its not.

> 6 months from now I come back and because of your way of solving problems we have PlaceableMagicCastableEdibleNonSmeltableItem as a class. That kind of spaghettii shouldnt live as a generic class. Thats just stupid. Dont mix roles. You cant use inheritance to get yourself out of this hole you have to use composition. You compose simple things and systems together and use glue code. You dont tie systems together and make spaghetii mess. If you cant make good decoupled FoxFabric addons out of what you make - youre a failure and need to start over.

> We dont know what were going to add. We have no idea what were going to make. Its always a black box. Think of pipelines in linux. We make a program that says what directory im in. pwd Then we make a program that lists the files in a directory ls We make a program to edit files nano We make a program to list out in the terminal the contents of a file cat We make something to search a file grep We make a program to pipe the outputs of one program into anothers input. | What we dont do is go ah we need cat and grep. Lets make catgrep Oh now it depends on what directory were in pwdcatgrep No. Thats dumb. You dont make something for every combination. You cant do every combination.

- **Many simple things, not a few clever ones.** A system does one job, as `ls` lists and `grep` searches. It does not know the system beside it.
- **Combinations are composed, never built.** No class or table stands for a combination of roles. A thing that places and burns and is eaten is one item whose own script calls three systems.
- **The test is the user's own:** could each piece be shipped as a decoupled FoxFabric addon? A registry that names the game's crate and stove could not, so the registries stopped naming them.
- **What will be added is not known.** So the general code makes no promise about any kind of thing, and a thing's script has only the functions that thing has a use for.
- **A fact one system needs about an item belongs to that system.** That a log burns for 16 seconds was a field of every item's definition. It is the stations' fact, and moved to `FuelRegistry`.

## What changed in the code
- `PlaceableItems` is gone. `ItemScripts` holds a script for each item and `PlacedObjectScripts` one for each kind of placed object, each filled by `register` and read by `find`. Neither names a thing of the game.
- `CrateItem` and `StoveItem` are the two items' scripts, and `CrateItemGhost` and `StoveItemGhost` are what each shows on the player's machine while selected.
- The game's own things are in `src/shared/content`, and `Content.register` is the one list of them. The rules name none of them.
- A request checks only what a machine sent. How far a player may stand is for the thing's script to ask.
- The rule this became is under "Simple things, and what joins them" in `docs/code/conventions.md`.
- **It is not all mended.** A helper told to apply this review to the result found where general code still decides for every kind of thing: `World` keeps a store for each sort of thing a placed object can be given, the furnace's screen and glow are drawn by general code, and picking up is one function across two systems. The list is in `docs/status/now.md`.
