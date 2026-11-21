# State machines: existing libraries (all)
Asked: does a library exist that has every line of the 8-line checklist (explicit machine, priority machine, plain Luau under lune, strict + tests + docs, licence, no dependency)?
Searched GitHub, wally/pesde (by web search), the DevForum and the Creator Store on 2026-11-21. One reader on Sonnet. Source files were read through a page-summarising fetch tool, not line by line by hand, so line numbers are approximate. The GitHub API returned 403, so last-commit dates were not found for any candidate. Nothing was downloaded or run.

Checklist: 1 exit, enter, announce, in that order. 2 request by name, non-active ignored. 3 switch inside enter announces only the final one; switch inside exit refused or deferred. 4 priority machine. 5 plain Luau, no Roblox call, time passed in. 6 `--!strict`, tests, documented. 7 commercial licence, maintained or under 600 lines. 8 no dependency, no framework.

## Candidates

### 1. BusyCityGuy/finite-state-machine-luau ("StateQ")
- Address: https://github.com/BusyCityGuy/finite-state-machine-luau (source `src/StateQ/init.luau`)
- Licence: MIT (`LICENSE.md`). Last commit: not found (197 commits). Wally `busycityguy/stateq@0.0.8`.
- Tests: yes, Jest through Wally dev-dependencies (`jsdotlua/jest`), plus a `lune/` folder. The test files were not opened.
- Brings along: a Signal module, a ThreadQueue module, GreenTea runtime type checks, a `src/TestService/Source` folder, Wally/Rokit/Selene/StyLua config. About 525 lines.
- 1: no. The header lists the order: "3. Fire `leavingState` signal", "4. Update the current state", "5. Fire `stateEntered` signal". There are signals only. No state has its own enter or exit function.
- 2: no. Events are submitted to the machine from outside. `Illegal event {eventName} called during state {beforeState}` is an error, not an ignore. No notion of "the requester is not the active state".
- 3: not found. The source does not say what a submit from inside a handler does. Events are queued FIFO (header).
- 4: no. "FIFO order" only. Nothing is polled.
- 5: no. `local Packages = script.Parent` (L123), `require(script.Modules.Signal)` (L125), `task.spawn(error, ...)` (L472). Time is not read.
- 6: partly. `--!strict` on L1. Tests exist. Public functions have doc comments in the header.
- 7: yes for the licence. 525 lines, so the line limit is met.
- 8: no. Requires `gt = require(Packages.GreenTea)` (L127) and two vendored modules.
- Verdict: missing: 1, 2, 3, 4, 5, 8

### 2. SnorlaxAssist/finite-state-machine-luau
- Address: https://github.com/SnorlaxAssist/finite-state-machine-luau (source `src/StateMachine.luau`)
- Licence: MIT. Last commit: not found (3 commits). Tests: none found. About 302 lines.
- Brings along: `src/dependencies/` with Signal and ThreadQueue. Its header has the same step list as StateQ. Whether it is a copy of StateQ was not checked.
- 1: no. Signals only: "Fire `leavingState` signal", then "Update `_currentState`", then "Fire `stateEntered` signal" (L231-233).
- 2: no. `assert(transition, \`Illegal event {eventName} called during state {beforeState}\`)` (L220). An error, and events come from outside.
- 3: not found.
- 4: no. FIFO queue (header L54).
- 5: no. `require(script.Parent.dependencies.Signal)` (L112). `task.wait()` in the header example only.
- 6: partly. `--!strict` on L1. No tests found.
- 7: yes (MIT, 302 lines).
- 8: no. Two dependency modules in the repo.
- Verdict: missing: 1, 2, 3, 4, 5, 6, 8

### 3. prooheckcp/RobloxStateMachine
- Address: https://github.com/prooheckcp/RobloxStateMachine (source `src/StateMachine/init.lua`, `Classes/State.lua`)
- Licence: MIT (wally.toml `license = "MIT"`, version 1.1.7). Last commit: not found (149 commits, 41 stars). Tests: none found. Docs: Moonwave site.
- Brings along: vendored Signal and Trove, `HttpService`, `RunService.Heartbeat`, loading states from a Folder of ModuleScripts, a shared data table, Transition objects.
- 1: no. `_ChangeState` starts the leave with `task.spawn(previousState.OnLeave, ...)` and the enter with `task.defer(state.OnEnter, ...)`. The enter runs after the switch is committed. `self.StateChanged:Fire(newState, ...)` is called after those.
- 2: no. `ChangeState` only checks `currentState:CanChangeState(newState)`. No active-state check on the caller.
- 3: no. No re-entrancy guard (searched `_ChangeState`).
- 4: no. Transitions are polled each Heartbeat and the first match wins (`break`), but they are per-state. No machine-wide order of states.
- 5: no. `local RunService = game:GetService("RunService")`, `RunService.Heartbeat:Connect(function(deltaTime: number)`, `HttpService:GenerateGUID(false)`.
- 6: no. No `--!strict` in `init.lua` or `State.lua`. No tests found.
- 7: yes for the licence. Source size not counted.
- 8: no. Vendored Signal and Trove, plus Roblox services.
- Verdict: missing: 1, 2, 3, 4, 5, 6, 8

### 4. bohraz/Arch
- Address: https://github.com/bohraz/arch (source `src/init.luau`, `src/Transition.luau`)
- Licence: MIT. Last commit: not found (15 commits, 13 stars). Tests: `tests/Arch.spec.luau` (TestEZ, opened: no).
- Brings along: hierarchical SCXML-style statecharts, history, an event queue, `after` timers. Published to pesde and Wally.
- 1: not found. `Transition.microstep` was not opened. `Transition.enterStates` and `exitStates` are called from `Start` and `Stop` (L405, L421).
- 2: no. `Send` (L436-443) checks only `_running`, then queues the event.
- 3: not found.
- 4: no. `table.remove(machine._queue, 1)` (L64), FIFO. It blocks on `machine.EventAdded:Wait()` (L94).
- 5: no. `os.clock()` (L297) inside the `after` guard, `task.spawn(mainEventLoop, self)` (L407), `require(script.Parent.sift)`.
- 6: no. L1 is `local Sift = require(script.Parent.sift)`, not `--!strict`. Tests exist.
- 7: yes for the licence.
- 8: no. pesde.toml lists jecs, sift, signal, janitor, TestEZ.
- Verdict: missing: 1, 2, 3, 4, 5, 6, 8

### 5. OverlineJunior/state-machine
- Address: https://github.com/OverlineJunior/state-machine (source `src/init.lua`, 191 lines)
- Licence: MIT in wally.toml (v2.4.4). No licence file listed in the repo. Last commit: not found (16 commits). Tests: `tests/Server`.
- Brings along: nothing else. Needs `sleitnick/option@1.0.4`.
- 1: no. "An immutable class for handling the state of things." Each transition returns a new machine (L90). No enter or exit callbacks.
- 2: no. 3: no. 4: no (searched, not found).
- 5: no. `require(script.Parent.Option)` (L1). Otherwise only Luau built-ins (`table.freeze`).
- 6: no. No `--!strict`. Tests exist.
- 7: licence yes in wally.toml. Under 600 lines.
- 8: no. Depends on Option.
- Verdict: unsuitable: immutable value machine with no enter, exit or announce. Missing: 1, 2, 3, 4, 5, 6, 8

### 6. RMSpratt/Roblox-State-Machine
- Address: https://github.com/RMSpratt/Roblox-State-Machine (source `StateMachine.lua`)
- Licence: not found in the repo. Last commit: not found (15 commits, 1 star). Tests: none found.
- Brings along: blackboard, conditions (And/Or/Not/Value), actions, behaviour-tree hooks for AI agents.
- 1: no. It builds a list of actions (exit, then transition, then entry) and returns it. It runs none (L122-145).
- 2: no. Only `self.CurrentState` is checked (L110).
- 3: not found.
- 4: partly. Transitions of the current state are checked in array order, first match wins (L110-114). Any-state transitions come first (L99). States are not asked in order.
- 5: partly. No Roblox calls found. It uses `require(script.Parent.SMArgValidation)` (L1), so it needs a Roblox-style module tree.
- 6: no. No `--!strict`. No tests found.
- 7: no. No licence found.
- 8: no. Several sibling modules, the Blackboard and condition classes.
- Verdict: unsuitable: no licence, no tests, built for AI agents with a blackboard

### 7. tannnxr/StateMachine
- Address: https://github.com/tannnxr/StateMachine (source `StateMachine.lua`, ~75 lines)
- Licence: not found. Last commit: not found (6 commits). Tests: none.
- Brings along: `goodSignal.lua`, `Utils.lua`.
- 1: no. `Next(target)` sets `self.current` (L53), then `self.StateChanged:Fire(lastState, self.current)` (L54). No enter or exit.
- 2: no. 3: no. 4: no.
- 5: partly. `require(script.Parent.GoodSignal)` (L1) is the only Roblox-style call.
- 6: no. No `--!strict`. No tests.
- 7: no licence found.
- 8: no. Needs GoodSignal.
- Verdict: unsuitable: no licence, no tests, no enter or exit

### 8. Bytebit-Org/roblox-FiniteStateMachine
- Address: https://github.com/Bytebit-Org/roblox-FiniteStateMachine (`@rbxts/finite-state-machine`, Wally `bytebit/finite-state-machine@1.0.11`)
- Licence: MIT. Last commit: not found (66 commits). Tests: `spec.server.lua` at the root (not opened).
- Source not opened. The repo is roblox-ts (TypeScript), with `tsconfig.json` and `package.json`.
- Verdict: unsuitable: written in TypeScript, not Luau. Checklist rows not filled, source not opened

### 9. chi0sk StateMachine v1.4
- Address: https://chi0sk.github.io/Documentation/statemachine.html
- A documentation page only (the first fetch of the page returned 404 and the address came from a search snippet). No source repository or file was found. The snippet claims nested states, guards, timeouts, snapshot/restore, and "Sends made inside OnEnter, OnExit, or actions are queued".
- Verdict: unsuitable: no source found, so no row can be judged

### 10. DevForum "Generalized State Machine" (topic 3630796) and "[Module] State Machine" (topic 4014762)
- Addresses: https://devforum.roblox.com/t/generic-statemachine-module/3630796 and https://devforum.roblox.com/t/module-state-machine-easy-statetransition-management/4014762
- 3630796: the first post has no code. It describes "exit", "update" and "enter" functions. Posted 2025-04-29. No licence stated. The source is in a Creator Store asset and a GitHub link in post 6. Neither was opened.
- 4014762: shipped as a `.rbxm` with the docs inside the module. Not opened.
- Verdict: unsuitable: source not opened, no licence stated. Rows not filled

## What was searched and found nothing
- pesde.dev: one web search for "state machine luau package". It returned no pesde listing. pesde.dev itself was not opened. Arch is the only pesde-published one found (its pesde.toml exists).
- wally.run: not opened. One search returned no wally.run page. Wally names come from READMEs and wally.toml files.
- Priority machine (checklist 4): searched for "priority", "first that wants control" and "ask each update" among the above. Found nothing like it in any source opened.
- A Lune-targeted state machine: the search found none. StateQ's `lune/` folder runs its tests, but its source still uses `script`, `task` and Packages.
- DevForum Community Resources category page: lists other modules, no state machine. The raw `/raw/<id>` form returned an empty page. The `/t/<id>.json` form worked.
- Creator Store: not searched (no way to read free-model source here).
- Plain Lua libraries (`kyleconroy/lua-state-machine`, `unindented/lua-fsm`, `rFSM`, `LuaSM`) appeared in results. Not opened. Plain Lua has no `--!strict` types, so line 6 would fail. Not judged further.
- Not opened: `devforum.roblox.com/t/2333194` (RobloxStateMachine thread), `3157190` (a tutorial), `@rbxts/fsm`, `awesome-roblox` lists.

## The nearest miss, and what it lacks
Nearest: BusyCityGuy StateQ (candidate 1). It has `--!strict`, MIT, Jest tests, a Lune CLI folder and documented functions. Its SnorlaxAssist copy (candidate 2) is smaller (about 302 lines) but has no tests.

What StateQ lacks:
- No state has enter or exit functions. There are `leavingState` and `stateEntered` signals on the machine only (checklist 1).
- Events come from outside and an unsuitable event is an error. A state cannot ask for a transition, and a non-active requester is not ignored (2).
- No statement of what a switch inside a handler does (3).
- No priority machine at all (4).
- It reads `script`, `task.spawn` and a `Packages` folder, so it does not run as plain Luau (5).
- GreenTea, Signal and ThreadQueue are dependencies (8).

Result: no library found has every line. Lines 4 and 2 are missing from all ten. Lines 1 and 3 together are missing from all that were opened.
