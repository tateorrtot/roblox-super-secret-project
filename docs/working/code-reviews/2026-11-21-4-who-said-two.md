# The eighteenth review: "Who said only two open inventories" (2026-11-21)

Claude had written that a client cannot send an inventory, so a request needs a word for "which of your two open inventories". The user's words, and what Claude took from them.

## Another contract
> uh what. Who said only two open inventories wtf? What about panels of inventories open.

> You just... wrote another contract to get to the fastest possible answer that works...

> What about non player focused inventories interacting. I.e. a hopper pulling items out of a crate and into a stove. Or a funnel that when items enter, moves them into the inventory its facing (like from the create mod).

> Youve just... made more contracts about players, sides, inventories, and coupling.

> Again. FoxFabric philosphy. You make things that DONT know about eachother. You dont make up some random concepts like "side". Now inventories have stuff about knowing about "sides", which is related to the players screen, about if they have inventory 1 or inventory 2 open.

Of "Shall I take `side` out of InventoryScreen's nine functions next, so each takes the inventory itself?":
> Yes. Side is awful.

- **"Who said only two?" is a decision:** a player may have any number of inventories open. `InventoryScreen` has room for two, `pack` and `otherInventory`, and nobody asked for that.
- **Inventories work on each other with no player in it:** a hopper, a funnel. `Inventory.takeFromSlot` and `Inventory.addStack` already do that, and Claude ran them so: a stack went from a crate's inventory into a stove's with no player and no screen.
- **The same run showed a hole.** What each slot of a stove accepts is a function that the stove hands to a player's screen, `otherSlotAcceptsItem`. A thing that adds to the stove's inventory without a screen is not asked: five stone went into the stove's input slot, which accepts no stone. The rule is the stove's, and it was written as a rule of a player's screen.
- **The folder `src/shared/inventory` holds three modules:** `Inventory`, and two that are about a player, `Hotbar` and `InventoryScreen`. `Inventory` itself knows nothing of a player or a side. The folder does, so it could not ship alone as the inventory system.
- **Each of these came from one habit:** Claude wrote the least that the one case in front of it needed, a player with a crate open, and wrote it as if it were the rule. Ask of each field and each argument: who said there is one, or two, or that a player is there at all?

## An inventory knows nothing of who uses it
Two messages, sent while Claude worked:
> Let me put it like this with inventory - an inventory has *no* idea it has anything to do with a backpack. Or a chest. Or a stove... Or a funnel/belt moving items around... Do you see how that works?

> You can write the glue code to couple these things together because its not inherent. If you cant just pull it out and use it in some completley other game or use case thats bad.

- **The test for a system is whether it can be pulled out and used in another game.** What ties it to this game is glue, and glue is allowed because it is not part of the system.
- **`Inventory.luau` passes, by its code:** its fields are `slotCount` and `slots`, and it requires `ItemRegistry` and `ItemStack` and nothing else. One comment named a player's pack as an example, and that is gone.
- **It rules out what Claude was about to propose:** to give the inventory a function that says what each slot accepts, so that a stove's rule would hold for a hopper. That would have put a need of the stove into the inventory. The rule stays the stove's, and a hopper asks the stove.
- **`Hotbar` and `InventoryScreen` do not pass.** They are in the inventory's folder, and their fields and words are a player's: `pack`, `otherInventory`.

## What changed in the code
- **No function of `InventoryScreen` takes a `side`.** Each takes the `Inventory` and the slot's number. `getInventoryOnSide`, `hasSlot`, `hasEverySlot`, `swapSlots`, and the type `Side` are gone from it.
- **Only the requests know the word that a client sends.** `InventoryRequests` turns `"pack"` or `"other"` into the `Inventory`, checks the slot, and calls functions that take the `Inventory`. Exchanging two slots is the request's own glue: `Inventory.getStack` and `Inventory.setStack`.
- **Not changed, and shown to the user as what is still a contract:** a screen has two inventories; a slot's rule is the screen's; `Hotbar` and `InventoryScreen` are in the inventory's folder.
