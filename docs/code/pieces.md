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
    Position, Direction   a point in the world; a way along the ground      built
  Players
    PlayerState       one player: pack, hotbar, the screen they have open, where their character is   built
  Plots and building
    Plot              a grid of tiles and the items placed on it       built: one shared plot, one item to a tile
    Footprint, a plot of one's own, walls, floors and ceilings         not started
  Stations and recipes
    RecipeRegistry, RecipeDefinitions, Station                         built: the stove. `Station` is a furnace, and no more general than that
    StationProgress   a station's fire and work, as times                built
  The world
    GroundItems       stacks loose in the world: spawned, merged, picked up, expired   built
    PlotCollision     what gives way when an item is placed: ground items are pushed out of the tile   built
    World             the game's state and what can be done in it      built
    PlayerSnapshot    what a player's machine is told                  built
  Requests: what a player's machine may ask for
    InventoryRequests, PlotRequests, Requests, Messages                built
  SaveData                                                             built; nothing stores it yet
  On the player's machine
    SlotGestures, InventoryControls   mouse and keys on the screen     built, PC only
    UseAndHit         the two actions on the world                     built, PC only; no Hit by touch
    InventoryGui, HotbarGui, SlotGui, StackIcon, PlotPointer, PlacementGhost   built, placeholder look
  On the server
    GroundItemParts   each ground item as a part Roblox's physics moves   built, placeholder blocks
    CollisionGroups   ground items pass through each other and characters   built
    PlotParts, PlaceholderWorld                                        built, placeholder blocks
  Later: conditions, creatures, people, carriers, places, bodies and needs
```

## Where it lives
- **The rules** are in `src/shared`: plain Luau with no Roblox calls, each piece tested in `tests/`. Its folders require one way only: `items`, then `inventory`, then `players`, `stations` and `plots`, then `save` and `world`, with `requests` on top. `lune run tools/requires` checks that.
- **The player's machine** is `src/client`. `Main.client.luau` is the only LocalScript, and holds the wiring and the keys. `SlotGestures` and `InventoryControls` are plain Luau, tested in `tests/client`. The rest draws, or works out what the pointer is over.
- **The server** is `src/server`. `Main.server.luau` is the only Script. It tells the `World` what happens, draws it, and sends each player their snapshot. It also limits each machine to 60 requests a second.

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
1. A request such as `dropFromSelectedSlot` comes with the way to throw, which the player's machine takes from its camera. It takes the stack out of the pack and calls `World.throwStackFromCharacter`.
2. That works out where the stack starts and how fast, and calls `World.spawnStack`, which makes a ground item.
3. `GroundItemParts.update` makes a part for it, at its position and moving at the velocity it was spawned with.
4. Roblox's physics moves the part, and shows that to every player. We wrote no physics, and Roblox picks which machine works the motion out.
5. Ten times a second `Main.server.luau` asks `GroundItemParts.getMovedPositions` where the parts have got to and tells `World.setGroundItemPosition`.
6. `World.advanceTo` then runs `GroundItems.mergeItems`: of two ground items of one kind that are close together and fit in one stack, the bigger takes in the smaller. One that was spawned or moved is looked at then, and one that lies still every two seconds (`docs/game/dropped-items.md`).

`PlotCollision.pushGroundItemsOutOfTile` is the one rule about motion that is ours: when an item is placed, it takes each ground item lying where the placed item now stands and spawns it again just outside the nearest free side. `World.placeItem` calls it.

## What knows what
`docs/code/requires.svg` is the chart: a box for each folder with its modules, and an arrow for each require. `lune run tools/requires --chart` draws it from the code, and `lune run tools/check` fails if it has gone out of date. `python tools/delete_directory_test.py` tests the same thing by deleting.

In short: the Roblox side requires the rules and never the other way. In the rules, `requests` is on top, then `world`, then `players`, `plots` and `stations`, which know nothing of one another, then `inventory`, then `items`.

`World` is the only piece of the rules that knows `players`, `plots` and `stations` together. It also holds rules of its own that could live in smaller pieces: the push out of a tile, reach, and what a placed item does over time. `docs/code/reviews/16-coupling-review-2026-11-20.md` has the list.

Nothing on the server knows that a mouse exists. Nothing is applied on the player's machine before the server answers (`docs/status/next.md`).
