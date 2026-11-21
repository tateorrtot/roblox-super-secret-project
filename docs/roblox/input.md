# Input: what Roblox has, what the game uses, and what was measured

Written on 2026-11-20, when the clicks on the world moved off `UserInputService`. What Roblox's documentation says and what was measured in Studio are kept apart, because the documentation leaves out much of what mattered.

## What Roblox has
| Roblox | What it is | Godot's nearest |
|---|---|---|
| The Input Action System: `InputContext` > `InputAction` > `InputBinding` | An action such as "interact" is an Instance, and each key, button or stick bound to it is a child of it. Made in Studio or in the project file, not by code. `action.Pressed`, `action.Released` and `action.StateChanged` are its events, and `action:GetState()` reads it. An `InputActionLabel` shows the right key or button for the player's device | The Input Map, and `Input.is_action_just_pressed` |
| `ClickDetector` in a part | Fires `MouseClick` and `RightMouseClick` with the player, on a click, a tap or a gamepad button, within `MaxActivationDistance` of the character. The server can connect to it | An `Area3D` with `input_event` |
| `ProximityPrompt` in a part | Shows a prompt when the character is near, and fires `Triggered` on E, a tap or a gamepad button, with a hold time if wanted | None built in |
| `Tool` in the Backpack | An item of Roblox's own hotbar. `Equipped`, `Unequipped`, `Activated` and `Deactivated` are its events | None built in |
| `UserInputService` | Every raw key, button and touch, with a flag for whether a screen took it. Roblox's guide calls it the old way | `_input(event)` |

## What the game uses, and why
- **The world's two actions are input actions:** `Interact` and `Break`, in the context `World` under `ReplicatedStorage.Inputs`. They are declared in `default.project.json`, and `python tools/studio.py sync` makes them. Which button does what is written there and nowhere in the code.
- **Where the pointer is comes from `UserInputService:GetMouseLocation()`.** An input action can hold it too, and the first version read one. It was taken out after the measurements below: the action held -1, -1 in two states that were tried, and what it holds in first person, where Roblox locks the mouse, was not tried.
- **`ClickDetector` and `ProximityPrompt` are not used.** Each belongs to one part, and tells the server that a player clicked that part. The game needs the same click on a bare tile, which is no part of its own, and needs it to depend on the item in the hand. Both also say where the click was only as "this part". A prompt may still suit a thing that is only ever interacted with, such as a door: it is there when wanted.
- **`Tool` is not used yet, and the user has asked why not.** Claude ruled out an item being a Tool: a Tool is one Instance with no count, and a stack of 16 logs, a crate's slots and rules in plain Luau cannot be Tools. The user means something else (2026-11-20): "Cant we just make it so theres a tool instance that your character equips when you say select a stack of 16 logs? ... the tool and the item are decoupled." What the character holds would be a system of its own, with glue that says which tool a selected stack puts in the hand. What is known of `Tool` for that is below.
- **A tap is still read from `UserInputService.TouchTapInWorld`.** The Input Action System has no tap and no hold: a binding is down or up.
- **The keys still go through `UserInputService`:** E, Q and 1 to 9, and the mouse buttons on the inventory screen. They are the next to move.

## Measured in Studio, 2026-11-20
With a context made at edit time under `ReplicatedStorage`, and Studio's connector moving the mouse (`build/scratch/ias_probe.py`):
- **A click that a `GuiButton` takes does not fire an input action.** A click on a hotbar slot fired nothing on an action bound to `MouseLeftButton`. So a click on the screen is not also a click on the world, with no check of ours.
- **A `ViewportPosition` action bound to `MousePosition` holds the pointer's place in the coordinates of `UserInputService:GetMouseLocation()`:** pixels from the top left of the whole window, the strip along the top included. It holds fractions of a pixel.
- **While its context is disabled it holds -1, -1,** and it stays so after the context is enabled until the mouse next moves.
- **Disabling a context fires `Released`** for an action that was held.
- **The right mouse button fires an action bound to `MouseRightButton`, and Roblox's camera takes it too.** Neither blocks the other.
- **The connector's mouse fires input actions,** so the play test can drive them.
- **`Workspace.PlayerScriptsUseInputActionSystem` cannot be read by a script,** not even one run through the connector. Roblox's guide recommends that it be set to `Enabled` by hand in Studio, so that the default movement and camera run on input actions too. The game's own actions work either way.

## What follows from that
- **The context `World` is never disabled.** While the inventory screen is open, `Main.client` treats the pointer as over nothing in the world. Disabling the context would say the same in Roblox's own terms, but it fires a `Released` that would count as a click.
- **`BreakClick` tells a click from a turn of the camera,** since the right button is both: a press that is let go within 0.35 seconds with the camera facing as it did.

## `Tool`, from Roblox's documentation (read 2026-11-20)
- **Documented:** `Equipped` passes the player's `Mouse`, and `Unequipped`, `Activated` and `Deactivated` pass nothing. `Activated` fires on a click, a tap, or the right trigger of a gamepad, and says nothing of where. `Humanoid:EquipTool` puts a Tool in the character and takes out the one that was there; `UnequipTools` puts it back in the Backpack. With `RequiresHandle` off a Tool needs no part; with it on, the part named `Handle` is held in the right hand. `CanBeDropped`, `Enabled` and `ManualActivationOnly` switch off the Backspace drop, the Tool, and activation by click. `Tool` is not deprecated, and the Input Action System lists "use equipped tool" among Roblox's own default inputs.
- **Not documented, so to be measured before anything is built on it:** whether `Activated` fires on the server; whether a click taken by a `GuiButton` still fires it; whether the server may call `EquipTool` for a Tool that is not in the Backpack; what the number keys and Backspace do while Roblox's backpack bar is switched off, as ours is; and whether a Tool that a player's own machine equips is seen by the server.

## How Minecraft does it (looked up 2026-11-20, for the same question)
- **There is no held object.** What a player holds is the stack in the selected hotbar slot. Other players are sent it in a message of its own.
- **The thing pointed at answers first, then the item:** the block's `useItemOn`, then the item's `useOn` for a block, then the item's `use` for the air (NeoForge's documentation gives the order).
- **The item's code is handed a context, in which the player may be missing,** and the stack. It shrinks the stack it was handed, and `use` returns the stack the hand is left with.
- **How far a player reaches is an attribute of the player,** `block_interaction_range`, 4.5 blocks.
- **`inventoryTick` is called every tick for every stack a player carries,** with a flag for the selected slot.
- **A dispenser does not call the item.** It has a table of its own, from item to behaviour. Furnace fuel is a table too, `FuelRegistry`, and not a field of the item.
- **Since 1.20.5 a stack carries data components,** and since 1.21.2 food and equipment are components and not subclasses. What a right click does still has no component.

## Not tried
- **A touch screen.** Whether a tap also fires an action bound to `MouseLeftButton`, which would interact twice.
- **Measured on 2026-11-21, and so no longer open: a click that a `GuiButton` takes does not fire an action bound to `MouseLeftButton`.** In a play test (`build/hotbar_click_probe.py`), a click on the open world fired `Interact.Pressed` once. A click on a slot of the hotbar selected the slot and fired it no more, and neither did a click on the pack button. Two reviewers had doubted it.
- **First person,** where Roblox locks the mouse to the middle of the screen: what a `ViewportPosition` action holds there. The play test throws in first person and does not click.
- **A gamepad.** No binding is declared: there is no pointer to say what is interacted with.
- **`InputActionLabel`,** which would show the player which button interacts.
