# The twelfth review: "Does CrateItem not like, extend Item?" (2026-11-20)

The user read Claude's answers to the eleventh review, and asked about four things. Their words, and what Claude took from them.

## An item is in several places
> Okay so does this split make sense? We might end up with more boilterplate having "CrateItem" and "XItem" for every item right? Is that okay?

> How do most games do it.

> Does CrateItem not like, extend Item? I dont see it anywhere.

> How would I change its ID, stack size, icon? Properties of the Item class?

> Is it more like two classes built together to compose an object or something? Wheres the code that glues them together? Is it in the content? Im confused. Sorry im new to roblox.

> Im used to something like a "crate_item" script, that extends item.

- **They looked in `CrateItem` for the crate item's facts, and they are not there.** Its stack size is a row in `ItemDefinitions`, its name and colour a row in `ItemLooks`, and its script is `CrateItem`. The three are joined by the string `"crate"`, which is written again in `Crate.ITEM_ID_WHEN_BROKEN`. `Content.register` is the glue.
- **There is no `Item` class, and nothing extends anything.** Luau has no `class` and no `extends`. That is true and it is not the answer they needed: what they expect is one place that holds everything about one item.
- **A script is written only for an item that does something.** Of ten items, two have one.
- **Claude proposed one table for each item:** its id, its stack size, its name and colour, and its functions if it has any. Not built: it waits on their word (`docs/status/asked-of-the-user.md`).
- **A thing that is spread over several files and joined by a string is hard to find,** however decoupled the files are. Say where each fact of a thing lives before they have to ask.

## The noun "station"
> "stations..."

> What is stations?

> I thought we just had PlacedObjects. They could happen to *be* stations in the way theyre composed but the noun station would be more like a vague idea than actually in the codebase? No? Enligthen me.

> But... what is a station...? What? Is it defined in the codebase? If it is, where? Why? Isnt a station just something that may happen to fall out as a more concept than literal named thing in the codebase?

- **The word was theirs, for an idea:** "a station is kinda like a black box" (`docs/game/placed-objects.md`). Claude made it a folder, a type, two registries keyed by "kind of station", a store in `World` and a field in what a player's machine is told.
- **What the code holds is a furnace:** a fire, three slots and a recipe worked over time. Nothing in it is more general than that, and one kind of placed object uses it.
- **A word for a category is not put in the code before there are things in the category.** A thing is named for what it is. They had said to leave `Station` until a second process showed what the kinds share; they did not say to keep the name.

## Ground items and inventories
> Does GroundItems being glued to inventory make sense. Should/can we pull it out.

- It did not make sense, and it is pulled out: `groundItems` no longer requires `inventory`. `World` joins them.

## Tiles
> Also with tiles and plots, how would a freeform grid like paralives work? Or would we just do "fractional" grids. Im curious. In paralives and the sims [when holding alt] you can freeform place an object. I think ark has a similar system i may be wrong. Id say the rigid tile, rigid walls, rigid ceilngs, etc in bloxburg is its greatest flaw.

- **They had already said it,** of walls and floors: "using the grid as a pure guideline rather than a set boundary" (`docs/game/decisions.md`). The tile grid in the code is Claude's first build of a model they have not accepted.
- Not built. What free placement would mean for the code is in `docs/status/next.md`.

## What they approved
Of "Shall I build the World change as shown: a crate carries its inventory, a stove its station?":
> Yes I think a crate basically being composed to have an inventory is fantastic.

- Built for the crate. The stove waits, because of what they asked about the word.

## What changed in the code
- `Plot.placeObject` takes the placed object itself. A kind builds it, with what it has on it, and the plot keeps that table and reads only its tile.
- `Crate.place` needs only the plot. A crate is a placed object with an inventory on it, and `World` lost its store of inventories.
- `GroundItems` says which ground items are in pickup reach of a position, and lets items be taken out of one. `World` puts them in the pack.
- Two helpers reviewed it. Of 16 findings, 7 were mended, 8 were left, and 1 Claude did not agree with. The account is in `docs/status/history/2026-11-20-crate-and-pick-up.md`.
