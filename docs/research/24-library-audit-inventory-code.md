# Inventory: existing libraries (code)
Asked: does a library already exist that meets all ten checklist lines for numbered-slot item holding. Searched GitHub (API search, trees, raw files), wally.run API, pesde.dev, npm @rbxts; 2026-11-21; one reader on Sonnet.
Result: none has everything. Nearest is stepovyk/luau-systems `InventoryCore.luau`; it lacks line 3 and half of line 7.

## Candidates

### 1. stepovyk/luau-systems, file src/shared/Inventory/InventoryCore.luau
- Address: https://github.com/stepovyk/luau-systems/blob/main/src/shared/Inventory/InventoryCore.luau
- Licence MIT. Created 2026-11-02, last commit 2026-11-03. One-file core, about 378 lines. Tests: yes, tests/InventoryCore.spec.luau, 17 tests, run with Lune.
- Brings along: player data, combat, shop, rate limiter, ItemCatalog, server service. The core file can be taken alone.
1. yes. `export type Stack = { Id: string, Count: number }`; `Def` has `MaxStack`, handed in by `GetDef = (id: string) -> Def?`.
2. yes. Header: "Pure inventory rules: no Roblox services, no networking." No requires. Data is `{ Capacity, Slots: { [string]: Stack } }`.
3. no. "`return def.EquipSlot == key`": backpack slots accept anything, equipment slots accept by `EquipSlot`. No accept rule can be handed in per slot.
4. yes. `takeFrom(data, key, amount?): Stack?` and `add(data, getDef, id, count): number` are separate. `add` returns the count added; the caller holds the rest. `sanitize` returns the stacks that no longer fit.
5. yes. No UI, remote or DataStore in the file.
6. yes. No list inside; `getDef` is handed in. But `Def` requires `Category`, `Rarity`, `Name`, which the job did not ask for.
7. partial. The data is already a plain table. `sanitize(raw, getDef, equipSlots, capacity)` reads it back and repairs it. No function writes it out.
8. yes. First line `--!strict`. 17 tests. Documentation is comments only; no generated reference.
9. yes. MIT; 378 lines, under 1,500. One day of history, no sign of upkeep.
10. yes. No requires.
- Verdict: missing: 3, 7 (partial)

### 2. skyzwrl/inventory (roblox-ts)
- Address: https://github.com/skyzwrl/inventory (npm name `@skyzwrl/inventory` 0.1.0)
- Licence MIT. Created and last commit 2026-10-19. Source about 19 KB of TypeScript (`inventory.ts` about 237 lines, `slot-store.ts` about 187). Tests: yes, TestEZ specs in src/__tests__, built with rojo.
- Brings along: transactions that apply fully or not at all, change events with slot indices, a validated save format.
1. yes. `ItemDefinition { id; maxStack }`, validated: "expected a positive integer".
2. yes. `Inventory` imports only its own files; no Players, Tool, DataStore or remote.
3. no. "The class has no filter or accept callbacks."
4. partial. `add(id, quantity): number` returns the count stored. `remove(id, quantity): boolean` works by kind, not by slot. No take-from-slot function; `move(from, to, quantity?)` returns `MoveResult`.
5. yes.
6. yes. `constructor(definitions?)`, `register(definition)`.
7. yes. `serialize(): SerializedInventory` is `{ version, slots }`; `static deserialize(registry, capacity, data)` returns the inventory and a `problems` list.
8. no. Source is TypeScript compiled by roblox-ts, not Luau with `--!strict`. Tests yes. Documentation: README is one line.
9. yes. MIT; under 1,500 lines. One commit, no upkeep shown.
10. yes. No dependencies; roblox-ts and TestEZ are dev tools only. Needs the roblox-ts toolchain.
- Verdict: missing: 3, 4 (partial), 8

### 3. Zyn-ic/Stoway
- Address: https://github.com/Zyn-ic/Stoway (core in ReplicatedStorage/Shared/Stoway/CoreStore/)
- Licence MIT. Last commit 2026-10-24. Tests: none found in the tree. Wally package; 2 vendored libraries; large (client skins, server service, remotes, console commands).
- Brings along: hotbar and storage UI, skins, QuickNet networking, Fusion, Janitor, conch console, pickup script.
1. no. `Settings.MaxStackSize: number` is one value for the whole inventory, not per kind.
2. partial. CoreStore has no Player. Slots are `Hotbar` and `Storage` lists, and `BackpackEnabled` is a setting.
3. no. "None are defined" in Types; placement is by mode strings.
4. partial. `Operations.remove(state, uuid, amount?)` and `Operations.add(...)` return `overflow`. Items have a `UUID`.
5. no. CoreStore is separate, but `Operations.luau` requires `@game/ReplicatedStorage/Shared/Stoway/Result`, and the repo ships remotes and UI.
6. yes. No item list; `ItemInput` is handed in.
7. no. Only a `FullSyncPayload` for the client. No encode or decode found.
8. no. First line `--!native`, not `--!strict`. Docs in docs/ (mkdocs). No tests found.
9. yes. MIT; actively changed.
10. no. Many packages.
- Verdict: missing: 1, 2, 3, 5, 7, 8, 10

### 4. Asiandayboy/InventoryMaker (IMS server module, wally asiandayboy/inventorymakerserver 1.3.1)
- Address: https://github.com/Asiandayboy/InventoryMaker, file src/server_modules/IMS/init.luau (58 KB)
- Licence MIT. Created 2025-04-11, last commit 2025-12-21. Tests: none in the tree. Brings along: a client UI framework (IMC: drag, hotbar, filter, input).
1. partial. "return 0 if you don't plan on adding a limit to stacks": limit is a callback, no built-in field.
2. no. "`Build` fails without one. The code throws "Player not set."" (`SetPlayer(player: Player)`).
3. partial. `IMS.DefineAllowedItems(containers, callback)` per container, not per slot.
4. no. `AddItem`, `RemoveItem(slotIndex)`, `Switch`; they return boolean, no leftover.
5. no. `DefineRemotesToClient` is in the same file.
6. yes. Items are handed in as data.
7. no. "`Items()` returns the raw array"; no serialize function.
8. partial. `--!strict` yes. No tests found.
9. no. Over 1,500 lines (58 KB).
10. yes for IMS alone.
- Verdict: missing: 1, 2, 3, 4, 5, 7, 8, 9

### 5. ahnminjae08043-glitch/roblox-secure-inventory-sample
- Address: https://github.com/ahnminjae08043-glitch/roblox-secure-inventory-sample, file src/shared/InventoryRules.luau
- Licence MIT. Created and last commit 2026-07-21. About 190 lines. Tests: yes, tests/inventory_rules.spec.luau. Brings along: server, DataStore session lock, rate limit, client.
- Rows: 1 yes (`ItemDefinition.maxStack`, `Catalog` handed in). 2 yes (no Player in the file). 3 no ("The code has no slot concept"). 4 no (`grant` and `remove` return a new inventory or an error string such as "stack_limit"; no leftover). 5 yes for the file. 6 yes. 7 partial (`normalize(raw, catalog)` reads; no write; the inventory is a map of item id to count). 8 yes (`--!strict`, tests). 9 yes. 10 yes.
- Verdict: missing: 3, 4, 7, and no numbered slots at all

### 6. orange451/Simple-Inventory
- Address: https://github.com/orange451/Simple-Inventory, file src/Inventory/Inventory.lua
- Licence GPL-3.0. Last commit 2025-03-07. About 413 lines. Tests: none in the tree.
- Rows: 2 no (`AddViewer(self, viewer: Player)`). 5 no (uses `HttpService`). 7 yes (`ToBuffer`, `FromBuffer`). 8 no (no `--!strict` seen; no tests). 9 no (GPL-3.0). Other rows not graded.
- Verdict: unsuitable: GPL-3.0 licence, and the code needs `Player`

### 7. inurentto/grid-pack
- Address: https://github.com/inurentto/grid-pack (wally.toml present)
- Licence MIT. Archived, last commit 2025-07-05.
- Rows: 5 no. "`Instance.new("CanvasGroup")`" in src/ItemManager/Grid.lua. It is a UI grid library.
- Verdict: unsuitable: it is a UI library (CanvasGroup, UIGridLayout)

### 8. Not opened, or cannot be judged
- bytepointer/InventoryService (no licence, last commit 2026-01-17). Tree opened: `backpack.luau`, `db.luau`, `cache.luau`. File names show a Tool backpack and a database. Source not opened.
- wally xnlogical/openinventory 0.2.0: metadata has no repository and no licence. Source not opened.
- wally aldrsd/inventory-system 0.1.1: metadata lists dependencies `sleitnick/knit` and `sleitnick/signal`, no repository, no licence. Source not opened. Fails line 10 by its metadata.
- ryanlua/satchel (MPL-2.0), encodedlux/sling (MIT), ryanlua/purse (Apache-2.0), wally mariochao/backpack-ui: described as backpack UIs. Source not opened.
- titaniumestar/RobloxInventorySystem: README lists RemoteEvents, Gui and item Models; no licence stated. Source not opened.
- Verdict for all: unsuitable by description, source not opened (bytepointer and the Wally packages: not opened)

## What was searched and found nothing
- GitHub API repository search: "roblox inventory language:Luau" (page 1 read in part, page 2 read), "topic:roblox inventory" (first 18 of 42 read), "roblox-ts inventory" (2 results), "itemstack luau" (1 result).
- GitHub searches "luau inventory slots stack" and "lua inventory itemstack language:Lua" returned 0 results. No engine-free Lua library was found.
- wally.run API search for inventory (11), item (22), container (22 listed). No other slot or stack library appeared.
- pesde.dev: the search URL returned 404. Not searched.
- npm @rbxts: web search only. `@rbxts/backpack-plus` is a backpack UI (depends on charm, remo, rbxts-react, ripple). `@rbxts/loot` has no readme. Neither opened.
- DevForum Community Resources, awesome-roblox lists, Creator Store: not searched.
- Many one-star-or-less repos in the GitHub lists (about 20 more names, mostly no licence) were not opened.

## The nearest miss, and what it lacks
stepovyk/luau-systems `InventoryCore.luau` is nearest. It is `--!strict`, pure, small, tested, MIT, and has no dependency.
It lacks:
- Line 3. The accept rule is fixed inside `canPlace`: any item in a backpack slot, and an item whose `EquipSlot` equals the key in an equipment slot. A caller cannot hand in a rule. A machine's slot rule would need a code change.
- Line 7, half. There is a reader (`sanitize`) but no writer. The data is already a plain table, so a writer is trivial.
- Not on the checklist but in the way: `Def` requires `Category`, `Rarity`, `Name`; slot keys are strings `"1"` to `tostring(Capacity)` plus equipment names; the repository has one day of history.
Second nearest: skyzwrl/inventory. It has line 7 in full and no accept rule either, but it is TypeScript through roblox-ts and has no take-from-slot function.
Neither is "has everything", so the team writes its own. They could read InventoryCore's `takeFrom`, `add` and `sanitize` as a model, and skyzwrl's `serialize`/`deserialize` with a `problems` list.
