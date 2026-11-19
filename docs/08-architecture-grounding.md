# Architecture Grounding Research, November 2026

Compiled 2026-11-18. Three researchers each wrote a brief from official documentation, Roblox staff posts and project repositories, and a second agent independently re-checked each brief's key facts and recommendations. Read each brief together with its "Independent check": the checkers corrected several facts and marked a number of recommendations as going beyond the evidence.

These facts change quickly. Check the live source before relying on a version number, a limit or a library's maintenance status.

## Summary of what held up

### Engine and replication
- **Server Authority** (released 2026-07-09) is opt-in. Turning it on forces five other settings, raises CPU on clients and server, has open bug reports on phones as of November 2026, and Roblox staff say it "isn't the right decision for all games". The docs aim it at shooters, racing, sports and combat. Simple default-avatar games can toggle it on later; complex custom movement must be rewritten around its simulation callback. Under it, plain Luau variables are not rolled back, so a table-backed rules core would stay server-only either way.
- **Two ways to get state to clients.** Instances the server creates are scoped by distance and streamed in and out by the engine automatically. Data sent through remotes must be scoped by hand, and Instances a client creates never stream out, so the client has to cull them itself. RemoteEvents are reliable and ordered. Nothing orders a remote against a property change, and a remote can arrive before the Instance it refers to.
- **Without Server Authority,** each client simulates its own character, unanchored parts near a player are simulated by that client, and anchored parts are always owned by the server.
- **A client must ask for its first snapshot.** Remotes fired before the client has connected a handler sit in a limited queue and are then discarded, and a receive handler that yields breaks ordering.
- **NPCs:** Roblox's performance guidance suggests rigs driven by an AnimationController with a custom mover and client-side animation for large counts. An Animator created on a client does not replicate. Skinned meshes that move without a Humanoid cause extra rendering work, so the advice holds cleanly for rigs made of rigid parts. The Character Controller Library is still labelled beta and its NPC interface has not shipped.
- **Touch input:** the Input Action System is fully released (2026-06-11) and binds an on-screen button to an action. ContextActionService's binding methods are planned for deprecation. With the new player scripts on, a drag on a scrolling panel also moves the thumbstick unless the panel's display order is above the default touch controls. Input action state is not sent to the server unless Server Authority is on, so intents must travel by RemoteEvent.
- **Streaming on a build-heavy plot:** parts added to a model after it first replicated arrive one at a time, and stream-in and stream-out look the same as real adds and removes to a script.

### Persistence
- **Limits:** 4,194,304 characters per key; write budget of 300 + 20 per concurrent player per minute across the experience; Roblox compresses stored values itself and says not to pre-compress.
- **Built-in session locking and transactions** are on Roblox's roadmap for early 2027 and have not shipped.
- **ProfileStore** is the successor to ProfileService and the common choice for session locking. It has had no commit since 2025-07-31, has unmerged fixes, has no tagged releases, copies buffers by reference, and cannot run outside Roblox, so tests need a fake behind an interface of our own. Its saved data is a plain table whose guarantee holds only until code yields.
- **After a server crash,** a returning player can wait up to 40 seconds before the old session is taken over.
- **Old servers keep running after an update** until they empty, so a save format change needs either a restart of old servers or a format old servers can still read.
- **Clocks:** both `os.time` and `DateTime.now` read that machine's clock, and Roblox steers new work to `DateTime`. Two servers can disagree slightly.
- **Arrays with gaps and tables with mixed key types** do not survive saving or remotes.
- **Scoped user ids** (a different id per game for the same account) are planned and not yet rolled out.
- **Hard to change after launch:** the data store name and key pattern, one key or several, the library's envelope around the data, definition id strings, the coordinate convention in saves, migrations once published, and what each saved timestamp means.

### Tooling and testing
- **Lune 0.11.1** runs Luau outside Roblox and installs through Rokit. Jest Lua runs only inside Roblox. TestEZ is archived. Lute, the Luau team's own runtime, has a stable 1.0.0 with a built-in test runner. Lune was not installed during the research, so its behaviour is untested here.
- **Only relative requires** (`./` and `../`) are accepted by Roblox, Lune and luau-lsp alike. Custom aliases are not released in Roblox.
- **`luau-lsp analyze --platform=standard`** fails on any Roblox global. That is a mechanical check that engine-free code stays engine-free.
- **File name case** is checked by Lune and Roblox and not by luau-lsp on Windows.
- **Strict typing does not catch a misspelled optional field** in a definition table. A validator has to reject unknown keys.
- **Libraries:** jecs is active but pre-1.0 and built for far more entities than this game has; Zap and Blink are pre-release; ByteNet has had no release since March 2024; Wally and pesde are both pre-1.0.
- **Measured locally** on about 46,000 lines: StyLua check 0.33 s, Selene 0.31 s, sourcemap 0.15 s, standard-platform analysis 0.5 to 1.6 s.

---

# A. Engine and replication

## Engine facts for the server/client split

Researched 2026-11-18. Creator docs pages carried a 2026-11-19 UTC build stamp. "Staff" means a post flagged Roblox Staff on the DevForum.

### 1. Server Authority (SA)

Full release 2026-07-09, opt-in ([release post](https://devforum.roblox.com/t/4727993)).

| Topic | What the sources establish |
|---|---|
| Turning it on | `Workspace.AuthorityMode = Server` forces five settings: NextGenerationReplication, PlayerScriptsUseInputActionSystem, Deferred signals, UseFixedSimulation, StreamingEnabled ([docs](https://create.roblox.com/docs/projects/server-authority)). |
| What is predicted | Simulation-access properties and attributes on instances near the local character, a whole physical assembly at a time (welds, joints, constraints included). Any mismatch causes a full rollback and resimulation (docs). |
| What it demands of code | Per-frame gameplay logic sits in `RunService:BindToSimulation` in a module loaded on both sides, reads input only from InputActions, and uses `time()`. Callbacks cannot yield, call `Destroy`, or reparent (docs). |
| Custom state | Attributes on predicted instances: first 64 per instance, names and string values up to 50 characters (docs). Staff intend to loosen this; no date (2026-07-09 FAQ). |
| Remotes | Allowed for discrete messages and tap/button input, but off the shared timeline by roughly 40-50 ms (staff, 2026-07-09) and with no ordering guarantee against property or attribute changes (docs). |
| Streaming | Prediction runs only in streamed areas; the prediction radius scales with device performance ([streaming](https://create.roblox.com/docs/workspace/streaming), [techniques](https://create.roblox.com/docs/projects/server-authority/techniques)). |
| Assemblies | Staff said the system works best with single-assembly mechanisms and that multi-part vehicles still mispredict ([engineers' notes](https://devforum.roblox.com/t/4139321), Dec 2025; [beta thread](https://devforum.roblox.com/t/4139157), 2025-12-10). The racing template regressed and was under investigation on 2026-10-02. |
| Tools | The release post says backpacks and tools are fully supported; the docs page still says they are not, and a known issue deletes the tool weld on misprediction. |
| Cost | Higher CPU on clients and server (staff, 2026-04-30; FAQ 2026-07-09). A low-end-device mode that trades input latency was only being considered (2026-04-30). |
| Phones | Open reports: auto-jump causes rollback ([2026-08-04](https://devforum.roblox.com/t/4774759), staff acknowledged); characters drift on mobile ([2026-10-30](https://devforum.roblox.com/t/4965276)); idle characters step under jitter, seen mostly on mobile ([2026-11-11](https://devforum.roblox.com/t/4987075)). |
| Who it is for | The docs describe competitive FPS, racing, sports and combat games. Staff (Khanovich, 2026-07-09): "Server Authority isn't the right decision for all games". |
| Adopting later | FAQ: default avatars and simple physics need only the toggle; complex custom gameplay must be rewritten around BindToSimulation and InputAction. One developer's account ([community](https://devforum.roblox.com/t/4712758), mid-2026) says conversion took six weeks and cannot be undone. |

### 2. Replicating state the developer owns

| | (a) Server creates Instances | (b) Server sends data, client builds visuals |
|---|---|---|
| Scoping by distance | Automatic for Workspace descendants under streaming; a streamed-out instance stops receiving updates ([streaming techniques](https://create.roblox.com/docs/workspace/streaming/techniques)). | Manual: `FireClient` per player. |
| Client memory | Engine streams out by radius and memory pressure. | Client-created instances never stream out ([streaming](https://create.roblox.com/docs/workspace/streaming)); the client must cull them itself. |
| Bandwidth | Creating or destroying large instance trees is network-intensive; chunk it across frames ([performance](https://create.roblox.com/docs/performance-optimization/improve)). Property replication is tuned for discrete changes, not per-frame ones (staff, [2026-06-09](https://devforum.roblox.com/t/4675512)). | Send on change, not per frame (performance doc). |
| Ordering | No ordering between property changes and remotes; same-type changes generally arrive in order ([attributes](https://create.roblox.com/docs/scripting/attributes)). | RemoteEvents are reliable and ordered, even across different RemoteEvent instances ([remotes](https://create.roblox.com/docs/scripting/events/remote)). |
| Limits | Under NextGenerationReplication the attribute limits above apply. | Client-to-server: about 500 requests per second per client, shared across all remotes of a type. Unreliable events drop payloads over 1,000 bytes and are unordered. Tables cannot mix key types, hold nil gaps, or keep metatables. |

- A remote can arrive before the instance it refers to, or the instance may never arrive (streaming techniques).
- The same doc warns against client-only copies of server-owned instances. Visuals built from data are not copies, but the stream-out exemption still applies.
- **Open-source practice:**
  - [Replica](https://github.com/MadStudioRoblox/Replica) (pushed 2025-08-07) keeps server tables, sends path-based changes over remotes, subscribes players individually, and can bind a subscription to an instance streaming in.
  - [jecs](https://github.com/Ukendio/jecs) (v0.11.0, pushed 2026-10-22) ships a networking example that batches component changes into one remote per tick.
  - [slither](https://github.com/littensy/slither) (pushed 2026-03-01) broadcasts a server store through remotes with custom serialisation, and the client renders and culls entities itself.
  - Buffer serialisers are maintained: [Zap](https://github.com/red-blox/zap) v0.6.29 (2026-06-23), [Blink](https://github.com/1Axen/blink) v0.18.9 (2026-09-19).

### 3. NPCs

- **Humanoid cost:** the performance doc says Humanoids carry a significant computation cost. It advises AnimationController rigs with a custom mover, client-side animation for large NPC counts, pooling, and spawning only near players.
- **Client-only animation:** an Animator created locally does not replicate ([Animator](https://create.roblox.com/docs/reference/engine/classes/Animator)), so client-built rigs animate locally with no server cost.
- **Skinned meshes:** skinned MeshParts that move without a Humanoid cause render-cluster rebuilds; the doc's workaround is to embed a Humanoid.
- **Character Controller Library (CCL):**
  - Base library released 2026-04-08 ([post](https://devforum.roblox.com/t/4565267)); staff recommended it for new projects.
  - The custom-abilities update is a Studio beta from 2026-09-10 ([post](https://devforum.roblox.com/t/4863739)) with breaking renames on 2026-10-08 and 2026-11-05. The [docs page](https://create.roblox.com/docs/characters/character-controller-library) labels the CCL beta.
  - Staff do not recommend it alongside Tools, Backpack or Health.
  - The NPC API is listed as upcoming with no date. Rigs without a Humanoid are supported since 2026-11-05.
  - Benchmarks claim 10-25% faster than Humanoid in active play.
  - Characters keep momentum on moving platforms.
- **SLIM for NPCs:** roadmap, early 2027 ([roadmap](https://devforum.roblox.com/t/4880208), 2026-09-18).

### 4. Touch input

- **Input Action System (IAS):** fully released 2026-06-11 ([post](https://devforum.roblox.com/t/4678416)). A Bool InputAction takes a GuiButton through `InputBinding.UIButton` ([docs](https://create.roblox.com/docs/input/input-action-system)).
- **Default player scripts:** the IAS versions are opt-in now, default in early 2027, and the legacy scripts go in mid 2027.
- **ContextActionService:** its binding methods are planned for deprecation ([reference](https://create.roblox.com/docs/reference/engine/classes/ContextActionService)).
- **Default button layout:** the thumbstick and jump button moved on 2026-04-30; staff advise keeping custom UI out of roughly 60 px at each screen edge.
- **Reading a touch target:** a ViewportPosition action bound to the Touch keycode, or `UserInputService.TouchTapInWorld`, gives a screen point; `Camera:ViewportPointToRay` turns it into a ray. Client raycasts see only streamed-in content.

### 5. Placing and removing many things

- **Physics:** anchor everything that needs no physics; sleeping assemblies are not simulated ([sleep system](https://create.roblox.com/docs/physics/sleep-system)).
- **Assemblies under streaming:** unanchored assemblies stream in as one unit, and the doc warns against large moving assemblies. Anchored ones stream part by part.
- **Recommended settings:** minimum radius 64, target radius 1024, Opportunistic stream-out, Improved model streaming, models under about 64 studs across. `PersistentPerPlayer` is suggested for a small roster of player-owned plots.
- **SLIM:** for static models only; runtime part changes break it.
- **EditableMesh:** strict client memory budgets and an experience-level toggle ([reference](https://create.roblox.com/docs/reference/engine/classes/EditableMesh)).
- **In-game creation persistence:** roadmap, early 2027, not shipped.

### Answers (my recommendations unless marked established)

**(a) Server Authority: later, decided by a phone test once a vehicle exists.**
- Established: it is opt-in, costs CPU on both sides, has open mobile bugs, and handles multi-part mechanisms worst.
- Adopting now would mean running on the beta replication system and writing every movement-touching system inside the simulation callback.
- Adopting later is cheap here only if the day-one constraints in (e) hold, because game state already lives in server data, not in the engine simulation.
- Never adopting leaves movement client-authoritative, so the server must check reach and speed on every intent.
- Enable streaming, Deferred signals and IAS player scripts from the start; leave the other two settings at default.

**(b) A mix, split by one rule: anything the engine must collide with or simulate is a server Instance.**
- Server Instances: player characters, vehicles and rideable creatures, and anchored walls, floors and ceilings.
- Data over one ordered remote stream, with pooled client visuals: item stacks, container contents, non-structural placed things, helper NPCs.
- If structure were client-only, the server could never simulate characters against it, which would close off SA.

**(c) Helper NPCs: client-built rigs on AnimationController plus Animator, moved by the client from server tile data.**
- No Humanoid, and no CCL until its NPC API ships.
- Player characters start on the default Humanoid; test the base CCL in the moving-deck prototype.

**(d) Two custom GuiButtons bound to IAS Bool actions through `UIButton`.**
- Add keyboard and gamepad bindings on the same actions, and send intents by RemoteEvent.
- Avoid ContextActionService and the CCL action slots.
- Use no Tool instances: a custom hotbar avoids both the SA tool issues and the CCL incompatibility.

**(e) Day-one constraints for the core:**
1. Entities carry their own ids and a spatial key; never pass Instance references.
2. The replication protocol carries its own sequence numbers and supports snapshot plus deltas per player.
3. The mutation path is synchronous and never yields.
4. No reading of clocks or Roblox signals inside the core.
5. All state is plain serialisable tables with single-type keys and no gaps.
6. Intents are idempotent and sequence-numbered.
7. No authoritative state lives in attributes.
8. NPC animation state is data.

Source copies are in `(session scratchpad)` (docs) and `(session scratchpad)` (forum threads).

## Researcher's direct answers (several are struck or narrowed by the check below)
- (a) Server Authority: adopt later, if at all, decided by a phone test once a vehicle prototype exists. ESTABLISHED: it is opt-in, raises client and server CPU, works best with single-assembly mechanisms, has open mobile bug reports as of November 2026, and staff say it is not right for every game; simple default-avatar games can toggle it on, while complex custom gameplay needs a rewrite around BindToSimulation and InputAction. RECOMMENDATION: do not enable it at the start. Adopting now would put the game on the beta replication system and force every movement-touching system into the simulation callback. Adopting later stays cheap only if streaming, Deferred signals and IAS player scripts are on from day one, structure is server-side, and no code relies on property-versus-remote ordering. Never adopting leaves movement client-authoritative, so the server must check reach and speed on every intent.
- (b) Instances or data: a mix is sensible. ESTABLISHED: engine replication scopes by distance and manages client memory automatically, but creating large instance trees is network-intensive and property replication is tuned for discrete changes; client-built instances never stream out; remotes are reliable and ordered; maintained open-source projects replicate owned state as data. RECOMMENDATION: split by one rule: anything the engine must collide with or simulate is a server Instance (player characters, vehicles and rideable creatures, anchored walls, floors and ceilings). Item stacks, container contents, non-structural placed things and helper NPCs travel as data over one ordered remote stream and are drawn from client pools. Keeping structure server-side is my inference from how Server Authority simulates characters on the server; it keeps that option open.
- (c) NPCs. ESTABLISHED: Roblox's guidance favours AnimationController rigs with a custom mover and client-side animation over Humanoids; a locally created Animator does not replicate; the Character Controller Library's NPC API has not shipped. RECOMMENDATION: build helper NPCs as client-only pooled rigs with AnimationController plus Animator, positioned by the client from server tile data, with animation state carried as data. Vehicles and creatures that players stand or build on must be server-side assemblies. Keep player characters on the default Humanoid for now and test the base library in the moving-deck prototype, since it keeps characters' momentum on moving platforms.
- (d) Two-action touch controls. ESTABLISHED: the Input Action System is fully released and binds a GuiButton to an action through InputBinding.UIButton; ContextActionService binding is planned for deprecation; the default thumbstick and jump button moved on 2026-04-30 and staff advise keeping custom UI about 60 px clear of each screen edge; the library's action-slot buttons belong to a beta. RECOMMENDATION: two custom GuiButtons bound to two Bool InputActions, with keyboard and gamepad bindings on the same actions, IAS player scripts enabled now, and intents sent by RemoteEvent. Resolve the target on the client to an entity id and validate reach on the server. Use a custom hotbar with no Tool instances.
- (e) Constraints the core must respect from day one. RECOMMENDATION, each derived from an established engine fact: (1) entities have their own ids and a spatial key, and Instance references never cross the wire, because remotes can outrun or miss instances; (2) the replication protocol carries its own sequence numbers and supports snapshot plus deltas per player, because nothing orders remotes against property changes; (3) the single mutation path is synchronous and never yields, so it could be called from a simulation step; (4) the core reads no clock and no Roblox signal, because only time() is synchronised under Server Authority and signals are deferred; (5) all state is plain tables with single-type keys and no gaps, because remotes cannot carry anything else; (6) intents are idempotent and sequence-numbered, because inputs can be dropped or replayed; (7) no authoritative state lives in attributes, given the 64-attribute and 50-character limits; (8) NPC animation state is data, because client-made Animators do not replicate.

## Not found
- Any published numeric budget for instance counts, memory per instance, or bandwidth per attribute change versus per remote call.
- A documented maximum payload size for reliable RemoteEvents (only the 1,000-byte limit for unreliable events was found).
- Staff guidance on Server Authority aimed specifically at sandbox, building or co-op games, beyond the general statement that it is not right for every game.
- Whether Server Authority can be applied to only some objects (for example vehicles only) while characters stay client-authoritative; AuthorityMode appears to be workspace-wide.
- Whether seats are still client-authoritative under Server Authority after full release; they were listed as such in December 2025 and January 2026.
- Official guidance on choosing which object an on-screen action button targets on touch (focus or aim-assist rules); only the screen-point and ray APIs are documented.
- Official guidance comparing the default hotbar and Tools with a custom inventory when players use their own avatars.
- A release date for the Character Controller Library's NPC API, or for the custom-abilities update leaving beta.
- Published numbers for Humanoid versus AnimationController cost per NPC; only the library's own benchmark claims against Humanoid were found.
- General instance-pooling guidance for parts and small props; the docs only recommend pooling NPC models.
- Whether a rig without a Humanoid can display avatar clothing and accessories; not checked in any page read.
- The posting date of the community Server Authority advice thread (devforum topic 4712758), and the contents of two IAS bug reports whose titles appeared in search (topics 4878000 and 4889933); these were not opened.

## Independent check

12 of 14 key facts confirmed.

### Facts corrected
- **partly wrong:** 3. SA gameplay code must run in RunService:BindToSimulation on both client and server, read input only through InputActions, keep custom state in attributes limited to the first 64 per instance with names and string values of at most 50 characters; callbacks cannot yield, Destroy or reparent.
  - Correction: Three points are stated more strongly or more narrowly than the sources. (a) 'Only through InputActions' is too strict: the SA page says InputActions 'should be used for all inputs that affect the core simulation' but also that clients 'can use remote events as an alternative API for sending inputs to the server, such as for button presses or tapping objects in the 3D world'. That exception is exactly this game's use/place and hit/break intents. (b) The no-yield rule is documented for CCL ability callbacks ('Callbacks must never yield as they run inside the engine's synchronous step'); neither the SA page nor the RunService reference states it for raw BindToSimulation callbacks. What those pages do state: only Simulation Access members may be touched (others error), Destroy and changing Parent of an in-DataModel instance error, and bound functions re-run on client resimulation. (c) The 64/50/50 limits are a NextGenerationReplication replication rule, not only a predicted-instance rule (release FAQ: 'The attribute limitation is part of the Next Generation Replication change'); with NGR enabled an over-limit string attribute is deleted with 'Removed invalid attribute' (topic 4765035; staff tudouuuu211 2026-08-03 confirmed the 50-character limit). Missing requirement: staff state that 'Luau variables in scripts are not rolled back', so predicted state must live in attributes on predicted instances.
- **partly wrong:** 14. Maintained open-source Roblox projects replicate developer-owned state as data over remotes: Replica (path-based changes, per-player subscription), jecs networking example (one remote per tick), slither (server store broadcast with custom serialisation, client renders and culls).
  - Correction: The mechanisms are described correctly (Replica: Set/SetValues by path, Subscribe/Replicate, BindToInstance; jecs example: per-component dirty storages flushed as one 'replication' RemoteEvent per call, full snapshot to joining players; slither: Reflex createBroadcaster with a serdes module and a client 'start' handshake). 'Maintained' is not supported for two of the three. Replica's last commit is 2025-08-07 (15 months ago), it has no tagged release, and its API page still says full documentation is coming. slither is a roblox-ts TypeScript game, not a Luau library; its last default-branch commit is a dependency bump on 2025-12-02 (the 2026-03-01 pushed_at is not a main-branch commit). Only jecs shows 2026 activity on main (commits through 2026-10-22). The jecs example is explicitly a sketch ('this is just an example, you need an actually populated map'), broadcasts to all clients with no interest scoping, and its own comment warns that pushing snapshots on PlayerAdded is fragile under streaming. Serialiser status: Zap v0.6.29 (2026-06-23) confirmed, no commits since; Blink v0.18.9 (2026-09-19) is the latest stable, but v1.0.0 pre-releases are in progress (pre.11 on 2026-11-07), so the 0.18 line may be superseded. I did not re-read the slither client culling code.

### Conclusions that go beyond the evidence
- (a) 'Adopting later stays cheap only if ...' has no source behind 'cheap'. The FAQ's toggle-only path covers default avatars and simple physics. Vehicles and rideable creatures with custom control would need their controllers rewritten into BindToSimulation with InputActions and attribute state, and the one first-hand conversion account the brief cites (devforum 4712758, 2026-07-01) says the opposite: a month and a half even with a mostly simulation-compatible codebase. It should be stated as a hypothesis the vehicle prototype tests, not as a property the day-one constraints buy.
- (e)(3) 'synchronous and never yields, so it could be called from a simulation step' implies the core would be SA-ready. It would not be on the client: bound functions may only touch Simulation Access members, they re-run during resimulation, and staff state 'Luau variables in scripts are not rolled back, so make sure you use attributes for synchronized game data' (devforum 4606949, 2026-04-30). A table-backed core called from a client simulation step would double-apply on every rollback. Together with (e)(7) (no authoritative state in attributes), the honest conclusion is that under SA the core stays server-only and unpredicted, with intents arriving by RemoteEvent about 40-50 ms off the shared timeline (staff, 2026-07-09). That is workable for this game, but it is the opposite of what the justification suggests.
- (e)(6) 'because inputs can be dropped or replayed' is an SA InputAction property (input drop reasons in the SA visualizer; replays on resimulation). The brief's own recommended transport, RemoteEvent, is reliable, ordered, and delays rather than drops throttled messages. Sequence-numbered idempotent intents are a reasonable design choice (acks, duplicate taps, hostile replays), but they are not 'derived from an established engine fact' as claimed.
- (e)(5) 'because remotes cannot carry anything else' is wrong as a reason. Remotes carry Instances, Enums, Roblox datatypes and Luau primitives. The documented restrictions are narrower: no mixed numeric/string keys, no nil gaps, non-string/number indices are converted to strings, metatables and functions are lost. The rule is sound (and it also means sparse integer-keyed entity maps must not be sent as-is); the stated cause is overstated.
- (e)(2) 'because nothing orders remotes against property changes': a sequence number on the remote stream cannot by itself order that stream against Instance replication, since Instances carry no such number unless the server stamps one on them. RemoteEvents are already ordered among themselves. The real requirement is that the client tolerates data-before-instance and instance-before-data in either order, plus a snapshot handshake; the brief does not say how a server Instance (wall, vehicle) is tied back to its entity id on the client.
- (b)/(c) 'anything the engine must collide with or simulate is a server Instance' and vehicles 'must be server-side assemblies' are design choices. The brief body states the supporting argument as fact ('If structure were client-only, the server could never simulate characters against it'), but under the default non-SA model each client simulates its own character, so that argument holds only if SA is adopted or for server-side queries. Also, a server-created unanchored assembly is not server-simulated by default: the engine auto-assigns network ownership to a nearby client (https://create.roblox.com/docs/physics/network-ownership.md), and the docs warn that SetNetworkOwner(nil) 'may result in jittery physics interactions for clients'. The brief never mentions network ownership, which is the actual choice for vehicles before SA.
- (c) 'No Humanoid' for moving helper-NPC rigs is given without the condition the same performance page sets: skinned MeshParts moving in a Model without a Humanoid cause FastCluster rebuilds, and Roblox's workaround is to embed a Humanoid. The brief lists this in section 3 and then recommends against it unconditionally. It holds for rigid-part rigs; for skinned rigs it needs profiling. 'Roblox's guidance favours' is also stronger than the doc's 'consider ... depending on the complexity of your NPCs'.
- (d) 'IAS player scripts enabled now' is presented with no downside. A staff-handled bug thread (devforum 4878000, opened 2026-09-17, staff replies 2026-09-29) reports that with PlayerScriptsUseInputActionSystem enabled a touch drag on UI, such as scrolling a ScrollingFrame, also drives the movement thumbstick; staff say this follows from the new thumbstick design and is fixed by giving your ScreenGui a DisplayOrder above the default TouchGui. Two related camera/Active-GUI issues were still tracked as open. For a phone game with a container panel and hotbar this needs to be in the recommendation.
- (d) 'staff advise keeping custom UI about 60 px clear of each screen edge' reshapes the source. The April 8 note says to avoid 'this area (roughly 60px from each side of the screen)' shown in an image, ahead of a layout change that shipped April 30; the April 30 update only says to check for overlap in the emulator or on a device. The exact thumbstick and jump-button rectangles are not given in text, so button placement has to be verified on a phone, not derived from a 60 px rule.
- (a) ESTABLISHED 'works best with single-assembly mechanisms' is written in the present tense from December 2025 Studio Beta statements. The current evidence for vehicle risk is the 2026-10-02 staff note that the official racing template regressed and is under investigation, which the brief has but does not use in the answer.

### What the brief missed
Items an architect needs that the brief lacks, all read in this run:

1. Network ownership (https://create.roblox.com/docs/physics/network-ownership.md): without SA, unanchored parts near a player are automatically owned and simulated by that client; anchored parts are always server-owned; SetNetworkOwner(nil) is allowed but documented as potentially jittery; loose parts on a vehicle should share the driver's ownership. This decides how vehicles, rideable creatures and anything players stand on behave before any SA decision.

2. Client-ready handshake: RemoteEvents fired before the client connects a handler sit in a queue limited by count and memory and are then discarded, and ordering is by handler start, so a yielding receive handler breaks it (remote.md, Delivery guarantees). The snapshot should be requested by the client and the receive path must not yield. Both slither ('start' remote) and Replica (RequestData) do this; the jecs example's own comment flags the lack of it.

3. InputAction state is not sent to the server unless SA is on: staff runitbackrolfo (devforum 4889933, 2026-09-23) said broadcasting input state under AuthorityMode = Automatic is 'still being discussed'. So RemoteEvent intents are required, not just preferred, in the recommended setup.

4. NextGenerationReplication status: staff tudouuuu211 on 2026-08-31 (devforum 4795364 post 9) called it 'still kinda beta-ish' and advised keeping it disabled if it blocks you; with it enabled, an over-limit string attribute is deleted outright (devforum 4765035). This supports leaving NGR at default and matters if entity ids or version stamps are ever put in attributes on server Instances.

5. Streaming behaviours that affect a build-heavy plot: atomic-model guarantees 'apply only during initial replication', so parts added to a plot model later arrive non-atomically; ChildAdded and CollectionService signals fire on stream in/out and are indistinguishable from real adds/removes; client pathfinding sees only streamed geometry; all streaming properties are non-scriptable (set in Studio or the place file).

6. Toolchain risk if SA is ever adopted with Rojo publishing: a user report dated 2026-11-06 (devforum 4978628, no staff reply, custom Rojo build) says a Rojo-built .rbxlx published through Open Cloud loses the default PlayerModule and InputContexts under SA while the .rbxl build works. Unconfirmed, but cheap to avoid by building .rbxl.

7. Roadmap items adjacent to this design (Creator Roadmap, 2026-09-18): 'Player data management improvements' with built-in transactions, session locking and schemas (Early 2027); 'Improved physics solver' (Early 2027), which staff tie to fewer vehicle mispredictions; 'Instance Streaming - Adaptive radius' (Late 2026); 'Multiple client views' in one playtest (Late 2026).

Fresh copies of every page I read are in (session scratchpad) (docs as .md, forum threads as raw_*/full_* text, GitHub metadata under gh\). Nothing was written to the project folder.


---

# B. Persistence

## Persistence brief: how this game should save and load

All pages were read on 2026-11-18. Creator Docs pages carry `last_updated: 2026-11-19Z`. "Docs/" below means `https://create.roblox.com/docs/`.

### 1. DataStoreService today

| Topic | Established value | Source |
|---|---|---|
| Value size | 4,194,304 characters per key; store, key and scope names 50 | Docs/cloud-services/data-stores/error-codes-and-limits |
| Metadata | 300 characters total per key | same |
| Per-key throughput | Read 25 MB/min, write 4 MB/min, each request rounded up to 1 KB | same |
| Experience budget | Read 300 + CCU×40 per minute, write 300 + CCU×20; UpdateAsync spends both; shared with Open Cloud | same; staff post devforum.roblox.com/t/4739240 (live 2026-07-29) |
| Server budget | Standard read and write 60 + players×40 per minute, adjustable with `SetRateLimitForRequestType` | same |
| Storage | 500 MB + 1 MB × lifetime users, measured on the compressed latest version | same |
| Throttling | Four queues of 30 requests; overflow fails with errors 301–306 | same |
| Versions | First write per key per UTC hour is kept; backups expire 30 days after being overwritten | Docs/cloud-services/data-stores/versioning-listing-and-caching |
| Write cooldown | The 6-second same-key cooldown was removed | devforum.roblox.com/t/2436230 (2023-06-23) |

- **UpdateAsync** reads and writes one key atomically. The callback cannot yield, re-runs if another server wrote in between, and cancels when it returns nil (Docs/reference/engine/classes/GlobalDataStore).
- **Failure modes:** a failed write "does not always guarantee that the backend write did not occur"; verify with `UseCache = false`. Retries must run in order per key. Strings must be valid UTF-8, and JSON nesting is capped at 400.
- **Ordered data stores** hold numbers only, with no versions or metadata.
- **Docs conflict:** the Extended Services page still shows the older 250 base and 100 MB figures.

**Announced, not shipped** (Creator Roadmap Fall Update, devforum.roblox.com/t/4880208, 2026-09-18):
- "Player data management improvements", with built-in transactions, session locking, schemas and validation: Early 2027.
- Compute functions: Early 2027.
- In-game creation persistence: Early 2027.
- `GetHistogramAsync` for ordered data stores: Early 2027.

### 2. Session locking and libraries

Roblox's player-data guide (Docs/cloud-services/data-stores/player-data-purchasing) says a previous server's final save can land after the next server has loaded. Causes are retries, throttling, a yielding `PlayerRemoving` handler or a slow server, "particularly… while teleporting". It calls this "a common source of item duplication exploits". Its fix is a lock written in the same UpdateAsync as the first read, refreshed by autosave (180 s in the sample), with expiry so a crashed server's lock can be taken over. A crash loses everything since the last autosave.

| Library | Status read | Guarantees and shape | Pitfalls |
|---|---|---|---|
| **ProfileStore** (github.com/MadStudioRoblox/ProfileStore) | Last commit 2025-07-31; wally 1.0.3; open PRs through 2026-09; thread lists Grow a Garden and Dead Rails as users | Single module. `StartSessionAsync` returns a mutable `Profile.Data`. Autosave 300 s. Conflicts are resolved over MessagingService, with a steal after 40 s and a 630 s dead-server rule. Has `Profile:Save()`, `LastSavedData`, `MessageAsync`, version queries and a built-in `.Mock` | No migrations or validation, only `Reconcile`. No multi-profile transaction. Open PR #22 (2026-08-02) reports buffers copied by reference. Author says he is "more focused on my own projects" unless crucial bugs appear |
| **ProfileService** | README: "no longer supported", use ProfileStore | Predecessor | Legacy |
| **Lapis** (github.com/nezuo/lapis) | 0.3.4, last commit 2025-02-12 | Promise API, frozen data, validation, ordered migrations with a `backwardsCompatible` flag | README: "not been battle-tested in a large production game". Lock expiry is fixed at 30 minutes in source |
| **Lyra** (github.com/paradoxum-games/lyra) | v0.6.0 2025-07-08, last commit 2026-03-25 | Schema, named migration steps, auto-sharding across keys, `txAsync` multi-player transactions, bundled DataStore and MemoryStore mocks | README: "early development", avoid where loss "would be catastrophic". Locks live in a MemoryStore hash map |
| **DocumentService** (github.com/anthony0br/DocumentService) | v2.0.0-beta.1 2026-03-02, last commit 2026-09-09, 40 open issues | Strictly typed, Result errors, migrations, injectable DataStore | README claims production use at 156K CCU; v2 is beta |
| **DataStore2** | Last release 2021 | — | Docs: "legacy… shouldn't use it for new experiences" |

Roblox endorses no library. Its best-practices page says to review a module's maintenance and "understand how to access and migrate your data without the module". My judgment is that ProfileStore is the de facto standard by adoption, though its maintenance is quiet.

### 3. Save format

**Established:**
- Use one key per player when the data fits, and keep data that must change together in one key (Docs best-practices).
- Storage is counted compressed and Roblox says "avoid pre-compressing it yourself" (limits page).
- Buffers are a supported value type. `JSONEncode` turns them into base64 and "often compresses".
- `EncodingService:CompressBuffer` offers Zstd.
- Take an Open Cloud snapshot before publishing any change to save logic (versioning page).
- For migrations, Lapis documents the old-server problem: a player can load on a new server, then join an old one. The fixes are "Migrate To Latest Update" or backwards-compatible steps. Lyra says never to edit, reorder or remove a published migration.

**Not found:** any public developer statement on the save formats of Lumber Tycoon 2, Theme Park Tycoon 2, Welcome to Bloxburg or Islands. The only hits were Bloxburg's developer reporting DataStore reliability bugs in 2018–19, and one 2018 post by Lumber Tycoon 2's developer on nesting attribute tuples under each item id (devforum.roblox.com/t/116953/14), which does not name the game.

### 4. Offline progress

**Established:**
- `os.time()` is UTC seconds.
- `DateTime.now()` uses the device's clock.
- `GetServerTimeNow()` is the client's estimate and "not suitable for things like timed rewards".
- `DataStoreKeyInfo.UpdatedTime` is a backend timestamp.
- ProfileStore stamps `LastUpdate` with server `os.time()`.

**Not found:** any official guidance on offline progress.

**Recommendation:**
- Keep a `simulatedThrough` server timestamp in the same document as the state it governs, so a rollback rolls both back together.
- On load, compute elapsed time as now minus that stamp, clamped to zero and to a cap, apply it once as a pure function, then advance the stamp.
- Rejoining then grants only real elapsed time.
- Offline rates must never exceed online rates.

### 5. Shared numbers

| Service | Quota at low player counts | Notes |
|---|---|---|
| MemoryStore | 1000 + 120×CCU request units/min; 64 KB + 1.2 KB×users; values up to 32 KB; items expire within 45 days | `UpdateAsync` costs at least 2 units and retries on conflict. Hash-map keys allow about 5,000 writes/min. Sorted maps are advised under 1,000 keys |
| DataStore | 300 + CCU×20 writes/min for the whole experience | Durable and versioned; UpdateAsync is atomic per key |
| MessagingService | 1 kB messages; 600 + 240×players sent per server per minute | "Delivery is best effort and not guaranteed" |

Docs advise local caching, batching, random start offsets and jitter, and exponential backoff. For values that are only read across servers, they recommend Configs.

### 6. Duplication and rollback

**Established classes:**
- A stale load on a second server (docs).
- Purchases granted twice; the fix is to record `PurchaseId` in the same save (docs).
- Default data overwriting real data after a failed load (docs).
- Bypassing the lock with `Steal` (ProfileStore docs).
- Yielding between check and write: `IsActive()` holds "only until code yields" (ProfileStore).
- A two-party transfer where only one side persists; Lyra's transaction exists for this, and ProfileStore has no equivalent.

**Inference:** any save that can be made to fail is a rollback lever. Invalid UTF-8 or oversize player-authored data would do it. Validate and bound those before they enter state.

### 7. Testing

- **Studio:** data stores need "Enable Studio Access to API Services" and then hit the same stores as live, so use a separate test experience. MemoryStore is isolated in Studio.
- **Mocks:**
  - ProfileStore `.Mock`.
  - Lyra's bundled mocks.
  - buildthomas/MockDataStoreService (v1.0.3, 2023-03).
  - nezuo/data-store-service-mock, which is "not fully featured".
- **Runners:** Lune 0.11.1 (2026-10-21) and Roblox's rocale-cli v0.1.3 (2026-04-13).

### Direct answers

**(a) Library — recommendation.** Use ProfileStore, vendored and pinned, behind a narrow `SaveStore` port owned by the server layer.
- Version checks, migrations, validation and the encode/decode codec are our own pure functions in shared/Core, tested headless.
- ProfileStore supplies only locking, autosave and conflict handling, which is the part the docs call hard.
- The port keeps a move to Roblox's built-in system (Early 2027) or to Lyra cheap.
- Do not write our own locking.

**(b) Document — recommendation.**
- One key, `User_{UserId}`.
- Top-level fields: `v` (integer schema version), `simulatedThrough`, `ledgerSeq`, a `purchases` id ring, `inventory`, `plot`, `standing` and `hires`.
- Migrations are an append-only array of pure `vN → vN+1` functions, never edited once published.
- A save newer than the server refuses to load rather than downgrading.
- Take a snapshot before each schema release.
- Definition ids in saves are stable strings, never renamed.

**(c) Plot — recommendation.**
- Store a string table of definition ids plus one array of compact tuples per placed thing: definition index, tile x/y/z, rotation, and optional state and contents.
- Coordinates are plot-local integers.
- By my estimate, a few thousand things come to tens to low hundreds of KB as plain tables, far under 4 MB.
- Start with plain tables for inspectability, since Roblox compresses anyway. The codec sits behind the version number, so a buffer encoding can replace it later.

**(d) Shared numbers — recommendation.**
- One DataStore key per site is the durable truth.
- Each server accumulates deltas and flushes with one jittered UpdateAsync every 60–120 s, carrying a batch id so an unknown-outcome retry cannot double-count. It reads the fresh total from the return value.
- Roughly 50 servers at one flush a minute is about 50 writes against a budget of 300 + 20×CCU.
- MemoryStore is optional and only ever a cache, so an outage costs nothing durable.

**(e) Expensive to change after launch — established where sourced.**
- Data store name and key pattern (also needed for right-to-be-forgotten templates).
- One key versus several.
- The library's envelope around the data.
- Definition id strings and the coordinate convention.
- Published migrations.
- Ledger and purchase-id semantics.
- The meaning of timestamps.

## Researcher's direct answers (several are struck or narrowed by the check below)
- (a) Save library — RECOMMENDATION: use ProfileStore, vendored at a pinned copy, behind a narrow SaveStore port in the server layer; write our own version check, migrations, validation and codec as pure functions in shared/Core; do not write our own session locking. ESTABLISHED: ProfileStore is the successor to the unsupported ProfileService and is used by very large games, but has had no commit since 2025-07-31 and has no migrations or multi-profile transactions; Roblox's built-in session locking and transactions are roadmap items for Early 2027 and have not shipped; Roblox docs recommend no specific library and call DataStore2 legacy.
- (b) Per-player document — RECOMMENDATION: one key per player (User_{UserId}) holding an integer schema version, a simulatedThrough timestamp, a ledger sequence, a bounded purchase-id list, inventory, plot, standing and hires; migrations are an append-only list of pure vN-to-vN+1 functions that are never edited after release; a save newer than the server's version refuses to load; take an Open Cloud snapshot before each schema release. ESTABLISHED: Roblox docs advise one key per player when data fits in 4 MB and keeping data that must change together in one key; Lapis and Lyra document the append-only and old-server rules.
- (c) Plot storage — RECOMMENDATION: inside the player document, a string table of definition ids plus one array of compact tuples per placed thing (definition index, plot-local integer tile coordinates, rotation, optional state and contents); start as plain tables, with the codec behind the version number so a buffer encoding can replace it later. Size is my estimate (tens to low hundreds of KB for a few thousand things), not a sourced figure. ESTABLISHED: Roblox compresses values itself, counts compressed size and says not to pre-compress; buffers are storable. No public save-format statement from the four named building games was found.
- (d) Shared numbers at a few hundred players — RECOMMENDATION: one DataStore key per site as the durable truth; each server batches local deltas and flushes with one jittered UpdateAsync every 60-120 seconds carrying a batch id for idempotent retry, reading the new total from the return value; MemoryStore only as an optional cache so an outage loses nothing; MessagingService only for best-effort nudges. ESTABLISHED: the write budget is 300 + 20 x CCU per minute experience-wide, MemoryStore data expires within 45 days and MessagingService delivery is not guaranteed; docs advise batching, jitter and backoff.
- (e) Decisions that are expensive after launch — RECOMMENDATION with ESTABLISHED basis: the data store name and key pattern (also needed for right-to-be-forgotten templates), one key versus several, the library's envelope around the data (docs: understand how to migrate without the module), definition id strings and the coordinate convention used in saves, published migrations (never edit them), ledger and purchase-id semantics, and what each saved timestamp means. The byte-level codec, autosave interval and shared-number transport can change cheaply if the version number and the port exist from the first build.

## Not found
- Any public developer statement on the save format or save bugs of Lumber Tycoon 2, Theme Park Tycoon 2, Welcome to Bloxburg or Islands. Only found: Bloxburg's developer reporting DataStore reliability bugs in 2018-19, and a 2018 post by Lumber Tycoon 2's developer on nesting item attribute tuples (devforum.roblox.com/t/116953/14) that does not name the game.
- Official Roblox or staff guidance on computing offline progress from timestamps.
- Official guidance or a shipped API for saving two players atomically; built-in transactions are roadmap-only (Early 2027).
- Any announcement describing the 'Improved Data Stores (Beta)' item listed in the Spring 2026 roadmap (Mid 2026 to Late 2026).
- The maximum retry count for MemoryStore UpdateAsync, and the lock expiry used by Roblox's sample player-data code.
- A maintainer response to ProfileStore PR #22 (buffer aliasing); only a third-party approval was visible.
- How large real plots are in comparable games; the plot size figures in the report are my own estimate.
- Star counts and open-issue lists for Lune, jest-lua and TestEZ (GitHub API rate limit reached; release and commit dates were read from the repositories' feeds instead).
- The project notes on disk contain no section on trading rules or shared-number design beyond 'community goals at fixed sites', so the recommendations assume player-to-player transfers happen on one server.

## Independent check

13 of 14 key facts confirmed.

### Facts corrected
- **partly wrong:** 12. Workspace:GetServerTimeNow is the client's approximation and 'not suitable for things like timed rewards'; os.time() returns UTC seconds; DateTime.now() uses the device's local clock; DataStoreKeyInfo.UpdatedTime is a backend timestamp.
  - Correction: The contrast between os.time() and DateTime.now() is false. The os.time page says it "uses the device's local clock" in the same words as DateTime.now(), and adds "This function should be avoided in new work. Instead, use the DateTime API." On a server both read that server's clock, so the injected clock should wrap DateTime.now().UnixTimestamp, and two servers' clocks can disagree slightly (the brief's clamp to zero covers that). The GetServerTimeNow quotes are accurate; the warning is about trusting it on the client. UpdatedTime is documented only as service-defined, read-only, milliseconds since epoch; "backend timestamp" is a fair inference, not a quoted statement, and it is in milliseconds where os.time is seconds.

### Conclusions that go beyond the evidence
- (a) "The port keeps a move to Roblox's built-in system (Early 2027) or to Lyra cheap." Nothing public describes the built-in system's API or stored format; the only source is one roadmap line, and the same post lists 32 delayed items. A port makes the code swap cheap, not the data move: ProfileStore stores its own envelope and lock state around the data, and answer (e) itself lists that envelope as expensive to change.
- (a) "the part the docs call hard" is not in the docs. The best-practices page says third-party modules "in many cases may be preferred to building systems from scratch", and the player-data guide warns that Roblox's own sample is unproven. "Used by very large games" is listed as established but rests on the author's own list of two games.
- (a) "Do not write our own locking" is sound as a recommendation, but the evidence shows every option is imperfect, not that ProfileStore is safe: it has had no commit since 2025-07-31, has five unmerged PRs including the buffer fix (#22) and a new-type-solver fix (#19), and has no releases to pin to.
- (b) "A save newer than the server refuses to load" is given without its operating cost. Per Roblox's release page and Lapis's docs, old servers persist until empty, so every schema release then needs a restart of outdated servers (or a backwards-compatible flag), or returning players are refused. That restart teleports whole servers at once, which is the hand-off case session locking exists for.
- (b) The top-level field list (ledgerSeq, purchases ring, standing, hires, simulatedThrough) is the researcher's design, not sourced. Only the purchase-id list has support (Roblox's guide, and ProfileStore's docs with a cache of 100). Putting all of them in the first schema also conflicts with the project's rule against adding fields ahead of need.
- (c) "Start with plain tables ... since Roblox compresses anyway" overstates what compression buys. It reduces only the storage quota; the 4,194,304 cap and the 4 MB/min write limit apply to the serialized JSON. The size figure is an unsourced estimate, as the brief says.
- (c) "A buffer encoding can replace it later" omits that the pinned ProfileStore copies buffers by reference (fact 8, confirmed in source). A buffer in the template or mutated in place would alias across profiles and LastSavedData unless the vendored copy is patched.
- (e) "The byte-level codec ... can change cheaply if the version number and the port exist." A codec change is a format change that old servers cannot read, so it carries the same restart requirement as any migration. Cheap in code, not in operations.
- Section 4, by way of fact 12: the brief treats os.time() as the safe server clock and DateTime.now() as a device clock. The docs describe both as the device's local clock and steer new work to DateTime.

### What the brief missed
1. Scoped user IDs. https://create.roblox.com/docs/players/users.md (last_updated 2026-11-19) says they have "not rolled out broadly yet"; the staff thread https://devforum.roblox.com/raw/4677155/1 (update 2026-09-01) deferred the timeline. After rollout every player of a new game gets a per-game ID, and Player.UserId returns it. Keys of the form User_{UserId} still work inside one game, and the docs show exactly that. But the same account will have a different ID in a separate test experience, and anything read outside the game should store User:ToString(). This belongs in the "expensive after launch" list.

2. ProfileStore cannot run headless. At require time it calls DataStoreService, MessagingService, RunService.Heartbeat and game:BindToClose (ProfileStore.luau lines 316-334, 2115, 2199), and Lune implements none of these. So ProfileStore.Mock is a Studio-only tool. The no-live-game tests need a hand-written in-memory fake behind the SaveStore port, which justifies the port on a present need (testing), not on a future library swap.

3. Array shape rules hit answer (c). ProfileStore's header warns that numeric tables with gaps error on save and that mixed tables lose their string keys; Roblox's JSONEncode page says to avoid nil at any index. Tuples with "optional state and contents" must therefore never leave a nil hole; use a sentinel or put optional fields last.

4. Strict typing and the vendored file. PR #19 "New Type Solver Fix" is unmerged and Wally carries forks made only to fix type errors under the new solver. Check the vendored module under the pinned luau-lsp and exclude it from Selene and StyLua.

5. Profile.Data is a plain mutable table whose save guarantee holds "only until code yields". The single validated mutation path has to be the only writer and must not yield between the IsActive check and the write.

6. After a server crash a rejoining player can wait up to SESSION_STEAL (40 s) before the session is stolen; the author confirms this in thread post 292. The loading screen on a phone has to allow for it.

7. Coordinates. "Plot-local integer tiles" does not cover things built on a vehicle or creature deck, or items set down off-grid, both of which are in the project notes. The coordinate convention is on the expensive-to-change list, so it needs an answer before the first save ships.

8. Minor: DataModel.ServerLowMemoryWarning (staff post https://devforum.roblox.com/raw/4972486/1, 2026-11-02) fires before an out-of-memory crash and could trigger an early save. In Studio with API access on, ProfileStore also writes a probe key to a data store named "____PS".


---

# C. Tooling and testing

## Tooling brief: strict Luau core, testable without Studio

Read on 2026-11-18. "Established" means read in this run (URL given). "Recommendation" is mine. Local measurements used the already-installed tools on a scratch copy; nothing in the project was changed and nothing was installed.

### 1. Running Luau outside Studio (established)

| Runtime | Current | Install | What it is |
|---|---|---|---|
| Lune | v0.11.1, 2026-10-21; Luau 0.740 as of 0.11.0 (github.com/lune-org/lune/releases) | `rokit add lune` (lune-org.github.io/docs/getting-started/1-installation) | General runtime with fs, process, task, serde, roblox libraries |
| Luau CLI | 0.747, 2026-11-13 (github.com/luau-lang/luau/releases) | Release binaries; jecs pins `luau = "luau-lang/luau@0.703.0"` in rokit.toml | `luau` is sandboxed: no file access except `require`; `luau-analyze` type-checks |
| Lute | Only nightly pre-releases listed (v1.0.1-nightly.20261119) | Release binaries | Luau team's runtime; has `lute test` and `@std/test` (lute.luau.org/guide/writing-tests); README says 1.0.0 is a stable base but not a finished product |

- **Lune's roblox library** reads and writes place and model files and offers a limited Instance API (new, Clone, Find*, attributes, tags, GetService) plus datatypes. Nothing on its API-status page covers RunService, signals or running game scripts (lune-org.github.io/docs/roblox/4-api-status).
- **Lune require:** relative to the requiring file; tries `x.luau`, `x.lua`, `x/init.luau`; `@self` inside init.luau; aliases from `.luaurc`; case-sensitive even on Windows (docs/the-book/7-modules). Since 0.10.0 it follows Luau's require-by-string semantics.
- **Differences that bite:**
  - Luau's standard library has no `task`, `Random`, `warn`, `tick`, `wait`, `game`, `Instance` or `DateTime` (luau.org/library).
  - In Lune, `task` is not a global; it is `require("@lune/task")`.
  - Lune lags Luau (0.740 against 0.747).

### 2. Test frameworks (established)

| Framework | Status | Runs where |
|---|---|---|
| Jest Roblox (Roblox/jest-roblox) | Pushed 2026-11-10; README pins 3.20.0; "We use Jest Roblox at Roblox" | Inside Roblox only. Roblox's docs run it with internal `roblox-cli` and `EnableLoadModule=true` |
| Jest Lua (jsdotlua/jest-lua) | v3.10.0, 2024-12-23, no push since | "can currently only run inside of Roblox"; needs `FFlagEnableLoadModule` and run-in-roblox (last push 2024-03-06). Decoupling issue #2 still open |
| TestEZ | Archived 2024-09-14 | Roblox only |
| frktest | 0.0.2; last push 2025-09-08; 14 stars | Lune, by a hand-written entry file; no discovery |
| Own harness | jecs and vide both run `luau test/tests.luau` in CI | Bare Luau CLI |

- **Studio's built-in MCP server** exposes `execute_luau` (Edit, Server or Client data model), `get_console_output`, `start_stop_play` and `get_studio_state` (create.roblox.com/docs/studio/mcp, updated 2026-11-19). It is workable for integration tests, but needs Studio open.
- **Open Cloud Luau Execution** runs scripts headless in a place: 5-minute limit, 10 incomplete tasks per place, no physics, scripts do not auto-run (create.roblox.com/docs/cloud/reference/features/luau-execution).

### 3. Type checking in a terminal

**Established**
- `luau-lsp analyze [--platform] [--sourcemap PATH] [--definitions @NAME=PATH] [--base-luaurc] [--flag:KEY=VALUE] files` (local `--help`, 1.70.1).
- The sourcemap comes from `rojo sourcemap default.project.json --output sourcemap.json`.
- Roblox definitions are `scripts/globalTypes.d.luau` in the luau-lsp repo. `--platform=roblox` without definitions warns (changelog 1.52.0).
- **Measured locally:** `luau-lsp analyze --platform=standard` reports `Unknown global 'game'` and `Unknown global 'task'`, resolves `require("./Other")` with no sourcemap, and exits 1.
- **New solver in Studio:** general release announced 2025-11-20 (devforum.roblox.com/t/4084991). It is on by default only for nocheck and nonstrict projects. Strict projects stay on the old solver unless `Workspace.UseNewLuauTypeSolver` is Enabled. The old engine is kept "through 2026".
- **Known strict-mode issues in that post:** verbose errors, performance and memory, and places where strict is "too strict". August 2026 release notes still list soundness and crash fixes (create.roblox.com/docs/updates/2026-08-24).
- **luau-lsp:** 1.70.1 uses the old solver by default; the Unreleased changelog entry switches `analyze` to the new solver (opt out with `--flag:LuauSolverV2=false`).
- **Pitfalls named by staff (2025-04-09, devforum raw/3155804/226):** mismatches between an annotated type and a table literal; refinement and assignment bugs; "constraint solving failed to complete"; type functions failing on cyclic types.

**Recommendation.** Write strict against the new solver from day one, since there is no legacy code and the old engine's guarantee ends this year. Pin the flag explicitly in the check command so a tool upgrade changes nothing silently. Put `--!strict` on every file.

### 4. Require styles (established)

| Form | Roblox | Lune | luau-lsp |
|---|---|---|---|
| `./x`, `../x` | Yes, since 2025-01-22 | Yes | Yes |
| `@self/x` | Yes, since 2025-05-20; `Init` special-casing removed | Yes, in init.luau | Yes (1.66+) |
| `@game/...` | Yes, since 2026-01-08 | No | Yes, from the sourcemap (1.65+) |
| Custom aliases (`.luaurc`) | Not released: "currently working on" (staff, 2026-01-08); nothing later found | Yes | Yes |
| `script.Parent.X` | Yes | No | Yes, with sourcemap |

Roblox string requires do not wait for replication (devforum raw/3405078/1). Rojo maps `init.luau` to a ModuleScript and plain `.luau` to ModuleScripts (rojo.space/docs/v7/sync-details). Only relative paths and `@self` work unchanged in all three.

### 5. Packages (established)
- **Wally:** latest stable is 0.3.2; v0.4.0-alpha.1 published 2026-10-12.
- **pesde:** v0.7.4, 2026-09-09; targets Roblox, Lune and Luau; can consume Wally packages.
- jecs and vide ship both manifests.

### 6. Networking helpers (established)
| Library | Status | Kind |
|---|---|---|
| Zap | v0.6.29, 2026-06-23; README: early pre-release, "API may change" | IDL to generated Luau, buffer packing, validates received data; output to `network/` |
| Blink | v1.0.0-pre.11, 2026-11-07; `rokit add 1Axen/blink` | IDL compiler written in Luau; buffer code; server validates client data |
| ByteNet | Last release v0.4.3, 2024-03-10; last push 2025-08-01 | Runtime library, no codegen |

### 7. ECS (established)
- **jecs:** v0.11.0, 2026-03-10; pushed 2026-10-22; archetype storage, relationship pairs; README claims 800,000 entities iterated at 60 fps. Idiom: `world:component()`, `world:set(e, pair(A, B), v)`, `for e, v in world:query(...)`.
- **Matter:** last release v0.8.5, 2024-12-09; the original evaera/matter is archived.
- No source compares readability; that judgment is in the answers.

### 8. Data definitions (established)
- Rojo turns `.json`, `.toml`, and since 7.6.0 `.yaml` into ModuleScripts returning tables; `.jsonc` since 7.7.0-rc.1.
- luau-lsp types JSON, TOML and YAML requires (changelog 1.30.0, 1.59.0).
- Lune's `require` only resolves `.luau`, `.lua` and init files, so JSON definitions would need a second loader under test.
- StyLua formats Lua and Luau only; Selene lints `*.lua` and `*.luau`.
- Published runtime validators: `t` (osyrisrblx/t; `t.interface`, `t.strictInterface`), Typed (devforum 4732434), Luau Schema Validator (devforum 3426387).

### 9. Conventions in open-source codebases (established)
- **jecs:** `src/`, `test/`, `.luaurc`, `rokit.toml`; CI runs `luau test/tests.luau` with a 2-minute job timeout and checks for "0 fails".
- **vide:** `src/`, `test/`; CI downloads the Luau CLI and runs `bin/luau test/tests.luau`.
- **RbxUtil:** CI runs `selene ./modules` and StyLua `--check ./modules`; its Open Cloud test job is commented out.
- **Rojo:** contributors run `stylua --check` and `selene` before a pull request; tools pinned with Rokit.
- **Matter:** release pull requests are "Squash and merge"; CHANGELOG kept accurate; has `.git-blame-ignore-revs`.
- No surveyed repo documents a commit-message convention.

### Timing (measured locally)
60 synthetic strict files, about 46,000 lines:

| Check | Time |
|---|---|
| `stylua --check` | 0.33 s |
| `selene` | 0.31 s |
| `rojo sourcemap` | 0.15 s |
| `luau-lsp analyze --platform=standard`, old solver | 0.50 s |
| Same, `--flag:LuauSolverV2=true` | 1.57 s |

Not measured: analyze with Roblox definitions loaded, and Lune test runs.

Scratch files: `(session scratchpad)` and the `df_*.txt` posts beside it.

## Researcher's direct answers (several are struck or narrowed by the check below)
- (a) What runs the core's tests, and what must be installed. ESTABLISHED: Jest Lua and TestEZ cannot run outside Roblox (Jest Lua's README says so; TestEZ is archived); Lune 0.11.1 installs with `rokit add lune`; jecs and vide test engine-free code with a small harness of their own on the bare Luau CLI. RECOMMENDATION: install one tool, Lune, pinned in rokit.toml, and write a harness of about 100 lines in the repo (describe, it, expect-equal, a failure count). Only the entry script touches `@lune/fs` (to find `*.spec.luau`) and `@lune/process` (to exit non-zero). Spec files and the core use nothing outside luau.org/library, so the same specs can later be run inside Studio through the MCP `execute_luau` tool as a second check on the real VM. Do not adopt Jest or frktest. Keep Studio MCP tests for the server binding only; they are not a pre-commit check.
- (b) Require style and layout. ESTABLISHED: only `./`, `../` and `@self/` resolve identically in Roblox, Lune and luau-lsp; custom aliases are not released in Roblox and `@game` does not exist in Lune. RECOMMENDATION: in `src/shared/Core` and `src/shared/Defs` use relative string requires only, with no aliases, no `@game`, no `script`, and no init.luau files (or only thin ones using `@self/`). Core takes its clock and randomness as injected values and ships its own small seeded generator in pure Luau, because `Random`, `task` and `os`-based time differ or are missing off Roblox. Put specs in a top-level `tests/` folder that requires `../src/shared/Core/...`, so nothing test-related ships to clients. `src/server` and `src/client` may use `@game/...` or Instance requires. Enforce the boundary mechanically by running `luau-lsp analyze --platform=standard` on Core, Defs and tests, which fails on any engine global (verified locally).
- (c) ECS, networking library, package manager. ESTABLISHED: jecs is active but pre-1.0 and built for iterating hundreds of thousands of entities; Matter is stale; Zap calls itself early pre-release, Blink is at 1.0.0-pre.11, ByteNet has had no release since March 2024; Wally's stable release is 0.3.2 and pesde is at 0.7.4. RECOMMENDATION: none of the three at the start. The design already names an entity store with one validated mutation path and a ledger; an ECS world that any system can write to works against that, and its ids, pairs and queries would appear in every system for a scale (6 to 12 players) that does not need archetype storage. For networking, write one typed Net module over RemoteEvents with hand-written validators and intents as plain data, so a generated buffer layer (Blink is the most active) can replace the transport later if measured bandwidth calls for it. With zero dependencies there is nothing for a package manager to manage; vendor a single-file module if one is ever needed.
- (d) Definition format. ESTABLISHED: Rojo and luau-lsp both handle JSON, TOML and YAML, but Lune's require does not load them, and StyLua and Selene ignore them. RECOMMENDATION: Luau tables in `.luau` files, one file per kind (or per region once they grow), each entry built through a typed constructor or assigned to an annotated local so strict mode checks every field. This gives one loader in both runtimes, comments, formatting and linting, and one-entry-per-hunk diffs. Types cannot check cross-references, so add a pure-Luau validator in Core (every id referenced by a process, people or placeable exists; stack sizes positive; no duplicate ids) that runs in the test suite and at server start. A library such as `t` is unnecessary for this. One known hazard: the new solver has had false mismatches between annotated types and table literals (staff post, April 2025), which the constructor-function form sidesteps.
- (e) Smallest pre-commit set and its cost. ESTABLISHED: Rojo's and RbxUtil's own gates are `stylua --check` and `selene`; measured locally on about 46,000 lines these take 0.33 s and 0.31 s, sourcemap generation 0.15 s, and a standard-platform analyze 0.5 s (old solver) or 1.6 s (new). RECOMMENDATION, in this order: (1) `stylua --check src tests`; (2) `selene src tests`; (3) `luau-lsp analyze --platform=standard` on Core, Defs and tests; (4) `rojo sourcemap default.project.json --output sourcemap.json` then `luau-lsp analyze --platform=roblox --sourcemap sourcemap.json --definitions=@roblox=<globalTypes.d.luau>` on `src`; (5) `lune run` on the test entry script. My estimate for the whole set is under 10 seconds at this project's early size; the two unmeasured parts are loading the Roblox definitions file and the Lune run. Two things need the owner's approval before this works: adding Lune to rokit.toml and downloading `globalTypes.d.luau` once.

## Not found
- Whether Roblox has released custom require aliases or .luaurc support in Studio after the staff post of 2026-01-08; no later announcement was found.
- An official sunset date for the old type solver beyond 'through 2026', and any Roblox statement later than 2025-11-20 on whether strict mode on the new solver is now recommended. Staff replies in the general-release thread could not be read (DevForum rate limit).
- Any Lune page comparing its task library with Roblox's, or stating outright that Lune cannot run game scripts; the conclusion rests on what the API-status page lists.
- Run time of a Lune test suite and of luau-lsp analyze with Roblox definitions loaded; Lune is not installed and the definitions file was not downloaded.
- Whether the exact form `--definitions=@roblox=PATH` is accepted as written; it is taken from the help text and changelog, not executed.
- A documented commit-message or history convention in jecs, vide, RbxUtil, Rojo, Matter or Nevermore; only Matter's 'Squash and merge' for release pull requests was found.
- Any sourced comparison of ECS readability against plain tables; that part of answer (c) is judgment.
- The exact file names Zap generates, and any stability statement from Blink or pesde.
- A port of Jest Lua to Lune; issue #2 (decouple from Roblox) is still open with a last comment on 2025-06-14.
- Whether Selene supports a different standard library per directory; only the `--config` flag is documented.
- Status of the 'tiniest' test library (repository path returned 404) and a stable, non-nightly Lute release (GitHub API rate limit reached).
- Confirmation that Lune's release includes a Windows x86_64 binary; inferred from the Rokit and Scoop instructions and the 0.10.2 note adding Windows on ARM.

## Independent check

13 of 17 key facts confirmed.

### Facts corrected
- **partly wrong:** 9. Jest Lua runs only inside Roblox, needs FFlagEnableLoadModule plus run-in-roblox (last pushed 2024-03-06), last release v3.10.0 2024-12-23; Roblox/jest-roblox pushed 2026-11-10, used internally, run with internal roblox-cli; TestEZ archived 2024-09-14.
  - Correction: All dates and the Jest Lua requirements check out. The one error: the current jest-roblox README (pins 3.20.0) says it runs "within Roblox itself, including via Roblox's OCALE (Open Cloud API for Luau Execution) for testing on CI systems". roblox-cli appears only on the older docs site, whose install steps pin 3.12.0. So there is a public headless route for Jest Roblox, though it still runs on Roblox's servers and is not a pre-commit check.
- **partly wrong:** Brief table: Lute has only nightly pre-releases listed (v1.0.1-nightly.20261119).
  - Correction: A stable v1.0.0 exists, released 16 April, marked Latest, described as "our first stable release version of Lute". The nightlies are 1.0.1 builds on top of it. `lute test` and `@std/test` are confirmed (test.case, test.suite, asserts.eq, filters by case, suite or file). The README still says Lute is not a finished product.
- **partly wrong:** Brief table: frktest is at 0.0.2, last push 2025-09-08, 14 stars.
  - Correction: Latest release is 0.0.4 (2025-09-08). Push date and stars are right.
- **partly wrong:** Answer (d): annotating each definition (typed constructor or annotated local) makes strict mode check every field.
  - Correction: Missing required fields and wrong value types are reported. Unknown or misspelled keys are not: `{ id = "a", stack = 1, stak = 2 }` and `tgas = {...}` on a type with optional `tags` pass silently in both solvers, in both the annotated-local and constructor forms. A typo in an optional field name is therefore invisible to the type checker.

### Conclusions that go beyond the evidence
- Answer (a): "the same specs can later be run inside Studio through the MCP execute_luau tool". Nothing read supports this, and it conflicts with answer (b). Specs in a top-level tests/ folder require `../src/shared/Core/...`, a path that does not exist in the DataModel (default.project.json maps only src/shared, src/server and src/client), and no source shows execute_luau resolving relative string requires from a code string. It would need a separate test project file that mirrors the folder shape, or specs that receive the module under test as an argument.
- Answer (a): "Jest Lua and TestEZ cannot run outside Roblox" is listed as established. It is established for Jest Lua. For TestEZ the evidence is only that it is archived; its README says it also runs inside Lemur. The conclusion (do not use it) stands, the stated reason does not.
- Answer (a): Lute's built-in `lute test` is dismissed without being weighed, on a status description that is wrong (a stable 1.0.0 exists). The own-harness recommendation may still be right, since `@std/test` specs could not run in Studio, but the comparison was not made.
- Answer (b): "only ./, ../ and @self/ resolve identically in Roblox, Lune and luau-lsp" is listed as established. The sources show all three accept these forms, not that they resolve identically. Two gaps: on this Windows machine luau-lsp resolved `require("./store")` to Store.luau and passed, while Lune's docs say paths are case-sensitive and Roblox names are too; and Lune's own docs contradict themselves on `./` versus `../` inside init.luau. Lune was never run.
- Answer (d): the new-solver table-literal hazard "which the constructor-function form sidesteps". The staff post (2025-04-09, beta period) says nothing about constructor functions, and locally the two forms gave the same diagnostics under both solvers.
- Answer (d): "A library such as `t` is unnecessary" rests on the claim that types check every field. Since unknown keys pass the type checker, the validator must reject unknown keys itself. That is what `t.strictInterface` does; hand-writing it is fine, but it has to be in scope.
- Answer (e), step 3: `luau-lsp analyze --platform=standard` on tests will fail on the Lune entry script. Locally, `require("@lune/fs")` gives "Unknown require" and exit 1. It needs Lune's type definitions and an alias (Lune's docs: `lune setup` generates them and creates or updates `.luaurc`), or the entry script excluded with --ignore. So the list of things needing the owner's approval is short by one.
- Answer (e), step 4 and the "under 10 seconds" estimate: the Roblox-platform command was never run, the security-level variant of the definitions file is not chosen, and compatibility of a main-branch definitions file with the pinned 1.70.1 binary is unchecked. The estimate is labelled as one, but its largest part (new solver plus Roblox definitions on real code) is the unmeasured part.
- Section 3 recommendation (new solver from day one): labelled as a recommendation, and supported in direction by the luau-lsp Unreleased entry. But the staff post it leans on also says strict mode is where the known problems are, and Studio will keep a strict project on the old solver unless the Workspace property is set. The brief should say that the property must be set in the place, or Studio and the terminal check will disagree.

### What the brief missed
Five things an architect would want, all from this run.

1. Unknown keys in definitions are not type errors (verified locally, both solvers). The def validator must reject unknown keys, or a misspelled optional field ships silently.

2. The purity gate has a case-sensitivity hole on Windows. luau-lsp accepted `./store` for Store.luau; Lune and Roblox would not. Only a test that loads the module, or Studio, catches it.

3. Keep Lune's alias out of Core. A `.luaurc` placed in tests/ (not the repo root) let the entry script resolve `@lune/*` while `require("@lune/fs")` from src/shared/Core still failed analyze. A root-level `.luaurc`, which is what `lune setup` may write, would let Core import Lune libraries without the gate noticing.

4. The old solver gave three misleading errors for one missing field inside a `{ [string]: ItemDef }` map literal; the new solver gave one clear error. That is concrete support for checking definitions with the new solver, and a reason to decide the solver before writing defs.

5. Jest Roblox has a public headless route (Open Cloud Luau Execution, per its README), and Lute 1.0.0 is a stable release with a built-in test runner. Neither changes the pre-commit recommendation, but both are real options for a later CI check on the real VM that the brief presents as unavailable or immature.

Also untested because Lune is not installed: everything about how Lune actually behaves (init.luau relative requires, JSON requires, run time). The first task after it is installed should be a ten-minute probe of those three.

My probe files are in (session scratchpad) Nothing in C:\Users\tate\Documents\dev\roblox was changed and nothing was installed.


---
