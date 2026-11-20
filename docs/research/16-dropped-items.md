# Dropped items: how Minecraft does it, and what Roblox can do

Researched on 2026-11-20, after the user said that dropped items here work nothing like Minecraft's and asked whether Minecraft's way is possible in Roblox. Their words are in `docs/game/dropped-items.md`.

**Caveats.** Five readers on Sonnet, each checked by a second, who upheld every claim sent to it. Minecraft's launch speeds come from decompiled 1.12 code, because the current code is not published; the wiki agrees with it on everything the wiki states. The Roblox measurements were made in Studio on the user's PC with one player, not on a phone or a real server.

## How a dropped item behaves in Minecraft
One block is one metre, and there are 20 ticks to a second.

| What | How it works |
|---|---|
| **It is an entity** | A box a quarter of a block across, with a position and a velocity. Only blocks stop it. It passes through other items, mobs and players |
| **Each tick** | Falls by 0.04 blocks per tick, each tick. Then every axis keeps 98% of its speed, or 98% times the slipperiness of the block below when it is on the ground (0.6 for most blocks, 0.98 for ice). On landing its vertical speed is halved and reversed, which is the small bounce |
| **Thrown by a player (Q)** | Starts at eye height less 0.3. Leaves at 0.3 blocks per tick (6 blocks a second) the way the player looks, plus 0.1 upward, plus a little random spread. It cannot be picked up for 40 ticks (2 seconds) |
| **From a dropper or dispenser** | Starts at the face. Leaves at 0.2 to 0.3 blocks per tick the way the block faces, with 0.2 upward |
| **From a broken block** | Appears within a quarter block of the block's middle, with up to 0.1 sideways and 0.2 upward. Pickup delay 10 ticks |
| **From a broken container** | Each stack is split into lots of 10 to 30 and scattered from inside the block, with a small random sideways speed and 0.2 upward |
| **Inside a solid block** | Every tick, an item that is inside a block is pushed out through the nearest open side, or the top if none is open, at 0.1 to 0.3 blocks per tick. This is why a block can be placed where an item lies: the item is squeezed out |
| **Flowing water** | Adds 0.014 blocks per tick along the flow, each tick. In still water an item floats slowly up |
| **Picking up** | A player takes items that touch their own box grown by 1 block sideways and half a block up and down. They take as many as fit and leave the rest |
| **Merging** | Two stacks of the same item within half a block sideways become one, the larger absorbing the smaller. Checked every 2 seconds, and at once when an item crosses into a new block |
| **Despawning** | After 6,000 ticks: five minutes |
| **How it looks** | It bobs and spins, and a bigger stack shows up to five copies. That is drawing only: the entity does not bob or spin |

Sources: `minecraft.wiki/w/Item_(entity)` and `minecraft.wiki/w/Entity`; decompiled `EntityItem`, `EntityPlayer`, `Entity`, `Block`, `InventoryHelper`, `BehaviorDefaultDispenseItem` and `World` from a public 1.12 tree; Paper's patch of the current `ItemEntity`.

## How ours behaved before 2026-11-20
This is what the user saw. It was replaced the same day (`docs/game/dropped-items.md`).
- A dropped stack does not move. The server works out one spot, the ground under a point 6 studs in front of the player, and the stack appears there, at rest (`DROP_DISTANCE` in `Main.server.luau`).
- That spot is found by looking straight down from above, so if a block stands there the spot is the top of the block.
- A player picks up what lies within 4 studs of the ground under their feet, measured in a straight line. The top of a 4-stud block beside them is farther than that. That is the bug the user saw.
- Nothing happens to a stack when a block is placed where it lies.

## What Roblox's physics does: measured
Three experiments in a play test, with parts one stud across, owned by the server, in a collision group that does not collide with itself (`build/drop_experiment*.luau`, not kept in git).

| Asked | Found |
|---|---|
| **300 items thrown at once** | The physics step took about 1 millisecond while they moved, and frames stayed at 60 a second. All were at rest within about a second, and asleep a second later, after which they cost nothing measurable. The one player was sent about 5 KB a second while they moved. None fell through the floor |
| **An item tossed at a 4-stud block 6 studs ahead**, from chest height | 20 of 20 hit its side and came to rest at its foot. None landed on top |
| **A block placed where a resting item lies** | **Roblox does not push the item out.** Left alone, it stays inside the block, 8 of 8. Woken by any means, it is squeezed half a stud into the floor under the block and stays there, 32 of 32 |
| **The same, with Minecraft's rule written by hand**: move the item out through the nearest side and let it drop | 40 of 40 ended outside, at rest, within 3 studs |

A fourth experiment, the same day, with cubes 1.2 studs across thrown at 24 studs a second forwards and 8 upwards from 3 studs up (`build/drop_experiment4.luau`):

| Asked | Found |
|---|---|
| **How far does a plain part go**, on Roblox's own gravity with nothing changed? | 6.7 studs, at rest after 0.7 seconds. All 20 landed in the same place |
| **A lighter fall**: an upward `VectorForce` on each part that leaves a gravity of 64 studs a second, each second | It works. With friction left alone the part slides to 18.9 studs. With friction 2 it stops dead where it lands, at 10.7 studs, after 0.5 seconds |
| **Does a part with that force still go to sleep?** | Yes. The count of moving parts was back to where it started three seconds after they came to rest, for every kind of body tried |
| **An `AlignOrientation` to stop the cube tumbling** | Works, and the part still sleeps. It lands in the same place |
| **A block destroyed under a resting item** | The item falls to the ground, 10 of 10. Roblox wakes it by itself |
| **An item thrown through a character**, in a collision group that does not collide with the characters' | 10 of 10 passed through, and the character did not move |
| **Thrown at a block 6 studs ahead** | 10 of 10 ended at its foot, touching its side |

Only the first row is used. The game throws plain parts on Roblox's own gravity, because the user asked on 2026-11-20 for nothing to be tuned before there is a game to play. The lighter fall is here for when they want to compare.

## What Roblox's documentation and developers say
- **Collision groups** make "collides with the world, not with other items or with characters". At most 32 groups. Characters must be put in a group of their own, each time one spawns.
- **Ownership.** Left alone, Roblox hands an unanchored part near a player to that player's machine, which can then put it anywhere. `SetNetworkOwner(nil)` keeps it with the server.
- **Sleep.** A part slower than about a third of a stud a second goes to sleep and is not simulated. An impulse, or a change to a physics property, wakes it.
- **Limits.** Roblox publishes none. Its physics channel to each player saturates near 40 KB a second (a staff post, 2024). One developer reported lag on low-end phones at about 200 loose crates. Lumber Tycoon 2 has lost items through the ground when a server was overloaded.
- **Water.** Terrain water has no flow. Anything that carries an item along would be ours to write.
- **What other games do.** Nothing public says how Booga Booga, Islands or The Survival Game do it. The common advice on the developer forum is to anchor a drop once it lands.
- **Server Authority,** announced in July 2026, predicts loose parts on the player's machine. Its documentation says nothing about thrown items.

## What follows
- Minecraft's behaviour is possible in Roblox. Roblox's own physics does the flight, the landing and the coming to rest, cheaply.
- Roblox's physics does not do the squeeze out of a placed block, the pickup box, merging, despawning, or water. Those are rules we write, and Minecraft's are simple.
- Roblox's gravity is 196 studs a second, each second. Minecraft's, at 4 studs to a block, is 64. An item that feels like Minecraft's needs its own, lighter gravity. That is a matter of feel, and the user's to judge.
- The rules cannot run Roblox's physics. If the flight is real physics, the server tells the rules where each stack has come to rest, as it already tells them where each player stands.
