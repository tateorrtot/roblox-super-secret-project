# NPC brains and pathing: existing libraries, and whether to use one
Asked: does a library already do the whole checklist for an NPC's deciding part and a `PathfindingService` helper? Made from `25-library-audit-npc-brains-all.md` (one reader), then this skeptic, 2026-11-21, all on Sonnet.

## The answer
**Write our own.**
- No candidate passes 3 (a job of steps, interrupted by an urgent need, then resumed). The nearest, pranav-bt/Systems, restarts a re-adopted job at action 1 (`Planner.luau`: `actionIndex = 1`).
- Line 2 fails for pranav-bt/Systems as well: its Planner returns nothing and calls each action's `enter`, `update` and `exit` hooks with `bot` (second reading). Our rule is that the decider returns intents.
- Line 7 fails for pranav-bt/Systems (no licence page shown) and for kietelmuis/simpletree, RMSpratt and red-shock/behaviour-tree (no licence found); GPL-3.0 rules out Defaultio/BehaviorTree3.
- The licensed trees (thefnox/btree, Arbor, birds3345, umamidayo) all keep a running child in a selector or lack tests; none has 3. thefnox/btree's `selector` loops from `activeChildIndex` and never re-checks earlier children (line 3).
- For the pathing helper (5) nsawill1405/Pathfinding-Plus is the only one with everything: `Blocked` replans, `maxReplans`, a `Failed` signal. It is v0.1.0, one day old at its last commit, and it moves the body in its own file. Take it as a model, or wrap it later (5, 7).
- No candidate is a pure-Luau decider that returns intents and is tested under `lune` (1, 2, 6). Pathing and deciding stay two libraries.

## Each candidate, after the second reading
Last commit dates are the first reader's. The pages I opened showed commit counts, not dates.

| Name | Address | Licence | Last commit | Fails | What was wrong in the first reading |
|---|---|---|---|---|---|
| pranav-bt/Systems (Bots, Pathfinding) | https://github.com/pranav-bt/Systems | none shown on the page | 2026-10-14 (first reader) | 2, 3, 7; 5 only partly | Line 2 was marked yes. Planner returns nothing and calls hooks (`callHook`, `runExit`). Tests: the only suite that names Bots is `test-bots-blackboard.luau`; none names Planner. PathAgent's loop is `while running do` with no attempt counter, so it never gives up: `Unreachable` and `Stuck` are statuses read with `GetStatus`, and the loop retries. Line 1 held: `game:GetService` is inside `defaultDriver()` only; requires use `script.Parent`, so `lune` needs the repo shim. |
| thefnox/btree | https://github.com/thefnox/btree | LICENSE file shown as Apache-2.0, README says MIT | 2026-11-03 (first reader) | 3, 5 | Held. Core has no `game`, `GetService`, `task.` or `typeof`. Selector has no re-check option. `reset` "reevaluates from the root" after interrupting tasks, so a job restarts. Has `.lune`, tests and `.luaurc`. Licence mismatch still open. |
| Axp3cter/Arbor | https://github.com/Axp3cter/Arbor | MIT by manifest, no LICENSE file | 2026-03-23 | 1, 3, 5 | Not reopened. |
| ahmicy/simplepath | https://github.com/ahmicy/simplepath | MIT | 2026-06-12 | 1, 2, 3, 4 (pathing only) | Not reopened. |
| nsawill1405/Pathfinding-Plus | https://github.com/nsawill1405/Pathfinding-Plus | MIT | 2026-11-20 | 1, 2, 3, 4 (pathing only); 5 holds | Line 5 held in `Navigator/init.luau`: `rawPath.Blocked:Connect(`, `maxReplans = 4,`, `if run.replanCount > self._options.maxReplans then`, `self.Failed:Fire(`. Correction: the Navigator has no `pcall` (the first reader's `pcall` was in the Planner file). The replan count only counts failed attempts, so a slow run that keeps progressing is not cut off. |
| birds3345/BehaviorTree | https://github.com/birds3345/BehaviorTree | MIT | 2026-07-01 | 1, 5, 6 | Not reopened. |
| umamidayo/BehaviorTree | https://github.com/umamidayo/BehaviorTree | MIT | 2026-02-05 | 3, 5, 6 | Not reopened. |
| kietelmuis/simpletree | https://github.com/kietelmuis/simpletree | none found | 2025-12-13 | 3, 5, 6, 7 | Not reopened. |
| Fangous/RbxBehaviorTree | https://github.com/Fangous/RbxBehaviorTree | MIT | 2025-03-03 | 1, 6 | Not reopened. |
| Defaultio/BehaviorTree3 | https://github.com/Defaultio/BehaviorTree3 | GPL-3.0 | 2024-02-10 | 1, 6, 7 | Not reopened. |
| rwilliaise/goap | https://github.com/rwilliaise/goap | package.json says MIT, GitHub none | 2024-02-24 | 1, 2, 6, 7 | Not reopened. roblox-ts. |
| RMSpratt/Roblox-State-Machine | https://github.com/RMSpratt/Roblox-State-Machine | none shown | 2024-03-02 (first reader) | 3, 5, 6, 7 | Dismissal held, now from source. `StateMachine.lua` has no `game`, `GetService`, `task.` or `typeof`, and requires `script.Parent`. `AnyStateTransitions` can preempt, but a transition overwrites `CurrentState`, with no history, so no resume. README lists no tests and no pathing. The first reader's "not checked against 3" is now checked: fails 3. |
| Aerodymier/Pathfinder | https://github.com/Aerodymier/Pathfinder | MIT (`LICENSE.md`) | not shown (98 commits) | 1, 2, 3, 4 (pathing only) | Page opened, source not. README lists `OnPathBlocked`, `OnPathCompleted`, `GetState()` of `Move` or `Idle`, config `MoveFunction` and `JumpFunction`. No test folder listed. Line 5: no failure event, no replan limit in the README. Dismissal holds, but line 5 is "fails" rather than "not judged". |
| red-shock/behaviour-tree (new) | https://github.com/red-shock/behaviour-tree | none shown | not shown (26 commits) | 1, 3, 5, 7 | Missed by the readers. `BehaviourTree/Tree.luau` has `local RunService = game:GetService("RunService")` and `Instance.new("BindableEvent")`, no `--!strict`, requires by `script.Parent`. `ControlNode.luau` `_runFallback` loops from the first child every tick, so it preempts, but there is no resume. Tests run through Rojo `test.project.json` in Studio. |
| GuaveTree/NPC-AI, spavdigital/roblox-npc-ai, zleodai/CompyAgents | https://github.com/GuaveTree/NPC-AI, https://github.com/spavdigital/roblox-npc-ai, https://github.com/zleodai/CompyAgents | MIT, MIT, none | not checked | demos | Not reopened. |
| TreeAI (DevForum 4034006) | https://devforum.roblox.com/t/treeai-easily-create-behavior-trees-for-your-npcs/4034006 | none stated | not checked | no source | Not reopened. |

## What our own library should take from these
- Interrupt by challenger score: a running job is displaced only if the challenger beats its score, and the running step exits with "Interrupted" (pranav-bt/Systems, `Bots/src/Planner.luau`, https://github.com/pranav-bt/Systems). Take the rule. Keep the progress, which it drops.
- Inject the clock and the random source: `Brain.tick` and `Brain.step` take `now`, with `Rng` and `Clock` as modules (same repo, `Bots/src/Brain.luau`). This is what makes a decider testable under `lune`.
- Budget by time per frame, checked after a step so one character always moves (`Brain.drain`, same file). The README figure is 100 bots at 0.2 s is about 8 steps a frame.
- Keep the engine call in a driver function, not at module top (`defaultDriver()` in `Brain.luau`).
- Pathing: replan on `Blocked` only for waypoints ahead, count replans, fail after a limit, with a `Failed` signal and a `Stuck` signal (nsawill1405/Pathfinding-Plus, `src/Navigator/init.luau`, https://github.com/nsawill1405/Pathfinding-Plus).
- Time out each waypoint (`moveTimeout`, 3 s) so no character waits for ever at one waypoint (same file).
- A tree that ticks only the active branch with reused tables, and a snapshot for a debug viewer (thefnox/btree, `lib/behaviorTree/behaviorTree.lua`, https://github.com/thefnox/btree).
- A `reset` that fires the cleanup hook of each active task before restarting (same file). Our interrupt needs the same hook.

## What was not checked
- Last commit dates for pranav-bt/Systems, thefnox/btree, RMSpratt, Aerodymier and red-shock: the pages showed counts only. The first reader's dates stand.
- Whether pranav-bt/Systems has a LICENSE file: the root listing shows none, but the page said "View all files". Not checked in the API.
- The licence text in thefnox/btree (Apache-2.0 against MIT): not opened.
- Source of Axp3cter/Arbor, SimplePath, birds3345, umamidayo, kietelmuis, Fangous, Defaultio, rwilliaise: not opened in the second reading.
- Source of Aerodymier/Pathfinder and TreeAI: not opened.
- The bodies of `Planner.luau` past the quoted lines, and whether pranav-bt/Systems tests reach Planner through the archetype suites: not opened.
- wally.run, pesde.dev search pages, awesome-roblox lists, the Creator Store: not opened. One extra web search over wally.run, pesde.dev and github.com found only red-shock/behaviour-tree as new.
- No library was downloaded or run. Cost per update (4) was judged from source for pranav-bt/Systems, thefnox/btree and Arbor only.
