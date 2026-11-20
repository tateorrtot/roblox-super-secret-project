# Physics networking: what the talk says, and what Roblox already does

Researched on 2026-11-20. The user asked whether a dropped item is still networked once it lands, and whether heavy physics networking is ours to build or Roblox's. They remembered Glenn Fiedler's GDC 2015 talk, "Networking for Physics Programmers", and pasted another assistant's answer for checking.

**Caveats.** Three readers on Sonnet, each checked by a second. They read Fiedler's article series on gafferongames.com, which covers the same ground as the talk, and not the talk itself. Roblox publishes no send rate, and is replacing its physics replication during 2026, so anything about rates may be stale.

## What the user asked, in their words
> When an item lands, are we still networking it? In fact, do we need to do heavy physics networking and be careful at all or does roblox handle it?
>
> If I recall, the client is ENTIRELY a renderer and does no physics computing. Then, theres optimizations like actually only sending the physics for objects the client needs/can see. The client figures out what it needs, not the server, to save bandwidth. And the way the physics objects are networked is by sending them actually pretty slow compared to the rest of the game. To deal with how weird that would look ... you use some kind of curve, math, and tweens/lerping animation. And for things further away from the client it gets less and less accurate. I think the curves are called Hermite spline interpolation.

They also said: "Ive heard in most physics-based multiplayer games network bandwith - not computing power - is what kills performance".

## What Fiedler's series says
He compares three ways to network a physics simulation.

| Way | What is sent | What the receiving machine does |
|---|---|---|
| Deterministic lockstep | Only the players' inputs | Runs the whole simulation itself. Needs every machine to compute exactly the same numbers |
| **Snapshot interpolation** | The state of the objects, a few times a second | **Runs no physics.** It draws, smoothing between the snapshots it has. This is the one the user remembered |
| State synchronization | Inputs and state | Runs the simulation too, and is corrected by what arrives |

On snapshot interpolation:
- **Slow sending.** Sixty snapshots a second of his test scene cost about 11.6 megabits a second. He drops to 10 a second.
- **A delay is the price.** The receiver holds snapshots back by three send intervals so that it always has two to draw between: about 300 milliseconds at 10 a second.
- **Hermite interpolation.** Drawing a straight line between two snapshots a tenth of a second apart looks wrong. A Hermite curve also uses each object's velocity, which must then be sent, and passes through both points at the right speeds.
- **Smaller packets.** Positions and rotations sent with fewer bits, only what changed since a snapshot the receiver is known to have, and a flag for an object at rest so that its velocity need not be sent.

Where the user's memory and the articles part:
- **Who decides what is sent.** In the articles it is the sender. It keeps a running priority for each object, sends the ones that have waited longest, and the receiver only acknowledges what arrived. The readers found nowhere that the receiving machine asks for what it needs.
- **Distance.** The readers found nothing in the articles about sending far objects less often or less exactly. Priority there goes by what an object is doing: the player's own, then moving ones, then resting ones.

Both may be in the talk itself, or in another talk. Neither was confirmed.

## What Roblox does by itself
The developer writes none of this for a part that Roblox's physics moves.

| Question | Answer | From |
|---|---|---|
| Who sends a moving part's motion? | The engine. It sends position, rotation and velocities, and a machine that does not own the part draws it by interpolation | A Roblox engineer |
| How often? | Roblox does not say. Developers say 20 times a second, or 15 | Unofficial, and they disagree |
| Is there a budget? | About 40 KB a second of physics to each player. Past it, some objects are sent less often, and far ones lag behind near ones | A Roblox engineer, 2024 |
| After a part lands? | The engine sends a last update and the part sleeps. No source says outright that nothing more is sent. In our own test the data rate with 460 parts at rest was the same as with none | A Roblox engineer; `16-dropped-items.md` |
| Who simulates? | By default the engine hands a loose part near a player to that player's machine. `SetNetworkOwner(nil)` keeps it on the server, and the documentation warns that it can then look jittery | Documentation |
| Who decides what a machine has at all? | The server, by distance, when instance streaming is on | Documentation |
| Our own messages? | A RemoteEvent is reliable and queued. An UnreliableRemoteEvent drops anything over 1,000 bytes and is meant for things that change all the time. About 500 a second to each player | Documentation |

Roblox is replacing its physics replication in 2026. The new one gives priority to motion near players and makes sure the resting place arrives. It was switched on in May 2026, rolled back, and started again in June.

## The other assistant's answer, checked
| It said | Verdict |
|---|---|
| Roblox hands physics for nearby loose parts to players' machines by default | Confirmed |
| `SetNetworkOwner(nil)` is needed for server authority | Confirmed. The documentation adds that it may jitter |
| A settled part sleeps | Confirmed |
| A sleeping part sends "zero" updates, with "delta-compression" | No source says so. Our test agrees with the first half |
| Anchoring a settled item stops bumps from waking it | No source addresses it |
| Server-owned parts replicate "at roughly 20Hz" | No official figure exists |
| That is "great for tens or a few hundred parts" | No source gives a number. The 40 KB a second budget is the real limit |
| A custom system is only needed for "hundreds or thousands" of objects moving at once | No source gives a threshold |

Its direction was right. Its numbers were not from any source the readers could find.

## What follows for this game
- **A dropped item needs none of Fiedler's machinery.** It moves for about a second, Roblox sends that, and then it rests and costs nothing.
- **The budget is on things moving at once, all the time.** Hundreds of items riding belts or water is where 40 KB a second would run out.
- **For that, send what decides the motion and not the motion.** An item that entered a belt at a known time, on a belt of a known speed, can be drawn by every machine with nothing more sent. That is what `StationProgress` already does for a stove's gauges. It is cheaper than snapshots, has no 300 millisecond delay, and suits anything whose motion is fixed once it starts.
- **Fiedler's snapshot interpolation is the tool for motion that cannot be worked out ahead,** such as many free physics objects pushed about at once, if the game ever has more of that than Roblox's budget carries. It would mean simulating on the server, sending our own snapshots through UnreliableRemoteEvents, and drawing copies on each machine.
