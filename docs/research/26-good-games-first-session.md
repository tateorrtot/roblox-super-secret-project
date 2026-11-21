# What a player's first session must do

Asked: what Roblox says about a new player's first minutes, how long-lived sandbox games start a player, what numbers exist for early leaving, what is known about phones, and what developers say they fixed.
Made by one reader on Sonnet, 2026-11-21, from Roblox's own docs and staff forum posts, forum threads by developers, one trade-press article on Roblox's annual report, and guide sites. The games' own wikis could not be opened (Fandom returned HTTP 402), so the per-game part rests on guide sites only.

## What the sources say

### 1. Roblox's own guidance
- Onboarding (also "FTUE") is "the first few minutes" of play. Success is measured by Day 1 retention and by onboarding goals. Page last updated 2026-11-20. https://create.roblox.com/docs/en-us/production/game-design/onboarding.md
- Day 1 retention is gauged by how many players get through the FTUE, which the page calls the Player Funnel. It narrows at each step and every game loses some players. Same page.
- Three goals: teach the essentials (controls and the core loop, what to do and why); get to the fun quickly; leave players wanting more (short, mid and long-term goals, and a deliberate high point at the end). Same page.
- "Players usually decide within minutes whether they like a game." Suggested levers: low early XP thresholds, starter items or soft currency, matchmaking tests. Same page.
- The page gives no numeric targets. Same page.
- Three techniques: visual elements (arrows, highlights, footprints, in-world signs), contextual "just-in-time" tutorials, and timed hints for players who seem stuck. Updated 2026-11-20. https://create.roblox.com/docs/en-us/production/game-design/onboarding-techniques.md
- Timed-hint example from the Roblox example game Plant: most players press the plant button within 10 seconds, so a highlight appears at 11 seconds. Hints show only the first time and only to players who need them. Same page.
- Squishmallows example: the combine tutorial shows when a player holds two identical items, not during onboarding, "too early and forgettable". Same page.
- Analytics docs: joining and leaving is low effort, so first impressions weigh heavily; users should have fun "within the first five minutes". Teach with short contextual prompts and tooltips, not long tutorials. Updated 2026-11-20. https://create.roblox.com/docs/en-us/production/analytics/engagement.md
- The New User First Session Retention chart shows how many new users are still playing X minutes after joining. If the five-minute share falls week on week, check recent onboarding changes and error and performance reports. Same page.
- Retention docs: D1, D7 and D30 are measured; the FTUE "should ideally" reach the fun within 5 minutes. Updated 2026-11-20. https://create.roblox.com/docs/en-us/production/analytics/retention.md
- Staff post (Developer Relations, posted 2023-09-28, updated 2023-12-07) introduced the FTUE article and the three techniques. It gives no benchmarks. https://devforum.roblox.com/t/learn-more-about-first-time-user-experience-onboarding/2621940
- Staff post, "Improving Onboarding through Funnel Events" (2024-07-12, updated 2024-09-24): log an event at each onboarding step and look for the step where players leave. Example funnel for Plant: step 1 (in farm) 100%, step 2 (plant seed) 29.52%, final step (step 9) under 3%. The author attributes the first drop to an unclear goal and planting process; adding an icon over the pots fixed it. https://devforum.roblox.com/t/improving-onboarding-through-funnel-events/3064458
- Roblox's own LiveOps page has nothing on new players or first sessions. https://create.roblox.com/docs/en-us/production/game-design/liveops-essentials.md

### 2. How long-lived sandbox and building games start a player
The wikis could not be read. Everything below is from guide sites, which are second best or worse. Each is marked.
- Lumber Tycoon 2: a guide says the player is dropped in with $20, no axe and almost no instructions; the first buy is a $12 Basic Hatchet; chop trees near the wood drop-off and sell. Aggregator page, no date seen, figures unchecked. Found by search; page address: https://allthings.how/lumber-tycoon-2-how-to-get-your-first-axe-and-sell-wood/ (not opened; snippet only).
- Welcome to Bloxburg: a player can begin on empty land or in a ready-built house; the guide lists collecting a daily reward, starting a job from the Jobs app or by walking into a workplace, then Build Mode to place a bed, shower, fridge, and a TV or computer. It does not say the starting money and does not describe an in-game tutorial. Last checked 2026-11-07. https://rolearn.dev/guides/welcome-to-bloxburg/ (a tool-vendor guide, second-hand).
- Build a Boat for Treasure: boats are built in a designated area from blocks from chests or missions; press Launch; distance earns gold, which buys chests for blocks. Guide advises small test boats first. 2025-04-01. https://www.bluestacks.com/blog/game-guides/roblox/beginners-guide-build-a-boat-for-treasure-roblox-en.html
- Plane Crazy: a Sportskeeda guide says a new player lands at a random base plot, confused, and there is an optional tutorial. Snippet only; page not opened (HTTP 405). https://sportskeeda.com/roblox-news/beginner-s-guide-roblox-plane-crazy
- Booga Booga: guides say the player gathers wood, stone and food to make tools, armor and weapons. Nothing found on hunger or the first ten minutes. https://earnaldo.com/blog/booga-booga-reborn-beginner-guide (new self-described beta site).
- Islands: two guide sites describe farming, crafting, selling and NPC merchants. Nothing on the opening quests. https://deltiasgaming.com/?p=251096
- No source gave a first-ten-minutes account for any of the six from the game's developers.

### 3. Numbers for early leaving
- No Roblox-published figure for first-minute, five-minute or first-session leaving was found. The engagement docs describe the chart but give no values. https://create.roblox.com/docs/en-us/production/analytics/engagement.md
- Developer reports (single games, not platform figures):
  - A mining game, posted 2025-12-26: title says D1 23% and "losing half my players in under 2 minutes"; body says "30% of traffic in the first minute". The metrics are not defined. Replies named cluttered UI, a cheap-looking store page, an unclear next click, and a crowded genre. https://devforum.roblox.com/t/my-day-1-retention-is-awful-23-losing-half-my-players-in-under-2-minutes-what-am-i-doing-wrong-with-onboarding/4186434
  - A racing-and-pets game, posted 2025-03-13: average session about 10 minutes; about 25% leave before hatching a pet, which the tutorial prompts seconds into the race; about 19% leave before buying a hammer. No replies. https://devforum.roblox.com/t/high-early-funnel-drop-off/3548159
  - Plant (Roblox's own example, 2024-07-12): 70.48% leave between step 1 and step 2. See question 1.
- Unsourced figures exist: RoWatcher says the cliff is "the first 90 seconds"; rolearn.dev says each second of non-gameplay in the first five minutes costs 2-3% of a cohort. Neither cites data (RoWatcher page checked: no number cited, no date). https://rowatcher.com/news/your-first-90-seconds-are-destroying-roblox-retention

### 4. Players on phones
- Roblox's 2024 annual report, as reported 2025-04-23: 82.9 million daily users, 80% on mobile, 17% PC, 3% console; 56% aged 16 or under. http://www.pocketgamer.biz/80-of-roblox-users-are-on-mobile-contributing-46-of-robux-revenue/ (second-hand; the report itself was not opened).
- Hardware docs (updated 2026-11-20): Android is roughly 65% of a typical game's players; about 60% of those have 2-4 GB RAM, 35% have 4-8 GB, 5% over 8 GB; over 50% of players are on devices scoring 10,000-20,000 on Passmark. Test text size, icon clarity and contrast on the lowest-supported device at arm's length. Time join-to-gameplay on a baseline device; if loads exceed "a few seconds", consider instance streaming. https://create.roblox.com/docs/en-us/performance-optimization/test-on-hardware.md
- Adaptive design docs (updated 2026-11-20): use font sizes readable on mobile, avoid thin or decorative fonts, test on real devices, move less important buttons into a menu, let UI follow players' text-scale settings. No touch-target sizes or numbers. https://create.roblox.com/docs/en-us/production/publishing/adaptive-design.md
- Input docs: use input actions, read the player's PreferredInput to adapt on-screen buttons; default orientation is landscape. https://create.roblox.com/docs/en-us/input/mobile.md
- Onboarding visuals "suit small mobile screens" and work across languages. https://create.roblox.com/docs/en-us/production/game-design/onboarding-techniques.md
- A developer asked why new players load in 90 s against 10-15 s for returning players (search snippet; thread not opened). https://devforum.roblox.com/t/players-joining-and-leaving-my-game/4810038
- No source gave where phone players drop out in the first session, or phone-versus-PC leave rates.

### 5. What developers say they got wrong
- A Gamefam founder (TechCrunch, 2021-03-26): removing the tutorial in Speed Run Simulator gave "a significant increase in D1 retention"; existing players guide new ones. No percentage given. He says mobile-style long tutorials fail because Roblox players want "immediate, visceral fun". https://techcrunch.com/?p=2129906
- Plant funnel: unclear goal, fixed with an icon (2024). https://devforum.roblox.com/t/improving-onboarding-through-funnel-events/3064458
- Mining game replies: too much UI on screen, unclear where to click (2025-12). See question 3.
- A third poster in a thread (2024) said the old tutorial caused a fall in five-minute retention, with no before-and-after numbers (search snippet only). https://devforum.roblox.com/t/improving-new-user-engagement-on-my-game/2947546
- No sandbox or building game's own developers were found describing an onboarding fix.

## Where the sources disagree, or are weak
- Roblox's docs say to teach the core loop and use tutorials with hints; Gamefam's founder says removing the tutorial raised D1. Both are shown; neither has a number for the tutorial effect.
- Roblox says "within the first five minutes" for fun. Third-party sites say 90 seconds. Only the first is first-hand, and it is a goal, not a measurement.
- The mining post's 23%, "half in 2 minutes" and "30% in the first minute" do not agree and are undefined.
- All leave figures are one game each. None is a Roblox-wide figure.
- The per-game section rests on guide sites, several of them low quality. Starting money and tutorial details are unverified.
- The 80% mobile figure is 2024, second-hand. Android share (65%) is "of a typical game", with no date beyond the page.

## What follows for someone building such a game
1. Log an event at each step of the first minutes and read the funnel; Roblox's own method and its Plant example (question 1).
2. Make the first goal visible in the world, since an unclear first step cost 70% of Plant's players (question 1, 3).
3. Put the player in the fun by about five minutes; that is Roblox's stated target (question 1).
4. Teach later features when the player meets them, not up front (question 1, contextual tutorials).
5. If a player stalls, show a hint after most players would have finished; do not show it to all (question 1, timed hints).
6. Keep the screen's UI small in the first minutes; replies on the mining game blamed clutter (question 3, 5).
7. Test text and icons on a low-end phone at arm's length, and time join-to-play (question 4).
8. Plan for phones: 80% of daily users in 2024 were on mobile (question 4).
9. A tutorial can lose to no tutorial; measure both with Roblox's Experiments before building a long one (question 1, 5).
10. Do not expect a benchmark to judge the numbers by; none was found (question 3).

## Not found
- Any Roblox-published first-minute, five-minute or first-session leave rate.
- A platform-wide D1 benchmark.
- Developer-written first-ten-minutes descriptions for Lumber Tycoon 2, Bloxburg, Build a Boat, Plane Crazy, Booga Booga, Islands (wikis unreadable).
- Starting money in Bloxburg; hunger and early crafting in Booga Booga; Islands' opening quests.
- Phone-versus-PC leave rates, or where phone players leave in the first session.
- Touch-target sizes or text sizes in numbers.
- Sandbox developers' own accounts of onboarding mistakes and fixes.
- Roblox talks (RDC) on onboarding: not searched in a way that returned any.
- Text of the forum threads on 4186434, 3548159 and 2947546 beyond what was returned; /raw/ addresses returned nothing, the .json addresses worked for some.

## Sources
- https://create.roblox.com/docs/en-us/production/game-design/onboarding.md (2026-11-20)
- https://create.roblox.com/docs/en-us/production/game-design/onboarding-techniques.md (2026-11-20)
- https://create.roblox.com/docs/en-us/production/analytics/engagement.md (2026-11-20)
- https://create.roblox.com/docs/en-us/production/analytics/retention.md (2026-11-20)
- https://create.roblox.com/docs/en-us/production/game-design/liveops-essentials.md (2026-11-20)
- https://create.roblox.com/docs/en-us/performance-optimization/test-on-hardware.md (2026-11-20)
- https://create.roblox.com/docs/en-us/production/publishing/adaptive-design.md (2026-11-20)
- https://create.roblox.com/docs/en-us/input/mobile.md (2026-11-20)
- https://devforum.roblox.com/t/learn-more-about-first-time-user-experience-onboarding/2621940 (2023-09-28)
- https://devforum.roblox.com/t/improving-onboarding-through-funnel-events/3064458 (2024-07-12)
- https://devforum.roblox.com/t/high-early-funnel-drop-off/3548159 (2025-03-13)
- https://devforum.roblox.com/t/my-day-1-retention-is-awful-23-losing-half-my-players-in-under-2-minutes-what-am-i-doing-wrong-with-onboarding/4186434 (2025-12-26)
- https://devforum.roblox.com/t/improving-new-user-engagement-on-my-game/2947546 and https://devforum.roblox.com/t/players-joining-and-leaving-my-game/4810038 (search snippets only)
- https://techcrunch.com/?p=2129906 (2021-03-26)
- http://www.pocketgamer.biz/80-of-roblox-users-are-on-mobile-contributing-46-of-robux-revenue/ (2025-04-23)
- https://rolearn.dev/guides/welcome-to-bloxburg/ (2026-11-07); https://rowatcher.com/news/your-first-90-seconds-are-destroying-roblox-retention (undated)
- https://www.bluestacks.com/blog/game-guides/roblox/beginners-guide-build-a-boat-for-treasure-roblox-en.html (2025-04-01)
- https://allthings.how/lumber-tycoon-2-how-to-get-your-first-axe-and-sell-wood/, https://sportskeeda.com/roblox-news/beginner-s-guide-roblox-plane-crazy, https://earnaldo.com/blog/booga-booga-reborn-beginner-guide, https://deltiasgaming.com/?p=251096 (search snippets or guide sites, undated)

## Checked by a second reader
Second reader (Sonnet), 2026-11-21. Sources opened with a page fetch; DevForum threads read as .json.
- Claims checked: 22. Confirmed: 16. Wrong: 3. Unconfirmed: 3.
- Confirmed (numbers and Roblox statements): Plant 10 s hint at 11 s; three goals; three techniques; first five minutes (docs updated 2026-11-20); Android 65%, RAM 60/35/5%, Passmark 10,000-20,000; Plant funnel 100%, 29.52%, under 3%, icon fix (posted 2024-07-12, updated 2024-09-24); staff post 2023-09-28, no benchmarks; racing game 10 min, 25%, 19%, 0 replies (2025-03-13); mining post 23%, "under 2 minutes", "30% ... first minute" (2025-12-26); pocketgamer 82.9 m, 80/17/3, 56% (2025-04-23); Gamefam, no percentage (2021-03-26); adaptive-design has no touch-target numbers; mobile.md input actions, PreferredInput, landscape; LiveOps page has no onboarding text; RoWatcher gives no data and no date.

### Wrong
- Brief: "Players usually decide within minutes whether they like a game." in quotation marks (section 1). Source: "New players typically decide their interest in a game within minutes." The meaning is the same. The quoted words are not the page's words. https://create.roblox.com/docs/en-us/production/game-design/onboarding.md
- Brief: retention docs say the FTUE "should ideally" reach the fun within 5 minutes (section 1). Source: the page says to avoid a complex or time-consuming first-time experience, getting users to the fun "ideally in 5 minutes or less". "Should ideally" is not in the page. https://create.roblox.com/docs/en-us/production/analytics/retention.md
- Brief: "A third poster in a thread (2024) said the old tutorial caused a fall in five-minute retention" (section 5). Source: the poster is the thread's original poster, Cort2, in a reply dated 2024-06-25: "The problem came down to the old tutorial and the lack of players." The opening post is dated 2024-04-27. The figures are in screenshots only. https://devforum.roblox.com/t/improving-new-user-engagement-on-my-game/2947546
- Smaller: the brief says the engagement page advises a check "if the five-minute share falls week on week". The page says "decreased significantly". Same meaning, but "significantly" is missing. https://create.roblox.com/docs/en-us/production/analytics/engagement.md

### Unconfirmed
- Squishmallows "too early and forgettable" (section 1, in quotation marks). The page text returned by the fetch shows the trigger (two identical Squishmallows in the inventory) but not these words. Not found in what was returned. https://create.roblox.com/docs/en-us/production/game-design/onboarding-techniques.md
- "Onboarding visuals 'suit small mobile screens'" (section 4, in quotation marks). The fetch returned only "text can be too small to read comfortably" on mobile. The quoted words were not found. Same address.
- "Mobile-style long tutorials fail" (section 5, Gamefam). TechCrunch says mobile-style mechanics needing ongoing tutorials "tend to backfire" on Roblox, and that a mobile tutorial is a big investment. It does not say "long tutorials fail". Partly supported. https://techcrunch.com/?p=2129906
- Not re-opened: the guide-site claims in section 2 (Lumber Tycoon 2, Bloxburg, Build a Boat, Plane Crazy, Booga Booga, Islands), rolearn.dev "2-3% per second", and the 90 s load thread 4810038. The brief already marks these as snippets or second-hand.

### Lines of "What follows" that go further than the evidence
- Line 2: "an unclear first step cost 70% of Plant's players". The post says 70.48% left between step 1 and step 2 and that the cause is "mainly" an unclear goal or process, "assuming no game-breaking bugs". The post gives no figure for how many players the icon brought back. The cause is the author's guess. Plant is Roblox's own example game, not a measured live game. https://devforum.roblox.com/t/improving-onboarding-through-funnel-events/3064458
- Line 6: "Keep the screen's UI small ... replies blamed clutter". Two replies in one thread (Clear and upz) said the UI was cluttered. The thread's own D1 figure is undefined. One game, two opinions.
- Line 9: "A tutorial can lose to no tutorial; measure both with Roblox's Experiments". The one case for "no tutorial" is a founder's statement with no number (Speed Run Simulator). The Roblox pages name Experiments for testing tutorial step designs (shorter dialogue against a guided arrow, hint delays). They do not name tutorial against no tutorial. Experiments runs 14 to 60 days per the search summary of https://create.roblox.com/docs/production/experiments (that page was not opened by this reader; its fetch address returned 404 for the .md form).
- Line 8: "Plan for phones: 80% of daily users in 2024 were on mobile". The figure is correct (pocketgamer.biz, 2025-04-23). It is for the platform. The brief's own "Not found" says no phone-specific drop-out data exists. Android 65% is "of a typical game", so it is not this game's mix.
- Line 3: "Put the player in the fun by about five minutes". Roblox says "ideally in 5 minutes or less" and "within the first five minutes". It is a goal with no data behind it. The brief says so in its disagreement section. The line does not.
- Line 5: "show a hint after most players would have finished". The Plant example does this, with a "most players within 10 seconds" figure from Roblox's own example. No source says the same delay suits another game.
