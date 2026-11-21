# Things that lie in the world and are picked up or interacted with: what Roblox already has
Asked: what Roblox provides for things lying in the world that are picked up or interacted with (`Tool`, `ProximityPrompt`, `ClickDetector`, `DragDetector`, spatial queries, collision groups, streaming).
Read by one reader on Sonnet, on 2026-11-21, from create.roblox.com/docs pages with `.md` added. Pages were read through a summarising fetch, not word for word.

## What Roblox has

### `Tool`
- A `Tool` is an object a `Humanoid` can equip. Source: https://create.roblox.com/docs/reference/engine/classes/Tool.md
- For players, tools are stored in a `Backpack` parented to the `Player`. Tools for respawning players belong in `StarterPack`. Same source.
- Equipping moves the `Tool` from the `Backpack` into the `Player.Character` model in `Workspace`. Same source.
- `Tool.CanBeDropped`: if true, pressing Backspace parents the `Tool` to `Workspace` and removes it from the `Backpack`. If false, nothing happens and the tool stays equipped. Same source.
- `Tool.RequiresHandle`: if true, the tool works only with a child part named `Handle`. `Equipped` and `Unequipped` do not fire when it is true and there is no `Handle`. Same source.
- `Tool.ManualActivationOnly`: if true, `Activated` fires only when `Tool:Activate()` is called. If false, clicks while equipped fire `Activated`. Same source.
- Other members: `Enabled`, `ToolTip`, `Grip`; methods `Activate()`, `Deactivate()`; events `Activated`, `Deactivated`, `Equipped`, `Unequipped`. Same source.
- `Humanoid:EquipTool(tool)` makes the `Humanoid` equip the tool. It first unequips all tools the `Humanoid` has equipped. Source: https://create.roblox.com/docs/reference/engine/classes/Humanoid.md (first 100000 of 160875 characters read).

### `ProximityPrompt`
- Properties: `ActionText` (default `Interact`), `ObjectText` (default empty), `Enabled`, `Exclusivity`, `HoldDuration` (seconds), `KeyboardKeyCode` (default `E`), `GamepadKeyCode` (default `ButtonX`), `MaxActivationDistance`, `MaxIndicatorDistance` (default 0), `RequiresLineOfSight`, `ClickablePrompt`, `Style`, `UIOffset`, `AutoLocalize`, `RootLocalizationTable`. Source: https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt.md
- `MaxActivationDistance`: the maximum distance from the character at which the prompt appears. Same source.
- `HoldDuration`: seconds the player must hold the button. `0` triggers at once. Sources: ProximityPrompt.md above; https://create.roblox.com/docs/ui/proximity-prompts.md
- `RequiresLineOfSight`: if true, the prompt is hidden when the path from the camera to the object is blocked. The parent part or model is left out of the check. The guide says it defaults to true. Sources: ProximityPrompt.md above; proximity-prompts.md above.
- Must be parented to a `BasePart`, `Model` or `Attachment`. Source: proximity-prompts.md above.
- `Exclusivity` values: `OnePerButton` (one prompt per keycode), `OneGlobally` (one prompt at a time), `AlwaysShow` (all in-range prompts show; each with the same keycode triggers on that key). Source: proximity-prompts.md above.
- `ClickablePrompt`: when false, only the key works. On phones and tablets a prompt can always be clicked. Source: proximity-prompts.md above.
- Events on the prompt: `Triggered`, `TriggerEnded`, `PromptButtonHoldBegan`, `PromptButtonHoldEnded` (each gives `playerWhoTriggered`); `PromptShown`, `PromptHidden`, `IndicatorShown`, `IndicatorHidden`. Source: ProximityPrompt.md above.
- Where it runs: `PromptShown`, `PromptHidden`, `IndicatorShown`, `IndicatorHidden` run on the client, in LocalScripts. Sources: ProximityPrompt.md above; https://create.roblox.com/docs/reference/engine/classes/ProximityPromptService.md
- `ProximityPromptService` has `Enabled`, `MaxPromptsVisible`, `MaxIndicatorsVisible` (default 16, clamped 0 to 64) and the same events, each with the prompt as first argument. Source: ProximityPromptService.md above.

### `ClickDetector` and `DragDetector`
- `ClickDetector` lets scripts receive pointer input on `BasePart`s and `Model`s. Source: https://create.roblox.com/docs/reference/engine/classes/ClickDetector.md
- Properties: `MaxActivationDistance` (studs from the `Character`), `CursorIcon`. Same source.
- Events: `MouseClick`, `RightMouseClick`, `MouseHoverEnter`, `MouseHoverLeave`, each with the player. `MouseClick` fires on left click, touch tap, or gamepad A with the centre dot over the target. Same source.
- It can be parented to a `BasePart`, `Model` or `Folder`. Its events fire on both client and server. Same source.
- If several detectors could take one input, only the deepest fires. An action bound with `ContextActionService` to the same input takes priority. `UserInputService.InputBegan` fires before `ClickDetector` events. Hover events are not guaranteed to pair. Same source.
- `DragDetector` lets players drag 3D objects such as doors and drawers. Placed under a `BasePart` or `Model`. Source: https://create.roblox.com/docs/reference/engine/classes/DragDetector.md
- It inherits from `ClickDetector`. It adds `DragStyle`, `ResponseStyle`, `Axis`, `Orientation`, `ReferenceInstance`, translation and angle limits, `PermissionPolicy`, `Enabled`, and events `DragStart`, `DragContinue`, `DragEnd`. Same source.
- With `RunLocally` false (default), the client sends drag signals to the server, which computes and replicates the motion. With `RunLocally` true, the client handles them and nothing replicates. Same source.
- Physical-mode settings (`MaxForce`, `MaxTorque`, `Responsiveness`) apply only to unanchored parents. Same source.
- Difference from `ProximityPrompt`: `ProximityPrompt` shows UI and triggers from a key, button, or hold near the object. `ClickDetector` takes pointer input and shows no prompt UI. Sources: the three class pages above. The DragDetector page does not compare them.

### Spatial queries
- `WorldRoot:GetPartBoundsInBox(cframe, size, overlapParams?)` returns parts whose bounding boxes overlap the box. Source: https://create.roblox.com/docs/reference/engine/classes/WorldRoot.md
- `WorldRoot:GetPartBoundsInRadius(position, radius, overlapParams?)` returns parts whose bounding boxes overlap the sphere. Same source.
- Both check bounding-box volume, not actual volume. The page says this matters for cylinders, spheres, unions and `MeshPart`s. Same source.
- `WorldRoot:GetPartsInPart(part, overlapParams?)` uses the exact volume of the given part. The part must be in the same `WorldRoot`. The page says the bounds methods are more efficient but less accurate. Same source.
- `OverlapParams` fields: `MaxParts` (default 0, meaning no limit), `CollisionGroup` (default `Default`), `RespectCanCollide` (use `CanCollide` instead of `CanQuery`), `BruteForceAllSlow` (checks every part; the page says not to use it in live experiences), `IncludeInstances` and `ExcludeInstances` (exclusions win). `FilterDescendantsInstances` and `FilterType` are marked superseded by those two. Source: https://create.roblox.com/docs/reference/engine/datatypes/OverlapParams.md
- `BasePart.CanQuery`: whether the part is considered in spatial queries such as `GetPartBoundsInBox` or `Raycast`. Parts with `CanQuery` false are never included. Source: https://create.roblox.com/docs/reference/engine/classes/BasePart.md (first 100000 of 178286 characters read).
- Parts with `CanTouch` and `CanCollide` both false can still be hit by raycasts and overlap queries. Same source.

### Collision groups
- `PhysicsService:RegisterCollisionGroup(name)`: name cannot be `Default`. The page notes a cost that scales with the number of `BasePart`s in `Workspace`, so groups are best registered at edit time. Source: https://create.roblox.com/docs/reference/engine/classes/PhysicsService.md
- `PhysicsService:CollisionGroupSetCollidable(name1, name2, collidable)` errors if either group is unregistered. Same source.
- `PhysicsService:GetMaxCollisionGroups()` returns the maximum; the page gives 32. Same source.
- `BasePart.CollisionGroup` is a string name, at most 100 characters. Parts start in `Default`. A part is in one group. Source: BasePart.md above; https://create.roblox.com/docs/workspace/collisions.md
- By default all groups collide with each other. Parts in non-colliding groups pass through each other even with `CanCollide` true. Passing one name twice sets collision within the group. Source: collisions.md above.
- `Workspace.TouchesUseCollisionGroups`: if true, parts in non-colliding groups also ignore `Touched`. Source: BasePart.md above.
- `RaycastParams.CollisionGroup` filters raycasts by group. Source: collisions.md above.
- `BasePart.CanTouch` false: `Touched` and `TouchEnded` do not fire; the page suggests it for performance. `CanCollide` false does not stop `Touched`. Sources: BasePart.md above; collisions.md above.

### Streaming
- `Workspace.StreamingEnabled` loads and unloads `Workspace` content as the player moves. Only descendants of `Workspace` stream. Source: https://create.roblox.com/docs/workspace/streaming.md
- A streamed-out instance is parented to `nil`, not destroyed. Local-only property changes can be lost when it streams back in. Same source.
- `StreamingMinRadius` (default 64): content inside streams in first and never streams out. `StreamingTargetRadius` (default 1024): the farthest streaming-in distance. Same source.
- `ModelStreamingMode`: `Nonatomic` (default), `Atomic`, `Persistent`, `PersistentPerPlayer`. Same source.
- `StreamOutBehavior.Opportunistic` is recommended by the page; the default `LowMemory` removes content beyond the minimum radius only under memory pressure. Same source.
- Client physics runs only in streamed areas. Distant objects keep simulating if a replication focus (`AddReplicationFocus()`) is near them. Each extra focus adds server work. Same source.
- Assemblies stream in whole and stream out only when all parts are eligible. Anchored assemblies stream in only for the parts in range. Same source.
- Instances created by client scripts are exempt from streaming out unless parented under a server-created instance. Same source.

## What it does not do
- The `Tool` pages do not say a `Tool` in `Workspace` is picked up on touch. Not found. Source checked: Tool.md and Humanoid.md (partly).
- No pickup delay or pickup filter on `Tool` is documented. Not found.
- `CanBeDropped` is documented only as a drop to `Workspace` by Backspace. Nothing is said of what the dropped tool does afterwards.
- `ProximityPrompt` has no property for a pickup target or for stacking; it only reports `Triggered` with a player.
- `ClickDetector` and `DragDetector` pages state no cost or limit on how many may exist.
- The spatial query methods document no cost figures and no part-count cap other than `MaxParts`.
- The streaming page gives no part-count threshold for many small parts.

## What a game must still build
- Not found in the sources: a Roblox feature for picking up a loose item that is not a `Tool`, or for stacking, counting, or merging loose items.
- Not found: a documented rule for what happens to a `Tool` dropped into `Workspace` when a character touches it.
- Not found: any per-instance cost figure for many small parts lying in `Workspace`.

## Sources
- https://create.roblox.com/docs/reference/engine/classes/Tool.md
- https://create.roblox.com/docs/reference/engine/classes/Humanoid.md (partly read)
- https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt.md
- https://create.roblox.com/docs/reference/engine/classes/ProximityPromptService.md
- https://create.roblox.com/docs/ui/proximity-prompts.md
- https://create.roblox.com/docs/reference/engine/classes/ClickDetector.md
- https://create.roblox.com/docs/reference/engine/classes/DragDetector.md
- https://create.roblox.com/docs/reference/engine/classes/WorldRoot.md
- https://create.roblox.com/docs/reference/engine/datatypes/OverlapParams.md
- https://create.roblox.com/docs/reference/engine/classes/BasePart.md (partly read)
- https://create.roblox.com/docs/reference/engine/classes/PhysicsService.md
- https://create.roblox.com/docs/workspace/collisions.md
- https://create.roblox.com/docs/workspace/streaming.md
- Disagreement: collisions.md states no maximum number of collision groups; PhysicsService.md gives 32.
- Disagreement: proximity-prompts.md says `RequiresLineOfSight` defaults to true; ProximityPrompt.md states no default.
## Checked by a second reader
- Claims checked: 26. Confirmed: 19. Wrong: 3. Unconfirmed: 5 (listed below).
- Wrong: `BasePart.CanQuery`. The brief says parts with `CanQuery` false are never included, and omits a condition. BasePart.md says "CanCollide must be disabled for CanQuery to take effect". https://create.roblox.com/docs/reference/engine/classes/BasePart.md
- Wrong: the line 98 "disagreement" over collision group limits. collisions.md says nothing about a maximum. It does not disagree with PhysicsService.md, which gives 32 through `GetMaxCollisionGroups()`. https://create.roblox.com/docs/workspace/collisions.md
- Wrong: the line 57 source. collisions.md does not mention `RaycastParams.CollisionGroup` (only a plugin tip) nor the 100-character limit. The facts are true, from https://create.roblox.com/docs/reference/engine/datatypes/RaycastParams.md and BasePart.md.
- Unconfirmed: "Equipping moves the `Tool` from the `Backpack` into the `Player.Character`". Tool.md as fetched did not say this.
- Unconfirmed: `DragDetector` physical-mode settings `MaxTorque` and `Responsiveness` apply only to unanchored parents. DragDetector.md says this only of `MaxForce`.
- Unconfirmed: `OverlapParams` `RespectCanCollide` meaning, "exclusions win", and the advice against `BruteForceAllSlow` in live experiences. The page text returned was cut off or silent.
- Unconfirmed: `StreamingMinRadius` content "never streams out". Streaming.md as fetched gave only the default of 64.
- Unconfirmed: `ClickDetector.MouseClick` event arguments, and that `DragDetector` is placed under a `BasePart` or `Model`. Not read.
- Confirmed (examples): `CanBeDropped`, `RequiresHandle`, `ManualActivationOnly`, `EquipTool` unequipping others, `ProximityPrompt` defaults and client events, `MaxIndicatorsVisible` 16 and 0 to 64, `RequiresLineOfSight` default true (proximity-prompts.md only), `ClickDetector` deepest-fires rule, `RunLocally`, spatial query methods, `TouchesUseCollisionGroups`, `RegisterCollisionGroup`, streaming defaults and rules.
