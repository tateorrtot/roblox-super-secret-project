# The fifteenth review: "who said we cant place things mid air? Or that Y is always up?" (2026-11-21)

The user read Claude's report on the Models and the class reference. Their words, and what Claude took from them.

## Whether the documentation is good
> Are you confident in the documentation's quality and will it be useful to you and a human later? Or right now?

- **Claude measured it and said what it found** (`docs/status/now.md`): complete, and not yet written to Godot's guidelines.

## Why there was a colour
Of "Items still have a `color` ... I left it because you said an item has a texture":
> You... left it because I said an item has a texture...? What? What the heck is color then? A modulate like in godot? What is color if we have a texture?

Of the crate's colour being written three times:
> Right so... why is there a colour..? Im confused

- **There is no art in the game, and Claude had never said so in those words.** Every thing was drawn as a block of a colour with its name on it, so that a log could be told from a fish. The colour was that block's. It was not a tint over a texture.
- **"I left it because you said an item has a texture" explained nothing.** Say what a thing is before why it is there.
- **A stand-in must not look like a decision.** A colour written on every item read as a rule of the game. It is gone: a thing without art is a plain grey block with its name.
- **They asked three times, over two reviews.** The first time was enough to mend it.

## How an item looks
> Items use 2D textures or a 3D model if that makes sense. Like holding a sword (a 2D texture in the inventory, then you hold it in your hand and its this 2D texture that has some depth / model to it). An "oak_log" is this 3D model at an angle in your inventory then you hold it in your hand and you see it. Things on the ground look the way they do in your hand.

> If you need I can give you more specifics and design.

> Minecraft has some pattern to what gets a 3D model in the inventory vs what gets a 2D texture. I think some way to give things a 2D items some depth like in minecraft automatically is a good idea. But not all items are going to be like that so we cant make it a rigid contract if that makes sense. Its almost like a small component/extra functionality to create a 3D mesh out of a 2D image deterministically (not with LLMs).

- **An item's look is its own, and is one of several sorts:** a 2D texture, which is given depth where it is held or lies on the ground, or a 3D model, which is shown at an angle in a slot. More sorts may come, so no general code may assume one.
- **Giving a texture depth is a small piece that an item's look may use,** worked out from the image by rule.
- Recorded in `docs/game/decisions.md`. Not built: there is no art to build it with.

## Grids on bodies
Of what the first step to free placement leaves open:
> Yeah so... things might be able to float or not. Its an unknown we cant contract in or out. Id imagine if you break most things it will break it off into its own grid/plot. Kinda like in scrap mechanic. Or for simplicity and bug exploits we could just say it makes it drop as an item. Idk.

> This depends though because say we want to do the trees in lumber tycoon. Would we use our existing systems? A tree is really a lot of cubes arranged in a way that link or depend on others to stay connected. When you make a thin cut at the log at the very bottom it shouldnt drop everything as an item or leave it floating. It should become a physics object and fall down.

> I think the same could apply for vehicles. Or buildings.

> Its the most human intuitive.

> In minecraft terms id think of it as "VoxelGrids on PhysicsBodies". A plot right now is just a rigid "voxelgrid" in a set space with no physics right?

> (Yes I know a voxel grid might not be the right term if we do freeform)

- **A plot is to become a set of placed objects that hold together on one body.** The plot of today is the case where the body does not move. A tree, a vehicle and a building are the same thing on other bodies, and what is cut loose becomes a body of its own and falls.
- **Whether a thing may float is not for the general code to say.**
- **Roblox's physics is already this:** parts joined by welds are one assembly, and a group that loses its last join to an anchored part falls as one piece. Recorded in `docs/roblox/facts.md`.
- Not designed, and not built. Claude's reading of the model, and the choices in it, are in `docs/status/next.md`.

## Mid-air, and which way is up
> And with placement, who said we cant place things mid air? Or that Y is always up?

> Im just a bit confused why you wrote the contract that you place on X and Z. With... no Y.

> "Floors"/"Levels" are things that are sometimes rigidly coded.

> Or we could do it more intuitively where a floor isnt some hardcoded "layer of the building/plot"

- **Nobody said so but Claude.** It built a flat floor of tiles on the second day, as the least that would let them judge a grid by playing, and never went back to it.
- **Decided:** a thing may be placed in mid-air; up is the plot's own up, and not always the world's; and there are no floors or levels in the code. A floor is a placed object like any other.

## What changed in the code
- No thing of the game has a colour. An item's table lost `color`, and the crate's and the stove's are written nowhere. The stand-ins are one plain grey.
- Nothing else: the rest of this review is design, which Claude answered and wrote down.
