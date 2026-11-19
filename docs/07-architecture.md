# Architecture (draft 5)

Draft 5, 2026-11-18.

**Status: reference notes. Nothing here needs a signature, and this is not the plan.** After this draft was written, the user asked why the whole architecture was being designed at once when small reusable pieces could be made, reviewed and iterated on one at a time. The work now goes that way, and CLAUDE.md has the list of pieces.

What stays in force from this note is small:
- dependencies go one way, and the game's rules never require the Roblox glue;
- the game's rules are pure Luau with no Roblox calls (A6).

The six directories of A1 are not in use. Since 2026-11-19 the code is laid out as `src/shared` (the rules), `src/server` and `src/client`, grouped by game concept inside each, with tests in `tests/`. CLAUDE.md has the current layout and the code conventions.

Part B is a set of ideas to consult when a piece needs them. The kernel in B1 is not built unless two real pieces need it. Parts C and D are superseded as a plan and kept as a list of open questions. A check of this draft against its own fix list was stopped unfinished, and none of it is checked against code, so expect contradictions in Part B and expect all of it to go stale.

## Where this stands

| Draft | Review | Result |
|---|---|---|
| 2 | Three reviewers, then a referee on each serious finding | All refused. About 45 findings upheld, three blocking. [09-architecture-review-draft2.md](09-architecture-review-draft2.md) |
| 3 | The same lenses checking each finding was closed, plus a cold reader | All four declined. The cold reader found 37 problems. [10-architecture-review-draft3.md](10-architecture-review-draft3.md) |
| 4 | A sign-off reader, a closure check, and a check of every platform claim | 87 of 96 platform claims confirmed and none that blocks. The closure checker: "close", five fixes needed. The sign-off reader: would sign the shape, not the rules mechanism |
| 5 | **None, on purpose** | This document |

Across all three rounds no reviewer found a reason to change the shape. What failed each time was mechanism described only on paper. The last checker's advice was: "do not run a fifth paper round. Make the sentence fixes, then prove the mechanism in step 2b with two made-up features." This draft does that. It makes the fixes, and it stops asking for a signature on anything code has not tested.

## What draft 5 asked the user to sign (superseded: nothing is asked now)

| | Sections | Tested or decided at |
|---|---|---|
| **Sign now: the shape** | Part A: the six directories, where they live in Roblox, definitions as validated rows, the checks, what is not code | Two items depend on step 0b and say so |
| **Working design: not for signature yet** | Part B: the kernel and how features interact; how state reaches the screen; saving | The kernel at step 2b, in code; the screen at steps 3a to 4f; saving at step 7a |
| **Plan** | Part C: features, modules, steps | Corrected by each step |
| **The user's decisions** | Part D: game rules and approvals | Each names the step that needs it |

Approving Part A lets steps 0a to 2b go ahead. Steps 0a to 2a build only what Part A covers. Step 2b is the experiment on Part B's kernel: small, tested with two made-up features, and revised or thrown away if it shows the mechanism is wrong. After 2b I revise Part B from what the code showed and bring it back.

Sources: [08-architecture-grounding.md](08-architecture-grounding.md), and Appendix B for facts the reviewers added.

It follows the user's FoxFabric library (small modules with one job, composed by design, no framework, add don't overwrite), Godot's best practices for engine contributors (a problem must exist before it is solved; prefer local solutions) and contribution rules (one change at a time), and the user's own rules (visuals are not tied to logic; keep it consistent; any feature can be added later).

---

# Part A: the shape (for signature)

## A1. Six directories, one direction

```
src/
  lib/        small pure helpers, one job each          requires: nothing outside lib
  content/    data rows                                 requires: nothing
  protocol/   types and names shared by both sides      requires: nothing
  rules/      this game's rules: a kernel and features  requires: lib, protocol
  server/     Roblox glue on the server                 requires: rules, lib, content, protocol
  client/     Roblox glue on the client                 requires: lib, content, protocol
tests/        specs and the test harness (never shipped)
tools/        the check scripts
```

```
  server ---> rules ---> lib <--- client
     |          |                   |
     |          +---> protocol <----+
     |                              |
     +-------> content <------------+
     (server also requires lib and protocol directly)
```

| Directory | May require | Must never require |
|---|---|---|
| `lib` | Other `lib` modules | Anything else; any Roblox global |
| `content` | Nothing | Anything |
| `protocol` | Nothing | Anything |
| `rules` | `lib`, `protocol` | `content`, `server`, `client`; any Roblox global |
| `server` | `rules`, `lib`, `content`, `protocol` | `client` |
| `client` | `lib`, `content`, `protocol` | `rules`, `server` |

Finer rules. The checks in A4 enforce every one of these:
- **Inside `rules`:** the kernel requires `lib` and the shared file in `protocol`, and never a feature. A feature requires `lib`, the kernel, features listed before it, and only its own file in `protocol`.
- **Inside `server` and `client`:** a feature's directory may require the shared modules of its side, `lib`, `content`, its own file in `protocol`, the directories of features listed before it, and, on the server, its own and earlier features in `rules`. It never requires a later feature's directory.
- **A shared module never requires a feature's directory.** Only the entry script does.
- **`server/pure` and `client/pure` hold glue that uses no Roblox global,** so the purity checks and the tests cover it. The order of things when a player joins and leaves goes there.
- **No cycles.** In Roblox a require cycle raises no error: the thread hangs. The edge check is what forbids them.
- **No `init.luau` files.** A directory is always a Folder and a module is always a file.
- The rules directory is called `rules`, not `game`, because `game` is Roblox's global for the whole data model.

`rules` never requires `content`: rules need the *shape* of a definition, never a particular one. The server's entry script loads `content` and hands it in. In Godot terms, `rules` holds the `Resource` class scripts and `content` is the `.tres` files.

## A2. Where the directories live in Roblox

All six directories use relative requires only (`./` and `../`), the one style Roblox, the test runner and the type checker all accept. In Roblox a relative require is resolved against the *Instance tree*, not the disk, so directories that require each other must be siblings in Roblox exactly as they are on disk.

| What | Roblox location | Visible to |
|---|---|---|
| `lib`, `content`, `protocol`, `rules`, `server` | Siblings under `ServerScriptService` | Server only |
| `lib`, `content`, `protocol` (a second copy of the same files) and `client` | Siblings under `ReplicatedStorage` | Clients |
| Two RemoteEvents | `ReplicatedStorage`, declared in the project file | Both |
| World models, one per definition id | `ReplicatedStorage`, imported in Studio | Both |

- The project file sets `emitLegacyScripts` to false, so the two entry files become Scripts whose run context is Server and Client. Roblox runs a client Script from `ReplicatedStorage` and recommends one entry script per side.
- Rojo 7.7.1 accepts one directory mapped to two places. Three reviewers built it. **Live sync into an open Studio is untested until step 0b.**
- Server code never requires anything under `ReplicatedStorage`, and client code never requires anything under `ServerScriptService`, so one copy is in use on each side.
- Roblox documents that client Scripts in `ReplicatedStorage` run after the game has loaded and can read `ReplicatedStorage` without waiting. The client entry script still begins with a guarded wait for loading, which Roblox staff give as sufficient for string requires. Nothing in the Workspace is covered by that.
- World models sit where both sides can read them, so a placement preview can show the real model and not only a box. Like content, they can then be read out of the game by anyone determined. That is question 9.
- One entry script on each side. Everything else is a ModuleScript that something requires explicitly. No scripts live inside models.

## A3. Definitions

Everything is an item, so there is one table of things. A thing is a row of components, and a component is what makes it placeable, a container or a station. This is RimWorld's definition-with-components pattern. The word is "component" because "part" already means a physical piece in Roblox.

```luau
-- content/Things.luau
return {
	log = { stack = { size = 16 } },
	crate = { stack = { size = 1 }, placeable = { footprint = { 1, 1 } }, container = { slots = 12 } },
}
```

- **Every row has `stack`,** so every thing can be held and dropped.
- **Content requires nothing,** so it cannot name a feature's types, and the type checker never rejects an unknown key.
- **A validator checks every row,** in the tests and at server start. `lib/Defs` is a generic registry. Each feature registers the shape of its components. Unknown keys are rejected, and the error names the row and field.
- **A component's shape and its Luau type sit side by side in that feature's file in `protocol`,** kept in step by hand, because both sides read a component: the rules to apply it, and a client view to draw from it.
- **Each side reads a component through one typed function** that builds it field by field, never by a cast. One test runs every such function over the real content and compares the result key for key with the validated row.
- **Checks that cross rows** ("every recipe a station names exists") are registered by the feature that owns the kind.
- **A definition id is never renamed in place.** The first rename will come with a migration.

## A4. Checks

One command runs all of these before every commit. The vendored library file is excluded from each.

| Check | Covers | Needs |
|---|---|---|
| Format | `src`, `tests`, `tools` | Installed |
| Lint | `src`, `tests`, `tools` | Installed |
| Lint for purity: bans the real clock, the global random source and yielding | `lib`, `content`, `protocol`, `rules`, the two `pure` folders | A rule file in the repo |
| Types with no Roblox globals | The same, and the specs | Installed |
| Types with Roblox definitions and the sourcemap | All of `src` | The definitions file, a download |
| Edges | All of `src` | Lune, a download |
| Tests | `lib`, `rules`, the two `pure` folders | Lune |

- **The edge check takes its graph from `luau-lsp require-graph`,** which is already installed and uses the same resolver as the type check. A small script applies A1's rules to it. The same command draws the graph as a diagram, and that diagram is what gets reviewed with each step. Its output format is marked experimental, so step 0a pins it with a test.
- It also fails on a file name whose case is not exact, and it reads the feature order from `rules/Features.luau` and checks the entry scripts against it.
- **The new Luau type solver is chosen now** and passed explicitly to both type checks. The next luau-lsp release makes it the default, and Roblox has committed to the old one only through 2026. Falling back is a flag.
- luau-lsp accepts some syntax that Studio may not load yet. The tests and Studio decide what loads.
- **Tests are plain scripts** with a small harness kept in the repo, in the style of FoxFabric's `tests.gd`.
- **No package manager, no entity-component library, no networking library.**

## A5. What is not code

**A Studio place file is the source for the map and the models.**
- Rojo syncs code and the two RemoteEvents into it. No part of the tree that holds Studio-made work is given a path in the project file, so a sync never deletes that work.
- **Rojo does not apply the place settings.** Its plugin skips settings it cannot script, without a warning. The Studio place is started once from a build of the project file, which does write them, and a tool fails if the saved place's settings ever differ from the project file's.
- The place file is kept in the repository as a binary. Studio can also save it as text, and a tool exists for readable diffs; the binary form is chosen for size, and map changes are reviewed in Studio. Beside it the place tool commits a text listing of tagged Instances, models by definition id and the settings, so a change can be read.
- **Publishing is done by a script** that runs the checks and then uploads that same file through Roblox's Open Cloud. Nobody publishes from Studio's menu. That is what makes the placeholder check binding. It needs an Open Cloud key from the user before the first publish.

| Thing | Authored in | In git |
|---|---|---|
| The map: terrain, plot spots, zone volumes. Plot spots and zones are tagged, and each carries an attribute naming its definition, read once at server start | Studio | The place file and its listing |
| World models | Blockbench, imported with Studio's 3D Importer. Rojo cannot turn glTF or FBX into Instances | Sources in `assets/`; imported form in the place file |
| Interface | Code | Yes |
| Placeholder assets made by a generator | Studio, tagged, in one folder | The place tool fails before any publish if one remains |

## A6. Invariants of the shape
1. Nothing in `lib`, `content`, `protocol`, `rules` or the two `pure` folders uses a Roblox global.
2. `rules` reads time only from the clock it was given.
3. `rules` never names a specific definition.
4. A client sends requests and nothing else.
5. Entity ids, never Instances, cross between server and client.
6. Authoritative state is plain tables: string-keyed maps, arrays without gaps, an explicit `false` for an empty slot, no not-a-number values. Tables with gaps or mixed key types do not survive remotes or saving.
7. Nothing authoritative lives in an attribute. Attributes carry data authored on the map and read once at start, and state shown to clients.
8. No metatables and no module-level mutable state in `lib` or `rules`. An object is a plain table, and a module's functions take it as their first argument.

---

# Part B: the working design (not for signature yet)

Each section says which step tests or decides it. Expect this part to change.

## B1. The kernel and how features interact

**Tested in code at step 2b,** with two made-up features kept in `tests/`: the later one calls down through a "would it succeed" question, reacts to the earlier one's record, registers a check, and throws after a change. This note is revised after 2b, and again after the first real second feature at step 4c.

`rules` is a small kernel plus features. The kernel knows nothing about any particular feature.

| Part | Job | Step |
|---|---|---|
| `Kernel` | Builds the parts below and holds them, with the definition registry and the clock it was given | 2b |
| `World` | The authoritative state: a table of entities (id, definition, owner) and each feature's section. Makes and removes an actor when a player joins or leaves. Fires once per completed action with that action's records | 2b |
| `Actions` | Applies one action. Holds the handlers, the reactions, the checks, and each feature's check of its own invariants | 2b |
| `Context` | The value passed to everything that runs inside an action | 2b |
| `Buttons` | Turns a button press into an action, given what is held and what is aimed at | 3e |
| `Access` | Answers whether an actor may look at, take from or change something that has an owner. A handler says which of the three its action is and passes the owner in | 4b |
| `Ticks` | The ordered list of features' tick functions, and the function that runs them | 6a |
| `Save` | A player's document: asks each feature to export or import, runs migrations, and owns the ids used inside a document | 7a |

Kernel-like code that sits outside that directory, listed so it cannot hide: `lib/Defs`, and `build(content, options)` in `rules/Features.luau`.

**The sign-off rule, from step 2b on:** the user's sign-off is needed to add a kernel part, a row to "what a feature provides", a field to the context or to the build options, or a shared module that more than one feature's files require. The edge tool prints the modules required by more than one feature.

### An action is the only way state changes

- **An action is a kind, an actor and a payload,** all plain data.
- **The actor is an entity id,** never a Roblox Player. Server glue sets it from who sent the request, never from the message.
- **Server glue adds the actor's position to every request's payload** as plain numbers. Rules never ask Roblox for anything.
- **Reach is a rule, not glue.** A handler measures from that position to the thing's position in state. Draft 4 measured to the Instance on screen, which tied a rule to the visual layer.
- **Opening and closing a container, and choosing the held slot, are actions.** Who has a container open is state in `inventory`. Every stack move re-checks reach, so a panel left open gains nothing.
- **Actions are applied for a request, by a tick, when a player joins or leaves, and by a feature's server glue when Roblox reports something a rule depends on,** such as the zones on the map at start or a plot being handed to a player. Nothing else applies one. Handlers do not; they call functions.
- **The context is a type in its own kernel module.** It carries the actor, the way to report a record, `World`, `Access`, the definition registry and the clock. It never carries `Kernel` or `Actions`. `Actions` passes the same context to the handler, to each reaction and to each check.
- **Every function in `rules` that changes state takes the context first,** so it can only run inside an action. `lib` functions take the table they change. Query functions return values or copies, never a live table.

How one action runs:
1. `Actions` builds the context and calls the handler for the action's kind.
2. **The handler validates everything first.** For each earlier feature it will change, it asks one question with the whole list of changes it intends there, and that feature answers for the list. Checks that later features registered run inside that question, so a handler and any other caller pass the same gate. If anything refuses, the handler returns not ok and nothing has changed.
3. The handler changes its own feature's section and calls earlier features' functions, reporting a record for each change.
4. `Actions` delivers each record, in the order reported, to the reactions registered for its kind. A reaction may change its own section and call earlier features' functions that cannot refuse. A reaction that throws is logged, and the remaining reactions still run. `Actions` fails an action that reports more than a fixed number of records.
5. `World` fires once with the whole list. Server glue listens there. Each glue listener is protected from the others' failures, and none may apply an action.

**There is no rollback.** If code throws after the first change, the action is logged and reported as failed, and `World` still fires so the screen matches the state. That is a bug by definition, and two things contain it. The tests run every feature's invariant check after every action. And before any export `Save` runs those checks for that player: if one fails it writes nothing, and the session ends on the last good document.

### Rules between features

- **Features are listed explicitly, in order,** in `rules/Features.luau`. No auto-discovery. The tests and the server call the same `build`.
- **Call down.** A feature may call the exported functions of features listed before it.
- **React to records.** A later feature reacts to an earlier one by registering a reaction to one of its record kinds. An earlier feature never names a later one. There is no separate signal system between features. `lib/Signal` remains for `World`'s one signal to the glue and for client views.
- **A later feature that must be able to refuse registers a check** under a check-point name the earlier feature exports.
- **A feature writes only its own section.** `World` hands a section's accessor to the feature that registers it, once, at install. There is no lookup by name, so every use of another feature's state is a require the edge check can see.
- **A tick reads state and applies actions.** It takes time only from the kernel's clock.
- **A new feature puts no knowledge of itself into an existing feature's files.** An existing feature may first need a new record kind or check point, added as its own small change.

### Joining and leaving
- **Join is an action that `World` handles.** It makes the actor, then runs each feature's load in install order with that player's document, which is empty for a new player. `inventory`'s load makes the pack, whose size glue passes in from content.
- **Leave is an action too.** It runs each feature's unload in reverse order and removes the actor.
- Both exist from step 3b. `Save` at step 7a only supplies and takes the document.
- **Load and unload report their own record kinds,** one per entity. Glue treats them as it treats "placed" and "removed". No feature reacts to them and no one-off event is sent for them.
- A client's Ready that arrives early is answered when the join action completes.

### What a feature provides
Everything is registered in the feature's one `install` function.

| A feature may provide | Example from `inventory` |
|---|---|
| The definition components it reads | `stack` and `container` |
| Its section of state, behind query functions | "What is in this container?" |
| The actions it handles, and the request shapes for those a client may ask for | Move a stack, drop, pick up, open, close, choose the held slot |
| What the two buttons mean on its things, as data, and what an actor is holding | Use on something with a `container` opens it |
| Record kinds that later features may react to, and check points | "A container was removed" |
| A tick | Items left on the ground expire |
| Load and unload for one actor; export and migrations from step 7b | The pack and the containers that player owns |
| A check of its own invariants | Every stack is in exactly one place |

Button meanings are declared as data in a feature's `protocol` file, and one pure matching function in `lib` resolves a press. The server's `Buttons` and the client's preview and hint run the same function, so the client can tell what a press will do without a second copy of the rule. The order of precedence is question 1.

### Entities
- **Entities are actors, placed things, stacks on the ground, and carried items that have a container.** A plain stack in a slot is not one.
- **Only an item with a container keeps its id when placed and broken.** Placing any other item makes a new entity, and breaking it ends that entity. The validator requires a stack size of 1 on every row with `container`.
- **A container has the same id as whatever carries it:** the crate's id for a crate, the actor's id for a pack. One container per thing.
- **Entity ids are strings,** handed out per server session and never saved.
- **Owner:** a carried entity's owner is the actor whose pack holds it; a placed entity's owner is its grid's owner; a stack on the ground has none. The owner changes only through one `World` function, which `inventory` calls when a thing enters a pack and `building` calls when it is placed.
- **Whenever an item with a container enters a pack or lands on the ground, `inventory` closes it for everyone who has it open.**

## B2. How state reaches the screen

**Tested at steps 3a to 4f.**

| What | How it reaches a client |
|---|---|
| Solid things: placed things, items on the ground | A feature's projector on the server creates anchored Instances; Roblox replicates them |
| What a character is holding | A server-made Instance attached to the hand |
| State with no place in space: your pack, a container you have open | A feature's sender sends it as data; the client keeps a read-only copy |
| One-off events: a thing breaking, a recipe finishing | Sent by the owning feature's sender to every player on the server, with what the client needs to show it, since the Instance may already be gone |
| A request refused | Answered directly, with the request's number and a reason |
| Player characters | Roblox's own replication, simulated by the player's own client |

Not designed: state over a whole area such as weather, moving things the server owns, helper characters, vehicles.

**Making every solid thing a server Instance is a hypothesis.** The research recommended it only for what the engine must collide with. This design goes further to avoid writing client-side culling. But with the streaming distances left at Roblox's defaults, a phone is spared only what is more than 1,024 studs away or what it cannot hold. Step 4f measures it, counting every placed thing inside that distance across all plots. If it fails for a feature, that feature's projector, view and aiming change. Because reach is a rule, no rule changes.

Rules for the glue:
- **Glue is per feature.** A feature brings its own projector, sender and views as new files. Shared glue checks a request's shape and routes it. It makes no game decision.
- **What everyone nearby sees rides on the Instance. What only the viewer of a panel sees goes by sender.**
- **Several features may decorate one Instance,** each from its own files, with an attribute or a tag and never with a child Instance. `stations` marks a station as running on the Instance `building` made; it never creates or removes it.
- **What blocks movement and what a tap can hit come from the definition, not the art.** A projector builds the solid shape from the footprint and puts the art inside with collision and queries off. An item on the ground or in the hand uses one fixed box set in content.
- **Each thing is one small Model, set to arrive whole** by its projector before it is parented, with its entity id and tag already on it. Only what is inside the Model at that moment arrives together. A client treats an arriving Instance as "show it", never "it was just placed".
- **Attribute and tag names are declared in `protocol`.**

The wire:
- Two RemoteEvents, requests up and updates down.
- A client connects its handler, then sends Ready, and the server answers on the update stream with a snapshot. No RemoteFunction, because Roblox does not order one against RemoteEvents.
- After that, one message per action per affected player. Each sender decides who is affected, queues what changed, and the channel sends once.
- A press is the one request the kernel declares, in the shared `protocol` file. Every other request is declared by a feature. An action that a press can reach is not also requestable.
- The order for a request: check its shape, set the actor, add the position, resolve a press through `Buttons`, apply.
- Every request carries a number, so a refusal can be matched to it.
- Messages carry entity ids, never Instances. A remote can arrive before the Instance it refers to.
- Receive handlers never yield.
- Any client can fire any RemoteEvent with any arguments, so nothing is trusted before the shape check.
- The shape check requires every number in a request to be finite and in range, and a whole number where it is a count, a slot or a tile coordinate. Handlers check again against current state.

Place settings, written into the project file (see A5 for how they reach the place):

| Setting | Value |
|---|---|
| `StreamingEnabled` | On |
| `ModelStreamingBehavior` | Improved |
| `StreamOutBehavior` | Opportunistic |
| `StreamingIntegrityMode` | PauseOutsideLoadedArea |
| Streaming radii | Left at 64 and 1024 |
| `SignalBehavior` | Deferred |
| `PlayerScriptsUseInputActionSystem` | Enabled |
| `UseNewLuauTypeSolver` | Matches the solver the checks use |
| `NextGenerationReplication` | Disabled |
| `UseFixedSimulation` | Disabled |

The last two are set explicitly because left at their defaults they follow Roblox's own rollout and could switch on by themselves.

Server Authority is **not adopted.** It is aimed at competitive shooters and racing, raises CPU use, and has open mobile bug reports. Movement stays simulated by each player's client, so the reach rule filters honest play and does not stop a cheat. Player characters stay on Roblox's default Humanoid, because the Character Controller Library is still labelled beta. Both are looked at again with the first vehicle prototype.

## B3. Saving

**Decided at step 7a, after questions 3, 8 and 10.** Nothing here is built before then.

- **One document per player,** in one key, with one version number and one section per feature.
- **Sections refer to each other by ids local to the document.** `Save` hands those out during an export and maps them back during a load. Each feature recreates its own entities on load.
- **A placement is a grid, three integer tile coordinates and a rotation.** Depends on question 3. The grid field has only one possible value today; keeping it is question 13.
- **Loading has two phases:** every feature decodes and validates its section without touching `World`; then all of them apply inside the join action, and every invariant check runs. If the apply phase fails, the leave action follows and the session ends on the last good document.
- **A server never changes the data of a document it cannot read.** If the stored version is newer than the server, or migration or validation fails, it ends the session leaving the data as it was, tells the player and removes them.
- **The export runs only in ProfileStore's before-save hook.** When a player leaves, the glue ends the ProfileStore session first, which fires that hook, and applies the leave action after. If ProfileStore ends the session itself because another server took it, this server stops accepting that player's requests and removes them with no export.
- **Every release that adds a saved definition id or changes the format ends with a restart of servers running the old version.**
- **The kernel's clock is the server's Unix time in seconds, and features save absolute times.** No tick is run specially on load: the first ordinary tick finishes anything whose time has passed. Whether and how time away counts is question 8.
- **Each feature owns the migrations of its own section** and registers them with `Save`, which runs them in version order.

ProfileStore provides session locking. It is one file, vendored with its Apache-2.0 licence and the commit recorded, excluded from the checks, and wrapped in a module of ours.

Risks that come with it, which are question 10:
- No commit since July 2025, with unmerged fixes.
- By default it autosaves each profile every 300 seconds, and the first save after joining can take about 450, so a crash can lose that much. The period is a constant we can change, and a profile can be saved at once at the cost of one write.
- After a crash a returning player can wait up to 40 seconds.
- **Duplication between two players.** Each document saves on its own schedule. If one player drops an item, another picks it up, and the server crashes after only the second has saved, the item exists twice. Nothing in the foundation prevents this. Saving both at once after a transfer narrows it.
- Its mock data lasts for one test server only, so step 7c runs against live keys in a separate test experience.

Expensive to change after launch, each proposed here and decided at step 7a with the user's sign-off:

| Decision | Proposal |
|---|---|
| The data store name | `players`: named for what it holds, not for the game |
| The key | `u_` and the user id. Roblox plans ids that differ per game, so the same account will have a different id in a separate test experience |
| One key per player | Yes |
| ProfileStore's envelope around the data | Accepted with the library |
| Definition ids | Never renamed in place |
| The coordinate convention | A grid, three integer tiles, a rotation |
| A container shares its carrier's id | Yes |
| Saved times | Absolute Unix seconds |
| Published migrations | Never edited |

---

# Part C: the plan

## C1. Scope

This note covers **the foundation**: four features and saving. It is smaller than the first playable build proposed earlier in the project notes, which has a handcart as a first home, a tamed creature, an enchantment, a second people, a machine earned from a faction and a caravan between settlements. Those need features that are not designed: bodies, creatures, peoples, settlements, and a grid that is not a plot. Three decisions wait with them: building on anything but a plot, state that belongs to a place and not to a player, and anything a player owns that must keep working while they are offline.

## C2. The foundation's features

An arrow means "requires and may call".

```
building  ----> inventory
climate   ----> building
stations  ----> climate, building, inventory
```

| Feature | Job | Components and kinds it owns |
|---|---|---|
| `inventory` | Stacks in containers and on the ground: moving, dropping, picking up, opening, closing, choosing what is held | `stack`, `container` |
| `building` | Placing an item as a thing on a grid, and breaking it back into an item | `placeable` |
| `climate` | Keeps what is giving off a condition and answers which conditions hold at a tile. Never reads `stations` | `emits`; the `Conditions` and `Zones` kinds |
| `stations` | Runs recipes on placed stations, telling `climate` what a station gives off | `station`; the `Recipes` kind |

- When `building` breaks a running station it reports "a thing was removed". `stations` reacts by dropping its record of that station and withdrawing its heat from `climate`. `building` knows about neither.
- A station stores when its recipe started. The tick only looks for recipes whose finish time has passed and applies one action for each. Progress on screen is computed from the start time, so nothing is sent per tick.
- Whether a station gives off heat while lit or only while a recipe runs is part of question 7. As drafted before, a recipe could not use the heat of the stove it runs on.

## C3. Planned modules

No "requires" column: the edge check draws that from the code.

| Directory | Module | Job | Step |
|---|---|---|---|
| `lib` | `Signal` | Connect and fire callbacks | 1 |
| `lib` | `Stack` | Merge and split arithmetic; changes its arguments | 1 |
| `lib` | `Container` | Slots holding stacks; answers for a whole list of intended changes | 1 |
| `lib` | `Schema` | Check a table against a shape, rejecting unknown keys | 2a |
| `lib` | `Defs` | Registry of definition kinds and components; validate, freeze, look up | 2a |
| `lib` | `ButtonMatch` | Resolve a press from declared button meanings | 3e |
| `lib` | `Grid` | Tile occupancy | 4a |
| `lib` | `TileSpace` | Convert between a grid's tiles and points, from plain numbers | 4a |
| `lib` | `Clock` | The type of a time source, and one a test sets by hand | 6a |
| `lib` | `Recipe` | Can it run, what it takes and gives | 6b |
| `lib` | `Migrate` | Run a document through versioned steps | 7a |
| `protocol` | `Wire` | The request and update envelope, Ready, a press, a refusal, the entity id attribute and tag | 3a |
| `protocol` | one file per feature | Its component shapes and types, its requests, its button meanings, its views and events, its attribute names | 2c, 4c, 5a, 6b |
| `content` | `Things`, `Settings` | Every thing; the pack's size and the box for a loose item | 2c |
| `content` | `Conditions`, `Zones` | Conditions, and kinds of place that give them off | 5a |
| `content` | `Recipes` | Recipes | 6b |
| `rules` | `kernel/*`, `Features` | See B1 | 2b to 7a |
| `rules` | `inventory`, `building`, `climate`, `stations` | See C2 | 2c, 4c, 5a, 6b |
| `server` | `Main.server` | Entry: build the rules from content, start the glue in feature order | 0a |
| `server` | `Channel` | The server end of the wire | 3a |
| `server` | `Actors` | Which actor id belongs to which Player | 3b |
| `server` | `pure/Session` | The order of things when a player joins and leaves | 3b |
| `server` | `Intake` | Check a request's shape, set the actor, add the position, resolve a press, apply | 3e |
| `server` | `Instances` | Entity id to Instance and back | 3d |
| `server` | `Plots` | Give a player a plot spot and report each plot's origin to `building` | 4d |
| `server` | `Loop` | Run the kernel's ticks | 6a |
| `server` | `SaveStore` | Our wrapper over ProfileStore | 7c |
| `server` | `Persistence` | Load and save a player's document | 7c |
| `server` | `inventory/Sender`, `GroundProjector`, `HeldProjector` | Send packs and open containers; show ground and held items | 3c, 3d, 3f |
| `server` | `building/Projector`, `Sender` | Show placed things; send break events | 4d |
| `server` | `climate/ZoneReader` | Read zone volumes from the map at start and hand them to `climate` as plain data | 5b |
| `server` | `stations/Projector`, `Sender` | Mark a running station on its Instance; send a station's recipe and start time | 6c |
| `client` | `Main.client` | Entry | 0a |
| `client` | `Channel` | The client end of the wire | 3a |
| `client` | `pure/Mirror` | Read-only copy of what senders sent, behind typed functions | 3c |
| `client` | `Instances` | Entity id to streamed-in Instance and back | 3d |
| `client` | `TwoButtons` | The Use and Hit input actions and their bindings | 3e |
| `client` | `Aim` | What the player is aiming at | 3e |
| `client` | `Press` | Turn a button press and an aim into a request | 3e |
| `client` | `Events` | Hand one-off events to the views that asked for their kind | 4d |
| `client` | `inventory/Hotbar`, `Selected`, `ContainerPanel` | The hotbar; the locally chosen slot; an open container | 3f, 3f, 4e |
| `client` | `building/PlacementPreview`, `Effects` | Where a held thing would go; a break effect | 4d |
| `client` | `stations/Effects`, `Progress` | Smoke on a running station; its progress beside the panel | 6c |
| `client` | `presentation/ThingLooks` | Definition id to icon, sounds and effects | 3f |

Client rule: the client shows a change before the server confirms it in one case only, which hotbar slot is selected.

## C4. Steps

Each step is one reviewable change.

| Step | What | Studio |
|---|---|---|
| 0a | The project file (code mapping, the two RemoteEvents, place settings), one placeholder module per directory, both entry scripts, every check, the harness with one test, and the Lune probes | No |
| 0b | First run: start a place from a build, sync into it, and have each entry script print a value required from every directory on its side. Try live sync. Confirm a script-made Model can be set to arrive whole | Yes |
| 1 | `Signal`, `Stack`, `Container` | No |
| 2a | `Schema`, `Defs`, tested with made-up components | No |
| 2b | `World`, `Actions`, `Context`, `Kernel`, `Features`, tested with two made-up features. **Stop and revise Part B** | No |
| 2c | `inventory`: containers and a pack; the first five things | No |
| 2d | `inventory`: items on the ground | No |
| 2e | `inventory`: opening and closing a container; choosing what is held | No |
| 3a | The wire: `Wire`, both `Channel`s, Ready | Yes |
| 3b | `Actors`, `Session`, and joining and leaving | Yes |
| 3c | `inventory/Sender`, `Mirror`, the snapshot | Yes |
| 3d | Both `Instances`; ground items in the Workspace | Yes |
| 3e | The two buttons: `Buttons`, `ButtonMatch`, `TwoButtons`, `Aim`, `Press`, `Intake` | Yes |
| 3f | The hotbar and the held item | Yes |
| 4a | `Grid`, `TileSpace` | No |
| 4b | `Access` | No |
| 4c | `building`: place and break, as rules with tests. **Stop and revise Part B** | No |
| 4d | Plots; `building`'s glue and views; `Events` | Yes |
| 4e | A crate: an item that keeps its container; the container panel | Yes |
| 4f | **Measure on a phone:** frame time and memory with 500, 2,000 and 5,000 placed things inside 1,024 studs. The pass mark is agreed with the user from the first reading | Yes, and a phone |
| 5a | `climate` as rules; conditions and zones | No |
| 5b | `climate`'s zone reader | Yes |
| 6a | `Clock`, `Ticks`, `Loop`; ground items expire | Partly |
| 6b | `Recipe`, `stations` as rules; recipes | No |
| 6c | `stations`' glue and views | Yes |
| 7a | Decide B3 with the user. `Migrate`, `Save` | No |
| 7b | Export and migrations in each feature | No |
| 7c | `SaveStore`, `Persistence`; leave and come back, against a test experience | Yes |

## C5. Can it be added?

Three levels, **counting rule code only**:
1. **A row of data.**
2. **A small addition inside an existing feature,** the first time a new kind of effect appears.
3. **A new feature directory.** It may first need a new record kind or check point in an older feature, as a separate small change.

Every row below except the first rests on something not designed yet, so every cost but the first is an estimate.

| The user's example | Rule code | Needs first | Glue, client and art |
|---|---|---|---|
| Ice cave | 1: a zone row. It only matters where something responds; in the foundation that is a recipe on a plot | `climate` and its zone reader | A volume placed in the map |
| Toxic fallout | 1 | Something that responds: bodies | A volume, an effect |
| Mana-heavy area | 1 | Recipes that need mana, from step 6b | A volume |
| Heavy mud | 2: a response that slows | Bodies | A server module allowed to write to characters |
| Rain storm, thunder cloud | 3: weather, a feature that tells `climate` when a source starts and stops | `climate`; bodies and marks for the strike | A way to send area-wide state; effects |
| Pigs and cows | 3: creatures | Bodies, needs | Rigs; a way to send moving things |
| Mules, horses, pterodactyls | 3 twice: creatures and carriers; movement in the air is one more addition | Creatures | Riding and flying controls |
| Boom rats | 2: an effect on death | Creatures, bodies | A burst effect |
| Wolfmen, vampires | 2: a condition that swaps a body's responses; then data | Bodies, peoples, needs, time of day | A change of appearance |
| A new region | 3 once: travel | Saving | A new Roblox place and its map per region |

Adding a feature touches: one directory in `rules` and a line in `Features.luau`; rows or files in `content`; one file in `protocol`; a directory in `server` and in `client` with a line each in the entry scripts; rows in `presentation`; a migration if a saved shape changes.

## C6. Regions

Not in the foundation. Each region would be its own Roblox place with its own servers, built from the same `src` and published separately, all released together. Reaching the edge teleports you behind a loading screen. What you carry travels in your saved document, never in teleport data, which the client can read; the server ends your session and saves before teleporting. Risks: a small audience spread over places leaves each empty; Fisch's separate region hurt it when it reset progress and currency; teleport time is unmeasured.

---

# Part D: the user's decisions

Game rules. Each has a proposal where I have one, and the step that needs the answer.

| # | Question | Proposal | Needed before |
|---|---|---|---|
| 1 | What Use does when you hold something and aim at something | What you hold applies to the target if a rule matches (fuel on a stove); otherwise the target's own use (open the crate); otherwise the held item's use (place it). Hit breaks or harvests | 3e |
| 2 | A filled crate | Breaking it gives an item that keeps its contents. It may go in a pack or on the ground, never inside another crate, so one slot cannot hold unlimited goods and a save cannot grow without bound | 4e |
| 3 | Walls | Do they fill a tile or sit on its edge, and are there floors above floors in the foundation? No proposal: it is a look-and-feel call, and it fixes the save's coordinates | 4a |
| 4 | Aiming on a phone | The nearest thing in front of your character within reach, so one thumb does it | 3e |
| 5 | Visitors on your plot | They cannot place or break. They can look inside a container but not take from it, which also limits the duplication risk | 4b |
| 6 | Items on the ground | Temporary: they disappear after a few minutes and are never saved. To keep that from deleting a filled crate, breaking a crate is refused when it will not fit your pack | 2d |
| 7 | How a station starts | Like a furnace: by itself when its inputs and fuel are present, running whichever recipe matches. It gives off heat while it has fuel burning, whether or not a recipe is running | 6b |
| 8 | Time away | A running recipe is saved with its start time and finishes while you are away. No cap, and one batch, not several | 6b |
| 9 | Content and models are sent to every client | Accept it. Anything meant to be discovered can be kept server-side later | 0a |
| 10 | The saving risks listed in B3 | Accept them for the foundation | 7a |
| 11 | Controls beyond the two buttons: rotate while placing, drop, open your pack | Ordinary on-screen buttons drawn by views | 3f |
| 12 | A limit on things per plot | None until step 4f gives a number | 4f |
| 13 | A tile-grid field in saved placements though the only grid today is a plot | Keep it. It is ahead of need, which your rule is against, but the coordinate convention is the hardest thing to change later | 7a |

Approvals:

| What | Needed before |
|---|---|
| Lune added to `rokit.toml`, with its type definitions kept inside `tests/` | 0a |
| The Roblox type definitions file for luau-lsp, `globalTypes.None.d.luau` at tag 1.70.1 | 0a |
| A working name for the project file and repository | 0a |
| A phone to test on | 4f |
| ProfileStore, one file and its licence | 7c |
| An Open Cloud key, kept by you and never sent through chat | The first publish |

---

# Appendix A: what changed from draft 4

| Finding from the third round | Change |
|---|---|
| Part A mixed what is signed with what is still a hypothesis | Three tiers: the shape to sign, a working design, a plan |
| "That is the whole kernel" was not true | The kernel table is in the working design, with what each part holds, kernel-like code elsewhere named, and a sign-off rule that gates the surface from step 2b |
| The mechanism could not be tested before two thirds of the plan | Step 2b tests it with two made-up features |
| The saved-time rule contradicted the tick rule | Absolute times; no special tick on load |
| No part owned an actor, joining or leaving | `World` handles join and leave as actions, from step 3b |
| "One id carried or placed" failed for anything that stacks | Entities are defined exactly |
| Unload reported no records | Load and unload report their own kinds |
| "Validate first" did not cover dependent changes or say where checks run | One question for the whole list of changes; checks run inside it |
| Nothing said what follows a failed action | Reactions keep running; `Save` refuses to export a state that fails its checks |
| The client could not tell what a press will do | Button meanings are data; one pure matcher runs on both sides |
| No edge rules inside `server` and `client` | A1's finer rules |
| A request was refused by measuring to an Instance | Reach is a rule, measured in state |
| Rojo was said to sync the place settings | It does not; the place starts from a build and a tool compares |
| The edge check was to be a hand-made scanner | It uses `luau-lsp require-graph` |
| The first wire step was nine modules | Split into 3a, 3b and 3c |
| Several game rules were assumed | Thirteen questions |

# Appendix B: facts the reviewers added

Read by the reviewers on 2026-11-18. I have not re-read these myself.

| Fact | Source |
|---|---|
| A relative require starts at the script's parent (`./`) or grandparent (`../`) | create.roblox.com/docs/reference/engine/globals/LuaGlobals |
| Roblox recommends one client Script, with a client run context, in `ReplicatedStorage`; such scripts run after loading and can read `ReplicatedStorage` without waiting | create.roblox.com/docs/scripting/locations and its replication-order section |
| Rojo keeps a map from one path to several Instances; its Studio plugin skips properties it cannot script; `rojo build` writes all ten place settings | Rojo 7.7.1 source and docs; built locally by three reviewers |
| `luau-lsp require-graph` prints resolved require edges as JSON or as a diagram | luau-lsp changelog 1.55.0; run locally with 1.70.1 |
| Lune has no Luau parser | Lune's documentation |
| RemoteEvents are ordered among themselves and not against RemoteFunctions; unhandled events wait in a limited queue | create.roblox.com/docs/scripting/events/remote |
| A server script may set a Model's `ModelStreamingMode` to `Atomic`; the Workspace streaming settings cannot be set by script | create.roblox.com/docs/workspace/streaming and the Model reference |
| With stream-out set to Opportunistic and radii at 64 and 1024, a client keeps what is within 1,024 studs as far as the device allows | create.roblox.com/docs/workspace/streaming |
| A cyclic require hangs with no error | Roblox's ModuleScript reference |
| Teleport data is visible to the client and unencrypted | create.roblox.com/docs/projects/teleport |
| Old servers keep running after an update | create.roblox.com/docs/projects/update-experiences |
| ProfileStore fires its before-save hook from `EndSession` too; steals a session after 40 seconds; autosaves every 300 by default; mock data is forgotten when the server shuts down; Apache-2.0 | Its API page and `ProfileStore.luau` |
| The Input Action System is three Instance classes: `InputContext`, `InputAction`, `InputBinding` | create.roblox.com/docs/input/input-action-system |

Not verified by anyone: anything about Lune's behaviour, since it is not installed; live sync of the twice-mapped directory; that an attribute set before parenting is present when the Instance arrives.

# Appendix C: Roblox and Luau for a Godot developer

| Godot | Roblox | Watch for |
|---|---|---|
| Scene tree of Nodes | The DataModel, a tree of Instances | |
| Autoload singletons | A ModuleScript can be one. Services such as `Workspace` are the engine's and you cannot add one | This codebase's rules do not use the pattern: they pass the kernel as a value |
| A `.gd` file with `class_name` used as a library | A ModuleScript: returns exactly one value | It runs once per side: separately on the server and on each client |
| A script attached to a node with `_ready` | A Script whose run context is Server or Client | It does not extend the Instance it sits under and has no lifecycle callbacks. Its body runs once, and only in certain containers |
| `PackedScene` and `instantiate()` | A Model kept in storage and `:Clone()`d | |
| `Resource` and `.tres` files | Closest is `content`: Luau tables | Godot checks a `.tres` against its script. Here a validator checks content when the tests run and when the server starts |
| Signals | Events on Instances; in plain Luau you write your own, hence `lib/Signal` | With deferred signals an engine handler runs later, not inside the firing call. `lib/Signal` is immediate |
| `@export` variables | An attribute set on an Instance in Studio's Properties window | Used here for two things only: data authored on the map, such as which zone a volume is, and state shown to clients |
| Groups | `CollectionService` tags | |
| `_process` | `RunService.PreRender` on the client, `Heartbeat` on both | |
| `_physics_process` | No fixed step unless a setting this project turns off is on | Ticks use elapsed time from the clock |
| `@rpc` | `RemoteEvent` | No per-call authority or argument checking. Any client can fire any RemoteEvent with any arguments |
| `MultiplayerSynchronizer` | Automatic: Instances the server puts in the Workspace are copied to clients | One way, with one exception that matters: Roblox gives a client ownership of its own character and of unanchored things near it, and that movement reaches everyone |
| Optional multiplayer | Always client and server, even when playing alone | |
| `await signal` | No `await` keyword. Any call may yield | You cannot see at a call site whether it yields |
| `res://` paths resolved on disk | Requires resolved against the Instance tree | |

Luau against GDScript:
- **Typing** is gradual, as in GDScript, and `--!strict` at the top of a file makes it strict. Types are structural.
- **Types are erased.** They give errors in the editor and the checks. Nothing is checked at run time.
- **No classes yet.** A module is a table of functions. An accepted Luau proposal adds classes; this codebase uses plain tables either way.
- **`obj:method()` passes `obj` as the first argument; `obj.method()` does not.**
- **One container type.** A table is both array and dictionary. Arrays start at 1.
- **Only `false` and `nil` are false.** Zero and the empty string are true.
- **One number type,** a double. Tile arithmetic needs `//` and `math.floor`.
- **`local`** declares a variable. Without it a name is global to that one script, and strict mode rejects it.
- **`~=`** is not-equal, **`..`** joins strings, **`nil`** is null.
