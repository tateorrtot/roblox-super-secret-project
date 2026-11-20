# Asked of the user, not yet answered

Only what is still open. When they answer, the answer goes where it belongs and the line leaves this file.

## About the code
- **To read the code,** and give their verdict on the names Claude chose (listed in `claudes-calls.md`).
- **Whether the shape in which the item decides is the one they want, and whether it comes before prediction.** Shown to them on 2026-11-20 after their eighth review (`next.md`).
- **`PlacedItem`, or `Block`.** They asked whether "placed item" is the best name. `Block` is their own word and Minecraft's, and is shorter. It also promises a cube on a grid, and they have said that walls will not keep to the grid.
- **A name for the piece now called `UseAndHit`,** and for `InventoryControls`. They turned down `PlotControls`. Roblox's own scripts name such a module for what it reads, as `CameraInput`, which would give `WorldInput` and `InventoryInput`.
- **Whether `fire` stays.** It is Roblox's word; Godot's is `emit`. Claude kept it under their rule and told them so.
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
- **Run the one-line download of Roblox's type definitions,** since the app refused it for Claude. The command is in `docs/roblox/studio.md`. With it the server's and the client's scripts can be type-checked.
- **For saving, when it is the next piece:** publish the place and switch on Studio's access (the steps are in `docs/roblox/studio.md`), and a clear yes to downloading ProfileStore, which the survey in docs/research/13 recommends wrapping behind a module of ours.
- **One Blockbench model with a stepped animation,** in `assets/`, as glTF or FBX plus the `.bbmodel`, to test the art pipeline.
- **A budget** for a small ad test, and for the 1,000 Robux fee that lets under-16s see the game later.
- **Whether they have a cheap Android phone to test on.**
