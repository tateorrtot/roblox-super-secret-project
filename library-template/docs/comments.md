# Comments

How a comment in `src` is written. Read this file before writing or changing one.

The comments are the class reference. `python tools/reference.py` makes a page for each module from them, and Tate reads those pages before reading a script: "The documentation must be *good*. Its a tool to help you and me."

The rules are Godot's writing guidelines (https://contributing.godotengine.org/en/latest/development/documentation/docs_writing_guidelines.html), the words in `names.md`, and what Tate's reviews added. The examples are of a countdown timer, as Godot's `Timer` is.

## What gets a comment
- **The file.** Its first paragraph is the page's brief description: what the thing is and does, in 200 characters or fewer. After a bare `---`, one paragraph says how the main members work together.
- **Each public function, each exported type, each field of an exported type, and each constant.**
- **Nothing else.** A private helper gets a name that says what it does. A function's body has no comment.

## What a comment says
- **Every noun is a thing the reader can point at:** an argument, a field, a type, or a literal value, in backticks. "Starts the countdown of the current timer" names nothing. "Sets `timer.timeLeft` to `timer.waitTime`" does. Tate: "you say things that sound good at first glance but can be done so much more concretley."
- **Each argument that the function reads is said to be what it is,** one to a line: its type, its values, and the field that it stands for. "`seconds`: a number of `0` or more. `advance` takes it from `timer.timeLeft`".
- **Everything a caller needs:** what changes, what the function returns, and what happens in each case a caller can meet.
- **Only what is true of the code.** Read the function before writing its comment. If the comment and the code disagree, the comment changes.
- **What is, never what was.** No history, no date, and no reason from a review.
- **Nothing outside the file.** A comment never points at a game, a device, another comment, or whoever calls the function. It names the module's own members.
- **A guard** is one sentence: `Raises an error if ...`. Say what stays unchanged.
- **A trap** is a line that starts with `Note:`. A check that a function leaves out is a trap.
- **No more than that.** One to three sentences is usual. If a shorter comment loses no fact, the shorter comment is better.

## How each kind starts
| Kind | Starts with | Example |
|---|---|---|
| File | A noun phrase: what the thing is and does | A countdown timer. |
| Type | A noun phrase | A countdown that `advance` runs down. |
| Field or constant | A noun phrase, with its unit | The time until the timer times out, in seconds. |
| Boolean field | `If true, ...` | If `true`, the timer stops when it times out. |
| Signal or callback | `Fires after ...`, then `Passes ...` | Fires after `advance` takes `timeLeft` to `0`. Passes the timer. |
| Function | A verb in the third person | Starts the timer, or resets the timer if it was started already. |
| Function that only answers | `Returns ...` | Returns `true` if `timer.timeLeft` is `0`. |

A function that returns a value says so with the word `Returns` or `returns`.

## How it is written
| Rule | Not this | This |
|---|---|---|
| The active voice. The subject is the thing described, or whatever acts | Fired when the time has run out | Fires after `advance` takes `timeLeft` to `0` |
| A precise verb. A comment never only says the function's name again | Starts the timer | Sets `timer.timeLeft` to `timer.waitTime` |
| No verb in `-ing` for a change that happens at once | Returns `nil`, changing nothing | Returns `nil` and changes nothing |
| No word that adds nothing | may be any value at all | Accepts a value of any type |
| The thing named again where `it` could be doubted | with the time it had | with the `timeLeft` that the timer had |
| `'s` for what belongs to a thing | the wait time of the timer | the timer's `waitTime` |
| A comma before the `and` or `or` that ends a list of three or more | starts, stops and resets | starts, stops, and resets |
| A value that a caller passes or gets is a literal, in backticks | counted from 1 | counted from `1` |
| The argument alone, never a word and then the argument of the same name | Adds the seconds `seconds` | Adds `seconds` |

- **Never:** `obvious`, `simple`, `basic`, `easy`, `actual`, `just`, `clear`, `however`, their forms in `-ly`, `the former`, and `the latter`.
- **`It` is fine** when it can only mean the subject of its own sentence, or the thing the comment stands over.
- **Other numbers** are words up to ten and digits above.

## The words
- **The two tables in `names.md` are the vocabulary:** one name for each idea, and one meaning for each verb. A comment uses those words and no others for those things.
- **A signal fires and passes. A callback connects.** Those are Roblox's words.
- **Backticks go around every argument, member, type, and literal value.** A member of this module is written by its bare name, `start`. A member of another module is written in full, `Queue.clear`, and the reference makes it a link.
- **No word of a user of the library.** A comment that needs a game to make sense is describing the game.

## What a page needs
- **A page uses no word that it does not explain or link.** A reader lands on one function and reads nothing else. Where an argument's type does not say what the argument is, the comment says so, or names the type in full so that the page links to it.
- **An example is a file in `demos`, named for its module:** the module `Timer` has a file of that name there. `lune run tools/check` runs every one, and the module's page shows the file with what it prints.

## Layout
- `---` and a space, directly over the thing, wrapped at 100 columns with a tab counted as 4.
- A bare `---` starts a new paragraph. A list item starts with `- `.

## How comments are checked
- **`python tools/comments.py`** fails for a missing comment, a brief description over 200 characters, a word followed by an argument of the same name, a function that returns a value and never says `Returns`, and each banned word or phrase. `lune run tools/check` runs it.
- **A script cannot tell whether a comment is true, complete, or well put.** A reader does that, against the function.
- **Look at the page in a browser,** as Tate will: `python tools/reference.py`, and then the page itself.
- **A cold reader reads the page.** A fresh helper is shown one page and nothing else, says what each member does, and lists each word it could not explain from the page. A guess is a failure, as it is for a name.
