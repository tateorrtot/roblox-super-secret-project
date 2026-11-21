# Things that lie in the world: existing libraries (all)
Asked: is there a library that records dropped things (place, time, contents), answers reach, merges, delays pickup and clears after a lifetime, meeting all 8 checklist lines.
Searched GitHub, wally.run, pesde.dev, the DevForum and Roblox docs on 2026-11-21. One reader, on Sonnet. Result: no candidate has everything.

## Candidates

### 1. tralfa42real/roblox-rpg-core-systems
- Address: https://github.com/tralfa42real/roblox-rpg-core-systems
- Licence: MIT (`LICENSE` is 1057 bytes; the repo lists MIT).
- Last commit: 2026-08-12 (the only commit shown).
- Tests: one file, `tests/RpgCore.spec.lua` (694 bytes).
- Brings along: profiles, banking, economy, guilds, pets, trade, vendors, enemy AI, combat, a rate limiter.

| # | Row | Result |
|---|---|---|
| 1 | Place, time, contents of a dropped thing | no. `InventoryService.lua` holds only a player's profile inventory. Its functions are `AddItem`, `GetItem`, `LockItem`, `UnlockItem`, `RemoveItem`, `TransferItem`. No world record. |
| 2 | Merge by given rule | no. Not found in the 37 files listed. |
| 3 | Pickup delay setting | no. Not found. |
| 4 | Lifetime clear setting | no. Not found. |
| 5 | Reach query, partial take | no. Not found. `LootService.Roll` grants rewards to a player; it has no position. |
| 6 | No Player, no inventory, no network | no. `LootService` takes a player and calls the inventory and economy services. |
| 7 | Strict, tests, docs | no strict line in `InventoryService.lua`. A 694-byte test file exists. `docs/` has three short notes, not a function reference. |
| 8 | Licence, size | MIT. About 37 files, small. Not applicable as it lacks the job. |

Verdict: unsuitable: it is a loot roller and a profile inventory. It never stores a thing lying in the world.

### 2. Meowtsun/Lootbag
- Address: https://github.com/Meowtsun/Lootbag
- Licence: MIT. Last push: 2026-10-08. Tests: none found (files are `src/init.lua`, `wally.toml`, `rotriever.toml`, `rokit.toml`). Size: `src/init.lua` is 7589 bytes.
- Brings along: weighted random choice with a luck value.

| # | Row | Result |
|---|---|---|
| 1 | Place, time, contents | no. API lines: `Lootbag.new(name)`, `Lootbag:AddItem(item, weight, label)`, `Lootbag:GetItem(luck, retries)`. No position or time. |
| 2 | Merge | no. Not found. |
| 3 | Pickup delay | no. Not found. |
| 4 | Lifetime | no. Not found. |
| 5 | Reach query | no. Not found. |
| 6 | No Player/inventory/network | yes. It touches none of them. |
| 7 | Strict, tests, docs | no strict (first line is `--[[`). No tests found. Functions are documented in comments. |
| 8 | Licence, size | MIT, small. |

Verdict: unsuitable: it picks a random item from a table. It records nothing in a world.

### 3. Roblox Battle Royale pickup system (official docs kit)
- Address: https://create.roblox.com/docs/resources/battle-royale/pickup-system.md
- Licence: not found. Last commit: not applicable (a docs page and a template place). Tests: not found.
- Read: the docs page only. The place file was not opened.
- Brings along: spawner Parts tagged `PickupSpawner`, visual Models in `ReplicatedStorage/Assets/Pickups`, functional Tools in `ReplicatedStorage/Assets/Weapons`, a `RarityConfiguration` script, the Weapons Kit.

| # | Row | Result |
|---|---|---|
| 1 | Place, time, contents without a Tool | no. The page says the Tools in `Assets/Weapons` are granted on pickup. |
| 2 | Merge | no. The page does not mention it. |
| 3 | Pickup delay | no. Not mentioned. |
| 4 | Lifetime | no. Not mentioned. |
| 5 | Reach, partial take | no. Not mentioned. |
| 6 | No Player etc. | not opened (script source not read). |
| 7 | Strict, tests, docs | not opened. |
| 8 | Licence, size | not found. |

Verdict: unsuitable: it places fixed spawner pickups of weapon Tools. Items are not dropped and recorded.

### 4. DevForum "Open Sourced Inventory System"
- Address: https://devforum.roblox.com/t/open-sourced-inventory-system/911931
- Licence: not found. Source: a place file `InventorySystem_OpenSourced.rbxl` (74.4 KB), not opened. No repository is linked. Tests: not found.
- Brings along: slots, stacking, weight, drag and drop.

| # | Row | Result |
|---|---|---|
| 1 | Place, time, contents | not opened. The feature list says "Drop/Pick up system". |
| 2 | Merge | no. The post describes stacking only inside inventory slots. |
| 3 | Pickup delay | not found. |
| 4 | Lifetime | no. "Despawn: Not mentioned anywhere." |
| 5 | Reach, partial take | not found. |
| 6 | No Player etc. | no, by design: it is a player inventory. |
| 7 | Strict, tests, docs | not opened. |
| 8 | Licence, size | not found. |

Verdict: unsuitable: it is a player inventory. It has no despawn or merge of ground items.

### 5. STKnight19185/roblox-inventory-system
- Address: https://github.com/STKnight19185/roblox-inventory-system
- Licence: none. Last push: 2026-09-11. The tree holds one file, `README.md`, 115 bytes. The description reads "Advanced Roblox Inventory & Drop System with Drag-Drop, Hotkeys, and Item Management".
- Verdict: unsuitable: no source in the repository. Rows 1 to 8 are not found.

### 6. Custom drop and pickup system (DevForum, by Tiw)
- Address: https://devforum.roblox.com/t/custom-drop-and-pickup-system/1566836
- The page describes Q to drop a Tool and click to pick up. It shares no code and no repository link.
- Verdict: unsuitable: no source. It works on Tools (row 1 is no). Rows 2 to 8 are not found.

### 7. ScavengeSurvive/item
- Address: https://github.com/ScavengeSurvive/item
- Licence: MIT. Language: Pawn for SA-MP (`item.inc`, `test.pwn`), 94 commits, no date shown.
- Verdict: unsuitable: it is Pawn code for another engine, with engine calls. Not Luau.

## What was searched and found nothing
- GitHub repository search (via the API): "roblox dropped item", "roblox dropped items", "roblox loot system", "roblox pickup loot item drop", "topic:roblox pickup", "rbxts item drop", and a few Luau-language variants. Several variants returned 0 results. Nothing matched a world-item record module.
- Hits that were not libraries: `OfficalIDontCode/roblox-healthbar-poc` (a drop feed UI), `kashyapchirag/secret-calculator` (a drop-rate calculator), `gooberddoober/roblox-trade-simulator-autobuy` and `EnderDevelopment/auto-tool-pickup` (scripts for existing games, no licence), `corruptedkid9/Loot-Crate-System` (no licence, last push 2024-08-05, not read), `MrBlueMW/GameStarter` (CC0 plugin with loot boxes, not read), `mhao-n/td-systems-lab` (weighted loot demo, not read).
- wally.run search: the page returned 404 (not opened). pesde.dev search: 404 (not opened). No Wally or pesde package was found by web search either.
- GitHub code search: needs login (401). Not opened.
- DevForum Community Resources: found only the inventory post above. A Roblox thread on stacking was a support question, not a resource.
- Creator Store and awesome-roblox lists: not opened.
- Minecraft-side merge code (Fabric mods, Stratum PR 442, drop-stacker) was seen in results. They are Java or Rust for other engines, so they do not count.

## The nearest miss, and what it lacks
Nearest: tralfa42real/roblox-rpg-core-systems, and only because it is MIT, small and has one test file. It lacks rows 1 to 5 and 7. It has no world record, no merge, no pickup delay, no lifetime and no reach query. Its loot and inventory services need a player and the other services. Nothing found could be adopted without writing the whole job. Custom is the answer.
