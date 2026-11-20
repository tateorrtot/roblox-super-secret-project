# Roblox, explained for a Godot developer

How Claude explained Roblox to the user on 2026-11-20, so that later sessions say the same thing. The user is a Godot architect who has never used Roblox or Luau.

| Roblox | Godot |
|---|---|
| An Instance | A Node |
| The DataModel (`game`) | The SceneTree |
| A ModuleScript | A script used as a library. `require` is `preload`, and the module runs once |
| A Script or LocalScript | A script that is itself a node in the tree, not attached to one |
| A RemoteEvent | An RPC |
| `RunService.Heartbeat` | `_process` |
| A Model or ScreenGui made in Studio, kept in storage and cloned | A scene. This project has none yet, because everything is built by code |
| A tag on an Instance, with one module that handles every Instance that has it (`CollectionService`) | A script attached to a scene's root. It is how Roblox gives each kind of thing its own behaviour |
| A table type that lists functions, such as `PlacedObjectKind` | An interface, or the traits proposed for GDScript. Luau has no keyword for it: any table with those functions fits, and the type checker says so where the table is used as that type |

## The one large difference
Every Roblox game is a server and clients, always. What would be the script on an inventory screen's node in Godot is split here in two:
- the rules, which the server runs, in `src/shared`;
- the drawing, on the player's machine, in `src/client`.

## Two things the user asked
- **"This sounds a bit like ECS?"** It is not. Plain functions on plain tables are classes written the long way round: `Inventory.addItems(pack, ...)` is `pack.add_items(...)`. Claude offered to write them in the method form (`pack:addItems(...)`) if the user would rather read that. They have not answered.
- **"Ah so World is a bit like a 'Game Manager'!"** It is. `World` holds the game's state and what can be done in it.
- **"Im not sure if lua has interfaces or not for this like godots proposed traits for more strict typing."** It has them without the word. `PlacedObjectKinds.PlacedObjectKind` is a table type listing `place`, `interact` and `breakPlacedObject`, and the list of kinds is typed with it, so `lune run tools/check` refuses a kind that lacks one or takes the wrong arguments. Nothing is checked while the game runs. A kind of placed object is not an Instance with a tag: the rules are plain Luau below Roblox, so a kind is a plain module, chosen by the placed object's `kindId`.
