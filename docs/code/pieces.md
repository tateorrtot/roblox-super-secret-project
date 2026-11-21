# The pieces

What exists in the code. `python tools/outline.py` prints every public function of every file, read from the code itself, so this file stays short.

## Systems, glue and things
The folders of `src/shared` are of three sorts (`conventions.md`, "Simple things, and what joins them").

```
SYSTEMS: each does one job and knows no other system
  items        ItemRegistry, ItemStack              every item by id; a count of one item
  inventory    Inventory, InventoryScreen, Hotbar   slots that hold stacks; what a player has open; the selected slot
  plots        Plot                                 a grid of tiles and the objects placed on it
  stations     Station, StationProgress,            a fire and a recipe worked over time: a furnace, and no more
               RecipeRegistry, FuelRegistry         general than that; which item cooks into which, and what burns
  groundItems  GroundItems                          stacks loose in the world: spawned, merged, taken from, expired
  players      PlayerState                          one player: pack, hotbar, open screen, where their character is
  (top level)  Position, Direction, Signal          a point; a way; the callbacks a thing calls when it changes

GLUE: joins systems, and holds no thing of the game
  world        World            one running game: the plot, the ground items, the players, picking up,
                                and the station that each stove was made
               PlotCollision    what gives way when an object is placed: ground items leave the tile
               PlayerSnapshot   what a player's machine is told
  requests     InventoryRequests, PlotRequests, Requests, Messages   what a player's machine may ask for
               ItemScripts, PlacedObjectScripts                      the script of each item and of each kind of
                                                                     placed object, which the requests call
  save         SaveData         a player's pack as stored data. Nothing stores it yet

THINGS: the game's own, and the one place that names them
  content      Crate, Stove                         a kind of placed object each: what it has on it, and its script
               CrateItem, StoveItem                 an item's script each
               ItemDefinitions, RecipeDefinitions, FuelDefinitions   written rows, placeholders
               ItemLooks, PlacedObjectLooks         how each is shown while it has no art
               Content                              registers all of the above
```

`python tools/delete_directory_test.py` shows it holds: deleting `content` breaks none of the rules, deleting a system breaks only what is built on it, and no system breaks one beside it. `docs/code/requires.svg` is the chart of every require, drawn from the code by `lune run tools/requires --chart`.

## The Roblox side
- **The server** is `src/server`. `Main.server.luau` is the only Script. It registers the content, tells the `World` what happens, draws it, and sends each player their snapshot. It limits each machine to 60 requests a second. `GroundItemParts` and `PlotParts` draw placeholder blocks, `CollisionGroups` lets ground items pass through each other and through characters, `PlaceholderWorld` is the grey plot, and `Remotes` makes the messages.
- **The player's machine** is `src/client`. `Main.client.luau` is the only LocalScript, and joins the rest.
  - `inventory`: `InventoryGui`, `HotbarGui`, `SlotGui` and `StackIcon` draw. `SlotGestures` and `InventoryControls` are plain Luau, tested in `tests/client`, and turn mouse and keys on the screen into requests.
  - `world`: `PlotPointer` says what a point of the screen is over. `BreakClick` tells a click of the Break action from a turn of the camera. `PlacementGhost` draws a see-through block on a tile. `LocalCharacter` says whether the character reaches a point, for drawing only.
  - `content`: `CrateItemGhost` and `StoveItemGhost` are what each of those items shows while selected.
- **The input actions** `Interact` and `Break` are Instances under `ReplicatedStorage.Inputs.World`, declared in `default.project.json` (`docs/roblox/input.md`).

## How an interaction reaches the thing's own script
1. On the player's machine, Roblox fires the input action `Interact`. `Main.client.luau` asks `PlotPointer` what the pointer is over, and sends `interactWithPlacedObject` or `interactWithTile`. A click of `Break` sends `breakPlacedObject`.
2. `PlotRequests` checks what was sent and what is about the player: that they have a character, and that it reaches the tile or the placed object.
   - For a placed object: it asks `PlacedObjectScripts` for the script of the object's kind, and calls its `interact` or `breakPlacedObject`.
   - For a tile: it asks `ItemScripts` for the script of the item in the selected hotbar slot, calls its `interactWithTile`, and takes out of that slot as many items as the script says were used up.
3. The script does the rest, by calling systems. `CrateItem.interactWithTile` asks whether an object can stand on the tile, calls `Crate.place`, and returns 1. It knows no player and no hotbar. `Crate.breakPlacedObject` takes every stack out of the crate's inventory, takes the crate off the plot, and has the world throw a crate item and those stacks from its tile.
4. The plot fires `placedObjectRemoved`. The world closes the screens open on the crate. The crate's inventory was on the crate itself, and goes with it.

Nothing happens for a thing with no script, or whose script lacks the function. A request, a registry and a system each know nothing of crates.

## What an item shows while it is selected
Every frame `Main.client.luau` asks what the pointer is over, and tells the piece of the item in the selected hotbar slot, if that item has one: `update` with the target, and `hide` once when the item is selected no longer. `CrateItemGhost.update` shows a see-through crate on a bare tile within reach. The table of pieces is in `Main.client.luau`.

## How a click on the inventory screen becomes a change
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

## How a ground item is picked up
`World.advanceTo` asks `GroundItems.getIdsInPickupReach` for the ground items in pickup reach of each character, nearest first. For each one it adds the stack to the player's pack with `Inventory.addItems`, and takes as many as went in out of the ground item with `GroundItems.takeFromItem`. `groundItems` and `inventory` do not require each other.

## How one rule tells another
`Plot.placeObject` and `Plot.removePlacedObject` fire the plot's two signals, `placedObjectAdded` and `placedObjectRemoved`. The world connected to both when it was made: for an object placed it pushes ground items out of the tile, and for one taken off it closes the screens open on it and drops the station it was made. The plot knows nothing of screens, stations, inventories or ground items.

## What is not yet a system of its own
`World` is the only piece of the rules that knows `players`, `plots`, `stations` and `groundItems` together. It holds rules that could live in smaller pieces: reach, picking up, and that every stove's station is kept and advanced. The user said to leave it as one piece of glue for now. `docs/code/reviews/16-coupling-review-2026-11-20.md` has the list, and `docs/game/placed-objects.md` ends with what the game still decides for every kind of placed object.

Nothing on the server knows that a mouse exists. Nothing is applied on the player's machine before the server answers (`docs/status/next.md`).

Later: a plot of one's own, walls and floors, conditions, creatures, people, carriers, places, bodies and needs.
