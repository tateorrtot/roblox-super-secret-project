# Working with the user

Who does what, what works with this user, and how code gets built here.

- Claude does most of the authoring: code, systems, building through the Studio MCP.
- The user covers art and assets, design that needs human taste, game feel, Roblox accounts and verification, phone playtests and marketing.
- **The user is an experienced programmer and systems architect** (8 years coding, about 5 years and 4,000 hours in Godot). Talk to them as one.
- **What works with this user:** ask one precise question, show reasoning, and expect to be challenged; they invite pushback ("youre free to challenge me"). What failed: handing over finished designs, panels of agents judging taste, rules derived from market research, and designing the whole architecture on paper through repeated drafts and agent reviews before any code existed.
- When you need something from the user, name the exact task.
- **A question is in plain words and can be read alone.** Claude asked "Build the item-decides shape first, starting with break, before prediction?", using a label of its own from a page earlier. The user: "Uh what? Im confused". Say what would be done, in the words they use.
- **A list says whether it is how things are, or what was done.** Claude listed the code's faults as they stood, and the user could not tell whether they had been fixed.
- **Claude may fetch and load the tools and skills it needs.** The user, 2026-11-20: "Youre free to grab and load whatever you need." Each is read before it is used, and written down in `docs/roblox/studio.md`. Robux, the account, and saving or publishing the place still need their yes.
- **Helper agents are used sparingly,** on Sonnet and a few at a time. One overnight run used the account's whole weekly allowance. A names test is cheap, because its reader uses no tools. Mutation runs and checks of bad arguments are done in the session.

## Ideas beyond what was asked (the user's correction, 2026-11-20)
Claude was building dropped items and was about to add a lighter gravity, custom friction and a guard against a case it had never seen. The user:
> You should really spend more time thinking about "should I do this..." instead of jumping the gun
>
> I think its fantastic you have ideas! ... Its more so jumping straight ahead and making them sometimes. For example, if I go to sleep go ahead! ... If im sitting here with you (right now)... Im mostly just sitting here waiting for you to do stuff and then you come back saying you built features Im not sure of. ... Its also how we end up with spaghettii and awful human-unmaintainbale codebases and APIs I need to correct you on

- **While the user is here,** say an idea in one line and let them choose. Build what was asked. Tell them the shape of an API as it is built, not at the end.
- **When they say they are away or asleep,** run with ideas, on a branch, in commits they can drop.
- **Before each piece, ask whether it is needed now.** Did they ask for it, or does something they asked for fail without it?
- **Use what the engine already does** before writing or tuning anything of our own. "I dont think its going to be reliable if you, an AI agent, make it instead of using a tried and true 10+ year old physics implementation."
- **No tuning of feel and no safeguard for an unseen problem before there is a game to play.** They called it "pre-mature optimization".
- **Say plainly what is being done.** "Physics experiment" read to them as Claude writing a physics engine. It was measuring Roblox's.
- **Changing an engine's default is a decision to put to the user, with what it costs.** Claude took ownership of dropped items' parts for the server, as a guard against cheating that nobody had asked for, and every thrown item drew a third of a second late. The user: "Im not even sure if its going to be an issue yet and youre changing a default for some reason?"
- **A small diff is not worth a tangled function.** Claude made `World.setPlayerPosition` also work out how a player's drops set off, because that kept the change small. The user: "Why is this method tied to that? Spaghetti!"
- **A fix has a cost too, and it is said when the fix is proposed.** This one is Claude's own, 2026-11-20. Fix 4 of the coupling review made the server the one keeper of the selected hotbar slot, so the highlight now waits for the server's answer. Claude proposed the fix without saying so, and a reviewer found it afterwards.
- **A restructuring is reviewed against the rule it was done for.** The untangle of `setPlayerPosition` produced two new functions that also did more than their names said. A reviewer caught them, not Claude.

## Time, and the play test (the user's question, 2026-11-20)
> Im noticing the roblox tests are always running? Are you constantly waiting on that? ... Cant you make changes, with lots of checkpoints, then test, then go back and see where when and why it broke? ... Im just wondering if anything in particular is making your replies and work take 30+ minutes everytime?

- **The fast checks run after every change.** `lune run tools/check` takes under a minute and does not touch Studio.
- **The play test runs once, when a turn's code changes are done.** It takes about four minutes and drives Studio with the mouse and the keyboard, so the user sees it, and their own use of the PC can spoil it. Say so before starting it, and say what to look for: they offered to watch with their hands off ("Go ahead ill watch you").
- **The play test comes last: after the helpers have reviewed the work and what they found is mended.** On 2026-11-20 Claude started it while two reviewers were still reading, and their findings then asked for changes. A change to a server or client script after the play test needs it run again.
- **Commits are the checkpoints.** If the play test fails, find the cause before running it again. A short trace of the one thing that failed takes half a minute, where the whole test takes four. On 2026-11-20 two such traces showed that a failure came from where the test character had spawned, and not from the code.
- **Read a result before building on it.** Claude once chained a commit after a play test run and committed a failure unread.
- **Quality comes before speed.** The user, later that day: "quality is a lot more important than speed!" Their words are at the top of `engineering-rules.md`. A turn may be long when the work needs it: say early what is taking the time, and keep saying where things are.

## Rules come from mistakes
- **When the user corrects something, name the pattern and write it as a rule** in the file for its topic. They steer by this: "Whenever it messes up, I tell it to add some rule/recognize the pattern and it puts it in as a rule".
- **Clean the notes up regularly, without asking first.** Merge duplicates, delete what a later rule replaced, move what is over to `status/history/`, and check each status file against what the user last said. The user, 2026-11-20: "You can take some time to clean it up and anything else youre using to manage the project if you need. I encourage you do this regularly if it helps you." The first clean-up was that day. `python tools/notes.py` checks paths and lengths, and cannot tell that a note has gone stale.

## Who decides what (confirmed: "that three tier split works for me")
| Tier | Who | What |
|---|---|---|
| The world | The user writes it; Claude does not change it without asking | Places and peoples, what each needs and makes, signature items, tone, names, the look |
| The content | Claude drafts in batches of ten to twenty definitions; the user approves, edits or rejects | Most items, recipes, creatures and machines, including the connecting pieces |
| The machinery | Claude owns it | Code, data format, numbers and timings, performance, bug fixes, tests |

The user owns the quality standard.

## How the code gets built (the user's correction, 2026-11-18)
After five drafts of an architecture note and three rounds of review by agents, with no code written, the user asked:
> Why are you trying to make the entire architecture / game at once?
>
> Why wouldnt you just identify the smaller re-usable pieces you need and individually make, review, and iterate on them instead of these massive architectural changes?

- **Build small reusable pieces, one at a time.** Identify the pieces the game needs. Make one. Show it to the user as a small diff with its tests. Iterate on their review. Then make the next.
- **A piece is one module with one job,** usable by itself and pure Luau wherever it can be, in the spirit of a FoxFabric micro-addon.
- **Compose pieces only once they exist.** Shared machinery (a kernel, a message format, a save format) is introduced when two real pieces need it, as its own small reviewed piece.
- **No design document is a gate before code.** No more drafts of docs/architecture/07, and no documents sent to panels of reviewing agents.
- The four points above are Claude's reading of the user's two questions. The user has not yet confirmed the details, or the list of pieces in `docs/code/pieces.md`.
