# The thirteenth review: "Systems being decoupled - fantastic. Pieces of content being scattered - not great." (2026-11-20)

The user read Claude's answers to the twelfth review. Their words, and what Claude took from them.

## A piece of content is in one place
Of one table for each item, in place of a row, a look and a script in three files:
> Okay yes your unified way of keeping the CrateItem spaghettii as one big file rather than 3 files, I think I like that?

> Its more coupled - but that doesnt really matter here. It being more intuitive and unified feels better.

> Systems being decoupled - fantastic.

> Pieces of content being scattered - not great.

> Yes do that.

- **Two rules, for two sorts of code.** A system knows no other system. A piece of content, such as the crate item or the stove, is written in one place, and that place may be coupled to whatever the thing needs.
- **Decoupling is not the aim everywhere.** Claude had applied it to the content too, and split one thing over files.

## A station is not a thing
Of the diagram that read "Station: fire, 3 slots, work":
> Yeah that... doesnt make sense we havent even defined what a station is. A station is more so something that happens to fall out rather than a defined list. A crafting table might be a station. That doesnt have 3 slots, fire, or work.

> The stove is more so code spaghetii that youve now contracted all "stations" to have its spaghetii.

Of the stove being composed of its fire and its slots, with `World` no longer keeping or advancing stations:
> Yes! I like this. A stove (do you mean furnace?) ISNT every station. A stove is just other things composed together. Yes it is an item that can be placed. Yes it is a placedobject. Yes you can interact with that placed object and it has things like slots, fire, work, etc.

- **A general name on one thing's code makes a contract for every later thing of that name.** A crafting table would have been handed three slots, a fire and a recipe.
- **The stove's workings are the stove's.** Its recipes, its fuels, its fire and its cooking are in `Stove`, with its slots, and nothing else in the rules knows them.

## Which way to place
Of Factorio's and Terraria's field on an item that says what it places, against Minecraft's function that every item has:
> Whats the best method to do here.

> I pushed on it since theres lots of non-generic cases.

- Claude's answer: the function. With a field, the general code knows one thing that an item can do, and every item that does something else needs a second way in. With a function, the general code knows nothing, placing is a few lines in the item that places, and a wand costs the same. When many items place in the same plain way, they call one shared function.

## Whether the systems can be lifted out
> Are we ending up with more so reusable generic systems that I could pull out and use for any roblox game? Or extract the logic if i say wanted to make a godot game? This is about testing the codebase and each module.

- **It is a test, so Claude ran it.** `python tools/lift_out_test.py` copies each system, with only what it requires, into an empty folder and runs its tests there. All five pass alone (`docs/code/checks.md`).

## Tiles and free placement
> I dont see tileY

> Yeah so this is my greatest worry.

> I think the freeform placement is generally better with optional grid snapping.

> However, NPCs and doing things like complex automation or checking neighbouring cells sounds expensive and confusing. What are your thoughts.

- **There is no `tileY`:** the plot is one flat layer. This is the third time they have pointed at the flat grid.
- **They lean to free placement, with snapping as an option.** Their worry is what it does to helpers and to machines that work on their neighbours. Claude's thoughts are in `docs/status/next.md`. Not decided, and not built.

## What they thought was done
Of "Which comes next: the stove without the word station, or one table for each item?":
> Uh both?

> I thought you already did this?

- **Claude had described two changes under "What I'd change" and "What I'd do", in the same message as work that was done,** and then asked which should come first. They read both as done, and had in effect approved both.
- **Say of each thing whether it is built or only proposed, in those words.** And when they have said yes to a direction, build it: do not ask which half comes first.

## What changed in the code
- An item is one table: `Items.ALL` lists every one, and `CrateItem` and `StoveItem` hold their own id, stack size, name and colour beside what they do.
- `Stove` holds everything of the stove. The folder `stations`, the type `Station`, the two registries and the two files of rows are gone.
- `World` keeps no stations and advances none. It fires `timePassed`, and the script of each placed object is told.
- What a player's machine is told of the placed object they have open is asked of the kind's script. What a kind shows on its block, and how its screen is laid out, are pieces of the kind's own: `StoveGlow` on the server and `StoveScreen` on the player's machine.
- Seven helpers reviewed it. Of 27 findings, 12 were mended, 11 were left, and 4 Claude did not agree with. The account is in `docs/status/history/2026-11-20-item-tables-and-the-stove.md`.
