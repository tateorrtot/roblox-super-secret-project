# State machines: existing libraries, and whether to use one
Asked: does a library exist with all 8 checklist lines for an explicit machine and a priority machine in plain Luau, so we can use it instead of writing our own.
Made from `25-library-audit-state-machine-all.md` (one reader), then this skeptic reading, on 2026-11-21, all on Sonnet. Source was read with `curl` on raw.githubusercontent.com and page fetches. Nothing was downloaded or run.

## The answer
**Write our own.**
- Line 4: no library found has a machine where each state is asked every update whether it wants control. Felix's "Priority" is a number a transition must beat (`src/init.luau`, `Send` doc). Priority (HighFlowey) ranks states, but it is `--!nocheck`, needs `sleitnick/signal` and sets Humanoid properties (lines 8, 5).
- Line 3: Felix queues a `Send` made inside a callback, so both switches run and both are announced (`Finish` calls `machine.StateChanged:Fire` per transition). We want only the final one announced. The "deferred from exit" half is met by Felix; the "only final announced" half is not.
- Line 2: every library takes the trigger from outside. None knows who asked, so none can ignore a request from a state that is not active.
- Line 1: the libraries that run enter and exit (Felix, Zarch, Arch) do not all announce. Zarch has no announce at all. StateQ and SnorlaxAssist announce but have no per-state enter or exit.
- Lines 5, 6, 8 together: only Felix and Zarch have no dependency. Felix has two `--!nocheck` files and is about 2,200 lines (line 7 passes because it is maintained). Zarch has no `--!strict` problem but fails 1 to 4.
- Nearest miss: Felix (3B-6/Felix). Misses 2, 3, 4, and part of 6.

## Each candidate, after the second reading
Last commit dates come from each repo's `commits` atom feed. "Fails" is the checklist lines that fail by this reading.

| Name | Address | Licence | Last commit | Fails | What was wrong in the first reading |
|---|---|---|---|---|---|
| Felix 3b-6/felix 0.1.1 | https://github.com/3B-6/Felix | MIT (`LICENSE`) | 2026-11-17 | 2, 3, 4, 6 (partly) | Missed by the readers. Not in their list at all. |
| StateQ BusyCityGuy | https://github.com/BusyCityGuy/finite-state-machine-luau | MIT | 2026-06-20 | 1, 2, 3, 4, 5, 8 | Held. Line numbers were off by one to two (`require` at 127-129, `task.spawn(error` at 474). |
| SnorlaxAssist | https://github.com/SnorlaxAssist/finite-state-machine-luau | MIT | 2023-12-15 | 1, 2, 3, 4, 5, 8; tests not found | Held. A page fetch said line 1 was `---`, but `curl` shows `--!strict` on line 1. Reader was right. Test files: none found, not proven absent. |
| Arch bohraz | https://github.com/bohraz/arch | MIT | 2025-02-20 | 2, 3, 4, 5, 6, 8; 1 partly | Row 1 was "not found". `Transition.luau` 304-306 runs `exitStates`, transition content, `enterStates` in that order. No announce signal was found there. `Transition.luau` line 1 is a `require`, no `--!strict`. |
| Zarch zarchify | https://github.com/zarchify/zarch | MIT (wally.toml) | 2026-04-01 | 1, 2, 3, 4; 6 partly | Missed by the readers. `machine.luau:205` `send` runs exit, then `on_entry`. No signal, no re-entrancy guard. `--!strict` on 1; dev dependency `testez`; no test folder seen. About 350 lines in `init.luau` and `machine.luau`. |
| Motix `StateMachine` Vel136 | https://github.com/Vel136/Motix | MIT | 2026-04-04 (1 commit) | 1, 2, 3, 4, 5, 6 | Missed by the readers. `Modules/StateMachine.lua` is 147 lines: line 1 `require(script.Parent.Parent.Core.Types)`, `os.clock()` in `_DoTransition`, one `_OnStateChange` callback, no `--!strict`. `RequestTransition(ToState, Priority)` queues from anyone. Part of an animation library. |
| Priority HighFlowey/FlowAshley | https://github.com/FlowAshley/Priority | MIT | 2024-06-10 | 4 (partly), 5, 6, 8 | Missed by the readers. `src/Statemachine.lua` line 1 is `--!nocheck`, line 2 requires `Signal`; wally.toml needs `sleitnick/signal`; it applies Humanoid properties. States are ranked by priority, not asked to want control. Marked deprecated in the README. |
| OverlineJunior | https://github.com/OverlineJunior/state-machine | MIT in wally.toml | not found | 1 to 6, 8 | Dismissal not rechecked. |
| prooheckcp RobloxStateMachine | https://github.com/prooheckcp/RobloxStateMachine | MIT | not found | 1 to 6, 8 | Not rechecked. |
| RMSpratt | https://github.com/RMSpratt/Roblox-State-Machine | not found | not found | 1, 2, 3, 6, 7, 8 | Not rechecked. |
| tannnxr | https://github.com/tannnxr/StateMachine | not found | not found | 1, 2, 4, 6, 7, 8 | Not rechecked. |
| Bytebit roblox-FiniteStateMachine | https://github.com/Bytebit-Org/roblox-FiniteStateMachine | MIT | 2023-11-03 | 1, 2, 3, 4, 5, 6, 8 | "Source not opened" is now fixed. `src/classes/FiniteStateMachine.ts` is TypeScript, 89 lines. `handleEvent` sets `currentState` and fires `stateChanged`: no enter or exit (lines 78-81). It imports `@rbxts/bin` and `@rbxts/signals-tooling` (lines 1-2). An unlisted event throws (line 75). The dismissal holds. |
| chi0sk StateMachine | https://chi0sk.github.io/Documentation/statemachine.html | not found | not found | not judged | Not rechecked. No source found. |
| DevForum Priority3 / [Module] State Machine / Generalized | topics 2491553, 4014762, 3630796 | none stated | 2023-07 (Priority3 post) | not judged | Priority3 is the same module as Priority above (README: deprecated for "priority 5"). The other two were not opened. |
| nightcycle/finite-state-machine | https://github.com/nightcycle/finite-state-machine | Apache-2.0 (page) | 2024-06-10 | not judged | Missed by the readers. Found on Wally; source not opened. |
| TheDynamicGit/Finite-State-Machine | https://github.com/TheDynamicGit/Finite-State-Machine | not found | 2025-10-03 | not judged | Missed by the readers. "hooks, guards" in its title. Source not opened. |

## What our own library should take from these
- Order exit, then transition effects, then enter, then announce. Felix `EnterTransition` comment: "Exit -> Effects -> Enter". https://github.com/3B-6/Felix
- Make an unknown trigger return `false` and fire a `Rejected` signal with the reason, instead of throwing. Felix `Send`. StateQ and Bytebit throw, which is a worse default (`FiniteStateMachine.ts:75`).
- Check the whole machine when it starts: missing target, two states with one name, no default. Felix `Start` lists each error. https://github.com/3B-6/Felix
- Fall back to plain coroutines when `task` is absent: `typeof(task) == "table"`. Felix `src/util/env.luau`. We should pass no thread helper in at all.
- Time in state comes from `Update(dt)`, not a clock. Felix `machine.Clock`. Motix reads `os.clock()` (`StateMachine.lua`), which line 5 forbids.
- Hand the machine to every callback as the first argument: `on_exit(machine, ...)`. Felix `ExitOne` and `EnterOne`.
- Keep the file small. Zarch is about 350 lines for exit, enter and guards. https://github.com/zarchify/zarch
- Run the tests under Lune. Felix has `lune/test.luau` calling `tests/*.spec.luau`. https://github.com/3B-6/Felix

## What was not checked
- Felix: `src/init.luau` was read only where grep and the transition and `Send` sections pointed. The `Update` and `Clock` code was not read. Whether its Lune tests pass was not run. `src/util/signal.luau` is `--!nocheck` (line 1); its Roblox use beyond `task` was not read.
- Test files of StateQ, SnorlaxAssist, Arch and Zarch were not opened. Zarch's test folder was not found.
- OverlineJunior, RobloxStateMachine, RMSpratt, tannnxr, chi0sk, and the two other DevForum modules were not rechecked.
- nightcycle/finite-state-machine and TheDynamicGit/Finite-State-Machine were found late. Their source was not opened.
- The Wally registry search (api.wally.run, queries "state", "machine", "fsm", "statemachine", "finite") listed about 40 state-machine-like packages. Only those with a repo found were read. Others (`jaeymo/finite-state-machine`, `hgta1287dev/guarded-state-machine`, `herilfiu/luau-hfsm`, `ocipa/tiny-fsm`, `cosinewaves/flux`, `itzmrratsp/jinx`, `denispionicul/stater`, `nightcycle/fsm`) were not opened; some repo guesses returned 404.
- The pesde registry returned nothing for "state". It was not searched further. The Creator Store and awesome-roblox lists were not searched.
- GitHub's API was rate limited, so commit counts and file sizes come from page fetches and `curl | wc -l`.
