# Items, placed objects, and what each kind does

How the user pictures a thing in the game, and how the code follows it. Their words are from 2026-11-20.

## The user's picture
> I see a "log" as something that can be in item or block/placed form. In item form it has a texture a name and a max stack. Maybe some other data later. In block form its associated with some kinda grid, has a position, a texture, and some other properties we cant really predict quite yet (what tools breaks it faster? how long does it take to break? does it have orientation? is it like stairs where it can be placed in all kinds of orientatinos with special block state depending on other things like a block update triggered by a block being placed adajacent to it making it a corner stair?

> For a stove and a crate, theyre just items/blocks. They both happen to have extra data associated. Like an inventory and a screen that gets displayed when you interact with them. When you interact with them they happen to show that screen and that screen happens to show the inventory / deeper workings.

> a station is kinda like a black box. Think minecraft UIs we geuinely dont know what happens when we open the screen. Could be a furnace, a crafting table, a cutting board, a mixer, a machining table... who knows what happens once its open or what the UI is or entails. Its most likely some slots that do stuff but not always.

> What about a chest? Or a crate? These are all basically the same thing of "thing that opens a menu". Same with a book item. It just so happens some of these things have more advanced functionality, like processing items. Or scanning for ore with a popup text at the bottom of your screen. Or a magic wand that has no screen per say but requires you to draw with your finger or mouse in a way to cast a spell and shows UI for it.

> We cant really predict what its going to be or "genericize" a lot of the time if that makes sense. I.e. its gonna be spaghettii but we gotta contain the spaghettii.

After Claude asked whether "a crate" should spill or keep what is in it:
> Shouldnt it be the item itself that determines what happens when it breaks? For example obsidian in minecraft doesnt drop its item unless you got a diamond pickaxe or netherite pickaxe. its the strategy pattern basically.

> a wand and a log are both just plain inventory items ... if you interact with a log over a valid plot spot it places. if you do the same with a wand it might cast a spell. see how that works? it sounds like youre favoring inheritance over composition - thats bad!

> Its per placed item (or whatever were calling it). ... What if we have a sack like from the mod supplementaries? You break it and the items stay inside like a shulker box. ... What if we break it and the items transform. What if we break it and theres not items in there. What if we break it and its like a cage thats containing an entity so now the entity should actually pop out say a bunny rabbit.

On what the two systems are, and the name:
> the item in the inventories, and the placed object should be entirely seperate and decoupled. they are two v e r y different systems that shouldnt rely on or mention eachother i feel. Glue code for them should exist outside of them.

> I like PlacedObject!

And on how each kind is written, when Claude showed the three steps:
> Yup so placed items shouldnt have an inventory. They could have some kinda "component" tacked on.

> Placed items kinda each get their own class / script. That contains the spaghettiii. its basically the mediator pattern. Its main thing is that its a placed item. It CAN have an inventory. It CAN have a process. It CAN have giant explosion when clicked. Who knows the spaghetti is contained to that script.

How they picture the furnace's screen: a background, three slots laid out as fuel, what is worked on and what comes out, and other parts drawn over them, such as a fuel bar and an arrow that shows how far the work has got.

## What follows
- **Items and placed objects are two systems.** A thing in a slot is an item. A thing standing on a plot is a placed object. Neither knows the other.
- **Each kind of placed object has a script of its own,** and what that kind does stays inside it. The rest of the game knows that a placed object was interacted with or broken, and nothing of what follows.
- **A placed object has its kind and its tile, and what its kind composes it of:** an inventory, a process, or anything else.
- **A thing held in the hand can open a screen too,** or show something with no screen at all.
- **Nothing is made general ahead of the things that need it.**
- **A crate that is broken spills what is in it.** That is the crate's own doing, and says nothing of a sack or a cage.

## The processes they want next
> Something simple like the furnace - two inputs and an output in a single block - something very different - like a basin from create where items can be put in its inventory and depending on other things like a "mixer" or a "press" above will enact processes on the basin and change its contents - and something that is very different - like a fan processor from the create mod where if say put water infront and an item on certain specified inventories like belts or "depots" that it can reach (unobstructed) will wash the items. Change the water out for lava and now it smelts. Or even just put the loose item out infront no inventory. For something like a press in create it works on loose items too with no basin.

Three kinds, then: one that works on what is inside it; one that is worked on by what stands over it; and one that works on what is in front of it, in an inventory or loose on the ground.

## Where the code is
Built on 2026-11-20, on the branch `placed-objects`. How it is put together is in `docs/code/pieces.md`.
- **A placed object is a kind, a tile, and whatever its kind put on it.** The plot keeps the whole table and reads only the tile. `plots` requires neither `items` nor `inventory`.
- **Each kind is a module in `src/shared/content`:** `Crate` and `Stove`. Each has `place`, `interact` and `breakPlacedObject`, and says in its own file what they do. The last two are the kind's script, which `PlacedObjectScripts` holds and the requests call.
- **A crate carries its own inventory,** on the placed object that `Crate.place` builds. The user, 2026-11-20: "a crate basically being composed to have an inventory is fantastic." A stove's station is still kept by the world, by the placed object's id.
- **An item that places an object has a script of its own:** `CrateItem` and `StoveItem`, which `ItemScripts` holds. No table says which items place. The user asked why one still did, on 2026-11-20 (`docs/working/code-reviews/2026-11-20-9-simple-things-and-glue.md`).

What the game still decides for every kind alike, each for the piece named:
- **A screen is a pack, another inventory and a furnace's gauges.** The player's machine draws a grid, or the furnace if the inventory has three slots. Any other screen needs the screens to be the kind's own.
- **Over time, the one thing a placed object can do is be a furnace:** the world advances every `Station`. `Station` is a furnace under a general name, and the user said to leave it until a second process shows what the kinds share. On 2026-11-20 they asked why the noun is in the code at all (`docs/working/code-reviews/2026-11-20-11-where-is-the-item.md`).
- **A placed object is a cube that fills one tile.**
- **An item's script is told of one thing only: that a bare tile was interacted with.** That was all the crate and the stove needed. A wand cast at a creature, at a placed object or at nothing needs a function for each, added when the wand is.
- **The item in hand takes no part when a placed object is interacted with or broken,** though the kind's script is handed the player and could look. Which of the two answers first, the object or the item, is not decided: nothing needs it yet.
- **What the world keeps for a placed object is a store for each sort of thing:** an inventory, a station. A kind that keeps or does something new over time, such as a plant that grows, needs a new store in `World`, a new function to add to it, a line where the object is taken off, and a loop in `World.advanceTo`. A reviewer who applied the user's test on 2026-11-20 called this the same table that `PlaceableItems` was, moved into `World`. The shape that would mend it: a kind's own module keeps what its objects have, and hears from the plot that one was taken off and from the world that time passed.
- **How a kind's object looks while it works is drawn by general code:** the server's `PlotParts` makes any station that burns glow, and the player's machine draws the furnace's gauges for any other inventory of three slots. Both belong in the stove's own pieces.
- **A break is at once.** A kind can leave what it likes, and nothing yet takes time or a tool.
