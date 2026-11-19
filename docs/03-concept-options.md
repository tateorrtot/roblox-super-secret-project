# Concept Options, November 2026

Compiled 2026-11-18. Five designers each proposed a small first game that could grow into the user's frontier idea (quoted in `CLAUDE.md`), each from a different starting angle. Three judges then scored all five, each through one lens. Background research is in [02-concept-research.md](02-concept-research.md).

**Nothing here is decided.** The scores are three opinions, not a measurement, and the user had not seen any of this when it was written.

The designers were briefed before the user's fifth and sixth messages (nomads and caravans; Lumber Tycoon-style plots; aiming attacks at non-player settlements; built-in avatars). The judges had the fifth message but not the sixth.

## Scores

| Concept | Angle | Market | Buildability | Vision | Total |
|---|---|---|---|---|---|
| **Feed the Dragon** | Shared settlement | 8 | 6 | 8 | 22 |
| **Pack a Yak** | One verb | 7 | 8 | 6 | 21 |
| Run a Hero Inn | Hospitality | 6 | 7 | 5 | 18 |
| Feed the Frontier | Homestead and races | 5 | 5 | 7 | 17 |
| Sail a Ferry | Journey | 4 | 4 | 4 | 12 |

Two judges (market, vision) picked Feed the Dragon. The buildability judge picked Pack a Yak. Two concepts were given a fatal flaw: Feed the Frontier needs both races present in a server, which launch servers won't have, and Sail a Ferry can't stand alone as specified.

## The two front-runners in brief

### Feed the Dragon
You are handed a working bakery or dairy in a six-homestead village that shares one young dragon. You carry what you make to travellers for coins, and into the dragon's bowl so it grows and scares off the goblin raids a director sends every few minutes. Goblins can be bonked, paid off, or befriended. Empty plots are run by NPCs, so the village works with one real player.
- **For it:** it is the user's "protection for a price" idea as a mechanic, the title explains the game, and it sits on the most proven demand (creatures).
- **Against it:** it has the most shared state to build, no return-tomorrow hook in the first slice, and races are only a label. The title is unchecked against existing dragon-feeding games.

### Pack a Yak
You pile goods sky-high on a pack beast, climb on, and ride a real road to market. Farther markets pay more and bring more trouble. Every slot on the stack is cargo, equipment, a gift for a faction, or a passenger.
- **For it:** it has the fewest systems before a real playtest, it is the most literal "real things, not menus", and a pack beast is the wandering caravan from the user's fifth message. Carts, rail and ships are later the same system with more slots.
- **Against it:** the ride may feel like waiting, hauling as the whole job has stayed small on Roblox, nobody makes anything another player needs, and it has no return hook in the first slice.

Each concept's growth path leads to the other: the village adds routes and pack beasts, and the yak road adds settling and stalls.

## What the judges said all five missed
- **Nobody designed the thumbnail,** though play-through from the thumbnail is the top ranking signal.
- **Every test is a watched hand-the-phone test.** A watched tester doesn't bounce. A small sample of real Roblox traffic is needed to measure the first minute.
- **No player owns a creature to raise,** the element with the deepest proven demand.
- **Nobody chooses where to settle,** though two kinds of plot on one map (protected and taxed, or exposed and richer) is cheap and was the user's own answer to the cozy-versus-raid problem.
- **Nothing outlasts the server.** One shared number in a data store (a world-wide goblin mood, the dragon's age) would seed cross-server persistence at almost no cost.
- **No player ever pays another player.** Every tip is minted by the system, so "for a price" between players goes untested.
- **None plans how the programmer tests.** The first build needs bot players, a clock that can be jumped, a director that can be forced to play a named card, and a debug panel.
- **The first playtest should run on grey boxes with default avatars,** so it does not wait on art.

## Claude's recommendation (not yet agreed)
Build Feed the Dragon's village as the game, starting with its smallest slice (carry, counter, dragon bowl, one goblin raid) on grey boxes. Add three things from day one: aged cheese as the return-tomorrow hook, goods that are consumables with one specific effect so races mean something, and a choice between a protected plot and a richer gate-side plot. Make the pack yak the first addition after that, as the nomad's path, and the fallback if the village test fails.

---

# The five concepts in full

## Feed the Dragon (angle: settlement, 22/30)

You are handed a working bakery or dairy in a six-homestead village that shares one young dragon: carry what you make to travelers for coins, and into the dragon's bowl so it grows and scares off the goblin raids a director sends every few minutes. Neighbours need your goods, can rescue or pocket your stolen crates, and can pay the goblins off instead, all by walking and carrying, never by chat.

### First 60 seconds
- 0-3s: Spawn already standing inside your own bakery (or dairy; the server gives you whichever trade the village has fewer of). In frame with no panels: an oven with 3 bouncing loaves, a traveler at your counter with a bread thought-bubble, a pony-sized dragon whelp asleep in a nest on the green behind. The NPC who ran the plot waves and walks off. One pulsing ground arrow: oven to counter. Only HUD is a coin counter.
- 3-8s: Walk into the oven. Three loaves hop onto your head one by one, each pop a note higher.
- 8-15s: Walk into the counter. Loaves hop off. The traveler takes one, coins burst out and fly to you: +5. Two more travelers step up: +5, +5. Counter reads 15.
- 15-30s: Oven refills (1 loaf per 2s during the first minute, 3s after). Second trip, coins reach 30. A glowing floor pad with an oven silhouette and a 25-coin fill ring appears beside the oven. Walk onto it: coins stream in, a second oven pops up with a bounce.
- 30-45s: Horn and drums. One knee-high goblin with a sack runs from the forest gate, grabs a loaf off your counter, gets a red outline and an arrow. Bump into it: bonk, it tumbles, drops the loaf plus 10 coins and flees. If you do nothing for 6s the whelp wakes and sneezes fire at it instead. The player cannot lose this one.
- 45-60s: The whelp yawns; the bowl in front of its nest glows with a loaf icon and three empty pips, arrow from your oven to the bowl. Carry 3 loaves in: chomp, chomp, chomp, a heart, the dragon visibly grows one step with a 'Dragon Lv 2' fanfare, and a flame banner over the nest fills to show the village is protected. The goal for the next hour is now on screen without a word.

### Core verb
Carry. Walk into a thing to pick up a stack on your head, walk into another thing to drop it: oven to counter, counter to dragon bowl, your goods to a neighbour's pantry, a dropped crate back from a goblin. No buttons; one thumb.

### Core loop
Make (stations fill on a timer) -> carry a stack -> sell at your counter to travelers who walk up only when stock exists -> step on coin pads to buy the next station, bigger carry stack (3/5/8/12), bigger counter, then a hired hand who does the oven-to-counter trip for you -> decide where surplus goes: your counter (5 coins each), the dragon bowl (protection plus permanent Dragon Bond), or a neighbour's pantry crate (2x pay to you, 5 Deluxe 3x-price charges to them). Every 4-7 minutes the director sends a goblin raid or a 2x-paying caravan; you answer the raid by having fed the dragon, paying the goblin toll, or bonking goblins and returning crates. Loot and the bigger dragon feed back into upgrades. Target first session: 20 minutes, three raids.

### Place, kind and service in the first slice
Service: present and the point of the slice. Protection is bought from an AI protector with goods (the dragon bowl); the goblins sell peace for a toll; players sell hauling to each other through the pantry crate (2x pay) and rescue through returned crates (tip), with the option to exploit by keeping a crate or free-riding on the dragon. Kind: a thin seed. There are two folk, each bound to one trade (the designer's blocky cat-folk run dairies with a Woolox; a second folk run bakeries), assigned by the server, and each needs the other's good to make Deluxe. There are no traits, gear or consumable effects yet. Place: nearly absent, and I say so plainly. It exists only as geometry: goblins come from the forest gate so the two plots nearest it are reached first, and the caravan stops there first. Nobody chooses where to settle in the slice; each plot record carries a risk number so that choice can be switched on later without changing the plot code.

### Director and factions
Trouble is a goblin raid sized to the village's income (2 goblins for a new village, up to 12), announced 20 seconds ahead by horn, drums, a sky tint and the chief standing at the gate with a toll sack. The director keeps a threat budget that rises with coins earned per minute, enforces at least 4 quiet minutes after any event, follows a raid with a 2x-paying caravan as relief, never targets a player in their first 5 minutes, and skips anyone who lost goods last time. Besides bonking, a player can: feed the dragon beforehand so it repels the raid and pays loot to feeders; drop goods in the chief's sack to buy the raid off for everyone and earn Goblin Friendship; reach 5 Friendship so goblins shop at their counter instead of stealing; run to a neighbour's plot and return crates for a tip; or do nothing and let the feeders carry them. Two AI parties (dragon, goblins) with opposite prices is the seed of the designer's 'player B sides with the raiders' story: in a later step, a dragon repel costs feeders Goblin Friendship, so patrons conflict.

### With friends, without chat
The dragon's level is the sum of the Bond of everyone present, so a friend joining makes the dragon visibly bigger at once and unlocks its stronger repel; two players of different trades keep each other in Deluxe (3x) permanently, which an NPC neighbour only does if you walk over and buy; a raid of 8 or more cannot be bonked by one person. Coordination is all in the world: a lit pantry icon over a plot means 'bring me cheese', a flare over a plot means 'being robbed', the flame banner over the nest shows how protected the village is, plot banners show who fed, and the chief's sack shows how much toll is still missing. Nothing needs to be typed or read.

### Why come back tomorrow
Added before launch on the same systems: (1) hired hands keep selling while you are away at 25% rate for up to 8 hours, computed from the save timestamp and shown as a physical chest of coins on your plot to walk into; (2) the dragon is hungry once a day and the first feeding returns a Dragon Gift, a free roll with odds shown on the nest sign (coins, a Deluxe bundle, rarely a dragon scale used for top-tier pads); (3) a goblin peddler at the gate changes his three items every 4 hours (station skins, a recipe seed), priced in coins and Friendship; (4) Bond keeps the dragon's next level in sight and it only moves when you feed.

### Why come back in week 3
A recipe book filled by combination, not hand-made content: base good x pantry ingredient x Deluxe tier x a rare 'smoked' variant that only appears when the dragon is awake near your ovens, so each new trade multiplies the book. Dragon levels 6 to 10 need thousands of Bond, weeks alone or days with a regular group, which pulls friends back together. The Goblin Friendship ladder runs to hiring a goblin hand and opening the goblin market. A new trade as a data row every two weeks (brewery, apothecary), and a weekly director modifier (fog week: more raids, double loot) so the same village plays differently each week.

### Monetization
No paid random items at all; the only roll is the free daily Dragon Gift with odds posted. Frequent small purchases at 10-50 Robux that help the whole server, so buying is welcomed rather than resented: Village Feast (all counters in the server sell 2x for 10 minutes), Dragon Treat (fills the watch meter to 100% for everyone). Permanent passes at 99-199 Robux: second hired-hand slot, carry stack +5, offline window 8h to 16h. Cosmetics bought directly: station skins, plot themes, nest decorations, dragon colours. Private servers free, because friends playing together is itself a ranking signal. Nothing sold removes raids or protects one player only, and the toll is never payable in Robux. Custom blocky characters keep the higher payout rate.

### Technical plan
Server size 6 (one plot each); the village is not persistent and is rebuilt from the saves of whoever is present plus NPC-run plots, which fits servers stopping when empty. Saved per player in one session-locked data-store key under 10 KB: coins, trade, pad purchases, carry tier, hired hands, Dragon Bond, Goblin Friendship, recipe book, last-seen timestamp, daily stamps. Travelers (cap 24) and goblins (cap 12) are server-side records {id, state, node, startTime} on a hand-placed waypoint graph with no PathfindingService; the server sends state changes only, and each client draws a blocky rig and walks it between nodes with stepped animation. Customers spawn only when a counter has stock and a queue slot. Carried stacks are a number on the character, drawn client-side. The dragon is one anchored model moved by scripted tweens. No vehicles and no physics objects in the slice. Part budget of 1,500 per fully upgraded plot, checked on a low-end phone. Biggest engineering unknown: bonking a goblin that exists only as server data. The client must report the bump and the server must accept it against its own idea of where the goblin is, at 150-300 ms phone latency, without feeling unfair or being trivially spoofed. Prototype that in week one, before anything else depends on it. Second unknown: the hand-over when a player joins and replaces an NPC plot mid-raid.

### Clip moment
Twelve goblins pour through the gate while the dragon snores because nobody fed it; one player sprints across the green with twelve cheeses stacked on their head, dumps them in the bowl with a second to spare, and the dragon erupts and sends goblins tumbling in every direction. The runner-up: 'my neighbour bonked the goblin, picked up MY cheese, and sold it at his own counter.'

### Prototype test
Put 6 to 8 people who have been told nothing on phones in one server and watch the first unscripted raid at about minute 5. Working: at least half of them break off their own sell loop to do something about it (carry goods to the bowl, fill the toll sack, or bonk), at least one steps onto another player's plot to return a crate or fill a pantry, and most are still playing when the second raid arrives around minute 10. Kill: most players keep running oven to counter and never touch the bowl, the sack or a neighbour's plot, which means the village layer is invisible and this is only a tycoon; or a third or more leave within a minute of first losing goods.

### Everything in the first slice
- Village map and plots: one small map, 6 plots in a ring around the green, forest gate on one side, traveler road through. 6 players max. Any plot without a player is run by an NPC homesteader so there are always 3 bakeries and 3 dairies; a joining player takes over the plot of the scarcer trade.
- Station + carry + counter: one Station module driven by a data row (Oven -> Bread, Woolox creature -> Cheese). Walk-in pickup, head stack shown as client-rendered meshes (no physics), walk-in drop. Counter holds 8.
- Traveler customers: server-side records on a hand-placed waypoint graph, simple client-rendered rigs; one spawns only when some counter has stock and a free queue slot (cap 24). Each buys 1 good, drops coins.
- Coin pads: about 8 purchases per plot (second and third station, carry 5/8/12, counter 16, one hired hand at 400 coins that automates the station-to-counter trip). The hired-hand code is the same code that runs NPC plots.
- Dragon and bowl: one shared dragon. Watch meter 0-100%, each good fed adds 5%, drains fully in 10 minutes. Each good fed also adds 1 permanent Dragon Bond to the feeder. Dragon level comes from the summed Bond of players present (thresholds 3, 25, 100, 300, 800); the model scales up per level. A banner on each plot shows flames for how much its owner fed this watch.
- Director: a threat budget that grows with village coins per minute; no event within 4 minutes of the last; never targets a player with under 5 minutes played (except the scripted first goblin); skips a plot that lost goods last time. Two events only: Goblin Raid (2 to 12 goblins, 20s telegraph of horn, drums and sky tint) and Caravan (6 travelers paying 2x) as the relief beat.
- Raid resolution, three answers: (1) Watch meter at or above 50% when the raid arrives: dragon wakes, roars, goblins flee and drop loot at feeders' plots in proportion to what they fed; costs 50% of the meter. (2) Toll: the goblin chief stands at the gate for the 20s telegraph with a sack showing a goods count (2 per goblin); any players may fill it together; raid cancelled, each contributor gains 1 Goblin Friendship. (3) Otherwise each goblin takes 1 good from a counter and runs 12s to the gate; bump to bonk and it drops the crate. Loss is capped at counter stock: never coins, never buildings.
- Dropped-crate rule: anyone can pick up a dropped crate. Carry it to the owner's counter and the system pays you a tip of 2x its value; carry it to your own counter and you keep it. A neighbour can therefore never leave you worse off than the goblin would have.
- Pantry crate: every plot has one, showing the other trade's icon. A non-owner dropping that good in is paid 2x list by the system; the owner's next 5 products come out Deluxe (sparkle, sell 3x). Any player can also buy from any counter by walking into the customer side (pays the owner list price), so a solo player can stock their own pantry from an NPC neighbour.
- Goblin Friendship flip: at 5 Friendship, goblins in a raid queue at your counter as customers instead of stealing from you. One flag on raider targeting; reuses customer behaviour.
- Save: one data-store key per player with session lock (coins, trade, pad purchases, Bond, Friendship, timestamp). The village itself is not saved; it is rebuilt from whoever is present.

### Cut for now
- Free building, interior design, landscaping (plots grow only through fixed pads)
- Offline earnings, daily rewards, rotating shop, invites, purchases: designed below, added after the prototype and before launch
- Any weapons, health, damage or player-versus-player raiding
- Vehicles, carts, trains, ships, rideable lines
- More than one map, regions, linked servers
- Player-set prices, trade windows, markets, auctions
- More than two trades and two folk; picking your folk (assigned in the slice)
- Gear, armour, consumable buffs, environment needs
- Taming or collecting creatures beyond the one dairy animal and the shared dragon
- Player-run protection, taxes set by players
- More factions, more director events (cold snap, sickness, festivals), story chains
- Healing, taverns, inns, hospitality
- Quests, dialogue, anything that needs reading or typing

### Growth path
- 1. Launch pack on the existing systems: offline chest, daily Dragon Gift, goblin peddler with rotating stock, friend-join bonus and invite prompt at the nest, free private servers, the purchases above. This is what makes the slice a game that can launch and hold by itself.
- 2. More trades and folk as data rows, with real kind traits: brewery, apothecary, inn. Each folk gets one production strength and one need met by another trade's consumable (eat it for a timed buff), and the first wearable gear made from Woolox wool. Healing arrives here in Mild form: weary travelers and singed goblins are carried to the apothecary's bed for pay.
- 3. Place: switch on plot choice. Add an outer ring on the same map beyond the dragon's reach (frost ridge, marsh): different raiders, unique ingredients, 2x caravans, and conditions only the right folk, gear or consumable makes easy. Add a guard post a player can build to sell watch to outer neighbours at one of three preset tithes, the first player-run protector.
- 4. A second faction and a wider director: river pirates who toll the road, cold snaps, a sick creature, festivals, and patron conflict (a dragon repel costs feeders Goblin Friendship; goblin friends can warn or shelter raiders). Friendship ladders reach alliance.
- 5. Real routes: a hand cart, then a rail or boat line a player lays from the village to an outpost on the same map, with cargo physically aboard, tickets other players buy by walking on, and pirates to pay or befriend; then a driven co-op journey to a distant volcano as a reserved-server run that returns rare goods.
- 6. Only when player counts support it: a second village as its own place with a different protector and climate, linked by the line with a loading-screen crossing and sharing coarse numbers (prices, route status) through data stores.

### Risks
- The first 30 seconds are a carry-and-sell tycoon, a familiar shape; if the goblin and dragon do not land by second 45 the game reads as generic to the 16+ launch audience.
- Cozy players may quit the first time goods are taken, even with the cap, the mercy rules and the dragon option.
- Free-riding may be the stable outcome: nobody feeds the bowl, the dragon never wakes, and the shared layer goes unused. It could also be the best story the game has; the playtest decides.
- At launch most servers will hold one or two real players. NPC-run plots keep the loop whole, but the neighbour moments that make it distinct will be rare until player counts rise.
- A dragon whose size is the sum of present players' Bond shrinks when a veteran leaves, which may feel wrong. Recomputing only after a raid softens it; it may need a different rule.
- Keeping a rescued crate is designed to be harmless to the owner, but may still feel like griefing to them.
- Two trades are thin for week 3. The game depends on growth steps 1 and 2 shipping before or soon after launch.
- The title is unchecked. A quick search found no Roblox game called exactly 'Feed the Dragon', but found several dragon-raising games built on feeding; search the Roblox catalogue by hand before committing, and keep the thumbnail about the village under the dragon, not about owning a dragon.
- Data-only goblins may not bonk well under phone latency (see technical plan).


---

## Pack a Yak (angle: one-verb, 21/30)

Pile your goods sky-high on a stubborn little pack beast, climb on top, and ride it down a real road to market: the farther the market, the better the pay and the worse the trouble on the way. Everything you put on the yak is either something to sell or something that gets it there.

### First 60 seconds
- 0-3s: You spawn already standing in your roadside camp, camera behind you, facing a shaggy blocky yak four steps away with an empty saddle. Five cheese wheels sit in a glowing line between you and it. The only UI is the thumbstick and a ground arrow.
- 3-8s: You walk forward. Each cheese hops into your arms with a pop that rises in pitch; the tower in your arms wobbles as you move.
- 8-12s: You bump the yak. The cheeses arc onto its back one at a time (thunk, grunt), the saddle sags, and a coin number floating over the yak ticks 0 to 125. A slot bar shows 5/6.
- 12-20s: The pumpkin patch beside you pops three ripe pumpkins. You walk through it, they jump into your arms, you load them. Slot 6 turns gold (full and safe); slots 7 and 8 turn red and the stack visibly leans. A bell over the yak starts to swing.
- 20-25s: You tap the bell, the only button on screen. You are seated on top of the pile and the yak sets off down the road.
- 25-35s: The ride. Other players' yaks pass with taller stacks than yours. A pothole jolts the yak and the top pumpkin tumbles off and rolls; the yak stops, you hop down, walk over the pumpkin and bump the yak to put it back.
- 35-45s: A single Magpie (bird-folk toll taker) stands at a rope across the road with two picture buttons over its head: a coin (5) and the pumpkin it is pointing at. Either one lifts the rope. Giving the pumpkin makes a heart pop over the Magpie.
- 45-55s: Meadow Market. The yak steps on the scale and the goods fly off one at a time into stalls, each popping coins (+25, +25, +10...), ending in a coin fountain of about 140.
- 55-60s: The saddler's stall next to the scale glows: bigger saddlebags, 80 coins, one tap. The yak's bags visibly grow from 6 slots to 9. The yak trots home empty at double speed with you on it; past the market, a second road with a heat shimmer and a x2.5 coin sign is visible.

### Core verb
Load. Walk over a physical good and it hops into your arms; walk into your yak and it thunks onto the stack on its back. The stack is this game's block: every item placed on the beast is cargo, equipment, a gift for a faction, or a passenger, and the pile is the whole build. Production makes loadable things, hauling moves the load, raiders take from the top of it, protection keeps it on, consumables and gear are things you load, and a journey is the load moving through the world with you sitting on it.

### Core loop
Pick (walk through your camp's nodes: pumpkins regrow in 20s, cheese in 40s) -> load (6 safe slots, up to 50% more if you dare) -> ring the bell and ride the road (30s to Meadow Market, 90s to Cinder Market) through one to three director events -> sell on the scale for a coin cascade -> spend on saddlebags (6/9/12/16 slots: 80/400/2,000 coins), arm stack (5/8/12: 60/300), a new node (cheese rack 150, honey hive 600) -> load a taller, richer, riskier stack. A cycle is 2-3 minutes; coins per trip climb from about 140 to about 2,000 in the first session. The decision each cycle is the stack: how far over the safe line to go, which market to aim for, and which slots to give up for things that are not for sale (an ice block for the hot road, a gift for the Magpies, a stranded peddler's crate).

### Place, kind and service in the first slice
Place: present as a seed, but not as settling. All camps are in the safe Meadow; place is which market you aim the yak at. Meadow Market is 30s away, pays x1 and gets a director budget of 1. Cinder Market is 90s away, pays x2.5, gets a budget of 3, and is hot. Choosing where to live is absent until growth step 4.

Kind: present as a seed in the beast, not the player. The yak's shaggy coat makes the Cinder road slow and miserable (half speed, 180s trip) unless you give up a slot to an ice block, at which point the same road is easy. That is the designer's 'trivial with the right kit, inhospitable without' rule in one item. Player races are absent, and there is only one beast species.

Service: present as three seeds. The stranded peddler pays you to haul their crate (a service sold to an AI). The Magpie toll is protection money to an AI faction that can instead be befriended with gifts. Convoys are players protecting each other by numbers, with an automatic tip for rescuing someone's spilled goods. No player sets a price or sells a service to another player yet.

### Director and factions
Trouble only ever happens to a trip, so the cost is bounded: one small state machine per yak on the road. Each trip gets a budget (Meadow 1, Cinder 3) plus 1 if the stack is worth more than twice the player's average. The director spends it from a deck: pothole costs 1, Magpie toll costs 2, stranded peddler costs 0 and is the relief card. It keeps a per-player mood like RimWorld's storyteller: after a trip where the player lost goods, the next trip is guaranteed a peddler or nothing; after three clean trips the budget rises by 1. Events are placed at fixed scenic spots on the road (the ford, the rope bridge, the dead tree) so players learn where to brace.

The Magpies are the one faction: bird-folk who want shiny things and never hurt anyone. They take items off the top of the pile, never coins already banked and never the yak. At the rope a player can pay (10% of stack value), give the item the Magpie points at (friendship +1), charge through (lose 1-3 top items, friendship -1), or arrive in a convoy of three or more and be waved past. At friendship 3 the Meadow road is toll-free. There is no fighting in the slice at all. Later ranks put a Magpie lookout on your stack, and a second faction (road Wardens who protect for a tax) gives the Magpies someone to be played against.

### With friends, without chat
A convoy is strictly better than going alone: one toll for the whole line, no Magpie stop at three or more yaks, +10% sale price per extra yak up to +30%, and extra hands to catch what falls. Coordination is entirely visible actions. A departing bell rings for 8 seconds with a ring over the yak, and every loaded player nearby gets one big Join button. Yaks walk nose to tail on the same road. Spilled goods lie in the road for anyone to walk over; putting them back on the owner's yak pays the helper 5 coins automatically. A player with no load can simply sit on a friend's stack and ride along. The only signals needed are the bell, the Join button, and stack height, which everyone can read at a glance. Private servers are free, so a friend group can fill a road with one long caravan; joining a friend's server and leaving on their bell is the intentional co-play the ranking counts.

### Why come back tomorrow
Not in the prototype; this is the first addition before any public launch. (1) A hired drover (800 coins) walks a second yak on the Meadow loop while you are away, computed from timestamps and capped at 8 hours; when you log in that yak is standing in camp under a pile of coin sacks you unload by walking into it, sometimes with a found item on top (a rare seed, a Magpie feather, later an egg). (2) Cheese left on the rack ages: x2 after 1 hour, x5 after 8, x10 after 24, shown by rind colour, so yesterday's cheese is today's best load. (3) Each market's wanted board (three picture signs) pays double for three goods and rotates every 4 hours. (4) A wandering peddler at the Meadow Market shows three rare items for coins and restocks every 30 minutes.

### Why come back in week 3
A beast collection where each species opens a road rather than just adding a number: eggs found on trips hatch into carriers with a home climate and a carrying quirk (a snail with 24 slots at half speed that loves rain, a salamander that needs no ice), each with coat colour and size rolls. A new road and market roughly every two weeks, each one a spline, a climate rule, one new event card and one new useful load, so content is combinations rather than hand-built levels. A Magpie friendship track with ten ranks and cosmetic rewards. A Saturday Great Fair where one far market pays triple for one good, which pulls whole servers into convoys. A tallest-stack-delivered record shown as a statue at each market. Aged cheese and rare goods give a slow, long-horizon inventory worth protecting.

### Monetization
None in the prototype. At launch, small direct purchases with nothing random for sale: a feed bag (about 15 Robux) that makes the yak gallop for 10 minutes; rope and tarp (about 25 Robux) that makes the next trip spill-proof; cosmetic bells, saddle blankets and yak hats bought directly (49-99 Robux); a second drover slot and an extra beast stall as one-time passes (about 199 Robux each). Private servers are free, since they drive co-play. Eggs and rare items are found in play or bought for coins only; if any random item is ever sold for Robux, its odds go on the stall sign. No paid restock of random stock, no reward-for-watching feed, nothing that takes goods from another player.

### Technical plan
One place, 8-player servers, no regions. Player camps are plots assigned on join; all progress saves to the player in one small data store key (coins, upgrade levels, owned nodes with last-harvest timestamps, friendship, later beasts, drover assignment and last-seen time) and loads into any server.

Yaks are not physics vehicles. Each is server data: route id, distance along the spline, speed, state, and a list of item ids. The server advances them a few times a second; clients interpolate and render the blocky rig, stepped animation and the stack as non-colliding welded props. Eight yaks with up to 24 items each is under 200 simple parts. Convoy following is the leader's distance minus a gap. Spilled items are short-lived server pickups. Magpies and the peddler exist only at the event spot while a trip is there. Offline drover trips are arithmetic on timestamps with the director rolled per computed trip.

Biggest unknown: how riding on top of a moving, client-rendered yak feels on a low-end phone, including hopping off and back on to chase a spill, since the research flags possible jitter for passengers on moving vehicles. Plan: give the owner's client control of a real seat part that follows the spline, with the server only checking that distance never advances faster than the allowed speed; prototype this in week one before anything else. Second unknown: making the walk-over arm stack feel good is game feel, which is the designer's call and needs phone playtests.

### Clip moment
A small yak under a pile twice its own height (cheese wheels, barrels, a peddler's crate, a friend sitting on the very top) hits the last pothole ten steps from the market scale, the whole tower bursts across the road, and a Magpie flies off with the one golden cheese while the convoy scrambles to grab the rest. The quieter version is a six-yak caravan in a line at sunset, every stack a different silhouette.

### Prototype test
Put 8-10 strangers on phones with no instructions and watch trip three. It is working if most of them (at least 6 in 10) load past the gold safe line on purpose, stay on or beside the yak for the whole ride, and ring the bell for a fourth trip without being asked, with at least one pair joining a convoy unprompted. It is dead if players stop at exactly the safe line, look away from the phone during the ride or ask how to skip it, and fewer than half start a third trip: that means loading is a chore and the journey is a wait, and no amount of later systems hung on the stack will fix it.

### Everything in the first slice
- One map, one server type (8 players): 8 roadside camp plots in the Meadow, one road as a spline running camps -> Meadow Market (30s) -> Cinder Market (60s further, hot).
- Carry and load: walk-over pickup into a visible arm stack (cap 5), walk-into-yak transfer onto a visible welded stack; 6 safe slots, overload up to +50%; each overloaded item adds 15% spill chance per pothole.
- Two production nodes per camp (pumpkin patch 10 coins/20s regrow, cheese rack 25 coins/40s) plus one buyable (honey hive, 40 coins each).
- One beast, the yak: a path follower on the road spline, bell to depart, rider seat on top of the stack, pauses up to 10s when the rider hops off, returns empty at double speed.
- Two markets with a sell scale: Meadow pays x1, Cinder pays x2.5. Coins, plus the saddlebag, arm-stack and node upgrades bought at physical stalls with one tap.
- Heat rule (the kind seed): on the Cinder road the shaggy yak pants and walks at half speed unless an ice block (20 coins at the Meadow ice-house, takes one slot, melts on arrival) is in the stack.
- Director with a per-trip budget and three event cards: pothole (spills overloaded top items, recoverable by walking over them within 8s), Magpie toll (pay 10% of stack value, give the item it points at, or charge through and lose 1-3 top items), stranded peddler (carry their crate in one slot for double that slot's pay).
- Magpie friendship, one number 0-5 per player: +1 per gift, -1 per charge-through; at 3 they wave you through on the Meadow road.
- Convoy: a departing bell rings for 8s and shows a Join button to any other player standing by a loaded yak; joined yaks follow nose to tail, the toll is charged once, Magpies do not stop three or more, each extra yak adds +10% sale price (cap +30%), and anyone can pick up anyone's spill and gets a 5-coin tip for putting it back.
- Minimal save (coins, upgrades, nodes, friendship) so the same testers can be watched on a second day.

### Cut for now
- Player races and custom player characters (the beast carries the 'kind' idea first)
- Choosing where to settle; free building and decorating of the camp
- All combat, weapons and health; players taking each other's goods
- Linked region servers and any crossing between places
- Carts, trains, ships and any physics vehicle
- Hired drover and offline trips (first addition after the prototype)
- Second beast species, eggs, taming, breeding
- Crafting chains, baking, aging cheese
- Taverns, hospitals, stalls, player-set prices, any player-to-player sale
- Second faction; faction protection for a tax
- Day/night, weather, seasons
- Robux purchases
- Quests, tutorial text, dialogue

### Growth path
- Drover and the offline layer: hired drover for a second yak, timestamp-computed trips, aging cheese, rotating wanted boards, wandering peddler. This is what makes the slice launchable; it adds data to the existing carrier and node records.
- Kinds: more beast species from eggs found on the road, each with a climate and a carrying quirk, then the player's own fantasy race chosen the same way (arm capacity, climate tolerance, one production bonus) using the artist's custom blocky characters. The heat rule becomes a general climate-versus-kind table.
- Useful loads and passengers: baked goods and brews made at camp that buff a trip in one specific way, a lantern for night roads, a guard dog crate, a healer's kit; NPC travellers who pay for a seat on your stack, and players riding each other's yaks for a fare. The stack becomes the full loadout.
- Settle the road: move your camp to a plot beside any market. Far plots have rarer nodes and get visited by the director (Magpies at your fence, storms, stray creatures). Add a roadside stall where passing players and NPC caravans buy your goods and services (meals, stabling, healing a tired beast), and a Warden faction that guards a stretch for a tax. This is where every homestead becomes a business and where player-to-player service starts.
- Bigger carriers on the same system: carts, then a river barge or rail line a player pays to lay between two markets and that others ride for a ticket. A carrier is still a path follower with slots, so nothing is rewritten.
- Regions, only when concurrent players support it: each far road ends at a gate to another place with its own markets and faction mood, sharing coarse numbers (prices, faction standing, route status) and saving the yak and its stack across the loading screen.

### Risks
- The ride may be dead time. Research found that hauling as the whole job has stayed small on Roblox; this bets that a short trip (30-90s), sitting on your own pile, and one to three events make it the payoff rather than the wait. If not, the drover has to arrive much earlier and the game leans toward loading and selling.
- Overloading may have one right answer (always or never). The spill odds, recovery window and Cinder multiplier need tuning until players disagree about it.
- Walk-over stacking is a familiar mobile pattern and may read as shallow to the 16+ players who decide the launch gate. Depth has to show up by the third trip through the slot trade-offs (ice, gift, peddler crate).
- The prototype has no return hooks. Whether it retains depends on growth step 1, which the first playtest cannot measure.
- Cozy players may hate losing goods to Magpies even though only the top of the pile is ever at risk. Watch for it; the gift route and the friendship waiver are there for them.
- Riding a moving client-rendered beast on a low-end phone is unproven here and is the first thing to prototype.
- The title makes the yak the mascot while later beasts differ, and a quick web search found no Roblox game with this name or premise, which is weak evidence. Search inside Roblox before committing.
- Eight yaks on one road could feel crowded or, with two players online, empty. Yaks pass through each other, and the road needs to feel alive with one player on it.
- Place is a destination, not a home, until step 4. The designer's 'where you settle' pillar is deferred, and that should be agreed rather than assumed.


---

## Run a Hero Inn (angle: hospitality, 18/30)

You are handed a working roadside inn where fantasy travellers stop on their way to dangerous places. What you serve them is what they carry out the door: feed, cool and patch them properly and they walk off up the road and come back later hauling loot crates that make your inn better; and every so often the road sends trouble through your door that you can pay, feed or chase.

### First 60 seconds
- 0-3s: No menu, no template pick, no name entry. You spawn behind the counter of a small lit inn at dusk (3 tables / 6 seats, Stew Pot, Ice Jug, Bandage Basket, Expedition Board by the door, empty Loot Shelf). Coin counter top-left reads 0.
- 3-8s: A blue Frostling walks in from the road and sits. A bubble with a stew-bowl icon pops over its head; the Stew Pot beside you pulses.
- 8-12s: Tap the Stew Pot. Your innkeeper ladles (0.6s) and holds a steaming bowl. The glow jumps to the guest.
- 12-16s: Tap the guest. You auto-walk over, set the bowl down, hearts and coins burst out and fly to the counter: 0 -> 10.
- 16-30s: Two more walk in: an orange Emberkin with an ice-jug bubble, a scuffed Mossfolk with a bandage bubble. Serve both the same way. Coins 10 -> 35. A patience ring (45s) is visible around each bubble but never expires this early.
- 30-38s: The Frostling, fully served, stands up wearing a backpack with a snowy-peak banner over its head and walks out the door and up the road toward the visible snow peak. Its portrait appears on the Expedition Board with a 30-second ring draining.
- 38-48s: A glowing floor pad labelled with a table icon and '40' appears. Walk onto it: a fourth table drops in with a poof. A new guest heads for it at once.
- 48-60s: A bell rings; a wagon rolls up outside and four travellers file in together (first Rush, scripted). Coins tick past 80 as you serve them.
- 60-75s: The Frostling walks back in carrying a crate and sets it on the Loot Shelf. Tap the crate: it bursts into 4 frostberries that fly into the Ice Jug; its meter fills and the jug visibly upgrades to Level 2 ('+25%' floats up). This scripted return is the moment the game stops looking like a restaurant.

### Core verb
Serve: tap a station to pick up an item (stew bowl, ice jug, bandage), tap the guest whose bubble shows it. The character auto-walks; one thumb, no reading.

### Core loop
Guests arrive only when a seat is free and show 1-3 need bubbles (stew / ice jug / bandage). You carry items to them for coins. A guest whose every need is met leaves on an expedition to one of three places visible on the horizon (Snowpeak, Ember Hollow, the Mire) and occupies a slot on the Expedition Board (3 slots to start) with a timer: Near 2 min, Far 30 min, Deep 4 h. They walk back in with a crate: Snowpeak gives frostberries (levels the Ice Jug), Ember Hollow gives emberpeppers (levels the Stew Pot), the Mire gives mendmoss (levels the Bandage Basket). Station level raises coin payout per serve by 25% a level and unlocks the next trip tier for that place. A guest who leaves with a need unmet goes anyway and comes back scuffed with no crate, wanting a bandage. Coins buy fixed floor pads: tables 4-6 (40 / 150 / 400), a 3-item tray (300), a second Stew Pot (500), Board slots 4-6 (400 / 900 / 2,000). Numbers that go up: coins, inn stars (1-5, from the share of guests fully served; sets arrival rate from one per 6s to one per 2s), three station levels, guestbook entries, Magpie hearts.

### Place, kind and service in the first slice
Service is fully present: the whole game is selling food, cooling and healing to travellers, and helping in another player's inn for tips is the first player-to-player service. Protection as a paid service exists only as the Magpie pay-off. Kind is present for guests, not for the player: each guest kind has a home element, and whether they thrive or need extra supplies depends on kind x destination x what you gave them, which is the vision's 'right race plus right consumables makes a hostile place easy' rule in seed form. There is no player race or player gear in the slice. Place is present only as three destinations on the horizon that guests physically walk toward and return from, each yielding a different ingredient. Place as 'where you settle sets your risk and reward' is absent: all plots are identical. It enters at growth step 2 as safe versus exposed plots on the same road in the same server, so the launch audience is never split.

### Director and factions
Trouble arrives through the front door as guests. Each inn has its own director: a 0-100 tension meter that climbs with coins per minute and time since the last card, and drops when guests are leaving unserved, so a struggling player gets calm and a cruising player gets pressure. At 60 or more it plays a card from a data-driven deck, then enforces 90 seconds of calm and a relief guest who pays triple. The slice deck has two cards. Rush: a wagon stops and 4-8 travellers file in at once, which is an opportunity under pressure. Magpie toll: three bandits arrive and you choose by tapping one of three icons: pay 15% of your purse and they leave; feed them three stews by hand in 30 seconds and gain a heart; or shut the door, in which case each snatches one crate and runs and you (and any friends) chase and tap them to get the crates back. At 3 hearts the gang stops tolling and turns into paying regulars. Losses are capped at three crates, never coins without consent, never offline. There is also a built-in consequence that needs no card: under-supplied travellers come back scuffed and empty-handed. New trouble later is new cards in the same deck (storm that soaks every arrival, wounded party, tax collector from the Wardens), not new code paths.

### With friends, without chat
It is a shared-kitchen game: two people serving one inn clear a Rush that one cannot, the wagon brings more guests when more players are inside, and three runaway Magpies going three directions is a job for three people. The helper is paid a 50% tip on top of the owner's full payment and the owner gets +25% while a friend is inside, so helping never costs anyone. Joining a friend drops you at their inn door while your own expeditions keep ticking. Coordination needs no words: need bubbles are the shared language, the item in each player's hands is visible, and picking up an item draws your colour ring around the guest you are heading for so two people do not serve the same one. Private servers are free.

### Why come back tomorrow
The travellers you sent on 4-hour Deep trips before logging off are standing at your door with crates when you load in, including the 1-in-20 golden crate chance, so the first ten seconds of tomorrow are opening loot and watching stations level up. Before quitting there is a reason to fill every Board slot with a Deep trip, which is the habit that carries. The first Rush of each real day guarantees a Knight-or-better guest, a daily shot at a new guestbook entry.

### Why come back in week 3
In the slice alone: station levels need 40 ingredients for L4 and Deep trips are 4 hours with 3-6 slots, so maxing three stations takes roughly two to three weeks of daily play; the guestbook has a 1-in-200 Dragonkin; the Magpie arc runs toll -> truce -> regulars; the trophy wall fills from golden crates. Honestly, that is thin by week 3 without additions. The design makes additions cheap because they are rows of data: a new guest kind, a new destination with its ingredient, a new director card, a new trophy set, shipped on Saturdays. Helpers and beds (growth step 1) should land before any player reaches day 14.

### Monetization
No paid random items at all: crates are only ever earned, so the odds rule never applies. Cheap, repeatable developer products at 10-50 Robux: Ring the Dinner Bell (call a Rush wagon now), Express Courier (bring current expeditions home now, priced by time remaining), restock-a-station later when stock exists. Permanent passes: Tray of 5, plus up to three extra Board slots sold directly. Direct-purchase cosmetics with no randomness: signboards, lanterns, innkeeper aprons. Private servers free, since they count as co-play and earn from Plus subscribers' time. The Magpie toll is payable in coins only, never Robux. In the prototype only two or three of these exist, enough to confirm the purchase flow.

### Technical plan
One place, 8 players per server, 8 plots, no teleports. Guests are rows in a server table (id, kind, state, seat, needs, patience end, path id, path start time) ticked at 4 Hz; state changes go to clients over one remote; clients compute position from path and start time and draw simple rigs with stepped pose-swap animation at about 8 fps, capped at 40 rigs within 150 studs. Hard cap about 18 guests per inn (12 seated, 6 walking), so at most about 150 server-wide as data. Fixed inn layout means waypoint paths, no pathfinding service. Taps raycast against rig hitboxes on the client and send a guest id; the server validates distance and carried item. Carry state is predicted on the client so serving feels instant. No physics vehicles: the Rush wagon and Magpie runners are tweened on clients from a server start time. Saved per player in one session-locked data store key: coins, stars, three station levels, pads bought, guestbook counts, Magpie hearts, Loot Shelf crates, last-seen timestamp, and the expedition list (kind, destination, tier, depart time, duration, supplied flag, loot seed). Expeditions resolve from os.time() on load; the loot seed is fixed at departure so rejoining cannot reroll. Autosave every 60s and on leave. StreamingEnabled, about 1,500 parts per plot budget. Player character is one custom blocky innkeeper, which still qualifies for the higher payout rate. Biggest unknown: whether 40-plus client-rendered rigs with bubbles hold 30 fps on a low-end phone while tap targets stay easy to hit in a crowded room; build a stress scene with 40 rigs and test it on a real phone in week one, before anything else depends on it. Rough order: week 1 serve loop, guests, save; week 2 expeditions, pads, director; week 3 Magpies, co-op, phone tuning.

### Clip moment
A 1-in-200 Dragonkin ducks through the inn door, sits across two chairs with three need bubbles, and later walks back in with a glowing golden crate. Runner-up: you shut the door on the Magpie Gang and three masked bandits sprint off down the road in three directions with your crates while you and a friend chase and tap them.

### Prototype test
Working: hand the phone to strangers with no instructions. At least 8 in 10 serve their first guest within 20 seconds, and the median tester is still playing unprompted at 12 minutes, by which point they have opened at least two returned crates and are seen deliberately finishing every need on a guest before the patience ring runs out (serving to send, not just serving to earn) and glancing at the Expedition Board or the door for returns. Kill: more than 1 in 4 have not served anyone by 30 seconds, or the median tester quits before 6 minutes, or testers leave returned crates unopened and ignore the Board. That last one means the expedition twist adds nothing over a plain restaurant game and this angle should be dropped.

### Everything in the first slice
- One place, 8-player servers, 8 identical fixed-layout inn plots along one road; on join you get a free plot with your saved inn loaded into it. No free building: expansion is fixed buy pads.
- Guests as server data with client-rendered blocky rigs: spawn only when a seat is free, follow precomputed waypoint paths (road -> door -> seat -> door), 6 kinds (Frostling, Emberkin, Mossfolk common; Knight 1 in 10 with 2 needs and double pay; Owl Mage 1 in 25; Dragonkin 1 in 200, takes two seats, 3 needs). First Rush of each real day guarantees one Knight-or-better.
- Tap-to-serve: three stations, carry 1 item (3 with tray), need bubbles with a 45s patience ring, coin and heart feedback, client-predicted carry state.
- Expeditions: fully served guests depart physically up the road, Board slots, timers from timestamps (run while offline), outcome rolled from a seed stored at departure, crate carried back in and opened by tap. Home-kind rule: a traveller bound for their own element's place needs 1 item and returns a double crate; anyone else needs 2 items including that place's counter-item (stew for Snowpeak, ice jug for Ember Hollow, bandage for the Mire). 1 in 20 Deep crates is golden and mounts a trophy on the inn wall.
- Station levels fed by ingredients (5 / 15 / 40 to reach L2 / L3 / L4) and the coin buy pads listed in the core loop.
- Road director, per inn: a tension meter that rises with income and time, falls when guests leave unserved, plays a card at 60+, then forces 90s of calm and sends one generous guest paying triple. Two cards only: Rush wagon (4-8 guests at once) and Magpie toll.
- Magpie Gang toll visit: three masked magpie bandits walk in and the leader shows three big buttons: coin bag (pay 15% of purse, capped 500), stew bowl (hand-carry 3 stews to them in 30s, +1 heart), shut door (each grabs one crate from the Loot Shelf and runs down the road; tap a runner to get the crate back). At 3 hearts they stop tolling and come as paying guests. Never fires in the first 4 minutes, during a Rush, or offline.
- Co-op helping: anyone can walk into any inn and serve; helper earns a 50% tip paid on top (owner loses nothing); owner gets +25% while a friend is inside; Rush size scales with players inside; picking up an item puts your colour ring on the guest you are heading to.
- Save: one session-locked data store key per player (coins, stars, station levels, pads bought, guestbook counts, expeditions, Loot Shelf crates, Magpie hearts, last-seen time); autosave every 60s and on leave.

### Cut for now
- Free-form building, decoration and interior design (fixed pads only; trophies are the only decor)
- Hired helpers and beds/overnight stays (first addition, not needed to test the loop)
- Player race pick and any player gear or consumables (the innkeeper is one custom blocky model)
- Different plot locations with different risk (all 8 plots are equal)
- Farming, animals, brewing, creature taming, stables
- Any alcohol: stew, ice jug and tea only, to stay Mild
- Combat of any kind; the Magpies are caught by tapping, nobody has health
- Playable journeys, rideable wagons, trains, ships (the Rush wagon is a tweened prop)
- Region servers, cross-server economy, trading between players, player-to-player prices
- Storms, sieges and every other director card beyond Rush and Magpie toll
- Rotating shop, daily quests, login streaks, leaderboards
- Text of any kind beyond numbers on pads; no tutorial panels
- Robux store beyond the two or three products needed to check the purchase flow works

### Growth path
- Helpers and beds: hire a server who takes over exactly the stew run, then one per station; add upstairs beds where guests stay overnight and pay while you are offline. Do it by hand, then hire it away.
- Place: split the road in the same server into Meadow plots (Road Wardens protect you for a 10% tax, common guests) and Pass plots (no tax, rarer guests and better crates, Magpies twice as often). Moving is a tap on an empty plot. A Frost Gate plot follows that is cheap to run only with the right kind and supplies.
- Kind for the player: choose an innkeeper race that changes station speeds, which guests favour your inn and what you yourself need (an Emberkin keeper must keep the hearth fed); add keeper gear and consumables made from expedition loot.
- Homestead behind the inn: garden beds, hens, a stable and a hatchery for rare eggs found in crates, so you grow what expeditions used to bring and raise creatures that guests ride out on. Kitchens, clinics and stables become specialisations, and inns start ordering goods from each other through a cross-server ledger with a visible delivery cart.
- Go yourself: the wagon to Snowpeak becomes a co-op run in a reserved server that you and friends ride, defend and return from with the big loot, and haulers and escorts become jobs players sell to other inns.
- More road: a second region as its own place sharing coarse state (prices, route safety, faction standing), more factions with pay, befriend or resist options, sieges as director peaks, and a rail or river line one player builds and others buy tickets to ride.

### Risks
- For the first 30 seconds it looks like Restaurant Tycoon in fantasy clothes; if the first crate return at about 70 seconds does not land, the twist is invisible and we are a late entrant in a volatile cozy-tycoon field.
- The expedition is a timer, not a journey. Travellers walking out and back carrying crates makes it physical, but it may still read as a menu until the playable wagon run exists.
- Tap-to-serve may be too shallow for the 16+ launch audience that has to produce the 250 engaged plays; depth has to come from need combinations, Rush pressure and the Magpie choice.
- Cozy players may read the Magpies as punishment. Feeding is the gentle default, losses are capped and never happen offline, but this needs watching in the playtest.
- Client-rendered crowds and tap accuracy on low-end phones are unproven for this project.
- Rating drift: an inn invites ale and brawls. Any alcohol or realistic fighting risks losing Mild. Tea, stew and tap-to-catch only.
- The slice by itself is thin at week 3, and Restaurant Tycoon 3's weekly updates produced no measurable lift, so retention has to come from the expedition habit and collection, not from content drops.
- With a tiny launch audience most players will be alone in a server; the inn must feel busy with NPCs only, and co-play may be rare until friends are invited.
- Coin and ingredient numbers here are first guesses and will need tuning against real session data.


---

## Feed the Frontier (angle: homestead, 17/30)

Run a roadside homestead between a frozen forest and a lava field: grow, cook and sell dishes whose effects let people survive where they otherwise can't. Your race is at home in one wild and helpless in the other, so the dish you make for free is the one your neighbour needs.

### First 60 seconds
- 0-3s: No menu and no race picker. You spawn as a blocky Frostfolk or Emberfolk (auto-assigned to whichever the server has fewer of) on your own plot facing the road. Three ripe turnips wobble and glow five studs ahead, a pot steams, and a traveler waits at your counter with a stew-bowl thought bubble. A snowy peak is visible down the road one way, a smoking volcano the other.
- 3-10s: Walk into the turnips. They pop and arc into the basket on your back (auto-pickup on touch).
- 10-18s: A bouncing arrow sits over the pot. Walk into it, the turnips fly in, one big pot button appears; tap it. Three seconds of bubbling, then two Turnip Stew bowls pop onto your tray.
- 18-25s: Walk to your counter. A bowl auto-places, the traveler grabs it, eats, shows hearts, and 5 coins burst out and fly to your coin counter.
- 25-30s: The spare bowl pulses with an eat button. Tap it: speed lines, you are Swift for 20 seconds. Lesson learned without text: food is power.
- 30-45s: An arrow leads 40 studs down the road to your home wild (Frostwood for Frostfolk, Emberflats for Emberfolk). At the gate an NPC traveler without the right dish comically turns into an ice cube (or a steaming dizzy puddle); you walk past unharmed with a race-icon checkmark. Three glowing home ingredients (Snow Ginger or Lava Melon) auto-collect.
- 45-60s: Dash back, pot, tap: Ginger Tea (or Melon Ice). Place it on the counter; a waiting traveler pays 15 coins with a bigger burst and sound. You hold 20 coins and the 25-coin 'new soil tile' button starts glowing.

### Core verb
Feed: carry a cooked dish to whoever needs it (your stall counter for a traveler or another player, yourself before an expedition, a frozen player to thaw them).

### Core loop
Gather (plot crops plus wild ingredients) -> cook at the pot -> stock the counter for coins or eat the dish yourself -> spend coins on soil tiles, pot level and basket -> go deeper. Two flavours of gathering alternate: in your home wild there is no timer, so it is relaxed picking with rarer 'Sparkling' rolls the deeper you walk; in the opposite wild you need the other race's dish (45s of Warm or Cool at pot level 1), so it is a push-your-luck dash: grab what you can and get out before the ring timer around your character empties. If it empties you shiver for 5s, then freeze (or overheat) for up to 20s; anyone can feed you the right dish to free you with your haul intact, otherwise you slide back to the gate and lose half of that trip's haul. The payoff for doing both is Fire-and-Ice Pie (turnip + ginger + melon), which sells for 60 against 15 for a single-zone dish and 5 for stew. Around minute 4 a VIP traveler asks for a pie and a beacon points at the nearest stall holding the dish you lack; the first weather front arrives around minute 5-7.

### Place, kind and service in the first slice
Place: seed form only. Two hazardous wilds with three depth bands set risk and reward for where you gather, and your plot sits at your race's end of the road, but you do not yet choose where to settle. Kind: race is present (two races, each immune to one hazard and able to grow that wild's crop at home) and consumables are the heart of the game (four dishes, three effects). Gear is absent. Service: food is the one traded service, sold through a physical stall to NPC travelers and to other players, and thawing a frozen player is rescue and healing in seed form. Protection and hauling are absent. The Caravan is the first AI faction, acting only as a pricey fallback supplier.

### Director and factions
Slice: the director sends weather, not enemies. Every 4-7 minutes (never before every player in the server has had 3 minutes, and never while more than two players are already frozen) a horn sounds, the sky tints for 20 seconds, then a Cold Snap or Heat Wave turns the whole road into band 1 of that hazard for 75 seconds. The native race is untouched; everyone else must eat the right dish, stand inside their hut, buy from a neighbour's stall, or get frozen and be fed free by someone. During the front every traveler wants that dish and pays double, so the trouble is also the native race's payday. There is nothing to fight. The director alternates the two fronts so each race gets to be the rescuer. Next step (addition 3): director budget scales with how much the server has earned, the event table grows (crop blight, a lost traveler to bring back, a festival that is pure upside), and the first faction arrives: the Toll Gang, raccoon bandits who camp on the road and turn away travelers before they reach your stall. They never touch your plot. You can pay their toll in coins, feed them their favourite dish for a few days until they become your stall's escort, or hire a guard (an NPC first, later a player selling protection).

### With friends, without chat
A friend of the other race is your supplier and your customer: they stock the dish you need at 15 coins against the Caravan's 40, you stock theirs, and only the two of you together can keep pies flowing. Coordination is all visible: dishes sit on counters as objects; a beacon points to the stall that has what you lack; when your timer drops under 10 seconds a thought bubble of the dish you need appears over your head automatically; a frozen player is an ice cube with that dish icon on it, and feeding it frees them with their haul and pays the rescuer 10 coins. You can also hand a dish straight to a player by walking up with it on your tray. Friends in the same server each get one extra traveler slot at their stall, and private servers are free.

### Why come back tomorrow
(Added straight after the slice, all computed from timestamps.) Crops planted before you left are ripe, including slow high-value ones (10 minutes to 8 hours). Dishes left on your counter sold to overnight travelers, capped at counter size, and wait as a coin pile to tap. The Caravan's rare slot changes daily: one unusual seed or recipe scroll bought with coins, odds shown. Three traveler orders per day pay seeds.

### Why come back in week 3
A recipe book that grows every Saturday from data rows, not hand-built content: ingredient x wild x Sparkling x effect tag (Warm, Cool, Swift, then Clear, Light, Lucky). Pot and plot ladders long enough that the deep bands take about two weeks to work comfortably. Then the additions in order: creatures to tame and collect with gear from their wool, a third race and wild, the Toll Gang relationship that builds over days, and a second character slot so you can play the other race.

### Monetization
Nothing paid is random. Small repeat purchases: Rescue Flask (19 R$) frees you on the spot with your haul when no player is near; Caravan restock now (15 R$); Thermos (+30s on your next dish, 10 R$). Passes: 2 extra counter slots (149), bigger basket (99), second character slot for the other race (199), scarecrow that auto-harvests your plot (249). Cosmetics from the artist: stall skins, pot skins, outfits for the custom characters. Private servers free. The Caravan's rare daily slot costs coins only and still shows its odds. Custom characters keep the higher 18+ payout rate; confirm the current wording before shipping.

### Technical plan
Server size 8, one place, no teleports. Saved per player (well under 4 KB, session-locked): race, coins, three upgrade levels, recipe book, basket contents, and later soil tiles with planted-at timestamps, counter stock with stocked-at timestamps and last-seen time. Travelers are rows in a server table (position along the road spline, wanted dish, target stall, state) ticked at 5 Hz and sent to clients in one batched remote; clients draw pooled blocky rigs with stepped animation, 16 at most, and a traveler is created only when a counter or the Caravan holds a dish for it. Wild nodes are server-owned respawn timestamps with client visuals; pickups are validated for distance and rate. Hazards are per-player expiry timestamps plus an axis-aligned band check at 4 Hz, with no touch events; a weather front is one server flag that makes the road count as band 1. Dishes on trays and counters are welded, anchored props, not physics. No vehicles in the slice; when carts arrive they move on the same road spline as travelers rather than as physics bodies. Budget: 400 parts per plot, streaming on, everything within the 500-stud low-end draw distance of the road centre. Biggest engineering unknown: getting the artist's Blockbench characters into Roblox as custom rigs with stepped animation that still feel responsive under default phone controls, and how much of that import the Studio tools can automate. Test it in week one with one character before anything else is built on it.

### Clip moment
A Cold Snap rolls down the road and the entire server freezes into ice cubes mid-stride, except the fox-folk, who waddle from cube to cube with trays of tea. The solo version: freezing one step short of the gate with a basket full of Sparkling ginger.

### Prototype test
Put 6-8 strangers on phones in one server with no instructions and watch the log. Working: at least half of them, within their first 10 minutes, eat a dish that came from another player (bought at that player's stall, handed over, or fed to them while frozen) and then enter the wild they are not native to. Killed: fewer than one in five do, meaning they sell only to NPC travelers and buy only from the Caravan, or never leave their home side. In that case it is a solo cooking tycoon and the idea that players will supply each other without chat has failed. A second stop sign: fewer than 70% make their first sale within 60 seconds unaided.

### Everything in the first slice
- One map, one place, 8-player servers: a straight road with 8 plots (Frostfolk plots at the west end, Emberfolk at the east), Frostwood at one end and Emberflats at the other, each wild split into three depth bands (rim, mid, deep) with a visible gate.
- Two custom blocky characters, Frostfolk and Emberfolk, auto-assigned on first join, each with one flag: immune to its home hazard. A mirror on the plot swaps race once for free.
- Gathering: 6 soil tiles per plot growing turnips (40s regrow) and the home crop; wild nodes with 60s respawn; a Sparkling roll per pick (rim 2%, mid 8%, deep 25%). Auto-pickup on touch, basket of 10.
- The pot: four recipes (Turnip Stew, Ginger Tea, Melon Ice, Fire-and-Ice Pie), one tap, 3s cook, dishes are physical objects carried on a tray of 3. A Sparkling ingredient makes a Sparkling dish: 5x price, 2x effect time.
- Effects and hazards: Swift, Warm, Cool as server-side timers shown as a ring around the character; band check four times a second; shiver, freeze or overheat, thaw-by-feeding, slide to gate losing half the trip's haul.
- The stall counter: 3 slots, fixed prices, sells to NPC travelers and to any player who taps a dish; works while the owner is away gathering. A need-beacon appears when you approach a gate without the right effect and points to the nearest stocked stall, player stalls first.
- NPC travelers and the Caravan: at most 16 travelers walking the road, each wanting one dish, spawned only against dishes actually stocked; one Caravan cart at mid-road selling Ginger Tea and Melon Ice at 40 coins, 2 of each per 5-minute restock, so a lone player is never stuck and players always undercut it.
- Coins and three upgrade ladders: soil tiles (25 coins, x1.35 each, to 24), pot level (longer effect: 45/60/80/105s, and bigger batches), basket size.
- Director v0: one event type in two mirrored forms, Cold Snap and Heat Wave.
- Save: race, coins, upgrade levels, recipe book. No offline growth yet.
- Funnel logging: seconds to first sale, first entry into the opposite wild, purchases from another player's stall, thaws given. Without these the playtest result cannot be read.

### Cut for now
- Third race and third wild (marsh fog)
- Creatures, taming, pens
- Gear of any kind (scarves, cloaks, armour)
- Free building, decoration, interiors
- Hired helpers and automation
- Offline crop growth and overnight stall sales (first addition after the slice)
- Hostile or toll-taking NPC factions; all combat
- Player-set prices, coin gifting, item trading between players
- Carts, rail, ships, any vehicle
- Settling inside a wild (outposts) and protection taxes
- Multiple places or region servers
- Inns, beds, infirmaries
- Daily order board, login streaks, leaderboards
- All Robux products (added only after the loop tests well)

### Growth path
- Offline and daily layer: timestamped crop growth, overnight stall sales, the Caravan's daily rare slot, three daily orders. This plus the slice is the launch build.
- Creatures and gear: feed a wild creature its favourite dish three times and it moves into a pen on your plot, producing wool or eggs by timestamp; a loom turns wool into a scarf or cloak that lengthens an effect. Adds the collection game and the missing gear part of 'kind'.
- Third race and third wild (marsh fog, cleared by a new effect), plus hired helpers: a traveler you have fed ten times will harvest or stock for you, removing exactly one job you were doing by hand.
- Director v2 and the Toll Gang: earnings-scaled event budget, a wider event table, and a bandit faction you pay, befriend by feeding, or guard against; players can post themselves as guards for a cut.
- Outposts: claim a second plot inside a wild's band. Deeper bands grow rarer crops and draw more trouble, and need the right race, gear or a steady supply of dishes to hold. Outposts beside an NPC fort or a player's watchtower are shielded for a share of sales. This is the 'place' pillar in full.
- Journeys: a cart, then a handcar on rails along the road, carrying visible crates from outposts to the crossroads, with other players riding or escorting; inn beds and an infirmary as services for travelers and players. A second region reached by ship comes only when player counts can fill it.

### Risks
- Players may ignore each other's stalls and use the Caravan; the 40-versus-15 price gap, tiny Caravan stock and the beacon are the only levers, and they are untested.
- A server with only one race present loses the whole point. Auto-assign balances first joins, but returning players bring a saved race.
- Auto-assigning race removes a choice cozy players may care about; the free mirror swap may not be enough.
- Cooking is one tap. If serving and the timed dash do not carry the fun, the loop is thin.
- Losing half a haul to a freeze may put off the cozy audience even though the home wild is always safe.
- Weather fronts could feel like punishment to a newcomer; the 3-minute grace and the hut are the mitigations.
- Cook-ingredients-for-effects has a known Roblox precedent (Wacky Wizards). Ours is an economy and survival use, not near-identical, but thumbnails must not look like it.
- Four recipes and two wilds will be exhausted in one or two sessions; the slice proves the loop, not retention.
- Fixed prices and no gifting limit alt-account abuse now, but any later trading opens it.
- Depends on the artist for two characters, traveler variants, two wilds and readable effect visuals within the first weeks.


---

## Sail a Ferry (angle: journey, 12/30)

You captain a small ferry carrying fantasy travelers across one sea between a safe port and a volcano isle, choosing each trip between the long, taxed, guarded channel and the short pirate reef. A director paces trouble onto each boat, and pirates can be paid, befriended or outrun, never only fought.

### First 60 seconds
- 0-3s: Spawn already seated at the tiller of a small dory at sea, 3 blocky travelers aboard, lighthouse beam dead ahead. A ghost thumb shows the drag; the boat moves the moment the thumb does.
- 3-10s: A line of glowing floating crates leads toward the port. Each one the hull touches pops '+5' with a chime and stacks visibly on the deck.
- 10-20s: A castaway waves from a raft inside a glowing ring. Steer through it: they hop aboard, all passengers cheer, their faces turn to smiles.
- 20-35s: Enter Lantern Port. Coast into the glowing berth and the boat snaps to the pier on its own. Passengers hop off one at a time tossing coins (+10, +10, +10, +20), then the crates slide off (+5 each). About 75 coins.
- 35-45s: A sign at the berth pulses with a seat icon and '50'. Tap it: a fourth bench hammers into the boat with a puff.
- 45-60s: Four new travelers with a volcano icon over their heads walk down the pier and seat themselves. Push the thumbstick to cast off. Ahead, two buoy gates: a green shield gate (channel) and a skull-flag gate (reef). The first pirate skiff meets them on the reef at about 90-120s.

### Core verb
Steer: one thumb turns a loaded boat toward the next dock, through floating salvage and around trouble.

### Core loop
Dock (travelers board by themselves when seats are free) -> pick a lane at the buoys -> steer 30-50s, scooping salvage and handling one or two director events -> dock at the other end, where each traveler pays fare by mood and crates sell -> spend coins at the berth sign on seats or sail speed -> travelers for the return leg board. One leg is 45-75s. Numbers that go up: coins, seats (3, 4, 6), speed, pirate hearts.

### Place, kind and service in the first slice
Place: present as where you sail, not where you settle. The Channel is safe, long and taxed 20% by the Guard; the Reef is short, rich in salvage and pirate water. Settling is absent: the berth is a fixed parking spot with one sign.
Kind: present only in the passengers. Two traveler races react differently to the same trouble, so the mix you can see on your benches should change which lane you pick. Player race, gear and consumables are absent.
Service: the whole job is a service (transport) sold to NPCs. Protection is bought from one AI faction by toll and negotiated with another by payment or gifts. Player-to-player services are absent.

### Director and factions
Each boat has its own director state on the server. Threat builds faster the more fares and crates are aboard and the more dangerous the lane, so trouble finds players who are doing well and leaves a struggling or brand-new boat alone. It spends threat on a small deck (castaway, squall, pirate skiff), never fires within 20s of the last card or within 150 studs of a port, gives a quiet crossing after a loss, and caps pirates at 3 skiffs per server. A reef crossing sees about two cards, a channel crossing about one mild one. New trouble later is one data row plus one model.
Two AI factions. The Harbor Guard sells safety for a 20% toll on the Channel. The Reef Pirates can be paid (30% of this trip's fares), befriended (gift a salvage crate for a heart; at 3 hearts they wave you through), or outrun in a 10s chase. There is no attack button. Losing costs crates and passenger mood, never saved coins, so cozy players can live on the Channel or buy peace while risk-takers farm the Reef.

### With friends, without chat
In the prototype other players are only visible: up to 8 loaded boats crossing the same sea, and anyone can sit on a free bench of someone else's boat for the ride. The first addition after the prototype makes a friend worth having: two crew seats on every boat. The Hook seat taps salvage at three times the hull's reach; the Galley seat taps passenger bubbles to hand out tea and lift mood. Each crewed seat adds 25% to fares, split evenly. The seat you take is your role, so nothing needs saying. Coordination is a tap-the-sea ping that drops a light beam both players see, plus the boat's horn. Private servers are free so joining a friend counts as deliberate co-play.

### Why come back tomorrow
The prototype alone has only the upgrade ladder and pirate hearts, which is not enough to launch on. The launch build adds growth steps 1 and 2: a home dock whose tea planters and traveler inn fill while you are away (computed from timestamps, capped at 8 hours so there is something to collect each day), and a tide board at the port that rotates daily, showing in icons which race or destination pays double today and which salvage is floating. Pirate hearts and Guard standing persist, so yesterday's gifts pay off today.

### Why come back in week 3
A boat ladder that takes weeks (dory, sloop, paddle ferry, galleon, each with seat, sail and hull tiers); faction tracks with real rewards at the top (5 pirate hearts = a pirate escort, Guard rank = toll waived); a deck-critter collection with rare rescues from castaway and salvage events; hired lines that keep earning and need protecting; and one new director card added to the deck most Saturdays, which is cheap because a card is data plus one model.

### Monetization
Free private servers. Small direct purchases at 20-80 Robux that recur naturally: sail colors, flags, figureheads, horn sounds, lantern styles, plus a daily rotating harbor stall of three such items (some for coins, some for Robux) to give a reason to spend on many separate days. Convenience passes later: a second berth, a larger crate rack. A provisions hamper (a fixed, listed set of teas and buns that lift passenger mood for 10 trips) is bought directly, not rolled. No paid random items: critters come only from play. Nothing sold removes pirates or wins chases, and nothing touches the Mild rating since there is no combat.

### Technical plan
Server size: 8 players, one sea, no regions. Servers are disposable; nothing in the world is saved.
Saved per player (one data store key with a session lock): coins, boat upgrades, pirate hearts, tutorial flag, last-seen timestamp, trip counts.
Boat: a single simple assembly with one box hull on a flat water plane, moved by constraint movers with network ownership given to the seated driver; bobbing is cosmetic on each client. The server checks speed against the cap and runs dock, pickup and event triggers by distance at about 5 Hz. Players are always seated while a boat moves, which sidesteps the standing-on-a-moving-vehicle jitter.
NPCs: travelers and pirates are rows of server data (race, mood, seat, destination; skiff position on a pursuit curve). Clients draw the artist's blocky rigs attached to seat points only for boats within about 300 studs. Travelers spawn only when a docked boat has a free seat, so the worst case is 8 boats x 6 seats. Open water means no pathfinding.
The low-end draw distance is 500 studs and the lanes are longer, so the destination is shown by a HUD arrow and a tall light beam, not by seeing the island.
Biggest unknown: whether 8 player-owned boats with seated riders and client-drawn passengers look smooth to each other on a low-end phone at 30 fps. Build that test in week one before any content.
Art needed from the designer for the prototype: one dory with 6 seat points and a crate rack, two traveler rigs with walk, sit, cheer and grumpy poses, a pirate skiff and captain, a raft, a crate, a pier kit, a lighthouse, the volcano dock. Grey boxes stand in until then.

### Clip moment
Six screaming passengers, a pirate skiff two boat-lengths behind, you clip a reef rock and a Mossling flies overboard; you loop back, scoop him out of the water and make the harbor gate as the pirates peel off. The quieter one: you toss the pirate captain a crate and the whole pirate crew does a happy dance and escorts you in.

### Prototype test
Ten strangers on phones, no instructions, watched or logged. Working: at least 7 of 10 dock within the first 60 seconds, and at least 7 of 10 start a third leg unprompted, with at least half choosing the Reef again after their first pirate encounter. Kill: fewer than half start a second leg, or testers look away or stop steering during crossings (the trip reads as waiting), or nearly everyone settles on one lane and never switches.

### Everything in the first slice
- One sea map (~2,400 x 1,600 studs): Lantern Port with 8 berths, Emberfall volcano dock, the Channel lane (~2,000 studs, Guard gate that takes 20% of that trip's fares at payout) and the Reef lane (~1,200 studs, rocks, more salvage).
- One boat (dory): one-thumb steering at 40 studs/s, no wheels or buoyancy physics, auto-snap docking, rock bump = 1.5s stall.
- Travelers: 2 races, spawn only when a docked boat has a free seat, walk aboard, each has a 3-state mood face; fare 10 coins x0.5 / x1 / x2 by mood. Mossling: -1 mood when pirates appear unless paid or waved through. Emberkin: +1 mood when you outrun pirates.
- Salvage crates: floating pickups worth 5 coins, stack on deck (max 6), sold on docking; also what pirates take and what you gift.
- Director, per boat: threat points accrue each second at sea (Reef x2, Channel x0.5, scaled by value aboard), spent on 3 cards: Castaway (15, good), Squall (25, soaks passengers unless you turn bow into the arrows), Pirate skiff (40). 20s minimum gap, a grace crossing after being caught, first two trips scripted.
- Pirate encounter: skiff pulls alongside with two icon buttons for 5s: coin pouch (pay 30% of fares aboard) or crate (gift one, +1 heart). Steer away instead and a 10s chase starts with wind-gust boosts on the water. Caught = lose up to 2 crates and 1 mood each; banked coins are never touched. At 3 hearts they wave you through.
- Berth sign upgrades: seats 3->4->6 (50, 600), sail speed 3 levels (100, 250, 600).
- Save per player: coins, upgrades, pirate hearts, tutorial flag.
- HUD with no words: coin count, arrow to destination, row of passenger faces.
- Playtest logging: time to first dock, legs per session, lane picked per leg, pirate choice, where the player quit.

### Cut for now
- Homestead building, farming and any production chain
- Playable races and custom player characters (players sit as their own avatar)
- Weapons and combat of any kind
- Hired crews, second boats, automated lines
- Creatures and collections
- Crew stations and co-op bonuses (first addition, not in the prototype)
- Player-to-player trade or contracts
- Regions, teleports, land routes, rail
- Cargo contracts and market prices
- Boat decoration and cosmetics, Robux store
- Daily board, offline income
- Day/night, weather beyond the squall card, leaderboards

### Growth path
- Crew seats: Hook and Galley stations, the ping beam, fare bonus per crewed seat, free private servers. Makes friends useful and turns tea into the first consumable.
- Home dock: the berth becomes a small pier plot with tea and berry planters that grow offline and an inn where waiting travelers stay and pay; plus the daily tide board. This is the homestead seed and the daily return hook. Launch with steps 1 and 2 done.
- Deck critters and tow beasts: rare rescues from castaway and salvage cards (gull spots salvage, otter patches hull, a young sea serpent tows faster). Free rolls from play; the collection is the long tail.
- Hire it away: hire a helmsman of a given race (each with a trait, such as faster in rain or calmer passengers) and the boat runs its route as a scheduled line, drawn in the world while you are online and computed from timestamps while you are not. Other players can ride it for a ticket. You sail a new boat by hand. Lines attract the director in proportion to their value.
- Protection and rescue as trade: an icon contract board at the port where a line owner buys a Guard patrol, a pirate escort (high hearts), or another player's escort for a cut of fares; stalled boats can be towed in for a fee. First player-to-player services, still no chat.
- More places with needs: a frozen port where only Frostkin crew, fur coats or hot tea keep passengers happy, deeper volcano docks, goods chains feeding boat parts, playable races on the designer's custom characters, a choice of which port your dock lives at, and only then a second sea as a second server-place with land and rail routes inland.

### Risks
- Hauling as the whole job has stayed small on Roblox in the games checked. This bets that passengers with faces, lane choice and director trouble make the crossing the fun part; if crossings feel like waiting, the concept fails.
- Steering with nothing to aim at is dull. Salvage lines, rocks and events must give the thumb something to do every 3-5 seconds.
- Boat smoothness across clients on low-end phones is unproven until week one's test.
- The prototype has no return hook of its own. It tests the first session only; launching requires growth steps 1 and 2.
- Eight separate boats can feel like eight solo games. Crew seats must land early or the co-play signal stays near zero.
- Pirate encounters repeat quickly with one card. The deck needs to reach 8-10 cards by launch.
- Lane balance: if either lane is plainly better, the place pillar collapses into one route.
- A pirate-and-boat theme invites comparison with existing boat games; I did not check the catalog for a ferry game this close. Check before naming and thumbnail work.
- The 500-stud draw limit means the sea can look empty on weak phones; fog and beacons have to carry the look.


---

# The three judges

## Market and discovery

**Ranking:** Feed the Dragon, Pack a Yak, Run a Hero Inn, Feed the Frontier, Sail a Ferry

**Verdict:** Prototype Feed the Dragon first. Through the discovery lens it has the best chance of a 16+ stranger tapping the thumbnail and still being there at 60 seconds: the title is the tutorial, the dragon grows inside the first minute, nothing in that minute is a choice, a read or a wait, and the shared dragon plus goblin raids keep it from reading as another cozy tycoon. Cut its slice to carry, counter, bowl and one raid for the first build, and graft aging cheese and the overload stack so it has a tomorrow hook and some skill for older players. If the week-one goblin-bonk test fails or playtesters ignore the bowl, Pack a Yak is the fallback: it is the most distinct concept and has the best co-play mechanic, but its seated ride is a real risk. I scored from the project's research files only and did not search the Roblox catalogue for title or premise collisions.

### Feed the Dragon: 8/10
- **Strongest:** Best title and thumbnail for play-through: 'Feed the Dragon' is verb + noun, sits on the deepest proven demand (creatures) and next to a pattern in the current top 5 (Throw Food For Animals), and the game keeps the promise inside the bounce window. Coins arrive by 15s, a goblin to bonk by 45s, and the dragon visibly grows by 60s, with no choice, no reading, no building and no waiting. NPC-run plots keep the village whole in the one- or two-player servers a launch will actually have.
- **Weakest:** The slice is the largest of the five (shared dragon, director, three raid answers, pantry, friendship flip, NPC plot hand-over) and has no return hook until the 'launch pack' is added, so day-2 and week-3 retention are untested by the prototype. The title may also over-promise: a stranger tapping a dragon thumbnail may expect a dragon of their own, not a shared one behind a bakery.
- **Weak on criteria:** 4. Return hooks for tomorrow (none in the slice; all deferred to the launch pack); 5. Return hooks for week 3 (two trades are thin; relies on growth steps 1 and 2); 9. Plays to Claude's strengths (widest slice; bonking server-data goblins at phone latency and mid-raid plot hand-over are unproven); 6. Better with friends (mechanics are good, but neighbour moments will be rare at launch player counts); 1. One-glance clarity (minor: thumbnail could promise a personal pet dragon the game does not give)

### Pack a Yak: 7/10
- **Strongest:** The most distinct of the five and the least likely to read as a cozy tycoon: a tiny yak under an absurd tower is a thumbnail that explains itself, the title rhymes and is the tutorial, and the far-market multiplier maps onto the proven 'power up, go farther' incremental pattern. The overload line gives 16+ players a real push-your-luck decision every cycle, and the convoy bell is the cleanest intentional co-play mechanic proposed.
- **Weakest:** The player is seated and passive from second 25, and every later cycle contains a 30-90s ride (180s on the hot road without ice). The research found hauling as the whole job has stayed small on Roblox, and the prototype has no return hook and no creature collection of its own.
- **Weak on criteria:** 4. Return hooks for tomorrow (none in the prototype; drover and aging cheese are a later step); 2. Fun within 15 seconds (loading is good, but a seated ride starts at 25s and risks reading as waiting); 5. Return hooks for week 3 (depends on the beast collection, which is not in the slice); 10. Mobile-first controls and performance (riding a client-rendered moving beast, hopping off and on, is unproven on low-end phones)

### Run a Hero Inn: 6/10
- **Strongest:** The only slice with a working tomorrow hook built in: 4-hour Deep trips resolved from timestamps, crates waiting at the door, and a reason to fill every Board slot before quitting. It is also the closest to launchable with nothing added, the first minute has zero waiting or choosing, and timer-skip products (Express Courier, Dinner Bell) are a proven source of repeat spend days.
- **Weakest:** For its first 60-70 seconds, and on any honest thumbnail, it is a fantasy restaurant tycoon, which is exactly the volatile cozy field launched since September 2026. Restaurant Tycoon's own peaks came from outside pushes a fresh account cannot reproduce, and tap-to-serve is shallow for the 16+ players who must supply the 250 engaged plays.
- **Weak on criteria:** 12. A real twist (the expedition twist is invisible until about 70s and is a timer, not a journey); 1. One-glance clarity ('Hero Inn' needs explaining; the thumbnail reads as a restaurant game); 3. Works for 16+ (tap-and-auto-walk serving has little skill or decision in it); 5. Return hooks for week 3 (thin by the designer's own admission); 7. Clip-worthy moments (a rare guest walking in is weak; the Magpie chase is the only real one)

### Feed the Frontier: 5/10
- **Strongest:** The best single clip (a whole server frozen into ice cubes while one race waddles round with tea) and the only slice where the designer's 'kind' pillar is the actual game. The timed dash into the hostile wild is real play for a 16+ audience.
- **Weakest:** The first minute teaches seven things in a row (crop, pot, counter, eat, wild, hazard, second recipe) under an abstract title, and the point of the game needs a player of the other race in the server. At launch most servers hold one or two people, so most strangers will meet a solo cooking tycoon with a pricey caravan.
- **Fatal flaw:** The distinguishing mechanic only exists when both races are present in a server, and a new game's servers will mostly hold one or two players.
- **Weak on criteria:** 1. One-glance clarity ('Feed the Frontier' is not verb + concrete noun; no obvious thumbnail); 2. Fun within 15 seconds (first sale at 25s, and the minute is a seven-step guided chain); 6. Better with friends (it is not merely better with others, it depends on them, which fails at launch counts); 4. Return hooks for tomorrow (no offline growth in the slice); 5. Return hooks for week 3 (four recipes, exhausted in two sessions); 12. A real twist (cook-for-effects has a known Roblox precedent; otherwise reads as a cooking tycoon)

### Sail a Ferry: 4/10
- **Strongest:** The thumb is steering within three seconds and crates pop coins by second 5, with no menu at all. The pay, befriend or outrun pirate encounter is the clearest version of the designer's faction idea.
- **Weakest:** It bets the whole game on hauling, the one pattern the research found has stayed small, and the prototype has no return hook and no co-play, so the launch build needs two further growth steps. The 500-stud low-end draw distance leaves the sea looking empty on the phones that matter, and 'Sail a Ferry' is a flat promise for a thumbnail.
- **Fatal flaw:** It cannot launch or retain as specified, and its core activity is the one the research flags as staying small on Roblox.
- **Weak on criteria:** 4. Return hooks for tomorrow (none; the designer says it cannot launch as specified); 6. Better with friends (other players are only visible in the prototype); 12. A real twist on a proven pattern (hauling as the whole job is unproven, and boat-and-pirate games invite comparison); 10. Mobile-first controls and performance (eight player-owned boats, empty sea at 500 studs); 5. Return hooks for week 3 (all in later steps); 1. One-glance clarity (clear but unexciting; a ferry is not something a 16+ stranger taps for); 2. Fun within 15 seconds (steering is immediate, but 30-50s crossings risk reading as waiting)

### Ideas worth grafting onto the top pick
- From one-verb: aging cheese (x2 after 1 hour, x5 after 8, x10 after 24, shown by rind colour). It gives the dairy a timestamp-only tomorrow hook inside the slice with no new system; give the bakery a matching slow-proof loaf.
- From one-verb: an overload line on the head stack. Carrying past the safe count is allowed but spills when a goblin bumps you. This gives 16+ players a push-your-luck decision in the carry verb and makes the twelve-cheese sprint to the bowl a skill moment.
- From one-verb: the bell plus one big Join button. Ring it at the nest to call everyone to a group feed, with a per-extra-player bonus, so joining a friend has a visible first action.
- From one-verb: per-player director mood. After a raid where a player lost goods, their next event is guaranteed to be the caravan or nothing.
- From hospitality: a daily guaranteed rare traveler (Knight or better on the first caravan of each real day) and a guestbook with a 1-in-200 entry, so the slice has a rarity roll and a collection from session one.
- From hospitality: Dinner Bell and Express Courier style products at 10-50 Robux (call a caravan now; finish the aging now), which are repeat purchases suited to spend days.
- From hospitality: a colour ring on the target you are heading for, so two players do not both run to the same goblin or pantry.
- From hospitality: a triple-paying relief guest after every raid, as well as the caravan, so the calm beat is personal even on a plot the raid skipped.
- From homestead: funnel logging from day one (seconds to first sale, first bowl feed, first step onto another plot, where the player quit). Without it the playtest cannot be read.
- From homestead: a Sparkling roll on each good produced (a few percent), with a Sparkling good fed to the dragon giving a visible effect such as a coloured flame. This is a rarity layer built from data rows.
- From homestead: alternate which trade the event favours (a caravan wanting bread, then one wanting cheese) so each trade takes turns being the one in demand.
- From journey: the 5-second two-icon offer format for the goblin chief, and the rule that threat scales with the value sitting on your counter, so trouble finds players who are doing well.

### What all five missed
1. The thumbnail is the first screen of the game and nobody designed it. Play-through from the thumbnail is the top ranking signal, yet no concept specifies the thumbnail image, checks that the first 10 seconds match it, or plans to test variants before building.
2. Every prototype test is a watched hand-the-phone test. A watched tester does not bounce. None proposes a small sample of real Roblox traffic to measure play-through and sub-60s bounce from strangers who can leave with one tap. Ad players never count for ranking, but they do measure the funnel.
3. Bounce is also measured at 61-180 seconds. All five script the first 60 seconds to the second and leave minutes 2 and 3 to the loop.
4. None gives the player a creature of their own to raise or collect in the slice, though that is the element with the deepest proven demand. The dragon is shared, the yak is a single vehicle, and guests are not owned.
5. Co-play and spend days are measured from day 1, yet every slice defers the invite prompt, friend-join reward and all purchases to after the prototype, so two of the six ranking signals go untested.
6. None says what a 17-to-25-year-old, the player who must supply the 250 engaged plays, is still doing at minute 10 that needs judgement. The only candidates are the yak's overload line and the homestead dash.
7. The first session at launch will be solo. Only Feed the Dragon (NPC-run plots) designs for an empty server; the others assume a road of eight players.


---

## Buildability and technical risk

**Ranking:** Pack a Yak, Run a Hero Inn, Feed the Dragon, Feed the Frontier, Sail a Ferry

**Verdict:** Prototype Pack a Yak first. It needs the fewest systems before a playtest means anything, one stranger on one phone can answer its kill question, and it faces the vision's hardest technical unknown (a player riding a moving carrier with visible cargo) in its cheapest form, a walking-pace follower on a fixed spline, in week one. Its carrier-with-slots model is the only growth path here where carts, rail and ships are more rows and models and not a second implementation. Run a Hero Inn is the safe second choice with no risky technology and a built-in offline hook, but it is a heavier slice, its twist cannot be tested until week two, and it postpones every journey problem; take its timestamped expeditions, tension director and phone stress test into the yak build, and bring the inn back later as the roadside stop.

### Pack a Yak: 8/10
- **Strongest:** Fewest systems before an honest playtest, and the only growth path that is truly additive. Pick, load, ride, sell and one upgrade is about five systems, all testable solo by the programmer and then by a single stranger; the kill question (do they overload on purpose and stay with the ride on trip three) needs no full server. NPC load is near zero (Magpies and the peddler exist only at an event spot), 8 yaks with 24 welded props is under 200 parts, and 'a carrier is a path follower with slots' extends to carts, barges and rail without touching the save format or the director.
- **Weakest:** It puts a player on top of a moving thing in week one, which is the research's flagged unknown, and the proposed implementation (server-data yak, client-rendered rig, owner-controlled seat part) is the harder way to do it: remote clients would see the rider replicated by physics and the yak interpolated from data, which can drift apart. Hop-off, chase a spill, hop-on adds state edges (yak pause timer, rider disconnect mid-trip, convoy leader leaving). The slice also has no offline or daily layer, so it cannot launch until growth step 1 ships.
- **Weak on criteria:** 4. Return hooks for tomorrow (none in the slice; drover, aged cheese and boards are a required pre-launch addition); 5. Return hooks for week 3 (depends on beasts and new roads that do not exist yet); 10. Mobile-first controls and performance (rider on a moving carrier on a low-end phone is unproven until the week-one test); 12. A real twist (walk-over stacking is a familiar mobile pattern; the twist rests on the ride and the overload choice)

### Run a Hero Inn: 7/10
- **Strongest:** Zero risky technology and the only slice that is launchable as written: no vehicles, no physics, no pathfinding service, no player-to-player transfer of goods, and each inn is an isolated simulation with its own director, so there are almost no multi-actor edge cases. Offline expeditions with a loot seed fixed at departure are plain timestamp arithmetic and are already in the slice, so the tomorrow hook is tested by the same prototype. Restaurant Tycoon proves the guest-per-seat pattern holds on phones.
- **Weakest:** It is the heaviest slice of the low-risk concepts: guest state machine with multi-need matching and patience, seat allocation, custom tap-to-serve with auto-walk around furniture (a control scheme that fights Roblox's default thumbstick and camera drag), expeditions, pads, tension director, a three-way Magpie encounter with a tap chase, and co-op rings. The twist cannot be judged until expeditions exist, so the honest playtest is week two, not week one. Up to 40 rigs with bubble GUIs in one room is the real phone risk, and fixed-layout waypoint paths become a rewrite the day free building or the homestead behind the inn arrives. The 'go yourself' step is a new game mode in a reserved server, not an addition, and it defers all carrier technology the vision needs.
- **Weak on criteria:** 12. A real twist (reads as a restaurant tycoon for the first 60 seconds); 5. Return hooks for week 3 (thin by the proposer's own account); 10. Mobile-first controls and performance (tap accuracy in a crowded room; 40 rigs plus bubbles on a low-end phone); 9. Plays to Claude's strengths (six guest kinds plus bandits, each needing walk, sit, eat, carry poses: the most rig and animation work of the five); 1. One-glance clarity (the title does not say what makes it different from a restaurant game)

### Feed the Dragon: 6/10
- **Strongest:** Walk-into carry is the lowest-risk input on a phone and the easiest for an AI to drive through Studio's input simulation: no tap targeting, no buttons, no custom controls. The hired-hand code doubling as the NPC-run plot code is a real saving and keeps the loop whole for a solo tester. Six plots in a ring is the smallest map and part budget of the five, and trades as data rows is honest addition.
- **Weakest:** The most shared state of any concept: one dragon whose level is the sum of whoever is present, raids that touch every plot, three raid resolutions that can overlap, crates that change hands between players, system-paid pantry rewards (a coin faucet two alt accounts can farm), cross-plot purchases, and an NPC plot being replaced by a joining player mid-raid. Saved trade collides with the fixed 3 bakeries / 3 dairies rule when four bakers join. Bonking data-only goblins at 150-300 ms needs a lenient client-authoritative hit check that is easy to spoof. The defining test needs 6-8 people in one server, which this team cannot stage often.
- **Weak on criteria:** 6. Better with friends, without needing chat (the neighbour layer only appears with several real players; launch servers will hold one or two); 4. Return hooks for tomorrow (cut from the slice; needs the launch pack); 10. Mobile-first controls and performance (bonk hit registration against server-data goblins under phone latency); 1. One-glance clarity (title invites comparison with dragon-raising games and may mismatch the thumbnail promise); 5. Return hooks for week 3 (two trades are thin)

### Feed the Frontier: 5/10
- **Strongest:** Every individual system is cheap and well understood: hazards as per-player expiry timestamps with an axis-aligned band check at 4 Hz, travelers on one road spline capped at 16, anchored dish props, no vehicles, no pathfinding. It is also the closest structural match to the vision's kind and place pillars, so later outposts and carts on the same spline are additions.
- **Weakest:** Nothing can be judged until almost everything works and a full mixed server exists: plots, crops, wild nodes, pot, tray, effects, freeze and thaw, stall with player-to-player purchase, travelers, Caravan, beacon, weather director and two races all have to be in before the stated test (did they eat another player's dish) means anything, and that test needs 6-8 strangers of both races online at once. It is the latest honest playtest of the five. It also puts the artist's custom-rig import pipeline on the critical path in week one, and a saved race means launch servers with one or two players will often hold a single race, which removes the point of the design.
- **Fatal flaw:** The hypothesis it exists to test cannot be tested by the programmer alone or by one stranger; it needs a full two-race server, which a new game on a fresh account will rarely have even after launch.
- **Weak on criteria:** 6. Better with friends, without needing chat (core loop requires both races present; a one-race or one-player server falls back to the Caravan); 4. Return hooks for tomorrow (no offline growth in the slice); 5. Return hooks for week 3 (four recipes, two wilds); 9. Plays to Claude's strengths (custom Blockbench rigs under default phone controls are a week-one dependency on an untested import path); 12. A real twist (cook-for-effects has a known precedent); 2. Fun within 15 seconds (the first minute is five chained steps with two 40-stud walks)

### Sail a Ferry: 4/10
- **Strongest:** Keeping every player seated while the boat moves sidesteps the standing-passenger jitter, open water needs no pathfinding, and traveler count is hard-capped at 8 boats times 6 seats. The playtest logging list is the most concrete of the five.
- **Weakest:** It stacks the most unknowns: free-steered boats under client network ownership with server speed checks, auto-snap docking, pirate skiffs that live as server data chasing a client-authoritative boat (the chase outcome is decided across that gap at phone latency), and a 2,400 by 1,600 stud sea against a 500-stud low-end draw distance. Steering feel is continuous analogue input, the hardest thing for an AI to evaluate through input simulation. The prototype has no return hook and no co-op by the proposer's own account, so launch needs a home dock with planters and an inn, which is a second game. Hired lines later need boats simulated on the server and from timestamps, a second boat implementation beside the client-owned one: that is a rewrite, not an addition.
- **Fatal flaw:** The slice is not a launchable game and its growth path replaces the boat model it is built on, so it fails both (c) and (d) of the brief.
- **Weak on criteria:** 4. Return hooks for tomorrow (absent; requires growth steps 1 and 2); 5. Return hooks for week 3 (all in future additions); 6. Better with friends, without needing chat (absent from the prototype); 10. Mobile-first controls and performance (boat smoothness across clients; empty sea beyond draw distance); 9. Plays to Claude's strengths (success rests on steering feel); 12. A real twist (hauling as the whole job has stayed small; boat-game catalogue unchecked)

### Ideas worth grafting onto the top pick
- Simplify the yak itself: make it a real unanchored assembly with network ownership given to its rider, constrained to the road spline, with the server only checking distance against max speed. That is ordinary Roblox vehicle replication at walking pace, so remote clients see rider and yak move together. Keep a fallback ready: the player leads the yak on foot and it follows on the spline, which removes the riding risk entirely if the week-one test fails.
- From hospitality: resolve every offline or hired trip from os.time() on load with the outcome seed fixed at departure, so rejoining cannot reroll. Use this for the drover's trips and store the trip list in the same save key.
- From hospitality: build the offline layer into the prototype rather than after it. One Deep-style long trip slot (the drover on a 4-hour far road) gives the prototype a tomorrow hook and lets the second-day test measure something.
- From hospitality: a week-one phone stress scene before content. For the yak that is 8 yaks with 24-item stacks, riders seated, a convoy of 4, on a real low-end phone.
- From hospitality: per-player tension meter that falls when the player is losing goods and forces a calm stretch plus a generous relief card after trouble. Replace the yak's simpler per-trip budget with this so the director is one data-driven deck from the start.
- From settlement: one code path for hired help and for NPC stand-ins. The drover that walks a second yak should be the same code that runs NPC caravans, so a server with one player still has a busy road and convoys to join.
- From settlement: the rule that a neighbour can never leave you worse off than the raider would. Apply it to spills: anyone may return a spilled item for a system-paid tip or keep it, but only after the Magpie window, so the owner's loss is never greater than the event's.
- From settlement: give every plot record a risk number now, even though all camps are equal, so 'settle beside a far market' later is a data change.
- From homestead: implement the heat rule as a per-carrier expiry timestamp plus an axis-aligned zone check a few times a second, no touch events, and write it as a general climate-versus-kind table from day one.
- From homestead and journey: funnel logging in the first build (seconds to first load, first sale, overload count per trip, market chosen, toll choice, where the player quit). Without it the trip-three test cannot be read.
- From homestead: a pricey NPC fallback supplier (the Caravan) for anything a player might otherwise need another player for, such as ice, so a lone player is never stuck.
- From hospitality, as the first settle-the-road addition: the roadside inn as the stall type. A mid-road stop that feeds and patches passing yaks and riders is where the inn concept attaches to the yak game without a new mode.

### What all five missed
None of them plans for how the programmer actually tests. An AI driving one Studio client cannot stage a convoy, a helper in an inn, a two-race stall trade or a six-player raid, yet every concept's social claim depends on those. The first build needs a test harness as a deliverable: scripted bot players that can occupy plots and perform the core verb, an injectable clock so offline and 4-hour timers can be jumped in seconds, a seeded director that can be forced to play a named card, and a debug panel to set coins and upgrade state. Related gaps: no concept gives its save a version number and migration step, although 'growth by addition' means the save shape changes every Saturday; none says how a weekly update moves players off old servers without losing in-flight state (a trip in progress, a raid, a carried stack); and none defines what happens to a plot, carrier or shared object when its owner disconnects mid-event. Finally, every proposal treats the artist's rigs as arriving on time: none states that the first playtest runs on grey boxes with default avatars, which is what makes a week-one test possible.


---

## Fidelity to the user's vision

**Ranking:** Feed the Dragon, Feed the Frontier, Pack a Yak, Run a Hero Inn, Sail a Ferry

**Verdict:** Prototype Feed the Dragon first: it is the only slice where protection is bought with what you make, raiders can be paid, befriended or resisted, and a neighbour can rescue or pocket your goods, which are the three things the designer added in his own words after the first pitch, and it still works when a server holds one real player. Its gap is the one Feed the Frontier fills, so build it with that concept's kind rule grafted in from day one (goods as consumables with a specific effect, folk with one strength and one need, and the mirrored weather card), otherwise the races he called incredibly interesting are only a costume. Feed the Frontier is a close second and would be first if launch servers were full; Pack a Yak is the best statement of 'real things, not menus' and should be kept as the hauling addition rather than the first game. Run a Hero Inn is the safest and the least his, and Sail a Ferry drops the homestead and the cozy half altogether.

### Feed the Dragon: 8/10
- **Strongest:** It is the designer's fourth message built as a mechanic: a cozy producer buys protection from an AI protector by paying in what she makes (the dragon bowl), and raiders can be paid off, befriended or resisted, which is his pirate 'thorn' almost word for word. The dropped-crate rule (return it for a tip or pocket it) and free-riding on the dragon are the only places in any of the five where a player can choose to help or exploit a neighbour, so his A/B/C story has a real seed. Cheese, baking, a dragon and a dairy creature come straight from his cozy list, and NPC-run plots keep the village whole when only one or two real players are in the server.
- **Weakest:** Kind is the thinnest of his pillars here. Folk are a label on a trade, assigned by the server, with no strength, need or reaction to food or environment, and that is the part of RimWorld he called incredibly interesting. Place is absent, as the author admits. The first 30 seconds (walk into oven, stack on head, drop at counter) is a familiar mobile carry-tycoon shape, so everything distinctive has to land between seconds 30 and 60.
- **Weak on criteria:** 4 Return hooks for tomorrow: nothing in the slice; offline chest, daily gift and peddler are all a pre-launch addition; 5 Return hooks for week 3: two trades and one raid type are thin; depends on growth steps 1 and 2; 12 A real twist: present from second 30, but the opening half-minute reads as a generic stack-and-sell tycoon; 10 Mobile-first controls and performance: bumping a data-only goblin at phone latency is unproven; 6 Better with friends: strong by design, but the neighbour moments will be rare while launch servers hold one or two real players

### Feed the Frontier: 7/10
- **Strongest:** The only concept where the player is a race with a real trade-off in the first minute: at home in one wild, helpless in the other, and the food you make for free is the consumable your neighbour needs to survive. That is his xenotype paragraph and his frozen-wasteland example at once, and his 'baked good with very specific stat boosts' is the core item. Interdependence is structural rather than a bonus, thawing a frozen player is the travelling-hospital seed, and the prototype test measures exactly the right thing (did you eat something another player made, then go where your race cannot).
- **Weakest:** The point of the game needs a player of the other race in the server, and at launch most servers will hold one or two people with saved races, so in practice it usually falls back to the Caravan and becomes a solo cooking tycoon. Protection for a price and a pay-or-befriend faction are both missing from the slice; the director sends only weather, so the stories are milder than the ones he described. Losing half a haul and being frozen by weather on your own plot will cost some cozy players.
- **Weak on criteria:** 1 One-glance clarity: 'Feed the Frontier' and a two-race stall game are hard to show in a thumbnail; 2 Fun within 15 seconds: the first 25 seconds are pick, cook, sell; the race rule does not appear until 30-45s and the minute has seven taught steps; 4 Return hooks for tomorrow: no offline growth in the slice; 5 Return hooks for week 3: four recipes and two wilds run out in a session or two; 6 Better with friends: excellent with a mixed-race pair, close to nothing in a one-race or one-player server; 11 Fair monetization: the Rescue Flask sells relief from a penalty the game imposes

### Pack a Yak: 6/10
- **Strongest:** The most faithful answer to 'not abstractions': goods are a visible pile, the journey is a ride you sit on, raiders take from the top of the stack, and gear, gifts and passengers all compete for the same slots. It also reads his fifth message closely, since a pack beast is the wandering caravan that follows the player into any server. The ice block on the hot road is his 'trivial with the right kit' rule in one item, and the convoy is protection by numbers with no chat.
- **Weakest:** There is no business that serves anyone. The camp is two respawning nodes, no player makes something another needs, and the race idea lives in the yak rather than the player, so the cozy cluster he listed (inns, baking for effect, taming, races) is all deferred to steps 2-4. Hauling as the whole job has stayed small on Roblox, and walk-over stacking may look shallow to the 16+ launch audience.
- **Weak on criteria:** 4 Return hooks for tomorrow: none in the prototype; 5 Return hooks for week 3: none in the prototype; 12 A real twist on a proven pattern: the twist is real but the base pattern (hauling) is the one research found stays small; 3 Works for 16+: walk-over stacking is a hyper-casual pattern; depth arrives only by trip three; 10 Mobile-first controls and performance: riding and hopping off a client-rendered moving beast is unproven

### Run a Hero Inn: 5/10
- **Strongest:** It takes his RimWorld Hospitality reference literally (taverns and hotels for travellers) and is the only slice with a working return-tomorrow hook inside it. The guest kind x destination x supplies rule is a neat miniature of 'right race plus right consumables makes a hostile place easy', and the Magpie pay, feed or chase choice with a truce arc is well made. Cozy players are served best here.
- **Weakest:** This is the concept closest to a known tycoon with his words on it: Restaurant Tycoon's opening plus an expedition timer board. The expedition, which is the twist, is exactly the kind of abstraction he said he does not picture. The player has no race, no gear and no location, players do not need each other (helping is a tip), and tap-to-serve gives the systems-minded teenager little to chew on. He would recognise the inn, not the frontier.
- **Weak on criteria:** 12 A real twist: reads as a fantasy Restaurant Tycoon for the first 70 seconds; 6 Better with friends: a shared kitchen, but no interdependence; nobody supplies or protects anybody; 5 Return hooks for week 3: admitted thin; 3 Works for 16+: one-thumb serving is shallow for the launch audience; 7 Clip-worthy moments: a rare guest walking in is a weak clip

### Sail a Ferry: 4/10
- **Strongest:** The lane choice is his fourth message as a single decision: a long channel taxed by a guard faction, or a short rich reef where pirates can be paid, befriended with gifts or outrun, and never fought. Losses hit only this trip's cargo, never banked coins. It is his boat-and-pirates example taken at face value.
- **Weakest:** Everything he called the emphasis is missing: no homestead, no production, no economy, no creatures, no player race, players seated as stock avatars so his character art has no place, and other players are scenery. It keeps the vehicle and drops the cozy cluster entirely, so it serves one half of the audience he asked about. The author also states the prototype cannot launch without two further additions.
- **Fatal flaw:** Fails the brief's condition that the slice can stand alone, and omits the homestead, production and cozy half of the vision, so the designer would recognise one example from his messages rather than his game.
- **Weak on criteria:** 4 Return hooks for tomorrow: none in the prototype, by the author's own account; 5 Return hooks for week 3: none in the prototype; 6 Better with friends: absent until the first addition; 12 A real twist on a proven pattern: hauling as the whole job has stayed small; 10 Mobile-first controls and performance: eight player-owned boats and lanes longer than the 500-stud low-end draw distance; 8 Systemic content: one pirate card repeats quickly; needs 8-10 cards before launch

### Ideas worth grafting onto the top pick
- From homestead: give each folk one real trait now, not at growth step 2. Simplest form: the two goods are consumables with a specific effect (eat a loaf for Swift, eat cheese for a bigger carry stack), taught in the first minute by the 'spare bowl pulses, eat it' beat, so 'food is power' and 'my neighbour makes what I need' are true on day one.
- From homestead: add its mirrored weather front as the director's third card (Cold Snap / Heat Wave). One folk is untouched and carries food to frozen neighbours for pay. This puts a race trade-off, a consumable need and rescue-for-a-price into the village without any new enemy, and alternates which folk gets to be the rescuer.
- From homestead: the automatic need bubble over a player's head and the beacon pointing at the nearest stall that stocks it, plus a free one-time folk swap at a mirror instead of pure server assignment.
- From homestead: its prototype measure. Log whether a tester used a good that came from another player within ten minutes; add it to the raid-response test so the village layer is measured two ways.
- From one-verb: aged cheese (worth x2 after 1 hour, x5 after 8, x10 after 24, shown by rind colour). It is a timestamp on a stack, it is the designer's 'cheese fermenting', it gives the dairy a return-tomorrow hook inside the slice, and it gives goblins something worth protecting.
- From one-verb: the per-player director mood rule (after a loss the next beat is relief or nothing; after three clean beats the budget rises by one) and fixed, learnable trouble spots.
- From one-verb: the pack beast as the first rung of settlement's growth step 5. A yak with a visible stack walking surplus down one road to a second market is the cheapest physical supply line, and it is the nomad caravan from his fifth message.
- From journey: turn place on with one choice instead of deferring it. Let the joining player pick between an inner plot under the dragon (pays a share to the bowl automatically) and a gate-side plot (untaxed, caravans arrive there first and pay double, goblins reach it first). Same map, same server, one risk number that the plot record already carries.
- From journey: no attack button anywhere, and losses limited to what is on the counter this raid, stated as a rule the player can see.
- From hospitality: the relief guest who pays triple after every director card, the rule that trouble never fires offline, and feeding raiders by hand as the befriending action (hand-carry three goods to the chief) so friendship is an act, not a counter.
- From hospitality: a served traveller who walks out toward a visible landmark and walks back in later carrying a crate, resolved from a timestamp and a seed fixed at departure. Use it sparingly as the offline hook for the bakery, the counterpart to aged cheese for the dairy.

### What all five missed
1. Choosing where to settle is absent from every slice, yet it was the designer's own answer to the cozy-versus-raid problem and is cheap: two kinds of plot on one map in one server (protected and taxed, or exposed and richer), not regions. It is also what lets the cozy player and the risk-taking teenager share a server by choice rather than by tuning.
2. No concept puts both halves of his fourth message in one slice. Settlement has protection for a price without races; homestead has races and environments without protection. Each author deferred the other half to step 3 or 4.
3. Nothing a player does outlasts their server or is felt by another server. Persistence and servers influencing each other was the first thing he said fascinated him, and one coarse shared number in a data store (a world-wide goblin mood, a dragon age, a weekly front that every server feels) would seed it at almost no cost. All five treat the world as disposable.
4. No player ever pays another player. Every tip and double payment is minted by the system, which is sensible against alt abuse, but it means 'for a price' between players is not actually tested by any prototype. A fixed-price, capped transfer (buying from a neighbour's counter at list price is the nearest thing, in homestead and settlement) should be measured deliberately.
5. Taming and collecting creatures, the element with the deepest proven demand on Roblox and one he named, is in no slice beyond one dairy animal, one shared dragon and one yak. Healing as a service is likewise only hinted at by homestead's thaw.
6. All five open with a hyper-casual first minute aimed at the eventual under-16 audience, while the 250 engaged plays must come from 16+ players, and none plans to read the age and gender split from creator analytics in the first playtest, which is the direct way to answer the designer's question about who this is for.
7. Every design assumes a neighbour for its best moments, but a first session at launch is usually alone. Only settlement (NPC-run plots) designs the solo server on purpose; none scripts a first neighbour moment with an NPC so a lone newcomer sees what the game is about.


---
