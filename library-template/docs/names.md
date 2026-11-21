# Names

How things in a library are named. A reader is shown one module as bare names, with no arguments and no comments, and must know what each function does. The other rules for code are in `conventions.md`. The examples are of a countdown timer, as Godot's `Timer` is.

## The rules
**A file is one thing, named for it with a noun.** `Timer`, `Queue`. No prefix.

**A function's name says what it acts on, and where.** Read alone, with no arguments and no comment, `Module.name` tells a stranger what the function does.
- A bare verb means the whole of the thing the file is named for. `Timer.start` starts the timer. `Queue.clear` empties the queue.
- Anything else names its object, and the place when there is one: `Queue.removeFromFront`, `Grid.getCellAt`.
- A noun in a name is a part of the thing, or something the caller passes or gets back. A name with `Cell` in it takes or returns a cell.
- Arguments come in the order the name gives them: the thing first, then where, then how much.
- No name stops at an adjective. `timeLeft`, not `left`.

**Every function starts with a verb.** The exception is a yes-or-no question, which is named as the statement that would be true: `isStopped`, `hasCell`, `canStart`. A function that only reads starts with `get`, `count`, or `find`.

**A name is a promise, and the function keeps it.** If what a function does cannot be said in a sentence built from its name, it is the wrong shape: split it or rename it.
- **A setter names the thing it sets:** `set` and the property. `setWaitTime`, never `setTimer`.
- **`And` in a name is a flag.** A function named for two things does the work of two functions: split it.
- **A long name is a flag too, and not always wrong.**
- **A word names a real thing in the code, or it is not used.** Every word in a name is a type, a field, or a constant of the code, a word from the two tables below, or a plain word nobody could doubt, such as `nearest` or `empty`. An adjective counts: if a name says `due`, the code says what makes a thing due.
- **Roblox's word first, then Godot's, and never one of ours.** Where Roblox has a word for a thing, the code uses it and keeps to it: `connect` and `fire` for a signal, as `RBXScriptSignal:Connect` and `BindableEvent:Fire` have them. Where Roblox has none, Godot's.
- **A noun that can be read two ways is a failed name.** `TimerControls` could be what controls a timer or the controls that a timer has.
- **No word of a user of the library.** A library's names come from what the library is, and never from what one game does with it. A queue has a front and a back. It has no customers.
- **No concept that exists only to route between two things.** If a function needs to know which of two things to act on, it takes the thing.

## One name for each idea
| Name | Means |
|---|---|
| `...Count`, `..._COUNT` | How many. A plural, such as `cells`, is the things themselves |
| `...Seconds`, `..._SECONDS` | A length of time |
| `...Time` | A moment on a clock, in seconds |
| `now` | The present time, in seconds, which the caller passes |
| `...Ratio` | A number from 0 to 1 |
| `...Id` | What a thing is found by. Say in its comment who makes the id |

A library adds a row here for each idea of its own, with the one name that it keeps to.

## One meaning for each verb
| Verb | Means | Returns |
|---|---|---|
| `new` | Makes one | It |
| `get` | Reads what is there | It, or `nil` when nothing is there |
| `set` | Replaces; `nil` removes | Nothing |
| `add` | Puts in wherever it fits | What did not fit, or how many went in |
| `put` | Puts into a named place | What did not fit |
| `take` | Takes out of a named place for the caller | What was taken |
| `remove` | Takes out wherever it is | How many were removed, or the thing if a caller has a use for it |
| `move` | Takes from where it is to somewhere else | How many moved |
| `merge` | Makes things of one kind into one | The merged thing, then what did not fit |
| `split` | Makes one thing into two | Both parts |
| `count` | Counts | A number |
| `has`, `is`, `can` | Asks, and changes nothing. `can` with an action's name asks whether that action could be carried out now: `canStart` before `start` | `true` or `false` |
| `find` | Looks for one that may not be there | It, or `nil` |
| `connect` | Connects a callback to a signal | Nothing |
| `fire` | Calls every callback connected to a signal, at once and in the order they were connected | Nothing |
| `start`, `stop` | Begins or ends what the thing does over time | Nothing |
| `advance` | Moves a thing on in time: `advance` by so many seconds, `advanceTo` a time | Nothing |
| `clear` | Empties | Nothing |
| `encode`, `decode` | Turns a thing into plain data, and back | The plain data; the thing, or `nil` and what was wrong |
| `validate` | Checks a value that came from outside | `nil`, or what is wrong with it, in words |
| `update` | Makes a drawing piece match what it is given | Nothing |
| `show`, `hide` | Puts a drawing piece in view, or takes it out of view | Nothing |

A library that needs a verb that is not here adds a row, with one meaning.

## The names test
Tate, 2026-11-20: "I see just the class. ... I look in the class. ... these are my methods. ... If it doesnt work out of context. It doesnt work."
- **A reader is shown one module and nothing else:** its name, the fields of its types, its constants, and its functions. `python tools/bare_names.py Timer` prints exactly that.
- No first line of the file, no comments, no arguments, no other module, and no word of what the library is for.
- The reader writes what the module is and what each member is or does, and marks each `clear`, `guess`, or `no idea`.
- **A guess is a failure, even when it is right.** A helper that reads names is far more forgiving than Tate is.
- A doubt about what a member acts on, or where, is a failed name. A doubt about how much moves, or what comes back, is the signature's to answer.
- **A module is a noun.** When no noun works, the module is wrong, not the name: split it, or give its parts to the things they belong to.
