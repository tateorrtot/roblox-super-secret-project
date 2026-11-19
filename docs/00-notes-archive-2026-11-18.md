# Notes archive, 2026-11-18

> This is the full running notes file from the first two sessions, kept as written, including every user message quoted in order. It is long and contains superseded sections. The current state is in `CLAUDE.md` at the project root; where the two disagree, `CLAUDE.md` wins.

---

# Roblox game project: read this first

## The brief (user's own words, 2026-11-18)
> I want you to make a Roblox game. I'd like you to author the majority of it to test your capabilities. Your primary goal is to make as successful of a game as possible with as high of a playercount for as long as possible as reasonable.
>
> Zeroithly, what tools or skills do you need? Are there any claude skills or other AI tooling or context needed in order to make a roblox game?
>
> Firstly, gather and do some research as to what works and doesn't work for games and roblox games.
>
> Then we'll continue from there. This brainstorming part like any other project is probably the most crucial part of the project.
>
> I'm here to help you succeed in your goal

## The user's follow-up (written for the next session, 2026-11-18)
The user was moving to a new Claude account and asked for this message to go to the next session:
> Do you need me to install studio or csn you do it.
>
> Also id like a fresh account if possible? I'd rather this project not be linked to my main internet handle.
>
> I have a photo ID and the game is a long way from being published so not a big issue right now
>
> And for the plug-ins you want can you install them or do I need to?
>
> Clones are something we can avoid.
>
> I had some some ideas for games, like I've been playing Balloons Tower Defense 6, RimWorld, Foxhole, and Rounds. I feel like just based on that context, it's so wildly different than what you see in most Roblox games. A good idea can be created from it. I can tell you my ideas if you dont have any.
>
> Art, any assets and design that heavily requires human input, and feel i have you covered.

### What was decided in reply
- **Roblox Studio:** the user installs it, since signing in is theirs to do. The installer may already be on the machine at `%LOCALAPPDATA%\Roblox\Versions\RobloxStudioInstaller.exe`; otherwise get it from create.roblox.com.
- **Fresh Roblox account:** yes. The user creates a new Roblox account for this project, separate from their main handle, and signs Studio into it. Claude can't create accounts or handle passwords.
  - Make it early: an account must be at least 2 days old to publish.
  - Age check, ID verification, and 2-step verification come later, close to publishing. The user has a photo ID.
  - Consider a Roblox group with a brand name to own the game, so the public creator name is the group's.
- **Plugins and tools:**
  - The command-line toolchain (Rokit, Rojo, StyLua, Selene, luau-lsp) and the Rojo Studio plugin: Claude installs these, asking the user once to approve the downloads.
  - The Claude "roblox-dev" plugin: the user has to enable it on their new Claude account. Claude can bring up the install card with SearchPlugins and then SuggestPluginInstall.
- **No clones.**
- **The user covers art, assets, design that needs human taste, and game feel.** Claude covers code, systems, building, and testing.
- **Inspirations:** Bloons TD6 (tower defense), RimWorld (colony sim), Foxhole (persistent multiplayer war), Rounds (1v1 card-pick shooter). Start the brainstorm by asking for the user's ideas, bring Claude's own ideas as well, and score everything against the research doc's §9 criteria.

## The user's game idea (their own words, 2026-11-18)
Given in two messages. First, on tycoon and farming:
> How about tycoon? I know its oversaturated as a genre. Im curious about tycoon mixed with other genres. Or the other way around of other genres mixed with some tycoon. I'm mostly interested in it because of economy. Same with farming games?

Then the original idea:
> My original idea that may have been too grand was a persistent SOMEWHAT foxhole like game. However with a greater emphasis on base building, economy, vehicles, supply chains (like building a train, dockyard, or airport) and much more grounded rather than a top down game or straight up clone of foxhole. I found foxhole very interesting in its persistence and the fact multiple servers connected in a geometric way and influenced eachother.
>
> As a VERY important side note, I myself have found myself in the demographic of "nerdy teen boy" yet I'm unsure about hyper zoning in on this demographic.
>
> Animals, magic, brewing, cheese fermenting, baking, farming, npcs, relationships, interior design, landscaping, horses, fantasy, dragons, I feel these along with a general "cozy" theme fit into a female demographic and Im curious if there is any pattern between everything Im describing.
>
> The ways I can think to even remotely tie these together is ark style taming creatures, running hospitals, taverns, & hotels for travelers (like the hospitality mod in RimWorld), growing crops and animals and turning them into extremely useful items such as consumables or gear. For example making a baked good that gives fantastic very specific stat boosts or using "thrumbofur" or "muffalofur" (furs from creatures) to create very good armour.
>
> Another thing that I found incredibly interesting specifically about rimworld were its "xenotypes" (basically fantasy races). They exceled at different things each with strengths and trade offs. And it deeply tied into other systems of the game like some being good crafters, some being good miners, some being good farmers, some being good fighters, etc. Or, some xenotypes NEEDING certain consumables or environments to stay alive or reacting differently to different consumables, gear, and environments.
>
> I also oddly feel like these fantasy races are an oppurtunity to cater to non-male demographics. They, along with farming and running a hotel, somewhat remind me of stardew valley.
>
> Im finding trying to hone in on a single genre is incredibly difficult because what I am picturing in my head and trying to describe has never existed before. It is like minecraft when it came out especically during the inf-dev stages there just isnt a game to really compare it to except sandbox. Not sure if that applies to this game though.
>
> As another thorn in your side to challenge the design of this game I can picture if you have supply lines say a boat, theres a pirate faction that will raid you unless you say befriend them or pay a toll or something.
>
> Something else challenging is these supply lines and EVERYTHING else in this game, I picture them NOT as abstractions but as very real things and events in the game. I.e. if you want to go out on a journey to a distant volcano by rail you can buy a ticket or get on a ship you built and travel to it. Does this make sense?

They also asked for research on Restaurant Tycoon and Retail Tycoon.

A third message, on leaning into RimWorld's "story generator":
> I can see a story where some player "A" is fighting an AI faction sieging their base. Then, another player "B" intervenes on the side of the AI faction due to some motive like economical or needing them as a deterant to keep others away from their base. And then another player "C" helps the first player since theyre friends and allied. It turns into a fight with pirates, dragons, wizards, robots, ninjas, zombies, and everything else roblox was originally catering to with childlike wonder.
>
> However, just down the road it turns into a fight to stop reinforcements to the battle at a bridge over a cliff and river. One side may be using militaristic snipers and tanks while another is using elves and bows and magic.
>
> However military is NOT the goal of the game in anyway! Its just one aspect. And this one little conflict can say end up with key characters being killed or another player needing to mediate and be diplomatic, with some people being extremely wounded and say another faction or player comes in as a traveling hospital to aid everyone (for a price...)
>
> Arent good games designed via small scope and basic easy to understand prototypes and game loops?

A fourth message, answering Claude's worry that cozy players won't want to be raided, and that a mixed theme is expensive in art:
> "expensive in art" Not an issue
>
> couldnt they get protection in exchange for their services? Say they live near an AI or another player who will fiercely protect them, but it has some sort of price or tax. Players who say dont live in such an easy going area are rewarded in other ways such as different loot or being high risk high reward if you say live in a dangerous place.
>
> This could also tie into gear, consumables, xenotypes, etc. Say a frozen wasteline. With the right gear, xenotype, or consumables its trivially easy to live in but insanely inhospitabile for others so the competition over it is different.

The user also showed their own art: a blocky, Minecraft-proportioned cat character made in Blockbench with stepped (low-frame-rate) animation, and asked whether custom player models are better than Roblox's built-in avatars.

A fifth message, on nomads and joining factions, and on the account:
> Couldnt players be nomadic or integrate into someone elses faction? Say theres a city of mushroom people, skeletons, zombies, and ghosts. One of its purposes is to break down corpses into valuable fertilizer (input output). A player could just be a wandering mercany who lives in a mad max caravan 24/7 and supplies them with what they need. Or, they could create their own base close to them and interact heavily with them. Or, become a vasaal of them. Or become so powerful they can subjugate them.
>
> Im also not sure how this works with persistent play and multiplayer.
>
> Also yes that cat I made has knees, elbows, and a spine. Even collarbones and a neck I think?

On the Roblox account and Studio's MCP permissions: "this is a fully fresh account youre free to do anything on it I literally made this as a sandbox for you so dont worry about it!" Claude still asks before any action that spends Robux, and passwords and verification stay with the user.

Claude's reading of the fifth message: what a player owns need not be a fixed base. A caravan is a homestead that moves, and it fits Roblox better than a fixed base because saves follow the player into any server. AI settlements defined by what they need and what they produce can be identical fixtures in every server, and a player's standing with each one (stranger, supplier, resident, vassal, ruler) is saved to the player.

A sixth message, on how bases persist:
> For the bases what about lumber tycoon's aproach? Theres just a handful of "plots" and everytime you log in you cycle through and pick one. If you log off it just goes away. The main concern would be "im getting raided right now so im just going to log off bye!" Or limit attacks to be more so focused on non-player settlements
>
> Or, the bases *do* stay. Somewhat like foxhole its persistent so when you log off things still exist there. And instead of a single server for the entire physical world its many servers all connected through hexes? Im not sure
>
> Are you seriously sure to not use just built in R15 avatars?

Claude's answers (recommendations, not yet agreed):
- Start with Lumber Tycoon-style plots that load with the player. Trouble comes from AI factions and is aimed at AI settlements and routes; players pick sides. A base under attack stays loaded until the attack resolves, so logging off gains nothing.
- Persistent hex regions are a later, opt-in frontier layer, not the starting point: a small launch audience spread over hexes leaves each empty.
- Avatars: Claude reversed its earlier lean. Start with built-in R15 avatars, show race through add-ons (ears, tails, horns, skin, size), and put the user's custom blocky art into factions, creatures, vehicles and buildings. Almost every lasting hit keeps the player's own avatar. Full custom race bodies can be added later because they would sit on the same skeleton.

A seventh message, describing four regions the user pictures:
> I pictured an industrial naval winter city inspired by St Petersburg, the netherlands, eastern europe, the black sea, alaska, and the bering strait
>
> Another idea was a magical tropical rainforest inspired by east asian cultures with waterfalls, magenta violet sage and other magical palletes, cats, "good" witches, and castles
>
> A "shire LOTR" inspired place with animals, crops, hobbit holes, wooden courthouses, a large market, a huge mountain with a wales-like dragon atop, biplanes, crystal caverns, and strong relationships and rivalaries
>
> A cyberpunk cyborg filled city with a dark tech filled castle, a huge bunker and military, a futuristic railway, bionic implants

Claude's reading: each region bundles a climate, a people, goods it makes and needs, and its own transport (ships, biplanes, railway), which is the user's "train, dockyard, or airport" from the first message. The pastoral region with a dragon on its mountain is the natural setting for Feed the Dragon and the safe starting region; the other three become later regions. Use original names in the game, not "Shire" or "hobbit", which are protected.

An eighth message, objecting to the concept names:
> "Feed the Dragon" "Pack a Yak" "Run a Hero Inn" "Feed the Frontier" compare these to LONG LASTING successful roblox games. these just... sound like what most slop games are nowadays...? X the Y. X a Y.
>
> Murder mystery, lumber tycoon, prison life, bloxburg, these dont... follow that pattern they arent just slop
>
> Also hows the mushroom city fit into the regions

Claude agreed. **Do not use "Verb a Noun" titles for this game.** That rule in docs/01-research.md (§4 point 1 and §9 criterion 1) was Claude's inference from the 2025-26 spike games, which are the ones that lost about 98% of their players; it also steered the concept panel's names. Criterion 1 is one-glance clarity, which long-lived games get by naming their world, role or genre in plain words. The concept names in docs/03 are working labels only. The user wants a game in the mould of the long-lived ones, not the trend games, so judge any design by what is there at hour ten as well as minute one.

Mushroom city: Claude suggested regions are large climates and settlements like the mushroom city are smaller factions inside or beneath them; its job (turning remains into fertilizer) links fighting to farming. Keep "corpses" cartoonish (bones, monster remains, compost) for the Mild rating.

A ninth message, giving the idea's origin and correcting Claude on the mushroom city:
> Heres more context. The original worldbuilding was for a FISHING TYCOON game where you ventured out on a boat, got fish from one region, and sold it at another. Then upgraded your ship, fishing rod, bait, etc. Eventually youd be able to buy properties and then employees like retail tycoon to do tasks for you and build a factory like in miners haven or the create mod from minecraft
>
> Does that help the direction?
>
> uh no no no the mushroom city was supposed to be on par with the other factions. it was german/new orleans inspired with zombies, ghosts, skeletons, fungal people, a huge haunted mansion, undead livestock and fantastical earthern mounts, a river with a big waterwheel, mushroom and run down bayou houses and new orlean streets, oracles, voodoo magic, etc!

So there are **five regions of equal weight**: the industrial naval winter city, the magical rainforest, the pastoral dragon country, the cyborg city, and the undead bayou city. The mushroom city is the fifth region, not a faction inside another.

Claude first read this as "the fishing tycoon should be the first game". **The user rejected that firmly** (tenth message, below): fishing is one aspect that the idea grew out of, not the core. Research on fishing, factory and sea-trade games was already running when they said so; treat its results as reference for individual activities, not as the direction.

A tenth message:
> NOOO fish is NOT the core idea of the game!! its just one aspect that eventually blossomed out!
>
> "ah yes minecraft the goal is to get coal so you can sell it at a shop, then get copper and repeat, then iron, them emeralds, then diamonds, then travel to a new region and get netherite, then..." like no! dont make slop! its so much broader than that.
>
> minecraft *is* a sandbox. But you can: farm, explore, build, fight, socialize, engineer, collect resources, make a zoo. see how it blossoms out? minecraft isnt "a mining game where you just craft new things... so you can mine more to craft new things... so you can..."

**Do not name any single activity as the core of this game** (not fishing, not hospitality, not hauling, not feeding a dragon). Claude made this mistake three times in one session. The thing to design is the substrate that activities grow from, as blocks are in Minecraft. Claude's proposal for that substrate (not yet confirmed by the user): every good is a real object that can be carried, stored, given, stolen or sold; and the world is full of things that take objects in and give other objects out (crops, animals, machines, guests, whole factions, other players). Farming, zoos, factories, taverns, trade, raiding and services are all cases of that one rule.

### THE CORE OF THE GAME (confirmed by the user, 2026-11-18)
Claude asked: is "real objects, and things that turn them into other things" the block? The user's eleventh message:
> YES! You are heading so much further in the right direction! This is a VERY expandable and diverse system.
>
> The core idea is just inputs and outputs but DIVERSE inputs and outputs, and have them be real and tangiable physical things (a cake) or real things occuring (like a service). Theres processes to change these inputs and outputs.
>
> You may need to get in a truck (or have an NPC do it for you or a friend), drive into a cavern and mine some crystals. Then go drive somewhere else and trade those crystals who a player or faction who can use them in exchange for a new item. That new item might be extremely useful to you (a new machine, recipe, NPC, or service, that can process lead into gold; an enchantment that can be applied to a weapon or tool to infuse it with lightning; etc) and these outputs can either be used as inputs into the world (you are now turning lead to gold, or using a weapon to strike down enemies (or using that same lightning on a certain race empowers them!) or using that tool to collect material better, or selling what you got in exchange for other things to other players or NPCs, or doing a ritual one of those things you got and some other inputs in order to get...)
>
> Do you see how this works! This is NOT just "feed a dragon" "dig a mountain" "steal a diamond"

What Claude takes from it:
- **Inputs and outputs are diverse:** physical things (a cake) and real events (a service).
- **Outputs include capabilities, not only goods:** a machine, a recipe, an NPC, a service, an enchantment.
- **The game as a whole is a web, not one ladder.** Any output can become an input somewhere else, in several directions, with loops.
- **Tiers inside the web are fine** (the user's twelfth message, calibrating Claude): "not everything has to be perfectly 'ANTI LADDER'. take minecrafts design. Leather boots may seem like the absolute worse set of boots in the game. But you can dye them or walk on powdered snow. And not everything has to have a secondary use (although it should). Wooden pickaxes, copper pickaxes, iron pickaxes, diamond pickaxes all perfectly belong in minecraft even though its very 'tiered'. Wooden pickaxes are very easy to get and serve wildly unknown emergent purposes, like players using them in minigames, diamond pickaxes are fantastic, but expensive and difficult to get and maintain." So: ordinary tiered progression is welcome, cheap tiers should stay useful, top tiers should cost something to get and keep, and secondary uses are a bonus, not a requirement. Do not over-correct into a design where nothing is simply better than anything else.
- **The same thing means different things in different contexts.** Lightning strikes down an enemy and empowers a certain race.
- **Any step can be done by you, by an NPC, or by a friend.**

- **It is one web that happens to contain chains, not many chains side by side** (the user's thirteenth message): "do keep in mind that was one insane weird web example. this is not lots of chains paralleled together its a huge web that happens to contain chains". Two more examples they gave:
  - The undead mushroom town: "conflict -> battle -> death -> corpse -> fertilizer -> crops -> animals -> milk -> cheese -> pizza".
  - The naval town: "if theyre production focused but live in a winterland maybe they need food from the agricultural town, gold from a cowboy town, magic users to heat their factories, and pixie dust to make electronics for the robot place".
  - The most useful form for content is the second one: for each people or place, what it needs, from whom, and what it makes for whom. Chains are then walks through the web. Note a sixth place appears here: a cowboy town that has gold.

### The user's corrections to the docs/05 rule-set (fourteenth message, 2026-11-18)
The user read the summary of docs/05 and rejected its abstract, slot-centred framing. In their words: "why are you so obsessed with slots and perfect abstract order", "you have this very weird abstracty non-retified un-physical way of designing things", "the slots would have to be predefined which ruins emergent gameplay no?", "lumber tycoon did amzing without slots". Treat docs/05 as raw material, not as the design. What they said, point by point:
- **Not predefined slots.** Things are physical objects in the world. Furniture and containers get used, but placement is not limited to holes a designer made.
- **"Card" is jargon.** Say definition (a def, as in RimWorld).
- **"Gives off chill" confused them.** Say a place is cold. And yes: the same condition can come from a stove, clothes, a meal, an enchantment or a race.
- **A service is not a body in a slot.** RimWorld examples: "someone comes to your colony and in exchange for you feeding and housing them they work for you"; "a person is injured! if you rescue and heal them their faction will reward you or this person will join!". The visitor wants a bed in a room, sits to eat, and walks between stations. They cited RimWorld's hospitality, gastronomy, museum and aquarium mods. So NPCs are agents with needs and behaviour.
- **Processes should be spatial and physical, like Minecraft's Create mod** (fan processing, the mixer, the deployer), not "insert into a tray".
- **A machine is just an object.** It can be bought with goods, earned with a service, or stolen. No special acquisition system.
- **No arbitrary limits.** "Why can't you own a vat?" If a thing exists in the world, a player can make, own or take it.
- **Materials have several real properties and gear layers.** A fur good against blunt hits, another that resists fire, armour worn over clothes.
- **Helpers doing trips, mining and defence need a separate vehicle entity and "a robust NPC AI"; they are "not a huge fan" of abstractions.**
- **"The web exists without the player."** Factions feed each other.
- **Relationships are with individuals,** and a faction's stance comes from its people: "People make up relationships which can then create larger abstract state relationships."
- **Conflict can be added later.**
- **Building is an open question** that depends on whether structures are preset, player-made, or block-based like Minecraft (they mention Create Aeronautics, where blocks form vehicles).
- **Commits:** small commits are fine in theory, but they need grouping so history does not become thousands of unreadable entries.
- **Player-facing text:** Claude's drafts are fine; the user reviews it all before release. (This relaxes the earlier rule. AI-generated art still must not ship.)

Claude's reply: conceded nearly all of it, and argued one thing back. The real choice is the spatial model: loose physics (Lumber Tycoon 2), a grid of cells (Minecraft, RimWorld, Create), or predefined slots (what docs/05 proposed, now dropped). Claude recommended a grid, because the user's own references are all grids and their emergence comes from adjacency, and because loose physics on Roblox phones carries real costs (docs/05 grounding brief). Claude also argued that anything nobody is watching must be simulated abstractly, since servers stop when empty, as RimWorld does on its world map. **Neither point is agreed yet.**

### The spatial model (fifteenth message, 2026-11-18; Claude's proposal awaiting the user's yes)
The user, after Claude explained why it had favoured slots: "Ah! I see why you liked slots so much! What about TerraTechs approach? Or minecrafts approach? Minecrafts approach especically feels very native and easy to understand." They worried that pure stacking makes vehicle differences pointless ("a truck with a lot of power and space but a rough bumpy bed"), floated weight and volume, mentioned Unturned's UI grid, and said "I really love diegetic ways". On helpers: "could we make it super cheap? (even if it makes theyre a bit dumb...) How does retail tycoon do it?" On buildings: "i wasnt really sure about a voxel based system for a roblox game... so i originally came up with roughly the idea of what you had where theres slots for buildings (or even just free placing them, for example ARK) and building presets that are customizable".

Claude's proposal in reply:
- **Storage is Minecraft-style:** a container has a number of slots and each kind of thing has a stack size. Shown diegetically (the goods are visible in the crate or on the truck bed), not in a UI grid. Unturned's shaped-item grid is too fiddly on a phone.
- **Vehicles matter through properties, not physics:** capacity, speed, and ride quality. Fragile goods break on a rough ride unless packed. One load number can slow a vehicle later; no separate weight and volume to start.
- **Vehicles are TerraTech-lite:** a chassis with mount cells that take modules (a bed, a stove, a cot, a crane).
- **Building is not voxel.** A plot has a tile grid; structures are snap-together pieces (as in ARK and Bloxburg) plus presets that can be placed whole and then customised. Enclosed rooms hold warmth. The same tile grid is what helpers walk on.
- **The world between plots is authored,** with no voxels. Things can be set down on the ground, at rest and not simulated.
- **Interactions with living things are not slots.** You heal a person where they lie; a bed helps.
- **Helpers are cheap, as in Retail Tycoon 2:** one job each plus two needs (food, rest), walking a tile grid on the plot, held as server data and drawn by clients; trips off the plot are computed, with the vehicle seen leaving and arriving.
- **Diegetic first:** state is shown on the object, with as few panels as a phone allows.

### Refinements to the spatial model (sixteenth message, 2026-11-18)
The user's questions and Claude's answers. Items marked agreed are things the user stated; the rest are Claude's proposals.
- **Storage needs an interface.** The user: "so... you dont open it? like theres no GUI or inventory? that doesnt make sense to me at all". Claude was wrong to say "no inventory grid". Proposal: large storage (crate, fridge, truck bed, ship hold) opens a Minecraft-style panel of stacks; small stations (pot, furnace) show their contents on the object; the object's fill level is visible from outside. Unturned-style shaped items stay out.
- **Health:** the user asked about RimWorld or Project Zomboid style health with hediffs, missing limbs, surgery and infections. Proposal: yes to conditions as data definitions (cause, visible sign, effect, cure), including implants, each cured by a specific treatment, with different peoples needing different cures. No per-limb body simulation at first. Check Roblox's maturity guidelines before designing anything like limb loss, because the rating must stay Mild.
- **Ride quality** must be a simple deterministic rule, not a physics simulation, and the user judges its feel ("i feel like via AI coding this might be unreliable so be careful im worried about the feel of it"). It is a later addition, not part of the first build.
- **Vehicles: ARK-style building on a platform replaces Claude's modules idea.** A vehicle is a small plot that moves: a platform with a tile grid taking the same stations, storage and furniture as a plot. While it moves, bodies are seated; parked, it behaves as a plot. Walking on a moving platform on phones is unproven and must be prototyped.
- **Buildings (confirmed reading of the user's question):** made by placing walls, floors and ceilings. A preset is a saved arrangement placed whole and then edited. A new player starts with a preset.
- **Deliveries are real (the user's requirement):** "it just... doesnt make sense to have this lively world where all these random events happen and then not have that thing be real. I.E. one helper is doing a delivery. they cant be intercepted by a player or another hostile helper or enemy AI". So a helper's vehicle is a real, visible path-follower on the road that can be stopped, robbed or escorted whenever the server is running. Trips are computed only while the owner's server does not exist, and that computation still includes the chance of trouble. Claude withdrew its Retail Tycoon 2 suggestion of rate-only delivery.
- **Needs reward, they do not punish (agreed, the user's words):** "you get rewarded for meeting 'needs' or interacting with parts of the game and either no punishment or light punishment". Meeting a need gives a bonus; an unmet need means no bonus or a mild slowdown, never a death spiral. Valheim's food is the reference. Needs are data, differ by people, start with two or three, and can grow toward The Sims' range later.

### Interfaces, transport and bodies (seventeenth message, 2026-11-18)
- **Interface style is open.** The user asked Claude to look at the "hands on delight" Minecraft mod and Vintage Story, and whether in-world interaction could work or a Minecraft-style panel makes more sense. Research started 2026-11-18.
- **Transport must be general.** The user: "so what if the players make roads. can they? what about planes or airships or boats or submarines or dragons or mules or gliders or helicopters or just walking by foot or cart". Claude's proposal: one carrier model as data (medium, speed, capacity, ride, what powers it, what it needs), with a separate movement controller per medium added one at a time (foot, then ground, then water, then air). A helper's route is a trip the player demonstrated once. Player-built road improvements might be shared projects at fixed sites, stored as one shared number across servers. Research started on what Roblox supports.
- **What is authored on a vehicle and what is not.** The user: "so vehicles and creatures are authored but whats on them isnt? this would also mean that say the truck, it doesnt really have storage if its just a platform bed right". Claude's answer: yes. The chassis or creature is authored (model, speed, deck size or bag hooks); storage comes from what is placed on it (crates, barrels, a fridge), and large things sit on the deck directly. Small carriers (a mule, a glider, your own back) have bag hooks instead of a deck. A vehicle can come with crates already placed, as a preset.
- **The body has parts, because implants need them.** The user: "so what about implants...? rimworlds works because its such a unified system. like if someone gets frostbite on their arm or a bad infection you cut it off and replace it with a bionic arm thats better but expensive". Claude reversed its "no per-limb body at first": the data model has body parts from day one (roughly head, torso, two arms, two legs, plus a few inner parts), conditions attach to a part or the whole body, parts have efficiency that feeds capacities such as moving and working, and a part can be replaced by an installed thing. Adding parts later would be exactly the rewrite the user wants to avoid. How limb loss can be shown at a Mild rating is being researched.

### Shared world state and characters (eighteenth message, 2026-11-18)
- **Shared world state:** the user understood Claude's bridge example as "a community goal" that "changes as the game expands" with "the entire playerbase" working toward it, noted that this makes new routes "pre-determined and authored", and asked whether it applies to more than bridges and roads. Claude's answer: yes, to anything at a fixed site that a few numbers can describe: how well supplied a settlement is, which faction holds a pass, prices, a region opening up, a monument, a festival, a plague. It should move both ways (things can decline or be lost), and targets must scale to how many people are actually playing. It is a later addition, not part of the first build. Whether any Roblox game has shipped this was being researched.
- **Characters:** the user asked whether characters should be "a set of memorable characters rather than always randomly generated. or a mix". Claude recommended a mix: a small authored cast at each settlement, the same in every server (the user writes these; world tier), plus generated travellers, guests and hired hands built from trait tables, who become the player's own and are saved to them.
- The user asked how Claude feels about the design so far. Claude's stated concerns: total scope; that a deep sandbox is a bet on lasting rather than on a high peak; and that nothing has yet been tested in Studio or on a phone. Claude also said this file needs consolidating before the next session.

### Generated characters (nineteenth message, 2026-11-18)
The user pushed back on an authored cast: "shouldnt they be randomly generated in the way rimworld handles them? Basically just a bunch of sliders and parameters changing. You can end up with a cyborg named 'Jose Xaiver' whose missing a leg, part of the 'Charity Givers' ideology, is married to some other character, and has push and pull factors for where they live, why, their background story, and what their future story is. Like where they work, where they live, and what they do. You can also get things like migration?" They asked whether that is out of scope or a future feature. They also confirmed: consolidate the notes file once the research lands.

Claude's answer: generate everyone, and seed the generation from the world, not the server, so every server meets the same people. A character is a record (people, body parts and conditions, traits, beliefs, skills, relationships to other characters, home, job, backstory tags). The record and a simple generator belong in the first build; needs, jobs and daily routine follow; ideology, marriage, family and migration are future systems that the record leaves room for. Migration can be driven by the shared settlement numbers (a starving city pushes people out) on a slow clock. A player's standing with each character is saved to the player. The generator needs a version number so that changing its tables does not change existing people.

### Claude's working summary of the vision (2026-11-18, superseded by the section above)
A persistent fantasy frontier where every player runs a homestead that makes something others need, and the stories come from who supplies, protects, taxes, raids or rescues whom. Three pillars: **place** (where you settle sets your risk and reward), **kind** (race, gear and consumables decide where you thrive), **service** (protection, healing, hauling and food are traded between players and AI factions). Small-scope first build still to be chosen.

## What the user will not accept (their words, 2026-11-18)
> I also dont want to abandon the original childlike wonder with pirates, ninjas, zombies, robots, cowboys, etc. These regions are just EXAMPLES of what could be if you need more ideas Im more than happy to spit them out.
>
> What im really trying to get at to you is... dont make some slop of "just do x for y"... for h o u r s. that isnt a game -- its a cashgrab. and it will die in a week.
>
> what im trying to make is difficult for me to pin down since it feels so broad and undefined. its not as easy as "copy steal a brainrot but change it to steal a dragon" or "feed a monster but feed a dragon" or "run a restaurant but instead run a tavern"

**This outranks the discovery criteria.** The game is a sandbox world in the mould of Lumber Tycoon 2, early Minecraft and RimWorld, not a single loop with a rising number, and not a reskin of a current hit. Claude's concept panel (docs/03) drifted into exactly what the user is rejecting, because Claude's brief over-weighted first-minute and discovery signals. Rules Claude proposed in reply (not yet confirmed by the user):
- **Hour-ten test:** at hour ten a player is doing something different from hour one, chosen by them, and two players at hour ten are doing different things.
- **Depth comes from rules that interact** (place, time, weather, price, kind, other players), not from more verbs or bigger numbers.
- **The world gives tools and needs, not a task list.** Many ways to live in it.
- First-minute simplicity is a constraint on how the game is entered, not a description of the game.
- "Small scope" means few systems that interact, not one loop.
- The setting is an everything-coexists world (pirates, ninjas, zombies, robots, cowboys). The five regions are examples; the user has more.

## How we work
- Claude does most of the authoring: code, systems, building through the Studio MCP.
- The user covers art and assets, design that needs human taste, game feel, Roblox accounts and verification, phone playtests, and marketing.
- When you need something from the user, name the exact task.
- **The user is an experienced programmer and systems architect** (8 years coding, about 5 years and 4,000 hours in Godot). Talk to them as one. They can review architecture and code.

### Authorship (confirmed by the user, 2026-11-18: "that three tier split works for me")
| Tier | Who | What |
|---|---|---|
| The world | The user writes it; Claude does not change it without asking | Places and peoples, what each needs and makes, signature items, tone, names, the look |
| The content | Claude drafts in batches of ten to twenty cards; the user approves, edits or rejects | Most items, recipes, creatures and machines, including the connecting pieces |
| The machinery | Claude owns it | Code, data format, numbers and timings, performance, bug fixes, tests |

The user owns the quality standard. A new thing should connect to at least two things already in the game.

### Engineering rules (the user's requirements, 2026-11-18)
> i dont want it to become unmaintanable buggy slop ... i *really* dont want to see 40k line difs and entire rewrites. take how rimworld was made its basically a solid core with lots of XML

- **A small, stable core and everything else as data.** The core is the rule engine (slots and holders, the two mutating functions, the process runner, aspects and responses, saving). Things, processes, peoples and places are data definitions that the core reads. Adding content must never require editing the core.
- **No giant diffs and no rewrites.** One change per commit, small enough to review. If a core change would run past a few hundred lines, stop and show the plan first. Content batches are separate commits from code.
- **Architecture is agreed before core code is written.** The user reviews the module boundaries, data schema, invariants and the server/client split.
- Strict Luau typing, Selene and StyLua clean on every commit. Core rules are pure logic with tests that run without a live game. Saves carry a version number and a migration step from the first build. The server is the authority; clients render.

### AI-made art and text (the user's rule, 2026-11-18)
> for the art i absolutely know people despise AI art and AI text so if its detectable in anyway im a bit nervous. for prototyping though and placeholders that wont hit hte public i have no issue

- **Nothing AI-generated reaches the public:** no generated meshes, textures, images, icons, thumbnails or audio in a published build.
- Generated assets (Studio's mesh and material generators) are allowed only as placeholders, kept in one clearly named place and tagged, with a pre-publish check that fails if any remain.
- **Player-facing words:** Claude drafts them and the user reviews all of it before release ("youre an LLM youre whole thing is being good at text... but ill definetly review it at the end").
- **History stays readable.** Work on a short-lived branch per feature and squash it into `main` with one descriptive commit, so `main` reads as a list of features. Prefix commits by area (core, defs, client, tools, docs), tag each playtest build, and keep a changelog. (Claude's proposal in answer to the user's worry about thousands of commits; not yet confirmed.)

## Status (as of 2026-11-18, second session)
- **Done:**
  - Tooling assessment and market research, in **[docs/01-research.md](docs/01-research.md)**. Read it before anything else. §9 has the 13 design criteria every game idea gets scored against.
  - The research doc was fact-checked this session: its hard constraints hold, but 24 details are wrong or stale and **have not been corrected in the file**. The ones that change decisions:
    - The 18+ DevEx rate is not "R15 only": custom characters and games with no visible player character also qualify. R6 still disqualifies.
    - Script Sync left beta in June 2026, so Rojo is a preference, not the default.
    - Only near-identical copies are suppressed as "non-unique"; a twist on a proven pattern is fine.
    - Ad-acquired players never count toward ranking.
    - The benchmarks describe games already at 1M+ monthly users.
    - Marketing cost figures are mostly unsourced.
  - **Roblox Studio is installed** (found running 2026-11-18).
  - **Fresh Roblox account created 2026-11-18:** `supreme_katrine`. It can publish from 2026-11-20. Never put this name in a web request.
  - The user enabled the community **roblox-dev** Claude plugin. Its skills have not been reviewed yet.
  - The user gave their game idea (section above).
  - **[docs/02-concept-research.md](docs/02-concept-research.md):** checked research on Restaurant Tycoon, Retail Tycoon, the cozy audience, Roblox precedents and platform limits. Read its summary and each section's "Independent check".
  - **[docs/03-concept-options.md](docs/03-concept-options.md):** five candidate first games, scored by three judges. Front-runners: **Feed the Dragon** (22/30, a village sharing a dragon protector) and **Pack a Yak** (21/30, hauling a visible stack to market). Claude recommends the village first with the yak as the first addition. **The user has not chosen yet.**
  - **docs/03 is superseded.** The user rejected its concepts as slop (see "What the user will not accept"). Keep it only as a record of what not to do.
  - **[docs/04-activity-research.md](docs/04-activity-research.md):** checked research on fishing, factory and sea-trade games. Reference on single activities only.
  - **[docs/05-core-rule-design.md](docs/05-core-rule-design.md): the current design work.** Four designs of the core rule-set, scored by three judges, who all converged on the same combination: things in slots of holders (no loose physics; three phone buttons; ghost outlines), process cards (takes, needs, time, gives) as the single content unit, aspects that places and running stations give off and bodies respond to, a service as a process with a body in a slot, capabilities bought in kind from behind glass, and plain tiers with odd tags. Its top section lists what all four designs missed and Claude's proposed first build. **The user has not yet seen or agreed to it.**
  - Proposed authorship split (Claude's suggestion, not yet confirmed): the user writes the world (places, peoples, what each needs and makes, tone, names, look) and owns the quality standard; Claude drafts content in batches of ten to twenty cards for the user to approve; Claude owns code, data format, numbers and tests. A new thing should connect to at least two things already in the game.
- **Next:**
  1. The user reads the rule-set summary and says whether it is their game. Then build the first build proposed at the top of docs/05.
  2. Confirm the Studio MCP tools load. The user enabled "Studio as MCP server" on 2026-11-18 and Claude wrote the project's `.mcp.json` from the JSON Studio showed (`cmd.exe /c "cd /d %LOCALAPPDATA%\Roblox && .\mcp.bat"`). It needs a new session, with Studio open on a place, to take effect. Studio's Quick connect lists "Claude Code CLI" as an alternative.
  3. **Toolchain installed 2026-11-18** (the user approved the downloads): Rokit 1.2.0 in `~/.rokit/bin` (added to the user PATH; a shell opened before the install needs `~/.rokit/bin` prepended), with Rojo 7.7.1, StyLua 2.6.0, Selene 0.32.0 and luau-lsp 1.70.1 pinned in `rokit.toml`. In a non-interactive shell, run `rokit trust <tool>` before `rokit add`. The project skeleton exists (`default.project.json`, `src/server`, `src/client`, `src/shared`, `selene.toml`, `stylua.toml`, `.gitignore`, `assets/`) and `rojo build` succeeds. `git init` is done on branch `main` with **nothing committed**. `rojo plugin install` failed (it could not find Studio's registry keys), so `Rojo.rbxm` was downloaded into `%LOCALAPPDATA%\Roblox\Plugins`; whether Studio loads it is unverified until Studio restarts. *(Further down, "The toolchain isn't installed" and "No git repo yet" are out of date.)*
  4. First build runs on grey boxes with default avatars, with a test harness (bot players, a clock that can be jumped, a director that can be forced, funnel logging).
- **Not done yet:**
  - The Studio MCP server is configured but not yet confirmed working.
  - The toolchain isn't installed.
  - No git repo yet.
  - Nothing has been built.

## Open questions for the user
1. Budget: Robux for ads; Roblox Plus or the 1,000 R$ per-game fee; the 50K R$ expedited review?
2. How much time can they give to phone testing, social clips, and Discord?
3. Personal or group ownership, and a group or brand name?
4. What is the empty `chooms-gonna-flatline/` folder for?

## Planned stack
- **Roblox Studio's built-in MCP server.** Enable it in Studio under Assistant → … → Manage MCP Servers → "Enable Studio as MCP server", then pick Claude Code under Quick connect. This gives Claude code execution, playtests, console output, viewport screenshots, input simulation, and mesh generation.
- **Rojo** for code as files, with **Rokit**, **StyLua**, **Selene**, and **luau-lsp**.
- **R15 avatars only,** to qualify for the higher US 18+ DevEx rate.
- Optional: the community **"roblox-dev"** Claude plugin, which the user enables per account.

## Hard constraints (details in the research doc)
- New games launch **only to age-checked users 16+**. Under-16s unlock after 250 plays by highly engaged 16+ players within 60 days.
- The Home ranking weighs:
  - play-through rate
  - **first-play bounce under 60s**
  - play days over Day 1, Days 2–7, and Days 8–28
  - playtime, capped at 60 min per user per day
  - intentional co-play with friends
  - spend days
- Only organic Home traffic counts toward ranking.
- Keep the content maturity rating **Mild**. No reward-for-watching media feeds. Don't rely on text chat, since it's age-gated. No clones.
