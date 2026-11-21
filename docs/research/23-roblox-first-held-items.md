# Items that a character holds and carries: what Roblox already has
Asked: what `Tool`, `Backpack`, `StarterPack`, `StarterGear` and the built-in hotbar do, and how games with slot inventories relate them to `Tool`.
Read by one reader on Sonnet, on 2026-11-21. Doc pages were read through a summarising fetch, not word for word.

## What Roblox has

### The classes
- `Tool` is "an object, such as a weapon, that can be equipped by a Humanoid". It inherits `BackpackItem`, `Model`, `PVInstance`, `Instance`. Source: https://create.roblox.com/docs/reference/engine/classes/Tool.md
- `Tool` properties: `CanBeDropped` (drop with backspace), `Enabled` (when false it cannot be activated and its events do not fire), `Grip` (a `CFrame`), `ManualActivationOnly`, `RequiresHandle` (works only with a child part named "Handle"), `ToolTip`. Source: same page.
- `Tool` methods: `Activate()` and `Deactivate()`. The tool must be equipped. Source: same page.
- `BackpackItem` is an abstract base class (not creatable) for `Tool` and `HopperBin`. Its `TextureId` is the icon in the backpack. If blank, the interface shows the tool's name. Source: https://create.roblox.com/docs/reference/engine/classes/BackpackItem.md
- A `Tool` may have no 3D model: set `RequiresHandle` to false and it "exist[s] only in the inventory". Source: https://create.roblox.com/docs/players/tools.md
- `Backpack` is a container under a `Player`. Any `Tool` in it shows as an icon button at the bottom of the screen. It has no properties, methods or events of its own. Source: https://create.roblox.com/docs/reference/engine/classes/Backpack.md
- `StarterPack` is a service. Its contents are copied into each player's `Backpack` when the character spawns. Source: https://create.roblox.com/docs/reference/engine/classes/StarterPack.md
- `StarterGear` is a child of each `Player`, added when the player joins if the place allows gear. Its contents are copied into the `Backpack` at spawn. It differs per player. Source: https://create.roblox.com/docs/reference/engine/classes/StarterGear.md
- On spawn the `Backpack` is filled from `StarterPack` and `StarterGear`. On death the client destroys the `Backpack` and makes a new one, filled again from the same two. Source: Backpack page above.
- `StarterPack` tools arrive "in the order it was added"; a LocalScript can reorder them. Source: https://create.roblox.com/docs/players/tools.md
- A tool cloned into a `Backpack` by a script (from `ReplicatedStorage`, for earned or bought items) affects only that player. Source: same page.
- A `Tool` placed in Workspace is picked up on touch, and is equipped and added to the inventory. Source: same page.

### The built-in interface
- The default backpack and hotbar is a CoreGui element, `Enum.CoreGuiType.Backpack` (value 2). Source: https://create.roblox.com/docs/reference/engine/enums/CoreGuiType.md
- It is switched off with `StarterGui:SetCoreGuiEnabled(coreGuiType: CoreGuiType, enabled: boolean)`. The `Backpack` page says to call it from a LocalScript. Sources: https://create.roblox.com/docs/reference/engine/classes/StarterGui.md and the `Backpack` page.
- A DevForum tutorial uses `StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)`. Source: https://devforum.roblox.com/raw/2873576
- Players equip by clicking the icon or pressing a number hotkey such as 1 or 2. Source: https://create.roblox.com/docs/players/tools.md
- Activation is a click, a tap, or the back-right trigger on a gamepad. Source: same page.
- Slot count, from DevForum only: the bar is built for the 1 to 0 hotkeys, ten tools fit, more go behind a button that shows the rest, and the player picks which ten sit on the bar. Source: https://devforum.roblox.com/raw/1015502 (2021, two replies from other developers, not from Roblox).
- A 2024 tutorial names variables `HOTBAR_SLOTS_FULL` in the CoreGui backpack script. Source: https://devforum.roblox.com/raw/2873576. A search summary says a mobile variable `HOTBAR_SLOTS_MINI` exists; that thread was not read (https://devforum.roblox.com/t/mobile-hotbar-more-than-3-items-custom-coregui/3120003).

### Equip, unequip, events
- `Humanoid:EquipTool(tool: Instance)` makes the humanoid equip the tool. It first unequips any tool already equipped. Source: https://create.roblox.com/docs/reference/engine/classes/Humanoid.md
- `Humanoid:UnequipTools()` unequips the current tool. It goes to the `Backpack` of the player. It does nothing if none is equipped. It works only for a `Humanoid` that has a `Player`, since a `Backpack` is required. Source: same page.
- Equipping "moves it from the Backpack and into a Player.Character model in the Workspace". Tools are held in the right hand by default. Source: Tool page.
- `Tool.Equipped(mouse)` fires when the tool is taken out of the `Backpack`. `Tool.Unequipped()` fires when it is put back. Neither fires if `RequiresHandle` is true and there is no handle. Source: Tool page.
- `Tool.Activated()` fires on a click while equipped, and not if Ctrl is held. `Tool.Deactivated()` fires on release. Source: Tool page.

### What replicates
- A tool in `StarterPack` is copied to all players. A tool cloned from `ReplicatedStorage` affects only the one player. Source: https://create.roblox.com/docs/players/tools.md
- Client input must go to the server through a `RemoteEvent` for effects to reach all players. Source: same page.
- The same page says `Equipped`, `Unequipped`, `Activated` and `Deactivated` "fire only in LocalScripts". Not checked against the class page, which does not say where they fire.
- Because equipping moves the `Tool` into the character `Model` in the Workspace, the tool is then part of the character's hierarchy. The pages do not describe the replication of that move to other players. Not found.

## What it does not do
- Stacks: not found in any page read. The `Tool` page says nothing of stacks. A forum answer says the default interface "can't show stacks" and counts same-named tools in the `Backpack` instead. Source: search result for https://devforum.roblox.com/t/inventory-system/3542187 (not opened).
- Containers that are not a character's: `Backpack` lives under a `Player`. No built-in container class for a chest or shelf was found in `BackpackItem`, `Backpack`, `Tool`, `StarterPack` or `StarterGear` pages. No other page was searched for this.
- Slots with rules (a slot that accepts only some kinds): not found. `Backpack` has no properties. `Tool` has none that restrict where it sits.
- Slot count setting: no property found. `Backpack` has none. The `players/tools.md` page says it does not state the slot or hotkey count.
- Fixed slot positions: the `Backpack` is a set of children, not a list with indices. Order follows the order added (tools page). A drag to reorder is a player action in the interface; no API for it was found.
- Saving: no `Backpack` or `Tool` page read says contents are saved between visits. Not found.
- Dropping: `CanBeDropped` lets the player drop with backspace. The pages do not say what the dropped object becomes.
- The hotbar interface: no documented setting for slot count, layout or art. Changes go through editing the CoreGui script (forum only) or replacing it.
- `StarterGui:SetCoreGuiEnabled` page does not mention `Backpack` by name. Source: StarterGui page above.

## What a game must still build
Statements of what the pages leave open, not advice.
- Anything with a count above one in a slot.
- Any container that is not a `Player`'s `Backpack`.
- Any rule on what a slot accepts.
- Any interface for more than ten slots, or for different art, once `Enum.CoreGuiType.Backpack` is off.
- Saving of held things.
- Replication of any held thing that is not a `Tool`.

How games with slot inventories relate to `Tool` (forum threads, from search summaries; the threads were not opened):
- Stack data kept as plain tables of name and quantity; one answer adds to the quantity or removes the entry at zero. https://devforum.roblox.com/t/inventory-system/3542187
- A `Tool` cloned from storage only when selected, passed to `humanoid:EquipTool`, and the previous clone destroyed. https://devforum.roblox.com/t/problem-with-custom-inventory-system/1425204 (the thread shown in the search was a custom loadout; which of the listed URLs it was is not certain)
- A guide using the built-in `StarterPack` system tracks the held tool in a variable set when a tool enters the `Character`. https://devforum.roblox.com/t/how-to-make-a-custom-inventory-using-robloxs-built-in-starterpack-inventory-system/4717210
- Open-source modules named in a summary: Satchel, Grove, InventoryMaker. https://devforum.roblox.com/t/inventorymaker-a-framework-to-help-you-create-your-own-inventory-system/3619173
- Whether "most games" keep `Tool` only for the held item: not found as a measured fact. Only the threads above point that way.

## Sources
- https://create.roblox.com/docs/reference/engine/classes/Tool.md
- https://create.roblox.com/docs/reference/engine/classes/BackpackItem.md
- https://create.roblox.com/docs/reference/engine/classes/Backpack.md
- https://create.roblox.com/docs/reference/engine/classes/StarterPack.md
- https://create.roblox.com/docs/reference/engine/classes/StarterGear.md
- https://create.roblox.com/docs/reference/engine/classes/StarterGui.md
- https://create.roblox.com/docs/reference/engine/classes/Humanoid.md
- https://create.roblox.com/docs/reference/engine/enums/CoreGuiType.md
- https://create.roblox.com/docs/players/tools.md
- https://devforum.roblox.com/raw/1015502
- https://devforum.roblox.com/raw/2873576
- Search-summary-only (not opened): the devforum.roblox.com/t/ URLs listed above.

## Checked by a second reader
Read on 2026-11-21. Pages were read through a summarising fetch, so quotes below are the summary's, not word for word.
- Claims checked: 24 (lines 8 to 35, 38 to 40, 47, 52 of the brief above).
- Confirmed: 13 groups of claims (listed below). Wrong (partly): 3. Unconfirmed: 6 items.

### Confirmed
- `Tool` description and inheritance (`BackpackItem`, `Model`, `PVInstance`, `Instance`). https://create.roblox.com/docs/reference/engine/classes/Tool.md
- `Tool` properties `CanBeDropped` (Backspace), `Grip` (`CFrame`), `ManualActivationOnly`, `RequiresHandle`, `ToolTip`; `Tool:Activate()` and `Tool:Deactivate()` need an equipped tool; `Activated` does not fire with Ctrl held; `Equipped` and `Unequipped` do not fire when `RequiresHandle` is true and there is no handle. Same page.
- `BackpackItem` is `NotCreatable`; its `TextureId` is the icon shown in the backpack. https://create.roblox.com/docs/reference/engine/classes/BackpackItem.md
- `Backpack` has no members of its own; `Tool` objects in it show as icon buttons; it is refilled from `StarterPack` and `StarterGear` on spawn; on death the client destroys it and makes a new one. https://create.roblox.com/docs/reference/engine/classes/Backpack.md
- `StarterPack` copies into each `Backpack` at character spawn. https://create.roblox.com/docs/reference/engine/classes/StarterPack.md
- `StarterGear` is inserted into each `Player` on join and is player-specific. https://create.roblox.com/docs/reference/engine/classes/StarterGear.md
- `Humanoid:EquipTool` first unequips all equipped tools; `Humanoid:UnequipTools` parents the tool to the `Backpack`, does nothing if none is equipped, works only for a `Humanoid` with a `Player`. https://create.roblox.com/docs/reference/engine/classes/Humanoid.md
- `Enum.CoreGuiType.Backpack` has value 2. https://create.roblox.com/docs/reference/engine/enums/CoreGuiType.md
- `StarterGui:SetCoreGuiEnabled(coreGuiType, enabled)` exists; its section does not name `Backpack`. https://create.roblox.com/docs/reference/engine/classes/StarterGui.md
- The `Backpack` page says to call `SetCoreGuiEnabled` in a LocalScript. Backpack page above.
- `players/tools.md`: StarterPack order is order added; a `ReplicatedStorage` clone affects one player; number hotkeys; activation by click, tap or gamepad back-right trigger; `RemoteEvent` carries client input to the server; page gives no slot count. https://create.roblox.com/docs/players/tools.md
- The same page says tool events "fire only in LocalScripts" (line 40). The `Tool` page itself does not say where they fire. Its examples use LocalScripts.
- DevForum 2873576 (12 March 2024) uses `SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)` and names `HOTBAR_SLOTS_FULL`, with the instruction to set it to thirteen. https://devforum.roblox.com/t/2873576.json (the `/raw/` address returned an empty page here)

### Wrong (partly)
- Line 27: "ten tools fit, more go behind a button that shows the rest". The source thread (30 January 2021, three non-staff posters) has the button only in the original question. The replies say the slot count cannot be changed and the bar is designed for the 1 to 0 hotkeys, and that players choose which tools occupy the ten. No reply says more tools go behind a button. https://devforum.roblox.com/t/1015502.json (the `/raw/` address returned an empty page here)
- Line 12: the quoted phrase "exist[s] only in the inventory" was not found. The `tools.md` page says a non-physical tool "simply occupies a player's inventory" and that `RequiresHandle` should be turned off. The meaning is the same. The quotation marks are not accurate. https://create.roblox.com/docs/players/tools.md
- Line 9: "when false it cannot be activated and its events do not fire". The `Tool` page names only `Activate`, `Deactivate`, `Activated` and `Deactivated` as blocked. It does not say `Equipped` or `Unequipped` stop firing.

### Unconfirmed
- Line 11: "If blank, the interface shows the tool's name". The `BackpackItem` page text read does not say this.
- Line 19: a `Tool` in Workspace is picked up "on touch". The page says collected tools are picked up automatically, with no collision code needed. "Touch" is not in the text read.
- Line 33: the quote about moving "from the Backpack and into a Player.Character model in the Workspace", and "held in the right hand by default". Neither phrase was found in the `Tool` page text returned.
- Line 28: `HOTBAR_SLOTS_MINI`. Not opened. Not found.
- Lines 44 and 64 to 67: the forum threads from search summaries (`3542187`, `1425204`, `4717210`, `3619173`, `3120003`). Not opened by this reader.
- Line 15: "if the place allows gear" is supported. "Differs per player" is supported. Nothing found on which gear is inserted beyond "appropriate gear Tools the player owns".
