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
  Players
    PlayerState       one player: pack, hotbar, screen, where they stand   built
  Plots and building
    Plot              a grid of tiles and the items placed on it       built: one shared plot, one item to a tile
    Footprint, a plot of one's own, walls, floors and ceilings         not started
  Stations and recipes
    RecipeRegistry, RecipeDefinitions, Station                         built: the stove
    StationProgress   a station's fire and work, as times                built
  The world
    GroundItems       stacks lying on the ground                       built
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
    GroundItemParts, PlotParts, PlaceholderWorld                       built, placeholder blocks
  Later: conditions, creatures, people, carriers, places, bodies and needs
```

## Where it lives
- **The rules** are in `src/shared`: plain Luau with no Roblox calls, each piece tested in `tests/`. Its folders require one way only: `items`, then `inventory`, then `players`, `stations` and `plots`, then `save` and `world`, with `requests` on top. `lune run tools/requires` checks that.
- **The player's machine** is `src/client`. `Main.client.luau` is the only LocalScript, and holds the wiring and the keys. `SlotGestures` and `InventoryControls` are plain Luau, tested in `tests/client`. The rest draws, or works out what the pointer is over.
- **The server** is `src/server`. `Main.server.luau` is the only Script. It tells the `World` what happens, draws it, and sends each player their snapshot. It also limits each machine to 60 requests a second, and decides where a dropped stack lands.

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

Nothing on the server knows that a mouse exists. Nothing is applied on the player's machine before the server answers (`docs/status/next.md`).
