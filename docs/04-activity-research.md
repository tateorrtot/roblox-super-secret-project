# Activity Research, November 2026

Compiled 2026-11-18. Three researchers each wrote a brief from live sources, and a second agent independently re-checked each brief's key facts and conclusions.

**How to read this.** These briefs were commissioned when Claude wrongly took "a fishing tycoon" to be the core of the game. The user rejected that: fishing, factories and sea trade are single activities among many, and the game's core is a rule (real objects, and processes that turn them into other things; see `CLAUDE.md`). Use this file as reference on how individual activities have been built and how they fared, not as a direction. Read each brief together with its "Independent check": the checkers struck many of the researchers' conclusions.

All player counts are from one Wednesday; weekend numbers run higher.

## Summary of what held up

### Fishing
- Fishing is large and standardised. Fisch (2024) averages about 62K players and Fish It! about 65K, each with around 5B visits.
- Both leaders have themed regions and sailed boats, rods, bait, enchanting, mutations and rarity tiers. A game built on those alone would read as another of the same.
- Neither has a cargo hold, prices that depend on where you sell, multi-step processing, or hired crew. Fisch items stack infinitely and sell to any merchant for the same price.
- Both sell a "Sell Anywhere" pass (315-399 Robux), so the trip to the seller is friction they charge to remove.
- Both have fallen a long way from their peaks. Fish It! averaged 987K in December 2025 and about 65K now, with no source explaining the fall. Fisch's worst period followed a "Second Sea" that was a separate, level-gated place with its own currency and rods; it was later removed.
- Fisch has pirate factions with a reputation ladder at a Minimal rating.
- Roblox's badge counts give real funnels: about half of Fisch's joiners and 63% of Fish It!'s ever sell a fish.

### Factories, automation and hired workers
- Automation has drawn five-figure peaks as a late game (Islands 102K, Factory Simulator 21K) and none of those games kept that level. Islands did stay above 10K for 28 months.
- Few players reach any deep milestone: 4.3% of Miner's Haven players who placed an item ever rebirthed. Those who do stay a long time.
- Games with physically moving items cap them. Miner's Haven starts at 50 ores per player; Islands now allows about 80 dropped items per machine with a two-minute despawn. Industrialist, the one automation game that grew in its third and fourth years, moves no physical items at all.
- No game in the style of Minecraft's Create mod was found on Roblox, and no fish cannery or seafood tycoon has a lasting audience.
- Hire-staff tycoons with a long record (Restaurant Tycoon 2, Retail Tycoon 2) sit at around 800-1,100 players; old free-form builders (Industrialist, Lumber Tycoon 2) at around 2,100.
- Free-form builders have the longest sessions (Miner's Haven and Factory Simulator about 49 minutes).
- DigCrew (October 2026) hauls ore to a railyard, processes it in steps and hires drivers with drawn routes, on phones, and averages about 4K players.

### Sea trade, boats and prices
- Buying or catching in one place to sell in another as the main loop has no large precedent. The games built on it are small or new and fading (Ship The Cargo peaked at 6.6K in October 2026 and fell within six weeks).
- Goods as physical things you load into a vehicle and drive back to sell does work at scale: Storage Hunters: Open World (June 2026) averages about 10K, and Dead Rails pays out at a trading post every 10 km of the journey.
- Arcane Odyssey is the closest single precedent: fishing, physical cargo priced by distance, hired deckhands, ship upgrades by part. It is keyboard-and-mouse only, sits around 450 players, and spikes on updates (24K in December 2025).
- A paid-off or befriended hostile faction already exists: Deepwoken has per-faction reputation from Villain to Hero, attack-on-sight enemies and bribe NPCs. Doing it with pirates would not be new in kind.
- A shared price table for a handful of ports is well inside Roblox's published limits at a few hundred players. Memory stores are not durable and had a partial one-hour outage on 2026-11-17, so servers need a last-known price and a data store snapshot.
- Starscape's player-to-player market was shut down over bots and duplication.
- The biggest boat-using games seat their players. Walking on a moving deck exists in other games (Build A Boat, Pilfering Pirates) and has not been tested on phones here.

---

# A. Fishing games

## Roblox fishing games: what already exists (read 2026-11-18)

The verb "fish" is saturated and its systems are standardised. The idea's specific combination (regional price gaps, fish as physical cargo, a sailed haul, hired crew, multi-step processing) was not found in any fishing game. Each piece exists somewhere, mostly in small games.

Source keys are listed at the end. Monthly averages are my own calculation from 6-hourly samples embedded in archived Rolimons pages.

### Fisch and Fish It! headline numbers

| | Fisch | Fish It! |
|---|---|---|
| Creator | WoozyNate; group Fisching [E][A] | Group Fish Atelier [A]; "Wildes" per wiki infobox [F] |
| Created / released | 2024-03-13 / 2024-10-05 [A][E] | Created 2024-10-21 [A]; first tracked players 2024-12-27 [B] |
| Live players | 47,648 [A] | 59,286 [A] |
| 7-day / 30-day average | 61,724 / 70,204 [C] | 64,799 / 67,077 [C] |
| All-time peak | 1,273,618 on 2025-10-18 [B] | 2,716,766 on 2025-12-07 [B] |
| Visits | 5.15B [A] | 4.83B [A] |
| Like ratio | 90.8% [A] | 82.8% [A] |
| Average session | 28.6 min [D] | 82.7 min [D] |
| Maturity | Minimal [G] | Minimal [G] |
| Top Earning rank | #13 [C] | #99 [C] |

**Monthly average players (thousands) [B]**

| | Nov 24 | Dec | Mar 25 | Apr | Jul | Sep | Oct | Nov | Dec | Feb 26 | Apr | Jul | Sep | Oct |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Fisch | 228 | 365 | 224 | 102 | 11 | 73 | 145 | 103 | 99 | 54 | 34 | 67 | 77 | 74 |
| Fish It! | n/a | 0.9 | 1.1 | 1.2 | 10 | 206 | 409 | 851 | 987 | 504 | 165 | 124 | 108 (to 10th) | n/a |

Like-month comparison: Fisch October fell from 145K (2025) to 74K (2026). Fish It! averaged 851K in November 2025 and about 67K over the last 30 days [B][C].

**What the sources say about the turns**
- **Fisch rise:** Roblox's Today's Picks featured it on 2024-11-04. Do Big Studios acquired it on 2024-11-02 [E].
- **Fisch fall:** the Second Sea shipped 2025-03-29 (v1.26) as a separate, level-gated place [E]. Monthly average went 224K, 102K, 38K, 11K over March to July [B]. Press blames the regrind and pay-to-win; I only saw this in search summaries.
- **Fisch recovery:** Do Big stepped down 2025-07-07 and some microtransactions were removed. WoozyNate regained ownership 2025-08-21. The Second Sea was removed in v1.47 on 2025-08-30 [E][G].
- **Fisch today:** peaks land on update days. 511,025 on 2026-10-17 (v2.06 released that day) and 377,080 on 2026-11-14 (v2.10) [C][E].
- **Fish It! rise:** one tracker article credits built-in AFK auto-fishing lifting session time, simple luck-based play and weekly updates [J]. A blog claims an Indonesian core audience on Discord-activity evidence only [K].
- **Fish It! fall in 2026:** no source found.
- **AFK signal:** Fish It!'s daily curve is nearly flat (24h average 63,431, peak 66,939) [C]. 1,038,040 accounts hold its "500,000 Catches" badge [H].

### How they play

| | Fisch | Fish It! |
|---|---|---|
| First 60 seconds | Spawn at Moosewood. Tutorial NPC Pierre asks for 3 fish, then "make some C$ and buy a new rod" [E] | Spawn on Fisherman Island with a rod. Quests: catch 2 fish, sell a fish, buy Luck Rod, buy bait [F] |
| Catching | Hold to cast, tap a moving "shake" button, then hold/release to keep a bar on the fish. Minimum 6.8 s reel [E] | "Click to charge up, click as fast as you can" [A]. AUTO button [M-search]; pets can grant auto-fishing [M] |
| Onboarding funnel | 123.0M joined, 63.0M sold a fish (51%), 28.8M reached 50 catches [H] | 104.3M played, 65.3M sold (63%), 29.5M reached 50 catches [H] |
| Rods, bait, enchant | Rods with stats and passives; bait mostly from crates; relics enchant at an altar; appraisal re-rolls a fish for 30% of its value [E] | Rods (luck, speed, max weight), 8 rarities; bait 100 to 3.7M coins; enchant stones at an altar [F] |
| Rarity and mutations | 24 rarities; one mutation plus stackable attributes; "400,000+ variations" [E] | Mutations at 0.5 to 1.4% each; "1,000,000+ variations" [F][A] |
| Boats | Bought from 31 Shipwrights, level 5+. Stats: speed, steering, acceleration, durability. Passenger seats. No hold, no part upgrades [E] | About 20 boats, 300 coins to 1.2M. Stats: speed, acceleration, passengers. No hold [F][M] |
| Map | One main place: 30 major locations in a sailed ocean. Separate places for Trade Plaza and Deep Sea [E][N] | 27 locations, boat travel. Main place plus Trade Plaza [M][N] |
| Selling | 18 Merchants. Value is per-kg price times weight times mutation. "Sell to any Merchant" [E] | Fish Merchant on islands [F]. No location pricing found |
| Trading | Since 2025-06-07, level 15+. Trade Plaza with booths and listings in a second currency [E] | Since 2026-03-29, level 20. Booths, Trade Tokens [K][I] |
| Passive / property-like | Personal Aquarium: 10 fish, hourly coins, offline at one quarter rate [E] | Aquarium: 4 areas, 14 tanks, 4M coins to unlock [O] |
| Social | Boat passengers, trading, aquarium visits, boat racing, voice [E][G] | +10% luck per friend in server (max 5) [F]. Fun with Friends chart #1 [C] |
| Cadence | 111 versions; last eight on consecutive Saturdays [E] | Weekly [F][A] |
| Monetization (Robux) | Sell Anywhere 399, Spawn Boat Anywhere 299, Double XP 289, 2x Luck 1h 59, skins to 1,999, boats to 4,499 [I] | Luck passes 50/245/545, VIP 445, Sell Anywhere 315, Hyper Pack 999, eggs 109, coins 125 to 2,500 [I] |
| Devices | PC, mobile, Xbox, PlayStation controls documented [E] | Desktop, mobile, tablet, console, VR [M] |
| Praise / complaints | Calm, detailed, soundtrack / grind, hard quests, earlier Robux pop-ups [L] | Easy / "too easy", repetitive, Fisch-like, Robux stalls [L]; bot and real-money-trading concerns [J] |

### Other fishing games

| Game (created) | Now / 7-day avg | Peak (source window) | Visits | Like | What it does differently |
|---|---|---|---|---|---|
| Net a Fish! (2026-10-15) | 17.3K / 26.6K | 40.1K [D] | 17.8M | 92.6% | Throw nets; pool earns cash; dock, boats, helpers; crews |
| Harpoon a Fish (2026-08-28) | 6.7K / 10.3K | 19.7K [D] | 24.0M | 97.2% | Aim and timed reel; steal others' fish; rated Mild |
| Deep Fishing (2026-07-18) | 5.1K / 5.3K | 38.6K [D] | 30.0M | 97.1% | Cast-distance strength incremental |
| Heavyweight Fishing (2025-08-04) | 4.9K / 8.2K | 27.7K [D] | 83.3M | 96.0% | Boss-fish fights |
| Sell a Million Sushi (2026-10-13) | 4.0K / 6.8K | 16.2K [D] | 15.6M | 99.0% | Hire fishermen, chef makes sushi, serve customers |
| Ice Fishing Simulator (2023-08-07) | 2.3K / 5.3K | 11.4K [D] | 81.0M | 89.8% | Coolers; market "prices shift every in-game day"; cooking; auto poles |
| Pull a Lucky Fish (2026-05-20) | 2.6K / 3.6K | 26.7K [D] | 59.8M | 95.1% | Place fish on your island to earn |
| Ro-BassFishing (2026-10-07) | 2.9K / 3.2K | 9K [D] | 8.3M | 89.4% | Realistic bass lake |
| GO FISHING (2024-11-06) | 263 / 387 | 80,891, 2024-12-15 [B] | 250.0M | 93.2% | Fisch-style rods, boats, maps |
| Fishing Simulator, formerly Fishing Frontier (2019) | 197 / 310 | 41,494, 2020-02-22 [B] | 498.1M | 92.2% | The original; 10+ islands, sailing |
| Titan Fishing (2026-01-25) | 11 / n.f. | 79,652, 2026-03-14 [B] | 51.7M | 98.0% | Monthly avg 14.2K then 1.3K a month later |
| Steal A Fish (2025-06-13) | 211 / n.f. | 192,221, 2025-09-20 [B] | 438.3M | 96.2% | Base-stealing game with fish |

Live players, visits and likes are from [A].

Games literally named tycoon or empire are tiny: My Fishing Empire! (5 playing), Fish Store Tycoon (4), Fish Tank Tycoon (64), Frozen Fish Tycoon (68) [A].

### The idea, element by element

| # | Element | Fisch | Fish It! | Elsewhere |
|---|---|---|---|---|
| 1 | Catch here, sell there for more | No | No (none found) | Arcane Odyssey: cargo value depends on distance between islands [P]. Tradelands: cargo trading (14 playing) [A] |
| 2 | Fish as cargo with hold capacity | No; no cap found | No | Hook & Harbor: "bigger hold" (56 playing). Ice Fishing Simulator: coolers [A] |
| 3 | Upgraded, sailed ship | Partly: sailed and owned, but you replace boats | Partly, same | Hook & Harbor: engine, sonar, hold upgrades [A] |
| 4 | Strongly themed regions | Yes | Yes | Most |
| 5 | Buying properties | Partly: aquarium, booths | Partly: aquarium areas | Tradelands houses [A] |
| 6 | Hired employees | No | No; auto-fish and pets | Sell a Million Sushi, Frozen Fish Tycoon, Net a Fish "helpers" [A] |
| 7 | Processing chain | No | No | Single-step cooking only: Sushi, Frozen Fish Tycoon, Ice Fishing Simulator, Fishing Chef [A] |
| 8 | Prices move with player sales | No | No | Not found. Ice Fishing Simulator shifts daily [A] |
| 9 | Pirates to pay off or befriend | Partly: three pirate factions with reputation ranks; quest-givers, not raiders [E] | No | Not found |

### Near-copy versus open ground

**A near-copy (my opinion, from the evidence above):** a game whose main progression is rod, bait, enchant, mutation and "1 in X" rarity; a cast-wait-reel minigame; an index to fill; luck boosts; and a Sell Anywhere pass. Fish It! says in its own description "Inspired by Fisch and Fishing Simulator" [A] and draws copycat criticism [L][J].

**What none has (evidence):** regional price gaps, a physical hold, a sailed haul, hired crew and multi-step processing together. The nearest pieces sit in very small games (Hook & Harbor 56, Frozen Fish Tycoon 68, Arcane Odyssey 422, Tradelands 14 playing) [A]. That shows the combination is unclaimed. It does not show it is wanted.

### Sources
- [A] games.roblox.com/v1/games?universeIds=… and /v1/games/votes
- [B] web.archive.org/web/20261030143221/https://www.rolimons.com/game/16732694052 ; web.archive.org/web/20260910232750/https://www.rolimons.com/game/121864768012064 ; same pattern for other games
- [C] statroblox.com/games/5750914919 ; statroblox.com/games/6701277882
- [D] rotrends.com/game/&lt;universeId&gt;
- [E] fischipedia.org/w/api.php (Fisch, Fishing, Boats, Merchant, Trading, Trade Plaza, Personal Aquarium, Pirate Factions, versions)
- [F] fish-it.fandom.com/api.php
- [G] roblox.fandom.com/wiki/Fisching/Fisch ; roblox.fandom.com/wiki/Fish_Atelier/Fish_It!
- [H] badges.roblox.com/v1/universes/&lt;id&gt;/badges
- [I] apis.roblox.com/game-passes/v1/universes/&lt;id&gt;/game-passes ; apis.roblox.com/developer-products/v2/universes/&lt;id&gt;/developerproducts
- [J] rowatcher.com/news/fish-it-reels-in-270k-players-inside-roblox-s-most-addictive-casual-game-of-2026
- [K] roonby.com/2025/11/11/why-fish-it-became-one-of-robloxs-most-popular-games-but-nobody-talks-about-it/ ; roonby.com/2026/03/27/fish-it-roblox-trading-update-guide-release-date-all-new-features/
- [L] droidgamers.com/guides/is-fish-it-better-than-fisch/
- [M] bloxodes.com/wiki/fish-it
- [N] develop.roblox.com/v1/universes/&lt;id&gt;/places
- [O] techwiser.com/fish-it-aquarium/
- [P] roblox-arcane-odyssey.fandom.com/wiki/Cargo

Raw downloads are in (session scratchpad)

## Researcher's lessons (several are struck or narrowed by the check below)
- Evidence-backed: A fishing game built on rod, bait, enchant, mutation and rarity progression with a cast-and-reel minigame would be the third of its kind behind two games with about 5B visits each. Fish It! already draws copycat criticism for exactly that, and the project rules out near-copies.
- Evidence-backed: None of the nine elements that define the tycoon half of the idea (regional prices, cargo hold, hired crew, processing chain, player-moved prices, pay-off raiders) is in Fisch or Fish It!. Themed regions and sailed boats are in both, so those two elements will not differentiate the game on their own.
- Evidence-backed: Both leaders sell 'Sell Anywhere' and Fisch sells 'Spawn Boat Anywhere'. They monetize removing the trip to the merchant. The idea makes that trip the game, so it cannot sell the same convenience without undercutting its own loop.
- Evidence-backed: The genre's first minute is always the same: catch a fish within seconds, then sell it nearby. 51% of Fisch joiners and 63% of Fish It! joiners reach a first sale. A design where the first sale needs a voyage to another region risks a worse funnel unless the first sale happens at the starting dock.
- Evidence-backed: Fisch's worst period followed putting new content in a separate, level-gated place (the Second Sea), which was later removed and merged back. Treat region gating and separate places for the five regions with caution.
- Evidence-backed: Weekly updates are table stakes here. Fisch has shipped on consecutive Saturdays and its player peaks land on update days; Fish It! also updates weekly. Content has to come from systems cheap enough to ship every week.
- Evidence-backed: Passive and AFK income is normal in this genre (Fish It! auto-fishing, Fisch aquarium paying offline, Cage Fishing, Net a Fish pools). Hired employees fit audience expectations; they are not a novelty by themselves.
- Opinion: The safest framing is a trading-and-tycoon game whose raw material happens to be fish, not a fishing game with tycoon features. Title and thumbnail should lead with the haul or the company, because 'fishing' in the name invites direct comparison with Fisch and Fish It! and with a dozen weekly 'verb a fish' entrants.
- Opinion: Keep the catch itself very short and light. Fisch owns the skill minigame and Fish It! owns click-spam plus AFK. The idea's distinct decisions are where to sell, what to carry and what to process, so the catch should feed those quickly.
- Opinion: The unclaimed combination is real, but the evidence that players want it is thin. The closest games (Hook & Harbor, Frozen Fish Tycoon, Tradelands, Arcane Odyssey's cargo) are small or have faded, and their size has many possible causes. This needs a cheap playtest of the haul-and-sell loop before the factory and employee layers are built.
- Opinion: Fisch's pirate factions show a reputation ladder with pirates is acceptable at a Minimal rating. Pirates as raiders who can be paid off would be new, and should be checked against the Mild rating once the mechanic is specified.
- Opinion: Ice Fishing Simulator is worth a hands-on look before design is fixed. It is the only fishing game found that advertises shifting market prices, storage capacity, processing and automation together, and its 7-day average more than doubled this week.

## Not found
- Why Fish It! fell from about 987K (December 2025) to about 67K average: no source gives a cause.
- What happened on Fish It!'s record day (2025-12-07) and Fisch's record day (2025-10-18): no source read names the event.
- Fish It!'s exact public release date. The API gives creation on 2024-10-21; the earliest tracked players are from 2024-12-27.
- Whether Fish It! sell prices differ by island, and whether its inventory has a cap. No source says either way; its fan wiki is thin and largely dated September 2025.
- Fish It!'s Clam Market, Doubloons and Crew Totems: they appear as product names in the developer-products API, but no page read explains them.
- Whether the Fish It! aquarium pays passive income (the one guide read covers costs and layout only).
- Fish It! auto-fishing unlock level. Guides say an AUTO button exists and that pets can grant auto-fishing; none gives a level.
- Fisch auto-fishing: none documented on its wiki; guides warn that macros break Roblox rules. Not confirmed in-game.
- Private-server price and availability for either game. The API field createVipServersAllowed reads false for Fisch; I did not verify what that means for paid private servers.
- A direct read of player complaints (Reddit, DevForum). Destructoid, GameBoost, Sportskeeda and Deltia's pages returned errors, so complaints come from one Droid Gamers comparison, one tracker article and search summaries.
- Any Roblox game where prices move with what players sell, and any game with NPC raiders that can be paid off or befriended: none found in the searches run.
- A Miner's-Haven-style multi-step fish processing chain: only single-step cooking was found.
- Peaks for Hole Fishing, Claw Fishing, Fish Tank Tycoon, My Fishing Empire!, Roll a Fisherman and Vox Seas history: no archived Rolimons snapshot. rotrends peaks carry no date and their tracking window is not stated.
- statroblox.com began returning 403 partway through, so 30-day averages for the smaller games were not collected; their table uses rotrends 7-day averages.
- Vox Seas (about 25K playing, described as sailing, combat and trading): what its trading actually is was not checked.

## Independent check

9 of 14 key facts confirmed.

### Facts corrected
- **partly wrong:** 8. Catching: Fisch is hold-to-cast, tap a moving 'shake' button, then a hold/release bar minigame lasting at least 6.8 seconds. Fish It! is 'click to charge up, click as fast as you can', plus built-in auto-fishing
  - Correction: 6.8 s is not a floor. The wiki says it takes at least 6.8 s 'assuming it is a perfect catch and there are no Progress Speed modifiers', and gives T(p) = 1.2 + 6.8/(1+p/100), so rods with a progress-speed bonus reel faster. Shaking is optional ('While not required'). Fish It!'s click description is verbatim; bloxodes only says pets can grant auto-fishing and describes no AUTO button.
- **partly wrong:** 9. Boats in both games are owned, bought with coins and physically sailed, with speed-type stats and passenger seats. Neither wiki describes a cargo hold or part-by-part upgrades. Fisch's inventory page describes no capacity limit
  - Correction: Mostly right, with two Fisch counter-examples. The Submarine 'can receive three upgrades' (Heat, Ice, Deep) that unlock deeper regions. Version 1.31 added four tiers of Utility Boats whose tier limited which nets and lobster cages you could use for 'regional-specific' catches (removed with the Second Sea). No hold on either game: Fisch items 'stack infinitely'; Fish It! boats list only Acceleration, Passengers and TopSpeed (300 coins to 1.20M, plus Robux boats). The Fish It! fandom wiki is stale (front page cites an update of 11/23/2025), so its silence is weak evidence; I could not verify whether Fish It! has an inventory cap.
- **partly wrong:** 11. Player trading: Fisch since 2025-06-07 (level 15+, Trade Plaza with booths and fish listings in a second currency); Fish It! since 2026-03-29 (level 20, booths, Trade Tokens 50 for 50 Robux up to 1,000 for 1,000)
  - Correction: Two details. The Fisch Trade Plaza itself needs Level 25+ (Trade Plaza page); 15+ is for direct trades. Fish It! Trade Tokens go up to 10,000 for 10,000 Robux, not 1,000 (packs of 50, 100, 250, 1,000, 2,500, 5,000 and 10,000 at 1 Robux each).
- **partly wrong:** 13. New fishing entrants keep charting but are short-loop twists and several faded fast: Net a Fish! (created 2026-10-15) 26.6K 7-day avg; Titan Fishing 14.2K monthly avg in Mar 2026 to 1.3K in April; GO FISHING peaked 80,891 in Dec 2024, now averages 387
  - Correction: The numbers hold, but GO FISHING did not fade fast: the snapshot from 2025-11-19 still shows a 30-day peak of 4,381, a year after launch. It is a slow two-year decline. Only Titan Fishing is a clean fast-fade example among the three named.
- **partly wrong:** 14. The idea's rarer elements exist only in small or non-fishing games: Hook & Harbor (bigger hold, engine, sonar; 56 playing), Frozen Fish Tycoon (nets, cooking, hired crew, warehouse, shipyard; 68 playing), Sell a Million Sushi (6.8K 7d avg), Ice Fishing Simulator (prices shift every in-game day, coolers, auto poles; 5.3K 7d avg), Arcane Odyssey (cargo crates valued by distance; 422 playing, peak 95,364)
  - Correction: Each number checks out, but 'only in small or non-fishing games' is too strong. Arcane Odyssey is itself a fishing game in part (rods with four stats, an 86-fish journal, selling and cooking fish), has hired deckhands and crew who 'catch 1 fish every 10-20 minutes while a player's ship is stationary', part-slot ship upgrades (sails, hulls, rams, cannons), and physical cargo limited by what fits on the hull. It reached 24,078 concurrent in December 2025 and its description says keyboard and mouse are required, so its 438 today is not a clean read on demand. Hook & Harbor also has processing ('Fillet your catch for chum or make ceviche'). The brief also missed live games with haul, process and hire outside fishing (see 'missed').

### Conclusions that go beyond the evidence
- Lesson 2 misstates its own table. It says 'none of the nine elements' but lists six; the brief's table marks three of the nine as Yes or Partly in both leaders. For Fish It! the six 'No' verdicts rest on a fandom wiki whose front page cites an update of 11/23/2025, a summary page and the store description, so they should read 'not documented', not 'is not in'. For Fisch the 'No' holds on a deep wiki, with two small exceptions: Submarine upgrades, and the removed tiered Utility Boats for regional net and lobster fishing.
- Lesson 4 says the first minute is 'always' catch-then-sell-nearby, from two games. The badge funnels are lifetime account ratios with no timing, so they do not show when the first sale happens or that a voyage before the first sale would lower it. Half of Fisch joiners never sell even with a merchant at spawn. The funnel risk is a reasonable hypothesis, not an evidence-backed finding.
- Lesson 5 is tagged evidence-backed, yet the brief itself says the causal link was only seen in search summaries. The Second Sea also had its own currency (earned and spent only there) and its own rods, the game was under DoBig-era monetization, and the decline had begun three months earlier. Fisch still runs separate places (Deep Sea, Trade Plaza) at a 62K weekly average. The evidence fits 'do not reset progression and economy in a new region' at least as well as 'avoid separate places or gating'.
- Lesson 6 ('weekly updates are table stakes', 'content has to ship every week') generalises from two top-20 games with teams. The update-day evidence is Fisch only. Nothing here shows what cadence a new, smaller game needs, and the Nov 14 spike (377K peak against a 99K daily average) lasted hours.
- Lesson 10 says the closest games 'are small or have faded'. Arcane Odyssey hit 24,078 concurrent in December 2025 and requires keyboard and mouse. DigCrew (haul, multi-step processing, hired drivers) was created 2026-10-11 and has a 7-day average of 3,961 per rotrends. Evidence of demand is thin for fishing specifically, but less thin for the haul-process-hire loop than the lesson states.
- Lesson 12 calls Ice Fishing Simulator 'the only fishing game' advertising prices, storage, processing and automation together. Hook & Harbor advertises a hold, processing (fillet, ceviche) and crews. The 'doubled this week' reading is real (7-day 5,282 against 14-day 3.7K) but live players were 2,305 at my read, below both averages, so the jump was already receding; it looks like an update spike on a 2023 game.
- Lesson 1 says a Fisch-like would be 'the third of its kind'. GO FISHING (250M visits, rods, boats, maps) and Fishing Simulator (498M visits) already sit in that slot, so the field is more crowded than 'third' implies. The copycat-criticism claim rests on one article I did not verify.
- The AFK reading of Fish It! (fact 6, lesson 7) leans on a flat player curve, but the cited article itself raises bot inflation as an alternative explanation.

### What the brief missed
Five things the brief lacks.

1. Live non-fishing precedents for the tycoon half, all from the Roblox games API and rotrends:
- DigCrew (universe 10770299564, created 2026-10-11): 'HAUL to the Railyard', 'PROCESS it: crush ore, wash gold, pour bars, smelt metal', 'HIRE DRIVERS and draw their haul routes', phone controls. 2,985 playing, 7-day average 3,961, peak 7.6K, 84.4% likes.
- Risky Pirates! (10769764065, created 2026-10-07): build a skiff with engines and upgrades, 'SELL loot at outposts', 'FIGHT raiders'. 2,118 playing, 7-day average 974, 78.6% likes.
- Ship The Cargo (10769735087, created 2026-10-07): 'Deliver Cargo Across The Ocean... Sell Your Cargo For Profit'. Peak 6.6K, 7-day average 1,019, down 57% on the week.
These are the cheapest things to play before the haul-and-sell playtest.

2. Arcane Odyssey is the closest single precedent and deserves more than a cargo footnote. It combines fishing, physical cargo priced by distance, hired deckhands, part-slot ship upgrades and bounty/notoriety systems. It peaked at 24,078 in December 2025 and is keyboard-and-mouse only.

3. Fisch's Second Sea used a region-locked currency (Embercoins). The idea has five regions, so this is the most directly relevant detail of that episode and it is absent from the brief.

4. Fish It!, the larger leader, lost over 90% of its average in under a year: 987K in December 2025, 854K in January, 165K in April, about 65K now, with an 82.8% like ratio. The brief notes 'no source found' for why. For a project aiming to last years, that unexplained fall matters as much as Fisch's.

5. Crews are now standard in the genre and the brief's Social row omits them. Fisch has seasonal Crews (10 to 50 members, crew rating, Crew House); Net a Fish! has Crew Wars; Fish It! sells a 'Golden Crew Totem'. Fish It! also has pirate-themed content (Doubloons currency, Pirate Crates) even though it has no pirate factions.

Not verified: Tradelands' '14 playing' (Roblox search did not return the game). Maturity 'Minimal' for both leaders is confirmed from Roblox's own experience-guidelines API, which is a better source than the fandom wiki the brief cites.

My raw downloads are in (session scratchpad)


---

# B. Factories, automation and hired workers

## Factories, automation and hired workers on Roblox: what the record shows (Nov 2026)

Snapshot: Thu 19 Nov 2026, 00:23 UTC (Wednesday evening in the US). "Live" is one weekday reading, so use the averages.

Source keys, with `<id>` being the universe ID in the tables:
- **API** = games.roblox.com/v1/games?universeIds=`<id>`
- **RT** = rotrends.com/game/`<id>`
- **SR** = statroblox.com/games/`<id>`
- **RW** = rowatcher.com/games/`<id>`
- **Roli** = web.archive.org copy of rolimons.com/game/`<placeId>` (embedded history, sampled every 6 hours)
- **Badges** = badges.roblox.com/v1/universes/`<id>`/badges
- **Passes** = apis.roblox.com/game-passes/v1/universes/`<id>`/game-passes

### 1. The long-lived games

| Game (universe ID) | Created / server size (API) | Live (API) | 7-day / 30-day avg | Peak found | Visits (API) | Avg session (RT) |
|---|---|---|---|---|---|---|
| Miner's Haven (105689481) | 2015-06-12 / 6 | 159 | 161 / 187 (SR) | 4,125 on 2020-04-05 (Roli, history starts Nov 2019) | 200.5M | 49 min |
| Lumber Tycoon 2 (2471084) | built 2015 / 6 | 1,230 | 2,134 / 2,440 (SR) | 34,174 on 2026-09-26 (SR) | 1.34B | 22 min |
| Bee Swarm Simulator (601130232) | 2018-03-21 / 6 | 33,501 | 34,556 / 31,982 (SR) | 258,790 on 2025-12-28 (Roli) | 4.68B | 22 min |
| Islands (1659645941) | 2020-04-08 / 20 | 425 | 541 / 593 (SR) | 101,903 on 2020-06-01 (Roli) | 2.36B | 13 min |
| Retail Tycoon 2 (2092410051) | 2020-10-23 / 6 | 626 | 814 / 1,073 (SR) | 8,670 on 2025-09-04 (Roli, last 30 months only) | 341M | 42 min |
| Factory Simulator (2566300911) | 2021-05-05 / 8 | 41 | 44 / not found (RT) | 21,097 on 2021-05-30 (Roli) | 76.1M | 49 min |
| Industrialist (3448264866) | 2022-03-25 / 20 | 1,755 | 2,156 / 2,368 (SR) | 9,565 on 2025-11-23 (Roli) | 75.1M | 39 min |
| Ultimate Mining Tycoon (6329693946) | 2024-07-27 / 8 | 580 | 773 / not found (RT) | 19,283 on 2026-03-29 (Roli) | 92.3M | 26 min |
| The Forge (7671049560) | 2025-05-10 / 12 | 17,217 | 23,228 / 13,488 (SR) | 870K (RW) or 1.1M (RT), Dec 2025 | 1.06B | 28 min |

Yearly and like-month trends (Roli):
- **Miner's Haven:** average 763 in 2020, 412 in 2022, 270 in 2025. November 2025 averaged 320; the last 30 days averaged 187 (SR).
- **Lumber Tycoon 2:** 6,164 in 2020, 4,010 in 2024, 2,940 in 2025. The September 2026 spike coincided with a Roblox platform event (The Hunt: Roblox 20) and the Advanced Logic Update (lumber-tycoon-2.fandom.com/wiki/Lumber_Tycoon_2).
- **Bee Swarm:** the yearly average rose every year, from 18.3K in 2020 to 42.0K in 2025.
- **Islands:** 36.7K in 2020, 10.2K in 2022, 5.4K in 2023, 1.7K in 2025. Updates were announced as stopped on 2023-11-07 (roblox.fandom.com/wiki/Easy.gg/Islands), so most of the decline came first.
- **Factory Simulator:** 3,191 in 2021, 1,126 in 2022, 243 in 2023.
- **Industrialist:** November averages were 946 (2024), 3,577 (2025) and 2,229 (2026, to the 14th). Its best month was August 2026 at 4,363.

### 2. What the player builds

- **Miner's Haven** (berezaa; now run by community developers led by OutOfOrderFoxy). Grid placement on a baseplate of droppers, conveyors, upgraders and furnaces, from "over a thousand unique items" (API description). It has five save slots and a solo-island option that the wiki says dramatically reduces lag. berezaa open-sourced it on 2019-09-16 under Apache 2 (devforum.roblox.com/t/350767). It sells three memberships at 80 to 2,450 R$ (Passes), 59 developer products (RT) and mystery boxes. No player trading was found.
- **Industrialist.** Machines, pipes and wires on a 1024×1024-stud world, with a research tree, pollution and six difficulty levels. Nothing travels in the pipes: nodes pass data (industrialist.fandom.com/wiki/Building_System). It sells four passes at 229 to 479 R$. 53% of players who started a world had someone join it (Badges).
- **Factory Simulator.** Harvest trees and ore by hand, haul by vehicle, then buy "Farms and Mines" droppers that replace the harvesting. Ten tiers (factory-simulator.fandom.com/wiki/Farms_and_Mines).
- **Islands.** Hand farming, then totems that harvest (wheat totem at Farming level 16), then conveyors (Forging level 8) and industrial machines. An NPC gifts the first industrial chest and eight conveyors when the first steel mill is built. Vending machines make a player economy (robloxislands.fandom.com/wiki/Totem, /Conveyor_Belt, /Vending_Machine).
- **Lumber Tycoon 2.** Chopping stays manual. Sawmills and conveyors add value, and logic parts let players build their own autocutters. Six save slots; load time grows with build size (lumber-tycoon-2.fandom.com/wiki/Load).
- **Ultimate Mining Tycoon.** Hand mining and trucks feed a factory the player designs on a 30×30 plot. Prestige at $20M (ultimate-mining-tycoon-wiki.pages.dev, unofficial).
- **Bee Swarm and The Forge** have no factory building. They are gather-and-craft loops.
- **Retail Tycoon 2 employees:** see the existing brief.

### 3. The 2025-2026 wave

| Game (universe ID) | Created (API) | 7-day avg (RT) | Peak (RT or RW) |
|---|---|---|---|
| Farm Evolution (10771290199) | 2026-10-16 | 12,122 | 20.2K, Nov 2026 |
| Run A Farm! (10768558548), hire workers | 2026-09-29 | 9,963 | 19.7K, Nov 2026 |
| Sell a Million Sushi (10770628276) | 2026-10-13 | 6,752 (down 31% in a week) | 16.2K |
| Run a Restaurant! (9970645639), hire staff | 2026-04-01 | 3,255 | 33.8K, May 2026 |
| Oil Empire (8786713187) | 2025-09-23 | 815 | 94K, Apr 2026 |
| Build A Pet Factory (8881105040) | 2025-10-05 | 807 | 31K, Feb 2026 |
| Make a Drill Farm (10231871497) | 2026-05-27 | 269 | 27K, Aug 2026 |
| Automate a Restaurant (10219827882) | 2026-05-25 | 209 | 12K, Aug 2026 |
| Unbox a Factory (9833422940) | 2026-03-04 | 55 | 14K, Apr 2026 |

- **Sell a Million Sushi** is the nearest thing to the fishing idea's later stage. Hired fishermen catch, the player carries fish to a chef, and customers pay (bloxodes.com/articles/sell-a-million-sushi-beginner-guide). Its six passes are worker roles at 29 to 499 R$ (Passes).
- **Fish and seafood tycoons are all tiny** (RT 7-day averages): SeaFood Tycoon 64, My Seafood Stand 27, Fishing Chef 20, My Fishing Empire 11, Fish Store Tycoon 6. Build A Fishing Factory has 57,608 visits in total (API).
- **Factorio-style games other than Industrialist are near empty** (API live): Manufrontier 7, Planet Settlers 6, The Deep Deposit 6, OVERCLOCKED 3.
- **No game inspired by Minecraft's Create mod was found.**

### 4. Direct answers

**(a) Which lasted, and what do they share?**
Lumber Tycoon 2 (11 years), Miner's Haven (11), Bee Swarm (8), Retail Tycoon 2 (6) and Industrialist (4, and the only one that grew in years 3 and 4). They share:
- small servers (6, or a private world) with a build saved to the player
- progression measured in months
- the longest sessions in this set (39 to 49 minutes for the builders)
- cheap passes with no pay-to-win ladder
- a cap on moving items

Only Bee Swarm is large, and it has no factory.

**(b) Does automation work as a late game after a hands-on start?**
It has reached five-figure peaks three times: Islands, Factory Simulator and Ultimate Mining Tycoon. None held. The one hands-on game that lasted, Lumber Tycoon 2, never removes the hands-on job.

Hand-over patterns seen:
- machines multiply the value of what the player gathers, and the gathering stays
- automation unlocks per job, gated by skill in that job (Islands)
- the first machine is gifted (Islands, Factory Simulator)

No source measures retention at the switch. The badge funnels show most players never arrive:

| Game | Milestone | Share |
|---|---|---|
| Miner's Haven | first rebirth, of players who placed an item (647,000 of 15.0M) | 4.3% |
| Factory Simulator | Tier 3, of tutorial finishers | 36% |
| Factory Simulator | Tier 6, of tutorial finishers | 6.7% |
| Industrialist | $1M, of players who started a world | 5.8% |

**(c) What does Miner's Haven teach?**
- **The reset is the content.** First rebirth costs $25 quintillion, wipes the base and grants a permanent Reborn item. 71% of first-rebirthers reached life 5, and 20% reached the life-1,000 Sacrifice (Badges).
- **Rarity is a weighted draw gated by life count,** over 135 reborn items (source `RebornHandler`; minershaven.fandom.com/wiki/Category:Rebirth).
- **Tiers encode persistence, not just power.** Shop tiers are gated by price and research points. Reborn items survive a rebirth, Slipstream items last one life, and Evolved and Fusion items consume duplicates (minershaven.fandom.com/wiki/Item_Tiers).
- **Saved layouts make rebuilding quick.**
- **Costs.** The Roblox wiki records criticism for repetitiveness and poor optimization, and a "speed meta" of rebirths under 30 seconds. The game now bans rebirth macros.
- **Its early peak is not recorded.** Visits went from 57M (Feb 2017) to about 100M (Apr 2018) to 200M (2026).

**(d) What is the practical ceiling?**

| Game | Published cap | Source |
|---|---|---|
| Miner's Haven | 50 moving ores per player, +25 per upgrade level, +25 with Premium. Guides mention setups using 175 to 200. Ore physics is handed to the owner's client. | 2019 source, `PlayerDataGuardian` and `Main` in github.com/berezaa/minershaven |
| Islands | Factory-dropped items cut to 40 on public servers (80 on private) because physics "will slow to a crawl". Block cap 50,000. | robloxislands.fandom.com/wiki/May_10,_2020 |
| Industrialist | 30,000 models per world (80,000 with an override, at risk of save corruption). No moving items at all. | industrialist.fandom.com/wiki/Model_count |
| Ultimate Mining Tycoon | 4,000 machines, conveyors and blocks per plot, raised from 750 | unofficial wiki, factory.html |

Roblox's own performance guide gives no number (create.roblox.com/docs/performance-optimization/improve). No developer has published a phone-specific figure.

**(e) What is unproven?**
- an automation late game that holds players for years after a hands-on start
- any fish-processing tycoon with a lasting audience
- Create-style mechanical networks
- a factory whose output feeds a player market at scale (Islands' vending machines are the only case)
- physical cargo, a factory and hired workers together on a phone
- retention across the hand-over

### 5. Design opinion (mine, not evidence)

- Treat the factory as a value multiplier on fish the player still chooses to catch. It should not replace fishing.
- Budget about 50 to 100 visible moving items per player, simulate the rest as rates, and let the client render them.
- Assume fewer than 1 in 10 players reach the factory, so the first week must stand on boats, fish and selling.
- Borrow the persistence tiers and saved layouts from Miner's Haven, not its ore-dropper format.

## Researcher's lessons (several are struck or narrowed by the check below)
- Evidence-backed: A hands-on game with an automation late game has reached five-figure peaks three times (Islands 101.9K, Factory Simulator 21.1K, Ultimate Mining Tycoon 19.3K) and none held those players. The only hands-on game that lasted a decade, Lumber Tycoon 2, never removes the hands-on job. Treat 'factory as the late game' as a proven draw and an unproven retainer.
- Evidence-backed: Most players never reach the late game. Only 4.3% of Miner's Haven players who placed an item ever rebirthed, 6.7% of Factory Simulator tutorial finishers reached Tier 6, and 5.8% of Industrialist world-starters reached $1M. The fishing, sailing and selling loop has to carry day 1 and week 1 by itself.
- Evidence-backed: Those who do cross into the deep loop stay a very long time. 71% of Miner's Haven first-rebirthers reached life 5 and 20% reached life 1,000, and that game still has 49-minute sessions after 11 years. A prestige loop is a strong tool for a small committed core, not a mass-retention tool.
- Evidence-backed: Every game with physically moving items had to cap them, and the published caps are low: Miner's Haven starts at 50 ores per player, Islands cut to 40 factory-dropped items per public server. The one automation game that grew in years 3-4 (Industrialist) moves no items at all. Fish as visible cargo and on belts must be budgeted in tens per player, with everything else simulated as rates.
- Evidence-backed: The lasting builders use small servers (6 players, or a private world) with the build saved to the player and loaded on join. That matches the earlier platform finding and argues against a large shared-server factory district.
- Evidence-backed: No fish cannery, seafood or fish-market tycoon has a lasting audience, and no Create-mod-style game was found. The fishing idea's factory stage would not be a clone, but it also has no proof of demand in that exact form. Sell a Million Sushi shows short-term appetite for 'hired fishermen feed a kitchen', and it is five weeks old and falling.
- Evidence-backed: Hired-worker tycoons are the current fashion (Farm Evolution, Run A Farm!, Run a Restaurant!, Sell a Million Sushi) and several sell worker roles or boosts directly. Run a Restaurant! is the only one with more than six months of data, at about a tenth of its peak. Worker hand-over is a safer, better-evidenced late game than a free-form factory, but its staying power beyond a few months is not shown.
- Opinion: Make the factory a value multiplier on fish the player still chooses to catch (as sawmills are to chopping in Lumber Tycoon 2), and make hired crews remove one specific chore at a time. Do not let either replace going to sea, because that is the part unique to this idea.
- Opinion: Borrow Miner's Haven's persistence tiers (items that survive a reset, items that last one cycle, items made by fusing duplicates) and its saved layouts for a seasonal or voyage-based reset, but not its ore-dropper format, which the 2025-2026 clone wave has worn out and which Roblox's non-unique-game rule penalises.
- Opinion: Sequence the build so the factory arrives last. Regions, boats, selling and hired crews are testable on a phone early; the factory is the element with the hardest performance limits and the smallest share of players who will ever see it.
- Opinion: Industrialist's 53% 'someone joined my world' rate suggests co-building a factory with a friend is a real draw and fits the co-play ranking signal. A shared cannery or dock that friends can work in together is worth prototyping before any open player market.

## Not found
- Miner's Haven's all-time peak and player counts for 2015-2018. Archived tracker history starts Nov 2019; current trackers' 'all-time peak' (524 or 1.1K) is only their own window.
- berezaa's Medium article on releasing Miner's Haven (medium.com returned 403 and the archive fetch was blocked), so his own account of why he stepped back and the game's revenue was not read.
- The maximum ore-limit level in Miner's Haven (the level table is inside the place file, not the scripts) and any current official figure for the live game.
- Any developer-published phone-specific budget for machines, conveyors or moving items. Roblox's performance guide gives no numbers; DevForum threads found were anecdotal.
- Any measurement of retention at the hand-over from hands-on play to automation or hired workers, in any game.
- A Roblox game inspired by Minecraft's Create mod (rotational power, contraptions) with any audience.
- A fish cannery, seafood-processing or fish-market tycoon with a lasting audience; every one found averages under 100 players except the five-week-old Sell a Million Sushi.
- Industrialist's v1.0 Beta release date and the cause of its Nov 2025 rise (the wiki's update log stops at v0.11.3, April 2025); how Industrialist saves worlds and how it performs on phones beyond the note that several building shortcuts are unavailable on mobile.
- 30-day averages for Factory Simulator, Ultimate Mining Tycoon and most 2026 games (Statroblox began returning 403 partway through; Rotrends gives 7-day and 14-day only).
- Why Factory Simulator and Ultimate Mining Tycoon declined; no source attributes a cause.
- Player trading or a player economy in Miner's Haven, Industrialist, Factory Simulator or Lumber Tycoon 2 (only Islands' vending machines were found).
- Exact mechanics of Run A Farm! and Farm Evolution worker systems beyond their store descriptions; neither has badges or a wiki that was readable.
- Monetization detail for Bee Swarm Simulator and The Forge, and developer-product prices for any game (only game passes were fetched).

## Independent check

11 of 14 key facts confirmed.

### Facts corrected
- **partly wrong:** 8. Islands: peak 101,903 on 2020-06-01; yearly averages 36.7K / 10.2K / 5.4K / 1.7K; now 541; factory-dropped items cut to 40 per public server (80 private) five weeks after launch; updates stopped 2023-11-07
  - Correction: Player numbers, the May 2020 patch note and the 2023-11-07 date are right. Two problems with the cap. (a) The patch note says 'Reduce max factory-dropped items to 40 (still 80 on VIP servers)' and that the change 'only applies to public servers'; it does not say 40 in total per server, and the wiki lists the limit under each player's island. (b) It was a stopgap: the current 'Player's Island' limits table gives item despawn as '80 by machine or totem (some totem max drop are 250); 30 by player', lasting 2 minutes, and the block cap as 80,000, not 50,000.
- **partly wrong:** 12. The 2025-2026 conveyor wave decays fast (Oil Empire 815 vs 94K; Build A Pet Factory 807 vs 31K; Make a Drill Farm 269 vs 27K; Automate a Restaurant 209 vs 12K; Unbox a Factory 55 vs 14K). Hire-workers tycoons currently lead: Farm Evolution 12,122, Run A Farm! 9,963, Run a Restaurant! 3,255
  - Correction: All averages and peaks check out (Rotrends itself shows lower peaks for Drill Farm, 12.3K, and Automate a Restaurant, 9.1K; the brief used RoWatcher's). The error is Farm Evolution: nothing shows it is a hire-workers tycoon. Its API description is empty, its passes are X2Money, X2Growth, Lucky and a laser gun, and its 205 developer products are eggs, 'Instant Hatch', 'Steal DNA', treadmills, speed multipliers and plot upgrades. That is an egg-hatching and stealing game. Run A Farm! ('Hire workers to run the farm for you') and Run a Restaurant! ('Hire staff to do the work for you') are correctly labelled.
- **partly wrong:** 14. Free-form builders have the longest sessions: Miner's Haven 49 min, Factory Simulator 49, Retail Tycoon 2 42, Industrialist 39, against 11-22 for the 2026 idle and worker tycoons and 22 for Bee Swarm. Roblox's performance guide gives no numeric ceiling for moving parts or instances
  - Correction: The ordering holds, but Rotrends showed me 36.6 for Retail Tycoon 2 (not 42) and 36.8 for Industrialist (not 39), and the idle/worker range is not 11-22: Automate a Restaurant reads 24.3, and newer store tycoons read 26-28. The performance-guide statement is correct: I found no numeric limit on moving parts or instance counts in that page.

### Conclusions that go beyond the evidence
- Lesson 7 is the weakest. 'Run a Restaurant! is the only one with more than six months of data' is wrong: hire-staff tycoons have years of record. Restaurant Tycoon 2 (created 2019-07-01, 1.66B visits, 7-day average 1,135), Restaurant Tycoon 3 (created 2025-01-16, staff with assignable worker roles per devforum.roblox.com/raw/3636102/1, 7-day average 6,099, peak 67.4K), Supermarket Simulator (created 2024-10-10, description says 'hire staff', 7-day average 995, peak 28.5K) and Retail Tycoon 2 itself. Its list of examples also includes Farm Evolution, which is an egg-hatching and stealing game with no sign of hired workers.
- Lesson 7's conclusion that worker hand-over is 'safer, better-evidenced' than a free-form factory does not follow. It compares 5-to-7-week-old games with 4-to-11-year-old ones. On the long record the two look alike: the oldest hire-staff games sit at about 800 to 1,100 (Retail Tycoon 2, Restaurant Tycoon 2) and the old builders at about 2,100 (Industrialist, Lumber Tycoon 2).
- Lesson 1 says none of the three held its players. Islands did hold for a long time by Roblox standards: its monthly average stayed above 10,000 from May 2020 to August 2022 (28 months) in the same Rolimons archive. Its decline also overlaps with slowing updates and a 2023 discontinuation, so the evidence does not tie the fall to the automation late game. Crediting Lumber Tycoon 2's survival to keeping chopping manual is a single-feature explanation with no source, and that game is itself falling on like months (November: 4,584 in 2024, 2,538 in 2025, about 2,135 now).
- Lesson 2 and the '1 in 10 reach the factory' opinion: none of the three funnels measures arrival at an automation hand-over. In Miner's Haven and Industrialist the factory is the game from the first minute; in Factory Simulator droppers are buyable at Tier 1 for $1.75k. The figures show that few players reach a deep milestone (rebirth, Tier 6, $1M), which is true of most Roblox games. How many reach the factory in the fishing game depends on where the designer puts it.
- Lesson 3 ('20% reached life 1,000 ... stay a very long time') overstates the commitment. Life count is not rebirth count: one rebirth can add up to 21 lives, and the Roblox wiki describes sub-30-second rebirths. The 49-minute session figure is the average of roughly 160 remaining concurrent players, so it describes the surviving core, not what the design does for a typical player.
- Lesson 4 says 'every game with physically moving items had to cap them'. Documented moving-item caps were found for two games (Miner's Haven, Islands). Ultimate Mining Tycoon's 4,000 is a build-complexity cap, and no moving-item cap was reported for Factory Simulator or Lumber Tycoon 2. The Islands figure is also misread and dated: the wiki now lists 80 per machine or totem (some totems 250) under each island's limits. Miner's Haven's cap grows by 25 per upgrade level and guides discuss using 175-200, so 'tens to low hundreds per player' is what the evidence supports. Linking Industrialist's growth to moving no items is a single-feature explanation.
- Lesson 5 and section 4(a): 'small servers (6, or a private world)' does not match the API for Industrialist or Islands, both 20 per server. Section 4(a) also lists shared traits with no evidence in the brief: 'progression measured in months', 'a cap on moving items' (nothing is cited for Bee Swarm or Retail Tycoon 2), and 'cheap passes with no pay-to-win ladder'. Miner's Haven sells a 2,450 R$ membership, 59 developer products and mystery boxes, and its Premium flag raises the ore cap by 25 and bypasses research-point requirements in the 2019 source.
- Lesson 11: the Industrialist badge is 'Have someone join you in your world' (wiki: 'Get any other player to join your world'). 53% of world-starters earning it shows that joining is common. It does not show the joiner was a friend, that they built anything, or that co-building is why people play; the game's own description recommends playing with friends because of its steep learning curve.
- Lesson 9's claim that the clone wave has 'worn out' the ore-dropper format is interpretation. The data shows fast decay of individual games, while new entrants in the same format still reach thousands (My Cookie Factory, created 2026-07-02, was at 3,247 live with a 7-day average of 1,465 today).

### What the brief missed
1. Hire-staff tycoons with a multi-year record are absent from this brief's worker evidence, though the project's own docs/02-concept-research.md already covers them: Restaurant Tycoon 2 (2019, 7-day 1,135), Restaurant Tycoon 3 (7-day 6,099, peak 67.4K, 25.9-minute sessions), Supermarket Simulator (Oct 2024, 7-day 995). They show the same shape as everything else here: a large peak, then a long tail at 2-10% of it. The worker wave is also wider than listed: Own a Grocery Store (created 2026-07-23, 'Hire cashiers, stockers, farmers & cooks', 7-day 2,386) and Pet Store Tycoon (created 2026-06-06, 7-day 3,826, peak 40.6K).
2. Farm Evolution should be removed from the hired-worker group (see check 12).
3. Miner's Haven life-skipping (up to 21 lives per rebirth) changes how the 71% and 20% badge shares should be read.
4. Islands' current per-island item limit is 80 per machine or totem with a 2-minute despawn, and its block cap is 80,000; the 40-item figure was a May 2020 stopgap.
5. Factory Simulator had a second wave (Nov 2021 to Jan 2022, monthly averages 4.8K-7.3K) after its badges were created, so the tier funnel does include a large cohort.
6. No Create-mod-style Roblox game turned up in my own searches either (Roblox search for create mod, cogwheel, gears/shafts, kinetic contraption; one web search). The nearest things with an audience are free-form mechanical builders, not factories: Plane Crazy (3,199 live) and Build A Boat For Treasure (9,333 live).
7. Statroblox returned HTTP 403 throughout this check, so every figure sourced only to it (the 30-day averages) is unreproduced; Rotrends 7-day and 14-day figures agree with them closely.
8. Outside this brief's scope but relevant to the idea: catch-and-sell fishing itself is large on Roblox today (Fish It! about 60K live, Fisch about 47.5K live, Net a Fish! about 17K live in my search results), so the unproven part is the processing and factory stage, not fishing.

Working files are in (session scratchpad) (nothing was written to the project folder).


---

# C. Sea trade, boats and prices

## Sea trade and place-based prices on Roblox: evidence brief (read 2026-11-18)

### Bottom line
- **Boats as transport are proven at the top of the platform. "Carry it there to sell it for more" as the core loop has stayed small**, and its players call the trip boring.
- **Place-based and demand-based prices exist and are buildable.** The one cross-server player market found was shut down over bots and dupers.
- A shared price per fish per port fits Roblox's published limits with a very large margin.

### Part 1: the games
Live, visits, created and server size are from the Roblox games API. 7-day and 30-day averages are from statroblox unless marked RT (rotrends).

| Game | Created | Visits | Live | 7d avg | 30d avg | Peak (window) | Server |
|---|---|---|---|---|---|---|---|
| Fish It! | 2024-10 | 4.83B | 59,357 | 64,799 | 67,077 | 2,712,152 (RT all-time) | 20 |
| Fisch | 2024-03 | 5.15B | 47,648 | 61,724 | 70,204 | 1,257,353 (RT all-time) | 20 |
| Build A Boat For Treasure | 2016-11 | 5.26B | 9,288 | 11,905 | 12,373 | 89,627 on 2021-04-02 (Rolimons since Nov 2019) | 7 |
| Trading Tycoon (not sea) | 2026-09 | 10.6M | 1,793 | 2,171 RT | not found (14d 2,364) | 6,604 RT | 6 |
| Sail and Sink Simulator | 2024-01 | 99.6M | 889 | 1,523 | 1,345 | 8,457 RT | 10 |
| Pilfering Pirates | 2020-12 | 1.18B | 947 | 1,360 | 1,802 | 15,554 (RT window) | 20 |
| Ship The Cargo | 2026-10 | 3.07M | 324 | 1,019 RT | not found (14d 1,704) | 6,559 RT | 12 |
| SharkBite 2 | 2022-02 | 503M | 441 | 524 | 603 | 19,893 (RT window) | 18 |
| Arcane Odyssey | 2019-06 | 156M | 422 | 455 | 500 | 85,243 on 2023-02-26 (Rolimons since Jun 2020) | 12 |
| Shipping Lanes | 2015-05 | 63.3M | 197 | 346 | 473 | 1,758 on 2026-03-29 (Rolimons since Jun 2022) | 23 |
| Silk Road: Trading Simulator | 2026-02 | 4.53M | 68 | 114 RT | 146 | 1,601 RT | 80 |
| Tradelands | 2014-12 | 53.5M | 13 | 18 RT | not found (14d 22) | 1,049 on 2021-04-23 (Rolimons since Jul 2020) | 50 |
| Starscape | 2017-03 | 16.1M | 9 | 15 RT | not found | 951 (RT window) | 16 |

Like-month checks from archived Rolimons monthly averages (November 2025 against the last 30 days; the trackers differ, so treat as rough):
- Shipping Lanes: 599 to 473. It has held 400-800 every month since 2022.
- Arcane Odyssey: 942 to 500.
- Build A Boat: 18,820 to 12,373.
- Tradelands: 72 to about 20.

#### How each handles cargo, boats and danger
| Game | Trade mechanic | Boat and phone | Threats |
|---|---|---|---|
| Arcane Odyssey | Crates cost 50 drachma and sit physically on deck. Sell value depends on the distance between ports (profit 6-70 per crate). A crew auto-unloads one crate per ~5 s. | Speed 30-75 studs/s by ship class. Seas are separate places: cargo moves below deck "when you load into the new sea". The game page says keyboard and mouse are required and 6 GB+ RAM is recommended. | NPC pirates, navy, sea monsters (cannot target players under level 40), weather. Notoriety can be cleared for drachma. |
| Tradelands | Cargo costs 30 doubloons; price depends on distance and rises with the pirate-to-trader ratio in the server. **Fish cargo**: trade caught fish for crates worth about 2-3x normal. The wiki says few players do it "due to how long it takes to fish". | One trade run is about 10 min 42 s. Wind direction changes every 3 real days. Phone support not found. | Player pirates steal cargo. Protections exist for players under level 10. |
| Shipping Lanes | Pay is the straight-line distance between ports times a port multiplier (0.87-1.3x). Oil is bought and sold at prices that move over time and with volume traded at each port. | Has phone controls (throttle lever and thumbstick). The starter route is 2 nm; later routes about 15 nm. | Rocks, shallow canals, fuel range. No enemies found. |
| Silk Road | Walk a caravan between 17 cities. Price is a base, plus city traits (5-10%), plus random events (every 30 min, lasting 1 hour, 2.5-10%). Buyable farms, mines and taverns earn offline. | No boats. An autowalk game pass exists. | None found. |
| Fisch / Fish It! | Fish sell to merchants; Fisch has 18. No place-based price is documented. Both sell a **"Sell Anywhere" pass (399 and 315 Robux)**, and Fisch sells "Spawn Boat Anywhere" (299). | Seated boats: Fisch 1-8 seats at 25-210 studs/s, Fish It! 1-10 passengers. | Not researched this run. |
| Build A Boat | No trade. A run is 11 stages of about 774 studs each, paying 8 gold per stage entered. | Player-built physics boats, 7-player servers. | Stage obstacles. |

SharkBite: technical details not found.

### Part 2: prices
- **Distance-based sell price** is the established pattern: Arcane Odyssey, Tradelands and Shipping Lanes all use it, per server, with static tables.
- **Demand-reactive price:**
  - Shipping Lanes oil reacts to volume traded. Players are told to "check the market mid journey" because a port may have "crashed". Whether this is per server is not stated; refined fuel stock is per server.
  - **Starscape spice** is the closest match to the idea. The buy price rises with distance and for colours from the opposite side of the map. Buying raises the price, and selling lowers it, "for all players in that system and in nearby systems". Runs continue "until it becomes unprofitable". The game averages 15 players.
- **Exploits:**
  - Starscape's cross-server player market has been "disabled by the devs because of bots and dupers" since March 2026, and was still off in July 2026.
  - Adopt Me's Trading Hub (2026-07-31) limits abuse with a 100 Bucks listing fee, two active listings, items locked while listed, listings visible only while the owner is online, and rejection of trades "detected as too unbalanced".
  - Tradelands' game page bans alt and bot farming.
- **Islands:** no dynamic prices found. Crate prices are fixed and changed by patch.
- **Roblox guidance:** the memory store docs name "cross-server auctioning" and a "live auction house" as intended uses. A developer write-up (July 2026) uses data stores as the source of truth, sorted-map order books with sharded keys, and a dead-letter queue.

### Direct answers

**(a) Is buy-here-sell-there proven fun?** No. It has stayed small.
- Every game where hauling is the main income sits under about 500 average players: Shipping Lanes, Tradelands, Silk Road, Starscape.
- The evidence does separate the two halves. Boats used as transport sit inside the two biggest fishing games (62-65K weekly average), and those games sell the removal of the sell trip.
- In Arcane Odyssey, cargo is a side activity that forum players call "the most boring activity in the game"; one says they "tab out of roblox" while sailing.
- No source shows why these games are small. Age, PC-only design and PvP are confounded with the trading.

**(b) Crossing time.**
- No big game publishes a target. Derived from Fisch wiki coordinates and boat speeds: Moosewood to Roslit is about 1,975 studs, so about 79 s in the first rowboat and 23 s in a speedboat. The speed table's wiki page is flagged outdated.
- Tradelands' roughly 10-minute run and Arcane Odyssey's long sails are the ones players complain about.
- What games do to fill the trip:
  - put fishing spots and exclusive deep-ocean fish along the way (Fisch);
  - pay per stage reached, not only on arrival (Build A Boat);
  - sell speed as the upgrade ladder (Fisch);
  - automate unloading and speed up unarmed ships (Arcane Odyssey);
  - sell a skip (Fisch, Fish It!, Silk Road autowalk).

**(c) One shared price per fish per port across servers.** Buildable. This is my calculation from the published limits, not a shipped example.
- At 300 concurrent players the memory store budget is 1,000 + 120 x 300 = 37,000 request units per minute, with 424 KB of memory.
- A 5-port, 40-fish table fits in one 32 KB value.
- Fifteen servers each doing one UpdateAsync (2 units) every 10 s use about 180 units per minute, roughly 0.5% of budget. The per-key write limit is about 5,000 per minute.
- **A 5-15 s update is comfortable.** Persist a snapshot to a data store each minute (write budget 6,300 per minute).
- Memory stores are not durable and failed platform-wide on 2026-11-17, so servers must fall back to the last known prices.

**(d) Safest boat on a phone.** Evidence, then opinion.
- The largest boat-using games seat their passengers. A Seat welds the character to the boat, and the Roblox docs example gives the driver network ownership.
- Deck-walking has engine support since 2018, with staff-listed caveats (vibration with some movers). A 2026 thread reports other players jittering on moving ships.
- A 2026 pirate MMO scrapped its deck-walking system because it "caused freezes and players getting thrown off"; it does not support mobile.
- Arcane Odyssey cargo placed in mid-air "will be unanchored and fling off".
- *Opinion:* use a small seated boat owned by the driver, show cargo as welded props that mirror a server-side count, and allow walking on deck only when docked.

**(e) Unproven.**
- Hauling as a core loop at scale.
- A global reactive price in a game with more than 15 players.
- Deck-walking on phones.
- A fishing game that makes players carry the catch.
- Pirates who can be paid off as a system; only Arcane Odyssey's notoriety buy-off was found.
- Server Authority (released July 2026) for boats.

### Sources
- Roblox games API: https://games.roblox.com/v1/games?universeIds=<id>
- Game passes: https://apis.roblox.com/game-passes/v1/universes/<id>/game-passes
- Trackers: https://rotrends.com/game/<id> and https://statroblox.com/games/<id>
- Archived Rolimons histories:
  - Arcane Odyssey: http://web.archive.org/web/20251229183153/https://www.rolimons.com/game/3272915504
  - Tradelands: http://web.archive.org/web/20260225182143/https://www.rolimons.com/game/198116126
  - Shipping Lanes: http://web.archive.org/web/20261030142857/https://www.rolimons.com/game/245440965
  - Build A Boat: http://web.archive.org/web/20261023030746/https://www.rolimons.com/game/537413528
- Wikis, read through api.php:
  - roblox-arcane-odyssey.fandom.com (Cargo, Guide: Cargo Runs, Ships, Ship Stats, Sea Monsters, Notoriety)
  - tradelands.fandom.com (Cargo, Cargo Prices, Trade Routes, Wind)
  - roblox-shipping-lanes.fandom.com (Shipping Lanes Tutorial, Oil, Cargo Types, Meta of Ships, Ports)
  - srtsimulator.fandom.com (Events & Traits, Properties, Update Logs)
  - silk-road-trading-simulator.fandom.com (Locations)
  - fischipedia.org/w/api.php (Boats, Merchant, Sell Anywhere, Ocean)
  - fisch.fandom.com (Boats)
  - fish-it.fandom.com (Boat Shop)
  - build-a-boat-for-treasure.fandom.com (Stages)
  - starscape-roblox.fandom.com (Spice, Player Marketplace, FAQ)
  - adoptme.fandom.com (Trading Hub)
  - robloxislands.fandom.com (Crate)
- Arcane Odyssey forum: https://forum.arcaneodyssey.dev/t/93151, /t/110049, /t/161819, /t/107378
- Roblox docs:
  - https://create.roblox.com/docs/cloud-services/memory-stores.md
  - https://create.roblox.com/docs/cloud-services/memory-stores/sorted-map.md
  - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits.md
  - https://create.roblox.com/docs/physics/network-ownership.md
  - https://create.roblox.com/docs/reference/engine/classes/Seat.md
- DevForum: https://devforum.roblox.com/t/183385, /t/4476777, /t/4860334, /t/4727993, /t/4993865, /t/2977379, /t/4754701

## Researcher's lessons (several are struck or narrowed by the check below)
- Evidence-backed: 'carry it there to sell it for more' has not carried a Roblox game past a few hundred concurrent players in the games found, while boats as transport sit inside the two largest fishing games. Treat trading as a layer on a loop that is already fun (fishing, upgrading, building), not as the reason to play.
- Evidence-backed: the two largest fishing games charge 315-399 Robux to skip the trip to the seller. A fishing game that forces the carry is going against what that audience currently pays to avoid; the design must make the carry rewarding in itself or keep it very short.
- Evidence-backed: long, empty crossings are what players complain about (Arcane Odyssey forum, Tradelands' 10-minute run and under-used fish cargo). The patterns that fill a trip are fishing spots and exclusive fish along the route (Fisch), pay per leg reached (Build A Boat), speed as the upgrade ladder, and automated unloading.
- Opinion: keep the first sell trip under about 90 seconds on the starter boat with a fishing spot or hazard on the way, and pay something at each leg, so the first minute on a phone is catching and steering, not waiting.
- Evidence-backed: a static distance-based price table per port is the established pattern (Arcane Odyssey, Tradelands, Shipping Lanes). A demand-reactive price shared beyond one server has one precedent (Starscape spice), in a game averaging 15 players.
- Evidence-backed: a shared price table for 5 ports is far inside published memory store limits at a few hundred players (about 0.5% of the request budget at a 10-second cadence, by my calculation), but memory stores are non-durable and failed platform-wide on 2026-11-17, so servers need a last-known-price fallback and a data store snapshot.
- Opinion: make ports buy fish from players only (no player-to-player order book at launch). Starscape's player market was shut down by bots and dupers; a sell-only sink limits what alt accounts can do to pushing a price down, which a per-player daily demand cap or slow price recovery can blunt.
- Evidence-backed: seated boats are what the biggest boat-using games ship, and deck-walking on moving hulls has documented jitter and has forced at least one 2026 rewrite on a PC-only game. Opinion: ship a small seated, driver-owned boat with cargo shown as welded props mirroring a server-side count; allow deck-walking only at dock until phone tests say otherwise.
- Evidence-backed: Silk Road added buyable properties with offline income four months after launch and still averages under 150; adding a tycoon layer to a trade-travel core did not by itself produce scale. Opinion: the tycoon and factory layers in this idea should be reachable early, since they are the proven retention genre, with the voyage as the supply line that feeds them.
- Evidence-backed: paying to clear hostile pursuit exists (Arcane Odyssey notoriety buy-off) and cannon-and-pirate games sit at Mild or below on trackers (Tradelands and Pilfering Pirates listed Mild, Shipping Lanes Minimal), so pirate threats do not by themselves break the Mild target. A full pay-off or befriend system for pirate factions was not found anywhere and would be new.

## Not found
- 30-day averages for Tradelands, Starscape, Be a Pirate, Ship The Cargo and Trading Tycoon (statroblox returned 403 after the first batch; 7-day and 14-day figures from rotrends used instead)
- True all-time peaks for SharkBite Classic, SharkBite 2, Pilfering Pirates and Starscape (tracker figures are window peaks only)
- Any developer statement on how Fisch, Fish It!, Arcane Odyssey, Tradelands, SharkBite or Build A Boat implement boats technically (physics constraints vs scripted movement, network ownership)
- Phone frame-rate or performance data for any boat game; Tradelands phone support
- Sea size in studs and crossing times in minutes for Arcane Odyssey and Shipping Lanes (only speeds in studs/s or knots and route lengths in nautical miles were found)
- Whether Shipping Lanes oil prices are per server or shared, and how Starscape implements its cross-system spice price
- Whether passengers can walk on deck under way in Fisch, Fish It!, Shipping Lanes or SharkBite (only seat counts found)
- Any Roblox game with supply-and-demand sell prices shared across all servers at more than a few hundred players
- Any farming game with rotating or demand-based sell prices (Islands uses fixed prices changed by patch; others not found)
- Any game where NPC pirates can be befriended or paid protection as a standing system
- Player reaction data (retention, reviews) specific to price mechanics in any of these games, beyond forum comments
- A Roblox staff post specifically walking through a cross-server price market (only the docs' auction-house mentions and the 2024 hash map announcement)
- Mechanics of Trading Tycoon and Ship The Cargo beyond their store descriptions
- How Fisch and Fish It! threaten boats at sea (not researched this run)

## Independent check

13 of 16 key facts confirmed.

### Facts corrected
- **partly wrong:** 1. Every Roblox game found where hauling goods between places is the main income averages under ~500 players (Shipping Lanes 346/473, Silk Road 114/146, Tradelands ~18, Starscape ~15).
  - Correction: The four 7-day figures check out on rotrends (345.35, 113.5, 17.94, 15.29). statroblox returned 403 to me, so the 30-day figures (473, 146) are unverified. The 'every game ... under ~500' claim fails three ways. (a) The brief's own table has Ship The Cargo (Roblox description: 'Deliver Cargo Across The Ocean ... Sell Your Cargo For Profit', created 2026-10-07, supports mobile) at 1,019 (7d) / 1.7K (14d), peak 6.6K. (b) Archived Rolimons monthly averages for Shipping Lanes are 529-838 for every month of 2026 (Oct 2026: 529), so it is not clearly under 500. (c) Haul-then-sell loops the brief did not look at are much larger: Storage Hunters: Open World (description: 'load up your vehicle ... drive back to your shop and sell'; 7d avg 10,428, peak 55.1K, 152M visits since June 2026) and Dead Rails (wiki: selling found items at Trading Posts every 10 km is the most common money source; 7d avg 19,314, peak 1.5M). Flight World ('deliver cargo ... earn cash') had 1,325 live. What the evidence supports is narrower: port-to-port price arbitrage as the core loop has only been found in small games.
- **partly wrong:** 12. Silk Road: Trading Simulator (created 2026-02-13, 4.53M visits, peak 1,601): base price plus city traits (5-10%) plus events every 30 min lasting 1 h (2.5-10%); added buyable farms, mines and taverns with offline income on 2026-06-12; sells an autowalk pass; averages 114-146.
  - Correction: Price mechanics, visits (4.53M), peak (1.6K) and 7d average (113.5) confirmed. Three errors: (1) the Roblox API creation date is 2026-02-13, but the wiki update log has dated entries back to 2026-01-09, so the game was live before that date and 'four months after launch' is an underestimate; (2) the 6/12/2026 log entry lists only taverns and mines as properties; farms and apiaries appear on the Properties page by August; (3) autowalk has been free since 2026-03-06; the pass is 'Auto-Walk Speed Boost' at 149 R$. 30d figure 146 unverified (statroblox 403); rotrends 14d is 129.5.
- **wrong:** Lesson 10 / answer (e): a pay-off or befriend system for hostile factions was not found anywhere on Roblox beyond Arcane Odyssey's notoriety buy-off.
  - Correction: Deepwoken (4,274 live, 1.66B visits) has exactly this as a system: per-faction reputation from -300 to 300 with Villain/Hated/Enemy/Neutral/Friend/Ally/Hero tiers, faction NPCs that attack on sight when you are an Enemy, faction ambushes when Hated, and Bribe NPCs you pay to reset reputation (not available at Villain). Starscape has faction standing from Enemy to Hero across several factions, though its NPC pirates are always hostile. Arcane Odyssey's notoriety buy-off is confirmed (points x 0.1 drachma, 20 to 900). What is not found is that system applied to sea pirates specifically; the mechanic itself is not new.

### Conclusions that go beyond the evidence
- Lesson 1 and answer (a) ('No. It has stayed small'; 'has not carried a Roblox game past a few hundred'): the sample is four games, three of them 9-12 years old, and the brief itself says age, PC-only design and PvP are confounded. Its own table lists Ship The Cargo at 1.0K-1.7K, and haul-then-sell loops sit inside Storage Hunters: Open World (10.4K 7d average) and Dead Rails (19.3K). The supportable claim is narrower: distance-based price arbitrage as the main loop has no large example. 'Hauling as a core loop at scale' should come off the Unproven list.
- Lesson 2 ('going against what that audience currently pays to avoid'): the evidence is that the passes exist and their prices. No sales counts were fetched, so nothing shows how many players buy them. A pass that skips the walk to a merchant also does not show that a rewarded voyage would be rejected; it equally shows the sell trip is friction worth monetising.
- Lesson 3 ('long, empty crossings are what players complain about'): rests on four Arcane Odyssey forum threads plus one wiki trivia line for Tradelands. The same AO thread has players calling cargo 'profitable and easy'. The Tradelands 10 min 42 s figure is one editor's single timed route, and no Tradelands player complaint about run length was sourced.
- Lesson 5 ('static distance-based price table is the established pattern'): two of the three examples are not static. Tradelands prices move with the number of pirates in the server and Shipping Lanes oil is market-based. 'One precedent' for shared reactive prices means one found in a short search; Starscape's cross-server scope is itself inferred from wiki wording.
- Lesson 6 ('failed platform-wide'): the outage was about one hour and partial (Get and Update failed; Set and GetRange worked). The fallback recommendation still follows, but the event supports 'plan for an hour of read failures', not a general unreliability claim. The 0.5% budget figure depends on a 2-unit UpdateAsync cost that was not sourced.
- Lesson 7: the Starscape shutdown is a one-line wiki FAQ note about a player-to-player order book; it says nothing about NPC sell-only sinks. That a sell-only port limits alt abuse to pushing prices down is reasoning, not evidence, and pushing a shared price down for everyone is itself a griefing vector the brief does not weigh.
- Lesson 8 ('seated boats are what the biggest boat-using games ship'; 'deck-walking ... has forced at least one 2026 rewrite'): true for Fisch and Fish It!, but Build A Boat (about 12K), Pilfering Pirates (1.18B visits, about 1.3K) and Tradelands/Arcane Odyssey all put walking players on moving vessels, and the 2018 engine feature was built for that. The rewrite example is a solo beta with 1,797 visits. 'Deck-walking on phones is unproven' was not tested: no one checked whether Pilfering Pirates or Build A Boat run on mobile.
- Lesson 9 ('adding a tycoon layer to a trade-travel core did not by itself produce scale'; 'tycoon ... the proven retention genre'): one game, no before/after player numbers around 2026-06-12, and the launch date used is wrong (wiki log starts January 2026). Nothing in this brief evidences that tycoons are the proven retention genre; that is imported from elsewhere and should be labelled so.
- Lesson 10 ('a full pay-off or befriend system for pirate factions was not found anywhere and would be new'): Deepwoken has faction reputation tiers, attack-on-sight enemies, ambushes and paid bribes to reset standing; Starscape has Enemy-to-Hero faction standing. Only the pirate skin on it is unfound.
- Table note: the brief's 'like-month' line for Shipping Lanes ('held 400-800 every month since 2022') contradicts its own key fact 2 and the archive (219-398 in many 2022-23 months).

### What the brief missed
1) Ship The Cargo (universe 10769735087) is the closest live comparison and was only a table row: a sea cargo delivery game with hazards, launched 2026-10-07, mobile supported, 12-player servers, 3.07M visits, peak 6.6K, 18-minute sessions, but already decaying fast (14d 1.7K, 7d 1,019, 316 live). It shows the pitch can pull a launch spike in 2026 and also that it did not hold for six weeks; its mechanics deserve a proper read. 2) Storage Hunters: Open World (universe 10261267004; June 2026, 152M visits, 7d average 10,428, 31.8-minute sessions, 8-player servers, All Ages) is a strong current precedent for 'goods are physical things you load into a vehicle and drive back to sell', with a shop-upgrade tycoon on top. That is the brief's 'real cargo, not menus' idea working at scale, without place-based prices. 3) Dead Rails (7d 19.3K, peak 1.5M): income is selling what you carry on the train at the next Trading Post every 10 km, so 'pay at each leg of a journey' has a much bigger precedent than Build A Boat. It is rated 13+ on rotrends, so not a maturity model. 4) Arcane Odyssey spiked to 24,078 on 2025-12-26 before returning to about 455, so its curve is update-driven spikes, not a single decay. 5) Trackers disagree on Shipping Lanes: Rolimons monthly averages for 2026 are 529-838 against statroblox's 473; statroblox returned 403 to me on every attempt (curl, page fetcher, browser), so none of the brief's 30-day figures were independently checked. 6) Fisch already makes every non-paying player carry the catch (in inventory) to one of 18 merchants; the untested parts of the idea are the physical hold and a price that depends on which port, not carrying as such. 7) Trading Tycoon (7d 2,171, 'buy low, sell high') was listed but its mechanic was never read; if it involves travel between markets it is another counter-example to answer (a), and if not it should be dropped from the table. Scratch files only: (session scratchpad) (wiki sources, archived Rolimons pages, forum JSON).


---
