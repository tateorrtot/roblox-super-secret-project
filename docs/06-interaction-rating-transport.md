# Interaction, Rating and Transport Research, November 2026

Compiled 2026-11-18. Three researchers each wrote a brief from live sources, and a second agent independently re-checked each brief's key facts and conclusions. Read each brief together with its "Independent check": the checkers struck or narrowed many conclusions.

## Summary of what held up

### In-world interaction or panels
- The mod the user meant is **Hands-On Delight** by Pocky (modrinth.com/mod/handson-delight), an add-on to Farmer's Delight built on the author's Diegesis library, first published in November 2026. Right-clicking a station flies the camera to it, hides the HUD, and gives a free cursor to work the station's 3D parts: stir with the spoon, cut along marks, flip the skillet.
- It is not panel-free. A compact drawer along the bottom shows only the stacks that station can use, a recipe book hangs beside each station, and the original menu is one key away.
- Several of its choices already suit touch: the spoon is click-to-grab and click-to-release, not a held drag; walking away lets the pot cook at the base rate, so the gesture is a bonus and not a gate; batching handles sixteen items at once.
- Its architecture is the transferable part: a station is declared in code (state and server rules) and its scene in data (camera point, slots, grabbable parts, controls), and a station can use an ordinary container's inventory so automation still works. The same author has sibling mods for furniture (put food anywhere on a fridge shelf) and for the crafting table and furnace.
- **Vintage Story is a hybrid.** The work itself happens in the world (knapping, clay forming, hammering on the anvil, pouring molds, piles on the ground, shelves, the clay oven). Recipe choice, the firepit's slots, cooking-pot ingredients and chest contents are panels.
- **Roblox games on phones** use a tap on the object, a context button, on-screen prompts or a panel. 99 Nights in the Forest cooks by dropping food on the campfire and loads its crock pot by dumping the whole sack over it. Dead Rails has a Store button and a tap-to-drop list. Cook Burgers is a physics-grab cooking game with phone support and 665M visits, so in-world handling by touch does ship.
- No measurement was found comparing in-world interaction with panels.
- The researcher's recommendation, which the check did not dispute: world verbs for any action where one held thing meets one target (apply, take, work, set down), and one consistent panel anchored to the object for contents, moving stacks and choosing recipes. A fixed-camera station mode in the style of Hands-On Delight could be added to a couple of flagship stations later.

### What the Mild rating allows
Roblox now uses a questionnaire based on IARC, and how its answers map to Minimal, Mild or Moderate is not published. Developers report it rating more strictly than the old one. Labels on existing games are declared by their creators, so they show what is tolerated, not what Roblox has approved. A new game's answers are pre-filled by Roblox reviewers at the Kids and Select gate.

| Design element | Finding |
|---|---|
| Conditions (burns, frostbite, infection, poison) | Fine as a system. The label depends on how it looks: icons, tints, shivering, limping and bandages are safe; textured wounds and red blood are Moderate |
| Losing a limb and replacing it | **Uncertain.** The one game found with the same loop (Rogue Lineage) is Moderate. IARC lists dismemberment as gore with no realism qualifier. Showing the state and never the act may keep it Mild, but that is not established |
| Undead peoples, bones, remains into fertiliser | Stylised skeletons, ghosts and fungal folk are fine. 99 Nights in the Forest is Minimal with corpses as items. Zombies need care: no open wounds or exposed flesh |
| Knock-outs or deaths | Either stays Mild without red blood or pain reactions; bodies that vanish at zero health are the stated Mild example |
| **Alcohol** | **Any depiction, reference or use of alcohol is 18+.** Brewing has to produce plainly non-alcoholic drinks (teas, tonics, juices, broths). Taverns exist on Roblox below Moderate when they lead with food |
| Potions, medicine, enchantments | Fine. Health and strength potions are explicitly not "fantasy drugs". Avoid anything smoked, and addiction or withdrawal mechanics |
| Pirates who rob and can be paid off | Fine against NPCs. A pay-off between players should be a structured in-game offer, never free text, and never tied to Robux |
| Magic inspired by a real religion | Fine if fully fictionalised: invented names and symbols, nothing lifted directly, never the villain's faith |
| **Romance** | **The rule text makes any romantic theme 18+.** Friendship, rivalry, kin and household are safe. A few Minimal games do feature weddings, so marriage as a stated fact about a character is a grey area; romance mechanics are out |
| Paid random items | Do not change the label, but need odds shown, are switched off for all Australian users, and affect regional ratings |

**Moderate is not a disaster.** Moderate games still reach Roblox Select (ages 9-15) and 16+; only Roblox Kids (ages 5-8) is lost. That changes how much design it is worth giving up to stay Mild.

### Transport, roads and building on vehicles
- **Player-laid track on a player's own plot is proven** (Theme Park Tycoon 2, Overfreight!, Mini Cities 2), all on servers of 6 to 9 players with per-player saves.
- **Free-form building in shared space that persists across public servers has almost no precedent.** Two tiny examples exist.
- **A community-wide project stored as one shared number has no shipped precedent that could be verified.** The storage is ordinary; each server should batch its contributions, because a single key has write limits.
- **No game was found where an NPC repeats a trip the player demonstrated.** DigCrew advertises drawing haul routes for hired drivers; how that works was not found.
- **Building on a moving thing:** welded pieces move as one rigid body, but Dead Rails reports that welding many objects to its train slows it through weight and server lag. Lumber Tycoon 2 holds cargo on open beds by physics, with vehicles prone to flipping and glitching.
- **Walking on a moving platform** ships at scale in Dead Rails with known flaws: it needed a fix in May 2025 and still fails at high ping.
- **Server sizes split cleanly:** games where you build on a vehicle or lay your own track run 6 to 8 players; games where you drive a prebuilt vehicle run 18 to 75.
- **Movement by touch:** foot, ground vehicles, trains, boats and land mounts all ship in games with audiences. Aircraft, gliders, flying creatures and submarines ship too, with less evidence about how well they control.
- **Two engine choices change the architecture and should be made before core code:** whether to adopt Server Authority (which predicts every welded part of what a player controls, so a deck of hundreds of pieces becomes a phone CPU question), and whether to use Humanoid or the Character Controller Library (which does not yet support the move-to call helpers would need).
- **Suggested prototype order:** walking on a moving deck on a phone; the hand-over when an intercepted delivery must become a real object; drawing or demonstrating a route by touch; a deck with a few hundred welded pieces on a low-end phone; one air controller, last.

---

# A. In-world interaction or panels

## In-world stations or panels: evidence brief

### 1. The mod

It is **Hands-On Delight** by Pocky: https://modrinth.com/mod/handson-delight (source https://github.com/Pocky-l/handson-delight). It is an add-on for Farmer's Delight, built on the author's library Diegesis (https://modrinth.com/mod/diegesis-api). It was published 2026-11-13 and had 15,855 Modrinth downloads when read.

What it changes, per its README:
- **Station mode.** Right-click a station and the camera flies to the block, the HUD hides, and a free cursor works the block's 3D parts. Players nearby see it happen.
- **Gestures.** Click the spoon and circle the mouse to stir; steady rounds earn up to three stars that add servings. Left-click along dashed marks to cut, and one cut goes through 16 items. Toss the skillet by its handle to flip.
- **Panels remain.** The inventory stays as a screen strip by default (Diegesis `"inventory_panel": true`). A recipe book hangs beside each station: click a dish twice and "its ingredients go into the pot from your inventory".
- **Escape hatches.** Sneak + right-click opens the original menu, hoppers keep working, and config can switch off any station or the stirring requirement.
- **Input.** Everything is mouse and keyboard (shift-click, right-click, wheel, cursor at the screen edge). I found no touch version.

So it is a fixed camera plus cursor plus 3D props, with inventory and recipe panels still on screen.

### 2. Vintage Story (wiki.vintagestory.at)

| Interaction | Where | What the player does |
|---|---|---|
| Knapping | World, one dialog | Sneak + right-click a stone on the ground; a dialog picks the tool head; click away voxels on a 10x10 grid with orange outlines |
| Clay forming | World, one dialog | Pick the item in a menu; right-click fills green voxels, left-click removes orange ones, layer by layer; F switches 1x1 / 2x2 / 3x3 / copy-layer |
| Smithing | World, one dialog | Placing a hot ingot on the anvil opens a recipe dialog; hammer voxels into green/purple outlines; F picks Heavy Hit, Upset or Split |
| Casting | Panel, then world | Crucible in the firepit GUI (4 slots); carry with tongs; aim at the mold and pour; right-click to take the cold item |
| Ground storage, piles | World | Sneak + right-click places one, right-click takes one, Sprint does many; a pile holds e.g. 64 ingots |
| Shelf | World | Right-click a free slot with the item; up to 8 small items |
| Clay oven | World | Add 1 to 6 firewood, light it, put in up to 4 doughs; no GUI described |
| Firepit | Panel | Three slots: input, output, fuel |
| Cooking pot | Panel in, world out | Ingredients go in 4 slots; a bowl or crock is filled by right-clicking the pot |
| Barrel | Both | Right-click with a bucket adds 10 L in the world; solids and sealing use the GUI |
| Quern | Both | Right-click the base for the input/output GUI; hold right-click on the top to grind |
| Chest, trunk, vessel | Panel | 16 / 36 / 12 slots (wiki does not describe the GUI itself) |

Every voxel craft starts with a recipe dialog. Anything with several ingredients, a fuel slot or many stacks stays in a panel.

### 3. Other designs

- **Farmer's Delight, unmodded** already splits the same way (farmersdelight.fandom.com). The cutting board and skillet are in-world: put the item on, hold use with a knife, outputs fly off. The cooking pot is a GUI with six ingredient slots.
- **Create** (create.fandom.com). Items are right-clicked onto a depot. A basin holds 9 stacks or fluids, takes items dropped into it, and the press or mixer fires "as soon as the basin contains all the ingredients for a valid recipe". A deployer "simulates player actions", so in-world verbs can be automated without new rules.
- **Valheim** (valheim.fandom.com). The smelter has sides: ore on the left, coal on the right, ingots drop out the front; it holds 10 ore and 20 coal. Meat on a cooking station takes 25 s (hare 60 s), then turns to coal if left. Key presses were not on the pages read.

### 4. Roblox, on phones

Live players are from games.roblox.com, read 2026-11-18.

| Game (playing) | In the world | Panel | Touch handling and friction |
|---|---|---|---|
| 99 Nights in the Forest (85,145) | Cook "by dropping it on the campfire"; feed the Grinder; Crock Pot takes 3 foods; shelves | Crafting Bench blueprint list | Sack holds 5 to 25 items. Wiki bug: fast sack use shows a wrong count |
| Dead Rails (15,695) | Drag items, weld them to the train or horse cart, fuel the firebox | Inventory; sack list where "tap on an item to drop it" | "Store button (Mobile)"; toolbar is 6 slots on mobile, 10 on PC. Patch notes: "Weld button now properly disappears on mobile", "Fixed mobile buttons blocking camera swipes" |
| A Dusty Trip (8,370) | Carry, attach, fuel | Not found | Third-party guide: tap an object to pick up or place; tap and hold to attach or fuel |
| Lumber Tycoon 2 (1,292) | Drag boxes and logs | Not found | "tap the bottom-left button for mobile" |
| The Forge (17,502) | Not found | Pick up to 3 ores, then on-screen meters: pump a bar, hold a cursor in a moving zone, hit rings | Mobile specifics not found |
| Bee Swarm Simulator (33,335) | Eggs are dragged from inventory onto a hive slot | Blender interface | "claim hive" tap button |
| Welcome to Bloxburg (14,567) | Character performs steps at counter and stove | Ingredient GUI | "click or tap on-screen prompts"; missing too many fails the dish |
| Restaurant Tycoon 3 (4,509) | Interact with the order counter, follow a green arrow, interact with appliances | Menus | Patch notes fixed a mobile "swipe up and down" gesture twice, a furniture dragger glitch, and iOS buttons at the screen bottom |
| Islands (441) | Blocks | Furnace is a 3-slot GUI; chests are slots | Not found |

None of these games uses free-camera dragging of small 3D parts as its main station interaction. They use a tap on the object, a context button, on-screen prompts, or a panel. Carry-and-drop games ship a sack or "Store" button beside the dragging.

### 5. Roblox guidance (create.roblox.com/docs)

- "The majority of Roblox sessions are played on mobile devices" (input/mobile.md).
- ProximityPrompt: on a phone the prompt itself is always tappable. Where prompts share a key, only one shows, chosen by camera direction (ui/proximity-prompts.md).
- DragDetector works by touch with no code and defaults to planar dragging on touch. By default the server performs the drag from client input (ui/3D-drag-detectors.md).
- "Most mobile players use two thumbs"; reaching far from the bottom corners is "uncomfortable or impossible" (ui/position-and-size.md).
- DevForum reports on mobile: drags are blocked in the dynamic-thumbstick region (topic 3060196); the camera locks while dragging in first person (3640012); the finger must stay held to keep hold of an object (3603285).

### 6. What it costs

- **Engineering.** Hands-On Delight is about 2.5 MB of Java, on a 1.4 MB library, across 110 and 76 commits, for one kitchen. It had 44 issues and 16 releases in its first 11 days. Issues included a server hang on shift-tap (#39), a recipe search every tick (#40), and stirring that a macro could fake because the client sends spoon positions (#41). Byte counts are a rough proxy for effort.
- **Phone usability.** The friction on record is in sections 4 and 5: gesture and drag fixes in developer patch notes, and DragDetector limits on mobile. I found no player-complaint threads and no measurement comparing the two approaches.

### 7. Recommendation (opinion)

Do both, split the way Vintage Story and Farmer's Delight split.

- **World:** every action that is one item meeting one thing. Hold the item and tap the target; tap empty-handed to take; hold to work.
- **Panel:** contents, stack moving and recipe choice. One panel design, anchored to the object.
- **Station mode:** a Hands-On-Delight-style fixed camera for one or two flagship stations, added later. The fixed camera removes the thumbstick and camera conflicts, and gestures there should be big taps and holds with a no-gesture fallback, as the mod itself provides.

A fully panel-free game on phones has no shipped precedent in what I read.

## Researcher's direct answers (several are struck or narrowed by the check below)
- (a) EVIDENCE-BACKED, with one inference. Works in the world on a phone: placing one thing into or onto another by a tap or a context button (99 Nights campfire, Grinder and Crock Pot; Dead Rails 'Store' button; A Dusty Trip tap to pick up and place; Bee Swarm dragging an egg onto a hive slot). Sequences work when each step is a tap or hold on a large target or an on-screen prompt (Bloxburg, The Forge, Restaurant Tycoon 3); swipes and free drags are where the patch-note fixes and DevForum reports cluster. Needs a panel: choosing among many items or recipes (even Vintage Story and Hands-On Delight keep a recipe dialog or book), and moving stacks between containers (Islands, Dead Rails and Vintage Story chests all use lists or slots). Arranging things: shipped only as build-mode placement or welding in what I read, and both show mobile bug fixes. Inference: several same-key prompts on one object, such as 8 shelf slots, will be awkward because Roblox shows one prompt chosen by camera direction.
- (b) EVIDENCE-BACKED for what, OPINION for why. Vintage Story keeps in panels: recipe choice for knapping, clay forming and smithing; the firepit's input, output and fuel slots; cooking-pot and crucible ingredients (4 slots); barrel solids and sealing; quern input and output; chest, trunk and vessel contents. In-world: the voxel work itself, pouring, serving from the pot, shelves, ground piles, the clay oven, grinding. The wiki does not state the reason. My reading: the panel appears wherever the player must pick from many options, set quantities across several slots, or see hidden state; the world is used wherever one held item meets one visible target.
- (c) OPINION, built from the patterns above. Five patterns cover all seven cases. 1) Apply: hold an item, tap the target (add an ingredient, pour water, feed a creature, bandage a patient, fuel a machine). 2) Take: tap with an empty hand to take the output or pick the thing up. 3) Work: hold or repeat-tap to advance a visible process (stir, hammer, grind, crank), which a helper NPC or machine can also do, as Create's deployer and Vintage Story's helve hammer show. 4) Set down: place an object on a snap point of any surface, the same rule for ground, shelf, truck bed or creature platform (loading a vehicle). 5) Open: one panel anchored to the object, for contents, stack moving and recipe choice. Cooking = Apply x n, Work, Take. Smithing = Open (choose), Apply, Work, Take. Brewing = Apply, wait, Take. Machine = Apply at an input side, Take at an output side, as in Valheim's smelter.
- (d) EVIDENCE-BACKED but thin. Engineering: the one full 'no menu' implementation I could measure is about 2.5 MB of Java on a 1.4 MB library for a single kitchen, with 44 issues and 16 releases in 11 days, including a server hang, a per-tick performance bug and a client-trusted gesture that could be faked; it still needed an inventory strip, a recipe book and a menu fallback. Phone usability: Roblox developers' own patch notes show repeated fixes to mobile swipes, draggers and context buttons, and DevForum posts show DragDetector conflicts with the thumbstick region and camera on phones. Roblox's docs say thumbs live at the bottom corners. Not found: any measurement (retention, bounce, task time) comparing in-world with panel interaction, and any player-complaint threads for the named games.
- (e) OPINION. Neither pure option. Use world verbs plus one panel: every single-item action is hold-item-and-tap on the object itself, with a context button near the right thumb; contents, stack moving and recipe choice open one consistent panel anchored to the object. Avoid free-camera drags and swipes as required inputs. Later, give one or two flagship stations (the cooking pot and the anvil are the obvious pair) a Hands-On-Delight-style fixed-camera mode, written as data-driven scenes, with big tap and hold targets, server-timed progress instead of client-reported gestures, and a no-gesture fallback. This keeps goods physical and visible to other players, lets NPC helpers and machines use the same verbs, and matches what the largest phone-heavy Roblox survival games already ship.

## Not found
- Player complaint threads about phone fiddliness in 99 Nights in the Forest, Dead Rails, A Dusty Trip or Lumber Tycoon 2: two web searches returned nothing usable; the friction evidence is developer patch notes and wiki bug lists only.
- Any measurement (retention, first-minute bounce, task time) comparing in-world interaction with panels, on Roblox or elsewhere.
- A touch or phone version of Hands-On Delight or Vintage Story, or any report of either being played by touch.
- The Forge: mobile-specific controls, whether an auto-forge or skip exists, and what is done in the 3D world; bloxinformer returned 403 and the PC Gamer page was truncated. Only one third-party guide was read.
- A Dusty Trip wiki: the fandom domains tried did not respond; controls come from one third-party guide (gamertweak.com), so treat as medium confidence.
- Restaurant Tycoon 3: a description of each cooking gesture; only the Mechanics page and patch notes were readable (the fandom Update History page returned 402 through the page fetcher but its subpages loaded through api.php).
- Valheim: the key presses for the cooking station, cauldron and fermenter were not on the wiki pages read.
- Vintage Story: the pour control for casting, whether the oven uses right-click, and the chest GUI layout are not stated on the wiki pages read; the bulk ground-storage key is given as Sprint but the page text was garbled.
- Lumber Tycoon 2: how dragging itself works by touch (no Dragging page exists on the wiki); Islands and Bee Swarm Simulator: touch-specific notes beyond the tap button to claim a hive.
- A Roblox-published minimum touch-target size; the touch subsection of the adaptive-design page came back empty in the markdown version.
- The project-note sections named in the task ('THE CORE OF THE GAME', 'The spatial model' and others) were not in the notes injected into this run; I worked from the task's own summary of the design.

## Independent check

12 of 14 key facts confirmed.

### Facts corrected
- **partly wrong:** 2. Camera-locked station mode, not panel-free: camera flies to block, free cursor on 3D parts; inventory stays as a screen strip by default; recipe book auto-loads from inventory; Sneak + right-click opens original menu; config can turn off any station or stirring
  - Correction: Camera move, hidden HUD, recipe book ('click it again and its ingredients go into the pot from your inventory'), 'Use the block as in Farmer's Delight | Sneak + right-click', and the per-station and stirring_required config keys are all confirmed. The inventory mechanism is misread: the brief cites Diegesis's default "inventory_panel": true, but Hands-On Delight's own scenes (cooking_pot, cutting_board, skillet, stove, keg all checked) set "inventory_panel": false and use "inventory_drawer": {side: bottom, style: minimal, always_open: true, compact: true, background transparent}. Per Diegesis docs a compact drawer shows 'Only the stacks the station can use'. So there is still a 2D inventory on screen, but it is a filtered, transparent strip of only the relevant stacks, not the vanilla inventory panel. The recipe book is an object in the 3D scene beside the station (scene node 'book_open'; issues #18/#22 are about it clipping), i.e. a diegetic panel, and it is optional (config recipe_book). The mod's own README headline is 'No menus, the blocks open in the world'.
- **partly wrong:** 4. Engineering cost: ~2.5 MB Java on a 1.4 MB library, 110 and 76 commits, 44 issues and 16 releases in first 11 days, incl. server hang on shift-tap (#39), per-tick recipe search (#40), macro-fakeable stirring (#41)
  - Correction: Byte and commit counts are exact, and the repo was created 2026-11-07 (11 days). But: (a) the 44 is 40 issues plus 4 pull requests, and #39, #40, #41 are all pull requests from one outside contributor (ledokua), found by code review, not player bug reports; #39 says 'Not reproduced in game yet'. (b) #39 is a 'server hang when shift-using the keg tap' (shift-click on the keg's spigot), not a 'shift-tap' touch input. (c) 16 releases are 8 versions, each published twice (1.20.1 and 1.21.1 builds). (d) Many of the 40 issues are compat or feature requests (e.g. #2, #3, #6, #7, #10, #21, #29, #34), not defects. (e) It is not 'one kitchen': the repo has 23 station scene files covering Farmer's Delight plus about 19 add-on mods (kegs, kettles, steamer, cask, oven, grill, cuisine board). (f) About 0.5 MB of the 2.5 MB Java is game tests (30 files); a single RecipeBook.java is 121 KB. (g) #41's own text says the server 'already limits pace and clock drift'; only the star-grading of stirring trusted client positions, and Diegesis states 'Server stations check every action'.

### Conclusions that go beyond the evidence
- Answer 4 and brief section 6 call Hands-On Delight costly 'for a single kitchen' / 'for one kitchen'. The repo has 23 station scenes across Farmer's Delight and about 19 add-on mods, includes 0.5 MB of tests, and went from first commit to 8 versions in 11 days by one author on a JSON-scene library. The same numbers support the opposite reading: once a data-driven scene layer exists, stations are cheap to add. The brief presents only the 'expensive' reading.
- Answer 4 lists 'a server hang, a per-tick performance bug and a client-trusted gesture that could be faked' as evidence of the approach's cost. All three are pull requests from one code reviewer, one explicitly 'Not reproduced in game yet'; the per-tick recipe search is an ordinary caching bug that the PR says also exists in base Farmer's Delight's cooking pot ('which uses the same pattern'), so it is not caused by in-world interaction. Only #41 (client-reported stir quality) is specific to gesture input.
- Answer 1: 'swipes and free drags are where the patch-note fixes and DevForum reports cluster.' The same patch notes contain as many or more mobile fixes for ordinary buttons, popups and menus (RT3 sell/store/move buttons, permissions popup, iOS bottom buttons; Dead Rails buttons firing on drag, drop-button overlap, scroll menu). The researcher searched for gesture problems and found them; no comparison of rates was made, so 'cluster' is not supported.
- Answer 1 and brief section 4: 'None of these games uses free-camera dragging of small 3D parts as its main station interaction' and 'A fully panel-free game on phones has no shipped precedent in what I read.' Hedged, but the sample missed an obvious counter-example: Cook Burgers (https://games.roblox.com/v1/games?universeIds=1073273083: 665,176,284 visits, 366 playing) is a physics-grab cooking game where ingredients are grabbed and stacked on a plate in the world, with mobile support (game description: 'Hold E or hold the Flip button to flip the thing you're holding'; update log: 'Fixed a bug preventing mobile players to grab items in the water'). Its low live count is itself a data point, but precedent exists. Dead Rails, A Dusty Trip and Lumber Tycoon 2, which the brief itself lists, also make free dragging of 3D objects their main interaction, just not at 'stations'.
- Answer 1's inference that several same-key prompts on one object (8 shelf slots) 'will be awkward because Roblox shows one prompt chosen by camera direction' treats the default Exclusivity setting as fixed. The docs offer AlwaysShow, and prompts are individually tappable on touch. The inference may still be right for clutter reasons, but not for the reason given.
- Answer 3 cites 'Vintage Story's helve hammer' as showing that the Work verb can be done by a machine. The wiki says it 'can only be used to' process iron blooms, blister steel and metal plates, and 'there is no way to automate the Input'. It supports a narrow version of the claim, not general automation of the smithing verb. Create's deployer does support it.
- Answer 5: the recommendation 'matches what the largest phone-heavy Roblox survival games already ship.' No per-game device split was found for 99 Nights or Dead Rails; 'phone-heavy' is assumed from Roblox's platform-wide statement. Also 'only the Crafting Bench blueprint list is a panel' in 99 Nights is asserted without a page that enumerates its UI.
- Answer 5 recommends 'server-timed progress instead of client-reported gestures' as if the mod had been found insecure. Diegesis states 'Server stations check every action' and 'The server checks every pour'; PR #41 says the server 'already limits pace and clock drift'. The weakness was limited to a bonus-quality score, which is a much narrower lesson: keep gesture quality cosmetic or low-stakes.
- Answer 2's rule for why Vintage Story uses panels is correctly labelled opinion, but brief section 2's summary line 'Anything with several ingredients, a fuel slot or many stacks stays in a panel' is stated as fact while the clay oven (fuel 1 to 6 firewood plus up to 4 doughs, no GUI) is a fuelled, multi-item station done entirely in-world on the brief's own table.

### What the brief missed
1) No maturity or rating line appears in this brief, so there was no rating definition to re-check. 2) The same author ships two sibling mods the brief did not mention and that bear directly on the user's other questions (storage on a truck bed, shelves): Hands-On Furniture ('open MrCrayfish's fridges, cabinets and drawers by hand and put food anywhere on their shelves') and Hands-On Vanilla ('craft and smelt with your own hands, right on the crafting table and the furnace, client-side'), both listed in the Hands-On Delight README. Diegesis itself advertises 'Free placing - items are put down anywhere on a station's shelves, turned and sized by hand. With physics on they fall, tip over and push each other', 'Multiblocks and seats - a station can cover several blocks and seat several players', and an inventory that can be 'laid out in the scene' instead of on screen. So the library already covers diegetic storage, not only cooking. 3) Diegesis's architecture is the most transferable finding and is underplayed: a station is declared in code (blocks, state schema, server rules) and a scene in JSON (camera point, nodes, slots, grabbables, controls), with a station able to 'sit on another mod's block and use that block's inventory, so hoppers keep working'. That is a concrete answer to how in-world stations and automation or NPC helpers can share one inventory model. 4) Hands-On Delight's design choices that already suit touch were not drawn out: the spoon is a click-to-grab, click-to-release toggle rather than a held drag; shift-click batches (one cut goes through 16, recipe book lays 16 sets); walking away lets the pot cook at the base rate, so the gesture is a bonus, not a gate; the drawer shows only stacks the station can use. 5) Reach: Diegesis has 162k CurseForge downloads (shields.io badge for project 1790227) versus about 18k on Modrinth, so the mod's audience is roughly ten times the figure quoted. 6) Vintage Story's wiki tells players to hold Alt or open a dialog to free the mouse during knapping, clay forming and smithing, which is independent support for a fixed-camera, free-cursor station mode. 7) Dead Rails wiki evidence relevant to the build-on-a-vehicle idea: welding too many objects slows the train through weight and server lag, horse-cart welding is bugged, and corpses despawn beyond 2000 m even when welded. 8) 99 Nights players load the Crock Pot by dumping the whole sack over it ('Holding F or the Unstore button will drop everything'), a shipped phone pattern for bulk transfer without a panel. 9) Bee Swarm Simulator (33k playing per the brief) has a drag from a 2D inventory onto a world hive slot as a core action (wiki: eggs are an inventory item 'the player drags into their hive'), which sits awkwardly with the advice to avoid drags as required inputs. Opinion: the overall recommendation (world verbs for single-item actions, one anchored panel for contents and recipe choice, a fixed-camera station mode for flagship stations) still looks sound, but the evidence supports a more favourable view of the station-mode approach's cost and of in-world storage than the brief gives.


---

# B. What Roblox's maturity rules allow

## Staying at "Mild": where Roblox's lines are (read 2026-11-18)

Sources, abbreviated below: **CM** = create.roblox.com/docs/production/promotion/content-maturity.md (updated 2026-11-10); **CR** = .../promotion/content-ratings.md (updated 2026-11-18, the newer IARC-based questionnaire); **KS** = .../publishing/kids-and-select.md; **ARC** = en.help.roblox.com/hc/en-us/articles/15869919570708; **HC** = en.help.roblox.com/hc/en-us/articles/8862768451604; **CS** = about.roblox.com/community-standards; **PRI** = .../monetization/paid-random-items.md; **API** = POST apis.roblox.com/experience-guidelines-api/experience-guidelines/get-age-recommendation.

### 1. Who each label reaches (CM, KS)

| Label | Reaches |
|---|---|
| Minimal, Mild | Roblox Kids (5–8), Select (9–15), and 16+ |
| Moderate | Select (9–15) and 16+; not Kids |
| Content May Vary | age-checked 16+ only |
| Restricted | ID-verified 18+ only |

- Every new game starts 16+ only. After 250 plays by highly engaged 16+ players, **Roblox reviewers play it and pre-fill the questionnaire** (devforum.roblox.com/raw/4985897/1). The label is therefore not purely self-declared.
- Answers must reflect "the most mature or extreme content players can encounter"; realistic violence counts "even if [it] only occurs once" (CM).

### 2. The definitions

| Topic | Stays Minimal/Mild | Moderate | Restricted or prohibited |
|---|---|---|---|
| Violence | "Implied or unrealistic depictions… such as bodies disappearing the moment their health reaches zero". Occasional = Minimal, repeated = Mild | "Non-graphic, realistic-looking depictions of violence and/or death… such as realistic depictions of real-life injuries" | "Graphic and realistic-looking… decapitation, impalement, hangings, dismemberment, mutilation, severed/severing body parts, presence of organs, maiming, disfiguration" (CM) |
| Blood | Light unrealistic = Minimal; heavy unrealistic = Mild. Unrealistic = unnatural colour, pixelated, or "minimal detail, such as red particle effects" (CR) | Light realistic: "Red blood", "Blood from visible wounds", pooling, staining | Heavy realistic |
| Fear, undead | "creepy-looking NPCs, jump scares, ominous music". Occasional = Minimal, repeated = Mild (HC) | "lack of flesh with realistic-looking connective tissues, organs… realistic open wounds" | — |
| Crude humour | burping, farting, "unrealistic looking vomit or poop" | pee | — |
| Gambling | — | unplayable depictions (casino props) | playable or simulated gambling is banned: "exchanging real-world money, Robux, or in-game items of value for a game of chance" |
| Alcohol | none allowed | none allowed | any game that will "depict, reference, or include use of alcohol", or shows "settings in which alcohol is common", is 18+. CS bans "intoxicated behavior" below Restricted |
| Tobacco, drugs | fantasy items "such as health or super strength potions, do **not** qualify as fantasy drugs" (CR) | — | banned at every label, "including fantasy drugs that mimic lifelike drugs in appearance or behavior"; CS also lists "pharmaceutical products" |
| Romance | none | none | "non-sexual expressions of love or affection, such as a quick kiss", or a game that primarily takes place in private spaces or "clubs or bars", is 18+. CS bans "Romantic or flirtatious gestures, content". IARC defines dating games as "Games with romantic relationship mechanics" |
| Religion | "a religious building in a city" needs no disclosure | — | 16+ only if the **primary theme** is a current polarising issue. CS bans mocking religion |
| Social | ordinary multiplayer | — | social hangout as primary theme = 16+ (18+ with bedrooms or small tents); freehand drawing or writing = 16+; extended generative-AI chat = 18+ |

Other points from the same documents:

- **Humanoid versus not:** the Roblox label does not distinguish. The IARC half of CR asks whether targets are humans or non-humans, whether the world is fantastical or realistic, and whether reactions are realistic ("Characters react to pain") or unrealistic ("Characters falling apart before respawning").
- **Gore** (CR): "dismemberment, visible bones through realistic wounds, and exposed organs" must be declared.
- **Medical:** there is no category. Non-violent blood ("a surgeon's scrubs") must be declared. CS bans content claiming to give real "diagnostic services, or treatment recommendations".
- **Corpses, bones, skeletons:** no rule names them. "Aftermath of a battle" counts as implied (mild) violence.
- **Paid random items:** a descriptor, not a label change (PRI, CS). They need numeric odds shown before purchase, a benefit from every outcome, and `ArePaidRandomItemsRestricted` gating.

### 3. Real games (API, read today)

| Game | Label | Descriptors | Relevant content (source) |
|---|---|---|---|
| 99 Nights in the Forest | Minimal | Violence Occ/Mild; Fear Occ/Mild | Human cultists drop corpse items that are burned as campfire fuel; churches, summoning circle (wiki Items and Cultist pages) |
| Dead Rails | Moderate | Violence Rep/Moderate | Corpses are a fuel item (wiki Fuel) |
| Deepwoken | Mild | Blood Light/Unreal; Fear Occ/Mild; Violence Rep/Mild | Bleed status, cauldron alchemy, an NPC surgeon known for amputation in dialogue only |
| Rogue Lineage | Moderate | Blood Heavy/Unreal; Fear Occ/Mild; Violence Rep/Moderate | Lost arm replaced by a Prosthetic Arm for 500 silver; Doctor fixes broken leg and frostbite (wiki) |
| Combat Warriors | Mild | Blood Heavy/Unreal; Violence Rep/Mild | Wiki Bandage page: "You can't heal back your missing limbs" |
| Guts & Blackpowder | Moderate | Blood Light/Realistic; Fear Rep/Mild; Violence Rep/Moderate | — |
| Fallen Survival | Moderate | Blood Light/Realistic; Violence Occ/Moderate | — |
| Project Delta | Moderate | Blood Light/Realistic; Fear Occ/Mild; Violence Rep/Moderate | — |
| Apocalypse Rising 2 | Moderate | Blood Light/Unreal; Gambling (unplayable); Violence Rep/Moderate | — |
| Creatures of Sonaria | Minimal | Blood Light/Unreal; Violence Occ/Mild | — |
| Booga Booga | Mild | Blood Heavy/Unreal; Violence Rep/Mild | — |
| Islands; Restaurant Tycoon 3; Wacky Wizards | Minimal | Suitable for everyone | — |
| Tavern Town | Mild | Violence Rep/Mild | "Pour drinks… bouncers and a bard band" (description) |
| Run a Medieval Tavern; My Jazz Bar | Minimal | Suitable for everyone | Jazz Bar description: "All drinks in this game are non-alcoholic" |
| Arcane Odyssey | Minimal | Violence Occ/Mild | Tavern location, potion brewing, bounties (wiki) |
| Maple Hospital | Minimal | Suitable for everyone | "Endure Surgery as a Patient" |
| Save A Life! | Mild | Blood Heavy/Unreal; Violence Rep/Mild | "swap organs, patch up bleeds and stitch him closed" |
| Zombie Attack; Zombie Rush | Mild | Blood Heavy/Unreal; Violence Rep/Mild | — |
| Tower Defense Simulator | Minimal | Violence Occ/Mild | — |
| Raise an Undead Army | Mild | Violence Rep/Mild | Zombie soldiers, skeleton knights |
| Jailbreak / Steal a Brainrot | Mild / Minimal | Violence | Robbery and stealing loops |
| CYBERPSYCHOSIS | Moderate | Blood Light/Unreal; Violence Rep/Moderate | "Chrome up" extraction shooter |

Pattern (evidence): every survival game listed with realistic red blood is Moderate. Corpses as items, undead, surgery, lost limbs, taverns and potions all appear at Minimal or Mild when stylised.

### 4. The ten design elements (detail is in the structured answers)

| # | Element | Mild form | Pushes higher |
|---|---|---|---|
| 1 | Conditions | Icons, tints, steam, shivers, bandage wraps | Realistic wounds or burns (Moderate) |
| 2 | Body parts, bionics, clinic | Part becomes "unusable"; clinic swaps it behind a curtain or flash | On-screen severing, stumps, organs (Restricted wording) |
| 3 | Undead peoples, bone fertiliser | Clean stylised skeletons, ghosts, fungal folk; bones as a drop | Exposed tissue or open wounds (Moderate fear) |
| 4 | Combat | Knock-out or poof, no red blood | Pain reactions, wounds, red blood (Moderate) |
| 5 | Brewing, taverns | Teas, tonics, juices with buff effects | Any alcohol word or drunk effect (18+) |
| 6 | Potions, medicine | Fantasy potions and herbal remedies | Pills, syringes, smoking, "high" effects (banned) |
| 7 | Pirates, raiders | NPC tolls, structured offers | Realistic crime technique; free-text threats |
| 8 | Magic tradition | Wholly fictional names and symbols | Real faith's symbols, or religion as main theme (16+) |
| 9 | NPC relationships | Friendship, loyalty | Any romance (18+) |
| 10 | Purchases | Fixed-outcome items | Chance bought with Robux; wagering (banned) |

### 5. Short list (my opinion, built on the evidence above)

**Safe:** status conditions as icons and tints; potions, herbs, bandages, splints; clean skeletons, ghosts and fungal folk; knock-outs and poof defeats; particle or off-colour hit effects; tavern or inn serving food and non-alcoholic drinks; NPC bandit tolls; invented magic tradition; friendship bonds; fixed-price convenience items; random drops that are never bought.

**Borderline, needs care:** limb loss and replacement (show the state, never the severing); clinic "surgery" (curtain and comedy, no organs); corpse or bone items (stylised, never player avatars); zombies (no open wounds); sickness vomit (whimsical only); the word "tavern" plus tankards (name every drink); player-to-player ransom; player-written signs; beds in small rooms; generative-AI NPC talk; any paid luck boost.

**Avoid:** ale, beer, wine, mead, rum, or drunk wobble; pipes, smoking, pills, syringes; red blood from visible wounds; pain animations; on-screen dismemberment or exposed organs; dice or card wagering for coins or items; kisses, dating, marriage; real religious names or symbols; real medicine names or advice; creature-abuse mechanics.

Out of scope for this step: the Hands-On mod, roads, and vehicle storage questions in the original request.

## Researcher's direct answers (several are struck or narrowed by the check below)
- (1) Condition system (burns, frostbite, infection, sickness, poison). EVIDENCE: no questionnaire category covers status conditions; Deepwoken (Mild) has Bleed and other status effects and Rogue Lineage has frostbite and anaemia. The label is set by how it looks: 'realistic depictions of real-life injuries' is Moderate violence and 'realistic open wounds' is Moderate fear. Vomit from sickness is Mild crude humour only if 'unrealistic looking'. OPINION: the most detailed Mild form is the full hediff data model shown through icons, skin tints, frost or steam particles, shivering and limping animations, bandage and splint props, and a readable health panel. What pushes it up: textured wounds, blisters or charred flesh on the model, red blood from a wound, realistic vomit, or real medicine names and dosing advice (Community Standards bar real 'treatment recommendations' and 'pharmaceutical products').
- (2) Separate body parts, limb loss, bionic, wooden or magical replacements, clinic surgery. EVIDENCE: 'dismemberment ... severed/severing body parts, presence of organs' are Restricted only when 'graphic and realistic-looking'; the IARC section calls 'Characters falling apart before respawning' unrealistic, and lists 'dismemberment, visible bones through realistic wounds, and exposed organs' as gore to declare. Rogue Lineage has exactly this loop and is Moderate; Combat Warriors has missing limbs at Mild; Save A Life! does organ-swap surgery at Mild; Maple Hospital has surgery at Minimal. OPINION: the system itself is fine at Mild if the game shows the state and never the act. A part becomes 'unusable' (greyed, wrapped, in a sling), the player or a helper carries the character to a clinic, a curtain, lantern flash or short comic sound covers the swap, and the limb reappears as a wooden, brass or glowing part. Keep the implant economy and stat differences as rich as RimWorld's. What pushes it up: an on-screen severing or tearing moment, a stump showing flesh or bone, a detached flesh limb as an item, visible organs, red blood on the operating table, or pain screams. Also do not let players mock prosthetics, since disability and disfigurement are protected categories in the Community Standards. This is the element I would expect a Roblox reviewer to look at hardest.
- (3) Zombie, ghost, skeleton and fungal peoples; a city turning battle remains or bones into fertiliser. EVIDENCE: Mild fear is 'creepy-looking NPCs'; Moderate fear is 'lack of flesh with realistic-looking connective tissues, organs, and/or blood vessels visible, realistic open wounds'. No rule names skeletons, bones or corpses as items. 99 Nights in the Forest is Minimal with human corpse items burned as fuel and an Undead class; Raise an Undead Army (zombies, skeleton knights) is Mild; Zombie Attack and Zombie Rush are Mild; Dead Rails burns corpses and is Moderate. OPINION: clean stylised skeletons, translucent ghosts and mushroom folk as a friendly playable people are safe, and since they are a people rather than monsters the fear descriptor may not even apply. Zombies need the most care: green or grey skin and stitched cloth, no open wounds, exposed muscle or hanging flesh. For the fertiliser loop, make the transformed good 'bones' or 'remains' as a stylised drop (bone pile, bundle), preferably from creatures and undead rather than whole humanoid bodies, and never a player avatar's body. What pushes it up: realistic corpses that persist, rot stages, visible tissue, or grinding a recognisable human body on screen.
- (4) Fighting that ends in knock-outs versus deaths. EVIDENCE: the label turns on how realistic the consequence looks, not on the word used; 'bodies disappearing the moment their health reaches zero' is the stated Mild example, and frequent combat is 'Repeated', which is Mild rather than Minimal. Jailbreak, Blox Fruits, Rivals and The Strongest Battlegrounds are all Mild with Violence Repeated/Mild. The IARC half also asks humans versus non-humans and fantastical versus realistic world. OPINION: knock-out with a dizzy state, then rescue or respawn, fits both the Mild rule and the 'needs reward, do not punish' design; creatures and undead can poof, crumble or flee. Either framing stays Mild if there is no red blood and no pain reaction. What pushes it to Moderate: realistic hit reactions ('Characters react to pain'), red blood from visible wounds (every realistic-blood survival game checked is Moderate), realistic firearms and setting, or bodies that lie as realistic corpses. Executions or finishing moves on downed humanoids are the usual route to Moderate.
- (5) Brewing, taverns and drinks with effects. EVIDENCE: any depiction, reference or use of alcohol, or a setting 'in which alcohol is common', makes the game 18+, and intoxicated behaviour is prohibited below Restricted. Games 'primarily' set in 'clubs or bars' are also 18+. Tavern Town (Mild), Run a Medieval Tavern (Minimal) and Arcane Odyssey's tavern (Minimal) show the word tavern and drink-pouring are published below Moderate; My Jazz Bar (Minimal) states all drinks are non-alcoholic. What Tavern Town's drinks are called was not found. OPINION: brewing as a deep transformation chain is fine if every product is plainly non-alcoholic: teas, tonics, juices, broths, syrups, fizzy mushroom drinks, with fermentation described as 'steeping' or 'culturing'. Give drinks buffs (warmth, stamina, night sight, mood) and call the place an inn, teahouse or canteen, or a tavern that leads with food. What pushes it to 18+: the words ale, beer, wine, mead, rum, grog, cider, or spirits; foaming tankards and wine bottles as art; any wobble, blur, slur or hiccup 'drunk' effect; a negative 'hangover' condition. There is no Mild version of alcohol.
- (6) Potions, medicines and enchantments. EVIDENCE: the questionnaire guidance says health or super-strength potions 'do not qualify as fantasy drugs'; Wacky Wizards and Arcane Odyssey (Minimal) and Deepwoken (Mild) are built on cauldron brewing. Prohibited at every label: tobacco, drugs, 'fantasy drugs that mimic lifelike drugs in appearance or behavior', 'pharmaceutical products', 'misuse of prescription or over-the-counter drugs', smoking paraphernalia, and steroids or supplements. OPINION: flasks, herbs, poultices, salves, antidotes, bandages and enchantment runes with any stat effect are safe, including harmful ones such as poison. What makes it a violation rather than a higher label: pills, syringes, powders that are sniffed, anything smoked or in a pipe, addiction, tolerance or withdrawal mechanics (a notable RimWorld feature to leave out), a euphoric or hallucination screen effect, and real drug or medicine names.
- (7) Pirates and raiders who rob and can be paid off. EVIDENCE: Jailbreak (Mild) is built on robbery, Steal a Brainrot (Minimal) on stealing from players, Pilfering Pirates is Mild, Arcane Odyssey (Minimal) has bounties. The IARC section says realistic descriptions of crimes 'e.g., robbery, kidnapping' or criminal techniques are prohibited, and the quest-log example 'Go eliminate the bandits who raided the village!' is merely a reference to violence. Community Standards list 'extortion, and blackmail' under harassment between people. OPINION: NPC raiders demanding a toll, and intercepting a delivery wagon, are safe as fantasy mild violence. A player-to-player pay-off should be a structured in-game offer (fixed buttons, in-game goods only) rather than free-text demands, so it never reads as one user threatening another; never tie it to Robux or real-world value. What pushes it up or out: realistic depiction of how to commit a crime, kidnapping or hostage mechanics on humanoids, or torture or abuse of captives or creatures (prohibited).
- (8) A fictional magic tradition loosely inspired by a real religion. EVIDENCE: the only religion rule in the questionnaire is the 16+ 'sensitive issues' descriptor, which applies when the primary theme is a current, polarising religious issue; a religious building in a city is explicitly exempt. Community Standards prohibit mocking or insulting people for 'Religion or religious affiliation or beliefs'. 99 Nights in the Forest is Minimal with cultists, churches and a summoning circle. No rule on spiritual practices or occult content as such was found. OPINION: safe at Mild if it is fully fictionalised: invented names, invented symbols, no real deities, scripture, prayers, sacred objects or clothing lifted directly, and never framed as the villain's faith. The closer it tracks a living religion the more it risks a discrimination report or regional trouble rather than a label change; that regional risk is my judgement, not something I found documented.
- (9) NPC relationships and romance-adjacent friendship. EVIDENCE: any romantic theme, down to 'a quick kiss on the mouth', is 18+; Community Standards prohibit 'Romantic or flirtatious gestures, content, or communication'; 'real-world dating games' are prohibited and the IARC section defines dating games as 'Games with romantic relationship mechanics'. No Mild game with an NPC romance system was found. OPINION: there is no Mild form of romance. The most detailed safe form is RimWorld's social layer minus lovers: friendship and rivalry scores, loyalty, mentorship, family or household groupings described as kin or crew, shared-meal and gift bonuses, grief when a friend is lost. Avoid hearts, kissing, flirting lines, 'dating', spouses, weddings, and shared-bed bonuses. Bedrooms for helpers are fine as long as the game is not a social hangout and does not 'primarily' take place in private spaces.
- (10) Paid convenience items and random-outcome items. EVIDENCE: ordinary digital purchases (passes, developer products, in-game currency, power-ups) are a disclosure only and do not change the label. Paid random items are also only a descriptor, but they require numeric odds shown before purchase, every outcome to give some benefit, and gating with PolicyService ArePaidRandomItemsRestricted; the definition covers anything bought with Robux or Robux-bought currency, including 'luck boosts', 'potion for ability with random duration' and 'upgrade spell with some chance of working'. Random rewards earned by play need no disclosure. Wagering in-game items of value on chance is prohibited simulated gambling at every label. From a search summary only (page did not load): Australia sets a minimum M for games with chance-based paid items, and Roblox's IARC ratings start showing in Australia on 2027-01-26; how regional ratings affect Kids and Select eligibility was not found. OPINION: sell fixed, known items only, and keep premium currency away from anything with a roll (enchant success, crafting quality, loot crates, luck boosts). If a random paid item is ever wanted, it is allowed at Mild but adds compliance work and regional risk. No tavern dice or card games played for coins or goods.

## Not found
- Any Roblox rule that names skeletons, bones, corpses-as-items, prosthetics, implants, amputation as a mechanic, or medical procedures specifically; the documents only give the general violence, gore, blood and fear definitions.
- How IARC regional ratings (ESRB, PEGI, ACB and so on) map onto Roblox Kids and Select eligibility; the docs say only that availability follows each region's criteria.
- Whether the labels read from the API for each comparison game were self-declared or reviewer-assigned; the API does not say. Labels on older or smaller games may be inaccurate.
- Which specific content drives Rogue Lineage's and Dead Rails' Moderate labels (the limb or corpse mechanics versus other content).
- The names of the drinks served in Tavern Town; only its store description was available ('Pour drinks').
- A Mild or Minimal Roblox game with cybernetic implants as a real system. Closest matches: Sandevistan Sandbox (Minimal, about 41K visits, 'Cyberware' in title), +1 Cyborg Evolution (Mild), CYBERPSYCHOSIS (Moderate).
- A Roblox game with an NPC romance or marriage system at any label.
- Injury mechanics of Guts & Blackpowder, Fallen Survival, Apocalypse Rising 2 and Project Delta: the Fandom hostnames tried returned 404, so only their labels are reported.
- The Australian Classification Board page on gambling-like content did not load; the M-for-paid-chance and R18+-for-simulated-gambling points come from a search summary, not a page read in this run.
- Any Roblox statement on fictional religions, spiritual practices or occult themes beyond the 'sensitive issues' primary-theme rule and the anti-discrimination rule.
- A documented answer on whether typed, text-filtered player signs count as 'free-form user creation' (16+); the definition names 'Freehand drawing, painting, writing' and exempts content that 'goes through Roblox moderation'.
- Two Roblox documents disagree on cross-experience content: the Age-Restricted Content article says 16+, the content-ratings doc says 13+.
- The other parts of the original request (the Hands-On mod and Vintage Story interfaces, player-built roads, vehicle storage) were not researched in this step.

## Independent check

12 of 14 key facts confirmed.

### Facts corrected
- **partly wrong:** 6. Tobacco and drugs prohibited at every label including lifelike fantasy drugs; health/strength potions exempt; Community Standards list 'pharmaceutical products' and 'Drug, tobacco, vaping, or other smoking paraphernalia'.
  - Correction: Substance is right; attribution is slightly off. The exact phrase 'Drug, tobacco, vaping, or other smoking paraphernalia' (and 'misuse of prescription or over-the-counter drugs') is in the Age-Restricted Content policy, not the Community Standards. In the Community Standards 'pharmaceutical products' appears as an example of 'Controlled substances', not as a ban on medicine in general.
- **partly wrong:** 10. Roblox reviewers evaluate new Kids/Select-eligible games and pre-fill the IARC questionnaire; accepted IARC ratings needed by 2027-01-26 for Australia; label no longer purely self-declared.
  - Correction: The facts are right; the conclusion is a little strong. Reviewers pre-fill, but the creator can still edit the answers or retake the questionnaire, and the Help Center still says 'Content descriptors are determined by the experience creator'. Accurate wording: reviewer-proposed and moderator-checked, still creator-editable. A developer in the same thread (post 32) reports the pre-fills were inconsistent across three similar games.

### Conclusions that go beyond the evidence
- Answer 2 (limb loss, bionics, clinic): 'the system itself is fine at Mild if the game shows the state and never the act' is not supported. The only game found with the same lose-a-limb / buy-a-replacement loop (Rogue Lineage) is Moderate. Combat Warriors declares Mild while its own description says 'bloody and gory', and Save A Life! (organ swapping at Mild) has about 2M visits; both labels are creator-declared. The IARC gore definition lists 'dismemberment' with no realism qualifier, and how a 'yes' on gore converts to the Roblox label is not published. The honest position is 'unknown, plan for Moderate as the likely outcome'. Worth stating beside it: per the docs Moderate still reaches Select (9-15) and 16+ and loses only Kids (5-8).
- Brief section 2 and answer 4: 'Humanoid versus not: the Roblox label does not distinguish' and 'Either framing stays Mild if there is no red blood and no pain reaction' rest on the legacy content-maturity.md tables. Under the new questionnaire the Roblox descriptor is produced from the IARC answers (humans vs non-humans, fantastical vs realistic world, animated vs realistic style) and the mapping is unpublished. A developer in devforum 4985897 post 65 reports a WW1 team shooter with standard avatars, 'no gore, no dismemberment, no blood' that came out 'Violence (Repeated/Strong)' and Restricted while its IARC ratings were ESRB E10+ / PEGI 12 / ACB PG; no staff answer. Unverified user report, but it is direct evidence that 'no red blood, no pain reaction' is not sufficient on its own, and that a fantastical setting and non-human targets may matter to the Roblox label.
- Answer 4: 'Executions or finishing moves on downed humanoids are the usual route to Moderate' has no source. The Strongest Battlegrounds, which the brief itself cites, is Mild (Violence Repeated/Mild).
- Answer 9 (romance): 'No Mild game with an NPC romance system was found' and the advice to avoid 'spouses, weddings' overstate practice. Counter-examples from the same API: Wedding planner (universe 10769793180, Minimal, 'Suitable for everyone': 'dress the bride and groom ... watch the ceremony') and Eternal Weddings RP (9151073775, Minimal). The rule text on the legacy page does say any romantic theme is 18+, so the caution is defensible, but 'there is no Mild form of romance' is contradicted by live Minimal games, and the new questionnaire page no longer has the romance question.
- Answer 5 (brewing, taverns): the 18+ trigger list goes beyond the documents. The docs name alcohol, 'Beer or wine bottles', bars and liquor stores. 'Cider', 'foaming tankards', a 'hangover' condition and renaming fermentation are the researcher's extrapolation. Deepwoken (Mild) sells a 'Fool's Tankard' weapon and has a Tavernkeep talent category; Rogue Lineage (Moderate, not Restricted) has 'Vincent's Speakeasy' with a bartender, kegs and a drink the wiki notes is 'not alcohol, it is actually juice'. Separately, 'Games primarily set in clubs or bars are also 18+' is contradicted in practice by My Jazz Bar (Minimal), and that question is absent from the newer page. The core conclusion (name every drink as non-alcoholic, no drunk effect) is well supported; Last Call Saloon (10771021038, Mild) does exactly this with 'frontier sodas ... sarsaparilla'.
- Answers 1 and 6 (medicine): 'pills, syringes ... real medicine names' as a violation is overreach. The Community Standards ban 'Controlled substances such as pharmaceutical products and recreational drugs' and content that 'claims to offer authoritative ... treatment recommendations'; neither bans depicting generic medicine. Maple Hospital is Minimal with 'Pharmacy', 'Diagnose and Treat Illnesses' and surgery in its description. Addiction / tolerance / withdrawal mechanics as 'mimicking lifelike drugs in behavior' is a fair reading; syringes and pills as such are not named anywhere.
- Brief section 3 'Pattern (evidence): every survival game listed with realistic red blood is Moderate' is presented as an empirical finding but is a tautology of the label definitions (see fact 14). Likewise 'Corpses as items, undead, surgery, lost limbs, taverns and potions all appear at Minimal or Mild when stylised' treats creator-declared labels, several on games with under 100 players, as if Roblox had ruled on them. The docs say moderation 'may review' declarations; none of these labels is shown to have been reviewed.
- Answer 3 (undead peoples): 'since they are a people rather than monsters the fear descriptor may not even apply' is speculation; content-ratings.md lists 'Non-realistic monsters' as scary elements with no exemption for playable or friendly ones. Whether humanoid skeleton or zombie peoples count as 'humans' for the IARC target question ('Characters that look like humans') is also open and was not addressed.
- Answer 10 (purchases): the Australia paragraph came from a search summary and is incomplete rather than wrong. What the primary sources show is more decisive: paid random items are switched off for every Australian user through the Policy API (devforum 3153602), and staff say regional IARC ratings respect PolicyService (devforum 4985897 post 26). 'Allowed at Mild but adds compliance work and regional risk' should be stated as: it does not move the Roblox label, it does move regional ratings (Brazil 18+ without the API, 14+ with it), and it cannot be sold at all in Australia.
- Brief section 1: 'After 250 plays ... Roblox reviewers play it' is slightly stronger than the source, which says reviewers 'review the game's content through a variety of methods, including gameplay'. And 'the label is therefore not purely self-declared' should note the creator can still edit or retake the questionnaire.

### What the brief missed
1. Two questionnaires are live and the brief blends them. content-maturity.md (2026-11-10) has the Roblox intensity tables the brief quotes (Mild violence = 'bodies disappearing', etc.). content-ratings.md (2026-11-18) is the IARC-based questionnaire now used; it tells creators to 'Prioritize IARC guidance', its Roblox-specific section covers only social hangout, free-form creation, sensitive issues, cross-experience content, AI interaction and media, and it does not publish how IARC answers become Minimal/Mild/Moderate. The DevForum announcement says 'For most games, this will likely match your current Roblox rating', i.e. not all. The practical design consequence (my opinion): the IARC inputs the designer controls, fantastical world, non-human or clearly non-realistic targets, animated style, unrealistic reactions, no blood or non-red particle blood, should be treated as the real levers, not just the legacy Mild wording.

2. Developer reports in devforum 4985897 (unverified, no staff resolution) that the new questionnaire rates more strictly than the old one: post 65 (no-blood WW1 shooter went from under-16 availability to Restricted with 'Violence (Repeated/Strong)'), post 20 (setting blood and gore to Moderate gives PEGI 16), post 46 (hard to obtain a 'fantasy violence' descriptor; classifying horror elements changed the violence descriptor).

3. Paid random items regionally: ArePaidRandomItemsRestricted returns true for all Australian users since 2024-09-20 (https://devforum.roblox.com/raw/3153602/1) and the same restriction applied earlier to UK users under 18. A user in 4985897 post 56 reports paid item trading, not random items, is what produced an ACB M rating in their preview. Staff post 24: a Kids and Select game without an IARC rating in Australia 'will be available for 16+'.

4. Cost of missing Mild: Moderate still reaches Roblox Select (9-15) and 16+; only Roblox Kids (5-8) is lost (kids-and-select.md: Select = 'Minimal, Mild, or Moderate (9+)'). The brief never states this, and it changes how much design to give up for the limb-loss and realistic-injury systems.

5. All API labels are creator-declared (Help Center: 'Content descriptors are determined by the experience creator'); the docs say inaccurate labels can be replaced or removed and repeated inaccuracy is moderated. The comparison-game table shows tolerance, not approval. A new game, unlike these, will go through the reviewer pre-fill at the Kids and Select gate.

6. Asset-level rule the brief does not mention: both docs warn 'Additional rules apply for assets you upload ... Realistic or excessive depictions of violence, blood, crude humor, or romantic themes may be moderated regardless of your game's content maturity label.' Meshes and images for wounds, stumps, corpses or organs are judged at upload, separately from the label.

7. Extra same-day precedents: Last Call Saloon - Western Bartender (Mild; bar with sodas and sarsaparilla, 'Poker Night' event, only 1.7K visits); Run a Monster Tavern (Minimal); Wedding planner and Eternal Weddings RP (Minimal); Criminality (Moderate, Blood Light/Realistic).

Not verified in this run: Deepwoken's Bleed status and cauldron alchemy (only the Sawbones 'reputation for amputation' dialogue line was confirmed), the 99 Nights 'Undead class' (an 'Undead' wiki page exists, content not read), Tavern Town's drink names (still not found), and the Australian classification.gov.au page (timed out; the minimum-M rule for paid chance-based purchases since 2024-09-22 came from search results only).


---

# C. Transport, roads and building on vehicles

## Movement, player-made routes and building on carriers: Roblox precedents and engine facts

Live player counts and server sizes are from Roblox's games API (`games.roblox.com/v1/games?universeIds=…`) and search API (`apis.roblox.com/search-api/omni-search`), read 2026-11-18/19. Wiki pages were read through each wiki's `api.php`. Anything marked "not found" was searched for and not confirmed.

### 1. Player-made paths that things follow

| Game (live players, server size) | How the path is laid | Limits | How followers move |
|---|---|---|---|
| Theme Park Tycoon 2 (1,989; 6) | Basic editor: tap direction and piece buttons, one segment at a time. Advanced editor: drag rings and arrows on a spline node ([wiki](https://tpt2.fandom.com/wiki/Advanced_coaster_creator)) | 80 rides per park; "Track has too many pieces"; "maximum spline count" (numbers not given); save-size cap in MB ([wiki](https://tpt2.fandom.com/wiki/List_of_error_messages)) | Developer, 2015: ride "animations are all CFramed", guest logic is server-side and "fairly lightweight" ([post](https://devforum.roblox.com/raw/19121/16)) |
| Overfreight! (348; 8) | Free-form track editor showing height, length, gradient and top speed; tunnels and bridges generated automatically ([wiki](https://overfreight.fandom.com/wiki/Track_Editor)) | Turns over 25° refused; grade ±17%; 4 parallel tracks ([wiki](https://overfreight.fandom.com/wiki/Rails)) | Listing says "physically simulated trains"; auto-drive on routes. Phone touch scheme: not found |
| DigCrew (3,203; 8; peak 7,622 on 2026-11-15) | Listing: "HIRE DRIVERS and draw their haul routes", "EASY or SIM controls on phone, PC and controller" ([tracker](https://rivalducks.com/apps/radar/games/10770299564-digcrew)) | Not found | Hired drivers run the player's trucks. How drawing works: not found |
| Mini Cities 2 (91; 6), Mini City Tycoon (729; 9) | Listings: curved and free-place roads | Not found | "AI cars and npcs navigate around your city" |
| Retail Tycoon 2 (576; 6), Restaurant Tycoon 3 (4,553; 6) | Player-built plots | Not found | Pathfinding implementation: not found |

Engine fact behind "a vehicle on a road is one object moved along a line": a Roblox-published guest article puts client receive at about 50 KB/s, each moving physics object at 0.4–0.9 KB/s, so "a rough safe budget of around 40-60 physics assemblies". Its fix is to hold movers as server data, send events, and move them on each client ([article](https://devforum.roblox.com/raw/3127146/1)). The article is from 2024; the June 2026 physics replication change may have shifted the numbers.

### 2. Building on moving platforms

| Game (live players, server size) | How pieces stay on | Limits and failures | Walking while moving |
|---|---|---|---|
| Build A Boat For Treasure (8,463; 7) | Grid blocks, anchored while building, un-anchored at launch; phones get a "speed build" mode ([wiki](https://build-a-boat-for-treasure.fandom.com/wiki/Building_Tool)) | "Welded blocks will move as one object; a properly built 10,000+ block ship will move about as fast as a 10 block ship"; loose blocks and unseated players slow it ([wiki](https://build-a-boat-for-treasure.fandom.com/wiki/Boats)) | Possible, but unseated players are named as a slowdown |
| Plane Crazy (2,907; 12) | Blocks on a plot | Plot is 51×51×39 blocks ([wiki](https://plane-crazy.fandom.com/wiki/Player_build_plots)) | Not found |
| Dead Rails (15,711; 16; rated Moderate) | Loose items are welded to the train or a horse cart; "Items must be welded to keep them from falling off" ([wiki](https://deadrails.fandom.com/wiki/Train)) | Many welded items: "servers may be unable to keep up", players drift; overloaded horse carts "glitch out" and lose everything ([bugs](https://deadrails.fandom.com/wiki/Bugs_and_Glitches), [cart](https://deadrails.fandom.com/wiki/Horse_Cart)) | Yes, on a train at 65 studs/s; phones drive with Forward/Backward |
| 100 Days at Sea (12,251; 27) | Items dropped on some boats "move with the boat" ([wiki](https://100-days-at-sea-roblox.fandom.com/wiki/Boats)) | Not found | Yes, up to 8 passengers |
| Booga Booga (717; 50) | Rafts are seated vehicles; building on them not found ([wiki](https://booga-booga-roblox.fandom.com/wiki/Rafts)) | Rafts vanish after 5 minutes unused | Seated |

A Dusty Trip (8,225; 25): mechanics not found. ARK-style platform saddles or buildable airships on Roblox: not found.

**What Roblox says.**
- An assembly of welded parts is one rigid body; the docs' example is a 179-part ship ([docs](https://create.roblox.com/docs/physics/assemblies.md)).
- Since 2018, characters on a moving platform replicate "in local-coordinates of the platform". It relies on the Humanoid's floor detection, small objects don't count, and platforms driven by BodyGyro/BodyPosition or constrained to anchored parts may make characters vibrate ([staff post](https://devforum.roblox.com/raw/183385/1)).
- That support is for physically simulated platforms. For CFramed platforms, a developer described the method passed to Jailbreak's developer: multiply the root part's CFrame by the car's movement each frame, and place other players from a relative CFrame sent by the server ([post](https://devforum.roblox.com/raw/236339/11)).
- Staff, July 2026, on a player in a pickup bed destabilising the truck: "a very long standing issue with essentially any kind of moving platform and multiple Humanoid based characters". The two fixes named are the Character Controller Library and Server Authority; "Putting the Humanoid in the Physics HumanoidState will disable all forces" ([thread](https://devforum.roblox.com/raw/4759663/4)).
- The Character Controller Library (full release 2026) conserves momentum, so "You no longer have to manually script complex CFrame math to keep players from 'sliding' off moving platforms or vehicles". NPC support is "coming soon" ([post](https://devforum.roblox.com/raw/4565267/1)).
- Server Authority (full release 2026) keeps vehicles server-owned with client prediction. It requires streaming and fixed simulation, predicts whole assemblies, costs up to 6.25× simulation on a misprediction at 100 ms, and has known drift on complex vehicles ([release](https://devforum.roblox.com/raw/4727993/1), [deep dive](https://devforum.roblox.com/raw/4624565/1)).
- Improved physics replication rolled out 2026-06-15; an opt-out still existed on 2026-07-14 while bugs were fixed ([post](https://devforum.roblox.com/raw/4675512/1)).

### 3. Movement modes on phones

| Mode | Shipped examples (live players) | Touch scheme found | Complaints found |
|---|---|---|---|
| Land vehicle | Jailbreak (15,172), a dusty trip (8,225), ER:LC (4,216), DigCrew | Jailbreak: joystick plus on-screen buttons ([wiki](https://jailbreak.fandom.com/wiki/Controls)); DigCrew offers "EASY or SIM" | Not found |
| Train on rails | Dead Rails | Forward accelerates, Backward brakes | None about controls |
| Boat | Fisch (45,803), 100 Days at Sea | Not found | Not found |
| Submarine | Fisch | Not found | Ascend/descend can stick; hard to get unstuck; players flung on exit ([wiki](https://fisch.fandom.com/wiki/Submarine)) |
| Helicopter | War Tycoon (4,130) | Throttle slider, arrow buttons, drag to look, separate hover and taxi modes ([wiki](https://war-tycoon-roblox.fandom.com/wiki/How_to_fly_helicopters)) | Wiki: "quite confusing and hard at first" |
| Glider, flying creature | Creatures of Sonaria (18,688), Dragon Adventures (6,460) | Sonaria: a movement switcher with a glide button ([wiki](https://creatures-of-sonaria-official.fandom.com/wiki/Controls)); Dragon Adventures: not found | Not found |
| Land mount | Wild Horse Islands (2,674), Horse Life (1,712) | Not found | Not found |
| Fixed-wing | Pilot Training Flight Simulator (2,713), Cabin Crew Simulator (882) | Not found | Not found |

NPCs using the same vehicles: DigCrew (hired drivers), Overfreight (auto-driven trains), the Mini City games (AI cars). Others: not found. Arcane Odyssey phone support: not checked.

### 4. Persistence outside a personal plot

- A shared world that persists across public servers: no precedent found.
- Closest found: Build Your World (15,389 live) "Builds save in FREE private servers!"; Overfreight save files with a whitelist so friends "build on the same area" ([wiki](https://overfreight.fandom.com/wiki/GUI)); DigCrew "Your pit saves exactly how you left it".
- One community-wide number across all servers: no shipped game verified. Grow a Garden's Community Garden was per server and wilted after 30 minutes ([wiki](https://growagarden.fandom.com/wiki/Community_Garden_Event)).
- The storage exists: MemoryStore is "accessible from all servers", quota 64 KB + 1.2 KB per user and 1,000 + 120 per user request units a minute, not durable, so the lasting copy belongs in a data store ([docs](https://create.roblox.com/docs/cloud-services/memory-stores.md)).

### 5. Recording a route by doing it

No Roblox game was found where an NPC repeats a trip the player demonstrated. DigCrew's drawn haul routes are the nearest.

### Answers

**(a) Can players make roads or routes? Evidence-backed for two forms, opinion for the third.**
- Laid pieces on their own plot: yes, proven in 6–9-player servers with per-player saves.
- Drawn routes across authored terrain: yes, DigCrew ships it with phone support in 8-player servers.
- Shared projects at fixed sites: no precedent, but one shared number is ordinary MemoryStore plus data store work.
- Opinion: skip free-form roads in the shared world. Nothing found does it, and it would need exactly the persistence nobody has shipped.

**(b) One carrier model? Opinion, resting on the evidence above.** Yes. A carrier is an authored body plus data: medium, speed, capacity, ride, seats, and either a deck grid or bag hooks. Two things differ in code:
- The mover: a path follower for helpers (server data, drawn by clients), and a per-medium controller for a player at the wheel.
- The attachment: deck pieces welded into one assembly, or hook slots.

Proven on phones: foot, ground vehicles, trains, boats, land mounts. Shipped but demanding: helicopters, gliding and flying creatures, submarines. Risky: free flight combined with walking on the deck.

**(c) What the building games show. Evidence-backed.** Welded piece count barely affects motion. The failures come from loose items, unseated characters and save size. Walking on a moving physical platform is engine-supported and proven at scale by Dead Rails, but characters pushing on vehicles is a known engine fault.

**(d) Prototype first. Opinion.**
1. Walking on a moving deck on a phone when the carrier is a path follower rather than a physics body. The engine's platform support does not cover this case.
2. The moment a helper's path follower is intercepted and must become a real object.
3. Drawing or demonstrating a route on a phone.
4. A deck with a few hundred welded pieces on a low-end phone.
5. Humanoid versus the Character Controller Library, and whether to adopt Server Authority, decided before core code because both change the architecture.
6. One air controller, last.

## Researcher's direct answers (several are struck or narrowed by the check below)
- (a) EVIDENCE-BACKED for two forms, OPINION for the third. Players can make routes in small non-persistent servers. Laid pieces on their own plot are proven (Theme Park Tycoon 2, Overfreight!, Mini Cities 2, all 6-9 players per server with per-player saves). Drawn routes across authored terrain are shipped by DigCrew with phone support in 8-player servers, though how its drawing works is not documented. Shared projects at fixed sites have no shipped precedent I could verify; the storage (one number in MemoryStore plus a data store) is ordinary. Opinion: do not offer free-form road laying in the shared world, because no game found persists shared-space building across public servers.
- (b) OPINION, resting on the evidence. One carrier model can cover pack, mule, cart, truck, boat, airship and platform creature: an authored body plus data (medium, speed, capacity, ride, seats, and either a deck grid or bag hooks). Two things differ in code: the mover (a path follower held as server data and drawn by clients for helpers; a per-medium controller when a player drives) and the attachment (deck pieces welded into one assembly, or hook slots). EVIDENCE-BACKED on phones: foot, ground vehicles (Jailbreak, a dusty trip, DigCrew), trains (Dead Rails), boats (Fisch, 100 Days at Sea) and land mounts (Wild Horse Islands, Horse Life) all ship with large audiences. Helicopters (War Tycoon), gliding and flying creatures (Creatures of Sonaria, Dragon Adventures) and submarines (Fisch) ship but need extra on-screen controls and draw complaints; free flight combined with walking on a deck is the risky case.
- (c) EVIDENCE-BACKED. Welded piece count barely affects motion: a welded build is one rigid body (Roblox docs), and the Build A Boat wiki claims 10,000+ blocks move like 10. The failures come from loose items, unseated characters and save size: Dead Rails slows when many items are welded on, its horse carts lose everything when overloaded, and Theme Park Tycoon 2 caps saves. Walking on a moving physical platform is engine-supported since 2018 and proven by Dead Rails at 65 studs/s with 16 players and phone support. Roblox staff call characters pushing on moving vehicles a long-standing fault, and CFramed (non-physics) platforms need a custom per-frame offset.
- (d) OPINION. Prototype in this order: 1) walking on a moving deck on a phone when the carrier is a path follower rather than a physics body, since the engine's platform support does not cover that case and it is where the 'deliveries are real path followers' and 'vehicle is a moving plot' ideas meet; 2) the hand-over when a helper's path follower is intercepted and must become a real object; 3) drawing or demonstrating a route on a phone (no demonstrated-trip precedent exists); 4) a deck with a few hundred welded pieces on a low-end phone; 5) Humanoid versus the Character Controller Library, and whether to adopt Server Authority, decided before core code because both change the architecture; 6) one air controller, last.

## Not found
- How DigCrew's haul routes are drawn on PC or phone, and how its hired drivers move (only the store listing line was found)
- Overfreight!'s phone touch scheme for laying track (a Korean wiki lists mobile as a platform; the game's wiki does not describe touch controls)
- Retail Tycoon 2 and Restaurant Tycoon 3 pathfinding implementation; the only hit was a 2018 forum remark that Restaurant Tycoon NPCs do not use Humanoids
- Any Roblox game with ARK-style platform saddles, or buildable airships that players walk on
- Any Roblox game where an NPC repeats a trip the player demonstrated by doing it
- Any verified Roblox game with one community-wide progress number shared across all servers (a 'global meter' in The Takeover appeared only in a search summary of a blog guide, not read directly)
- Any Roblox game where building in shared public space persists across servers; Fallen Survival and Trident Survival wikis had no usable page on wipes or persistence
- a dusty trip: how items stay in the car, piece limits, phone behaviour (no wiki found)
- Whether Dead Rails' train is physics-driven or CFramed
- Booga Booga: building structures on rafts (wiki shows rafts as seated vehicles only)
- Phone touch schemes for Dragon Adventures, Wild Horse Islands, Horse Life, Fisch boats, Pilot Training Flight Simulator, Cabin Crew Simulator, Plane Crazy and Emergency Response: Liberty County
- Arcane Odyssey phone support (not checked)
- Exact track piece and spline count limits in Theme Park Tycoon 2 (errors exist, numbers not given)
- Create a Cart Ride! and Build a Roller Coaster mechanics (only listings and player counts read)
- Experience-guidelines API was not queried; maturity labels come from the Roblox search API's contentMaturity field

## Independent check

13 of 14 key facts confirmed.

### Facts corrected
- **partly wrong:** 11. Overfreight! (348 live, 8 per server, 16.4M visits): free-form track editor with automatic tunnels and bridges, refuses turns over 25 degrees, grade limit 17%, 4 parallel tracks, whitelisted friends build in the same saved area.
  - Correction: Everything holds except the 25-degree rule, which the brief states more firmly than the source allows. The wiki sentence is self-contradictory: 'make sure the angles is more then 25 degrees or else the train refuses to go and say "the turn is too sharp (>25°), pls fix"'. It is the train that refuses to run, not the editor that refuses the piece, and the same page then says 'You CAN use 25km/h curves if you want to save space', i.e. sharp curves are allowed and only slow trains. Treat the 25-degree figure as unclear. Confirmed: 'Tracks have a limit of 17% and -17% grade incline and decline'; 'max of 4 tracks running parallel'; 'the game automatically generates structures' (tunnels, bridges); 'Using whitelist other players can collaborate on building together'; listing: 'Invite your friends and build on the same area'. 'Free-form' is the researcher's word, not the wiki's.

### Conclusions that go beyond the evidence
- Answer (c) 'Welded piece count barely affects motion' is labelled evidence-backed but rests on one stub wiki's claim plus a docs definition, and the brief's own Dead Rails source says the opposite: 'Welding too many objects to the Train can slow down its speed and acceleration due to the increased weight and increased server-side lag', worse for multi-part items. The docs sentence ('single rigid body') says welded parts cannot move relative to each other; it says nothing about cost. What the evidence supports: welding removes per-piece physics replication, but mass, collision work and server load still grow with piece count, and nobody has published a number. The brief also files Dead Rails' slowdown under 'loose items, unseated characters and save size' when the wiki attributes it to welded items.
- Answer (c) 'Walking on a moving physical platform is ... proven by Dead Rails at 65 studs/s with 16 players and phone support'. The wiki shows it worked only after a fix ('Prior to the 21/5/2025 update, players could fall off the train by jumping'), still fails with high ping ('Players can get flung both forwards and backwards'), and nothing read says the train is a physics body using the engine's 2018 platform support rather than a custom system like Jailbreak's. 'Shipped at scale with known flaws' is supported; 'proven' and the link to the engine feature are not.
- Answer (a) 'Drawn routes across authored terrain are shipped by DigCrew with phone support'. The only evidence is two separate lines of a store description. It does not say routes are drawn on phones, does not say where routes may go, and the terrain is player-dug ('Every bucket changes the ground'), not authored. Supported: a 3,000-player game advertises drawn haul routes for hired drivers and advertises phone controls for machines. The brief itself says how drawing works was not found, so 'evidence-backed' is too strong for this form.
- Answer (a) and section 4 'no game found persists shared-space building across public servers'. I found two small counter-examples in a few minutes: Ro-Place (universe 8466218997, https://games.roblox.com/v1/games?universeIds=8466218997), whose listing says 'Draw on a big global canvas (500x500) that saves and syncs acros all servers!', with 14 visits and 0 players; and a developer's 2021 report of 'Global Build [Alpha]' where 'the map is divided into chunks, each 60 seconds every server merges the data from its chunks ... Each chunk is its own datastore key' (https://devforum.roblox.com/raw/1306125/6; that place is now unavailable). The accurate statement is 'no game with an audience was found', which still supports the opinion to avoid it but for a different reason: it has been built and went nowhere, not that it is unbuilt.
- Answer (b) 'EVIDENCE-BACKED on phones: ... boats (Fisch, 100 Days at Sea) and land mounts (Wild Horse Islands, Horse Life) all ship with large audiences'. The brief's own table says the touch scheme for boats, land mounts and fixed-wing was 'not found'. What is shown is that these games have players; that phones are a large share of them and that the vehicle controls work well on touch is inferred. Wild Horse Islands (2,674) and Horse Life (1,712) are also not large next to the others cited.
- Answer (b) 'gliding and flying creatures ... need extra on-screen controls and draw complaints'. The table records 'Not found' under complaints for Creatures of Sonaria and Dragon Adventures and no touch scheme at all for Dragon Adventures. The only complaint evidence is a how-to page's opening line about helicopters on all devices and three bug notes on a stub page about one submarine. 'Risky: free flight combined with walking on a deck' has no source at all; it is opinion and should be labelled so.
- Answer (d) item 1 and section 2 state that the engine's platform support 'does not cover' path-follower carriers as if custom per-frame CFrame code were the only route. Two other routes are in the sources: Roblox's docs say setting Velocity on an anchored part makes it carry what touches it (Jailbreak's developer used exactly this before, 'the character would move along with it. This broke down a bit on Xbox'; a community post adds it 'doesn't work if the part rotates'); and a path follower can be made a real unanchored assembly only while a player is aboard, which is the case the 2018 feature was built for. The prototype should compare three options, not assume one.
- Section 2 presents the Character Controller Library and Server Authority as 'the two fixes named' for characters disturbing vehicles. Staff said the projects 'intend to fix' it and that CCL 'should impose more realistic forces'; the developer in that thread could not get CCL working. Neither is shown to solve standing on a moving deck, and CCL does not yet support Humanoid:MoveTo, which the NPC helpers would need.
- The 2015 Theme Park Tycoon 2 quote is used as the implementation behind a current game. It is a pre-release work-in-progress post; it supports 'the developer's stated approach in 2015', not how followers move today.

### What the brief missed
1. The closest precedent to the question actually asked ("the truck has no storage object, it is just a bed") is missing: Lumber Tycoon 2 (1,251 live, 6 per server, 1.34B visits). Its wiki defines vehicles as 'machines used to transport Players and Loose Items', with open beds and trailers and 'no limit to the number of trailers that can be hitched to a truck'; cargo is held by physics, not by an inventory. Same page: 'vehicles colliding with each other are very prone to either flipping, glitching, or temporarily merging' (lumber-tycoon-2.fandom.com api.php, Category:Vehicles). This and Dead Rails are the two models to compare: loose cargo held by physics versus cargo welded on.

2. Server Authority has a direct consequence for 'a vehicle is a platform you build on' that the brief states as a fact but does not connect: prediction covers 'every part that's physically connected to it through welds, joints, or constraints', and a misprediction resimulates all of it on the client at up to 6.25x. A deck with hundreds of welded pieces under Server Authority is therefore a phone CPU question, and should be part of prototype item 4, not only item 5.

3. For one community-wide number, hash-map keys have their own limit (about 5,000 writes a minute per key) and a DevForum thread on exactly this use (https://devforum.roblox.com/t/global-progress-across-all-servers/3247735) raises write contention. Ordinary, as the brief says, but each server should batch its contribution rather than write per player action.

4. Server sizes for the phone-vehicle examples were given only as live counts. From the games API: Jailbreak 30 per server, a dusty trip 25, Fisch 20, War Tycoon 18, Creatures of Sonaria 75, 100 Days at Sea 27, Plane Crazy 12. The build-on-a-vehicle and lay-your-own-track games are all 6 to 8 per server; the drive-a-prebuilt-vehicle games run 18 to 75. That split is evidence in itself.

5. Demonstrated-route search: I also found no Roblox game where an NPC repeats a trip the player performed (one web search, not exhaustive). The brief's 'none found' stands as 'none found', not 'none exists'.

6. Housekeeping: live counts drifted 1 to 3 percent between the researcher's read and mine, which is normal. No rating line is stated in this brief; the three labels I checked through Roblox's API match (Dead Rails Moderate for repeated moderate violence, DigCrew Minimal, War Tycoon Mild).


---
