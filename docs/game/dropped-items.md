# Dropped items

What the user wants of items loose in the world, what is built, and what is left to choose.

## The user's words (2026-11-20)
> The way dropped items work compared to minecraft seems to be completly different?
>
> The way it works in minecraft is you say hit Q, break a storage block, or activate a dropper, the item is an "entity". It gets this momentum from whatever it came from, if its a player/dropper it gets "spat" out in the direction the player/dropper is facing, a chest/storage it just drops
>
> Things like water can push it around. Items dont collide with eachother or other entities
>
> Infact before you do anything probably research how it works in minecraft.
>
> The reason I bring this up, is that possible/reasonable to do in roblox?
>
> It would completly eliminate the bug of landing ontop of a placed block, or placing blocks ontop of it (placing a block ontop of an item stack in minecraft just pushes the item stack out of the way)

They called this "a bigger issue from the 'lots of little issues'" they have been holding back about the first build. On 2026-11-20 they approved an outline and said "Go ahead and build it."

## What they asked for, and where each stands
| | They asked | Built |
|---|---|---|
| 1 | A dropped item is a thing with momentum, taken from what dropped it | Yes. Each ground item is an ordinary Roblox part, set moving once and then left to Roblox's physics |
| 2 | A player spits it out the way they face. A broken container just drops what it held | Yes for a player and for a broken container. There are no droppers yet |
| 3 | Water can push it around | No. There is no moving water |
| 4 | Items do not collide with each other, or with players and creatures | Yes, by Roblox's collision groups |
| 5 | A block placed where an item lies pushes the item out of the way | Yes. Roblox does not do this, so it is a rule of ours: out of the nearest side with nothing against it |

Also built, from the outline they approved: a player picks up what lies up to 7 studs above their feet, so a stack on a block beside them is in reach. A ground item lasts five minutes.

## Merging, copied from Minecraft
The user, 2026-11-20: "I think we should follow minecraft's item behaviour exactly if its not too much work."

- **Two ground items of the same item merge when they are close and both stacks fit in one stack.** Close is a gap of less than half a tile (2 studs) between their sides along x and along z, with neither lying wholly above the other. It is a box, not a distance.
- **The bigger stack takes in the smaller, and stays where it is.** Of two the same size, the one being looked at goes.
- **The one that is left is as new as the newer of the two:** its pickup delay and its five minutes are counted from the later spawn time.
- **A ground item is looked at when it is spawned, whenever it is told to have moved, and every two seconds after it was spawned.** So two stacks that lie still side by side merge within two seconds of there being room.
- All of it is `GroundItems.mergeItems`, which `World.advanceTo` runs first, ten times a second. The facts about Minecraft are in `docs/research/16-dropped-items.md`.

Two differences are left, and are Claude's call:
- **A moving item is looked at every tenth of a second.** Minecraft looks at one only as it crosses into a new block, so two stacks thrown to one spot can lie apart for up to two seconds there. Ours merge as soon as they are close. Copying it would mean ground items knowing about tiles, to make merging slower.
- **The nearest is tried first, and of two equally near the older.** Minecraft tries them in whatever order it holds them. Ours is the same every time, which the tests need.

## How it is built
- **Roblox's physics does all the motion.** We wrote no physics. The user, 2026-11-20: "I dont think its going to be reliable if you, an AI agent, make it instead of using a tried and true 10+ year old physics implementation."
- **The rules decide where a stack starts and how fast,** and are told where each one has got to (`World.setGroundItemPosition`), as they are told where each character is.
- **Which machine works out a part's motion is left to Roblox,** which gives a part near a player to that player's machine. Claude had first taken every part for the server, as a guard against cheating that nobody had asked for, and every thrown item drew about a third of a second late. The user felt it the first time they played, and said to go back to the default. The numbers are in `docs/research/16-dropped-items.md`.
- `docs/code/pieces.md` lists the pieces. `docs/research/16-dropped-items.md` has how Minecraft does each thing and what was measured in Roblox.

## Ideas not built, for the user to choose
None is needed now. Each was Claude's idea, set aside when the user asked it to stop building ahead (`docs/working/with-the-user.md`).
- **A lighter, floatier fall,** as Minecraft's items have. Measured and working: one built-in force on each part, and the part still goes to sleep. Numbers are in `docs/research/16-dropped-items.md`.
- **Two pickup delays,** as in Minecraft: 2 seconds for what a player throws, half a second for everything else. There is one delay of 1.5 seconds.
- **A bigger stack drawn as a bigger block.** Every ground item is one size, with the count on its label.
- **A check on every moving item for being inside a block.** The rule runs only when a block is placed. An item flying through a tile at the instant a block is placed there could end inside it.
- **Keeping an item's age when it is pushed out of a block.** A pushed item is taken up and thrown again, so its five minutes and its pickup delay start over.

## The user's to judge by playing
How far a throw goes, how a knocked-off crate scatters, and whether items should fall more lightly. The numbers are the constants at the top of `src/shared/world/World.luau`, and are Claude's first guesses.
