# Inventory: existing libraries (community)

Asked: does a library exist that meets all ten checklist lines for numbered slots holding stacks? Searched DevForum Community Resources, GitHub, wally and pesde listings, the Creator Store, npm (roblox-ts) and plain-Lua repos on 2026-11-21. One reader, on Sonnet.
Method: GitHub file listings and raw files were opened. A line is quoted where one proves a yes or no. Anything not opened is marked "not opened". Line numbers are approximate (the fetch tool estimated them).

Checklist (numbers used below): 1 stacks with a given limit per kind. 2 belongs to nobody. 3 per-slot accept rule for every caller. 4 take and put are separate, what does not fit is returned. 5 no UI, networking or DataStore (or separable). 6 no built-in item list. 7 plain data in and out. 8 strict Luau, tests, documented. 9 licence and size or upkeep. 10 no framework, at most one small dependency.

## Candidates

### 1. luau-systems (InventoryCore only)
- Address: https://github.com/stepovyk/luau-systems, file `src/shared/Inventory/InventoryCore.luau` (10,695 bytes)
- Licence: MIT (`LICENSE`, 2026). Last commit: 2026-11-03 (3 commits in all, repo has 0 stars). Tests: yes, `tests/InventoryCore.spec.luau`, 17 cases, run by `lune run tests/run` in CI.
- Also brings: a player-data service, shop kit, pickups, combat, client UI (`src/client/Inventory/init.client.luau`, 27 KB), RateLimiter, Signal. None of it is needed. InventoryCore requires none of it.
- 1 yes. `Def` has `MaxStack`, found through a function passed in: "function InventoryCore.add(data: InventoryData, getDef: GetDef, id: string, count: number): number".
- 2 yes. Header: "Pure inventory rules: no Roblox services, no networking." (line 2). Data is "export type InventoryData = { Capacity: number, Slots: { [string]: Stack } }" (line 10). No Player, Tool or Backpack in the file.
- 3 no. The only rule is built in, and it has two cases: "if InventoryCore.isBackpackSlot(data, key) then return true end return def.EquipSlot == key" (`canPlace`, lines 57-60). The caller cannot give a slot its own rule.
- 4 partly. `takeFrom(data, key, amount): Stack?` and `add(...)` are separate. `add` returns what was placed, not what is left over: "return count - remaining" (line 133). The caller subtracts to find the rest.
- 5 yes. No remote, UI or DataStore call in the file.
- 6 yes. The item list is `ItemCatalog.luau`, a different file. Core takes `getDef`.
- 7 yes, by shape. The data is a plain table with string keys, and `sanitize(raw: any, getDef, equipSlots, capacity)` (line ~303) reads saved data back and repairs it. There is no `serialize` function.
- 8 strict yes ("--!strict" in the file), tests yes. Documented public functions: not found. Only a file header and short comments were seen.
- 9 yes. MIT, about 330 lines.
- 10 yes. No `require` in the file.
- Verdict: missing: 3 (and 4 returns the amount placed, not the rest; 8 has no per-function docs).

### 2. Stoway (CoreStore)
- Address: https://github.com/Zyn-ic/Stoway, folder `ReplicatedStorage/Shared/Stoway/CoreStore/`
- Licence: MIT. Last commit: 2026-10-24. Tests: not found in the file listing (there are specs in `docs/specs/*.md`, as prose). 13 stars.
- Also brings: client UI with skins and layouts, a network layer (QuickNet), Fusion, Vide, Janitor, Promise, a console (Conch), a 835 KB type file, a place file.
- 1 no. One limit for all kinds: "if existingItem.Amount >= settings.MaxStackSize then" (`Stack.luau`).
- 2 no. The slots are a hotbar and a storage: `Types.SlotType = "Hotbar" | "Storage"`. It also has `equip` and `unequip`. No Player in `Operations.luau`.
- 3 no. "The code has no locked or filter concept." Only checks for empty or valid slots (`HOTBAR_SLOT_OCCUPIED`).
- 4 partly. `Operations.add` and `Operations.remove(state, uuid, amount)` are separate. Both return a `Result`. Whether the rest comes back from `add` was not read.
- 5 yes. `init.luau` header: "Pure Luau inventory engine - public API facade".
- 6 yes. No item list.
- 7 not found. No serialize or snapshot function in `init.luau`. `FullSyncPayload` is a type for the network.
- 8 `--!native` is the header of `Stack.luau` and `Operations.luau`. `--!strict` not found in the files read. Tests not found.
- 9 yes for the licence. The core is about 100 KB across 9 files.
- 10 no. Needs a `Result` module from the same repo, and the wider kit needs several packages.
- Verdict: missing: 1, 3, 7, 8, 10.

### 3. InventoryMaker (server part, IMS)
- Address: https://github.com/Asiandayboy/InventoryMaker, file `src/server_modules/IMS/init.luau` (58,173 bytes). Wally: asiandayboy/inventorymakerserver 1.2.1 and asiandayboy/inventorymakerclient 1.2.1 (from the DevForum post, https://devforum.roblox.com/t/3619173; wally page not opened).
- Licence: MIT. Last commit: 2025-12-21. Tests: not found. 16 stars.
- Also brings: a client part (`IMC/init.luau`, 165 KB) with dragging, hotbar, filters, containers.
- 1 partly. No limit is built in. The caller gives a function: "ValidateStackFunc: (player: Player, targetItem: ITEM_TYPE, currItem: ITEM_TYPE) -> (boolean, number)".
- 2 no. "function props.SetPlayer(self: _Inventory, player: Player)".
- 3 partly. The rule is per container, not per slot: "export type AllowedItemsCallback = (item: ITEM_TYPE) -> boolean".
- 4 no. "AddItem: (...) -> boolean" and "RemoveItem: (self, slotIndex: number, ...any) -> ()". Nothing is returned for what does not fit.
- 5 partly. It does not call RemoteEvents, but it takes callbacks for the client: "DefineRemotesToClient". The client part is another file.
- 6 yes. No item list.
- 7 not found. "Items: (self: Inventory) -> DATA" returns the data. No serialize function.
- 8 "--!strict" yes. Tests not found. Docs are on a site (inventorymaker.vercel.app), not opened.
- 9 MIT. About 1,300 lines by its own line references, near the limit. Maintained: last push 2025-12.
- 10 yes. No `require` in IMS.
- Verdict: missing: 2, 3, 4, 7, 8.

### 4. inventory-logic-NoGoodUi
- Address: https://github.com/lab2SecurityProjectsR/inventory-logic-NoGoodUi
- Licence: reviewing only. "no right to use, copy, modify, or distribute it", and commercial use is barred without written permission (`LICENSE`). Last commit: 2026-09-29. Tests: none in the listing.
- Also brings: remotes, a session-locked DataStore manager, equipment, world drops, a 55 KB client controller.
- 1 no. Fixed 24 slots: "Slots: { [number]: InventorySlot }, -- 1 to 24" (`InventoryTypes.luau`).
- 2 no. Slots are tied to a Player's profile through event handlers.
- 4 no: "TryAddItemToProfile(profile, itemId, quantity): boolean".
- 5 no. `MoveItemEvent.OnServerEvent` is in the same script as the logic.
- Verdict: unsuitable: the licence forbids use in a game, and logic, remotes and saving share one script.

### 5. Satchel
- Address: https://github.com/RyanLua/Satchel (also on wally as ryanlua/satchel 1.1.0, from search results). Licence: MPL-2.0. Last push: 2026-11-21. 139 stars. Tests: none in the file listing.
- It is a replacement for Roblox's backpack bar. `src/init.luau` has "local BackpackGui: ScreenGui = Instance.new("ScreenGui")", "local Backpack: Instance = Player:WaitForChild("Backpack")" and "local function IsEquipped(tool: Tool): boolean". The header is "--!nolint DeprecatedApi", not strict.
- Verdict: unsuitable: it is a Tool and Backpack interface, with no data layer and no stacks.

### 6. grid-pack (GridPack)
- Address: https://github.com/Screech46/grid-pack (fork), source https://github.com/inurentto/grid-pack. Licence: MIT. Last push of the source: 2025-07-05, archived. Tests: a test place only (`test/`).
- `src/ItemManager/SingleSlot.lua` clones a slot asset and updates its colour every frame ("self.Assets.Slot:Clone()").
- Verdict: unsuitable: it is a drag-and-drop interface for grid inventories, and the data lives in GUI objects.

### 7. Not opened (source not reachable)
- OpenInventory, https://devforum.roblox.com/t/2712718. The post links https://github.com/XnLogicaL/OpenInventory, which returned 404 on 2026-11-21. No licence stated. Its features list "Strictly Typed". The call is "Module:GetInventory(Player)", which ties it to a Player. Verdict: unsuitable: source not found, and it is keyed by Player.
- Open Sourced Inventory System, https://devforum.roblox.com/t/911931. A single `.rbxl` upload, no licence, built on ProfileService, with weight, equip and drop. The place file was not opened. Verdict: unsuitable: bundled with saving and Tool equipping, and no source to read.
- Open Source Advanced Inventory System, https://devforum.roblox.com/t/511932. A `.rbxl` upload, "no stacking". Verdict: unsuitable: no stacks.
- dispeller's open-source inventory, https://devforum.roblox.com/t/405675. A Roblox asset, no stacking ("possibly item stacking" is planned). Its slots are ObjectValues holding Tools. Verdict: unsuitable.
- Grove, https://devforum.roblox.com/t/4013591. Creator Store asset 119456747866813, a UI backpack. Not opened. Verdict: unsuitable: it is a UI.
- Secure Inventory System, https://baseplate-site.pages.dev/docs/modules/inventory-system. The host did not resolve, so the page and any source were not opened. Search snippets only. Verdict: not opened, cannot be judged.

## What was searched and found nothing
- pesde.dev: a search for "inventory" returned no package. The registry itself was not queried.
- npm, roblox-ts: only `@rbxts/backpack-plus` (a React backpack UI built on Satchel, depends on charm and remo) and `@rbxts/loot` (no README; not opened). No slot or stack package.
- wally: no package for slots and stacks found beyond InventoryMaker and Satchel. The wally.run search page was not opened.
- Plain Lua or Luau repos with no engine calls: none found. Results were FiveM and RedM inventories (ox_inventory, vorp_inventory), which need their frameworks, and JS or C# libraries (motioneffector/inventory, TinyInventory, TheChest), which are not Luau.
- awesome-roblox list: not opened. Only the Satchel page that says it is mentioned there.
- Paid or closed items (CoreShun, SnowGhosty, Advanced RPG Inventory, Inventory & Trading Engine, itch.io kits): no source, not read.

## The nearest miss, and what it lacks
`InventoryCore.luau` in luau-systems (candidate 1) is nearest. It passes 1, 2, 5, 6, 7, 9 and 10, and has strict types and 17 tests.
It lacks:
- 3. The slot rule is one built-in test (equipment slots take only the item whose `EquipSlot` matches). The caller cannot give a slot a rule of its own, so a machine's input slot cannot be described.
- 4. `add` returns the amount placed, not what remains. Taking out (`takeFrom`) and putting in are separate.
- 8, in part. No per-function documentation was found.
- Shape. There is a fixed `Capacity` with numbered string keys, a backpack/equipment split in `isBackpackSlot`, and a `sort` by category and rarity. Each of these would be removed or reworked to serve a chest or a machine.
- One repo, three commits, one author. Using it means copying one file with MIT notice, then owning it.

Result: no library has everything. Nothing found should be used as is.
