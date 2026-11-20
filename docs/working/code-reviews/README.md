# The user's reviews of the code

The user has reviewed the code four times. Each file here is one review, in their words, with what Claude took from it. Read this page before showing them code; read a review when you need their exact words.

| Review | What they found |
|---|---|
| `2026-11-19-the-first-piece.md` | An empty slot stored as `false`. "If something is empty... it is empty!" Pieces must make sense with no context |
| `2026-11-20-1-first-read.md` | They could not judge the code. Files too long, too many comments, names that said nothing: "What is SlotMouse?" |
| `2026-11-20-2-the-sample.md` | Comments that leaned on Minecraft and on a mouse. A function named `drop` that did not drop. "you can and should break it up!" |
| `2026-11-20-3-the-names.md` | Function names with no object. "gather... what?" They guessed wrongly what `moveStack` took |

## What to check before showing them code
These are Claude's readings of the four reviews. The quotes are in the files.

- **Read the outline of names alone,** with no arguments and no comments (`python tools/outline.py --names`). Each name must say what the function acts on, and where. If you would have to ask "... what?", so will they.
- **A name is a promise.** A function does what its name says, all of it, and nothing else.
- **If they would have to ask what a thing is, its name failed.**
- **A comment says completely what a thing does, in its own words.** It never points at another game, a device, the caller or another comment. Godot's class reference is the model.
- **Short was never the point. Explicit was.**
- **Empty is empty.** No placeholder or sentinel stands in for nothing.
- **Break it up:** directory, file, function, block. The work is deciding where to cut, what to name each part, and which layer it sits on.
- **Few indents.** Nothing nests more than two deep.
- **The rules know nothing of the mouse, the keys or a touch screen.**
- **Measure before showing:** `python tools/metrics.py --functions`, `python tools/unused.py`, and a names test on a fresh reader (`docs/code/names.md` says how).
- **Explain Roblox by its Godot counterpart** (`docs/roblox/explained-for-godot.md`).

Each of the four reviews found something the checks before it had passed. Expect a fifth.
