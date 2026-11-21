# Stats: bounded values and stacks of modifiers: existing libraries, and whether to use one

Asked: does a library exist that meets all eight checklist lines for a pool, a modifier stack and counted hierarchical tags, in plain Luau.
Made from the readers' file `25-library-audit-stats-all.md`, then this skeptic reading, on 2026-11-21, all on Sonnet.

## The answer

**Write our own.**

- Line 1 (pool): nothing found has a current value between bounds with a changing maximum and a signal. The nearest, ModifierManager, only clamps a computed result (Types.luau `minClamp`, `maxClamp`).
- Line 3 (pure function, any value type, priority, ties in added order): ModifierManager's Calculator takes numbers in three fixed kinds. Priority only picks the winning Override, and a tie goes to the first one met. Modie and Stats Handler are weaker.
- Line 5 (counted, hierarchical tags): none of the Luau candidates has it. Only Unreal's `FGameplayTagCountContainer` and a Unity port do, and neither is Luau.
- Line 6 (plain Luau): the stack is split from Roblox in only one place, ModifierManager's `Calculator.luau`, and that file still loads `Types` through `script.Parent`. The rest of that library calls `task.delay` and needs players.
- Line 7 (tests): ModifierManager's tree of 27 files has no test file. Modie, StatusEffectManager, and the skill-tree repo have none either.
- Line 8 (size and licence): ModifierManager is about 67 KB of source, not 800 lines. Modie has no licence listed.

## Each candidate, after the second reading

How this reading was done: the fetch tool summarises pages, so quotes below are its words or short fragments, not whole lines. GitHub's tree API was used for file lists and sizes.

| Name | Address | Licence | Last commit | Lines that fail | What was wrong in the first reading |
|---|---|---|---|---|---|
| ModifierManager | https://github.com/estrogenie/ModifierManager (the search API lists it as waterdreamer/ModifierManager) | MIT (LICENSE, 1056 bytes) | 2026-07-03 (search API `pushed_at`) | 1, 3, 4 (id string, not a handle), 5, 6, 7, 8 (size) | Line 2 was "partly". Types.luau `StatStack` has `baseValue`, `modifiers`, `cachedValue`, `isDirty`, so every recompute starts from the base: yes. Size was 62 KB; the tree sums to 67,106 bytes. Order was not "add then multiply, priority aside": Calculator.luau walks the array once, sums Additive, multiplies Multiplicative, and `finalValue = (baseValue + additiveTotal) * multiplicativeTotal`. It is order-free, so no set order exists. Calculator itself makes no Roblox call. |
| Modie | https://devforum.roblox.com/t/modie-stat-buffs-have-never-been-easier/4720272 ; https://github.com/serioustemmie/Modie | none listed (search API `license: None listed`) | 2026-08-02 (search API `pushed_at`) | 1, 3, 4, 5, 6, 7, 8 (licence) | Last commit was "not found"; it is now found. The licence is now confirmed absent in the API. The fetch tool also flagged `getModifier(nil)` as never matching, so the duplicate-id check fails for auto ids. Not checked: a LICENSE file by direct fetch. |
| Stats Handler | https://devforum.roblox.com/t/stats-handler-fix-overlapping-walkspeed-stack-stat-buffs-debuffs-modifiers-easily/3632324 | none stated | 2025-05-15 (post) | 1, 3, 4, 5, 6, 7, 8 | Not reopened. The "no" on line 3 rests on the signature `AddModifier(Character, StatName, ModifierName, Amount?, Multiplier?)`, which is data only. It holds. |
| Boost | https://create.roblox.com/marketplace/asset/15931813099/Boost | none | 2025-01-11 (post) | 1, 3, 4, 5, 6, 7, 8 | Weak evidence: source never opened. The search result shows `SetAdd`, `SetPercent`, `SetScale`, `SetClamp`, so the reader's "fixed operations" holds. Archived, so it fails line 8 on maintenance. Still not opened. |
| Nevermore rogue-properties | https://github.com/Quenty/NevermoreEngine/tree/main/src/rogue-properties | MIT | not opened | 6, 8 | Weak evidence: no source file opened. Dismissal rests on 29 dependencies in package.json. That alone fails line 8 ("no dependency"). It holds, but rows 1 to 5 and 7 are unknown. |
| StatusEffectManager | https://github.com/WBlair1/StatusEffectManager | MIT | 2026-02-01 (search API) | 1, 2, 3, 5, 7 | Date was missing. Tree: LICENSE, README.md, `src/Signal.luau`, `src/init.luau`, `src/initializer.server.luau`; no test. Dismissal holds. |
| Effectify | https://devforum.roblox.com/t/effectify-a-customizable-status-effect-implementation/3635681 | none stated | 2026-07-14 (post) | 1, 2, 3, 5, 6, 7, 8 | Not reopened. Source is in the Creator Store only. The post lists `Duration`, `Interval`, `MaxStack`. Holds, weakly. |
| Moonlets | https://github.com/loneka/moonlets | MIT | not shown | 1 to 5 | The first reading listed 7 modules. The tree has 11 (also EnumSerDes, Footstepper, GamepassHandler, SessionStore). `modules/Stator/src/init.luau` is opened now: `NewStator(Value, Updaters)`, `Observe`, `Update`, `Get`. It is a state container with change callbacks. No modifier, pool or tag logic. It also needs `script.Parent.TableUtil`. Dismissal holds. |
| @motioneffector/stats | https://github.com/motioneffector/stats | MIT | not shown | 6, 7 | TypeScript, so it cannot run in `lune`. Not reopened. |
| RollEngine (new) | https://github.com/gmoddev/RollEngine | MIT | 2026-08-11 (search API) | all | Weighted loot rolls with pity and "modifiers". 19 files, no tests, no stat stack. Not the job. |
| roblox-progression-skilltree-system (new) | https://github.com/banowey/roblox-progression-skilltree-system | none listed | 2026-07-27 (search API) | all | Skill tree demo: 3 modules, a UI file, a server file, no tests, no licence. Its "stat-modifier system" is not in a file of its own. |

## What our own library should take from these

- A stored `baseValue`, a list, and a `cachedValue` with an `isDirty` flag: recompute from the base, so removal needs no undo. (ModifierManager, `src/ModifierManager/Types.luau`)
- Clamps kept as fields beside the base, applied after the modifiers. (ModifierManager Types.luau `minClamp`, `maxClamp`)
- Removal by `source` and by tag in one call. (ModifierManager `RemoveAllBySource`, `RemoveAllByTag`, docs/api.md)
- A modifier that has a duration removes itself; a run token stops a stale timer from removing a modifier that was added again. This belongs in glue, not in the stack. (Modie, https://github.com/serioustemmie/Modie)
- An unsubscribe function returned by `Observe`, and a callback that gets old and new value. (Moonlets Stator, https://github.com/loneka/moonlets/tree/main/modules/Stator)
- Counted, hierarchical tags: the model is Unreal's `FGameplayTagCountContainer`. Adding `A.B` and `A.C` makes `GetTagCount("A")` return 2. (https://dev.epicgames.com/documentation/unreal-engine/API/Plugins/GameplayAbilities/FGameplayTagCountContainer)
- A corner to avoid: a nil id on `getModifier` or `hasModifier` matches anything. Ids come from a counter we own. (Modie, as reported by the fetch tool)
- A corner to avoid: an Override that ignores the other modifiers makes a floor impossible. Ours should let a floor be a function at a chosen priority. (ModifierManager Calculator.luau)

## What was not checked

- No line of any file was read in full. Every page went through a summarising fetch tool, which refused to reproduce files. Line numbers are not given for that reason.
- Not opened: the Boost and Effectify source (Creator Store only), the Nevermore `rogue-properties` source files, the `@motioneffector/stats` source, ModifierManager's `PlayerManager.luau` and `EntityManager.luau`.
- Not found: last commit dates for Nevermore, Moonlets and `@motioneffector/stats`. The GitHub search API gave `pushed_at` for the rest, which is the last push, not strictly the last commit.
- Searched this time: GitHub's repository search API with five queries (modifier, status effect, stat modifier, gameplay tags, attributes). Three returned nothing. Not searched: wally.run and pesde.dev pages, awesome-roblox lists, GitHub topic pages. A repo page was also not checked for forks of ModifierManager.
- The ModifierManager owner differs between the address (estrogenie) and the search API (waterdreamer). Not found: which is current.
- Whether a Luau port of gameplay tags exists on a site this search did not reach: not found.
