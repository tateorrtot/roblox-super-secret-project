# The nineteenth review: "would you do it the same?" (2026-11-21)

The user stopped the work on the inventory's folder and asked about the whole. Their words, and what Claude took from them.

## The test
> If I had you making each system for this game as seperate, fully isolated, generic, reusable libraries/addons (like foxfabric) would you do it the same?

> Have you violated anything?

> If I sandboxed you into different repos will you perform better?

> Lets identify our systems first.

- **No, it would not be the same.** Measured the same day, in `src/shared`:
  - Five modules keep a list that every user of the module shares: `ItemRegistry`, `ItemScripts`, `PlacedObjectScripts`, `Items`, and `PlacedObjectKinds`. A library would be handed its list.
  - Eleven numbers of this game are written inside systems: `Plot.TILE_SIZE`, eight in `GroundItems`, and two in `PlayerState`. A library would be handed them.
  - `ItemScripts` requires `World`, and `PlacedObjectScripts` requires `World` and `PlayerState`, so the script of a thing cannot exist without this game's glue.
  - `Inventory` and `ItemStack` read an item's `stackSize` from the list that `ItemRegistry` keeps for the whole program. `Inventory` knows no user, and is still not a library.
  - `InventoryScreen` is three things in one table, and `Hotbar` holds an inventory that it does not need (below).
- **Why:** Claude wrote each system with the whole game in view, and wrote the one case it had in front of it into the system. A session that had never heard of the game could not have.
- **Their FoxFabric's own rules** (its README): modules are independent and minimal, the data and logic modules depend on no space, every class is documented in full, each module has tests, and its `character` module is named as not in the intended style because of hardcoded behaviour.

## The state of the work
> Weve been dealing with your buggy weird spaghettii architecture you keep producting for the past several days. We've gotten basically nowhere and Im worried that Im going to have to throw this all away and spin up sessions to make each of the systems, fully decoupled, in their own repos. Or hand-code it. You originally claimed you had the code 100% covered. The past few days has shown me everything but that

> A human would not build a game by making it all at once. They start with big problems and break them down and down. Eventually you end up with lots of smaller - very isolated - problems that are easy and straightforward to solve. You dont keep the entire context of the game for everything thats *weird* and produces bad code since you make assumptions.

> Im here because I want to make good games that will last. That just so happen to be profitable.

> I was told Claude was incredible and could "do the coding for me!". As a programmer of 6+ years, I am disappointed and tempted to just make the game by hand based on your performance.

- **What Claude's checks covered was whether the code does what Claude wrote.** Tests, mutation testing and the play test all pass, and none of them can see a contract that should not be there. Each of nineteen reviews found one.
- **The way of working they describe is the one to follow:** break the problem down until each piece is small and isolated, and solve each piece without the rest of the game in view.

## The inventory's folder
Of "Shall I move Hotbar and InventoryScreen out of the inventory folder next?":
> What do you think? Based on what I just told you. Does Hotbar, InventoryScreen, and Inventory all belong into the same big "decoupled" micro-addon? Or are they vastly seperate things? Where is the coupling. Break the problem down.

- **They are separate things, and moving a folder would only move the tangle.**
  - `Inventory` is numbered slots that each hold a stack or nothing. It is a system.
  - `Hotbar` is one number: which of the first N slots is selected. It holds an inventory only so that two of its functions can call `Inventory.getStack` and `Inventory.takeFromSlot` for the caller.
  - `InventoryScreen` is three things. A stack held outside any inventory, with the moves between it and a slot: a system. Which inventories a player has open: this game's record of a player. What each slot of a stove accepts: the stove's.
- **`PlayerState` is not a system either.** It is this game's record of a player: a pack, a hotbar, a screen, and a character.

## Two messages that followed, the same hour
> Sorry - that was rough. Im frustrated. Were days in and we've just been reinventing buggy inventories, grid building systems, and throwing items. It doesnt feel like we have a game. I have no problem moving very slow - if I was hand making this Id still be working on the underlying architecture. Slower is better. Its just frustrating being sold that you were going to be some game changer when it hasnt felt that way.

> Problem solving is recursive. You take a problem, break it up. Then take those problems, and break them up. Rinse and repeat. What I feel youve done is instead of doing that - you take a big problem and break it up in some odd way then break it up a bit more and then spiderweb everything together. It doesnt feel like a clean hierarchy or isolated modules. It feels like a spiderweb of scripts, methods, variables, random concepts, etc. That just spaghettii out and changing one tiny thing in the codebase is liek dominos that destroys the rest of the codebase. This is the "50k line changes" I warned about long ago when we started this project.

- **The dominos, measured.** The commit that took `side` out of `InventoryScreen` changed 14 files: 582 lines added, 572 removed. The commit that split `moveFromSlotToInventory` changed 14 files: 535 added, 476 removed.
- **The middle of the web, measured.** `World` requires 10 modules and is required by 10 files of `src`. `PlayerState` is required by 8. `src` is 6,379 lines, and `tests` 11,830.
- **Slower is better.** The breakdown comes before any code, as a tree that the user has read, and each leaf is written with nothing of the game in view.

## What changed in the code
Nothing. The user asked for the systems to be named first. Claude's list is in `docs/status/next.md`.
