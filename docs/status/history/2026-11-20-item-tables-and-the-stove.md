# An item is one table, and the stove carries what it is made of (2026-11-20)

What was done after the user's thirteenth review. It is over; `docs/status/now.md` says where things stand.

## What they had said
- **Of one table for each item:** "Yes do that." And the rule behind it: "Systems being decoupled - fantastic. Pieces of content being scattered - not great."
- **Of the stove being composed of its fire and its slots, with `World` no longer keeping stations:** "Yes! I like this. ... A stove is just other things composed together."
- **Of which of the two came next:** "Uh both? I thought you already did this?"

Their words in full are in `docs/working/code-reviews/2026-11-20-12-content-in-one-place.md`.

## What was built
Three commits on the branch `placed-objects`.
- **An item is one table.** `src/shared/content/Items.luau` lists every item and returns one by id. An item that only lies in a slot is a row there: its id, stack size, name and colour. `CrateItem` and `StoveItem` are files of their own, because they do something. `ItemDefinitions` and `ItemLooks` are gone.
- **`ItemRegistry.register` keeps only the id and the stack size,** and passes over whatever else is on the table. `Content.register` hands each item to it and to `ItemScripts`.
- **Everything of the stove is in `Stove`:** its three slots, `RECIPES`, `FUEL_SECONDS`, its fire, its cooking, and how far both have got. The folder `stations`, the type `Station`, `StationProgress`, the two registries and the two files of rows are gone.
- **`World` keeps no stations and advances none.** It fires `timePassed` with the seconds that passed. `PlacedObjectScripts.advancePlacedObjects` calls the `advance` of each placed object's script, the lowest id first, and `Main.server` connects the two.
- **A script may have `getScreenData`:** what a player's machine is told of the placed object they have open. `PlayerSnapshot` asks for it, and moved to `requests` to do so.
- **`Crate.get` and `Stove.get`** return a kind's object by its id.
- **A kind's own drawing is a piece on each side:** `StoveGlow` on the server, handed to `PlotParts`, and `StoveScreen` on the player's machine, handed to `InventoryGui`. Neither general piece knows what a stove is.
- **`tools/lift_out_test.py`** runs each system's tests with only what it requires beside it.

## How it was checked
- `lune run tools/check` passes, with 2,273 test checks in 29 files.
- `python tools/lift_out_test.py`: all five systems pass alone.
- Mutation testing: `Stove` 187 of 193, `World` 146 of 148, `PlacedObjectScripts` 29 of 29, `PlayerSnapshot` 35 of 38, `Items` 11 of 11, `ItemRegistry` 34 of 41, `Crate` 33 of 33, `CrateItem` 10 of 10, `StoveItem` 10 of 10, `Content` 6 of 6, `InventoryRequests` 136 of 140. Every one that survived changes nothing a caller could see: most are a word inside an error's text, or `nil` for `false` where both mean no.
- The play test passed 93 of 93 in Studio, on the last commit.
- The server's and the client's scripts, type-checked by hand: six reports in one place, `PlaceholderWorld` line 94, which is older. The seventh went with the code that moved into `StoveScreen`.

## How the tests were moved
Six helpers each ported one set of test files, at the same time, after the rules were changed. The furnace's four test files became part of the stove's one. What had no counterpart was not carried: the two registries' checks of a row as it is registered, and the old way of asking for a recipe. The stove's rows are checked as they stand.

## What the helpers found
Four readers were shown bare names, and three reviewers read the work: one for mistakes, one against the user's words, and one comparing the ported tests with the old.

- **The names.** A reader could make nothing of `World.advanced`. It is `timePassed`. `Stove.get`, `Stove.advance` and `getScreenData` were each read rightly and marked as guesses: what they act on is an argument.
- **29 findings, 27 once two that two reviewers shared are counted once.**
- **Mended, 12:**
  - `Main.client` asked whether the open placed object was a stove, and `InventoryGui` drew the stove's panel. Both are gone: the panel is `StoveScreen`.
  - Neither `World.advanceTo` nor `advancePlacedObjects` said what follows when a script's `advance` fails. They do now.
  - A private function's name had a word that is nothing in the code, and a length of time was not named as one.
  - An item's table, and each recipe row, could be changed by anyone. They are frozen.
  - Six faults in the ported tests: what a player watching a lit stove is told was no longer pinned from end to end; a stove could not be told from a stove-kind object with slots and no fire; four messages said more than their checks, or named the wrong function.
- **Left, 11** (each is in `docs/status/now.md`):
  - A placed object of the stove's kind with no fire on it stops the world's tick, loudly. Only a mistake in the code can make one.
  - A stove cooks only if whoever makes a world connects `timePassed`.
  - What a script's `getScreenData` returns is not checked on the player's machine, which trusts the server.
  - A stove is known by its kind and by having a `fire`, and nothing looks at what the `fire` is.
  - A kind's name and colour are in `PlacedObjectLooks`, apart from the kind, and are written again on its item.
  - The id of the item that a broken crate or stove leaves is written twice.
  - Each side has its own hand-written list that names the game's things: `Content.register`, a table in `Main.server`, and two in `Main.client`.
  - The two ghosts are alike in every line but the kind.
  - With one fuel, no test can show that a fire's length comes from the fuel's own row.
  - Two tests of general code use the words "crate" and "stove" for their made-up kinds.
  - A misspelled function on an item's table is no longer refused.
- **Not agreed with, 4:**
  - That only an item with a function should be registered with `ItemScripts`. One rule for every item is simpler, and a table with no function does nothing.
  - That an item need not have a name and a colour. The user: "In item form it has a texture a name and a max stack."
  - That `advance` should not be handed the world, and that the order of telling should not be promised. The glue cannot know what each kind uses, and an order that changes would make the tests uncertain.
  - That the gauges' arithmetic belongs on the player's machine. It is the stove's, and it is tested with the stove.
