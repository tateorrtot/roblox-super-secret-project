# Gyms

Experiments. The word and the rule are from https://www.gdquest.com/library/modular_game_architecture/, which the user chose on 2026-11-21: a gym is where an idea is tried without the game's conventions, and nothing outside a gym may refer to one.

- **Nothing in `src`, `tests`, `demos`, or `tools` requires or names a file in `gyms`.**
- **A gym is not part of the game.** `default.project.json` does not send it to Studio, and `lune run tools/check` does not read it.
- **A gym may be rough.** It need not follow `docs/code/names.md` or `docs/code/conventions.md`. It must say at its top what it tries, how to run it, and what was found.
- **What a gym finds is written down outside it,** in `docs/roblox/facts.md` for a fact about Roblox, or in the note of the branch it belongs to. A finding that only the gym holds is lost when the gym is deleted.
- **When an idea proves out, it is built again properly,** as a library in a folder beside this repo or as a system here. The gym's code is not moved in.

| Gym | What it tries |
|---|---|
| `vehicles` | Whether a body of welded blocks with wheels at any places can be driven from one small function that is handed what the driver wants |
| `items` | Whether the `inventory` and `ground-items` libraries join into a pack, a hotbar, a crate, a machine with rules, and a mover, with glue alone |
