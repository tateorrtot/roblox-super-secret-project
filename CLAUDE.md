# Roblox sandbox game

A systemic sandbox game on Roblox, written mostly by Claude for the user. This file is the map, and the rules that always apply. Everything else is in `docs/`, one topic to a file, and is read when it is needed.

**Keep this file short.** It is loaded whole into every session, and most helper agents are shown it. What changes from day to day goes in `docs/status/`. A new fact goes in the file for its topic, or in a new small file. This file changes only when a rule or the map changes.

## The brief (the user's words, 2026-11-18)
> I want you to make a Roblox game. I'd like you to author the majority of it to test your capabilities. Your primary goal is to make as successful of a game as possible with as high of a playercount for as long as possible as reasonable.

**This is the goal: a good game that many people play for a long time. Everything else is a means to it.** The user, 2026-11-21: "its important to remember the original main goal of why were doing any of this and what the goal is. Anything else is just a means to reach that goal." Before a piece of work, say how it brings that game closer. A library, a rule, or a note that does not is not built.

The user is here to help with whatever Claude can't do.

## Rules that always apply
- **The game has a core rule, not a core activity.** Never name one activity as the core, never reskin a current hit, and no "Verb a Noun" titles. Things in the game are physical objects and real events. This outranks Roblox's discovery criteria. See `docs/game/brief.md` and `docs/game/core-rule.md`.
- **The world is the user's.** Places, peoples, tone, names and the look are theirs. Claude drafts content in batches for their approval, and owns the machinery. See `docs/working/with-the-user.md`.
- **The user is an experienced programmer and Godot architect who has never used Roblox or Luau.** Talk to them as one. Explain Roblox by its Godot counterpart. Ask one precise question, show the reasoning, and expect to be challenged. Show structure as a diagram, not a listing.
- **Build small pieces, one at a time.** No design document is a gate before code. No giant diffs and no rewrites: past a few hundred lines, show the plan first. Shared machinery is shown before it is written.
- **Quality before speed.** The user, 2026-11-20: "Cant build ontop a foundation made on mud." Maintainable, decoupled, checked code outranks finishing sooner (`docs/working/engineering-rules.md`).
- **Before changing code, read `docs/code/names.md` and `docs/code/conventions.md`.** In short: a class makes sense from its bare names with no context; a name says what it acts on and where, and keeps its promise; a function does one thing, every time, with any check kept apart as `can...`; `And` in a name is two functions; deleting a directory does not break the one beside it; one rule tells another with a signal; a system does one job and knows no other system, and each could ship as a FoxFabric addon; general code never asks what sort of thing a thing is, and calls the thing's own script; a thing stays dumb: its script is handed only what it uses, and answers whoever called it; nothing is pulled out before there is a pattern, and no combination gets a piece of its own; every word in a name is a real thing in the code, in Roblox's word first and Godot's second; a comment says completely what a thing does, in its own words, by Godot's writing guidelines, and in the defined words (client, server, content); the rules know nothing of the mouse; nothing nests more than two deep. `lune run tools/check` must pass.
- **Roblox first.** Before proposing a thing of our own, say what Roblox has for it and why that will not do.
- **Before showing the user code, read `docs/working/code-reviews/README.md`.** They have corrected the code twenty times, and the same mistakes are easy to repeat.
- **Commit as work is done. Push nothing unless asked.**
- **No AI-generated art reaches the public.** Player-facing words are drafted by Claude and reviewed by the user before release.
- **Ask before any action that spends Robux.** Passwords and verification stay with the user. Never put the Roblox account name, or anything about the user, in a web request. Do not save or publish the Studio place. Tools and skills may be fetched without asking ("Youre free to grab and load whatever you need", 2026-11-20): read each first, and note it in `docs/roblox/studio.md`.
- **Helper agents run on Sonnet, a few at a time.** One overnight run used the account's whole weekly allowance. Design work stays in the main session.

## Where things stand (2026-11-21)
- **Playable:** a first loop on grey boxes, for PC. A pack and hotbar, stacks that are thrown and land, one shared plot of tiles, a crate, and a stove that cooks. `README.md` says how to run it.
- **The game does not use the libraries yet.** `src/shared/inventory`, `src/shared/items`, and `src/shared/groundItems` are an older inventory of the game's own. The user approved replacing them with glue over the libraries `inventory` and `ground-items`, which stand in folders beside this repo. That waits on their read of each library, and on how the game holds a clone of each. `gyms/items` shows the glue.
- **An outside audit began on 2026-11-21.** The user is having a Gemini model audit the code, and may write the load-bearing parts by hand. Start no rewrite. The file named FOR-THE-AUDITOR, in the folder above, says what is built, what is known to be wrong, and what a review round of that day found, mended, and left. The game as the user described it to that model is in `docs/game/products-for-people.md`.
- **Checked:** `lune run tools/check` passes, and the play test passes in Studio. The counts are in `docs/status/now.md`.
- **Next, and what waits on the user:** `docs/status/next.md` and `docs/status/asked-of-the-user.md`. The game's tree is in `docs/code/tree.md`.

More in `docs/status/now.md`. What comes after is in `docs/status/next.md`.

## The map
| Where | What it holds | Read it |
|---|---|---|
| `docs/status/now.md`, `docs/status/next.md` | Where things stand, and what comes next | At the start of a session |
| `docs/status/asked-of-the-user.md` | What the user has been asked and has not answered | Before asking them anything |
| `docs/status/claudes-calls.md` | Decisions Claude made, for the user to veto | Before building on one of them |
| `docs/game/` | The brief, the core rule, the setting, design decisions, the consistency rule, dropped items, placed objects | Designing anything a player meets |
| `docs/working/` | How the user and Claude work, and the user's engineering rules | Planning work |
| `docs/working/code-reviews/` | The user's reviews of the code, in their words | Before showing them code |
| `docs/code/names.md`, `docs/code/conventions.md` | How things are named, and how code is written | Before changing code. Both load by themselves when a file in `src` or `tests` is opened |
| `docs/code/pieces.md`, `docs/code/checks.md` | What exists, and how it is checked | Finding your way; before calling anything done |
| `docs/roblox/` | Platform facts, driving Studio, input, Roblox explained for a Godot developer | Touching the platform, or explaining it |
| `docs/research/`, `docs/architecture/`, `docs/code/reviews/` | Research and reviews. Large | Only for the question each answers. Each folder's README says which |

`docs/README.md` describes the folders, and how to add to them.
