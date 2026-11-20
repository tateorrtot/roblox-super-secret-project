# Code in `src`

This file loads when a file under `src` is opened, and brings the conventions with it.

- `src/shared` holds the rules: plain Luau, no Roblox calls, each piece tested in `tests/`.
- `src/server` and `src/client` are the Roblox side. `Main.server.luau` and `Main.client.luau` are the only scripts that run by themselves.
- `python tools/outline.py` prints every public function. `docs/code/pieces.md` says what each piece is.
- After a change: `lune run tools/check`, and `python tools/playtest.py` if it touched `src/server` or `src/client`.

@../docs/code/names.md
@../docs/code/conventions.md
