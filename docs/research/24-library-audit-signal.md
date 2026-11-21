# Signals: existing libraries, and whether to use one
Asked: does an existing Luau signal library do the whole job (plain Luau, fires in connection order, no copy, typed, tested, no dependency)? Made from the readers' file `24-library-audit-signal-all.md`, then this skeptic reading the sources again, on 2026-11-21, all on Sonnet.
The source was read as plain text through `curl` to the terminal (nothing saved, nothing run). GitHub's search API ran out of requests part way through (see the last section).

## The answer
Write our own.
- Line 3 fails in every library whose source was read. Every one of them puts a new connection at the head of its list or counts down from the end, so Fire runs the newest callback first.
  - ffrostfall luausignal: `self._head = #self` then `sig._head -= 1; sig[sig._head + 1](...)`, init.luau lines 149-150 and 46-48. Its own comment at line 108 says "ran in order of connection". The code does the opposite.
  - LemonSignal: `_next = head` ... `self._head = cn`, LemonSignal.lua lines 101-108. Fire walks from `_head` (line 149).
  - ewd3v luau_signal: its doc comment says "fired in the reverse order that they were connected in" (src/signal.luau line 310).
  - RbxUtil: `connection._next = self._handlerListHead` (init.luau lines 221-223).
- Line 3 also asks what happens when a callback changes the list during a fire. Only Roblox signal-lua states it, and it fails lines 1 and 4 (one value, `script.Parent`). The linked-list libraries leave it unstated.
- Line 1 fails or is unproven for the ones that are otherwise close. luausignal and LemonSignal call `task.spawn` or `@lute/task`. Whether `lune` has a global `task` was not checked here, so neither can be called a yes or a no. ewd3v reaches Lune through a `_G.RUNTIME` value set by its build step (line 298), which a plain `lune run` does not set.
- Line 6 fails for RbxUtil (431 lines) and ewd3v (357 lines, last commit 2025-11-01). LemonSignal (224) and luausignal (270) are short enough.
- Taking one and changing its order is a fork. A fork of 224 lines with a different order, plus our own tests, is about the size of writing the file.

## Each candidate, after the second reading
"Opened" means this reading opened the source. "Not reopened" means the first reading stands and was not checked.

| Name | Address | Licence | Last commit | Lines that fail | What was wrong in the first reading |
|---|---|---|---|---|---|
| luausignal (ffrostfall) | https://github.com/ffrostfall/luausignal/blob/master/src/init.luau | MIT (repo, not reopened) | 2026-08-11 (not reopened) | 3, 1 unproven, 4 (ten values) | Right. Opened. Order, comment mismatch and the ten-value limit confirmed (lines 40, 48, 108, 149-150). `connect` is `table.insert`, `disconnecter` is `table.find` then `table.remove` (lines 116-123), so a disconnect during a fire shifts the array. Line 3 `task or require("@lute/task")` is not a Lune path. |
| LemonSignal | https://github.com/Data-Oriented-House/LemonSignal/blob/main/src/LemonSignal.lua | MIT, 2023 (LICENSE opened) | 2026-07-13 (not reopened) | 3, 5, 1 unproven | Line 5 was "unconfirmed". It is a no: line 2 is `--!nocheck`, and `Fire` is typed `(self, T...)` at line 18. The first reading's guess that varargs were dropped is wrong for the file now: `fire` takes `...: any` and forwards it. Also wrong: "1 partly". At load, `if task then ... Instance.new("BindableEvent")` (lines 90-94) runs only when a global `task` exists. If Lune has none, it is skipped. Not checked. A disconnected node keeps its `_next`, so a fire carries on past it. A node unlinked before it is reached is skipped. A connect during a fire goes to the head and is not reached. Tests: none found by file name (rate limit, see below). |
| RbxUtil Signal | https://github.com/Sleitnick/RbxUtil/blob/main/modules/signal/init.luau | MIT (not reopened) | not reopened | 1, 3, 6 | Right. Opened lines 205-345. Prepend at 221-226, `task.spawn(freeRunnerThread, item._fn, ...)` at 334, `if item.Connected` check at 330. `DisconnectAll` also calls `task.cancel` and `warn` (lines 304-305), so line 1 fails in more places than Fire. |
| ewd3v luau_signal | https://github.com/ewd3v/luau_signal/blob/main/src/signal.luau | MIT (LICENSE exists, text not read) | 2025-11-01 | 3 (documented as reverse), 6 (357 lines, a year old) | Not in the readers' files. New. Typed `Fire: <T...>(self, T...)` (line 173). `tests/init.luau` and a CI file exist. No `require` except `@lune/task`, chosen by `_G.RUNTIME` (line 298-300). Fire spawns each callback on a shared thread (line 324). Disconnect keeps the node's `_next` (lines 93-107). |
| jiwonz luau-signal | https://github.com/jiwonz/luau-signal/blob/main/src/lib.luau | MIT (file exists) | 2025-02-22 | 3, 7, 5 | Not in the readers' files. New. Says "Luau, Lune, and Roblox". Lines 3-5 require `@pkg/go`, `@luau_pkg/table_helper`, `@pkg/task`: three dependencies. Reconnect and connect both set `signal._head = self` with `_next = head` (lines 214-220, 230): newest first. No tests folder. |
| signalis (luau-ecs) | https://github.com/luau-ecs/signalis | MIT | 2026-08-17 | all | Not in the readers' files. New. `src/init.luau` is 10 bytes and reads `return {}` at HEAD. Its readme says "pre-1.0" and "not published yet". Nothing to judge. |
| GoodSignal | https://gist.github.com/stravant/b75a322e0919d60dde8a0316d1f09d2f | MIT (header, not reopened) | not opened | 1, 3, 5 | Not reopened. |
| red-blox Util Signal | https://github.com/red-blox/Util/blob/main/libs/Signal/Signal.luau | MIT (not reopened) | 2023-12-02 | 1, 3, 5, 7 | Not reopened. |
| FastSignal | https://github.com/RBLXUtils/FastSignal | MIT, 2021, LucasMZ (LICENSE opened) | 2025-04-07 | 1, 3, 5, 7 | Line 3 was "not found". Now found: `Deferred.lua` line 129 is `task.defer(node._handler, ...)`, so callbacks do not run inside `Fire` at all. A no for line 3, with a different reason than the others. It also depends on `script.Parent.Docs` (line 189). |
| seaofvoices luau-signal | https://github.com/seaofvoices/luau-signal/blob/main/src/Signal.lua | MIT (not reopened) | 2024-11-28 | 1, 3, 5, 7 | Not reopened. It is the only one read by the first reader that appends in connection order. It needs `luau-task` and loops a live array while callbacks are spawned. |
| Roblox signal-lua | https://github.com/Roblox/signal-lua/blob/main/src/createSignal.lua | MIT (not reopened) | 2026-11-12 | 1, 3, 4, 5 | Not reopened. |
| LimeSignal | https://github.com/CavefulGames/LimeSignal/blob/main/src/lib.luau | MIT | 2024-12-16, archived | 1, 3, 6, 7 | Not reopened. |
| LastTalon signal | https://github.com/LastTalon/signal | MIT (first reading; this reading found no file at `LICENSE`, 404) | not shown | 1, 7 | "Source not opened" was a gap. Opened `lib/init.lua` by grep only: line 2 `require(Package.LinkedList)`, line 187 `task.spawn(listener.callback, ...)`. A dependency inside its own package and a Roblox spawn. The order was not read. |
| denpa | https://github.com/AnotherSubatomo/denpa/blob/main/denpa.luau | MIT | 2026-08-06 | not a signal | Not reopened. |

## What our own library should take from these
- Keep a connection as a node of a linked list and unlink it in constant time, as in LemonSignal and ewd3v. Keep the node's `_next` after it is unlinked, so a fire that is standing on it carries on. https://github.com/Data-Oriented-House/LemonSignal/blob/main/src/LemonSignal.lua lines 36-56.
- Append, and walk from the first node. This is the one behaviour none of them has, and it is the whole reason for line 3.
- Decide the corner cases and write them in the comment: a callback that disconnects itself, one that disconnects a later one (skipped, as in LemonSignal's unlink), one that connects a new one (not reached in this fire). Roblox signal-lua is the only one that states a rule for a connect during a fire. https://github.com/Roblox/signal-lua/blob/main/src/createSignal.lua lines 26 and 51-54 (first reading).
- Return a `Connection` with a `Connected` field and `Disconnect`, as RbxUtil, LemonSignal and ewd3v do. Roblox's own names, so it reads the same as `RBXScriptSignal`.
- Type it as `Signal<T...>` with `Fire: (self, T...) -> ()`. ewd3v lines 156-177 and RbxUtil line 25 do this and the file stays `--!strict`.
- Run each callback with a plain call, not `task.spawn`. A plain call has no dependency and runs under `lune`. The cost: a callback that yields holds up the fire. That is a decision for the user, not for this file.
- Do not copy luausignal's limit of ten values (line 40) or its `table.remove` disconnect (line 122).
- Test the order and each corner case, and run the tests under `lune`. Only luausignal and ewd3v ship tests that were seen by name. Neither tests order, as far as the file names show (test files not opened).

## What was not checked
- Whether Lune has a global `task`, and whether `task.spawn` there runs a callback at once. Not checked, not run. This decides line 1 for luausignal, LemonSignal and RbxUtil.
- The test files of every candidate. Only file names were seen, and for LemonSignal and seaofvoices the listing failed when GitHub's search API ran out of requests.
- Licence text of luausignal, RbxUtil, GoodSignal, red-blox, seaofvoices, LastTalon (404 at the path tried), signal-lua, LimeSignal and denpa. Taken from the first reading.
- Rukioyuza/Signal.luau ("typed signal with safe disconnects and thread reuse", pushed 2026-11-17, MIT in the search result), IvyyDev/luau-signal, Khoshal-Studio/luau-signal (Apache-2.0), overworded/Luau-Signal (no licence): found by one GitHub search, not opened.
- wally.run, pesde.dev, the DevForum and the Creator Store were not searched by this reading.
- The first reading's line numbers for RbxUtil (326-337), GoodSignal, red-blox, seaofvoices, signal-lua and LimeSignal were not compared with the source again. RbxUtil's Fire is at 327-338 in this reading, one line off.
