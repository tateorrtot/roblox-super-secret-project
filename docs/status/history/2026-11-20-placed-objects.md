# Items and placed objects become two systems (2026-11-20)

What was done when the user said "Keep going" to the three steps Claude had shown them. It is over; `docs/status/now.md` says where things stand.

## What they had said
- Their ninth review: items and placed objects are "two v e r y different systems that shouldnt rely on or mention eachother". Glue lives outside both (`docs/working/code-reviews/2026-11-20-8-two-systems.md`).
- Of the three steps, the same day: "Good. Good. and good." Of the name: "I like PlacedObject!" And how they picture a kind: a script of its own, a mediator, which can have an inventory, a process, or "giant explosion when clicked" (`docs/game/placed-objects.md`).
- They asked whether Luau has interfaces, "like godots proposed traits for more strict typing". It has no keyword for one. A table type that lists functions is one, and the type checker holds a kind to it.
- They also asked: "so have you actually changed UseAndHit yet". No. It is next (`docs/status/next.md`).

## What was built
On a new branch, `placed-objects`, cut from `dropped-items`. Eight commits, each with every check passing.

| Commit | What it did |
|---|---|
| A placed item is called a placed object | Spelling only, across the code, the tests and the play test |
| A player's state no longer names placed objects | `PlayerState.openScreen` is the one way to open the screen. The world remembers which placed object a screen was opened on |
| Step 1 | The inventory comes out of the placed object. The world keeps what a placed object is given, by its id. `plots` no longer requires `inventory` |
| Step 2 | A placed object is a kind and a tile. Each kind is a module in `src/shared/placedObjectKinds`. Items lose `placeable` and `slotCount`. `plots` no longer requires `items` |
| Step 3 | Each kind says what interacting with it does and what breaking it leaves. The requests are `interactWithTile`, `interactWithPlacedObject` and `breakPlacedObject` |
| `World.REACH` is `World.CHARACTER_REACH` | A name cold readers had doubted |
| After the cold readers and the reviewers | Two names, three comments, six checks |
| Notes | These |

A player sees no difference: the game plays as it did.

## How it was checked
- **`lune run tools/check`** after every commit: 2,129 test checks at the end, up from 2,054.
- **The delete test:** deleting `items` or `inventory` leaves `plots` type-checking, and deleting `plots` leaves both of them.
- **The interface:** a stove given a `place` that takes a string, and then no `place` at all, was refused by the type checker both times, at the line of `PlacedObjectKinds` that lists it. The file was put back.
- **Mutation testing** of each changed piece. The numbers are in `docs/status/now.md`.
- **Seven cold readers,** each shown one class as bare names: `Plot`, `World`, `Crate`, `Stove`, `PlacedObjectKinds`, `PlotRequests` and `PlayerState`. They were told to be strict, and marked 76 of 84 members as a guess. Nearly all of those doubts were for a type, a unit, an argument or what comes back, which bare names never show. Four were about what a name acts on. Two of those names were changed: a kind's `KIND_ID` ("kind of what?") is `PLACED_OBJECT_KIND_ID`, and its `ITEM_ID` ("which item?") is `ITEM_ID_WHEN_BROKEN`. Two stand: `breakPlacedObject` on a kind ("this stove, or any placed object?"), because Luau keeps `break` for itself, and `World.throwStacksFromTile`, which one reader took to throw stacks held in the tile; by the rule in `docs/code/names.md` a name with `Stacks` in it is handed them.
- **Two reviewers,** one on the rules and one on the server's and client's scripts, found no bug. Three findings, all mended: comments that left out a player with no character; a kind's functions not saying that they are for an object its own `place` placed; and no check that the world forgets a closed screen.
- **The server's and client's scripts were type-checked** with Roblox's definitions: the same seven reports in two places as before, and none from this work.
- **The play test** passed 83 of 83 in Studio.

## What it showed
- A seeded random test in `Requests.test` had only ever opened the crate by chance. When the requests' names changed their order, the chance went. It now opens the crate on purpose now and then, which also makes the test stronger.
- Claude chained a commit after a check once, through a pipe, so the commit would have been made whatever the check said. It had passed. The rule stands: read a result before building on it.
