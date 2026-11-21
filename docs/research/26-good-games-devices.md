# What devices Roblox players use, and what a game can afford on them

Asked: what share of play is on which devices, what Roblox documents as performance limits, what streaming and server traffic cost, and what usually makes building games slow.
Made by one reader on Sonnet, 2026-11-21, from Roblox's documentation pages (fetched as plain text, summarised by a fetch tool), one DevForum post by Roblox, one trade-press report of Roblox's annual report, and search snippets of analyst reports.

## What the sources say

### 1. Share of play by device

- Roblox's own figure found: for 2024, mobile was 80% of daily active users, PC 17%, consoles 3% (full-year average). This is a press report of "Roblox's annual report", not the report itself. https://www.pocketgamer.biz/80-of-roblox-users-are-on-mobile-contributing-46-of-robux-revenue/ (2025-04-23)
- Same split appears at Statista, "December 2024": mobile 80%, desktop 17%, console 3%. https://statista.com/statistics/1190919/roblox-games-users-global-distribution-platform (snippet only, page not opened)
- Those are players, not hours, and "mobile" is phones and tablets together. No Roblox-published split of phone and tablet was found.
- Hours (not Roblox's own): the analyst firm Newzoo, via Windows Central, gave about 11.5 billion of about 14 billion monthly hours in Q3 2025 as mobile and 2.5 billion as PC plus console. The 82%/18% ratio is arithmetic from a search summary, not a stated figure. https://www.windowscentral.com/gaming/oof-roblox-has-as-much-player-engagement-as-steam-playstation-and-fortnite-combined-and-now-its-even-nipping-at-netflixs-heels (snippet only)
- GameAnalytics (2025 report, via search snippet): 44% of players used both mobile and PC in the year, about 40.8% PC only, about 11.6% mobile only, 0.43% console only, 3.69% used a console at all. It counts every device used at least once. https://www.gameanalytics.com/cn/reports/2025-roblox-report
- Roblox's Q3 2026 shareholder letter, read as extracted text, has no device split. https://s27.q4cdn.com/984876518/files/content_files/Q3-2026-Earnings-Shareholder-Letter.pdf
- Roblox's "Test on hardware" page says Android is "roughly 65%" of a typical game's player base. Of Android players, about 60% have 2-4 GB RAM, about 35% have 4-8 GB, about 5% more than 8 GB. It also says "over 50%" of players are on devices scoring 10,000-20,000 on Passmark. No date shown. https://create.roblox.com/docs/en-us/performance-optimization/test-on-hardware.md

### 2. Performance limits and targets in the docs

- Frame budget: "At 60 FPS, the total budget for each frame is 16.67 milliseconds." Client frame rate cap is 60 FPS by default; Windows users can raise it to 240. Server heartbeat is capped at 60 FPS. https://create.roblox.com/docs/en-us/performance-optimization/design.md (page updated 2026-11-20); https://create.roblox.com/docs/en-us/performance-optimization/identify.md
- Draw calls and triangles: the design page gives "stay below 1,000 draw calls and 1,000,000 triangles" as an example for a chosen baseline device, not a universal limit. Same page, 2026-11-20.
- Memory on low-end phones: no figure. The docs say such devices have "severe memory limitations" and tell you to pick a low-end baseline device and test on it. Same page.
- Draw distance: at the lowest quality level it is at least 500 studs. Same page.
- Part counts and moving assemblies: no limit given on the design, identify, improve or scene-analysis pages.
- Server memory: keep below 50% of `6.25 GiB + (100 MiB * largest number of connected players)`. Example given: 30 players gives about 9.18 GiB. Memory grows with joins and is not released when players leave. https://create.roblox.com/docs/en-us/performance-optimization/identify.md
- Crash rate: investigate if it rises "above 2-3%". Same page.
- Texture memory: a 1024x1024 texture uses four times the graphics memory of a 512x512 one. https://create.roblox.com/docs/en-us/performance-optimization/improve.md
- How to measure:
  - MicroProfiler: check whether frames exceed 16.67 ms; spikes are the key sign (identify page).
  - Developer Console (F9): Memory tab for client memory, Server Jobs tab, Heartbeat, "Steps Per Sec" for server rate. Use a real client, not Studio.
  - `Shift F5` shows the debug stats summary on the client. Studio numbers are skewed.
  - Scene analysis view: triangle and draw-call breakdown by pass (shadows, opaque, transparent, terrain, particles, UI), instance counts, script memory. It says its numbers may not match what players see. https://create.roblox.com/docs/en-us/performance-optimization/scene-analysis.md
  - Memory under test: emulators are not accurate for memory. Test 10-15 minutes on a phone to see thermal throttling (test-on-hardware page).

### 3. Instance streaming (`Workspace.StreamingEnabled`)

- What it does: loads and unloads `Workspace` content by region. On by default for new places. Stated benefits: faster joins, lower memory, better performance. https://create.roblox.com/docs/en-us/workspace/streaming.md
- Defaults: `StreamingTargetRadius` 1024, `StreamingMinRadius` 64. Docs say keep the defaults. Target should be larger than min, or there is no buffer and network pauses can occur. Same page.
- Recommended settings: `StreamingIntegrityMode = PauseOutsideLoadedArea`, `ModelStreamingBehavior = Improved`, `StreamOutBehavior = Opportunistic` (lowers memory and out-of-memory crashes). `Model.ModelStreamingMode` defaults to `Nonatomic`; `Atomic`, `Persistent`, `PersistentPerPlayer` exist. Same page.
- Costs listed:
  - Larger `StreamingMinRadius` needs more memory and server bandwidth.
  - Each replication focus adds server work; one player with nine moving foci is "comparable to ten players".
  - Persistent models are never streamed out; overuse may hurt performance.
  - Many instances streaming together as moving assemblies can cause network and CPU spikes.
  - Streamed-out instances are parented to nil; local-only property changes can be lost.
  - Client physics runs only in streamed areas.
- For many dynamic parts (techniques page): spawn on the server, not as client-only copies; keep dynamic parts out of atomic models; group spawned parts in small models, each under about 64 cubic studs; `ChildAdded`/CollectionService signals fire again on stream in and out; `Touched`, `ProximityPrompt`, `ClickDetector` do not work for a player who lacks the part; `GetChildren()` on a client returns only streamed-in parts. The page says it gives no per-part memory or CPU figures. https://create.roblox.com/docs/en-us/workspace/streaming/techniques.md

### 4. Limits on what a server sends and receives

- Client to server: about 500 `FireServer()` calls per second per client, shared across all remote events of the same type, for both `RemoteEvent` and `UnreliableRemoteEvent`. https://create.roblox.com/docs/en-us/reference/engine/classes/UnreliableRemoteEvent.md and .../RemoteEvent.md (no date shown)
- Excess `RemoteEvent` messages are delayed and processed in order; excess `UnreliableRemoteEvent` messages are dropped. Queues for `RemoteEvent` and `RemoteFunction` are limited "in both count and memory"; no figures. https://create.roblox.com/docs/en-us/scripting/events/remote.md
- Size: an `UnreliableRemoteEvent` payload over 1000 bytes is dropped. No size limit was found for `RemoteEvent`. Buffers are compressed, so the size is hard to predict. Same pages.
- Physics replication: no rate or size figure found. The network-ownership page says the server owns unanchored parts by default and may hand them to a nearby client; Roblox cannot verify physics run on client-owned parts. https://create.roblox.com/docs/en-us/physics/network-ownership.md
- Players per server: `Players.MaxPlayers` is set only in place settings, and the page gives no number. https://create.roblox.com/docs/en-us/reference/engine/classes/Players.md A Roblox post of 2023-04-13 says 200 players per server for all experiences, with a beta that had allowed 700. https://devforum.roblox.com/t/experience-join-improvements-server-size-join-queues-and-social-slots-reservations/2294621 (read as JSON)

### 5. Usual causes of bad performance, and the fixes

All from Roblox docs unless marked.
- Unanchored parts: "Anchor all parts that don't need to be driven by physics." Reduce joints and constraints per assembly. https://create.roblox.com/docs/en-us/performance-optimization/improve.md
- Awake parts: many awake parts slow the game; anchored parts are always asleep; use Show Awake Parts to check. Roblox post, 2019-05-17: https://devforum.roblox.com/t/physics-best-practices/280812
- Welds: Roblox's 2019 post calls surface joints and welds legacy and unsupported, with constraints as the supported route. The improve page does not mention welds. A forum thread says legacy welds cost only when unanchored and `WeldConstraint` does not; that is a user's claim. https://devforum.roblox.com/t/do-welds-cause-unnecessary-lag/1559762 (snippet only)
- Many scripts per object: the improve page does not name this. It names per-frame `RunService` work (use sparingly), connections never disconnected, and table entries never removed.
- Collisions: each contact point costs; disable collision or use `NoCollisionConstraint`; a part with a `Touched` listener still makes contacts when `CanCollide` is false. Precise collision fidelity is the most expensive; use box or hull. Union and MeshPart fidelity: same sources.
- Unions: the improve page does not address unions. The 2019 post says unions generate collision geometry and suggests Hull or Box. A CSG forum post (snippet) says many unique models and unions bottleneck the CPU; not read in full.
- Transparency: partial transparency near other parts causes overdraw; the design page says use only 0 and 1.
- Draw calls: decals, textures, particles batch poorly; meshes with the same mesh and texture draw in one call, so upload once and duplicate; reduce `CastShadow` on small parts.
- Physics step: fixed stepping runs all assemblies at 240 Hz; adaptive steps at 60, 120 or 240 Hz. Use adaptive.
- Networking: do not replicate every frame; do not send big payloads at once; chunk large instance trees; tween on the client, not server.
- Many creates and removes: `updateInvalidatedFastClusters` over 4 ms in the MicroProfiler signals too many invalidations; pool models.

## Where the sources disagree, or are weak

- Roblox's own device share was found only second-hand (a 2025 press report of the 2024 annual report). The primary filing was not read. The 10-K for FY2025 was not opened.
- Players (80/17/3) and hours (about 82/18 by arithmetic) are different measures from different sources. GameAnalytics counts any device used in a year, and Newzoo's hours exclude the youngest players, per the search summary.
- Server size: the 2023 post says 200; the `Players` page gives no number; forum snippets mention 60 and 700 without Roblox confirming a current value.
- The 1,000 draw calls and 1,000,000 triangles figure is an example in the docs, not a limit.
- The "about 2,000 unanchored parts" claim is one forum user's, unsourced.
- Pages were read through a fetch tool that summarises; wording in quotes is that tool's rendering of the page.

## What follows for someone building such a game

1. Most players are on phones or tablets (Finding 1), and the docs give no memory figure (2), so pick a low-end Android baseline and test on it.
2. Android is about 65% of the base and most have 2-4 GB RAM (1); that is the memory the world has to fit in.
3. The frame budget is 16.67 ms at 60 FPS (2); measure in the MicroProfiler on a real device, not Studio (2).
4. Turn streaming on with the recommended settings (3); a world of player-built parts depends on it for memory (3).
5. Spawn built parts on the server, in small models, and expect stream-in and stream-out signals (3).
6. Anchor what need not move; many awake parts and contacts cost (5).
7. Remote traffic is limited to about 500 calls per second per client and 1000 bytes on the unreliable kind (4); batch and throttle sends (5).
8. Server memory grows with players and is not freed on leave (2); players per server was last stated as 200 (4).
9. Avoid partial transparency and precise collision on unions (5).
10. Several things were not found (below); measure them in the game itself.

## Not found

- A Roblox-published share of play by phone, tablet, computer and console separately; any device split of hours from Roblox itself.
- A documented memory figure for low-end phones.
- A documented limit on part count, moving assemblies or unanchored parts.
- A documented size limit for `RemoteEvent` payloads, and a documented physics replication rate or bandwidth.
- A current official players-per-server maximum on a docs page.
- Per-part memory or CPU costs of streaming.
- An official statement on many scripts per object, or on weld cost in current docs.
- A first-hand developer write-up of a large building game's performance (only forum snippets seen).

## Sources

- https://create.roblox.com/docs/en-us/performance-optimization/design.md (updated 2026-11-20)
- https://create.roblox.com/docs/en-us/performance-optimization/identify.md
- https://create.roblox.com/docs/en-us/performance-optimization/improve.md
- https://create.roblox.com/docs/en-us/performance-optimization/scene-analysis.md
- https://create.roblox.com/docs/en-us/performance-optimization/test-on-hardware.md
- https://create.roblox.com/docs/en-us/workspace/streaming.md
- https://create.roblox.com/docs/en-us/workspace/streaming/techniques.md
- https://create.roblox.com/docs/en-us/scripting/events/remote.md
- https://create.roblox.com/docs/en-us/reference/engine/classes/RemoteEvent.md
- https://create.roblox.com/docs/en-us/reference/engine/classes/UnreliableRemoteEvent.md
- https://create.roblox.com/docs/en-us/reference/engine/classes/Players.md
- https://create.roblox.com/docs/en-us/physics/network-ownership.md
- https://devforum.roblox.com/t/physics-best-practices/280812 (2019-05-17, Roblox)
- https://devforum.roblox.com/t/experience-join-improvements-server-size-join-queues-and-social-slots-reservations/2294621 (2023-04-13, Roblox)
- https://s27.q4cdn.com/984876518/files/content_files/Q3-2026-Earnings-Shareholder-Letter.pdf (Roblox, Q3 2026)
- http://www.pocketgamer.biz/80-of-roblox-users-are-on-mobile-contributing-46-of-robux-revenue/ (2025-04-23, trade press)
- https://statista.com/statistics/1190919/roblox-games-users-global-distribution-platform (snippet only)
- https://www.windowscentral.com/gaming/oof-roblox-has-as-much-player-engagement-as-steam-playstation-and-fortnite-combined-and-now-its-even-nipping-at-netflixs-heels (snippet only)
- https://www.gameanalytics.com/cn/reports/2025-roblox-report (snippet only)
- https://devforum.roblox.com/t/do-welds-cause-unnecessary-lag/1559762 (snippet only, user thread)

## Checked by a second reader

Checked 2026-11-21. Method: each page was fetched through a fetch tool that summarises, so quotes below are that tool's rendering. 25 claims checked (22 confirmed or partly, 1 disagrees, 5 not confirmable; some claims counted in two groups).

### Wrong or in disagreement
- GameAnalytics device mix. Brief: 44% both, about 40.8% PC only, about 11.6% mobile only, 0.43% console only, 3.69% any console. Page: both 48.39% (2025), 44.68% (2024); PC only 37.56% (2025), 43.98% (2024); mobile only "7-10% range"; console about 2% of players in 2025. No figure in the brief matches the 2025 column. The brief's numbers came from a snippet; the page is the stronger source. https://www.gameanalytics.com/cn/reports/2025-roblox-report
- Brief says the test-on-hardware page has "No date shown". The page carries last_updated 2026-11-20T18:47:19Z. https://create.roblox.com/docs/en-us/performance-optimization/test-on-hardware.md

### Unconfirmed (no source I could open says it)
- Statista 80/17/3 "December 2024": page returned HTTP 403. https://statista.com/statistics/1190919/roblox-games-users-global-distribution-platform
- Newzoo, about 11.5 of 14 billion monthly hours on mobile, Q3 2025: the Windows Central body text did not load (truncated). https://www.windowscentral.com/gaming/oof-roblox-has-as-much-player-engagement-as-steam-playstation-and-fortnite-combined-and-now-its-even-nipping-at-netflixs-heels
- Q3 2026 shareholder letter "has no device split": the PDF came back as binary; I could not read it. Neither confirmed nor refuted. https://s27.q4cdn.com/984876518/files/content_files/Q3-2026-Earnings-Shareholder-Letter.pdf
- Improve page as source for "a part with a Touched listener still makes contacts when CanCollide is false" and for `NoCollisionConstraint`: the page names "no-collision constraints" for ragdoll limbs only, and never mentions Touched. Not found there. https://create.roblox.com/docs/en-us/performance-optimization/improve.md
- "Pool models" as the fix for `updateInvalidatedFastClusters` over 4 ms: the page ties the tag to avatar instantiation or modification; pooling not found in the text returned. Same address.
- Techniques page: "keep dynamic parts out of atomic models" and "spawn on the server, not as client-only copies" are not stated as advice. The page says local clones stop receiving server updates, and atomicity covers initial replication only. https://create.roblox.com/docs/en-us/workspace/streaming/techniques.md
- "Partial transparency near other parts causes overdraw": the design page says only "Avoid transparency values other than 0 and 1"; the overdraw reason was not in the text returned. https://create.roblox.com/docs/en-us/performance-optimization/design.md

### Confirmed (source opened)
- 80/17/3 for 2024, Roblox annual report as relayed; article 2025-04-23. https://www.pocketgamer.biz/80-of-roblox-users-are-on-mobile-contributing-46-of-robux-revenue/ (second-hand, as the brief says)
- Android "roughly 65%"; about 60/35/5% RAM bands; "over 50%" on Passmark 10,000-20,000. test-on-hardware page above.
- 16.67 ms at 60 FPS; 1,000 draw calls and 1,000,000 triangles (for a baseline device); draw distance at least 500 studs; "severe memory limitations": design page above.
- Server memory formula, 30 players about 9.18 GiB, crash rate "above 2-3%", 60 FPS default cap and 240 on Windows, heartbeat cap 60, memory not lost on disconnect: https://create.roblox.com/docs/en-us/performance-optimization/identify.md
- 1024 texture is four times 512; anchoring advice; adaptive 60/120/240 Hz against fixed 240 Hz; 4 ms tag: improve page above.
- Streaming defaults 1024 and 64; the three recommended settings; on by default for new places; Nonatomic default; nine foci "comparable to ten players"; listed costs: https://create.roblox.com/docs/en-us/workspace/streaming.md
- About 500 requests per second per client, shared by type: https://create.roblox.com/docs/en-us/reference/engine/classes/RemoteEvent.md and .../UnreliableRemoteEvent.md. Over 1000 bytes dropped (unreliable only); excess RemoteEvent delayed, excess Unreliable dropped; queue "limited in both count and memory": https://create.roblox.com/docs/en-us/scripting/events/remote.md
- `Players.MaxPlayers` gives no number: https://create.roblox.com/docs/en-us/reference/engine/classes/Players.md
- 200 players per server, 700 in beta, post 2023-04-13: https://devforum.roblox.com/t/experience-join-improvements-server-size-join-queues-and-social-slots-reservations/2294621.json
- Awake parts, legacy welds, unions with collision decomposition, Hull or Box: https://devforum.roblox.com/t/physics-best-practices/280812.json (2019-05-17)
- Network ownership defaults and "cannot verify physics": https://create.roblox.com/docs/en-us/physics/network-ownership.md
- Techniques: about 64 cubic studs; Touched, ProximityPrompt, ClickDetector fail without the part streamed in; GetChildren returns only streamed-in parts; no per-part figures: techniques page above.

### Lines of "What follows" that go further than their evidence
- 1: "Most players are on phones or tablets" rests on one second-hand press report and an unopened Statista page. "Low-end Android" is the brief's choice; the design page says only "pick a low-end baseline device".
- 2: "that is the memory the world has to fit in." The page gives 2-4 GB as the RAM of about 60% of Android players. It does not name a memory budget, and 35% have 4-8 GB.
- 3: "measure ... on a real device, not Studio": the identify page says use a real client for the Developer Console; it was not shown to say this of the MicroProfiler.
- 4: "a world of player-built parts depends on it for memory." The page lists lower memory as a benefit. It does not say any world depends on it.
- 5: "Spawn built parts on the server, in small models": the 64 cubic studs figure and the signal behaviour are on the page. "Spawn on the server" as advice and the atomic-model rule are not (see Unconfirmed).
- 7: "batch and throttle sends (5)": item 5 says do not replicate every frame and do not send big payloads at once. It does not say batch. The 1000-byte limit is for UnreliableRemoteEvent only.
- 9: "precise collision on unions": the improve page speaks of meshes. Unions come only from the 2019 post.
