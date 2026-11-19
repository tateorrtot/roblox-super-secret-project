# 13. Existing libraries, plugins and engine features

Made on 2026-11-19, after the user said:

> also hey if a plugin or addon already existed for this or the future systems youre going to make... maybe we should use that. dont throw anything away though! its just a consideration

## How this was made, and how far to trust it
- Six readers, one for each area below, read the projects' own pages and Roblox's docs and listed what exists. Three more readers then tried to refute the 23 entries that had been recommended. All nine ran on the Sonnet model. Nothing was downloaded, installed or run.
- **The checkers found something wrong or unconfirmed in most entries they checked,** usually a date, a version or how the thing is obtained. Every such point is listed under the entry as "Independent check". No recommendation was overturned.
- Not checked by a second reader: every entry marked "read only" or "skip", and four recommended entries beyond the first four in their area.
- Dates and versions are as found on 2026-11-19. This ecosystem changes month to month. Before adopting anything, open its page again.
- The wording under each entry is the readers' own.

## In short (Claude's reading)
- **Nothing found replaces what is built.** No library gives stacks, containers and Minecraft's carried-stack rules, and Roblox's own Backpack has no stacking or containers. The inventory, the hotbar and the plot's rules stay ours. Nothing is thrown away.
- **Saving is the one place a library clearly beats writing it ourselves.** ProfileStore, wrapped behind one module of ours, with our own `SaveData` format inside it. It is a single file under the Apache 2.0 licence. Needs the user's yes to download it.
- **Phone controls:** Roblox's own Input Action System is the thing to build Use and Hit on when the phone layout is made.
- **Type-checking the Roblox side** needs Roblox's type definitions file for luau-lsp (about 700 KB) and a Rojo sourcemap. Needs the user's yes to download it.
- **Messages:** stay on plain RemoteEvents for now. Zap is the tool to put behind a module of ours when a second kind of message appears.
- **Later, each behind a module of ours:** Vide if screens multiply; Roblox's PathfindingService for helpers; jecs only if a measured need for many identical helpers appears. Roblox's Server Authority and Character Controller Library are to be tried again with the first vehicle prototype, as already planned.
- **Worth reading for ideas, not installing:** Purse (hotbar details on touch and gamepad), Placement Service and Tunicus (what a placement client needs), A-Chassis (vehicle tuning).


## Saving player data

**Recommendation.** Wrap ProfileStore behind one module of ours (start session, get data, end session), vendored as a single file. Keep our own versioned plain-data format inside Profile.Data and write the migration step ourselves, run when a session starts, since ProfileStore has none. Do not adopt a library whose schema or Promise style would shape the rest of the game. Writing the storing ourselves would mean: UpdateAsync with a lock field, a lock timeout and takeover when a server dies, retries with backoff against budgets, autosave, save on leave and on BindToClose within its time limit, and handling of throttles. That is a few hundred lines. The real cost is the failure cases (crashed servers, double joins, shutdown timing, budget exhaustion), which are hard to test outside live servers and are where duplication bugs come from. I would not do it. Keep DocumentService and Lyra as things to look at again later: DocumentService for shared world state across servers, Lyra for trades once it is past early development. Not recommended: DataStore2, Suphi's module, DataKeep, ProfileService. Because ProfileStore's last commit is over a year old, the wrapper should let us swap it and the test harness should fake the DataStore.

**What the reader could not confirm.** I could not confirm: whether ProfileStore is published on Wally or Pesde (wally.run did not render; the pesde search returned 404); ProfileStore's last commit after 2025-07-31; ProfileStore's migration or BindToClose behaviour (the docs page I read did not cover them); Lapis's install name and whether it has had releases after v0.3.3; DocumentService's version and release date; what Ledger actually does, its licence and its install; licence and activity for Suphi's module and DataKeep; whether there is a project called "Keep" other than DataKeep; DataStore2's repository status. GitHub's API started refusing requests partway through, so some dates come from pages and not the API. I also found no evidence that Roblox added built-in session locking in 2026, but my search did not reach the official release notes.

### ProfileStore: use

Single-ModuleScript wrapper over DataStore for player data: one server holds a session lock on a key, caches it in Profile.Data, auto-saves (default 300 s), hands the session over between servers using MessagingService to speed conflicts, and exposes OnSave/OnLastSave/OnAfterSave and LastSavedData. Successor to ProfileService; its profiles are backward-compatible with ProfileService data. It is the most used and the best documented option, it is one file, and it is a thin cache plus lock that does not dictate the data format, which matches our wrap-it design. Weaknesses: its docs describe it as not ideal for frequent writes from several servers or for global state, and the last commit is over a year old. It is stable, though, and its predecessor was described as stable for a long time.

- Where: https://github.com/MadStudioRoblox/ProfileStore
- Last activity found: Latest commit 2025-07-31 (GitHub commits page and API). DevForum thread created 2024-10-11, last post 2026-09-18 (https://devforum.roblox.com/t/3190543.json). The GitHub Releases page is empty. I found no 2026 commit.
- Licence: Apache-2.0 (repo page)
- How it is obtained: Copy the ModuleScript (the README says Roblox library). The repo has a wally.toml, but I could not confirm it is published on the Wally registry (wally.run did not render) and found nothing on Pesde (pesde.dev search 404). Vendoring the single file into our own folder is the safe route.
- How it would fit: Wrap behind one module of ours with start(player, key) / get / end(player). The game never touches Profile objects directly. Our versioned plain-data save format sits in Profile.Data. We own the migration step, run when a session starts, because ProfileStore has no migration feature of its own.
- What of ours it touches: The storing we have not written: session lock, retry, auto-save, save on leave and on shutdown. Our save format, versioning and migration stay ours.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Latest commit 2025-07-31 (https://api.github.com/repos/MadStudioRoblox/ProfileStore/commits); repo pushed_at 2025-07-31 (https://api.github.com/repos/MadStudioRoblox/ProfileStore). No releases page entries found (https://github.com/MadStudioRoblox/ProfileStore). DevForum thread dates not checked by me. Licence the checker found: Apache-2.0 (https://api.github.com/repos/MadStudioRoblox/ProfileStore) The verdict stands: yes.
  - Wrong or not confirmed: Entry says it is unconfirmed whether it is on Wally. Its wally.toml (https://raw.githubusercontent.com/MadStudioRoblox/ProfileStore/main/wally.toml) names it lm-loleris/profilestore version 1.0.3, realm server. I could not confirm it is actually published: wally.run did not render, the Wally API returned 500, and my guessed index path returned 404.
  - Wrong or not confirmed: Not confirmed: Pesde availability, the DevForum thread dates (created 2024-10-11, last post 2026-09-18), and the claim that profiles are backward-compatible with ProfileService data. The source only shows backwards-compatible handling of metadata tags and the global update format (https://raw.githubusercontent.com/MadStudioRoblox/ProfileStore/main/ProfileStore.luau), not full data compatibility.
  - Note: Confirmed from source: AUTO_SAVE_PERIOD = 300, MessagingService used for fast session-conflict handling, OnSave/OnLastSave/OnAfterSave/LastSavedData exist. The README says it is player-data-oriented, not ideal for quick writes from several servers, and not for global state. It is one ModuleScript. Vendoring is sound and the claim that a 'wally.toml exists' is true.

### Roblox DataStoreService and MemoryStoreService (built in): use

Engine key-value storage. DataStoreService gives GetAsync, SetAsync, UpdateAsync, key versions and metadata. MemoryStoreService is fast, shared, short-lived storage (sorted maps, queues, hash maps) with TTL. This is what any library sits on. It gives no session lock, no built-in retry and no migration (docs say wrap calls in pcall; use UpdateAsync when several servers may write). Per key limits are 4 MB per minute written and 4,194,304 characters per key. MemoryStore has a 64 KB plus 1.2 KB per user quota, eviction on expiry, and the docs do not mention locks, so a lock held there can vanish. I found no 2026 announcement of built-in session locking, but a search cannot rule it out.

- Where: https://create.roblox.com/docs/cloud-services/data-stores
- Last activity found: Current Creator docs, fetched 2026-11-19. No page date shown.
- Licence: Roblox platform
- How it is obtained: Built in
- How it would fit: Our wrapper would have to sit on top of it directly if we wrote our own.
- What of ours it touches: Nothing. It is the base the others build on.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Docs read 2026-11-19, no date on the pages: https://create.roblox.com/docs/cloud-services/data-stores.md , https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits.md , https://create.roblox.com/docs/cloud-services/memory-stores.md Licence the checker found: Roblox platform (no separate license; I found nothing stating one) The verdict stands: yes.
  - Wrong or not confirmed: Not confirmed: that the docs say 'wrap in pcall; use UpdateAsync when several servers may write'. The data-stores page tells you to use pcall and describes UpdateAsync as a read-modify-write callback, but I did not find it saying to use it for multi-server writes. It says nothing about retry logic.
  - Wrong or not confirmed: Everything else checked is right: the 4 MB per minute per key write limit (shared across servers) and the 4,194,304 character per-key limit (https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits.md), and the memory quota of 64 KB + 1.2 KB per user plus expiry eviction. The memory-stores page does not mention locks, so locks held there can expire or be evicted by the stated eviction policy (my inference). Its conflict guidance is DataUpdateConflict plus backoff.
  - Wrong or not confirmed: Not confirmed: absence of any 2026 built-in session locking. The data-stores page I read does not mention session locking.
  - Note: Mostly right. MemoryStore expiry is 0 to 3,888,000 seconds, default 45 days. The 'no built-in session lock' point rests only on the page not mentioning one.

### Lyra: consider

Promise-based player data library with session locking, schema validation, versioned migrations, automatic sharding of large data across keys, drop-in import of existing data, and atomic multi-player transactions (txAsync) for trades. It covers more of the wishlist than ProfileStore (migrations, validation, sharding, trades). But the README itself says it is early in development and advises against using it where data loss would be catastrophic until tested more. For player saves that is the opposite of what we want to bet on. Revisit when it is 1.0 or when we need trades.

- Where: https://github.com/Paradoxum-Games/lyra
- Last activity found: Latest release v0.6.0 on 2025-07-08 (GitHub releases API). Most recent commits seen on 2026-03-25 (GitHub commits API). 552 commits, 158 stars, 2 open issues.
- Licence: MIT
- How it is obtained: Wally: paradoxum-games/lyra@0.6.0 (README). It depends on the Promise library.
- How it would fit: Wrap behind our module. Its migrations and validation line up with our versioned format. Transactions would suit trading between players later. Costs: it brings in Promise and a schema library, and its API shapes the code around it somewhat.
- What of ours it touches: The storing, plus part of our versioning and migration step, which we would still keep so the plain-data format stays ours.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Latest release v0.6.0 on 2025-07-08 (https://api.github.com/repos/Paradoxum-Games/lyra/releases). Latest commits seen 2026-03-25 (https://api.github.com/repos/Paradoxum-Games/lyra/commits). Its main-branch wally.toml says 0.6.1, which has no release in the list I read. Licence the checker found: MIT (https://raw.githubusercontent.com/Paradoxum-Games/lyra/main/wally.toml and README https://github.com/Paradoxum-Games/lyra) The verdict stands: yes.
  - Wrong or not confirmed: Not confirmed: the 552 commits, 158 stars and 2 open issues figures. I did not check them.
  - Wrong or not confirmed: Minor: main now carries version 0.6.1 in wally.toml, newer than the 0.6.0 release and install line. The entry's 'depends on the Promise library' is incomplete. It also depends on osyrisrblx/t 3.1.1, plus evaera/promise 4.0.0.
  - Note: The README confirms session locking, validation, migrations, auto-sharding, drop-in import and transactions. It also carries an explicit early-development warning against production use where data loss would be catastrophic. Install line is paradoxum-games/lyra@0.6.0. 'Consider, revisit at 1.0' stands.

### DocumentService: consider

Strictly typed Luau library with a DocumentStore abstraction. Documents can be session-locked (player data) or not (shared data edited by several servers), with hooks around operations, exponential-backoff retries, and migration from no library or another library. A DevForum review thread notes the lock uses MemoryStores. It is the only one that treats shared, multi-server documents as a first-class case, and it is typed and has no dependencies. It is less used and less documented than ProfileStore, and a forum commenter criticised using MemoryStores for locks. Keep it in mind for shared world state, not for player saves first.

- Where: https://anthony0br.github.io/DocumentService/docs/intro
- Last activity found: Last push 2026-09-09 (GitHub API). I did not find a release number or date.
- Licence: MIT
- How it is obtained: Wally, Roblox asset library, or roblox-ts package (per DevForum thread). No dependencies, so the target/roblox folder can be copied.
- How it would fit: Wrapped behind our module this would work. Its non-locked mode could cover shared state such as community goals later.
- What of ours it touches: The storing, and possibly the later shared-world-state storage.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Repository pushed 2026-09-09 (https://api.github.com/repos/anthony0br/DocumentService). I found no release number or date. Licence the checker found: MIT (https://api.github.com/repos/anthony0br/DocumentService) The verdict stands: yes.
  - Wrong or not confirmed: The entry's note that the lock uses MemoryStores was not confirmed. Neither the README (https://raw.githubusercontent.com/Anthony0br/DocumentService/main/README.md) nor the intro page (https://anthony0br.github.io/DocumentService/docs/intro) mentions MemoryStore. I did not read the DevForum thread.
  - Wrong or not confirmed: Understated: the README says 'Ready for production' and claims use in production with 156K CCU, which the entry omits. These are the author's own claims and I did not verify them. The README also lists immutable cache, Result-type errors and DataStore injection for mocks.
  - Wrong or not confirmed: Not confirmed: the roblox-ts and Roblox asset library install routes. The README gives only Wally and manual copy of target/roblox.
  - Note: Confirmed: typed, no dependencies, session-locked or unlocked documents, hooks/signals, automatic retries with exponential backoff, migrations, validation, auto-save and BindToClose saves. The README names ACID transactions across documents as a future goal. The entry's 'consider, for shared multi-server documents' fits. Stars were 55, a small following.

### Lapis: read only

Promise-based DataStore abstraction with session locking, validation, migrations, retries, throttling that errors rather than overrun the budget, deep-frozen immutable documents, save batching, 5-minute autosave and BindToClose closing. Its README says it has not been battle-tested in a large production game. It has had no pushes in about nine months. Its design is worth reading for the immutable, validated document idea, but I would not store player data on it.

- Where: https://github.com/nezuo/lapis
- Last activity found: Last push 2025-02-12 (GitHub API). Latest release I could read was v0.3.3 on 2024-08-24. The releases list I saw may be incomplete.
- Licence: MIT
- How it is obtained: Wally or Pesde package. I could not verify the exact name or version, and the install page was not in what I read.
- How it would fit: A good fit in shape: immutable documents and migrations match our value-style data. It would sit behind our wrapper.
- What of ours it touches: The storing and part of the migration step.

### Ledger: read only

A lockless, append-only DataStore library, announced on the DevForum in July 2026. A different approach: no session lock. Newly released and I could not read what it does. Worth reading its post, since no-lock designs avoid lock-stuck problems, but it is too new to bet saves on.

- Where: https://devforum.roblox.com/t/ledger-a-lockless-append-only-datastore-library/4737492
- Last activity found: Thread created 2026-07-14, last post 2026-11-19, 11 posts (devforum JSON). I could not read the post body, so what it does and its licence are unknown.
- Licence: Unknown.
- How it is obtained: Unknown.
- How it would fit: Unknown.
- What of ours it touches: Unknown.

### ProfileService: skip

The original session-locking player data module by the same author as ProfileStore. Its own author says it is unsupported and points to ProfileStore, which reads the same data. It would only be of interest if we had old data to read, and we do not.

- Where: https://github.com/MadStudioRoblox/ProfileService
- Last activity found: The README says it is no longer supported and recommends migrating to ProfileStore. I could not get a last commit date from the page.
- Licence: Apache-2.0
- How it is obtained: Wally config exists in the repo (unverified on the registry). Copy the module.
- How it would fit: Would sit behind the same wrapper as ProfileStore.
- What of ours it touches: Same storing job as ProfileStore. Not needed beside it.

### Suphi's DataStore Module: skip

Community module with always-on session locking stored in MemoryStore, event-driven rather than polling, with a docs site and an unofficial GitHub copy. No licence found, the canonical copy is an unofficial mirror, and reported locking quirks. ProfileStore does the same job with a clearer source and licence.

- Where: https://devforum.roblox.com/t/suphis-datastore-module/2425597
- Last activity found: Not established. The thread exists with many pages, but I did not read dates. The GitHub mirror says it is not the author's own repo but a copy posted with permission.
- Licence: Not found.
- How it is obtained: Creator Store, or the GitHub mirror (NameTakenBonk/SuphisDataStoreModule), or the npm port @rbxts/suphi-datastore.
- How it would fit: Could be wrapped, but the lock lives in MemoryStore and users report quirks (second store opened from the first broke locking, Studio does not share the live lock).
- What of ours it touches: Same job as ProfileStore.

### DataStore2: skip

Older caching and backup layer over DataStore with no session lock. It has no session lock, which is the main thing we need, and forum posts say it is outdated. The deprecation claim is from community forum posts, not an official notice.

- Where: https://devforum.roblox.com/t/how-to-use-datastore2-data-store-caching-and-data-loss-prevention/136317
- Last activity found: Could not read a repository (the GitHub API URL I tried returned 404). Forum threads describe it as outdated and unsupported.
- Licence: Not checked.
- How it is obtained: Not checked.
- How it would fit: Would not meet our session-lock need.
- What of ours it touches: Nothing.

### DataKeep: skip

Promise-based auto-saving DataStore module with session locking, by noahrepublic. The only thing I found is a changelog entry for 5.0.0 in December 2024. I could not confirm its licence or recent activity, and it does nothing ProfileStore does not. You asked about Keep. The only match I found for that name is DataKeep. If you meant a different project, give me its link.

- Where: https://devforum.roblox.com/t/datakeep-a-promise-based-auto-saving-datastore-module/2656200
- Last activity found: Changelog shows 5.0.0 from December 2024. The repository returned 403, so no commit date.
- Licence: Not found.
- How it is obtained: Not checked.
- How it would fit: Could be wrapped, but unverified.
- What of ours it touches: The storing.


## Messages, replication and small utilities

**Recommendation.** Messages: put a generated-code tool (Zap, with Blink as a short side-by-side trial) behind one Net-style module of ours, with our pure rules unaware of it. Keep Roblox's own RemoteEvent as the base and UnreliableRemoteEvent only for losable data. Do it when the second kind of message appears, not before, because a handful of hand-written remotes is working now. State replication: keep the whole-inventory snapshot for now. When a second kind of state (plot, stations, helpers) needs per-player patches, look at charm-sync, wrapped behind our own module, and be wary of its atoms becoming a second way of holding state. Prediction of the player's own clicks: write it ourselves with the pure InventorySession (apply the click on the client, send the action, replace with the server's snapshot). No library found does this for custom data, and Roblox's Server Authority is aimed at physics and attribute state with a 64-attribute limit, so keep it for vehicles. Utilities: take Trove and Signal from RbxUtil one module at a time when the screen needs them. Skip ReplicaService, Janitor, BridgeNet2, Red and ByteNet. Nothing needs to be thrown away: all of this is additive and sits behind our modules.

**What the reader could not confirm.** I did not read Blink's install or output docs (404) or charm-sync's own README (404), so I could not compare how each handles sparse tables or per-player filtering, and charm-sync's release date is unknown. I could not read Wally or pesde package pages (they load in the browser only), so versions and pesde availability for Charm, Remo and Zap are unconfirmed; Zap is a command-line tool, not a package, and I did not check whether Rokit installs it. I did not read ByteNet's, Net's, TypedRemote's or Replica's own pages, and could not determine Replica's last update. I did not check whether any built-in Roblox typed or schema remote feature exists beyond the one Remote docs page. Server Authority details come from one docs page and a DevForum thread's dates, not its post text (the raw fetch was empty). Years were missing from GitHub release pages, so I used the GitHub API for dates.

### Zap: use

A config-file (IDL) compiler: you write a .zap file naming events and their typed data, run the zap command-line tool, and get one generated Luau file for the server and one for the client. Packs data into buffers and validates everything received. It is the best-fitting way to get typed, validated, compact messages without adopting a framework: a build step, then plain events. The cost is an extra tool in the build (it needs a step in tools/check or a documented command) and the pre-1.0 label. Reliable and unreliable events are both supported, and each event goes one direction, which matches a server-authoritative Use/Hit/click protocol.

- Where: https://github.com/red-blox/zap
- Last activity found: Latest release v0.6.29 on 2026-06-23 (GitHub releases API); repository last pushed 2026-06-23. Repository README still calls it an early pre-release where the API may change.
- Licence: MIT (GitHub repository metadata)
- How it is obtained: CLI only, not a Wally package: GitHub release download or `aftman add red-blox/zap` (docs). Rokit should take the same GitHub-release form but I did not confirm that. Generated files are committed to the project.
- How it would fit: Wrapped easily. Generated code is plain Luau files we would commit; our Roblox-side code calls them from one module (a Net or Remotes module), and the pure rules never see them. The game is not written inside it.
- What of ours it touches: Our hand-written handful of RemoteEvents and the manual sanity checks on their arguments. The whole-inventory snapshot would become one typed event (and later a delta event). Our pure save format could be turned into a Zap type once.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Release v0.6.29 on 2026-06-23 (https://api.github.com/repos/red-blox/zap/releases); repo pushed 2026-06-23 (https://api.github.com/repos/red-blox/zap) Licence the checker found: MIT (https://api.github.com/repos/red-blox/zap; the README itself names no license for the code, only CC BY 4.0 for the logo: https://raw.githubusercontent.com/red-blox/zap/main/README.md) The verdict stands: yes.
  - Wrong or not confirmed: The entry says 'Rokit should take the same GitHub-release form but I did not confirm that'. Still unconfirmed. The docs install page (https://zap.redblox.dev/install.html) lists only Aftman and GitHub Releases, and the Aftman section had no commands in what I could read. I did not test Rokit.
  - Wrong or not confirmed: Not confirmed: the claims about reliable and unreliable events, one direction per event, buffer packing and validation. I only confirmed that the README says it packs data into buffers and calls itself an early pre-release where the API may change. The README mentions security but I did not read the validation docs.
  - Note: Exists and is current, last active June 2026, and the pre-release label on the README is real (https://raw.githubusercontent.com/red-blox/zap/main/README.md). The README may be stale next to six-plus months of 0.6.x releases.

### Roblox RemoteEvent and UnreliableRemoteEvent (built in): use

The engine's own message objects. RemoteEvent is reliable and ordered; UnreliableRemoteEvent may drop or reorder messages and has a 1,000 byte limit. Tables are copied, keys must not be mixed, nil values are to be avoided, and metatables are lost. Keep it as the base: reliable events for inventory actions, unreliable ones only for things that can be lost, such as position hints. I found no built-in typed or schema feature for remotes on the docs page, but I only read that one page and not the RemoteEvent reference page.

- Where: https://create.roblox.com/docs/scripting/events/remote
- Last activity found: Current Creator docs page, fetched 2026-11-19; no date shown on the page.
- Licence: Roblox platform
- How it is obtained: Built in
- How it would fit: This is what every library above sits on. Using it directly is fine for a few messages, but it gives no schema and no validation of what a client sends.
- What of ours it touches: Nothing; it is the base layer.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Docs read 2026-11-19, no date shown: https://create.roblox.com/docs/scripting/events/remote.md Licence the checker found: Roblox platform (no separate license; I found nothing stating one) The verdict stands: yes.
  - Wrong or not confirmed: Confirmed on the page: the 1,000 byte limit for unreliable messages (larger ones may be dropped and are not resent), the mixed-key warning, nil values to avoid, metatables lost, tables copied, non-string indices converted to strings, and no typed schema feature mentioned.
  - Wrong or not confirmed: Not confirmed: that RemoteEvent is reliable and ordered. That is the usual understanding but I did not find the sentence in my read. The entry's wording 'avoid nil values' matches the page's guidance.
  - Note: Page confirms unreliable events can be dropped when congested, throttled, or with no handler connected, and advises timestamps or sequence numbers if order matters. I read only this page, not the RemoteEvent API reference.

### Trove and Signal (RbxUtil), Janitor: use

Small utilities. Trove 1.8.0 tracks objects and cleans them up together; Signal 2.0.3 is an event class; Janitor is another cleanup helper. RbxUtil's module list also has Promise-like and queue tools (Concur, TaskQueue). Trove and Signal are the right size and are current, and the user explicitly welcomes libraries that earn it. Take one when a real piece needs it (the inventory screen is the first: it connects and disconnects many listeners). Skip Janitor, which does the same as Trove. Skip Promise unless we end up with long chains of waiting: the game's own code should use plain functions and the task library.

- Where: https://github.com/Sleitnick/RbxUtil
- Last activity found: RbxUtil pushed 2026-11-17; Janitor (howmanysmall/Janitor) pushed 2026-07-28 (GitHub API). evaera/roblox-lua-promise (Promise) last pushed 2024-08-06, so it is stable but not changing.
- Licence: MIT (RbxUtil, Janitor, Promise)
- How it is obtained: Wally, one module at a time, for RbxUtil (`sleitnick/trove@1.8.0`, `sleitnick/signal@2.0.3`, from its README). I did not check Janitor's or Promise's install lines.
- How it would fit: Each is a single self-contained module, which matches the user's FoxFabric style. They would be used inside the Roblox-side layers (screen, connection handling), never in the pure rules. Signal and Trove are small enough to read fully before adopting.
- What of ours it touches: Nothing yet; we have no signal or cleanup code. They would sit beside our own modules. I did not check whether Roblox's own signals or the new Deferred signal behaviour make Signal unnecessary in places.

### Blink: consider

The same idea as Zap: an IDL compiler written in Luau that produces buffer networking code. Docs list a command-line usage page and a Roblox Studio plugin page. Equal in kind to Zap and more recently active, but it is in the middle of a 1.0 pre-release series, and I could not read its install or output docs. Worth a short trial next to Zap with the same one event (the inventory snapshot) before we choose. I did not verify how each one handles gaps and optional fields in tables, which matters for our sparse slots.

- Where: https://github.com/1Axen/blink
- Last activity found: v0.18.9 stable on 2026-09-19; v1.0.0-pre.11 pre-release on 2026-11-07; repository pushed 2026-11-19 (GitHub API). Most active of the generated-code options.
- Licence: MIT
- How it is obtained: Not confirmed. The docs install page returned 404 for me. The docs site mentions a command-line tool and a Studio plugin.
- How it would fit: Same as Zap: a generated file wrapped by our own module.
- What of ours it touches: Same as Zap. Pick one of the two, not both.
- **Independent check.** Exists as described: yes. Latest activity the checker found: v0.18.9 stable 2026-09-19; v1.0.0-pre.11 pre-release 2026-11-07 (https://api.github.com/repos/1Axen/blink/releases); repo pushed 2026-11-19 (https://api.github.com/repos/1Axen/blink) Licence the checker found: MIT (https://api.github.com/repos/1Axen/blink) The verdict stands: yes.
  - Wrong or not confirmed: The entry says the install is not confirmed and that the install page returned 404. It exists at https://1axen.github.io/blink/getting-started/1-installation . It recommends Rokit (`rokit add 1Axen/blink`), also GitHub Releases, pesde (`pesde add --dev 1axen/blink`, pesde 0.18.5+) and a Studio plugin from the Creator Store or Releases. It does not mention Aftman or Wally.
  - Wrong or not confirmed: The entry's 'IDL compiler written in Luau' is confirmed by the README (https://raw.githubusercontent.com/1Axen/blink/main/README.md). Not confirmed: that it handles sparse tables or optional fields, which the entry itself did not check.
  - Note: A stronger candidate than the entry says, because Rokit is its recommended install and the project uses Rokit already. It is mid 1.0 pre-release series (pre.11 on 2026-11-07), so a stable 1.0 may change the syntax. Worth the same trial as Zap.

### Charm and charm-sync: consider

Charm is a small reactive state library (atoms and computed values, effects when they change). charm-sync, in the same repository under packages/charm-sync, sends state from server to clients: the server calls connect to be handed patches to send over a remote, the client calls patch with what arrives. The server decides which players see which parts. Good for later, when many pieces of state (plot, stations, helper needs) each need to go to the right players as patches. Today we have one inventory per player and a snapshot is small, so the saving is small. Its atoms would also be a second way of holding state next to our plain tables, which clashes with the user's one-way-of-doing-things rule. Look again when a second kind of replicated state appears.

- Where: https://github.com/littensy/charm
- Last activity found: Repository last pushed 2026-10-01 (GitHub API). I could not open charm-sync's own README (404), so its release date is unknown. The Charm README I read shows install through Wally and npm, and it says v0.11 introduced breaking changes.
- Licence: MIT
- How it is obtained: Wally: `littensy/charm@VERSION` and `littensy/charm-sync@VERSION` per the Charm README. I could not read the Wally page, so I did not confirm versions or whether pesde has it.
- How it would fit: charm-sync is used as a pipe, so it can sit behind our module if we keep game state in Charm atoms. That is the cost: state would have to live in atoms, not in our pure Inventory tables. Wrapping an atom around each player's inventory is possible. It does not do prediction; it is a one-way sync.
- What of ours it touches: Our whole-inventory-snapshot message, and nothing else. It would sit next to Inventory, not replace it.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Repository pushed 2026-10-01 (https://api.github.com/repos/littensy/charm). No release date for charm-sync found. I did not open the releases page. Licence the checker found: MIT (https://api.github.com/repos/littensy/charm; README https://raw.githubusercontent.com/littensy/charm/main/README.md) The verdict stands: yes.
  - Wrong or not confirmed: The entry says atoms. The README now describes Charm as 'fine-grained reactivity' built on signals, with `untracked()` replacing `peek()` since v0.11. It still uses the term atom() in the breaking-changes list, so this is partly a naming difference.
  - Wrong or not confirmed: The entry says the server 'calls connect' and the client 'calls patch'. The README confirms server `connect` and client `patch`, and adds `addSignalsToClient` and `addSignals`. Since v0.11 sync APIs are singletons via CharmSync.client and CharmSync.server (README). I could not open packages/charm-sync/README.md (404), though the directory packages/charm-sync does exist (https://api.github.com/repos/littensy/charm/contents/packages).
  - Wrong or not confirmed: The README names a separate package, Wally `CharmSync`, rather than the entry's `littensy/charm-sync@VERSION`. The exact Wally package name and versions are unconfirmed, because I could not read the Wally registry. Charm's own Wally line `littensy/charm@VERSION` is as the README says.
  - Wrong or not confirmed: Not confirmed: the claim that the server decides which players see which parts. The README says sync can be per client, including computed signals.
  - Note: Exists and is current, last push October 2026. The entry's 'consider, later' fits. The repository also holds packages react-charm, vide-charm and deep-charm, which are irrelevant to us. Wally package name for sync needs checking before use.

### Roblox Server Authority (client prediction and rollback): read only

The engine keeps the server as the source of truth while clients predict their own inputs and re-simulate when the server disagrees. Covers physics assemblies and Humanoids; custom state goes through instance attributes written inside functions bound to the simulation. Fits the user's open question about Server Authority: it is released and is aimed at physics, characters and attribute state. For our own inventory prediction, our pure InventorySession is better: apply the click on the client, send the action, and replace the result with the server's snapshot. Revisit for vehicles.

- Where: https://create.roblox.com/docs/projects/server-authority
- Last activity found: DevForum full-release thread created 2026-07-09, last post 2026-11-02 (topic JSON). Docs page does not state a status.
- Licence: Roblox platform
- How it is obtained: Built in, enabled with Workspace properties (AuthorityMode = Server, NextGenerationReplication, UseFixedSimulation, StreamingEnabled and others).
- How it would fit: Not a fit for inventory. The docs say custom state replicates through attributes, limited to the first 64 per instance, with 50 character name and string limits, and that RemoteEvents may not be ordered consistently with attribute updates. It would force an Instance-shaped design, against our rule that rules never touch an Instance. It could matter later for vehicles and moving decks.
- What of ours it touches: Nothing for inventory. Possibly our own prediction for vehicle movement later.

### Remo and Sleitnick's Net / TypedRemote: read only

Remo: a type-safe remote library where all remotes are declared in one schema, with validation through the t library and logging and throttling middleware. In RbxUtil, TypedRemote 1.0.0 gives typed RemoteEvent, RemoteFunction and UnreliableRemoteEvent, and Net 0.2.0 is a static networking module. Remo's validation through t duplicates what our pure modules can already do for a payload, and gives no packing. Zap or Blink does validation and packing in one tool, so these are only a fallback if we dislike a build step.

- Where: https://github.com/littensy/remo
- Last activity found: Remo last pushed 2025-12-02. RbxUtil pushed 2026-11-17 (GitHub API). I did not read the Net or TypedRemote pages, only the module list in the RbxUtil README.
- Licence: MIT (both)
- How it is obtained: Remo: Wally `littensy/remo@VERSION` per its README. RbxUtil: Wally entries per module, for example `sleitnick/trove@1.8.0`.
- How it would fit: Both are thin and wrappable. Neither compresses data; they give types and checks.
- What of ours it touches: The hand-written remotes only, with no bandwidth gain.

### Replica and ReplicaService: skip

Server to client state replication: wrap a table in a Replica on the server, choose which players receive it, change it with mutator calls, and clients get only the changes and can listen. ReplicaService is the older version; its README says it is no longer supported and points to Replica. ReplicaService is declared unsupported and Replica is thin on evidence of upkeep. Charm-sync does the same job and is newer. I did not examine the Replica fork lineage (several forks with the same name exist) closely.

- Where: https://github.com/MadStudioRoblox/ReplicaService
- Last activity found: ReplicaService last pushed 2024-10-16, and says it is unsupported. Replica (MadStudioRoblox/Replica): I could not find a date; its page showed 12 commits and no releases.
- Licence: ReplicaService Apache-2.0; Replica Apache-2.0
- How it is obtained: ReplicaService README gives no install steps and links a Roblox library asset and a wiki. Replica: unknown.
- How it would fit: Replicas are server-owned tables with mutator functions, which is a different shape from our pure Inventory with plain functions. Using them for inventory means every change goes through Replica's mutators, which pushes the game's state to be written inside it.
- What of ours it touches: Would sit in the same place as charm-sync, not both.

### ByteNet, BridgeNet2, Red (older network libraries): skip

Buffer-based networking libraries that work at run time (you define a packet or bridge in code) rather than through a compiler. ByteNet is a modern, typed library; BridgeNet2 batches remote calls; Red is a networking library. A year or more without a commit, against Zap and Blink which are current. If we wanted a no-build-step option, ByteNet is the one to look at, but nothing here beats a generated-code route on validation. I did not read ByteNet's README.

- Where: https://github.com/ffrostfall/ByteNet
- Last activity found: ByteNet last pushed 2025-08-01. BridgeNet2 last pushed 2025-05-30, and its README tells readers to use ByteNet instead. Red (red-blox/Red) is archived, last pushed 2024-02-18. (GitHub API.)
- Licence: MIT for all three
- How it is obtained: Wally (ByteNet and BridgeNet2 have a wally.toml per my reading of the BridgeNet2 page; not verified for ByteNet).
- How it would fit: They would each be wrapped easily, but ByteNet and BridgeNet2 have been quiet for more than a year, and Red is archived.
- What of ours it touches: Same slot as Zap or Blink.


## Screens, hotbars and inventory UI

**Recommendation.** Keep our own Minecraft-style inventory, hotbar and screen. Replacing them with an existing system would be a loss. Roblox's Backpack and Tool model has no stacking or containers in its docs, and the backpack forks (Purse, Satchel) are built on it. The community inventory kits I found are either paid or bundle data and screen together, so they would swap our tested click rules for theirs. Nothing found gives us stacks, containers and the Minecraft carried-stack rules, so there is nothing to throw away or adopt. Do three things. First, turn the default backpack off with SetCoreGuiEnabled. Second, use the Input Action System for Use, Hit and movement when we do the phone layout, after a small phone prototype. Third, read Purse's source for hotbar details such as number keys, touch and gamepad. Treat Vide as the one UI library worth a trial, behind one adapter module, once a second or third screen (a station panel, a building menu) would otherwise each need their own refresh code. Do not adopt React Luau or Fusion. Add UI Labs for previewing screens at phone size once Studio is available, and TopbarPlus only when we have menu buttons. I would NOT rewrite the working inventory screen into any UI library now.

**What the reader could not confirm.** I could not confirm: the exact Wally and Pesde package names for Vide and Fusion (I read only the repo's wally.toml for Vide); whether UI Labs works with Vide or what its licence is; the licences of Flipbook and Hoarcekat; whether Purse's docs site describes stacking (I did not read purse.luau.page); the last release or commit date of Satchel; a dated release of React Luau; how the Input Action System behaves with an open inventory screen and in practice on a phone; how well UIDragDetector works on touch (the docs page says only that it works on all inputs). The community inventory systems were judged from search summaries, not from reading their code. Roblox's devforum release thread was not read this time, so recent engine UI features I did not search for (for example a built-in studio UI preview) may be missing.

### Input Action System and default touch controls (built-in): use

Actions and bindings set up as Instances, with a binding per input type. For touch a binding links to an on-screen button through its UIButton property. Default touch controls include a thumbstick, a jump button, tap on tool icons, drag to look, pinch to zoom. It is the engine's own answer to mapping two actions across keyboard, gamepad and touch buttons. I have not tried how it behaves with our inventory screen open (needs Studio), so plan a small prototype on a phone first.

- Where: https://create.roblox.com/docs/input/input-action-system
- Last activity found: Docs page last updated 2026-11-19. InputActionLabel and the Input Action Manager are marked beta; the core system is not labelled beta on the page.
- Licence: Part of Roblox
- How it is obtained: Built in.
- How it would fit: A direct fit for our two actions, Use and Hit, plus movement: one action each, bound to mouse, key, gamepad and an on-screen button. Replaces hand-written input code on the client, not the rules.
- What of ours it touches: Our hand-written input handling for Use and Hit, once we do the phone layout.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Docs page last updated 2026-11-19 (https://create.roblox.com/docs/input/input-action-system.md) Licence the checker found: Part of Roblox (platform) The verdict stands: yes.
  - Wrong or not confirmed: Nothing wrong found. Confirmed: touch binding links to an on-screen button via the UIButton property; InputActionLabel and Input Action Manager are the two beta tools; default thumbstick, jump button, tap tool icons, drag to look, pinch zoom.
  - Wrong or not confirmed: Not confirmed: that the core system is stable outside beta beyond the page not labelling it so; behaviour with our inventory screen open is untested, as the entry says.
  - Note: The 'use' verdict rests on the page not labelling the core as beta; recommend the phone prototype the entry already suggests.

### Vide: consider

A reactive Luau UI library inspired by Solid: you write UI as functions that build real Instances, and values are signals that update only what depends on them. Fully typecheckable in Luau. Of the UI libraries it matches us best: small, MIT, typed, active this autumn, and it builds plain Instances. It is still pre-release (0.4.x), and our screens are few, so a screen rewrite is not worth it now. Revisit when the station panel and the building menu would otherwise each need their own hand-written refresh logic. UI Labs supports it for preview (see below).

- Where: https://github.com/centau/vide
- Last activity found: Latest commit 2026-10-26 (GitHub commits API); latest release 0.4.1 on 2026-07-11, marked pre-release (GitHub releases page).
- Licence: MIT (wally.toml in the repo)
- How it is obtained: Wally package from the Wally index; the repo also has a pesde.toml. I did not confirm the exact package name or version string on wally.run.
- How it would fit: Fits our rules: a small library, not a framework. Our pure Luau rules stay untouched. The screen reads session state through one adapter module that turns state changes into signals. A screen can be rewritten one at a time, and Vide builds ordinary Instances so it sits beside our hand-built screens.
- What of ours it touches: The code that builds and refreshes the inventory screen, hotbar and later station panels by hand. Nothing in the rules layer.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Commit 2026-10-26 (https://api.github.com/repos/centau/vide/commits); release 0.4.1 on 2026-07-11, prerelease (https://api.github.com/repos/centau/vide/releases). All 7 releases are marked prerelease. Licence the checker found: MIT (wally.toml https://raw.githubusercontent.com/centau/vide/main/wally.toml; LICENSE.md in repo https://github.com/centau/vide) The verdict stands: yes.
  - Wrong or not confirmed: Wally package name and version now confirmed from the repo manifest: centau/vide 0.4.1 (registry UpliftGames/wally-index). I did not confirm it is live on wally.run; the Wally index page was not loaded.
  - Wrong or not confirmed: pesde.toml existence confirmed from the repo file list; its package name was not read.
  - Note: Description matches: repo describes itself as a reactive Luau UI library. Typecheck support and Solid inspiration stated on repo page. The commit and release dates are correct. 'Consider' verdict is reasonable given pre-release status.

### UIDragDetector (built-in): consider

A child you add to a 2D GuiObject that makes it draggable on all inputs with no script. Drag styles: TranslateLine, TranslatePlane, Rotate, Scriptable. Events DragStart, DragContinue, DragEnd. Right tool for drag-style controls; wrong model for the inventory.

- Where: https://create.roblox.com/docs/reference/engine/classes/UIDragDetector
- Last activity found: Engine feature; docs page has no date.
- Licence: Part of Roblox
- How it is obtained: Built in.
- How it would fit: Good for sliders, dials and a draggable window. Our inventory follows Minecraft's tap-to-pick-up, tap-to-put-down model with a carried stack, not press-and-drag. The page does not describe touch specifics, only that all inputs work.
- What of ours it touches: Nothing in the inventory. It could serve a future building or map screen.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Docs page marked last updated 2026-11-19T03:02:21Z (https://create.roblox.com/docs/reference/engine/classes/UIDragDetector.md) Licence the checker found: Part of Roblox (platform) The verdict stands: yes.
  - Wrong or not confirmed: Entry says the docs page has no date; the .md version carries a last-updated stamp of 2026-11-19. Minor, and that stamp is a page timestamp, not a feature date.
  - Note: Drag styles TranslateLine, TranslatePlane, Rotate, Scriptable and events DragStart, DragContinue, DragEnd all confirmed. Docs say it handles all input types without code.

### TopbarPlus: consider

A library for making icons, dropdowns and menus in Roblox's top bar. Maintained and small. We have no top bar buttons yet, so there is no need now; the credit condition is a small cost to note.

- Where: https://github.com/1ForeverHD/TopbarPlus
- Last activity found: v3.5.0 on 2026-10-19 (GitHub releases API).
- Licence: MPL 2.0, plus a condition: keep its Attribute module unchanged or credit TopbarPlus in the experience description.
- How it is obtained: Wally: 1foreverhd/topbarplus@3.5.0; Creator Store; Icon.rbxm from releases.
- How it would fit: A topbar helper and nothing else. It does not do hotbars or inventories. Mobile support is not stated on the page.
- What of ours it touches: Nothing now. Might be used for a menu button (map, settings) later.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Release v3.5.0 on 2026-10-19, not prerelease; previous v3.4.0 2025-09-17 (https://api.github.com/repos/1ForeverHD/TopbarPlus/releases) Licence the checker found: MPL 2.0 plus a condition: keep the Attribute module unchanged or credit TopbarPlus in the experience description (README https://raw.githubusercontent.com/1ForeverHD/TopbarPlus/main/README.md) The verdict stands: yes.
  - Wrong or not confirmed: No wrong claims found. Install via Wally 1foreverhd/topbarplus@3.5.0, Creator Store and Icon.rbxm from releases all match the README.
  - Note: The release list was read in part (first 5 of a long page); the license text itself was taken from the README statement, not the LICENSE file.

### UI Labs: consider

A Studio plugin that previews UI components as stories with hot reload, without running the game. Works with Fusion, Roact and React natively, and with generic stories for other libraries (DevForum post). Previewing a screen at phone size without running the game is useful, and it is maintained this year. It runs in Studio, so it cannot be set up until Studio tools work in a session.

- Where: https://github.com/PepeElToro41/ui-labs
- Last activity found: v1.6.1 on 2026-08-13 (GitHub releases API).
- Licence: Not confirmed. The README does not state one.
- How it is obtained: Roblox Creator Store plugin or GitHub releases; an optional utility package on npm (@rbxts/ui-labs).
- How it would fit: A tool, not part of the game. Because it uses generic stories, a plain-Instance screen can be shown by returning a Frame. It also fits Vide (the DevForum search results show a Vide converter tool from the same ecosystem; I did not verify UI Labs' Vide support).
- What of ours it touches: Running the game to look at a screen.

### Purse (maintained fork of the default backpack): read only

A copy of Roblox's default backpack, moved out of CoreGui so the code can be edited and its APIs used. It aims to stay as close to the default as it can. Useful as a reference for the hotbar details the default backpack handles (key numbers, touch, gamepad). The README does not describe stacking and the project says it adds no features, so I expect none, but I did not read its docs site.

- Where: https://github.com/ryanlua/purse
- Last activity found: Latest release v1.2.1 on 2026-11-08 (GitHub releases API). Active.
- Licence: Apache 2.0
- How it is obtained: Wally package ryanlua/purse, the Creator Store, or the repo. A devforum search snippet showed ryanlua/purse@1.1.5, older than the release above.
- How it would fit: It is still a Tool-and-Backpack hotbar, so it carries the same limits: no stacks, no containers. It is code we could read for how Roblox handles hotbar number keys, touch and gamepad.
- What of ours it touches: Nothing we would keep. It could stand in for the default hotbar if we gave up our own, which we would not.

### Fusion: skip

A portable Luau library for declarative, reactive UI (state values, computed values, and a scope that cleans up after itself). Does the same job as Vide, but with no release for over two years and no commit in nine months. Pick Vide if we want this kind of library at all.

- Where: https://github.com/dphfox/Fusion
- Last activity found: Latest release v0.3 on 2024-08-30 (GitHub releases API). Latest commit 2026-02-02 (GitHub commits API). So slow: nine months with no commit as of today.
- Licence: MIT (README)
- How it is obtained: Download from GitHub releases or Wally. I did not confirm a current package name.
- How it would fit: Same shape as Vide: a library behind our own screen module. Its scope-based cleanup is a different style from Vide's.
- What of ours it touches: Same as Vide, hand-written screen code.

### React Luau (React-lua, Roblox's own port of React 17): skip

A Luau translation of ReactJS 17, kept by Roblox. It is the successor to Roact. You describe the screen as a tree of elements and it updates the Instances. Best supported of the three, but biggest and furthest from our small-module approach. Roact itself is superseded by this; I did not check Roact's final release, so I do not list it as a candidate. Only reconsider if the screens grow into dozens of components.

- Where: https://github.com/Roblox/react-lua
- Last activity found: Latest commit 2026-10-29 (GitHub commits API), so it is actively touched by Roblox staff. I did not find a dated release.
- Licence: MIT (README)
- How it is obtained: Wally package roblox/react (named in the README); the example code expects Packages.React and Packages.ReactRoblox. Also on the Creator Store.
- How it would fit: It is the heaviest of the three. It brings hooks, a reconciler and a component model, and the code around it tends to be written in its style. That is close to a framework the screens must live inside, which the project rules out.
- What of ours it touches: Hand-written screen code.

### Roblox built-in Backpack and Tool: skip

The engine's own hotbar and inventory: a Tool is an Instance in the player's Backpack, shown as an icon at the bottom of the screen, equipped into the hand. Can be switched off with StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false). Cannot express stacks, stack sizes, containers or the Minecraft click rules. Turn the default backpack off and draw our own, which is what we already do.

- Where: https://create.roblox.com/docs/reference/engine/classes/Tool
- Last activity found: Engine feature; the Tool docs page was current when fetched (no date shown on the page).
- Licence: Part of Roblox
- How it is obtained: Built in.
- How it would fit: The Tool page documents no stacking, no container and no slot grid: each Tool is a separate icon, and the properties listed are CanBeDropped, Enabled, ToolTip, Grip and RequiresHandle. Our rule that an inventory is slots holding stacks does not map onto Tool Instances. Items would have to be duplicated as Instances and kept in step with our data.
- What of ours it touches: Would replace our Inventory and Hotbar and put game state into Instances, which breaks the rule that rules never touch an Instance.

### Satchel: skip

An open-source replacement for the default backpack with a restyled UI. Unmaintained v1; its author directs people to Purse. No stacking claims in the README.

- Where: https://github.com/RyanLua/Satchel
- Last activity found: The README says v1 is unmaintained while v2 is developed, and points to Purse. I could not find a date for its last release or commit.
- Licence: Mozilla Public License 2.0
- How it is obtained: Creator Store, or the Satchel.rbxmx release file into StarterPlayerScripts.
- How it would fit: Same as Purse: Tool-based, so no stacks or containers.
- What of ours it touches: Nothing.

### Community inventory systems (InventoryMaker, open-source DevForum posts, paid BuiltByBit kits): skip

Assorted inventory kits with slots and drag and drop, some with stacks. Found by search; I read only the search summaries, not the code. I found no open-source system that has stacks, containers and our click rules, and none with a package. Ours is tested (348 checks). Not worth a closer look unless a specific one is pointed out.

- Where: https://devforum.roblox.com/t/inventorymaker-a-framework-to-help-you-create-your-own-inventory-system/3619173
- Last activity found: Not checked. I did not find a maintained open-source repo with stacks and containers together.
- Licence: Unknown for the DevForum ones; the BuiltByBit ones are sold under their own licences.
- How it is obtained: DevForum posts or paid downloads; no Wally or Pesde package found.
- How it would fit: Each would own the inventory data and the screen together, which clashes with our pure rules module and our own tested click rules.
- What of ours it touches: Would replace Inventory, InventorySession and the screen all at once.

### Hoarcekat and Flipbook (other story previewers): skip

Studio plugins that preview UI stories. Hoarcekat is the older one; Flipbook is the storybook-style plugin. UI Labs has the more recent release and lists generic stories; Hoarcekat has had no commits for a year. Flipbook is a fair alternative if UI Labs does not suit.

- Where: https://github.com/flipbook-labs/flipbook
- Last activity found: Flipbook v2.5.0 on 2026-04-10 (GitHub releases API). Hoarcekat last commit 2025-11-22 (GitHub commits API).
- Licence: Not checked.
- How it is obtained: Studio plugins from the Creator Store or releases.
- How it would fit: Same role as UI Labs.
- What of ours it touches: Same as UI Labs.


## Placing, building and plots

**Recommendation.** Use ProfileStore for the saving and wrap it in our own save module. It is the one piece here that clearly beats what we would write, and the user already asked for safe saving across servers. Keep the plot's rules, the footprint and the save format as our own pure Luau. No library found matches them, and the only close match in structure is a 2022 teaching example tied to four frameworks. Write the pointer-to-tile code ourselves. It is a few lines of integer math. If the tilted-surface case turns out to be fiddly, LibreGrid (MIT, about 100 lines) is small enough to wrap or copy. Read Placement Service and Tunicus for the list of options a placement client needs (rotation step, hold-to-place, collision test, cooldown, and how mobile buttons are left to the developer). Do not install either, because both are stale and written around Instances. For walls, floors and ceilings I found no maintained open-source runtime library. Build it as our own pieces, and read the attachment-point snapping idea from the DevForum. Store plots as plain versioned rows relative to the plot, and add `buffer` packing only if a measured plot nears the 4 MB key limit. Do not adopt the all-in-one plot bundles (Snap, Snappit). Do not rely on Procedural Models for wall pieces until its runtime status is confirmed. DragDetector is not for tile placement. Nothing here was installed or run.

**What the reader could not confirm.** Package names and versions were not confirmed on wally.run or pesde.dev (the Wally page did not load), so ProfileStore's Wally package name and version are unconfirmed. I found no release or tag dates for ProfileStore, LibreGrid or Placement Service, only latest-commit dates for some (GitHub API gave no commit date for Placement Service, whose request returned 403). I did not check the licence file of the 2022 cell-based placement repo, or whether ProfileStore stores raw buffers (no official answer). Runtime availability of Procedural Models is unconfirmed. I did not read each module's source, so claims about their features come from first posts and READMEs, not from running them. I did not search Pesde, and the search for open-source wall, floor and roof building systems was thin, so one may exist that I missed. I did not find a Roblox engine feature for runtime grid snapping or build-mode placement in the 2026-10-26 release notes. I did not read the other 2026 release notes.

### ProfileStore (MadStudioRoblox): use

A DataStore wrapper for per-player data: periodic autosave, session locking across servers, and handling of lock conflicts. Successor to ProfileService. Session locking and autosave are the hardest part of saving a plot and a pack safely. The README says it is for per-player data, not global state, which is exactly our use. One open question: raw `buffer` values in a profile were not confirmed. A 2026-05 thread got no official answer, and the poster's workaround was to convert with `buffer.tostring` and Base64.

- Where: https://github.com/MadStudioRoblox/ProfileStore
- Last activity found: Latest commit 2025-07-31, a small type-fix pull request (GitHub API). No release or tag date found on the repo page. Still in active use: a DevForum thread from 2026-05 discusses it.
- Licence: Apache-2.0
- How it is obtained: Wally (the repo has a wally.toml; I could not confirm the published package name or version because wally.run did not load). Also a Creator Store asset, ID 109379033046155.
- How it would fit: Wrap it behind our own save module. We call it with a plain table (our versioned save data) and it handles the lock and autosave. Nothing else has to be written inside it.
- What of ours it touches: Nothing written yet. It is the 'saving each player's data safely across servers' item, and it would hold the plot's saved form too.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Latest commit 2025-07-31, merge of a type-fix PR (https://api.github.com/repos/MadStudioRoblox/ProfileStore/commits). The releases API returned an empty list, so there are no GitHub releases. Nothing in 2026 found in the repo. Licence the checker found: Apache-2.0 (https://github.com/MadStudioRoblox/ProfileStore/blob/main/LICENSE) The verdict stands: yes.
  - Wrong or not confirmed: Wally package name now found in the repo manifest: lm-loleris/profilestore 1.0.3 (https://raw.githubusercontent.com/MadStudioRoblox/ProfileStore/main/wally.toml). Not confirmed on wally.run.
  - Wrong or not confirmed: The README states a Creator Store install only; the Wally route is shown by the manifest, not the README.
  - Wrong or not confirmed: The Creator Store asset ID 109379033046155 and the 2026-05 DevForum thread were not checked by me.
  - Wrong or not confirmed: Buffer support in profiles is not confirmed: the README does not mention buffers. I did not check the DataStore docs for buffer values either.
  - Note: README confirms it is a DataStore wrapper with autosave and session locking, in a single ModuleScript, and designed for per-player data, not global state or leaderboards. It is described as a successor to ProfileService in the entry; I did not verify that wording. The last repo activity is about 16 months before today, so 'maintained' rests on stability, not recent work.

### Roblox DataStore limits and buffers (built in): use

The engine's own storage, with limits that decide how we save builds: about 4 MB per key, and a per-server request budget of 60 + 40 per player per minute for reads and writes. The limit changes the answer for (d). Compact binary packing is not needed at first. A plot of a few thousand placed items as plain rows is far below 4 MB. Pack with `buffer` only if a measured plot gets near the limit. The 4 MB figure is from the docs. The size of a typical plot is my estimate, not something I measured.

- Where: https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits.md
- Last activity found: Current Creator docs page, fetched 2026-11-19. I did not find a date on the page.
- Licence: n/a (platform)
- How it is obtained: Built in
- How it would fit: Our save format is already plain data with a version. A plot is a list of {item id, tile, facing} rows. That fits easily under 4 MB without any packing.
- What of ours it touches: Nothing. It is the ground the save module stands on.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Page last_updated 2026-11-19T03:02:08Z (https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits.md) Licence the checker found: n/a (platform) The verdict stands: yes.
  - Wrong or not confirmed: The 4 MB figure is more exactly 4,194,304 characters of the serialized (string) value per key, not bytes of the original data, so JSON-encoded size is what counts.
  - Wrong or not confirmed: Entry says no date found; the .md page does carry a last_updated stamp of 2026-11-19.
  - Wrong or not confirmed: The per-server budget 60 + 40 per player per minute is correct for standard reads and writes only. Ordered write is 30 + 5 per player, ordered read 60 + 40 per player.
  - Wrong or not confirmed: The entry's name says 'and buffers' but the page text I read gave nothing about buffers; that part is not confirmed.
  - Note: Entry's own plot size estimate remains unmeasured, as it says. Because the limit applies to the serialized string, a plain-rows plot is fine, but a buffer converted to string would be subject to the same character limit.

### LibreGrid (completelyhazel): consider

About 100 lines of strictly typed Luau that do grid math: snap a position to a 2D or 3D grid, align to tilted surfaces, custom rotation, decimal grid sizes. Three functions and no shapecasts. It does little and does it cleanly, and it is MIT. But snapping a hit position to our own tile grid is a few lines we would write anyway. Its tilted-surface alignment is the one part with real value. Users also reported that orientation is not relative to the surface grid, and that the API uses `:` calls. Decide when we build the client ghost.

- Where: https://github.com/completelyhazel/LibreGrid
- Last activity found: Latest commit 2025-03-22 ('Update usage.md', GitHub API). DevForum thread created 2025-03-19, last post 2025-08-09. No releases listed on the repo.
- Licence: MIT
- How it is obtained: Copy the module from the repo. No Wally package is stated and the repo lists no dependencies.
- How it would fit: It is small enough to wrap behind one module of ours. It works on BaseParts and Models and takes a raycast result, so it belongs on the Roblox side only. Our pure tile grid does not need it, because tile coordinates are integer math. Its value would be pointer-on-a-surface to a tile and back.
- What of ours it touches: A small piece of the client pointer code, if we choose not to write it. Nothing in the pure rules.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Latest commit 2025-03-22 'Update usage.md' (https://api.github.com/repos/completelyhazel/LibreGrid/commits). No releases listed (https://github.com/completelyhazel/LibreGrid). Licence the checker found: MIT, per the repo page's Resources section; I did not open the LICENSE file itself. The verdict stands: yes.
  - Wrong or not confirmed: Not confirmed: that it is strictly typed, that it has three functions named as described (the page gives only the count of three), tilted-surface alignment, decimal grid sizes, or user reports about orientation and `:` calls. I did not read the source, usage.md or the DevForum thread.
  - Wrong or not confirmed: Confirmed: about 100 lines per the Features section, no releases, empty Packages section, no install method stated.
  - Note: Existence, MIT, the ~100 line claim and the last-commit date check out. Last activity is about 20 months old. The 'consider' verdict is cautious and fits what is confirmed.

### Placement Service (zblox164): read only

A placement kit for sandbox and tycoon games: grid snapping, rotation, tilting, floors, collision checks, callbacks and server-side placement, with a ghost shown while placing. It is the best-documented placement kit and the closest to what we need on the client, but it is written around Instances and its own rules, and its author warns it is stale. Read it for the list of options (rotation step, floors, cooldown, callbacks) and for the mobile gap. Do not make it the base.

- Where: https://github.com/zblox164/PlacementService
- Last activity found: The latest DevForum post is 2026-03-01 (topic JSON). The README says the module may not work as intended because it has not been updated in over 2 years, and that it is paused, not abandoned. I did not find a commit date. Version 1.6.2.
- Licence: Apache-2.0 (GitHub repo page)
- How it is obtained: Creator Store asset 5073110873 or copy `PlacementService.lua` from the repo. I found no Wally or Pesde package.
- How it would fit: It is a ModuleScript that wants to own the ghost, the input and the collision test. Our rules (what may go where) are pure Luau, so its validity logic would duplicate ours. Mobile is not handled: you wire your own buttons, though a template UI is included.
- What of ours it touches: Would sit beside the client-side ghost and pointer code. It would not replace our rules.

### Tunicus Placement v3 (glitchifyed): read only

A client placement preview for sandbox tycoons: grid texture, platforms that objects can sit on, hold-to-place, selection boxes, keybinds and Xbox controller support. Server-side protection is only in a separate test place. Useful for seeing how others handle hold-to-place and a grid texture. Its hydraulics and platform features are for a different game. Not maintained in 2025-2026 beyond replies.

- Where: https://devforum.roblox.com/t/tunicus-grid-placement-module-v312-open-source/1547553
- Last activity found: Latest commit 2024-11-23 ('Version 3.2'). DevForum thread created 2021-11-13, last post 2025-07-23. The author said in 2024 that a next version is a long way off.
- Licence: MIT (stated in the first post)
- How it is obtained: Creator Store asset 7980966840, or the GitHub repo glitchifyed/Tunicus-Placement-v3.
- How it would fit: It is a preview-only client module and ships no mobile controls (the first post mentions only Xbox). The hydraulic legs and platform features do not match our flat tile plot.
- What of ours it touches: Would sit beside our client ghost.

### Open Source Cell-Based Grid Placement System (0_1195): read only

A learning example of a cell grid where each cell can hold an object and objects can span several cells (1x1, 2x1, 3x3). It uses ProfileService, Fusion, Rodux and Knit together. The closest match in structure to our pure rules, so it is worth reading once to compare how multi-cell footprints and occupancy are handled. The code is old and tied to four frameworks, so we would write our own.

- Where: https://github.com/Y1195/Cell-Based-Placement-System
- Last activity found: DevForum thread created 2022-06-24, last post 2022-07-15. No later activity found. I did not check the repo for commits.
- Licence: Not stated on the DevForum post. The repo's license was not checked.
- How it is obtained: Clone and read. Do not install.
- How it would fit: Its data model (grid, cell, cell object, footprint across cells) matches our Plot, PlacedItem and Footprint. Its framework stack is exactly what we avoid. The author says not to use it as a template for a full game.
- What of ours it touches: Nothing.

### Procedural Models (built in, Studio beta): read only

A model whose geometry is generated by a Luau generator module from a size and attributes, so a wall or floor piece can resize without stretching. The one engine feature in 2026 that touches building from walls, floors and ceilings. A beta whose runtime use is unconfirmed is too risky to depend on. Revisit when wall pieces are built. Known limits from the docs: no Actors, no packages, and long generators can time out.

- Where: https://create.roblox.com/docs/parts/procedural-models.md
- Last activity found: The DevForum announcement is dated 2026-04-28 and calls it a Studio beta. The docs page lists runtime generation as a capability but gives no release status. I could not confirm that it runs in a live game today.
- Licence: n/a (platform)
- How it is obtained: Built in, enabled from Studio's Beta Features panel.
- How it would fit: It could one day make wall, floor and ceiling pieces that resize to fit a span. It does not touch our rules. It is a presentation tool for the Roblox side.
- What of ours it touches: Nothing now. It might replace hand-made resizable wall and floor meshes later.

### Snap and Snappit (grid placement class with plots): skip

A placement class that bundles plot ownership, claiming, DataStore saving and loading, rotation consistency across plots, collisions and build mode. Stale, no stated licence, and it is a bundle written around Instances and its own DataStore calls. Its only use is the feature list: 'rotation consistency' (a plot loaded in a different place or facing) is a real problem we will meet. Our save stores positions relative to the plot, which community threads give as the standard answer.

- Where: https://devforum.roblox.com/t/snap-an-advanced-grid-placement-class-v12/2730963
- Last activity found: First post 2023-12-06, last post 2024-06-21. The author warned of bugs. No later activity found.
- Licence: Not stated. The thread does not say whether it is open source or link a repository, and a reader asked for the GitHub link without an answer.
- How it is obtained: Creator Store model only, as far as I could find.
- How it would fit: It is the all-in-one that does plots and saving in one module, which is the shape we are avoiding. Our plots and saves are already designed to be separate pieces.
- What of ours it touches: Would try to replace Plot and the save work together. That is what we do not want.

### Bloxburg Building Tools plugin (ClassicDev): skip

A Studio plugin that copies Welcome to Bloxburg's build tools to place walls, floors and roofs, with doors and windows unioned into walls. The author says some floor and roof tools are buggy. It serves a creator in Studio, not a player in the game. I did not find any maintained open-source runtime library for walls, floors and roofs. The useful ideas are separate: attachment points on pieces for snapping (a DevForum building-system thread describes this), and the wall-gap and corner problems users report.

- Where: https://devforum.roblox.com/t/building-tools-build-like-bloxburg/3066418
- Last activity found: Thread created 2024-07-13, last post 2026-06-19. It is a Creator Store asset (18459970081).
- Licence: Not clearly stated. The first post does not say it is open source. A code comment mentions CC BY-SA.
- How it is obtained: Creator Store plugin for Studio. It is for building in the editor, not for players in a running game.
- How it would fit: It is an editor tool, so it is not a runtime module. It cannot be wrapped behind one of ours.
- What of ours it touches: Nothing.

### DragDetector (built in): skip

An engine instance that makes parts and models draggable by mouse, touch, gamepad or VR, with line, plane, axis and trackball drag styles and limits. It does not do what we need for tile placement. It may serve a different job later (dragging a lever, door or drawer, or a carried object), which is outside this area.

- Where: https://create.roblox.com/docs/reference/engine/classes/DragDetector.md
- Last activity found: Current Creator docs, fetched 2026-11-19. I did not find a date on the page.
- Licence: n/a (platform)
- How it is obtained: Built in
- How it would fit: The docs page says nothing about grid snapping or validity checks. It moves things physically. Our placement is a tile, a facing and a validity answer from the rules, with a ghost that shows it.
- What of ours it touches: Nothing in placement. It could suit physical carry or doors and drawers later.


## Helpers, creatures, vehicles and characters

**Recommendation.** Use the engine's PathfindingService, constraints and unanchored-part physics, wrapped behind our own modules, and write the rest ourselves. Vendor SimplePath only if outdoor helper walking turns out to need its stuck and blocked handling; read its single file first and copy the idea if it is thin. Keep helper behaviour as plain code: a job, two needs, a short state function. Do not add an ECS now; if a measured need for many identical helpers appears, jecs is the one to try, behind a Population module, and everything we have already built (items, stacks, inventories) stays outside it as plain values. Do not adopt Chickynoid or Matter, and read A-Chassis only for tuning ideas, not as a base. Server Authority and the Character Controller Library are both engine features of uncertain status: do not adopt them yet, and re-test both with the first vehicle prototype, as already planned. Nothing here needs to be thrown away. Things I would not do: write the game inside any ECS, replace the Humanoid before the vehicle prototype says it must go, or depend on an unlicensed or one-week-old repository.

**What the reader could not confirm.** I could not confirm: A-Chassis licence, last update and release (the GitHub API call was refused). Whether jecs is on Wally under a given name or version (the Wally page would not load, only the repository's wally.toml was seen). Whether ahmicy/simplepath is the original author's repository. Whether Server Authority is beta or released (the page never says). How the beta Character Controller Library handles riding on a moving deck (one forum answer says it does; I did not test or read the docs on it). Anything about BehaviorTree3 forks or thefnox/btree beyond their search listing. Roblox's own 2026 documentation of NPC counts for pathfinding does not exist on the page I read, so the 'hundreds of cheap helpers' question is untested; the best available evidence is the project's own plan to walk helpers on a tile grid in the rules. I did not read the DevForum release thread for any of these. The second SimplePath result (v2.2.1 in 2022) is the release tag only; the repo had a push in June 2026 that I did not look at.

### PathfindingService (Roblox built-in) with PathfindingModifier and PathfindingLink: use

Roblox's own navmesh path computation. CreatePath takes agent size, jump and climb flags, waypoint spacing and per-material or per-label costs. PathfindingModifier regions set costs or make an area impassable. PathfindingLink joins two points across a gap (a boat, a ladder). The Blocked event reports an obstacle ahead. It is what everything else in this area sits on. Documented limits: a start-to-goal distance of 3,000 studs, about 20,000 nodes, and no specific guidance for many NPCs. Those limits suit a plot of a few tiles. Our plan to have helpers walk the plot's tile grid in the rules means most helper movement may not need it at all. Use it only for the outdoor legs between plots and settlements.

- Where: https://create.roblox.com/docs/characters/pathfinding
- Last activity found: Docs page read 2026-11-19; part of the engine, so no release date applies.
- Licence: Part of Roblox (no separate license)
- How it is obtained: built in
- How it would fit: Wrap behind one server module of ours that turns a start, a goal and an agent size into a list of waypoints. The game's rules would not call it; only the thin Roblox layer would.
- What of ours it touches: Nothing of ours yet. Helper walking is not built.

### Roblox constraints, VehicleSeat and unanchored-part riding (built in): use

HingeConstraint (motor or servo), SpringConstraint and CylindricalConstraint build wheels, suspension and moving parts from the engine's own physics. An unanchored moving platform carries characters standing on it by default. No library is better than the engine here for a deck that players build on. The unreliable parts are riders and network ownership: a DevForum bug report says a rider does not inherit the platform's velocity when the server owns the platform, and tweened platforms need an explicit velocity. These are community posts, not documentation. The mechanical-constraints page says nothing about vehicles or VehicleSeat, so I confirmed no official guidance. This is the first thing to prototype on a phone, as the project already planned.

- Where: https://create.roblox.com/docs/physics/mechanical-constraints
- Last activity found: Docs page read 2026-11-19; engine feature.
- Licence: Part of Roblox
- How it is obtained: built in
- How it would fit: Our own Carrier module would build a chassis from these and expose speed, capacity and a deck. This is the ARK-style platform the project asked for.
- What of ours it touches: Nothing of ours yet; it is the base under any vehicle.

### SimplePath: consider

A small module that wraps PathfindingService so a character walks a computed path: it follows waypoints, recomputes when blocked and fires events. It works for humanoid and non-humanoid characters. It saves perhaps a hundred lines, and those lines are exactly the kind that are easy to get wrong (stuck detection, blocked recompute). Its release is four years old and users on DevForum say it may be unmaintained, though the author replied that it just calls the engine. Vendor it, wrap it, and keep the option to replace it.

- Where: https://github.com/ahmicy/simplepath
- Last activity found: The repo I found, ahmicy/simplepath, was last pushed 2026-06-12 (GitHub API). The latest tagged release I found is v2.2.1, 2022-02-28. I could not confirm that ahmicy is the original author's current home; the original DevForum thread is 1196762 and I did not read its first post.
- Licence: MIT
- How it is obtained: The README lists the Creator Store module and GitHub Releases. It does not mention Wally or pesde, and a DevForum commenter asked for Wally, so I found no sign of one. We would vendor the single file.
- How it would fit: Would sit behind our own WalkTo module. The whole module is small enough to read in one sitting, so it is a candidate to read and reproduce rather than depend on.
- What of ours it touches: The 'walk this path and recompute when blocked' loop we would otherwise write.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Last push 2026-06-12 (https://api.github.com/repos/ahmicy/simplepath). The GitHub Releases section of https://github.com/ahmicy/simplepath is empty, so the entry's 'v2.2.1, 2022-02-28' was not confirmed. Licence the checker found: MIT (https://api.github.com/repos/ahmicy/simplepath, spdx MIT) The verdict stands: yes.
  - Wrong or not confirmed: Latest tagged release v2.2.1 dated 2022-02-28: the repo page shows no releases, so not confirmed.
  - Wrong or not confirmed: 'Four years old' release claim: not confirmed for the same reason.
  - Wrong or not confirmed: The README's install links point at a different owner's repo (Zeref-Z/RBLX-SimplePath) and a docs site, which suggests ahmicy may be a mirror. The API says it is not a GitHub fork (created 2021-04-29), but whether it is the canonical home is unconfirmed.
  - Wrong or not confirmed: Absence of Wally/pesde: not checked on the package indexes, so not confirmed.
  - Note: Exists, MIT, README says it works for humanoids and non-humanoids and wraps PathfindingService. 'Consider, vendor and wrap' is reasonable, but the provenance and release status need to be settled before vendoring.

### jecs: consider

An entity component system for Luau with relationships between entities, archetype storage and a typed API, with no dependencies. The README claims 800,000 entities iterated at 60 frames per second. It is the one actively maintained candidate in its class and is pure Luau, so it passes our test of being testable under Lune. But our rules are plain modules, and adopting its style (systems over queries) would pull code toward a framework. Add it only when a measured need for hundreds of helpers appears; until then, plain tables are simpler. Reading its relationship feature is worthwhile, since 'worker employed by station' and 'creature carries crate' are relationships.

- Where: https://github.com/Ukendio/jecs
- Last activity found: Latest release v0.11.0, 2026-03-10; last push 2026-10-22; not archived (GitHub API).
- Licence: MIT
- How it is obtained: The repository has a wally.toml; I did not find a pesde.toml. The README gives no install steps and I could not read the Wally page, so I did not confirm the Wally package name or its version.
- How it would fit: It is pure Luau, so it can run under Lune. It could be wrapped behind a Crowd or Population module that holds many helpers or creatures. It would not hold items or inventories, which are values in our own modules.
- What of ours it touches: Nothing yet. It would be a new store for the state of many identical things (helpers, creatures, vehicles in motion).
- **Independent check.** Exists as described: yes. Latest activity the checker found: Latest release v0.11.0, 2026-03-10 (https://api.github.com/repos/Ukendio/jecs/releases). Last push 2026-10-22 (https://api.github.com/repos/Ukendio/jecs). Not archived. Licence the checker found: MIT (https://api.github.com/repos/Ukendio/jecs) The verdict stands: yes.
  - Wrong or not confirmed: The README says 'Iterate 800,000 entities at 60 frames per second', but its benchmark section is a different test: 21,000 entities across 125 archetypes with 4 random components queried.
  - Wrong or not confirmed: Wally package name and availability: https://raw.githubusercontent.com/Ukendio/jecs/main/wally.toml has name ukendio/jecs, version 0.11.0, but wally.run was a JS page I could not read, so publication on the registry is not confirmed.
  - Wrong or not confirmed: 'No pesde.toml': not checked.
  - Note: The repo is active, dependency-free apart from the toolchain, and pure Luau. 'Consider, only on measured need' stands.

### A-Chassis: read only

A free, open-source car chassis kit for Roblox with a plugin system. Its search-result summary says it provides a beginner-friendly but scalable starting point. It is built for a driven car with tuning, gearbox and so on. It is a driving-feel kit for cars. Our vehicles include flatbeds, boats, creatures and a handcart, with a deck as the point. Read it for how a good wheel and suspension setup is tuned. The search results also show many fake download sites carrying scripts with hidden require calls; get it only from the repository.

- Where: https://github.com/lisphm/A-Chassis
- Last activity found: I could not confirm. The search listing showed about 99 stars; the GitHub API call for its dates was refused (403). A DevForum tag page lists an 'A-Chassis Vehicle Mobile Support' post (September 2025) but I did not read it.
- Licence: Not confirmed
- How it is obtained: Download from the repository or the DevForum post. It is a model with scripts, not a Wally package.
- How it would fit: It would force us to write vehicles inside its model and its scripts: a car with its own input, seat and tuning. We want a carrier as data (what it travels on, speed, capacity) with a deck players build on, and A-Chassis does not offer that.
- What of ours it touches: Nothing wanted.

### Roblox Character Controller Library (beta): read only

An opt-in replacement for the Humanoid's fixed states. Abilities such as running, jumping, climbing and swimming are Luau tables with start and run conditions, blocking rules and input modes. Callbacks run on both the predicted client and the server and must be deterministic. It is still beta, which is the project's own reason for staying on the Humanoid. Re-test it with the first vehicle prototype, as the project already planned. Its abilities and labels are worth reading now because the shape matches the two-action design.

- Where: https://create.roblox.com/docs/characters/character-controller-library
- Last activity found: The docs page says it is 'currently in beta' and must be switched on under Beta Features. Its metadata says last updated 2026-11-19. No release date or version is given.
- Licence: Part of Roblox
- How it is obtained: built in, behind a beta feature
- How it would fit: An ability is a small module with one job, which matches our style. Our tool would be a Use ability and a Hit ability. It is not yet clear how it carries a character on a moving deck; one DevForum answer says the beta controller handles this, which I did not verify.
- What of ours it touches: The Humanoid and the default control scripts, eventually.

### Roblox Server Authority: read only

A netcode model in which clients predict the results of input at once and the server stays the authority. Code that must be predicted is bound with RunService:BindToSimulation and re-run when the server corrects it. It is switched on with Workspace.AuthorityMode set to Server. Its example set includes a racing project, so it is probably aimed at vehicles, but the page says nothing about vehicles or custom characters. Our model of server-made Instances plus snapshots would have to change to fit. Keep it off for now and read the Racing example when the first vehicle prototype runs. Its status label is unclear, so I would ask on DevForum before relying on it.

- Where: https://create.roblox.com/docs/projects/server-authority
- Last activity found: The page was last updated 2026-11-19 and has example projects (Racing, Soccer, Laser Tag). It does not say beta or released. Related videos were published 2026-07-08 and 2026-08-11.
- Licence: Part of Roblox
- How it is obtained: built in; set Workspace.AuthorityMode, then NextGenerationReplication, UseFixedSimulation, StreamingEnabled, deferred signals and the input action system
- How it would fit: It is a whole networking model that every script must be written for, so it is closer to a framework than a module. Known limits from the page: tools not fully supported, Destroy and Parent errors inside bound functions, only 64 attributes replicate, and remote events may not stay ordered with property updates.
- What of ours it touches: Nothing now. It would change how vehicles, characters and our RemoteEvent snapshots work.

### Chickynoid: skip

A server-authoritative character controller with client prediction and rollback. It replaces the Humanoid with its own movement, collision and physics code. Used in released games, per its README. The README says it cannot ride or interact with physics parts, and our players stand on moving decks. It is also 18 months without a push and replaces the whole character. Read its rollback loop if we ever write our own predicted movement.

- Where: https://github.com/easy-games/chickynoid
- Last activity found: easy-games/chickynoid was last pushed 2024-05-27 (GitHub search API). A 2026-03-26 fork, rola2410/chickynoid-modernized, has 0 stars and I could not judge it.
- Licence: MIT
- How it is obtained: No install steps in the README; it is a repository to copy in. No Wally package confirmed.
- How it would fit: It would be the thing the whole game is written inside: it owns movement. Its README lists limits that conflict with our plans: the character is a fixed-size box, and it cannot push, pull or ride physics parts.
- What of ours it touches: The Humanoid.

### Matter: skip

A Roblox ECS library with hooks (useEvent, useThrottle and the like) and a debugger plugin. Nearly two years without a release, and jecs covers the same ground with more recent work. I did not read its code, so this verdict rests on dates and on its stated design. Read it only for its debugger idea.

- Where: https://github.com/matter-ecs/matter
- Last activity found: Latest release v0.8.5, 2024-12-09; last push 2024-12-31 (GitHub API). Nothing newer in my fetches, so it appears to have gone quiet.
- Licence: MIT
- How it is obtained: I did not check Wally or pesde.
- How it would fit: Its hooks style pushes the whole game to be written as systems running every frame, which is the opposite of our modules.
- What of ours it touches: Nothing wanted.

### Arbor (behavior trees): skip

Composable, typed behavior trees for Roblox AI, installed through Wally as arbor = "axp3cter/arbor@2.1.0" according to its README. No license, three stars, one week of commits. A behavior tree earns its place when behavior is deep and varied; one job plus food and rest is not. The older options (BehaviorTree3 and its forks, thefnox/btree on pesde) I found only through search listings and did not verify, so I make no claim about them.

- Where: https://github.com/Axp3cter/Arbor
- Last activity found: Repository created 2026-03-18, last push 2026-03-23, 3 stars (GitHub API). Very new and barely used.
- Licence: None listed on the repository; that means we would have no clear right to use it.
- How it is obtained: Wally, per the README line.
- How it would fit: It would drive helper job choice. But our helpers have one job and two needs, which a short function or a small table of states covers.
- What of ours it touches: A few dozen lines of ours, if we wrote them.

### Independent check of "PathfindingService with PathfindingModifier and PathfindingLink"

The checker named this entry a little differently from the reader. Exists as described: yes. Latest activity found: Engine feature; docs page read 2026-11-19 (https://create.roblox.com/docs/characters/pathfinding.md). No release date applies. Licence found: Part of Roblox; no separate license found The verdict stands: yes.
- Wrong or not confirmed: The 'no specific guidance for many NPCs' remark was not checked and is not confirmed.

### Independent check of "Roblox constraints, VehicleSeat and unanchored-part riding"

The checker named this entry a little differently from the reader. Exists as described: yes. Latest activity found: Engine feature; docs page read 2026-11-19 (https://create.roblox.com/docs/physics/mechanical-constraints.md). Licence found: Part of Roblox The verdict stands: yes.
- Wrong or not confirmed: The DevForum claim that a rider does not inherit the platform's velocity when the server owns the platform was not checked by me; it is not confirmed.


## Testing and tooling

**Recommendation.** Keep what is in place: Lune for the pure rules tests, luau-lsp for types, Rokit for tools. Two additions are worth doing now. First, extend `luau-lsp analyze` to src/server and src/client with `--definitions:@roblox=<globalTypes.d.luau>` and a Rojo sourcemap, then add a `luau-lsp require-graph` check that fails on a shared module requiring a server module. Run `luau-lsp analyze --help` first to confirm the flag names for definitions and sourcemap on analyze, since I could only confirm them from the changelog. Later, if the Roblox-side code needs tests that run without a person, try Jest Lua (upstream roblox/jest on Wally) on ModuleScripts through Open Cloud Luau Execution, with a small script of our own after reading jest-rodeo. That needs a published place and an API key from the user. I would not adopt TestEZ, run-in-roblox, or a Lune test library; I would not rewrite the existing Lune tests into Jest; and I would not take Wally or pesde until a first library is chosen.

**What the reader could not confirm.** I did not find: a README line on how analyze obtains Roblox definitions (changelog 0.3.0 says the VSCode client downloads them, so the CLI likely needs a file passed in) or whether a sourcemap is mandatory for it; the exact analyze flag for the sourcemap; the exact size of the definitions file at the moment you download it (713,040 bytes via the GitHub contents API for globalTypes.None.d.luau, 696.3 KB via the Cloudflare Pages copy); whether Open Cloud Luau Execution is stable or beta; dates for frktest, tiniest and jest-rodeo; the latest Roblox/jest-roblox release tag; any Studio plugin worth adding beyond Rojo's (not researched). Several licenses are from memory. The Studio MCP the project already has was not examined here.

### luau-lsp analyze (Roblox-side type checking): use

The command-line type checker and linter in luau-lsp, run as `luau-lsp analyze <files>`. For Roblox code it needs the Roblox type definitions file, and a Rojo sourcemap so that instance paths such as script.Parent resolve. We already use it, and it is the only CLI checker that understands Roblox types plus Rojo paths. Definitions: in the repo's scripts/ folder the files are globalTypes.d.luau (the Roblox default), globalTypes.None.d.luau, globalTypes.PluginSecurity.d.luau, globalTypes.LocalUserSecurity.d.luau and globalTypes.RobloxScriptSecurity.d.luau. globalTypes.None.d.luau is 713,040 bytes in the GitHub contents API. Since 1.56.0 (2025-11-02) a definitions file needs a name: `--definitions:@roblox=path/to/globalTypes.d.luau`. Generate the sourcemap with `rojo sourcemap default.project.json --output sourcemap.json`. In 1.67.0 (2026-05-10) string requires and @game aliases resolve in `analyze` when a sourcemap is used. The repo README says the prebuilt definitions are hosted on Cloudflare Pages because GitHub rate-limits unauthenticated requests.

- Where: https://github.com/JohnnyMorganz/luau-lsp
- Last activity found: Latest release 1.70.1, 2026-09-27 (GitHub releases API). The CHANGELOG has an unreleased note that `analyze` now uses the new Luau type solver by default (old solver: `--flag:LuauSolverV2=false`).
- Licence: MIT (from memory, not checked this session)
- How it is obtained: Already pinned in our rokit.toml (1.70.1). Release asset luau-lsp-win64.zip is 5,358,589 bytes.
- How it would fit: Fits as a build tool, not a library. The server and client folders are the first code that needs the Roblox definitions. Today the shared rules are checked with `--platform=standard`.
- What of ours it touches: Nothing. It extends the check we already run to src/server and src/client.

### luau-lsp require-graph: use

A command added in 1.55.0 (2025-10-19): `luau-lsp require-graph [--sourcemap PATH] <files>`, with `--output-mode=json` (default) or `--output-mode=dot`. It prints which module requires which. It is a free way to draw and enforce the dependency graph from real code. The notes already plan this.

- Where: https://github.com/JohnnyMorganz/luau-lsp
- Last activity found: Part of luau-lsp 1.70.1, 2026-09-27.
- Licence: MIT (from memory, not checked)
- How it is obtained: Already installed with luau-lsp.
- How it would fit: Fits our rule that dependencies must not become a spider web: a check script can fail if a shared module requires a server module.
- What of ours it touches: The hand-written module dependency tables that the architecture notes say failed three review rounds. It is new for us, so it replaces nothing built.
- **Independent check.** Exists as described: yes. Latest activity the checker found: Added in 1.55.0 (2025-10-19) per the changelog; part of 1.70.1 (2026-09-27). Licence the checker found: MIT (same repository) The verdict stands: yes.
  - Wrong or not confirmed: The changelog says the JSON output format is experimental, which the entry does not mention.
  - Note: Confirmed: luau-lsp require-graph [--sourcemap PATH] <files>, JSON by default, DOT with --output-mode=dot. The VS Code require-graph commands came earlier, in 1.54.0 (2025-09-27). Because the JSON is experimental, build any enforcement behind a wrapper of our own.

### Lune (including its roblox library): use

A standalone Luau runtime. Its built-in `roblox` library reads and writes .rbxl and .rbxm files as a DataModel (`deserializePlace`, `deserializeModel`, `serializePlace`, `serializeModel`), but it does not run Roblox scripts or the engine. This is the right place to run the rules tests. The roblox library is only for static checks on the place file, for example failing if a placeholder asset is still in it. It cannot run a game script.

- Where: https://github.com/lune-org/lune
- Last activity found: v0.11.1 published 2026-10-21 (GitHub releases API).
- Licence: MPL-2.0 (from memory, not checked)
- How it is obtained: Already pinned in rokit.toml (0.11.1).
- How it would fit: It runs the pure-Luau rules tests and the tools/ scripts. The roblox library can inspect or build place files in CI. The docs page does not list which classes and properties are supported.
- What of ours it touches: Sits beside our tests/Check.luau runner.
- **Independent check.** Exists as described: yes. Latest activity the checker found: v0.11.1 published 2026-10-21 (https://api.github.com/repos/lune-org/lune/releases). Last push 2026-10-21. Licence the checker found: MPL-2.0 (https://api.github.com/repos/lune-org/lune, spdx MPL-2.0). The entry said 'from memory'; now confirmed. The verdict stands: yes.
  - Wrong or not confirmed: 'Does not run Roblox scripts': the docs page at https://lune-org.github.io/docs/api-reference/roblox lists no way to run scripts but does not state this, so it is an inference.
  - Note: Confirmed: the roblox library provides deserializePlace, deserializeModel, serializePlace and serializeModel, described as 'manipulating Roblox place & model files'.

### Jest Lua (jsdotlua/jest-lua) and Roblox/jest-roblox: consider

A port of Jest v27.4.7 for Luau that runs inside Roblox. jsdotlua/jest-lua is the community fork; Roblox/jest-roblox is the upstream, MIT licensed, with 50 stars. Tests are *.spec.luau files under __tests__ folders. It is the only mature framework for tests that need the engine, and the upstream repo is active in 2026. The cost is a Wally dependency and a runner. Do not rewrite the Lune rules tests into it: they run faster and need no engine.

- Where: https://github.com/jsdotlua/jest-lua
- Last activity found: jsdotlua/jest-lua: latest commit 2024-12-23, release 3.10.0 (GitHub API). Roblox/jest-roblox: latest commit 2026-11-10 (GitHub API). Its README gives Wally packages roblox/jest and roblox/jest-globals, with 3.20.0 as an example pin; I did not confirm 3.20.0 is the latest release.
- Licence: MIT
- How it is obtained: Wally dev-dependencies: jsdotlua/jest-globals@3.10.0 (community) or roblox/jest and roblox/jest-globals (upstream). The jsdotlua README says it can only run inside Roblox and asks for Lune support. Neither README mentions pesde.
- How it would fit: A test framework we would use only for Roblox-side tests (server/client code that needs real Instances). It would sit beside the Lune tests, not replace them.
- What of ours it touches: Beside our Lune tests. It would also stand in for the hand-driven Studio play test, but only if a runner executes it.
- **Independent check.** Exists as described: yes. Latest activity the checker found: jsdotlua/jest-lua: last push and release v3.10.0 both 2024-12-23 (https://api.github.com/repos/jsdotlua/jest-lua). Roblox/jest-roblox: last push 2026-11-10 (https://api.github.com/repos/Roblox/jest-roblox). That repo's releases API returned an empty list, so it has no GitHub release. Licence the checker found: MIT for both (spdx MIT, from the GitHub API) The verdict stands: yes.
  - Wrong or not confirmed: jsdotlua/jest-lua has 58 stars; the entry gave 50 for Roblox/jest-roblox, which is correct for that repo.
  - Wrong or not confirmed: The README of jest-roblox pins roblox/jest and roblox/jest-globals at =3.20.0, so 3.20.0 is the README's example pin and not confirmed as the latest release (there is no GitHub release to compare against).
  - Wrong or not confirmed: The 'jsdotlua README says it can only run inside Roblox' claim, the *.spec.luau naming, and the package jsdotlua/jest-globals@3.10.0 were not checked.
  - Wrong or not confirmed: Neither pesde nor Lune is mentioned in the jest-roblox README (confirmed).
  - Note: Confirmed: README describes a port of Jest v27.4.7 with Wally dev-dependencies. The fork is stale (2024); the upstream is active in 2026. The wally.run pages could not be read, so no version was confirmed against the registry.

### Open Cloud Luau Execution (built in to Roblox): consider

An HTTP API that loads a published place on a Roblox server and runs a Luau script against it, with no person present. It is a Roblox feature, not a library. It is the only way to run engine tests without a Studio window or a person. It needs a published place and an API key, which are the user's tasks, and it cannot test anything that needs physics or a running player.

- Where: https://create.roblox.com/docs/cloud/reference/features/luau-execution.md
- Last activity found: The docs page marks the endpoints [STABLE] (fetched 2026-11-19). The DevForum thread is still titled [Beta], and its last post is 2026-05-11. I could not tell which is right.
- Licence: Not applicable
- How it is obtained: Built in. The API key goes in an `x-api-key` header to https://apis.roblox.com, `POST /cloud/v2/.../places/{place_id}/luau-execution-session-tasks`. It needs the place published and an API key from the account.
- How it would fit: It is a CI backend only. The script runs against the DataModel, but physics does not run and Scripts and LocalScripts do not run automatically. So it can run Jest tests on ModuleScripts, not the live game. Limits: script 4 MB, 5-minute default timeout, 450 KB of logs, 10 incomplete tasks per place, task creation 5 per minute. Changes are not saved unless the script calls SavePlaceAsync.
- What of ours it touches: Nothing we have. It would stand in for part of the hand-driven Studio play test.

### Wally and pesde (package managers): consider

Two package managers for Luau. Wally (UpliftGames/wally) is the long-standing Roblox one with the wally.run index. pesde is newer, runtime-agnostic (Roblox, Lune), and also publishes scripts and tools. Which one depends on the libraries chosen: Jest Lua and the Roblox/jest packages are on Wally (README shows Wally only), jest-rodeo is on pesde. Choose when the first dependency is taken, not now. Wally's stable release is three years old and its current work is alpha.

- Where: https://github.com/pesde-pkg/pesde
- Last activity found: pesde v0.7.4+registry.0.2.3 published 2026-09-09. Wally: latest commit 2026-10-12, latest release v0.4.0-alpha.1 (2026-10-12), previous stable v0.3.2 (2023-06-05) (GitHub API).
- Licence: pesde MIT; Wally not checked
- How it is obtained: Rokit for either (pesde mentions mise as its recommended installer).
- How it would fit: A package manager is only needed once we take a library. The code we have has none.
- What of ours it touches: Nothing.

### jest-rodeo (revvy02/jest-rodeo): read only

A command-line runner for Jest Lua. It has three targets: `serve` (the open Studio session through `rodeo exec`), `once` (a fresh Studio on a cloned place file) and `cloud` (Open Cloud Luau Execution, with universe ID, place ID, version and API key). It is the one runner covering all three ways of running engine tests, and it installs through Rokit. But it is one star, one author, no dated releases. Read how it calls Open Cloud and write our own thin script if we need it.

- Where: https://github.com/revvy02/jest-rodeo
- Last activity found: Could not find a release or commit date. The page shows 28 commits and no releases.
- Licence: Not stated on the page
- How it is obtained: pesde add rvy/jest-rodeo, or rokit add revvy02/jest-rodeo, or mise.
- How it would fit: It would be a dev tool only. It is not game code.
- What of ours it touches: Nothing built.

### frktest and tiniest (Lune-side test libraries): skip

Two small test libraries for plain Luau and Lune. frktest (pesde: itsfrank/frktest) has assertions, diff printing and a console reporter, but no test discovery. tiniest (StoryBakery, forked from dphfox) has benchmarks, plugins and snapshot tests, with Lune test discovery still planned. Our Check.luau already does the job, including `Check.raises` blaming the calling script, which these libraries do not describe. Dates are unknown, and both are small projects by individuals.

- Where: https://github.com/StoryBakery/tiniest
- Last activity found: Could not find a release or commit date for either.
- Licence: Not found
- How it is obtained: pesde: itsfrank/frktest, storybakery/tiniest (listed on a pesde mirror, not on pesde.dev itself).
- How it would fit: They would sit behind our own test entry point.
- What of ours it touches: tests/Check.luau.

### TestEZ (Roblox/testez): skip

The older BDD-style Roblox test framework. Archived and read-only. Jest Lua is its successor in practice, though I did not find the README naming one.

- Where: https://github.com/Roblox/testez
- Last activity found: Archived by its owner on 2024-09-14 (repo page).
- Licence: Not checked
- How it is obtained: Wally, not checked
- How it would fit: It would run inside Roblox only.
- What of ours it touches: Nothing.

### run-in-roblox (rojo-rbx/run-in-roblox): skip

A command that opens a place file in Studio, runs one script, pipes its output to the terminal and exits: `run-in-roblox --place MyPlace.rbxlx --script starter-script.lua`. Two years without a commit. Newer tools (jest-rodeo, below) do the same job for Jest. The Studio MCP the project already has can also drive Studio.

- Where: https://github.com/rojo-rbx/run-in-roblox
- Last activity found: Latest commit 2024-03-06 (GitHub search API). The repo is not archived. The README names version 0.3.0.
- Licence: MIT
- How it is obtained: Foreman or cargo install run-in-roblox, or a binary from GitHub releases. Not on Rokit as far as I checked.
- How it would fit: A way to run tests through a real Studio on this machine.
- What of ours it touches: Nothing built.

### Independent check of "luau-lsp analyze"

The checker named this entry a little differently from the reader. Exists as described: yes. Latest activity found: Release 1.70.1, 2026-09-27; win64 zip 5,358,589 bytes (https://api.github.com/repos/JohnnyMorganz/luau-lsp/releases). Last push 2026-11-17. Licence found: MIT (https://api.github.com/repos/JohnnyMorganz/luau-lsp, spdx MIT). The entry said 'from memory'; now confirmed. The verdict stands: yes.
- Wrong or not confirmed: globalTypes.*.d.luau file names and the 713,040-byte size: not checked.
- Wrong or not confirmed: The Cloudflare Pages claim about hosted definitions: not checked.
- Wrong or not confirmed: The 1.67.0 (2026-05-10) string-require note: not checked.
