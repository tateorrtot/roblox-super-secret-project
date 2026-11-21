# Asked of the user, not yet answered

Only what is still open. When they answer, the answer goes where it belongs and the line leaves this file.

## About the code
- **Where the record of a thing in the world is kept:** in a Luau table that the server draws parts from, as today, or in the part itself, with tags and attributes on it. Asked plainly on 2026-11-21, after another model's brief proposed tags and attributes (`docs/game/products-for-people.md`), and after a cold review found faults that come from keeping two records (`docs/code/reviews/18-cold-review-2026-11-21.md`). Claude's view: the part, for anything that physics moves, and a table only for what Roblox has no place for, such as a slot, a recipe, or a stove's fire. No code moves until they answer.
- **To read the code,** and give their verdict on the names Claude chose (listed in `claudes-calls.md`).
- **Whether the keys move onto Roblox's input actions next, before prediction** (`next.md`). Asked on 2026-11-20.
- **Whether the scripts read right to them:** `ItemScripts` and `PlacedObjectScripts`, and the game's things in `src/shared/content`. The names and shapes that are Claude's are in `claudes-calls.md`, with the four names a cold reader doubted in `history/2026-11-20-scripts-and-input.md`.
- **How "items and moving them around" breaks down below its four parts,** and whether a folder may require the folder beside it or only what is inside it. Their guideline says not above; it does not say beside. Asked on 2026-11-21.
- **Whether to try one leaf as a library in a repo of its own, overnight,** built from a one-page spec by a session that is told nothing of this game. Offered on 2026-11-21, as they went to bed.
- **What to call `screen` and `side`.** They read `screen` as a GUI and `side` as a side of the player (`next.md`).
- **Whether an item's look is a ModuleScript for each item,** with one function for what a slot shows and one for what the world shows (`next.md`). Drawn for them on 2026-11-21 as "a look piece", which they could not read.
- **What to call the thing that a plot becomes.** They asked: "is "Plot" the best word here? Were basically taking the existing concept of a plot and giving it physics - no?" Claude answered that a plot is land with an owner in every Roblox building game, that a tree or a vehicle reads oddly as a plot, and that they will want the word for "multiple plots with associated owners". The choice is theirs (`next.md`).
- **Whether a thing placed in mid-air starts a plot of its own.** It follows from their two decisions, that a thing may be placed in mid-air and that what nothing joins is a plot of its own. Claude said so on 2026-11-21 and they have not answered.
- **The specifics of how an item looks,** which they offered: "If you need I can give you more specifics and design." Claude needs what decides whether an item is a texture or a model, and how a texture with depth sits in the hand.
- **What to call a table of one thing's drawing functions.** The code says `piece` in three type names (`next.md`).
- **Whether to try a Roblox `Tool` for what the character holds,** as they proposed. The first step is a short measurement in Studio of what Roblox's documentation leaves unsaid (`docs/roblox/input.md`).
- **Whether `Crate` should be `CratePlacedObject`,** to pair with `CrateItem`. They asked whether `CrateItem` is the best name.
- **A name for `InventoryControls`.** `UseAndHit` went when the clicks on the world moved to Roblox's input actions, and the same may be true of this one when the keys move.
- **Which of the words that are neither Roblox's nor Godot's they want changed:** `put` and `take`, `advance` and `advanceTo`, `validate`, `pack` where Roblox says `Backpack`, and `spawn`, which in Roblox means something else. The list is in `docs/code/reviews/17-audit-after-the-eighth-review-2026-11-20.md`.
- **Whether they would rather read the code in the method form** (`pack:addItems("log", 5)`) than as plain functions (`Inventory.addItems(pack, "log", 5)`).
- **Whether screens and models are made in Studio,** as scenes are in Godot, or stay in code.

## About the game
- **Their feedback on the build:** "a LOT of feedback and little issues / tweaks". They are holding it until the code is checked.
- **How dropped items feel now:** how far a throw goes, how a broken crate spills, whether items should fall more lightly, and whether the two differences from Minecraft that are left in merging matter to them (`docs/game/dropped-items.md`).
- **Which, if any, of the ideas Claude set aside they want.** The list is at the end of `docs/game/dropped-items.md`.
- **For each place or people they picture:** what it needs and what it makes.
- **Personal or group ownership, and a brand name.**

## Things only they can do
- **In Studio, select `Workspace` and set `PlayerScriptsUseInputActionSystem` to `Enabled`,** if they want Roblox's own movement and camera to run on input actions too. Roblox's guide recommends it, a script cannot read or set it, and the game's own actions work either way (`docs/roblox/input.md`).
- **For saving, when it is the next piece:** publish the place and switch on Studio's access (the steps are in `docs/roblox/studio.md`), and a clear yes to downloading ProfileStore, which the survey in docs/research/13 recommends wrapping behind a module of ours.
- **One Blockbench model with a stepped animation,** in `assets/`, as glTF or FBX plus the `.bbmodel`, to test the art pipeline.
- **In Studio, switch on "Allow Mesh / Image APIs":** it is on the Security tab of Experience Settings. It lets a script write the pixels of a stand-in texture and build a mesh from them. Without it a script in Studio can do neither (`docs/roblox/facts.md`). It is a security setting of their place, so it is theirs to switch.
- **Real art for the items, when they want it.** Until then Claude draws primitive stand-ins of its own, by their word of 2026-11-21. No stand-in may reach the public.
- **A budget** for a small ad test, and for the 1,000 Robux fee that lets under-16s see the game later.
- **Whether they have a cheap Android phone to test on.**
