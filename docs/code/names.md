# Names

How things in the code are named. The user reads an outline of bare names, with no arguments and no comments, and expects to know what each function does (`docs/working/code-reviews/2026-11-20-3-the-names.md`). The rest of the conventions are in `conventions.md`.

## The rules
**A file is one thing, named for it with a noun.** `Inventory`, `ItemStack`. No project prefix.

**A function's name says what it acts on, and where.** Read alone, with no arguments and no comment, `Module.name` tells a stranger what the function does.
- A bare verb means the whole of the thing the file is named for. `Station.advance` advances the station. `Inventory.encode` encodes the inventory.
- Anything else names its object, and the place when there is one. `Hotbar.selectSlot`, `Plot.placeItem`, `World.dropStackAt`, `InventoryScreen.pickUpFromSlot`, `InventoryScreen.swapCarriedStackWithSlot`.
- A noun in a name is a part of the thing, or something the caller passes or gets back. A name with `Stack` in it takes or returns a stack. One with `Slot` takes a slot.
- Arguments come in the order the name gives them: the thing first, then where, then how much.
- No name stops at an adjective. `placedItem`, not `placed`. `carriedStack`, not `carried`.
- The game's own verbs follow the same rule. `pickUp`, `putDown`, `drop`, `throw`, `swap`, `use` and `hit` are welcome, and each still names what it acts on: `pickUpFromSlot`, `dropFromSlot`, `throwStack`, `swapSlots`, `usePlacedItem`. No verb is excused for being familiar.

**Every function starts with a verb.** The exception is a yes-or-no question, which is named as the statement that would be true: `isFull`, `hasSlot`, `canReachTile`, `slotAcceptsItem`. A function that only reads starts with `get`, `count` or `find`.

**A name is a promise, and the function keeps it.** `drop` leaves the stack on the ground. A function that only takes the stack out is `take`. If what a function does cannot be said plainly in a sentence built from its name, it is the wrong shape: split it or rename it.

## One name for each idea
| Name | Means |
|---|---|
| `slot` | A slot number, from 1 |
| `side` | Which of an open screen's two inventories: `"pack"` or `"other"` |
| `itemId`, `count`, `stack`, `inventory`, `screen` | What they say |
| `carriedStack` | The stack a player is moving between slots |
| `player` | A `PlayerState`, in the rules |
| `placedItem`, `placedItemId` | A thing standing on a plot, and its id |
| `position` | A point in the world, `{ x, y, z }` in studs. A character's is at its feet; a ground item's is the middle of its underside |
| `facing`, `direction` | A way along the ground, `{ x, z }` with a length of 1 |
| `throw` | How a stack sets off into the world: where from, and how fast. A player drops; what happens to the stack is a throw |
| `velocity` | How fast along each axis, `{ x, y, z }` in studs a second |
| `now` | The present time, in seconds |
| `selected` | The hotbar's selected slot. A comment may say that what it holds is in the player's hand. No function is named for a hand |
| `...Seconds`, `..._SECONDS` | A length of time: `burnSecondsLeft`, `LIFETIME_SECONDS` |
| `...Ratio` | A number from 0 to 1 |
| `...Count`, `..._COUNT` | How many: `slotCount`, `PACK_SLOT_COUNT`. A plural, such as `slots`, is the things themselves |

## One meaning for each verb
| Verb | Means | Returns |
|---|---|---|
| `new`, `open` | Makes one | It |
| `get` | Reads what is there | It, or `nil` when nothing is there |
| `set` | Replaces; `nil` removes | Nothing |
| `add` | Puts in wherever it fits | Given a count, how many went in; given a stack, the stack that did not fit |
| `put` | Puts into a named place | The stack that did not fit |
| `take` | Takes out of a named place for the caller | The stack taken |
| `remove` | Takes out wherever it is | How many were removed |
| `move` | Takes a thing from where it is to somewhere else: stacks into an inventory, a ground item to a position | How many items moved, when it moves items |
| `count` | Counts | A number |
| `has`, `is`, `can` | Asks, and changes nothing | `true` or `false` |
| `find` | Looks for one that may not be there | It, or `nil` |
| `advance` | Moves a thing on in time: `advance` by so many seconds, `advanceTo` a time | Nothing |
| `update` | Makes a drawing piece match what it is given | Nothing |
| `clear` | Empties | Nothing |
| `encode`, `decode` | Turns a thing into plain data, and back | The plain data; the thing, or `nil` and what was wrong |
| `validate` | Checks a value that came from outside | `nil`, or what is wrong with it, in words |

A number returned is how many items moved. A stack returned is one the caller now holds: what was taken out, or what is left of the stack that was put in.

## The names test
A reader is given nothing but each file's first line and the bare names of its public functions (`python tools/outline.py --sheet`), and writes what each function takes and does.
- The reader is a fresh agent of the `Explore` type, on Sonnet, told to use no tools. That type is not shown `CLAUDE.md`; most others are, and the notes describe the code.
- A question the reader is left with about what a function acts on, or where, is a failed name. Fix it by renaming or reshaping, not by adding a sentence.
- A question about how much moves, or what comes back, is the signature's to answer.
