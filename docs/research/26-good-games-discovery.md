# What decides whether Roblox shows a game to players

Asked: what Roblox itself says decides whether a game is shown on Home and in recommendations, what a new game gets, what analytics define as good, and how thumbnails, friends and private servers matter.
Made: one reader on Sonnet, 2026-11-21. It rests on Roblox's creator docs (.md pages), one DevForum staff announcement, one Roblox newsroom post, and web-search summaries. No video or third-party site was used. Page text was read through a fetch tool that summarises; quotes are as that tool returned them.

## What the sources say

### 1. Signals Roblox names for Home ("Recommended for You", RFY)
- Two stages. Retrieval picks games a user might enjoy. Ranking orders them for that user. https://create.roblox.com/docs/en-us/discovery.md (page last_updated 2026-11-20)
- Most important signals, as the docs name them: "Play through rate", "First play bounce rate" (a negative signal, tracked under 60 seconds and 61-180 seconds), "Play days per user" (Day 1, Day 2-7, Day 8-28), "Playtime per user" (capped at 60 minutes per user, per game, per day). https://create.roblox.com/docs/en-us/discovery.md
- Important signals: "Intentional co-play days per user" (joins, invites, private servers), "Qualified play sessions per user", "Spend days per user", "Robux spent per user". https://create.roblox.com/docs/en-us/discovery.md
- Signals are averages per user, not totals, so small games with engaged users are not disadvantaged. No single signal decides. https://create.roblox.com/docs/en-us/discovery-faq.md
- Signals are measured only for users who joined from the RFY sort on Home. Users first acquired from ads, curation, friends, search, social media or any other source are left out of the ranking stage. https://create.roblox.com/docs/en-us/discovery.md
- Genre and category tags are not explicit ranking factors. https://create.roblox.com/docs/en-us/discovery-faq.md
- Most signals update within 24 hours. A signal change shows in impressions a few days later (staff example: a dip on Feb 28 gave an impression drop on Mar 3). Over 90% of traffic begins on Home. https://devforum.roblox.com/t/boost-your-discovery-with-the-improved-recommended-for-you-algorithm-and-analytics-for-creators/3587441 (staff post 2025-03-31, edited with an update dated 2025-12-11)
- The 2025 announcement named the signals differently: "Qualified play-through rate (qPTR)" (engaging plays divided by RFY impressions), "7-day playtime per user", "7-day play days per user", "7-day spend days per user", "7-day Robux spent per user", "7-day intentional co-play days per user". Same post, 2025-03-31. Update 2025-12-11: play sessions in reserved servers now count as intentional co-play.
- Newsroom, 2026-06-15: Roblox widened the algorithm's view from 7 to 28 days (day 1, day 2-7, day 8-28). It split the old qualified play-through rate into separate signals for play-through behaviour, session quality, and spend. It gives no weights. It says long-term retention "was always an important signal". https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox
- Four things move impressions: your updates, Roblox algorithm changes, total Home traffic and seasonality (Saturdays, summer, back-to-school, holidays), and how other games perform. https://create.roblox.com/docs/en-us/discovery.md
- Where to see your signals: Creator Analytics > Overview, and Analytics > Acquisition > Home Recommendations. https://create.roblox.com/docs/en-us/discovery-faq.md

### 2. A new game
- No 28-day wait. Early signals count at once: first-session play-through rate and bounce rate, then Day 1, Day 2-7, Day 8-28. https://create.roblox.com/docs/en-us/discovery-faq.md
- The system explores and expands. A spike of new users from recommendations is tested. If they engage well, the game is shown to similar groups of users. https://create.roblox.com/docs/en-us/discovery.md
- Weak early results are not penalised. The algorithm keeps testing with new users daily and recalibrates if retention is poor. https://create.roblox.com/docs/en-us/discovery-faq.md
- Roblox says friends, teleport, notifications, curated games and social sharing "can accelerate your consideration" for RFY, and that "a small number of people playing" can signal a game is worth considering. No count is given. https://create.roblox.com/docs/en-us/discovery.md
- Old games can re-enter testing with "a low minimum number of plays from any source". No number is given. https://create.roblox.com/docs/en-us/discovery-faq.md
- A custom thumbnail is required. A game with only the default thumbnail is not eligible for Home recommendation impressions. https://create.roblox.com/docs/en-us/discovery.md
- The 2025 announcement does not address new or cold-start games. https://devforum.roblox.com/t/boost-your-discovery-with-the-improved-recommended-for-you-algorithm-and-analytics-for-creators/3587441

### 3. Analytics definitions and benchmarks
- D1, D7, D30 retention: share of new users who return on the next day, the 8th day (Day 7), the 31st day (Day 30). Users are grouped in cohorts by first play date. https://create.roblox.com/docs/production/analytics/retention.md
- The analytics guide adds what a low value may mean (D1: onboarding; D7: weak progression; D30: no end-game). It gives no numbers for "good". https://create.roblox.com/docs/en-us/production/analytics/get-started.md
- Average session length: how long a player plays from session start to logout. No number for "good". Same page.
- Roblox's only time targets: reach the fun "ideally in 5 minutes or less" (retention page); active spenders need 10 minutes of play for Daily Engagement Rewards (get-started page).
- Benchmarks: "similar" games with at least 100 daily active users. Each KPI shows a 50th to 90th percentile range. Example from the docs: Day 1 retention 12.11% to 18.73% means 50% of similar games are at or below 12.11% and 10% are at or above 18.73%. Falls back to genre, then all experiences. Updated daily. https://create.roblox.com/docs/en-us/production/analytics/analytics-dashboard.md (the 12.11/18.73 figures are an example, not a measured norm)
- Overall-success benchmark: top 1,000 games by playtime over a rolling 30 days, games under 30 days old excluded. Tiers: Top 200, Top 500, Top 1,000. Same page.
- Benchmarks do not affect RFY ranking. https://create.roblox.com/docs/en-us/discovery-faq.md
- Conversion rate is defined as "Percent of new users who played your game after viewing an impression." https://create.roblox.com/docs/production/analytics/acquisition.md

### 4. Thumbnails, icons, titles, pages
- Thumbnails show on Home and at the top of the experience page. Up to 10 images or videos. 16:9, ideally 1920x1080. https://create.roblox.com/docs/en-us/production/publishing/thumbnails.md
- Personalisation: needs at least 2 active thumbnails (2 to 5 advised). It shows each to random users, then gives more impressions to the best one per user group. The metric is qualified play-through rate (qualified plays divided by Home impressions). Roblox reports an average rise of 8.5% in testing, up to 50% for some games. No date is shown on the page. Same page.
- Advice there: show what players will find, keep key content off the bottom edge (player count may cover it), refresh on major updates.
- Icons: square, at least 512x512. Shown at about 150x150 in some places. "Often a user's first impression." The page says nothing of ranking or conversion. https://create.roblox.com/docs/en-us/production/publishing/experience-icons.md
- Titles and metadata: titles implying money rewards (giveaways) are not prioritised. Metadata that mismatches gameplay, or irrelevant keywords, reduce visibility. https://create.roblox.com/docs/en-us/discovery.md
- Games close to existing ones are deprioritised. Thumbnails, titles or gameplay "virtually indistinguishable" from others can reduce discoverability. Reusing your own old thumbnails is fine. https://create.roblox.com/docs/en-us/discovery.md and discovery-faq.md
- Newsroom 2026-06-15 says over-weighting short-term engagement favoured games with "exciting thumbnails" that did not hold players. This is why the window was widened. https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox
- Reduced exposure shows as a banner in Creator Dashboard, updated daily. https://create.roblox.com/docs/en-us/discovery-faq.md

### 5. Friends, groups, private servers, joining a friend
- "Friends" is an acquisition source meaning the Friend Activity section on Home. https://create.roblox.com/docs/production/analytics/acquisition.md
- Users from Friends do not count in RFY ranking signals (see 1). Intentional co-play days (join, invites, private servers, and from 2025-12-11 reserved servers) do count as an "important" signal.
- Invite prompts let a player invite friends; invited friends get a notification. The docs give no number for how many players this brings. https://create.roblox.com/docs/en-us/production/promotion/invite-prompts.md
- The 2025 announcement advises adding invite prompts and private server options to encourage co-play. Same devforum post as above.
- Private servers: a creator tool; a monthly Robux fee; Roblox Plus subscribers get them free and the creator earns up to 100 Robux per subscriber per month. The page says nothing of discovery. https://create.roblox.com/docs/en-us/production/monetization/private-servers.md
- Newsroom 2026-06-15: players bringing friends back is cited as a sign a game gives a meaningful experience. No figure.
- Groups: only that group-owned game analytics need group permission. https://create.roblox.com/docs/production/analytics/acquisition.md

## Where the sources disagree, or are weak
- Signal names changed. 2025 post: qPTR and 7-day windows. 2026 docs: "Play through rate", bounce rate, Day 1 / 2-7 / 8-28. The 2026-06 newsroom post says qPTR was split. The 2025 post may now be out of date; its table was not seen in a revised form.
- Friends: the discovery page says friends "can accelerate" consideration, yet friend-acquired users are excluded from ranking. Roblox does not say how both hold. The reader did not resolve it.
- Playtime cap: 60 minutes per user per day appears in both the docs and the 2025 post. Agree.
- The docs give percentile ranges but no stated "good" retention figure. The 12.11% and 18.73% (and a 12.4% / 24.1% pair seen in a search summary) are examples and differ.
- The discovery docs list "most important" and "important" signals but no weights.
- Several pages were read through a summarising fetch tool, not as raw text. The DevForum announcement was read as a summary of the page. Thumbnail-page numbers (8.5%, 50%) have no date.
- A search summary said a forum reply claims playtime beyond 60 minutes gives no extra benefit. That matches the docs' cap, but the forum reply itself was not read.

## What follows for someone building such a game
Only what the sources state or directly imply.
1. Ranking is per-user averages, so a small game with engaged players is not at a disadvantage (finding 1).
2. Returns over days 1, 2-7 and 8-28 are named signals, and weak early days make strong later days unlikely (finding 1, FAQ).
3. Playtime past 60 minutes a day per user adds nothing to ranking (finding 1).
4. A custom thumbnail is required before Home impressions are possible (finding 2).
5. A new game is tested at once and is not penalised for a weak start (finding 2).
6. Play with friends via invite, join, private or reserved server counts as a signal, so those features feed ranking (finding 1, finding 5).
7. Friends, ads and search can bring first plays, but those users do not count for RFY ranking (findings 1 and 5).
8. A near-copy of another game's look or gameplay can lose reach (finding 4).
9. Roblox now judges 28 days of behaviour and says it wants long-term retention over attractive thumbnails (findings 1 and 4).

## Not found
- Any numeric "good" value from Roblox for D1, D7, D30 retention or session length (only example percentile ranges).
- A count of plays or impressions a new game gets first, or the number needed to be tested further.
- Weights for the ranking signals.
- Roblox's own account of how many players arrive by friends, groups, joining a friend, or private servers.
- Any Roblox statement on groups in discovery.
- Any Roblox statement on experience page text (description) in ranking or conversion.
- Any Roblox statement on icon effect on ranking or conversion.
- A first-hand statement of how title affects conversion (only the penalty for reward-implying titles).
- Revised DevForum RFY post text after the June 2026 change.
- The 2026 Creator Analytics "Home Recommendations" signal list as shown in the dashboard (not publicly readable).

## Sources
- https://create.roblox.com/docs/en-us/discovery.md (last_updated 2026-11-20)
- https://create.roblox.com/docs/en-us/discovery-faq.md
- https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox (2026-06-15)
- https://devforum.roblox.com/t/boost-your-discovery-with-the-improved-recommended-for-you-algorithm-and-analytics-for-creators/3587441 (2025-03-31, update 2025-12-11; read as JSON summary)
- https://create.roblox.com/docs/production/analytics/retention.md
- https://create.roblox.com/docs/production/analytics/acquisition.md
- https://create.roblox.com/docs/en-us/production/analytics/get-started.md
- https://create.roblox.com/docs/en-us/production/analytics/analytics-dashboard.md
- https://create.roblox.com/docs/en-us/production/game-design/analytics-essentials.md
- https://create.roblox.com/docs/en-us/production/publishing/thumbnails.md
- https://create.roblox.com/docs/en-us/production/publishing/experience-icons.md
- https://create.roblox.com/docs/en-us/production/promotion/invite-prompts.md
- https://create.roblox.com/docs/en-us/production/monetization/private-servers.md
- https://create.roblox.com/docs/en-us/production/recommendation.md (read; about the Recommendation Service API, not used)

## Checked by a second reader
Date of check: 2026-11-21. All pages were read through a summarising fetch tool, as the first reader's were. Quotes are as that tool returned them. Not read raw: the DevForum post (read as .json via https://devforum.roblox.com/t/3587441.json; the /raw/ address returned nothing).

### How many claims checked
24: the signal lists, the 60-minute cap, RFY-only measurement, the custom-thumbnail rule, the "accelerate" wording, averages per user, no 28-day wait, genre tags, benchmarks not affecting ranking, the benchmark rules (100 DAU, 50th-90th, 12.11/18.73, top 1,000, 30 days), the retention day definitions, "5 minutes", "10 minutes", the 8.5% and 50% figures, up to 10 thumbnails, private-server terms, invite-prompt notification, conversion rate, the Friends source, the 2025 signal names, "over 90%", the 2025-12-11 update, the newsroom 7-to-28-day change, and the 9 lines of "What follows".

### Confirmed (no change needed)
- Signal names and the "most important" / "important" split, bounce segments (<60 s, 61-180 s), two stages, 60-minute cap, RFY-only users, custom thumbnail required: https://create.roblox.com/docs/en-us/discovery.md (page front matter 2026-11-20).
- Averages per user, no 28-day wait, genre not a ranking factor, benchmarks do not affect ranking, "very low minimum number of plays", daily banner, where signals are shown: https://create.roblox.com/docs/en-us/discovery-faq.md
- 2025 signal names, "over 90% of traffic begins" on Home, Feb 28 / Mar 3 example, 60-minute limit, reserved servers counted as co-play (update 2025-12-11), post created 2025-03-31: https://devforum.roblox.com/t/3587441.json
- 7-day to 28-day view, qPTR split into more granular signals, no weights, "exciting thumbnails": newsroom page, "Published Jun 15, 2026".
- Benchmark rules and example: https://create.roblox.com/docs/en-us/production/analytics/analytics-dashboard.md
- D1/D7/D30 definitions and "5 minutes or less": https://create.roblox.com/docs/production/analytics/retention.md
- Low-value readings, 10 minutes, session length: https://create.roblox.com/docs/en-us/production/analytics/get-started.md
- Thumbnail figures (+8.5% average qPTR, +50% for some, 2 or more, up to 10, 1920x1080): https://create.roblox.com/docs/en-us/production/publishing/thumbnails.md
- Private-server terms: https://create.roblox.com/docs/en-us/production/monetization/private-servers.md
- Conversion rate and Friend Activity definitions, group permission: https://create.roblox.com/docs/production/analytics/acquisition.md
- Invite notification, no player count: https://create.roblox.com/docs/en-us/production/promotion/invite-prompts.md

### Wrong claims
1. Section 4, line "Games close to existing ones are deprioritised. Thumbnails, titles or gameplay 'virtually indistinguishable'... https://create.roblox.com/docs/en-us/discovery.md and discovery-faq.md".
   - discovery.md does not contain "virtually indistinguishable". It says games with "metadata and place files that closely resemble existing games" are no longer prioritised. It does not mention gameplay in that rule.
   - The phrase is in discovery-faq.md, about near-identical titles and visuals ("Games like that will have reduced discoverability"). Gameplay is not named there either, as returned by the fetch tool.
   - So "gameplay" is not supported. "Place files" (the game's content) is the nearest word, and the sources do not say how similarity is measured.
2. Section 4, thumbnail personalisation: "No date is shown on the page." The page front matter shows last_updated 2026-11-20. That is the page's edit date, not the date of the 8.5% test, which is still not given. Minor.

### Unconfirmed
- "Reusing your own old thumbnails is fine": the FAQ says "Reusing an existing thumbnail alone shouldn't negatively affect discoverability." The discovery page also says "Avoid publishing content with repetitive titles and images that have been previously published." The brief gives only the first.
- Section 2, "A spike of new users from recommendations is tested": discovery.md says the spike follows a content update ("explore"), then similar cohorts get the game if the cohort engages and monetises ("expand"). It is not stated as a rule for new games.
- Section 1, "Most signals update within 24 hours": the DevForum post attributes this to the FAQ. The FAQ text returned did not show it. Not confirmed on the FAQ.
- Devforum post: not read as raw text. Its text was seen only through the summariser.
- The 12.4% / 24.1% search-summary pair and the forum reply on playtime: not checked, not first-hand.

### Lines of "What follows" that go further than the evidence
- Line 2: "weak early days make strong later days unlikely". No source says this. The sources name the day windows as signals and say weak early results are not permanent (FAQ). The line contradicts line 5.
- Line 3: "Playtime past 60 minutes a day per user adds nothing to ranking". The cap is stated for the playtime signal ("recommendation benefits", 2025 post). Other signals (play days, sessions, spend) are not stated to be capped. "Adds nothing to ranking" is wider than the source.
- Line 5: "not penalised for a weak start". The FAQ says poor early performance does not permanently hold a game back and the system recalibrates. It does not say there is no penalty. The sources also say reduced exposure exists (banner).
- Line 6: "so those features feed ranking". The sources say co-play days are an "important" signal. They give no weight and no evidence that adding invites or private servers raises it. The 2025 post advises adding them.
- Line 8: "near-copy of another game's look or gameplay can lose reach". "Gameplay" is not in the sources (see wrong claim 1). "Look" (visuals, metadata, place files) is.
- Line 9: "says it wants long-term retention over attractive thumbnails". The newsroom post says over-weighting short-term engagement favoured exciting thumbnails and the view was widened to 28 days. It does not say it prefers retention over thumbnails.
- Line 7: supported for ranking signals only. Sources say friends "can accelerate your consideration" (discovery.md); the brief notes the conflict in its own disagreement section.
