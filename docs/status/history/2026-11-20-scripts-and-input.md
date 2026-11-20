# Each thing gets a script, and the world's input moves to Roblox's own (2026-11-20)

What was done after the user's tenth review. It is over; `docs/status/now.md` says where things stand.

## What they had said
- **"right so why do PlaceableItems still exist."** Items are items. Having one selected is an event that code is attached to, and interacting while it is selected is another. "Just keep it generic."
- **Then, while Claude worked on that:** "The way youre breaking up this problem is subpar and needs work. ... Systems shouldnt know about eachother. Dont pull out abstractions. ... You compose simple things and systems together and use glue code." The test: could each piece be a decoupled FoxFabric addon. The picture: Unix programs joined by a pipe, and never `catgrep`.
- **To rebuilding the world's input so that `UseAndHit` goes:** "Yes that sounds good."

Their words in full are in `docs/working/code-reviews/2026-11-20-9-simple-things-and-glue.md`.

## What was built
On the branch `placed-objects`. Five commits of code, each with every check passing, and one of notes.

| Commit | What it did |
|---|---|
| That an item burns is the furnace's fact | `burnSeconds` leaves the item's definition. `FuelRegistry` holds which items burn, in `stations` |
| Each thing answers through a script of its own | `ItemScripts` and `PlacedObjectScripts`, filled by `register`. `CrateItem` and `StoveItem`. `PlaceableItems` deleted. The game's things move to `src/shared/content`, with `Content.register` as the one list. The request tests use made-up things |
| The world's input goes through Roblox's Input Action System | `Interact` and `Break` are input actions declared in `default.project.json`. `tools/studio.py sync` makes them. `BreakClick`. `UseAndHit` deleted |
| The written rows move to content, and ground items to a folder of their own | The folders of `src/shared` are systems, glue, or things |
| After the cold readers and the reviewers | Reach is the script's to ask. A request checks only what was sent. The pointer's place comes from `UserInputService` again. Tests and play test steps that could not fail |

A player sees no difference, but for one thing: a click on the world from beyond reach now sends a request, which the server's script ignores.

## How it was checked
- **`lune run tools/check`** after every commit: 2,244 test checks in 33 files at the end, up from 2,129.
- **Mutation testing** of the eight pieces written or changed: 146 of 146 planted bugs caught. `PlotRequests` 39, `Crate` 28, `Stove` 30, `ItemScripts` 14, `PlacedObjectScripts` 10, `Content` 9, `CrateItem` 8, `StoveItem` 8.
- **The delete test:** deleting `content` breaks none of the rules. Deleting `plots`, `stations`, `groundItems` or `players` breaks only `world`, `requests` and `content`, which are built on them.
- **The interface:** a stove whose `interact` took a string was refused by the type checker at the line of `Content` that registers it.
- **An experiment in Studio** before the input was written, for what Roblox's documentation leaves out (`docs/roblox/input.md`).
- **The server's and client's scripts were type-checked** with Roblox's definitions: the same seven reports in two places as before.
- **The play test** passed 93 of 93 in Studio, on the last code commit. Ten of its checks are new.

## What the readers and reviewers found
Six cold readers and three reviewers, all helpers on Sonnet, read the first four commits.

- **The readers,** told to be strict, marked all 18 members a guess. Six doubts were about what a name is or acts on. Two names were changed: `BreakClick.WITHIN_SECONDS` and `SAME_DIRECTION` ("of what?") are `RELEASED_WITHIN_SECONDS` and `CAMERA_TURNED_BELOW`. Four stand, and the user may want them changed:
  - `Content.register`: "register what? ... The class name tells me nothing". It is named for its folder.
  - `PlacedObjectScript`: "one per placed object or per kind?" Per kind. `register` takes the kind's id.
  - `CrateItem`: "an item held in inventory, or an object placed in the world?" An item, as everywhere in this code. The object is `Crate`.
  - `interactWithTile` and `breakPlacedObject`: "who interacts?", "does it break the object or respond?" The player; and it does. Both are the game's verbs in `docs/code/names.md`.
- **The reviewer of the rules** found no bug and 8 other things. Mended, 6: failure checks that passed on any error; a note's case that nothing tested; that note being half untrue, since `Crate.interact` opened the pack for a crate with no inventory; two headers that pointed at their caller; `register` missing from the table of verbs; three notes that still named deleted classes. Left, 2: the word `script`, which in Roblox is an Instance; and the two item scripts being alike, which is on purpose.
- **The reviewer of the Roblox side** found 8. Mended, 7: three play test steps that passed with the feature broken; the pointer's place read from an input action that held -1, -1 in states measured and unmeasured; the sync tool taking a service for an instance to make; a dead character still shown as reaching; the same stale notes. Left, 1: a request is now sent for every click on the world, which is by design.
- **The reviewer who applied the user's own test** found 12. Mended, 1: reach had two owners, the request for a placed object and the script for a tile. Corrected in the notes, 1: the claim that adding a thing changes no request. Left, 10, all listed in `docs/status/now.md`. The largest: `World` still keeps a store for each sort of thing a placed object can be given.

In all: 28 findings, 14 mended, 1 corrected in the notes, 13 left.

## What it showed
- **Claude kept `PlaceableItems` through a whole split and called it glue.** It read "nothing built ahead of need" as a reason not to give items a script. A generic hook is not building ahead. A shared helper is.
- **A helper told to apply the user's last review, and to assume the author thinks it is mended, found more than the other two together.** It is worth doing before showing them code.
- **The type checker refuses a call through a narrowed optional function** when the table it came from was returned by an `if` expression that narrowed something else. Written as an `if` statement with a `return`, the same code passes (`docs/roblox/facts.md`).
- **A seeded random test reached its target by luck again,** this time a made-up bell in `Requests.test`. It now asks on purpose now and then, as the crate's test already did.
- **A state that was not measured decided a design.** The pointer's place went back to `UserInputService` because nobody had tried the input action in first person.
- **`cd` inside a command left the shell in a scratch folder** that then could not be deleted. Every command starts from the repository's root.
