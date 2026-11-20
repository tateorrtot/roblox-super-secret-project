# Concept Research, November 2026

Compiled 2026-11-18 for the user's game idea (quoted in `CLAUDE.md`). Five researchers each wrote a brief from live sources, and a second agent independently re-checked each brief's key facts and conclusions.

**Read each brief together with its "Independent check".** The checkers corrected several numbers and struck many of the researchers' conclusions as going beyond the evidence. All player counts are from one Wednesday; weekend numbers run higher.

## Summary of what held up

### Restaurant Tycoon (Ultraw Games)
- Restaurant Tycoon 2 (2019) has 1.66B visits. Restaurant Tycoon 3 went free on 2025-08-20, peaked at 67K, and now averages 6-7K with 21-24 minute sessions.
- The start is the lesson: a new player picks a template and is standing in a working restaurant with a customer to click. Building comes after the first sale.
- Every job is done by hand first, then a hired worker type removes exactly that job.
- Customers spawn only when a valid seat exists, so NPC load follows capacity.
- It sells building freedom and convenience, with many 10-50 Robux products.
- It shipped an update every week of 2026. The checker found no measurable player lift from them.
- About 62M players have tried RT3. Roughly a third of each day's players are new, and only 4.6% ever reach a 3-star restaurant.
- Both series peaks came from outside pushes: a Roblox platform event, and a known sequel going free. A new game on a fresh account can't reproduce either.

### Retail Tycoon 2 (Secret Cactus)
- 341M visits and about 1K average players now. There has been no content update since early 2025, though two unreleased passes created in September 2026 suggest one is coming.
- The player drives the truck with visible cargo. Hired drivers are a delivery rate: their truck is visible parked at the dock, and nothing is simulated on the road.
- Instant delivery costs +25%, so the physical trip is the cheap option and never the only one.
- Transport has its own upgrade ladder: capacity 300 to 6,000, then helicopter and airship.
- It already has a raid loop: robbers steal stock, countered by hired guards, cameras and gates.
- NPCs path on a custom tile grid. A client-side pathfinding option shipped in 2022 and was removed in 2024.
- Decoration caps were added after launch. Physics trucks were undrivable under about 20 fps and needed rework.

### The cozy audience
- The user's list is one cluster: make, tend, decorate, collect and belong, in a fantasy setting, at the player's own pace.
- Off Roblox, the evidence that this cluster over-indexes with women and adults is strong. On Roblox it is directional only, because Roblox publishes no gender data.
- Creator analytics has a gender breakdown, so our own first playtest can measure the split.
- Gather-and-craft chains with light combat hold players at scale: Bee Swarm Simulator (34K average, eight years old) and The Forge (23K).
- Cozy shop, farm and hotel tycoons launched since September 2026 are volatile. One fell about 80% in nine days.
- No cozy or life-sim game was found with playable races, and none where race affects production or needs. Combat RPGs do have race picks.

### Precedents
- A driven train journey works as a co-op run (Dead Rails: 1.5M peak, 19K average now), but that game is a combat survival run rated 13+.
- Hauling cargo as the whole job has stayed small in the games checked.
- No game was found where players ride a rail or ship line another player built.
- One game links many servers into a persistent world: Starscape, with one server per star system, now averaging 14 players. Its low count has other possible causes (its age, and no update since May 2026).
- The builders that lasted a decade save progress to the player and load it into any small server (6-12 players).
- Adopt Me added a cross-server Trading Hub in July 2026. It shares listings, not a world.
- Raising and collecting creatures has the deepest proven demand of any element in the idea.
- No game was found with an NPC raider faction that players pay off or befriend.

### Platform
| Feature | Verdict | What that means |
|---|---|---|
| Connected region servers | Reduced form | One place per region, sharing coarse numbers (stock, control, route status). Empty regions don't run. |
| Base that produces offline and can be visited or raided | Reduced form | Production is computed from timestamps on load. Visits and raids load the owner's save. |
| Rideable cargo vehicles between regions | Reduced form | The ride is real inside one server. Crossing regions is a loading screen, with vehicle and cargo saved and rebuilt. |
| Dozens of NPCs per base | Reduced form | Simulate them as data on the server and render simple rigs on the client near the viewer. |
| Cross-server player economy | Feasible | Data stores hold the ledger. A large market does not fit the free MemoryStore quota at launch scale. |
| All of it on a low-end phone | Not as described | Needs hard per-plot part caps, streaming and tested budgets. |

- Servers shut down when empty. The maximum is 200 players per server, and nothing shows a building game holding that on phones.
- Persistent shared state belongs in data stores (4 MB per key; 500 MB + 1 MB per lifetime user).
- Request and memory quotas scale with concurrent players, so a new game gets only the base amounts.
- **Splitting a small launch audience across region servers leaves each one nearly empty.** This is the main argument against starting with many regions.
- The low-end draw distance has been 500 studs since 2026-11-05, and Studio can now test teleports between places without publishing.
- Standing passengers on fast trains may jitter. The evidence is thin and old, so prototype it.
- Teleport time between places has no current measurement. Measure it.

---

# A. Restaurant Tycoon series

## Restaurant Tycoon series (Ultraw Games): case study

Snapshot taken Wed 18 Nov 2026, 23:37 UTC. "Live" is a single weekday reading; use the averages.

### 1. Who and when
- Creator: Ultraw, founder and lead programmer of Ultraw Games, Isle of Man (https://devforum.roblox.com/raw/3670704/1, https://devforum.roblox.com/raw/3840933/1). RT1 and RT3 sit on his user account, RT2 on the group "Ultraw Games" (games.roblox.com/v1/games?universeIds=331220105,1214576306,7094518649).
- RT1 created 27 Apr 2017. RT2 created 1 Jul 2019. RT3 created 16 Jan 2025; paid alpha 2 May 2025 at 25 R$; beta 24 Jun 2025; free release 20 Aug 2025 (API; https://devforum.roblox.com/raw/3670704/1; https://deltiasgaming.com/?p=232199; rt3.fandom.com Update_History).

### 2. Numbers

| | RT1 | RT2 | RT3 |
|---|---|---|---|
| Live now (API) | 6 | 761 | 4,494 |
| 7-day avg | not found | 1,156 (rotrends) / 1,296 (statroblox) | 6,219 (rotrends) |
| 30-day avg (bloxodes) | 12 | 1.3K | 7.3K |
| All-time peak (Rolimons, archived) | 2,259 on 15 Nov 2020 (tracking starts Apr 2020) | 65,251 on 26 May 2024 | 67,443 on 31 Aug 2025 |
| Visits (API) | 403.9M | 1.655B | 394.3M |
| Like ratio (API votes) | 92.8% | 93.1% | 95.3% |
| Favorites (API) | 2.74M | 4.31M | 942.6K |
| Last update (API) | 9 Oct 2026 | 16 Nov 2026 (bug fix) | 13 Nov 2026 |
| Server size (API) | 5 | 9 | 6 |
| Avg session | 6.0 min (Rolimons) | 21 min (statroblox) | 24.1 min (rotrends) |
| Maturity (Roblox guidelines API) | Minimal | Minimal | Minimal |

Sources: https://rotrends.com/game/7094518649, https://rotrends.com/game/1214576306, https://statroblox.com/games/1214576306, https://bloxodes.com/stats/games/restaurant-tycoon-3-7094518649 (and the RT2/RT1 pages), web.archive.org captures of rolimons.com/game/119048529960596 (29 Aug 2026), /3398014311 (11 Feb 2026), /755776245 (6 Nov 2026).

#### What the sequel did to the older game
Monthly averages below are my own computation from the 6-hourly player history embedded in those archived Rolimons pages.

| Month | RT2 avg | RT3 avg |
|---|---|---|
| 2024 (full year) | 9,519 | - |
| Jul 2025 (RT3 paid beta) | 10,031 | 4,723 |
| Aug 2025 (RT3 free on the 20th) | 8,045 | 12,331 |
| Sep 2025 | 3,310 | 25,894 |
| Jan 2026 | 3,522 | 15,116 |
| Aug 2026 | 2.9K (bloxodes) | 12,389 |
| Last 30 days (bloxodes) | 1.3K | 7.3K |

- The paid alpha did not hurt RT2. The free launch did: RT2's daily average fell from 7,755 (19 Aug) to 3,815 (3 Sep 2025), about 60% within a month, and never recovered.
- RT3 went from about 3K to a 49.6K daily average in 11 days after going free, then decayed to about 7K over 14 months despite weekly updates.
- Today both games together (about 8.6K) are below what RT2 alone averaged in 2024. RT1 fell from 699 average (2020) to 25 (2026).
- RT2's all-time peak came on the weekend of its "Classic event" (listed 23 May 2024 in https://devforum.roblox.com/raw/356970/1), not from a content update.

### 3. Core loop and the first 60 seconds
First minute (rt3.fandom.com pages Restaurant_Tycoon_3, Restaurant, Mechanics; https://deltiasgaming.com/?p=232199):
1. Pick a free plot on the map.
2. Pick one of 16 pre-built starter restaurants, a cuisine (50+), type a name.
3. You are standing in a working restaurant: two 2-seat tables, 2 ovens, 2-3 counters, an order stand, 250 cash.
4. Click a customer group to seat it (tutorial arrows point at free tables), click the order bubble.
5. Interact with the order counter, follow a green arrow from appliance to appliance doing short gestures (chop, mix, fry, knead; swipe on mobile).
6. Carry the dish, follow green arrows to the customer, click.
7. Click plates to clear, click the money on the table.

Then: spend cash on tables, kitchen gear, upgrades (30 in prerequisite branches), staff, expansions and decoration, which raise a 5-star rating that raises customer spawn rate.

### 4. Acted out versus automated

| Step | Player does it physically | Automated or abstracted |
|---|---|---|
| Seating, orders, serving, clearing | Yes, by walking and clicking | Servers (up to 8) with per-task roles; trays carry 3-4 dishes |
| Cooking | Gesture minigames at real appliances | Chefs (up to 8) use the same stations; fires and burnt food exist |
| Payment | Click cash on table | Card Payments upgrade (50%), Auto Money pass (299 R$) |
| Drinks, drive-thru, delivery | Yes | Baristas and operators (2 each); max 20 workers |
| Ingredients | Walk to farm, bakery, butcher, supermarket, fishmonger; plant crops on 8 tiles with 15 min to 3 h timers | Ingredients only boost dish prices; no restocking requirement; "Fully Restock Stores" 40 R$ |
| Customers | - | Spawn only when an eligible table exists; group size matches largest free table; rare types by odds (Rude 1/200, VIP 1/256, Critic 1/512, Celebrity 1/800, "Rig" 1/20,000) |
| Offline | - | Restaurant earns while logged out (game description; "Earn Offline Update" 28 Aug 2026) |

(rt3.fandom.com Workers, Customers, Farming, Upgrades; https://devforum.roblox.com/raw/3636102/1.) RT2 paid skill points only for work the player did personally (https://news.xbox.com/en-us/2020/08/13/feed-your-creativity-in-restaurant-tycoon-2-on-roblox/); RT3 milestone buffs do not apply to workers.

### 5. Building, progression, multiplayer
- Build mode: 745 items, free wall, door, window and diagonal placement, three floors, roofs, wallpaper, three colour/material slots, hex colours, primitive blocks, plot digging with water, grid 1 or 2 free, undo/redo, templates, 15 save files, plots up to 128x128 (https://devforum.roblox.com/raw/3636102/1; https://bloxodes.com/wiki/restaurant-tycoon-3).
- Progression: 238 foods and 24 drinks unlocked through 24 rotating objectives; 9 milestone skills with trophies and titles, shared across saves; 36 rating factors; 5-day login streak; badges up to "Day 100" (3.7% of players) (bloxodes).
- Multiplayer: 6 plots per server. Owners can hire other players as staff or co-owners with permissions; visitors order food, send likes and gifts; a daily friendship meter fills by helping in someone else's restaurant; Friend Boost (8 Nov 2025); one-hour daily Rush Hour for everyone; leaderboards (rt3.fandom.com Daily_Friendship_Meter, Rating; changelog). Co-play was the most requested feature because running a restaurant alone "can often feel isolating" (Creator Spotlight).

### 6. Monetization (prices from Roblox APIs)
- RT3 passes: 2x Milestone Boost 249, Auto Money 299, 2x Item Limits 299, Allow Build Collisions 349, Chip Shop Diva bundle 349, 3x Customer Luck 399, Glass Animals bundle 399, Faster Cooking 449, Precision Build 599, Sandbox Mode 1,499.
- RT3 products (23): Unlock 1 Food 10, Skip Objective 15, Start Rush Hour 25, Instant Grow 35, Restock Stores 40, 15% boost for 10 minutes 50, Starter Pack 149, cash 99 to 1,499, diamonds 199 and 899, plus gift versions of every pass.
- RT2: 11 passes (50 to 1,299) and 41 products, including plot expansions sold for Robux up to MEGA Plot 3,200.
- Regional pricing and thumbnail personalization are in use (Creator Spotlight). Rotrends ranks RT3 #240 by earnings. Rowatcher estimates $125,100 a month, but that page's other figures were internally inconsistent.

### 7. Cadence, devices, audience, criticism
- Cadence: one update every Friday through 2026 (46 dated entries, 2 Jan to 13 Nov), built as one big update then 2-3 small ones, with seasonal events, a boss battle and brand tie-ins (Glass Animals, Chip Shop Diva). Bloxodes measured about +50% average players in the 48 hours after the 13 Nov update.
- Devices: changelogs fix mobile and Xbox bugs; a DevForum report cites Windows and Android; RT2 launched on Xbox One in 2020. Official device list: not found.
- Audience: no age, gender or region data found. Indirect signals only: 30+ volunteer translators, constant requests for national dishes, commenters calling it a childhood game.
- Criticism (DevForum Spotlight replies 7-11): RT3 "looks exactly like" RT2 but paid; staff upgrades let you "do absolutely nothing"; decorating fights profit. The wiki notes players dump rating-required items in one corner to satisfy the checklist. In 2019 Ultraw himself said RT1 had "below average retention" (https://devforum.roblox.com/raw/227124/8).

### 8. NPC simulation at scale
- RT1 NPCs used no Humanoids: custom MoveTo on BodyVelocity, which Ultraw said "reduces lag by a lot" but suits only flat maps (https://devforum.roblox.com/raw/118322/2, /raw/96250/3).
- RT3 bounds the problem instead of solving it generally: 6 players per server, full rating at 100 seats, 20 workers per plot, hard item limits, a "smart render system" for distant restaurants, performance settings, and a dedicated performance-test place.
- Customers are demand tokens, not simulated people: no needs, travel or memory, only an emoji mood, a "thoughts" list and a rarity roll.
- Pathfinding across doors, pillars, stairs and floors is a recurring bug source in the changelogs.

## Researcher's lessons (several are struck or narrowed by the check below)
- Copy the start: hand the new player a finished, working business, not an empty plot. RT3's three setup choices (template, cuisine, name) lead straight to a customer to click, with arrows pointing at the next object. For this idea that means a new player's first minute is serving a traveller in a pre-built tavern, not building, taming or travelling.
- Copy 'do it by hand first, then hire it away': every job (seat, cook, serve, clear, collect) is a physical action the player learns, and each staff type later removes exactly one of them. Keep a reason to stay hands-on, as RT2 did by paying skill points only for the player's own work and RT3 does by not applying milestone buffs to workers; the top complaint is that staff let you 'do absolutely nothing'.
- Copy demand-pulled NPC customers: a visitor exists only when there is a free, valid seat, and group size fits the table. That keeps NPC count proportional to capacity. Budget from RT3's own ceiling: 6 plots per server, about 100 seats and 20 workers per plot.
- Copy rare special visitors as the collection layer on top of ordinary customers (critic, celebrity, rude, a 1-in-20,000 mythical) with an encounter log. It gives clip moments and a paid luck pass without any power creep. In this idea these could be named travellers, race-specific guests or pirate envoys.
- Copy the monetization shape: sell building freedom (precision placement, collisions, item limits, sandbox) and convenience, with many 10-50 Robux impulse products (skip, instant grow, restock, start a rush hour) and giftable passes. That fits the spend-days signal and keeps a cozy builder audience paying without pay-to-win.
- Copy the co-play scaffolding that needs no chat: hire friends as staff or co-owners with permissions, a daily friendship meter filled by working in someone else's business, a friend boost, likes and gifts, eating at other players' restaurants, and a server-wide daily rush hour.
- Copy the cadence if it can be afforded: a fixed weekly day, one big beat then 2-3 small ones, each with a thumbnail-worthy feature. Measured effect was roughly +50% players for 48 hours, but it only slowed decay (25.9K to about 7K in 14 months), so cadence is maintenance, not growth.
- Avoid shipping a sequel or a second place as the 'new version': RT2 lost about 60% of its players within a month of RT3 going free and the two games together now sit below RT2's 2024 level. Evolve one experience in place.
- Avoid a checklist rating that clutter can satisfy: RT3 players pile the required items in a corner. If hospitality quality matters in this idea, score it from what guests actually experience (wait time, route, distance to amenities) rather than item counts.
- Avoid treating this series as proof that deep NPC simulation scales on Roblox. It shows the opposite approach works: customers have no needs, journeys or memory, the map is flat, and each server holds six isolated plots. NPC travellers who really ride trains or ships between regions are untested territory; RT1 dropped Humanoids and RT3 still fights pathfinding bugs on stairs and doors.
- Supply chains here are optional flavour: ingredients come from walk-up shops and 15-minute to 3-hour crop timers and only raise dish prices. That is a safe first rung for this idea's farming and brewing (boosts, not requirements) before making goods physically necessary.
- A paid-access alpha (25 Robux) worked as a soft launch: it gathered feedback, reached about a third of RT2's CCU, and did not cannibalise the old game. It also drew 'same game but paid' criticism, so it only suits a creator with an existing audience, which a fresh account lacks.
- Sessions of 21-24 minutes with offline earnings, crop timers and a 5-day login streak fit the Home ranking's 60-minutes-per-day cap and play-days signals; the series is a daily-visit game, not a marathon.

## Not found
- Any age, gender or region breakdown of players for any entry (only indirect signals: 30+ volunteer translators, requests for national dishes, nostalgic comments)
- Official supported-device list for each game (mobile, Xbox and PC are evidenced only through changelog bug fixes, a DevForum bug report and a 2020 Xbox Wire article)
- RT1 player history before April 2020, RT1's true all-time peak, and what happened to RT1's players when RT2 launched in July 2019
- Retention figures (D1/D7/D30) for any entry; the only statement is Ultraw's 2019 remark that RT1 had below-average retention
- Reliable revenue; only a third-party estimate ($125,100 a month, Rowatcher) from a page with internally inconsistent numbers, and a Rotrends earning rank of #240
- Private server price and availability for RT3 (RT2's description advertises free VIP servers)
- Details of how RT3's Friend Boost, delivery and offline-earning formulas work after the franchise ladder was removed on 28 Aug 2026
- Independent reviews or Reddit threads on RT3; criticism found was limited to DevForum replies on the Creator Spotlight
- A Restaurant Tycoon 2 public (non-beta) release date distinct from its 1 Jul 2019 creation date
- endgametools.com page for these games (404)

## Independent check

11 of 14 key facts confirmed.

### Facts corrected
- **partly wrong:** 5. Sequel cannibalisation: RT2 9,519 in 2024, 8,045 in Aug 2025, 3,310 in Sep 2025 (7,755 on 19 Aug to 3,815 on 3 Sep); paid alpha did not dent RT2
  - Correction: Every number reproduces, but the attribution is overstated because the window straddles US back-to-school. In the 11 days after RT3 went free (while RT3 climbed from 3K to 49.6K) RT2 only slipped from 7,755 to 6,912. The big step came 1-3 Sep 2025 (Labor Day week), when RT3 itself fell 33% (47,020 to 31,694). In 2024, with no sequel, RT2 fell 23% from Aug to Sep (9,913 to 7,675). Year on year RT2 was already down 19% in Aug 2025 and went to down 57% in Sep and Oct 2025. So the sequel's share of the loss is roughly 45% of RT2's seasonally expected players, not 60%. Also, the two sources disagree for later months: Rolimons-derived Jan 2026 is 3,522 but bloxodes shows 2.6K for the same month, so the brief's table mixes series that differ by up to about 25%.
- **partly wrong:** 6. RT3 decayed from 25,894 (Sep 2025) to 12-15K through 2026 and 7.3K in the last 30 days despite weekly updates; RT3 plus RT2 (about 8.6K) now below RT2's 2024 solo average
  - Correction: The decay numbers hold (my monthly means: Sep 2025 25,894; Jan-Jul 2026 between 12.6K and 17.2K; bloxodes shows 10.3K-13.5K for Jan-May 2026, 17.5K Jun, 15K Jul, 12.4K Aug, 9.4K Sep, 8.6K Oct, 7.3K last 30 days). The combined-versus-2024 comparison is misleading: it sets a mid-Oct to mid-Nov window against a full-year average that includes summer and the May 2024 event spike. Like for like, RT2 averaged 6,378 over 19 Oct-18 Nov 2024, so the pair's 8.6K is about 35% ABOVE that. By month: Jul 2026 pair 18.7K vs RT2 Jul 2024 11,988; Aug 2026 15.3K vs 9,913; Sep 2026 11.0K vs 7,675; Oct 2026 10.0K vs 7,436. The franchise is larger than before the sequel in every like-for-like month I checked.
- **partly wrong:** 11. An update every Friday in 2026 (46 dated entries, 2 Jan-13 Nov), events, boss battle, brand tie-ins; bloxodes measured about +48-50% players in the 48h after the 13 Nov update
  - Correction: The count is right: 46 entries, 44 on Fridays and 2 on Saturdays (18 Apr, 26 Sep), one per week. The +48-50% is displayed by bloxodes but it is a weekday-to-weekend artifact, not an update effect: it compares Thursday with Saturday-Sunday. The same bloxodes table gives RT2 +71% for a 13 Nov bug-fix update, and RT3 -26% and -3% for its 9-10 Nov updates (weekend to weekday). Statroblox daily averages show the post-update Sunday (15 Nov, 8,046) was lower than the Sunday before (8 Nov, 8,792), and the 7-day average is down 5.9% on the prior week. No lift from the Thanksgiving update is visible.

### Conclusions that go beyond the evidence
- Lesson 7 (cadence gives roughly +50% players for 48 hours): not supported. The bloxodes figure compares a Thursday with the following weekend. RT2 shows +71% for a bug-fix update the same day, RT3's own 9-10 Nov updates show -26% and -3%, and the Sunday after the 13 Nov update (8,046) was below the Sunday before it (8,792). The evidence shows no measurable lift from a weekly update; 'it only slowed decay' also has no counterfactual.
- Lesson 8 (avoid a sequel; the two games together now sit below RT2's 2024 level): the comparison sets an Oct-Nov window against a full-year average. Like for like the pair is above RT2 alone: 8.6K vs 6,378 for the same 30 days of 2024, and 10.0K vs 7,436 (Oct), 15.3K vs 9,913 (Aug), 18.7K vs 11,988 (Jul). The sequel also produced a 67K peak and ranks #240 in Top Earning while RT2 is unranked. What the data supports is narrower: a free sequel pulls most players out of the old game (roughly 45% beyond the seasonal drop, not 60%), and the launch spike does not last.
- Lesson 2 ('the top complaint is that staff let you do absolutely nothing'): this is one rhetorical question from one DevForum commenter (reply 7 on the Spotlight thread). There is no evidence it is a top or common complaint.
- Lesson 10 and brief section 8 ('customers have no needs, journeys or memory, the map is flat'): partly unsupported. Customers have used bathrooms since 23 Jan 2026 per Ultraw's changelog, and RT3 has plot digging, three floors, stairs and elevators with a custom tile-map pathfinder. The flat-map remark is a 2018 comment about RT1. The core point stands (the series does not show deep NPC simulation or cross-region travel scaling), but RT3 is evidence that grid pathfinding on player-built multi-floor plots is workable, at the cost of many bug fixes.
- Lesson 3 ('RT3's own ceiling: about 100 seats per plot'): 100 seats is the threshold for full rating, not a cap. The real limits are per-category item limits, which a 299 R$ pass doubles. No source gives the actual NPC count a server carries, so this is not a performance budget.
- Lesson 13 ('the series is a daily-visit game' that fits the play-days signals): no retention or play-days data was found. Roblox's badge API points the other way: the '100x Daily Reward Streak' badge has 1,874 awards in total, 'Day 100' counts in-game restaurant days (its text says 'a century of days in one Restaurant') and its 3.7% is a daily win rate, not a share of all players; 394.3M visits over 62.1M welcome-badge holders is about 6 visits per player ever. Ultraw himself said RT1 had below-average retention. Session length fits the 60-minute cap, but return frequency is unproven.
- Lesson 12 ('reached about a third of RT2's CCU'): over the whole paid period (3 May-19 Aug 2025) RT3 averaged 4,355 against RT2's 8,893, about half; it was a third only in May (36%), then 68% in June and 47% in July.
- Lesson 5 ('fits the spend-days signal... without pay-to-win'): the price list is confirmed, but there is no data on what sells or how often players buy, so the spend-days fit is a guess. Four of ten passes and several products sell progress or income (Faster Cooking, 2x Milestone Boost, Auto Money, 3x Customer Luck, cash packs up to 1,499 R$), so 'without pay-to-win' is generous.
- Lesson 4 ('a paid luck pass without any power creep'): special customers pay out (VIP large tip, Celebrity raises spawn rate, the mythical gives 10 diamonds), so the luck pass buys income. A paid odds multiplier also sits near Roblox's paid-random-item disclosure rule noted in the project research doc; that should be checked before copying it.
- Lesson 6 (copy the co-play scaffolding): the features exist as described, but the only usage data I found is modest. Yesterday 4.2% of players earned 'Friendship Forever' (filled the meter in someone else's restaurant) and 5.2% liked a restaurant. That shows the features are used by a small minority, not that they drive co-play.
- Lesson 1 (copy the start): reasonable, but the evidence is only that the design exists. No bounce or funnel numbers were found, and the first-minute sequence was reconstructed from wiki text, not observed.

### What the brief missed
1. Roblox's badges API (https://badges.roblox.com/v1/universes/7094518649/badges) is a primary source the brief did not use. The welcome badge (created 19 Aug 2025) has 62.1M awards, so about 62M unique players since the free launch; 22,350 were awarded in the past day at a 31.2% win rate, meaning roughly a third of each day's players are first-timers. Lifetime: 3-star restaurant 2.88M (4.6% of players), 5-star 179K (0.3%), 30 Hours Playtime 815K (1.3%), 100-day login streak 1,874. Most players leave early; a small core goes deep.
2. Seasonality runs through all the CCU comparisons. US back-to-school alone cut RT2 by 23% from Aug to Sep 2024, and RT3 dropped 33% in two days over Labor Day 2025. Any before/after claim in the brief should be compared with the same weeks a year earlier.
3. The update-effect table on bloxodes cannot be used as evidence because Friday updates are always followed by a weekend.
4. RT3's NPC approach is more specific than the brief says: a custom tile-map pathfinder over player-built plots with stairs and elevators (May 2025 changelog), customers that are refused entry to floors with no stairs, and repeated fixes for workers teleporting or freezing. That is the closest available precedent for NPCs walking through player-built taverns or stations.
5. RT2's all-time peak was driven by a Roblox-run platform event (The Classic, 23-28 May 2024), and RT2 was also in The Hunt (Mar 2024) per rotrends. Both peaks in this series came from outside pushes (a platform event and a free-launch of a known sequel), which a new game on a fresh account cannot reproduce.
6. Source quality: the Rolimons-derived and bloxodes monthly averages disagree by 8-25% for Nov 2025-May 2026 and the brief's table mixes them; statroblox history before 4 Oct 2026 is copied from Rotrends; the fandom wiki's worker and customer pages are alpha-era or stubs.
Working files are in (session scratchpad) (roli.py and roli2.py hold the recomputation). Nothing was written to the project folder.


---

# B. Retail Tycoon series

## Retail Tycoon series: case study (data read 2026-11-18, ~23:40 UTC)

Source tags: **[API]** games.roblox.com/v1/games?universeIds=111535124,2092410051 and /v1/games/votes · **[CL]** devforum.roblox.com/raw/858524/1 (official changelog) · **[TR]** trello.com/b/hO1Tsvgz.json (dev Trello) · **[BX]** bloxodes.com/stats/games/retail-tycoon-2-2092410051 and /retail-tycoon-111535124 · **[RT]** rotrends.com/game/2092410051 and /111535124 · **[RW]** rowatcher.com/games/2092410051/retail-tycoon-2/dying · **[WK]** retail-tycoon.fandom.com/wiki/(page) · **[RWK]** roblox.fandom.com/wiki/Player:Haggie125/Retail_Tycoon · **[GR]** gamingroute.com guide (updated 2026-10-29) · **[BD]** badges.roblox.com/v1/universes/2092410051/badges

### 1. Identity and numbers

| | Retail Tycoon (RT1) | Retail Tycoon 2 (RT2) |
|---|---|---|
| Creator | Haggie125 (user) [API] | Secondhand Studios (group owned by Haggie125, 531,923 members; groups.roblox.com/v1/groups/2748390). Devs listed: Haggie125, MicroK, Alanze [WK Retail_Tycoon_2] |
| Created | 2015-08-14 [API]; paid beta cost 25 R$ [RWK] | Universe 2020-10-23 [API]; paid beta 2020-11-06; free 2021-07-16 [CL] |
| Live players | 12 [API] | 622 [API] |
| 7-day avg | 15.2 [RT] | 830.5 [RT] |
| 30-day avg | 16.7 [BX] | ~1K, down 33-34% [BX][RW] |
| Monthly avgs 2026 | Jun 27.4, Oct 19.4 [BX] | Jan 1.8K, Apr 2.0K, Jun 2.4K, Aug 2.2K, Sep 1.8K, Oct 1.3K [BX] |
| Peak | all-time not found (tracker window max 300 [RT]) | all-time not found; 9.8K undated [RT]; 5K on 2026-04-19 [RW] (both tracker-window only) |
| Visits | 218,374,869 [API] | 341,107,729 [API] |
| Likes | 603,751 up / 161,309 down = 78.9% [API] | 516,802 / 67,863 = 88.4% [API] |
| Favorites | 1,881,337 [API] | 1,415,500 [API] |
| Last update | 2025-10-18 [API] | 2026-04-08 (v1.8.2.8, save fix) [API][CL]; last content 1.8.2 on 2025-02-13 [CL] |
| Server size / maturity | 6 / Minimal [API][age API] | 6 / Minimal [API][age API] |
| Avg session | 39.8 min [RT] | 35.4 min [RT] |

**What happened to RT1:** the sequel was a separate universe, not an in-place update. RT1 stays up with "Retail Tycoon 2 is out!" at the top of its description [API] and has decayed to ~15 CCU. RT2 has since passed it on visits.

**Cadence:** dated releases in the changelog: 13 (2020), 82 (2021), 54 (2022), 1 (2023), 7 (2024), 9 (2025), 3 (2026) [CL, my count]. Roughly weekly for two years, then near-silence. It still averaged 1.4K-2.4K CCU through 2026 with no content since Feb 2025 [BX]. The studio's newer game, Cash Cow [Beta] (created 2026-05-08), has 15,516 visits and 0 playing (games.roblox.com/v1/games?universeIds=10139093702).

### 2. Core loop and first minute

Exact tutorial script, beat by beat: **not found** (no page documents it). What sources do establish:
1. Main menu, pick a save slot, pick a plot from a plot-picking GUI [CL 0.1.4b, 0.4.6b].
2. An optional tutorial (added 2021-03-05) [CL]; 10,882,277 "Do the tutorial" badges vs 11,212,427 "Sell 100 things" [BD].
3. Claim plot, build floor/walls/roof, place a checkout and shelves, buy first stock (deltiasgaming.com/roblox-retail-tycoon-2-a-beginners-guide/). There is a default store with one parking spot [CL 0.1.3b]; storage starts at 100 units [WK Storage]; a pickup truck is free for starters [WK Vehicles].
4. Customers arrive by car, shop, queue, pay. Reinvest in shelves, parking, signs, staff, land, floors.

So the first minute is menus plus building, not a sale. One guide calls the start "a bit complicated for new players" (deltiasgaming).

### 3. Stock and supply: physical vs automated

| Step | Manual version | Automation |
|---|---|---|
| Order | Store Inventory menu or the Warehouse NPC [WK Loading_Dock] | Manager ($400 hire, $40/min) buys to a 50-200% stock target [WK Managers][CL 1.3.3] |
| Transport | Goods pile up at a shared Loading Dock; player drives a truck there, loads, drives back, unloads at own unloading dock [CL 1.2][WK] | Instant delivery at +25% cost [WK]; or Delivery Driver ($300, $30/min), one truck each [WK] |
| Store | Storage racks (+capacity, $500) [WK Storage] | none needed |
| Shelve | Click shelves; drag-to-stock on PC only [CL 1.8] | Restocker ($200, $20/min) [WK] |
| Sell | Player can man a register | Cashier, or self-checkout (1.8 s/item, ~50% of customers refuse it) [WK Tips] |

Truck ladder: Pickup 300 capacity, Van 600, Large Box 2,500, Semi 6,000 ($60,000); overloaded trucks drive much slower [WK Vehicles][CL 0.6.6b]. Cargo is visible with load/unload animations [CL 0.2.1b]. No manufacturing exists.

Key detail: **hired delivery drivers are not simulated on the road.** They "cannot be seen at the loading dock nor can they be seen driving on the road" [WK Delivery_Drivers]; "Truck drivers actually drive around and are visible" is still an open Trello card [TR]. Only the player's own haul is physical.

### 4. NPCs and performance

- Customers come in groups of 1-6 per car, with budgets and shopping lists drawn from what the store stocks [WK Customers][CL 0.4b]. Spawn rate scales with ratings, parking spots and the largest sign [CL 0.4b, 0.4.2b]. Six ratings: decoration, crowdedness, shelter, cleanliness, queue size, walkability [GR].
- Count at once: exact cap **not found**. Haggie125 in 2018: "watch a hundred little artificial people run around" [RWK interview]. Parking is the throttle (each spot $1,000 more than the last; wiki editors say more than ~40 rarely fill [GR]).
- Performance history from the changelog [CL]: register transactions "using a ton of server cpu" (0.6.7.1b); shelf-item and furniture render-distance settings, only the current plot's furniture loaded by default (1.0.1, 1.3.6); walls rebuilt with fewer parts (1.3.5); pathfinding +20-25% (1.5.4); guards "cheat" under high server load (1.4.0.2); hard caps (200 hanging plants, signs, string lights); client-side pathfinding added 2022-06, removed 2024-05 "cuz it mostly caused problems"; memory-leak fixes in Dec 2024-Jan 2025; NPC distance LOD [TR]. Haggie125 wrote in 2019 that tile-based A* ran "much smoother" than Roblox pathfinding (devforum.roblox.com/raw/231741/7).
- Trucks broke below ~20 fps and needed a rewritten raycast suspension (devforum.roblox.com/raw/1222425/1).

### 5. Building, progression, multiplayer, money

- **Building:** 5x5-stud tile grid, plots 300x360 studs [TR]; walls, floors, up to 3 floors, stairs/elevators, colour palettes, overlays for decoration/crowding/trash; undo; top-down camera [CL].
- **Long-term goals:** worker levels 1-5; money trees (+2% profit each, next threshold 2.5x the last) [WK Money_Tree]; net-worth leaderboard; trams, airships, helicopters, sports cars [CL].
- **Funnel [BD]:** sell 100 = 11.21M; 1,000 = 4.99M; 10,000 = 1.99M; 100,000 = 266K; 1,000,000 = 3,085; Millionaire = 466K.
- **Multiplayer:** 6 plots on one island with shared loading dock, car dealer, go-kart track. Co-op (whitelisted friends get full owner rights) arrived only in Feb 2022 [CL 1.5]. No shared economy; "Global economy so prices/demand can fluctuate" stayed an idea card [TR].
- **Monetization:** six passes: Military 499, More Land 399, Electric Semi 299, Palettes 299, Custom Floors 149, Radio 149 R$ (apis.roblox.com/game-passes/v1/universes/2092410051/game-passes); cash packs from 5 R$; one brand deal (Philips Norelco, 2022) [CL 1.7.1]. Top Earning best #493 [RT].
- **Devices:** PC; mobile from 2021-04-13; Xbox from 2021-08-13 [CL]. Mobile lacks drag-stocking [CL 1.8].
- **Who plays:** not found.

### 6. Why it lasted, where it hurts

- Depth without content treadmill: 50+ product categories reuse one shelf/customer system [WK].
- Automation as the progression spine. A DevForum reviewer of a rival store game: tycoons lure with hands-on early play, then become "a building sim where you just afk" (devforum.roblox.com/raw/4319794/2).
- Pain points: recurring NPC stuck/pathing bugs across four years [CL]; managers can bankrupt low-margin stores [WK Managers]; RoWatcher verdict "declining", -33% in 30 days vs platform +3% [RW].

### 7. Lessons for the idea

See the lessons list. The headline: RT2 made the player's own trip physical and everyone else's an off-screen timer, and its developer never shipped visible NPC hauling in six years.

## Researcher's lessons (several are struck or narrowed by the check below)
- Make the player's own journey physical and let everyone else's be an off-screen timer. RT2's player drives the truck with visible cargo; hired drivers just teleport goods on a schedule and were never rendered on the road in six years (open Trello card). For trains and ships, simulate the vehicle the player is riding or watching and resolve the rest as arrival events with a visible vehicle only at the endpoints.
- Price the skip instead of forcing the chore. Instant delivery at +25% is the whole anti-tedium design: the physical trip is the cheap option, never the only one. Give every haul in the idea a paid-in-game-currency shortcut and an NPC-crew automation tier, so hauling is a choice players make when they want the ride.
- Automate in the order players get bored: RT2 sells cashier, restocker, manager, then driver, each removing one manual step and each with levels 1-5. A DevForum reviewer of a rival store game says the genre contract is hands-on early, then 'a building sim where you just afk'. Plan the idea's crafts (baking, brewing, hauling) so each has a hireable NPC who takes it over.
- Give transport its own upgrade ladder. Capacity 300 to 6,000 across eight trucks, then helicopter and airship, made hauling a progression track rather than a tax. A cart-to-wagon-to-train-to-ship ladder with visible cargo does the same job and yields clip-worthy moments.
- Throttle NPC count with an in-fiction resource. RT2 uses parking spots at +$1,000 each and groups of 1-6 per car, so the player pays to raise their own NPC load and the server never sees an unbounded crowd. Use beds, stable stalls or dock berths as the cap for tavern and hotel guests.
- Budget for roughly a hundred pathing NPCs per server and no more unless you build the tech first. Even at 6 players per server RT2 needed distance LOD, per-plot furniture streaming, part-count rewrites, hard decoration caps and 'cheating' guards. Start with a tile grid and custom A*, no humanoid collisions, client-rendered NPC visuals and server-side state only.
- Do not plan on offloading pathfinding to clients as the fix. RT2 shipped that toggle in June 2022 and removed it in May 2024 because it 'mostly caused problems'. Design the server budget to hold without it.
- Cap placed objects from day one and say why in the UI. RT2 had to retrofit limits (200 hanging plants, sign and string-light limits) after players broke servers, and still fixed wall-saving bugs in April 2026. For a persistent world with interior design, set per-plot part budgets and a compact save format before launch.
- RT2's first minute is menus, plot choice and building before any sale, and a guide calls the start 'a bit complicated'. With a 60-second bounce signal now in the ranking, the idea should hand the player a working starter stall with a customer already walking up, and teach building after the first coin.
- A shared hub creates ambient multiplayer cheaply, but it is not co-play. RT2's shared loading dock and car dealer put players on the same roads, yet real co-op came 15 months late and there is still no shared economy. If connected regions and trade are the idea's twist, the first cross-player trade route has to be in the launch build, since the ranking rewards intentional co-play.
- Systemic content works: 50+ product categories reuse one shelf, customer and shopping-list system, and the game held 1.4K-2.4K average CCU for over a year after content stopped. But the curve fell from 2.4K (Jun 2026) to about 1K (last 30 days) with no updates, so recipes, crops and creatures should be data rows on shared systems that can ship weekly.
- Keep a long tail goal that is cheap to make. Money trees (+2% profit, each threshold 2.5x the last, per product) gave RT2 an endless per-item collection from one rule; only 3,085 accounts hold the million-sales badge. A per-recipe or per-route mastery track would do the same for the idea.
- Physics vehicles are a mobile risk. RT2's trucks were undrivable under about 20 fps and needed a rewritten suspension, plus another low-end pass in 2025. Rail-guided trains and path-following ships avoid most of this; free-driving vehicles should use a kinematic or simplified chassis.
- A sequel as a new universe abandons the old audience's momentum: RT1 fell to about 15 CCU with only a link in its description. For a persistent-world game, plan to evolve one place in versions rather than relaunch.

## Not found
- All-time peak concurrent players for either game. Trackers only cover their own windows: rotrends shows 9.8K (undated) for RT2 and 300 for RT1; RoWatcher shows 5K on 2026-04-19 for RT2. Haggie125 said RT1 had 'thousands of players online during the beta' (2018 interview) but gave no figure.
- The literal first 60 seconds of RT2 (tutorial script beat by beat). Sources only establish: main menu, save slot, plot picker, optional tutorial, default store with one parking spot, free pickup truck, 100 starting storage. Starting cash for RT2 not found (RT1 started with $5,000).
- Exact number of NPCs running at once per store or per server, and any hard customer cap.
- Whether RT2 itself uses custom tile A* rather than PathfindingService. Haggie125's 2019 post describes that approach for 'a tile-based game I'm working on' without naming it.
- RT2's paid-beta price in Robux (RT1's was 25 R$).
- Any demographic data on who plays (age, gender, device split). Rotrends showed a 'platform share' field of 0.00% with no breakdown.
- Player reviews and complaints from Reddit (domain blocked to the search tool) or from Roblox itself; the complaints listed come from the changelog's recurring bug fixes, the community wiki and one DevForum post about a rival store game.
- Any interview or postmortem specifically about RT2. The only interview found is the Sept 2018 one about RT1.
- Revenue or earnings figures. Only a rotrends Top Earning chart rank (#493 best) was found.
- Private server status is contradictory: the community wiki says private servers are free, while the Roblox games API returns createVipServersAllowed=false for RT2.
- May 2026 monthly average for RT2 (missing row in the bloxodes table).
- PlayStation support: one tracker FAQ mentions it generically; the changelog only confirms PC, mobile and Xbox.
- One RoWatcher news article credits RT2 to 'Widgeon', dates it 2021 and claims 5,000-15,000 CCU through 2025-2026; all three conflict with the Roblox API and the monthly averages, so it was not used.
- The community wiki's Build Mode page hit a bot check and was not read; building-tool details come from the changelog and Trello instead. A dedicated RT2 wiki at retail-tycoon-2.fandom.com does not exist; the wiki used is retail-tycoon.fandom.com.

## Independent check

11 of 14 key facts confirmed.

### Facts corrected
- **partly wrong:** 6. Hired delivery drivers are not simulated on the road (wiki quote; Trello card 'Truck drivers actually drive around and are visible' from 2021-09-13 still open); only the player's hauling is physical, with visible cargo, load/unload animations and slower overloaded trucks
  - Correction: The wiki quote is verbatim and the Trello card exists, open, created 2021-09-13. But the Trello evidence is worthless for 'still': the board's last activity of any kind is 2022-03-18, and the sibling card 'Option for clientside pathfinding' (same day, same list) is also still open even though that feature shipped in 1.6.4 on 2022-06-23. What actually supports the claim through 2026 is the wiki trivia (2024 edit) plus changelog silence. Also 'only the player's hauling is physical' is too strong: a hired driver's truck is a visible object at the store end. Changelog 1.2 requires 'an unloading dock with enough space to park their truck', 1.3.5.1 'Fixed delivery drivers parking badly', 1.5.11 'Made delivery driver vehicle animations clientside (smoother)' and 'Hid rooftop NPC-controlled vehicles when using the build camera'; the wiki says the vehicle 'will remain parked at its respective docking area' and that the driver is not visible in it 'when they arrive at the store'. The hired haul is a throughput rate: the Vehicles table has an 'Items/Per Minute (With Delivery Driver)' column (150 pickup to 4,500 electric semi) and the original Trello design card says each driver 'gives the tycoon a set amount of volume that can be delivered per minute' with progress bars. Player-truck cargo/animation and overload claims are confirmed (0.2.1b, 0.6.6b).
- **partly wrong:** 10. Haggie125 2016 request for clients to share pathfinding ('pretty strenuous on the server'); 2019 post that tile-grid A* ran 'much smoother' than Roblox pathfinding; Trello lists distance-based NPC LOD, 5x5-stud tiles and 300x360-stud plots
  - Correction: Both posts are real and correctly dated and quoted; the 2019 one also says 'I don't have any numbers to compare but it seems to be similar if not less cpu-intensive', so it is an impression, not a benchmark. Trello: 'NPC LOD is acting up: Disabled on-screen checking for now, distance checks still on' (2020-11) and 'Tiles are 5x5 and walls are 0.5 thick' are there. The plot size is not a shipped fact: the card (created 2020-02-01, nine months before beta) says 'Land plots are 300x360 but that is very easy to change and probably will change based on performance results'. The live More Land pass says 1,344 tiles is '60% more than default', i.e. about 840 buildable tiles (21,000 sq studs at 5x5), versus 4,320 tiles for a 300x360 plot. Treat the buildable area as roughly 840 tiles, 1,344 with the pass.
- **partly wrong:** 13. Monetization is light and cosmetic/convenience: six passes (Military Clearance 499, More Land 399, Electric Semi 299, Custom Color Palettes 299, Custom Floors 149, Custom Radio 149), cash packs from 5 R$ for $1,000, one brand deal (Philips Norelco Oct-Nov 2022), rotrends best Top Earning #493
  - Correction: Prices, the six on-sale passes, six cash packs (5, 10, 50, 100, 500, 1,000 R$ for $1,000 to $300,000) and the Philips event are all correct. Two problems. (1) 'Cosmetic/convenience' is wrong for half the catalogue: Military Clearance unlocks four sellable product categories plus vehicles, More Land gives 60% more buildable tiles, Electric Semi is a faster hauler, and cash packs buy progress directly. Only palettes, floors and radio are cosmetic. (2) The pass API returns eight passes, not six: 'Sandbox Mode' (save slots with unlimited funds, excluded from leaderboards) and '4th Floor' were both created 2026-09-28 and are not yet for sale. The #493 Top Earning rank covers only rotrends' window of 2024-04-20 to 2026-09-18, long after the 2021-22 peak, so it is not a lifetime best.

### Conclusions that go beyond the evidence
- Lesson 1 ('never rendered on the road in six years (open Trello card)'): the Trello board has had no activity since 2022-03-18, and the neighbouring open card 'Option for clientside pathfinding' shipped three months later, so an open card proves nothing about 2022-2026. Drivers only existed from Sept 2021, so 'six years' is five. The remaining support is one fan-wiki trivia line last edited Aug 2024 plus changelog silence. The lesson's design advice is reasonable, but it is stated with more certainty than one small studio's unshipped feature justifies; it shows RT2 got away without it at 6 players per server, not that visible NPC hauling is infeasible or unwanted. It also sits in tension with the user's stated wish that supply lines be real, visible things.
- Lesson 2 ('Instant delivery at +25% is the whole anti-tedium design'): overstated. RT2 has three parallel answers (instant delivery, hired drivers with per-vehicle throughput, managers), and the wiki notes instant delivery turns some goods into a net loss, so it is a priced trade-off, not a free skip. 'Give every haul a paid shortcut' is a design opinion; nothing read shows how many RT2 players use instant delivery or that it improves retention.
- Lesson 3 ('Automate in the order players get bored: cashier, restocker, manager, then driver'): that is simply the order the developer shipped them (cashier and restocker at beta, manager 2021-05-22, driver 2021-09-03); no source ties it to player boredom. The list also omits janitors, guards and finance reps. The 'genre contract' rests on one DevForum reply (2026-02-01) about a different game, which is one player's opinion.
- Lesson 4 ('made hauling a progression track rather than a tax'; 'yields clip-worthy moments'): the ladder exists, but no evidence was read about how players feel about hauling or about clips. Speculation presented as outcome.
- Lesson 5 ('the server never sees an unbounded crowd'): parking cost rises linearly with no documented hard cap, and RT2 later added tram stations and bus stops as non-parking customer sources. The '~40 spots rarely fill' remark is from a third-party guide, not the wiki. Parking is a soft economic throttle, not a guarantee.
- Lesson 6 ('Budget for roughly a hundred pathing NPCs per server'): the only number behind this is a 2018 interview remark about Retail Tycoon 1 ('watch a hundred little artificial people run around'), a figure of speech. No concurrent NPC count for RT2 was found by them or by me. The prescription 'no humanoid collisions, client-rendered NPC visuals and server-side state only' is general Roblox practice, not something the RT2 sources document (the changelog shows only delivery-truck animations and beeps moved client-side). Custom tile A* is supported only by a 2019 impression post that says 'I don't have any numbers'. A tile grid also fits bounded store plots; it does not obviously transfer to an open persistent world.
- Lesson 7 ('Do not plan on offloading pathfinding to clients'): one opt-in beta toggle in one game was removed with the note 'it mostly caused problems'; the reason is not given. That supports caution, not a general rule. It could have failed for implementation or trust reasons specific to RT2.
- Lesson 8 ('after players broke servers'): the changelog says 'Limited hanging plants to 200 (you did this to yourselves)', which implies abuse but does not say servers broke. Minor, but worded stronger than the source.
- Lesson 9 ('RT2's first minute is menus, plot choice and building before any sale'): the brief itself says the tutorial script was not found. Changelog 0.1.3b mentions a 'default store' with a parking spot, which suggests new players may not start from bare land. The cited guide (published 2025-06-03) says the start 'can be a bit complicated' and, two paragraphs later, that it 'is fairly straightforward'. Time-to-first-sale in RT2 is unverified; the recommendation follows from the project's own 60-second criterion, not from RT2 evidence.
- Lesson 10 ('the first cross-player trade route has to be in the launch build, since the ranking rewards intentional co-play'): RT2 reached 341M visits with co-op arriving 15 months late, so the case study does not show late co-op is fatal. The ranking signal is co-play days (joining friends, invites, private servers), which a trade route does not automatically produce. This is a design position, not a finding.
- Lesson 11 ('held 1.4K-2.4K average CCU for over a year after content stopped' and 'fell from 2.4K to about 1K with no updates'): the CCU series starts in Nov 2025, nine months after the last content update, has no May 2026 row, and covers 12 months, so 'over a year after content stopped' is not what the data shows. The fall is attributed to missing updates, but the rise from 1.4K (Mar) to 2.4K (Jun) happened under the same absence of updates; summer seasonality and back-to-school explain the shape at least as well. A fairer read is year over year: 1.6K in Nov 2025 against about 1.0-1.1K now. 'Systemic content works' is a causal claim from a single game whose long tail could equally come from 1.4M favorites and brand age.
- Lesson 13 ('Rail-guided trains and path-following ships avoid most of this'): plausible engineering judgment, but nothing in the RT2 material tests it. RT2's problem was specific to a per-frame PID raycast-thruster suspension run on low-fps clients.
- Lesson 14 ('A sequel as a new universe abandons the old audience's momentum'): no RT1 player count from before the sequel was read, RT1 was already five years old, and RT2 went on to exceed RT1's lifetime visits (341M vs 218M) with a better rating (88.4% vs 78.9%). The evidence fits 'the sequel succeeded and the original was retired' as well as it fits the brief's reading. 'Evolve one place' may be right for a persistent world, but RT1/RT2 does not demonstrate it.

### What the brief missed
1. The dev Trello is a dead source: board, card and action timestamps all stop at 2022-03-18 (https://trello.com/b/hO1Tsvgz.json). Anything the brief calls 'still open' or 'never shipped' on the strength of that board needs the changelog as its real evidence.
2. RT2 is not abandoned: the game-pass API lists two unreleased passes created 2026-09-28, 'Sandbox Mode' (unlimited-funds save slots, excluded from leaderboards) and '4th Floor', both not yet for sale. That points to an update in preparation and weakens the 'near-silence' framing. The studio's other game Cash Cow [Beta] was last updated 2026-09-11.
3. Hired hauling is a per-vehicle throughput stat, which is the useful design detail: the wiki Vehicles table gives 'Items/Per Minute (With Delivery Driver)' from 150 (pickup) to 4,500 (electric semi), drivers gain +5% driving speed per level, and the truck is visibly parked at the store dock between runs. So RT2's model is 'visible vehicle at the home end, rate-based delivery, nothing on the road'.
4. Buildable area: the More Land pass text implies about 840 default tiles and 1,344 with the pass; the 300x360-stud figure is a Feb 2020 planning note.
5. RT2 has an NPC raid loop the brief never connects to the user's pirate idea: robbers steal stock, countered by hired guards, cameras and security gates; 1.8 (2024-12-18) reworked it so detected robbers freeze, then flee after 30 seconds. Guard AI was a repeated performance and bug source (guards 'cheat' under load, freezing fixes into 2025).
6. Late-game customer inflow is decoupled from parking by tram stations and bus stops (1.5.7, 1.5.8), relevant if beds or berths are meant to be the only guest throttle.
7. Monthly CCU has a visible summer hump (Jun-Aug 2.2K-2.4K) and an unexplained April jump (+40.1%, tracker peak 5K on 2026-04-19, right after the 1.8.2.6-1.8.2.8 save patches). Any retention conclusion should compare like months.
8. Seven worker types exist (cashier, restocker, janitor, manager, guard, delivery driver, finance rep); the finance rep, who lends customers money so they can afford big items, is a neat demand-side automation the brief skips.
Scratch copies of everything fetched are in (session scratchpad) (nothing was written to the project folder).


---

# C. The cozy audience

## Who plays "cozy", and does it widen a Roblox audience?

All Roblox numbers were read on 2026-11-18 (a Wednesday). Live players, visits and created dates come from `games.roblox.com/v1/games?universeIds=<id>`. Averages and 30-day peaks come from `statroblox.com/games/<id>/x`. All-time peak comes from `rotrends.com/game/<id>`; for older games it is lower than press-reported peaks, so treat it as "peak on that tracker".

### 1. Roblox audience by gender and age

| Fact | Source |
|---|---|
| Q2 2026: 57% of DAUs age-checked; of those, 35% under 13, 38% aged 13-17, 27% over 18 (about one-third in the US) | [Q2 2026 shareholder letter](https://s27.q4cdn.com/984876518/files/doc_financials/2026/q2/Roblox-Q2-2026-Earnings-Shareholder-Letter.pdf) |
| US over-18 DAUs up 32% year on year, 18-34 up 42%; US over-18s monetize over 50% higher than under-18s | same letter |
| Q3 2026: 138M DAU; 64% age-checked; over-18s are 29% of age-checked DAU globally, 37% in the US | press, [GGRecon](https://www.ggrecon.com/articles/roblox-daily-players-fall-q3-2026/); the Q3 letter itself was not retrieved |
| Roblox says RPG, strategy and shooter games are "heavily underrepresented despite strong demand from older age groups" | [Roblox newsroom, Mar 2026](https://about.roblox.com/newsroom/2026/03/roblox-announces-incubator-jumpstart-creator-programs) |
| Gender: the FY2024 and FY2025 10-Ks say only that users are "diversified across... gender"; the Q2 2026 letter has no mention of gender, female or women | [FY2025 10-K](https://www.sec.gov/Archives/edgar/data/1315098/000131509826000024/rblx-20251231.htm), text search of the Q2 letter |
| US mobile panel: female weekly users passed male for the first time; female +24% year on year vs male +5%. The panel cannot track under-17s | [Apptopia, 28 Jul 2026](https://apptopia.com/en/insights/female-waus-now-outnumber-male-users-on-roblox-mobile/) |

**16+ women specifically:** no official figure exists. The Apptopia panel is the nearest evidence. The other is Dress To Impress: 43% of its players over 18 (Vogue, via [Gameranx, May 2025](https://gameranx.com/updates/id/538084/article/is-a-roblox-fashion-game-bringing-in-a-big-adult-audience/)), described as mostly women aged 25-35 by [L'ADN](https://www.ladn.eu/nouveaux-usages/dress-to-impress-ce-jeu-roblox-qui-seduit-les-femmes-trentenaires/), which cites no data.

### 2. Roblox games that are cozy or widely described as girl-leaning

No per-game gender split was found for any of these.

Flags: C = ingredients-to-products chain, T = taming or breeding, D = interior design, R = playable species, X = danger or combat. No game's description mentioned NPC relationships.

| Game (universe id) | Live | 7d avg | 30d peak | Tracker peak | Visits | Created | Loop | Flags |
|---|---|---|---|---|---|---|---|---|
| Brookhaven (1686885941) | 296,771 | 350,273 | 687,673 | 1.3M | 89.6B | 2020 | town roleplay, houses | D |
| Adopt Me! (383310974) | 275,992 | 187,045 | 1,128,838 | 1.9M | 45.4B | 2017 | raise, collect, trade pets; build home | D |
| Fish It! (6701277882) | 60,762 | 64,542 | 159,677 | 2.7M | 4.8B | 2024 | click fishing, collect variants | – |
| Fisch (5750914919) | 47,046 | 62,845 | 434,881 | 1.3M | 5.2B | 2024 | fishing, exploration | – |
| Dress To Impress (5203828273) | 45,885 | 52,631 | 322,094 | 1.7M | 11.4B | 2023 | timed outfit, runway vote | – |
| Berry Avenue (3240075297) | 38,402 | 39,056 | 126,113 | 200.6K | 9.0B | 2022 | town roleplay | – |
| Creatures of Sonaria (1831550657) | 20,209 | 22,008 | 42,255 | 72.7K | 2.3B | 2020 | grow a creature, survive, trade | R, X |
| Grow a Garden (7436755782) | 17,728 | 16,734 | 107,336 | 22.3M | 36.0B | 2025 | plant, wait, sell; offline growth | – |
| Evermore High (10767537135) | 10,138 | 15,046 | 47,574 | 47.6K | 23.9M | Sep 2026 | school roleplay, dress-up | – |
| Welcome to Bloxburg (88070565) | 14,103 | 13,820 | 42,141 | 592.5K | 10.2B | 2014 | build and decorate house, jobs, cooking skill | D |
| Cozy Lucky Scoop Order (10771928551) | 6,867 | 12,603 | 21,285 | 21.3K | 24.9M | Oct 2026 | scoop, pack, ship orders | D |
| Run A Farm! (10768558548) | 5,997 | 10,518 | 19,692 | 19.7K | 10.0M | Sep 2026 | coop, crops, trucks to market | C |
| Royale High (321778215) | 7,229 | 8,307 | 14,894 | 40.8K | 10.5B | 2017 | fantasy school dress-up | – |
| Dragon Adventures (1235188606) | 6,372 | 7,981 | 13,343 | 61K | 1.76B | 2019 | hatch and raise dragons, lair, guild wars | T, D, X |
| Restaurant Tycoon 3 (7094518649) | 4,461 | 6,210 | 15,142 | 67.4K | 394M | 2025 | cook, serve, build; offline income | C, D |
| Livetopia (2549475383) | 1,993 | 3,487 | 8,505 | 65.8K | 5.5B | 2021 | town roleplay | – |
| Wild Horse Islands (2682938349) | 3,183 | 3,335 | 11,058 | 17.9K | 695M | 2021 | capture, train, sell horses | T |
| Run a Restaurant! (9970645639) | 2,624 | 3,321 | 7,742 | 33.8K | 138M | Apr 2026 | cook, farm crops and animals, decorate | C, D |
| Tavern Town (10771350522) | 1,672 | 2,658 | 3,564 | 3.6K | 0.9M | Oct 2026 | build a tavern, cook, hire; hunt, fish, mine | C, D, X |
| Horse Life (5422546686) | 1,768 | 1,858 | 3,803 | 23.2K | 375M | 2023 | tame and breed horses, home building | T, D |
| Farming and Friends (1001911915) | 1,023 | 1,338 | 3,413 | 9K | 246M | 2019 | co-op crops and animals | – |
| Islands (1659645941) | 431 | 558 | 1,183 | 5.2K | 2.36B | 2020 | island farm, animals, cooking, bosses | C, X |
| My Hello Kitty Cafe (3494556606) | 220 | 208 | 2,692 | 20.5K | 523M | 2022 | themed cafe tycoon | C, D |
| Wacky Wizards (2628404708) | 306 | 409 | 912 | 5.1K | 1.02B | 2021 | combine ingredients into potions | C |

Average session is 48 minutes in Adopt Me and 55 in Tavern Town, against 17-25 for most of the rest (statroblox estimates).

### 3. Outside Roblox: who plays cozy games, and why

- **Genre skew:** Quantic Foundry's 2017 study found Match 3 and Family/Farm Sim had the highest share of women (69%), against 7% for first-person shooters and 2% for sports. The author ties this to motivation: genres with more women stress Completion and Fantasy; low-share genres stress Competition and Destruction ([Game Developer](https://www.gamedeveloper.com/business/beyond-50-50-breaking-down-the-percentage-of-female-gamers-by-genre)).
- **Animal Crossing:** 75% female, average age 35, in a 180,000-person Japanese survey ([Nintendo Life, Jul 2025](https://www.nintendolife.com/news/2025/07/gender-split-and-average-ages-of-japanese-nintendo-players-revealed-via-new-survey)).
- **Pace preference:** US women split evenly between fast-paced and cozy games; 79% of men prefer fast-paced. 88% of both say customization makes them play or buy more ([MarketCast via GamesBeat, Dec 2025](https://gamesbeat.com/data-report-in-2025-women-spent-more-time-gaming-than-men/)).
- **Reasons given:** switching off from stress 53%, playing at one's own pace 52%, feeling productive without pressure 51% in Spain. 17% in Spain and Germany want a better balance of relaxation and challenge ([Sago, Sep 2025](https://sago.com/en/resources/insights/the-rise-of-cozy-gaming-across-borders/)).
- **Stardew Valley, Palia, The Sims:** no gender data found from a page read in this run.

### 4. Cozy production mixed with danger or logistics

| Game | Scale | How the mix is built | Source |
|---|---|---|---|
| Stardew Valley | 50M copies by Feb 2026 | Monsters live only in the mines; the game is designed so players never feel rushed; reviewers call combat simple but rewarding | [Wikipedia](https://en.wikipedia.org/wiki/Stardew_Valley) |
| Palworld | 2.1M Steam peak (Jan 2024); about 962K again after 1.0 (Jul 2026) | Captured creatures staff the base; combat feeds capture | [Wikipedia](https://en.wikipedia.org/wiki/Palworld) |
| Core Keeper | 1M sales by Jul 2022; Metacritic 85 | Farming and cooking give buffs for bosses; 8-player co-op | [Wikipedia](https://en.wikipedia.org/wiki/Core_Keeper) |
| My Time at Sandrock | Metacritic 80 on PC | Workshop crafting, dungeons, 21 romanceable NPCs, co-op | [Wikipedia](https://en.wikipedia.org/wiki/My_Time_at_Sandrock) |
| Palia (no combat) | 10M players by Apr 2026 | Two layoff rounds in 2024 (35%, then 40%), then sold; updates irregular from early 2026 | [Wikipedia](https://en.wikipedia.org/wiki/Palia) |
| 99 Nights in the Forest (Roblox) | 147,184 7d avg; 14.1M peak | Co-op survival and crafting | statroblox, rotrends (id 7326934954) |
| Islands (Roblox) | 2.36B visits, now 558 7d avg | Farm, cook, bosses; last updated Jan 2026 | Roblox API |

On Steam, cozy games with the Crafting tag reach 1,000 reviews 30% of the time, Farming Sim 27.8%, Life Sim 24.4% and Building 23.4%, against 11% for all cozy games and 4.2% for all of Steam. Cozy idlers manage 15.8% and incrementals 7.5% ([Steam Page Analyzer, Sep 2026](https://www.steampageanalyzer.com/blog/cozy-games-steam-2026-niche-report)).

### 5. What looks under-served on Roblox

These come from keyword searches of Roblox's own search API today, so "none found" means none surfaced.

- **Depth:** the big cozy games are roleplay, dress-up and pet collecting. Games with a real production chain sit at about 10K average players or below.
- **Potions, witches, brewing:** the largest potion game is Wacky Wizards at 409; the largest "witch" result is a school roleplay.
- **Fantasy hospitality:** Tavern Town, one month old, is the only tavern game found: 2,658 average, 55-minute sessions.
- **Playable species with trade-offs:** only Creatures of Sonaria (22K average, six years old), which is a survival game.
- **NPC relationships:** none found.
- **A fast-follow wave is forming:** six cozy shop, farm and hotel tycoons created since September 2026 already average 6K-15K.

### The pattern, and how strong the evidence is

The designer's list is one cluster: making, tending, decorating, collecting and belonging, in a fantasy setting, at the player's own pace. In Quantic Foundry's terms it is Completion, Fantasy and Design, which are the motivations it reports as most common among women; Competition and Destruction lead for men.

- **Off Roblox:** strong and consistent that these themes over-index with women and adults.
- **On Roblox:** directional only. Roblox publishes no gender data; the support is one third-party panel, Dress To Impress's adult share, and the size of the roleplay, pet and dress-up evergreens.
- **Limit:** cozy adds women without holding most men (79% of men prefer fast-paced), so the wider audience comes from the mix, not from cozy alone.

## Researcher's lessons (several are struck or narrowed by the check below)
- The designer's list is one cluster: make, tend, decorate, collect and belong, in a fantasy setting, at the player's own pace. In Quantic Foundry's terms that is Completion, Fantasy and Design. Treat those three as the design levers for the wider audience, not the individual themes.
- The claim 'these themes widen the audience beyond teenage boys' is well supported off Roblox and only directionally on Roblox, because Roblox publishes no gender data. Plan to measure it in our own analytics from the first playtest; do not assume it.
- Cozy adds women without holding most men (79% of men prefer fast-paced games). The widening has to come from the mix: a calm production layer alongside the logistics, economy and conflict layer, with neither one forced on the other's players.
- The hybrids that reached scale keep danger in a separate place the player chooses to enter (Stardew's mines, Core Keeper's bosses) and make cozy output matter there (food buffs, creatures as labour). The baked goods with specific stat boosts and creature furs into armour in the idea are this same link.
- Avoid time pressure on the cozy layer. Stardew was built so players never feel rushed, and 'own pace' and 'productive without pressure' are the top reasons cozy players give. Raids on supply lines need a response that does not punish a player who was baking.
- Customization is the one feature both genders rate equally (88% each). Interior design, landscaping and playable races serve both audiences at once, so they are the safest early investment of the cozy systems.
- Playable species with real trade-offs has one Roblox precedent, Creatures of Sonaria, which has held about 22K average players for six years. No cozy or life-sim game found offers it, so races are a differentiator rather than a proven draw.
- Depth is the open space on Roblox: games with multi-step production chains sit at 10K average players or below, and potions, brewing, fantasy taverns and NPC relationships have almost nothing above 3K. Islands' fall to 558 shows the risk side: a chain-heavy farm game that stops updating loses its audience.
- The first players are age-checked 16+, where adults are the fastest-growing and best-monetizing group, Roblox says older users want RPG and strategy, and Dress To Impress shows adult women will turn up for the right game. A deep economy with a cozy layer fits the launch gate better than a pure young-kids roleplay game would.
- Tavern Town (one month old, 2,658 average, 55-minute sessions) and the cozy tycoon wave since September 2026 show the theme is being fast-followed now. A simple cozy tycoon would be one of many; the persistent world, physical supply lines and races are what would keep the game from reading as a clone.

## Not found
- An official Roblox gender split for any period: SEC filings read say only 'diversified across gender'; the IPO-era 44% female figure was seen only in a search summary of Quartz (the page returned 403).
- Gender of age-checked 16+ or 18+ Roblox users, from Roblox or anyone else.
- What age-checked 16+ or 18+ users play, by genre or by title, beyond Roblox's one sentence on RPG, strategy and shooter demand.
- The Q3 2026 shareholder letter itself (several URL patterns returned 404); Q3 figures are from press coverage, and the Q3 under-13 and 13-17 shares were not found.
- A measured gender split for any individual Roblox game, including Adopt Me, Royale High, Brookhaven, Bloxburg, Grow a Garden and the horse games. A tracker blog's claim that 'RPGs skew 70% female' on Roblox had no source and was not used.
- Player gender data for Stardew Valley, Palia, Disney Dreamlight Valley, Valheim, Core Keeper and Minecraft. The Sims 4 figure (74% women, Circana 2023) and Animal Crossing's 50/50 figure (Nintendo, 2020) were seen only in search summaries, not on a page read.
- Quantic Foundry's own pages (403), so the motivation ranking by gender comes from secondary coverage and no percentages were confirmed.
- Any study measuring how cozy players react to optional versus forced combat; only reviewer opinion on Fae Farm surfaced, in a search summary.
- Data on My Time at Portia, Dinkum, Travellers Rest and Disney Dreamlight Valley (not reached); My Time at Sandrock sales.
- Reliable all-time peaks for older Roblox games: tracker history is incomplete (for example Islands shows 5.2K and Royale High 40.8K on rotrends), and Dress To Impress shows 1.7M on rotrends against 1.1M on rowatcher.
- Whether any Roblox game has NPC relationship systems or cozy playable races: none surfaced in keyword searches of Roblox's search API, which is not an exhaustive check.

## Independent check

11 of 14 key facts confirmed.

### Facts corrected
- **partly wrong:** 4. Roblox's only stated steer on what older users want: 'RPG, strategy, and shooter games are heavily underrepresented despite strong demand from older age groups.' No genre/title data for 16+ or 18+ found.
  - Correction: The quote is exact (post dated March 9, 2026) and I also found no genre-by-age data. But it is not the only steer. Roblox's April 2026 DevEx post says the 18-34 US audience is driving demand for 'deeper gameplay, distinct visuals, and genre-defining games', and the Q2 letter says Roblox is adding 2D, single-player, offline and turn-based support to reach players over 25. Note the quote names shooters too; lesson 9 drops that.
- **partly wrong:** 8. Roblox games with real ingredient-to-product chains are small: Run A Farm 10,518; Restaurant Tycoon 3 6,210; Run a Restaurant 3,321; Tavern Town 2,658; Islands 558 (2.36B visits, last updated Jan 2026); Wacky Wizards 409.
  - Correction: Every number is right. The generalisation is not. Bee Swarm Simulator (gather pollen, make honey, craft; created 2018) has a 34,005 7-day average, and The Forge (mine ore, forge gear from 1,000+ ore combinations; created May 2025) has 22,888 with a 94,159 30-day peak. The brief's own table also has 99 Nights in the Forest (survival crafting) at 147K. The accurate statement is narrower: cozy-themed farm, food and tavern production games sit at about 10K or below. Most of those listed are also falling (Restaurant Tycoon 3 down 16% on 30 days, Run a Restaurant down 32%).
- **partly wrong:** 10. A wave of cozy shop, farm and hotel tycoons created since September 2026 already averages 6K-15K with 89-96% like ratios (Evermore High 15,046; Cozy Lucky Scoop Order 12,603; Farm Evolution 11,933; Run A Farm 10,518; My Small Business 8,058; My Cookie Store 6,209; Run a Motel 6,068).
  - Correction: The seven averages, creation dates and like ratios all check out. Two problems with the framing. Evermore High is a dress-up school roleplay, not a tycoon; without it the range is 6K-12.6K. And the 7-day averages hide steep, opposite trends: My Small Business peaked at 45,598 on Oct 31 and its daily average fell from 21,178 (Nov 8) to 4,305 (Nov 17), down 44% week on week; Evermore High is down 28%; My Cookie Store (+165%), Run a Motel (+110%) and Cozy Lucky Scoop (+33%) are still climbing. Estimated sessions are short for two of them (11 minutes for Farm Evolution and Cozy Lucky Scoop). Live counts on 2026-11-18 ran 2.6K to 10.2K.

### Conclusions that go beyond the evidence
- Lesson 3 (cozy adds women 'without holding most men'): the 79% is a forced-choice preference among 397 US men, mostly adults, in one survey. It does not show that men avoid cozy games, and it is not Roblox or teen data. The brief's own sources show substantial male play of slow games (Animal Crossing 25% male; farm sims about 31% male on Quantic Foundry's numbers). Fair wording: men lean to fast-paced play, so a calm layer alone is a weaker hook for them.
- Lesson 4 (hybrids at scale keep danger in a separate place the player chooses to enter): supported by Stardew only. Palworld's Wikipedia page describes hostile factions patrolling the open world, Core Keeper's bosses gate technology and biomes in the same world the player farms in, and 99 Nights in the Forest (147K average, in the brief's own table) brings the threat to the base. The second half of the lesson, that cozy output should matter in the danger layer, is supported by Core Keeper and Palworld.
- Lesson 5 (avoid time pressure, citing Stardew): Stardew has a day clock, an energy bar and seasons; Barone's point was no deadline to finish everything. The evidence supports 'no fail deadlines and no punishment for absence', not 'no time pressure'. The 51% 'productive without pressure' figure is Spain only, from a Sago omnibus that states no sample size.
- Lesson 6 (customization is rated equally by both genders, so interior design, landscaping and playable races are the safest early investment): the 88% is about character customization. It supports avatar and race appearance options; it says nothing about interior design or landscaping, and 'safest early investment' is a design judgment, not a finding.
- Lesson 7 (playable species with trade-offs has one Roblox precedent): too narrow. Blox Fruits (222,120 live players on 2026-11-18, Roblox search API) has playable races with different abilities according to several guides, and Deepwoken (about 4.2K live) is a race-based RPG. Race picks with mechanical differences are common in Roblox combat RPGs. What the evidence supports is that no cozy or life-sim game was found with them, and none where race affects production or needs.
- Lesson 8 ('depth is the open space'; chain games sit at 10K or below): contradicted by Bee Swarm Simulator (34,005 7-day average, eight years old), The Forge (22,888) and 99 Nights in the Forest (147K). Low counts for cozy production games are also consistent with low demand, not only an opening; the brief has no evidence to tell the two apart. The Islands point is one case with only a last-updated date: no timeline shows the decline followed the end of updates.
- Lesson 9 (the 16+ launch audience favours a deep economy with a cozy layer): stacks several weak links. No data exists on what age-checked 16+ users play. The growth and monetization figures are US-only extrapolations that Roblox itself caveats. Roblox's quote names shooters as well as RPG and strategy. The Dress To Impress 43% over-18 figure has no gender split, rests on self-reported ages, and is disputed by other outlets (about half). The 16-17 group sits inside the 13-17 bracket, the largest one, so the launch pool is not mainly adults. It is a reasonable hypothesis, not a finding.
- Lesson 10 (the cozy tycoon wave shows the theme is being fast-followed; persistence, supply lines and races keep the game from reading as a clone): the wave is real but volatile. My Small Business lost about 80% of its daily average in nine days, and one of the seven is a dress-up roleplay. 'Averaging 6K-15K' overstates how settled these games are. Tavern Town's 55-minute session is a tracker estimate on under 1M visits. The claim about what prevents a clone reading is a design opinion with no evidence in the brief.
- Lesson 1 (Completion, Fantasy and Design are the motivations Quantic Foundry reports as most common among women): the cited article names only Completion and Fantasy. Design appears in Nick Yee's other write-ups (found via search, not read in full), so the claim is probably right but is not supported by the source given. The 'belong' part of the cluster (NPCs, relationships) maps to none of the three.

### What the brief missed
1. Gender can be measured per game. Roblox's Creator analytics dashboard docs list Gender ("Female, male, unknown") as both a filter and a breakdown (https://create.roblox.com/docs/production/analytics/analytics-dashboard.md). That makes lesson 2 concrete: the first playtest can report the split directly. It is self-reported and has an "unknown" bucket.

2. Production-chain games that are not small were left out: Bee Swarm Simulator (34,005 7-day average, created 2018, estimated 20-minute sessions) and The Forge (22,888 7-day average, 94,159 30-day peak, created May 2025). Both pair a gather-and-craft chain with light combat, which is closer to the proposed design than the restaurant tycoons are.

3. The user asked for Restaurant Tycoon and Retail Tycoon. The brief covers Restaurant Tycoon 3 only. Live counts from Roblox's search API on 2026-11-18 (single weekday reading, no average fetched): Restaurant Tycoon 2 about 785, Retail Tycoon 2 about 608, original Retail Tycoon 13, My Restaurant! 193.

4. The September-October wave is churning, not settling: My Small Business went from a 45,598 peak (Oct 31) to a 4,305 daily average (Nov 17). That is the same fast decay the project's Day 8-28 ranking signals punish, and it matters more for the design than the headline averages.

5. Roblox's own direction for older users goes beyond genre: "deeper gameplay, distinct visuals, and genre-defining games" (April 2026 DevEx post), plus 2D, single-player and turn-based support for players over 25 (Q2 letter).

6. Not verified in this run: the full Apptopia article (blocked to the fetcher), the Vogue original for the Dress To Impress figures, and the origin of the 51/44/5 split.


---

# D. Physical-economy and persistent-world precedents

## Closest Roblox comparables: what is proven, what is untested

Snapshot: Wed 2026-11-18, ~23:40 UTC. Number sources:
- **[A]** Roblox games API, `games.roblox.com/v1/games?universeIds=<id>`: live players, visits, created date, server cap.
- **[T]** `rotrends.com/game/<id>`: 7-day average, peak.
- **[W]** `rowatcher.com/games/<id>` then `/dying`: 30-day average.

Peaks are tracker-recorded only. RoWatcher holds 200-730 days per game, so older all-time peaks are not found. "Created" is the place creation date, which can predate release (Lumber Tycoon 2's 2009 is the place shell).

| Game (universe id) | Created [A] | Live [A] | 7d avg [T] | 30d avg [W] | Peak [T] | Visits [A] | Cap [A] |
|---|---|---|---|---|---|---|---|
| Lumber Tycoon 2 (2471084) | 2009-07 | 1,344 | 2,191 | 2K | 34.2K | 1.34B | 6 |
| Oaklands (3666294218) | 2022-06 | 245 | 298 | 501 | 8.1K | 61.9M | 8 |
| Industrialist (3448264866) | 2022-03 | 1,866 | 2,165 | 2K | 9.8K | 75.0M | 20 |
| Overfreight! (8794536584) | 2025-09 | 362 | 738 | 806 | 4.1K | 16.4M | 8 |
| Islands (1659645941) | 2020-04 | 431 | 558 | 635 | 5.2K | 2.36B | 20 |
| Welcome to Bloxburg (88070565) | 2014-11 | 14,103 | 13,863 | 17K | 592.5K | 10.17B | 12 |
| Theme Park Tycoon 2 (31970568) | 2012-01 | 2,107 | 2,668 | 3K | 57.7K | 1.63B | 6 |
| Build A Boat (210851291) | 2016-11 | 9,148 | 12,064 | 13K | 50.8K | 5.26B | 7 |
| Dead Rails (7018190066) | 2025-01 | 16,918 | 19,293 | 21K | 1.5M | 6.66B | 16 |
| Stepford County Railway (300039023) | 2017-03 | 98 | 234 | 286 | 11.9K | 130.9M | 75 |
| Cabin Crew Simulator (1802741133) | 2020-06 | 954 | 1,373 | 2K | 11.7K | 446M | 10 |
| Tradelands (92096286) | 2014-12 | 11 | 20 | 26 | 558 | 53.5M | 50 |
| Arcane Odyssey (1180269832) | 2019-06 | 441 | 464 | 492 | 24K | 156.4M | 12 |
| Silk Road: Trading Simulator (9718589349) | 2026-02 | 64 | 121 | 140 | 1.6K | 4.5M | 80 |
| Starscape (290384992) | 2017-03 | 14 | 14 | 13 | 951 | 16.1M | 16 |
| Northwind (1463361180) | 2019-12 | 86 | 104 | 133 | 2.2K | 28.8M | hub |
| Fallen Survival (3747388906) | 2022-07 | 1,197 | 1,830 | 2K | 7.3K | 51.0M | 100 |
| Deepwoken (1359573625) | 2019-10 | 4,359 | 3,945 | 4K | 36.8K | 1.66B | 30 |
| Rune Slayer (3764534614) | 2022-07 | 36 | 42 | 41 | 44.8K | 116.8M | 25 |
| Creatures of Sonaria (1831550657) | 2020-06 | 20,209 | 22,025 | 21K | 72.7K | 2.31B | 75 |
| Dragon Adventures (1235188606) | 2019-07 | 6,372 | 7,976 | 8K | 61K | 1.76B | 20 |
| Grow a Garden (7436755782) | 2025-03 | 17,728 | 16,621 | 18K | 22.3M | 36.0B | 4 |
| Restaurant Tycoon 3 (7094518649) | 2025-01 | 4,461 | 6,219 | 8K | 67.4K | 394M | 6 |
| Retail Tycoon 2 (2092410051) | 2020-10 | 622 | 831 | 1K | 9.8K | 341M | 6 |
| Tavern Town (10771350522) | 2026-10-16 | 1,672 | 2,660 | too new | 3.6K | 908K | 8 |

Also checked (7d avg [T]): Adopt Me 187,332; 99 Nights in the Forest 146,520; Run a Motel 6,090; War Tycoon 5,971; ER:LC 3,912; Plane Crazy 3,821; Wild Horse Islands 3,346; World // Zero 1,799; The Wild West 1,446; Booga Booga 1,081; Rogue Lineage 856; Pilgrammed 432; Vesteria 377; Shipping Lanes 356; Refinery Caves 2 82; Rails Unlimited 38.

### How the closest ones work

**Physical goods and journeys**
- **Dead Rails:** players fuel and drive a train about 80 km, with a safe fort every 10 km. Each run starts fresh.
- **Tradelands:** cargo is bought at a port and carried on your ship. Pay rises with distance, enemy factions can steal it, and running aground loses it.
- **Arcane Odyssey:** cargo is limited by what physically fits on the hull, and pay is by distance. Clans have built on claimable islands since Sept 27, 2024.
- **Starscape:** supply crates are hauled between star systems, and pay rises per warp.
- **Stepford County Railway:** players drive trains carrying passenger players, with dispatcher and guard roles.
- **Overfreight!:** "Build a railway", "drive physically simulated trains", "complete cargo chains"; friends build on the same area [A description].

**Economy**
- **Islands:** "economy revolves around player trading". Duped items forced a wipe on Jan 22, 2021, and the developer discontinued updates on Nov 7, 2023.
- **Starscape:** player marketplace since Oct 2020.
- **Dragon Adventures:** a Trade Island world with auction and Player Market.
- **Creatures of Sonaria:** trading only inside a Trade Realm.

**Persistence**
- **Lumber Tycoon 2:** six save slots per player, loaded into any server.
- **Theme Park Tycoon 2, Restaurant Tycoon 3:** a per-player plot; RT3 "can literally make money while you're offline" [A].
- **Fallen Survival:** the base is saved on your last server, and servers wipe every Friday [A].
- **Starscape:** player structures stay "indefinitely on the servers".

**World split across places**
- **Starscape:** one server per star system.
- **Deepwoken:** three region places capped at 24, 20 and 14 players.
- **Northwind:** six islands chosen from a hub.
- **Dragon Adventures:** twelve worlds via a teleporter.

**Races**
- **Deepwoken:** 13 randomly rolled aspects with innate talents and small attribute bonuses; reroll 150 Robux.
- **Rune Slayer:** a random species with "somewhat balanced" perks, reroll 100 Robux; creatures are tamed with their favourite food.
- **Rogue Lineage:** roll odds from 18.5% down to 0.9%.
- **Creatures of Sonaria:** each species' diet sets what it must eat, and seasons multiply food values.

### Direct answers

**(a) Goods and journeys as real things, at scale?**
Yes for the journey as a co-op run, no for player-built infrastructure.
- Dead Rails peaked at 1.5M [T], has 6.66B visits [A], and still averages 19,293 [T].
- Physical hauling inside a builder has lasted: Lumber Tycoon 2 has 1.34B visits and averages 2,191.
- Hauling or trading as the main job stays small: Tradelands 20, Silk Road 121, Shipping Lanes 356, Overfreight! 738.
- I found no game where players ride a railway or ship line that another player built to reach another region.

**(b) Many servers linked into one persistent world?**
One: Starscape.
- **How it is built:** 4,576 charted systems. A warp jump ends when "ROBLOX teleports the player to the next server". Overflow servers open at 200 players.
- **How regions affect each other:** three NPC factions fight over 282 contested systems. A system can be captured only if it borders enemy territory, then locks for six hours. Attacks show on the galaxy map for every player. Defences are built from supplies hauled in.
- **How it did:** 16.1M lifetime visits, 93.3% likes, a 7-day average of 14, and a tracker peak of 951.
- **Partial cases:** Deepwoken and Northwind split the world into places, but I found no cross-server influence. Tradelands' faction outcomes are staff-run roleplay.
- **DevForum:** only concept threads (topics 2224136 and 1926239).
- **Platform limit:** MemoryStore gives 64 KB + 1.2 KB per user for the whole game.

**(c) Strongest and weakest proven demand?**
- **Strongest:** raising and collecting creatures. Adopt Me averages 187,332 after nine years, Creatures of Sonaria 22,025, Dragon Adventures 7,976.
- **Next:** farming has the highest peak (Grow a Garden, 22.3M) but now averages 16,621.
- **Being tested now:** hospitality for NPC guests. Restaurant Tycoon 3 averages 6,219. Run a Motel reached 6,090 in a month. Tavern Town averages 2,660 with 59.3-minute sessions [T].
- **None:** I found no game with an NPC raider faction that players pay off or befriend. The linked-server world has one example, at 14 players.

**(d) Which held players for years, and what do they share?**
Adopt Me (2017), Bloxburg (2014), Build A Boat (2016), Creatures of Sonaria (2020), Dragon Adventures (2019), Deepwoken (2019), Plane Crazy (2014), Theme Park Tycoon 2 (2012), Lumber Tycoon 2.
- Progress is saved to the player and loads into any server.
- Building games use small servers (6-12). Only roleplay and creature sims run 50-75.
- None depends on shared world state.
- Play is open-ended making or collecting.
- All show place updates in November 2026 [A].

Counter-cases: Islands (2.36B visits, 558 after updates stopped) and Rune Slayer (species, taming and crafting; 44.8K peak, now 42).

### Wiki and doc sources
Fandom pages were read through each wiki's `api.php`, because the page fetcher returned HTTP 402.
- starscape-roblox.fandom.com/wiki/ Map, Warp, Faction_Warfare, Warfare_Structures, Player_Structures, Overflow_Servers, Historical_Marker
- tradelands.fandom.com/wiki/Cargo
- roblox-arcane-odyssey.fandom.com/wiki/ Cargo, Clans
- deepwoken.fandom.com/wiki/ Servers, Aspects
- lumber-tycoon-2.fandom.com/wiki/Load
- robloxislands.fandom.com/wiki/Economy_Wipe
- runeslayer.fandom.com/wiki/ Species, Pets
- rogue-lineage.fandom.com/wiki/Races
- creatures-of-sonaria-official.fandom.com/wiki/ Food_Sources, Trading
- dragon-adventures.fandom.com/wiki/ Worlds, Trade_Island
- scr.fandom.com/wiki/List_of_Roles
- roblox.fandom.com/wiki/ RCM_Games/Dead_Rails, Easy.gg/Islands, NORTHWIND_HUB/NORTHWIND, Spinning_Seal_Studios/Tradelands
- create.roblox.com/docs/cloud-services/memory-stores.md
- devforum.roblox.com/t/2224136, devforum.roblox.com/t/1926239

## Researcher's lessons (several are struck or narrowed by the check below)
- The ride itself is proven; the persistent network is not. Dead Rails shows a fuelled, driven train journey with stops can reach 1.5M concurrent players as a self-contained co-op run, so the first playable slice can be one journey between two places rather than a rail network.
- Linking many servers into one world has exactly one Roblox precedent (Starscape) and it averages 14 players across 4,576 systems. If regions are used, the evidence favours very few of them (Deepwoken runs three places, Northwind six islands) so players are not spread thin.
- Every building game that lasted a decade saves the base to the player and loads it into any small server (Lumber Tycoon 2: six slots, 6 players; Theme Park Tycoon 2: own plot, 6 players). Attaching persistence to a player or guild is the proven pattern; attaching it to a specific server is only seen with weekly wipes (Fallen Survival).
- Shared cross-server state has a hard budget: MemoryStore allows 64 KB + 1.2 KB per user game-wide, so at 100 concurrent players the whole shared world state must fit in about 184 KB. Region influence would need to be a few numbers per region, not synced objects.
- Hauling cargo as the main job tops out at 20-750 concurrent players (Tradelands, Silk Road, Shipping Lanes, Overfreight!). Where physical cargo survives in larger games it is one income source inside a broader game (Arcane Odyssey, Lumber Tycoon 2).
- Creature raising has the deepest proven demand of any element in the idea (Adopt Me 187K, Sonaria 22K, Dragon Adventures 8K, all five-plus years old), and each of those pairs it with player trading in a dedicated trade area.
- Tavern and inn play for NPC guests is the idea's most timely element: Tavern Town and Run a Motel both launched in October 2026 and sit at 2.7K and 6.1K 7-day averages, with Tavern Town at 59-minute sessions. Both are solo-plot tycoons with 6-8 player servers, so a shared-world version is untested.
- Races with trade-offs exist only as random rolls with paid rerolls in hardcore RPGs; no cozy or building game found uses them, and no game found ties a race to crafting, mining or farming aptitude. Sonaria's diets are the nearest evidence that players accept species-specific needs.
- Rune Slayer stacked species, taming and crafting and still fell from a 44.8K peak to 42, so the combination of systems does not hold players by itself.
- A player-trading economy needs duplication protection from the first day and continued updates: Islands wiped its economy over dupes in 2021 and dropped to 558 average players after updates stopped in 2023, despite 2.36B visits.
- Large servers (50-100) appear only in roleplay, creature sims and PvP survival; builders run 4-12. A design needing many players in one place to feel alive is outside what the surviving building games do.

## Not found
- All-time peaks from before the trackers' histories began (Starscape, Tradelands, Islands, Booga Booga, Northwind) and the date of Rune Slayer's 44.8K peak. RoWatcher holds only 200-730 days per game; Rolimons and RoMonitor were not usable.
- Averages over windows longer than 30 days.
- Any Roblox game with an NPC pirate or raider faction that attacks player trade unless paid or befriended. Tradelands has player pirates only.
- Any Roblox game where players ride a railway, ship line or airline that another player built to reach another region. Overfreight! has player-built freight railways on a shared plot; Stepford County Railway has player drivers on a fixed network.
- How Starscape is implemented under the hood (which data services, how server state is reconciled). Only wiki descriptions of behaviour were found, no developer write-up.
- Why Rune Slayer collapsed: only one low-authority blog (false bans, July 2025).
- What caused Lumber Tycoon 2's 34.2K peak on 2026-09-26. Several older games show tracker peaks the same week (ER:LC 2026-09-27, Plane Crazy 2026-09-26), which suggests a platform-wide event, but no source confirmed it.
- Whether Northwind houses and Booga Booga bases persist across servers.
- Whether Deepwoken's or Northwind's separate places influence each other; nothing found saying they do.
- Gender or age split of any game's audience.
- Search results for a shipped Foxhole-like game on Roblox returned only DevForum concept threads (topics 2224136 and 1926239).
- Fandom wiki pages returned HTTP 402 through the page fetcher; content was read through each wiki's api.php instead, so wording is from wiki source text and is community-written.

## Independent check

13 of 14 key facts confirmed.

### Facts corrected
- **partly wrong:** 13. Other world splits: Deepwoken three region places capped at 24, 20 and 14; Northwind hub to one of six islands with faction forts; Fallen Survival (100-player servers, 200 Robux, avg 1,830) saves base on last server and wipes every Friday.
  - Correction: Deepwoken and Fallen Survival match. Northwind is slightly off: the wiki says the screen shows 6 islands, but a new player can only enter Beauval Isles, four more (Cantermagne, Stonemore, Isle of Rupert, Ellesmere) unlock with progress, and the sixth 'is reserved for events held by staff'. So it is five playable islands gated by progression, not a free choice of six.

### Conclusions that go beyond the evidence
- Lesson 4 (shared state must fit in about 184 KB): not supported. MemoryStore is Roblox's fast, expiring cache, not the only cross-server store. Persistent shared state normally goes in data stores, which the docs give 4,194,304 characters per key and a game total of 500 MB + 1 MB per lifetime user (https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits.md), read and written by any server. The MemoryStore quota itself can also be raised through paid Extended Services (https://create.roblox.com/docs/cloud-services/extended-services.md, which requires an ID-verified 18+ owner). The real constraints are request rates and update latency, not a 184 KB ceiling, so 'a few numbers per region, not synced objects' does not follow from this figure.
- Lesson 1 ('the ride itself is proven'): Dead Rails proves a co-op zombie-survival run framed by a train journey. The wiki describes combat, looting guarded buildings and a final fort fight as the play; the brief did not separate the appeal of the ride from the appeal of the horde shooter. It also sits at about 1.3% of its peak and is rated 13+ on RoTrends, above the project's Mild target. 'One journey between two places' as a first slice is a reasonable design choice, but the 1.5M figure is not evidence for a peaceful or economic journey.
- Lesson 2 (Starscape's 14 players as a verdict on linked servers; 'evidence favours very few regions'): Starscape's low count is confounded. The API shows no update since 2026-05-28, it is nine years old, its earlier peak is unknown, and it still holds 93.3% likes. Nothing fetched shows that the number of systems caused the small audience. 'Very few regions' rests on two examples (Deepwoken, Northwind) that are themselves small or mid-sized, and no comparison with a many-region game that failed for that reason.
- Lesson 3 ('attaching persistence to a specific server is only seen with weekly wipes'; 'player or guild is the proven pattern'): contradicted by the brief's own Starscape entry, where player structures linger 'indefinitely' in a world location with no wipe. The guild half is not evidenced: none of the decade-old builders cited saves a base to a guild. 'Every building game that lasted a decade' is drawn from three games.
- Lesson 5 ('tops out at 20-750'): this is the range of four games the researcher picked, not a measured ceiling. One of the four (Overfreight!) is a railway-building tycoon by its own description, and no search of trucking, delivery or airline job games is shown beyond Cabin Crew Simulator (1,373), which already sits above the stated top.
- Lesson 6 ('each of those pairs it with player trading in a dedicated trade area'): wrong for Adopt Me. Its wiki (adoptme.fandom.com/wiki/Trade_System) says a trade starts by clicking any player and choosing Trade, anywhere; the Trading Hub building for cross-server listings was only added on July 31, 2026. The dedicated-area pattern holds for Creatures of Sonaria ('Trading may only take place in the Trade Realm') and Dragon Adventures (Trade Island) only.
- Lesson 7 ('most timely element') and fact 8's 'being proven': Tavern Town and Run a Motel are four to five weeks old with 7-day averages up 115% and 182% in a week, which is launch momentum, not retention. The one comparable with a few months of history, Run a Hotel (July 2026), has dropped from an 8.8K peak to 1,353 and lost half in a week. The data shows current interest in the theme, and equally shows these games fade fast.
- Lesson 8 ('races exist only as random rolls with paid rerolls in hardcore RPGs; no cozy or building game uses them; no game ties a race to crafting, mining or farming'): three universal negatives resting on four wikis. Northwind, in the brief's own table, lets players choose a role (Colonist, Hudson's Bay Company, Native) that changes 'spawn, clothing items, weapons, craftables', alongside nine professions including Mining, Farming and Cooking. The honest claim is 'none found in the games checked'.
- Lesson 9 (Rune Slayer shows the combination of systems does not hold players): one game, cause explicitly not established in the brief, and it is a hardcore PvP RPG. Its collapse says nothing either way about species + taming + crafting in a different genre. The blog cited shows it had already lost most of its players before the July 2025 ban wave, with a weak event update named as a suspect.
- Lesson 10 ('dropped to 558 after updates stopped'): the order of events is not shown. RoTrends' recorded peak for Islands is only 5.2K, so within the tracker's window it was already far below its 2020-21 size; no figure for November 2023 was fetched, so the decline cannot be attributed to the end of updates. The dupe lesson is sound and stronger than stated: the wiki records two separate duplication periods.
- Lesson 11 ('large servers appear only in roleplay, creature sims and PvP survival; builders run 4-12'): contradicted by the brief's own table. Silk Road: Trading Simulator runs 80 per server and Tradelands 50 (trading games); Industrialist and Islands, both builders, run 20. These API caps are also root-place maximums, which for hub games (Northwind shows 1, Starscape 16) are not the playable server size.
- Section (d) 'All show place updates in November 2026' as a shared trait: the API 'updated' field is not a content-update signal. Islands shows updated 2026-01-19 although updates were discontinued in 2023, and RoTrends lists several of the same games as 'updated 2 months ago'.

### What the brief missed
1. Cross-server shared features do exist at the top of the market: Adopt Me's Trading Hub (released July 31, 2026) lets players 'post trade listings and offer on the listings of other players across all servers' (adoptme.fandom.com/wiki/Trading_Hub). That is light shared state (a market), not a linked world, but it shows the realistic middle ground between 'one isolated server' and 'Starscape'.
2. Roblox's data stores, not MemoryStore, are the normal home for persistent world state: 4 MB per key and 500 MB + 1 MB per lifetime user for the game (create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits.md). The brief's platform-limit conclusion should be rebuilt around data store and MemoryStore request rates.
3. Tracker peaks are window-dependent and disagree: RoWatcher shows Starscape's peak as 106 (May 2026) and Rune Slayer's as 405 (March 2026), against RoTrends' 951 and 44.8K. RoTrends peaks for old games (Islands 5.2K, Rogue Lineage 3.1K, Tradelands 558) are clearly not all-time peaks, so the Peak column mixes true records (Grow a Garden, Dead Rails) with partial windows.
4. Maturity ratings: RoTrends lists Dead Rails, Deepwoken, Fallen Survival, Northwind and Rogue Lineage as 13+; the project's criteria require Mild. Several of the brief's strongest precedents are outside that rating.
5. Starscape has had no update since 2026-05-28 (API), which matters when reading its 14-player average.
6. The hospitality newcomers are volatile in both directions (Run a Motel +181.6%, Tavern Town +114.8%, Run a Hotel -49.9% week on week); Tavern Town's session length read 56.6 minutes, close to the 60-minute daily cap the Home ranking counts.
7. Rune Slayer species already vary in hunger needs (Human 'Hunger Efficiency', Half-Golem slow hunger, Vampire 'Bloodthirst'/'Famished'), a second precedent beside Sonaria's diets for species-specific needs.
8. Not verified in this pass: the 7-day averages in the 'also checked' list (99 Nights, War Tycoon, ER:LC, Plane Crazy, Wild Horse Islands and others), the two DevForum threads, the Starscape marketplace date, Arcane Odyssey clan building, Dragon Adventures' twelve worlds, Stepford roles, and the claims that no game has a pay-off raider faction or a player-built line others ride. Blox Fruits (221,546 live, 12-player servers per the API) splits its world into three level-gated Seas per its wiki and is a far larger case of a divided world than Deepwoken or Northwind; I did not confirm from fetched text that each Sea is a separate place.


---

# E. Platform feasibility

## Platform feasibility brief: persistent multi-region world on Roblox (read 2026-11-18)

Source keys are listed at the end. "Staff" = DevForum post by a Roblox_Staff account or the official Roblox account. "Community" = non-staff developers, treat as anecdote.

### 1. Server model

- **Servers are not persistent.** They shut down when empty or on update, and replacements start fresh [ID]. `BindToClose` gets 30 seconds [DM]. Nothing simulates a region nobody is in.
- **Max players per server: 200** for everyone (staff, 2023) [SZ]; 700 was a 2020 beta only [B700]. A March 2026 staff post still calls 200 "the maximum server size"; voice chat works up to 100 [VC]. No 2025-26 increase found.
- **Server resources:** memory 6.25 GiB + 100 MiB x peak players [ID]. CPU scales per connected player, formula undisclosed (Nov 2025) [CPU]. Extended Services for Compute (June 2026) more than doubles per-player CPU: first 100K playtime hours/month free, then $0.001/hour [XC][ES].
- **Server Authority** fully released 2026-07-09: opt-in, requires StreamingEnabled, raises server load; known limits include 64 attributes per instance and 8 animation tracks per Animator [SA].
- **Improved Physics Replication** (eventual consistency) rolled out 2026-05-04, rolled back next day, opt-in again since June [PR1][PR2].

### 2. Cross-server tools

| Tool | Published limits | Source |
|---|---|---|
| MemoryStore | Universe quota **64 KB + 1.2 KB x users** (arithmetic: 184 KB at 100 CCU, about 1.26 MB at 1,000); 1000 + 120 x CCU request units/min; item value 32 KB, key 128 chars; max expiry 45 days; sorted map/queue max 1M items or 100 MB; about 30,000 units/min per partition. Paid overage: $0.10/GB-hour, $0.003/1M requests | [MS][SM][ES] |
| MessagingService | 1 kB message; "typically within 1-2 seconds"; **best effort, not guaranteed**; send 600 + 240 x players/min per server; receive (40 + 80 x servers)/min per topic, (400 + 200 x servers)/min per game | [MSG] |
| DataStore | 4,194,304 chars per key; key name 50 chars; per-key throughput 25 MB/min read, 4 MB/min write; universe budget read 300 + CCU x 40, write 300 + CCU x 20, list 300 + CCU x 2 per minute, **shared with Open Cloud** since 2026-07-29; storage **500 MB + 1 MB x lifetime users** (was 100 MB); overage $0.12/GB-month; GetAsync caches 4 s; ordered stores page size max 100 | [DS][DS26][ES][DSC] |
| Teleport | Server-side `TeleportAsync`, max 50 players per call; teleport data is value types only, **client-visible and unencrypted**; a reserved-server ID can be reused to route everyone to one instance | [TP][TS][TO] |
| Open Cloud | Headless Luau tasks: max 5 minutes, 10 concurrent per place, **no physics, scripts do not auto-run**, can call DataStore APIs, task creation 5/min per key owner. REST for data stores, memory-store queues and sorted maps, and message publish. HttpService: 500 external requests/min per server | [LX][OCS][HS] |

- Typical teleport time: no official figure. Community reports 3-8 s; one developer logged up to 2,000 reserved-server teleports per hour taking over 15 s to start [TT].
- Places per universe: not found. Place file limit is 100 MB [PUB].
- Newer shared-state service: none shipped. Roadmap (2026-09-18) lists **"Compute functions"** (scheduled serverless Luau, Early 2027) and built-in transactions and session locking (Early 2027) [RM].
- Note: the Extended Services page still shows the old 250 base / 100 MB figures [ES]; the limits page and staff post say 300 / 500 MB [DS][DS26].

### 3. Recommended patterns

- Split large worlds into places and teleport; Roblox notes this "imposes additional join times" [DE].
- Carry secure state between places in data stores or memory stores, never teleport data [TP].
- MemoryStore as cache, DataStore as source of truth (staff FAQ) [MSL]. Roblox's own docs name "cross-server trading and auctioning" via a sorted map as a use case [MS].
- Offline progress from saved timestamps on rejoin: community pattern only [OFF]; no staff post found.
- Region-per-place Foxhole-style layouts: no staff guidance found.

### 4. Vehicles

- Characters on moving platforms is engine-supported since 2018 (staff), but momentum is lost on jumps and it fails if the server does not know the platform [MP].
- Ownership is per assembly; server-owned vehicles "may result in jittery physics"; loose parts riding a vehicle should share its owner [NO].
- Community: fast constraint-driven trains still jitter for standing passengers; one developer moved the map instead of the train [DR]. Jailbreak CFrames characters with the train car [JB].
- Replication budget (community, linked from Roblox docs): client receive throttles near 40-50 KB/s, about 0.4-0.9 KB/s per moving assembly, so roughly **40-60 moving assemblies** in view [OPT].
- Crossing servers: only players teleport. Games save the vehicle's type, state and cargo to MemoryStore/DataStore, teleport riders, and rebuild on arrival (community, July 2026) [XP].

### 5. NPCs

- No published cap. Docs: Humanoid has "significant computation cost"; use AnimationController or custom controllers, animate on the client, spawn only near players [IM].
- Pathfinding: max 3,000 studs straight-line, 20,000-node budget [PF].
- Community: 200 R15 Humanoids at 60 FPS on a PC; 1,000-1,500 stripped R6 with client visuals (2019) [NPC]. Hundreds of pets done as events, not replicated parts [OPT].
- SLIM excludes NPC characters today; NPC support is roadmap Early 2027 [SLIM][RM].

### 6. Player builds and phones

- No official part cap. Streaming defaults: min radius 64, target 1024, Opportunistic stream-out recommended [ST].
- Budgets (community, linked from official docs): 500,000 triangles and 500 draw calls in view, under 1.3 GB client memory for 2 GB phones [OPT][DE].
- Low-end Android at quality 1 draws 200 studs today; 500 planned Late 2026 (staff) [RDC].
- Saving builds: 4 MB per key, do not pre-compress [DS]. "In-game creation persistence" is roadmap Early 2027 [RM].

### 7. Policy

- Paid item trading must be gated with `PolicyService.IsPaidItemTradingAllowed` [CS][PRI].
- Paid random items: numeric odds before purchase, every outcome must give a benefit, gate with `ArePaidRandomItemsRestricted` [CS][PRI].
- Off-platform secondary-market sales of virtual content are prohibited for users; developers may not sell on-platform items off-platform [CS].
- Nothing specific to persistent cross-server economies found.

### Verdicts

| Feature | Verdict | Main constraint |
|---|---|---|
| A. Connected region servers | **Reduced form.** One place (or reused reserved-server ID) per region, sharing coarse aggregates updated every few seconds | Empty regions do not run; MemoryStore quota is tiny at low CCU; messaging is 1 kB, best effort; 200-player cap per instance |
| B. Offline base produces, visitable, raidable | **Reduced form.** Production computed from timestamps on load; visits load the owner's save; raids resolve against that save | No server runs for an offline owner; no built-in session locking until 2027 |
| C. Rideable cargo vehicles between regions | **Reduced form.** Real ride inside one server; region crossing is a loading screen with serialise-and-rebuild | Nothing physical crosses servers; standing-passenger jitter; 40-60 moving assemblies |
| D. Dozens of NPCs per base | **Reduced form.** Server-side data agents, client-rendered non-Humanoid rigs near the viewer | Humanoid cost and replication bandwidth |
| E. Cross-server player economy | **Feasible as described** | DataStore must be the ledger; PolicyService gating; real-money trading pressure on scarce goods |
| F. All of it on a low-end phone | **Not feasible as described**; possible only with hard per-plot part caps, streaming and strict budgets | About 1.3 GB memory, 200-stud draw distance |

### Sources

- [MS] create.roblox.com/docs/cloud-services/memory-stores.md; [SM] .../memory-stores/sorted-map.md
- [MSG] create.roblox.com/docs/reference/engine/classes/MessagingService.md
- [DS] create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits.md; [DSC] .../data-stores/versioning-listing-and-caching.md
- [ES] create.roblox.com/docs/cloud-services/extended-services.md
- [TP] create.roblox.com/docs/projects/teleport.md; [TS] .../reference/engine/classes/TeleportService.md; [TO] .../TeleportOptions.md
- [ID] [IM] [DE] create.roblox.com/docs/performance-optimization/identify.md, /improve.md, /design.md
- [ST] create.roblox.com/docs/workspace/streaming.md; [SLIM] .../workspace/streaming/slim.md
- [NO] create.roblox.com/docs/physics/network-ownership.md; [PF] .../characters/pathfinding.md
- [LX] create.roblox.com/docs/cloud/reference/features/luau-execution.md; [OCS] .../cloud/reference/features/storage.md
- [HS] [DM] create.roblox.com/docs/reference/engine/classes/HttpService.md, /DataModel.md
- [PUB] create.roblox.com/docs/production/publishing/publish-games-and-places.md
- [PRI] create.roblox.com/docs/production/monetization/paid-random-items.md; [CS] about.roblox.com/community-standards
- Staff: [SZ] devforum.roblox.com/t/2294621; [B700] /t/722045; [VC] /t/4534031; [CPU] /t/4044040; [XC] /t/4665165; [SA] /t/4727993; [PR1] /t/4618365; [PR2] /t/4675512; [DS26] /t/4739240; [RM] /t/4880208; [RDC] /t/4865880; [MP] /t/183385; [MSL] /t/1475935
- Community: [DR] /t/3672458; [JB] /t/236339; [OPT] /t/3127146; [XP] /t/4753372; [TT] /t/3071966; [NPC] /t/284180; [OFF] /t/3761245

## Researcher's lessons (several are struck or narrowed by the check below)
- Treat each region as a place (or one reused reserved-server ID per region) and share only coarse region aggregates such as stock levels, route status and faction control, refreshed every few seconds. Real-time entity-level influence between regions is not available: messaging is 1 kB and best effort, and MemoryStore is 184 KB total at 100 concurrent players.
- A single true world per region, Foxhole-style, is capped at 200 players per server instance. Above that a region needs several parallel instances, so region state must live in DataStore/MemoryStore and not in any one server's workspace.
- Design every offline system (base production, growing crops, fermenting, region decay, pirate pressure) as a closed-form function of saved timestamps evaluated on load. No server runs for an empty region or an offline owner, and scheduled serverless Luau is only on the roadmap for Early 2027.
- Offline raids are workable only as a raid against the owner's saved base loaded into the raider's server, with the result written back through UpdateAsync. Built-in transactions and session locking are roadmap Early 2027, so duplicate and lost-write protection has to be hand-built until then.
- Keep physical journeys inside one server: a rail line, sea lane or flight that is ridden for real should fit in a single place. Crossing to another region will always be a loading screen (community reports 3-8 s, sometimes 15 s or more), with the vehicle and cargo saved as data and rebuilt on arrival.
- Prototype passengers standing on a moving train or ship before committing to it. Staff-built moving-platform support exists, but 2025 community reports still show jitter at speed, and the two known fixes (CFraming characters with the car, or moving the world instead of the vehicle) both constrain the design. Seated passengers are the safe default.
- Budget about 40-60 simultaneously moving replicated assemblies in a player's view. Trains, ships, cargo, creatures and NPCs all draw from that one budget, so NPCs and tamed creatures should be server-side data with client-rendered, non-Humanoid rigs driven by events.
- Dozens of travellers, staff and creatures per base is achievable only if they are simulated as data and rendered near the viewer; dozens of full Humanoids per base, multiplied by several bases per server, will not hold on phones.
- Player building needs a hard per-plot part or instance cap, a compact save format well under the 4 MB key limit, and pieces made from a small set of reused meshes so draw calls stay near the 500 budget. Unbounded free-form building conflicts directly with the low-end phone target.
- A cross-server market is the one feature Roblox's own docs name as an intended use (sorted map plus DataStore ledger). If any tradable item can be bought with Robux or Robux-bought currency, trading must check IsPaidItemTradingAllowed, and scarce tradable goods will attract off-platform selling that the Community Standards prohibit.
- Low-end phones see 200 studs at quality level 1 today, so anything meant to be seen at distance (an approaching train, a ship on the horizon, a distant volcano) needs a cheap far representation or will not be visible on those devices until the planned 500-stud minimum ships.
- Check storage and compute cost early: MemoryStore above quota is paid ($0.10 per GB-hour) and Extended Services needs an ID-verified 18+ account in a supported country. Plan the shared-state footprint to fit the free quota at launch-level CCU.

## Not found
- Official limit on the number of places per universe: no figure in the creator docs or a staff post (only community claims of 'no limit').
- Official typical or median teleport time between places: none published; only community reports (3-8 s typical, 15 s or more for some reserved-server teleports).
- Any 2025-2026 increase to the 200-player server cap, or a creator docs page that states the current cap (the 200 figure rests on a 2023 staff post and a March 2026 staff reference).
- Staff-authored guidance on region-per-place persistent world layouts or on a timestamp 'world clock' for offline progress: only community threads describe these.
- A published per-server limit for Humanoid NPCs, parts, instances or moving assemblies: none exists; available figures are community anecdotes from 2018-2024.
- Official guidance on trains, ships or aircraft with standing passengers beyond the 2018 moving-platforms post and the network ownership page; nothing found on Server Authority behaviour for large passenger vehicles.
- Roblox's exact CPU allocation formula per server (staff state it is intentionally not shared).
- Any policy text specific to persistent cross-server economies, or current per-country lists for paid item trading restrictions (only the PolicyService flags are documented).
- Open Cloud REST endpoints for MemoryStore hash maps (only queues, sorted maps and flush are listed in the storage reference read).
- Documentation or a release date more specific than 'Early 2027' for Compute functions, in-game creation persistence and player data transactions.

## Independent check

12 of 14 key facts confirmed.

### Facts corrected
- **partly wrong:** 9. Characters on moving platforms engine-supported since 2018, momentum not conserved on jumps; ownership per assembly, server-owned vehicles "may result in jittery physics"; 2025 community reports of jitter on fast constraint-driven trains; Jailbreak CFrames characters; one developer moved the map.
  - Correction: Substance is right but the evidence is thinner and older than the wording suggests. (a) "Community reports in 2025" is one thread by one developer using a PrismaticConstraint train; a reply suggested the cause was network-ownership fighting and that SetNetworkOwner(nil) might fix it, which was never tested. The move-the-map fix only works when every player is on the train. (b) The Jailbreak detail is from February 2019 (its developer confirmed CFraming the character with the train; staff said the system predates the engine feature). (c) The doc quote is about any object set to server ownership ("may result in jittery physics interactions for clients"), not vehicles specifically. (d) The momentum statement is a 2018 staff reply; nothing read in this run shows whether it still holds under 2026 Server Authority or the new physics replication.
- **partly wrong:** 13. Streaming defaults min radius 64, target 1024, Opportunistic recommended; low-end Android at quality level 1 has a 200-stud draw distance today, 500 planned for Late 2026; place files limited to 100 MB.
  - Correction: The draw-distance part is out of date. The 500-stud minimum was announced as "introducing today" on 2026-11-05, on all platforms, rolling out automatically. New draw distances by internal quality level: 1 = 500, 2 = 800, 3 = 1200, 4 = 1600 studs (previously 200, 250, 300, 450). The design doc (last updated 2026-11-18) now says "even at the lowest quality level, the draw distance is at least 500 studs" and warns not to design around exact distances. The brief's source (RDC post, 2026-09-11) was correct when written. Streaming defaults and the 100 MB place limit are confirmed; the default StreamOutBehavior is LowMemory, with Opportunistic recommended.

### Conclusions that go beyond the evidence
- Lesson 11 (and verdict F's '200-stud draw distance') rests on an outdated fact. The 500-stud minimum shipped on 2026-11-05 (devforum.roblox.com/raw/4977292/1), with 800/1200/1600 studs at the next three quality levels. A cheap far representation is still needed for a horizon ship or distant volcano, but the reason is now the 500-stud floor plus the 1024-stud default streaming target radius, not a 200-stud limit.
- Lesson 5's teleport timings are not supported by the cited source. '3-8 s' appears nowhere in thread 3071966. The '15 s or more' figure is a July 2024 bug report about reserved-server teleports; Roblox staff replied on 2026-04-02 that reserved-server joins were improved and closed the bug as addressed on 2026-04-09. There is no current measured teleport time in the evidence; it should be measured, not quoted.
- Lesson 1 says real-time entity-level influence between regions 'is not available'. The evidence shows it is constrained (1 kB messages, best effort, 1-2 s, rate limits of 600 + 240 x players per minute per server), not unavailable. It also treats 184 KB as a fixed ceiling, when the quota tracks an eight-day peak of users and paid overage costs cents per month for megabytes.
- Lesson 12 overstates the cost risk. At $0.10 per GB-hour, megabytes of extra MemoryStore cost under a dollar a month, the minimum budget is $0.50, and for a group-owned game only the group owner needs to be ID-verified 18+. The real constraint is eligibility (ID, age, country), not price.
- Lesson 3 ('design every offline system as a closed-form function of saved timestamps') is stronger than the evidence. The brief itself says this is a community pattern with no staff source, and it lists working alternatives that exist today: Open Cloud Luau tasks (5 minutes, 10 concurrent) triggered by an external scheduler, external writes through Open Cloud data store, memory store and messaging APIs, and any live server ticking shared state. Systems that depend on other players' actions (pirate pressure, region decay under contest) cannot be closed-form.
- Lesson 4 says offline raids are workable 'only' as a raid on the saved base loaded into the raider's server. No source in the brief covers offline raids at all (section 7 and section 3 report nothing found). It is a reasonable design, not a finding. 'Has to be hand-built' also skips that single-key UpdateAsync is atomic today; the docs only say writes are not atomic across keys.
- Lesson 6 leans on one 2025 thread by one developer, a 2019 Jailbreak thread, and a 2018 staff post. A reply in the 2025 thread attributed the jitter to network-ownership fighting, untested. 'Two known fixes' and 'seated passengers are the safe default' are not established: no cited source tests seats, and nothing tests standing passengers under 2026 Server Authority or the new physics replication. The advice to prototype first is the part the evidence supports.
- Lesson 7 turns one developer's mid-2024 'napkin math', which he calls his opinion and subject to change, into a budget of 40-60 moving assemblies 'in a player's view'. The guide gives a client receive-bandwidth figure, not a per-view count, and it predates 2026 replication changes. Use it as a starting assumption to measure, not a limit.
- Lesson 8 states dozens of Humanoids per base 'will not hold on phones'. The only evidence is the docs' unquantified 'significant computation cost' and PC-based community anecdotes from 2019. No phone measurement exists in the brief. Likely true, but unproven.
- Lesson 9 treats 500 draw calls as the budget. That is the same community opinion; Roblox's own doc gives 1,000 draw calls and 1,000,000 triangles as an illustrative baseline-device limit and says to derive the number by testing on your own baseline device.
- Lesson 10 and verdict E ('feasible as described') conflict with the brief's own quota math. A sorted map lives on a single partition (throttling from roughly 30,000 request units per minute) and the whole universe has 184 KB of MemoryStore at 100 concurrent users, so a market with more than a few hundred listings does not fit the free quota at launch scale and must run from DataStore (write budget 300 + 20 x CCU per minute) or pay overage. 'Scarce tradable goods will attract off-platform selling' is a prediction with no evidence cited.
- Lesson 2 treats 200 players as the working size of a region. The staff post that set 200 warns of performance issues at that size and voice chat only works up to 100. Nothing in the evidence shows a building, vehicle and NPC game holding 200 players on phones; the practical per-instance figure is unknown and probably much lower.

### What the brief missed
1. Draw distance already changed: 500-stud minimum live since 2026-11-05 (https://devforum.roblox.com/raw/4977292/1).

2. Teleport testing in Studio shipped the same week (Weekly Recap Nov 2-6, 2026, https://devforum.roblox.com/raw/4979364/1: "You can now test TeleportAsync in Studio's Test and Team Test modes without publishing"). The roadmap had it for Early 2027. Multi-place prototypes are now cheap to test, and Studio MCP now has Open Cloud access.

3. SLIM does not work on models modified at runtime or on animated models (https://create.roblox.com/docs/workspace/streaming/slim.md). Player-built bases and moving trains or ships therefore cannot rely on SLIM for their far representation; that would have to be custom.

4. MemoryStore memory quota has an eight-day traceback before it shrinks, so it follows recent peak users. Sorted maps and queues each sit on one partition (about 30,000 request units per minute); hash maps spread across partitions and are the documented choice when ordering is not needed.

5. The low-population problem is the opposite of the 200 cap and is not addressed. Request and memory quotas scale with CCU, so a new game gets the base only (300 data store requests per minute per type, 64 KB of MemoryStore). Splitting a small launch audience across region places leaves each region nearly empty, which works against the co-play signal and criterion 6 in docs/research/01-research.md, and any teleport before the fun starts works against the under-60-second bounce signal (criterion 2).

6. Other roadmap items relevant to this design (https://devforum.roblox.com/raw/4880208/1): Developer push notifications "for asynchronous gameplay" (Late 2026), Instance Streaming adaptive radius and path pre-fetching (Late 2026), Queue service (Early 2027), In-game creation persistence (Early 2027), Offline play (Mid 2027).

7. Not found in this run: any limit on places per universe; any official teleport duration; what happens when a reused reserved-server ID's server is full or closed.

Scratch downloads are in (session scratchpad) and (session scratchpad) Nothing was written to the project folder.


---

# F. How the four original inspirations have done on Roblox

From the first research pass on 2026-11-18 (one researcher, not independently re-checked).

Only tower defense is already a large Roblox genre. The other three inspirations have no real equivalent on the platform: I found no RimWorld-like, no Foxhole-like, and only three tiny Rounds-likes.

**Where each stands (snapshot 2026-11-18)**

| Inspiration | Closest Roblox games | Size now | Main lesson |
|---|---|---|---|
| Bloons TD6 | Anime Adventures, Anime Crusaders X, Toilet TD, Cameraman TD, Tower Defense Simulator | About 170K CCU across the ten biggest | Proven and lucrative, but gacha-and-IP driven and decays to 2–10% of peak |
| RimWorld | 99 Nights in the Forest, Mini War, Raise an Ant Colony, God Simulator | 92.8K for 99 Nights; 4.5K–7K for the new colony-style games | Best fit for offline progress and systemic content; worst fit for a fast first minute |
| Foxhole | Voxel Wars, RoWorld, Command An Army, War Tycoon, Empire Clash | 14.4K for Voxel Wars; 238 for the one faction-and-roles game | Highest risk: nobody has shipped persistence plus logistics, and it leans on chat |
| Rounds | Card Chaos, Fortune Fighters, WildCard | 83, 21 and 0 CCU | Best first minute and cheapest content; existing attempts are PC-first and need a friend |

**Patterns across the four**

- **2026 has rewarded commanding many small units.** Mini War peaked at 126K, Command An Army at 84K and RoWorld at 36K. All fell to 4–20% of peak within one to five months.
- **Depth buys long sessions but not reach.** Industrialist (38-minute sessions, about 2K CCU) and Fallen Survival (46 minutes, about 1.2K) are the clearest cases.
- **The gaps are real but unproven.** An empty niche could mean opportunity or poor fit; the adjacent games are the only evidence either way.

**What looks under-served**

- Tower defense on original IP where players or systems generate the maps, and competitive tower defense.
- A colony game with an event director and colonists that have traits and moods.
- Card drafting on loss, layered onto a format Roblox already plays, built for phones with bots filling empty servers.
- A shared cross-server war fed by small servers or personal bases. This is the riskiest of the four.

My own hypothesis, not a finding: these combine naturally into one design, a small co-op base run by autonomous workers, defended against paced raids, with a card draft after each loss.

**How far to trust the numbers**

- **Live counts, visits, ratings and dates** come from Roblox's own public endpoints. It is a single weekday reading, so weekend numbers will be higher.
- **Peaks** come from RoTrends and RoWatcher. RoWatcher's "all-time peak" appears to cover only its own tracking window, so where the two differ I give both.
- **Session lengths and earning ranks** are RoTrends estimates.
- **Not readable:** Rolimons returned no data or a 404, and RoMonitor returned only a page title. statroblox and endgametools were not tried.
- **Single-source claims:** the ASTDX collapse (340,060 to 350) and the licensing reason for Anime Adventures going offline. A November 2026 Twinfinite search snippet said Anime Adventures was still private, which the live Roblox listing (57K playing) contradicts.
- **"Not found" means not found by about 60 keyword searches of Roblox's search endpoint plus web and DevForum searches.** It does not prove a game does not exist.

No project files were edited. Two throwaway query scripts are in the session scratchpad:
- (session scratchpad)
- (session scratchpad)

## Tower defense (Bloons TD6)

| Game | Players now | Peak or visits | Note |
|---|---|---|---|
| Anime Adventures | 57,456 | Peak 184.7K (RoTrends); 141K in Nov 2026 (RoWatcher). 2.64B visits. | Anime gacha TD, created Dec 2021, rated Mild. Average session 23.7 min; top-earning rank #5. Was offline for more than 18 months over licensing problems (allthings.how, single source) and is live again. |
| Anime Crusaders X | 40,208 | Peak 42K in Nov 2026 (RoWatcher). 122.4M visits. | Anime gacha TD titled "[RELEASE]", so it is at launch peak now. 98% likes. RoTrends page showed no usable data. |
| Toilet Tower Defense | 16,805 | Peak 443.4K (RoTrends). 6.23B visits. | Meme-themed gacha TD with trading, created Jun 2023. Now about 4% of peak. 86% likes; session 15.3 min; top-earning rank #27. |
| Cameraman Tower Defense | 15,017 | Peak 151.6K (RoTrends); 133K in Nov 2026 (RoWatcher). 146.5M visits. | Created 2026-08-26, so a new TD can still break out. Already about 10% of peak. 98% likes; session 14.7 min; top-earning rank #23; averaged 16K in Oct 2026 at rank #65 (Bloxodes). |
| Tower Defense Simulator | 13,994 | Peak 160.7K (RoTrends); 104K in Sep 2026 (RoWatcher). 5.09B visits. | Original-IP zombie TD from 2019, the longest-lived non-anime TD. Session 15.8 min; top-earning rank #20; 94% likes. |
| Vanguards: Trail of the Saint (Anime Vanguards) | 12,965 | Peak 338.3K (RoTrends). 2.11B visits. | Session 53.5 min (99th percentile). Top-earning rank #95. Now about 4% of peak. |
| Garden Tower Defense | 3,527 | Peak 196.3K (RoTrends); 66K in Aug 2025 (RoWatcher). 833M visits. | Created May 2025 with a garden theme and Saturday updates. Now about 2% of peak. 98% likes; session 14.0 min. |
| All Star Tower Defense, and its sequel ASTDX | 1,667 (original); sequel live count not found | Original: 7.97B visits. Sequel: 340,060 CCU on launch day, 350 CCU by Mar 2026 (RoWatcher article, single source). | The sequel lost its players back to the original. The original was at 22,857 CCU around Mar 2026 per the same article and is at 1.7K now. |
| Build a Tower Defense | 2,190 | 1.45M visits. Peak not found. | Created 2026-10-03. The only TD found where the player designs the path and places the enemy spawners. |
| TrenchLine: Tower Defense | 169 | 2.5M visits. Peak not found. | The only TD found with ranked 1v1/2v2 PvP and a draft mode ("draft a new troop every few waves"). It has almost no players. |

### What works
Tower defense is the only one of the four inspirations that is already a large Roblox genre. The ten biggest TD listings summed to about 170K concurrent players at the snapshot (my sum of Roblox API figures).

- **Formula:** co-op lobbies, gacha unit summoning, evolutions and traits, unit trading, and weekly Saturday updates. Game descriptions and the RoWatcher genre article both describe it this way.
- **Sessions:** 14 to 53 minutes, which is the 92nd to 99th percentile on RoTrends.
- **Money:** top-earning ranks of #5, #20, #23 and #27 for the leaders.
- **Theme-riding:** toilet/cameraman memes, anime, and the garden trend each produced a hit.
- **New entrants:** Cameraman Tower Defense launched 2026-08-26 and peaked above 130K.

### What fails
- **Fast decay:** Toilet TD is at about 4% of peak, Garden TD about 2%, and Cameraman TD about 10% within roughly a month of its peak.
- **Sequels and migrations:** ASTDX fell from 340K on launch day to 350 (single source).
- **Borrowed IP:** Anime Adventures was offline for more than 18 months over licensing, and its fan remake was removed by a DMCA claim (allthings.how).
- **Reskins:** the search returned dozens of TD listings under 1K CCU.
- **Small share of the top charts:** Roblox's "Strategy" genre was 1.8% of top-100 play in Oct 2026, with 4 games in the top 100 (Bloxodes).
- **PvP TD:** the one ranked/draft TD found has 169 CCU.

### Fit with our constraints
- **First 60 seconds:** weak by default. The standard flow is lobby, step on a platform, wait for a match, then a slow wave 1. This is my reading of the game descriptions; no bounce data was found. It needs an instant solo wave on spawn.
- **Mobile:** good. Tap-to-place works, and every leader is on phones.
- **Text chat:** not needed.
- **Rating:** easy. Nearly all TD listings are rated Minimal; Anime Adventures is Mild.
- **Daily return:** strong. Banners, daily quests, trading and Saturday updates are the genre norm.
- **Week 3:** strong while updates continue, but the decay figures show it is content-hungry.
- **Systemic content:** mixed. Units × traits × evolutions is combinatorial, but the leaders depend on a stream of hand-made unit models and maps, mostly borrowed IP. That conflicts with the research doc's criteria 8, 9 and 12.

### Open space
- **Player-authored or procedural TD.** Only Build a Tower Defense (2.2K CCU, six weeks old) lets players design the path.
- **Competitive TD.** A search for "pvp tower defense" returned only PvE games.
- **TD on a persistent owned base that fights while you are offline.** Build a base RNG does this and has 68.9M visits but 391 CCU now.
- **Original-IP TD.** Tower Defense Simulator is the only large one.
- **Bloons-style TD.** Nothing found beyond Ball Tower Defense at 406 CCU.

## Colony sim and base management (RimWorld)

| Game | Players now | Peak or visits | Note |
|---|---|---|---|
| 99 Nights in the Forest | 92,770 | Peak 14.1M (RoTrends). 30.6B visits. | Co-op "build a camp and survive the nights". You control your own avatar, not colonists. Global rank #7; session 18.5 min; rated Minimal. The nearest proven large game. |
| Mini War | 5,548 | Peak 126.3K on 2026-06-13 (RoTrends, RoWatcher). 373.7M visits. | Build a city and economy, train an army, capture other players' land. Session 29.0 min (98th percentile); top-earning rank #77; 96% likes. Monthly average fell from 49.3K in June to 10.6K in October (Bloxodes). |
| Raise an Ant Colony | 7,273 | At its all-time high of about 7K (RoWatcher). 1.24M visits. | Created 2026-10-19. Queen lays eggs, workers gather, you dig a nest and declare war on rival colonies. 85% likes; rated Mild. No session data yet. |
| God Simulator | 4,496 | Peak 9.4K in Nov 2026 (RoTrends). 4.0M visits. | Created 2026-10-09. Villagers build a town on their own while you help them or throw disasters. Session 19.2 min; 86% likes. The closest thing found to autonomous colonists. |
| Build and Survive | 5,244 | Peak 34.1K (RoTrends); 31K in Feb 2026 (RoWatcher). 276M visits. | Build a base and survive monster waves, up to 6 players, autosaves. 97% likes; session 16.8 min; 9.6M favorites. |
| Industrialist | 1,887 | Peak 9.8K (RoTrends); 10K in Nov 2025 (RoWatcher). 75M visits. | Factory builder from 2022. Session 37.9 min (98th percentile). Its own description warns of a "steep learning curve". Deep and sticky, but small. |
| Build and Conquer | 863 | 8.5M visits. Peak not found. | Created 2026-08-23. Manages workers, population, happiness, power and research, then war. The closest management depth found, at under 1K CCU. |
| Booga Booga and The Survival Game | 765 and 380 | 271M and 336M visits. Peaks not found. | Open-world tribe and kingdom survival games that were once large and are now under 1K. |

### What works
No RimWorld-like was found. Searches for rimworld, colony, colony survival, settlement, villagers, manage workers, npc workers, frostpunk and dwarf fortress returned no game with indirectly controlled colonists, needs or moods, and an event director. What works is nearby:

- **Co-op survive-the-night camp building.** 99 Nights in the Forest is global rank #7.
- **Build an economy, then fight with it.** Mini War peaked at 126K with 29-minute sessions.
- **Small autonomous creatures you grow.** Raise an Ant Colony and God Simulator both launched in October 2026 and sit at 4.5K to 7K.
- **Long sessions.** 17 to 38 minutes across these games.

### What fails
- **Complexity:** Industrialist has 38-minute sessions but about 2K CCU. Build and Conquer has the most management systems and 863 CCU.
- **Old open-world tribal survival faded:** Booga Booga and The Survival Game are under 1K.
- **Economy-and-war games decay fast:** Mini War is at 4% of its peak five months later.
- **Lower approval:** the two new colony-style games sit at 85 to 86% likes, against 94 to 98% for simple tycoons and TD. This is a snapshot, not a trend.

### Fit with our constraints
- **First 60 seconds:** the hardest of the four. Colony sims start slowly, so the opening needs a direct avatar action with an instant result before any management appears.
- **Mobile:** tap-to-assign suits touch; dense priority menus do not.
- **Text chat:** not needed.
- **Rating:** achievable if raids and breakdowns stay cartoonish. Every example here is Minimal or Mild.
- **Daily return:** the best natural fit of the four. Colonists working while you are offline matches the offline-progress hook in the research doc.
- **Week 3:** good. An event director produces new stories without new assets.
- **Systemic content:** the best fit of the four. Traits × events × biomes is pure systems work.

### Open space
- **A storyteller.** No game found has an event director that paces raids and disasters.
- **Colonists with traits and moods** that the player grows attached to.
- **A verb-plus-noun framing of a colony game.** Raise an Ant Colony is testing this right now at small scale and is worth re-checking in three to four weeks.

The gap may also mean the genre needs heavy simplification to work on phones. Nothing here proves demand for a full RimWorld.

## Persistent faction war with player-run logistics (Foxhole)

| Game | Players now | Peak or visits | Note |
|---|---|---|---|
| Voxel Wars | 14,430 | 12.8M visits. Peak not found. | Created 2026-10-28. 15v15 destructible battles with vehicles and buildable turrets. Round-based with a map vote, not persistent. 80% likes; rated Mild. |
| RoWorld [World PvP] | 7,767 | Peak 36K in Oct 2026 (RoTrends, RoWatcher). 138M visits. | Created 2026-09-26. A port of OpenFront: real-time territory conquest with up to 55 players per server and alliances. Session only 5.3 min; 83% likes. |
| Command An Army | 4,942 | Peak 84.3K in Oct 2026 (RoTrends, RoWatcher). 97.3M visits. | Created 2026-06-02. Recruit troops, capture points, order formations, team against team. Session 21.8 min; 95% likes. About 6% of peak one month later. |
| War Tycoon | 4,565 | Peak 43.8K (RoTrends); 40K in Mar 2025 (RoWatcher). 1.15B visits. | From 2020. Build a base tycoon, then fight with vehicles. Top-earning rank #74; session 21.0 min. The durable form of the war theme. |
| Conquer The World WW2 | 3,826 | Peak 30.8K (RoTrends). 329.7M visits. | Grand strategy in 14-player matches. Session 19.9 min; 81% likes. |
| ENTRENCHED | 2,657 | Peak 11K (RoTrends); 9K in Dec 2025 (RoWatcher). 329.6M visits. | From 2019. WW1 class shooter with 40 players and frontline modes. Session 14.2 min. Steady but small. |
| Fallen Survival and Fust Survival | 1,251 and 1,549 | Fallen: peak 7.3K (RoTrends), 51M visits. Fust: 6.7M visits, created 2026-10-03, peak not found. | Rust-style gather, build and raid on 100-player servers with a weekly Friday wipe. The closest thing to persistent player-versus-player bases. Fallen has 46.4-minute sessions (99th percentile) and is rated Moderate. |
| Empire Clash | 238 | Peak 6.7K (RoTrends). 55.3M visits. | Four factions fighting for a continent, 13 classes from blacksmith to monarch. The closest match to Foxhole's faction-plus-roles idea, and nearly empty. Session 29.8 min. |

### What works
No Foxhole-like was found. Searches for foxhole, persistent war, logistics, supply lines war and faction war returned round-based shooters, tycoons and map-conquest games. What works with the theme:

- **Commanding armies rather than being one soldier.** Mini War peaked at 126K, Command An Army at 84K and RoWorld at 36K, all in 2026.
- **Tycoon wrappers.** War Tycoon has 1.15B visits and top-earning rank #74.
- **Round-based large battles.** Voxel Wars reached 14K CCU in three weeks.
- **Sessions** of 14 to 46 minutes for those who stay.

### What fails
- **Nobody has shipped persistence plus logistics.** DevForum has a 2020 thread asking whether it could work, a 2023 "Foxhole Inspired Game" thread (3,163 views, 2 posts) worried about servers, and a 2025 devlog for "The Long War". No live game by that name was found.
- **Factions with roles:** Empire Clash has 238 CCU.
- **Weekly-wipe raiding** stays at 1K to 2K and drifts to a Moderate rating.
- **Spikes decay fast:** Command An Army is at about 6% of peak after a month; Mini War at 4% after five months.
- **Round-based conquest has short sessions:** RoWorld averages 5.3 minutes.
- **Scale:** the largest per-server caps seen were 700 (Rise of Nations), 200 and 100; most games use 30 to 80. A single shared war world would have to live in cross-server data, which is what the DevForum reply recommended.

### Fit with our constraints
- **First 60 seconds:** poor as Foxhole is designed, because the logistics payoff takes hours. It needs an instant personal action, such as delivering one crate and seeing the front move.
- **Mobile:** risky. Both DevForum designers defaulted to PC-only. Top-down driving and hauling is feasible on touch; twitch shooting is not the goal anyway.
- **Text chat:** the biggest conflict. Foxhole depends on player coordination, so this needs pings, auto-assigned jobs and visible supply requests.
- **Rating:** realistic war drifts to Moderate (Blackhawk Rescue Mission 5, Fallen Survival, Guts & Blackpowder). Voxel or toy styling stays Mild or Minimal (Voxel Wars, Mini War).
- **Daily return:** strong in theory. A front that moved while you were away is a reason to check in.
- **Week 3:** war resets work as seasons.
- **Systemic content:** strong. The content is player-generated.

### Open space
- **An asynchronous shared war.** Each small server or personal base feeds supply into one cross-server front. Nothing like it was found.
- **A logistics job that is fun alone and needs no chat.**
- **Toy-scale styling** to hold a Mild rating.

This is the highest-risk direction of the four. There is no evidence of demand for hauling as play, and the nearest role-based game is nearly empty.

## Card-pick and build-drafting PvP (Rounds)

| Game | Players now | Peak or visits | Note |
|---|---|---|---|
| Card Chaos | 83 | Peak 2.7K (RoTrends); 370 in Jun 2026 (RoWatcher's window). 16.15M visits. | Created 2025-05-06 by a solo developer. A 2.5D shooter "strongly based on Modded ROUNDS and Stick Fight" with 75+ stackable cards and 5 players per server. Session 21.1 min (92nd percentile); 82% likes. Its page says mobile support is a work in progress. |
| Fortune Fighters | 21 | Peak 2.8K (RoTrends); 786 in Sep 2026 (RoWatcher's window). 39.08M visits. | Created 2024-02-02. Melee duels where you "draw and stack cards every round you lose", with tap buttons for mobile. 95.6% likes but 4.7-minute sessions. Top-grossing rank #362 in Jul–Aug 2024. |
| WildCard | 0 | 592,695 visits. Peak not found. | Created 2026-01-23, last updated 2026-06-08. FPS/top-down shooter with 80+ cards, "inspired by ROUNDS and Card Chaos". Lists keyboard controls only. Dead. |
| RIVALS (reference: duels without cards) | 107,939 | 19.37B visits. Peak not fetched. | 1v1-to-5v5 duel shooter from 2024. Shows the duel format itself is top-tier on Roblox. Rated Mild. |
| Murderers VS Sheriffs DUELS (reference) | 56,015 | 2.11B visits. Peak not fetched. | Short-round duels, created Feb 2025. Rated Mild. |
| Survive Your Ideas | 33,183 | 128.6M visits. Peak not fetched. | Created 2026-10-06. Each round one player types a word that comes to life, and the words stack up. This is escalating stacked modifiers in a party-survival format, but it relies on typed input. |
| Towers of Fortune | 6,478 | 5.16M visits. Peak not fetched. | Created 2026-10-25. Everyone gets a random item every few seconds; last one standing wins. Random-power PvP reached 6K in three weeks. |
| Ability Arena | 5,035 | 126.4M visits. Peak not fetched. | Created 2026-05-27. Pick an ability moveset and unlock more by landing hits. It is build choice before the fight, not a draft during it. |
| Breach the Bastion, and Undercroft | 1,466 and 676 | 2.24M and 0.50M visits. Peaks not fetched. | Co-op Slay the Spire-style deckbuilders created Sep and Oct 2026. Card roguelikes are being tried as PvE and are small so far. |

### What works
- **The duel container is proven.** RIVALS has 108K CCU and Murderers VS Sheriffs DUELS has 56K, with short rounds, ranked play and cosmetics, all rated Mild.
- **Escalating random powers work in party formats.** Survive Your Ideas has 33K CCU and Towers of Fortune 6.5K, both launched in October 2026.
- **The Rounds loop holds the players it gets.** Card Chaos has 21-minute sessions at the 92nd percentile.

### What fails
All three direct Rounds-likes are tiny. None passed a 3K peak, and they sit at 0 to about 100 CCU. The likely reasons below are my reading of their own pages; no post-mortem was found.

- **PC-first controls.** Card Chaos calls mobile a work in progress, and WildCard lists keyboard keys only.
- **Needs a friend.** Card Chaos and WildCard say they are best or designed to be played with friends, and Card Chaos has 5-player servers. At low population a new player lands in an empty server.
- **Unfamiliar camera.** A side-view 2.5D shooter is not a Roblox norm.
- **Little to come back for.** Fortune Fighters has 96% likes but 4.7-minute sessions.

### Fit with our constraints
- **First 60 seconds:** the best of the four. You fight immediately and a card pick is one tap. It needs bots so nobody waits in an empty server.
- **Mobile:** fine with melee or auto-aim. Fortune Fighters already ships tap buttons. Precision 2.5D shooting is the weak spot.
- **Text chat:** not needed.
- **Rating:** every example is Mild or Minimal.
- **Daily return:** weak by default, since a match leaves nothing behind. It needs a collection, ranked seasons or a daily card pool.
- **Week 3:** new cards are cheap to add and combine with every existing card.
- **Systemic content:** very strong. Cards × cards is pure combinatorics and pure code, with almost no art.

### Open space
- **Loser-drafts-a-card as a layer on a format Roblox already plays**, such as arena brawls, duels, wave survival or TD, instead of a 2.5D shooter.
- **Mobile-first, with bot backfill.**
- **Something persistent between matches.**

No card-draft PvP game is above about 110 CCU, so the mechanic is unoccupied. The existing attempts show the mechanic alone has not been enough.
