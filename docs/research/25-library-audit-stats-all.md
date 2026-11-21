# Stats: bounded values and stacks of modifiers: existing libraries (all)

Asked: does a library exist that meets all eight checklist lines for a pool plus a modifier stack with counted, hierarchical tags, in plain Luau. Searched GitHub, wally.run, pesde.dev and the DevForum on 2026-11-21, one reader on Sonnet.
Result: none has everything. Nine were looked at; only ModifierManager and Modie are near the job, and both fail on several lines. Sources were read through a fetch tool that summarises pages, so quoted lines are as that tool returned them, with its line numbers.

## Candidates

### 1. ModifierManager (estrogenie)
- Address: https://github.com/estrogenie/ModifierManager (Wally: estrogenie/modifier-manager@1.0.0). Docs: https://estrogenie.github.io/ModifierManager/
- Licence: MIT (LICENSE file). Last commit: 2026-07-03 (api.github.com commits, message "docs(modifier): add inline logic comments..."). 11 commits.
- Tests: none. The tree of 27 files has no test file, only `.github/workflows/ci.yml`.
- Brings along: client-server sync (PlayerManager, ClientStatReader), timed expiry with `task.delay`, four stacking rules, embedded Signal and Trove, mkdocs site, 720 KB type stubs. Source is about 62 KB across `src/ModifierManager/*.luau`.
- Rows:
  1. Pool: no. BaseModifierManager.luau: "There's no pool logic in this file". It has stat clamps (`SetClamps`, `minClamp`, `maxClamp`) but no current value, and no bound-reached signal. Not opened: whether the Signal fires on a change.
  2. Stack: partly. Types.luau `StatStack` holds "a base value, a list of modifiers, a cached computed value, a dirty flag". Removal is exact, but only because it recomputes.
  3. Stack: no. docs/api.md: the `Modifier` type holds `id, value, modifierType, source, priority, tags, stackingRule, expireTime, minValue, maxValue`, and "No" function field. Types are only Additive, Multiplicative, Override. Number values only. Calculator.luau: add all, then multiply all, then the highest-priority Override. Priority does not order the steps.
  4. Stack: partly. docs/api.md: "Returns the modifier ID for later removal". An id string, not a handle. Removal by `source` and by tag exists (`RemoveAllBySource`, `RemoveAllByTag`).
  5. Tags: no. BaseModifierManager.luau line 246: `self.tagIndex[stackKey][statPath][tag][modifier.id] = true`. Match is `if modifierTag == tag then`: exact, flat, not counted. These tags label modifiers; there is no on_fire counter.
  6. Plain Luau: no. BaseModifierManager.luau lines 59 and 107 call `task.cancel` and `task.delay`; line 104 `os.clock()`. PlayerManager needs Roblox players and remotes (not opened line by line). Would not run in `lune` without stubs.
  7. Strict and docs: partly. Line 2: `--!strict`. Public functions are documented in docs/api.md. No tests.
  8. Licence and size: licence yes; size no (about 62 KB, 11 commits). Dependencies: none external (Signal and Trove are copied in `Packages/`).
- Verdict: missing: 1, 2 (partly), 3, 4 (partly), 5, 6, 7 (no tests), 8 (size)

### 2. Modie (serioustemmie)
- Address: https://devforum.roblox.com/t/modie-stat-buffs-have-never-been-easier/4720272 ; source https://raw.githubusercontent.com/serioustemmie/Modie/refs/heads/main/Modie.luau
- Licence: not stated in the post. Not opened: a LICENSE file (the GitHub API returned 403). Last commit: not opened. Thread created 2026-07-06, last update 2026-07-07.
- Tests: none mentioned. About 251 lines, one file.
- Brings along: it wraps a Roblox Instance and writes the value back with `SetAttribute`; timed modifiers (`task.delay`); Override mode.
- Rows:
  1. Pool: no. `setLimits` clamps the computed value (L225-228, "Clamping applies to the computed value or override, not to the stored base value"). No current value, no signals on bounds.
  2. Stack: yes in effect. `getValue` returns `recalculate(propName, true)` from `Values[propName]` plus the active modifiers, so removal needs no undo.
  3. Stack: no. Three modes only: Override, Multiply, Add (L40-45). Numbers only (`tonumber`, L87). Scanned in `pairs` order (L38-48): no priority, no set order. Several overrides: the last one visited wins.
  4. Stack: partly. `addModifier` returns a modifier table (L149); `Deactivate` removes it (L136-139). Bulk removal is by property (`clearModifiersByProperty`, L203-210), not by label.
  5. Tags: no. "The file does not use CollectionService or tags."
  6. Plain Luau: no. L1: `const ReflectionService = game:GetService("ReflectionService")`; also `GetAttributes`/`SetAttribute` (L23, L68, L79), `Destroying:Connect` (L231).
  7. Strict and docs: no. "There is no `--!strict`". No tests found.
  8. Licence: not found. Size under 800 lines: yes. Dependencies: none.
- Verdict: missing: 1, 3, 4 (partly), 5, 6, 7, 8 (licence)

### 3. Stats Handler (DevForum, 2025)
- Address: https://devforum.roblox.com/t/stats-handler-fix-overlapping-walkspeed-stack-stat-buffs-debuffs-modifiers-easily/3632324
- Licence: none stated. Last change: 2025-05-15 (made "strictly typed"). Source is posted in the thread; no repo. Tests: none mentioned.
- Brings along: it stores stats on a Humanoid and as Character attributes.
- Rows: 1 no (no pool). 2 yes in effect (`UpdateModifiers` recomputes a stat; not read in detail). 3 no (`AddModifier(Character, StatName, ModifierName, Amount?, Multiplier?)`: an amount and a multiplier, no function, no priority). 4 partly (removal by `ModifierName` string via `RemoveModifier`; `ClearModifiers` for bulk). 5 no. 6 no (takes a Character). 7 partly (typed since 2025-05-15; no tests). 8 licence not found.
- Verdict: missing: 1, 3, 4, 5, 6, 7, 8

### 4. Boost (Creator Store)
- Address: https://create.roblox.com/marketplace/asset/15931813099/Boost ; thread https://devforum.roblox.com/t/boost-dynamically-scale-numbers/2786416
- Licence: none; the author asks that credit stay if reuploaded. Last update 2025-01-11; thread marked ARCHIVED. Source is not posted in the thread; only in the asset (not opened).
- Brings along: depends on the author's Assert and Event modules.
- Verdict: unsuitable: archived, no licence text, source not opened, depends on two other modules, and the API (`SetAdd`, `SetPercent`, `SetScale`, `SetClamp`) is a fixed set of number operations, not functions with priority.

### 5. Nevermore rogue-properties (Quenty)
- Address: https://github.com/Quenty/NevermoreEngine/tree/main/src/rogue-properties
- Licence: MIT (package.json: `"license": "MIT"`). It has `test/` and `src/` folders. Last commit: not opened.
- Brings along: 29 workspace dependencies listed in package.json, among them `@quenty/binder`, `@quenty/rx`, `@quenty/brio`, `@quenty/maid`, `@quenty/remoting`, `@quenty/servicebag`.
- Verdict: unsuitable: a framework with 29 dependencies built on Instances and Rx. Source files not opened; rows not filled.

### 6. StatusEffectManager (WBlair1)
- Address: https://github.com/WBlair1/StatusEffectManager
- Licence: MIT. 34 commits; last commit date not shown. Files: `src/`, LICENSE, README.md. No tests seen.
- README: no numeric stat modifiers, no pools, no tags ("Effects use discriminators"). Needs Roblox characters and a client-server split. Credits a Signal module by sleitnick.
- Verdict: unsuitable: a status-effect and combat-state tracker, not a stat stack.

### 7. Effectify (ro1bro1x)
- Address: https://devforum.roblox.com/t/effectify-a-customizable-status-effect-implementation/3635681 ; asset https://create.roblox.com/store/asset/121743174910696/Effectify
- Licence: none stated. Latest post 2026-07-14. Source only through the Creator Store (not opened).
- Post says: effects have `Duration`, `Interval`, `MaxStack`; no pools; no tag system (only an `Attributes` table on each effect).
- Verdict: unsuitable: timed effects with ticks and signals, not a value computed from a base.

### 8. Moonlets (loneka)
- Address: https://github.com/loneka/moonlets
- Licence: MIT. 73 commits, has `tests/`, `pesde.toml`. Last commit date not shown.
- Seven modules: Wrapper, Stator, Instantiate, Leaderboard, HumanoidDescriber, CoreThemer, Bootloader. "None is listed by those names" for stat, modifier, tag or pool. The Stator module was not opened.
- Verdict: unsuitable: no listed module for this job. Stator: not opened, so its fit is not known.

### 9. @motioneffector/stats
- Address: https://github.com/motioneffector/stats
- Licence: MIT. 51 commits. It has a `test.ts` file. Language: TypeScript, not Luau.
- Verdict: unsuitable: TypeScript for D&D 5e stats and dice; does not run in `lune`.

## What was searched and found nothing
- pesde.dev: a search for stat, modifier, buff and attribute returned no package page. The pesde registry itself was not opened. Not found.
- wally.run: only ModifierManager came up, through a search engine. The wally.run search page itself was not opened.
- GitHub search for a Luau or Lune library with priority, pure-function modifiers and handles: nothing. The only match for "pure resolver" was a project issue (OuroborosCollective/Echoes_of_Aurion #504), a design note, not a library.
- Roblox port of Unreal's Gameplay Ability System (gameplay tags, attribute sets): none found. Results were Unreal, Godot (GodotGAS) and Unity.
- Hierarchical, counted tag module in Luau (FGameplayTagCountContainer-like): none found. Results were Unreal and Unity only.
- Pool module (health, stamina, fuel with changing maximum) in Luau: none found as a separate library.
- DevForum: Simple Status Effect Module, Thunder's Status Effect System, "best way of making Buffs" threads and several help threads were seen in results only. Not opened; none claims a stat stack with tags.
- GitHub API calls for commit dates returned 403 for Modie. Dates for Modie, StatusEffectManager and Moonlets are not found.
- Awesome-roblox lists and the Creator Store search page: not opened.

## The nearest miss, and what it lacks
ModifierManager is the nearest. It is MIT, strict, documented, has a priority, a tag index, stacking rules and removal by source or tag, and its last commit is 2026-07-03.

It lacks:
- (1) A pool: it has clamps on the computed value, but no current value, no bound events.
- (3) A modifier as a pure function: modifiers are numbers with three fixed types, so it cannot run on a non-number or apply a floor as a function in a chosen order. Priority only picks the winning Override.
- (4) A handle: it returns an id string.
- (5) Counted, hierarchical tags: its tags are flat labels, matched exactly.
- (6) Plain Luau: it uses `task.delay`, `task.cancel`, `os.clock`, and its PlayerManager needs Roblox players.
- (7) Tests: none.
- (8) Size: about 62 KB of source.

Modie runs closer on size (about 251 lines) but fails more lines: it needs a Roblox Instance, has no strict mode, no tags, no priority, and no licence found.
Conclusion: writing the two small pieces is justified. Lines 2 and 4 are the only ones either library comes near.
