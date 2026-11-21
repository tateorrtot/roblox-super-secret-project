# Design decisions

**Agreed** means the user stated or confirmed it. **Proposed** means Claude suggested it and the user has not yet said yes.

## Agreed
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
- **The first process, cooking on the stove, works as a Minecraft furnace does,** with slots for what goes in, for fuel and for what comes out. (The user, 2026-11-19: "yes furnace style slots I like".)

- **Saving matters, and so does a plot for each player** (2026-11-20). Technically it is "multiple plots with associated owners". The owner is not always a player: "Could be a faction, a bank, a corporation, a player-made clan, a shared base/save among multiple players who knows! the owner is a bit of a black box". Many plots to buy and work through, as in Schedule 1, was turned down: it "ruins the magic of joining a server with other players and never knowing what youll get".
- **Rigid tiles, walls and ceilings are a flaw.** The user, 2026-11-20: "Id say the rigid tile, rigid walls, rigid ceilngs, etc in bloxburg is its greatest flaw." They pointed at Paralives, and at The Sims with Alt held, where an object is placed freely. How placement will work is not designed (`docs/status/next.md`).
- **Walls and floors are wanted,** as in The Sims, Bloxburg, Retail Tycoon and Paralives (2026-11-20): parts that can be customised, "using the grid as a pure guideline rather than a set boundary", and walls of other heights and thicknesses. The user sees that this "may need rethinking with the plots and placement", and that helpers must still find their way. Not designed.
- **Three kinds of process are wanted** (2026-11-20): one that works on what is inside it, as the furnace does; one worked on by what stands over it, as Create's basin is by a mixer or a press; and one that works on what is in front of it, as Create's fan does. Their words are in `placed-objects.md`.
- **A helper does what a player can, with a different brain** (2026-11-20). "they should kinda be like the player and able to do the things a player can, its just an AI brain happens to be driving it and they may have other functionality like dialogue." They may skip the screen: "they dont actually "click" on a furnace with a cursor and put items in they just kinda get near it open its inventory and put stuff in". Skills change how fast, as in RimWorld: "Wanna cut down that tree? They better be good at a "plants" skill."
- **Items and placed objects are two systems, and each kind of placed object has a script of its own** (2026-11-20). The thing standing on a plot is a placed object: "I like PlacedObject!" What a kind has and does is its own business: "It CAN have an inventory. It CAN have a process. It CAN have giant explosion when clicked." Built. See `placed-objects.md`.
- **A dropped stack is thrown the way the camera looks** (2026-11-20). In third person it goes along the ground: "in third person it should shoot out based on the x y of the camera (not the z or "pitch" though since the camera will naturally be looking down at the world)". In first person it goes up and down with the view: "Yup it should just like minecraft." Built.
- **Ground items merge as Minecraft's do** (2026-11-20): "I think we should follow minecraft's item behaviour exactly if its not too much work." Built. What still differs is in `dropped-items.md`.
- **A carried stack that does not fit the pack when a screen closes drops at the player's feet** (2026-11-20): "Yup! Thats exactly how minecrafts work! Good". Built.
- **What a player does is shown on their own machine at once, and the server corrects it** (2026-11-20). Our own prediction, not Roblox's Server Authority: "We had to do our own inventory and hotbar, so our own client side prediction makes sense." They said yes to the plan the same day. Not built; the plan is in `docs/status/next.md`.

## Proposed, awaiting the user
- **Spatial model** (a first tile grid is built, so the user can judge it by playing; see `docs/status/now.md`): plot tile grid for building and for helpers to walk on; authored terrain between plots; things can be set down anywhere, at rest and not simulated; physics only where it is fun (carrying, throwing, vehicles).
- **Interface:** world verbs wherever one held thing meets one target (apply, take, work, set down), and one consistent panel anchored to the object for contents, moving stacks and choosing recipes. A fixed-camera station mode in the style of the Hands-On Delight mod for a couple of flagship stations later. See docs/research/06.
- **Conditions come from places, weather and running stations,** and each people, creature and material has its own table of responses. Marks carry enchantments, meal effects, protection and race.
- **Transport:** one carrier model as data (what it travels on, speed, capacity, ride, what powers it, what it needs) with a deck or bag hooks; a separate movement controller per medium, added one at a time (foot, ground, water, air). A helper's route is a trip the player demonstrated once.
- **Helpers:** one job each plus two needs (food, rest), walking the plot's tile grid, held as server data and drawn by clients.
- **Characters are seeded from the world, not the server,** so every server meets the same people. A player's standing with each is saved to the player. The generator carries a version number.
- **Shared world state** moves both ways (a city can decline, a bridge can be lost) and its targets scale to how many people are playing. Migration can be driven by it on a slow clock.
- **Ride quality** (fragile goods on a rough ride) as a simple deterministic rule, later; the user is wary of its feel.
- **First build:** handling on a phone with a handcart as the first home; one creature tamed by feeding; one heat-giving station and one cold place whose remedy is in reach; one machine to earn from a faction; one enchantment and one people other than the default; one caravan running between two settlements; a test harness. Runs on grey boxes. See the top of docs/research/05.

## Rating decisions (the user's answers, 2026-11-18)
- **No alcohol.** Any depiction or reference is 18+ on Roblox. Brewing makes teas, tonics, juices and broths. The user: "Yup thats okay!"
- **No romance mechanics.** The user never planned any. Family and household ties are fine as facts; whether the words "wife" or "husband" can appear is a grey area to settle when the rating questionnaire is filled in.
- **Stay Mild and work around it.** The user: "if its just losing a limb and romance i think we can get around that". They asked how big the ages 5-8 group is before giving it up; the research gives only that under-13s are 35% of age-checked daily users, with no figure for 5-8.
- **Death is fine at Mild** when stylised: no red blood, no pain reactions, bodies that vanish. A battle can end with someone dead.
- **Static disabilities are welcome** (the user's idea): a blind seer, a pirate with a peg leg, someone with a bionic heart or a sword arm. In the data these are permanent conditions and installed parts set when a character is generated, the same records a dynamic injury would create. Ship static ones first; add losing a part during play later, in a form that shows the result and never the act.

## Scope decisions (the user, 2026-11-18)
- **No limbs lost during a fight.** Battles are real and in real time, and the user could not see how losing a leg mid-battle would work. In a fight, bodies take conditions and are knocked out or killed. A part can be ruined by a severe untreated condition and replaced at a clinic, which is the RimWorld frostbite example.
- **Remains persist** as stylised items, so the chain from battle to fertiliser stands.
- **New characters need no special explanation.** People arrive. Claude's per-people origin stories were over-designed.
- **For the first build, skip family ties, permanent death of shared characters, and migration** ("maybe this is overkill for the MVP"). Characters are generated with a record, can be knocked out, and a player's own hires stay with the player. Because generation is seeded from the world, a recruit's brother is the same person next time and is not lost; that only starts to matter once family ties exist.

## Open decisions
1. **Humanoid versus the Character Controller Library.** Claude's position in docs/architecture/07 section B2: characters stay on Roblox's default Humanoid, because the library is still labelled beta. It is looked at again with the first vehicle prototype. Server Authority, which stood beside it here, is settled for the inventory and for throwing: on 2026-11-20 the user chose our own prediction (`docs/research/18-client-first.md`).
2. **The architecture itself** is no longer decided on paper. It grows from the pieces as they are joined; docs/architecture/07 is reference.
3. Later: whether a character shared by every server can die, and how.

## The name
- **The user's first name for it was "products for people"** (told 2026-11-20: "I originally envisioned calling this game "products for people"").
- **The game has no name, not even a placeholder** (the user raised this). Claude suggested "Patchwork" as a working name, with "Crossroads" and "Waymeet" as alternatives; names belong to the user. Not chosen yet.
