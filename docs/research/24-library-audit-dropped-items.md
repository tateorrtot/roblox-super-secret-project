# Things that lie in the world: existing libraries, and whether to use one
Asked: is there a library that records dropped things (place, time, contents), answers reach, merges, delays pickup and clears after a lifetime, meeting all 8 checklist lines.
Made from the readers' file `24-library-audit-dropped-items-all.md`, then rechecked by a skeptic reading the source, on 2026-11-21, all on Sonnet.

## The answer
**Write our own.**
- Nothing found records a dropped thing's place and time (line 1). The nearest, `stepovyk/luau-systems`, keeps a record of `Model`, `ItemId`, `Count`, `OnEmpty` only.
- Nothing merges like things (line 2). The word "merge" appears in no pickup file opened.
- Nothing delays pickup (line 3). No file opened has a pickup delay.
- Lifetime exists once, as a hard-coded `local DROP_LIFETIME = 120` inside a `task.delay` (line 4). It is not a setting.
- The nearest code needs a `Player` and the inventory module inside the pickup file (line 6): `local added = InventoryService.Give(player, pickup.ItemId, pickup.Count)`.
- The readers missed `stepovyk/luau-systems`. It is the closest. It still fails lines 1 to 4 and 6, so the answer does not change.

## Each candidate, after the second reading
| Name | Address | Licence | Last commit | Lines that fail | What was wrong in the first reading |
|---|---|---|---|---|---|
| tralfa42real/roblox-rpg-core-systems | https://github.com/tralfa42real/roblox-rpg-core-systems | MIT | not shown on the page | 1-7 | Default branch is `master`, 2 commits (the readers said one). `LootService` has no position, drop, merge or lifetime lines. No `--!strict`. The "no" holds. |
| Meowtsun/Lootbag | https://github.com/Meowtsun/Lootbag | MIT | not shown (14 commits on `main`) | 1-5, 7 | First line of `src/init.lua` is `--[[`, so not strict. "position" there is a list index. The "no" holds. |
| Roblox Battle Royale pickup system | https://create.roblox.com/docs/resources/battle-royale/pickup-system.md | not found | not applicable | 1-5, 7, 8 | The page shows no code. It names one script, `RarityConfiguration`. Spawners pick a Tool from `Assets/Weapons`. Source in the template place: not opened. |
| DevForum Open Sourced Inventory System | https://devforum.roblox.com/t/open-sourced-inventory-system/911931 | not found | not found | 2-5 by the post, 1 and 6-8 not opened | The only source is `InventorySystem_OpenSourced.rbxl` (74.4 KB). Not opened: a place file cannot be read by these tools. The post says "Drop/Pick up system" and nothing on despawn or merge. The "no" rests on the post alone. |
| STKnight19185/roblox-inventory-system | https://github.com/STKnight19185/roblox-inventory-system | none | 2026-09-11 | all | Confirmed: the tree API lists one file, `README.md`, 115 bytes. |
| Custom drop and pickup system (DevForum) | https://devforum.roblox.com/t/custom-drop-and-pickup-system/1566836 | none | not found | all | Not reopened. The readers say no source. Not rechecked. |
| ScavengeSurvive/item | https://github.com/ScavengeSurvive/item | MIT | not found | 7, and not Luau | Not reopened. Search results describe it as an item library for another engine. |
| **stepovyk/luau-systems** (new) | https://github.com/stepovyk/luau-systems | MIT (LICENSE, year 2026) | 2026-11-03 | 1, 2, 3, 4, 6 | Missed by the readers. See below. |
| Zyn-ic/Stoway (new) | https://github.com/Zyn-ic/Stoway | MIT | 2026-10-24 | 1-5 | Missed by the readers. `src/server/StowayPickup.server.luau` works on `Tool`. |
| kpackk/roblox-gameplay-systems (new) | https://github.com/kpackk/roblox-gameplay-systems | MIT | 2026-07-11 | 1-4, 7 | Missed by the readers. `ItemSpawner.Spawn(itemId, position, opts)` builds a Part. |
| aloqqgem/inventory-trading-system (new) | https://github.com/aloqqgem/inventory-trading-system | none listed | 2026-11-21 | not opened | Missed. Readme lists no world drops, no despawn, no pickup delay. Source not opened. |

### The strongest candidate: stepovyk/luau-systems
Opened `src/server/Inventory/ItemPickups.luau` (5429 bytes) and `InventoryService.luau`.
- Line 1, fails. The record is `Model`, `ItemId`, `Count`, `OnEmpty`. No time, no position field. The position is used once: `model:PivotTo(CFrame.new(position + Vector3.new(0, HOVER_HEIGHT, 0)))`.
- Line 2, fails. No "merge" in the file.
- Line 3, fails. No delay between drop and pickup. The only delay is the respawn of a spawner part: `task.delay(if type(delaySeconds) == "number" then delaySeconds else 30, respawn)`.
- Line 4, fails. `local DROP_LIFETIME = 120` is a constant in the file. Cleared by `task.delay(DROP_LIFETIME, function()`. No start time is kept, so the time left cannot be asked.
- Line 5, half. Reach is checked in the click handler: `(rootPart.Position - root.Position).Magnitude > PICKUP_RANGE + 2`. There is no query for what is in reach of a point. The rest of a stack stays behind when the backpack is full, which is a partial take.
- Line 6, fails. `local function onDrop(player: Player, stack: { Id: string, Count: number }): boolean` and the `ProximityPrompt` and `Workspace:Raycast` are in the same file.
- Line 7, half. `--!strict` is the first line of both files. Tests exist (`tests/InventoryCore.spec.luau`) for the inventory core, not for pickups.
- Line 8, passes for licence. The repo has 9 commits.
- Fits one thing: `InventoryService.SetDropHandler(handler)` is a hook, so the inventory does not know who spawns world items.

### The two weakest dismissals, rechecked
- Battle Royale pickup system: the page was read again. It says nothing of dropped items, despawn, merge or delay, and shows no code. The "no" holds on the page. The template place was not opened.
- Open Sourced Inventory System: the post was read again as JSON. The post lists "Drop/Pick up system" and "Droppable --if item can be dropped". It says nothing of despawn, merge or licence. Source is a place file, not opened. The "no" is likely but not proven. No licence means it cannot be used anyway (line 8).

## What our own library should take from these
- A hook for who spawns the world thing, so the record knows nothing of the inventory: `InventoryService.SetDropHandler`, https://github.com/stepovyk/luau-systems (`src/server/Inventory/InventoryService.luau`).
- The rest of a stack stays when the taker is full: `ItemPickups.luau`, same repository. Our `take` returns the part taken, and the remainder stays in the record.
- A drop is placed by a downward ray from in front of the dropper: `Workspace:Raycast(origin + Vector3.new(0, 3, 0), Vector3.new(0, -50, 0), params)`, same file. That belongs in the glue, not in the record.
- Lifetime as a stored start time, which `DROP_LIFETIME` plus `task.delay` lacks. Our record has `droppedAt`, and expiry is `now - droppedAt >= lifetime`.
- A tag on the Part to find it again, with the item and count as attributes: `ItemSpawner.Spawn` in https://github.com/kpackk/roblox-gameplay-systems (`inventory-system/src/ItemSpawner.module.luau`). Our record is data first, and the Part is made by the glue.
- Stoway keeps items as UUID data, "never live Tool instances", https://github.com/Zyn-ic/Stoway. Our record does the same.

## What was not checked
- The template place of the Battle Royale kit: not opened.
- `InventorySystem_OpenSourced.rbxl`: not opened.
- wally.run and pesde.dev: not opened by me (the readers found 404). A web search for Wally packages named "dropped items" found none.
- GitHub code search needs a login: not used. GitHub repository search returned 0 results for several phrasings. Topic page `github.com/topics/roblox-inventory` returned 404.
- The Creator Store: not opened. `dig1t/roblox-modules` was read: no module for dropped items or pickups.
- Not opened: `aloqqgem/inventory-trading-system` source, `ahnminjae08043-glitch/roblox-secure-inventory-sample`, `ryanlua/satchel`, and the rest of a 172-result GitHub readme search (only 18 were read).
- Not reopened: Custom drop and pickup system, ScavengeSurvive/item, `corruptedkid9/Loot-Crate-System`, `MrBlueMW/GameStarter`.
- Last-commit dates for tralfa42real, Meowtsun and the DevForum items: not shown on the pages I opened.
- Nothing was downloaded or run.
