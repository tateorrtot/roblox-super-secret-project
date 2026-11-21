# NAME

ONE SENTENCE: WHAT THIS LIBRARY IS. Its page is `README.md`: read that first.

This folder is one library. It works in any game, and it knows nothing of who uses it. The goal that it serves, and the rules that hold in every folder, are in the `CLAUDE.md` one folder up.

## Rules of this folder
- **Never open a folder outside this one.** What you need is here. If it is not, say what is missing and stop.
- **The page comes before the code.** `README.md` says what the library is, the cases it serves, each decision with its reason, the signatures, and what is open. Tate reads the page first, and the code does what the page says.
- **Before changing code, read `docs/names.md`, `docs/conventions.md`, and `docs/comments.md`.**
- **`lune run tools/check` must pass.** Run `export PATH="$HOME/.rokit/bin:$PATH"` first.
- **Commit as work is done. Push nothing.**

## The map
| Where | What it holds |
|---|---|
| `README.md` | The page: what this library is and why, its decisions, its signatures, what is open |
| `src/` | The modules. Plain Luau, each `--!strict` |
| `tests/` | `Check.luau`, and one `<Module>.test.luau` for each module |
| `demos/` | One example for each module, which runs and prints |
| `docs/` | How names, code, and comments are written here |
| `tools/` | The checks, and the class reference |
| `build/` | What the tools write. Not kept in git |

## The tools
| Command | What it does |
|---|---|
| `lune run tools/check` | Runs every check: format, lint, types, requires, notes, comments, tests, demos |
| `python tools/reference.py` | Writes the class reference to `build/reference` from the comments |
| `python tools/bare_names.py <Module>` | Prints one module as bare names, for the names test |
| `python tools/outline.py` | Prints every public function |
| `python tools/metrics.py --functions` | Shows each function's length and depth |
| `python tools/mutate.py` | Changes the code a little at a time and shows which changes no test notices |
| `python tools/unused.py` | Lists public functions that no case of the page needs |

## Where things stand
NOTHING IS BUILT YET. Keep this section true: what is built, what is checked, what is open, and what waits on Tate.
