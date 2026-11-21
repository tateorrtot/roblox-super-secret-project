# Decisions Claude made on 2026-11-21

For the user to veto, as the calls in `claudes-calls.md` are. Each followed a direction of theirs that day, and the details are Claude's.

- **Sides out of `InventoryScreen`, 2026-11-21.** The user said yes: "Side is awful." These details are Claude's.
  - **The requests keep `"pack"` and `"other"` as the words a client sends,** and the type `Side` moved to `InventoryRequests`. It goes when a screen holds a list of inventories.
  - **`InventoryScreen.swapSlots` is gone,** since it used nothing of the screen. The request exchanges the two stacks with `Inventory.getStack` and `Inventory.setStack`.
  - **`InventoryScreen.hasSlot`, `hasEverySlot`, and `getInventoryOnSide` are gone.** They checked a client's values, which is the requests' job: the private `findInventoryWithSlot` and `decodeScreenSlots` do it.
  - **A function of the screen takes any `Inventory`,** and does not check that it is one of the screen's two.
- **The split of `moveFromSlotToInventory`, 2026-11-21.** The user said how: two functions, and glue. These details are Claude's.
  - **The request keeps its name and is the glue.** It takes `toSlots`, a list of slot numbers, where it took a first and a last.
  - **A list from a client may have no more entries than the inventory has slots,** and may name a slot twice.
  - **The rule that a stack never goes into the slot it came from is gone.** If that slot is listed, what is left over goes back into it, which is where it would have stayed.
  - **`Variant<T>` is written out in each of the two request modules,** since a type that both export from a third file would need that file.
  - **The private helpers `findInventoryOnSide`, `isListOfSlots`, and `getSlotsAccepting`,** in `InventoryRequests`.
  - **The stove's five checks of the old function are gone, and so is one kind of turn in two random runs.** The request's own tests move a stack into a slot that accepts it, with a made-up oven.
- **The comment pass, 2026-11-21.** The user asked for it: "The documentation must be *good*." These details are Claude's.
  - **How each kind of comment starts** (`docs/code/comments.md`): a signal is "Fires after ...", and then "Passes ..."; a value that a caller passes or gets is a literal, in digits and backticks.
  - **What `tools/comments.py` fails for,** and that `lune run tools/check` runs it.
  - **A `Note:` on four functions that take a count and do not check it,** where the checkers could state no guard that holds in every case.
  - **The reference's links, its anchors, and its lists of what a module requires and what requires it.**
  - **The reviews, the history, and the research keep their old words.** Only the living notes say client where they said the player's machine.
- **Stand-ins without colour, 2026-11-21.** The user asked why there was a colour. Taking it out is Claude's answer, and these details are Claude's.
  - **Every stand-in is one grey, `Color3.fromRGB(110, 112, 120)`, with the thing's name on it.** A lit stove still glows orange: that is the stove's Model's own.
  - **Each drawing piece that needs the grey writes it,** in four places, so that no piece on the client requires one on the server.
