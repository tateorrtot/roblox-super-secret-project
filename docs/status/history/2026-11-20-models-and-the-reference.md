# A Model for each kind, and a class reference (2026-11-20)

What was done after the user's fourteenth review. It is over; `docs/status/now.md` says where things stand.

## What they had said
- **Of a table that gave each kind of placed object a name and a colour:** "who said colour? Are you coupling visuals to logic? ... Its an unknown black box and it sounds like you just make a contract that placedobjects are a cube with a colour." And: "Shouldnt it be in the Crate and Stove itself?"
- **Of browsing the code:** "Could we get a read the docs or is that a lot of work."
- **Of the reference's section titles,** while Claude worked: "Youre... again making up a lot of words to say other simple already defined things no? Look at how godot sets up its website and documentation."

Their words in full are in `docs/working/code-reviews/2026-11-20-13-contained-spaghetti.md`.

## What was built
- **`PlacedObjectLooks` is gone.** `PlotParts.update` is handed a piece for each kind of placed object. A piece has `make`, which returns the kind's `Model`, and may have `update`. `CrateModel` and `StoveModel` are the two, in `src/server/content`, and `StoveModel` took over the stove's glow. Each uses `PlaceholderBlock` until there is art.
- **On the client a placed object is found by its Model,** which has the attribute `placedObjectId`, whatever part of it the pointer hits.
- **A kind's name is `NAME` in its own file,** and its item takes its name from there. `PlacedObjectKinds` lists every kind and returns one by id, and `Content.register` goes through it.
- **`tools/reference.py`** writes a page for each of the 53 modules from the comments in the code, and MkDocs serves them in the theme of Read the Docs. A page is laid out as Godot's are: a brief description, the description, properties, methods, constants, and each method's description. The sections are `shared`, `server` and `client`. Four notes on the code are its contributing pages.
- **Godot's writing guidelines, and the defined words,** are in `docs/code/conventions.md` and `docs/code/names.md`.

## How it was checked
- `lune run tools/check` passes, with 2,285 test checks in 29 files.
- Mutation testing: `PlacedObjectKinds` 10 of 10, `Crate` 34 of 34, `Content` 5 of 5, `CrateItem` 10 of 10, `StoveItem` 10 of 10. `Stove` was last run before it was given a `NAME`: 187 of 193.
- The play test passed 93 of 93 in Studio.
- The server's and the client's scripts, type-checked by hand: six reports in one place, all older.
- The reference was built, and looked at in a browser.

## What the helpers found
One read the change for mistakes, knowing Roblox. One read it against the user's words. One read two classes cold.

- **19 findings.**
- **Mended, 5:**
  - A kind with no piece was not shown, and nothing said why. `Main.server` fails at the start for one.
  - A check that every kind leaves an item when it is broken had gone with the table. It is back.
  - Two comments on the client still spoke of a part where there is a Model now.
  - A comment's lines were left broken.
- **Left, 12** (each is in `docs/status/now.md` or `docs/status/next.md`):
  - An item's `color`, and the three general pieces that draw every item from it: 3 findings. It is asked of the user.
  - A crate's colour is written three times, and a ghost is a see-through block where it could be the kind's own Model: 3 findings.
  - A Model stands on one tile, and its piece is not told the tile, a size or a turn.
  - The middle of a Model's box is taken as the placed object's middle, which is so for a block and may not be for a model with an arm.
  - The lists in the two `Main` scripts.
  - The kinds' own tables can be changed by whoever holds them.
  - The word `piece` in three type names, and `Block`, `Model` and `Ghost` for sides of one look.
  - `PlacedObjectKinds` asks a `NAME` of every kind, which no rule reads.
- **Not agreed with, 2:**
  - That the pointer's target carries a Model nothing reads. `Main.client` puts the outline around it.
  - That `PlotParts` should not name and tag the Model a piece returns. The client finds a placed object by that tag.
