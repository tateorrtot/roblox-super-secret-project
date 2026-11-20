# An audit after the user's eighth review (2026-11-20)

The user asked of four faults they had found: "are you doing a pattern of this across the codebase? any of these issues im bringing up?" This is the answer, read from the code.

**How it was done.** Nine helpers on Sonnet. Three gathered what Roblox, Godot, Minecraft and RimWorld call things, from their own documentation. Three read all of `src` against the user's words. A skeptic then tried to refute each reader, and Claude checked a sample of the lines by hand. Nothing in the code was changed by it. The user's words are in `docs/working/code-reviews/2026-11-20-7-the-item-decides.md`.

## 1. What the game promises for every item
**Yes, it is a pattern, and it has one root.** An item is a row of flags (`placeable`, `slotCount`, `burnSeconds`) and a table of recipes, and the rest of the code reads those flags to decide what an item does. A kind of item can say nothing of its own: `ItemRegistry` refuses any field it does not list.

Twelve promises stood up to the skeptic. Each is made for every item or every placed item alike.

| | The promise today | Made in | What of the user's it breaks |
|---|---|---|---|
| 1 | A placed item that is hit comes off the plot at once, with no tool and no time | `PlotRequests.hitPlacedItem` | Obsidian that needs the right pickaxe. A thing that takes time to break |
| 2 | It then drops one of itself and every stack inside it | `World.throwPlacedItemAndContents` | A sack that keeps its stacks. A cage that lets a creature out. A thing that leaves nothing |
| 3 | Using a placed item opens its inventory, and does nothing if it has none | `PlotRequests.usePlacedItem`, `World.canOpenPlacedItemScreen` | A crafting table or a book, whose screen is not a grid of slots |
| 4 | Using an item over a bare tile places it if it is flagged `placeable`, and does nothing if not | `Plot.canPlaceItem`, `PlotRequests.placeSelectedItem`, `Main.client`, `UseAndHit` | A wand that casts a spell where a log places itself |
| 5 | The item in hand takes no part when a placed item is clicked | `UseAndHit` | A tool used on a placed thing |
| 6 | The one thing a placed item can hold is an inventory, made empty when it is placed | `Plot.placeItem`, the `PlacedItem` type | A sack placed with what it carried. A cage's creature. A book's page |
| 7 | The one thing a placed item can do over time is be a furnace, and it is one if a recipe names it | `World.newStationFor`, `World.stations`, `World.advanceTo` | Any second process |
| 8 | A slot of a placed item takes anything, unless the placed item is a furnace | `World.openPlacedItemScreen`, `Station.slotAcceptsItem` | A sack that refuses a sack |
| 9 | A player is told of an open screen as a pack, another inventory and a furnace's progress | `PlayerSnapshot` | Any other screen |
| 10 | A screen is drawn as a grid of slots, or as the furnace if it has exactly 3 slots | `InventoryGui`, which repeats `RecipeRegistry.STATION_SLOT_COUNT` as a bare 3 | Any other screen |
| 11 | A placed item is a cube that fills one tile | `Plot`, `PlotCollision`, `PlotParts` | A rug. A thing that covers two tiles |
| 12 | The requests that touch the plot are three fixed verbs: place, use, hit | `PlotRequests`, `Requests.NAMES` | Each new kind of interaction needs a new request, a new message and a new branch on the player's machine |

**Pieces that know two things which have nothing to do with each other unless a kind of item says so:** `World` (a placed item and its contents; a placed item and a furnace; a placed item and a screen), `PlotRequests`, `PlayerSnapshot` (a screen and a furnace's progress), `InventoryGui` (a grid and the furnace's layout), `UseAndHit` (the pointer, placing, opening and breaking), `PlotParts` (a cube and a fire).

**What keeps the rule already:** `ItemStack`, `Inventory`, `Hotbar` and `GroundItems` read only an item's stack size. `InventoryScreen` knows two inventories and nothing of what they belong to. `Plot.removePlacedItem` and the plot's two signals say what happened and decide nothing. `PlotPointer` and `PlacementGhost` decide nothing.

**The root lines,** which a new kind of item would force an edit to: the list of fields in `ItemRegistry`; the `inventory` field of `PlacedItem`; the three requests in `PlotRequests`; `World.newStationFor`; `World.throwPlacedItemAndContents`; the furnace's layout in `InventoryGui`; and the two branches in `UseAndHit`.

## 2. How the games the user names do it
Read from the Minecraft Wiki, NeoForge's documentation and the RimWorld wiki. Where a page was read only through a summary, it says so in the helpers' own notes, which are not kept.
- **Neither game lets one flag or one central script decide what a thing does.** The behaviour is with the kind of thing, and much of it is data.
- **Minecraft has three forms with three names:** an item in an inventory (`Item`, `ItemStack`), a block in the world (`Block`, with a block entity if it must hold more than a few states), and an item entity on the ground.
- **Using:** the block that was clicked is asked first, and then the item in hand. A log places a block because the log's item is a `BlockItem`, whose own `useOn` places it. Nothing outside the item decides that.
- **Breaking is a process,** with progress, the tool's speed and the block's hardness.
- **What breaking leaves is data, one table for each block.** Obsidian's table drops obsidian, and a separate property with a tag says the drop needs a diamond pickaxe or better. A chest's table drops the chest alone; the stacks spill because the chest's block entity spills them as it is removed. A shulker box's table copies its contents into the item that drops. A spawner's table is empty.
- **RimWorld puts a thing together from parts.** A definition lists its comps. Each comp has its own data in the definition and its own code, with hooks for the moments it cares about: a tick, being spawned, being destroyed.

## 3. Words
**Yes, it is a pattern too, mostly outside the rules.** The reader flagged about sixty names in forty-odd files. The skeptic checked the thirty-two weightiest: twenty-two stood, nine were overstated, and one, `isDueForMerge`, had been fixed while the audit ran. The public names of the rules in `src/shared` came out mostly clean. The worst places are the Roblox-side files (`Main.server`, `Main.client`, `UseAndHit`, `PlaceholderWorld`) and private helpers.

| The fault | Where it stood up |
|---|---|
| **A word that names nothing in the code** | `getWorkableRecipe` ("workable", and a check hidden in a `get`). `PlacementGhost` ("ghost"). The side `other` of a screen, in about fourteen names. `tellCharacter`, `tellGroundItemPositions`, `showWorldToPlayers`, `try` in `Main.server` |
| **A bare adjective as a constant** | `FLAT`, `FARTHEST`, `SAME_DIRECTION`, `SMALLEST`, `LARGEST`, `SAME_TIME`: of what, and in what unit |
| **`And`, `Or` or `If` in a name, hiding two jobs or a check** | `throwPlacedItemAndContents`, `UseAndHit`, `findOrMakeSpawnPoint`, `onScreenOpenedOrClosed`, and `showFireIfChanged`, `sendSnapshotIfChanged`, `addGroundIfMissing`, `closeScreenIfOutOfReach` |
| **A noun that reads two ways, or says nothing** | `InventoryControls`, the same word the user turned down. Two different modules both called `Remotes`. Three types all called `Callbacks`, beside `Signal`, which is the same idea done a second way |
| **One word for several ideas** | `item`: a kind, a ground item, a placed item, and a number of units. In `GroundItems` the functions say `removeItem` and `setItemPosition` where `World` says `setGroundItemPosition`. A bare `id` is a ground item in one file and a placed item in another, and the kind's id is `id` on its definition and `itemId` everywhere else. `slot` is a number, and also a record of a side and a slot under two type names |
| **One idea under several words** | `show` and `hide` beside `setVisible`. A moment is `...Time` in the names table and `...At` in six fields. `corner` and `plotCorner`. `burnSecondsTotal` and `fuelBurnSeconds`. Types declared a second time under the same name in `InventoryControls` and `SlotGestures` |
| **A promise of the verb table that a function does not keep** | `Direction.new` returns `nil` for numbers that point nowhere, where `new` is said to make one. `countRequest` returns a yes or no and changes a number. Fifteen private functions do not start with a verb |

**Two cannot be fixed by a rename, because the shape is wrong:** `UseAndHit`, which finds what the pointer is over, draws two markers and tells two clicks apart; and the flat record of an item's flags, which is section 1.

**Overstated, in the skeptic's view:** `PlotPointer`, `PlotCollision`, `PlaceholderWorld`, `Requests.carryOut`, `Plot.isTileTaken`, and `ground` and `screen` each used in two senses.

The whole list, with a file and a line for each, is in the helpers' output and is not kept in git. It is worked through as each file is next changed, and what is left gets a pass of its own (`docs/status/next.md`).

## 4. Roblox's word, Godot's, or ours
The user's rule: "If youre following roblox conventions stick to it. If youre following invented conventions - go with godots".

- **The code mostly follows Roblox where Roblox has a word.** `new`; `get`, with `nil` when nothing is there; `set`, with `nil` to clear; `find` returning `nil`; `is`, `has` and `can`; `connect` and `fire`; `encode` and `decode`; `clear`; the suffixes `Gui` and `Parts`; events named for what happened, in the past tense; `PascalCase` for modules and types, `camelCase` for functions and fields, `LOUD_SNAKE_CASE` for constants. Roblox's own newer scripts write their functions the same way: `ConnectionUtil:trackConnection`, `ConnectionUtil:disconnect`.
- **`fire` is Roblox's word.** `BindableEvent:Fire`, `RemoteEvent:FireServer`. Roblox has no `emit` anywhere, and the signal libraries its developers write use `Connect` and `Fire`. Godot's pair is `connect` and `emit`. Two of the helpers argued for `emit` all the same, because our `Signal` is not a Roblox event. Claude kept `fire`, and it is the user's to overrule.
- **To keep to it:** if a way to stop hearing a signal is ever needed, it is `disconnect`, and hearing it once is `once`, as Roblox has them.
- **"Listener" was ours.** Roblox says a callback is connected, and the result is a connection; Godot says a callable and a connection. `Signal` now says `connections` and `callback`.
- **Minecraft's words, with no Roblox or Godot word to take their place:** `stack`, `slot`, `merge`, `hotbar`, and a registry of kinds.
- **Ours, with no engine behind them:** `put` and `take` (Godot would say `insert` and `pop`); `advance` and `advanceTo` (both engines step by a length of time, as `Heartbeat(deltaTime)` and `_process(delta)`, and neither steps to a time); `validate`, whose answer is `nil` for yes; the suffixes `Controls`, `Requests`, `Definitions`, `Looks`, `Snapshot` and `State`; a unit in a name, as `...Seconds`; and `pack`, where Roblox says `Backpack`.
- **Roblox's word with another meaning:** `spawn`, which in Roblox starts a function running (`task.spawn`).
- **The verb table was wrong about `open`.** It said `open` makes a thing and returns it. The two functions that open a screen return nothing. The table is corrected.
- **Whether calls are written `Module.verb(thing)` or as methods** is nearer to Roblox than to Godot either way, and still waits for the user.

The skeptic's view was that most of this list is a choice and not a fault: a verb that the table defines and the code uses one way is not an invented noun. What stood as faults: `Controls`, `UseAndHit`, "listener", `open`, and `side` used for two ideas.
