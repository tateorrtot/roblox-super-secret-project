# Core Rule Design, November 2026

Compiled 2026-11-18. This is the design work on the one thing the user has confirmed: the game has no core activity. It has a core rule, as Minecraft has blocks. Every good is a real object or a real event, and the world is full of things that take inputs and give outputs through processes. See "THE CORE OF THE GAME" in `CLAUDE.md` for the user's own words, including that tiers inside the web are fine.

Two researchers grounded the work, four designers each designed the rule-set from a different angle, and three judges scored all four. **The user had not seen any of this when it was written, and nothing here is agreed.** Scores are three opinions, not a measurement. The grounding briefs were not independently re-checked.

## Scores

| Design | Angle | Advocate | Systems | Engineer | Total |
|---|---|---|---|---|---|
| **Process cards** | Processes first | 8 | 8 | 7 | 23 |
| **Hands, holders and stations** | What it feels like in the hands | 7 | 7 | 8 | 22 |
| Stuff, form and three dials | Properties first | 7 | 7 | 5 | 19 |
| Want-and-offer web | Wants first | 6 | 5 | 6 | 17 |

No judge marked any design as a ladder or a single loop. All three judges reached the same conclusion independently: build on the process card and the slot-based physical model together, take the best parts of the other two, and drop the points-and-standing system from the wants design.

## The rule-set the judges converged on

### 1. Every thing sits in a slot
A thing is always in exactly one slot of one holder: your hands, a pack, a crate, a cart, a station's tray, a plate, a seat, a bed. Nothing is ever a loose physics object. Things come in four sizes, and a huge one needs two bodies or wheels to move. On a phone this is three buttons (take or put, use, pack), and when you hold something, every slot that would accept it shows a ghost outline.

This one rule is the control scheme, the save format and the protection against duplication at once. The grounding research found that no shipped Roblox game keeps every good as a live physics object; the ones that lasted make goods physical only while someone handles them.

### 2. Everything that transforms is a process card
Any thing can carry cards with four parts: what it **takes**, what it **needs** (a tool, a condition, a helper), how much **time**, and what it **gives**. A hen, a stove, a guest, a ritual, a raider and a faction's trade offer are all the same card. New content is new cards, written as data.

### 3. Context: things give off aspects, and bodies respond
Places, weather and running stations give off aspects such as heat, chill, spark, rot and dark, in a radius you can see. Every people, creature and material has a short table of how it responds. What you wear or eat edits your own table. A mark is the single mechanism behind an enchantment, a meal's effect, protection and a player's people.

Because a running station gives off an aspect as well as needing one, where you put things matters. A lit stove is a cooker, a heater, a hatchery and, on a cart, a camp you can push into a frozen cavern. Nobody scripts those.

### 4. A body can sit in a slot too
A service is a process with a body in one of its slots: a patient in a cot, a passenger in a seat, a guest at a table. A worker spot accepts any body, so the player, a friend or a hired hand can do the job. You teach a helper by doing the job once in front of it.

### 5. Capabilities are bought in kind
A machine, recipe card or helper sits behind glass at a faction's counter, with the goods it wants shown as empty slots beneath it. Fill them and it comes out as a crate you have to get home. There is no reputation bar and no points.

### 6. Kind and material, with plain tiers
A thing is a kind (pick, coat, crate) made of a material (wood, iron, crystal). Materials have a few plain numbers and at most two odd tags, such as lead shielding its contents. Tiers stay plain, and each cheap tier keeps one odd use. A transmuter changes the material and keeps the shape.

### 7. Direction without a task list
Holding a thing lights up everything that wants it and crosses out everything that refuses it. Slots that would accept it but lack a condition show that condition greyed out. Towns show their state on their buildings. An almanac records processes the player has seen, with silhouettes for ones they haven't.

## How the user's own examples fared
One judge walked each of the user's examples through each design using only its stated rules.

| Example | Result in the leading designs |
|---|---|
| Crystals traded to a faction for a machine that turns lead to gold | Works exactly; one row of data |
| Lightning that harms an enemy and empowers a people | Works |
| A cake with a specific effect | Works; effects are an open list |
| A travelling hospital that charges | Works: a cot and stove on a cart |
| A nomad living in a caravan | Works: a cart is a home that saves |
| A city that turns remains into fertiliser | Works as a faction; no way stated to own a vat yourself |
| Creature fur into armour | Half works: it makes weather gear, and nothing yet reads a material as protection from blows |
| A truck trip to a crystal cavern | Partly: every design starts with a handcart and defers trucks, and helpers can't yet do the trip |

## What all four designs missed
These came from the judges and need answers before or during the first build.

- **Factions don't feed each other.** The user's clearest content rule was "what each place needs, from whom, and what it makes for whom". In all four designs towns take only from the player, so the player is at the centre of every strand. No NPC caravan runs between two towns that a player could raid, guard, undercut or replace.
- **Conflict isn't a process in the web.** Nothing models a faction attacking a settlement, players taking sides, or the wounded and remains that follow.
- **A relationship with a faction is only a number.** The user listed stranger, supplier, neighbour, vassal and ruler.
- **The player's own people is deferred** in three of four designs, so "the same thing means different things" is felt only through helpers.
- **Built transport and building are absent.** No design treats a rail line, dock or ferry as something a player builds and others ride, and none lets walls or a roof matter to the rule.
- **Free-value holes.** Three designs let the cheapest possible object satisfy a town's request. Every request needs checking for its cheapest satisfier before humans play.
- **The web is a star.** All four made crystal the hub good and one cold cavern the hub place.
- **Capabilities never wear out,** so everyone ends up owning everything. The user's calibration says the top tier should cost something to keep.
- **Minutes one to six are empty.** Every first build fills them with timers, in a server with one real player.
- **The first taste of the context rule is a punishment:** the first interesting place is cold and the remedy isn't in reach.
- **Nothing is fun in the hand.** Every opening verb is put, give or hold. The first build needs one act with weight and feedback.

## Claude's proposed first build (not agreed)
The smallest thing that shows whether the rule blossoms, following the engineer judge:

- The handling layer on a phone: slots, three buttons, ghost outlines, four sizes, a handcart that is your first home.
- One living thing that can be tamed by feeding it.
- One heat-giving station, and one cold place whose remedy is within reach.
- One visible machine to earn in kind from a faction.
- One enchantment and one people other than the default, because those are what the user would look for first.
- One NPC caravan running between two settlements, so the web has a strand the player isn't at the centre of.
- A test harness: bot players, a clock that can be jumped, and a script that reports the cheapest way to satisfy every request.

Hired helpers, trading between players and driven vehicles come after the first phone test. The test is whether a player combines things in a way nobody scripted.

---

# Grounding briefs

## Physical objects on Roblox

#### Physical goods on Roblox: what shipped games and Roblox's own docs support (read 2026-11-18)

**Bottom line:** no shipped game treats every good as a permanently live physics object. The survivors keep goods physical only while someone is handling them, then anchor, weld, containerise or count them. That fits the brief's Minecraft point: tiers of fidelity are fine, and not every good needs the full physical treatment.

##### 1. Live snapshot (games.roblox.com/v1/games, this run)

| Game | Playing | Visits | Max players* | What is physical | What is abstracted |
|---|---|---|---|---|---|
| Lumber Tycoon 2 | 1,280 | 1.34B | 6 | Logs, planks, boxed items, vehicles | Money, axes (tool inventory) |
| Oaklands | 225 | 61.9M | 8 | Wood, ore, crates, vehicles | Not found |
| Refinery Caves 2 | 66 | 18.7M | 8 | Ores, trees, items, crates, vehicles | Sack, item bag, storage units |
| Dead Rails | 16,739 | 6.66B | 16 | All loot, corpses, fuel | Sack (10 items, 15 with pass), toolbar, ammo |
| A Dusty Trip | 9,710 | 2.64B | 25 | Car parts, items | Not verified |
| 99 Nights in the Forest | 93,050 | 30.6B | 25 | Logs, scrap, fuel, corpses | Sack (5/15/20/25 items) |
| Booga Booga | 778 | 271M | 50 | Dropped items only | Bag inventory |
| Build A Boat | 9,420 | 5.26B | 7 | Placed blocks | Block inventory, save slots |
| Islands | 427 | 2.36B | 20 | Dropped items, placed blocks | Hotbar and inventory |
| Retail Tycoon 2 | 630 | 341M | 6 | Not found | Cargo is a number (300 to 2,500 per vehicle) |

*Root-place value; lobby-based games may run smaller match servers (not found).

##### 2. Lumber Tycoon 2

- **Physical model:** logs behave as loose objects you carry to a sawmill or dropoff. Wood is sold by physically touching the dropoff. Shop items are boxes you drag to a counter.
- **Saving:** six slots. Only items and structures on your Land save; logs never save and despawn or get claimed. Loading a large slot lags the whole server. A slot over the data limit becomes effectively read-only, and disconnects mid-load have erased slots.
- **Phones:** mobile support arrived 15 April 2020, five years after launch. The wiki mentions only a bottom-left interact button; drag specifics were not found.
- **Vehicles:** loads are loose, not welded. The 2022 patch "revamped" network ownership so trucks carry better and items stop spilling when owned by another player.
- **Exploits:** a March 2017 leak exposed server code. The wiki says nearly every server from 2019 to 2026 saw an exploiter. Duplication was only declared fully patched on 20-21 October 2026 (v2575).
- **Dupe classes fixed:**
  - rejoining before the old server saved;
  - dragging items onto another plot while a laggy slot loads (fixed by blocking interaction until load completes);
  - resetting or touching a dropped axe during reload;
  - reload-and-leave after driving items onto another plot;
  - a mobile/PC desync window.
- **Other fixes:** a leftover network-ownership debug hook was "the basis of most item teleportation exploits". "Save Items to Base" and "Sit in Seats" were made mutual permissions. Land is now destroyed even if its save fails.
- **Why it lasted:** not established by any source. The author said in 2015: "my abuse of physics in this game was actually pretty intentional". It still holds 1,280 concurrent players after a content drought from 2018 to 2024.

##### 3. Other games: what they were forced to do

- **Refinery Caves 2:**
  - "Items now Anchor if no player is around" (Aug 2024).
  - "Made Vehicles not calculate physics when no Player is nearby".
  - Ores weld into vehicles.
  - It removed an "All-in" client networking model so clients simulate only some physics.
  - Owned items no longer collide with other players' items.
- **Oaklands:** on 10 May 2024 it gave players physics ownership of all their items "to reduce server lag", and reverted on 13 May. Crates anchor their contents. Vehicle stacking via conveyors was removed for griefing. Mobile dragging needed repeated fixes, including a thumbstick conflict and a new mobile drag UI.
- **Dead Rails:** on phones it uses on-screen Store, Drag, Drop and Weld buttons aimed by a crosshair. Items must be welded to the train or they fall off. The wiki records that many welded items can leave servers unable to keep up. Weld-state bugs produced two "infinite duping" bugs, and a rapid shop lever double-charged and duplicated items.
- **99 Nights:** a counted sack with a Store/Unstore button; holding it dumps everything. Two players chopping one tree at once can double the logs. Persistence: not found.
- **Islands:** dropped items are capped at 30 for player drops and 80 for machine drops, with a 120-second despawn, and they vanish when the island owner leaves. It had an economy wipe on 22 January 2021 and trading disabled from 29 December 2021 to 6 January 2022 over dupes.
- **Booga Booga:** fast clicking "Buy" in the Market duplicated trade chests, leading to bans and the Market's removal.
- **A Dusty Trip:** a 2024 guide gives tap to pick up and place, and tap-and-hold to attach.
- **Build A Boat:** merging blocks is said to cut physics lag; no block limit was found.

##### 4. What Roblox says

- **Sleep:** a sleeping assembly is "not simulated". Each assembly is one rigid body, so welded goods cost one body.
- **Anchored parts:** the server always owns them. Staff's Physics Best Practices post adds "Anchored parts are always asleep".
- **Network ownership:** the owning client has "complete authority" over the physics. It can teleport parts, set Inf/NaN velocities to fling others, and fake Touched events. The docs advise assigning loose parts on a vehicle to the driver.
- **Streaming:** assemblies stream in as complete units. The docs warn against moving assemblies with large instance counts because of network and CPU spikes. Defaults are a 64-stud minimum radius and 1,024 target. Nothing specific on small parts was found.
- **Bandwidth:** a guest article posted on DevForum (Aug 2024) gives the only numbers found.
  - Client receive caps at 50 KB/s.
  - Physics updates throttle above 40 KB/s.
  - A moving object costs about 0.4 to 0.9 KB/s.
  - That gives a budget of "around 40-60 physics assemblies" moving at once.
  - It also recommends under 1.3 GB client memory for 2 GB phones.
- **Client-rendered goods:** the same article runs up to 200 coins per player as server table records with serial numbers. Clients clone them locally and anchor them after a short bounce.
- **Devices:** Android is roughly 65% of a typical player base, and about 60% of those have 2 to 4 GB of RAM.
- **Official part or assembly counts for phones:** not found. A 2026 DevForum thread reports low frame rates on low-end devices with about 200 loose objects; that is one anecdote.

##### 5. Server Authority (full release 9 July 2026)

- **Setup:** opt-in. It forces streaming, fixed simulation, deferred signals and Next Generation Replication.
- **Carried objects:** an item welded to a predicted character is predicted with it. A separate assembly is predicted only inside a simulation radius that "grows and shrinks" with device performance.
- **Limits:**
  - 64 replicated attributes per instance, with 50-character strings.
  - No Destroy or reparenting inside the simulation.
  - Remote events are not synchronised with the simulation timeline.
- **Cost:** server utilisation rises. A misprediction at 100 ms means 6.25 times the client simulation load.
- **Tools:** the release post says Backpacks and Tools are "now fully supported"; the docs page still says they are not.
- **Drag detectors and proximity prompts:** client-authoritative at Studio beta; current status not found.
- **Reliability:** an August 2026 bug report describes degraded sessions, "especially on mobile devices". Staff replied that fixes were en route.
- **Trading:** nothing specific found.

##### Sources

- Live stats: https://games.roblox.com/v1/games?universeIds=2471084,3666294218,4298676072,7018190066,5650396773,7326934954,4154513353,210851291,1659645941,2092410051
- Lumber Tycoon 2 wiki (via api.php): https://lumber-tycoon-2.fandom.com/wiki/Duplication, /Autumn_Patch, /Great_Patch_of_2022, /Load, /Logs, /Land, /Errors, /March_2017_Game_Leak, /Lumber_Tycoon_2, /Tutorial
- Author's 2015 post: https://devforum.roblox.com/t/18069
- Refinery Caves: https://refinerycaves.fandom.com/wiki/Changelog_(RC2)
- Oaklands: https://oaklands.fandom.com/wiki/Version_1.55.0, /Version_1.56.0, /Version_1.27.0, /Version_1.0.0, /Small_Crate
- Dead Rails: https://deadrails.fandom.com/wiki/Sack, /Inventory, /Bugs_and_Glitches, /Bugs_and_Glitches/Patched_Bugs, /Changelogs, /Train
- 99 Nights: https://99-nights-in-the-forest.fandom.com/wiki/Sacks, /Bugs_%26_Glitches
- Islands: https://robloxislands.fandom.com/wiki/Item, /Player%27s_Island, /Duplication_(Dupe), /Trading
- Booga Booga: https://booga-booga-roblox.fandom.com/wiki/Glitches
- Build A Boat: https://build-a-boat-for-treasure.fandom.com/wiki/Merging
- Retail Tycoon 2: https://retail-tycoon.fandom.com/wiki/Vehicles
- A Dusty Trip: https://gamertweak.com/a-dusty-trip-controls/
- Roblox docs: https://create.roblox.com/docs/physics/sleep-system.md, /physics/network-ownership.md, /scripting/security/network-ownership.md, /workspace/streaming.md, /performance-optimization/improve.md, /performance-optimization/test-on-hardware.md, /projects/server-authority.md, /projects/server-authority/techniques.md, /cloud-services/data-stores/player-data-purchasing.md, /ui/3D-drag-detectors.md
- DevForum (raw): https://devforum.roblox.com/raw/3127146/1, /raw/280812/1, /raw/4727993/1, /raw/4624565/1, /raw/4139157/1, https://devforum.roblox.com/t/4772071, /t/4834429

### Direct answers
- (a) Budget: the only numeric budget found is about 40 to 60 simultaneously MOVING assemblies visible to one client. It comes from a guest article on DevForum (Aug 2024): client receive caps at 50 KB/s, physics updates throttle above 40 KB/s, and each moving object costs 0.4 to 0.9 KB/s (https://devforum.roblox.com/raw/3127146/1). That budget is shared with characters and vehicles, so by simple division 8 players in one area get roughly 5 to 7 moving goods each; that division is mine, not a source's. Shipped caps point the same way: Islands allows 30 player-dropped and 80 machine-dropped items per island with a 120-second despawn; Dead Rails sacks hold 10 to 15; 99 Nights sacks hold 5 to 25. Goods at rest can be far more numerous if anchored, since Roblox says anchored parts are always asleep and sleeping assemblies are not simulated, but no Roblox figure for at-rest counts on 2 to 4 GB phones was found. One 2026 DevForum anecdote reports low frame rates on low-end devices with about 200 loose unanchored objects.
- (b) Phone carry-and-place: the most robust shipped pattern is the Dead Rails / 99 Nights one (16,739 and 93,050 concurrent players in this run). The player aims with a crosshair or proximity and uses dedicated on-screen buttons: Store/Unstore into a counted sack (the item reappears in front of the player; holding the button dumps everything), a Drag button for oversized objects, and a Weld button to fix an item to the train or cart. A Dusty Trip uses tap to pick up and place and tap-and-hold to attach (2024 guide). Free physics dragging in the Lumber Tycoon 2 style is the fragile option on phones: Oaklands' changelog shows repeated mobile drag fixes, a conflict with the thumbstick mode and a rebuilt mobile drag UI, and Lumber Tycoon 2 only got mobile support in April 2020. Roblox's DragDetector supports touch natively with a scriptable permission function, but nothing found shows a hit game shipping it.
- (c) Representation: keep a server-side record per good as the truth, and give it a real instance only when a player is near. Four states are each backed by a shipped game or doc. At rest it is anchored and server-owned (Refinery Caves 2: 'Items now Anchor if no player is around'; Oaklands crates anchor their contents). While handled it is unanchored for that one player. In transit it is welded to the character or vehicle so the whole load is one assembly (Dead Rails weld-to-train; Refinery Caves 2 ores weld in vehicles; Roblox docs: one assembly is one rigid body; under Server Authority a welded item is predicted with the character). In bulk it becomes a count inside a container (sacks, crates, Retail Tycoon 2's numeric cargo capacity). Purely cosmetic piles can be rendered client-side from server records with serial numbers, as the guest article does for 200 coins per player, never replicated.
- (d) Surviving a server stop: in every game checked, goods persist only as serialized data tied to an owned plot or container, never as loose world objects. Lumber Tycoon 2 saves only what is on your Land to one of six slots; logs never save, oversize slots become read-only, and interrupted loads have erased slots. Islands drops despawn when the island owner leaves. Dead Rails is run-based with no persistence (inferred from its per-run structure, not stated by a source); 99 Nights persistence was not found. Roblox's reference pattern is session-locked player data written with UpdateAsync, a periodic autosave (180 seconds in the sample) and a final save on PlayerRemoving and BindToClose. Loose goods in the open world should be declared ephemeral by design.
- (e) Exploit risks: there are two families. Physics authority: a client that owns a part has 'complete authority' over it, so it can teleport goods, fling players with Inf/NaN velocities and fake Touched events (Roblox security docs); Lumber Tycoon 2's teleport and 'base drop' exploits ran on a leftover network-ownership debug hook. Save and trade races: rejoining before the old server saves, dragging goods onto another plot during a laggy load, reload-and-leave, double-fired purchases (Booga Booga's Market, a Dead Rails shop lever), weld-state bugs (Dead Rails), simultaneous actions on one object (99 Nights logs) and mobile/PC desync. Known defences: session locking; blocking all interaction with a player's objects until their load completes; mutual save and seat permissions; destroying a plot even when its save fails; keeping gameplay-critical goods anchored or server-owned; no collision between different owners' goods (Refinery Caves 2); serial numbers on client-rendered goods; and logging save wipes. Even UI-based trading was duped in Islands, with trading disabled 29 Dec 2021 to 6 Jan 2022 and an economy wipe on 22 Jan 2021. Lumber Tycoon 2's duplication was only declared fully patched in October 2026.
- (f) Prototype first: (1) how many anchored-at-rest goods a 2 to 4 GB Android phone tolerates in the streamed area, for memory and draw calls; (2) the wake delay and feel when an anchored good is grabbed or hit; (3) a vehicle carrying N welded goods streaming in as one unit, which the docs warn can spike network and CPU; (4) whether the 40 to 60 moving-assembly figure from 2024 still holds under the 2026 replication changes; (5) Server Authority with loose goods on phones, covering resimulation cost, the device-scaled simulation radius and the mobile session bug reports; (6) whether drag detectors and proximity prompts are server-authoritative now; (7) phone usability of button-based stacking and loading onto vehicles; (8) save size and load time for a plot holding the target number of goods.
- Server Authority, fully released 9 July 2026 and opt-in, lets carried goods stay server-owned without input lag. An item welded to the character is predicted with it; a separate loose assembly is predicted only inside a simulation radius that shrinks on weaker devices. Costs and limits: higher server utilisation, 6.25 times client simulation load on a misprediction at 100 ms latency, 64 replicated attributes per instance with 50-character strings, no Destroy or reparenting inside the simulation, and remote events not synchronised with the simulation. The release post says Tools are fully supported while the docs page still says they are not. Nothing specific to trading was found.
- Server size: the games built on persistent, freely draggable goods all run small servers (Lumber Tycoon 2 at 6, Oaklands 8, Refinery Caves 2 at 8, Build A Boat 7, Retail Tycoon 2 at 6). The much larger current hits (Dead Rails, 99 Nights, A Dusty Trip) are run-based, cap what a player carries with a sack, and weld or attach loads to a vehicle. Their API max-player values of 16 to 25 are root-place figures; match-server sizes were not found.

### Unproven
- No Roblox documentation or staff post was found that gives a part or assembly count that holds on low-end phones. The 40 to 60 moving-assembly figure is one community expert's mid-2024 opinion in a guest article, and it predates the June 2026 physics replication rollout.
- How Lumber Tycoon 2's drag works on a phone (controls, rotation, stacking) was not found in any page read. Its internal drag implementation and per-server loose-object counts were also not found.
- Why Lumber Tycoon 2 has lasted is not established by any source; the report gives only facts (player count, update history, the author's 2015 statement).
- Per-server or per-player loose-object counts were found only for Islands (30 and 80). Counts for Dead Rails, 99 Nights, A Dusty Trip, Oaklands and Refinery Caves were not found.
- Match-server sizes for Dead Rails, 99 Nights and A Dusty Trip were not found; the API values (16, 25, 25) are for the root place.
- A Dusty Trip details rest on one April 2024 guide; no wiki API was reachable. Its backpack persistence appeared only in a search summary and was not read directly.
- Retail Tycoon 2: whether cargo is shown as visible physical boxes was not found; only numeric cargo capacity was read.
- Build A Boat: block limits and per-server physics counts were not found.
- 99 Nights in the Forest: whether goods or bases persist between sessions was not found.
- Dead Rails having no persistence between runs is my inference from its per-run structure; no page read states it.
- Booga Booga wiki pages read appear to describe the classic game and may not match the current 'Booga Booga [Combat]' place whose stats were pulled.
- Instance streaming behaviour for small parts specifically (pop-in, priority) is not described in the streaming doc read.
- Server Authority: whether DragDetectors, ProximityPrompts and ClickDetectors are server-authoritative in the full release was not found (they were client-authoritative at Studio beta). Tool support is contradictory between the release post and the docs page. Nothing on trading was found.
- The Lumber Tycoon 2 wiki's claim that duplication was patched 'in its entirety' in October 2026 is a community wiki statement about a patch weeks old; it is not verified independently.

## How systemic sandbox games are built

### How "one rule, many activities" games are built underneath

`docs/research/04-activity-research.md` did not exist, so nothing was taken from it. Fandom wikis refused requests, so the Roblox rows lean on third-party guides. Everything I could not check is listed under `unproven`.

#### 1. The games

| Game | Unit, and what it carries | Interactions are keyed on | Direction and first minutes | Fails by |
|---|---|---|---|---|
| **Minecraft** | Block or item stack on one grid. Hardness, tool tier needed, flammability, light, plus tags (`#planks`). | Tags and properties. Sticks accept any plank. Leather boots cross powder snow because they carry the tag `freeze_immune_wearables`. | No task list. Night is the first need, and wood → table → pickaxe is the only chain in reach. The recipe book and advancements arrived in 1.12. | Needed a wiki before 1.12. After the dragon, only self-set goals remain. |
| **Breath of the Wild** | Materials (solid objects, including the player) and elements (fire, water, ice, wind, electricity). | Three rules: elements change materials; elements change elements; materials never change materials. | A walled plateau hands over the tools, then opens. | Chemistry feeds puzzles and fights, not an economy. |
| **RimWorld** | A Thing defined by a Def; a "Stuff" material scales its stats. Pawns carry needs, skills, genes. | Categories and stat maths: any Leathery stuff fills any leather recipe. | Three pawns and supplies. Need bars and storyteller events supply the goals. | Raid size follows colony wealth, which pushes players to one defensive answer. |
| **Dwarf Fortress** | Item type × material. Materials carry density, yield strength, edge, melting point. | Reactions take reagents by class (`REACTION_CLASS`, e.g. any FLUX stone). | Almost none. | Opacity. |
| **Factorio / Create** | Item on a belt; machine = recipe + speed + power. Create uses in-world rotation with a stress budget instead of menus. | Recipes are per item, but belts, trains and pipes carry anything. | Mine by hand, then the first drill removes that job. Science packs are the visible goal. | Solved ratios and pasted blueprints. In Create, nothing consumes the output. |
| **Noita / Caves of Qud** | Noita: a pixel of material with tags. Qud: an object as a set of composed properties. | Noita's reactions name tags (`[water]`, `[corrodible]`), so a new material joins by tag. | Death teaches. | Chain reactions nobody can read. |
| **Potion Craft / Stardew Valley** | Potion Craft: an ingredient is a direction and length on a map. Stardew: item with category, quality, season. | Potion Craft: geometry, so every ingredient combines with every other. Stardew: per recipe, but one crop feeds sale, cooking, gifts, machines and bundles. | Stardew: a few seeds, and Community Center bundles that ask for goods from every system. | Potion Craft: customers are the only sink. Stardew: one best crop-to-keg line. |
| **Foxhole** | Crate, truck, stockpile at a place. | A fixed chain: scrap → materials → crates → front. Everything is consumed (a shirt per respawn). | Other players ask for supplies. | Logistics became shift work: about 1,800 players struck in 2022. |
| **EVE / Albion** | Item with volume, at a location. | Recipes; meaning comes from place. Albion's markets are per city, and a city's refining speciality returns about 37% of materials against about 15% elsewhere. | Guided tutorials. | Spreadsheet play; needs thousands online. |
| **Lumber Tycoon 2** | A log: physical, with size, species and cut state. | Physics and volume. Sawmill, truck and drop-off accept any wood. | $20, a $12 hatchet in the shop across the road, trees in sight, no instructions. | Few uses for money; species form a ladder relieved by secrets. |
| **Bee Swarm Simulator** | Bee with rarity and abilities; fields; quest bears. | Stacking bonuses between bees, gear and fields. | The first bee gathers within seconds; bears point at fields. | Months-long number grind late on. |
| **Islands** | Block and item on a private island. Totems generate goods, conveyors move them, industrial machines process, vending machines sell. | Recipes; conveyors are generic. | Skyblock-style start. | Once automated, little left to want. |
| **Booga Booga** | Resource node, crafted gear, character level. | A recipe ladder gated by level; rebirth at 100. | Hit a tree, craft. | A ladder that resets, plus geared tribes. |
| **Miner's Haven** | Ore with a value and status effects; machines on a grid. | Upgraders act on any ore; some effects destroy ore within seconds unless countered. | Dropper → conveyor → furnace. | One number; rebirth resets it. |

**How capabilities enter the same system.** In every durable case the capability is itself an object. Minecraft's crafting table and enchanted book are items. Factorio's machines come out of the factory. RimWorld's workbenches are Things made of Stuff, and its genes are extracted, stored and traded. EVE's blueprints are tradeable. Lumber Tycoon's sawmill is a box you carry home.

**One correction.** Lumber Tycoon 2 does not hand you an axe. It gives $20, and the only thing worth buying is a $12 hatchet across the road. The effect is the same: one obvious first action.

#### 2. Cross-cutting findings

**(1) What produces emergence from few rules**
- **Interactions live on properties, not pairs.** RimWorld added Stuff precisely because wood walls and metal walls had been separate definitions. Noita, Dwarf Fortress and Minecraft do the same with tags and classes. A new item then interacts with old ones for free.
- **Two kinds of thing, with a short rule list between them.** Zelda's developers called the chemistry engine a "rule-based state calculator" (Thumbsticks, GDC 2017) and kept it to three rules.
- **Item × material.** N item types and M materials give N×M goods from N+M definitions.
- **Generic carriers.** Belts, trucks, redstone signal and rotation do not care what they carry.
- **Agents with needs.** Pawns, villagers, guests and factions turn any good into a reason.

**(2) What produces a ladder even in a sandbox**
- A single sink (coins, customers) with a single measure.
- Tier as the only difference between items. Minecraft's pickaxes are tiered and fine, because cost, upkeep and odd tags differ too. The leather boots are literally a tag.
- Rebirth or prestige as the answer to "what next" (Miner's Haven, Booga Booga).
- Threat that scales with wealth, which punishes growth and rewards one fortress design.
- Automation with nothing to feed.

**(3) Cold start**
- A need on a clock: night, hunger.
- A starting kit that affords exactly one action.
- A fenced starter area that releases the player.
- A visible menu of needs that points across systems, not up one: Stardew's bundles, Bee Swarm's bears, Factorio's science packs. These are task lists in practice; what matters is that they ask for different kinds of thing.
- Do it by hand first, then the first machine or helper removes exactly that job.

**(4) Making value contextual**
- Goods have volume and must be physically moved (Lumber Tycoon 2, EVE, Foxhole).
- Stock and prices are local to a place (Albion).
- A place gives a processing bonus for one family of goods (Albion).
- Goods are destroyed in use, so demand never ends (Foxhole, EVE).
- A property meets an environment or a body: insulation against climate, a gene that changes what food or temperature means.
- Risk on the route.

**(5) What survives phones, short sessions and one-or-two-player servers**
- **Survives:** tag and property rules (they are pure data); item × material; capabilities as objects; NPC settlements as fixed consumers with needs; a menu of needs; hand-first-then-helper; offline production computed from timestamps; shared numbers such as faction stock across servers.
- **Does not survive as built:** player-only economies and fronts (Foxhole and EVE need thousands present); pixel or voxel simulation at scale; hundreds of moving items on belts; raids on absent owners; heavy physics hauling on low frame rates (see docs/research/02 on Retail Tycoon 2).

**(6) Smallest content set that showed real emergence**
- **Designed:** Zelda's five elements, a handful of material properties and three rules. Fire makes an updraft that lifts a glider; a metal weapon draws lightning. The team reportedly proved the idea in a prototype styled on the first NES game.
- **Player-discovered:** Minecraft's redstone. A wire, a torch that inverts and a switch are enough for players to build logic circuits.

#### Sources
- [Thumbsticks: GDC 17 chemistry engine](https://www.thumbsticks.com/gdc-17-breath-of-the-wild-science-lies)
- [TechSpot: BotW prototype](https://www.techspot.com/news/68369-nintendo-created-2d-prototype-breath-wild-modeled-after.html)
- [RimWorld Wiki: Stuff](https://rimworldwiki.com/wiki/Stuff), [Raid points](https://rimworldwiki.com/wiki/Raid_points), [Metabolic efficiency](https://rimworldwiki.com/wiki/Metabolic_efficiency), [Work](https://rimworldwiki.com/wiki/Work)
- [Dwarf Fortress Wiki: Reaction](https://dwarffortresswiki.org/index.php/DF2014:Reaction), [Material definition token](https://dwarffortresswiki.org/index.php/Material_definition_token)
- [Noita Wiki: Reaction](https://noita.wiki.gg/wiki/Documentation:_Reaction)
- [Unity: Systems-driven design in Caves of Qud](https://unity.com/resources/systems-driven-design-in-caves-of-qud)
- [NeoForge docs: Tags](https://docs.neoforged.net/docs/1.21.11/resources/server/tags), [Minecraft wiki: Leather Boots](https://minecraft.gamepedia.com/Leather_Boots)
- [Factorio FFF 275](https://direct.factorio.com/blog/post/fff-275), [Create Wiki: Kinetic Stress](https://create.fandom.com/wiki/Kinetic_Stress)
- [Wikipedia: Foxhole](https://en.wikipedia.org/wiki/Foxhole_(video_game))
- [Albion refining guide](https://heaven-guardian.com/albion-online-refining-guide/), [Albion economy guide](https://heaven-guardian.com/albion-online-economy-guide/)
- [EVE Monthly Economic Report](https://www.eveonline.com/news/view/monthly-economic-report-february-2026)
- [Lumber Tycoon 2 first axe guide](https://allthings.how/lumber-tycoon-2-how-to-get-your-first-axe-and-sell-wood/)
- [Islands Wiki: Coal Totem](https://robloxislands.fandom.com/wiki/Coal_Totem), [Islands stats](https://bloxodes.com/stats/games/islands-1659645941)
- [Miner's Haven blog description](https://churchillgary.blogspot.com/2017/11/miners-haven.html), [DevForum patch note](https://devforum.roblox.com/t/miners-haven-reincarnation-4-5-2020/511714)
- [Potion Craft walkthrough](https://www.trueachievements.com/walkthroughfull.aspx?walkthroughid=3793), [Stardew Wiki: Bundles](https://stardewvalleywiki.com/Bundles)
- [Booga Booga Reborn guide](https://earnaldo.com/blog/booga-booga-reborn-beginner-guide)

### Direct answers
- Define interactions on properties or tags, never on pairs of named items. RimWorld's Stuff system was added in version 0.7.581 because wood walls and metal walls had been separate definitions; Noita reactions name tags such as [water] and [corrodible]; Dwarf Fortress reactions accept any material with a REACTION_CLASS; Minecraft recipes accept #planks. A new item then works with every old one for free, which is what lets regions and peoples be data.
- The designer's own leather-boots example is implemented exactly this way: leather boots carry the item tag freeze_immune_wearables, and powder snow checks the tag. A cheap tier stays useful by carrying a tag the better tiers lack, with no special-case code. Tiers plus a few odd tags is the Minecraft pattern; it does not need every item to have several uses.
- Breath of the Wild's chemistry engine is the smallest designed example of emergence: two kinds of thing (materials = solid objects including the player; elements = fire, water, ice, wind, electricity) and three rules (elements change materials; elements change each other; materials never change each other). Its developers described it as a rule-based state calculator, alongside physics as a rule-based movement calculator.
- Item x material is the cheapest content multiplier found: N item types and M materials give N x M goods from N + M definitions, with stats computed from the material (RimWorld Stuff categories Metallic, Woody, Stony, Fabric, Leathery; Dwarf Fortress density, yield strength, edge). This is the structure behind the designer's 'thrumbofur armour' example.
- In every durable game the capability is itself an object in the same system as goods: Minecraft's crafting table and enchanted book are items; Factorio machines are products of the factory; RimWorld workbenches are Things made of Stuff and genes are extracted and traded as items; EVE blueprints are tradeable; Lumber Tycoon 2's sawmill is a box you buy and carry home. A machine, recipe, helper or enchantment should be something that can be carried, placed, given, stolen or sold.
- Generic carriers are what turn recipes into a web: belts, trucks, trains, pipes, redstone signal and Create's rotation do not care what they carry. Factorio's recipes are per-item and it still produces endless variety because the logistics layer is generic and each new product poses a new routing problem.
- What makes a ladder inside a sandbox is not tiers. It is: one sink with one measure (coins, customers); tier as the only axis of difference; rebirth or prestige as the answer to 'what next' (Miner's Haven, Booga Booga Reborn at level 100); threat scaled to wealth (RimWorld raid points = wealth points + pawn points, times difficulty and adaptation), which pushes players to one defensive answer; and automation whose output nothing consumes (Create, Islands).
- Cold start is handled five ways: a need that arrives on a clock (Minecraft's night, RimWorld's hunger); a starting kit that affords exactly one action; a fenced starter area that then releases the player (Zelda's plateau); a visible menu of needs that points across systems rather than up one (Stardew's Community Center bundles, Bee Swarm's quest bears, Factorio's science packs); and doing a job by hand before the first machine or helper removes exactly that job.
- Lumber Tycoon 2 does not literally hand you an axe: per a current guide the player spawns with $20, no axe and no instructions, and a $12 Basic Hatchet is sold in the shop across the road. An uncut oak sells for about $149, oak is $0.50 per unit as a log and $3 as a plank, and a utility vehicle costs $400. The lesson is the same as the designer's: the start affords one obvious action, and processing and transport are the first two capabilities bought.
- Value becomes contextual through six devices: goods with volume that must be physically moved (Lumber Tycoon 2, EVE, Foxhole); stock and prices local to a place (Albion's per-city markets); a place-bound processing bonus for one family of goods (Albion: about 36.7% material return in the speciality city against about 15.3% elsewhere, per guides); destruction in use so demand never ends (Foxhole consumes a shirt per respawn); a property meeting an environment or a body (insulation against climate; RimWorld genes shifting hunger rate from 50% to 225%); and risk on the route.
- Patterns that survive phones, short sessions and one-or-two-player servers: tag and property rules (pure data), item x material, capabilities as objects, NPC settlements as fixed consumers with needs, a menu of needs, hand-first-then-helper, offline production from timestamps, and shared numbers across servers standing in for a market.
- Patterns that do not survive as built: player-only economies and fronts (Foxhole launched with 64 players per region instance, later 120, across what is now 53 regions; EVE and Albion depend on thousands online); pixel or voxel simulation at scale (Noita); hundreds of moving items on belts; raids on absent owners; and heavy physics hauling at low frame rates.
- Foxhole is the warning for 'logistics as the game': when hauling is the only way anything exists and other players depend on it, it becomes unpaid shift work. A group of about 1,800 logistics players sent an open letter listing 11 problems in late 2021 and struck from January to 1 March 2022, ending when Update 48 addressed the concerns. Any hauling step needs to stay optional or delegable, which matches 'any step can be done by you, an NPC or a friend'.
- Stardew Valley is the best single model for one good meaning different things in different contexts without a simulation: the same crop can be sold, cooked, gifted, put in a machine or given to a bundle, and the Community Center's 6 rooms and 30 bundles ask for items from every system and pay out in capabilities (the Pantry unlocks the greenhouse).
- Potion Craft shows a way to define crafting without a recipe table: each ingredient is a direction and length on a map and an effect is a location, so every ingredient combines with every other. Its weakness is structural too: customers are the only sink, so the web has one exit.

### Unproven
- Booga Booga: the original game's structure could not be checked. The level-100 rebirth and Mojo points come from guides to Booga Booga Reborn, a fan remake by a different group, and two guides disagree on what rebirth wipes. The failure mode I give (geared tribes dominating) is from memory, not a source.
- Miner's Haven: only a 2017 fan blog and one 2020 DevForum patch note were reachable. The grid of droppers, upgraders and furnaces, the reborn item on rebirth and the ore-destroying effects are from those; upgrade limits, resetters and current player numbers were not found.
- Bee Swarm Simulator: sources were low-quality guide sites. Bee abilities, quest bears, nectar buffs and planters are confirmed at that level only; the claim that the late game is a months-long grind is my own reading, not sourced.
- Islands: totems, conveyors, industrial machines and vending machines are confirmed from the fan wiki. 'Little left to want after automation' is my inference. I recalled but did not confirm that item duplication damaged its economy, so I left it out of the report. Trackers show about 1-1.5K concurrent players in 2026 and 2.4B visits; a tracker's 'peak of 2K in April 2026' reflects its tracking window, not the game's 2020 peak.
- Lumber Tycoon 2: the first-minutes details and prices come from one third-party guide, not the game or its wiki (the Fandom wiki refused requests). The claim that some wood species need a specific axe is supported only by a price table listing an End Times Axe for phantom wood.
- RimWorld: the Def and XML inheritance model, components on Things, and mods adding content purely as data are from my own knowledge; the modding page I fetched did not cover them. Tynan Sylvester's own 'story generator' framing was not retrieved. The 'killbox' failure mode is community consensus, not a cited source.
- Breath of the Wild: the three rules come from one press write-up of the GDC 2017 talk, not the recording. One outlet says the NES-style prototype was actually built in a 3D engine. The specific examples (updraft from fire, metal drawing lightning) are from my own knowledge of the game.
- Minecraft: wooden-to-diamond tool tiers, redstone being sufficient for logic circuits, and the first-night sequence are from my own knowledge. The claim that pre-1.12 players needed a wiki rests on forum anecdotes. No count of blocks in early versions was verified.
- Factorio and Create: only the science-pack progression statement (Friday Facts 275) and Create's stress units and in-world design were checked, the latter from fan wikis that disagree on numbers. 'Solved ratios and pasted blueprints' and 'nothing consumes Create's output' are my characterisations.
- Noita and Caves of Qud: Noita's tag-based reactions are confirmed, but the wiki page did not state outright that a modded material joins existing reactions by carrying a tag; that follows from the system and a mod's compatibility guide. Qud's event system and XML blueprints were not confirmed; only the composition-of-properties description was.
- EVE Online: nearly-everything-player-made, tradeable blueprints, regional price differences and destruction as the main sink are from my own knowledge. The only thing confirmed this session is that CCP publishes a monthly economic report tracking production, destruction and trade.
- Albion Online: the return-rate figures (about 15.3%, 36.7%, 53.9% with Focus) come from third-party guides that vary slightly between sites and may be out of date.
- Dwarf Fortress: reaction and material pages mix current and legacy versions, and the main Reaction page returned an error on direct fetch, so the REACTION_CLASS description is from search excerpts of older-version pages.
- Stardew Valley: the 'one best crop-to-keg line' failure and the starting seed count are from my own knowledge. Potion Craft: 'customers are the only sink' is my characterisation.
- Finding 5 (what survives phones and small servers) is my inference from the platform facts in docs/research/02 applied to these structures. No source tested these patterns on Roblox directly.


---

# The four designs in full

## Process-carrier model (things that carry processes) (23/30)

### Summary
Everything in the world is a Thing, and some Things carry one or more Processes. A Process is one small card of data: what it takes, what it needs around it, how long it runs, and what it gives. A hen carries "takes feed, gives an egg". A stove carries "takes two foods and an optional flavouring, gives a dish". A hungry traveller carries "takes a dish, gives payment and a keepsake from home". A whole city carries "takes bones, gives fertiliser" at its counter. A ritual ring carries "takes a tool and crystals during a storm, gives the same tool with lightning on it". You run any of them the same way: physically put the inputs in, supply the work (you, a friend or a hired hand) or let the clock run, and pick up what comes out. Because machines, recipe cards, helpers, banners of protection and enchantments are themselves Things that come out of processes, getting one changes what you can do next, not only how much. Because processes ask for tags ("any food", "any fibre") and for conditions in the air (heat, chill, spark, rot, dark) instead of named items, every new thing works with the old ones without anyone scripting the pairing. Tiers exist where they are natural (picks, carts, coats) and are left plain.

### What a thing is
A Thing is one server record: kind, optional material, marks, quantity, condition, owner, place.

Tags are what the rules read. A Thing's tags are the union of its kind's tags, its material's tags and its marks' tags. A fleece coat is kind "coat" (wearable, body) x material "fleece" (fibre, insulating). Nothing in the rules names a specific item; processes ask for tags.

Material is the content multiplier: N kinds and M materials give N x M goods from N + M definitions. A pick or a coat takes its stats and odd tags from what it was made of.

Marks are things done to a Thing or a person: an enchantment, a flavour effect, a faction's banner, a kinship. A mark adds tags and usually has charges or a timer.

Condition: tools wear per use, marks lose charges, fresh food spoils into Scraps (which is still hen feed, so nothing is simply deleted).

Physical states (one record, four views, following the grounding brief):
- At rest: an anchored model on the ground, a shelf or a station slot.
- Held: welded to the character. Small Things go in a counted sack (8 stacks) with Store/Unstore buttons; large Things (crate, crated machine, sack of ore) are carried in two hands, one at a time.
- Loaded: welded into a numbered slot on a cart or vehicle bed, so the whole load is one assembly.
- Bulk: a count inside a container (a crate holds 12 of one kind and shows its fill level; station hoppers and troughs are containers).
Living Things follow on a lead or ride in a cart slot. Stations are fixed when placed and are crated to move (one cart slot).

Holding: the only places that save are your plot and your cart. A cart is a holding that moves, so a nomad needs no plot. Loose goods anywhere else fade after about five untouched minutes, with a visible fading outline so the rule is honest.

### What a transformer is
A Process is one data card with four fields.
- takes: slots filled by tag query and count ("2 x #food", "1 x #tool"). Consumed, or transformed and returned.
- needs: not consumed. A tool tag in hand, a pattern card slotted in, an aspect present or absent at that spot (Heat, Chill, Spark, Rot, Dark), time of day or weather, a charge, and "hands" (work) if the process is not clock-driven.
- time: either work seconds supplied by an agent, or clock minutes that keep running from timestamps while you are away.
- gives: Things (inheriting material from inputs), marks on an input Thing, marks on a person, an aspect emitted while running (a lit stove gives Heat around it), a by-product.

Any Thing can carry process cards. That is the whole model:
- Living thing: a hen carries Lay and Hatch. Its "takes" is its need. Unfed, it stops; neglected for days, it wanders off.
- Machine: a stove or transmuter carries one or two fixed cards. A workbench carries none of its own and runs whatever pattern card is slotted into it.
- Ritual: the same card, with a weather or aspect condition and a mark as its output.
- Guest: a person carrying a need card (takes a dish, needs a seat) whose gives is payment set by their people.
- Body: a response to an aspect is the same card with an aspect as the input ("takes Spark, gives Charged" for tin-folk; "takes Chill, gives slowed" for valley-folk).
- Settlement or faction: a Thing with a stockpile and several cards on its counters. Its trade offers are cards too ("takes 12 crystal, gives a crated transmuter").
- Raider and protector: cards with a place-and-mark condition ("takes loose #shiny at night from holdings with no banner").
- Player stall: a card the owner writes ("takes 2 crystal, gives 1 warm dish").

One server routine runs every card: check slots by tag, check needs at that position, consume, set a finish timestamp, emit outputs at the station's output spot. Chaining is physical: an output is a Thing, so it goes wherever a slot accepts its tags, by hand, by cart or by a hired carrier.

### Capabilities
Every capability is a Thing or a mark, produced by a process and usable as an input elsewhere.
- Machine: comes out of a faction counter or a workbench as a crate. Carried home, placed, it adds its card to your holding. It can be given, sold, lent, loaded on a cart, or stolen back from a roost.
- Recipe: a pattern card. Slot it into a workbench and the bench gains that process. One card serves one bench at a time, so a second bench needs a second card or a friend who lends theirs.
- Helper (a Hand): a person of some people, hired by a process whose "takes" is a daily wage in kind. Assigned to a slot, a Hand is the "hands" input. A Hand has its own need card and its people's responses, so it is also a consumer and is affected by place.
- Service: not an item. It is a process whose output lands on the customer (fed, rested, warmed, carried across the river, tool marked). You sell one by opening a station to others; you buy one by being the customer at someone else's.
- Enchantment: a mark with charges, put on any Thing with the right tag by a ritual card. It adds tags (a Spark-marked pick emits Spark on each hit), so every process and response that reads Spark now reacts to that pick.
- Protection: a banner Thing with daily charges, given by a faction (or the dragon) for tribute. Raider cards check for it.
- Kinship (later): a mark on the player from a people's rite that overlays their response table. Becoming "a certain people" is an output like any other.

Re-entry: a transmuter's gold is tribute for the dragon, payment at the tinker and coin at the mint; a storm-marked tool is a weapon against raiders, a charger for tin-folk Hands and a better crystal breaker; a Hand fed on your dishes frees you to leave.

### Context
Three rules, no pair tables.
1. Emit. Places, weather, running stations and marked Things emit aspects in a radius. Starter aspects: Heat, Chill, Spark, Rot, Dark. The cavern emits Chill and Dark; a thunderstorm emits Spark on high ground; a lit stove and a running transmuter emit Heat; loam emits Rot; the dragon's ledge emits Heat.
2. Respond. Every people, creature and material has a short response table: aspect -> nothing, harmed, fed, or changed. Anything not listed uses the default. Heat and Chill cancel where they overlap.
3. Edit. What you wear, eat or are marked with edits your table for a while. A fleece coat sets Chill to nothing. A pepper dish does the same for five minutes. A kinship mark would do it permanently.

Starter response data:
- Valley-folk (default, and every player in the first build): Chill slows then knocks out (you wake at your holding; what you carried lies where you fell); Dark hides ore nodes; Rot makes guests leave the table; Spark stuns.
- Bayou-folk: Rot restores and pleases; Dark is nothing; Heat wearies.
- Winter-folk: Chill is nothing; Heat wearies.
- Tin-folk: Spark gives Charged (double work speed for two minutes); Chill and Rot are nothing; they take crystal instead of food.
- Hen: Chill stops laying. Shag ox: Chill is nothing.
- Wood: Spark does nothing (non-conducting), Heat burns it (fuel). Iron: Spark passes to the holder. Crystal: Spark turns it into a storm shard that carries Spark.
- Soil: Rot halves growing time for any seed.

So the same loam heap speeds your crops, is required by glowcaps, delights a bayou guest seated beside it and drives a valley guest away. The same lightning stuns a jackdaw, zaps a valley miner holding an iron pick, does nothing through a wooden one, and doubles a tin-folk Hand's work. A new region is one aspect list for the place plus one response table and taste list for its people; a new material is a few tags.

### Who does it
Work is an input slot called "hands". Whoever fills it runs the step.
- You: stand at the station and hold the Work button.
- A friend: any player you have marked as a partner can fill hands at your stations, load your cart and use your containers. Permission is mutual, as in Lumber Tycoon 2's fix.
- A Hand (hired NPC): assigned one of three generic jobs, none tied to a particular good.
  - Work: stand at one station and supply hands.
  - Carry: move anything matching a tag from container A to container B.
  - Run: take a cart to a named settlement counter, run one card there, come back. The Hand and cart are seen leaving and arriving; the road in between is a timer, as Retail Tycoon 2 does with hired drivers.
A Hand's people matters through the same response tables: a winter-folk Hand can do the cavern Run without a coat, a bayou-folk Hand tends glowcaps in the dark, a tin-folk Hand is paid in crystal and speeds up when sparked.

A service is a process where the customer is not the owner. The owner sets a station to "open"; the customer brings the need (or the inputs) and receives the output; payment follows the customer's people's values for NPCs, or the card the owner wrote for players. A tavern is open seats near a stove. A travelling hospital is a cot and a stove on a cart. A ferry ticket, a mint and the dragon's protection are services you buy from the world. Hauling stays optional: every Run can be done by you, by a Hand or by a friend, so it never becomes the unpaid shift that broke Foxhole's logistics.

### Exchange
With factions: every trade is a process card on a settlement counter. Two kinds.
- Commodity cards: the settlement takes a wanted good and gives coin, or takes coin and gives a stocked good. The price follows hunger: each settlement consumes its wants on a clock, and a want's price runs from roughly 0.4x when its stock is full to 2.5x when it is empty. Stock is one shared number per want across all servers, with a small NPC trickle so it never sticks at an extreme.
- Capability cards: machines, pattern cards, ritual kits, banners and willing Hands are given for specific goods in kind (crystals for the tinker's transmuter, shiny tribute for the dragon's mark), never for coin alone. This is the main anti-ladder rule in the economy.
Coin is a Thing struck from gold at any mint. It buys commodities and services (meals, rest, a ferry, a Run). It is a convenience, not the measure of everything.

With players: hand-over is physical (set it down, they pick it up) for friends; a two-sided swap bench with both sides visible and both confirming for strangers; and a stall card the owner writes, which works without text chat. All of these are server-side moves of records, never client-authoritative.

What stops one best route:
- Hunger: delivering the same good lowers its price for everyone until the settlement eats it down.
- Bulk and spoilage: carts have slot counts, fresh food turns to scraps, so distance and load matter.
- In-kind capability prices: different capabilities need different goods from different places.
- Conditions: weather, night, Chill and Dark change what a trip costs today (a storm doubles crystal yield for those equipped for it).
- Charges: marks and banners run down, so the best kit has an upkeep in goods.
- Raiders on some roads and at night, which a banner, a truce, a guard or a detour answers differently.

### Direction without tasks
Six things, all in the world or in the player's own notebook. None is a list of tasks and none points an arrow.
1. What is in your hands. Any station slot within a few steps that accepts the tags of the Thing you are holding pulses softly. "What can this go into?" is answered by looking around.
2. Unmet conditions. A slot that would accept your Thing but lacks a need shows the missing condition as an icon (glowcap spores in a bed show Dark and Rot icons, greyed). That is a question the world poses, and the answer is somewhere else.
3. Needs of what you own. A hen with an empty trough, a Hand with no wage, a banner on its last charge, a worn pick. These are the RimWorld need bars, on Things.
4. Want boards and shop windows. Each settlement has a physical board showing its hungriest wants as icons with fill bars, and a window where the capabilities it offers sit as real models with their price in goods beside them. It is a menu that points across systems (bones, dishes, crystals, gold), and it shifts as stock moves.
5. The land and the sky. From the starting crossroads you can see the cavern glow on the mountain, the dragon on its ledge, the bayou smoke downriver and snow on the pass. The market's weather vane shows the next storm, which follows a schedule derived from the clock, so it is the same on every server and friends can plan for it.
6. The almanac. A notebook that records every process you have seen, with unknown slots as silhouettes and unknown outputs as question marks, and every want a guest has told you about their home. It is memory, not instruction: it fills by observation and by gossip.
Other players' holdings, carts and stalls are a seventh source when a server has them.

### Starter things
| Thing | Properties |
|---|---|
| Egg | food, hatchable, fragile, fresh (spoils to scraps). Small. |
| Hen | living, small creature. Carries Lay and Hatch. Chill stops laying. Rides in a cart slot. |
| Shag ox | living, large creature. Carries Shed. Chill is nothing. Can be hitched to a cart; follows on a lead. |
| Grain | food, fodder, seed, burnable. Small. Grows anywhere in daylight. |
| Ember pepper | food, seed, flavour: Warm. Grows only where Heat is present. |
| Glowcap | food, seed (spores), flavour: Night-sight. Grows only in Dark with Rot. Favourite of bayou-folk. |
| Fleece | material: fibre, insulating. Small. |
| Bones | remains, hard, burnable. Small. Found on the scree under the dragon's ledge and in the jackdaw roost. |
| Loam | emits Rot in a small radius; spread on a soil bed it stays for several harvests. Bulky. |
| Crystal shard | mineral, shiny, holds charge. Bulky. Spark turns it into a storm shard, which emits Spark. |
| Lead ore | mineral, heavy, metal: lead. Bulky. |
| Gold (nugget, or coin once struck at a mint) | metal: gold, shiny. Small. Coin is countable and accepted for commodities and services. |
| Dish | food, made. Carries the mark of whatever flavouring went in (Warm, Night-sight, or none). Hot for two minutes. |
| Pick (wood, iron, crystal-tipped) | tool, a plain tier line. Wood: free to make, slow, wears fast, non-conducting. Iron: bought or made, faster, conducts Spark. Crystal-tipped: fastest, opens deep veins, uses a crystal charge every few swings. |
| Coat (x material) | wearable. Takes its tags from its material: a fleece coat is insulating (Chill -> nothing). |
| Cart | vehicle and holding. Handcart: 4 slots, pushed by you, fits cavern galleries. Ox-cart: 8 slots, needs a fed ox. Slots take crates, bulky goods, creatures or one small station. |
| Stove | station. Carries Cook. Burns anything #burnable. Emits Heat while lit. Fits a cart slot. |
| Workbench | station with no card of its own. Runs the pattern card slotted into it. |
| Pattern card | recipe as an object. Starter cards: coat (3 x #fibre), pick (1 x #burnable shaft + 2 x #hard or #metal head), crate (4 x #burnable). |
| Storm ring | ritual station, comes as a kit from the tinker. Carries Storm-mark. Needs Spark present. |
| Transmuter | machine, comes crated from the tinker. Carries Transmute. Emits Heat while running. Uses crystal charge. |
| Seat (table or cot) | station that draws guests whose need it matches: table for hungry, cot for worn out. Can be set to open. Fits a cart slot. |
| Banner | protection as an object, with daily charges. Dragon's mark (from tribute) or Jackdaw truce (from a toll). Planted on a plot or fixed to a cart. |
| Hand | hired person of a people (valley, bayou, winter or tin). Fills a hands slot, a Carry job or a Run. Has a daily wage in kind and its people's responses. |

### Starter processes
| Process | Takes | Needs | Gives |
|---|---|---|---|
| Lay (hen) | 1 x #fodder | daylight, no Chill; 4 clock minutes | 1 egg in the nest |
| Hatch (hen) | 1 egg left in the nest | Heat present; 10 clock minutes | 1 hen |
| Shed (shag ox) | 2 x #fodder | 8 clock minutes, then a moment of hands to shear | 1 fleece; while fed the ox can be hitched to a cart |
| Grow (soil bed) | 1 x #seed | daylight plus the seed's own condition tags (pepper: Heat; glowcap: Dark and Rot); Rot in the bed halves the time | 3 of the crop and 1 seed back |
| Cook (stove) | 2 x #food, optionally 1 x #flavour | 1 x #burnable as fuel; 4 seconds of hands | 1 dish carrying the flavouring's mark; Heat around the stove while lit |
| Make (workbench) | whatever the slotted pattern card asks for, by tag | a pattern card in the slot; hands | that kind of Thing in the material of the inputs (fleece coat, wooden pick, bone-headed pick) |
| Dig (crystal node, lead vein) | nothing | a #pick in hand (tier sets speed; deep veins need crystal-tipped); the cavern emits Chill and Dark; nodes refill on a clock | crystal shards or lead ore. After a storm, high nodes are charged: double yield and storm shards, but Spark passes through a conducting pick |
| Transmute (transmuter) | 2 lead ore | 1 crystal of charge per 4 runs; 60 clock seconds | 1 gold nugget; Heat while running |
| Storm-mark (storm ring) | 1 x #tool or #wearable, 2 crystal | Spark present: a thunderstorm overhead or a storm shard set in the ring | the same Thing with the Spark mark, 30 charges |
| Be served (guest at a table) | 1 dish | a free seat; no aspect their people dislikes at the table | coin by their people's values (more for a favoured flavour), sometimes a keepsake from home (glowcap spores, a crystal, a pattern card), and one want from their home board into your almanac |
| Rest (guest or player on a cot) | 1 dish | Heat present; 30 seconds lying down | removes worn-out or chilled from the person on the cot; they pay about three times a meal |
| Compost works (bayou outpost counter) | 4 x #remains | its loam stock above zero; price follows its hunger for remains | 3 loam. Its window also offers glowcap spores for dishes and a bayou Hand's introduction for 10 glowcap dishes |
| Tinker's wagon (tin-folk counter) | 12 crystal, or 6 crystal and 4 gold | the wagon is in the valley (it leaves for two days in seven) | a crated transmuter, or a storm ring kit. It also buys crystal and gold for coin |
| Crossroads market (valley counter) | anything on its want board, or coin | daytime | coin at the hunger price; or grain, an iron pick, a soil bed, a seat, pattern cards, a valley Hand's introduction. Its mint turns gold nuggets into coin |
| Dragon's tribute (the dragon) | 6 x #shiny, or 4 dishes with the Warm mark | carried up to the ledge, which emits Heat; the road passes the cavern's Chill | a Dragon's mark banner with 7 daily charges; the dragon drops bones on the scree after it eats |
| Jackdaw gang (raiders) | up to 3 loose #shiny or #food Things at night from a plot or cart with no banner | no banner, no Spark nearby, no awake Hand on Guard | the Things sit in the gang's roost by the cavern road and can be taken back; 3 coin at the roost buys a Jackdaw truce banner for a night |
| Hire (a Hand) | 1 dish a day (tin-folk: 1 crystal a day), suited to their people's taste | an introduction from their people's counter | hands at one station, a Carry job between two containers, or a Run to a counter and back |
| Stall (player-written card) | whatever the owner sets, by tag and count | owner's holding loaded in this server; stock in the stall's container | whatever the owner sets, including a service done at their station (your tool marked in their storm ring) |

### What a player could do with only the starter set
- A rolling hearth (expedition; a combination the content never states). The stove fits a cart slot and emits Heat; Heat cancels Chill. A player pushes a lit stove into the cavern mouth on a handcart and mines inside its warm bubble with no coat, cooking as they go and burning bones for fuel. Nothing in the data says 'mobile camp'; it falls out of three separate rules.
- A waste-heat hatchery (animal keeping meets engineering; also unstated). Hatch needs Heat. A running transmuter emits Heat. A player builds the coop against the transmuter, so every batch of lead turned to gold also hatches eggs, and plants ember peppers in the same warm patch. When the lead runs out the hens stop hatching, which makes the cavern Run matter to the flock.
- A rest stop at the cavern road (service, with other players and a Hand). One player parks a cart with a stove, a table and a cot where chilled prospectors come down. NPC travellers pay coin; other players pay through a stall card the owner wrote: 2 crystal for a Warm dish before going up, 3 for a rest coming down. A friend or a winter-folk Hand does the digging meanwhile, so the cook never enters the cavern and still ends the day with crystal.
- The bone round, with no plot at all (trade and travel). A player living on an ox-cart collects bones from the dragon's scree after it has eaten, carries them to the compost works, takes loam, and sells loam at the crossroads or trades it to another player's farm. When the works is glutted with bones the price drops, so the round changes: glowcap dishes downriver, spores back up. On a night when the gang is out, a Night-sight dish lets the same player walk into the dark roost and take back what the jackdaws have stolen from everyone.
- Storm days (weather, the cheap tier, and a helper). The weather vane shows a storm for the evening. Charged nodes give double, but an iron pick passes the Spark to its holder, so the player makes a stack of wooden picks, which are free and non-conducting, and brings storm shards home. A shard in the storm ring marks one cheap wooden pick with Spark; tapping a tin-folk Hand with it gives Charged, so the Hand at the transmuter works at double speed. The wooden pick has become a charging tool.
- Two answers to the jackdaws (protection, and a friend). One player carries gold up past the Chill to the dragon each week for its mark and never thinks about raiders again. Their friend refuses the cost, wears a Spark-marked coat, and walks beside other players' carts on the cavern road at night for a share of the load. Same threat, two ways of living with it, and the second is a service one player sells to another.

### First minute
- 0-5 s: you ride in on the back of a market wagon, which stops at a small roadside holding at the crossroads. In view, close together: a hen coop with two eggs sitting in the nest, a lit stove, one table with a traveller from the bayou whose thought bubble shows a dish. One large button on screen: Pick up.
- 5-15 s: you pick up the eggs. They are in your hands. The stove's intake pulses, because eggs carry #food. No text has been read.
- 15-30 s: Put in, then hold Work for about four seconds. A steaming dish comes out at the stove's output spot. This is the whole rule, run once: inputs in, work, output out.
- 30-45 s: carry the dish to the traveller. They eat, leave coin on the table, and leave a keepsake from home: a pouch of glowcap spores. Their bubble shows a picture of what their town wants (bones) and what it gives (loam); the almanac keeps it.
- 45-60 s: three things now pulse because of what you hold, and nothing tells you which to choose. The soil bed accepts the spores but shows two greyed condition icons, Dark and Rot, which this sunny yard does not have. The market board across the road shows its wants with fill bars. The hen's empty trough shows a grain icon. A handcart stands at the gate, and the road forks towards the glowing cavern on the mountain and the smoke downriver.
- At the gate a stake reads 'This holding is yours'. Tapping it claims the coop, stove, table, one soil bed and the handcart. The prompts stop here. The table has one seat and travellers pass only every few minutes, so repeating egg-dish-guest is not the fastest thing to do; the unfinished things (spores with unmet conditions, a hungry hen, a board of wants, an empty cart) are.

### Three players at hour ten
Player A keeps animals on the warm slope under the dragon's ledge. Peppers grow wild-fast there, hens hatch without a stove, and a bayou Hand tends glowcaps in a dug cellar that A lined with loam. A pays the dragon in Warm dishes rather than gold, sells fleece coats to players heading into the cavern, and has never owned a transmuter. A differs because of where they settled: the place hands them Heat for free and charges them a hard road.

Player B has no plot. B lives on an ox-cart with a stove and a cot, follows the storm schedule and the tinker's wagon, sells rest and hot food where chilled miners come out, and raids the jackdaw roost on nights the gang is away. B differs because their holding moves, so prices and weather decide their day, not a building.

Player C runs machines. Two transmuters, fed by a Carry Hand, worked by a tin-folk Hand that C keeps Charged with a Spark-marked wooden pick; a storm ring whose marking C sells to other players through a stall card. C watches the mint's gold price and holds gold back for the tinker when it is glutted. C differs because of which capability they bought first: crystals went to machines instead of to a dragon or a cart.

They differ for three structural reasons: capabilities are paid for in different goods, so what you could gather early shaped what you got; place supplies or withholds aspects; and a holding can be a plot or a cart.

### Why it is not one ladder
Tiers are used and left plain: picks (wood, iron, crystal-tipped), carts (hand, ox, later truck), coats by material, sack then crate. Low tiers stay worth having for ordinary reasons. The wooden pick is free and carries one odd tag, non-conducting, which matters on storm days. The handcart needs no feed and fits where an ox-cart cannot. A fleece coat is three shearings. The crystal-tipped pick is simply better and eats crystal to stay that way.

What keeps the whole from being one ladder is four specific rules.
1. Capabilities are bought in kind, with different goods at different counters. There is no single number that buys the next thing, so "more of the same" does not answer "what next".
2. Processes read tags and aspects, not item names. Each new Thing lands in several existing processes at once, which is why the stove is also a heater, a hatchery and a camp.
3. Settlement hunger is shared and falls as you feed it, so the best delivery now is not the best delivery after you have made it.
4. Outputs that are capabilities change what you do: a Hand removes a job, a cart moves your home, a mark changes what a place or a storm means to you.

How it could still collapse, honestly:
- Coin creep. If machines and banners become buyable for coin "for convenience", everything reduces to coin per hour, and the transmuter-to-mint line becomes the game. The in-kind rule has to be held.
- The want board as a checklist. If players simply deliver whatever is hungriest, it is "do X for Y" with a rotating X. It is only a menu if players have their own plans to weigh it against; the first build tests exactly this.
- Weak context. If Chill, Rot and Dark are mild enough to ignore, place stops mattering and the response tables are decoration.
- Tier-only content. If each new region adds the same goods with bigger numbers, the regions become rungs. A region must bring an aspect, a people's responses and wants that point back at old regions.
- The first minute repeated. Egg, dish, guest is a loop; it is held in check only by having one seat and slow traffic, which is a tuning choice that could be undone under pressure to raise early retention.

### Technical model
Data. All content is Luau tables in shared modules: Kinds (tags, bulk, model, carried process ids), Materials (tags, stat multipliers), Marks, Aspects, Peoples (response table, tastes, pay profile), Processes (takes, needs, time, gives), Settlements (counters, wants, consumption rates). A new region or people is new rows, not new code. One server module, the process runner, is the only code that creates, consumes or moves a Thing.

Truth and view. The server holds one record per Thing or stack; Roblox instances are views of records. States follow the shipped games in the grounding brief: anchored and server-owned at rest; welded to the character when held; welded into a cart slot when loaded so the load is one assembly; a count inside a container in bulk. Clients never own goods' physics. Targets to be measured, not facts: no more than about 40 moving assemblies visible to one client, 8-stack sacks, about 150 placed Things per holding.

Aspects are not simulated. The aspect at a point is computed on demand from emitters in range (place volumes, global weather state, lit stations, marked Things) and cached about once a second per station and per character.

Clocks. Every clock process stores a start timestamp; on load, production is settled from elapsed time, limited by inputs present and output space. Weather is a pure function of UTC time, so all servers agree without messaging.

Saving. One session-locked profile per player, written with UpdateAsync, autosaved and saved on leave and on shutdown: the plot, the cart and its load, containers as counts, marks and charges, Hands and their jobs, almanac, standing. All interaction with a player's Things is blocked until their load completes. Settlement stock is a handful of shared numbers per settlement, batched about once a minute, with a last-known value and a data store snapshot behind the memory store.

Servers. One place for the first build, 8 players, plots loaded with their owners in the Lumber Tycoon 2 manner. NPC guests and Hands are data on the server with simple rigs shown near viewers; a Hand's Run is a timer.

Costliest part. Phone handling of physical goods and the state transitions behind it: pick up, put in, carry large, load a cart, with every transition one atomic server move so nothing duplicates. Second is a cart with a welded load streaming in on a 2-4 GB phone. Both are on the brief's prototype-first list, along with how many anchored goods such a phone tolerates and the save size of a full holding.

### Test
Run the first build with five to eight testers on phones for 30 to 40 minutes each, with no instructions after the first minute, and log every process run.

Signs the rule is blossoming:
- Someone moves the stove: onto the cart, beside the coop, beside the pepper bed or into the cavern mouth. Nothing prompts this; it only happens if Heat has been understood as a thing in the world.
- Someone carries a Warm or Night-sight dish into the cavern, or puts loam somewhere other than a soil bed (by the table for a bayou guest, in a dug cellar).
- At minute 20, two testers are doing visibly different things and can each say why.
- A tester ignores the hungriest want on the board because they have a plan of their own.
- Testers ask "can I...?" about something untested and the rules already answer yes.
- By the log: at least five distinct process types per player in 30 minutes, no single process above about 40% of a player's runs, and stations placed in layouts that differ between players.

Signs it is not:
- Everyone repeats egg, dish, guest until bored, then asks what the coin is for.
- Everyone asks "what do I do now?" at about the same minute.
- The cart is used for one route only, or not at all.
- Nobody notices the greyed condition icons; glowcap spores are sold instead of grown.
- Players sell everything to the market and treat the want board as the game.
- The Hand is hired and nothing changes in what the player does with the freed time.

Separately for the entrance: the share of testers who complete coop, stove and guest within 60 seconds on a phone, and how many Pick up or Put in attempts fail or need a second try. If handling fails here, fix handling before judging the rule.

### First build
- The rule itself: one server process runner (tag-matched slots, needs checked at the station's position, work or clock time, outputs emitted physically) and the three context rules (emit, respond, edit) with five aspects.
- Thing handling on a phone: Pick up, Put in, Work, Store/Unstore sack, carry one large Thing, load and unload a 4-slot handcart. Anchored at rest, welded when held or loaded, counted in containers. Plot and cart save; loose goods fade.
- The affordance layer: slots pulse for what you hold, unmet conditions show as greyed icons, the almanac records processes seen.
- A living thing: the hen (Lay, Hatch).
- A machine that is also a heat source and fits a cart: the stove (Cook, with the generic flavouring rule that makes Warm and Night-sight dishes).
- A soil bed with three seeds whose conditions differ: grain (anywhere), ember pepper (Heat), glowcap (Dark and Rot).
- A guest with a need and a people: travellers at a table, valley and bayou, paying coin, keepsakes and gossip.
- A place with aspects: a small cavern emitting Chill and Dark, with crystal nodes dug by a wooden pick made at a workbench from one pattern card.
- Two settlement counters with hunger numbers (per server at first): the compost works (bones to loam) and the crossroads market (want board, grain, coin).
- One capability bought in kind, and one way to hand a step to someone else: a valley Hand hired with a dish a day for a Work or Carry job; a partner permission so a friend can work your stations.
- A test harness: bot players that run processes, a clock that can be jumped, logging of every process run per player and of first-minute steps.

### Left out of the first build
- Transmuter, lead and gold, and the mint (the machine chain comes second, once handling is proven)
- Storm ring, the Spark mark, thunderstorms and charged nodes
- Shag ox, fleece, coats and the ox-cart; trucks and any driven vehicle
- The dragon's tribute, banners and the jackdaw gang (no raiding or protection until the cozy loop is seen to stand alone)
- Tin-folk, winter-folk and bayou Hands; Run jobs to a counter
- Player kinship marks and any race choice for players
- Player-written stall cards and the two-sided swap bench
- Cross-server shared stock for settlements (per-server numbers first)
- Other regions as places; they appear only as visiting travellers and one outpost
- Cots and the rest service
- Monetisation, private servers, daily hooks beyond clocks that are already in the rule
- Roblox Server Authority mode (revisit after the handling prototype)

### Risks
- Handling on phones. Carrying, slotting and cart loading may be too fiddly with thumbs; Oaklands and Lumber Tycoon 2 both struggled here. If it is, more goods must become sack counts, and the 'physical' promise thins.
- Duplication. Every game with physical goods in the brief was duped through save, trade or weld races. One atomic server move per transition is the plan; it is unproven until attacked.
- Legibility. Tags, aspects and responses are invisible rules. If the pulse, the greyed condition icons and the almanac do not carry them, this becomes a wiki game, or players never notice context at all.
- Thin web at small size. Twenty-four things may read as three short chains. The claim that they combine is an argument until the first playtest shows unprompted combinations.
- Minute three. The first minute is guided by affordance and then stops. A share of Roblox players will leave when nothing tells them what to do; the unmet-condition icons and the want board have to do that work without becoming a quest list.
- One or two players per server. Player stalls, escorts and swaps will be rare at launch. NPC guests, counters and Hands must make the web work alone, with other players as a bonus.
- Coin creep and a single best line (lead to gold to mint), described under why_not_a_ladder.
- Idle drift. Clock processes plus Hands can turn the game into checking timers. Hands need wages and stations need inputs that someone must still fetch or arrange.
- Raiders and the cozy audience. Even recoverable theft may drive off players who came to tend animals. It is left out of the first build for that reason and must be avoidable by a banner when it arrives.
- Scope for one programmer. Runner, aspects, handling, carts, guests, counters, Hands and saving are eight interacting pieces. The first build keeps each to its minimum; vehicles beyond a handcart are deferred because of the physics evidence.
- Runaway growth. Hens hatch hens. Without holding slot limits and fodder cost, populations and part counts explode.
- Mild rating. Bones, a compost works for remains, knock-outs from Chill and night theft all need cartoon treatment and a check against the maturity questionnaire before publishing.


---

## Hands, Holders and Stations (slot-based physical goods, tag-matched processes, receiver-side reactions) (22/30)

### Summary
Everything in the world is a Thing you can see, and every Thing is always sitting in exactly one slot of exactly one Holder: your two hands, a pack, a crate, a handcart, a truck bed, an oven tray, a guest's plate, a settlement's dock, a bed, a seat. The player has three thumb buttons: Take/Put, Use, and Pack. A Station is any holder that turns what is in its slots into something else after some time: a crop bed, a goat, an oven, a lightning rod in a storm, a hungry traveller, a whole town. Stations do not ask for named items; they ask for kinds ("any fuel", "any fibre", "anything this guest's body likes"), so each new thing fits in several places without extra code. What a thing does when it is eaten, worn, struck with or stood in is decided by the body or place receiving it, so lightning dazes most people and charges the wired folk. Machines, recipe cards, hired hands and enchantments are also Things that sit in slots, so they can be carried, given, traded and lost like a loaf. There is no loose physics: goods snap into slots and ride welded on whoever carries them, which is what makes it buildable by one programmer and runnable on a cheap phone. Ordinary tiers exist (wood then iron tools, hands then cart then truck) and the cheap ones keep an odd advantage.

### What a thing is
A Thing is a server record: serial id, kind, optional material, a stack count, a short list of marks, and its location (holder id + slot index). Its meaning comes from tags, which are the union of kind tags, material tags and mark tags (e.g. a fleece coat = kind 'coat' [worn] + material 'fleece' [fiber, effect:warm]). Item x material is used wherever it is natural (mattock x wood/iron, coat x fleece, cake x flavour), so N kinds and M materials give N x M goods from N + M definitions.

Four size classes, which are the whole carrying rule: SMALL (stacks to 8, shown as a pile with three visual levels; fits anywhere), HAND (one per slot; hands, pack, any slot), BULKY (hands only and you walk slower; fits cart, vehicle bed, foundation or ground, never the pack), HUGE (needs two bodies on it or a cart/vehicle, takes 4 bed slots; this is what a machine crate is).

Holders are things with slots: hands (1 slot, the thing is visibly held and welded to the avatar), pack (3 slots, counted, the Dead Rails / 99 Nights sack pattern), crate (4 slots, closed crates show only a count), handcart (4 goods slots + 1 foundation slot, towed by a body, no fuel), vehicle bed (12 slots + seats), station trays, plot foundations (grid slots that accept stations), seats and beds (slots that accept a body), and the ground (snapped ground spots; capped at 12 loose things per player, 3-minute fade, never saved).

Physical existence, strictly: there is never a free-tumbling good. At rest a thing is an anchored model at a slot attachment. Carried, it is welded, massless and non-colliding on the avatar, cart or vehicle, so a full load is one assembly. Dropped, it plays a client-only tumble and anchors on a ground spot. The only moving assemblies in a server are characters, creatures and vehicles, which keeps well under the 40-60 moving-assembly figure in the grounding brief regardless of whether that figure still holds.

Thumbs: Take/Put is one button whose label flips with whether your hands are full; it targets the nearest valid thing or slot in a cone in front of you, highlighted, and tapping another highlight retargets. Use works whatever you face or hold (swing, eat, sit, work a station, re-crate). Pack stows or unstows hands to pack. Putting a thing into another player's empty hands is giving. No dragging anywhere.

### What a transformer is
A Process is one data row: TAKES (a list of slot filters written as tags, never item names), NEEDS (conditions: station kind, a pattern card present, a place tag or weather event, a worker body at the worker spot, a minimum tool material), TIME (seconds, computed from timestamps so it runs offline), GIVES (output templates that may inherit material and effect tags from the inputs). A Station is a holder with input slots, output slots, optionally a worker spot and pattern slots, and a list of processes it knows. When its slots satisfy a process and the needs hold, a ring starts; when it ends, inputs are consumed and outputs appear in the output slots. If the output slots are full it waits.

One model, six faces:
- Living things: a grow bed takes a seed (+ optional anything fertile) and needs the place tags the seed lists; a goat is a station that walks, takes any feed in its trough and gives fleece.
- Machines: an oven or transmuter is a station that arrived as a crate and was unpacked on a foundation slot.
- Rituals and ambient events: a lightning rod takes any empty vessel and needs the storm event; joining a people takes an offering on a shrine and gives a mark on your body.
- Guests: a traveller is a walking station whose input filter is derived from its own body table (it accepts as a treat anything its body reacts well to), with a patience timer, and whose outputs are coin plus one thing from where it came from.
- Factions: a settlement is a large station whose dock slots are its current needs and whose shop window holds its outputs, including capabilities.
- Bodies: an avatar, helper, guest or creature is itself something that can occupy a seat, bed or worker slot. That is what makes a service: a process in which one of the slots holds a body (patient in a cot, passenger in a seat, guest at a table) and the output is a change to that body.

Fighting is the same row shape: Strike takes one swing of a tool at a body and applies the tool's marks to it; the body's table decides the result (a night imp falls apart into sticks and old bones; a wired body is charged). No health-bar ladder is needed for the first build: Mild knock-downs only, no death, a knocked-down player gets up at the nearest bed.

### Capabilities
Every capability is a Thing in a slot, made or released by a process and consumed or installed by another.
- Machine: a crated station (bulky or huge). The settlement's window shows the actual transmuter behind glass with the three need icons under it; fill the bundle and the crate is released onto the dock. You must then physically get a HUGE crate home (a friend on the other end, a cart, or a truck) and unpack it on a foundation slot. Use-hold re-crates it, so it can be moved, lent, given or sold.
- Recipe: a pattern card, a small Thing that sits in a station's pattern slot and adds one process to that station (Cake card in an oven, Marking card in a workbench). Stations have 1-2 pattern slots, so which cards live where is a real choice, and a card can be handed to a friend.
- Helper: a hired hand is a body. It is obtained at a window for goods, kept by putting one meal a day in its lunch slot, and does one of two jobs: Tend (stand at a worker spot) or Carry (repeat the last take-from-A, put-in-B you did while it watched).
- Service: not an item; it is a process with a body in one slot. It exists wherever someone owns the station (a cot on a cart is a travelling hospital).
- Enchantment: a charm (a storm jar) is consumed by the Mark process to add its effect tag to a tool or worn thing as a mark. Marked tools are ordinary Things afterwards.
- Protection and people: both are marks. Ward puts 'warded' on a cart or plot for a day; Join a people puts a people mark on your body. Marks are the single mechanism behind enchantment, meal effects, protection and race.
Re-entry: the transmuter eats crystals and dull ore; the card enables cakes that guests eat; the helper eats meals; the mark is spent on swings that produce remains; the remains become fertiliser. Nothing ends as a number.

### Context
Effects are tags carried by things, places and events (starter set: cold, shock, rot, glow, warm, coldproof, warded). The receiver owns the reaction. Every body kind (wayfarer, wired, bogkin, goat, imp) and every place has a small table: effect tag -> one response from a fixed vocabulary implemented once in code (hurt/daze, mend, slow, haste/charge, thrive, flee, ignore, cancel-tag). Anything not listed falls to a default. Adding a people is one table; adding an effect is one default line plus exceptions. No pair is ever scripted.

Starter tables:
- Wayfarer (default player): cold -> chilled then dazed; shock -> dazed; coldproof or warm -> cancels cold; glow -> gives off light.
- Wired folk: shock -> charged (works at double speed for 60 s); cold -> stalls twice as fast.
- Bogkin: rot -> mended; composts four times faster as worker.
- Shag-goat: cold -> thrives (fleece in half the time).
- Night imp: glow -> flees; warded -> leaves; any hit -> falls apart.
- Places: Crossroads (mild); Cavern (cold, dark); Storm front (event: shock strikes on rods and on anyone holding conductive metal, visible on the horizon two minutes ahead).

What the body table is made of: your people mark, plus what you wear, plus what you have eaten (timed marks). So the cold cavern is trivial for a goat, fine for anyone in a fleece coat or on a frostcap cake, and hostile to a wired digger. Guests use the same tables in reverse: a guest wants whatever its body reacts well to, so a wired traveller will accept a storm jar as a treat without anyone authoring that.

### Who does it
A process that needs work has one worker spot, and it does not care whose body stands in it. The player works it with Use. A friend can, if the owner's gate is set to 'hands welcome' (a mutual permission, default off). A hired hand can: lead it to the spot and tap Tend. Carrying is delegated by demonstration: with a hand watching, take a thing from holder A and put it in holder B once; the hand then repeats 'move that kind from A to B' whenever A has one and B has room. There is no route editor and no job menu.

Driving is the third job and is abstract on the road, as in Retail Tycoon 2: a hand given a loaded cart or truck and a destination dock leaves, and returns after a time set by distance with what that dock paid. Nothing is simulated in between; route risk is a roll against the route's tags unless the vehicle carries 'warded'.

A HUGE thing needs two bodies or wheels, which is the plainest reason to bring a friend or a hand. A service is the same rule seen from the other side: you are the body in someone else's cot, seat or bench, and you (or the guest) pay the station's owner by putting coin or a thing on its tray. Offline, hands keep working from timestamps up to a cap of 8 hours and stop when their lunch slot is empty.

### Exchange
With factions: the settlement dock shows its needs as empty marked slots with a painted stock gauge beside each. Each need is an appetite that drains over time and fills as it is supplied; what it pays in coin falls as the gauge fills. Guests and docks also pay in kind with one thing from somewhere else (iron bars from naval travellers, odd seeds and bones from the bayou), which is how goods from regions not yet built enter play.

Three rules stop one best route:
1. Capabilities are never sold for coin alone. Each window item names a bundle of goods the settlement needs, and different items name different bundles. Coin buys commodities, fuel, wages, tickets and tolls.
2. Appetites saturate, so repeating one delivery pays less each time until it recovers.
3. Volume is real: a handcart holds four goods slots, a machine crate takes four bed slots, a trip costs time and (for trucks) fuel, and many inputs are destroyed in use (fuel, feed, meals for hands, charms, tribute), so demand does not end.

With players: put a thing in their hands (give), or use a counter, which is a holder with two trays where both sides place things and both tap to swap; the server swaps atomically. No listed prices, no chat needed; value is whatever two players agree by what they put down. In the first build appetites are saved per player; shared cross-server stock numbers come later and need a last-known value fallback because memory stores are not durable.

Coin is a counted purse stack, the one abstracted good, as money is in Lumber Tycoon 2.

### Direction without tasks
1. Their own hands. Holding any thing makes every slot in view that would accept it show a ghost outline of that thing (nearest five, more on a tap). What comes out is shown as a silhouette if you have seen it before and a question mark if not. The question a goalless player asks is 'where could this go?', and the world answers it for whatever they happen to be holding.
2. Shop windows and docks. Each settlement displays the real machine, card or hand it offers behind glass, with the goods it wants for it as empty slots underneath, and gauges showing what it is short of today. This is a menu of needs that points across systems, with no order and no checklist.
3. Idle things they own. An empty oven tray, a hungry goat's trough, an unslotted pattern slot and an empty lunch slot all show their ghost. An idle hand stands with a visible shrug.
4. Clocks in the world. Ripening rings on beds, a guest's patience, a storm front on the horizon two minutes out (rods and jars matter now), nightfall (imps come for grain beds).
5. Other bodies. Travellers arrive visibly carrying things from elsewhere and visibly react to what they are given; other players' hands and carts are legible at a glance because goods are never hidden in menus except inside a pack or closed crate.
6. A notebook that fills itself with every fit the player has seen (thing -> slot -> result), with unseen results left as question marks. It has no order, no rewards and no next step.
There is no quest list and no arrow after the first hand-off.

### Starter things
| Thing | Properties |
|---|---|
| Grain | SMALL, stack 8. Tags: plant, grain, feed, seed. Plantable, goat feed and oven input in one thing. Grows anywhere mild. |
| Frostcap | SMALL, stack 8. Tags: plant, fungus, seed, flavour, effect:coldproof. Grows only in a bed standing in a cold or dark place. |
| Log | BULKY. Tags: wood, hard, fuel. Material 'wood' for Shape. From timber nodes. |
| Crystal shard | SMALL, stack 8. Tags: crystal, hard, glow, flavour, effect:glow. Material 'crystal' for Shape. Dock need, transmuter input, jar material and cake flavour: four pulls on one good. |
| Dull ore | SMALL, stack 8. Tags: metal, dull. From hard nodes (iron tool only) and from naval travellers. |
| Iron bar | SMALL, stack 8. Tags: metal, hard, conductive. Material 'iron' for Shape. Not mined in this region: arrives as payment in kind. |
| Gold bead | SMALL, stack 8. Tags: metal, gold, conductive. Only from the transmuter. Asked for in two window bundles and by naval travellers; not a universal currency. |
| Old bones | HAND. Tags: remains, rot. From fallen night imps and bayou travellers. Worthless at the Crossroads dock; input to Compost. Cartoon bones only (Mild). |
| Fertiliser | HAND. Tags: fertile, rot. Doubles a grow bed's yield; mends a bogkin body if eaten. |
| Fleece | HAND. Tags: fiber, effect:warm. Material 'fleece' for Stitch; also the linen a cot consumes. |
| Loaf | HAND. Tags: food, meal. The plain meal: guests, hired hands' lunch slot, yourself. |
| Cake (x flavour) | HAND. Tags: food, treat, + the flavour's effect tag for 5 minutes on whoever eats it. Frostcap cake = coldproof; crystal cake = glow; storm cake = shock. |
| Jar | HAND. Tags: vessel, crystal. Shaped from 2 crystal shards. Empty until something fills it. |
| Storm jar | HAND. Tags: charm, flavour, effect:shock. One use. Made only by weather. Charm for Mark, flavour for cake, treat for wired folk. |
| Mattock (x material) | HAND. Tags: tool, dig, chop; holds 1 mark. Wood: made anywhere from 2 logs, never dulls, non-conductive, taps crystal clusters out whole, burns as fuel. Iron: 3x faster, opens hard nodes, cracks half the crystal, dulls and needs whetting, draws strikes in a storm. |
| Coat (x material) | HAND, worn. Passes its material's effect to the wearer while worn. Fleece coat = warm. |
| Pattern card | SMALL. Tags: pattern. Sits in a station's pattern slot and adds one process. Starter cards: Cake, Marking. |
| Crated station | BULKY (oven, workbench, grow bed, cot, trough-and-pen, lightning rod) or HUGE (transmuter, compost vat). Unpacks on a foundation slot into a station; Use-hold re-crates it. |
| Crate | BULKY holder, 4 slots. Closed, its contents are a count and it is one object to carry and to render. |
| Handcart | Holder that moves: 4 goods slots + 1 foundation slot (so it can carry one working station). Towed by any body, no fuel, fits the cavern path and footbridges. Saved to the player; the first home. |
| Shag-goat | Creature: a body and a station. Eats any feed, gives fleece. Body table: cold -> thrives. Follows whoever fed it last; rides in a cart pen. |
| Hired hand | Body with a people tag (starter: wayfarer or wired). Wants 1 meal a day in its lunch slot. Jobs: Tend a worker spot, or repeat one shown carry. Reacts to effects by its own table. |
| Coin | Counted purse stack, takes no slot. The one abstracted good. Buys commodities, fuel, wages and tolls; never a capability on its own. |

### Starter processes
| Process | Takes | Needs | Gives |
|---|---|---|---|
| Dig | One swing of any tool tagged dig or chop at a node | Hard nodes need an iron tool. Cavern nodes sit in a cold, dark place. | Timber node -> log. Stone node -> dull ore. Crystal cluster -> 2 shards with wood, 1 with iron. |
| Grow | 1 seed + optionally 1 of anything fertile | Grow bed; the place tags the seed lists. 4 min, runs offline. | 3 of the plant (6 if fertilised) |
| Graze | 1 of anything tagged feed in the trough | A creature penned on a plot or cart. 5 min, offline; half that if the creature thrives in the place. | The creature's product (goat: fleece) |
| Bake | 2 grain + 1 of anything tagged fuel | Oven. 20 s. | Loaf |
| Bake cake | 2 grain + 1 fuel + 1 of anything tagged flavour | Oven with the Cake card in its pattern slot. 30 s. | Cake carrying that flavour's effect tag |
| Shape | 2 of one material tagged hard | Workbench; built-in shapes: mattock, crate, jar (crystal only) | That item in that material |
| Stitch | 2 of one material tagged fiber | Workbench | Coat of that material |
| Mark | 1 tool or worn thing + 1 charm | Workbench with the Marking card, or the settlement smith does it as a paid service | The same thing carrying the charm's effect tag as a mark |
| Catch a storm | 1 empty vessel on a lightning rod | The storm event overhead (about every 20 min, visible 2 min ahead) | Storm jar |
| Compost | 1 of anything tagged remains or rot | Compost vat. 8 min; 2 min if the body at the worker spot is bogkin. | Fertiliser |
| Transmute | 2 of any metal tagged dull + 1 crystal | Transmuter. 60 s. | 1 gold bead |
| Host a guest | One thing the guest's body reacts well to, put on its plate (a meal for anyone; a treat matched to its people) | A free seat on a plot or beside a cart; the guest's patience timer | Coin + one thing from the guest's home region + standing with its people |
| Rest and mend | A chilled or dazed body lying in a cot + 1 fiber | Cot (on a plot or a cart). 15 s. | The body cleared of the condition; the body's owner (or the guest) leaves payment on the cot's tray |
| Supply the settlement | Anything matching a need slot at the dock | That need's gauge is not full | Coin on a falling scale + standing; a completed bundle under a window item releases that machine, card or hand |
| Hire | The window bundle once, then 1 meal a day in the lunch slot | A free bunk (cot or cart seat) for the hand | A body that Tends or repeats a shown carry, including offline up to 8 h |
| Ward | 1 treat a day left in the hill warden's bowl | A cart or plot within the warden's country | Mark 'warded' on that cart or plot for a day; imps and road trouble leave it alone |
| Strike | One swing of any tool at a body | - | The tool's marks applied to that body; its table decides. Imp: falls into a log and old bones. Wired body: charged. Wayfarer: dazed. |
| Join a people | That people's offering on their envoy's stone (bogkin: 3 fertiliser; wired: 2 gold + 1 storm jar) | The envoy guest is in the server (they travel through on a clock) | A people mark on your body (replaces the old one), shown as avatar add-ons |
| Eat or wear | A food or worn thing, by Use while holding it | - | Its effect tags applied to your body for a time (food) or while worn (coat) |

### What a player could do with only the starter set
- The cavern-mouth cot (a service nobody authored). A player notices that wayfarer diggers, NPC travellers and other players come out of the cavern chilled. They unpack a cot on their handcart's one foundation slot, park at the cavern mouth with a stack of fleece and a few frostcap cakes, and get paid for rest and for cakes by whoever staggers out. The content defines a cot, a cold place and a cart; it never mentions a clinic at a cave.
- The night watch that turns into a fertiliser business (fighting feeding farming). Imps come for grain beds after dark and fall apart into old bones when hit. Bones are worth nothing at the dock, so they pile up, until the player tries one in a compost vat. Fertiliser doubles bed yields, so the person who likes swinging a mattock at night ends up as the supplier to the people who like growing things. If they take the bogkin mark they compost four times faster and can eat their own product to recover.
- Keeping a wired hand charged (a combination the content never spells out). The Strike row says a tool applies its marks; the wired table says shock means charged. A player with a wired hired hand at the oven marks a wooden mattock with a storm jar and taps the hand with it every minute for double work speed, or simply moves the hand's bunk next to the lightning rod before a storm. A wired friend asks for the same favour before a dig.
- The lightning bakery (trade by reading people). Guests want what their bodies react well to. A storm jar is tagged flavour, so storm cake exists by rule; wired travellers treat it as the best thing on the table, while a wayfarer who is handed one is dazed for a few seconds. The player ends up watching who walks in and choosing what to put on which plate: frostcap cake for the digger heading uphill, crystal cake for someone who wants a light at night.
- A herd in the cold (animal keeping shaped by place). Goats thrive in cold, so their fleece comes twice as fast in the cavern. A player moves the pen onto the cart, tows it up, and has to solve their own cold problem with a coat or cakes. Crystal shards set around the pen keep imps off because imps flee glow. They come down with fleece nobody else can produce at that rate and the dock gauge for fibre is theirs to fill.
- Two players and one transmuter (needs another body). The transmuter crate is HUGE. A digger who has filled the crystal bundle cannot move it alone without wheels, so a second player takes the other end and they walk it home. After that they split without a word of chat: one keeps tapping crystal out whole with a wood mattock, the other hauls dull ore from travellers and runs the machine, and they settle up across a counter in gold beads and jars.

### First minute
- 0-5 s: You appear at the Crossroads yard standing by a handcart with your name on it. It holds three things: a loaf, a pouch of grain and a wood mattock. One of the three is already in your hands, chosen at random per new player (which also gives a free comparison of which opening bounces least). No text box.
- 5-15 s: Because you are holding something, every slot in view that takes it shows a ghost outline, and one is within ten steps: a traveller's empty plate for the loaf, a tilled bed for the grain, a crystal-veined rock at the yard's edge for the mattock. The big thumb button reads Put (or Use for the mattock). One press and something visibly happens: the traveller eats, a sprout pops with a ripening ring, a shard cracks off.
- 15-30 s: What comes back is not what went in. The traveller leaves coin and an iron bar from the north; the rock gives a crystal shard; the bed, while its ring runs, shows the trough of a goat that also wants grain. You Take the new thing, and different ghosts light up: the shard fits the dock's crystal need, the oven's flavour slot (locked, showing a card outline) and a jar shape at the workbench.
- 30-45 s: The other two things are still on your cart, and the Take button now points at them. Whatever you try next uses the same two presses in a different place. The yard has a shared oven and workbench, so a loaf or a second mattock can be made on the spot from what is lying around.
- 45-60 s: The cart handle shows a ghost for your empty hands. Grab it and it follows you. Thirty steps away the settlement window is lit, with a real transmuter and a real pattern card behind glass and empty need slots beneath them. Uphill, the cavern mouth breathes cold mist; on the horizon a storm front may be building. Nothing tells you which to walk to.

### Three players at hour ten
The herder lives on a cart in the cold pass and has never claimed a plot. She wears fleece, keeps four goats that produce at double rate up there, rings the pen with crystal to keep imps off, and leaves a cake in the warden's bowl each day for the ward. She comes down to sell coats and frostcap cakes at the cavern mouth.

The tinkerer has a plot by the Crossroads with a transmuter, three lightning rods and a wired hired hand he keeps charged. He took the wired mark himself, so storms are an opportunity and the cavern is a problem; he pays the herder in gold for coldproof cakes or sends a hand with a cart instead. He has not planted anything.

The host runs benches and two cots, took the bogkin mark, composts the bones that night imps and bayou guests leave, and feeds a kitchen garden with the result. Her skill is reading who walks in and what their body wants. A friend does her fetching.

They differ because of where they stand (place tags), what their bodies are (people mark, clothes, meals), which window bundle they filled first (each asks for different goods, and none can be bought with coin), and what happened to be in their hands in the first minute. The tools are tiered and all three own an iron mattock; that is the part of the game that is a ladder, and it is a small part.

### Why it is not one ladder
Tiers are in it on purpose: wood then iron tools, hands then pack then cart then truck, a clay oven then a bigger one, more hands. The low tiers stay because of one odd property each, not three: the wood mattock is free anywhere, safe in a storm and gets crystal out whole; the handcart needs no fuel and goes where a truck cannot; bare hands go everywhere.

What keeps the whole from being one ladder is four specific rules. First, processes match tags, not names, so a new thing lands in several existing slots (a storm jar is a charm, a flavour and a wired treat on day one). Second, payment in kind: a station's output is by construction something that station cannot take back in, and guests and docks pay partly with goods that belong somewhere else, so the answer to 'what next' is a different place and a different verb. Third, capabilities are never sold for coin alone, and each asks for a different bundle, so there is no single number to raise and no single shop to grind towards. Fourth, the receiver decides the effect, so the same good is worth different amounts to different bodies and places and no price list can rank everything.

I would enforce the second and third with a content check run on every data change: for each thing, count the distinct station families that make it and take it; for each station, check that its shortest route back to more of its own inputs passes through another family. A thing may fail the check only if it is marked plain on purpose.

How it could still collapse: (a) tuning. If loaf-to-plate coin outpaces everything and coin buys enough commodities to fill bundles, players will run that one loop; the falling appetite scale has to bite. (b) Gold. If later content lets gold beads substitute for most bundle goods, the transmuter becomes the game and everything else is a detour to it. (c) Content drift. If the second and third regions add 'better crystal', 'better oven', 'better transmuter' rather than new tags and new body tables, the web turns into parallel ladders; the designer's naval-town example (needs food, gold, heat from magic users, pixie dust) is the right shape and the check above is how to hold to it. (d) Helpers that remove every hand job with nothing new to do, as happened in Islands. Hands need a meal a day and can only Tend or Carry, which keeps the player as the one who decides where things go.

### Technical model
Data: Luau ModuleScripts of plain tables under src/shared: Tags, Materials, Things, Stations (slot layouts as named attachments on the model), Processes, Bodies (reaction tables), Places (tags, events), Settlements (needs, drain rates, window bundles). Regions and peoples are rows.

Truth and rendering: the server holds ThingRecord and HolderRecord tables; instances are a view. One MeshPart per thing kind (the artist's blocky models), three pile levels for stacks. At rest: anchored at the slot attachment. Carried: welded, massless, CanCollide off. Closed crates and packs render nothing inside. Loose ground things are anchored after a client-only tumble, capped at 12 per player with a 3-minute fade. Streaming on. There are no unanchored goods at all, so the physics-ownership exploit family (teleporting goods, flinging, faked Touched) has nothing to act on, and the client never has authority over a good.

All goods change through two server functions. Move(thing, to holder, slot, actor) checks distance, ownership, slot filter and capacity, and is atomic. Transform(station, process) consumes and creates with new serials and writes a ledger line. Purchases, swaps and gives are Moves, with a per-player action lock so a double tap cannot fire twice (the Booga Booga and Dead Rails dupes). Vehicle and character speed is sanity-checked server-side.

Saving: one session-locked profile per player (UpdateAsync, autosave every 2-3 minutes, save on leave and BindToClose): owned holders with contents as short arrays (kind, material, marks, count), station timestamps, hands and their assignments, standing, body marks, notebook, appetites. Rough size: 300 stacks at about 40 bytes is 12 KB against a 4 MB key. No interaction with a player's holders until their load completes; the plot is removed even if the save fails. On load, a single deterministic catch-up function runs each station forward from its timestamp, limited by inputs present and output room, with hands' carries applied as capped rates.

Servers: 8 players, in line with Lumber Tycoon 2, Oaklands and Refinery Caves. One place for the first region. Per-player caps: about 150 visible stacks and 30 stations on plot plus cart. Guests are capped by free seats (the Restaurant Tycoon rule). Guests and hands are server-side data moving along a small authored waypoint graph, with simple rigs rendered on clients; no Humanoid pathfinding.

Costliest parts: in code, the hired hand and guests sharing slots with players (slot reservations so two actors never claim the same thing, recovery when a holder is moved or re-crated mid-task) and the offline catch-up being exactly consistent with live play. In feel, phone targeting when many slots sit close together. Unverified and to be measured early: how many anchored models a 2-4 GB Android phone tolerates in the streamed area, and how a cart with a welded load and a working station streams in.

### Test
Log every (thing kind, slot or body it was put into) pair per tester, with timestamps, and compare against the list of pairs used in the authored examples.

Blossoming looks like:
- In the first ten minutes a tester touches at least three different station families without being told to.
- A tester puts a thing somewhere other than its nearest ghost because they were curious (the storm jar in the oven, a shard on the pen fence, a cake handed to the hired hand).
- At thirty minutes two testers' carts hold visibly different things and they describe what they are doing in different words.
- Someone walks to the window, looks, and leaves to fetch something specific.
- Someone carries a station somewhere odd on the cart.
- At least one logged pair is one the designer did not list in advance. One is enough for a first test; none is a bad sign.
- With two testers in a server, one hands the other something unprompted.

Not blossoming looks like:
- More than about 60% of all Moves after minute thirty go into one process (most likely loaf to plate).
- Testers ask 'what am I supposed to do' after the first hand-off, or ignore the ghosts.
- The lightning rod, the cot and the cavern go unused: the web is there but nothing pulled them into it.
- Testers hoard coin and ask what it buys.
- Everyone's cart holds the same things.
- Phone testers fumble Take/Put (undo rate above one in five) or avoid the cart.

Also measure: seconds to first Put, seconds to first Take of a thing they did not start with, and whether the random starting hand changes either.

### First build
- The rule itself: Thing records with tags; holders with slots; exactly two server functions that change goods, Move (atomic, validated for distance, ownership, slot filter) and Transform (process completion, logged); the process engine driven by data rows and timestamps; receiver-side reaction tables.
- The three buttons on a phone: Take/Put with cone targeting and tap-to-retarget, Use, Pack. Ghost slots for the held thing. This is the part to get in front of the human tester first.
- Hands, pack and the handcart (a holder that moves with a welded load and one foundation slot). No other vehicle.
- Four very different stations: an oven with one pattern slot (machine), a grow bed with offline ripening (living thing), a lightning rod that only works in the storm event (ambient ritual), a cot (service with a body in a slot).
- One node type in one cold place: crystal clusters in a short cavern, wood and iron mattock so the tier and the wood tool's odd advantage are both testable.
- One guest generator with two body tables (wayfarer, wired), wants derived from the tables, payment in coin plus one thing in kind.
- One settlement dock with three draining needs and a window with three items on three different bundles: Cake card, Marking card, one wired hired hand.
- One hired hand with Tend and show-once Carry, on a small waypoint graph, with a lunch slot.
- Give (hands to hands) and one counter for two-player swaps; the 'hands welcome' gate permission.
- Save and load of cart, plot stations, contents, timestamps, standing and body marks with session locking; a test harness with bot players, a clock that can be jumped and a log of every (thing, slot) pair used.
- About 14 things from the starter list: grain, frostcap, log, crystal shard, iron bar, fleece (from guests for now), loaf, cake, jar, storm jar, mattock, coat, pattern card, crated station.

### Left out of the first build
- Trucks, trains, ships and any driven vehicle: vehicle physics on phones is the known fragile part (Retail Tycoon 2's trucks were undrivable under about 20 fps), and the handcart already tests a moving holder. A seat-based truck is the first addition.
- Hired drivers and off-road haul runs; route risk; road trouble.
- Transmuter, compost vat, goats, imps and Strike as combat, Ward, Join a people for players. They are in the starter data and are the second build; the first build proves the rule with one people difference on guests and the hired hand.
- A second region or place, teleports, and shared cross-server stock numbers. Appetites are saved per player at first.
- Plots chosen from pads Lumber Tycoon-style beyond a single foundation grid per player; decoration; building walls and rooms.
- Player-owned stalls that sell while the owner is away; any listed-price market.
- Raiding or taking from other players' holders. Loose ground things are free to anyone; owned holders are locked unless the gate is open.
- Free physics dragging, throwing, stacking by physics. Never planned, not just postponed.
- Spoilage, heat, water and liquids, whetting and tool wear (iron's upkeep arrives with the second build).
- Monetisation, daily rewards, tutorials beyond the first hand-off.
- Server Authority mode: unnecessary while no good is ever a loose assembly; revisit with vehicles.

### Risks
- Phone targeting. With an oven, a crate and a cart within arm's reach, the nearest-valid-slot rule may pick the wrong one. If more than about one in five Puts is immediately undone, the control scheme needs rework before anything else is built.
- Snapping instead of physics loses the mess that makes Lumber Tycoon 2 and Dead Rails clips funny. Client-side wobble and a swaying cart are cosmetic substitutes; this is a real trade for stability and should be shown to the designer early as a feel question.
- Too many ghosts. A crystal shard fits four places; in a busy plot the outlines could become noise. Capped at five nearest, but untested.
- Coin or gold becoming the single measure through tuning or later content, which would turn the web back into sell-then-buy.
- Content authoring depends on tagging judgement. Sloppy tags give either dead-end items or everything-fits-everywhere mush. The content check catches the first, not the second.
- Solo servers. With one real player, guests, the dock and one hired hand have to be the whole web. Give, the counter and two-body carrying will rarely be exercised at launch.
- The first minute offers three openings at random. One may bounce worse; it is measurable, but until then it is a guess that all three read in ten seconds.
- Offline catch-up and helper automation are where duplication and runaway production would come from. The ledger and the 8-hour cap limit it; they do not prove it safe.
- Per-player appetites in the first build mean no real scarcity between players; the shared-numbers version changes the feel and has not been designed in detail.
- Scope. The first build is an engine plus about 14 things and still includes a save system, NPC bodies and a test harness. It is small in systems, not small in work.
- Mild rating: old bones and knock-downs must stay cartoonish, and marking another player's body with shock must not become harassment; Strike on players is off unless both have their gate open.
- The grounding brief's device figures (moving-assembly budget, low-end frame rates) are one 2024 article and one anecdote. The design avoids depending on them, but anchored-object counts on cheap phones are still unmeasured.


---

## Stuff, Form and Three Dials (a property-first rule-set) (19/30)

### Summary
Every object in the world is a form made of a stuff: a mattock made of iron, a coat made of fur, a crate made of lead. Every object, creature, person and place also carries the same three dials: Heat (cold to warm), Life (rot to bloom) and Spark. A handful of short rules say how dials move (things slowly take on the dial of the place they are in; crystals hold a dial without losing it; magic "pins" a dial to an object for good) and what a dial does when it touches something (each kind of body has one row saying whether warm, cold, spark, bloom and rot hurt it, feed it or do nothing). Machines, crops, animals, guests, towns and other players are all "stations" that ask for classes of thing ("anything rigid", "anything holding Spark", "anything rotten"), never for named items. Nothing in the game is scripted as a pair. Lightning on a tool hurts a bandit and recharges a robot helper because of their rows, not because anyone wrote that interaction. A cake's effect is whatever dials its ingredients carried when it was baked, read against whoever eats it. A new region is a row of ambient dials, a people row, a few stuffs and a list of what its town needs and offers, and it works with everything already in the game on day one. Ordinary tiers sit inside this (wood, iron and crystal tools; handcart then truck), and they stay plain tiers.

### What a thing is
A thing is one server record: Form x Stuff + three dials + at most one pin + wear + count + where it is.

STUFF (the material) carries five numbers or flags and nothing else: hard (0-3, what it cuts and what cuts it), warmth (0-3, insulation when worn), bulk (1-3, space it takes), class (rigid / pliable / edible), and at most two odd tags from a short list (conducts, shields, holds, burns, precious, seed, cures, rot-proof, dull->noble).

FORM (the shape) says how many units of which class it takes and which Stuff number it reads: a mattock reads hard, a coat reads warmth, a crate reads the odd tags. N forms and M stuffs give N x M goods from N + M definitions. A lead crate, a gold mattock and a fur coat are never defined anywhere.

THE THREE DIALS, on every thing, body and place: Heat -3..+3, Life -3..+3, Spark 0..3. Warm and cold cancel; bloom and rot cancel. Magic is not a fourth dial: it is the act of pinning one dial to a thing permanently.

Physically: one thing is one blocky model. It is anchored at rest, welded to your hands while carried (one big thing, or a counted pack of small ones), welded into a slot on a cart or truck in transit, and a count with a visible fill level inside a crate. Phone controls are three context buttons (Pick up, Put, Use) aimed by proximity; there is no free physics dragging. You own containers, not loose objects: your pack, your handcart or truck, your plot. What is inside an owned container saves with you and loads into any server. Loose things left in the open world are declared temporary and fade after two minutes. Coin is the one abstracted good (a wallet number), as money is in Lumber Tycoon 2.

### What a transformer is
One record covers every transformer:
- station: the thing where it happens
- takes: property queries with amounts, never names
- needs: a dial band for the place, a tool class, a standing level, an operator
- time: operator-seconds or wall-clock
- gives: one of six output shapes

The six output shapes:
1. Change Form, keep Stuff (shape at a bench).
2. Change Stuff, keep Form (transmute).
3. Move, lock or pin a dial (soak, cook, bind).
4. Break a thing down to its Stuff.
5. Change a body's state (a service).
6. Hand over a capability object or standing.

How each kind of transformer is a case of that record:
- Crop: the station is soil, the take is "any seed", time is wall-clock, and the produce carries the dial of the place it grew in.
- Animal: the station is the creature's own body, the take is "any fodder", and it gives milk, fur and eventually remains.
- Machine: a station whose need is Spark or a cranking operator.
- Ritual: a station (the binding stone) whose take includes a dial-holding crystal.
- Guest: a walking station that takes whatever feeds its row and gives coin, standing and a thing from its homeland.
- Faction town: a station with a need list (queries whose price falls as its stock fills and recovers as the town uses it up) and an offer list (commodities for coin; capabilities for standing plus goods).
- Another player: a station too, by placing a Counter with a take-and-give rule they set themselves.

The whole chemistry is four rules:
1. A thing drifts one step a minute toward the dial of where it is (the place, or a pinned container), unless it is crystal (holds), inside lead (shielded) or pinned.
2. A dial touching a body is looked up in that body's row: hurts, nothing or feeds. Worn gear and recent food edit the row.
3. A dial touching a process is looked up in that process's band: runs, stalls or changes the output.
4. Stuff never acts on stuff; only stations do, and stations ask for classes.

One guard rule keeps it honest: only places are free sources of a dial. Everything else spends fuel, a crystal's charge or tool wear to pass a dial on.

### Capabilities
Every capability is an object in the same system. It arrives in a crate you carry home, takes up bulk, can be placed, given, lent, stolen back from a bandit camp, or sold from a counter.
- Machine: a station in a crate (Oven, Mill, Transmuter, Compost Vat, Counter, Binding Stone). Placing it on a plot or on a truck bed is what makes a workshop, a tavern or a travelling hospital.
- Recipe: there are no named recipes. Knowing how to make something means owning the station and having the classes it asks for. What you learn is properties, recorded in an almanac as you observe them.
- Helper: a body with a people row and a contract object. It is assigned to a station, a route or a guard post, and it has upkeep in whatever feeds its row. That makes the helper a consumer of other people's outputs as well as a worker.
- Enchantment: a pinned dial. It is made at the Binding Stone from any thing, a crystal holding the dial and binding dust (ground crystal). There are no named enchantments: five dial poles on every Form give them all (cold crate, lightning mattock, warm coat, rot blade).
- Service: a station plus stock plus an operator plus a customer who is present (see who_does_it).
- Vehicle and deed: a carrier is a container with wheels and station slots; a plot deed is a container that stays put.

Each of these re-enters as an input. The Transmuter eats Spark crystals and lead and makes gold. A gold thing takes a pin one level higher. A pinned thing is itself wanted by a town or a player. A helper needs feeding from someone's kitchen, cavern or compost.

### Context
Context is two lookups, both pure data.

1. A place has ambient dials.
- Meadow: 0 / 0 / 0, with bloom +1 by the river.
- Frost Pass: Heat -2. The crystal cavern inside it: Spark 3.
- Bog Hollow: Life -1.
Standing in a place is the same as being touched by a source of that dial.

2. A body has one row of five responses, plus a need.

| Body | Warm | Cold | Spark | Bloom | Rot | Needs |
|---|---|---|---|---|---|---|
| Hearthfolk (player default, market folk, bandits) | comforts | hurts | hurts | mends | sickens | food |
| Wired | hurts | speeds work | feeds | nothing | nothing | Spark |
| Risen | nothing | nothing | hurts | hurts | mends and feeds | rot |
| Shagback | no milk when warm | nothing | hurts | mends | sickens | fodder |
| Sparkling | nothing | hurts | feeds (it grows) | nothing | nothing | Spark |

Gear and food edit the row: a coat cancels as many steps of cold as its Stuff has warmth; bogweave cancels rot; a cake applies its locked dials for five minutes.

What follows without scripting any pair:
- The Frost Pass is deadly to a bare Hearthfolk player, trivial in a fur coat or after a warm cake, and a place where a Wired helper works faster.
- The lightning mattock stuns a bandit, recharges your Wired helper and makes a Sparkling bigger.
- Milk left in the bog turns to cheese; milk left in the pass keeps.
- Grain grown at the pass mouth is cold grain.

A new people is one row. A new region is ambient dials, a people row, a stuff list and a town's needs and offers. The winter naval city is Heat -2 with a people that cold feeds and warmth hurts, needing warm food, gold and warm-pinned stones for its factories. No code is written for it.

A player's own people is changed by a ritual (a process), shown as add-ons on their Roblox avatar, and is reversible. That is left out of the first build.

### Who does it
Every process has one operator slot, and three kinds of body can fill it.

- You: stand at the station and hold Use.
- A helper: tap the helper, then tap a station ("work here"), two containers ("carry anything matching this from here to there"), a carrier ("drive this route") or a post ("guard this"). A helper works at the speed its row gives it in that place. It works while you are elsewhere in the server and, in the full game, while you are offline (worked out from timestamps when you load, limited by input stock and upkeep stock). A remote trip is a timer with a real truck that visibly leaves and comes back loaded, as hired drivers work in Retail Tycoon 2.
- A friend: per-container permission flags (use stations, take from crates, drive, ride as guard), mutual and off by default.

A service is a process whose output lands on a body or a carrier instead of in a crate: fed, warmed, mended, charged, guarded, carried. It needs a station (a Counter, or a seat on a truck), stock, an operator and a customer who is physically there, and it takes real seconds. You can watch it, queue for it and interrupt it.
- Tavern: a Counter with a stocked crate on a plot.
- Travelling hospital: the same Counter on a truck bed, parked where bodies get hurt. Mending means applying the dial that feeds that body's row (bloom for Hearthfolk, rot for Risen, Spark for Wired).
- Protection: the state "guarded" on a carrier or plot while a guard body is present. It can be bought four ways: the market's wardens for a tithe on stall sales; the bandits themselves, by toll or by standing; a hired helper for upkeep; another player, who sells "ride-along guard, ten minutes" from their own Counter.

### Exchange
With towns:
- A need is a property query with a price that falls as the town's stock fills and recovers as the town uses the stock up.
- Commodities (seed, iron, fodder, wood) are bought with coin.
- Capabilities are never sold for coin alone. They cost standing with that town plus a class of goods. Standing is earned only by filling that town's needs, serving its travellers or guarding its carts.
- Each town's needs point at another zone's ambient or another people's output. The Depot wants cold things and held Spark. The Lodge wants rot and cheese. The Market wants warmth and gold.

With players:
- Hand a thing over, set friend permissions, or place a Counter with your own take-and-give rule, shown as icons so it works without chat.
- Every exchange is a server-side move of records. The models are only views.
- A cross-server consignment board comes later.

How value is set: there is no price on a thing. A thing's worth is how well it matches somebody's unfilled need right now, plus what it does as Stuff. Gold is wanted by every town, but its demand saturates like any other need. Its lasting worth is that a gold thing takes a pin one level higher.

What stops one best route:
1. Stock saturates, so the fifth load pays less than the first.
2. Dials fade in transit unless you invest in crystal, lead or a pin, so which route is open depends on what you have built.
3. Each town pays out in different capabilities, so "best" depends on what you want to become.
4. Upkeep sinks never close: helpers eat, trucks burn fuel, crystal tools shatter.
5. The dangerous road takes a third of a truck's cargo unless you have paid for passage in one of four ways.
6. A town's need list shifts with its state (the Depot overheats and pays double for cold; the Lodge holds a feast and wants cake).

In the first build, stock is per server. Shared stock across servers comes later.

### Direction without tasks
There is no list. A player with no goal has six things to look at.

1. The icon language. Tap any thing to see its Stuff, form and dials as icons. The same icons float over every station's slot (any rigid, any rot), over every town gate (what it is short of, drawn as empty racks and cold chimneys as well as icons) and over every body in need (a shivering traveller, a slumped Wired). Direction is matching what is in your hands to what the world is showing, in any order.
2. Towns run their capabilities in the open. You watch the Depot's transmuter turn lead pipes into gold pipes, and the Lodge's vat turn bones into mulch, before you can own either.
3. Travellers of other peoples walk up to your gate with a need, and pay partly in something from their homeland (a crystal soaked in a dial you have never held, a seed, a lump of lead). The web comes to you.
4. Your own things have needs: the helper's charge, the Shagback's fodder, the truck's fuel, the cracking crystal mattock.
5. The almanac is a Form x Stuff grid and a dial card per body. It fills in only as you observe things, so the blank squares are questions ("what does a fur crate do?"), not tasks.
6. Three roads leave the crossroads, and each signpost shows the ambient dials of where it leads.

The only prompt in the game is one line of hint text during the first minute.

### Starter things
| Thing | Properties |
|---|---|
| Wood (stuff) | rigid, hard 1, bulk 1. Tags: burns (fuel, gives warm 2), does not conduct. Trees everywhere. |
| Iron (stuff) | rigid, hard 2, bulk 2. Tag: conducts. Bought at the Depot; veins in the cavern. The plain workhorse tier. |
| Lead (stuff) | rigid, hard 1, bulk 3. Tags: shields (contents of a lead container do not drift), dull->noble (transmutes to gold). Poor for tools. |
| Gold (stuff) | rigid, hard 1, bulk 3. Tags: conducts, precious (every town wants it; demand saturates). A gold thing takes a pin one level higher. From the Transmuter only. |
| Crystal (stuff) | rigid, hard 3, bulk 1. Tags: holds (keeps the dial it was last soaked in; fills only in places at level 2+), brittle (wears three times as fast). Grinds to binding dust. |
| Fur (stuff) | pliable, warmth 3, bulk 1. Sheared from a Shagback. |
| Bogweave (stuff) | pliable, warmth 0, bulk 1. Tag: rot-proof. Woven at the bench from bog reed. |
| Grain (stuff) | edible, bulk 1. Tags: seed, fodder. Mills to flour. Carries the dial of where it grew. |
| Milk (stuff) | edible, bulk 1. Tag: cures (becomes cheese at Life -1; cheese no longer turns). Turns to remains at Life -3; drift stops at Heat -1 or colder. |
| Remains (stuff) | bulk 1, native Life -2. Bones, critter bits, spoiled food, drawn as cartoon bones and compost. A Compost Vat turns it into mulch (Life +2). |
| Mattock (form) | 2 rigid. Cut power = Stuff hard. One tool for chopping, mining and hitting. Passes its dials to whatever it hits; a conducting mattock also passes the target's Spark back to the wielder. |
| Coat (form) | 3 pliable. Cancels cold by Stuff warmth; rot-proof Stuff cancels rot. A pinned dial is applied to the wearer and wears the coat down. |
| Crate (form) | 4 rigid. Holds 6 bulk. Contents sit at the crate's pinned dial if it has one; a lead crate shields contents from all drift. |
| Cake (form) | flour + milk + up to two dial-carrying extras (a pinch of charged crystal dust, or any edible carrying a dial). Locks those dials in at baking. Eaten: applies them for five minutes, read against the eater's row. Grain alone bakes a plain loaf. |
| Carrier (form): handcart, truck | Handcart: 6 bulk, 1 station slot, no fuel, bandits ignore it. Truck: 20 bulk, 3 station slots, burns wood or drinks Spark, bandits notice it. Both are containers you own and can live out of. |
| Workbench (station) | Shapes any Stuff of the right class into a Form. On the starting plot. |
| Oven (station) | Burns wood. Cooks, and is a warm 2 source for anything near it. On the starting plot. |
| Mill (station) | Breaks things down: grain to flour, crystal to binding dust, any made thing to half its Stuff. Hand crank or Spark 1. On the starting plot. |
| Binding Stone (station) | Pins one dial to one thing for good. On the starting plot. |
| Counter (station) | Offers stock from a linked crate to guests and players as goods or as a service, at the owner's price. Works on a plot or a carrier. |
| Transmuter (station, earned from the Tinker Depot) | Swaps a dull Stuff for its noble pair, keeping the Form. Needs Spark 1 per bulk. |
| Compost Vat (station, earned from the Mire Lodge) | Turns anything at Life -2 or lower into mulch. Stalls in cold. |
| Shagback (creature) | Body row: cold nothing, warm stops milk, Spark hurts, bloom mends, rot sickens. Tamed by feeding. Follows; can be penned. |
| Sparkling (cavern critter) | Body row: Spark feeds (it grows a size), cold hurts (goes brittle), other dials nothing. Sheds crystal shards by size. |

### Starter processes
| Process | Takes | Needs | Gives |
|---|---|---|---|
| Tree, lead vein, crystal node (gather) | hits from any mattock | hard at least equal to the node's (tree 1, lead 2, crystal 3); one tier under works at quarter speed and gives chips | units of that Stuff carrying the dial of the place. A charged crystal node passes Spark up a conducting mattock into the wielder. |
| Soil bed (grow) | any seed; optionally mulch | place not colder than Heat -1; wall-clock time | three produce carrying the place's dial; five with mulch |
| Shagback (keep) | any fodder each day | place not warmer than Heat +1 | milk daily; fur when sheared; remains at the end |
| Sparkling (keep or hunt) | Spark, from a charged node or from being struck by a Spark-carrying tool | nothing | grows a size and sheds more crystal shards; a cold-carrying hit breaks it into shards at once |
| Soak | an empty crystal left in a place | a place dial of 2 or more: deep cavern (Spark), high pass (cold), oven mouth (warm), bog pit (rot), river grove (bloom); two minutes | a crystal holding that dial until it is used |
| Shape (Workbench) | units of any rigid or pliable Stuff, by the Form's count | an operator | that Form in that Stuff |
| Break down (Mill) | grain, crystal, or any made thing | a cranking operator or Spark 1 | flour, binding dust, or half the thing's Stuff |
| Cook (Oven) | flour + milk + up to two dial-carrying extras; wood as fuel | an operator | a cake with those dials locked in (grain alone gives a loaf) |
| Bind (Binding Stone) | any thing + a crystal holding a dial + one binding dust per level | an operator; one pin per thing | the thing with that dial pinned for good, and the crystal emptied. A pin acts on use and costs wear. |
| Transmute (Transmuter) | any thing made of a dull Stuff + Spark 1 per bulk | an operator | the same Form in the noble Stuff (lead to gold) |
| Compost (Compost Vat) | anything at Life -2 or lower | place not colder than Heat -1; wall-clock time | mulch (Life +2) |
| Serve (Counter) | a guest or player with a need, and matching stock | an operator present | the effect on the customer's body; coin to the owner; standing with the guest's people |
| Traveller (guest) | whatever feeds its row for its one need: fed, warmed, mended or charged | a Counter or a hand-over within reach | coin, standing, and one thing from its homeland (a soaked crystal, a seed, a lump of lead) |
| Crossroads Market (Hearthfolk town) | anything with warmth 2+, cheese, warm food, gold | standing for the capabilities | coin, seed, fodder; at standing: a Shagback calf, a Counter, a truck body, a meadow plot deed, warden patrols (a tithe on stall sales) |
| Tinker Depot (Wired town at the pass mouth) | crystals holding Spark, anything at Heat -2 or colder, gold | standing for the capabilities | coin, iron, lead scrap; at standing: a Mill motor, a Wired helper contract, a truck engine, the Transmuter |
| Mire Lodge (Risen town in the bog) | anything at Life -2 or lower, cheese, crystals holding rot | standing for the capabilities | coin, mulch, bog reed; at standing: a Risen gardener contract, the Compost Vat, a bog plot deed |
| Pass Bandits (outlaw crew, Hearthfolk row) | a third of a truck's crates, carried off to their camp where they sit as real objects | waived by a coin toll, a guard on board, or standing (they are cold and hungry: warm cake) | at standing: safe passage, a lookout who rides as your guard for a cut, cheap fenced iron and lead |
| Helper (hired hand) | upkeep by its row: food, Spark or rot | one assignment: a station, a route between two containers, a carrier, a guard post or a Counter | the operator's work at that process, at the speed its row gives it in that place |
| Friend (another player) | whatever the two of you agree, by hand-over or Counter | mutual permission flags | any operator's work, a guard's presence, a second pair of hands on a truck |

### What a player could do with only the starter set
- HAULING (a combination the content never spells out). A player soaks a crystal at the top of the pass and pins cold to a wooden crate. Nothing in the game is called a fridge, but milk in that crate stops turning, so fresh milk can now reach anywhere. The same player finds the opposite: milk parked in the bog's rot 1 air becomes cheese on its own, which the Lodge and the Market both want. They end up running a cold crate one way and a bog cellar the other.
- KEEPING CREATURES (not spelled out; uses a helper). A player notices their lightning mattock makes Sparklings bigger instead of hurting them. They wall a few in with crates at the cavern mouth and strike them each visit for the shards they shed. Then they hand an iron mattock to a Wired helper: the conducting iron passes Spark back up the handle, which hurts a Hearthfolk player and feeds a Wired one. The helper now tends the pen and never needs a crystal.
- RUNNING A SERVICE. A player bolts an Oven and a Counter to a truck bed and parks at the cavern mouth, where bodies arrive cold, drained or hurt. Warm cake for Hearthfolk miners, Spark cake for Wired haulers, rot cake for Risen travellers. The wrong cake sickens the customer, so the job is reading who is in front of you. The bandits get fed too, and after a few visits they wave the truck through.
- ALCHEMY AND CRAFT (not spelled out). The Transmuter keeps the Form, so a player stops transmuting lumps. They shape cheap, heavy lead into mattocks and crates first, then turn the finished goods to gold. A gold mattock cuts badly but takes a level 3 pin. They also learn to leave some crates as lead on purpose, because a lead crate shields its contents and delivers cakes through the pass still warm. One object, two right answers.
- SETTLING AND FARMING. A player takes a bog plot and never leaves it. Bogweave coat; Shagbacks for milk and fur; remains into the vat; mulch onto grain; grain back to the herd. A Risen gardener is paid in the plot's own leftovers. Cheese and fur coats go out and almost no coin comes in, because nothing they need is bought.
- PROTECTING (needs another player). One player drives a full truck down the pass. A stranger whose Counter offers 'ride-along guard' sits on the tailgate in a fur coat with a cold mattock for Sparklings, and the bandits let a guarded truck by. No chat is used: the offer and the price are icons on the Counter, and the guard is paid in crystals at the bottom.

### First minute
- 0-5 s: No menu and no class pick. You spawn on your own small camp at the crossroads in your own avatar, already holding a crackling crystal. Three things within ten steps pulse with the same spark icon: a silent mill with a sack of grain on it, a slumped tin traveller at your gate, and a wooden mattock lying on a flat stone with dust on it. One line of hint text: 'Put the crystal into something.'
- 5-20 s: One big Put button. Whichever you walk to, something happens at once. The mill whirs and pours flour. The traveller sparks, stands up and follows you as your first helper. The mattock takes the lightning for good.
- 20-35 s: The crystal in your hands is now empty and the other two things are still pulsing. You have seen one object mean three things and you could only pick one. A signpost shows where a crystal fills again: up the pass, with a snowflake and a spark.
- 35-50 s: Your handcart beside you holds two warm loaves that are visibly cooling, six grain and nothing else. An untamed Shagback grazes at your fence. The Oven, Workbench and Binding Stone are already on the plot. Each first choice leads to a different second action: flour to the Oven, the helper to the mill crank, the mattock to the tree by the gate (or to the slumped traveller, who twitches when struck).
- 50-60 s: A traveller of another people walks up to your gate with a hunger icon. Hand over a loaf and they pay coin plus a crystal soaked in cold from a place you have not been.
- After the minute: three roads (pass, bog, market) with ambient dial icons on the signposts, a cart that is yours, two unfilled spark icons at home, and no next instruction. The entrance was one use of the rule shown in three contexts. It was not the first rung of an activity.

### Three players at hour ten
THE COLD-CHAIN COOK lives on a truck and owns no plot. Oven, Counter and a cold-pinned crate are bolted to the bed. She follows need: warm cake to the pass, cheese from the bog to the market, Spark cake to the Depot when its crystal stock is low. The bandits are her friends because she feeds them. She got here because her first choice was the mill and her first sale was a loaf.

THE BOG RANCHER has a plot in the hollow with eight Shagbacks, a vat and two Risen gardeners. The loop is nearly closed and runs mostly without him. His hours go on breeding, on fur coats for the market, and on deciding whether a pass-mouth plot for cold grain is worth the bandits. He got here because he tamed the Shagback at the fence and followed the remains to the Lodge.

THE TINKERER holds a pass-mouth plot with a Transmuter, a Sparkling pen and three Wired helpers who feed themselves off iron mattocks. She makes gold forms and pins dials to them to order, sold from a Counter. Her current project is finding out what a rot-pinned gold coat does for a Risen guard. She got here because she chose the mattock.

Why they differ: three different places with different free ambient, helpers of different peoples with different upkeep, and capabilities earned from three different towns whose needs point in different directions. None of the three is ahead of the others on any shared number.

### Why it is not one ladder
The rule that prevents it is the pairing of two things. First, nothing has a rank: a thing's worth is read against a body's row, a place's ambient and a town's unfilled need, so the same cake is medicine, lunch or poison. Second, capabilities cannot be bought with coin: they cost standing, standing comes only from filling a town's needs, and every town's needs are written as property queries that point at a different zone or a different people's output. To get the next capability you have to go sideways into another context. Doing more of what you already do makes more coin, and coin only buys commodities.

Tiers are used plainly where they belong, and they stay plain.
- Tools: wood, iron, crystal by hardness against node hardness.
- Carriers: handcart, then truck.
- Dial levels: 1 to 3.
The cheap tier stays worth having through one odd tag each, not through invented extra uses. A wooden mattock is free, burns as emergency fuel and does not conduct, so it is the safe tool on a charged node. The handcart needs no fuel and bandits ignore it. Lead is the worst metal, and it shields. The top tier costs something to keep: crystal tools shatter, the truck burns fuel and draws bandits, a level 3 pin needs gold. An iron mattock is simply better than a wooden one at cutting, and a loaf is just food. Not everything has a second use.

How it could still collapse:
1. If one need pays best and saturation is too gentle, the game becomes "haul crystals to the Depot". That is the old failure with a truck in it.
2. If dials are used only as locks (cold zone needs coat, then the next zone needs the next coat), the web is a ladder of keys.
3. If the useful pins and cakes turn out to be four or five, a best-in-slot list appears and experiment stops.
4. If helpers automate everything and no one consumes the output, there is nothing left to want.
5. The gold loop (lead + Spark to gold to coin) is the most obvious attractor. It only stays healthy if gold demand saturates everywhere and gold's real value stays as a Stuff.

With three towns the first build's web is small and can be exhausted in a few hours. It tests whether players diverge. It does not test whether the game lasts.

### Technical model
DATA. Shared ModuleScripts: Stuffs, Forms, Stations (each a list of process records), Bodies (rows), Places (ambient zones as tagged volumes), Towns (needs and offers). A query is a small predicate table, for example {class = "rigid", hardMin = 2} or {holds = true, sparkMin = 2}. Adding content is adding rows.

THING RECORD (the server-side truth): id, form, stuff, three integer dials each with a last-changed timestamp, pin, wear, count, location (a container id and slot, or a world position).
- Drift is never ticked. It is worked out on read from the timestamp and the current target.
- Dials are integers, so identical things in a container stack into one record.
- Dials stop while the owner is offline.

PHYSICAL VERSUS DATA. A thing has a model only near a player, in one of four states.
- At rest: anchored and server-owned.
- Carried: welded to the character, so there are no loose network-owned parts.
- In transit: welded into a carrier slot, so a loaded truck is one assembly.
- In bulk: a count with a fill-level mesh.
Budgets to prove on a 2-4 GB phone:
- about 40 moving assemblies in view
- a per-plot cap on loose resting things (start at 60), with the rest forced into crates
- open-world loose things fade after 120 s
Server Authority is not used in the first build: its reliability on phones is unproven, and welding carried things removes most of the need.

SAVING. One session-locked profile per player, written with UpdateAsync, autosaved every 180 s and on leave and server close. It holds owned containers and their records, stations, helpers and their assignments, standing, and the almanac.
- A plot with 2,000 stacks should be on the order of 100 KB, well under the 4 MB key limit. That is an estimate to measure.
- No interaction with a player's containers until their load completes.
- A plot is destroyed on leave even if its save fails.

SERVERS. 8 players. Plots load with the player, as in Lumber Tycoon 2. Towns, guests, bandits and helpers are all NPC processes, so the web works with one player in the server. Helpers and guests are server data agents drawn as simple rigs on nearby clients. Town stock is per server at first, later a shared number with a data store snapshot behind it.

EXPLOITS. Every pick-up, put, trade and process is one server transaction on records, checked for distance and ownership; the models follow. That closes the double-fire and weld-state dupes other games suffered. The driver owns the truck's physics; the server checks speed and position before any hand-in.

COSTLIEST PARTS, in order.
1. Phone handling of real objects (carry, slot, load a truck) feeling good within the moving-object budget.
2. The transaction and save layer around containers.
3. Making three dials and five-column rows readable at a glance. This is design and UI work more than code, and the whole rule fails without it.

### Test
Run four to six testers on phones for about an hour each, with no instructions, and log every process each one runs, in order.

SIGNS THE RULE IS BLOSSOMING
- By minute 40 the testers' process logs have diverged: different stations, zones and towns, not the same sequence at different speeds.
- At least one tester makes or does something that appears in no hint and in none of my six stories. Count unlisted Form x Stuff x pin combinations and unlisted uses, such as storing something somewhere for its ambient.
- Testers open the inspect card unprompted and say a prediction out loud before trying it ("this should keep it cold").
- Someone hands a job to the helper and goes off to do a different job.
- Someone notices without being told that the same dial did opposite things to two bodies.
- Someone parks, stores or settles outside the meadow by choice.

SIGNS IT IS NOT
- Everyone converges on cavern to Depot and repeats it.
- Nobody uses the Binding Stone or bakes a dial into a cake after the first minute.
- Testers use the helper only to do their own job faster.
- "What am I supposed to do?" is asked after minute five, and the tester then waits instead of poking at something.
- The almanac is never opened.
- Dial effects happen and nobody notices: a helper gets recharged, milk turns to cheese, and the tester cannot say why.

FIRST-MINUTE FUNNEL, measured separately
- share who place the crystal within 30 s
- share who run a second, different process within 5 minutes
- share still present at 60 s

If the logs converge, the fix is in the towns' needs and saturation, not in adding content. If the effects go unnoticed, the fix is the icon language. If both fail with the icon language working, the property set is wrong and should be rethought before anything else is built.

### First build
- The rule engine: thing records as Form x Stuff with three dials; drift worked out lazily from timestamps; the pin; body rows; process records with property queries and one operator slot. All content is plain data tables.
- One grey-box map of three zones about a minute's walk apart: Meadow (neutral), Frost Pass (Heat -2) with the crystal cavern (Spark 3) inside it, and Bog Hollow (Life -1).
- Phone handling: Pick up, Put and Use buttons aimed by proximity; things welded to hands, cart slots and station slots; crates as counts with a fill level. Handcart and truck.
- The inspect card and the shared icon language on things, station slots, town gates and bodies. This is as much a part of the rule as the dials.
- Seven stuffs (wood, iron, lead, crystal, fur, grain, milk, with remains as what they turn into) and four forms (mattock, coat, crate, cake).
- Five stations on the starting plot (Workbench, Oven, Mill, Binding Stone, Counter) and two earned ones (Transmuter, Compost Vat).
- Bodies: the player on the Hearthfolk row, the Shagback, the Sparkling, travellers of three peoples, one Wired helper type.
- Three towns with two needs and two offers each, with per-server stock that saturates and recovers. The pass bandits as one chokepoint with toll, guard or standing.
- Basic session-locked save of owned containers, standing and the almanac, plus a log of every process each player runs, in order.

### Left out of the first build
- Changing the player's own people by ritual, and the avatar add-ons that show it
- Offline production from timestamps (the first playtest is single-session)
- Shared town stock across servers, and the cross-server consignment board
- Regions as separate places; trains, ships and biplanes
- A fourth dial (wet/dry), the fifth people and the other regions' rows
- Town states that shift their need lists (overheating, feasts, sieges)
- Risen and Hearthfolk helper types; mounts; creature breeding
- Plot deeds in more than one zone (the first build gives one plot at the crossroads and uses the truck as the movable home)
- Monetisation, private servers, invite rewards
- Final art: everything runs on grey boxes and default avatars

### Risks
- Opacity: three dials times body rows times places could read as noise on a phone (the Dwarf Fortress failure). If players cannot predict what a dial will do before they try it, emergence turns into confusion.
- Dials used as locks: content authors (including me) will be tempted to gate zones behind the right coat, which rebuilds a ladder out of keys.
- One best route: crystals hold their dial and never spoil, so crystals to the Depot is the natural money line. Saturation, bandits and cold have to be tuned so it is a good first chain and a poor only chain.
- Free-energy holes: any path that lets a pinned thing act as an endless source (charging crystals or helpers for nothing) collapses upkeep. 'Only places are free sources' must be one choke point in code, and every new station is a chance to break it. The self-feeding Wired miner is deliberate and bounded by mattock wear; others will not be.
- Phone handling: carrying and loading real objects is the fragile part of every comparable Roblox game, and none of the budget figures is from Roblox itself.
- Lonely servers: with one or two players the friend-and-stranger half of the web rarely fires. Helpers, guests and towns must carry it, or the world feels like a single-player crafting game.
- The player is always Hearthfolk in the first build, so 'the same thing means different things' is felt only through helpers, creatures and guests. That may be too indirect to prove the context rule.
- The three-way first choice could stall a new phone player for the very seconds the ranking punishes. It needs a funnel measurement and possibly a nudge after ten idle seconds.
- Scope: six interacting systems for one programmer. The engine is small, but the icon language, save layer and handling are not.
- Spoilage and wear can feel like punishment in short sessions. Dials are frozen offline for that reason; the played-time rates still need tuning.
- Mild rating: bandits take cargo and do not kill; a hurt player wakes at their camp; remains are cartoon bones and compost; no alcohol in the curing chain. Each new people and region needs the same check.
- Familiar parts: dial chemistry resembles Breath of the Wild's elements and Form x Stuff resembles RimWorld. Neither is a Roblox near-copy, but the game's identity will have to come from the world and the peoples.


---

## Want-and-offer web: properties, stances and hunger (17/30)

### Summary
Everything in the world that can act (a crop, a goat, a stove, a traveller, a whole people, a pirate crew, another player's stall) is the same kind of object underneath: it wants some things and gives others back. Wants are never for a named item; they are for a property ("anything warm", "any remains", "being guarded tonight"), so any object carrying that property will do, and a new object works with every old wanter for free. How much a wanter gives depends on three things that are all data: how strong the property is, how hungry the wanter is right now (hunger falls when fed and climbs back over time, and for peoples it is a number shared across all servers), and the wanter's kind, because each kind has a short table saying which properties it craves, likes, ignores or is hurt by. That one table is why lightning knocks out a bog creature and speeds up a tin helper, and why a frozen hollow is free land for one people and dangerous for another. What comes back is as often a capability as a good: a tool, a machine, a creature, a helper, a service. Capabilities are only offered by the people who make them, in return for standing earned by feeding that people's own wants, so there is no single currency to climb. The player finds direction by looking: every wanter shows an icon bubble of what it wants and how badly, and holding any object up lights the bubbles of everyone nearby who wants it. Nothing here has been prototyped; all numbers are starting values to tune.

### What a thing is
A thing is a server record with a serial number: form (loaf, hatchet, crystal, coat, cart), optional material (flint/iron/steel; frost/storm crystal; lurker/goat hide), a size class, and a small bag of properties with levels 1-3.

Property vocabulary, about 20 in total, each with one icon:
- Aspects, which can sit on things, places and beings: warm, cold, wet, charged, rot.
- Substances: hearty, sweet, fibre, hide, metal, crystal, remains, rich (fertiliser), fuel, shiny.
- Functions: edge, spark, mend, carry (slots).
- States on beings and places only: fed, rested, hurt, guarded.

Form x material gives stats without new definitions: a steel hatchet is the hatchet form with steel's numbers; a lurker-hide coat is the coat form plus the lurker's ward.

Size decides how it moves, on four fidelity tiers (per the physical-goods brief):
- Pocket: goes into a counted satchel (8 slots), shown as a bulging bag.
- Armful: carried one at a time, welded to the avatar's hands and visible.
- Load: needs a carrier (handcart, pack animal, later truck, train, ship) or two players.
- Fixture: placed once on a plot or cart (stove, cot, loom).

Everything at rest sits in a slot: shelves, counters, crates, cart beds, animal panniers and plot floors all have slots that things snap to and anchor in. There is no free physics dragging in the first build. A dropped thing tumbles for two seconds, anchors, and despawns after 120 seconds unless it is on its owner's plot. Bulk becomes a count inside a crate that shows its top item and fill level.

Some things carry clocks: fresh food spoils, a lit ember fades, a storm crystal's charge is used up. Tools have wear. One binding slot per tool, weapon or wearable holds an aspect.

Phone verbs are five context buttons aimed by proximity: Give, Take, Stow, Drop/Place, Use.

### What a transformer is
There is one transformer type, the actor, and one event, the handover.

An actor has:
- a kind (its stance table),
- a place (which has aspects),
- wants: each is a property or a state, with a hunger from 0 to 3 that falls when fed and recovers at its own rate,
- offers: each is a thing, a state or a capability, with a cost in pips, a required standing, and a stock,
- optional conditions and a time.

The handover: a thing (or a performed state) meets a want. Satisfaction = property level x hunger x stance multiplier, shown as 1-5 pips on the bubble before you confirm. The actor then pays from its offers.

One model covers every case:
- Crop: wants wet and optionally rich; condition: place not cold; time 8 minutes, computed from timestamps so it runs offline; offers produce.
- Animal: wants fibre or hearty; offers milk and wool on a timer; fed three times it follows you.
- Resource node: "wants" to be struck by edge of a given level; offers logs, lead, crystals.
- Machine: wants inputs by property (the oven takes anything with grain plus anything with fuel plus an optional extra); time; offers an output.
- Ritual: a machine whose condition is a place aspect or a weather event (the storm rock).
- Guest: wants states (fed, rested, warm, mended); offers coin, a rumour, standing with their people.
- People or faction: several wants with shared hunger; a shelf of offers.
- Threat: a want that it takes by force unless it is paid or the target is guarded.
- Another player's stall: wants and offers the player set.

Four chemistry rules sit on top, in the spirit of Zelda's short list:
1. Warm and cold cancel level for level.
2. An output inherits the strongest aspect among its inputs, one level lower (a cold-2 crystal baked into a cake gives a cold-1 cake).
3. Cold pauses spoiling, warm doubles it, and rot in the place turns fresh things into rot goods (milk to cheese, remains to fertiliser).
4. A being responds to a property only through its kind's stance, never to a named item.

### Capabilities
A capability is a thing or a being in the same system, so it can be carried, placed, given, lent, or put on a stall.

- Machine: a fixture thing that is itself an actor once placed (stove, loom, cheese shelf, binding bench, transmuter). You receive it as a crate from the people who make it and carry it home.
- Recipe: there is no recipe list. A machine's wants are its recipes, written in properties, so the "recipe" for a warming cake is knowing the inheritance rule plus owning an oven. What a people can teach is a new want on a machine you own (the Meadowfolk add "plus sweet and milk gives cake" to your oven), delivered as a stamped plate you slot into the machine.
- Helper: a being with a kind, a wage want and one routine. Tamed creatures and hired hands are the same object; taming is simply satisfying a wild creature's want three times.
- Service: an offer whose output is a state (see who_does_it). Buying one from a people (ferry passage, bone-setting, escort) is the same handover as buying a loaf.
- Enchantment: binding puts a crystal's aspect into an item's single slot. The item then carries that property, and everything that reads properties (wants, stances, the chemistry rules) reacts with no further code.
- Kinship (after the first build): a people's top offer is a rite that rewrites part of your own stance table, with a trade-off. This is how a player becomes one of the designer's "xenotypes" without a blind choice in the first minute.

Re-entry as inputs: a stove is wanted by the Harbourfolk (warm 3) as well as used by you; a helper is wage-hungry, so it creates a standing want you must feed; a bound hatchet is a weapon, a buff for tin helpers and a way to charge a transmuter; gold from the transmuter is the river crew's craving.

Tiers are used plainly where they belong (see why_not_a_ladder).

### Context
Three pieces of data, none of them pairwise.

1. Stance tables. Each kind lists a response to each property: crave (x3 and needed), like (x1.5), ignore (x0), harmed (negative: staggers, adds hurt, or refuses the gift). Starter kinds:
- Outlander (every new player): likes hearty, sweet and warm; harmed by cold above 1, by charged, and by eating rot.
- Harbourfolk: crave warm; like hearty and metal; ignore cold; harmed by rot.
- Bayou kin (undead): crave remains; like rot and sweet; ignore cold; harmed by charged and strong warm.
- Meadowfolk: crave rich; like fibre and edge tools; crave guarded at night; harmed by cold.
- Tin-folk: crave charged (it speeds them up); like crystal; ignore hearty and cold; harmed by wet.
- River crew: crave shiny; like sweet and hearty.
- Shag goat: likes fibre and hearty; harmed by cold.
- Bog lurker: likes rot (it heals them); harmed double by charged; driven off by warm; slowed by cold.
A new kind is one row. A new property is one column with a default of ignore.

2. Place aspects. A place carries aspects the same way a thing does (the Hollow is cold 3, the bog is wet 1 and rot 1, the storm rock is charged 2 during storms). A being standing there is "handed" the aspect every few seconds and its stance decides the result. Gear and food shift the sum: a warm-2 coat in a cold-3 place leaves cold 1, which an Outlander shrugs off. So the frozen waste is trivial for one people and hostile to another from two numbers.

3. Hunger and time. A want's hunger depends on what that actor has been fed lately, everywhere. Day and night, weather (storm, cold snap), the tinker's timetable and skirmishes push hungers and place aspects up and down on clocks derived from UTC time, so every server agrees.

The designer's lightning example is then just: charged-2 hatchet meets lurker (harmed x2) or meets tin helper (crave).

### Who does it
Every handover has a hand: whoever carries the thing to the want. The resolver does not care whose hand it is.

- The player: walks up, taps Give.
- A helper: a being that repeats one demonstrated handover. With the helper following, you do the handover once from a source slot to an actor or slot, then tap "Yours now"; it loops that as long as its wage want is fed and the source has stock. On your plot or cart the walking is real. Off-plot trips are shown leaving and returning with the cart and are resolved after the trip time by the same resolver, including the toll check on the route, so a helper's cargo can be taken exactly as yours can. Helpers have kinds, so a bone hand works the cold Hollow for free and stalls in a storm, while a tin hand is the reverse.
- A friend: Give works on players, and a plot toggle lets friends use your slots. Gratitude goes to the hand, and the returned thing can be handed straight on. Load-size things can be carried by two players without a cart, which is the one place a second player is physically stronger than a helper.

A service in the model is an offer whose output is a state on the receiver instead of a thing: fed, rested, warm, mended, guarded, carried (moved from A to B), bound. It is produced at a place over a short time by a furnishing or a being: a cot gives rested, a lit stove gives warm, a tonic or bone-setter gives mended, a posted guard or a paid crew gives guarded. Because wants can be for states, anyone holding the right furnishings is a tavern; the same furnishings on a cart are a travelling hospital; and a player standing night watch on a meadow field is selling protection. Buying protection is the mirror: you feed the river crew's want and their offer is guarded-2 on your next crossing.

### Exchange
With the world: you hand a thing to an actor, pips appear, and you take things off its shelf (physical items, each showing a pip cost). Leftover pips come back as coin. Lifetime pips with a people are your standing with it, which opens the back rows of its shelf.

Coin is an ordinary thing (purse-stacked, shiny 1). Every people has a weak want for it that sates quickly, so it buys front-row goods and small services and nothing else.

Capabilities (machines, helpers, recipe plates, escorts, rites) are never sold for coin. They need standing with the people who make them, and standing only comes from feeding that people's wants.

With players:
- Give is free-form.
- A trade blanket has two rows of slots; both sides confirm; the server swaps atomically by serial number.
- A stall sign turns a player into an actor: you set one want (a property icon) and one offer from your shelf, and it deals with players and passing travellers while you are in the server.

Value is never stored on the thing. It is computed at the handover from level x hunger x stance, so the same cheese is 5 pips to a hungry Bayou envoy, 2 to a sailor, and refused by a tin hand.

What stops one best route:
- Sating: each delivery lowers that want's hunger. For peoples the hunger is a shared number, so a route everyone runs pays everyone less, and the people's next-hungriest want becomes the better deal.
- Stock: shelf offers deplete and restock on a clock.
- Spoilage, size and distance: milk will not survive the walk unless packed cold; load-size goods need a carrier.
- Notice: the river crew only bothers carriers above handcart size or carrying shiny, so the best payload invites a toll.
- Moving demand: the tinker changes camp on a timetable; storms, cold snaps and skirmishes shift hungers.
- Rivalry: taking a side (paying the crew, guarding against them) nudges standing with the other side down.
- Several axes: three or four standings that cannot be converted into each other.

### Direction without tasks
The world's wants are visible, and that is the whole direction system. Nothing is issued, tracked or completed.

- Want bubbles. Any actor with a hungry want shows a small icon bubble (flame, bone, wheat, shield) with a ring for urgency. Crops, animals, machines, guests and envoys all use the same bubble.
- Hold-to-ask. Holding any thing lights the bubbles of every nearby actor that wants it and shows the pips it would give. "I have this odd crystal; who wants it?" is answered by looking around. An actor that refuses it shows a crossed bubble, which teaches stances.
- Shelves. What a people offers is physically on its shelf, back rows visible but roped off. Tapping a roped item makes that people's want bubbles pulse. Wanting the thing on the shelf is the goal; the player sets it.
- Far signs. Each people's state shows on its buildings: thin chimney smoke when the Harbourfolk are short of warmth, dim lanterns when the Bayou kin lack remains, wilted fields when the Meadowfolk lack fertiliser. Storm clouds gather over the rock a minute before a storm. The tinker's wagon lantern is visible from the crossroads.
- Rumours. A served traveller leaves a rumour: a picture of a place and a property. It is added as a page in the almanac, a book of facts you have seen (who wants what, which kind is hurt by what, where things grow). The almanac has no checkboxes.
- Your own stuff. A goat with a wheat bubble, a helper with a wage bubble, an oven showing an empty fuel slot and a spoiling jug are the nearest wants, and they are yours.

A player with no goal therefore sees, at any moment: what is in their hand and who lights up for it; the hungriest bubble in sight; a shelf item they cannot yet have; and a far sign of somewhere in need.

### Starter things
| Thing | Properties |
|---|---|
| Bread loaf | pocket; hearty 2; warm 1 for 5 min after baking; spoils in a day |
| Cake | pocket; hearty 1, sweet 2; carries one inherited aspect from its extra ingredient at one level lower (frost cake cold 1, storm cake charged 1); eating it gives that aspect to the eater for 5 min |
| Grain sheaf | armful; grain (hearty 1 raw), fibre 1 |
| Reed bundle | armful; fibre 1, fuel 1; cut anywhere wet with any edge |
| Log | armful; wood, fuel 2; needs edge 1 to cut |
| Water pail | armful; wet 2; refilled free at any well or river |
| Milk jug | pocket; hearty 1; spoils in 4 min, paused by cold; turns to cheese where rot is present |
| Cheese | pocket; hearty 2, rot 1; never spoils |
| Honey pot | pocket; sweet 2 |
| Fleece | armful; fibre 2, warm 1 |
| Bones | armful; remains 2, rot 1; left by knocked-out lurkers and by skirmish wreckage |
| Fertiliser sack | armful; rich 2, rot 1 |
| Lurker pelt | armful; hide 2; ward: wet and rot (anything stitched from it lets the wearer ignore those) |
| Crystal (frost or storm) | pocket; crystal 2 plus cold 2 (frost, from the Hollow cave) or charged 2 (storm, a frost crystal that has sat on the rock in a storm); cold fades next to warm; charge is used up by use |
| Lead lump | load; metal 1; dug from the bog bank with edge 2 |
| Gold nugget | pocket; metal 1, shiny 3 |
| Coin | purse-stacked; shiny 1; weakly wanted by every people |
| Hatchet (flint, iron or steel) | armful, held; flint: edge 1, spark 1, about 30 uses, made anywhere, not metal; iron: edge 2, metal, long wear; steel: edge 3, metal, needs mending at the harbour to keep its edge; one binding slot |
| Coat | wearable; warm equal to the average of the three fibre or hide pieces used; inherits any ward; fits any being with a body; one binding slot |
| Tonic | pocket; mend 2, rot 1 (helps the living, and Bayou kin simply like it) |
| Handcart | carrier; 6 slots; pushed on foot; fits footpaths and the cave; below the river crew's notice unless it carries shiny |
| Goat cart | carrier; 12 slots; pulled by a tamed goat; road only; noticed by the river crew |
| Cot | fixture; gives rested to any being that lies on it for 60 s |
| Scarecrow | fixture; guarded 1 against crows and lurkers within its field |

### Starter processes
| Process | Takes | Needs | Gives |
|---|---|---|---|
| Wheat plot (crop) | wet 1 or more; optionally rich | place not cold after gear and stoves are counted; 8 min, runs offline from timestamps | 2 grain sheaves (4 if rich); produce carries any aspect it was watered or fed with, one level lower |
| Shag goat (animal, tameable) | fibre or hearty | not left in cold (a coat counts) | milk every 5 min while fed; fleece when sheared with any edge; after three feedings it follows you, carries 2 armfuls and can pull a goat cart |
| Resource node (reeds, tree, bog bank, cave vein) | a strike from edge at or above its level (reeds 1, tree 1, bog bank 2, cave vein 2) | cave vein is in a cold-3 place | reed bundles, logs, lead lumps, frost crystals; regrows on a clock |
| Oven / stove (machine) | anything with grain, plus anything with fuel, plus one optional extra | lit by spark or a warm thing; 60 s | bread; with the cake plate fitted and sweet plus milk as extras, a cake inheriting the extra's aspect. While lit it gives warm 2 to everything within 20 studs |
| Cheese shelf (machine) | milk | rot 1 in the place or a rot thing on the same shelf; 10 min | cheese |
| Stitching frame (machine) | any three pieces of fibre or hide | nothing | a coat with averaged warm and any inherited ward |
| Binding bench (machine, also the tinker's service) | any tool, weapon or wearable, plus any crystal | nothing | the same item carrying the crystal's aspect in its slot, replacing any earlier one |
| Transmuter (machine) | a lead lump | charged 2 present: a storm crystal in its socket (10 uses), a tin hand beside it, or a storm overhead | a gold nugget |
| Storm rock (place and weather) | anything metal or crystal held or parked on the rock during a storm | storm, about one in six day-cycles, clouds gather a minute before | charged 2 on the thing; charged applied to whoever is holding it (Outlander staggers and gains hurt 1; tin-folk are sped up) |
| Harbourfolk envoy (people) | warm (fuel, hot bread, coats, a stove), metal, hearty | shared hunger; shelf back rows need standing | coin, rope, iron hatchet; standing 2: stove, handcart, ferry passage; standing 3: steel hatchet and its mending |
| Bayou kin envoy (people) | remains, rot goods (cheese, tonic), sweet | shared hunger; shelf back rows need standing | fertiliser sack, tonic, bone-setting (removes hurt); standing 2: cheese shelf, a bone hand; standing 3: a compost heap of your own (remains to fertiliser) |
| Meadowfolk envoy (people) | rich, fleece and coats, edge tools, and guarded on their field through a night | shared hunger; shelf back rows need standing | wheat seed, honey, bread; standing 2: goat cart, stitching frame, scarecrow, cake plate; standing 3: a field lease beside theirs |
| Tinker (nomad wagon) | any crystal, anything charged, gold | camps at the crossroads, the bog edge or the Hollow mouth on a fixed UTC timetable | binding as a service; standing 2: binding bench; standing 3: transmuter, a tin hand |
| River crew at the bridge (threat and people) | shiny, sweet, hearty. From any carrier above handcart size, or any carrying shiny, that crosses unpaid with guarded below 2, they take a third of the load | their take goes into a stock number shared across servers | passage; standing 2: escort (guarded 2 for one crossing, yours or your helper's) and a shelf of whatever has been taken lately |
| Bog lurker (threat creature) | drawn at night to fresh food, crops and milk; likes rot | stays away from warm 2; charged harms it double; cold slows it | knocked out: bones and a lurker pelt. Fed rot three times: it follows you like any tamed creature and counts as guarded 1 |
| Traveller (guest, any kind) | states: fed, rested, warm, mended, each from your furnishings or goods; which ones and how much depend on kind | stops only where it can see a free cot or a lit stove; arrives hurt after a skirmish | coin, a little standing with its people, a rumour page, sometimes a thing from home |
| Bone hand / tin hand (helper) | wage once a day-cycle: remains (bone hand) or charged (tin hand) | shown one handover and given a post | repeats that handover; a guard post gives guarded 1. Tin hands work at double speed while charged |
| Flint knapping (by hand) | a river stone | nothing, anywhere | a flint hatchet |

### What a player could do with only the starter set
- Cold chain (hauling and engineering, never spelled out). Milk spoils in four minutes and the harbour envoy is a longer walk than that. A player notices frost crystals pause spoiling, packs jugs in a handcart around two crystals and arrives with fresh milk. Then they notice the lit stove on the same cart killed the crystals' cold on the way, and have to choose between hot bread and cold milk per trip, or build two carts.
- A goat in a coat (animals plus place, never spelled out). The Hollow is cold 3 and nobody farms it. A coat fits any being with a body, so a player stitches one from fleece and a pelt and puts it on the goat, lights a stove beside a wheat plot to cancel the cold, and ends up with a homestead where lurkers will not come (they avoid warm) and the frost cave is at the door. Nothing in the content says goats wear coats or stoves protect crops; both fall out of the stance and cancel rules.
- Storm charging (exploring and fighting). Storm crystals cost a climb and a hurt. A player parks an iron handcart of frost crystals on the rock as clouds gather and stands back with a flint hatchet, which is not metal. They bind one crystal into an iron hatchet, drop lurkers in two hits for bones, and find that tapping their own tin hand with the same hatchet makes it work double time.
- Roadside ward at the bridge (service, needs other players or the world's rivalry). Skirmishes between the river crew and harbour patrols leave hurt, cold travellers on the road. One player parks a cart with a cot, a stove and tonics and treats whoever comes, earning coin, rumours and standing with three peoples at once. A second player in the server hires out as escort across the same bridge, which cuts the first player's patients; the two can split the road, or the first can pay the crew in cheese to keep things lively.
- Tamed lurker (creatures and protection, never spelled out). Lurkers like rot, and anything fed three times follows you. A cheese-maker feeds one instead of fighting it and gets a pack-beast that ignores the bog and counts as a guard. Posted on the Meadowfolk's field at night it satisfies their guarded want, so the player earns meadow standing with a monster the Bayou kin taught them to feed.
- Gold for safe passage (delegation and diplomacy, with a helper or a friend). A player with a transmuter makes gold from bog lead. Gold is what the river crew craves and also what makes them stop a cart. The player pays the crew a nugget for an escort, shows a bone hand the lead run once, and lets it loop under escort while a friend carries the gold across by handcart on the footpath, where the crew does not look.

### First minute
- 0-5 s: no menu, no kind picker, no text. You ride into a crossroads on the tailboard of a peddler's cart, already holding a basket of three steaming loaves. This is the axe: one object, already in your hands.
- 5-12 s: the cart stops and you hop down. Because you are holding bread, three bubbles within fifteen studs light up with pips: a shivering harbour sailor (flame, 3 pips), a shag goat (wheat, 2 pips), a tired traveller on a bench (plate, 2 pips). A fourth, the skeleton envoy, shows a bone icon crossed out: he does not want bread. One large Give button appears when you are close to any of them.
- 12-25 s: first Give, to whichever you walked to. The return is a different kind of thing in each case: the sailor hands over an iron hatchet (a tool); the goat starts following you with empty panniers (a creature and carrying room); the traveller gives coins and a rumour, which opens the almanac at a picture of the blue cave up the road (knowledge).
- 25-45 s: what you now hold lights new bubbles. With the hatchet, reeds and a tree by the road show strike marks, and the sailor's bubble changes to a fuel icon. With the goat, its own bubble returns asking for fibre. Two loaves remain, so most players try the other two takers, or eat one and see the warm state appear on themselves.
- 45-60 s: you are holding at least one thing that is not bread, and at least two actors visibly want something you could go and get: bones for the skeleton, fuel for the sailor, water for a potted seedling on the meadow stall. An unclaimed plot stake by the road shows an empty-slot outline.
- Why this opens onto the web and not a loop: the three first handovers lead to three different verbs (gather, tend, travel), the crossed-out bubble teaches that who you bring it to matters, and nothing given back is more bread. The bubbles used here are the same ones used at hour ten, so there is no tutorial layer to remove.

### Three players at hour ten
Player one lives in the Hollow. She chose it because nobody else can stand there: she wears a fleece-and-pelt coat, her plots sit inside a stove's warm ring, and her goat has its own coat. She sells frost crystals and cold-carrying bread, and keeps one tin hand, which ignores the cold, hauling fuel. Her worry is the fuel pile during a cold snap. Her standing is highest with the Harbourfolk and the tinker.

Player two has no plot. He lives on a goat cart with a cot, a stove and a binding bench, follows the tinker's timetable and skirmish rumours, and sells rest, hot food, mending and binding to travellers and to other players through a stall sign. He pays the river crew in cheese, so the bridge is always open to him. His standing is spread thinly across everyone, and he owns almost no machines.

Player three is the Bayou kin's supplier. She hunts lurkers with a storm-bound hatchet, keeps two tamed lurkers on guard at the Meadowfolk's field, runs a cheese shelf in the bog's rot, and has just earned her own compost heap, which makes her the meadow's fertiliser source and a rival to the envoy who taught her. A bone hand runs her bones-to-compost handover.

They differ for structural reasons, not taste alone. Capabilities come only from the people who make them, so three different standings mean three different tool sets. Place aspects make each spot cheap for one set of gear and costly for another. Shared hunger means that when one of them leans on a route, it pays the others less.

### Why it is not one ladder
The specific rule: capabilities are never sold for a universal currency. Each is offered only by the people who make it, against standing earned by feeding that people's wants, and those wants are written in different properties and sate. Coin exists but buys only front-shelf goods. So "what next" cannot be "the same verb, bigger number": repeating a delivery is the worst-paying choice available (its hunger has just dropped, for you and for everyone), and the thing you covet on another shelf needs a different property from a different place.

Two supporting rules:
- Wants are properties, so every new thing has several takers and every taker has several sources.
- Outputs inherit aspects, so making something is a choice about context, not about tier.

Tiers are used plainly and on purpose:
- Hatchets: flint, iron, steel. Flint stays worth having: free anywhere, strikes sparks to light a fire with no stove, and is not metal, so it is safe to hold in a storm. Steel is simply better and needs harbour mending to stay that way.
- Carriers: hands, handcart, goat cart, later truck. The handcart fits footpaths and the cave and is beneath the river crew's notice.
- Heat: campfire, stove, later kiln.
- Standing: three shelf rows per people.

How it could still collapse, honestly:
1. Coin creep. If every want ends up paying mostly coin and coin buys most things, players convert everything to coin per minute and one route wins. The shelf rule must hold under pressure to "just add a price".
2. Standing as three ladders side by side. If each people's want is in practice met by one obvious good, standing becomes a delivery quest per faction. Each want needs at least three practical sources from different activities.
3. Sating tuned wrong. Too weak and there is a best loop; too strong and it reads as punishment for playing.
4. Bubbles as a quest list. The hungriest bubble in sight can be followed like an arrow. The difference from a quest is that nothing is issued or completed and the answer changes with what you hold, but a tired player may not feel that difference.
5. One aspect dominating (warm is useful almost everywhere in this set).

### Technical model
Definitions are Luau tables in shared modules:
- Things: form, size, properties, clocks, slots.
- Materials: stat multipliers and tags.
- Kinds: a stance per property.
- Actors: kind, wants with hunger rate, offers with pips, standing and stock, conditions, time.
- Places: aspects.
- Clocks: day, weather and the tinker's route as functions of UTC time, so servers agree without storage.
Adding a region or people is new rows, not new code.

One server module resolves every handover. It is a pure function of (actor state, payload, hand, place aspects, time), so it can be unit-tested and driven by bots.

Representation follows the physical-goods brief:
- The server record with a serial number is the truth; an instance exists only when streamed near a player.
- Held things are welded to the character. Slotted things are anchored. Carts are one assembly with welded loads.
- Dropped things simulate briefly, then anchor, and are capped at about 40 per server.
- Bulk is a count in a crate.
- No free dragging, no DragDetector, no Server Authority opt-in in the first build. Welded carry does not need it, and the brief records mobile reliability reports.
- NPCs are data on the server with simple rigs rendered near the viewer.

Saving: one session-locked profile per player (UpdateAsync, autosave, final save on leave and on close). It holds plot or cart slot contents, satchel, standings, almanac, helpers and their routines, and actor timestamps for offline growth. Interaction with a player's slots is blocked until their load completes. Loose things off-plot never save.

Shared across servers: a few hunger numbers per people and the river crew's loot stock. They live in a memory store with a data-store snapshot and a last-known fallback, with deltas pushed about once a minute. That is a handful of keys.

Servers of 8, Lumber Tycoon-style plots that load with the player.

Costliest parts, in order:
1. Phone feel of carry, give and slot.
2. Helper routines (real walking on-plot, resolved trips off-plot).
3. Tuning hunger so no loop dominates.
4. Save and trade integrity against duplication.
Part and instance budgets on low-end phones are unmeasured and must be prototyped first.

### Test
Run five to ten people on phones for 40 minutes each with no instructions, plus the bot harness overnight. Log every handover as (player, actor, property, pips, what was taken).

Signs the rule is blossoming:
- Divergence: by each tester's sixth handover the sequences differ between testers, and at 40 minutes testers hold different capabilities and have settled in different spots.
- Probing: testers hold things up to actors just to see the pips, including actors that are not shops (the goat, a crop, a lurker, their own helper).
- An unscripted combination appears without prompting: a coat on the goat, crystals packed with milk, a stove beside a plot, charging something on the rock, feeding a lurker.
- Fewer than about two in five handovers repeat that player's previous handover.
- When asked "what are you doing next?", testers answer with an object or a place they want, and the answers differ.
- Nobody asks what they are supposed to do after the third minute, or when they do, they answer it themselves by looking at bubbles.
- In the bot run, no single loop accounts for most of the pips earned once sating is on.

Signs it is not:
- Everyone runs bread-to-sailor until the pips drop, then stops or asks for a quest.
- Testers talk in coin per minute, or leave pips unspent because nothing on a shelf interests them.
- Stances go unnoticed: nobody remarks on the crossed bubble, and nobody uses cold, warm or charged on purpose.
- Things are only ever given to the two envoys.
- More than a fifth of testers have not completed a handover within 60 seconds, or cannot say what an icon means.
- The helper is ignored or is only used to repeat the best-paying delivery.
- Testers call the hungriest bubble "the quest".

### First build
- The resolver: one pure server function for the handover (property level x hunger x stance, then pay from offers), plus the four chemistry rules. It is unit-tested headlessly before any art exists.
- Phone handling: Give, Take, Stow, Place and Use buttons; satchel, armful and handcart slots; want bubbles with pip preview when a thing is held; the crossed bubble for a refusal.
- One small map on grey boxes: crossroads, a cold hollow with a crystal vein, a bog edge, a rock that storms hit, a bridge, and four plot stakes.
- Two peoples as envoy stalls with physical shelves and a hunger each: Harbourfolk (warm, hearty) and Bayou kin (remains, rot). Hunger is per server at first; the shared number comes after the rule is proven.
- One of each very different actor: a wheat plot, a shag goat, an oven/stove, a cheese shelf, a binding stone, a bog lurker, a traveller with a cot, a bone hand taught by showing once.
- About twelve things: bread, grain, reeds, log, water, milk, cheese, bones, fertiliser, frost/storm crystal, flint and iron hatchet, coat, handcart.
- Day/night and storm on a clock that the test harness can jump; bot players that perform random legal handovers and log every (actor, property, pips) so the web can be mapped and a dominant loop spotted before humans play.
- Session-locked save of plot slots, satchel, standing, helper routine and timestamps; loose things outside a plot are declared temporary.

### Left out of the first build
- The Meadowfolk, the tinker, the transmuter, the river crew's toll and escort, tin hands, the goat cart, the stitching frame's ward inheritance and the cake plate: all in the starter set, added one at a time once the two-people build shows divergence.
- Hunger shared across servers, player stall signs and the trade blanket.
- Other regions as separate places, and trucks, trains, ships and biplanes as higher carrier tiers.
- Kinship rites that change the player's own stance table, and avatar add-ons that show kind.
- Player-against-player raiding, theft from plots, vassalage and ruling a settlement.
- The dragon and other large protectors whose guarded offer covers a whole region.
- Monetisation, private servers, invite rewards and daily-return hooks.
- Final art, names and title. All names used here are working labels.

### Risks
- Nothing here has been built or tested. Every number (pips, hunger rates, timers, slot counts, the 40 loose-object cap) is a starting guess, and the only moving-object budget available comes from one 2024 community article.
- Icon load on a phone: about twenty property icons plus pips, rings and crossed bubbles may be unreadable at arm's length. The first build should ship with eight and add only what testers can name.
- Three takers in the first fifteen seconds may stall some new players. If more than a fifth have not made a handover by 60 seconds, the entrance should light one bubble first and the others a few seconds later.
- Hunger shared across servers means strangers can flatten a route you depend on. That is the intended anti-route pressure, but it may feel unfair when you cannot see who did it; the far signs must make it legible.
- Warm is over-useful in the starter set (harbour want, crop condition, lurker repellent, guest want). If playtests show everyone building around stoves, another aspect needs equal reach before more content is added.
- Helper trips resolved off-screen can feel like a rate and not like an event, which is the abstraction the designer said they do not want. Showing the helper leave, return, and come back visibly robbed is the minimum; real walking across the map may be needed.
- Standing shelves can harden into per-faction delivery ladders if each want has one practical source.
- The river crew taking a third of a load, and lurkers raiding crops at night, are losses a cozy-leaning player did not choose. Both are avoidable by rule (handcart, footpath, stove, scarecrow), but that needs to be discoverable without text.
- Duplication and save races are the historic killers of physical-goods games on Roblox. Slots, serial numbers and atomic trades reduce the surface but do not remove it.
- Skirmishes, knocked-out creatures and bones must stay cartoon-level to keep the Mild rating; the rating questionnaire should be checked against the lurker fights and the undead envoy before art is made.
- A one-player server has no stalls, trades or rival escorts. The world's actors keep the rule working, but the stories that need a second person will be rare at launch.
- The first build puts all peoples on one small map as envoys. Later regions as separate places add loading screens to every route and split a small audience, per docs/research/02.


---

# The three judges

## The designer's advocate

**Ranking:** Process-carrier model (things that carry processes), Stuff, Form and Three Dials (a property-first rule-set), Hands, Holders and Stations (slot-based physical goods, tag-matched processes, receiver-side reactions), Want-and-offer web: properties, stances and hunger

**Verdict:** Build the rule-set on the processes design: a Thing carries cards of takes, needs, time and gives, everything from a hen to a faction is that card, and capabilities are traded in kind at a counter with no reputation ladder in front of them. Put it on the hands design's physical base, where every Thing is in a slot of a holder, a service is a process with a body in a slot, and the machine you want sits behind glass until you fill its bundle and carry the crate home. Take context from processes and hands together (places, weather and running stations emit; the receiving body's table decides; marks cover enchantment, food effects, protection and race), keep properties' Form x Stuff and its plain tiers with one odd tag each, and leave out both the three-dial cap on effects and the ban on named recipes. Fill the world from the wants design's content (the toll crew at the bridge, skirmishes that feed a travelling hospital, a people that pays to be guarded, hide that carries a ward) and its hold-to-ask signalling, but not its pips or standing rows. Enter through one object that fits three different things, as in properties, never through a cook-and-serve or deliver-for-pips loop, and make sure the first build contains at least one machine earned from a faction, one enchantment and one non-default people, because those are what the designer would look for first.

### Process-carrier model (things that carry processes): 8/10
- **Why:** This is the closest to the designer's own eleventh message, down to his word 'processes'. A Thing carries cards of takes / needs / time / gives, and a hen, a stove, a guest, a ritual, a raider, a body's reaction and a faction's trade offer are all the same card. Capabilities are bought directly in kind (12 crystal for a crated transmuter), which is his sentence almost verbatim, with no reputation number in between. Its effect vocabulary is open (marks such as Night-sight, banners, kinship), so a cake can do something specific. Tiers are left plain (wood, iron, crystal-tipped pick) with one odd tag on the cheap one, which matches the calibration. It clearly could not have been written without his messages: dragon on the mountain, crystal cavern, bayou compost works, tinker, caravan life. What holds it back is the entrance and first build: egg, stove, dish, guest is the tavern opening he already called slop, the dish quietly becomes the wage, tribute and payment for almost everything, and the first build defers every one of his signature examples (transmuter, lightning, dragon, raiders, other peoples, truck).
- **Strongest:** One card shape covers everything he listed, and faction trades are in-kind cards on a counter, so 'trade crystals for a machine that turns lead to gold' is literally one row of data. The stove that is also a heater, a hatchery and a mobile camp shows the web falling out of three unrelated rules.
- **Weakest:** The first minute and first build are a cozy cooking loop ('until the cozy loop is seen to stand alone'), and the dish is close to a universal currency. He would recognise the rule-set and distrust the way in.
  - Walked: Truck to the crystal cavern: partly works. The cavern, Chill, Dark and crystal nodes are there, and a handcart or ox-cart carries the load, but there is no truck (deferred). A friend works through partner permission. The NPC case breaks on wording: a Hand's Run goes to a settlement counter and back, and nothing says a Hand can dig a node, though the hour-ten text assumes it.
  - Walked: Crystals to a faction for a lead-to-gold machine: works exactly. Tinker's wagon takes 12 crystal and gives a crated transmuter; Transmute takes 2 lead ore and crystal charge and gives gold. It is left out of the first build.
  - Walked: Lightning harms an enemy and empowers a people: works. A thunderstorm or storm shard emits Spark; the storm ring marks a tool; Spark stuns valley-folk and jackdaws and gives tin-folk Charged. Lightning is also real weather that passes through an iron pick but not a wooden one.
  - Walked: Cake with a specific effect: works. Cook takes 2 food plus a flavouring and the dish carries that mark (Warm cancels Chill, Night-sight cancels Dark). The effect list is open, not limited to aspects.
  - Walked: Fur into armour: half works. Fleece coat by pattern card and material gives insulation; nothing reads a material as defence against being hit, so 'very good armour' is only weather gear.
  - Walked: City that turns remains into fertiliser: works as a faction. The compost works takes 4 remains and gives 3 loam at a hunger price, and loam emits Rot that crops, glowcaps and bayou guests all read. Breaks on ownership (no way stated to get a vat of your own) and on the source: bones come from the dragon's scree, not from a fight.
  - Walked: Travelling hospital that charges: works. A cot and stove on a cart; Rest takes a dish and Heat and removes chilled or worn-out; NPCs pay about three meals, players pay by stall card. There is no 'wounded' state from battle, only chilled and worn-out.
  - Walked: Nomad in a caravan: works. A cart is a holding that saves, so Player B has no plot.
  - Walked: Protection for a price: works three ways. Dragon's tribute for a banner with daily charges, a jackdaw truce for coin, or a player in a Spark-marked coat walking beside carts for a share.

### Stuff, Form and Three Dials (a property-first rule-set): 7/10
- **Why:** A real web with honest plain tiers, and more of his examples walk through it cleanly than through any other design: truck in the first build, the lead-to-gold transmuter earned from a town, a travelling hospital whose medicine depends on the patient's people, protection bought four different ways, his naval winter town written as one data row. The first minute (one charged crystal, three places to put it) shows the rule instead of an activity. It loses points for narrowing 'DIVERSE inputs and outputs' to three dials: every cake, enchantment, hazard and cure is one of five poles, so 'very specific stat boosts' cannot be expressed, and it deliberately deletes recipes and named enchantments, which he listed by name as outputs. 'Nothing has a rank' and nameless combinatorial goods also make it harder to want a particular thing; Minecraft has a diamond pickaxe, this has 'a rot-pinned gold coat'. Capabilities go through a standing number per town rather than a direct trade, which is three reputation tracks. It reads more like a chemistry set than a world of pirates and dragons.
- **Strongest:** Context is two data lookups (place ambient, body row), so 'lightning hurts a bandit and feeds a robot' and 'a frozen waste is trivial for one people' need no scripting, and a new region is literally a row. The Transmuter keeping Form (shape lead goods, then turn them to gold) and lead shielding are exactly the leather-boots kind of odd tag.
- **Weakest:** Three dials are the whole effect vocabulary, and recipes and enchantments stop being things you get. That flattens the diversity he asked for and risks the Dwarf Fortress opacity the design itself names.
  - Walked: Truck to the crystal cavern: works. Truck is a carrier with 20 bulk and 3 station slots, earned as a body from one town and an engine from another; a helper can be told 'drive this route'; a friend rides by permission flag; bandits take a third unless paid. One snag: crystal nodes need hard 3 and only crystal is hard 3, so the first mattock that can mine crystal is unclear ('quarter speed and gives chips').
  - Walked: Crystals to a faction for a lead-to-gold machine: works, indirectly. The Depot takes Spark crystals and gives the Transmuter 'at standing', so the trade is crystals to a reputation number to a machine, not goods for a machine.
  - Walked: Lightning harms an enemy and empowers a people: works from the rows alone. A Spark-pinned mattock hurts Hearthfolk bandits, feeds Wired helpers and grows Sparklings. Breaks for the player, who is always Hearthfolk in the first build, and there is no lightning as weather.
  - Walked: Cake with a specific effect: half works. A cake locks in the dials of its ingredients and is read against the eater's row, which is neat (wrong cake sickens the customer), but the only possible effects are warm, cold, spark, bloom and rot.
  - Walked: Fur into armour: half works. Coat form in fur stuff cancels cold by warmth. No form reads a stuff as protection from harm, though adding an armour form reading 'hard' is one row.
  - Walked: City that turns remains into fertiliser: works. The Mire Lodge takes anything at Life -2, runs its vat in the open, pays mulch, and the vat can be earned. Breaks at the start of his chain: nothing that is fought leaves remains (bandits do not fall, Sparklings break into shards).
  - Walked: Travelling hospital that charges: works well. A Counter on a truck bed, with mending defined as the dial that feeds that body's row, at the owner's price.
  - Walked: Nomad in a caravan: works. The cold-chain cook lives on a truck with an oven, counter and cold crate and owns no plot.
  - Walked: Protection for a price: works, the best of the four. Wardens for a tithe, bandits by toll or standing, a hired helper for upkeep, or another player selling a ride-along guard from a Counter.

### Hands, Holders and Stations (slot-based physical goods, tag-matched processes, receiver-side reactions): 7/10
- **Why:** Not a ladder: tag-matched processes, receiver-side reactions, bundles in kind and plain tool tiers. It has two ideas none of the others match for making his 'real things, not abstractions' true: every Thing sits in a slot you can see, and a service is a process with a body in one of the slots (a patient in a cot, a passenger in a seat). The transmuter sitting behind glass with its needs as empty slots, then leaving as a crate two people must carry, is the most physical version of his crystal-for-machine example. It is also the only design that puts changing the player's own people into the starter data. It scores below processes because the world around the mechanism is thin: one settlement, one hill warden, imps, and guests as the only sign of other regions. His bayou city as a faction, the pirate toll, protection sold between players and an NPC who goes to the cavern for you are missing or abstracted to a dice roll. The core reads as an inventory specification; the parts that sound like him are in the content, not the frame.
- **Strongest:** Service as a body in a slot, marks as the single mechanism behind enchantment, meal effects, protection and race, and guest wants derived from the same body table that decides harm. A wired traveller wanting a storm jar is never authored.
- **Weakest:** The world is too small to be the everything-coexists place he describes: one dock, no factions with their own purposes, driving and route risk reduced to a timer and a roll, and a hired hand that can only Tend or Carry.
  - Walked: Truck to the crystal cavern: breaks in two places. Vehicle beds exist in the model but trucks are deferred, so it is a handcart. A hand can only Tend a worker spot or repeat a shown carry, and digging is a swing at a node, so no NPC can do the cavern trip. A friend can, with the gate open.
  - Walked: Crystals to a faction for a lead-to-gold machine: works and feels right. Fill the crystal bundle under the window item, the HUGE crate is released on the dock, and getting it home needs a friend or wheels. Transmute takes 2 dull metal and a crystal.
  - Walked: Lightning harms an enemy and empowers a people: works, the best of the four. A storm jar is caught on a rod, marked onto a tool, and Strike applies it: wayfarer dazed, imp falls apart, wired charged. Join a people lets the player become the one lightning empowers.
  - Walked: Cake with a specific effect: works. Any flavour's effect tag rides on the cake for five minutes (coldproof, glow, shock), and effect tags are an open list.
  - Walked: Fur into armour: half works. A fleece coat passes 'warm' to the wearer. No hide from a fought creature and no defence value.
  - Walked: City that turns remains into fertiliser: breaks as stated. The player owns the compost vat and bayou travellers bring bones, but there is no city whose job this is, so the caravan mercenary who supplies it has nobody to supply. Imps do drop bones, so fighting does feed farming.
  - Walked: Travelling hospital that charges: works. A cot on the handcart's foundation slot, a chilled or dazed body lying in it plus one fibre, payment left on the tray.
  - Walked: Nomad in a caravan: works, thinly. The handcart is the first home and the herder never claims a plot, but it carries one station.
  - Walked: Protection for a price: works in one form only. A treat a day in the warden's bowl gives 'warded'. No toll, no raiders beyond imps, no player selling protection.

### Want-and-offer web: properties, stances and hunger: 6/10
- **Why:** The content is the most faithful to his stories of any design: a crew at the bridge that takes a third unless paid or befriended, skirmishes that leave hurt travellers for a roadside ward, a people that craves being guarded so a player can sell protection to it, creature hide that carries a ward into a coat, and his full chain from a knocked-out creature to bones to fertiliser to crops to milk to cheese. The frame is the problem. It makes one event, the handover, the whole game and prices it in one number, pips, shown before you confirm; lifetime pips are standing, and standing opens shelf rows one to three. Honestly summarised that is 'carry things to whoever wants them most, fill the bar, unlock the next row', which is the 'do x for y' he rejected, with a rotating x. It does not fully reduce to that, because machines, crops and the four chemistry rules are real transformers, so I do not mark it as a single loop, but it is the nearest of the four and its own risk list says so (standing as ladders side by side, bubbles as a quest list). Reactions are also squeezed onto one liking scale (crave, like, ignore, harmed), which is poorer than hurt, mend, speed, flee.
- **Strongest:** The world behaves like his: peoples with rivalries and visible states (thin chimney smoke, dim lanterns), a toll crew that ignores a handcart and notices gold, and hold-to-ask, where holding any object lights up everyone who wants it and crosses out those who refuse it.
- **Weakest:** Handover for pips, with standing rows, turns every faction into a delivery track and puts one measure on everything. The first minute is literally giving bread to whoever shows the most pips.
  - Walked: Truck to the crystal cavern: partly works. Cave vein in a cold-3 place, handcart or goat cart (truck later). A helper repeats one demonstrated handover and off-plot trips are resolved with the same toll check, so an NPC can do the run and be robbed. A friend can carry by Give.
  - Walked: Crystals to a faction for a lead-to-gold machine: works only through a ladder. The tinker takes crystals for pips; the binding bench sits at standing 2 and the transmuter at standing 3. Transmute needs charged 2 present, which a storm crystal, a tin hand or a storm supplies.
  - Walked: Lightning harms an enemy and empowers a people: works. The storm rock charges metal or crystal, binding puts it in a hatchet, lurkers are harmed double and tin-folk crave it and speed up. The Outlander holding it on the rock is staggered.
  - Walked: Cake with a specific effect: weak. A cake inherits one aspect one level lower and gives it to the eater, so effects are only warm, cold, wet, charged or rot, and a cold-1 or charged-1 cake does little for the default player.
  - Walked: Fur into armour: works best here. A coat averages the warmth of three fibre or hide pieces and inherits a ward, so a lurker-hide coat ignores wet and rot. This is the 'fur from a particular creature makes special gear' structure. Still no defence against blows.
  - Walked: City that turns remains into fertiliser: works, including the chain. Knocked-out lurkers and skirmish wreckage leave bones, the Bayou kin crave remains and give fertiliser, rich doubles wheat, goats give milk, rot turns milk to cheese, and at standing 3 you get your own compost heap and rival the envoy.
  - Walked: Travelling hospital that charges: works and matches his story. A cart with a cot, stove and tonics treats travellers who arrive hurt after a skirmish, for coin, rumours and standing.
  - Walked: Nomad in a caravan: works. Player two lives on a goat cart with a cot, stove and binding bench.
  - Walked: Protection for a price: works. Pay the river crew for an escort, post a tamed lurker or stand night watch on the Meadowfolk field, or hire out as escort at the bridge.

### Parts to combine
- processes: the universal record. A Thing carries process cards with takes (by tag), needs (tool, pattern card, aspect at that spot, weather, hands), time (work seconds or clock) and gives (things, marks, emitted aspects, by-products). Body reactions, raiders, guests and faction offers are the same card, run by one server routine.
- processes: capabilities bought directly in kind on a faction counter (12 crystal for a crated transmuter), with no standing number in between and never for coin alone. Use wants' and properties' standing only for relationships (toll waived, escort offered), not as a gate on every machine.
- hands: every Thing sits in one slot of one Holder, changed only by two server functions (Move and Transform), with Take/Put, Use and Pack on a phone. Size classes where a HUGE crate needs two bodies or wheels.
- hands: a service is a process with a body in one of its slots (patient in a cot, passenger in a seat, guest at a table). This is what makes his 'real things occurring' concrete.
- hands: the shop window. The real machine, card or helper behind glass with the goods it wants as empty slots beneath, then a crate you must physically get home.
- hands: receiver-side reaction tables with a fixed response vocabulary coded once (hurt/daze, mend, slow, haste, thrive, flee, ignore, cancel), and marks as the one mechanism behind enchantments, meal effects, protection and a player's people. Keep Join a people in the starter data. Guest wants derived from the body table.
- processes: emit / respond / edit for context, with running stations and marked things as emitters (the lit stove's heat bubble) and weather as a pure function of UTC time. Add properties' guard that only places and weather are free sources. Keep the effect list open (Night-sight, glow) and do not cap it at three dials.
- properties: Form x Stuff with a few plain Stuff numbers (hard, warmth, bulk) and at most two odd tags, including 'lead shields' and 'the Transmuter keeps the Form'. Plain tiers stay plain, each cheap tier keeps one odd tag.
- processes: recipes as pattern cards that slot into a bench and can be lent. Do not adopt properties' 'no named recipes, no named enchantments'; he listed a recipe and an enchantment as things you receive.
- wants: hold-to-ask (holding a thing lights every actor that wants it and crosses out those that refuse), far signs of a town's state on its buildings, and processes' greyed unmet-condition icons. Drop the pip number.
- wants: its world content. The crew at the bridge that takes a third unless paid, befriended or guarded and ignores a handcart; skirmishes that leave hurt travellers and wreckage; 'guarded' as a state a people wants so a player can sell protection to NPCs; knocked-out creatures leaving bones and a pelt whose ward carries into a coat; taming by feeding three times.
- properties: four ways to buy protection (wardens for a tithe, the raiders by toll or standing, a hired helper, another player's ride-along guard) and helpers whose upkeep follows their people's row, so a helper is also a consumer. Add processes' dragon tribute banner with daily charges.
- wants and hands: teach a helper by doing the job once in front of it. Extend it to nodes so an NPC can do the cavern trip, which hands cannot.
- properties: the first minute. One charged crystal already in your hands and three different things to put it into, or hands' random starting object. Not processes' egg, dish, guest and not wants' bread for pips.
- properties: mending means the effect that feeds that body's row (bloom for one people, rot for another, spark for a third), so a hospital has to read its patient.
- processes: clock processes settled from timestamps, shared settlement hunger across servers with a small NPC trickle, and the almanac that records processes seen with silhouettes for unknowns.
- hands: the content check run on every data change (how many station families make and take each thing; a thing may be marked plain on purpose), with the per-player process log and divergence test from properties and processes.

### What all four missed
1. Factions do not feed each other. His clearest content rule was 'for each people or place, what it needs, from whom, and what it makes for whom' (the naval town needs food from the farm country, gold from the cowboy town, magic users for heat). In all four designs towns consume only from the player. No NPC caravan runs between two towns that a player could raid, guard, undercut or replace, so the web has the player at the centre of every strand.
2. Conflict is not a process in the web. His third message is a siege by an AI faction, players joining either side, a fight at a bridge, mediation, then a hospital arriving. Fighting in all four is a stun or a knock-out of one creature type; nobody models a faction attacking a settlement, taking a side, or the remains and wounded that follow. Only the wants design gestures at it, off-screen.
3. Relationship with a faction is a number. He listed stranger, supplier, living beside them, vassal and subjugating them. None of the designs lets a player join, be taxed by, rule or be protected as a resident of a settlement.
4. The player's own people. He called xenotypes 'incredibly interesting'. Three designs defer it and keep every player on the default row, so 'the same thing means different things' is felt only through helpers. Only hands has it in the starter data, and still not in the first build.
5. Built transport and infrastructure. 'Building a train, dockyard, or airport', 'a ship you built', 'buy a ticket'. Every design stops at a handcart or cart and treats trips as timers; none treats a rail line, dock or ferry as a capability a player builds and others ride as a service.
6. Building itself. Base building, interior design and landscaping are in his list, and Minecraft's 'build' is one of his eight examples. Plots here are grids that hold stations; walls, rooms and decoration are not part of the rule in any design.
7. Armour. 'Thrumbofur armour' is gear that protects in a fight. All four implement fur only as warmth.
8. The setting's wonder. Pirates, ninjas, zombies, robots, cowboys, dragons, witches. All four drift to a pastoral valley with a cold cave and a tinker; the wild mix he refuses to give up is mostly absent, and nameless combinatorial goods make it harder to covet a particular thing.
9. A story source. He pointed at RimWorld's story generator. Events in all four are clocks (storms, night, a wagon's timetable). Nothing decides that today a town is besieged or a road is cut, which is where his stories begin, and it matters most on a server with one or two players.


---

## The systems critic

**Ranking:** Process-carrier model (things that carry processes), Hands, Holders and Stations (slot-based physical goods, tag-matched processes, receiver-side reactions), Stuff, Form and Three Dials (a property-first rule-set), Want-and-offer web: properties, stances and hunger

**Verdict:** Build the rule-set on the hands substrate (every Thing in one slot of one Holder, bodies included, two mutating server functions, no loose physics) and run it with the processes card, whose key property is that aspects are both conditions and outputs, so players build context by placing running things next to each other. Take Kind x Material with a handful of odd material tags and 'any aspect can be fixed onto any thing' from properties, but as on/off tags and marks with charges, not three drifting integer dials. Take generic taming, wearables that fit any body and states-as-needs from wants, and drop its pips and standing rows in favour of in-kind capability cards shown as physical window bundles. Before any human plays, run the hands content lint and a bot harness that reports, for every tag query, the cheapest object that satisfies it and, for every faucet, the sink that consumes it; three of the four designs have a free-value hole that this would have caught on paper. Tiered picks, carts and coats stay plain throughout, each cheap tier keeping one odd tag.

### Process-carrier model (things that carry processes): 8/10
- **Why:** Best ratio of rules to possibilities. One card schema (takes / needs / time / gives) plus three context rules (emit, respond, edit) over five on/off aspects. The decisive move is that an aspect appears on both sides of the same card: a running stove or transmuter GIVES Heat, and Hatch, pepper-growing and Rest NEED Heat. So players create context by where they put things, and adjacency becomes the emergent puzzle with no extra rule. I count about 20 unscripted affordances from 24 things. Capabilities, protection, kinship, raiders and faction trade are all cards or Things (a banner with charges, a pattern card, a counter card paid in kind), with no standing number outside the system. Delegation is literally an input slot called hands. Legibility is fair: on/off aspects and greyed unmet-condition icons let a player predict ('needs Dark and Rot; loam gives Rot'), though tags and response tables are still small lookups. Weak on economy closure: food is a self-sustaining faucet (Grow returns its seed, hens hatch hens) against small food sinks, coin is minted from transmuted gold, and both tinker machines are priced mainly in crystal, so 'dig crystal' gates every machine. A single stove on a cart cancels a whole cavern's Chill because aspects have no strength, which may make the coat redundant within 20 minutes.
- **Strongest:** Aspects are outputs of running processes as well as conditions of others, so stations become context sources (stove = cooker, heater, hatchery, camp) and layout generates content for free.
- **Weakest:** Faucets outrun sinks: free self-reseeding grain, exponential hens, a lead-to-gold-to-mint coin printer, and crystal as the single price of all tinker machines. No strength on aspects, so one emitter trivialises a hostile place.
  - Walked: Stove on handcart into cavern: works by rule (stove fits cart slot, emits Heat, Heat cancels Chill). Unscripted. Also a likely dominant answer to Chill because aspects have no level.
  - Walked: Coop built against transmuter: works (Hatch needs Heat, Transmute gives Heat while running). Couples lead supply to flock size, a real cross-system dependency.
  - Walked: Loam beside a table: works both ways from one response table (bayou guest pleased, valley guest leaves), so seating by people emerges without authoring.
  - Walked: Storm shard set in the storm ring: works, ritual without weather; the same shard near a plot blocks jackdaws (their card needs 'no Spark nearby'), an unlisted defence.
  - Walked: Tin-folk Hand with iron pick on a charged node: by the rules it gets Charged for free each swing. Unlisted self-feeding labour; needs a wear bound.
  - Walked: Bones as stove fuel and bone-headed pick: work through #burnable and #hard tags with material inheritance; nothing authored.
  - Walked: Hen + grain loop: Grow gives 3 crop + 1 seed back, Hatch gives hens. Checked sinks: wages 1 dish/day, tribute 4 dishes/week, seat-capped guests. Faucet exceeds sinks; FAILS closure without holding caps.
  - Walked: Lead -> gold -> mint -> coin: works as a coin printer bounded only by crystal charge (1 per 4 runs) and the mint's price; dominant coin line once the transmuter is owned.
  - Walked: New account claims holding (hen, stove, table, bed, cart) and stations are giftable: alt accounts can hand starter stations to a main. Not addressed.

### Hands, Holders and Stations (slot-based physical goods, tag-matched processes, receiver-side reactions): 7/10
- **Why:** The most enforceable and the most legible substrate, with moderate generativity. One invariant (every Thing is in exactly one slot of one Holder) is at once the object model, the phone control scheme, the save format and the anti-duplication model: only Move and Transform change goods, with a ledger and a per-player action lock, and there is never an unanchored good. Bodies are slot occupants too, so services and delegation are not analogies to goods, they are the same rule (patient in a cot slot, worker in a worker spot). Guest wants are DERIVED from body tables, so a new effect creates demand with no authoring, and the proposed content lint (count station families that make and take each thing; require a station's route back to its own inputs to cross another family) is the only mechanical guard against ladder drift in any of the four. Predictability is the best here because the player need not predict: ghost outlines show every legal slot for what is held. It scores below processes because context is mostly fixed by place and events: nothing says an oven emits warm, so players cannot build context, and I count about 14 unscripted affordances rather than 20. Appetites saved per player mean nothing changes when everyone does the same thing, so a published best bundle order works forever; the route-risk dice roll and timer-only driving sit outside the rule.
- **Strongest:** Thing-in-slot-of-Holder with exactly two mutating server functions: one rule gives handling, saving, dupe resistance and services (a body in a slot), and the content lint makes 'is it a web' checkable by script.
- **Weakest:** Context is not player-manipulable (stations do not emit effects; proximity effects like crystal glow repelling imps are used in a story but never stated as a rule), and per-player appetites remove any shared economy and allow fresh-appetite alts.
  - Walked: Cot unpacked on the cart's foundation slot at the cavern mouth: works by rule (cot is a crated station, cart has one foundation slot, Rest takes a chilled body + fibre).
  - Walked: Storm jar in the oven's flavour slot: works because the jar is tagged flavour; storm cake dazes a wayfarer and is a treat for wired guests via derived wants. Fully unscripted.
  - Walked: Lightning rod or grow bed on the cart: works by the foundation-slot rule, so a storm-chasing rod and a frostcap bed towed into the cavern exist unlisted.
  - Walked: Goat pen on cart in the cavern: works (goat table: cold -> thrives, Graze halves).
  - Walked: Crystal shards around a pen to repel imps: the story uses it, but no rule says a Thing at rest applies its effect tag to nearby bodies. FAILS as specified; needs an explicit emit rule.
  - Walked: HUGE transmuter crate carried by two bodies: works, and a hired hand is a body, so a solo player is not blocked; an alt account also satisfies it.
  - Walked: Loaf to plate: 2 grain + 1 fuel, grain reseeds itself, logs free. Free with time; bounded by seats and per-player appetite only. Dominant opening loop, found in about ten minutes.
  - Walked: Give goods to an alt with a fresh per-player appetite, alt sells at full price and hands coin back: works. Coin buys little, so low damage, but it defeats saturation.
  - Walked: Offline catch-up capped at 8 h with inputs and output room as limits: sound bound on runaway; first build has no spoilage or wear, so sinks are thin and hoarding is likely.

### Stuff, Form and Three Dials (a property-first rule-set): 7/10
- **Why:** The largest possibility space and the only one where outcomes are genuinely predictable from physics-like rules instead of a table: warm and cold cancel, things drift to ambient, crystal holds, lead shields, a pin fixes. Form x Stuff with odd tags multiplies again: a crystal crate is a rechargeable cold box without binding, the Transmuter keeps Form so shaping then transmuting matters, and 'enchantment = any dial pinned to any thing' gives every enchantment from one rule. I count 20-plus unscripted affordances. Capabilities, helpers (bodies with rows whose speed depends on place) and services sit in the same system; standing is the one abstract number. It loses points on cost and exploit surface. Every thing carries three integers with timestamps, a drift clock, wear and a pin, read against 5x5 body rows and process bands: the most state per object for a phone player to read and the most tuning knobs. Pure dial queries invite the cheapest satisfier: the Depot sits in a Heat -2 pass and buys 'anything at Heat -2 or colder', so free wood left on the ground for two minutes is a sale. The cavern is Spark 3, holds the lead veins, and machines need Spark, so a Transmuter parked there makes gold for nothing. Pinned containers that set their contents' dial are a standing perpetual-source risk the design itself flags. Per-server town stock is reset by server hopping.
- **Strongest:** Dials as shared axes on things, bodies, places and processes: one drift rule plus hold / shield / pin lets a player reason forward ('this should keep it cold') and gives fridge, cellar, thermos and enchantment without naming any of them.
- **Weakest:** Heaviest state and tuning load, and the rules as written contain free-value holes: ambient-chilled junk satisfies town queries, ambient Spark powers the Transmuter beside the lead veins, and pinned containers are near-free sources.
  - Walked: Cold-pinned wooden crate with milk: works (contents sit at the crate's pinned dial; milk drift stops at Heat -1). Unscripted fridge.
  - Walked: Milk left in Bog Hollow becomes cheese: works from the cures tag at Life -1; place used as a machine.
  - Walked: Crystal as a Form's Stuff (crystal crate or mattock soaked in a level 2+ place): by the 'holds' tag it carries the dial with no Binding Stone. Works and is unlisted; also undercuts the pin's cost.
  - Walked: Shape lead into a mattock, then transmute: works because Transmute keeps Form; milling it back returns half the Stuff, so no duplication loop.
  - Walked: Wood dropped at the pass mouth for two minutes, sold to the Depot as 'anything at Heat -2 or colder': works as written. FAILS as economy; found within about ten minutes.
  - Walked: Transmuter on a truck inside the cavern (Spark 3) next to lead veins: by 'places are free sources' the Spark cost is zero. Dominant gold line once the Transmuter is owned; bounded only by gold saturation.
  - Walked: Spark-pinned crate holding empty crystals: rule 1 says contents drift to a pinned container's dial; guard rule says a pin costs wear. Conflict resolved only by tuning wear against a free wooden crate. Risky.
  - Walked: Iron mattock handed to a Wired helper on a charged node: works, self-feeding helper bounded by mattock wear, as the design says.
  - Walked: Server hop after saturating a town's per-server stock: full price again. Not addressed in the first build.
  - Walked: Almanac asks 'what does a fur crate do?' but Crate takes 4 rigid and fur is pliable: internal inconsistency; class limits cut the Form x Stuff grid to about 12 real cells.

### Want-and-offer web: properties, stances and hunger: 5/10
- **Why:** The most uniform abstraction and the weakest generator. Making everything an actor with wants and offers resolved by one handover is tidy and bot-testable, and several pieces are excellent: taming as 'feed any creature three times' so pets and hired hands are one object; states such as guarded or rested as things a wanter can want, which puts services and protection in the same system; a coat that fits any body; aspect inheritance at one level lower; a tin hand acting as the charge source beside a transmuter. About 15 unscripted affordances. But the resolver reduces every interaction to one scalar (level x hunger x stance = pips), and hold-to-ask displays that number for every actor in view, so the UI computes the dominant move for the player in the first five minutes. Pips are an abstract per-people currency, lifetime pips are standing, and standing opens shelf rows 1, 2, 3: three or four reputation ladders side by side, which the design admits. A crop 'wanting' water and a node 'wanting' a strike stretch the metaphor until process time, conditions and layout are second-class. Stance tables over about 20 properties and 8 kinds are a 160-cell lookup that is probed, not predicted. Not a single loop, since capabilities and chemistry do change what the player does, but it is the closest of the four to 'bring X to whoever pays most for Y'.
- **Strongest:** Wants can be for states as well as things, and taming / hiring / wages are one mechanism, so services, protection and helpers need no separate system; the pure resolver is easy to test with bots.
- **Weakest:** One verb and one number: pips with a live preview make pips-per-minute the game, and standing rows per people are explicit parallel ladders paid in a non-physical currency.
  - Walked: Hold bread, read pips on three bubbles, give to the highest: works, and is exactly the optimisation the design wants to avoid; found in seconds.
  - Walked: Logs to the Harbour envoy (fuel counts as warm, logs are free with a flint hatchet): cheapest satisfier of a craved want; dominant early loop until sated, then rotate. Rotation is the hungriest-bubble quest list.
  - Walked: Coat on the goat, stove beside a wheat plot in the Hollow: works from 'fits any being' and warm/cold cancel. Good unscripted combination.
  - Walked: Frost crystals packed with milk on a cart, then a lit stove on the same cart cancels them: works and creates a real trade-off from the cancel rule.
  - Walked: Feed a lurker rot three times, post it on the Meadowfolk field at night: works (generic taming, guarded as a wanted state). Best example in the design.
  - Walked: Tin hand beside the transmuter instead of a storm crystal: works, a helper as a power source; wage is charged, so it closes a small loop.
  - Walked: Give a stove to the Harbourfolk (warm 3): works, a capability re-entering as a good, but it only yields more pips.
  - Walked: Standing = lifetime pips, shelf rows at standing 2 and 3: FAILS the ladder check per people unless each want has several practical sources.
  - Walked: Per-server hunger in the first build: server hop resets sating. Shared hunger later fixes hopping but lets strangers flatten a route invisibly.

### Parts to combine
- hands: the substrate. Every Thing is in exactly one slot of one Holder (hands, pack, crate, cart, station tray, foundation, seat, bed); four size classes with HUGE needing two bodies or wheels; no loose physics ever; only two server functions change goods (Move, Transform) with a ledger and a per-player action lock.
- hands: bodies are slot occupants. A service is a process with a body in a slot, a worker spot accepts any body (player, friend, hired hand), and Carry is taught by doing it once. This makes delegation and services the same rule as goods.
- processes: the process card with aspects on BOTH sides. 'needs' can require an aspect and 'gives' can emit one while running, so a lit stove, a running transmuter, loam and a marked tool are context sources and layout becomes the emergent puzzle. hands lacks this and should take it as an explicit emit rule.
- processes: emit / respond / edit as the whole context model with on/off aspects and Heat-Chill cancel; start on/off, and add a strength only if one emitter proves to trivialise a place.
- hands: a fixed response vocabulary implemented once in code (hurt/daze, mend, slow, haste, thrive, flee, ignore, cancel) so a people is one data row, plus guest wants DERIVED from the body table so new effects create demand without authoring.
- processes: capabilities acquired by ordinary cards paid in kind at counters, with no standing number; combined with hands' shop window showing the real machine behind glass with its bundle as empty slots.
- hands: the content lint run on every data change (families that make and take each thing; a station's route back to its own inputs must cross another family; things may be marked plain on purpose). Extend it with a cheapest-satisfier report per query and a hub-centrality count.
- properties: Kind x Material with a few odd material tags that act on any kind (holds, shields, conducts), and processes that act on the material axis while keeping the kind (Transmute keeps Form). Keep these as tags, not as three integer dials.
- properties: enchantment as 'any aspect fixed onto any thing' with no named enchantments (implemented as processes/hands marks with charges), and the guard rule that only places and consuming processes are free sources of an aspect, enforced at one choke point in code.
- wants: generic taming (feed any creature what its table likes three times and it follows; tamed creature and hired hand are the same object with a wage), a coat that fits any body, and states such as guarded or rested as things a need can ask for.
- wants: the pure, headless resolver with bot players logging every transaction before any art exists (hands and processes propose the same harness); and the crossed-out 'refuses this' icon to teach body tables.
- processes: spoilage into Scraps that are still feed, marks and banners with charges, and tool wear, so sinks recycle instead of deleting; weather as a pure function of UTC so all servers agree.
- processes: settlement appetite consumed on a clock with a price band and a small NPC trickle, stored per player at first (hands, hop-proof) and moved to a shared cross-server number once population exists.
- hands: ghost outlines for every slot that accepts the held thing, with processes' greyed unmet-condition icons on slots that would accept it but lack a need. Together they replace prediction with visible affordance.
- processes: the first minute as one complete run of the rule (pick up, put in, work, hand over, receive something foreign) before the world opens; lower bounce risk than a three-way choice at second five.

### What all four missed
1. Cheapest satisfier. All four ask for classes or tags instead of named items, which is right, but none checks what the cheapest thing satisfying each query is. As written, free wood chilled by ambient sells to the Depot (properties), free logs feed a craved want (wants), and free self-reseeding grain plus free fuel makes the universal meal (processes, hands). Every query needs a substance or class alongside its property, or payment tied to what the object cost to make.
2. The web is a star. All four independently made crystal the hub good and one cold cavern the hub place; crystal is tool tier, battery, enchant reagent and machine price at once. With three zones the honest graph is a hub with spokes. Nobody drew the graph or counted in- and out-degree; the hands lint should be extended to flag any good that sits on most paths.
3. Capability objects never leave the world. Machines, cards and stations have fuel costs but no wear and no destruction, so the end state is every player owning everything, and hour-ten differences become differences of unlock order. The designer's own calibration says the top tier should be costly to keep. Only capacity limits (hands' pattern slots and station caps, processes' one card per bench, cart slots) currently force lasting specialisation; this needs to be a stated rule.
4. Fresh accounts and server hops. Giftable capabilities plus a starter holding means each new account is a free stove, hen or bench for a main (processes, properties). Per-server stock is reset by hopping (properties, processes, wants first builds); per-player appetite is reset by an alt (hands). Starter kit items should be bound or worthless, and appetite should be per player first and shared later.
5. Guests are an unmetered faucet. In every design a served guest hands over a thing from elsewhere created from nothing, so foreign goods scale with seats and the cheapest dish. That is the main import channel for unbuilt regions and nobody budgeted it.
6. Shared numbers with one or two players per server and a small launch population will be set by the NPC trickle, so 'prices fall when everyone does it' will not be felt at launch; the anti-route pressure that all four rely on has to work per player first.


---

## The Roblox engineer and first-hour player

**Ranking:** Hands, Holders and Stations (slot-based physical goods, tag-matched processes, receiver-side reactions), Process-carrier model (things that carry processes), Want-and-offer web: properties, stances and hunger, Stuff, Form and Three Dials (a property-first rule-set)

**Verdict:** Build the rule-set on hands' skeleton: Things in slots of Holders, two server functions, three buttons with ghost outlines, size classes, a handcart that is your first home, and capabilities shown as real objects over in-kind bundles. Put processes' emit/respond/edit on top of it so running stations and places radiate aspects and layout matters, and write all content as process cards matched by tag. Take the entrance from wants (arrive holding one thing, three takers that return three different kinds of thing, a crossed-out refusal) plus its taming and aspect-inheritance rules, but leave out pips and standing rows, which turn the first ten minutes into deliveries for a number. Keep properties' container tags, form-preserving transmuter and free-source guard rule for the second build, and do not build per-item drifting dials or a truck first. The first thing to put on a phone is handling plus one living thing, one heat-emitting station, one cold place whose counter is within reach, and one visible machine to earn; helpers, trading counters and vehicles come after that test.

### Hands, Holders and Stations (slot-based physical goods, tag-matched processes, receiver-side reactions): 8/10
- **Why:** As engineer: this is the only design written from the build outward. Every good sits in one slot of one holder, goods change through two server functions (Move, Transform), and nothing is ever an unanchored assembly, so the unmeasured 40-60 moving-assembly budget, network-ownership exploits and weld-state dupes mostly stop mattering. True first-build size is the smallest of the four in risk, though not in work: engine, three buttons, handcart, four stations, one cavern, guests with two body tables, a dock with three bundles, one hired hand, save, harness. The costliest piece is the hired hand and guests sharing slots with the player (reservations, recovery when a station is re-crated mid-task) plus offline catch-up matching live play; I would cut the two-player counter and the hired hand from the very first phone test. It gives the earliest honest playtest: three buttons, ghost slots and a towed cart can be in a tester's hand before any economy exists. As the 17-year-old: at second 20 one button reads Put or Use and a ghost outline shows where, so my thumb knows. By minute 5 the shard I cracked off shows four ghosts (dock, locked flavour slot with a card outline, jar shape, plate), and a real machine sits behind glass with empty need slots, so I have seen a web and something to covet. At minute 30 alone there are different verbs left (dig, shape a jar, catch a storm, fill a bundle, flavour a cake, read a wired guest), but no creature, no threat and no physics, so it risks feeling like a tidy menu in 3D. Tiers are plain and correctly calibrated.
- **Strongest:** Slots plus two server functions make physical goods cheap, phone-safe and dupe-resistant, and the held-thing ghost outline answers 'what do I do' without a task list; the window showing the real machine over its bundle slots gives a goal I can see.
- **Weakest:** The first build has nothing alive and nothing kinetic except the mattock swing: goats, imps and trucks are all deferred, and with 4-minute beds and a 20-minute storm I would most likely close the app around minute 8-12, standing in the yard waiting on rings, or after the cavern chills me before any guest has paid me fleece. Co-carrying a HUGE crate with two welded characters is also unproven jank.
  - Walked: Second 20, loaf in hand: ghost on traveller's plate, press Put, he eats and leaves coin plus an iron bar. Works, no text needed.
  - Walked: Minute 2-5, mattock on the yard rock: shard appears, ghosts light at dock need, oven flavour slot (locked), workbench jar. Shows one good with several pulls. Works, if five ghosts in a tight yard do not mis-target.
  - Walked: Minute 5-15, cavern: cold chills then dazes a wayfarer; coat needs 2 fleece, which in the first build only arrives from guests; frostcap needs a bed carried into the cavern on the cart's foundation slot, and the source of the first frostcap seed is not stated. Partly broken: the counter to cold is not reliably in reach when I first walk uphill.
  - Walked: Minute 20, storm: rod plus crystal jar gives a storm jar that is charm, flavour and wired treat. Works by tags alone and is the one world event in the build.
  - Walked: Engineering walk, hired hand Carry: shown one take-from-A put-in-B, repeats on a waypoint graph with slot reservations. Buildable, but the waypoint graph has to be regenerated when the player moves stations; sized by the design as its costliest code, and I agree.

### Process-carrier model (things that carry processes): 7/10
- **Why:** As engineer: one process runner plus emit/respond/edit over five aspects is small and pure data, and the first build is honestly trimmed (transmuter, storms, ox, coats, dragon, raiders, stalls all deferred). Its handling layer is heavier than hands' (8-stack sack, two-hand carry, cart slots, outputs emitted at an output spot, free station placement not pinned to a grid), and it never says how a Carry Hand moves around player-placed stations. The least proven code is clock processes whose needs vary with time (daylight, a stove that is only lit while fuelled): settling Lay or Hatch offline means integrating over those windows, which the design does not acknowledge. Its best idea is also its cheapest: running stations and places emit aspects in a radius, so where you put the stove matters, and 'does a tester move the stove' is the most diagnostic single playtest signal in all four designs. As the 17-year-old: at second 20 I am holding eggs and the stove intake pulses, so yes. But minute 1 is a three-step line (egg, dish, guest), a loop demonstrated once, and the web is only hinted by spores with two greyed icons I may not read. At minute 5 I am waiting on a 4-minute hen and a traveller every few minutes. At minute 30 alone the first build has only one capability to earn (a valley Hand), and crystals from the cavern have nowhere to go but the want board, so the cavern trip pays coin, which is the hole.
- **Strongest:** Aspects emitted by running stations (stove heats, transmuter heats, loam rots) make layout and carrying a station on a cart meaningful with almost no code, and produce combinations nobody authored (rolling hearth, waste-heat hatchery).
- **Weakest:** The entrance is a single chain and then stops: I would close the app around minute 3-6, either idling at one seat waiting for the next traveller, or walking to the glowing cavern, being knocked out by Chill with no coat in the build, and waking at the holding with my goods fading on the cavern floor.
  - Walked: Second 5-30: pick up eggs, stove pulses, Put in, hold Work 4 s, dish out, carry to traveller. Works and is readable, but it is one loop shown once.
  - Walked: Second 45-60: spores accept the soil bed but show greyed Dark and Rot. A good question if I understand greyed icons; if not, I sell the spores (the design lists this as a failure sign).
  - Walked: Minute 4-8: buy grain with the coin, feed hen, wait 4 clock minutes for an egg; table has one seat. Works mechanically, but it is dead air at exactly the 61-180 s window.
  - Walked: Minute 6-10: cavern for crystals. Chill slows then knocks out valley-folk; coats are out of the first build, so the answers are a pepper dish (pepper needs Heat, so plant by the stove) or pushing the lit stove in on the cart. Clever for a tester who gets it, a wall for one who does not.
  - Walked: Engineering walk, rolling hearth: stove in a cart slot, aspect at a point computed from emitters in range and cached once a second. Cheap and works.
  - Walked: Engineering walk, Hatch offline: needs Heat present for 10 clock minutes while the stove burns fuel. Offline settlement needs fuel-window maths or a rule that conditions are checked only at start; unspecified.

### Want-and-offer web: properties, stances and hunger: 6/10
- **Why:** As engineer: the handover resolver is a pure function, so it is the earliest thing testable headlessly and the bot harness can map the web before art exists; that tests numbers, not feel. The first build is mid-sized but hides moving creatures (a goat that follows, a lurker that hunts at night, flees warmth and can be tamed), a storm, day/night, five context buttons and a show-once helper, with shelf purchases that leave a pending pip balance to manage. As the 17-year-old: this has the best first 20 seconds of the four. I am already holding bread, three bubbles show pips, one is crossed out, one Give button, and the three returns are a tool, a creature and a rumour. The crossed bubble teaches 'who you bring it to matters' in ten seconds with no text. Then it narrows. The pip count is a price shown before every handover, and lifetime pips per people are standing that unlocks shelf rows, so the honest minute-5-to-30 experience is carrying logs one armful at a time to the sailor for fewer pips each trip until row 2 gives me a handcart. I do not mark it as a single loop because ovens, cheese, binding, crops and taming are real processes, but it is the nearest of the four to parallel reputation ladders, which the designer's thirteenth message warns about ('not lots of chains paralleled together'). Forcing nodes and machines to be 'actors that want' is unification for its own sake.
- **Strongest:** The entrance: one object already in hand, hold-to-ask lighting every taker with a crossed bubble for a refusal, and three first handovers that return three different kinds of thing.
- **Weakest:** Pips and standing rows put a number on every act and a cumulative bar per faction; I would close the app around minute 6-8 on my fourth log run to the sailor, having concluded this is fetch quests without the quest text.
  - Walked: Second 5-25: bread to sailor gives an iron hatchet; to goat gives a follower with panniers; to traveller gives coin and a rumour page; skeleton shows crossed bone. Works, the strongest opening of the four.
  - Walked: Minute 1-10: hatchet on tree gives a log (armful, one at a time); sailor wants fuel; pips fall with each delivery; standing 2 unlocks stove and handcart. This is 'do X for Y' with a falling number, exactly the pattern the notes reject, in the first ten minutes.
  - Walked: Bones for the skeleton: bones come from knocked-out lurkers, which appear at night at the bog. So the second people's craving is gated behind combat and a clock in the first build. Weak for a solo newcomer.
  - Walked: Cold chain (milk packed around frost crystals, stove on the same cart cancels them): works by the cancel and pause rules and is a nice unauthored trade-off; costs per-item spoil clocks.
  - Walked: Engineering walk, 'guarded through a night' as a want: needs presence detection over a time window and a definition of what counts. Fuzzy, costly, rightly outside the first build.
  - Walked: Engineering walk, taming by three feedings and a coat on a goat: cheap in code (same resolver, same wearable slot), costs the artist a coat fit per body.

### Stuff, Form and Three Dials (a property-first rule-set): 5/10
- **Why:** As engineer: the largest first build by a wide margin. Three zones, three towns with saturating stock, a bandit chokepoint with three ways through, seven stations, two creatures, travellers of three peoples, a helper, a handcart and a truck, and an icon language for three signed dials. A driven truck on phones is the known fragile piece (Retail Tycoon 2's trucks were undrivable under about 20 fps) and is in build one. The core mechanic is also the least proven: every thing carries three dials that drift a step a minute toward a target that depends on place, container, pin, stuff tags and (for milk) another dial's threshold. Computing that lazily through nested containers is where bugs and free-energy holes will live, items loaded at different minutes stop stacking, and the 'four rules' already have per-stuff exceptions in the starter list. It would reach an honest playtest last. As the 17-year-old: at second 20 there is one Put button and three pulsing targets, and seeing one crystal run a mill, wake a helper or charge a tool is the best ten-second statement of 'same thing, different contexts' in any design. By second 40 I am standing in a camp with five stations, a cart, a creature and a cooling loaf, and the only signposted next step (refill the crystal) leads up a pass that hurts my default body. At minute 30 there is plenty in the world if I can read it, but nothing has a name to want: no recipes, no named enchantments, worth never shown on a thing. That is mild over-correction into abstraction, even though the tool and carrier tiers are kept plain.
- **Strongest:** The opening object: one charged crystal that visibly means three different things, and you can only spend it once. Also the guard rule 'only places are free sources of a dial', and container tags (lead shields, crystal holds) as second-build depth.
- **Weakest:** Legibility and state cost of continuous drift on three dials: effects happen on timers I cannot see on a phone, and I would close the app around minute 3-6, after walking up the pass with an empty crystal, taking cold damage I do not understand, and waking at camp facing five stations and no named thing to make.
  - Walked: Second 5-20: crystal into mill, traveller or mattock; each responds at once. Works and is memorable.
  - Walked: Second 20-50: crystal now empty, two targets still pulsing, signpost to the pass; camp also holds Oven, Workbench, Mill, Binding Stone, Counter, cart, Shagback. Too many targets for proximity aiming and for a first minute.
  - Walked: Minute 2-6, refill trip: the crystal fills only at dial 2+, i.e. the cavern (Spark 3) inside the Frost Pass (Heat -2), which hurts Hearthfolk. The intended answer is tame the Shagback with grain, shear, shape a 3-pliable coat. Reasonable chain, but nothing but a snowflake on a signpost tells me before I am hurt.
  - Walked: Engineering walk, milk in a cold-pinned wooden crate on a truck parked in the bog: Heat drifts to the crate's pin, Life drifts to the place's -1 unless Heat is -1 or colder, which stops it. Two coupled dials with a threshold, evaluated lazily, per jug, each with its own timestamp. Resolvable, but this is the bug farm and the stack-breaker.
  - Walked: Engineering walk, transmute a finished lead crate to gold: record keeps form, swaps stuff. Trivial in data and a genuinely good rule.
  - Walked: Engineering walk, bandits take a third of a truck's crates to a camp as real objects: needs truck, route trigger, camp inventory and recovery. Good fiction, a whole system, in build one.

### Parts to combine
- hands: the physical model. Every Thing sits in exactly one slot of one Holder (hands, pack, crate, cart, station tray, plate, seat, bed, foundation); goods change only through two server functions, Move and Transform; no unanchored goods in the first build. This is what makes physical goods buildable by one programmer and safe on cheap phones.
- hands: three thumb buttons (Take/Put with a flipping label, Use, Pack) with cone targeting, and ghost outlines of the held thing on every slot that would accept it. Add from wants: a crossed-out ghost on a body that would refuse or be harmed, so stances are taught by a refusal in the first seconds.
- hands: four size classes (small stack, hand, bulky, huge) as the whole carrying rule, and the handcart as the first saved home with one foundation slot that can carry a working station.
- processes: the process card (takes by tag, needs, time, gives) as the single content unit, carried by any Thing; a workbench that has no process of its own and runs the pattern card slotted into it (hands has the same pattern-slot idea).
- processes: emit / respond / edit. Places, weather and RUNNING stations emit aspects in a visible radius, bodies and materials respond through a short table, and what you wear or eat edits your table. Keep levels as small integers. This is the cheapest source of unauthored combinations (stove as heater, hatchery, camp).
- hands: guests want whatever their own body table reacts well to, so guest demand is derived, not authored; and a service is a process with a body in one of its slots (cot, seat, table).
- hands and processes: capabilities are Things paid for in kind with a specific bundle of goods, shown as the real machine, card or helper behind glass with empty need slots under it. No standing bar and no pip count; drop wants' pips and properties' standing as the gate.
- wants: the entrance shape. The player arrives already holding one thing, and the first act can go to three takers that each return a different kind of thing (a tool, a creature, a piece of knowledge). Use properties' variant as the alternative to test against it: one charged object that visibly does three different things and can be spent once. Use hands' randomised starting hand to measure which opening bounces least.
- processes: unmet conditions shown as greyed icons on a slot that would otherwise accept the held thing (spores that need Dark and Rot), and a keepsake from elsewhere as the first open question.
- wants: taming is satisfying a creature's want three times, and any wearable fits any body. Both are nearly free in code and bring a living thing into the first build, which hands lacks.
- wants: an output inherits the strongest aspect among its inputs one level lower. One rule replaces a recipe table for flavoured food and marked gear. Hands' marks are the storage for it (one mechanism for enchantment, meal effect, protection, people).
- processes and wants: weather and travelling-vendor timetables as pure functions of UTC time, so every server agrees with no storage; keep one scheduled storm in the first build as the world event that happens to a solo player.
- wants: the resolver as a pure function with a bot harness that maps which processes get used before humans play; hands: the content check that counts, per thing, the distinct station families that make and take it, with 'plain on purpose' as an allowed mark.
- properties, for the second build only: container tags that edit context (a shielding crate, a holding crystal), a transmuter that keeps the form and swaps the material, the guard rule that only places are free sources of an aspect enforced at one point in code, and stolen cargo sitting as real objects at the raiders' camp. Do not take per-item continuous drift on three dials; use one fresh/spoiled clock at most.
- hands: NPC helpers and guests as server data on a waypoint graph with slot reservations, show-once Carry, per-player appetites before any shared numbers, driven vehicles deferred until the handcart and handling are proven.

### What all four missed
1. Minutes 1 to 6. Every first build fills this stretch with clock processes (4 to 8 minute crops, hens, travellers every few minutes) in a server holding one real player, and none says what the thumb does while rings run. Roblox also counts a bounce at 61 to 180 seconds, not only under 60.
2. The first meeting with the context rule is a punishment in all four. The first interesting destination (cavern, pass, hollow) is cold and hostile to the default body, and in three of the four the counter (coat, cake, fleece) is not reliably in reach when a newcomer first walks there. The first context effect a player feels should be a surprise in their favour, and chill should be slow, loud and recoverable without losing the load.
3. Nothing is fun in the hand. Every opening verb is Put, Give or hold Work. Lumber Tycoon's entrance is chopping and physics; here the only kinetic acts are a mattock swing and towing a cart. Slot-snapping is the right engineering call, but the first build needs at least one act with weight and feedback, and that is a feel task for the human artist to be asked for by name.
4. Building. The designer's lists include building, interior design and landscaping, and the hardest platform item named in the brief (saving a world of placed objects) is sidestepped by all four with foundation slots. None lets structure matter to the rule, for example walls or a roof that hold an emitted aspect in. It can wait, but it should be an explicit decision.
5. Helpers are in every first build and nobody sized them. An NPC that walks between player-placed stations, shares slots with the player and keeps working offline is the single costliest piece of code in each design; only hands names a waypoint graph and reservations. It should follow the first phone test, not be part of it.
6. Offline settlement of processes whose conditions change over time (daylight, a stove that is lit only while fuelled, storms). Either conditions are checked only when a process starts, or such processes pause offline. No design states the rule.
7. What the artist must actually make. Item x material is counted as free content, but each pair needs a visual rule (a recolour or texture swap of the form's mesh). Coats that fit any body need a fit per body. None gives the artist a list.
8. Every design defers the player's own people to a later build, so the designer's favourite feature (xenotypes) is felt only through guests and helpers at first. Timed meals and worn gear editing the player's table partly cover it; that should be said and tested on purpose.
9. With one or two players per server, the swap counter, trade blanket and stall are scope with almost no use at launch and are the classic duplication surface. Hand-to-hand Give is enough for the first build.
10. All four resolve helper trips as timers, and hands resolves route risk as a dice roll. The designer said supply lines are 'NOT abstractions but very real things'. The timer is right for a first build, but the return must be visible (cart comes back, load visibly lighter if robbed) and the designer should be told plainly this is a reduced form.


---
