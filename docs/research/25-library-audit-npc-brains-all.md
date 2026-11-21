# NPC brains and pathing: existing libraries (all)
Asked: does any library already do the whole checklist (a deciding part that returns intents, plus a PathfindingService helper)? Searched GitHub search, DevForum, pesde (through a mirror) and the web on 2026-11-21; one reader on Sonnet. Sources were read from raw.githubusercontent.com. GitHub's API ran out of calls part-way, so some trees came from the file pages.

Checklist: 1 plain Luau, runs under lune. 2 only decides. 3 job of steps, interrupted by an urgent need, resumed. 4 cost for a few hundred characters. 5 pathing helper (blocked, failure). 6 types, tests, docs. 7 commercial licence, maintained. 8 no framework.

## Candidates

### 1. pranav-bt/Systems, folders `Bots` and `Pathfinding` (the nearest miss)
Address: https://github.com/pranav-bt/Systems (Bots/src, Pathfinding/src). Licence: none found (no LICENSE, LICENSE.md or LICENSE.txt at the root or in Bots/; the repo page states none). Last commit 2026-10-14. Tests: yes, 25 Lune suites for the repo, run through a Roblox shim (README "Testing"); the README says Perception, TacticalQuery, HTN, Placement and Units have no suite. Brings along: Blackboard sensors, group boards, Tokens (squad slots), a Brain scheduler with a frame budget, tracing, an HTN planner, Perception, TacticalQuery, 11 other packages.
- 1 yes. Planner.luau line 3: "Pure logic -- no clocks, no scheduling, no Roblox instance APIs". Brain.luau line 514 `game:GetService("RunService")` sits inside the optional `Brain.start`; `Brain.tick`/`Brain.step` take an injected `now`. Modules load by `script.Parent` requires, so lune needs the repo's shim.
- 2 yes. Bots/README.md: "There is deliberately no movement code in this package". Actions drive `bot.body`; they return "Running"/"Success"/"Failure". Intents are what an action calls on the body, not returned values.
- 3 partly. Interrupt yes: Planner header "a challenger must beat that product to interrupt"; the running action exits with "Interrupted". Resume no: `begin` (Planner.luau line 292) sets `actionIndex = 1`, so a re-adopted job restarts at its first action.
- 4 yes. Brain README: "100 bots at 0.2s is ~8 steps every frame". Each step loops over the bot's goals calling `canRun` and `score` (Planner.luau `selectBest`, line 78). `Brain.step` stops at a budget measured with `os.clock()` (Brain.luau lines 361-407). Tracing allocates nothing when off.
- 5 yes, in Pathfinding/src/PathAgent.luau (separate package). Line 28 `PathfindingService`; line 326 `path:ComputeAsync(from, to)`; line 239 `status = "Unreachable"`; line 459 `status = "Stuck"`. Recomputes on a timer (`repathInterval`, 3.0 s), goal drift and stall. It does not use the `Blocked` event (no match in the file). Calls `humanoid:MoveTo`, so it moves the body, in its own file.
- 6 types and docs yes (`--!strict` on every Bots file; READMEs and a header spec in Planner.luau). Tests yes.
- 7 no: no licence, so no right to use it. Maintained: last commit 2026-10-14.
- 8 yes. The Brain is a singleton scheduler but needs no framework and no ECS.
Verdict: missing: 3, 7.

### 2. thefnox/btree (pesde `thefnox/btree` 0.2.2)
Address: https://github.com/thefnox/btree (lib/behaviorTree/behaviorTree.lua). Licence: LICENSE file is Apache-2.0; pesde.toml says MIT. Both allow commercial use; the mismatch should be asked about. Last commit 2026-11-03. Tests: yes, tiniest specs run with Lune (test/test_main.luau, `require("@lune/task")`). Brings along: debug snapshots, six RemoteEvents for a Studio viewer, serialization of the blackboard.
- 1 yes for the core. behaviorTree.lua has no `game`, `GetService` or `task.` (grepped); init.lua line 26 `game:GetService("CollectionService")` belongs to the debug wrapper. Tests require the core file directly.
- 2 yes. Tasks are modules that read and write a blackboard; nothing moves a Humanoid. It returns a status, not an intent object.
- 3 partly. Selector keeps its running child (line 777 `if status == RUNNING ... return RUNNING`), so a later child that is running is not preempted by an earlier one turning true. Interrupting means a parallel guard or `tree:reset()` ("Interrupts any tasks active ... then resets the tree"). After a reset the tree restarts at the root.
- 4 yes. `update` walks from the root down the active branch only, using flat arrays, then loops over nodes reached last tick for `onExit` (lines 1230-1260). A task's `run` may yield (line 687), so ticks must run in a task.
- 5 no. Not a pathing library.
- 6 types yes (`--!strict`), tests yes, README documents the API.
- 7 yes. Maintained.
- 8 yes.
Verdict: missing: 3, 5.

### 3. Axp3cter/Arbor (Wally `axp3cter/arbor` 2.1.0)
Address: https://github.com/Axp3cter/Arbor. Licence: MIT in wally.toml and package.json; no LICENSE file in the repo. Last commit 2026-03-23. Tests: yes (test/ folder, Roblox runner `Run.server.luau`, own `Runner.luau`). Brings along: decorators, snapshots, a Heartbeat runner, roblox-ts types.
- 1 no. src/core/Context.luau line 5 `local RunService = game:GetService("RunService")` at module top, loaded by every tree. Requires use `script.`.
- 2 yes for the tree; the README example moves the agent with `PivotTo` inside actions.
- 3 partly. Select.luau header: "Re-evaluates from child 1 every tick for priority checking", and it halts the previous branch. Sequence resumes "from the last running child", but a halted sequence clears its index (`state[node] = nil`), so the job restarts.
- 4 yes. `Context.tick` runs the root once; Heartbeat runner is capped by `MAX_CATCHUP = 4`.
- 5 no.
- 6 types yes, tests yes (Roblox-run), README API reference.
- 7 licence yes by the manifest only; maintained.
- 8 yes.
Verdict: missing: 1, 3, 5.

### 4. SimplePath (ahmicy/simplepath, moved from 00xima/SimplePath)
Address: https://github.com/ahmicy/simplepath (src/SimplePath.lua). Licence: MIT (LICENSE; header line 7). Last commit 2026-06-12. Tests: src/SimplePath.spec.lua (TestEZ, needs a Dummy model in Studio). Changelog newest entry v2.2.1 (2022).
- 1-4: not a brain. 1 no (line 22 `PathfindingService`); 2 no, it calls `humanoid:MoveTo` itself (line 338); 3 no; 4 not stated.
- 5 mostly. Line 212 `CreatePath`, line 295 `ComputeAsync`. Blocked: the `Blocked` handler jumps and fires a `Blocked` event (line 227-230); the caller recomputes. Failure: `ComputationError`, `TargetUnreachable`, `AgentStuck` events (lines 32-36, 180). Repeated `Run` is the intended way to recompute.
- 6 untyped (no `--!` line), docs yes (docs/api-reference.md), tests yes. 7 yes. 8 yes.
Verdict: missing: 1, 2, 3, 4 (pathing only); line 5 yes except automatic recompute on blocked.

### 5. nsawill1405/Pathfinding-Plus (Wally `nsawill1405/pathfinding-plus` 0.1.0)
Address: https://github.com/nsawill1405/Pathfinding-Plus (src/Planner, src/Navigator). Licence: MIT (LICENSE, 2026). Last commit 2026-11-20 (new, v0.1.0). Tests: test/run.luau, six specs, run with Lune (README). Brings along: Coordinator (shared compute budget, staggered repaths, spacing), Janitor and Signal copies.
- 1-4: not a brain. Planner/init.luau line 1 uses `game:GetService("PathfindingService")`; Navigator calls `self._humanoid:MoveTo` (line 336) in a separate folder from the Planner.
- 5 yes. Navigator/init.luau lines 297-304: `rawPath.Blocked:Connect(...)` sets `replanReason = "BlockedAhead"` for waypoints ahead only; lines 420-425: when `replanCount > maxReplans` it calls `_finishRun(run, "Failed", ...)`; `Stuck` and `Failed` signals (lines 30-33). Compute is wrapped in `pcall` (Planner line 61).
- 6 partly typed (src/Types.luau has 3 `export type`, rest is plain), tests yes, README yes. 7 yes; too new to judge upkeep. 8 yes.
Verdict: missing: 1, 2, 3, 4 (pathing only); line 5 has everything.

### 6. birds3345/BehaviorTree
Address: https://github.com/birds3345/BehaviorTree. Licence: MIT. Last commit 2026-07-01. Tests: none seen (root: src, README, LICENSE, default.project.json). Brings along: nothing.
- 1 partly: no Roblox call in the files read (Tree, Selector, Sequence, Action, Types), but requires use `script.Parent`, and `typeof` is used.
- 2 yes.
- 3 partly. Tree.luau `evaluate` re-walks from the root each call and calls `_finish` on actions no longer active; Selector.luau tries children in order every time. Interrupt yes; resume has to be rebuilt from blackboard conditions.
- 4: allocates `newActiveActions = {}` on each evaluate (Tree.luau line 9-10).
- 5 no. 6 types yes (generics), tests no, docs: one README example. 7 licence yes; 3 commits, small. 8 yes.
Verdict: missing: 1, 5, 6.

### 7. umamidayo/BehaviorTree
Address: https://github.com/umamidayo/BehaviorTree. Licence: MIT. Last commit 2026-02-05. Tests: none seen. README: "won't actively maintain".
- 1 partly (no Roblox call in Tree, Node, Selector, Action; `script.Parent` requires). 2 yes. 3 no: Selector.luau keeps `currentIndex` on a running child and never re-checks earlier children. 4 not stated. 5 no. 6 partly typed, no tests. 7 yes, unmaintained by the author's word. 8 yes.
Verdict: missing: 3, 5, 6.

### 8. kietelmuis/simpletree
Address: https://github.com/kietelmuis/simpletree. Licence: none found. Last commit 2025-12-13. Tests: `test.luau`, a demo script. `.luaurc` sets strict.
- 1 yes: `require("./tree")` relative paths, no Roblox call in tree.luau, selector.luau. 2 yes. 3 no: Selector keeps `_index` while a child is RUNNING. 5 no. 6 typed; no real tests; readme is one line. 7 no licence. 8 yes.
Verdict: missing: 3, 5, 6, 7.

### 9. Fangous/RbxBehaviorTree (Wally)
Address: https://github.com/Fangous/RbxBehaviorTree. Licence: MIT. Last commit 2025-03-03. Tests: none seen.
Verdict: unsuitable: src/init.lua line 8 `game:GetService("RunService")` and it ticks itself on `RunService.Heartbeat` (line 146); no tests; the single file cannot run under lune.

### 10. Defaultio/BehaviorTree3
Address: https://github.com/Defaultio/BehaviorTree3. Licence: GPL-3.0. Last commit 2024-02-10.
Verdict: unsuitable: GPL-3.0 does not fit a commercial game; line 66 `game:GetService("RunService")` at module top; no tests in the repo.

### 11. rwilliaise/goap
Address: https://github.com/rwilliaise/goap. Licence: package.json "MIT"; GitHub shows none. Last commit 2024-02-24. Tests: none.
Verdict: unsuitable: roblox-ts (TypeScript) port of a Unity library; `Agent` takes a `Model` and has a `RunningState.MOVING` (src/agent.ts), so it moves the body.

### 12. RMSpratt/Roblox-State-Machine
Address: https://github.com/RMSpratt/Roblox-State-Machine. Licence: none found. Last commit 2024-03-02. No Roblox call matched in StateMachine, State, Action, Blackboard (grep only; not read in full). No tests seen. Not checked against 3.
Verdict: unsuitable: no licence, no tests, no pathing.

### 13. Others opened but small or out of scope
- GuaveTree/NPC-AI (MIT): one file, "My first try". Verdict: unsuitable: one demo module, no tests.
- spavdigital/roblox-npc-ai (MIT): Patrol/Chase/Attack demo; README says chase follows `waypoints[2]`. Verdict: unsuitable: a demo that moves Humanoids.
- zleodai/CompyAgents: GOAP agents; README: no project licence; needs SPEARHEAD and other assets. Verdict: unsuitable: no licence, a game slice.
- Aerodymier/Pathfinder (MIT, Wally): wraps PathfindingService, `GetState`, `OnPathCompleted`; no tests seen. Source not opened. Line 5 not judged.
- TreeAI (DevForum 4034006): Creator Store models only, no licence stated, source not opened. Verdict: unsuitable: no source and no licence.

## What was searched and found nothing
- A Luau utility-AI or GOAP library that is pure Luau: GitHub search "utility ai language:Luau" and "goap language:Luau" gave only pranav-bt/Systems and zleodai/CompyAgents (above).
- wally.run: the web search returned no page; wally.run was not opened. pesde.dev: not opened; the pesde package page for thefnox/btree was read through a mirror (lukadev-pesde.pages.dev).
- DevForum Community Resources: BehaviorTree2 post (60302) returned an empty page through /raw/. TreeAI's .json page was read. SimplePath, NoobPath, SuperPath, ProPath, PathManager, PathfindingModule threads were seen only as search results, not opened.
- NoobPath: no GitHub repo found; its source is a Creator Store model, not opened. A copy sits inside zleodai/CompyAgents, not opened.
- herfavesenpai/BehaviorTree2: the API call said "Moved Permanently"; not opened.
- Not opened: Fangous/RbxBehaviorTreeVisualizer, elcapykkzxd/NavPathX, g0ofycat/PathfindingModule, ProtonDev-sys/StridePath, Daemon6109/AStarPathfinding, Ali-lov3/Custom-PathfindingService (these replace PathfindingService with their own A*, so they do not fit line 5), awesome-roblox lists, Roblox Creator Store free-model search.

## The nearest miss, and what it lacks
The nearest miss is pranav-bt/Systems: Bots (decider) with Pathfinding (PathAgent). It passes 1, 2, 4, 5, 6 and 8, and its Planner is a utility chooser with interrupts that fits "a job made of steps, interrupted by a need".
It lacks:
- 7: no licence file anywhere in the repo. Without one the code cannot be used in a game. The author could add one, and that is a question for them, not a thing to assume.
- 3, resume: an interrupted job restarts at action 1 (Planner.luau line 292). To resume at the step, the job's progress has to live on the blackboard and each action has to skip finished work.
- It brings a singleton Brain, sensors, group boards, tokens and 11 other packages the job did not ask for.
- PathAgent does not use the `Blocked` event; it recomputes by timer, goal drift and stall.
The best pathing helper is nsawill1405/Pathfinding-Plus (Blocked replans, `maxReplans`, `Failed`), which has the licence but is v0.1.0 and a day old at the last commit.
The best licensed decider is thefnox/btree, which lacks the preempting selector (3) and pathing.
No single library has everything.
