# Reviews of the code

Reviews done by agents, as opposed to the user's own reviews, which are in `docs/working/code-reviews/`.

| File | What it is | Caveat |
|---|---|---|
| `14-code-review-2026-11-19.md` | The independent review of the code written overnight: every finding, whether a second agent upheld it, and what was done | Eight agents on Sonnet. Findings about the server and the player's machine were reasoned from the code, not run |
| `15-code-double-check-2026-11-20.md` | The double check the user asked for after reading the code: the measurements, what a Godot developer made of seven files shown cold, every finding of four more readers with a skeptic's verdict on each, what was done about it, and the test of the names | Nine agents on the session's model, then five readers on Sonnet. Nothing was run in Studio |
| `17-audit-after-the-eighth-review-2026-11-20.md` | The audit the user asked for with "are you doing a pattern of this across the codebase?": what the game promises for every item, names with invented words or two readings, and which words are Roblox's, Godot's or ours | Nine agents on Sonnet, each reader checked by a skeptic. The skeptic of the words ruled on half of the names. The full lists are not kept |
| `16-coupling-review-2026-11-20.md` | The review the user asked for after `World.setPlayerPosition` alarmed them: is the code coupled spaghetti? Ten findings upheld and worth acting on, what waits for a feature, what is harmless, what is clean, and four additions traced through the code | Ten agents on Sonnet. Nothing was run, and nothing was fixed |
