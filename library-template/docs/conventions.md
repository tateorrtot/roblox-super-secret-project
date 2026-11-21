# Conventions for the code

How code in a library is written. Read this file before changing anything in `src` or `tests`. Names are in `names.md`, and comments in `comments.md`. The examples are of a countdown timer, as Godot's `Timer` is.

## What a library is
- **It works in any game.** If it could not be copied into a different game as it is, it is wrong. Tate, 2026-11-21: "If you cant just pull it out and use it in some completley other game or use case thats bad."
- **It knows nothing of who uses it.** No name, comment, field, or argument comes from one user of the library. A need of one user never becomes a field of the library: it stays with that user, who calls the library.
- **It is handed what it needs.** A list is handed in, and is not kept in the module for every user to share. A number that a game would tune is handed in, and is not a constant of the module. A rule is handed in as a function.
- **It requires nothing outside its own folder.** Not the game, and not another library. Where nothing else will do, `README.md` says why.
- **Inside the folder, a file requires what is beside it or below it,** and never what is above. Every require in `src` starts with `./`. `lune run tools/check` fails for one that does not.
- **It talks to Luau, and to Roblox only where talking to Roblox is its job.** Code that needs no Roblox call makes none, so that `lune` can run its tests.
- **Roblox first.** Before a library is built, its `README.md` says what Roblox already has for the job and why that will not do.

## Shape
- **A thing is a plain table, and its module's functions take it first:** `Timer.start(timer)`. No metatable and no method. This is Claude's call, for Tate to veto.
- **One job each.** A function does one thing. A function that takes a thing out and puts it somewhere else is two functions, and whoever uses the library calls them in turn. Tate, 2026-11-21: "Dont bake it together".
- **Count what a type has room for, and ask who said so.** One of a thing, two of a thing, and "someone is there" are each a contract. Tate, of a type with room for two: "Who said only two"?
- **Nothing is pulled out before there is a pattern.** Write the plain thing. A shared part comes out only when the repetition is real, and then as one more single-job function.
- **Nothing nests more than two deep.** `python tools/metrics.py --functions` shows each function's depth.
- **Break it up.** When a piece does more than one thing, split it: a folder, a file, a function, a block.

## Data
- **Empty is empty.** Where there is nothing there is `nil`: no placeholder value, no sentinel, and no empty record stands in for it.
- **A value never changes,** and its functions return new values. It is frozen, and its fields are typed `read`.
- **A thing changes in place, through its own module's functions.** Only a thing's own module assigns its fields. Only fields that never change after the thing is made are `read`.
- **A function that moves things returns what the caller is left holding,** and nothing is made or lost.
- **Keep the facts, and work the rest out where it is used.** A value worked out from others is not stored.
- **Time is handed in.** A thing that changes with time has `advance`, and the caller says how many seconds passed. No module reads a clock.

## Check, then act
Tate, 2026-11-20: "if you say "jump" dont have a check inside that method. Check before you call the method like "can_jump" THEN "jump". A method should always do as it says so its intuitive. ... Sometimes we may never care about "can_jump" and just force a jump."
- **A function does what its name says, every time it is called.** It does not look first and quietly do nothing.
- **The check is a function of its own,** named `can...` or `is...`, and the caller asks it first.
- **An action that cannot be carried out fails loudly,** where going on would spoil the data, and its comment says so: "Raises an error if ...".
- A function that is asked to remove a thing that is not there has nothing to do, and that is not a check.

## Telling, and answering
- **An answer for the one who asked is a return value.**
- **News for whoever cares, when the library does not know who that is, is a signal or a callback.** A library has no signal module to require. It takes a callback that it was handed, or returns what changed. If it must have signals of its own, `README.md` says why.
- **A callback that a library is handed is called with only what that callback needs.**

## Failure
- **What can happen in use is a return value.** No room, nothing there.
- **What comes from outside is checked once, where it comes in:** stored data, in `decode`; a value from another machine, in the one function that takes it.
- **Below that a function trusts its arguments.** It does not check them again or build error messages.
- **A guard stays only where Luau would otherwise make or lose data without an error:** a count that is not a whole number, a place that the thing does not have. A guard raises an error that blames the caller, with `error(message, 2)`.
- The type checker vouches for types and for nothing else.

## Comments
`comments.md` has the rules in full. In short: the comments are the class reference, written as Godot's is. Every noun in a comment is an argument, a field, a type, or a literal value. `python tools/reference.py` makes a page for each module, and Tate reads the pages before the code.

## Tests and examples
- Tests are plain scripts in `tests`, one `<Module>.test.luau` for each module, using `tests/Check.luau`.
- A check's message says what should be true, and starts with the name of the function it is about.
- `Check.raises` also requires the error to blame the calling script.
- A test never reaches into a thing's fields to set them up when a function of the module can.
- **Each module has an example in `demos`, named for it,** that runs and prints. Writing it is the test of the interface: if the example is hard to write, the interface is hard to use.
- **The cases in `README.md` are tests.** Each case that the page says the library serves has a test or a demo that shows it served, with no change to the library.

## A library is done when
1. `README.md` says what the library is, and the code does what the page says.
2. Every check passes: `lune run tools/check`.
3. A mutation run (`python tools/mutate.py`) leaves only changes no caller could see.
4. `python tools/unused.py` lists no function: every public function is called in `src`, in a demo, or in a case of the page.
5. Its names pass the names test in `names.md`.
6. A cold reader, shown one page of the reference and nothing else, can say what each member does.

A passing check says that the code does what was written. It never says that the design is right: a reader does that.
