# What other games call a thing placed in the world

Researched on 2026-11-20, when the user turned down "block" and "placed item" and asked: "What do other games call this?"

**Caveats.** Three readers on Sonnet, each fetching wikis and modding documentation. Many fan wikis refused the fetch, so several rows rest on a mirror or on a search summary; those are marked. Nothing was checked by a second reader. The Roblox games have no modding documentation, so how they join an item to a placed thing is not known.

## The words
| Word | Who uses it | Source |
|---|---|---|
| **building** | RimWorld, Oxygen Not Included, Dwarf Fortress, and Satisfactory's wiki | Their wikis |
| **structure** | ARK, Don't Starve Together | Their wikis |
| **object** | The Sims 4, for a thing in the catalogue and in the world alike. Roblox's own placement tutorials on the developer forum say "objects" too | The Sims wiki; two forum tutorials |
| **entity** | Factorio: "nearly everything on the map except tiles" | Factorio's official prototype documentation |
| **buildable** | Satisfactory, in its code | Its modding documentation |
| **piece** | Valheim: "anything that can be built in the game" | The Jotunn modding documentation. The game's own wiki refused the fetch |
| **deployable** | Rust, as the common word. In Don't Starve the item that puts a structure down is the deployable | Modding forums, not official pages |
| **block**, **tile** | Minecraft; Terraria. Two Roblox games, Islands and Build A Boat, say "blocks" | Their wikis; search summaries for the Roblox two |
| **furniture** | Animal Crossing, Restaurant Tycoon 2 | Nookipedia; the game's update log |
| **big craftable** | Stardew Valley, for a machine such as a keg | A search summary of its modding wiki |

Roblox itself has no word for it. A thing with a place in the 3D world is a `PVInstance`, in practice a `Model` or a part, and a thing a player carries is a `Tool`. The documentation gives no way from one to the other.

Welcome to Bloxburg, Lumber Tycoon 2, Retail Tycoon 2 and Theme Park Tycoon 2 use no one word that the readers could find: "items", or the name of each thing.

## Which games keep the two apart, and how they are joined
| Game | Two definitions? | What joins them |
|---|---|---|
| **Factorio** | Yes: an item prototype and an entity prototype | The item names the entity it builds (`place_result`). The entity names the item it gives back when mined (`minable.result`) |
| **Minecraft** | Yes: an item and a block | The item that places a block holds a reference to it. Not every block has an item |
| **Satisfactory** | Yes | A third thing, a descriptor, names the buildable |
| **Don't Starve Together** | Yes: two prefabs | The item has a part, Deployable, that makes the structure appear |
| **Rust** | Yes | A part on the item names the placed entity. From plugin code, not official pages |
| **Valheim** | Yes | The tool, not the piece, lists what it can build |
| **Stardew Valley, The Sims 4, Animal Crossing** | No: one thing, carried or placed | Nothing to join |

In every game that keeps them apart, the join is written on one side or the other, most often on the item. None was found that keeps it wholly outside both, which is what the user asked for here.

## What follows for this game
- The user's own two candidates are both in use: "structure" in two survival games, and "object" in The Sims and in Roblox's tutorials.
- "Building" is the commonest word, and says a house more than a crate.
- Factorio is the nearest thing to what the user described: two definitions that are whole without each other, and one line in each that points across. Here that line would sit in a third place.
