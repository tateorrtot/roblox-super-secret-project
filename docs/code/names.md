# Names

How things in the code are named. The user reads an outline of bare names, with no arguments and no comments, and expects to know what each function does (`docs/working/code-reviews/2026-11-20-3-the-names.md`). The rest of the conventions are in `conventions.md`.

## The rules
**A file is one thing, named for it with a noun.** `Inventory`, `ItemStack`. No project prefix.

**A function's name says what it acts on, and where.** Read alone, with no arguments and no comment, `Module.name` tells a stranger what the function does.
- A bare verb means the whole of the thing the file is named for. `Station.advance` advances the station. `Inventory.encode` encodes the inventory.
- Anything else names its object, and the place when there is one. `Hotbar.selectSlot`, `Plot.placeItem`, `World.throwStackFromCharacter`, `InventoryScreen.pickUpFromSlot`, `InventoryScreen.swapCarriedStackWithSlot`.
- A noun in a name is a part of the thing, or something the caller passes or gets back. A name with `Stack` in it takes or returns a stack. One with `Slot` takes a slot.
- Arguments come in the order the name gives them: the thing first, then where, then how much.
- No name stops at an adjective. `placedItem`, not `placed`. `carriedStack`, not `carried`.
- The game's own verbs follow the same rule. `pickUp`, `putDown`, `drop`, `throw`, `spawn`, `swap`, `use` and `hit` are welcome, and each still names what it acts on: `pickUpFromSlot`, `dropFromSlot`, `throwStackFromCharacter`, `spawnStack`, `swapSlots`, `usePlacedItem`. No verb is excused for being familiar.
- **`use` and `hit` are Claude's words for the game's two actions. The user says `interact` and `break`.** The names change to theirs when that code is next rewritten.

**Every function starts with a verb.** The exception is a yes-or-no question, which is named as the statement that would be true: `isFull`, `hasSlot`, `canReachTile`, `slotAcceptsItem`. A function that only reads starts with `get`, `count` or `find`.

**A name is a promise, and the function keeps it.** `drop` leaves the stack on the ground. A function that only takes the stack out is `take`. If what a function does cannot be said plainly in a sentence built from its name, it is the wrong shape: split it or rename it.
- **A setter names the thing it sets:** `set` and the property. The user, of `setCharacter`: "setCharacter what?" It is `setCharacterPosition`.
- **`And` in a name is a flag.** A function named for two things is doing the work of two functions: split it. The user, of `setCharacterPositionAndFacing`: "Its weird to have "And" in a function that signals to me hey this method is doing the role of two methods." Two names still have it. The function `throwPlacedItemAndContents` goes when a placed item says for itself what breaking it leaves (`conventions.md`, "What an item does"). The class `UseAndHit` wants a name the user can read; they turned down `PlotControls`.
- **A long name is a flag too, and not always wrong.** `pushGroundItemsOutOfTile` stands: the user called it "one of these times a mouthful may be okay".
- **A word names a real thing in the code, or it is not used.** The user, of a `Transform` that did not exist: "is transform a defined solid thing? like a class? if not dont do transform". An adjective counts too. Of `mergeDueItems`, which Claude offered the same day: "what are due items. did you just invent that. ... But a "DueItem". is that a class? What is that?" Every word in a name is a type, a field or a constant of the code, a word from the two tables below, or a plain word nobody could doubt, such as `nearest` or `empty`.
- **Roblox's word first, then Godot's, and never one of ours.** Where Roblox has a word for a thing, the code uses it and keeps to it: `connect` and `fire` for a signal, as `RBXScriptSignal:Connect` and `BindableEvent:Fire` have them. Where Roblox has none, Godot's. The user, 2026-11-20: "If youre following roblox conventions stick to it. If youre following invented conventions - go with godots". They confirmed it of `fire` the same day: "no lets keep things more styled to roblox / in tune to it". Whether calls are written `Module.verb(thing)` or as methods is a separate question, and waits for them.
- **A noun that can be read two ways is a failed name.** Claude offered `PlotControls` for the piece that hears clicks in the world, meaning the controls a player has. The user: "controling a plot? Im confused? Theres a class / object somewhere whose job it is to control a plot? isnt that the plots job?"
- **There is no exception.** The user allowed one on 2026-11-20, for two functions of `World` that also merged ground items, and it was lifted the same day when the merge moved to `World.advanceTo`.

## One name for each idea
| Name | Means |
|---|---|
| `slot` | A slot number, from 1 |
| `side` | Which of an open screen's two inventories: `"pack"` or `"other"`. `PlotCollision` alone uses it for a side of a tile, in names that say so: `findNearestFreeSideOfTile` |
| `itemId`, `count`, `stack`, `inventory`, `screen` | What they say |
| `carriedStack` | The stack a player is moving between slots |
| `player` | A `PlayerState`, in the rules |
| `placedItem`, `placedItemId` | A thing standing on a plot, and its id. The user turned the name down on 2026-11-20: "Who said it had anything to do with an item." It is to be `PlacedObject` or `Structure`, and never "block" |
| `position` | A point in the world, `{ x, y, z }` in studs. A character's is at its feet; a ground item's is the middle of its underside |
| `character` | A player's body in the world, as far as the rules know it: its `position`. `nil` while they have none |
| `direction` | A way in the world, `{ x, y, z }` with a length of 1. `y` is upwards, and one with a `y` of 0 lies along the ground |
| `velocity` | How fast along each axis, `{ x, y, z }` in studs a second |
| `...Time` | A moment on the world's clock, in seconds: `spawnTime` |
| `now` | The present time, in seconds |
| `selected` | The hotbar's selected slot. A comment may say that what it holds is in the player's hand. No function is named for a hand |
| `...Seconds`, `..._SECONDS` | A length of time: `burnSecondsLeft`, `LIFETIME_SECONDS` |
| `...Ratio` | A number from 0 to 1 |
| `...Count`, `..._COUNT` | How many: `slotCount`, `PACK_SLOT_COUNT`. A plural, such as `slots`, is the things themselves |

## One meaning for each verb
| Verb | Means | Returns |
|---|---|---|
| `new` | Makes one | It |
| `open`, `close` | Opens or closes a screen for a player | Nothing |
| `get` | Reads what is there | It, or `nil` when nothing is there |
| `set` | Replaces; `nil` removes | Nothing |
| `add` | Puts in wherever it fits | Given a count, how many went in; given a stack, the stack that did not fit |
| `put` | Puts into a named place | The stack that did not fit |
| `take` | Takes out of a named place for the caller | The stack taken |
| `remove` | Takes out wherever it is | Given a count, how many were removed. Given one thing, that thing if a caller has a use for it |
| `move` | Takes items from where they are to somewhere else | How many items moved |
| `spawn` | Makes a thing appear in the world at a position | Its id |
| `merge` | Makes things of one kind into one | Given two stacks, the stack that holds both, and then what did not fit. Given every ground item, nothing |
| `count` | Counts | A number |
| `has`, `is`, `can` | Asks, and changes nothing. `can` with an action's name asks whether that action could be carried out now: `canPlaceItem` before `placeItem` | `true` or `false` |
| `connect` | Connects a callback to a signal | Nothing |
| `fire` | Calls every callback connected to a signal, at once and in the order they were connected | Nothing |
| `find` | Looks for one that may not be there | It, or `nil` |
| `advance` | Moves a thing on in time: `advance` by so many seconds, `advanceTo` a time | Nothing |
| `update` | Makes a drawing piece match what it is given | Nothing |
| `clear` | Empties | Nothing |
| `encode`, `decode` | Turns a thing into plain data, and back | The plain data; the thing, or `nil` and what was wrong |
| `validate` | Checks a value that came from outside | `nil`, or what is wrong with it, in words |

A number returned is how many items moved. A stack returned is one the caller now holds: what was taken out, or what is left of the stack that was put in.

## The names test
The user, 2026-11-20: "I see just the class. ... I look in the class. ... these are my methods. ... If it doesnt work out of context. It doesnt work." Their words are in `docs/working/code-reviews/2026-11-20-4-out-of-context.md`.

- **A reader is shown one class and nothing else:** its name, the fields of its types, its constants and its functions. `python tools/bare_names.py World` prints exactly that.
- No first line of the file, no comments, no arguments, no other class, and no word of what the program is.
- The reader writes what the class is and what each member is or does, and marks each `clear`, `guess` or `no idea`.
- **A guess is a failure, even when it is right.** Claude's readers are far more forgiving than the user. On 2026-11-20 two of them read all 345 names, got none wrong and 28 right only by guessing, and the user could make nothing of a class among those.
- The reader is a fresh agent of the `Explore` type, on Sonnet, told to use no tools. That type is not shown `CLAUDE.md`.
- A doubt about what a member acts on, or where, is a failed name. A doubt about how much moves, or what comes back, is the signature's to answer.
- **A class is a noun,** as `PlayerState` is. When no noun works, the class is wrong, not the name: split it, or give its parts to the things they belong to.
