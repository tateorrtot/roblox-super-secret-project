# A crate carries its inventory, and picking up leaves the ground items (2026-11-20)

What was done after the user's twelfth review. It is over; `docs/status/now.md` says where things stand.

## What they had said
- **"Yes I think a crate basically being composed to have an inventory is fantastic."** That was to the first half of what Claude had shown for `World`. Of the second half, a stove and its station: "But... what is a station...?"
- **"Does GroundItems being glued to inventory make sense. Should/can we pull it out."**

Their words in full are in `docs/working/code-reviews/2026-11-20-11-where-is-the-item.md`.

## What was built
Three commits on the branch `placed-objects`.
- **`Plot.placeObject(plot, placedObject)` takes the placed object itself.** The plot keeps that table, freezes it, and reads only `tileX` and `tileZ`. `kindId` is on it for whoever must find the kind's script.
- **A crate is a placed object with an inventory on it:** `Crate.Crate = Plot.PlacedObject & { inventory }`. `Crate.place(plot, tileX, tileZ)` builds one and needs no world.
- **`World` lost** `placedObjectInventories`, `addPlacedObjectInventory` and the line that emptied the store.
- **A stove is unchanged.** `World` still keeps its station and advances it.
- **`GroundItems` no longer requires `Inventory`.** `moveNearbyStacksToInventory` is gone. `getIdsInPickupReach` returns the ground items in pickup reach of a position, nearest first, and `takeFromItem` takes a count out of one.
- **`World` joins the two,** in eight private lines: for each ground item in reach of a character, `Inventory.addItems` into the pack, then `GroundItems.takeFromItem` for as many as went in.
- **The ground items' tests no longer use an inventory.** The tests of picking up into a pack are the world's.
- **`tools/bare_names.py` prints a type that is another type with more fields.**

## How it was checked
- `lune run tools/check` passes, with 2,247 test checks in 33 files.
- Mutation testing: `Crate` 32 of 32, `CrateItem` 10 of 10, `Stove` 27 of 27, `Plot` 80 of 81, `GroundItems` 140 of 141, `World` 153 of 155. The four that survived change nothing a caller could see.
- The play test passed 93 of 93 in Studio on the second commit. The third commit changed only the rules, and it was not run again.
- The server's and the client's scripts, type-checked by hand: the same seven reports in two places as before.

## What the helpers found
Three readers were shown bare names, and two reviewers read the two commits. One reviewer was given the user's words and told to find where the code went against them.

- **The names.** `Crate.place` was read as "places the crate into a plot" by a reader who could not tell what it acts on. That is the same doubt as before the change. `getItemIdsInPickupReach` was read rightly, with a doubt about whether the delay applied.
- **19 findings, 16 once the three that both reviewers made are counted once.**
- **Mended, 7:**
  - The plot kept a table that its caller could still change, while its comment said the fields never change. It freezes the table now, as it froze the record it used to make.
  - The comments said the plot reads a placed object's kind. It never does.
  - `Crate` cast any placed object with an `inventory` field to a crate. It asks the kind as well.
  - The comments of `interact` and `breakPlacedObject`, for the crate and the stove, did not say that they fail for a wrong id.
  - `GroundItems.setItemStack`, Claude's first shape, could set any stack, quietly did nothing for an unknown id, and was a second way to remove a ground item. `takeFromItem` replaced it.
  - `getItemIdsInPickupReach` read as the ids of items. It is `getIdsInPickupReach`.
  - A ground item that none of fitted in a pack was rebuilt on every pass. It is left as it was.
- **Left, 8** (each is in `docs/status/now.md`):
  - A stove is still a station that `World` keeps. It is the next piece.
  - `Stove.STATION_KIND_ID` and the two registries keyed by a kind of station go with it.
  - Picking up is joined inside `World`, which grew by those lines.
  - `GroundItems` still holds how far a picker reaches and how long a ground item waits.
  - `World` decides when a screen on any placed object closes.
  - An item's facts are in several files, joined by a string.
  - Whole-numbered tiles are the plot's data.
  - `PlaceholderWorld` casts a placed object to a crate to reach its inventory. A lookup in `Crate` would spare the cast. It waits for the next change to the server's scripts, since one needs the play test.
- **Not agreed with, 1:** that the two registries of scripts should not name `World` in their types. They are part of the requests, which are glue.
