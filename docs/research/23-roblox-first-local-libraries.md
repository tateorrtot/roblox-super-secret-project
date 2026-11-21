# How a Roblox project uses a library that lives in another folder on disk: what Roblox already has
Asked: how a game project reads a library kept in another folder on the same disk, in Rojo, Wally, pesde, Roblox, `lune` and `luau-lsp`.
Read by one reader on Sonnet, on 2026-11-21. Roblox Studio was not tested.

## What Roblox has
**Rojo 7 (`$path`)**
- The project-format page says `$path` is "the path on the filesystem to pull files from" and that paths "are relative to the folder containing the project file". It says nothing about `../`. https://github.com/rojo-rbx/rojo.space (docs/project-format.md)
- The source joins a relative `$path` to the project's folder and uses an absolute `$path` as it is. It makes no check that the result is inside the project. https://raw.githubusercontent.com/rojo-rbx/rojo/master/src/snapshot_middleware/project.rs (lines 109-118)
- The 7.7.1 changelog lists a fix for "`$path` values that point outside the project folder failing to match `syncRule`s on Windows". https://raw.githubusercontent.com/rojo-rbx/rojo/master/CHANGELOG.md (line 42)
- A folder that holds a `default.project.json` is read as a project, not as a plain folder. https://raw.githubusercontent.com/rojo-rbx/rojo/master/src/snapshot_middleware/mod.rs (lines 135-138)
- Nested project files exist since 0.6.0-alpha.1. Sync rules are reset in each project file, so each file must state its own `syncRules`. https://raw.githubusercontent.com/rojo-rbx/rojo/master/CHANGELOG.md (lines 287, 899)
- Rojo 0.6 stopped searching parent folders for a project file. Same changelog (line 913).
- Not found: a documentation page that states `../` in `$path` is allowed. The answer to question 1 rests on the source and the changelog.

**pesde**
- A `path` dependency is "found anywhere available to the operating system", is "forbidden in published packages", and the path "must be absolute" and point to a folder with a `pesde.toml`. Example: `foo = { path = "/home/user/foo" }`. https://docs.pesde.dev/guides/dependencies/
- A git dependency is `{ repo = "acme/package", rev = "main", path = "pkgs/foo" }`. The target "must either be a valid pesde package or a Wally package". Same page.
- A workspace dependency is `{ workspace = "acme/bar", version = "^" }`. Same page.
- A `wally` dependency is `{ wally = "acme/package", version = "^1.0.0" }`. Same page.

**Wally**
- The manifest shows only registry entries, `"SCOPE/NAME@VERSION_REQ"`. https://raw.githubusercontent.com/UpliftGames/wally/main/README.md (lines 182-197)
- The lockfile example has a `git:https://github.com/Roblox/cool-thing.git` entry with `rev` and `commit`. The README does not say how a manifest declares it. Same file (lines 217, 231).

**`require` by string in Roblox**
- Documented prefixes: `./` (starts at `script.Parent`), `../` (starts at `script.Parent.Parent`), `@self/` (starts at `script`), `@game/` (starts at `game`). Each other part is a child instance, and `..` is the parent. The call does not wait for a `ModuleScript` to exist. https://create.roblox.com/docs/reference/engine/globals/LuaGlobals.md (`require`)
- `@self` was enabled platform-wide on 2025-05-20. `@game` was added on 2026-01-08. https://devforum.roblox.com/raw/3405078
- The same post says absolute paths are not supported and that aliases are "not yet" supported. On 2026-01-08 Roblox wrote it is "working on making it possible to define your own custom require aliases". Same address.

**`lune` 0.11.1**
- A path starting with `./` or `../` is relative to the file that holds the `require`. Lune tries `name.luau`, `name.lua`, `name/init.luau`, `name/init.lua`. Paths are case-sensitive. https://raw.githubusercontent.com/lune-org/docs/main/src/content/docs/the-book/7-modules.mdx
- Aliases come from `.luaurc` (`"aliases"`), searched from the script's folder up through its parents. `@lune/` cannot be overridden. Same page.
- `@self` inside an `init.luau` means the folder of that file. Same page.

**Luau configuration**
- An alias is written `@name/path`. A relative alias path is read from the `.luaurc` that defines it. Missing aliases are inherited from parent folders' `.luaurc`. A cycle is an error. https://raw.githubusercontent.com/luau-lang/rfcs/master/docs/require-by-string-aliases.md
- An unprefixed path is an error in the final design; the prefixes are `@`, `./`, `../`. https://raw.githubusercontent.com/luau-lang/rfcs/master/docs/amended-require-resolution.md

## What it does not do
- The Rojo documentation page does not say whether `$path` may leave the project folder.
- Roblox Studio documents no `.luaurc` aliases. The only Roblox prefixes are `./`, `../`, `@self/`, `@game/`. Not found: any Roblox page that says `.luaurc` aliases work in Studio. A reply in the DevForum thread says Roblox lacks `.luaurc` support. https://devforum.roblox.com/raw/3405078 (line 1003 of the raw text)
- pesde does not take a relative `path` dependency. It takes an absolute one, and not in a published package.
- Wally: not found: a manifest field for a folder or git dependency.
- Roblox `require` by string resolves through `Instance` parents and children. It does not read the disk.
- Rojo changes the shape of an `init.luau` folder: it becomes a `ModuleScript` named after the folder. The thread says this differs from Luau's file semantics. https://devforum.roblox.com/raw/3405078 (lines 301-334 of the raw text)

## What was run
Scratch folder: `build\research\alias-test`, with `rokit.toml` copied from `main-project`. Layout: `library/src/hello.luau` returns a table with `say(): string`. `game/.luaurc` holds `{"aliases":{"lib":"../library/src"}}`. `game/viaAlias.luau` requires `@lib/hello`. `game/viaRelative.luau` requires `../library/src/hello`.
- `lune --version` printed `lune 0.11.1`. `luau-lsp --version` printed `1.70.1`.
- `lune run game/viaAlias` printed `hello from library`, exit 0.
- `lune run game/viaRelative` printed `hello from library`, exit 0.
- `luau-lsp analyze game/viaAlias.luau` and `game/viaRelative.luau`: no errors, exit 0. It printed `Loading Luau configuration from ...\game\.luaurc`.
- `luau-lsp analyze --platform=standard game/typed.luau`, where `typed.luau` assigns `hello.say()` to a `number`: `TypeError: Expected this to be 'number', but got 'string'`, exit 1. The type crosses the alias.
- `game/bad.luau` requires `@nope/hello`. `lune run game/bad` printed `@nope is not a valid alias`, exit 1. `luau-lsp analyze game/bad.luau` printed `TypeError: Unknown require: ...\game\@nope\hello.lua`, exit 1.
- Not run: `luau-lsp analyze` with `--sourcemap` (the mode that maps requires onto Rojo's instance tree), `@self` in `luau-lsp`, and Rojo.

## What a game must still build
- `@lib/...` resolves in `lune` and `luau-lsp` and not in Roblox. A require written with an alias in a file that Rojo syncs fails in Studio.
- `./` and `../` work in all three. In Roblox they resolve over the `DataModel`, in `lune` and `luau-lsp` over folders. They agree only when the instances Rojo builds sit in the same relative places as the files on disk. Not tested.
- A `$path` that leaves the project folder is accepted by the source, and no documentation page confirms it. Not run.
- Roblox `@game/...` has no counterpart in `lune` or `luau-lsp`, unless an alias with that name is defined. Not tested.
- No tool read here copies or links a folder from the same disk through a manifest, apart from pesde's absolute `path`.

## Sources
- https://github.com/rojo-rbx/rojo.space (docs/project-format.md) and https://raw.githubusercontent.com/rojo-rbx/rojo/master/CHANGELOG.md
- https://raw.githubusercontent.com/rojo-rbx/rojo/master/src/snapshot_middleware/project.rs and .../mod.rs
- https://docs.pesde.dev/guides/dependencies/
- https://raw.githubusercontent.com/UpliftGames/wally/main/README.md
- https://create.roblox.com/docs/reference/engine/globals/LuaGlobals.md
- https://devforum.roblox.com/raw/3405078
- https://raw.githubusercontent.com/lune-org/docs/main/src/content/docs/the-book/7-modules.mdx
- https://raw.githubusercontent.com/luau-lang/rfcs/master/docs/require-by-string-aliases.md and .../amended-require-resolution.md
- Not read: https://luau.org/require (404). The sources above that disagree: none found.

## Checked by a second reader
- Claims checked: 15. Confirmed: 12. Wrong: 0 outright, 2 imprecise. Unconfirmed: 3.
- Checked on 2026-11-21 by fetching each address. The brief's line numbers were matched against the raw files.

**Wrong or imprecise**
- Rojo line 11 joins two facts in one sentence: "Nested project files exist since 0.6.0-alpha.1. Sync rules are reset in each project file". The 0.6.0-alpha.1 entry says only "Added support for nested project files" (line 899). The sync rule reset is in the 7.5.0 entry, dated April 25th, 2025 (line 287). The cited lines are right. The sentence reads as if both came in 0.6.0-alpha.1. https://raw.githubusercontent.com/rojo-rbx/rojo/master/CHANGELOG.md
- Wally line 22 says the manifest "shows only registry entries". The README comment at line 188 says the value "will usually be a string of the form" `SCOPE/NAME@VERSION_REQ`. "Usually" leaves other forms open. The README shows no other form. https://raw.githubusercontent.com/UpliftGames/wally/main/README.md

**Confirmed (each against the address the brief gives)**
- Rojo `project.rs`: a relative `$path` is joined with `project_folder`, an absolute one is used as it is, and no check follows. The code is at lines 114-118, not 109-118.
- Rojo 7.7.1 changelog (line 42, dated October 1st, 2026): fix for `$path` values that point outside the project folder failing to match `syncRule`s on Windows.
- Rojo `mod.rs`: `DEFAULT_PROJECT_NAMES` is checked first (line 135) and returns `Middleware::Project`.
- Rojo changelog line 913: Rojo no longer traverses directories upwards looking for project files. It is under 0.6.0-alpha.1.
- Rojo project-format page: `$path` is "The path on the filesystem to pull files from into the project." and "Paths are relative to the folder containing the project file." It does not mention `../`. https://rojo.space/docs/v7/project-format/
- pesde: `path` must be absolute, must hold a `pesde.toml`, and is forbidden in published packages. The git, workspace and `wally` examples match. https://docs.pesde.dev/guides/dependencies/
- Wally lockfile has the `git:https://github.com/Roblox/cool-thing.git` entry (lines 217, 231). The README does not show a manifest form for it.
- Roblox `require`: `./` starts at `script.Parent`, `../` at `script.Parent.Parent`, `@self/` at `script`, `@game/` at `game`. The call does not wait for a `ModuleScript`. https://create.roblox.com/docs/reference/engine/globals/LuaGlobals.md
- DevForum 3405078: `@self` enabled platform-wide in the update dated May 20, 2025. `@game` added in the update dated Jan 8, 2026. Roblox says it is "working on making it possible to define your own custom require aliases". Absolute paths: "No". Aliased paths: "Not yet". A reply (line 1003) says Roblox released the feature without `.luaurc` support. A reply (lines 301-304) says `foo/init.luau` changes shape when Rojo syncs it. https://devforum.roblox.com/raw/3405078
- Lune modules page: `./` and `../` are relative to the requiring file. Lookup order is `name.luau`, `name.lua`, `name/init.luau`, `name/init.lua`. Paths are case-sensitive. Aliases come from `.luaurc` and are searched up through parent folders. `@lune/` cannot be overridden. `@self` in `init.luau` means that file's folder. https://raw.githubusercontent.com/lune-org/docs/main/src/content/docs/the-book/7-modules.mdx
- Luau aliases RFC: `@name/path`. A relative alias path is read from the defining `.luaurc`. Missing aliases are inherited from parent folders. A cycle is an error. https://raw.githubusercontent.com/luau-lang/rfcs/master/docs/require-by-string-aliases.md
- Luau amended resolution RFC: an unprefixed path always errors. https://raw.githubusercontent.com/luau-lang/rfcs/master/docs/amended-require-resolution.md

**Unconfirmed**
- Everything under "What was run" (the `lune` and `luau-lsp` results, versions 0.11.1 and 1.70.1). No source is given for it, and the second reader did not rerun it.
- "A `$path` that leaves the project folder is accepted" by Rojo 7 in practice. The source and the 7.7.1 entry point that way. No documentation page says it. The brief states this itself.
- `https://luau.org/require` returned 404 for the second reader as well. The brief's source list gives the RFC addresses instead. No Luau documentation page for require was found.
- Note on addresses: the brief cites `https://github.com/rojo-rbx/rojo.space (docs/project-format.md)`. The repository exists (200). The quoted text was confirmed on the page above, not in that file.
