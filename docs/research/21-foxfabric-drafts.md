# The user's drafts for FoxFabric's next addons

The user sent these on 2026-11-21: "I attached some of the core things I was going to have in foxfabric that may be useful. Theyre in VERY rough state though - drafts made by AI agents." They are for Godot. The spec they attached is beside this file, as `21-foxfabric-modifiers-spec.md`. The two summaries below are as they pasted them, and were written by another assistant: its lines on what Roblox already has are not checked.

## First summary: the core addons

Here's the core idea of each. Modifier Stack has the most detail because it's the only one with a written spec (your Modifiers doc).

Modifier Stack (replaces Attribute Map)
The idea is that many independent things change the same property (a potion, a slow, an upgrade, a "Cursed " name prefix) and end in any order without knowing about each other. Whatever combination is active, the property shows the right result.

* A modifier is a tiny stateless Resource. It takes a value in and returns a value out, of any type, with no side effects. The built-ins are Add, Multiply, Set, Clamp and Tag.
* The stack works from a stored base. The first time a property gets modified, the stack saves its current value as the base. Every recompute runs the base through the modifiers in priority order (default 0, which means the order they were added) and writes the result into the real property. Other code just reads `speed` like normal.
* Removal is exact. Since it always recomputes from the base, there's no undo code. When the last modifier comes off, the base is restored.
* Removing what you added. `add_modifier` returns the applied copy, and you pass that copy back to remove it. Labels handle bulk removal, like "remove all weapon modifiers."
* Tags are counted and hierarchical. Two sources of `on_fire` give a count of 2, so removing one leaves the tag on. `status.debuff` matches `status.debuff.poison`.
* RemoteModifierStack pushes modifiers into another stack, like a player passing weapon modifiers to the gun they're holding.
* Rules of use: modify caps like `max_value`, never spent values like current health, and keep modifiers pure.

Pool (replaces FoxStatPool and FoxBoundedValue)
A current value between bounds, like health, stamina or ammo. Damage and healing change the value directly, and modifiers only touch the max, so the two never fight.

Effects (never actually designed)
Only the requirements were settled before it was parked until Modifier Stack exists:

* Effects are where side effects live: damage over time, sounds, particles.
* An effect has per-instance state (time left, stacks).
* An effect adds modifiers while active and can change them mid-life, like RimWorld hediff stages.
* Minecraft potions were the reference for how effects stack.

State Machine (explicit transitions)

* States are child nodes, and only the active one runs.
* You switch by setting `current_state`, or a state emits `transition_requested(name)`. Each switch runs old exit, then new enter, then the `state_changed` announcement.
* Requests from inactive states are ignored.
* If a state redirects inside its own enter, only the final switch is announced.
* Switching from inside an exit is refused; use a deferred switch instead.
* It's for sequences: match flow, combos, boss phases, menus.

Priority State Machine (not drafted yet)

* Nobody requests switches. Every frame, each state answers "do I want control?" (this defaults to yes), and the first one in child order that does is active. If none want control, no state is active.
* It's for reactive things: movement modes (Swim > Air > Ground), AI, cameras.
* Flicker gotcha: a state can toggle on and off rapidly at a boundary. Fix it with hysteresis (different thresholds for taking and releasing control).
* Commitment gotcha: an attack has to keep wanting control until its swing ends. The attack can nest an explicit State Machine for its own phases.

For the Roblox port: the ideas carry over, but the Godot plumbing doesn't. Resources and `.tres` files become ModuleScripts or tables. Roblox's native Attributes are the natural thing for modifiers to write into. Roblox's built-in tags aren't counted, so you'd still need the counting on top.

## Second summary: the modules to migrate, and what is planned

Existing modules, mostly straight migrations

* Hit Pipeline (old `damage`): hit sources (an area, a raycast or a shapecast) deliver a payload to hurt areas, and the hurt area routes it onward. The core idea is that neither side knows what "damage" is. The payload is whatever the game says it is, and the receiver decides what it means. An old TODO also wanted the payload typed per project instead of a generic Variant. Projectiles and ballistics stay out of it.
* Interaction Pipeline: a raycast that tracks what it's pointing at (focus gained and lost), plus interactable areas that respond when you interact with them.
* Shop: wallets, prices and catalogs. The core idea is that a price decides for itself whether a wallet can pay, so multiple currencies or barter work without the shop knowing. A catalog item pairs what the player sees with what they get. Simple `int` versions plus the menu and slot UI come with it.
* Save File (old `json`): converts Godot types to JSON and back. A file is stamped with its format version, and an older file migrates forward when it's read. Writes are all-or-nothing, so a crash can't half-write a save.
* Socket: named seats, one occupant each. Attaching reparents the node and snaps it to the marker. A socket map keys them by name, like "hand_r" or "back".
* Physics Dragger: pulls a RigidBody toward the dragger's position and rotation using forces and torque, so carried objects still collide. Stiffness and damping live in a profile resource.
* Camera Rig: I believe this was the old `aim_gimbal` plus `zoom_spring_arm`. The gimbal turns mouse or stick input into clamped pitch and yaw on separate nodes. The spring arm eases to a new length between a min and max instead of snapping.

`view_model` and `world_environments` weren't on the migration list, and I don't have a record of why.

Planned, not built yet

* Character template: decoupled movement modes driven by the Priority State Machine (covered in my last message). Beyond that:
   * Abilities come in three kinds: one-shots (jump), high-priority temporary modes (dash), or modifiers on a mode (sprint).
   * Controllers (player or AI) only produce intents, like "move this way" or "jump".
   * AnimationTree reads the mode changes and the velocity.
   * It's a template project, not an addon.
* Inventory and Hotbar:
   * Item is a Resource.
   * Slot is a Resource that you can subclass.
   * Inventory has a swappable capacity rule.
   * The hotbar holds references to slots, not items.
* Others with no design yet: Water and buoyancy, vehicles (an old list had planes, boats, tanks and so on), projectiles, a multiplayer test gym, and a docs site.

Roblox already has some of these:

* Interaction: ProximityPrompt covers most of it.
* Physics Dragger: DragDetector does this.
* Socket: Attachments and welds cover it.
* Save File: DataStore replaces the JSON part. The versioned-migration idea is still worth keeping.
* Character template: check the Character Controller Library first, as before.

The ideas worth porting as-is are the Hit Pipeline's "payload is the game's business", the Shop's "price decides if a wallet can pay", and Modifier Stack.
