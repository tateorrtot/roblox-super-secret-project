# What the makers of building and process games say makes them work

Asked: what the makers of Lumber Tycoon 2, Bloxburg, Build a Boat, Plane Crazy, RimWorld, Create, Factorio and Satisfactory say about why their games work: goals for a new player, and multiplayer.
Made by one reader on Sonnet, 2026-11-21, from web search and page fetches. Pages were read through a fetch tool that summarises them, so wording is paraphrase, not checked against the page. Sources are developer forum posts, developer blogs, a trade-press interview, a mod's own page, and a few reviews (marked weaker). Very little first-hand material was found; the gaps are listed under Not found.

## What the sources say

### 1. Roblox building and physics games (first-hand only)
- Lumber Tycoon 2, Defaultio, post of 2015-08-29: made the first Lumber Tycoon in 2008 and wanted a sequel; made it in a summer incubator program; his stated worry was that "the progress arch" may be too slow. https://devforum.roblox.com/t/lumber-tycoon-2/18069.json
- Lumber Tycoon 2, Defaultio, thread of 2015-08-30 to 2015-09-23: says he is "a huge fan of physics games" and that heavy use of physics was intended; he knew he was pushing the engine and wanted to see how it breaks. Why this holds players: not stated. https://devforum.roblox.com/t/lumber-tycoon-pgs-physics-instabilities-and-networking-issues/18098.json
- Same thread: the client asks the server for network ownership of a part when a player drags it; one request per part failed, so he sent one request for all parts. Loose wood stacked on trucks and carried items were unstable with a high BodyGyro D value.
- Welcome to Bloxburg, Coeptus, interview 2018-03-07 (PocketGamer.biz): says he started from prebuilt models and learned by changing them; gives no reason players stay, and says nothing of building design, multiplayer or griefing. https://www.pocketgamer.biz/160-million-plays-with-roblox/
- Welcome to Bloxburg, why the building system holds players: only guides and reviews turned up (second best at most): build mode is menu-driven, and jobs earn money for furniture and materials. Not first-hand; not cited further.
- Build a Boat for Treasure: not found. Plane Crazy: not found.

### 2. Tynan Sylvester (RimWorld)
- "The Simulation Dream", his essay, Game Developer, 2013-06-02: large systems with many linked parts become a "hairball" players cannot read, so their outcomes stay hidden. Players supply meaning to simple events themselves. Use the least representation that supports the stories wanted. His "Player Model Principle": the value of a game is in the mental model it puts in the player's head. https://www.gamedeveloper.com/design/the-simulation-dream
- Game Developer, 2016-08-11 ("How RimWorld fleshes out the Dwarf Fortress formula"): the storyteller picks events from a database using a few statistics of the game state. Events are built to overlap (fallout and fires last days, raids besiege for days), so they collide; he says the richest stories come from that. The storyteller eases off as the colony shrinks so a collapse is slow. https://www.gamedeveloper.com/design/how-i-rimworld-i-fleshes-out-the-i-dwarf-fortress-i-formula (by a summary; whether the words are his or the author's was not shown)
- GDC 2017 talk "RimWorld: Contrarian, Ridiculous, and Impossible Game Design Methods": treat the game as a story generator, not a game; leave features out; decide without long planning. Only a Game Developer write-up (2019-05-16) was read, not the video. https://gamedeveloper.com/design/video-how-i-rimworld-i-found-success-through-ridiculous-contrarian-design
- Book "Designing Games" (O'Reilly): publisher page gave HTTP 403, no text read. No page or address from the book can be given.
- Second-hand, weak: a 2019-10-09 Game Developer blog by Henri Brouard says Sylvester and the Adams brothers see fun in unscripted stories, not set objectives. https://gamedeveloper.com/design/rimworld-dwarf-fortress-and-procedurally-generated-story-telling
- A 2024-09-09 podcast page (AIAS Game Maker's Notebook) lists "elastic failure"; the page gives no detail. https://gamemakersnotebook.libsyn.com/generating-human-stories-with-rimworld-creator-tynan-sylvester

### 3. Create, Factorio, Satisfactory on machines and processes
- Create, its own mod page (no date; page shows "published 4 years ago"): the tech "leaves as many design choices to the player as possible"; players build contraptions of animated parts; Ponder is an in-game visual guide to its mechanics. https://modrinth.com/mod/create . No post or talk by its makers found.
- Factorio, Twinsen, FFF #191, 2017-05-19: wants the quickbar to be shortcuts, not a second inventory; wants ghost placement so players can keep designing without stopping to craft; prioritises new players. https://factorio.com/blog/post/fff-191
- Factorio, FFF #74, 2015-02-20: the core concept to keep in the endgame is "building automated systems"; playtest wishes were tools that cut tedious micromanagement (trash area, construction robots, automatic rail). https://www.factorio.com/blog/post/fff-74
- Factorio, FFF #300 (2019-06-21): Twinsen's section does not say what he enjoys in the game. A search snippet quoted him on enjoying replacing improvised factory parts with organised ones; the fetched page did not confirm it, so it is not relied on.
- Satisfactory, Coffee Stain developers: the game came from a prototype period after Goat Simulator work stopped, and from people at the studio who were hooked on Factorio (seen in search snippets of the Unreal Engine interview, 2019-03-22; the page itself returned 403). Why machines are fun to build: no first-hand statement read. A PC Gamer review (weaker) says exploration feeds the factory. https://www.unrealengine.com/developer-interviews/how-satisfactory-is-combining-crafting-gunplay-and-vehicles-into-one-ambitious-building-simulator

### 4. A goal for a new player in a game with no fixed goal
- Factorio FFF #241, 2018-05-04 (V453000, Abregado, Twinsen): their tutorial took 30 to 45 minutes to reach automation, and its tasks taught how to pass the tutorial. Objectives lacked purpose (gather because asked). They want goals to come from the tech tree, with recipes unlocked by research, and want players to learn by experiment. https://factorio.com/blog/post/fff-241
- Factorio FFF #74: a rescue-mission endgame (rocket silo, space ship) gives a stated end to the build. https://www.factorio.com/blog/post/fff-74
- Sylvester 2013: does not frame goals; players build stories from what they perceive (see 2). RimWorld can be won, per Brouard 2019 (second-hand).
- Defaultio 2015: pacing of progress was his own open worry (see 1).

### 5. Multiplayer: sharing, griefing, trading, showing off
- Factorio FFF #157, kovarex, 2016-09-23: planned for 20 to 50 players, a large event reached about 350; the goal is "not to make some MMO" but a good single player game with decent multiplayer; about 200 players is "more than enough". The post says nothing on griefing; it asks for admin options changeable during play. https://direct.factorio.com/blog/post/fff-157
- Factorio FFF #74: the team played a shared map for half a day; it grew the railway and gave many feature ideas.
- Satisfactory: Varlet confirmed multiplayer (2019 Unreal interview, seen in a snippet); a Techraptor interview is said to report co-op with no PvP (page 403; snippet only; no date). https://techraptor.net/content/satisfactory-interview-oscar-jilsen
- Lumber Tycoon 2: network ownership design in 1 above is the only multiplayer detail.
- Griefing, trading, showing off a build: not found.

## Where the sources disagree, or are weak
- Almost every Roblox claim is missing. The one Roblox maker with first-hand text (Defaultio) wrote about bugs and a physics hobby, not retention.
- Sylvester (2013) says complex linked systems hide their outcomes; Sylvester (2016, by summary) says overlapping events give the richest stories. Both are shown; the sources do not reconcile them. The difference may be that the first is about what the player can read and the second about what events collide.
- Factorio's own goal posts (FFF #241 tech tree goals, FFF #74 rocket ending) differ from the story-generator view of Brouard (second-hand), which says fun is not set objectives.
- Create and Satisfactory rest on a mod page and search snippets. Satisfactory's Unreal interview and Techraptor could not be read.
- Player counts from trackers disagreed in search results (for example for Lumber Tycoon 2); none are used here.
- Fetch-tool summaries may drop or alter wording. Quotes should be checked on the page before reuse.

## What follows for someone building such a game
Only what the sources say, with the finding each rests on:
1. Keep systems small enough that the player can form a mental model of them (2: Sylvester 2013).
2. Let separate events overlap in time so they collide (2: Sylvester 2016, by summary).
3. Build the pace of progress deliberately; its own maker named it a worry (1: Defaultio 2015).
4. Take a goal from the tool tree (research unlocks), not from tasks given for no reason (4: FFF #241).
5. Teach by letting the player try things; a tutorial that teaches passing itself fails (4: FFF #241).
6. Cut tedious repeat work so players keep to planning (3: FFF #74, FFF #191 ghosts).
7. Give players choices in how things are built (3: Create page).
8. A drag on a shared physical thing needs the server to hand ownership to one client (1: Defaultio thread).
9. Plan for far more players than first expected, and give admins live settings (5: FFF #157).
10. Griefing, trading and showing off have no support in these sources; decide them elsewhere (5: not found).

## Not found
- Any developer statement from Build a Boat for Treasure or Plane Crazy.
- Bloxburg: the maker's reasons for the building system; anything on multiplayer or griefing.
- Lumber Tycoon 2: why its physics or building holds players (only intent to use physics).
- "Designing Games": text, page or chapter on story generators or interacting systems.
- Create: any post or talk by its makers on why it was made.
- Satisfactory: first-hand talk on why factory building is fun, on goals, or on showing builds (two pages gave 403).
- Factorio: anything on griefing, trading or showing off a build.
- Any source on trading between players, or on showing off what one built, in any of these games.

## Sources
- https://devforum.roblox.com/t/lumber-tycoon-2/18069.json (2015-08-29)
- https://devforum.roblox.com/t/lumber-tycoon-pgs-physics-instabilities-and-networking-issues/18098.json (2015-08-30)
- https://www.pocketgamer.biz/160-million-plays-with-roblox/ (2018-03-07)
- https://www.gamedeveloper.com/design/the-simulation-dream (2013-06-02)
- https://www.gamedeveloper.com/design/how-i-rimworld-i-fleshes-out-the-i-dwarf-fortress-i-formula (2016-08-11)
- https://gamedeveloper.com/design/video-how-i-rimworld-i-found-success-through-ridiculous-contrarian-design (2019-05-16, on a 2017 talk)
- https://gamedeveloper.com/design/rimworld-dwarf-fortress-and-procedurally-generated-story-telling (2019-10-09, weaker)
- https://gamemakersnotebook.libsyn.com/generating-human-stories-with-rimworld-creator-tynan-sylvester (2024-09-09, page only)
- https://modrinth.com/mod/create (undated)
- https://factorio.com/blog/post/fff-191 (2017-05-19)
- https://www.factorio.com/blog/post/fff-74 (2015-02-20)
- https://factorio.com/blog/post/fff-241 (2018-05-04)
- https://direct.factorio.com/blog/post/fff-157 (2016-09-23)
- https://factorio.com/blog/post/fff-300 (2019-06-21)
- https://www.unrealengine.com/developer-interviews/how-satisfactory-is-combining-crafting-gunplay-and-vehicles-into-one-ambitious-building-simulator (2019-03-22, snippet only)
- https://techraptor.net/content/satisfactory-interview-oscar-jilsen (undated, snippet only)

## Checked by a second reader
Second reader, 2026-11-21. Sources opened through a fetch tool that summarises, except the two Roblox forum threads, which were read as raw text (https://devforum.roblox.com/raw/18069 and https://devforum.roblox.com/raw/18098). I did not search for Roblox documentation, since the brief makes no "Roblox says" claim about the engine.

### Count
- 24 claims checked: 18 confirmed, 2 wrong in part, 4 unconfirmed.

### Wrong claims
- Brief: loose wood stacked on trucks and carried items were unstable "with a high BodyGyro D value" (section 1, same thread). Source: only carried (grabbed) parts are tied to high BodyGyro D, when a part is welded to the end of a long, slender member. Loose logs on a truck are a different problem: logs with different network owners fight over physics, and a client sees logs slide then jump back. https://devforum.roblox.com/raw/18098 (posts of 2015-08-30 and later replies).
- Brief: FFF #74 "playtest wishes were tools that cut tedious micromanagement" (section 3). Source: the wishes were a logistic trash area, personal construction robots (to "speed up later game stages") and automatic railway building. The page, as fetched, does not use the word tedious or micromanagement. The playtest was the dev team playing for half a day, not outside players. https://www.factorio.com/blog/post/fff-74 (2015-02-20).
- Related note, not an error in the brief: for FFF #300 the brief says a search snippet attributed the "improvised parts replaced by organised ones" line to Twinsen. The page gives that sentence to kovarex, as one of his favourite parts. https://factorio.com/blog/post/fff-300 (2019-06-21). The brief did not rely on it.

### Unconfirmed claims
- The LT2 thread "of 2015-08-30 to 2015-09-23": the JSON shows only the first post, 2015-08-30. The 2015-09-23 end date was not found. The raw page lists later replies without their original dates.
- Satisfactory: Goat Simulator prototype period, Factorio-hooked staff, Varlet confirming multiplayer (Unreal Engine interview, 2019-03-22). The page returned HTTP 403 for me too. Not found.
- Satisfactory: co-op with no PvP (Techraptor). HTTP 403 for me too. Not found.
- Book "Designing Games", Build a Boat for Treasure, Plane Crazy: no source was read, as the brief says.
- Source dates I could not check on the page: the 2024-09-09 podcast page, and the Create mod page (shows only "Published 4 years ago", "Updated 7 months ago").

### Confirmed (for the record)
- LT2 post 2015-08-29, Defaultio: 2008 original, sequel, summer incubator, "progress arch ... may be too slow". https://devforum.roblox.com/raw/18069 (the raw page shows 2015-10-25 as an import time; the JSON gives created_at 2015-08-29).
- "huge fan of physics games"; "if you want to fix something, you've got to see how it breaks"; the one-request-for-all-parts fix. https://devforum.roblox.com/raw/18098
- Bloxburg interview, 2018-03-07: prebuilt models, no building design, multiplayer or griefing content. https://www.pocketgamer.biz/160-million-plays-with-roblox/ . The page also says players earn currency for furniture and additions and that passes allow larger houses.
- Sylvester 2013-06-02: hairball, minimum representation, Player Model Principle, player adds meaning. https://www.gamedeveloper.com/design/the-simulation-dream
- Game Developer 2016-08-11: overlap, richness from interaction, eases off on population drop are Sylvester's quoted words. The database sentence is the article's own narration. https://www.gamedeveloper.com/design/how-i-rimworld-i-fleshes-out-the-i-dwarf-fortress-i-formula
- GDC 2017 write-up 2019-05-16: story generator, leave features out, less planning. https://gamedeveloper.com/design/video-how-i-rimworld-i-found-success-through-ridiculous-contrarian-design
- Brouard 2019-10-09: unscripted stories, RimWorld can be won. https://gamedeveloper.com/design/rimworld-dwarf-fortress-and-procedurally-generated-story-telling
- Create page wording and Ponder. https://modrinth.com/mod/create
- FFF #191 (2017-05-19), #74 (2015-02-20), #241 (2018-05-04), #157 (2016-09-23): numbers and statements as the brief gives them. FFF #157 has no mention of griefing.

### Lines of "What follows" that go further than their evidence
- 3 (pace of progress, "build deliberately"): the source is one worry from the maker in a feedback request. It gives no result and no advice. Replies in the same thread (Den_S) say the pace felt slow, but the brief does not use them.
- 4 ("tool tree"; goals from research): FFF #241 is a proposal in a post on new-player experience. It says what they intend. It reports no result. "Tool tree" should read tech tree.
- 5 (a tutorial that teaches passing itself "fails"): the post is the team's own criticism of its tutorial. It gives no test or number showing failure.
- 6 (cut tedious repeat work): see the wrong claim on FFF #74. FFF #191 supports ghost placement only. It says nothing of tedium.
- 7 (give players choices in how things are built): the only source is a mod's own description of its design aim. It gives no evidence that choice holds players.
- 8 (a drag needs the server to hand ownership to one client): the source describes one developer's design, where the client asks and the server sets owner. The finding was that per-part requests arrived out of step, so batching was needed. It does not say the server must hand ownership to one client. The server-set part holds. A security question in the thread (reply by Spacek531) was answered only by "the server sets it at the client's request".
- 9 ("plan for far more players than first expected"): FFF #157 says the 350-player event exceeded the 20 to 50 planned, and also that the goal is "not to make some MMO" and that about 200 is "more than enough". The admin-settings part is supported. The "far more" advice runs against the post's own limit.
- 1 and 2: supported, with a small stretch. Line 1 turns "choose the minimum representation" into "small enough that the player can form a model". Line 2 rests on a staff-written feature, which the brief already marks.
- 10: supported (a statement of absence).
