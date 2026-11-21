# The comment pass (2026-11-21)

The user, of the class reference: "The documentation must be *good*. Its a tool to help you and me." Claude had measured it the same day and found it complete and not well written. This is how every comment in `src` was brought to the rules, and what was found on the way.

## What was done
1. **A guide, a check, and a model.** `docs/code/comments.md` says how a comment is written, with before-and-after pairs from the code. `tools/comments.py` fails for what a script can match. Claude rewrote `Plot`'s comments by hand as the model.
2. **Six helpers on Sonnet rewrote the other 52 modules,** a group of modules each, three helpers at a time. Each read every function before writing its comment.
3. **Six more helpers checked each group,** told to assume that the first had made mistakes: every statement against the code, every fact of the old comment, every rule, and whether a sentence had to be read twice.
4. **Claude read every module's comments afterwards,** and checked five functions against their code.
5. **A script proved that no code changed.** `build/z1_comments_only.py` takes the comment lines out of each file and compares what is left with the commit before: 52 files differ, and in none does the code differ.

## The counts
| | |
|---|---|
| Comments rewritten by the helpers | 382, and 39 added where there was none |
| Statements in the old comments that the code did not bear out | 87, corrected by the writers |
| Things the checkers found in the new comments | 64, all fixed: 20 untrue, 12 facts lost, 14 rules broken, 17 hard to read, 1 other |
| Things the checkers could not settle | 14: 1 mended by Claude, with a `Note:` on four functions, and 13 left (below) |
| Comments Claude changed after its own read | 14 |
| Sentences that look passive, by `python tools/comments.py --report` | 108 of about 1,330. Before: 250 of about 1,247 |

Most of the 108 are states and not actions: "is frozen", "is registered", "is selected".

## What the reading found in the code
None of it is mended: the pass changed no code. Each is in `../now.md`.
- `InventoryScreen.moveFromSlotToInventory` takes the stack out of its slot before it checks `toSlots`, so a `toSlots` that lists a slot the inventory lacks loses the stack. The request checks the slots first, so no client can cause it.
- `Inventory.takeFromSlot` and the three functions built on it do not check that `count` is a whole number of 0 or more, though `docs/code/conventions.md` says `Inventory` refuses such a count.
- `ScreenScale.applyTo` keeps every `UIScale` it has made, also after its GuiObject is destroyed.

## What was left
- **Thirteen things the checkers could not settle.** Claude first reported ten, and "mostly facts about Roblox": both were wrong, and the user asked what they were.
  - Three are facts about Roblox that a comment states and the code cannot show: that Roblox's input actions have no tap, that a modal button frees the pointer in first person, and that a finger on a touch screen counts as the left button.
  - Four are statements that depend on another module, which the checker of that group did not open: what `Inventory.addItems` does for the five files that call it, that `CrateItem.interactWithTile` runs on the server, what "equal shares" means in `InventoryControls`, and whether `PlaceholderWorld`'s starting items always fit.
  - One is a guard that holds only sometimes: `InventoryScreen.spreadCarriedStackOverSlots` fails for a slot the screen lacks only if it reaches that slot.
  - One cannot be shown from its own file: "Nothing else in the game knows what a crate looks like", in `CrateModel` and `StoveModel`.
  - Three are wordings: a heavy sentence in `World.setCharacterPosition`, whether a count of items is a literal, and the `---` comments over local values (below).
  - One is not about a comment: `Direction` assigns its own `read` fields.
- **`---` comments over local values in `Main.client` and `StoveScreen`.** The guide says a private helper gets none. They hold facts, the check accepts them, and Claude left them.
- **No page has an example,** and the tests' own comments were not part of the pass.
- **The records keep their old words:** the reviews, the history, and the research still say "the player's machine". The living notes do not.

## What it cost
Twelve helpers on Sonnet, about 1.6 million tokens between them, ten minutes by the clock.
