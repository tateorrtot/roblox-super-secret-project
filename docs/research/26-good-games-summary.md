# How good Roblox games are made and built: what six briefs found

The user asked for this on the night of 2026-11-21: "research how to make good roblox games and roblox architecture". Six readers on Sonnet each wrote a brief, and a second reader checked each against its sources. This page is Claude's reading of the six, after the second reading. It keeps what a source states, and it marks what is only Claude's inference for this game. Each brief lists what its checker found wrong: 16 claims in all, and 30 lines of advice that went further than their evidence.

## What decides whether Roblox shows a game (`26-good-games-discovery.md`)
From Roblox's own pages, dated 2026-11-20, and its post of 2026-06-15:
- **The signals that Roblox names as most important:** "Play through rate"; "First play bounce rate", counted under 60 seconds and from 61 to 180; "Play days per user", over day 1, days 2 to 7, and days 8 to 28; and "Playtime per user", which stops counting at 60 minutes a day.
- **The signals it names as important:** "Intentional co-play days per user" (joins, invites, private and reserved servers), "Qualified play sessions per user", "Spend days per user", and "Robux spent per user".
- **Each is an average for each user,** so a small game is not behind a large one. They are measured only for players who came from the Home page's recommendations.
- **In June 2026 Roblox widened what it looks at from 7 days to 28.** Its reason: weighing the short term too much favoured games with "exciting thumbnails" that did not hold players.
- **A new game is tested at once.** It needs a thumbnail of its own. Roblox gives no number for a good day-1 or day-7 retention: it shows where a game stands among similar games.
- **Inference for this game:** what Roblox now measures over 28 days is what the brief asks for, a game that people come back to. Playing with friends is a named signal, so joining a friend's server and private servers are worth having early.

## What a first session must do (`26-good-games-first-session.md`)
- **Roblox's own target:** a new player reaches the fun "ideally in 5 minutes or less". It has no data behind it.
- **Roblox's own method:** log an event at each step of the first minutes and read where players leave. In its example game, 70.48% left between the first step and the second, and it blames an unclear goal.
- **Teach a thing when the player meets it,** and show a hint only to a player who has stalled. Both are Roblox's advice.
- **About 80% of daily users were on phones in 2024,** by a press report. No source gives where phone players drop out.
- **Not found:** how the long-lived building games start a new player, in their makers' words.
- **Inference for this game:** it has no first goal yet, and its text and slots have never been seen on a phone.

## What keeps a game alive for years (`26-good-games-long-life.md`)
- **Roblox's guidance on updates:** many games release every two weeks to a month, and make that content from systems they already have. It gives no figure that ties this to retention.
- **Every source of a currency needs a sink.** Roblox's page on economies shows one event that flooded a game with gold.
- **One company says that a third of its returning players come back to be with others.**
- **Duplication of items after an update** is named in two weak accounts as what hurt games that started well.
- **Not found:** a maker of Minecraft, RimWorld, Factorio, or Terraria who lists what gave the game its years.
- **Inference for this game:** content made "out of existing systems" is the core rule's promise: one web of inputs, outputs, and processes, where a new thing connects to two that exist.

## What a game can afford on a player's device (`26-good-games-devices.md`)
- **Roblox gives no memory figure for a phone.** It says to pick a low-end device and test on it. About 60% of Android players have 2 to 4 GB of memory, by one report.
- **A frame is 16.67 ms at 60 a second.** The MicroProfiler and the Developer Console measure it.
- **Instance streaming** sends a client only what is near it, and lowers memory. Roblox recommends it.
- **A client may call remotes about 500 times a second,** and an unreliable remote carries 1,000 bytes.
- **Anchor what need not move.** Parts that are awake and touching cost the most.
- **Half of this brief's advice went further than its sources,** so it is the weakest of the six. Measure in the game.

## How experienced developers structure a project (`26-good-games-architecture.md`)
- **Roblox's own reference project, Plant,** has one `Script` on the server and one `LocalScript` on the client, which require ModuleScripts. Its stated reasons are control of the order things start in, and systems that share objects. Every script is `--!strict`. The same page says that several entry points also work, and give isolation.
- **Plant's network module checks the type of every value from a client,** and Roblox's security page says the server must check that each request is "possible and permissible", at any rate of calls.
- **Knit, the best-known framework of services and controllers, was archived on 2024-07-31.** Its author says plain ModuleScripts now do what it did.
- **An entity-component system is a way to organise, and not a way to go faster,** by the author of the most used one, jecs. One studio's account reports weeks of unlearning.
- **What sources say goes wrong as code grows:** scripts multiply until a team is "overwhelmed by the code itself"; connections that are never disconnected; patterns that differ from file to file; and one late, global refactor that was abandoned (Vesteria).
- **Not found:** any first-hand account of folders by feature against folders by layer, or of a game built from libraries kept in repos of their own.
- **Inference for this game:** the game's present shape matches Roblox's reference: one script each side, strict types, modules. Libraries in folders of their own go beyond what any source describes, so nothing here confirms or refutes that choice.

## What the makers of building games say (`26-good-games-sandbox-design.md`)
- **Tynan Sylvester, of RimWorld:** choose "the minimum representation" of a thing, so that a player can hold the system in mind; and let separate events overlap, so that they collide.
- **The maker of Lumber Tycoon 2, in 2015:** a part that a player carries is moved by that player's client, and the server sets who owns it. Requests for many parts arrived out of step until they were sent together.
- **Factorio's team:** a new player's goals should come from the tree of things to unlock, and not from tasks given for no reason. That was a proposal, with no result reported. Their event for 350 players had been planned for 20 to 50.
- **Not found:** anything first-hand from the makers of Bloxburg, Build a Boat, or Plane Crazy; and anything on griefing, trading, or showing off what one built.
