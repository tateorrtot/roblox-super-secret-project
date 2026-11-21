# The fourteenth review: "who said colour? Are you coupling visuals to logic?" (2026-11-20)

The user read Claude's report on the item tables and the stove. Their words, and what Claude took from them.

## Systems, and content that glues them
Of `Stove` holding all of the stove in 305 lines:
> right so later once it gets to a point, we can do things like pull the idea of fuel or fire or cooking or gauges or recipes or slots [slots are already pulled out]! right?

> for example minecraft has a recipe index of sorts right

> im not saying we need to do this right away its just - good. Youve pulled the spaghetii out!

> We still have spaghetii in that code but if were not going to reach a point in the game we dont need to overengineer. Does that make sense.

> Id much prefer a strong robust collection of systems that have content that glues them all together in a messy frenzy. As long as its contained to each contents script - it doesnt matter! The code spaghetii is contained

- **This is the shape they want, said whole.** Strong systems. Content that glues them together as messily as it needs to, one thing to a script. A system is pulled out of a thing's script when a second thing needs it, and not before.
- **Mess inside one thing's script is not a fault.** Do not tidy it into systems ahead of need, and do not apologise for it.

## One noun for one thing
Of "The stove is this game's furnace":
> Okay got it. Just a reminder to be careful I dont want to see nouns gets mixed up or invented. I couldve started calling it a furnance and bam a furnace and a stove mean the same thing two words for the same script.

- **The thing is a stove, everywhere.** "Furnace" is Minecraft's word for its own thing, and is used only when speaking of Minecraft's. Claude found it twice in the play test's own messages, and changed them.

## Browsing the code
> For the game, Im wondering. Could we get a read the docs or is that a lot of work. I find it really nice to have this ability to browse through the documentation rather than go into every script. Doesnt have to be read the docs just my top choice since I know godot uses it and my old foxfabric repo uses it.

- **Built, to be browsed on their own machine:** `python tools/reference.py` writes a page for each module from the comments in the code, and MkDocs serves them in the Read the Docs theme (`docs/code/checks.md`). Putting it on readthedocs.org needs the repository somewhere that site can read, which is theirs to do.
- **They read documentation before they read scripts.** The comments are the documentation, so a comment that is wrong or thin is now a page that is wrong or thin.

## Plots are 3D
Of "There isn't one. The plot is one flat layer":
> Right... so i said the plots are 3D did i not...?

- **They had: "Also who said tiles werent 3D?"**, in the eleventh review. Claude filed it as a question for them, and they had meant it as the answer.
- **When they ask who said a thing was so, they are saying it is not so.** Take it as a decision, and say back what was understood.
- Decided, and not built (`docs/game/decisions.md`, `docs/status/next.md`).

## How a thing looks is a black box
Of a placed kind's name and colour being a row in `PlacedObjectLooks`:
> How come? Is this good practice?

> Shouldnt it be in the Crate and Stove itself?

> Also who said colour? Are you coupling visuals to logic? This could be replaced with somethign wild and unknown later. In godot terms, it could be replaced with a model scene with who knows what in it, animation players, imported meshes, text hovering above etc. Its an unknown black box and it sounds like you just make a contract that placedobjects are a cube with a colour.

- **It was not good practice, and Claude had listed it as left.** A thing they ask about is mended, not listed.
- **Claude said colour,** as a stand-in for art. It was a contract in two places: a row for every kind in the rules' own folder, and a general drawing piece that made a cube of that colour for whatever stood on the plot.
- **How a thing looks is the thing's own, and nobody else knows what is in it.** In Roblox the black box is a `Model`, which is what a scene is in Godot.

## What they want explained
Of "Shall I make where a placed object stands one value, as the first step to free placement?":
> Explain. I think I want this but I want to verify

- Claude had asked it without an example. Explained with the code before and after; it waits on their word (`docs/status/asked-of-the-user.md`).

## The reference's own words
Sent while Claude worked, of the section titles Claude had given the reference:
> "The game's things" "On the server" "On the player's machine" These feel like overly verbose ways to state a single thing. Youre... again making up a lot of words to say other simple already defined things no?

> Look at how godot sets up its website and documentation.

And then two pages of Godot's own: its rules for contributions, and its guide to writing documentation.

- **The sections are `shared`, `server` and `client`,** the folders' own names, and a page is laid out as a page of Godot's class reference is.
- **Godot's writing guidelines are the project's** (`docs/code/conventions.md`, "Comments"). The comments written before do not all follow them, and a pass is owed.
- **Claude's plain-words habit had become a habit of paraphrase.** "The player's machine" is in 131 places. The word is client.
- **From Godot's rules for contributions:** one change to a commit, and a change explained by what it is, why, how it was tested and what it risks. The project already works so.

## What changed in the code
- `PlacedObjectLooks` is gone. `PlotParts` is handed a piece for each kind, which makes that kind's `Model`: `CrateModel`, and `StoveModel`, which also shows the stove's fire. Each is a `PlaceholderBlock` until there is art.
- A kind's name is in the kind's own file, and its item takes its name from there. `PlacedObjectKinds` lists every kind, as `Items` lists every item.
- On the player's machine a placed object is found by its Model, whatever the Model holds.
- `tools/reference.py`, and the pages it writes.
