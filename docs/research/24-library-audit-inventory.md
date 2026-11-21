# Inventory: existing libraries, and whether to use one
Asked: does a library hold items in numbered slots (stacks, per-slot accept rule, data and rules only) well enough to use instead of our own, judged on ten checklist lines.
Made by two readers (`24-library-audit-inventory-code.md`, `24-library-audit-inventory-community.md`), then one skeptic, on 2026-11-21, all on Sonnet.

## The answer
**Write our own.**
- No candidate passes line 3 (a per-slot accept rule that holds for every caller). The nearest, `InventoryCore.luau`, fixes it in `canPlace`: `return def.EquipSlot == key` (L61), after `if InventoryCore.isBackpackSlot(data, key) then return true`.
- Line 4 fails in the nearest: `add` returns the amount placed (`return count - remaining`, L133), not the leftover, and there is no put-into-slot function. `takeFrom(data, key, amount?)` (L173) is a good take-from-slot.
- Line 7 fails in the nearest: `sanitize` reads (L302) and nothing writes. Our own would add both.
- The only candidate with a full serialize and deserialize (`skyzwrl/inventory`) fails line 3 (no filter in `SlotStore`, whose public methods I listed) and line 8 (roblox-ts TypeScript, not Luau `--!strict`).
- Line 9 and line 10 cost the rest: the nearest has five commits over two days and a game around it. Using it means copying one file and owning it, so the saving over writing our own is small.
- Candidates with an accept rule per container (InventoryMaker) need a `Player` (line 2).

## Each candidate, after the second reading
"Opened" means I fetched the source or a file listing myself this run. "Not opened" means no source was read.

| Name | Address | Licence | Last commit | Lines that fail | What was wrong in the first reading |
|---|---|---|---|---|---|
| luau-systems `InventoryCore.luau` | https://github.com/stepovyk/luau-systems/blob/main/src/shared/Inventory/InventoryCore.luau | MIT (README and licence commit 2026-11-02) | 2026-11-03 (five commits by the API) | 3, 4 (partial), 7 (partial) | Opened. The two readers disagreed on 4 and 8, and each was half right. Line 4: `add` does not return the leftover, so the community reader was right. Line 8: the code reader was right that public functions have comments (L56, L74, L85, L103, L136, L172, L189, L256, L299), but the community reader was right that there is no generated reference. Both put the file at 330 to 378 lines, and I did not count. The commit count was given as three or "one day"; the API shows five commits over two days. `Def` has more than `MaxStack` (a type at L13); I did not read its fields, so the claim that it requires `Category`, `Rarity` and `Name` is not checked. |
| skyzwrl/inventory | https://github.com/skyzwrl/inventory | MIT (page lists it; no header in `inventory.ts`) | 2026-10-19 (six commits, all that day) | 3, 4 (partial), 8 | Opened. Confirmed no accept rule: `SlotStore` public methods are `write, commit, rollback, committed, count, space, add, remove, move, clear`, and `add` is `public add(id, quantity, maxStack): number`. `remove` is by kind (`remove(id, quantity): boolean`). `move` returns `{ success: false, reason: "DifferentItem" }` for a partial drop on another kind. Serialize and deserialize confirmed: `public serialize(): SerializedInventory`, `public static deserialize<T>(registry, capacity, data: unknown): LoadResult<T>`. The repo has `.lune/` and `rokit.toml`, so tests may run under Lune; the first reading said TestEZ and I did not open `src/__tests__`. The README on the page is the one-line description only. Language is TypeScript by `tsconfig.json`, `eslint.config.mjs` and `.ts` file names. |
| Zyn-ic/Stoway (CoreStore) | https://github.com/Zyn-ic/Stoway | MIT | 2026-10-24 | 1, 3, 7, 8, 10 | Not re-opened. One reader gave 2 as partial and the other as no; I did not settle it. `Stack.luau` returned 404 at the path I guessed, so the `MaxStackSize` quote is the readers' only. The docs page `zyn-ic.github.io/Stoway/server/inventory-data.html` returned 404. |
| Asiandayboy/InventoryMaker (IMS) | https://github.com/Asiandayboy/InventoryMaker | MIT | 2025-12-21 | 2, 3 (partial), 4, 7 | Not re-opened. The readers disagree on size: 58,173 bytes is the file, and "about 1,300 lines" is from line references. The code reader marks line 9 as failed over 1,500 lines, which is not shown by either. Fails line 2 on its own: `SetPlayer(player: Player)`. |
| ahnminjae08043-glitch/roblox-secure-inventory-sample | https://github.com/ahnminjae08043-glitch/roblox-secure-inventory-sample | MIT | 2026-07-21 | 3, 4, 7, and no numbered slots | Not re-opened. Judged by the code reader only. |
| aloqqgem/inventory-trading-system | https://github.com/aloqqgem/inventory-trading-system | none stated | not shown (two commits) | 9 | New. Missed by both readers. Opened the page only. About 8,500 lines of `--!strict` Luau, 148 tests, no dependencies, but the `Inventory` module is one of ten server modules, the page shows no licence, and the README names no accept rule. Not read at source. Too large and unlicensed. |
| bytepointer/InventoryService | https://github.com/bytepointer/InventoryService | none | not re-read | 2, 5, 9 | Dismissal checked and it holds. Opened the page. README: "Every method takes a player instance as its first argument." It needs remote events set up by hand, and no licence is stated. Stacks are by an `amount` argument and the README gives no maximum. |
| titaniumestar/RobloxInventorySystem | https://github.com/titaniumestar/RobloxInventorySystem | none | not shown | 5, 9 | Dismissal checked and it holds. Opened the page. README lists `PlayerPickUp`, `AddItem`, `AnimationEvent` and `ItemEvent` remotes, item Models tagged `IsItem`, and ScreenGuis. It says nothing of stacks or slots, and no licence. |
| Secure Inventory System | https://baseplate-site.pages.dev/docs/modules/inventory-system | not shown | not shown | not rated | Host still does not resolve (`ENOTFOUND`). Search snippet only: `maxSlots` per player, `maxStackSize` defaulting to 1. That reads as fails 1 and 2. Not opened. |
| orange451/Simple-Inventory | https://github.com/orange451/Simple-Inventory | GPL-3.0 | 2025-03-07 | 2, 5, 9 | Not re-opened. |
| inventory-logic-NoGoodUi | https://github.com/lab2SecurityProjectsR/inventory-logic-NoGoodUi | review only | 2026-09-29 | 1, 2, 4, 5, 9 | Not re-opened. |
| Satchel, Purse, sling, backpack-ui, grid-pack, Grove | https://github.com/RyanLua/Satchel ; https://github.com/inurentto/grid-pack | MPL-2.0, Apache-2.0, MIT | various | 5 (user interface) | Not re-opened. The search result says Satchel v1 is unmaintained. |
| OpenInventory, aldrsd/inventory-system, other Wally and DevForum packages | https://wally.run/package/aldrsd/inventory-system | not shown | not shown | not rated | Not opened. The Wally page loads only a shell with no metadata, so the claim that aldrsd needs Knit rests on the first reader's note and I could not check it. The OpenInventory repo returned 404 for the first reader. |

## What our own library should take from these
- `takeFrom(data, key, amount?)` returns the removed stack and takes the whole stack by default, as its own function (https://github.com/stepovyk/luau-systems/blob/main/src/shared/Inventory/InventoryCore.luau, L173).
- `add` tops up existing stacks before opening new ones (same file, L103). Return the leftover, not the amount placed.
- `sanitize` returns the stacks that no longer fit, for the caller to log or compensate (same file, L299 to L301). Do this on read-back.
- Slot keys as strings, "so there are no array holes", for plain data that saves (same file, L5).
- Saving as `{ version, slots }`, with `deserialize` returning the inventory and a `problems` list (https://github.com/skyzwrl/inventory, `inventory.ts`).
- Validate quantities, item ids and slot indices at the edge, with the message "expected a positive integer" (same repository, the first reader's quote; the validation file was not opened).
- Changes that apply fully or not at all, using `commit` and `rollback` on a slot store (https://github.com/skyzwrl/inventory, `slot-store.ts`).
- Change events carrying slot indices, for a caller that replicates (same repository, from its description).

## What was not checked
- Test files: I did not open `tests/InventoryCore.spec.luau` or `src/__tests__`. "17 tests" and "TestEZ specs" are the readers' words.
- Line counts: none of them counted by me.
- Fields of `Def` in luau-systems (L13 to L21).
- Source of ahnminjae08043-glitch, Stoway, InventoryMaker, Simple-Inventory and inventory-logic-NoGoodUi: first reading only.
- pesde: a search for "inventory" returned no pesde page. The registry was not queried.
- Creator Store, the awesome-roblox list itself, and Wally package metadata: not opened (the Wally page has no metadata without scripts).
- GitHub search I added: one query sorted by update time, 18 of the results read, and 67,320 characters of the page unread. Only aloqqgem/inventory-trading-system was new and relevant.
- npm search for rbxts inventory slots returned no inventory package.
- Plain-Lua libraries for other engines: none found by either reader, and none found by me.
