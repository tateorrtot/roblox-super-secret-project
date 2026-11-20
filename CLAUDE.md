# Roblox sandbox game

A systemic sandbox game on Roblox, written mostly by Claude for the user. This file is the map, and the rules that always apply. Everything else is in `docs/`, one topic to a file, and is read when it is needed.

**Keep this file short.** It is loaded whole into every session, and most helper agents are shown it. What changes from day to day goes in `docs/status/`. A new fact goes in the file for its topic, or in a new small file. This file changes only when a rule or the map changes.

## The brief (the user's words, 2026-11-18)
> I want you to make a Roblox game. I'd like you to author the majority of it to test your capabilities. Your primary goal is to make as successful of a game as possible with as high of a playercount for as long as possible as reasonable.

The user is here to help with whatever Claude can't do.

## Rules that always apply
- **The game has a core rule, not a core activity.** Never name one activity as the core, never reskin a current hit, and no "Verb a Noun" titles. Things in the game are physical objects and real events. This outranks Roblox's discovery criteria. See `docs/game/brief.md` and `docs/game/core-rule.md`.
- **The world is the user's.** Places, peoples, tone, names and the look are theirs. Claude drafts content in batches for their approval, and owns the machinery. See `docs/working/with-the-user.md`.
- **The user is an experienced programmer and Godot architect who has never used Roblox or Luau.** Talk to them as one. Explain Roblox by its Godot counterpart. Ask one precise question, show the reasoning, and expect to be challenged. Show structure as a diagram, not a listing.
- **Build small pieces, one at a time.** No design document is a gate before code. No giant diffs and no rewrites: past a few hundred lines, show the plan first. Shared machinery is shown before it is written.
- **Before changing code, read `docs/code/names.md` and `docs/code/conventions.md`.** In short: a class makes sense from its bare names with no context; a name says what it acts on and where, and keeps its promise; a function does one thing; deleting a directory does not break the one beside it; a comment says completely what a thing does, in its own words; the rules know nothing of the mouse; nothing nests more than two deep. `lune run tools/check` must pass.
- **Before showing the user code, read `docs/working/code-reviews/README.md`.** They have corrected the code six times, and the same mistakes are easy to repeat.
- **Commit as work is done. Push nothing unless asked.**
- **No AI-generated art reaches the public.** Player-facing words are drafted by Claude and reviewed by the user before release.
- **Ask before any action that spends Robux.** Passwords and verification stay with the user. Never put the Roblox account name, or anything about the user, in a web request. Do not save or publish the Studio place. A download needs the user's yes.
- **Helper agents run on Sonnet, a few at a time.** One overnight run used the account's whole weekly allowance. Design work stays in the main session.

## Where things stand (2026-11-20)
- **Playable:** a first loop on grey boxes, for PC. A pack and hotbar, stacks that are thrown and land, one shared plot of tiles, a crate, and a stove that cooks.
- **The code** was broken up, rewritten and renamed on 2026-11-20 after three reviews by the user. Branch `first-pieces`. Dropped items were rebuilt on the branch `dropped-items`, and untangled there after a fifth and a sixth review. It is not merged. Nothing is pushed.
- **Checked:** on `dropped-items`, `lune run tools/check` passes, and the play test passes 71 of 71 in Studio.
- **Waiting on the user:** a yes or no to signals in the rules and to acting on the player's machine first; their read of the untangled code; then their feedback on the game, which they are holding until the code is checked.

More in `docs/status/now.md`. What comes after is in `docs/status/next.md`.

## The map
| Where | What it holds | Read it |
|---|---|---|
| `docs/status/now.md`, `docs/status/next.md` | Where things stand, and what comes next | At the start of a session |
| `docs/status/asked-of-the-user.md` | What the user has been asked and has not answered | Before asking them anything |
| `docs/status/claudes-calls.md` | Decisions Claude made, for the user to veto | Before building on one of them |
| `docs/game/` | The brief, the core rule, the setting, design decisions, the consistency rule, dropped items | Designing anything a player meets |
| `docs/working/` | How the user and Claude work, and the user's engineering rules | Planning work |
| `docs/working/code-reviews/` | The user's reviews of the code, in their words | Before showing them code |
| `docs/code/names.md`, `docs/code/conventions.md` | How things are named, and how code is written | Before changing code. Both load by themselves when a file in `src` or `tests` is opened |
| `docs/code/pieces.md`, `docs/code/checks.md` | What exists, and how it is checked | Finding your way; before calling anything done |
| `docs/roblox/` | Platform facts, driving Studio, Roblox explained for a Godot developer | Touching the platform, or explaining it |
| `docs/research/`, `docs/architecture/`, `docs/code/reviews/` | Research and reviews. Large | Only for the question each answers. Each folder's README says which |

`docs/README.md` describes the folders, and how to add to them.
