# Items, placed items, and what each one does

How the user pictures a thing in the game, and how far the code is from it. Their words are from 2026-11-20.

## The user's picture
> I see a "log" as something that can be in item or block/placed form. In item form it has a texture a name and a max stack. Maybe some other data later. In block form its associated with some kinda grid, has a position, a texture, and some other properties we cant really predict quite yet (what tools breaks it faster? how long does it take to break? does it have orientation? is it like stairs where it can be placed in all kinds of orientatinos with special block state depending on other things like a block update triggered by a block being placed adajacent to it making it a corner stair?

> For a stove and a crate, theyre just items/blocks. They both happen to have extra data associated. Like an inventory and a screen that gets displayed when you interact with them. When you interact with them they happen to show that screen and that screen happens to show the inventory / deeper workings.

> a station is kinda like a black box. Think minecraft UIs we geuinely dont know what happens when we open the screen. Could be a furnace, a crafting table, a cutting board, a mixer, a machining table... who knows what happens once its open or what the UI is or entails. Its most likely some slots that do stuff but not always.

> What about a chest? Or a crate? These are all basically the same thing of "thing that opens a menu". Same with a book item. It just so happens some of these things have more advanced functionality, like processing items. Or scanning for ore with a popup text at the bottom of your screen. Or a magic wand that has no screen per say but requires you to draw with your finger or mouse in a way to cast a spell and shows UI for it.

> We cant really predict what its going to be or "genericize" a lot of the time if that makes sense. I.e. its gonna be spaghettii but we gotta contain the spaghettii.

How they picture the furnace's screen: a background, three slots laid out as fuel, what is worked on and what comes out, and other parts drawn over them, such as a fuel bar and an arrow that shows how far the work has got.

## What follows
- **An item has two forms:** held, and placed. Each form has its own facts.
- **What a placed thing does is its own business.** The game knows that it is there and that using it may open a screen. What is behind the screen is that thing's to say.
- **A thing held in the hand can open a screen too,** or show something with no screen at all.
- **Nothing is made general ahead of the things that need it.** The mess a kind of thing needs stays inside that kind.

## The processes they want next
> Something simple like the furnace - two inputs and an output in a single block - something very different - like a basin from create where items can be put in its inventory and depending on other things like a "mixer" or a "press" above will enact processes on the basin and change its contents - and something that is very different - like a fan processor from the create mod where if say put water infront and an item on certain specified inventories like belts or "depots" that it can reach (unobstructed) will wash the items. Change the water out for lava and now it smelts. Or even just put the loose item out infront no inventory. For something like a press in create it works on loose items too with no basin.

Three kinds, then: a block that works on what is inside it; a block that is worked on by what stands over it; and a block that works on what is in front of it, in an inventory or loose on the ground.

## Where the code is
- **`Station` is a furnace under a general name.** It has three slots for what is worked on, fuel and what is made; a fire; and recipes of one item in and one item out. The stove is the only one.
- **The screen has one special case,** written into the inventory screen's drawing code. An inventory of three slots that belongs to a station is drawn with the slot for what is worked on above the slot for fuel, a fire gauge between them, and the slot for what is made to the right, past a work gauge. It is close to what the user pictures, and it is not the furnace's own.
- **`World` knows stations by name.** It keeps a list of them and moves each on in time.
- **A crate is not a station.** It is a placed item with an inventory, and the same screen draws it as a plain grid.
- **A held item cannot open a screen.**

None of the three processes above fits `Station`. The second one to be built will show what the kinds really share, and that is the time to give each kind a place of its own. Until then `Station` should be read as "the furnace".
