# Skills in this repository

Guides that Claude loads when a task calls for one. Each folder is one skill.

## Where these came from
The eight folders here were copied, unchanged, from the repository gamedev-skills/awesome-gamedev-agent-skills on GitHub, at commit c6ca6c41c839b68319ffc08430b99ab768debc32 of 2026-11-12. They are under the Apache licence, version 2.0: the licence and the notice are the two text files beside this one. The user asked for them on 2026-11-20.

## How they were checked before they were copied
- Every file was read in full by a helper told to treat it as untrusted and to report anything that was not a plain coding guide. Five readers, thirty files, about 3,700 lines.
- The only hosts any file names are create.roblox.com, devforum.roblox.com and github.com.
- The only commands any file asks for are linters, Rojo, Lune and a text search, and Studio's own connector.
- The three scripts in the folder for simulator economies are a calculator and its tests. They read one settings file named on the command line and print. They use no network and write no file.

## Where a skill and this project disagree, the project wins
The project's rules are in `CLAUDE.md` and `docs/`.
- **A skill says to prove each change in Studio.** Here the fast checks run after each change, and the Studio play test runs once a turn, after the user is told.
- **A skill says to author things in Studio's Explorer.** Here the world and the screens are built by code. Whether that changes is the user's to say.
- **Nothing here saves or publishes the place.**
- **The rules in `src/shared` are plain Luau with no Roblox calls,** written as a module's function called with the thing.
- **What a skill says of Roblox's limits, dates and versions is a lead to check** against Roblox's own documentation, not a fact. The readers marked several dozen such claims as ones they could not confirm.
- **The simulator-economy skill is about the kind of Roblox game called a simulator:** click, upgrade, rebirth. This game is not one (`docs/game/brief.md`). Its sums for costs and pacing may still serve the game's economy.
