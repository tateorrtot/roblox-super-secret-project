# The consistency rule

The user's requirement that the game has one way of doing each thing: everything is an item, and there are two actions.

> keep it consistent. a player only has so much brain capacity. if you overload it with these weird conflicting systems that sound good on paper its confusing. minecraft has: left click to place/interact. right click to swing or break. then WASD/jump/crouch/sprint. everything can be an item and lots of things can be placed as blocks. all items can be dropped on the floor as an entitty

- **One rule for things, as in Minecraft: everything is an item.** The user rejected Claude's split between "inventory items" and "big placed objects" as inconsistent ("what about entire trees full of logs! or huge chunks of rock! or massive hauls of fish!").
- **Two actions:** one to use, place or interact, and one to hit or break. Plus movement.
- Before adding any system, ask whether it is a second way of doing something the player already knows how to do. If so, fold it into the existing one.

Claude's restatement of the inventory under that rule (awaiting the user's yes):
1. Everything is an item, including a machine, a crate and a vehicle.
2. Items sit in slots and stack up to that item's stack size.
3. Any item can be dropped on the ground.
4. An item that can be placed becomes a thing in the world when placed, and becomes an item again when broken or picked up. A crate keeps its contents. (The user, 2026-11-20: what breaking leaves is for each kind to say. A broken crate spills what is in it; a sack would keep it.)
5. A container is a placed object with slots. What else a placed object does is its own business, in the user's later words (`placed-objects.md`). Claude had written "a station is a container with a process", which cast a general kind from one example.
6. Stack size is the one knob that makes hauling matter: bulky things stack small (a machine stacks to one), and the player's own pack is small, so a truck with crates carries far more.
