# Signals: existing libraries (all)
Asked: does any existing Luau signal library meet the 7-line checklist (plain Luau, order of connection, no copy, typed, tested, licence, no dependency)? Searched GitHub (API and raw files), DevForum search hits, wally and pesde mentions, on 2026-11-21, one reader on Sonnet.
Caveat: files were read through a page-summarising fetch tool, not a plain download. Line numbers and quoted lines are as that tool reported them and were not re-checked byte for byte. Every "not opened" below is a gap, not a no.

Checklist: 1 plain Luau, runs under lune. 2 Connect, Fire, disconnect. 3 inline, in connection order, with stated behaviour for changes during a fire. 4 no copy of arguments. 5 typed over the values, tests, documented. 6 commercial licence, and maintained or under about 300 lines. 7 no dependency.

## Candidates

### 1. sleitnick RbxUtil Signal
- Address: https://github.com/Sleitnick/RbxUtil/blob/main/modules/signal/init.luau
- Licence: MIT ("Licensed under the MIT license." line 11). Last commit in repo: 2026-11-21 (not for this file). Tests: not opened. 431 lines.
- Extras: Once, Wait, FireDeferred, DisconnectAll, GetConnections, Destroy, Wrap (takes an RBXScriptSignal).
- 1 no. `task.spawn(freeRunnerThread, item._fn, ...)` (line 333) in Fire. Lune availability of `task` as a global: not verified.
- 2 yes. Connect (212-228), Fire (326-337), Disconnect (82-103).
- 3 no. `connection._next = self._handlerListHead` (221): new callbacks go first, so Fire runs newest first. Callbacks go through task.spawn, so a yield leaves the Fire loop. Disconnect leaves `_next` intact so a running Fire continues past a removed node (reported).
- 4 yes. Varargs are passed on (`...`).
- 5 partly. `export type Signal<T...>` (line 25), documented. Tests: not opened.
- 6 no. 431 lines, over 300, but maintained. Licence yes.
- 7 yes, no `require`.
- Verdict: missing: 1, 3, 6.

### 2. stravant GoodSignal
- Address: https://gist.github.com/stravant/b75a322e0919d60dde8a0316d1f09d2f (raw: gist.githubusercontent.com/stravant/b75a322e0919d60dde8a0316d1f09d2f/raw)
- Licence: header says "Licenced under the MIT licence." Last commit: not opened. Tests: none (a gist). Length: not opened.
- Extras: Wait, DisconnectAll, strict-mode guards that error on unknown members.
- 1 no. `task.spawn(freeRunnerThread, item._fn, ...)` in Fire.
- 2 yes. Connect, Fire, Disconnect.
- 3 no. Connect prepends to `_handlerListHead`, so newest runs first. Disconnect keeps the node's `_next` so a running Fire continues.
- 4 yes (varargs).
- 5 no. Types and tests: not found in the gist; no docs beyond comments.
- 6 licence yes; maintenance not opened.
- 7 yes.
- Verdict: missing: 1, 3, 5.

### 3. LemonSignal (Data-Oriented-House)
- Address: https://github.com/Data-Oriented-House/LemonSignal/blob/main/src/LemonSignal.lua
- Licence: MIT (repo LICENSE). Last commit: 2026-07-13, "Sacrifice varargs in favor of types". Tests: `tests/` folder exists, not opened. 224 lines.
- Extras: Reconnect, Once, Wait, DisconnectAll, a docs site.
- 1 partly. Line 160 `task.spawn(thread, cn._fn, thread, ...)`; line 177 falls back to `coroutine.resume(thread, cn._fn, thread, ...)` when `task` is absent. Header is `--!nocheck`, `--!native`.
- 2 yes (Connect line 15, Fire line 18, Disconnect 39-59).
- 3 no. Line 105-108 put the new node at `_head`; Fire walks from `_head` (149-162): newest first. Disconnect does not clear the node's own `_next`/`_prev` (reported).
- 4 yes (varargs forwarded).
- 5 partly. `Fire: (self: Signal<T...>, T...) -> ()` (line 18) is generic, but the file is `--!nocheck`. The latest commit says varargs were given up for types; the current Fire may no longer take a variadic. Tests not opened.
- 6 yes (MIT, recent commit, 224 lines).
- 7 yes, no `require`.
- Verdict: missing: 3 (and 5 unconfirmed).

### 4. red-blox Util Signal
- Address: https://github.com/red-blox/Util/blob/main/libs/Signal/Signal.luau
- Licence: MIT (libs/Signal/LICENSE). Last commit on this path: 2023-12-02, "signal version bump". Tests: none seen in the folder (LICENSE, Signal.luau, default.project.json, wally.toml). 93 lines.
- 1 no. Line 1 `local Spawn = require(script.Parent.Spawn)`; `script.Parent` is Roblox.
- 2 partly. `Signal.Connect<T...>(self, Callback): () -> ()` returns a disconnect function (line 40). Fire at line 76.
- 3 no. Prepend (`Next = self.Root`, line 42; `self.Root = Node`, line 46): newest first. Fire line 80 `Spawn(Current.Callback, ...)`.
- 4 yes.
- 5 partly. `Fire: (self: Signal<T...>, T...) -> ()` (line 14). No tests found.
- 6 yes on licence; last change 2023.
- 7 no. It needs the `Spawn` library in the same repo.
- Verdict: missing: 1, 3, 5, 7.

### 5. FastSignal (RBXUtils)
- Address: https://github.com/RBLXUtils/FastSignal (src/ReplicatedStorage/FastSignal/Immediate.lua and Deferred.lua)
- Licence: LICENSE file exists; Wally package lists MIT (search snippet, not opened). Last commit: 2025-04-07, "pkg: bump version to 10.4.0". Tests: none; only `SignalTesting.client.lua` and benchmark scripts.
- 1 no. Immediate.lua line 21 `require(script.Parent.Deferred)`, line 68 `task.spawn(`.
- 2 yes (types lines 7 and 14).
- 3 not found. Connect lives in Deferred.lua, not opened.
- 4 yes (varargs).
- 5 partly. `ScriptSignal<T...>` (lines 4-12). No real tests.
- 6 licence not confirmed in the file (no header).
- 7 no. Immediate requires Deferred and Docs; it bundles GoodSignal, LemonSignal and RBXScriptSignal copies.
- Verdict: missing: 1, 3, 5, 7. (3 is "not found".)

### 6. ffrostfall luausignal
- Address: https://github.com/ffrostfall/luausignal/blob/master/src/init.luau
- Licence: MIT (repo API). Last commit: 2026-08-11, "fix bug". Tests: `tests/signal.spec.luau` and `.lute/tests.luau`. 270 lines.
- Extras: once, wait, collect, delete, disconnect_all, benches, docs site.
- 1 partly. Line 3 `local task = task or require("@lute/task")`. It runs on Roblox and Lute by design; the page claims Lune ("Cross-runtime (Roblox, Lune)"). Lune: not tested.
- 2 yes (lower-case `connect`, `fire`; connect returns a disconnecter, line 117-123).
- 3 no. Line 109 comment says "Connections will be ran in order of connection." Code: `self._head = #self` (150) and the loop counts down (47-48): last connected first. Doc and code disagree. Disconnect uses `table.remove` (123), which shifts later entries, so a disconnect during a fire can skip or repeat a callback. Connects during a fire are not reached in that fire (reported).
- 4 yes. Up to 10 arguments are passed by position (`arg1 ... arg10`, line 48): a limit of ten values.
- 5 yes. `Identity<T...>` (lines 260-268), tests, moonwave docs.
- 6 yes (MIT, maintained, but 270 lines is under 300 too).
- 7 yes for the module. `vendor/testkit.luau` is for tests.
- Verdict: missing: 3 (and 4 only if more than 10 values are needed).

### 7. seaofvoices luau-signal
- Address: https://github.com/seaofvoices/luau-signal/blob/main/src/Signal.lua
- Licence: MIT (package.json). Last commit: 2024-11-28, "Release 0.1.2". Tests: `scripts/` and `src/` listed; no test folder seen. 58 lines.
- Extras: Subject (a value holder), Connection class.
- 1 no. Line 1 `local task = require('@pkg/luau-task')`; line 37 `task.spawn(callback, ...)`.
- 2 yes (`table.insert(self._callbacks, callback)`, line 44; disconnect by `table.remove`, 48).
- 3 partly. Append, so connection order is right. But Fire loops over the live list (line 36 `for _, callback in self._callbacks do`) and each callback is spawned. A disconnect during the loop shifts entries (skip). Not stated anywhere. Disconnect of an absent callback errors only when `_G.__DEV__` is set.
- 4 yes.
- 5 partly. `Signal<T...>` (line 10). README does not mention tests.
- 6 yes on licence; last change 2024. Under 300 lines.
- 7 no. Depends on `luau-task` ^1.0.1.
- Verdict: missing: 1, 3, 5, 7.

### 8. Roblox signal-lua (read-only mirror)
- Address: https://github.com/Roblox/signal-lua/blob/main/src/createSignal.lua
- Licence: MIT. Last commit: 2026-11-12, "Publish to LPM". Tests: `src/__tests__`, jest config. 62 lines.
- 1 no. Line 2 `require(script.Parent.types)`.
- 2 yes (subscribe, unsubscribe, fire).
- 3 no. Subscriptions are keyed by the callback in a hash table (`subscriptions[callback] = subscription`, line 28): no order. The same callback twice is one entry. Changes during a fire: callbacks added during a fire are held in `suspendedSubscriptions` and join after (lines 26, 51-54); a removed callback is skipped (line 45). This part is well defined.
- 4 no. One value only: `callback(value)` (line 46).
- 5 partly. `Signal<T>` has one value type. Tests and docs exist.
- 6 yes.
- 7 yes for the file; needs the `types` module in the repo; `Packages` folder is dev.
- Verdict: missing: 1, 3, 4, 5.

### 9. LimeSignal (CavefulGames, archived)
- Address: https://github.com/CavefulGames/LimeSignal/blob/main/src/lib.luau
- Licence: MIT. Last push: 2024-12-16. Archived: true. Tests: `dev/test.server.luau` only. 377 lines.
- 1 no. Line 5 `require(script.Parent.Parent.roblox_packages.threadpool)`; line 229 `Instance.new("BindableEvent")`.
- 3 no. Prepend (`_next = head`, line 241); `ThreadPool.spawn(cn._fn, ...)` (line 285).
- 5 partly. `Signal<T...>` (line 151).
- 6 no. Archived, 377 lines.
- 7 no. Depends on threadpool.
- Verdict: unsuitable: archived, needs BindableEvent and a Roblox path.

### 10. LastTalon signal
- Address: https://github.com/LastTalon/signal
- Licence: MIT. Last commit: not shown. Describes itself as "for Roblox". Has `lib/`, `tests/runners/`, testez config. Source files not opened.
- Verdict: unsuitable: written for Roblox; source not opened.

### 11. denpa (AnotherSubatomo)
- Address: https://github.com/AnotherSubatomo/denpa/blob/main/denpa.luau
- Licence: MIT. Last push: 2026-08-06. About 769 lines. It is a reactive-values library (alien-signals port): no Connect or Fire.
- Verdict: unsuitable: a different kind of signal (state, effects), no Connect or Fire.

## What was searched and found nothing
- lukadev-0 signals: a search found no repo by that name. Not found.
- lightsignal (wally `wiam77/lightsignal`, pesde `wiam/rl`): a search named it as Roblox and Lune; no repo found, github.com/wiam77/lightsignal returned 404. Source not opened.
- pesde.dev: no signal package listing could be reached; the search returned only mentions of LimeSignal and lightsignal.
- wally.run: not opened. Only search snippets named packages.
- Named in results but not opened: XSignal (Novaly-Studios; the GitHub API returned 404), YuiElina/Signal, Clownxz/Signal, ayiosbot/signal, Signal+ (DevForum), VeSignal, CuteSignal, RoBits Signal, NamedSignal, AcidSignal, Weaver Signal, GenericSignal, Resignal, Quenty signal, kalrnlo, dig1t Signal.
- Roblox Creator Store and awesome-roblox lists: not searched.
- DevForum topics: only search-result titles seen; no topic read.
- Lune support: no candidate's source was run, and nothing here was installed.

## The nearest miss, and what it lacks
The nearest is ffrostfall luausignal (6). It is typed over the values, tested, MIT, maintained, 270 lines, and one file. It lacks checklist 3: it runs callbacks last connected first, against its own comment, and a disconnect during a fire can skip a callback. It also needs a global `task` or `@lute/task` to fire (line 3), so line 1 needs checking under lune. It passes at most ten values.

The second is LemonSignal (3). It is 224 lines and falls back to `coroutine.resume` when `task` is missing, but it fires newest first, is `--!nocheck`, and its latest commit may have dropped variadic Fire.

Every library read prepends or counts down, except luau-signal, which appends but has a dependency and a skip bug. None meets all seven lines. Result for the team: none has everything; write the library.
