# Roblox, explained for a Godot developer

How Claude explained Roblox to the user on 2026-11-20, so that later sessions say the same thing. The user is a Godot architect who has never used Roblox or Luau.

| Roblox | Godot |
|---|---|
| An Instance | A Node |
| The DataModel (`game`) | The SceneTree |
| A ModuleScript | A script used as a library. `require` is `preload`, and the module runs once |
| A Script or LocalScript | A script that is itself a node in the tree, not attached to one |
| Luau has no `class` and no `extends` | GDScript's `extends Item`. A module returns a table of constants and functions. A thing "is an item" by having the fields a registry asks for, and the type checker says so where it is registered. Inheritance can be imitated with metatables, as JavaScript does with prototypes, and many Roblox projects do. This one does not. Roblox's own classes, such as `Part`, cannot be extended at all |
| An Instance with Attributes, and a script beneath it | A Resource or a scene with exported variables, edited in the Inspector. It is Roblox's own way to give a thing properties. The game's items are tables in code, because the rules are tested outside Studio |
| A RemoteEvent | An RPC |
| `RunService.Heartbeat` | `_process` |
| A Model or ScreenGui made in Studio, kept in storage and cloned | A scene. This project has none yet, because everything is built by code |
| A tag on an Instance, with one module that handles every Instance that has it (`CollectionService`) | A script attached to a scene's root. It is how Roblox gives each kind of thing its own behaviour |
| A table type that lists functions, such as `PlacedObjectScript` | An interface, or the traits proposed for GDScript. Luau has no keyword for it: any table with those functions fits, and the type checker says so where the table is used as that type |
| An `InputAction` with its `InputBinding`s, in an `InputContext` | An action in the Input Map, with its events. `action.Pressed` is `Input.is_action_just_pressed`. It is an Instance in the tree, made in the editor or the project file (`input.md`) |
| A `Tool`, with `Equipped` and `Activated` | Nothing built in. They are Roblox's words for what the user called an item being selected, and interacting while it is selected. The game's items are not Tools (`input.md` says why) |

## The one large difference
Every Roblox game is a server and clients, always. What would be the script on an inventory screen's node in Godot is split here in two:
- the rules, which the server runs, in `src/shared`;
- the drawing, on the player's machine, in `src/client`.

## Two things the user asked
- **"This sounds a bit like ECS?"** It is not. Plain functions on plain tables are classes written the long way round: `Inventory.addItems(pack, ...)` is `pack.add_items(...)`. Claude offered to write them in the method form (`pack:addItems(...)`) if the user would rather read that. They have not answered.
- **"Ah so World is a bit like a 'Game Manager'!"** It is. `World` holds the game's state and what can be done in it.
- **"Does CrateItem not like, extend Item? ... How would I change its ID, stack size, icon?"** There is no `Item` class. On 2026-11-20 an item was three things joined by its id as a string: a row in `ItemDefinitions`, a row in `ItemLooks`, and a script if it does anything. Claude proposed one table for each item (`docs/status/next.md`).
- **"Im not sure if lua has interfaces or not for this like godots proposed traits for more strict typing."** It has them without the word. `PlacedObjectScripts.PlacedObjectScript` is a table type listing `interact` and `breakPlacedObject`, each marked as one a script may leave out, and `register` takes that type. So `lune run tools/check` refuses a script whose function takes the wrong arguments, at the line that registers it. Nothing is checked while the game runs. A kind of placed object is not an Instance with a tag: the rules are plain Luau below Roblox, so a kind is a plain module, found by the placed object's `kindId`.
