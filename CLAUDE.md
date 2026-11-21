# Everything Roblox

This file is read by every session in every folder below it. It holds the goal, what each folder is, and the rules that are true of any code here. It names nothing that is inside the game.

## The goal (Tate's words, 2026-11-18)
> I want you to make a Roblox game. I'd like you to author the majority of it to test your capabilities. Your primary goal is to make as successful of a game as possible with as high of a playercount for as long as possible as reasonable.

**The goal is a good game that many people play for a long time. Everything else here is a means to it.** Tate, 2026-11-21: "its important to remember the original main goal of why were doing any of this and what the goal is. Anything else is just a means to reach that goal." Before a piece of work, say how it brings that game closer. If it does not, do not build it.

## The folders
```
roblox\
├─ main-project\       the game. Its own repo, with its own CLAUDE.md
├─ library-template\   what a new library starts as: the checks, the test helper, the rules for names, code, and comments
└─ <name>\             one library each. Its own repo, with its own CLAUDE.md and README.md
```
Everything Roblox is inside `roblox\`. Never ask for a folder outside it.

## The layers
From https://www.gdquest.com/library/modular_game_architecture/, which Tate chose on 2026-11-21. A script checks each rule.

| Layer | Where | What it holds | Its rule |
|---|---|---|---|
| Library | `roblox\<name>\` | Code that works in any game | Talks only to Luau and Roblox. Never requires the game. Requires another library almost never |
| Systems | `main-project\` | This game's rules | May use any library, and any other system |
| UI | `main-project\` | What shows the systems | Reads, never writes |
| Content | `main-project\` | This game's own things | Uses the systems. Nothing depends on content |
| Gyms | `main-project\` | Experiments | Nothing outside a gym refers to it |

- **A library knows nothing of who uses it.** If it could not be copied into a different game as it is, it is wrong. It is handed what it needs: a list, a number, a rule as a function.
- **A library requiring another library:** Tate, 2026-11-21: "okay and makes sense sometimes. It just needs to be done incredibly sparringly IF at all ever." Where one does, its `README.md` says why nothing else would do.
- **In a library's folder, never open `main-project\` or another library's folder.** What you need is in your own folder. If it is not, say what is missing and stop.
- **Inside any folder, a file requires what is in its own folder or below it, and never what is above.** This is Godot's "signal up, call down". Where that is impossible, break it and say where.

## Who you work with
Tate (@tateorrtot) is an experienced programmer and Godot architect who is new to Roblox and Luau.
- Explain Roblox by its Godot counterpart. Use Roblox's word first, then Godot's, and never an invented one.
- Be concrete. Every noun is a file, a type, a function, an argument, a field, or a value that Tate can open. Give one case with real values.
- Show structure as a diagram. An indent means that the thing above holds and calls the thing below.
- Say of each thing whether it is built or only proposed. Give counts with their lists: found, fixed, left.
- Ask one question at a time, readable alone. Expect to be challenged, and ask "who said?" of your own design first.
- "Slower is better." Sound and small beats fast and wide.

## How anything here is made
1. **Top down.** Break the problem into parts, and each part again, until a part is small and needs nothing of the rest. Never list parts by reading the code that exists: "Bottom up produces these webs."
2. **A page before code.** A library's `README.md` says what it is and why it exists, the cases it serves, its name and the names rejected, each decision with its reason, its files, its signatures, its rules of use, and what is open. Tate reads the page first.
3. **One job each.** A function does one thing, every time. Two jobs are two functions, and whoever uses them calls them in turn. A check is a separate `can...` or `is...`.
4. **No contract nobody asked for.** Count what a type has room for (one, two, "someone is there") and ask who said so. Never invent a concept to route between two things: pass the thing itself.
5. **Roblox first, then a library that exists.** Before building a thing, say what Roblox already has for it and why that will not do. Then look for a library that already does it. Tate, 2026-11-21: "if a library existing with everything I want lets use it ... If not custom. If youre unsure, custom." Judge a library by its source, not its README.
6. **Checked, and said plainly.** The folder's own check must pass. A passing check says that the code does what was written. It never says that the design is right: a reader does that.
7. **Names, code, and comments** follow `docs/names.md`, `docs/conventions.md`, and `docs/comments.md` of the folder you are in. Read them before changing code.

## Always
- **Commit as work is done. Push nothing unless asked.**
- **Ask before any action that spends Robux.** Passwords and verification stay with Tate. Never put an account name, or anything about Tate, in a web request. Do not save or publish a Studio place.
- **No AI-generated art reaches the public.** Words that a player reads are drafted and then reviewed by Tate.
- **Helper agents run on Sonnet, a few at a time.** One overnight run used a week's allowance. Design stays in the main session.
- **Keep this file short,** and keep the game out of it.
