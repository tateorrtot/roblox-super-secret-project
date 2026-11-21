# How experienced developers structure a Roblox project
Asked: how experienced Roblox developers choose tooling, arrange code, use ECS, split client and server, which open projects to read, and what goes wrong as a codebase grows.
Made by one reader on Sonnet, 2026-11-21, from Roblox's documentation, GitHub READMEs, and DevForum threads. Pages were read through a fetch tool that summarises them, so quotes are not verbatim. Search summaries alone were never used as a source.

## What the sources say

### 1. Tooling
- Roblox's Rojo page recommends a toolchain manager (Rokit) to keep tool versions the same on every machine. Its sample `rokit.toml` pins Wally and Lune. It does not mention luau-lsp, selene or StyLua. https://create.roblox.com/docs/projects/rojo.md (page dated 2026-11-20)
- One open-source game (Completionist) uses Rojo, Wally, StyLua, Selene, TestEZ (not Jest), Moonwave for docs, and pre-commit. Its GitHub Actions run a StyLua check, Selene, and a Rojo build on every commit, and the checks must pass before a merge. Its VS Code setup has the StyLua, Selene, Rojo and Luau LSP extensions. No date shown. https://kristian-petras.github.io/completionist
- A second small game (a tycoon on Codeberg) runs `selene`, `stylua --check` and a Rojo build in CI. Found only through a search summary, not opened. https://codeberg.org/thunksuck3r/roblox_game
- Racing Club: Bling City (a studio's write-up, 2026-03-31) lists Rojo, JECS, Vide (UI) and Jabby (entity debugger). https://full-turbo.pages.dev/blog/how-we-built-racing-club-bling-city-roblox-game
- Jest Roblox is a port of Jest 27.4.7. Its README says Roblox uses it to test its own apps, in-game core scripts and Studio plugins. It runs in Roblox or in CI through Roblox's OCALE. It installs through Wally as `roblox/jest@=3.20.0`. https://github.com/Roblox/jest-roblox (no date shown)
- Roblox's Plant Reference Project uses `--!strict` in every script. https://create.roblox.com/docs/resources/plant-reference-project.md (2026-11-20)
- Older Roblox demo repo (Desert Bus 2077) pins Rojo, Remodel, Tarmac through Foreman, now superseded by Rokit in Roblox's docs. https://github.com/Roblox/desert-bus-2077
- pesde, luau-lsp and Lune in a team's own words: not found.

### 2. Arranging code
- Single entry script. Roblox's Plant Reference Project uses one client LocalScript and one server Script. Reason given: control of startup order, and systems share objects by reference. Systems are singleton ModuleScripts. It also says several entry points give isolation and allow Actors and multithreading, and that their run order is non-deterministic. https://create.roblox.com/docs/resources/plant-reference-project.md (2026-11-20)
- DevForum posters say single-script architecture means one script starts each side and the logic stays in ModuleScripts. Opinions range from "engineering nightmare" to "preference". Source is a search summary of several threads, not opened: https://devforum.roblox.com/t/single-script-architecture/3659625 . In that thread (2025-05-21) every reply favours a module loader; one example loader requires every module in a Services folder, sorts by `Priority`, runs each `Init`, then each `Start`. A reply points to the Vesteria repository as a client and server startup example.
- Services and controllers (Knit). Knit's README says it is archived and gets no updates (archived 2024-07-31 per the repo page). Its author's ARCHIVAL.md says the reason is not maintainability: Knit cannot fully use newer typing and Luau intellisense. He says ModuleScripts now cover the service-like structure; networking is harder because tools keep changing; he advises a thin wrapper over remotes with runtime type checks, and names no library because they "come and go". https://github.com/Sleitnick/Knit , https://raw.githubusercontent.com/Sleitnick/Knit/main/ARCHIVAL.md . A forum post (2025-04-14) lists plain ModuleScripts, Net, Comm, Warp, ByteNet, and a module loader from Knit's creator (Axis) as replacements. https://devforum.roblox.com/t/life-after-knit-should-i-use-it-is-it-outdated-how-to-move-on/3605691
- Folders by feature against folders by layer: not found. No first-hand account of either view was read. The one view seen is the Plant project's split by place (ReplicatedStorage, ServerStorage, each with `Source`, `Instances`), which is by layer.

### 3. Entity-component systems
- JECS: its author's announcement (2024-11-17, 89 posts) says he uses it in his own games, advises choosing ECS "for organizational benefits" more than speed, and says it is "not a silver bullet", so profile first. He claims 800,000 entities iterated at 60 fps. Benefits may be less noticeable in some games; overuse of relations fragments queries. https://devforum.roblox.com/t/jecs-optimizing-declarative-scene-graphs-with-ecs/3263203
- Racing Club: Bling City (2026-03-31) uses JECS. About 40 systems that share state through components and queries, not calls or events. About 1 million entities created and torn down per track build, no major problems, not compared with a non-ECS build. Server fully authoritative; components replicate per entity and component on a 0.25 s interval; very few RemoteEvents. Cost they report: weeks to unlearn event-driven habits, early inconsistent code needing standard structure, code review still needed (they say AI agents wrote about 99% of the code). Gain: simpler interaction between systems, systems that can be switched off alone. Their rule: "If it can be done with a query, it probably should." https://full-turbo.pages.dev/blog/how-we-built-racing-club-bling-city-roblox-game
- Matter: docs report 0.65 ms per frame in Matter code on 1,000 entities, 300 component types, 200 systems. No users named. https://matter-ecs.github.io/matter/docs/intro (copyright 2024)
- Other teams using ECS on Roblox: not found.

### 4. Client and server
- Roblox security docs: a client can fire a remote at any rate with any arguments except the Player. The server checks the action is "possible and permissible" before running it. Ask what happens for any value of a parameter and at 1,000+ calls a second. https://create.roblox.com/docs/scripting/security/security-tactics.md (2026-11-20)
- Plant project: its Network module type-checks arguments from the client at run time. It prefers player data replication, then attributes, then CollectionService tags, and only then direct messages. https://create.roblox.com/docs/resources/plant-reference-project.md
- Generated networking: Zap's README says it packs data into buffers and "validates all data received"; it said "early pre-release" at the time of reading, no date. https://github.com/red-blox/zap . Blink (IDL compiler, buffer networking) and ByteNet are named in forum threads; their claims on speed come from their own authors. https://devforum.roblox.com/t/blink-an-idl-compiler-written-in-luau-for-roblox-buffer-networking-0111/2959671 . I did not open Blink's or ByteNet's pages.
- Roblox server authority: the server owns all state and clients send inputs. Clients predict, then roll back and resimulate on a difference. Needs `Workspace.AuthorityMode = Server`, plus NextGenerationReplication, PlayerScriptsUseInputActionSystem, SignalBehavior Deferred, UseFixedSimulation and StreamingEnabled. Core logic goes in a ModuleScript run on both sides and bound with `RunService:BindToSimulation()`. https://create.roblox.com/docs/projects/server-authority.md (2026-11-20). Limits listed there: no `Destroy()` or reparenting inside bound functions; only the first 64 attributes replicate; tools are not fully supported; `tick()`, `os.time()`, `os.clock()` are not rolled back; RemoteEvents may arrive out of order against property changes; use InputActions, not `InputBegan`. Smoothing and instance creation advice: https://create.roblox.com/docs/projects/server-authority/techniques.md . The docs page does not say whether the feature is in beta. A Roblox newsroom post (2026-07) announces it: https://about.roblox.com/newsroom/2026/07/creating-responsive-cheat-resistant-games-roblox-server-authority (seen as a search result only).
- Studio games shipped on server authority: not found.

### 5. Projects worth reading
- Plant Reference Project (Roblox). Data model: ReplicatedFirst (loading screen, client entry `start`); ReplicatedStorage with `Dependencies` (third-party), `Instances` (prefabs), `Source` (shared code); ServerScriptService (one server Script); ServerStorage with `Instances` (Farm template) and `Source` (server code); Workspace (static world and an empty folder for player farms). Source repo layout (files on disk): not found. https://create.roblox.com/docs/resources/plant-reference-project.md
- Vesteria (open-sourced, 2020 per the README). Top level: `.github/workflows`, `.vscode`, `assets`, `src`, `tools`, `.luacheckrc`, `selene.toml`, `roblox.toml`, `default.project.json`, Apache-2.0 licence, 179 commits. The README says a Rojo and VS Code conversion was started, several global refactors followed, it was never completed, and the game reverted to the original version. What `src` holds: not found. https://github.com/berezaa/vesteria
- Desert Bus 2077 (Roblox). Top level: `.github/workflows`, `assets/brand`, `models`, `modules`, `script`, `src`, `default.project.json`, `foreman.toml`, `.gitmodules`, MIT. README calls it a demo of Rojo-ecosystem tools. Folder purposes are not described. https://github.com/Roblox/desert-bus-2077
- Completionist: `Packages/` (Wally), `tests/` (TestEZ specs by area), config files `wally.toml`, `stylua.toml`, `selene.toml`; other folders not described. https://kristian-petras.github.io/completionist
- Roblox's samples page lists about 40 single-purpose scripts (Moderation System, Player Data, Purchase Handling, Leader Election and others), not whole games. https://create.roblox.com/docs/samples.md

### 6. What goes wrong as a codebase grows
- A 2019-12 DevForum thread: a team "overwhelmed by the code itself" as scripts multiply, repeated scrap and refactor, two programmers editing the same scripts, little documentation. Replies: split by area (data, UI, weapons), document each function's inputs and outputs, comment heavily, small goals, early playtests, read *Game Programming Patterns*. https://devforum.roblox.com/t/how-do-you-keep-yourself-oriented-as-your-game-progresses-and-grows/414808
- Plant project: connections must be disconnected on cleanup or the instance is never collected; run order of several entry points is non-deterministic; per-message networking set-up adds complexity. https://create.roblox.com/docs/resources/plant-reference-project.md
- Racing Club: inconsistent patterns and duplicate logic in early code, fixed by standardising system structure. https://full-turbo.pages.dev/blog/how-we-built-racing-club-bling-city-roblox-game
- Vesteria: a late conversion to Rojo with global refactors was abandoned. https://github.com/berezaa/vesteria
- Platform changes breaking games: one poster in the 2019 thread says an update made a previous game unplayable. Same link as the first item.

## Where the sources disagree, or are weak
- Single entry script against several: the Plant project gives both views itself (control of order against isolation). Forum threads disagree and were read only as search summaries.
- Knit: the Knit author says it is not about maintainability; the forum calls it outdated. Both agree on plain ModuleScripts plus a thin remote wrapper.
- ECS: the only team account (Racing Club) has no baseline without ECS, and says AI wrote most of the code. JECS speed figures are its author's own.
- Tooling accounts are from small projects and one doc page. No team talk or post about pesde, luau-lsp or Lune was found.
- Networking libraries: speed claims come from each library's author. No independent comparison was read.
- Plant project advises against modules shared by client and server, yet its own Network module is one; the page says so.
- Several fetched pages show no date (Zap, Jest Roblox, Completionist, Vesteria, Desert Bus).

## What follows for someone building such a game
1. Pin tools with Rokit and run formatting, lint and a Rojo build in CI (finding 1, Rojo doc and Completionist).
2. One entry Script per side that loads ModuleScripts is Roblox's own reference layout, and the Plant page states its reason (finding 2).
3. Do not build on Knit; its author points to ModuleScripts and a thin remote wrapper (finding 2).
4. Expect to standardise system structure early if using ECS; the one team account reports inconsistency and weeks of unlearning (finding 3).
5. Treat ECS as a way to organise, not a speed gain; its own author says so (finding 3).
6. Validate every remote on the server for permissibility and rate (finding 4, security doc).
7. If server authority is wanted, check its listed limits first, since logic moves into bound functions and `Destroy()` is barred there (finding 4).
8. Read the Plant project's data model first; read Vesteria for what an unfinished refactor looks like (finding 5).
9. Cleanup of connections and standard structure are the problems the sources name most (finding 6).

## Not found
- First-hand team accounts of pesde, luau-lsp, Lune, Jest for Luau in a shipped game.
- A first-hand view on folders by feature against folders by layer.
- Named shipped games using Matter or JECS, other than Racing Club.
- Independent comparison of Zap, Blink and ByteNet; opened pages for Blink and ByteNet.
- A shipped game on Roblox server authority; whether it is beta.
- The Plant project's source repository layout; what Vesteria's `src` holds; contents of Desert Bus's folders.
- A post-mortem by a large Roblox game team on codebase growth.

## Sources
- https://create.roblox.com/docs/projects/rojo.md
- https://create.roblox.com/docs/projects/server-authority.md
- https://create.roblox.com/docs/projects/server-authority/techniques.md
- https://create.roblox.com/docs/scripting/security/security-tactics.md
- https://create.roblox.com/docs/resources/plant-reference-project.md
- https://create.roblox.com/docs/samples.md
- https://github.com/Sleitnick/Knit
- https://raw.githubusercontent.com/Sleitnick/Knit/main/ARCHIVAL.md
- https://devforum.roblox.com/t/life-after-knit-should-i-use-it-is-it-outdated-how-to-move-on/3605691
- https://devforum.roblox.com/t/single-script-architecture/3659625
- https://devforum.roblox.com/t/jecs-optimizing-declarative-scene-graphs-with-ecs/3263203
- https://devforum.roblox.com/t/how-do-you-keep-yourself-oriented-as-your-game-progresses-and-grows/414808
- https://full-turbo.pages.dev/blog/how-we-built-racing-club-bling-city-roblox-game
- https://matter-ecs.github.io/matter/docs/intro
- https://github.com/red-blox/zap
- https://github.com/Roblox/jest-roblox
- https://github.com/berezaa/vesteria
- https://github.com/Roblox/desert-bus-2077
- https://kristian-petras.github.io/completionist
- https://codeberg.org/thunksuck3r/roblox_game (search summary only)
- https://about.roblox.com/newsroom/2026/07/creating-responsive-cheat-resistant-games-roblox-server-authority (search result only)
- https://devforum.roblox.com/t/blink-an-idl-compiler-written-in-luau-for-roblox-buffer-networking-0111/2959671 (search result only)

## Checked by a second reader
Checked on 2026-11-21. Pages were fetched as raw text, not through a summariser. Dates are those shown on the source.

### How many claims
- 31 claims checked: 23 confirmed (some with small gaps, listed below), 4 wrong, 4 unconfirmed.
- Confirmed against the page, not listed again below:
  - Rojo page recommends Rokit; its sample file has no luau-lsp, selene or StyLua (https://create.roblox.com/docs/projects/rojo.md, 2026-11-20).
  - Completionist tool list and CI (https://kristian-petras.github.io/completionist, no date).
  - Racing Club tools, 1 million entities, 0.25 s sync, 99% AI, "weeks", the query rule (https://full-turbo.pages.dev/blog/how-we-built-racing-club-bling-city-roblox-game, 2026-03-31).
  - Jest Roblox 27.4.7, OCALE, `roblox/jest@=3.20.0` (https://github.com/Roblox/jest-roblox).
  - Plant: `--!strict`, data model, networking order, shared Network module, cleanup, non-deterministic order (https://create.roblox.com/docs/resources/plant-reference-project.md, 2026-11-20).
  - Knit archived 2024-07-31, and the ARCHIVAL.md text (https://raw.githubusercontent.com/Sleitnick/Knit/main/ARCHIVAL.md).
  - Matter 0.65 ms benchmark, 2024 copyright (https://matter-ecs.github.io/matter/docs/intro).
  - Security doc wording (https://create.roblox.com/docs/scripting/security/security-tactics.md, 2026-11-20).
  - Every server authority setting and limit in finding 4 (https://create.roblox.com/docs/projects/server-authority.md, 2026-11-20).
  - Vesteria top level, 179 commits, README text (https://github.com/berezaa/vesteria).
  - Samples page lists exactly 40 entries (https://create.roblox.com/docs/samples.md, 2026-11-20).
  - JECS "800,000 entities at 60 fps", "not a silver bullet", "organizational benefits", "used jecs in my own games" (https://devforum.roblox.com/raw/3263203, posts #1, #9, #13).
  - Single-script thread loader code and the Vesteria link (https://devforum.roblox.com/raw/3659625, 2025-05-21).
  - Blink's speed figures come from its own author (https://devforum.roblox.com/raw/2959671, 2025-10-24).
  - The Roblox newsroom post exists, published Jul 9, 2026 (https://about.roblox.com/newsroom/2026/07/creating-responsive-cheat-resistant-games-roblox-server-authority).

### Wrong claims
1. Zap. Brief: the README said "early pre-release" when read. The repo page now says "Zap is currently undergoing a rewrite" and that versions 0.6.x are maintained by another person on a 0.6.x branch. "Early pre-release" is not on that page. It is in the README file on the `main` branch: "Zap is currently in a early pre-release state". The two disagree. https://github.com/red-blox/zap and https://raw.githubusercontent.com/red-blox/zap/main/README.md
2. Desert Bus 2077, owner. Brief: a Roblox repo at github.com/Roblox/desert-bus-2077, "Older Roblox demo repo". That address redirects to github.com/rojo-rbx/desert-bus-2077, the Rojo community organisation. The page says "Demo game project using Rojo-based tools". Nothing there says Roblox made it.
3. Desert Bus 2077, tools. Brief: "pins Rojo, Remodel, Tarmac through Foreman". `foreman.toml` has two lines: rojo 7.0.0-alpha.4 and tarmac 0.4.0. Remodel is in the README's tool list, not in the file. https://raw.githubusercontent.com/rojo-rbx/desert-bus-2077/master/foreman.toml
4. Knit forum post date. Brief: "A forum post (2025-04-14)". The post is dated 2025-05-25 (post #1, the only dated post). https://devforum.roblox.com/raw/3605691

### Unconfirmed claims
1. "now superseded by Rokit in Roblox's docs" (Desert Bus line). The Rojo page recommends Rokit and does not mention Foreman. Roblox saying Foreman is superseded: not found. https://create.roblox.com/docs/projects/rojo.md
2. The Codeberg tycoon repo returns HTTP 404 today, so its CI claim has no source. The brief already says it was not opened. https://codeberg.org/thunksuck3r/roblox_game
3. DevForum opinions "from 'engineering nightmare' to 'preference'" (finding 2). "Nightmare" is not in the one thread I opened; the other threads are not named. Not found. https://devforum.roblox.com/raw/3659625
4. The 2019 thread: the brief lists "little documentation" among the poster's problems. The first post does not say it. Not found. https://devforum.roblox.com/raw/414808 (2019-12-23)

### Small gaps in claims marked confirmed
- JECS: "89 posts" counts the posts shown. Numbering runs to #106 (2026-09-20). Post #1 shows 2026-03-13 (likely an edit); the first reply is 2024-11-17. In post #68 (2025-12-09) the same author writes "It is closer to 8 million rather than 800,000", replying to a critic of the throughput figure. The brief gives only 800,000. https://devforum.roblox.com/raw/3263203
- Plant "Reason given": the page lists advantages of each entry-point style and says "The correct approach for your project depends on your requirements." It gives no reason for why Plant chose one.
- The Rojo sample file pins three tools (rojo 7.6.1, wally 0.3.2, lune 0.10.4). The brief names two.
- Knit thread: its own summary is "If you don't care about autocomplete, feel free to use Knit", and it says "many, if not most top games are still using Knit". The brief says only that the forum "calls it outdated".
- Vesteria: the README says the Rojo conversion began in early 2020. "Late" and "abandoned" are the brief's words. The README says "never completed" and that the game "reverted back to the original version".

### Lines of "What follows" that go further than their evidence
- Line 1 (Rokit, and CI for format, lint, build). Rokit is in Roblox's doc. The CI part rests on one hobby project's docs and an unopened Codeberg repo. Roblox's doc does not mention CI or formatters.
- Line 2 ("Roblox's own reference layout ... the Plant page states its reason"). It is one reference project. The same page says many Roblox projects use many entry points and that the choice depends on requirements. It lists tradeoffs and gives no reason for its own choice.
- Line 3 ("Do not build on Knit"). The author archived it for typing and intellisense reasons and says ModuleScripts replace the structure. He does not say "do not build on it". A forum post says to use it freely if autocomplete is not needed. The finding supports "Knit gets no updates", not "do not build on it".
- Line 4 ("standardise system structure early if using ECS"). Racing Club lists "inconsistent patterns, duplicate logic" under its section on AI-written code, not as an ECS problem. The "weeks of unlearning" part is supported.
- Line 8 ("read the Plant data model first; read Vesteria for what an unfinished refactor looks like"). No source gives a reading order. The brief did not read what Vesteria's `src` holds (its own "Not found" list), so it cannot say the repo shows an unfinished refactor. The README says only that the refactor was never completed.
- Line 9 ("the problems the sources name most"). Connection cleanup appears once (Plant). Standard structure appears once (Racing Club). Others appear as often: event webs and coupling (Racing Club), scrapped rewrites and two people in one script (2019 thread), non-deterministic run order (Plant). "Most" is not shown by a count.
- Lines 5, 6 and 7 are supported by the findings they name. Line 5 leaves out that the JECS author's first post leads with a speed claim.
