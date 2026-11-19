# Roblox Game Research, November 2026

Compiled 2026-11-18. The goal: make the most successful Roblox game we reasonably can, with high concurrent players (CCU) for as long as possible. Claude writes most of it.

Each claim is labeled by source: **[official]** means Roblox's own docs, DevForum posts, or newsroom. **[3rd-party]** means trackers, blogs, or vendors, and many of those sell services. **[analysis]** means my own conclusions.

---

## 0. Tooling: what we need

### What this machine has now
- Windows 11, git, Python 3.12, and the Roblox **Player**.
- Not found: **Roblox Studio** (only the Player is under `%LOCALAPPDATA%\Roblox\Versions`), Rojo, Rokit, StyLua, Selene, luau-lsp, Node, gh.

### The key enabler: Studio's built-in MCP server [official]
Studio has a built-in MCP server. Claude Code is a "Quick connect" client. To turn it on: **Assistant → … → Manage MCP Servers → Enable Studio as MCP server**, then pick Claude Code under Quick connect and restart both apps. Windows fallback config: `cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat`.

Tools it gives Claude, as listed on the docs page (create.roblox.com/docs/studio/mcp):
| Area | Tools |
|---|---|
| Code | `script_read`, `multi_edit`, `script_search`, `script_grep`, `execute_luau` (Edit/Client/Server) |
| World inspection | `search_game_tree`, `inspect_instance` |
| Playtesting | `start_stop_play`, `get_console_output`, **`screen_capture`** (viewport image with a custom camera), `get_studio_state` |
| Input simulation | `character_navigation`, `user_keyboard_input`, `user_mouse_input`, `subagent` (explore / playtest) |
| Asset generation | `generate_mesh` (textured mesh from text), `generate_material`, `generate_procedural_model`, `generate_animation`, `generate_avatar` |
| Assets | `search_asset` / `insert_asset` (Creator Store, including licensed audio), `upload_image`, `store_image` |
| Place | `save_place`, `list_roblox_studios` |

This gives a closed loop: **write code → playtest → read logs → screenshot → fix**, with no human in between. It is the biggest single factor in how much of the game Claude can author alone.

### Code as files: Rojo
- **Rojo** syncs files on disk into Studio, so code lives in git and gets linting, formatting, and type checking. Roblox's own docs point to Rojo for whole-project version control. [official]
- Studio's native **Script Sync** is still beta and only covers Script, LocalScript, ModuleScript, and Folder. [official]
- Planned toolchain: **Rokit** (installs the tools below), **Rojo**, **StyLua** (formatter), **Selene** (linter), **luau-lsp** (type checking), and maybe **Lune** (runs Luau outside Studio for unit tests).
- Split: **Rojo for code, MCP for the world** (building, assets, playtesting).

### Claude plugins and skills
- The Anthropic plugin directory has a community **"roblox-dev"** plugin. It has skills for Luau strict typing, DataStores, remote security, performance, UI, testing, and a reviewer agent. It's community-authored, so we should review it before relying on it. Nothing else Roblox-specific turned up.
- We'll write our own `CLAUDE.md` with project conventions once the stack is chosen.

### Things only you can do (account and legal) [official]
| To reach | Requirements |
|---|---|
| **16+ and Trusted Friends** | Age check (face estimate or government ID), account in good standing and ≥2 days old, content questionnaire |
| **All ages** (Kids 5–8, Select 9–15) | All of the above, plus **ID verification**, **2-Step Verification**, and either **Roblox Plus/Premium held for 2 consecutive months** *or* a **1,000 Robux refundable fee per game**, plus the evaluation in §2 |

- Ownership: a **Roblox group** is recommended. For a group game, only the group owner must meet the requirements; members need 2SV to publish.
- Optional later: an **Open Cloud API key** for automated publishing. You create it and keep it in an environment variable; it never goes through chat.
- Budget: Robux for **Ads Manager**, plus an optional **50,000 Robux refundable expedited review** if we want a fixed launch date.

### Where Claude is weak (where your help matters most) [analysis]
1. **Icon and thumbnails.** These drive play-through rate, the #1 discovery signal. I can stage scenes in Studio and capture them, but a human eye (and possibly an image tool) will beat me here.
2. **Feel on a real phone.** I can simulate input but can't feel touch controls or frame drops on a cheap Android phone.
3. **Taste and trend sense.** What's funny or memeable among kids and teens *this month*.
4. **Marketing.** TikTok and Shorts posting, Discord, creator outreach.
5. **Real playtests** with friends and kids, watched in person.

---

## 1. How discovery works now [official]

Roblox says **over 90% of traffic starts on Home**, through the "Recommended For You" (RFY) sort.

### RFY signals since June 15, 2026 (DevForum "RFY algorithm improvements that better value long-term retention")
| Priority | Signal |
|---|---|
| **Most important** | **Play-through rate** (impression → play) |
| | **First-play bounce rate**, a *negative* signal, measured at **<60s** and **61–180s** |
| | **Play days per user** |
| | **Playtime per user**, capped at **60 min per user per game per day** |
| **Important** | **Intentional co-play days** (joining a friend, invites, private/reserved servers; matchmaking doesn't count) |
| | Qualified play sessions per user |
| | **Spend days** per user (how often players spend, separate from how much) |
| | Robux spent per user |

- Each signal is measured over three windows: **Day 1, Days 2–7, and Days 8–28**. Before June 2026 the window was 7 days.
- Signals are **per-user averages, not totals**, so small games aren't disadvantaged.
- **Only players who joined organically from RFY count for ranking.** Ads, search, friends, social media, and curation only speed up *retrieval* (getting into consideration).
- The system works in **explore → expand** phases. Signals update within about 24h, and impressions follow a few days later.
- A **custom thumbnail is required** for any Home impressions. Thumbnail personalization rotates variants and is moving to PTR.
- Exposure is **limited** for giveaway-bait metadata ("Free Robux!"), metadata that doesn't match the game, and **"non-unique" games** (clones).
- Traffic peaks on **Saturdays**, in summer, and over holidays.

### What this means for us [analysis]
1. **The first 60 seconds decide everything.** A bounce in under a minute is a top-tier negative signal.
2. **Design for daily return, not marathons.** Playtime past 60 min/day doesn't count, and play days across Days 8–28 are now measured directly. We need reasons to come back tomorrow *and* in week 3.
3. **Friends playing together is rewarded directly.** We want invite prompts, friend-join bonuses, cheap or free private servers, and co-op goals.
4. **Small, frequent purchases count.** Spend *days* is its own signal.
5. **Ads can't buy ranking.** They only buy a sample, and the game has to convert it.
6. **Clones get suppressed.** We need a real twist, not a reskin.

---

## 2. The 2026 gate: new games launch to 16+ only [official]

Since May 19, 2026, a new game is **first trialed only with age-checked users 16+**. To unlock the under-16 audience (Roblox Kids and Select):
- The creator must meet the all-ages requirements in §0.
- The game needs **250 unique plays from "highly engaged" age-checked 16+ players within 60 days**. A highly engaged player has account tenure, playtime in your game, and **a purchase anywhere on Roblox in the last 60 days**. They don't have to spend in our game. This is checked hourly. *(At launch the bar was 500; it has been lowered twice.)*
- After that comes a safety review based on real-time moderation reports.
- Shortcut: **50,000 Robux refundable expedited review**, completed within 48h.
- Ads Manager has an **"Engagement" objective (beta)** that targets exactly these highly engaged players.
- Maturity: **Kids sees only Minimal/Mild**, and **Select sees up to Moderate (9+)**. → **Keep the game Mild** to reach everyone.

Other 2026 rules that shape design:
- **Chat requires an age check** and only connects similar ages. Self-declared under-16 accounts have chat off. → **Social play can't depend on text chat.** Use emotes, pings, quick-chat, shared goals, and visible actions.
- **Social links are hidden from under-16s** (since June 30). Discord and TikTok links on the game page only reach 16+.
- **Media feed + autoplay/scroll + reward for watching = banned from Kids and Select** (Aug 2026, after Steal an Egg's "Reels" treadmill). Rewarded video ads are exempt.
- **Paid random items** (eggs, crates) must show their odds. [Roblox policy; confirm current wording before shipping]

### Demographics (Q3 2026 earnings, reported Oct 29) [official via press]
- 138M DAU (down 9% YoY), engagement hours down 15%, bookings $1.70B (down 12%), 30.3M monthly payers. The market is **softer than the 2025 boom**, so competition for attention is tighter.
- **Over-18s are the fastest-growing group**: 29% of age-checked DAU globally and 37% in the US. 64% of DAU have done an age check, including over 80% of 13–17s.

### Money tilts older too [official]
- DevEx pays **$0.0038 per Robux** at the standard rate, and **$0.0054 (+42%)** for spend by **age-checked US 18+ players**, *if the game uses R15 avatars 100% of the time*. R6 at any point disqualifies it. → **Go R15-only. It's free money.**

### What this means for us [analysis]
**The launch audience is 16+, and the growth audience is everyone.** The game has to be genuinely fun for teens and adults (to earn the 250 highly engaged plays and pay the 18+ rate), while staying Mild-rated and simple enough to explode once under-16s unlock. That rules out designs that only work for young kids, like pure roleplay for 8-year-olds.

---

## 3. What's on top right now (chart snapshot, Nov 18 2026) [3rd-party]

| # | Game | CCU now | Genre | Notes |
|---|---|---|---|---|
| 1 | Steal An Egg | ~450K | Steal/collect sim | Launched **Jul 25 2026**; peak ~14.2M; 11.5B visits |
| 2 | Brookhaven RP | ~290K | Roleplay | Evergreen (2020) |
| 3 | Adopt Me! | ~286K | Pet collect/trade RP | Evergreen |
| 4 | Blox Fruits | ~222K | Anime RPG/PvP | Evergreen |
| 5 | **Throw Food For Animals** | ~183K | Incremental "throw farther" sim | Launched **Sep 18 2026**, so 2 months old; 94% rating |
| 6 | Murder Mystery 2 | ~112K | Social deduction | Evergreen, trading economy |
| 7 | RIVALS | ~102K | Competitive shooter | Skill PvP |
| 8 | 99 Nights in the Forest | ~93K | Co-op survival | Peak ~14.2M |
| 10 | Hyper Realistic Ragdoll | ~65K | Physics comedy | Only 24M visits, so very new |
| 11 | Fish It! | ~63K | Fishing collect sim | |
| 15 | Break and Steal an Egg | ~54K | Steal clone + twist | 97% rating |
| 17 | Ragdoll Soccer | ~52K | Physics sports | New |
| 23 | Steal a Brainrot | ~40K | Steal tycoon | Peaked **25M+** in Aug 2025 |
| 28 | BloxNG [CRASH PHYSICS] | ~35K | Physics destruction | Only 12M visits, so new |
| 36 | 100 Miles Down the River | ~28K | Co-op survival journey | +134%/day, 2.7M visits, brand new |
| — | Grow a Garden | ~15K | Idle garden | Peaked **22.3M** Aug 2025, now off the top 50 |

**Recurring patterns:**
- **"Steal a ___"** social-conflict collectors (the top naming pattern)
- **Incremental "power up → go farther" sims**
- **Ragdoll/physics comedy**
- **Casual-skill sports** (volleyball, soccer, basketball)
- **Co-op survival/horror**
- **Streamer-themed novelties** ("Scare Your Favorite Streamer")

---

## 4. Why hits hit [analysis from the games above]

1. **The title is the tutorial.** Verb + noun: *Grow a Garden, Steal a Brainrot, Throw Food For Animals.* You know what to do before it loads.
2. **Fun in seconds, zero reading.** One obvious action, an instant reward, and juicy feedback.
3. **Number goes up, visibly.** Rarity tiers, mutations, sizes. Collection is driven by gacha-style hatching.
4. **A persistent thing you own and others can see.** Garden, base, or pet lineup. **Offline progress** (plants grow while you're away) pulls players back.
5. **Other players matter.** Stealing, trading, showing off, co-op. Social conflict creates stories, revenge loops, and clips.
6. **Timed scarcity.** Shop restocks every few minutes, weather events, limited items. These drive play *days*, not just playtime.
7. **Relentless weekly updates,** usually Saturday (the traffic peak), with limited-time events and "admin abuse" streams.
8. **Clip-native moments** for TikTok and Shorts: rare drops, steals, physics fails.
9. **Mobile-first simplicity.** Big buttons and one-thumb play.
10. **Tiny teams that iterate fast.** Grow a Garden began as a solo teen project, and most mega-hits shipped rough and improved weekly.

**Peak isn't longevity.** Grow a Garden went from 22M to 15K CCU, and Steal a Brainrot from 25M to 40K, within about 15 months. The games that last 5–8 years (Adopt Me, Brookhaven, MM2, Blox Fruits) share at least one of these:
- **A player-driven economy** (trading, item value)
- **Social identity or self-expression**
- **Skill/PvP mastery**

The mega-hits had loops. The evergreens have **economies and communities**. Our target is both: a hit-shaped hook on an evergreen-shaped foundation.

---

## 5. What fails

- **Clones with no twist.** The algorithm penalizes "non-unique" games, and players have no reason to switch. [official + analysis]
- **Slow starts:** long loads, intro cutscenes, text tutorials, menus before play. These feed directly into first-play bounce. [official signal]
- **Thumbnail/title promises the game doesn't keep.** Players bounce, and metadata mismatch is penalized. [official]
- **No goals and linear progression.** A recurring theme in DevForum postmortems ("the core loop just wasn't engaging enough, no goals worth achieving"). [3rd-party anecdote]
- **No reason to return tomorrow:** no persistence, timers, social ties, or new content. [analysis, backed by the D2–28 signals]
- **Poor performance on low-end phones,** and PC-only controls. [analysis]
- **Launch-and-abandon.** Every hit above updates weekly. [analysis]
- **Paying for traffic before the game retains.** Ads don't count for ranking, so the money only buys a sample. [official]
- **Policy traps:** reward-for-watching feeds, copyrighted IP or memes, "free Robux" bait, undisclosed odds. [official]
- **Over-scoping:** content-hungry designs (hand-built levels, story) that a tiny team can't refresh weekly. [analysis]

---

## 6. Benchmarks [3rd-party: GameAnalytics 2026, games with 1M+ MAU only]

| Metric | p25 | median | p90 | p99 |
|---|---|---|---|---|
| D1 retention | 8.4% | 10.3% | ~13–16% | 22.2% |
| D7 retention | 1.0% | 1.6% | — | 9.1% |
| D30 retention | 0.3% | 0.5% | — | 4.7% |
| Session length (min) | 7.3 | 9.8 | 14.7 | 21.1 |
| Sessions per player per day | 1.34 | 1.56 | 3.22 | 8.30 |
| ARPPU | $0.32 | $0.70 | $2.33 | $55.31 |

Payer conversion is about 3.8%. Devices: 44% of games are played on mobile+PC, 41% PC-only, 12% mobile-only.

**Our stretch targets** [analysis]: D1 ≥ 20%, D7 ≥ 7%, D30 ≥ 3%, sessions per day ≥ 3, first-play bounce under 60s as low as possible. That's roughly top-1% territory, which is what a sustained hit needs.

---

## 7. Money [official unless noted]
- **DevEx:** $0.0038 per Robux standard, $0.0054 for US 18+ spend in R15-only games.
- **Revenue sources:**
  - Game passes and developer products (consumables)
  - **Paid private servers.** Roblox Plus ($4.99/mo) subscribers get them free, and **Roblox pays creators for Plus subscribers' time in them**. These also count as co-play.
  - Subscriptions
  - **Rewarded video ads:** eligibility is 13+, ID verified, and ≥2K monthly unique visitors. Roblox expects them to be up to ~3% of earnings. They're exempt from the media-feed rule.
  - **Creator Rewards:** pays for engagement from spenders and for bringing new or lapsed users. Check exact rates in Creator Hub.
- **Spend days** is a ranking signal, so offer cheap, frequent, *fair* purchases, not just whale items.

## 8. Marketing [3rd-party, vendor-biased numbers]
- Rough cost per player: TikTok organic is cheapest, then creator partnerships (~$0.05–0.20), then Roblox Ads (~$0.20–0.45 per play). Micro-creator videos run ~$50–$450 each.
- Typical launch sequence:
  1. Soft launch to a few hundred players and fix the funnel.
  2. Small ad test, including the Engagement objective for highly engaged players.
  3. Micro-creators on TikTok and Shorts.
  4. Scale only once retention holds.
- Ship updates on Saturdays. Build a Discord, but remember its link only shows to 16+.

---

## 9. Design criteria for our game [analysis]

Every candidate idea gets scored against these:

1. **One-glance clarity.** The title (verb + noun) and thumbnail explain the game instantly.
2. **Fun within 15 seconds,** with no reading. Kills first-play bounce.
3. **Works for 16+ and Mild-rated.** Wins the launch gate, then the mass market.
4. **Return hooks for tomorrow:** offline progress, timers, rotating shop, daily goals.
5. **Return hooks for week 3:** weekly content cadence, long collections, events, an economy.
6. **Better with friends, without needing chat:** co-op or competitive interaction, invite rewards, private servers.
7. **Clip-worthy moments:** physics, rare pulls, steals, funny fails.
8. **Systemic content.** Content comes from combinatorics and procedural systems (rarity × mutation × size × biome), so Claude can ship weekly updates cheaply. Avoid hand-made-content treadmills.
9. **Plays to Claude's strengths.** Code- and systems-heavy, with a stylized look built from parts and generated meshes. Not art- or animation-heavy.
10. **Mobile-first controls and performance.**
11. **Fair, frequent monetization,** R15-only, with paid private servers.
12. **A real twist.** Fresh, not a clone, while still riding a proven pattern.
13. **No policy traps.**

---

## 10. Open questions for the brainstorm
- Budget: Robux for ads, Plus subscription vs. the 1,000 R$ fee, and the 50K expedited review?
- Your Roblox account status: age-checked? ID-verified? 2SV? Plus or Premium?
- How much time can you give to phone testing, social clips, and Discord?
- Personal vs. group ownership, and a group name?
- Does the empty `chooms-gonna-flatline/` folder mean anything for this project?

---

## Sources
**Official (Roblox):**
- Studio MCP server: https://create.roblox.com/docs/studio/mcp
- MCP updates (Feb 2026): https://devforum.roblox.com/t/studio-mcp-server-updates-and-external-llm-support-for-assistant/4415631
- Script Sync (beta): https://create.roblox.com/docs/scripting/sync · Rojo: https://create.roblox.com/docs/projects/rojo
- Discovery docs: https://create.roblox.com/docs/production/promotion/discovery
- RFY 28-day update (Jun 15 2026): https://devforum.roblox.com/t/recommended-for-you-algorithm-improvements-that-better-value-long-term-retention/4684575
- RFY original + Dec 2025 update: https://devforum.roblox.com/t/boost-your-discovery-with-the-improved-recommended-for-you-algorithm-and-analytics-for-creators/3587441
- Publishing requirements (May 2026): https://devforum.roblox.com/t/new-publishing-requirements-evaluation-process-for-games/4573166
- Kids & Select docs: https://create.roblox.com/docs/production/publishing/kids-and-select
- Kids & Select global launch: https://devforum.roblox.com/t/roblox-kids-and-select-global-launch-upcoming-updates-to-eligibility-ads-manager-and-expedited-review/4685717
- Media-feed restriction: https://devforum.roblox.com/t/roblox-kids-and-select-new-restrictions-on-reward-driven-media-feeds/4829188
- Roblox Plus: https://devforum.roblox.com/t/introducing-roblox-plus/4567894
- Age checks for chat: https://devforum.roblox.com/t/age-checks-to-access-chat-studio-team-create-and-links-on-roblox/4079702
- 18+ DevEx rate: https://create.roblox.com/docs/production/monetization/18-plus-devex-rate · https://about.roblox.com/newsroom/2026/04/roblox-fuels-high-fidelity-games-over-18-players-increases-qualifying-devex-rate-42
- Onboarding: https://create.roblox.com/docs/production/game-design/onboarding · Core loops: https://create.roblox.com/docs/production/game-design/core-loops
- Rewarded video ads: https://create.roblox.com/docs/en-us/production/promotion/rewarded-video-ads

**Third-party:**
- Charts: https://endgametools.com/en/roblox/charts · https://statroblox.com/leaderboards/playing · https://en.wikipedia.org/wiki/List_of_Roblox_games
- Steal an Egg: https://otakukart.com/robloxs-steal-an-egg-reaches-6-billion-visits-and-14-2-million-peak-concurrent-players/ · https://kotaku.com/roblox-cracks-down-on-doomscrolling-games-like-steal-an-egg-that-forces-players-to-watch-reels-while-running-on-a-treadmill-2000727952
- Throw Food For Animals: https://www.sportskeeda.com/roblox-news/throw-food-for-animals-a-beginner-s-guide
- Benchmarks: https://www.gameanalytics.com/reports/2026-roblox-report
- Q3 2026 results: https://www.ggrecon.com/articles/roblox-daily-players-fall-q3-2026/ · https://gaming.net/roblox-q3-revenue-rises-16-as-bookings-fall-12-to-1-7-billion
- Launch commentary: https://dubit.io/library/what-makes-a-new-roblox-game-take-off · https://rowatcher.com/news/roblox-s-algorithm-gives-new-games-two-boosts-then-nothing
- Marketing costs (vendor): https://bloxg.com/statistics/roblox-advertising-benchmarks · https://metaclip.app/guides/roblox-influencer-marketing
- Genre trends: https://www.exitlag.com/blog/roblox-game-genres-and-popularity/
