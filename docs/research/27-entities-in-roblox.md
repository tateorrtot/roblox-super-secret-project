# What Roblox has in the place of an entity

Asked: what Roblox gives a thing in the world by itself, what it leaves to the developer, how NPCs and dropped items are represented, and whether developers keep their own entity list.
Made by one reader on Sonnet, 2026-11-21, from Roblox's documentation pages (no date shown on them; read 2026-11-21), dated DevForum posts by community members, and a library's own docs. No Roblox staff statement was found on NPC cost or on entities.

## What the sources say

### 1. What the engine does for every thing
- `Instance` is the base class of everything in the DataModel tree. It gives Name (not unique), Parent, Archivable, tags, attributes, Destroy, and `UniqueId`. https://create.roblox.com/docs/en-us/reference/engine/classes/Instance.md
- `UniqueId`: "A unique identifier for the instance", read-only from scripts, visible in Studio's Properties window; its serialization settings allow it to be saved and loaded. https://create.roblox.com/docs/en-us/reference/engine/classes/Instance.md
- `Workspace` "houses 3D objects which are rendered to the 3D world"; objects outside it are neither drawn nor in physics. https://create.roblox.com/docs/en-us/reference/engine/classes/Workspace.md
- `BasePart` is "the abstract base class for in-world objects that physically interact". Anchored parts never move by physics; CanCollide decides physical interaction. https://create.roblox.com/docs/en-us/reference/engine/classes/BasePart.md
- `Model` is a container that groups objects; it is for geometric groups (Folder for others). PrimaryPart is the reference for its pivot. https://create.roblox.com/docs/en-us/reference/engine/classes/Model.md
- Network ownership: the engine assigns each unanchored BasePart's physics to the server or a client; the server always owns anchored parts. https://create.roblox.com/docs/en-us/physics/network-ownership.md
- Replication: the server keeps clients in sync with the data model; an object created on the server does not reach clients until parented under a replicated object. https://create.roblox.com/docs/en-us/projects/client-server.md ; https://create.roblox.com/docs/en-us/reference/engine/classes/Instance.md
- Instance streaming loads and unloads Workspace content around the player. Defaults: StreamingMinRadius 64, StreamingTargetRadius 1024. Model streaming modes: Atomic, Persistent, PersistentPerPlayer. Only Workspace descendants stream. https://create.roblox.com/docs/en-us/workspace/streaming.md
- Finding parts in a region: `GetPartBoundsInBox` and `GetPartBoundsInRadius` return parts whose bounding boxes overlap a shape; the docs say the bounding-box methods "perform more efficiently" than `GetPartsInPart`. https://create.roblox.com/docs/en-us/reference/engine/classes/WorldRoot.md
- Tags: sets of strings on instances that replicate server to client, are saved with the place, and are found with `GetTagged` and added/removed signals. https://create.roblox.com/docs/en-us/reference/engine/classes/CollectionService.md
- Attributes: "custom properties that you define", set with `SetAttribute`. https://create.roblox.com/docs/en-us/scripting/attributes.md (that page does not say whether they replicate or are saved; see Not found).

### 2. What the engine does not do
- The docs describe saving only as explicit calls into a data store: "essentially a dictionary", one value per key. https://create.roblox.com/docs/en-us/cloud-services/data-stores.md
- The best-practice page covers player data (one key per player, 4 MB object limit, 180 s save interval in its sample) and says nothing on saving world state or instances. https://create.roblox.com/docs/en-us/cloud-services/data-stores/best-practices.md
- Nothing read says a running server's instances are copied to another server or restored after a restart. This is silence, not a stated rule.
- Ticking: no page read describes a per-thing update. Behavior is a script you write (the NPC kit's NPC is a Script). https://create.roblox.com/docs/en-us/resources/npc-kit.md
- Streaming guidance: client reads of moving parts go stale once an instance streams out; "Move the logic to the server, as server-side scripts see all instances at all times." https://create.roblox.com/docs/en-us/workspace/streaming/techniques.md

### 3. Non-player characters
- Roblox's NPC kit: each NPC is a `Model` with a `Humanoid`, a HumanoidRootPart as PrimaryPart, and an NPC `Script` for roaming and attacking; CollectionService tags choose whom they attack. The page does not say whether it runs on server or client and gives no performance figures. https://create.roblox.com/docs/en-us/resources/npc-kit.md
- `AnimationController` "allows animations to be loaded and applied to a character or model in place of a Humanoid"; the page's sample destroys the Humanoid and adds one. The page makes no cost statement. https://create.roblox.com/docs/en-us/reference/engine/classes/AnimationController.md
- The Humanoid class page read (first 100000 characters of 160875) has no cost statement. It says `EvaluateStateMachine` disables the Humanoid's internal physics and state machine. https://create.roblox.com/docs/en-us/reference/engine/classes/Humanoid.md
- Streaming page: NPCs are excluded from SLIM avatars; stream-in and stream-out signals look like real spawns and removals, so track a flag such as an attribute. https://create.roblox.com/docs/en-us/workspace/streaming/techniques.md
- Cost, community only: one tester measured about 44 fps with AnimationController animators against about 110 fps with Humanoid animators on hundreds of characters (2025-12-21); replies called the setup suspect, no staff reply, unresolved. https://devforum.roblox.com/t/humanoids-are-more-performant-than-animation-controllers-when-playing-animations/4170689
- A 2026-03 thread on many server-side enemies: the accepted answer is server-authoritative data with the client drawing them; the poster reported the script's Activity going from 1.4% to 0.2%. No staff reply. https://devforum.roblox.com/t/how-do-i-optimize-server-side-npc-movement-for-an-rpg-massive-amount-of-enemies/4464033

### 4. Dropped items and pickups
- Roblox's battle-royale pickup system: a spawner is a `Part` tagged PickupSpawner; the visible pickup is a `Model` with tags (Pickup, WeaponPickup, a rarity tag); the real item is a `Tool` that is granted on activation; a prompt shows when the player is close. The page does not say how the server validates the grant. https://create.roblox.com/docs/en-us/resources/battle-royale/pickup-system.md
- `Tool`: with CanBeDropped true, backspace moves it from the Backpack to Workspace. The page does not say what then happens to it. https://create.roblox.com/docs/en-us/reference/engine/classes/Tool.md
- Streaming: `Touched` does not fire for players whose client lacks the part; the page does not address dropped items. https://create.roblox.com/docs/en-us/workspace/streaming/techniques.md

### 5. Developers' own entity lists
- jecs's author (Marcus, DevForum, 2024-11-17) says the problem is memory access in Luau: other implementations "struggle during naive iterations because their data in non-contiguous structures"; jecs stores data in archetypes. https://devforum.roblox.com/t/jecs-optimizing-declarative-scene-graphs-with-ecs/3263203 (read through the topic's .json address)
- Matter's own docs state goals (simple API, performant, debuggable) and do not say what ECS is for. https://matter-ecs.github.io/matter/docs/intro
- Proxiom (DevForum, 2025-09-27) lists several reasons: avoiding rigid inheritance, tight coupling, and inflexible entity definitions. No benchmarks. https://devforum.roblox.com/t/ecs-in-roblox-studio-why-is-it-better-than-oop-and-how-to-cook-it/3962745
- uatemycookie22 (2024-06-16) says ECS is "known for composing state and querying entities", that items and loot drops each get a generated unique id, and that he did not need Matter; with Matter he struggled to read his code after a break. https://devforum.roblox.com/t/mvc-a-practical-approach-towards-developing-games-and-how-to-stop-confusing-yourself-with-ecs-vs-oop/3026159

### 6. Does Roblox's documentation call anything an entity?
- One use found: "As an assembly, the connected parts act as a single rigid entity, referencing a common position, orientation, and scale." That is a description, not a class. https://create.roblox.com/docs/en-us/parts.md
- A search of create.roblox.com found no page that defines "entity" as an engine term. https://create.roblox.com/docs/llms.txt lists no entity page.

## Where the sources disagree, or are weak
- The authors give different single problems: jecs says memory layout and speed; Proxiom says inheritance and coupling; uatemycookie22 says composing state and querying. No source states one problem.
- Humanoid against AnimationController: the docs make no cost claim; the one benchmark found shows Humanoid faster, and other DevForum posts (reported by a search summary, not opened) say the opposite. Unresolved.
- The pickup page names Tool, Model and tags but not the server-side record of the item.
- All entity statements are by community members. The jecs reasoning rests on one author's post.

## What follows for someone building such a game
- Every Instance has a `UniqueId`, but the docs show it only in Properties and do not say scripts can read it (finding 1).
- Saving world things is the developer's job; the docs describe only key-value stores (finding 2).
- No per-thing tick exists; NPC behavior in Roblox's own kit is a Script (findings 2, 3).
- Moving things that clients must see go through streaming; logic on them belongs on the server (finding 2, streaming techniques).
- A server-data-plus-client-drawing NPC has community backing and a stated result in one thread, not a Roblox statement (finding 3).
- Choose Humanoid or AnimationController by measuring; the sources conflict (finding 3, disagreements).
- Roblox's own pickup is a tagged Model plus a Tool; the persistent record is not described (finding 4).
- Tags are the documented way to find things by kind and survive saving (finding 1); Proxiom proposes them as components (finding 5).
- Roblox has no entity class, so an entity list is a library choice, not a platform feature (finding 6).

## Not found
- Whether attributes replicate and are saved (the attributes page is silent; it was not checked elsewhere).
- Whether scripts can read `UniqueId` and whether it survives Clone.
- A Roblox statement of the cost of Humanoid or AnimationController.
- A Roblox statement on how many instances or moving parts a server handles.
- What the `Humanoid` page says after its first 100000 characters; likewise `BasePart` after 100000.
- How dropped Tools are tracked, validated or saved in any Roblox sample.
- A Roblox staff or Roblox-employee statement that developers should keep an entity list.
- Dates on documentation pages.

## Sources
- https://create.roblox.com/docs/llms.txt
- https://create.roblox.com/docs/en-us/reference/engine/classes/Instance.md
- https://create.roblox.com/docs/en-us/reference/engine/classes/Workspace.md
- https://create.roblox.com/docs/en-us/reference/engine/classes/WorldRoot.md
- https://create.roblox.com/docs/en-us/reference/engine/classes/BasePart.md
- https://create.roblox.com/docs/en-us/reference/engine/classes/Model.md
- https://create.roblox.com/docs/en-us/reference/engine/classes/CollectionService.md
- https://create.roblox.com/docs/en-us/reference/engine/classes/AnimationController.md
- https://create.roblox.com/docs/en-us/reference/engine/classes/Humanoid.md
- https://create.roblox.com/docs/en-us/reference/engine/classes/Tool.md
- https://create.roblox.com/docs/en-us/scripting/attributes.md
- https://create.roblox.com/docs/en-us/workspace/streaming.md
- https://create.roblox.com/docs/en-us/workspace/streaming/techniques.md
- https://create.roblox.com/docs/en-us/projects/client-server.md
- https://create.roblox.com/docs/en-us/physics/network-ownership.md
- https://create.roblox.com/docs/en-us/parts.md
- https://create.roblox.com/docs/en-us/resources/npc-kit.md
- https://create.roblox.com/docs/en-us/resources/battle-royale/pickup-system.md
- https://create.roblox.com/docs/en-us/cloud-services/data-stores.md
- https://create.roblox.com/docs/en-us/cloud-services/data-stores/best-practices.md
- https://matter-ecs.github.io/matter/docs/intro
- DevForum topics 3263203, 3962745, 3026159, 4170689, 4464033 (addresses above)

## Checked by a second reader
Second reader (Sonnet), 2026-11-21. Documentation pages were fetched as .md text. DevForum threads were read through their .json addresses. Roblox documentation pages show no date.

### How many claims
29 checked: 22 confirmed as written, 2 wrong, 1 partly wrong, 4 not confirmed.

### Wrong claims
1. Brief (finding 1, line 10): UniqueId is "read-only from scripts". Brief (Not found): whether scripts can read UniqueId is not found.
   Source: the property page says the property "is visible in the Properties window in Studio but is not readable or writable from scripts". The metadata block lists access ReadOnly, read security RobloxScriptSecurity, write security RobloxEngineSecurity, and saveable true. So the answer is stated, and it is no.
   https://create.roblox.com/docs/en-us/reference/engine/classes/Instance.md (line 343 of the text). The page does not say whether Clone copies it.
2. Brief (finding 5): uatemycookie22 "says ... that items and loot drops each get a generated unique id, and that he did not need Matter; with Matter he struggled to read his code after a break".
   Source: all three statements are about "Lee", an invented character in the post's story ("Lee is supposed to be someone who went through similar experiences I did"). The post does not say the author did these things. The ECS sentence ("ECS is known for composing state and querying entities") is the author's own and is quoted correctly.
   https://devforum.roblox.com/t/mvc-a-practical-approach-towards-developing-games-and-how-to-stop-confusing-yourself-with-ecs-vs-oop/3026159 (2024-06-16)

### Partly wrong
3. Brief (finding 1): model streaming modes are "Atomic, Persistent, PersistentPerPlayer". The page lists four: Nonatomic (the default), Atomic, Persistent, PersistentPerPlayer. The default is left out.
   https://create.roblox.com/docs/en-us/workspace/streaming.md

### Not confirmed
- "Other DevForum posts (reported by a search summary, not opened) say the opposite" on Humanoid against AnimationController. I did not find or open them either. Not found.
- "Nothing read says a running server's instances are copied to another server or restored." Silence cannot be confirmed by reading two pages. The best-practices page does say nothing on world state or instances (confirmed), and it names only DataModel.JobId for sharding.
- "Replies called the setup suspect" (thread 4170689). One reply (2112Jay, 2025-12-21) guessed the calling code was at fault. The poster answered that his script did the same as the suggested one, and tested 1600 characters with LOD off and anchored roots, with the same result. No reply measured anything. The thread has 12 posts and none from staff. The 44 and 110 fps figures are confirmed.
- "No Roblox staff statement was found" is true of the five cited threads (no staff in them; thread 4464033 has only the system account). I did not search for others.

### Confirmed (with the address)
- Instance gives tags and attributes (AddTag, SetAttribute and related); UniqueId is shown in Properties and serializes (can_load, can_save true). Instance.md above.
- Workspace houses rendered 3D objects; others are not rendered or in physics. https://create.roblox.com/docs/en-us/reference/engine/classes/Workspace.md
- BasePart is "the abstract base class for in-world objects that physically interact". https://create.roblox.com/docs/en-us/reference/engine/classes/BasePart.md
- Model is for geometric groups; Folder otherwise. https://create.roblox.com/docs/en-us/reference/engine/classes/Model.md
- The server always owns anchored parts; for unanchored parts the engine decides from client hardware and distance. https://create.roblox.com/docs/en-us/physics/network-ownership.md
- A server-made object does not replicate until parented to a replicated object. Instance.md, "Object Replication".
- Streaming defaults 64 and 1024; only Workspace descendants stream. streaming.md above.
- GetPartBoundsInBox and GetPartBoundsInRadius "perform more efficiently" and are less accurate than GetPartsInPart. https://create.roblox.com/docs/en-us/reference/engine/classes/WorldRoot.md
- Tags replicate server to client, are serialized when places are saved, and have GetTagged and added/removed signals. https://create.roblox.com/docs/en-us/reference/engine/classes/CollectionService.md
- Attributes "are essentially custom properties that you define"; the page says nothing on replication or saving. https://create.roblox.com/docs/en-us/scripting/attributes.md
- A data store is "essentially a dictionary". https://create.roblox.com/docs/en-us/cloud-services/data-stores.md
- 4 MB per key, 180 s in the sample, nothing on world state. https://create.roblox.com/docs/en-us/cloud-services/data-stores/best-practices.md
- The "Move the logic to the server" quote, the SLIM exclusion of NPCs, the stream-in signals, and Touched not firing for unstreamed parts. https://create.roblox.com/docs/en-us/workspace/streaming/techniques.md
- NPC kit: Model, Humanoid, HumanoidRootPart as PrimaryPart, an NPC script, tags; server or client not stated; no figures. https://create.roblox.com/docs/en-us/resources/npc-kit.md
- AnimationController description and no cost statement. https://create.roblox.com/docs/en-us/reference/engine/classes/AnimationController.md
- Humanoid.EvaluateStateMachine is "used to disable the internal physics and state machine". I read the whole page (about 161,000 characters, not 100,000): it has no cost statement. That closes one "Not found" item. https://create.roblox.com/docs/en-us/reference/engine/classes/Humanoid.md
- 44 fps against 110 fps, 2025-12-21, no staff. https://devforum.roblox.com/t/humanoids-are-more-performant-than-animation-controllers-when-playing-animations/4170689
- Thread 4464033, 2026-03-03: the accepted answer is server data with client models; Activity 1.4% to 0.2% (the poster's figures were 1.4%/30.0s to 0.2%/6.0s). https://devforum.roblox.com/t/how-do-i-optimize-server-side-npc-movement-for-an-rpg-massive-amount-of-enemies/4464033
- Pickup system: PickupSpawner tag, visual Model with tags, Tool granted; no server validation described. https://create.roblox.com/docs/en-us/resources/battle-royale/pickup-system.md
- Tool.CanBeDropped true: backspace parents the Tool to Workspace and removes it from the Backpack. https://create.roblox.com/docs/en-us/reference/engine/classes/Tool.md
- jecs: author Marcus (username Ukendio), 2024-11-17, quote as in the brief. https://devforum.roblox.com/t/jecs-optimizing-declarative-scene-graphs-with-ecs/3263203
- Matter lists goals and does not say what ECS is for. https://matter-ecs.github.io/matter/docs/intro
- Proxiom, 2025-09-27: rigid inheritance, weak interconnection, flexibility; no benchmarks; proposes tags and attributes as components. https://devforum.roblox.com/t/ecs-in-roblox-studio-why-is-it-better-than-oop-and-how-to-cook-it/3962745
- parts.md uses "rigid entity" once; llms.txt has no page whose title holds "entity". https://create.roblox.com/docs/en-us/parts.md

### Lines of "What follows" that go further than their evidence
- Line 1 (UniqueId): it says the docs "do not say scripts can read it". The docs say scripts cannot. The line is too weak and points the reader the wrong way.
- Line 2 (saving): "the docs describe only key-value stores" rests on two pages. Other persistence pages were not read.
- Line 3 (no per-thing tick): the finding is only that no page read describes one. Absence of a page is not a statement that none exists. The Humanoid page itself shows a per-Humanoid state machine.
- Line 4 (streaming): stated without the condition that StreamingEnabled is a Workspace property, on by default for new places and settable off (streaming.md). The techniques quote applies only when streaming is on.
- Line 8 (tags "survive saving"): the docs say tags are serialized when a place is saved, that is, in the place file. They say nothing of tags surviving a server restart or a data store save. The brief's own line 2 says world saving is the developer's job. The two lines read as if tags solve it.
- Line 9 ("an entity list is a library choice, not a platform feature"): finding 6 supports "no entity class". "Library choice" is an inference. Proxiom's post proposes tags and attributes, which are platform features, as the components. So an entity list can be built from platform parts.
- Line 6 ("choose by measuring"): advice. No source gives it, except one non-staff forum reply.
