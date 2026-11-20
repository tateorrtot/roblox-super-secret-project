# Is the code coupled spaghetti? A review, 2026-11-20

The user read `World.setPlayerPosition`, found that it also works out how a player's drops set off, and asked for a review of the whole codebase:
> that one scare about setPlayerPosition is making me think we got unmaintainable super coupled spaghettii

**How it was done.** Five reviewers on Sonnet, each with one question: do functions keep their names' promises (two reviewers, half the rules each); how are the pieces of the rules tied together; is the Roblox side only wiring; and four additions traced through the code by a reader shown no notes. A skeptic then tried to refute each reviewer. Nothing was changed. The branch was `dropped-items`.

## The verdict
All ten said the same thing in their own words: **it is not spaghetti, and the scare was pointing at something real.**
- What requires what runs one way, with no cycles. The rules never call Roblox. The server and the player's machine require nothing from each other.
- `World` is where the pieces meet, and a handful of its functions do more than their names say. The same fault shows in a few other places.
- Most of what was found was there before dropped items. Two findings come from that day's work: the stored throw, and `StationProgress`.

## Upheld, and worth acting on
Worst first. "Size" is the skeptic's estimate.

| # | What | Where | Why it will hurt | Size |
|---|---|---|---|---|
| 1 | **`setPlayerPosition` also works out and stores `player.throw`.** A value worked out from two others is kept, and only the order of calls in `Main.server` keeps it fresh. `addPlayer` takes a `position` that is not the player's position | `World`, `PlayerState`, `Main.server` | A throw that depends on anything else (aim, strength, a dropper) means editing the function that records a position | A few lines, and tests |
| 2 | **`removePlacedItem` closes screens, deletes the station and spills the contents.** The name says remove | `World` | A removal that should not spill (a reset, picking a crate up whole) must copy four steps | A few lines |
| 3 | **A player's screen is written from three places.** `InventoryRequests.openPack` and `World` assign `player.screen` and `openedPlacedItemId`; `PlayerSnapshot.decode` assigns `screen.carriedStack`. The conventions say only a thing's own module assigns its fields | `PlayerState`, `InventoryScreen` | A third way to open a screen that forgets one of the two fields | One file |
| 4 | **The selected hotbar slot is kept twice,** on the player's machine and on the server, and the machine never reads the server's back | `Main.client`, `PlayerSnapshot` | Loading a save, or the server changing the selection | A few lines |
| 5 | **The player's machine spells request names and argument orders as strings.** The inventory family is covered by a test that runs each built request through the rules; the seven names in `Main.client` are not | `InventoryControls`, `Main.client` | A renamed request or a new argument fails silently for those seven | One file |
| 6 | **"A station has three slots" is written in the screen's drawing code,** a copy of `RecipeRegistry.STATION_SLOT_COUNT`, with the roles of the slots | `InventoryGui`, `RecipeRegistry`, `Station` | A second shape of station draws wrongly, and no check sees it | A few lines |
| 7 | **`world.stations` is a second table kept in step with the plot by hand,** in three functions | `World` | Loading a plot, or a second kind of placed item that acts | One file |
| 8 | **`StationProgress` decides for itself whether a station is working,** without checking the fire | `StationProgress` | A work gauge that climbs with no fire, when a tick ends exactly as the fuel runs out | A few lines |
| 9 | **`Main.client` reads `inventoryGui.hoveredSlot`.** A drawing piece is keeping input state | `Main.client`, `InventoryGui` | Touch controls, which have no hover | A few lines |
| 10 | **The order of calls in `Main.server` matters and is written nowhere:** positions, then the request; positions, ground items, advance, restock, show | `Main.server` | A second way in that skips a step. Fixing 1 removes most of it | A comment |

## Upheld, and waiting for the feature that needs it
- **One plot is built into `World`,** and a placed item's id is unique only within its plot while `World.stations`, the requests, the snapshot and the parts use it as if it were unique in the world. Bases are to be a plot for each player (`docs/game/decisions.md`), so this is coming. It touches `World`, `PlotRequests`, `PlayerSnapshot` and `Main.server`. The skeptic: do it once, when plots are designed.
- **A placed item has no facing and no owner,** and `advanceTo` has one fixed list of things that act. A dropper or a creature each needs a table, a loop, and for a dropper a facing passed from the click down to `Plot`.

## True but harmless
`advanceTo` picks up, closes screens, runs stations and expires items, and its comment says so. The push-out geometry is 45 private lines inside `World`. `moveItemTo` also merges. `droppedAt` moves when a stack joins. `tools/playtest.py` repeats two sizes. Reach is worked out in three forms on purpose. `Station.slotAcceptsItem` takes an item id, not a station. A slot's and a count's validity are checked in more than one place. An item's row carries `placeable`, `slotCount` and `burnSeconds`. `PlaceholderWorld` works the plot's corner out a second time.

## Refuted
- **"`World` is a god object."** 364 lines and 22 functions, and what it holds belongs together.
- **"`SaveData` cannot be extended."** Nothing calls it yet, and ground items are never saved, by the user's choice.

## What is clean
Named by more than one reviewer: `Throw`, `Direction`, `Position`, `Plot`, `GroundItems`, `Inventory`, `ItemStack`, `Hotbar`, `Station`, the request modules, `SlotGestures`, `InventoryControls`, every `...Gui` and `...Parts` piece (they draw and decide nothing), and `CollisionGroups`. `GroundItems.moveNearbyStacksToInventory` takes any position and any inventory, so a creature could use it as it is.

## The four additions
| Addition | Reach | What it needs |
|---|---|---|
| A dropper | A few pieces | One more constructor in `Throw`. A facing on placed items. A home for a timer on a placed item |
| A creature that picks items up | A few pieces | A table in `World`, a loop in `advanceTo`, a way to say where it is, a piece to draw it. Pickup is reusable already |
| A second plot, owned by a player | Many pieces | See above |
| Saving the plot | Many pieces, mostly unbuilt | An encoder for `Plot`, and stations' fires, which live outside the plot |

## Not done
Nothing was fixed. The user asked for the review before anything else was touched. What they chose is in `docs/status/now.md`.
