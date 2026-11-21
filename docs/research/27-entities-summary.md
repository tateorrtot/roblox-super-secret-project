# What an entity is, and the one problem it solves

For the user, who said on 2026-11-21: "ill ahve to look over architecture for defining entities tomorrow and why they even exist. Like what problem (notice its problem not probemS plural...) theyre trying to solve". Two readers on Sonnet read the documentation, and a second reader checked each: `27-entities-elsewhere.md` and `27-entities-in-roblox.md`. This page is Claude's reading of the two. What a source states is kept apart from what Claude infers.

## What the sources state
**No source states the one problem.** Not Minecraft's wiki, not the documentation for its modders, not Unity's, and not the two entity-component libraries read. Each says what an entity is, and none says why it exists.

| Where | What an entity is, in its own words | What every one gets |
|---|---|---|
| Minecraft | "all dynamic objects throughout the Minecraft world" | A position, a rotation, a velocity, and a bounding box. The game ticks each one, saves each one, and sends each one to the clients |
| Minecraft's block entity | "an additional object associated with certain blocks": a chest, a furnace | Data that a block cannot hold, and code that runs while its chunk is loaded. It never moves |
| Godot | Has no entity. "Nodes are your game's smallest building blocks that you arrange into trees" | A `Node3D` gives a place, and a `CharacterBody3D` a body that code moves |
| Unity | A `GameObject` is "anything that can exist in a Scene", and a container for components | Nothing by itself: its components decide what it does |
| An entity-component system | "An entity is a unique thing in the world, and is represented by a 64 bit id" | Nothing: an id with no data. The data is in components |
| Roblox | Has no entity. Its documentation uses the word once, to describe an assembly | See below |

- **In Minecraft a dropped item is an entity.** It holds the stack, and adds an age, a pickup delay, an owner, and a thrower.
- **A chest in Minecraft is not an entity.** It is a block, with a block entity for what it holds.

## What Roblox already does for every thing in the world
From Roblox's own pages, read on 2026-11-21:
- **A place and a body.** A `BasePart` is "the abstract base class for in-world objects that physically interact", and a `Model` groups parts.
- **Moving it.** Physics moves every part that is not anchored, on the server or on one client.
- **Sending it to clients.** Whatever is under `Workspace` is sent, and streamed in and out around each player.
- **Finding what is in a region.** `GetPartBoundsInBox` and `GetPartBoundsInRadius`.
- **Marking it and putting data on it.** Tags, which are found by name, and attributes.

What Roblox does not do, by the same pages:
- **Save it.** Saving is a call that the game makes, into a store of keys and values.
- **Keep it across servers or a restart.** No page says that an instance outlives its server.
- **Tick it.** There is no update for each thing. Roblox's own NPC is a `Model` with a `Script`.
- **Give a script its id.** `UniqueId` "is not readable or writable from scripts".

## Claude's inference, for the user to judge
- **In Minecraft, an entity solves this:** the world is a grid of blocks, and some things are not on the grid. Each of those needs to be updated, saved, and sent, and one kind of thing lets one piece of code do each.
- **Roblox has no grid, so most of that problem is already solved.** Every thing in a Roblox world is off the grid already, and the engine moves it, sends it, and finds it.
- **What is left, if anything, is one of Roblox's gaps:** a thing in the world that the game must save, or must know by an id that outlives its part. That is one problem. Ticking is another, and finding things near a point is a third, which Roblox answers.
- **So the question for this game is not "do we need entities".** It is "which things in the world must be saved or known after their part is gone, and is that one problem or several".
- **A dropped item is the first case.** Today the `ground-items` library keeps its own list of drops and its own search of a region. Roblox keeps a list of parts and searches a region too. Which of the two is the record is the open decision in `docs/code/tree.md` named "Where the truth is kept".

## Also found
- **Developers on Roblox who keep their own list of things** give different reasons: speed of reading data in Luau (the author of jecs), and avoiding rigid inheritance (one forum post). None is a statement from Roblox.
- **Non-player characters:** Roblox's own kit uses a `Model` with a `Humanoid`. One forum thread reports that data on the server, drawn by each client, cut a script's share of the frame from 1.4% to 0.2%. No statement from Roblox was found on the cost of either.
- **What the checkers corrected:** 7 claims in the two briefs. Each file lists them at its end.
