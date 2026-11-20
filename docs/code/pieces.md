# The pieces

What exists in the code. `python tools/outline.py` prints every public function of every file, read from the code itself, so this file stays short.

The game from the top down. Each line is a tangible thing, and the lines indented under it are its parts.

```
The game
  Items: every thing you can hold
    ItemRegistry, ItemStack, ItemDefinitions, ItemLooks               built
  Inventories: places that hold items
    Inventory         slots that hold stacks                           built
    InventoryScreen   what a player has open, and the carried stack    built
    Hotbar            the first slots, and the selected one            built
  Where and which way
    Position, Direction   a point in the world; a way in the world          built
  How one rule tells another
    Signal            the callbacks that a thing calls when it changes   built
  Players
    PlayerState       one player: pack, hotbar, the screen they have open, where their character is   built
  Plots: where objects are placed
    Plot              a grid of tiles and the objects placed on it     built: one shared plot, one object to a tile
    Footprint, a plot of one's own, walls, floors and ceilings         not started
  Stations and recipes
    RecipeRegistry, RecipeDefinitions, Station                         built: the stove's. `Station` is a furnace, and no more general than that
    StationProgress   a station's fire and work, as times                built
  The world
    GroundItems       stacks loose in the world: spawned, merged, picked up, expired   built
    PlotCollision     what gives way when an object is placed: ground items are pushed out of the tile   built
    World             the game's state and what can be done in it      built
    PlayerSnapshot    what a player's machine is told                  built
  Kinds of placed object: what each one has and does
    Crate, Stove      a module for each kind                           built
    PlacedObjectKinds every kind by id, and what a kind must have      built
    PlaceableItems    which item places which kind                     built, placeholder rows
    PlacedObjectLooks how each kind is shown                           built, placeholder rows
  Requests: what a player's machine may ask for
    InventoryRequests, PlotRequests, Requests, Messages                built
  SaveData                                                             built; nothing stores it yet
  On the player's machine
    SlotGestures, InventoryControls   mouse and keys on the screen     built, PC only
    UseAndHit         the clicks on the world                          built, PC only; no break by touch. To be replaced
    InventoryGui, HotbarGui, SlotGui, StackIcon, PlotPointer, PlacementGhost   built, placeholder look
    ScreenScale       how big the screens are drawn in this window     built
    Remotes           the messages, as the player's machine finds them   built
  On the server
    Remotes           the messages, as the server makes them           built
    GroundItemParts   each ground item as a part Roblox's physics moves   built, placeholder blocks
    CollisionGroups   ground items pass through each other and characters   built
    PlotParts, PlaceholderWorld                                        built, placeholder blocks
  Later: conditions, creatures, people, carriers, places, bodies and needs
```

## Where it lives
- **The rules** are in `src/shared`: plain Luau with no Roblox calls, each piece tested in `tests/`. Its folders require one way only. `items`, then `inventory`, then `players` and `stations`. `plots` stands apart and requires none of them. Then `save` and `world`, then `placedObjectKinds`, with `requests` on top. `lune run tools/requires` checks that.
- **The player's machine** is `src/client`. `Main.client.luau` is the only LocalScript, and holds the wiring and the keys. `SlotGestures` and `InventoryControls` are plain Luau, tested in `tests/client`. The rest draws, or works out what the pointer is over.
- **The server** is `src/server`. `Main.server.luau` is the only Script. It tells the `World` what happens, draws it, and sends each player their snapshot. It also limits each machine to 60 requests a second.

## Two systems, and what joins them
Items and placed objects do not know each other (`conventions.md`).
- **Items:** `items` and `inventory`. A stack in a slot.
- **Placed objects:** `plots`. A placed object is a kind's id and a tile, and no more.
- **What joins them is outside both:**
  - `World` keeps what a placed object was given, by its id: an inventory, a station.
  - `placedObjectKinds` has a module for each kind, which says what its objects are given and what interacting with one and breaking one do.
  - `PlaceableItems` says which item places which kind.

## How an interaction with a placed object reaches its kind
1. On the player's machine, `PlotPointer` works out what the pointer is over, and `Main.client.luau` sends `interactWithPlacedObject`, `interactWithTile` or `breakPlacedObject`.
2. `PlotRequests` checks what was sent, and that the player stands in reach.
3. It asks `PlacedObjectKinds` for the placed object's kind, and calls that kind's function. For a bare tile it asks `PlaceableItems` what the item in the player's selected slot places, and calls that kind's `place`.
4. The kind does the rest. `Crate.breakPlacedObject` takes every stack out of the crate's inventory, takes the crate off the plot, and has the world throw a crate item and those stacks from its tile.
5. The plot fires `placedObjectRemoved`. The world closes the screens open on the crate, and drops the inventory it kept for it.

## How a click becomes a change
On the player's machine:
1. `InventoryGui` reports that a slot was pressed.
2. `SlotGestures` works out which gesture it was: a click, a double click or a drag.
3. `InventoryControls` works out which request that gesture asks for.
4. `Main.client.luau` sends the request, by name.

On the server:
5. `Main.server.luau` hands it to `Requests.carryOut`.
6. `InventoryRequests` checks what the machine sent, and calls the operation.
7. `InventoryScreen` moves the items, through `Inventory`.
8. `PlayerSnapshot.encode` makes what the player's machine is told, and the screen redraws from it.

## How a dropped stack moves
1. A request such as `dropFromSelectedSlot` comes with the way to throw, which the player's machine takes from its camera: along the ground in third person, and up and down as well in first person. It takes the stack out of the pack and calls `World.throwStackFromCharacter`.
2. That works out where the stack starts and how fast, and calls `World.spawnStack`, which makes a ground item.
3. `GroundItemParts.update` makes a part for it, at its position and moving at the velocity it was spawned with.
4. Roblox's physics moves the part, and shows that to every player. We wrote no physics, and Roblox picks which machine works the motion out.
5. Ten times a second `Main.server.luau` asks `GroundItemParts.getMovedPositions` where the parts have got to and tells `World.setGroundItemPosition`.
6. `World.advanceTo` then runs `GroundItems.mergeItems` (`docs/game/dropped-items.md`).

`PlotCollision.pushGroundItemsOutOfTile` is the one rule about motion that is ours: when an object is placed, it takes each ground item lying where the object now stands and spawns it again just outside the nearest free side. The world calls it when its plot says that an object was placed.

## How one rule tells another
`Plot.placeObject` and `Plot.removePlacedObject` fire the plot's two signals, `placedObjectAdded` and `placedObjectRemoved`. The world connected to both when it was made: for an object placed it pushes ground items out of the tile, and for one taken off it closes the screens open on it and drops the inventory and the station it was given. The plot knows nothing of screens, stations, inventories or ground items.

## What knows what
`docs/code/requires.svg` is the chart: a box for each folder with its modules, and an arrow for each require. `lune run tools/requires --chart` draws it from the code, and `lune run tools/check` fails if it has gone out of date. `python tools/delete_directory_test.py` tests the same thing by deleting.

In short: the Roblox side requires the rules and never the other way, and the rules' folders require one way only, in the order given under "Where it lives". `players`, `plots` and `stations` know nothing of one another, and `plots` knows nothing of `items` or `inventory`.

`World` is the only piece of the rules that knows `players`, `plots` and `stations` together. It holds rules of its own that could live in smaller pieces: reach, and that every station is advanced. `docs/code/reviews/16-coupling-review-2026-11-20.md` has the list.

Nothing on the server knows that a mouse exists. Nothing is applied on the player's machine before the server answers (`docs/status/next.md`).
