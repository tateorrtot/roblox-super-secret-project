# Comments

How a comment in `src` is written. Read this file before writing or changing one. `conventions.md` has the same rules in short.

The comments are the class reference. `python tools/reference.py` makes a page for each module from them, and the user reads those pages before they read a script. The user, 2026-11-21: "The documentation must be *good*. Its a tool to help you and me."

The rules come from three places:
- Godot's writing guidelines, which the user sent on 2026-11-20 (https://contributing.godotengine.org/en/latest/development/documentation/docs_writing_guidelines.html);
- the user's reviews of the code (`docs/working/code-reviews/`);
- the defined words in `names.md`.

`src/shared/plots/Plot.luau` is the model: it was written by hand to these rules, and every example below is from the code.

## What gets a comment
- **The file.** Its first paragraph is the page's brief description: what the thing is and does, in 200 characters or fewer. After a bare `---`, one paragraph says how the main members work together.
- **Each public function, each exported type, each field of an exported type, and each constant.**
- **Nothing else.** A private helper gets a name that says what it does. A function's body has no comment. A script that runs by itself, `Main.server` or `Main.client`, may keep a plain `--` comment over a block where the engine sets a trap.

## What a comment says
- **Everything a caller needs:** what changes, what the function returns, and what happens in each case a caller can meet.
- **Only what is true of the code.** Read the function before writing its comment. If the comment and the code disagree, the comment changes.
- **What is, never what was.** No history, no date, and no reason from a review.
- **Nothing outside the file.** A comment never points at another game, a device, another comment, or whoever calls the function. It names the module's own members, and the members of other modules that the function calls.
- **A guard** is one sentence: `Fails if ...`. Say what stays unchanged.
- **A trap** is a line that starts with `Note:`. A check that a function leaves out is a trap.
- **No more than that.** One to three sentences is usual. If a shorter comment loses no fact, the shorter comment is better.

## How each kind starts
| Kind | Starts with | Example |
|---|---|---|
| File | A noun phrase: what the thing is and does | A grid of square tiles that holds placed objects, at most one to a tile. |
| Type | A noun phrase | An object on one of a plot's tiles. |
| Field or constant | A noun phrase, with its unit | The plot's width, in tiles along x. |
| Boolean field | `If true, ...` | If `true`, a Shift key was down when the button came up. |
| Signal | `Fires after ...`, then `Passes ...` | Fires after `placeObject` adds a placed object. Passes the placed object's id and the placed object. |
| Function | A verb in the third person | Removes the placed object with the id `id` from the plot and returns it. |
| Function that only answers | `Returns ...` | Returns `true` if a placed object stands on the tile `tileX`, `tileZ`. |

A function that returns a value says so with the word `Returns` or `returns`.

## How it is written
Godot's rules. Each pair is a comment of `Plot` before and after the pass of 2026-11-21.

| Rule | Before | After |
|---|---|---|
| The active voice. The subject is the thing described, or whatever acts | Fired when an object has been placed | Fires after `placeObject` adds a placed object |
| A precise verb. A comment never only says the function's name again | Places `placedObject` on the tile it names | Adds `placedObject` to the plot, on the tile `placedObject.tileX`, `placedObject.tileZ` |
| No verb in `-ing` for a change that happens at once | Returns `nil`, changing nothing and firing nothing | Returns `nil`, changes nothing, and fires nothing |
| No word that adds nothing | may be any values at all, and nothing fails | Accepts a value of any type for each, and never fails |
| The thing named again where `it` could be doubted | with the id it had | Passes the id that the placed object had |
| `'s` for what belongs to a thing | How many tiles it has along x | The plot's width, in tiles along x |
| A comma before the `and` or `or` that ends a list of three or more | changing nothing and firing nothing | changes nothing, and fires nothing |
| A value that a caller passes or gets is a literal: digits, in backticks | counted from 1 | counted from `1` |
| The defined word | the player's machine | the client |

- **Never:** `obvious`, `simple`, `basic`, `easy`, `actual`, `just`, `clear`, `however`, their forms in `-ly`, `the former`, and `the latter`.
- **`It` is fine** when it can only mean the subject of its own sentence, or the thing the comment stands over.
- **Other numbers** are words up to ten and digits above.

## The words
- **The two tables in `names.md` are the vocabulary:** one name for each idea, and one meaning for each verb. A comment uses those words and no others for those things: client, server, content, stove, Model, placed object, kind, ground item, pack, hotbar, slot, stack, screen, plot, tile, script.
- **A signal fires and passes. A callback connects.** Those are Roblox's words.
- **Backticks go around every argument, member, type, and literal value.** A member of this module is written by its bare name, `placeObject`. A member of another module is written in full, `Plot.placeObject`, and the reference makes it a link.

## Layout
- `---` and a space, directly over the thing, wrapped at 100 columns with a tab counted as 4.
- A bare `---` starts a new paragraph. A list item starts with `- `.

## How comments are checked
- **`python tools/comments.py`** fails for a missing comment, a brief description over 200 characters, a function that returns a value and never says `Returns`, and each banned word or phrase. `lune run tools/check` runs it. With `--report` it counts the sentences that look passive, for a reader to judge.
- **A script cannot tell whether a comment is true, complete, or well put.** A reader does that, against the function, and then on the page that `python tools/reference.py` makes.
