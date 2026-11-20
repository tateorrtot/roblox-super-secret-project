# Dropped items

What the user wants of items lying in the world, and where that stands. Nothing here is built yet.

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

They called this "a bigger issue from the 'lots of little issues'" they have been holding back about the first build.

## What they asked for, as a list
1. A dropped item is a thing with momentum, taken from what dropped it.
2. A player or a dropper spits it out the way they face. A broken container just drops what it held.
3. Water can push it around.
4. Items do not collide with each other, or with players and creatures.
5. A block placed where an item lies pushes the item out of the way.

## Where it stands
- **Researched, not built.** `docs/research/16-dropped-items.md` has how Minecraft does each of these, with numbers, and what was measured in Roblox.
- **Claude's answer to "is it possible and reasonable": yes.** Roblox's physics handles 1, 2 and 4 cheaply. It does not do 5: a block placed over an item leaves the item inside it, so that rule has to be written, and a hand-written version worked in a test. 3 needs moving water, which does not exist yet.
- **Networking it is Roblox's job, not ours.** A dropped item moves for about a second, the engine sends that, and then it rests and costs nothing. `docs/research/17-physics-networking.md` has what the user asked about physics networking and what was found.
- **Not decided, and the user's to decide:** whether an item should fall as lightly as Minecraft's does or as heavily as Roblox's own gravity makes it; how far a throw goes.
- **Not decided, and Claude's to propose:** whether the flight is Roblox's physics, with the server telling the rules where each stack came to rest, or a small simulation of our own inside the rules.
