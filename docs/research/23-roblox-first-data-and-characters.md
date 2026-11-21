# Attributes, tags, saved data, and character control: what Roblox already has
Asked: what Roblox provides for instance attributes, tags, saved data, character controllers, and NPC pathfinding.
Read by one reader on Sonnet, on 2026-11-21. Each fact has its address beside it, relative to https://create.roblox.com/docs/.

## What Roblox has

### Attributes (`Instance:SetAttribute`)
- `SetAttribute(name, value)` sets one. `GetAttribute(name)` returns the value, or `nil`. Setting `nil` removes it. (reference/engine/classes/Instance.md)
- Value types: string, boolean, number, `UDim`, `UDim2`, `BrickColor`, `Color3`, `Vector2`, `Vector3`, `CFrame`, `NumberSequence`, `ColorSequence`, `NumberRange`, `Rect`, `Font`. (studio/properties.md)
- An unsupported type throws an error. (reference/engine/classes/Instance.md)
- Names may hold letters, numbers, periods, hyphens, slashes, underscores. A name may not start with "RBX" unless the caller is a Roblox core script. (reference/engine/classes/Instance.md)
- Strings are limited to 100 characters. (reference/engine/classes/Instance.md)
- Change signals: `Instance.AttributeChanged` passes the name. `Instance:GetAttributeChangedSignal(name)` fires for one name and returns the same signal on each call. Both fire when the value is set to `nil`. (reference/engine/classes/Instance.md)
- Attribute values replicate, so clients can read them at once. Attributes are saved with the place. (studio/properties.md)

### Tags (`CollectionService`)
- Tags are a set of strings per instance. The same tag cannot be held twice. A second `AddTag` does nothing. Tags are not counted. (reference/engine/classes/CollectionService.md)
- `AddTag`, `RemoveTag`, `HasTag`, `GetTags` exist on `CollectionService`. `AddTag`, `RemoveTag`, `HasTag` also exist on `Instance`. (same page)
- `GetTagged(tag)` returns tagged instances that are descendants of the DataModel. Instances with a `nil` parent are excluded. (same page)
- `GetInstanceAddedSignal(tag)` fires when the tag is added, or when a tagged instance enters the DataModel. `GetInstanceRemovedSignal(tag)` fires when the tag is removed, or when a tagged instance leaves the DataModel. Neither fires for instances already present, so `GetTagged` is used alongside. (same page)
- `TagAdded` and `TagRemoved` fire once per tag, when it first comes into use or last goes out of use. They fire deferred. (same page)
- All tags of an instance replicate together. A client's tag change is overwritten when the server later changes a different tag on that instance. With `StreamingEnabled`, an instance that streams back in re-syncs its tags from the server. (same page)

### Data stores (`DataStoreService`)
- Limits (cloud-services/data-stores/error-codes-and-limits.md):
  - Data store name, key name, scope: 50 characters each.
  - Value: 4,194,304 per key (unit not stated on the page text read).
  - Metadata value: 250 characters. Metadata key-value pairs: 300 characters in total.
  - Per-key throughput over a rolling 60 seconds: read 25 MB, write 4 MB. Throughput is rounded up to the next kilobyte per request.
  - Experience requests per minute, standard store: read 300 + concurrentUsers x 40, write 300 + concurrentUsers x 20, list 300 + concurrentUsers x 2, remove 300 + concurrentUsers x 40.
  - Server requests per minute, standard store: read 60 + numPlayers x 40, write 60 + numPlayers x 40, list 5 + numPlayers x 2, remove 60 + numPlayers x 40.
  - Each queue holds 30 requests. Maximum JSON nesting depth: 400.
  - Storage for latest versions: 500 MB + 1 MB x lifetime user count.
- `UpdateAsync` (reference/engine/classes/GlobalDataStore.md):
  - Reads the current value and `DataStoreKeyInfo`, then writes what the callback returns.
  - If the callback returns `nil`, the write is cancelled.
  - The callback cannot yield.
  - If another server changed the key in between, the callback runs again with the new value.
  - It counts against both the read and write limits.
  - Metadata and UserIds not returned from the callback are cleared.
- `SetAsync` writes without reading and counts only against write limits. Two servers writing one key at once can give inconsistent data. It returns a version identifier. (same page)
- Stored strings must be valid UTF-8. (same page)
- Versions (cloud-services/data-stores/versioning-listing-and-caching.md):
  - `GetVersionAsync` reads a version by number. `ListVersionsAsync` lists versions, filterable by time range.
  - A backup expires 30 days after a new write overwrites it. The latest version never expires.
  - `GetAsync` values are cached locally for four seconds by default.
- `RemoveAsync` removes a key and keeps an accessible version. (reference/engine/classes/DataStore.md)
- Calls are network requests that can fail. The guide says to wrap them in `pcall`. (cloud-services/data-stores.md)
- The best-practices page advises: load at session start, keep a server-local copy, save periodically, on leave, on server shutdown, and at critical points. It gives 180 seconds as the interval in its sample. It advises `UpdateAsync` over `SetAsync` when a write depends on the current value, and advises versions over a new key per revision. (cloud-services/data-stores/best-practices.md)

### Character controller (`ControllerManager`)
- `ControllerManager` manages simulated motion for its `RootPart` and can be used to build a physics-based character controller. (reference/engine/classes/ControllerManager.md)
- Properties: `ActiveController`, `BaseMoveSpeed`, `BaseTurnSpeed`, `ClimbSensor`, `GroundSensor`, `FacingDirection`, `MovingDirection`, `RootPart`, `UpDirection`. One controller is active at a time. (same page)
- `GroundController` is active on the ground. It holds the root part at `GroundOffset` above the floor, ramps with `AccelerationTime` and `DecelerationTime`, and applies friction. (reference/engine/classes/GroundController.md)
- `AirController` is active while airborne. It keeps the character upright, turns it toward `FacingDirection`, and moves it toward `MovingDirection`. It works only when parented to a `ControllerManager`. (reference/engine/classes/AirController.md)
- `ClimbController` works with a `ClimbSensor` in Ladder mode. (physics/character-controllers.md)
- `ControllerPartSensor` finds floors and ladders with the same code `Humanoid` uses. (physics/character-controllers.md)
- A `Humanoid` character typically assigns `Humanoid.RootPart` as `ControllerManager.RootPart`. (reference/engine/classes/ControllerManager.md)
- Roblox names a "Character Controller Library" (CCL). It is a beta feature, enabled in File > Beta Features > "AvatarAbilities Character Controller Library". Abilities are Luau tables with start and run conditions, conflict rules, input, and callbacks. Abilities register on the server and run on both the predicted client and the server, so they must be deterministic and must not yield. Running, Jumping, and Climbing are on by default. The page says it is designed to replace the `Humanoid` state machines. (characters/character-controller-library.md)

### Pathfinding (`PathfindingService`)
- It finds a route around obstacles for an agent such as an NPC. (characters/pathfinding.md)
- `CreatePath()` takes `AgentRadius` (default 2), `AgentHeight` (5), `AgentCanJump` (true), `AgentCanClimb` (false), `WaypointSpacing` (4), `Costs`. `ComputeAsync()` then `GetWaypoints()` give waypoints with `Position`, `Action`, `Label`. (same page)
- `Costs` sets a cost per material. `math.huge` makes a material impassable. `PathfindingModifier` sets a cost on a region. `PathfindingLink` joins two attachments across a gap. (same page)
- `Path.Blocked` fires when a route is blocked. (same page)
- Limits: straight-line distance 3,000 studs, about 20,000 nodes per computation, waypoints beyond +/-65,536 studs vertically are ignored. (same page)

## What it does not do
- Attributes: the pages read give no limit on attribute count or name length. Not found.
- Tags: the page gives no limit on tags per instance, tag length, or tags per place. Not found. Tags carry no count and no value.
- Data stores:
  - No page read describes session locking. The best-practices page mentions a "session-lock expiration" without saying who provides it. (cloud-services/data-stores/best-practices.md)
  - No page read describes migration of an old saved format. It covers only moving off the DataStore2 pattern. (same page)
  - `UpdateAsync` conflict handling covers writes between servers on one key. It does not tie a key to one server for a session. (reference/engine/classes/GlobalDataStore.md)
  - The pages read do not list which Luau types can be stored. Not found.
- Pathfinding: the page describes moving a `Humanoid` with `Humanoid:Move()` per waypoint. `PathfindingService` returns waypoints only and does not move anything itself. (characters/pathfinding.md)
- Client scripts may fail to path to instances not yet streamed in. (same page)
- `ControllerManager`: the class page states no release status and no replacement of `Humanoid`. Not found.
- CCL: `OnUpdate` does not run in a parallel context yet. Input cannot appear in `StartsWhen` or `RunsWhile`. (characters/character-controller-library.md)

## What a game must still build
- A stored-format version field, and the code that upgrades old saved values.
- Any lock that stops two servers holding one player's data at once.
- Anything that groups a player's data across several keys.
- Movement along a path, using the waypoints.
- Any count on a tag, or a value on a tag.

## Sources
- https://create.roblox.com/docs/reference/engine/classes/Instance.md
- https://create.roblox.com/docs/studio/properties.md
- https://create.roblox.com/docs/reference/engine/classes/CollectionService.md
- https://create.roblox.com/docs/cloud-services/data-stores.md
- https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits.md
- https://create.roblox.com/docs/cloud-services/data-stores/versioning-listing-and-caching.md
- https://create.roblox.com/docs/cloud-services/data-stores/best-practices.md
- https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore.md
- https://create.roblox.com/docs/reference/engine/classes/DataStore.md
- https://create.roblox.com/docs/physics/character-controllers.md
- https://create.roblox.com/docs/reference/engine/classes/ControllerManager.md
- https://create.roblox.com/docs/reference/engine/classes/GroundController.md
- https://create.roblox.com/docs/reference/engine/classes/AirController.md
- https://create.roblox.com/docs/characters/character-controller-library.md
- https://create.roblox.com/docs/characters/pathfinding.md
- https://create.roblox.com/docs/llms.txt

## Checked by a second reader
- Claims checked: 24, against the same pages the brief cites, fetched as .md on 2026-11-21.
- Wrong: 1.
- Unconfirmed: 5.

### Wrong
- Brief (data stores, Value): "4,194,304 per key (unit not stated on the page text read)."
  - Source: the table is headed "Maximum number of characters", and the row reads `Data (key value) | 4,194,304 per key`. The unit is characters. The page adds that the value is stored as a string whatever its type.
  - https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits.md

### Unconfirmed
- Attribute value types (brief lists 15, citing studio/properties.md). The page says "You can store the following types/values in attributes" and names string, boolean, number and several datatypes. A reader could not confirm every one of the 15 (`NumberSequence`, `ColorSequence`, `NumberRange`, `Rect`, `UDim`, `BrickColor` were not seen). `Instance.md` gives no list. https://create.roblox.com/docs/studio/properties.md
- "Strings are limited to 100 characters" for attributes. `Instance.md` has the line "Strings must be 100 characters or less" inside the list of attribute name rules. It does not say whether it limits names, string values, or both. The brief states it as a limit on strings in general. https://create.roblox.com/docs/reference/engine/classes/Instance.md
- "Tags are not counted." No page says this. It is the brief's reading of the set behaviour. The page says `AddTag` does nothing if the tag is already applied. https://create.roblox.com/docs/reference/engine/classes/CollectionService.md
- `UpdateAsync` clears "Metadata and UserIds" not returned. The page text read says only that existing metadata is cleared; `UserIds` were not seen. https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore.md
- `SetAsync` "returns a version identifier" and "counts only against write limits". Not found in the text read of `GlobalDataStore.md`.

### Confirmed (no difference from the source)
- `SetAttribute`/`GetAttribute` nil behaviour; unsupported type throws; name characters and the "RBX" prefix rule; `AttributeChanged` and `GetAttributeChangedSignal` including firing on `nil`, and the same signal returned on each call.
- Attributes replicate to clients and are saved with the place (studio/properties.md).
- `CollectionService`: `GetTagged` excludes instances outside the DataModel; added/removed signals do not fire for instances already present; `TagAdded`/`TagRemoved` fire once per tag lifetime and deferred; all tags replicate together and a server change overwrites a client's.
- Data store limits: name, key, scope 50; metadata 250 and 300; per-key throughput 25 MB read and 4 MB write; the experience and server request formulas for standard stores; queue 30; nesting 400; storage 500 MB + 1 MB x lifetime users.
- `UpdateAsync`: nil cancels, cannot yield, reruns on conflict, counts against read and write. `SetAsync` can give inconsistent data across servers. Strings must be valid UTF-8.
- Versions: backup expires 30 days after overwrite; latest never expires; `GetAsync` cache is four seconds. `RemoveAsync` retains an accessible version.
- Best practices: 180 seconds is the sample's interval; session-lock expiration is mentioned and not defined; `UpdateAsync` advised over `SetAsync` for dependent writes; versions over new keys. The page does not mention `BindToClose`, so the brief's "on server shutdown" is the page's wording only.
- `ControllerManager` properties, `RootPart` with a `Humanoid` character, and no status note on the page. `GroundController` `GroundOffset`, `AccelerationTime`, `DecelerationTime`, friction. `AirController` uprights, faces `FacingDirection`, moves toward `MovingDirection`, works only under a `ControllerManager`.
- `ControllerPartSensor` runs the `Humanoid` floor and ladder code (physics/character-controllers.md).
- CCL: beta, enabled in File > Beta Features; abilities are Luau tables; registered on the server, run on predicted client and server; deterministic, no yielding; Running, Jumping, Climbing on by default; `OnUpdate` not parallel; input not allowed in `StartsWhen`/`RunsWhile`. The page says the architecture "replaces rigid `Humanoid` state machines". The brief's "designed to replace" is a paraphrase.
- Pathfinding: `CreatePath` defaults; 3,000 stud line-of-sight; 20,000 nodes; +/-65,536 stud vertical cut; `Costs` default 1 and `math.huge`; `PathfindingModifier`; `PathfindingLink`; `Path.Blocked`; client streaming caveat. The `Humanoid:Move()` per-waypoint statement was not rechecked.
