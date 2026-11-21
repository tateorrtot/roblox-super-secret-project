# What an entity is in Minecraft, Godot, Unity, and entity-component systems, and the one problem it solves
Asked: what an entity is in Minecraft, Godot, Unity and ECS libraries, and the one problem it solves.
Made by one reader on Sonnet, 2026-11-21, from engine and library documentation, a modding documentation site and the Minecraft wiki. Pages were read through a fetch tool that summarises them, so quotes are the tool's quotes of the page. No page carries a date. No developer talk was read.

## What the sources say

### 1. Minecraft Java: what an entity is
- The wiki defines entities as "all dynamic objects throughout the Minecraft world." (https://minecraft.wiki/w/Entity)
- The wiki says most entities share: a position, rotation and velocity; a bounding box of one or more non-rotating boxes; the ability to be on fire and take status effects; a view point. (same page)
- The wiki's text does not list an id or saved data as common to all. It says Java entities have a root NBT compound with common tags, defined in a template the page did not show. (same page)
- NeoForge docs: "Entities are in-world objects that can interact with the world in a variety of ways." A simple entity is an `Entity` subclass, a registered `EntityType` and an `EntityRenderer`. (https://docs.neoforged.net/docs/entities/)
- NeoForge docs, what every `Entity` has: `tick`, `baseTick` (updates values common to all entities, such as on-fire and swimming) and `rideTick`. Every subclass implements `readAdditionalSaveData`, `addAdditionalSaveData` and `defineSynchedData` (save and send to clients), and `hurtServer`. (same page)
- `ItemEntity` is listed there as a direct subclass of `Entity` for dropped items. (same page)
- `LivingEntity` and `Mob`: not confirmed by any page I read.
- What the game does for all entities alike (ticking, saving, sending to clients): confirmed only by the NeoForge method names above. Colliding them and finding the entities in a region: not found in a source I read.

### 2. What is and is not an entity
- Entity, per the wiki table: dropped item, arrow, minecart, painting (immovable, aligned to the block grid). (https://minecraft.wiki/w/Entity)
- Falling block: a gravity block "normally exists as a block" and becomes an entity when its support is removed. (same page)
- Block: not an entity. (same page)
- Chest: the Entity page does not address the chest block. The Block entity page lists the chest as a block entity. (https://minecraft.wiki/w/Block_entity)
- Block entity (also "tile entity"): "an additional object associated with certain blocks." It stores information a block state cannot hold, and can run code regularly while its chunk is loaded. It is always tied to one block at a fixed position. Examples: chest (contents, name), furnace (contents, cooking and fuel time, ticks), beehive, banner, sculk sensor, monster spawner, jukebox. (same page)
- Why separate, wiki: the page does not say.
- Why separate, NeoForge: block entities exist for data "in cases where block states are not suitable." Block states suit a small finite set of values. Block entities hold data with "non-finite amount of options," such as inventories. They are "stationary and bound to a block," and "otherwise work much like entities." (https://docs.neoforged.net/docs/blockentities/)

### 3. The one problem an entity solves in Minecraft
- Not found as a stated purpose from the developers, Fabric or NeoForge.
- Nearest statements: the wiki's "all dynamic objects" (Entity page) and NeoForge's "in-world objects that can interact with the world in a variety of ways." Neither names a problem.
- Nearest statement of a problem, for block entities only: a block state cannot hold unbounded data (NeoForge block entity page, above).
- Fabric's entity page returned 404 at https://docs.fabricmc.net/develop/entities/ and was not read.

### 4. Godot
- Godot has no "entity." The Key Concepts page does not use the word. It says "Nodes are your game's smallest building blocks that you arrange into trees." (https://docs.godotengine.org/en/stable/getting_started/introduction/key_concepts_overview.html)
- `Node`: base class of all scene objects, "Godot's building blocks." Nodes sit in a parent-child tree; a tree saved to disk is a scene. Nodes can run code every frame or physics tick, respond to input, join named groups and send remote procedure calls. (https://docs.godotengine.org/en/stable/classes/class_node.html; the last 61,707 characters of this page were not read)
- `Node3D`: base class of 3D nodes. It gives a position, rotation and scale in 3D, local and global, plus visibility. "All other 3D nodes inherit from this class." (https://docs.godotengine.org/en/stable/classes/class_node3d.html)
- `CharacterBody3D`: "a specialized class for physics bodies that are meant to be user-controlled." Not moved by physics itself; `move_and_slide()` adds wall and slope detection. (https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html)
- Against Minecraft's entity: Node3D gives position and rotation; CharacterBody3D gives a collision body and movement. A bounding box comes from a child collision shape (the design page says a few nodes are used by a parent physics body, but does not say this of boxes). Velocity: CharacterBody3D page as read does not state it. An id, saving and sending to clients: not found on these pages.
- Godot says its nodes "do not work like components in some other game engines." Scenes "work like a class in pure code" and can be nested like prefabs. (https://docs.godotengine.org/en/stable/getting_started/introduction/godot_design_philosophy.html)
- What a node is for, in the docs' words: a building block with one specific purpose, arranged in a tree. No single stated problem found.

### 5. Unity and ECS libraries
- Unity `GameObject`: "anything that can exist in a Scene." "GameObjects are the building blocks for scenes in Unity and act as a container for functional components which determine how the GameObject looks and what it does." (https://docs.unity.com/en-us/engine/current/manual/working-with-gameobjects/gameobject-fundamentals/class-game-object)
- Unity Entities package, entity: "An entity represents something discrete in your program that has its own set of data." Unlike a GameObject, an entity is an id that links components and contains no code. (https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/concepts-entities.html)
- Unity Entities package: "a data-oriented implementation of the Entity Component System (ECS) architecture," part of DOTS. The pages read do not state a problem it solves. (https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/index.html)
- flecs: "An entity is a unique thing in the world, and is represented by a 64 bit id." (https://github.com/SanderMertens/flecs/blob/master/docs/Quickstart.md) Also "just a unique identifier that does not contain any state"; ids are recycled and versioned so the API can tell if one is still alive. (https://raw.githubusercontent.com/SanderMertens/flecs/master/docs/EntitiesComponents.md) No problem statement found on either page.
- EnTT: "An entity (the E of an ECS) is an opaque element to use as-is." ECS is "an architectural pattern used mostly in game development." No problem statement. The closest line is a trade-off "between performance and memory usage." (https://raw.githubusercontent.com/skypjack/entt/master/docs/md/entity.md)
- The one problem each says it solves: Unity GameObject, none stated; Unity Entities, not stated; flecs, not stated; EnTT, not stated.

### 6. A dropped item in each
- Minecraft: an entity with extra data. Java stores `Item` (the stack), `Age` (destroyed at 6000 ticks), `PickupDelay`, `Health`, `Owner` (only UUID allowed to pick it up) and `Thrower`. Only blocks move or stop it; it does not collide with most entities. Spin and bob are visual only. Merging stacks keeps the longer timer. (https://minecraft.wiki/w/Item_(entity)) In code, `ItemEntity` extends `Entity` (NeoForge page above).
- Godot: no documentation page on a dropped item found. By the node description, it would be a node with a script, but no source says so. Not found.
- Unity GameObject: no page found. Not found.
- Unity Entities, flecs, EnTT: no page read describes a dropped item. By their definitions (an id with components) it would be an id with components, but no source says so. Not found.

## Where the sources disagree, or are weak
- The Minecraft wiki lists position, motion and a bounding box as common. NeoForge shows save and sync methods on every `Entity`. No single page lists all of these together.
- The wiki is silent on why block entities are separate. NeoForge gives a reason (unbounded data a block state cannot hold). The NeoForge reason is stated for block entities, not for entities.
- Unity uses "entity" for an id with no code and "GameObject" for a container with code. Godot calls neither an entity. flecs and Unity agree an entity is an id; EnTT calls it "opaque."
- No source states a single problem that an entity solves. Every definition says what it is, not why it exists.
- The fetch tool summarises pages with a small model. Each quote is that tool's report, not checked against the raw page. The Minecraft Entity and Item pages were read only to character 100,000 of about 106,000 and 149,000.

## What follows for someone building such a game
- Minecraft entities are what moves in the world; blocks are not. (Finding 2)
- Minecraft keeps stationary data in a second kind of thing, block entity, because a block state cannot hold unbounded data. (Finding 2, NeoForge)
- Minecraft's per-entity shared work is tick, save and sync to clients. (Finding 1, NeoForge)
- A dropped item in Minecraft is an entity holding an item stack plus age, pickup delay, owner and thrower. (Finding 6)
- The ECS libraries define an entity as an id with no state; the data sits in components. (Finding 5)
- No source gives the one problem an entity solves, so that cannot be settled from these sources. (Findings 3 and 5)
- Godot has no entity; a node is a building block in a tree. (Finding 4)

## Not found
- A Minecraft developer or Fabric/NeoForge statement of the one problem an entity solves.
- Minecraft's `LivingEntity` and `Mob` classes in a source.
- That Minecraft collides entities and finds entities in a region, in a source.
- Why the wiki separates block entities from entities.
- An id as common entity data in the wiki text.
- A stated problem solved by Unity GameObject, Unity Entities, flecs or EnTT.
- A dropped item in Godot, Unity GameObject, Unity Entities, flecs or EnTT.
- Fabric's entity page (404). EnTT's crash-course wiki page (did not load). Video or talk sources (none read).

## Sources
- https://minecraft.wiki/w/Entity
- https://minecraft.wiki/w/Block_entity
- https://minecraft.wiki/w/Item_(entity)
- https://docs.neoforged.net/docs/entities/
- https://docs.neoforged.net/docs/blockentities/
- https://docs.godotengine.org/en/stable/getting_started/introduction/key_concepts_overview.html
- https://docs.godotengine.org/en/stable/getting_started/introduction/godot_design_philosophy.html
- https://docs.godotengine.org/en/stable/classes/class_node.html
- https://docs.godotengine.org/en/stable/classes/class_node3d.html
- https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html
- https://docs.unity.com/en-us/engine/current/manual/working-with-gameobjects/gameobject-fundamentals/class-game-object
- https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/concepts-entities.html
- https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/index.html
- https://github.com/SanderMertens/flecs/blob/master/docs/Quickstart.md
- https://raw.githubusercontent.com/SanderMertens/flecs/master/docs/EntitiesComponents.md
- https://raw.githubusercontent.com/skypjack/entt/master/docs/md/entity.md

## Checked by a second reader
Second reader, Sonnet, 2026-11-21. Pages were read through the same summarising fetch tool, and the NeoForge and Minecraft wiki pages were also read as raw source (raw.githubusercontent.com/neoforged/Documentation/main/docs/blockentities/index.md, .../entities/index.md; minecraft.wiki/w/Entity?action=raw, minecraft.wiki/w/Item_(entity)?action=raw). No video or talk was read.

- Claims checked: 24.
- Confirmed: 19. Wrong: 4. Unconfirmed: 5 (some claims are counted in more than one group because one line holds several claims).

### Wrong
- "No page carries a date" (line 3). The Block entity page says "Last edited: 15 September 2026, at 19:09" (https://minecraft.wiki/w/Block_entity). The Entity page gives a revision id, oldid=3900945 (https://minecraft.wiki/w/Entity). The Entity and Item pages show no edit date.
- "`LivingEntity` and `Mob`: not confirmed by any page I read" (finding 1). The NeoForge page names `LivingEntity` as a base class under `Entity`: "anything 'living', in the sense of it having things like hit points, equipment, mob effects" (https://docs.neoforged.net/docs/entities/, raw line 351; hierarchy at line 329). `Mob` is named on the same page only as a class with its own spawning and pick-result handling, not as a subclass in the hierarchy. So `LivingEntity` is confirmed; `Mob` is mentioned but its place in the tree is not shown.
- NeoForge block entities "otherwise work much like entities" (finding 2, in quotation marks). The page says: "Block entities are stationary and bound to a block, but otherwise share many similarities with entities, hence the name." (https://docs.neoforged.net/docs/blockentities/). The quoted words are not on the page.
- `CharacterBody3D` page "as read does not state" velocity (finding 4). The page lists a `velocity` property: "Current velocity vector (typically meters per second), used and modified during calls to move_and_slide()" (https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html). The Godot side of the comparison with Minecraft's entity therefore has velocity.

### Minor wording differences
- Brief: a block entity ticks "while its chunk is loaded" (finding 2). The wiki says "while loaded" and does not name chunks (https://minecraft.wiki/w/Block_entity). The wiki's Item page does tie item despawn to a loaded, entity-ticking chunk.
- Brief: "Every subclass implements" the three save and sync methods and `hurtServer`. NeoForge says `Entity` is abstract and defines four required methods (raw line 121). Same meaning.

### Unconfirmed (I did not open or could not verify)
- Falling block "normally exists as a block" quote (finding 2). The page agrees a falling block is an entity; I did not check the quoted words.
- Unity `GameObject` quotes (finding 5): not opened.
- Unity Entities index page "data-oriented implementation of ECS" and "pages read do not state a problem": not opened.
- Godot `Node` page quotes (finding 4): not opened. The `Node3D` quote "All other 3D nodes inherit from this class" is confirmed.
- Fabric page 404 and the EnTT crash-course page not loading: not retried.

### Confirmed (source address, no date shown unless stated)
- "all dynamic objects"; common position, rotation, velocity, bounding box, fire, status effects, view point; no id or saved data listed as common; dropped item, arrow, minecart and painting are entities; blocks are not (https://minecraft.wiki/w/Entity).
- Block entity definition and the seven examples (https://minecraft.wiki/w/Block_entity, edited 2026-09-15).
- Item entity: NBT Age (destroyed at 6000 ticks), PickupDelay, Owner (only that UUID may pick up), merge keeps the longer timer, blocks move or stop it (https://minecraft.wiki/w/Item_(entity)). The page also says boats, chest boats, happy ghasts and shulkers do collide with items; the brief's "most entities" covers this.
- NeoForge entity definition, `tick`/`baseTick`/`rideTick`, the four required methods, `ItemEntity` as a direct subclass (https://docs.neoforged.net/docs/entities/).
- NeoForge block entity reason: "in cases where block states are not suitable", "non-finite amount of options", "stationary and bound to a block" (https://docs.neoforged.net/docs/blockentities/).
- Godot: "do not work like components in some other game engines", scenes "work like a class", "like nested prefabs" (https://docs.godotengine.org/en/stable/getting_started/introduction/godot_design_philosophy.html); `CharacterBody3D` description (page above).
- Unity Entities: "represents something discrete in your program that has its own set of data"; an id "rather than containing any code" (https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/concepts-entities.html).
- flecs: "unique thing in the world, and is represented by a 64 bit id" (https://github.com/SanderMertens/flecs/blob/master/docs/Quickstart.md); "just a unique identifier that does not contain any state"; recycled ids carry a version so liveness can be tested (https://raw.githubusercontent.com/SanderMertens/flecs/master/docs/EntitiesComponents.md).
- EnTT: "opaque element to use as-is"; "architectural pattern used mostly in game development"; trade-off "between performance and memory usage"; no problem statement (https://raw.githubusercontent.com/skypjack/entt/master/docs/md/entity.md).

### Lines of "What follows" that go further than their evidence
- "Minecraft entities are what moves in the world; blocks are not." The brief's own finding 2 lists the painting as an entity that is immovable, and block entities are stationary things that tick. The wiki says "dynamic objects", not "what moves". Weaker: entities are the wiki's "dynamic objects", and blocks are not entities.
- "Minecraft keeps stationary data in a second kind of thing, block entity, because a block state cannot hold unbounded data." The reason comes from NeoForge, a modding library's docs, and the brief says the wiki gives none. The line states it as Minecraft's own reason. Say "NeoForge's docs say".
- "Minecraft's per-entity shared work is tick, save and sync to clients." The evidence is method names on a modding class. The brief's own finding 1 says the rest (collision, region lookup) was not found, so "is" reads as the full list. It is a list of what NeoForge exposes.
- "The ECS libraries define an entity as an id with no state." flecs and Unity say this. EnTT says only "opaque element"; Unity also says an entity is something "that has its own set of data". Two of three sources say it.
- The lines on dropped item, Godot, and "No source gives the one problem" are supported by their findings. The last is a negative result: it holds for the pages read and the sources not read (developer talks, Fabric) leave it open.
