# The next branches of the tree: entities, and vehicles

A first cut of the two parts that the user named for when the night's plan of 2026-11-21 ran out: "do the next parts of the game like vehicles/npcs". Nothing here is built, and every line below the user's own words is Claude's draft for them to correct. `tree.md` has the top of the tree, the layers, and the two branches before these. In each diagram an indent means that the thing above holds and calls the thing below.

## Entities: things that move
The user's words, 2026-11-21: players; NPCs, which are helpers, animals, and quest givers; "theyre all just some kind of "creature""; "they might have a food component and a comfort component. Ah wait those both belong in "needs"!"; "this one is complex maybe dont worry about it yet". And on 2026-11-20: "they should kinda be like the player and able to do the things a player can, its just an AI brain happens to be driving it".

```
entities: things that move
├─ content
│  └─ each kind of creature or person: its needs, what it can do, its Model
├─ UI
│  └─ draws each one, and shows what a person is told about it
└─ systems
   ├─ actors          what anything that acts has: a place, what it carries, what it is doing
   ├─ brains          what decides for an actor: a person's client, or code
   ├─ needs           what a creature needs, how each need falls as time passes, what meeting it gives
   ├─ jobs            what a helper was asked to do, as steps that a need can interrupt
   ├─ walking         turns "go there" into a path from Roblox's `PathfindingService`
   └─ libraries
      ├─ state machine    which of several states is active
      ├─ pool             a value between bounds, such as one need
      └─ brain            picks the next step from jobs and needs, and returns what the actor wants to do
```

- **The idea this branch rests on: a player and a helper are both actors.** Today every request takes a `PlayerState`, so only a player can pick up, place, or cook. If a helper does what a player can, each system acts for an actor. A person's client asks through the door, which checks what it sent. A helper's brain asks with a plain call.
- **A brain only says what its actor wants to do.** It moves nothing. The user's own draft for a character, written for Godot: "Controllers (player or AI) only produce intents, like "move this way" or "jump"" (`docs/research/21-foxfabric-drafts.md`).
- **Three libraries, and each is our own to write.** No library that exists passes its checklist (`docs/research/25-library-audit-state-machine.md`, `docs/research/25-library-audit-stats.md`, `docs/research/25-library-audit-npc-brains.md`). The state machines and the pool are the user's own designs for FoxFabric, so their rules are already written.
- **Walking is Roblox's.** `PathfindingService` makes the path. One library that exists wraps it well and is one day old (`docs/research/25-library-audit-npc-brains.md`): it is a model to copy from, and not yet a thing to depend on.

Open, and the user's to decide:
- [ ] **Whether a thing that lies on the ground is an entity.** The user, late on 2026-11-21: "isnt it an entity? like we should have some kinda entity library no?" Of the `ground-items` library, six of `Ground`'s eight functions and one of `Drop`'s four fields are what any thing in a world needs: the list, adding and removing, what is in a box, and saving. The rest is only a drop's.
- [ ] **The word.** Minecraft says entity, and mob for one that acts. Roblox has a character, which is a `Model` with a `Humanoid`. The user said creature.
- [ ] **What an NPC is made of.** A Roblox character that the engine moves, or a record on the server that each client draws. `docs/game/decisions.md` says the second, for helpers, from before any was built.
- [ ] **How many at once,** since that decides the answer above. No number is written down.
- [ ] **Whether needs punish.** `docs/game/decisions.md`: "Needs reward, they do not punish."

## Vehicles
A vehicle is not a branch of its own. The user, in `docs/game/decisions.md`: vehicles and large creatures are "platforms you build on, as in ARK", and on 2026-11-21, of placed objects that hold together on one body: "I think the same could apply for vehicles. Or buildings." So a vehicle is a body of placed objects, from the objects branch, and something that drives the body.

```
a vehicle
├─ a body of placed objects     the objects branch: placing, joins, bodies
├─ content
│  └─ each kind of wheel, seat, engine, and hull: a placed object like any other
└─ systems
   ├─ driving        turns what the driver wants into forces on the body: one way each for ground, water, air
   ├─ seats          who rides, who drives, and whose client moves the body
   └─ libraries
      └─ drive (no name yet)    a function: what the driver wants and how the wheels stand, to what each motor does
```

- **What the driver wants is one small value:** throttle, brake, steer. A person and a helper's brain both make one, so a helper can drive.
- **Nothing that exists drives a body that a player built.** Every chassis found needs wheels with fixed names, such as `FL`, `FR`, `RL`, `RR` (`docs/research/25-library-audit-vehicles.md`). A-Chassis is the one maintained kit, and is a whole car with gauges and sounds.
- **Roblox does the physics:** a `HingeConstraint` as each wheel's motor, a spring for each wheel, and the driver's client as the body's network owner (`docs/research/23-roblox-first-placing-and-joining.md`).
- **Tried in a gym, and the idea holds** (`gyms/vehicles`). One function of 80 lines, which knows no Roblox instance, drove two bodies of welded blocks with wheels at uneven places: one with two steering wheels, one that turns as a tank does. A wheel must not collide with the body that it is on. A block cut loose at speed became a body of its own, and the vehicle drove on.
- **This waits on the objects branch.** Its five open decisions in `tree.md` come first, since a vehicle is made of what that branch places and joins.

## For the user's reading
- `docs/research/27-entities-summary.md`: what an entity is elsewhere, what Roblox already does for every thing in its world, and the one problem that an entity might solve here.
- `docs/code/state-machine-uses.md`: a draft list of where a state machine might be used. One clear use was found: a helper.
- `docs/working/libraries-as-submodules.md`: how the game would hold a clone of each library inside itself, tried in a scratch folder.

## What was looked up for these
- What Roblox already has: the files of `docs/research` whose names start with `23-roblox-first`.
- Libraries that exist, judged by their source: the files whose names start with `25-library-audit`. The answer for each of the four was to write our own.
- How good Roblox games are made and built: the files whose names start with `26-good-games`.
