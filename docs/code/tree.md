# The game's tree

How the game breaks down, from the top. The top is the user's, in their words of 2026-11-21 (`docs/working/code-reviews/2026-11-21-6-top-down.md`). Everything below the first level is Claude's draft, for them to correct. In each diagram an indent means that the thing above holds and calls the thing below.

## The top
```
the game
├─ items and moving them around
├─ objects in the world that can be broken or placed
└─ entities: things that move                           parked by the user
```

## The layers
Each branch is cut into the four layers of the `CLAUDE.md` in the folder above this repo. A library works in any game and knows nothing above it. The other three are this game's own, and live in this repo.

```
content      this game's own things             uses the systems
UI           what shows the systems             reads, never writes
systems      this game's rules                  call the libraries, and each other
libraries    code that works in any game        one folder each, beside this repo
```

## Items and moving them around
```
items and moving them around
├─ content
│  └─ each kind of item: its id, how many fit in one slot, what it does
├─ UI
│  ├─ draws slots, and the stack that a person holds between slots
│  └─ turns a click or a drag into what the person asks for
└─ systems
   ├─ kinds                      the list of kinds of item, found by id
   ├─ a character's items        a pack, a hotbar, and a held stack
   ├─ what a person asks for     pick up, put down, swap, spread, gather, quick move
   ├─ dropping and picking up    joins the two libraries below
   ├─ the door                   checks what a client sent, and tells each client what changed
   └─ libraries
      ├─ inventory               numbered slots, each a stack or nothing
      └─ ground-items            things that lie in a world
```

| Part | Layer | Built |
|---|---|---|
| `inventory` | Library, in the folder `inventory` beside this repo | Started on the night of 2026-11-21, by a session that was told nothing of this game. Its page is the README of that folder |
| `ground-items` | Library, in the folder `ground-items` beside this repo | Started the same night, the same way |
| Kinds, a character's items, what a person asks for, dropping and picking up, the door | Systems | Not built on the libraries. Today's `src/shared` does these jobs in `ItemRegistry`, `PlayerState`, `InventoryScreen`, `InventoryRequests`, `World`, and `PlayerSnapshot` |
| The UI | UI | Today's `src/client` |
| Each kind of item | Content | Today's `src/shared/content/Items.luau` |

- **Each system above is glue:** it calls one function of a library, then another. The user's pattern, 2026-11-21: ""inside of inventory A, at this slot, grab this stack." Thats one function. "Inside inventory B, distribute an item stack across these slots" Thats another function. Dont bake it together".
- **The door and saving are on no branch of the user's tree.** They are drawn here under the branch that uses them, and may be a branch of their own.
- **This repo's `src` is not rewritten yet.** It moves onto the libraries after the user has read them.

## Objects in the world that can be broken or placed
The user named three parts, and said that the third contradicted the second: a placed object; "a collection of placedobjects", with no name; and a plot, "some kinda constraint on placing things. Like a certain area you can build in". Earlier that day they confirmed that placed objects hold together on one body that physics can move, that building and physics are two systems joined by glue, and that what is cut loose becomes a body of its own (`docs/game/decisions.md`). This branch is a first cut, and nothing of it is built.

```
objects in the world that can be broken or placed
├─ content
│  └─ each kind of placed object: what it is made of, what interacting with it and breaking it do, its Model
├─ UI
│  └─ shows where a held thing would be placed
└─ systems
   ├─ placing and breaking       what a person asks for, and what it uses up
   ├─ bodies                     a weld for each join, so that Roblox moves what holds together as one
   ├─ plots                      an area that may be built in, and who may build there
   └─ libraries
      └─ joins (no name yet)     which things are joined to which, and which groups a removal cuts loose
```

Open, and the user's to decide before any of this branch is built:
- [ ] **Where the truth is kept.** Today a Luau table says what stands where, and parts are drawn from it. Roblox can answer "is this place free" and "what touches this" from its own parts. Which of the two is the record?
- [ ] **What joins two placed objects:** that they touch, or a join that placing makes.
- [ ] **A name for placed objects that hold together.** Roblox's word for parts joined into one rigid body is an assembly.
- [ ] **Whether a plot owns what is built in it,** or only says who may build there.
- [ ] **Whether a grid is kept at all,** since they want it as "a pure guideline rather than a set boundary".

## Entities
Parked by the user: "this one is complex maybe dont worry about it yet". Minecraft's word is entity. A dropped item is an entity there too, so `ground-items` may touch this branch.

## What Roblox already has
For each part above, `docs/research` has a brief of what Roblox offers, each checked by a second reader: the files whose names start with `23-roblox-first`.
