# Roblox sandbox game: read this first

Consolidated 2026-11-18 at the end of the second session. The full running notes from that day, with every user message quoted in order, are in [docs/00-notes-archive-2026-11-18.md](docs/00-notes-archive-2026-11-18.md). Read the archive when you need the user's exact words on something; this file is the current state.

## The brief (the user's words, 2026-11-18)
> I want you to make a Roblox game. I'd like you to author the majority of it to test your capabilities. Your primary goal is to make as successful of a game as possible with as high of a playercount for as long as possible as reasonable.

The user is here to help with whatever Claude can't do.

## What the user will not accept
> What im really trying to get at to you is... dont make some slop of "just do x for y"... for h o u r s. that isnt a game -- its a cashgrab. and it will die in a week.
>
> its not as easy as "copy steal a brainrot but change it to steal a dragon" or "feed a monster but feed a dragon" or "run a restaurant but instead run a tavern"

- **This outranks Roblox's discovery criteria.** The game is a sandbox in the mould of Minecraft, RimWorld, Lumber Tycoon 2 and Minecraft's Create mod, not a single loop with a rising number and not a reskin of a current hit.
- **Never name a single activity as the core.** Claude did this three times in one day (a dragon-feeding village, hauling on a yak, then "a fishing tycoon") and was corrected each time: "NOOO fish is NOT the core idea of the game!! its just one aspect that eventually blossomed out!"
- **No "Verb a Noun" titles.** The user reads them as slop. Long-lived games name a world, a role or a genre (Murder Mystery, Lumber Tycoon, Prison Life, Bloxburg).
- **Do not over-abstract.** The user: "you have this very weird abstracty non-retified un-physical way of designing things". Things in this game are physical objects and real events. Prefer the concrete, physical answer, and ask what would happen in the real world.
- **Do not impose arbitrary limits.** "Why can't you own a vat?" If a thing exists in the world, a player can make, own or take it.
- Hour-ten test (Claude's, not disputed): at hour ten a player is doing something different from hour one, chosen by them, and two players at hour ten are doing different things.

## The core of the game (confirmed by the user)
The game has no core activity. It has a core rule, the way Minecraft has blocks.

> The core idea is just inputs and outputs but DIVERSE inputs and outputs, and have them be real and tangiable physical things (a cake) or real things occuring (like a service). Theres processes to change these inputs and outputs.

- **Inputs and outputs are diverse:** physical things and real events.
- **Outputs include capabilities, not only goods:** a machine, a recipe, an NPC, a service, an enchantment.
- **It is one web that happens to contain chains,** not many chains side by side. "the web exists without the player": places and peoples feed each other.
- **The same thing means different things in different contexts.** Lightning strikes down an enemy and empowers a certain people. Warmth can come from a stove, clothes, a meal, an enchantment or your race.
- **Any step can be done by you, an NPC or a friend.**
- **Tiers inside the web are fine.** "not everything has to be perfectly 'ANTI LADDER'": wooden, copper, iron and diamond pickaxes belong. Cheap tiers stay useful, top tiers cost something to get and keep, and a second use is a bonus, not a requirement.
- **It snowballs.** Once the baseline kinds of thing and a quality standard exist, each addition connects to what is there (the user's example: Minecraft's copper). A new thing should connect to at least two things already in the game.

The user's own examples, to test any design against:
- A truck (driven by you, an NPC or a friend) to a cavern to mine crystals; crystals traded to a player or faction for a machine that turns lead to gold, or an enchantment that puts lightning on a tool or weapon.
- "conflict -> battle -> death -> corpse -> fertilizer -> crops -> animals -> milk -> cheese -> pizza".
- A production town in a winter land that needs "food from the agricultural town, gold from a cowboy town, magic users to heat their factories, and pixie dust to make electronics for the robot place".
- A baked good with a very specific effect; fur from a particular creature made into armour, layered over clothes.
- A travelling hospital that heals for a price; protection bought with goods or a tax; a nomad living in a caravan who supplies a city; becoming a city's neighbour, vassal or ruler.
- RimWorld services: "someone comes to your colony and in exchange for you feeding and housing them they work for you"; "a person is injured! if you rescue and heal them their faction will reward you or this person will join!"

The most useful form for content: for each place or people, what it needs, from whom, and what it makes for whom.

## The setting
An everything-coexists world in the spirit of classic Roblox: pirates, ninjas, zombies, robots, cowboys, dragons, witches. The user's regions are examples and they have more:
- An industrial naval winter city (St Petersburg, the Netherlands, eastern Europe, the Black Sea, Alaska, the Bering Strait).
- A magical tropical rainforest (east Asian influences, waterfalls, magenta, violet and sage palettes, cats, good witches, castles).
- A pastoral country (animals, crops, burrow homes, wooden courthouses, a large market, a mountain with a Welsh-style dragon, biplanes, crystal caverns, strong relationships and rivalries). Do not use "Shire" or "hobbit" in the game.
- A cyberpunk cyborg city (a dark tech castle, a huge bunker and military, a futuristic railway, bionic implants).
- An undead bayou city of equal weight to the others (German and New Orleans influences; zombies, ghosts, skeletons, fungal people; a haunted mansion; undead livestock and earthen mounts; a river with a big waterwheel; oracles; its own magic, which should get an invented name).
- A cowboy town with gold.

## Design decisions so far
**Agreed** means the user stated or confirmed it. **Proposed** means Claude suggested it and the user has not yet said yes.

### Agreed
- **Bases use Lumber Tycoon-style plots.** A player's property saves to them and loads into a plot spot on whatever server they join. (The user's suggestion.)
- **Players use their own Roblox avatars.** Race shows through add-ons. The user's custom blocky art goes into creatures, peoples, vehicles and buildings. (The user pushed for this; Claude agreed.)
- **No predefined slots as the model of the world, and no voxel world.**
- **Storage is Minecraft-style** (slots and stack sizes), and storage needs an interface you can open. The user loves diegetic presentation.
- **The inventory screen copies Minecraft's.** The user, 2026-11-19: "if its for GUIs and we are SPECIFICALLY doing the minecraft GUI copy it". Their description of it: left click picks up the stack; clicking another slot puts it down; "if it doesnt fit (i.e. theres some already there) it keeps the leftover selected"; a right click with nothing selected "grabs half". So there is a held stack, as in Minecraft, and the click rules are a piece of their own that the screen builds on.
- **Buildings are made by placing walls, floors and ceilings,** with presets that can be placed whole and then customised.
- **Vehicles and large creatures are platforms you build on, as in ARK.** The chassis or creature is authored; what is on it is the player's. A flatbed has no storage until you put crates on it.
- **Deliveries are real.** A helper's vehicle is a real, visible thing on the road that a player or hostile AI can intercept. The user accepts abstraction only where it is unavoidable.
- **Needs reward, they do not punish.** "you get rewarded for meeting 'needs' or interacting with parts of the game and either no punishment or light punishment".
- **Bodies have parts, RimWorld-style,** so that an injury, losing a part and replacing it with a bionic one are one unified system.
- **Characters are generated, RimWorld-style,** from parameters. Ideology, family, backstory and migration are wanted eventually.
- **Machines are objects.** They can be bought with goods, earned with a service, built or stolen.
- **Materials have several real properties and gear layers.**
- **Relationships are with individuals;** a faction's stance comes from its people.
- **A service is an arrangement with an agent who has needs and behaviour,** not a body in a slot.
- **Helpers may be cheap and a bit dumb.**
- **Conflict can be added later.**
- **Shared world state as community goals** at fixed, authored sites is understood and welcome as a later addition.

### Proposed, awaiting the user
- **Spatial model:** plot tile grid for building and for helpers to walk on; authored terrain between plots; things can be set down anywhere, at rest and not simulated; physics only where it is fun (carrying, throwing, vehicles).
- **Interface:** world verbs wherever one held thing meets one target (apply, take, work, set down), and one consistent panel anchored to the object for contents, moving stacks and choosing recipes. A fixed-camera station mode in the style of the Hands-On Delight mod for a couple of flagship stations later. See docs/06.
- **Processes are spatial,** as in Create: a station acts on what is in, on or next to it.
- **Conditions come from places, weather and running stations,** and each people, creature and material has its own table of responses. Marks carry enchantments, meal effects, protection and race.
- **Transport:** one carrier model as data (what it travels on, speed, capacity, ride, what powers it, what it needs) with a deck or bag hooks; a separate movement controller per medium, added one at a time (foot, ground, water, air). A helper's route is a trip the player demonstrated once.
- **Helpers:** one job each plus two needs (food, rest), walking the plot's tile grid, held as server data and drawn by clients.
- **Characters are seeded from the world, not the server,** so every server meets the same people. A player's standing with each is saved to the player. The generator carries a version number.
- **Shared world state** moves both ways (a city can decline, a bridge can be lost) and its targets scale to how many people are playing. Migration can be driven by it on a slow clock.
- **Ride quality** (fragile goods on a rough ride) as a simple deterministic rule, later; the user is wary of its feel.
- **First build:** handling on a phone with a handcart as the first home; one creature tamed by feeding; one heat-giving station and one cold place whose remedy is in reach; one machine to earn from a faction; one enchantment and one people other than the default; one caravan running between two settlements; a test harness. Runs on grey boxes. See the top of docs/05.

### Rating decisions (the user's answers, 2026-11-18)
- **No alcohol.** Any depiction or reference is 18+ on Roblox. Brewing makes teas, tonics, juices and broths. The user: "Yup thats okay!"
- **No romance mechanics.** The user never planned any. Family and household ties are fine as facts; whether the words "wife" or "husband" can appear is a grey area to settle when the rating questionnaire is filled in.
- **Stay Mild and work around it.** The user: "if its just losing a limb and romance i think we can get around that". They asked how big the ages 5-8 group is before giving it up; the research gives only that under-13s are 35% of age-checked daily users, with no figure for 5-8.
- **Death is fine at Mild** when stylised: no red blood, no pain reactions, bodies that vanish. A battle can end with someone dead.
- **Static disabilities are welcome** (the user's idea): a blind seer, a pirate with a peg leg, someone with a bionic heart or a sword arm. In the data these are permanent conditions and installed parts set when a character is generated, the same records a dynamic injury would create. Ship static ones first; add losing a part during play later, in a form that shows the result and never the act.

### Consistency rule (the user's requirement, 2026-11-18)
> keep it consistent. a player only has so much brain capacity. if you overload it with these weird conflicting systems that sound good on paper its confusing. minecraft has: left click to place/interact. right click to swing or break. then WASD/jump/crouch/sprint. everything can be an item and lots of things can be placed as blocks. all items can be dropped on the floor as an entitty

- **One rule for things, as in Minecraft: everything is an item.** The user rejected Claude's split between "inventory items" and "big placed objects" as inconsistent ("what about entire trees full of logs! or huge chunks of rock! or massive hauls of fish!").
- **Two actions:** one to use, place or interact, and one to hit or break. Plus movement.
- Before adding any system, ask whether it is a second way of doing something the player already knows how to do. If so, fold it into the existing one.

Claude's restatement of the inventory under that rule (awaiting the user's yes):
1. Everything is an item, including a machine, a crate and a vehicle.
2. Items sit in slots and stack up to that item's stack size.
3. Any item can be dropped on the ground.
4. An item that can be placed becomes a thing in the world when placed, and becomes an item again when broken or picked up. A crate keeps its contents.
5. A container is a placed item with slots. A station is a container with a process.
6. Stack size is the one knob that makes hauling matter: bulky things stack small (a machine stacks to one), and the player's own pack is small, so a truck with crates carries far more.

### Scope decisions (the user, 2026-11-18)
- **No limbs lost during a fight.** Battles are real and in real time, and the user could not see how losing a leg mid-battle would work. In a fight, bodies take conditions and are knocked out or killed. A part can be ruined by a severe untreated condition and replaced at a clinic, which is the RimWorld frostbite example.
- **Remains persist** as stylised items, so the chain from battle to fertiliser stands.
- **New characters need no special explanation.** People arrive. Claude's per-people origin stories were over-designed.
- **For the first build, skip family ties, permanent death of shared characters, and migration** ("maybe this is overkill for the MVP"). Characters are generated with a record, can be knocked out, and a player's own hires stay with the player. Because generation is seeded from the world, a recruit's brother is the same person next time and is not lost; that only starts to matter once family ties exist.

### Open decisions
1. **Server Authority, and Humanoid versus the Character Controller Library.** Claude's position in docs/07 section B2: Server Authority is not adopted, and characters stay on Roblox's default Humanoid because the library is still labelled beta. Both are looked at again with the first vehicle prototype. The user has not been asked to confirm this.
2. **The architecture itself** is no longer decided on paper. It grows from the pieces as they are joined; docs/07 is reference.
3. Later: whether a character shared by every server can die, and how.

## How we work
- Claude does most of the authoring: code, systems, building through the Studio MCP.
- The user covers art and assets, design that needs human taste, game feel, Roblox accounts and verification, phone playtests and marketing.
- **The user is an experienced programmer and systems architect** (8 years coding, about 5 years and 4,000 hours in Godot). Talk to them as one.
- **What works with this user:** ask one precise question, show reasoning, and expect to be challenged; they invite pushback ("youre free to challenge me"). What failed: handing over finished designs, panels of agents judging taste, rules derived from market research, and designing the whole architecture on paper through repeated drafts and agent reviews before any code existed.
- When you need something from the user, name the exact task.

### Authorship (confirmed: "that three tier split works for me")
| Tier | Who | What |
|---|---|---|
| The world | The user writes it; Claude does not change it without asking | Places and peoples, what each needs and makes, signature items, tone, names, the look |
| The content | Claude drafts in batches of ten to twenty definitions; the user approves, edits or rejects | Most items, recipes, creatures and machines, including the connecting pieces |
| The machinery | Claude owns it | Code, data format, numbers and timings, performance, bug fixes, tests |

The user owns the quality standard.

### How to write things (the user's lesson, 2026-11-19)
The user reviewed the first piece, a `Container` module that stored an empty slot as `false`, and then explained what the review was for. Their words:
> What I just did as this quick review was "look at it from a TOP DOWN PERSPECTIVE" and break it up into smaller and smaller tangible pieces that make sense.
>
> If you didnt have context on how something worked, how would you expect it to work as an API?
>
> The { false } has a size of 1. Even though its full of 0 items. That just doesnt make sense. If something is empty... it is empty! not false? why introduce redundant data
>
> See how godot designs its incredibly robust classes
>
> Me challenging you here was for you, not just to fix some one little module, its to notice the greater pattern and cause you to question how to write things that will make sense to you in 9 months from now. You are not trying to make something that "works right now... mostly!" you are trying to make a game. a game is very complex. it can be broken down into smaller pieces, recursively. and each of those pieces need to intuitively make sense! Without context on them
>
> If I see "restaurant" then I go inside and its actually a farm because "oh well they both do food", no that makes no sense. If I see "Restaurant, reservations [1]" and see the one reservation and its called "Empty - No Date or TIme" that makes no sense! You shouldnt have to dig heavily to understand how things work. They should be CONCRETE and intuitive

They also said: "Youre welcome and encouraged to continue coding", "You are free to continue questioning the architecture and iterating on code and all that jazz", and "Remember the original goal".

What Claude takes from it. The quotes are the user's; this list is Claude's reading:
- **Work top-down.** Start from what the game and the player do. Break that into smaller tangible pieces, and those into smaller ones. Do not start from generic helpers and work up.
- **Every piece makes sense with no context.** Its name says what it is, and its functions are the ones a stranger would guess. Claude starts every session with no memory, so the reader nine months from now is Claude.
- **Empty is empty.** No placeholder, sentinel or "empty" record standing in for nothing. That rules out `false` for an empty slot, and it equally rules out Minecraft's empty stack with a count of 0, which Claude proposed next. How many slots a thing has and how much is in them are separate facts.
- **A name is a promise.** What is inside must be what the name says. "Container" already failed this: to a Godot developer a Container is a GUI layout node.
- **Concrete.** A thing in the code is a thing in the game.
- **Godot's classes are the model** for how an interface is shaped. Read the real class reference; do not work from memory.
- **The goal is the game,** not a perfect module.
- **The stranger test** is how Claude checks a piece without the user: give a reader only the name and one line, have them write the interface they would expect, then compare. Each difference is fixed or given a reason. A reader used this way is a test subject, not a judge of taste.

### Conventions for the code (Claude's, 2026-11-19)
Drawn from Godot's class reference, FoxFabric's template (`adder.gd`, the user's own standard for the shape of a piece) and what readers with no context expected. Godot never wrote down what its verbs mean, and its inconsistencies come from that, so these are written down. The user has not reviewed them.

- **A file is one thing, named for it with a noun:** `Inventory`, `ItemStack`. No project prefix.
- **A function is `verbNoun`,** taking the thing first, then where (a slot, an item id), then how much. The noun says what it works on: `getStack` and `putInSlot` work on one slot; `addItems` and `countItems` work on the whole inventory.
- **One meaning for each verb:**

| Verb | Means | Returns |
|---|---|---|
| `new`, `open` | Makes one | It |
| `get` | Reads what is there | It, or `nil` when nothing is there |
| `set` | Replaces; `nil` removes | Nothing |
| `add` | Puts in wherever it fits | What did not fit |
| `put`, `place` | Puts into a named place | What did not fit, or how many went in |
| `take` | Takes out of a named place for the caller | What was taken |
| `remove` | Takes out wherever it is | How many were removed |
| `count` | Counts | A number |
| `has`, `is`, `can` | Asks, and changes nothing | `true` or `false` |
| `clear` | Empties | Nothing |

- **One name for each idea:** `slot` (a slot number, from 1), `itemId`, `count`, `stack`, `inventory`, `session`.
- **Nothing is `nil`.** No placeholder values and no empty records. How many places a thing has (`slotCount`) and what is in them are separate facts.
- **Values and things.** A value never changes, and its functions return new values: `ItemStack`, an item type. It is frozen, and its fields are typed `read`. A thing changes in place, through its own module's functions: `Inventory`, `InventorySession`, `Hotbar`. Its fields are typed `read` too, so that only its module assigns them.
- **Failure.** What can happen in play (no room, nothing there) is a return value. A mistake in the calling code (a slot that does not exist, an unknown item id, a negative count) raises an error that names the function, says what was wrong, shows the bad value and blames the caller. Every check comes before the first change. A count of 0 is allowed and does nothing. Functions do not check that their first argument is the thing itself; the type checker does that.
- **Moving items.** A function that moves items returns what the caller is left holding, and no item is made or lost.
- **Comments.** A file opens with one sentence saying what the thing is, then how it works, then a short example with its results. A function's comment starts with its verb ("Returns", "Adds"), says what happens when there is nothing or no room, and ends with "Raises an error if". Private helpers get clear names, not comments.
- **Tests** are plain scripts in `tests/`, mirroring `src/shared`, using `tests/Check.luau`. A check's message says what should be true. `Check.raises` also requires the error to blame the calling script.
- **A piece is done when:** every check passes; a mutation run (`python tools/mutate.py`) leaves only changes no caller could see; arguments that could never be valid raise clean errors; and readers with no context predict its behaviour from its comments.

### How the code gets built (the user's correction, 2026-11-18)
After five drafts of an architecture note and three rounds of review by agents, with no code written, the user asked:
> Why are you trying to make the entire architecture / game at once?
>
> Why wouldnt you just identify the smaller re-usable pieces you need and individually make, review, and iterate on them instead of these massive architectural changes?

- **Build small reusable pieces, one at a time.** Identify the pieces the game needs. Make one. Show it to the user as a small diff with its tests. Iterate on their review. Then make the next.
- **A piece is one module with one job,** usable by itself and pure Luau wherever it can be, in the spirit of a FoxFabric micro-addon.
- **Compose pieces only once they exist.** Shared machinery (a kernel, a message format, a save format) is introduced when two real pieces need it, as its own small reviewed piece.
- **No design document is a gate before code.** No more drafts of docs/07, and no documents sent to panels of reviewing agents.
- The four points above are Claude's reading of the user's two questions. The user has not yet confirmed the details, or the list of pieces in "Next".

### Engineering rules (the user's requirements)
> i dont want it to become unmaintanable buggy slop ... i *really* dont want to see 40k line difs and entire rewrites. take how rimworld was made its basically a solid core with lots of XML

- **Follow the philosophy of the user's FoxFabric library** (github.com/tateorrtot/foxfabric): small independent modules, each with one very specific job, that chain together by design and not by tight coupling; no heavy framework; "add don't overwrite". And Godot's best practices for engine contributors: the problem comes first, a problem must exist before it is solved (no future-proofing), to each problem its own solution, prefer local solutions, no complex canned solutions for simple problems.
- **Libraries are welcome when they earn it.** The user: "if you can find some seriously good libraries and theyre better than what youd make or atleast save you time youre more than welcome to use them! YOU are doing alot of the code authoring here its not exactly hand made so it matters a bit less". Wrap each behind a module of ours; do not adopt a framework the game is written inside.
- **The user wants the code "as maintainable and easy to understand and expand on as possible no matter what crazy feature i come up with",** and wants diagrams, not text listings, when shown structure. The kernel-plus-features layout in docs/07 was Claude's answer to that on paper (a feature is a new directory and never needs another feature's files edited). It is not built unless real pieces need it.
- **"most importantly dont tie visuals heavily to logic!"** Rules never touch an Instance; presentation is a separate layer and separate data.
- **Dependencies must not be a spider web.** The user wants to see which scripts and directories are coupled to which. The note is [docs/07-architecture.md](docs/07-architecture.md), now **draft 5, kept as reference notes. It is not a plan, and nothing in it awaits a signature.**
  - The user asked "one last check you absolutely confident and happy with this architecture?" Claude answered that it was confident in the structure. **Draft 2 then failed independent review:** all three reviewers refused to sign, with about 45 findings upheld and three blocking ([docs/09-architecture-review-draft2.md](docs/09-architecture-review-draft2.md)). The six-directory shape and the platform foundation held; the feature mechanism did not. Do not tell the user an architecture is sound before it has been reviewed.
  - **Draft 3 also failed.** It closed most findings, but all four checkers declined to approve: the fixes opened new gaps, and a cold reader found 37 problems, two blocking ([docs/10-architecture-review-draft3.md](docs/10-architecture-review-draft3.md)). No reviewer in either round found a reason to change the six-directory shape or the kernel-plus-features split.
  - **Lesson from three failed drafts:** hand-written tables of which module requires which were incomplete every time, and mechanisms described only on paper contradicted their own examples. Stop specifying module-level detail on paper. Approve the shape and rules, build a small skeleton, and let a tool print the module graph from real code.
  - **Draft 4 was checked by three agents and not approved either,** but the check narrowed the problem ([docs/11-architecture-check-draft4.md](docs/11-architecture-check-draft4.md)). Platform facts: 87 of 96 claims confirmed, none blocking. The closure checker called it close. The sign-off reader would sign the shape, and would not sign the kernel mechanism, the screen or saving. Its advice: no fifth paper round; prove the mechanism in code with two made-up features.
  - **Draft 5 is in four parts and is now reference only** (see "How the code gets built"). Part A is the shape: six directories with one-way dependencies (`lib`, `content`, `protocol`, `rules`, `server`, `client`); where they live in Roblox; definitions as rows of components checked by a validator, with component shapes and types in `protocol`; the checks, with the edge check built on `luau-lsp require-graph`; a Studio place file as the source for the map and models; eight invariants. Part B is a working design and **not for signature**: `rules` as a small kernel plus features installed in order, an action as the only way state changes, features "call down" and "react to records", no rollback (tested in code at step 2b); how state reaches the screen, with solid things as server-made Instances (a hypothesis, measured at step 4f); saving (decided at step 7a). Part C was a plan of 28 small steps, now superseded. Part D holds thirteen game-rule questions and six approvals, to be asked one at a time when a piece needs the answer. **Still in force from it:** the one-way dependency rule (A1), and everything outside `server` and `client` being pure Luau with no Roblox calls (A6).
  - **No more paper review rounds and no more drafts.** Draft 5 was not sent for a design review. A narrower check of it against its own fix list was started, then stopped unfinished when the user redirected the work, so Part B may contradict itself in places. That is acceptable for reference notes.
- **The user's test for any architecture is "can it be added".** They listed ice caves, toxic fallout, mana-heavy areas, heavy mud, rain storms, thunder clouds, mules, horses, pigs, cows, pterodactyls, boom rats, wolfmen and vampires, and said "this is all really an exercise to see 'can it be added' is the greater pattern im getting at". Section C5 of docs/07 answers each with a cost level: a row of data, a small handler in an existing feature, or a new feature directory.
- **Regions as separate servers:** the user asked whether there are "seperated worlds / hexes like in foxhole or ultimate driving where going to the edge of a map takes you to a new server", and whether that would be per region. Claude's answer: yes, one Roblox place per region with a teleport at the edge, all running the same code; not in the first build. See section C6 of docs/07.
- **The game has no name, not even a placeholder** (the user raised this). Claude suggested "Patchwork" as a working name, with "Crossroads" and "Waymeet" as alternatives; names belong to the user. Not chosen yet.
- The user is "a master with godot" and "not very familiar with roblox and lua". Explain Roblox by mapping it to Godot. Document code in Godot's style.
- **A small, stable core and everything else as data.** Adding content must never require editing the core. Say "definition" (a def), not "card".
- **No giant diffs and no rewrites.** If a core change would run past a few hundred lines, stop and show the plan first. Do not add fields or modules ahead of need; with small modules and versioned saves, adding later is an addition. (This replaces Claude's earlier idea of putting body parts and character fields in the schema from day one.)
- **Shared machinery is shown to the user before it is written.** A single piece is shown as it is made (see "How the code gets built"). This replaces Claude's earlier commitment to show the whole architecture before any core code.
- **History stays readable.** The user worries about commits "ballooning into thousands". Claude proposed a short branch per feature squashed into `main`, prefixes by area, a tag per playtest build, and a changelog. Not yet confirmed.
- All changes to authoritative state go through one code path. Strict Luau typing, Selene and StyLua clean on every commit. Core rules are pure logic with tests that run without a live game. Saves carry a version number and a migration step from the first build. The server is the authority.
- Nothing has been committed. Commit only when the user asks.

### AI-made art and text (the user's rule)
- **No AI-generated art reaches the public:** no generated meshes, textures, images, icons, thumbnails or audio in a published build. Generated assets are allowed as placeholders, kept in one tagged place, with a pre-publish check that fails if any remain.
- **Player-facing words:** Claude drafts, and the user reviews all of it before release.

## Status (2026-11-19, overnight after the second session)
- **Roblox Studio** is installed. Its MCP server is enabled, and the project has a `.mcp.json` for it (`cmd.exe /c "cd /d %LOCALAPPDATA%\Roblox && .\mcp.bat"`). **The Studio tools have never been loaded;** they need a new session with Studio open on a place. Studio's MCP permission groups were left on Allow.
- **Roblox account:** `supreme_katrine`, created 2026-11-18, can publish from 2026-11-20. The user made it as a sandbox for this project and said Claude is free to act on it. Claude still asks before any action that spends Robux; passwords and verification stay with the user. Never put the account name in a web request.
- **Toolchain:** Rokit 1.2.0 in `~/.rokit/bin` (on the user PATH; older shells need it prepended), with Rojo 7.7.1, StyLua 2.6.0, Selene 0.32.0, luau-lsp 1.70.1 and Lune 0.11.1 pinned in `rokit.toml`. The user approved Lune on 2026-11-19. In a non-interactive shell run `rokit trust <tool>` before `rokit add`. Rokit's tools only run from inside the project directory; outside it, call the exe under `~/.rokit/tool-storage/<owner>/<tool>/<version>/`.
- **Checks:** from the repository root, `lune run tools/check` runs format, lint, strict types and every test. One test alone: `lune run tests/inventory/Inventory.test.luau`. Types are checked with `luau-lsp analyze --platform=standard --flag:LuauSolverV2=true`: no Roblox globals, and the **new solver only**, because read-only fields (`read`) are a syntax error under the old solver. When the place file exists, set `Workspace.UseNewLuauTypeSolver` to Enabled, or Studio's own analysis will report "read keyword is illegal here". `python tools/mutate.py <module> <tests...>` runs mutation testing (needs Python 3).
- **Project:** `default.project.json` maps `src/shared`, `src/server` and `src/client`. `rojo build` succeeds. `src/server` and `src/client` are empty. Git is initialised on `main` with **nothing committed**; commit only when the user asks.
- **Rojo's Studio plugin:** `rojo plugin install` could not find Studio, so `Rojo.rbxm` was placed in `%LOCALAPPDATA%\Roblox\Plugins`. Unverified.
- **The community `roblox-dev` Claude plugin** is enabled. Its skills have not been reviewed.
- **Code:** five pieces in `src/shared`, all plain Luau with no Roblox calls. Their tests are in `tests/` (348 checks, all passing). **The user has reviewed none of it.**
  - `items/ItemRegistry`: every kind of item the game has, by id. One registry for the whole game, filled at start. An item type is `{ id, stackSize }`. Functions: `register`, `get` (an unknown id is an error), `has`, `all`.
  - `items/ItemStack`: some number of one item, `{ itemId = "log", count = 12 }`. A value that never changes. Its count is from 1 to the stack size, and there is no empty stack. Functions: `new`, `spaceLeft`, `isFull`, `isSameItem`, `equals`, `merge`, `split`.
  - `inventory/Inventory`: slots that hold stacks. A 3-slot inventory with 5 logs in slot 2 is `{ slotCount = 3, slots = { [2] = stack } }`; a slot that holds nothing has no entry. Functions on one slot: `getStack`, `setStack`, `takeFromSlot`, `putInSlot`. On the whole inventory: `addItems` (returns how many did not fit), `addStack`, `removeItems`, `countItems`, `hasItems`, `spaceFor`, `isEmpty`, `clear`.
  - `inventory/InventorySession`: one player's open inventory screen, rules only: the pack, another inventory if one is open, and `carried`, the stack being moved between slots (`nil` when nothing is carried). Functions named for what they do: `take`, `place`, `swap`, `quickMove` (Minecraft's shift-click), `takeCarried`, `close`. `click(session, side, slot, "left" or "right")` turns a Minecraft mouse click into those.
  - `inventory/Hotbar`: the first slots of a pack and which one is selected. Functions: `new`, `select`, `selectNext`, `selectPrevious`, `selectedStack`.
- **How these were checked, 2026-11-19:**
  - Readers with no context, first test: eight readers said what they expected from each name. Every reader asked expected `{ slotCount = 3, slots = {} }` for an empty inventory, `nil` for an empty slot, the stack size looked up from the item and never passed per call, an error for a slot that does not exist, and no empty stack.
  - Readers, second test: four readers predicted what 66 calls return. With the comments, both got 66 of 66. From function names alone, 63 and 64. Their written answers led to the present names: `put`, `add` and `set` looked alike, so functions now say whether they work on a slot or the whole inventory; `CursorStack` "is not a stack", so it became a field of `InventorySession`, the name four of five readers gave that thing; `leftClick` and `rightClick` became `take`, `place` and `swap` with `click` on top; `canMerge` became `isSameItem`; a stack's `item` became `itemId`.
  - Mutation testing: the tests catch 559 of 573 small deliberate bugs. Claude examined the 14 survivors and each changes nothing a caller could see. The run also showed the tests' own random number generator was weak; it was fixed.
  - Arguments that could never be valid: every slot number, count, item id and stack passed as data is refused with an error naming the function. The only raw errors come from passing something that is not an inventory, stack, session or hotbar as the first argument, which the type checker rejects.
  - **Not done:** the overnight agents that were to run these checks independently, and to check the research, stopped when the account's usage limit was reached. Claude ran the mutation and bad-argument checks itself. Nobody but Claude has checked the research in docs/12.
- **Claude's calls, for the user to veto:**
  - Code is grouped by game concept inside the three folders Roblox really has (`src/shared/items`, `src/shared/inventory`, and later the same names under `src/server` and `src/client`), not in the six layers of docs/07. `src/shared` holds the game's rules and no Roblox calls. Tests sit outside it in `tests/`, as FoxFabric keeps tests outside an addon's folder.
  - One global `ItemRegistry`, as RimWorld's DefDatabase and Minecraft's registries are global, because every reader wrote `ItemRegistry.get("log")`.
  - A stack holds the item's id as a string, not a reference to the item type, so a stack prints, saves and sends as it is.
  - The actions on an inventory screen are named for what they do (`take`, `place`, `swap`), not for mouse buttons. Minecraft on phones has no right click: you tap to pick a stack up and tap to put it down, and press and hold to choose an amount. The same actions serve mouse and touch. The research says to decide the remote messages in this form too, before any are written.
  - An unknown item id is an error even in a pure question such as `countItems`. Readers who saw only the names guessed 0; an error is louder when an id is mistyped.
  - An inventory's `slots` table must never be handed to a remote or a data store: Roblox drops or re-keys tables with gaps. The plain form for saving and sending is `{ slotCount = 9, stacks = { { slot = 2, itemId = "apple", count = 3 } } }`, converted in one place. Not built yet.
- **Architecture note:** docs/07 draft 5 is reference only. Three rounds of paper review are recorded in docs/09, 10 and 11.
- **The user reported the moderation fixed later the same evening** ("Fixed the moderation thing"); Claude has not verified it. Background:
- **The Roblox account was moderated on 2026-11-18** (evening, local time). Studio could not open any place ("Failed to fetch place info"), and its log shows every request refused with HTTP 403 and the message `User is moderated`. The user's blank experience disappeared for the same reason. Claude has never touched Studio or the account (the Studio tools never loaded) and cannot see the reason. **The user has to sign in at roblox.com to read the moderation notice.** Nothing can be built in Studio on this account until that is resolved. Studio logs are in `%LOCALAPPDATA%\Roblox\logs`.

## Next
The game from the top down. Each line is a tangible thing, and the lines indented under it are its parts. The names of things not built yet are the ones readers with no context gave them from plain descriptions (five readers; the count that chose each name is in docs/12).

```
The game
  Items: every thing you can hold
    ItemRegistry      every kind of item, by id                        built
    ItemStack         some number of one item                          built
    ItemDefs          the written rows that say what each item is      not started
  Inventories: places that hold items
    Inventory         slots that hold stacks                           built
    InventorySession  one player's open inventory screen, rules only   built
    Hotbar            the first slots, and the selected one            built
    the screen itself draws slots and sends actions                    needs Studio
  The world
    World             everything in one running copy of the game       not started
    PlayerState       one player: pack, hotbar, open session, position not started
    GroundItems       stacks lying on the ground, picked up, dropped   not started
  Plots and building
    Plot              a player's grid of tiles                         not started
    PlacedItem        one thing placed on it: item, tile, facing       not started
    Footprint         the tiles a kind of item covers, and turning it  not started
  Stations and recipes
    Recipe            inputs become outputs after a time at a station  not started
    Station           a placed thing that runs recipes                 not started
  SaveData: a player's pack and plot as plain data with a version      not started
  Playing it: movement, Use and Hit, screens, phone first              needs Studio
  Later: conditions, creatures, people, carriers, places, bodies and needs
```

1. Get the user's review of the five pieces, the conventions, and Claude's calls listed in Status.
2. Carry on down the tree one piece at a time. For each: write the calling code first; ask readers with no context what they expect from the name; build it with tests; then run the checks listed under "A piece is done when".
3. Be sparing with agents. The overnight run used the account's whole usage limit. Reader tests are cheap (no tools). Do mutation and bad-argument checks in the session.
4. In a new session, confirm the Studio tools load. Nothing on the Roblox side has been written, because it cannot be run without them.
5. First things to prototype on a real phone: handling and carrying; walking on a moving deck; an intercepted delivery becoming a real object; demonstrating a route by touch; a deck of a few hundred welded pieces.

## Asked of the user, not yet answered
- Their review of the five pieces in `src/shared`, the conventions under "How we work", and Claude's calls listed in Status.
- For each place or people they picture: what it needs and what it makes.
- One Blockbench model with a stepped animation, in `assets/`, as glTF or FBX plus the `.bbmodel`, to test the art pipeline.
- Budget for a small ad test and for the 1,000 Robux fee that lets under-16s see the game later.
- Personal or group ownership, and a brand name.
- Whether they have a cheap Android phone to test on.
- What the empty `chooms-gonna-flatline/` folder is for.

## Roblox facts that constrain the design
Details and sources are in the docs. Roblox changed these roughly monthly through 2026; check the live docs page before relying on a number.
- **New games are shown first only to age-checked 16+ users.** Under-16s unlock after 250 plays by highly engaged 16+ players within 60 days (a drop to 100 was announced), or a refundable 50,000 Robux expedited review.
- **Home ranking** weighs play-through from the thumbnail, leaving within 60 and 180 seconds (negative), play days across days 1, 2-7 and 8-28, playtime up to 60 minutes a day, deliberately playing with friends, and days on which a player spends. Players acquired through ads never count.
- **Only near-identical copies are suppressed** as non-unique.
- **Servers stop when empty,** hold at most 200 players, and long-lived building games run 6 to 12. Progress saves to the player. A few shared numbers across servers are feasible; a shared live world is not.
- **Most play is on phones.** Do not rely on text chat, which is age-gated.
- **The higher 18+ payout rate** needs R15 avatars, or custom characters with enough joints, or no visible avatar. R6 disqualifies.
- **No shipped Roblox game keeps every good as a live physics object.** The ones that lasted make goods physical only while handled. The only budget found is roughly 40 to 60 moving assemblies in one player's view, from a community article.
- **Paid random items** need odds shown and are switched off in some regions.

## Where the research is
| File | What it is | Caveat |
|---|---|---|
| [docs/01-research.md](docs/01-research.md) | Market and tooling research; section 9 has 13 design criteria | 24 details were found wrong or stale and not corrected in the file. Its "verb + noun title" rule is rejected. Its criteria are subordinate to "What the user will not accept" |
| [docs/02-concept-research.md](docs/02-concept-research.md) | Restaurant Tycoon, Retail Tycoon, the cozy audience, precedents, platform limits, and how tower defense, colony, war and card-duel games fared | Read each brief with its independent check |
| [docs/03-concept-options.md](docs/03-concept-options.md) | Five single-activity concepts | **Rejected by the user as slop.** Kept as a record of what not to do |
| [docs/04-activity-research.md](docs/04-activity-research.md) | Fishing, factory and sea-trade games | Reference on single activities only |
| [docs/05-core-rule-design.md](docs/05-core-rule-design.md) | Four designs of the core rule-set, three judges, and research on physical objects and on how systemic sandboxes are built | The user rejected its slot-centred framing. Use its parts, its list of what the designs missed, and its grounding briefs |
| [docs/06-interaction-rating-transport.md](docs/06-interaction-rating-transport.md) | In-world interaction, what the Mild rating allows, transport and roads | Read each brief with its independent check |
| [docs/07-architecture.md](docs/07-architecture.md) | The code architecture, draft 5, in four parts | **Reference only: not a plan, nothing to sign.** In force: the dependency rule (A1) and purity (A6). Part B may contradict itself; none of it is checked against code |
| [docs/09-architecture-review-draft2.md](docs/09-architecture-review-draft2.md) | The independent review that failed draft 2: findings, referee rulings, proposed fixes | Section numbers refer to draft 2; minor findings were not refereed |
| [docs/10-architecture-review-draft3.md](docs/10-architecture-review-draft3.md) | The check that failed draft 3: what was closed, what the fixes broke, and a cold read | Section numbers refer to draft 3; not refereed |
| [docs/11-architecture-check-draft4.md](docs/11-architecture-check-draft4.md) | The check of draft 4: a sign-off reader, closure of the second review, and 96 platform claims tested (87 confirmed). Read its platform facts before a piece touches Rojo, streaming, RemoteEvents, saving or the type checker | Section numbers refer to draft 4; not refereed. Nobody confirmed that draft 5 applies every finding |
| [docs/12-grounding-for-the-first-pieces.md](docs/12-grounding-for-the-first-pieces.md) | How Godot shapes its classes, how FoxFabric is written, exactly how Minecraft's inventory behaves on PC and on phones, what Luau and Roblox do with tables that have gaps; and what readers with no context expected of the first pieces and would name the next ones | Each brief is one agent's work: the second-agent checks did not run. Nothing was run in Godot, Minecraft or Roblox |
| [docs/08-architecture-grounding.md](docs/08-architecture-grounding.md) | Engine and replication, persistence, tooling and testing facts the architecture rests on | Read each brief with its independent check; these facts change quickly |
