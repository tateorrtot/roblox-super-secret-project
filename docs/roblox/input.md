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
- **`Tool` is not used.** Its two events are the user's two events for an item, selected and interacted with while selected. But a Tool is an Instance in Roblox's own Backpack, one to a slot, with no count. A stack of 16 logs, a crate's slots and rules that run in plain Luau below Roblox cannot be Tools. The game has `ItemScripts` on the server and a piece for each item on the player's machine instead (`docs/code/pieces.md`).
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

## Not tried
- **A touch screen.** Whether a tap also fires an action bound to `MouseLeftButton`, which would interact twice.
- **First person,** where Roblox locks the mouse to the middle of the screen: what a `ViewportPosition` action holds there. The play test throws in first person and does not click.
- **A gamepad.** No binding is declared: there is no pointer to say what is interacted with.
- **`InputActionLabel`,** which would show the player which button interacts.
