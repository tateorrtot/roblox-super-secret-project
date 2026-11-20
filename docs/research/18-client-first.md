# Acting on the player's own machine first: what Roblox does, and what it offers

Researched on 2026-11-20. The user asked why everything waits for the server, and whether the hotbar, the inventory and a thrown item could be shown at once and corrected afterwards, as a character's movement is.

**Caveats.** Four readers on Sonnet, each checked by a second reader who fetched the sources again. They read Roblox's documentation, two staff posts and an old open copy of Roblox's backpack script. Nothing was run. Where the documentation is silent, this file says so. `docs/architecture/08-architecture-grounding.md` has the fuller study of Server Authority, from 2026-11-18.

## What the user asked, in their words
> why are we doing it so the server is always synced. Cant we do more predictive client stuff. Like how players move they dont actually wait for the server they show their character moving and then the server sees it and verifies and if the client moves but the server doesnt see you get a "rubberband" right? Cant it be like that for physics and for hotbars, inventories, etc. Then theres no delay yet we stay server authoritive. How does robloxs built in hotbar handle this issue?

> Why is there even a delay at all when throwing an item? Why cant we treat it like characters or the hotbar where the client simulates it? Theyre the ones throwing it no?

## How Roblox itself does it
| Question | What the sources say | From |
|---|---|---|
| Who moves a player's character? | The player's own machine, at once. A machine can own the physics of its character, and "Roblox cannot verify physics calculations when a client has ownership" | Network ownership page; security page |
| Does the server check it? | Not by default. The security page says a cheating machine can move its character anywhere, and that a game must validate on the server whatever matters | Security tactics page |
| Is there a rubber band? | Not by default. Nothing pulls a character back unless the game's own server code does. The documentation describes the pull-back only under Server Authority | Server Authority page |
| How does the built-in hotbar equip a tool? | Roblox's own backpack script sets the tool's parent to the character on the player's machine, at once. It does not ask the server and wait. The copy read is an old open one, and the readers could not confirm the current script is the same | `github.com/Roblox/Core-Scripts`, `BackpackScript.lua` |
| Does the server then know? | The documentation does not say which changes to a tool's parent made on a player's machine reach the server | Not found |
| What does Roblox teach for a shot? | Its blaster tutorial has the player's machine show the shot at once, tell the server with a RemoteEvent, and the server check everything and show the other players | Gameplay scripting tutorials |
| Do our messages keep their order? | Yes. RemoteEvents arrive in the order they were fired, across different RemoteEvents too. An UnreliableRemoteEvent promises neither order nor arrival | Remote events page |

So the user's picture is right for the first half and not the second. A Roblox character does move at once on its own machine. By default the server does not verify it, so there is no rubber band: a cheat is simply believed.

## What Roblox offers: Server Authority
Released for all games on 2026-07-09, and switched on for a whole place with `Workspace.AuthorityMode = Server`. It is the rubber band the user described, built into the engine.

- **What it does.** Players' machines send only their inputs. Each machine predicts a few frames ahead, and when the server disagrees it goes back to the server's state and runs those frames again.
- **What it covers.** Characters and physics near the player's character. A game's own state is covered only if it is kept in attributes on instances and changed inside functions bound with `RunService:BindToSimulation`, in a module both sides load.
- **A thrown part.** Created inside such a function, it appears on the thrower's machine at once and is matched with the server's copy when that arrives. Created by ordinary server code, as ours is, no source says it would be.
- **What it costs.** It switches on five other settings, among them the newer replication system, streaming and deferred signals. Servers and players' machines work harder. Phone bugs were open in November 2026. Attributes are limited to 64 on an instance, and names and text to 50 characters.
- **Our rules would not be predicted by it.** They are Luau tables, and a staff post says "Luau variables in scripts are not rolled back".

## A part the server creates and throws, without Server Authority
- A part made by a server script belongs to the server at first. The engine may then hand it to a nearby player's machine. No source says how soon.
- A part made by a script on a player's machine exists only on that machine, and so does a change that machine makes to a part the server sent it.
- Our own measurements are in `16-dropped-items.md`: in Studio the thrower first sees the part move about 140 milliseconds after the key press when Roblox chooses the owner or the thrower is given it, and about 280 when the server keeps it. The test session draws only 15 frames a second, so each figure is good to about 67 milliseconds.

## What follows for this game
- **The wait is the trip to the server and back.** The request goes up, the server acts, and the answer comes down. That is one round trip for the hotbar, for a click in the inventory, and for a throw. In Studio it is a frame or two, because the server is on the same PC.
- **For our own state, we predict it ourselves.** The rules are shared code, so a player's machine can apply a request to its own copy at once. Requests are numbered, each snapshot says the last request it includes, and the machine re-applies the ones not yet answered. When the server refuses one, the machine's copy snaps back. That is the rubber band, for an inventory.
- **For a thrown item,** the thrower's machine can show a look-alike part at once and swap it for the real one when that arrives. It needs the numbered requests, to know which real part is its own.
- **Server Authority stays an open decision** (`docs/game/decisions.md`). It would give prediction for characters and physics, at the cost above, and would not cover the rules. It is looked at again with the first vehicle.
