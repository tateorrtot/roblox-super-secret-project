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
- **A stack dropped on the ground vanishes after a few minutes and is never saved.** (The user's choice, 2026-11-19.) Built as five minutes.

### Proposed, awaiting the user
- **Spatial model** (a first tile grid is built, so the user can judge it by playing; see Status): plot tile grid for building and for helpers to walk on; authored terrain between plots; things can be set down anywhere, at rest and not simulated; physics only where it is fun (carrying, throwing, vehicles).
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
| `add` | Puts in wherever it fits | Given a count, how many went in; given a stack, the stack that did not fit |
| `put` | Puts into a named place | The stack that did not fit |
| `take` | Takes out of a named place for the caller | The stack taken |
| `remove` | Takes out wherever it is | How many were removed |
| `count` | Counts | A number |
| `has`, `is`, `can` | Asks, and changes nothing | `true` or `false` |
| `clear` | Empties | Nothing |
| `encode`, `decode` | Turns a thing into plain data, and back | The plain data; the thing, or `nil` and what was wrong |
| `validate` | Checks a value that came from outside | `nil`, or what is wrong with it, in words |

- **What a number or a stack returned means:** a number is how many items moved. A stack is one the caller now holds: what was taken out, or what is left of the stack that was put in.
- **Verbs from the game are used where they are plainer:** `pickUp`, `putDown`, `swap`, `drop`, `expire`, `click`.

- **One name for each idea:** `slot` (a slot number, from 1), `itemId`, `count`, `stack`, `inventory`, `session`, `position` (a point in the world, `{ x, y, z }` in studs), `now` (the present time in seconds).
- **Nothing is `nil`.** No placeholder values and no empty records. How many places a thing has (`slotCount`) and what is in them are separate facts.
- **Values and things.** A value never changes, and its functions return new values: `ItemStack`, an item type. It is frozen, and its fields are typed `read`. A thing changes in place, through its own module's functions: `Inventory`, `InventorySession`, `Hotbar`. Its fields are typed `read` too, so that only its module assigns them.
- **Failure.** What can happen in play (no room, nothing there) is a return value. A mistake in the calling code (a slot that does not exist, an unknown item id, a negative count) raises an error that names the function, says what was wrong, shows the bad value and blames the caller. Every check comes before the first change. A count of 0 is allowed and does nothing. Functions do not check that their first argument is the thing itself; the type checker does that.
- **Moving items.** A function that moves items returns what the caller is left holding, and no item is made or lost.
- **Comments.** A file opens with one sentence saying what the thing is, then how it works, then a short example with its results. A function's comment starts with its verb ("Returns", "Adds"), says what happens when there is nothing or no room, and ends with "Raises an error if". Private helpers get clear names, not comments.
- **Tests** are plain scripts in `tests/`, mirroring `src/shared`, using `tests/Check.luau`. A check's message says what should be true. `Check.raises` also requires the error to blame the calling script.
- **On the Roblox side** (`src/server`, `src/client`): a piece that draws is named for what it draws, ending in `Gui` on a player's machine (`SlotGui`, `HotbarGui`) and `Parts` on the server (`GroundItemParts`). It is told what to show, reports clicks through callbacks it was given, and never changes the game's state. `Main.server.luau` and `Main.client.luau` are the only scripts that run by themselves, and they join the pieces. Anything that is there only until the real thing exists has `Placeholder` in its name.
- **A piece on the Roblox side is done when** `python tools/playtest.py` passes, with a step added for what the piece does.
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
- The user approved committing as work is done (2026-11-19). Nothing is pushed; push only when the user asks.

### AI-made art and text (the user's rule)
- **No AI-generated art reaches the public:** no generated meshes, textures, images, icons, thumbnails or audio in a published build. Generated assets are allowed as placeholders, kept in one tagged place, with a pre-publish check that fails if any remain.
- **Player-facing words:** Claude drafts, and the user reviews all of it before release.

## Status (2026-11-19, the end of the overnight build)
- **There is a first playable loop.** Press Play in Studio and you appear on a grey plot with a hotbar along the bottom. Stacks of items lie about, and walking over one picks it up. E opens the pack, an inventory screen that works as Minecraft's does. Clicking the crate on the plot opens it above the pack. A left click picks a stack up or puts it down, a right click takes half or puts one down, a double click gathers a kind into the carried stack, Shift and a click sends a stack to the other inventory (or between the hotbar and the rest of the pack), a number key over a slot swaps it with that hotbar slot, a click outside the screen drops what is carried, and Q drops one of what is in hand. Walking away from the crate closes it. The plot is marked out in tiles. With a crate or a stove in hand, a faint block shows the tile it would stand on, and a left click places it there. A placed thing within reach gets a white outline under the pointer. A short right click on a placed thing knocks it off the plot: it lies on the ground as an item again, and what was in a crate spills around it. It is all grey boxes, laid out for a PC.
- **What Claude checked by playing it,** driving a test character through Studio's connector and looking at pictures: every action in the line above; that a player keeps their pack when their character dies; that ground items vanish after five minutes of real time and fresh ones turn up; and that a player who leaves while carrying a stack causes no error. **Not checked:** a phone or any touch screen; two players at once (the crate is shared and each player is sent its changes, but nobody watched two screens); a real server (in Studio there is no delay; on a real server the screen waits for the server's answer after each click and will feel a little late).
- **Nothing is saved yet.** A player's pack lasts until they leave. The shape of a save exists (`SaveData`, a pack as plain data with a version number), but nothing stores it: in Studio the server's data store calls are refused with "Studio access to APIs is not allowed", that switch is the user's, and which storage library to use is undecided (ProfileStore was not approved for download). Ground items are never saved, by the user's choice.
- **The user has reviewed none of the code.**
- **Roblox Studio** is driven from a terminal with `python tools/studio.py`. It starts Studio's own connector (`%LOCALAPPDATA%\Roblox\mcp.bat`) and talks to it directly, so it works in any session while Studio is open on a place with its MCP server enabled. Commands: `state`, `sync`, `run <file> [Server|Client]`, `play`, `stop`, `console`, `shot <file.jpg>`, `key <keys>`, `click <where>`, `tools`, `call <tool> <json>`.
  - `sync` replaces `ReplicatedStorage.Shared`, `ServerScriptService.Server` and `StarterPlayer.StarterPlayerScripts.Client` with what is in `src/`, as Rojo would. Do it in Edit mode, then `play`.
  - **Claude has not saved or published the place,** and told the user it would not. The place open on 2026-11-19 is the user's "Untitled Experience", with Studio's baseplate and spawn pad. If Studio has been closed since, open the place and `sync` again, or open `build/game.rbxl` after `rojo build -o build/game.rbxl`. The world is built by code, so the project folder alone is enough.
  - Claude told the user it would not use Studio's asset uploads, its AI generators, the Open Cloud tool or the feedback tool.
  - Facts about the connector: the mouse tool takes a GUI object's path (`LocalPlayer.PlayerGui.Inventory.Panel.PackSlot3`) or screen coordinates, not a part's path; for a part, get coordinates from `Camera:WorldToScreenPoint`. Pictures come back as JPEG. `run` works in the Edit, Server or Client data model, but cannot see a script's local variables, and the connector gives up on a call that takes minutes: for a long wait, leave a mark in the data model with one call and read it with another. In the Bash tool a heredoc turns `\\n` into a real newline, so write scripts that contain backslashes with the Write tool.
- **Roblox account:** `supreme_katrine`, created 2026-11-18, can publish from 2026-11-20. The user made it as a sandbox for this project and said Claude is free to act on it. Claude still asks before any action that spends Robux; passwords and verification stay with the user. Never put the account name in a web request. It was moderated on the evening of 2026-11-18 and working again by that night; Claude never learned why.
- **Toolchain:** Rokit 1.2.0 in `~/.rokit/bin` (on the user PATH; older shells need it prepended), with Rojo 7.7.1, StyLua 2.6.0, Selene 0.32.0, luau-lsp 1.70.1 and Lune 0.11.1 pinned in `rokit.toml`. In a non-interactive shell run `rokit trust <tool>` before `rokit add`. Rokit's tools only run from inside the project directory. Python 3 is needed for `tools/studio.py` and `tools/mutate.py`.
- **Checks:** from the repository root, `lune run tools/check` runs format, lint, strict types and every test (the user's PowerShell may need `~/.rokit/bin/lune`). One test alone: `lune run tests/inventory/Inventory.test.luau`. `python tools/mutate.py <module> <tests...>` runs mutation testing. `python tools/faces.py <out.txt> <modules...>` writes the public face of modules, to give to a reader with no context.
  - `src/shared`, `tests` and `demos` are type-checked with `luau-lsp analyze --platform=standard --flag:LuauSolverV2=true`: no Roblox globals, and the **new solver only**, because read-only fields (`read`) are a syntax error under the old one.
  - **`src/server` and `src/client` are formatted and linted but not type-checked.** luau-lsp needs Roblox's type definitions file for that, and the download has not been approved. Until it is, mistakes there are found by the play test. The rules refuse bad arguments with errors that name the function, which makes those mistakes loud.
  - **`python tools/playtest.py` is the end-to-end test of the Roblox side.** With Studio open on the place in Edit mode, it copies `src/` in, starts a play test, drives the test character with keys, clicks and walking through the whole loop (pack, dropping, picking up, the crate, placing, using and hitting), checks what the screen shows and what is in the world after each step, and stops the play test. 38 checks, about two minutes. It is PC only. Run it after any change to `src/server` or `src/client`.
- **Git:** branch `first-pieces`, committed as work is done (the user, 2026-11-19: "Yes, commit as you go"). `main` has no commits. Nothing is pushed anywhere; push only when the user asks.
- **The community `roblox-dev` Claude plugin** is enabled. Its skills have not been reviewed. Rojo's Studio plugin file was placed in `%LOCALAPPDATA%\Roblox\Plugins`, unverified and not needed while `tools/studio.py sync` is used.
- **The rules,** in `src/shared`, plain Luau with no Roblox calls, each with tests in `tests/` (923 checks):
  - `items/ItemRegistry`: every kind of item, by id. One registry for the whole game. An item definition is `{ id, stackSize }`, with `placeable = true` for an item that can stand on a plot and `slotCount` for one that holds things once placed. Functions: `register`, `get`, `has`, `all`.
  - `items/ItemStack`: some number of one item, `{ itemId = "log", count = 12 }`. A value that never changes; its count is from 1 to the stack size, and there is no empty stack. Functions: `new`, `validate`, `spaceLeft`, `isFull`, `isSameItem`, `equals`, `merge`, `split`.
  - `items/ItemDefinitions`: the written rows, one per item. Eight placeholder items so far. `items/ItemLooks`: the name and colour each item is shown with while it has no art. Nothing in the rules reads the looks.
  - `inventory/Inventory`: slots that hold stacks. `{ slotCount = 3, slots = { [2] = stack } }`; a slot that holds nothing has no entry. One slot: `getStack`, `setStack`, `takeFromSlot`, `putInSlot`. The whole inventory, or a run of its slots: `addItems` (returns how many were added), `addStack`. The whole inventory: `removeItems`, `countItems`, `hasItems`, `spaceFor`, `isEmpty`, `clear`. Plain data for saving and sending: `encode`, `decode`.
  - `inventory/InventorySession`: one player's open inventory screen, rules only: the pack, another inventory if one is open, and `carried`. Actions: `pickUp`, `putDown`, `swap`, `quickMove` (Minecraft's shift-click: to the other inventory, or between the hotbar and the rest of the pack when the pack is open alone), `swapWithHotbar` (Minecraft's number key over a slot), `gather` (fills the carried stack from every slot of its kind), `drop`, `close`; `click` turns a Minecraft mouse click into those, and `doubleClick` the second click of a double click; `hasSlot` checks a request before it is acted on.
  - `inventory/Hotbar`: the first slots of a pack and which one is selected.
  - `world/GroundItems`: the stacks lying on the ground. `drop` (a stack dropped beside its own kind joins it), `pickUpNear` (a player walking over them: nearest first, as far as the inventory has room), `expire`. A ground item cannot be picked up for 1.5 seconds, is picked up from 4 studs, and is gone after 5 minutes.
  - `players/PlayerState`: one player: a pack of 36 slots, a hotbar of 9, and the open inventory screen if any. `new`, `openInventory`, `closeInventory`.
  - `plots/Plot`: a grid of tiles and the items standing on them, one to a tile. `{ width, depth, nextId, placedById = { [id] = { itemId, x, z, inventory } } }`. `place` (returns the new id, or `nil` if the tile is taken or the item cannot be placed), `canPlace`, `remove` (returns the placed item, inventory and all), `hasTile`; `tileAt` and `tileCenter` turn a position in the world into a tile and back. A tile is 4 studs, and a player reaches a tile from 16 studs (`Plot.REACH`).
  - `save/SaveData`: what is kept of a player between visits, as plain data: `{ version = 1, pack = <encoded inventory> }`. `encode`, and `decode`, which never raises and says what is wrong with data it cannot read.
  - `Messages`: the name of every message between a player's machine and the server, with what each is sent with.
- **The Roblox side,** verified only by play tests:
  - `src/server/Main.server.luau`: the only Script. Answers the players' requests, checking each, and ten times a second runs the step (pick up, expire, redraw ground items, send changed inventories). `Remotes` makes the RemoteEvents. `world/GroundItemParts` shows ground items as blocks, and `world/PlotParts` shows placed items as blocks a tile wide and draws the lines between tiles. `world/PlaceholderWorld` builds the grey plot with a crate and a stove on it, and keeps about ten stacks lying on the plot.
  - `src/client/Main.client.luau`: the only LocalScript. Draws what the server last said and sends keys and clicks as messages; it changes no inventory itself. `inventory/StackIcon`, `SlotGui`, `HotbarGui` and `InventoryGui` draw; `ScreenScale` fits them to the window; `Remotes` finds the RemoteEvents. `world/PlotPointer` works out what the pointer is over, a placed item or a bare tile, and `world/PlacementGhost` is the faint block.
- **How the rules were checked:** tests written beside each piece; mutation testing on every rules module, with each surviving change examined and found to change nothing a caller could see; arguments that could never be valid refused with errors naming the function. Readers with no context were tested three times on the first five pieces, and once on GroundItems and PlayerState: with the comments a reader predicted 35 of 35 calls, and from names and types alone 31 of 35. On Plot: 30 of 30 with the comments, 29 of 30 without (docs/12).
- **Claude's calls, for the user to veto:**
  - Code is grouped by game concept inside the three folders Roblox really has, not in the six layers of docs/07. `src/shared` holds the rules and no Roblox calls; tests sit outside it in `tests/`.
  - One global `ItemRegistry`. A stack holds its item's id as a string.
  - The screen's actions are named for what they do (`pickUp`, `putDown`, `swap`), because Minecraft on phones has no right click. `click` is the PC mouse on top of them.
  - Asking about an unknown item id (`countItems`, `hasItems`) answers 0 or `false`; adding, removing or making a stack of one is an error.
  - Pack 36 slots, hotbar 9: Minecraft's numbers.
  - Ground items: the three numbers above, joining on drop, and that a player keeps their pack when their character dies.
  - One of Minecraft's inventory moves is not built: dragging to spread a stack over several slots.
  - **Use and Hit, first version:** Use is a left click or a tap, and Hit is a short right click (holding the right button turns Roblox's camera, so only a quick press that did not turn it counts). This follows the user's own sentence, "left click to place/interact. right click to swing or break". Hit has no touch control yet, and a tap was never tried on a touch screen. How these feel is the user's to judge.
  - **The plot is a grid of 4-stud tiles with one item to a tile,** built on the spatial model that is still only proposed. There is one plot, shared by every player, and nobody owns what stands on it: anyone can open or break anything. Reach is 16 studs, checked on the server; a player's machine marks only what is in reach, so that a click does something exactly when something is marked. A thing cannot be placed on a tile a player stands on.
  - **A crate knocked off the plot spills what was in it,** as a Minecraft chest does. Claude's restatement under "Consistency rule" says a crate keeps its contents; that needs an item that carries an inventory, which does not exist yet.
  - The server sends a player their whole inventories whenever they change, and the screen shows only what the server said. Nothing is predicted on the player's machine. The fix for the delay on a real server is known: apply the same rule locally first, since the rules are shared code.
  - Keys: E for the pack, 1 to 9 for the hotbar, Q to drop one; over a slot of the open screen, 1 to 9 swap it with that hotbar slot and Q drops from it (Ctrl and Q the whole stack, untried). The mouse wheel is left to Roblox's camera.
  - How an item looks (`ItemLooks`) is kept apart from what it is (`ItemDefinitions`).
  - The eight item rows, every name, the hint on the inventory screen and the label on the crate are placeholders and draft words.
- **Architecture note:** docs/07 draft 5 is reference only. Three rounds of paper review are recorded in docs/09, 10 and 11.

## Next
The game from the top down. Each line is a tangible thing, and the lines indented under it are its parts.

```
The game
  Items: every thing you can hold
    ItemRegistry      every kind of item, by id                        built
    ItemStack         some number of one item                          built
    ItemDefinitions   the written rows that say what each item is      built, 8 placeholder rows
    ItemLooks         the name and colour each is shown with           built, placeholders
  Inventories: places that hold items
    Inventory         slots that hold stacks                           built
    InventorySession  one player's open inventory screen, rules only   built
    Hotbar            the first slots, and the selected one            built
    InventoryGui, HotbarGui, SlotGui, StackIcon: the screens           built, PC layout
  The world
    GroundItems       stacks lying on the ground, picked up, dropped   built
    GroundItemParts   the blocks that show them                        built, placeholder blocks
    PlayerState       one player: pack, hotbar, open screen            built
    World             everything in one running copy of the game       not needed yet
  Messages: what crosses between a player's machine and the server     built
  Plots and building
    Plot              a grid of tiles and the items placed on it       built: one shared plot, one item to a tile
    PlotParts, PlotPointer, PlacementGhost: showing and pointing       built, placeholder blocks
    Footprint         the tiles a kind of item covers, and turning it  not needed until an item covers two tiles
    a plot of one's own, saved and loaded into a plot spot             not started
    walls, floors and ceilings                                         not started
  Stations and recipes
    Recipe            inputs become outputs after a time at a station  not started
    Station           a placed thing that runs recipes                 not started
  SaveData: a player's pack as plain data with a version               built; nothing stores it yet, and no plot in it
  Use and Hit: the two actions                                         first version on PC; no Hit on a phone
  Later: conditions, creatures, people, carriers, places, bodies and needs
```

1. Get the user's review: play it, then the pieces, the conventions, and Claude's calls listed in Status.
2. Carry on down the tree one piece at a time. For each: write the calling code first; build it with tests; then run the checks listed under "A piece is done when".
3. Be sparing with agents. One overnight run used the account's whole usage limit. Reader tests are cheap (no tools). Do mutation and bad-argument checks in the session.
4. The plot, and Use and Hit, were built on proposals so that the user can judge them by playing. Their answer is needed before more is built on them: walls, things that cover two tiles, a plot of one's own, and how Hit works on a phone.
5. First things to prototype on a real phone: the inventory screen by touch; handling and carrying; walking on a moving deck; an intercepted delivery becoming a real object; demonstrating a route by touch; a deck of a few hundred welded pieces.

## Asked of the user, not yet answered
- To play the build and say what feels wrong.
- Their review of the pieces, the conventions under "How we work", and Claude's calls listed in Status.
- For saving: to switch on Studio's access to data stores for the place (Game Settings, Security, "Enable Studio Access to API Services"), and to say whether the ProfileStore library may be downloaded or Claude should write the storing itself.
- Approval to download Roblox's type definitions for luau-lsp (`globalTypes.d.luau`, from the luau-lsp project, a few megabytes), so that `src/server` and `src/client` are type-checked.
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
- **Roblox's chat window lies over the top left of the screen and takes clicks there even when it has faded from sight** (seen 2026-11-19: 308 by 181 pixels in a small window). A screen of ours that may overlap it turns the chat off while it is open.
- **The strip along the top of the screen is 58 pixels high.** `UserInputService:GetMouseLocation` counts it, and so does a ScreenGui with `IgnoreGuiInset` on; `Camera:WorldToScreenPoint` and a GUI object's `AbsolutePosition` do not.
- **`require("@game/ReplicatedStorage/...")` works in Studio** (checked 2026-11-19). The code does not use it: Roblox-side requires go through `game:GetService`, which is what luau-lsp follows with a Rojo sourcemap.

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
