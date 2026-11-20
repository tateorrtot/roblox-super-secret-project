# The user's reviews of the code

The user has reviewed the code seven times. Each file here is one review, in their words, with what Claude took from it. Read this page before showing them code; read a review when you need their exact words.

The number in a file's name counts the reviews of 2026-11-20, so it is one less than the review's place in this list.

| | Review | What they found |
|---|---|---|
| 1 | `2026-11-19-the-first-piece.md` | An empty slot stored as `false`. "If something is empty... it is empty!" Pieces must make sense with no context |
| 2 | `2026-11-20-1-first-read.md` | They could not judge the code. Files too long, too many comments, names that said nothing: "What is SlotMouse?" |
| 3 | `2026-11-20-2-the-sample.md` | Comments that leaned on Minecraft and on a mouse. A function named `drop` that did not drop. "you can and should break it up!" |
| 4 | `2026-11-20-3-the-names.md` | Function names with no object. "gather... what?" They guessed wrongly what `moveStack` took |
| 5 | `2026-11-20-4-out-of-context.md` | A function tied to a thing that is not its own: "Spaghetti!" A class named with a verb. "If it doesnt work out of context. It doesnt work." Delete a directory, and its neighbour must not break |
| 6 | `2026-11-20-5-events-and-glue.md` | "setCharacter what?" A thing that is removed should say so, and the pieces that care do the rest. A big glue service is fine. One exception to a name's promise, "here and HERE ONLY", which was lifted the same day |
| 7 | `2026-11-20-6-check-then-act.md` | "verbNounAndNoun": a name with `And` is two functions. "Check before you call the method like can_jump THEN jump." "Doesnt roblox have events?" A station is a black box: "contain the spaghettii" |

Their message after the seventh was answers and not a review: signals approved, merging to follow Minecraft, and "quality is a lot more important than speed!" (`docs/working/engineering-rules.md`).

## What to check before showing them code
These are Claude's readings of the seven reviews. The quotes are in the files.

- **Read each class alone,** as `python tools/bare_names.py <Module>` prints it: its name and its members' names, and nothing else. Each name must say what it is, or what it acts on and where. If you would have to ask "... what?", so will they. A guess is a failure.
- **A class is a noun.** If no noun works, the class is wrong.
- **A name is a promise.** A function does the thing its name says: all of it, nothing else, and every time it is called. If it also sets, stores or works out something for another concern, that is the tangle they called spaghetti. If it looks first and quietly does nothing, the check belongs in a function of its own, `can...`, called first.
- **A setter names the thing it sets:** `set` and the property. "setCharacter what?"
- **`And` in a name is two functions.** A long name is a flag, and not always wrong.
- **Say what Roblox has before proposing ours.** "This is a roblox game first."
- **A general name on one example is a promise the code cannot keep.** Each kind of thing keeps its workings to itself.
- **When a cold reader doubts a name, change it.** Two readers doubted `setCharacter`, Claude kept it, and the user asked the readers' question word for word.
- **The function that removes a thing does not know what else must happen.** The thing says it is going, and each piece that cares does its part.
- **Glue may be big. It holds no rules of its own.**
- **Say the cost of a cleaner design with the proposal.** They turned one down for its cost and allowed an exception instead.
- **Maintainable and plain comes before working.** "much. much. much. more important than getting it to work right now."
- **A comment says completely what a thing does, in its own words.** It never points at another game, a device, the caller or another comment. Godot's class reference is the model.
- **Short was never the point. Explicit was.**
- **Empty is empty.** No placeholder or sentinel stands in for nothing.
- **Break it up:** directory, file, function, block. The work is deciding where to cut, what to name each part, and which layer it sits on.
- **Few indents.** Nothing nests more than two deep.
- **The rules know nothing of the mouse, the keys or a touch screen.**
- **Measure before showing:** `python tools/metrics.py --functions`, `python tools/unused.py`, and a names test on a fresh reader (`docs/code/names.md` says how).
- **Explain Roblox by its Godot counterpart** (`docs/roblox/explained-for-godot.md`).

Each of the seven reviews found something the checks before it had passed. Expect an eighth.
