# Asked of the user, not yet answered

Only what is still open. When they answer, the answer goes where it belongs and the line leaves this file.

## About the code
- **To read the code,** and give their verdict on the names Claude chose (listed in `claudes-calls.md`).
- **Whether the keys move onto Roblox's input actions next, before prediction** (`next.md`). Asked on 2026-11-20.
- **Whether the scripts read right to them:** `ItemScripts` and `PlacedObjectScripts`, and the game's things in `src/shared/content`. The names and shapes that are Claude's are in `claudes-calls.md`, with the four names a cold reader doubted in `history/2026-11-20-scripts-and-input.md`.
- **Whether to build what Claude showed them for `World` on 2026-11-20:** a kind makes its own object with what it has on it (a crate with its inventory, a stove with its station), the plot holds it, and `World` drops its two stores. They asked to be shown it: "Is this to debloat World as our big singleton?"
- **Whether to try a Roblox `Tool` for what the character holds,** as they proposed. The first step is a short measurement in Studio of what Roblox's documentation leaves unsaid (`docs/roblox/input.md`).
- **Whether tiles should be three-dimensional,** and if so whether now. They asked who said tiles were flat.
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
