# The notes

Everything Claude and the user have worked out, one topic to a file. `CLAUDE.md` at the top of the repository is the map; this file says what each folder is for.

| Folder | What is in it |
|---|---|
| `game/` | What the game is. The user's brief, the core rule, the setting, design decisions, and the consistency rule |
| `working/` | How the work is done. Who decides what, the user's engineering rules, and their reviews of the code in their own words |
| `code/` | The code. Its conventions, the pieces that exist, how it is checked, and the reviews of it |
| `roblox/` | The platform. Facts that constrain the design, how Studio is driven, and Roblox explained for a Godot developer |
| `status/` | Where things stand, what comes next, what the user has been asked, and the calls Claude made. `status/history/` holds what is over |
| `research/` | Research on the market, on concepts and on how things are built. Large files, each with a caveat in the folder's `README.md` |
| `architecture/` | The architecture notes and their reviews. Reference only |

## Keeping it readable
- **One topic to a file.** If a file grows past a screen or two, it is two topics: split it.
- **A file starts with what it is,** in a line or two, so that it can be judged without reading it.
- **The user's words are quoted, and Claude's reading of them is marked as Claude's.**
- **What is over moves to `status/history/`.** `status/now.md` holds only what is true now.
- **The files in `research/`, `architecture/` and `code/reviews/` keep the numbers they were written under** (`05`, `15`), because older notes and commit messages refer to them that way.
