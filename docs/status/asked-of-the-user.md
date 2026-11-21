# Asked of the user, not yet answered

Only what is still open. When they answer, the answer goes where it belongs and the line leaves this file.

## About the code
- **To read the code,** and give their verdict on the names Claude chose (listed in `claudes-calls.md`).
- **Whether the keys move onto Roblox's input actions next, before prediction** (`next.md`). Asked on 2026-11-20.
- **Whether the scripts read right to them:** `ItemScripts` and `PlacedObjectScripts`, and the game's things in `src/shared/content`. The names and shapes that are Claude's are in `claudes-calls.md`, with the four names a cold reader doubted in `history/2026-11-20-scripts-and-input.md`.
- **Whether to make a tile one value with a height,** which only `Plot` makes and reads, as the first step to 3D plots and to free placement (`next.md`). Claude explained it with the code before and after on 2026-11-20, when they said "I think I want this but I want to verify".
- **What 3D means in play.** Claude takes "plots are 3D" to mean that a placed object can stand on top of another, or on a floor above. Whether a thing may float, or falls when what is under it goes, is theirs to say.
- **Whether an item's colour should go the way a kind's went.** `Items.Item` has a `color` for every item, and the slots and the ground items draw from it. It stands in for the texture they said an item has. If it goes, each item's icon and its look on the ground become pieces of the item's own.
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
- **A budget** for a small ad test, and for the 1,000 Robux fee that lets under-16s see the game later.
- **Whether they have a cheap Android phone to test on.**
