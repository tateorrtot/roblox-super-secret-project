# Modifiers — addon spec

Oct 23, 2026 · @Tate

## What it is and why it exists

Modifiers layers removable changes onto any object's real properties. Changes can be any type, apply in order, and come off exactly.

It exists because many independent things change the same properties, overlap, and end in any order without knowing about each other: a potion raising damage, a slow on the motor's speed, a roguelite upgrade, a "Cursed " prefix on an item's name, an `on_fire` tag. Whatever combination is active, the property shows the right result, and removing any one leaves the right result. Changes can live as `.tres` data instead of code.

It replaces attribute maps and `FoxModifiableStat`. `FoxStatPool` and `FoxBoundedValue` move into a separate Pool node.

## Name

**Modifiers**, with `ModifierStack` as the main node. "Modifier" is the established word for an ordered, non-destructive, removable change: Blender's modifier stack, Minecraft's attribute modifiers, and GAS's modifiers. "Stack" says the order matters.

| Rejected name | Why |
| --- | --- |
| Rule | Sounds like a condition or law |
| Attribute | Implies numbers-only stats, and Godot's word is "property" |
| Layers | Collides with Godot's collision and render layers |
| Buff | Genre-specific |

Class names follow Godot's conventions: singular nouns (`RemoteModifierStack`, like `RemoteTransform3D`), and subclass families named base-first (`ModifierAdd`, like `AudioEffectReverb`).

## Design decisions

| Decision | Why |
| --- | --- |
| Results written into the real property | Reads are free, typed, and autocomplete, and every other system works unchanged |
| Every recompute starts from the stored base | Removal is exact for any type, in any order, with no undo code |
| Modifiers are Resources | Usable as `.tres` files, editable in the inspector, and safe to share because they're stateless |
| `add_modifier` returns the applied copy | You remove exactly what you added, and two copies of one `.tres` stay separate |
| Labels | Bulk removal, like node groups |
| `priority` defaults to 0 | Untouched, it's plain array order. You opt in only when independent sources mix. |
| `property` is a NodePath | Property addressing like AnimationPlayer tracks and `Tween.tween_property`, so one stack reaches its child nodes |
| Tags live in the stack, not in metadata | Metadata names must be valid identifiers, so dotted tags like `status.debuff.poison` can't be metadata |
| `RemoteModifierStack` | The RemoteTransform3D pattern: explicit, one target, visible in the inspector |
| A Node plus a RefCounted version | The Node for scenes, the RefCounted for objects outside the tree, like inventory items |
| No lookup helpers like `of()` | Exported references plus configuration warnings, which is how Godot injects dependencies |

## Structure

One repo, one addon folder, four classes plus five built-in modifiers.

```
modifiers/                        (repo)
├─ addons/modifiers/
│  ├─ modifier.gd                 Modifier             (Resource)
│  ├─ modifier_stack.gd           ModifierStack        (Node)
│  ├─ object_modifier_stack.gd    ObjectModifierStack  (RefCounted)
│  ├─ remote_modifier_stack.gd    RemoteModifierStack  (Node)
│  ├─ built_in/                   ModifierAdd, ModifierMultiply, ModifierSet, ModifierClamp, ModifierTag
│  └─ icons/
├─ demos/
└─ README.md
```

Example scene, where a player's held gun receives weapon modifiers:

```
Player
├─ ModifierStack            target: Player
├─ RemoteModifierStack      remote_path set by the equip script, labels: [weapon]
├─ Motor                    speed (modifiers target "Motor:speed")
├─ Health                   a Pool node (modifiers target "Health:max_value")
└─ Hand/Gun
   └─ ModifierStack         target: Gun, receives the pushed weapon modifiers
```

## API

Signatures only. Names are placeholders until the prefix is decided.

```gdscript
@abstract
class_name Modifier extends Resource
## Changes one property's value. Value in, value out, any type. Must not cause side effects.
@export var property: NodePath            # "damage", "Motor:speed" (unused by ModifierTag)
@export var priority := 0                 # lower runs first; ties run in the order added
@export var labels: Array[StringName]
@export var create_if_missing := false    # creates a metadata key while active (identifier names only)
@export var enabled := true
@abstract func _modify(value: Variant, read: Callable) -> Variant

# Built-ins, all priority 0 by default
class_name ModifierAdd       # @export var amount: float
class_name ModifierMultiply  # @export var factor: float
class_name ModifierSet       # @export var value: Variant
class_name ModifierClamp     # @export var min_value: float, max_value: float
class_name ModifierTag       # @export var tag: StringName (adds a counted tag to the stack)


class_name ModifierStack extends Node
## Applies modifiers to its target's properties and holds its tags.
@export var target: Node                  # defaults to the parent
@export var modifiers: Array[Modifier]    # applied from the start
signal value_changed(property: NodePath, old: Variant, new: Variant)
signal tag_added(tag: StringName)         # count went from 0 to 1
signal tag_removed(tag: StringName)       # count went from 1 to 0
func add_modifier(modifier: Modifier) -> Modifier    # returns the applied copy
func remove_modifier(applied: Modifier) -> void
func remove_modifiers(label: StringName) -> void
func get_modifiers(label: StringName = &"") -> Array[Modifier]
func has_modifiers(label: StringName) -> bool
func has_tag(tag: StringName) -> bool              # "status.debuff" matches "status.debuff.poison"
func get_tag_count(tag: StringName) -> int
func set_base(property: NodePath, value: Variant) -> void
func get_base(property: NodePath) -> Variant
func get_steps(property: NodePath) -> Array
func force_update() -> void


class_name ObjectModifierStack extends RefCounted
## The same logic for objects outside the tree, like inventory items.
func _init(target: Object) -> void
# + every ModifierStack method and signal


class_name RemoteModifierStack extends Node
## Pushes its parent stack's modifiers into the stack at remote_path.
@export var remote_path: NodePath
@export var labels: Array[StringName]     # which to push; empty = all
```

`ModifierStack` and `RemoteModifierStack` show a configuration warning when their target or path isn't set.

## Tags

Tags are counted labels the stack holds while a `ModifierTag` is active. Two sources of `on_fire` give a count of 2, and removing one leaves the tag on.

- **Hierarchical:** dotted names. `has_tag(&"status.debuff")` is true while `status.debuff.poison` is active.
- **Stored in the stack:** never on the object as metadata, because metadata names must be valid identifiers.
- **Reacting:** `tag_added` and `tag_removed` fire when a count crosses between 0 and 1.
- **A tag that needs a value** (intensity, source) is data, not a tag. Make it a property that modifiers change.

**Optional later: Tag resources.** A `Tag` resource wraps the same StringName with `display_name`, `icon`, and `color`. You pick it from a file in the inspector, which gives typo safety and status-bar icons. Internally it's still the StringName, so there's one tag system, not two.

## How a value is computed

1. **Base capture.** The first modifier on a property captures its current value as the base. For `create_if_missing`, the base is "didn't exist."
2. **The result.** The base runs through the enabled modifiers, sorted by priority, with ties broken by the order they were added.
3. **Write-back.** The result is written into the property, or into metadata for created keys.
4. **Last removal.** When the last modifier is removed, the base is written back, or the created key is erased.
5. **Outside writes.** A direct write from outside is adopted as the new base, with a warning in debug builds.
6. **Read tracking.** Values a modifier reads through `read()` are tracked automatically. The node checks them once per frame. The RefCounted version has no frame loop, so its owner calls `force_update()`.
7. **Caching.** Each step's result is cached, so a change at step *n* recomputes only from step *n* onward.

## Rules of use

- **Modify caps, not spent values.** Target `max_value`, not the current `value`. Damage and healing change the current value directly, so they never fight the stack.
- **Keep modifiers pure.** A modifier only calculates and returns. Sounds, particles, and damage belong in effects.
- **Leave `priority` at 0** unless independent sources must always run in a set order, like adds before multiplies.
- **Permanent changes to a layered property go through `set_base`.** Direct writes still work, but they're adopted as the new base with a debug warning.
- **`create_if_missing` keys must be valid identifiers,** since they're stored as metadata.

## Open decisions

- [ ] **Prefix.** `Modifier` is generic enough to collide with classes in users' games.
- [ ] **Tag resources.** Build them now, or add them later as an optional wrapper.
- [ ] **Effects.** Being rethought next. They need per-instance state and modifiers that can change mid-life, like RimWorld hediff stages.
- [ ] **Pool node.** Its own small addon, replacing `FoxStatPool` and `FoxBoundedValue`.
