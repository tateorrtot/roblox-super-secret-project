--!strict
--- The stacks of items loose in the world of one running game: lying on the ground, or flying
--- towards it.
---
--- A ground item is a stack, its position, the velocity it was spawned with, and the time it was
--- spawned. `spawnStack` adds one. Nothing here moves a ground item: `setItemPosition` records
--- where a ground item has got to. `mergeItems` makes ground items of the same item that lie close
--- together into one. `getIdsInPickupReach` returns the ids of the ground items in pickup reach of
--- a position. `takeFromItem` takes some of a ground item's stack and leaves the rest where it
--- lies, and `removeItem` removes a whole ground item. `removeExpiredItems` removes the ground
--- items that have been out too long. `spawnStack` numbers ground items from `1` in the order it
--- adds them, and never uses an id twice. A time is a number of seconds, passed in as `now`, from
--- any clock that only goes forward. Positions and distances are in studs. Ground items are never
--- saved.
local ItemStack = require("../items/ItemStack")
local Position = require("../Position")

local GroundItems = {}

type ItemStack = ItemStack.ItemStack

--- A point in the world, in studs.
export type Position = Position.Position

--- How fast a thing moves along each axis, in studs a second. `y` is upwards.
export type Velocity = { read x: number, read y: number, read z: number }

--- A stack loose in the world. A ground item never changes: `setItemPosition`, `takeFromItem`, and
--- `mergeItems` each replace one with a new ground item under the same id.
export type GroundItem = {
	--- The items that the ground item holds.
	read stack: ItemStack,
	--- The ground item's position: the middle of its underside.
	read position: Position,
	--- The velocity that the ground item was spawned with. `setItemPosition` does not change it.
	read spawnVelocity: Velocity,
	--- The time that the ground item was spawned, in seconds. When `mergeItems` merges another
	--- ground item into it, `spawnTime` becomes the later of the two ground items' times.
	read spawnTime: number,
}

--- Every ground item in one running game.
export type GroundItems = {
	--- The id that `spawnStack` gives the next ground item.
	nextId: number,
	--- Every ground item, by id. An id with no entry is not in the world.
	--- Note: the ids stop being consecutive once a ground item leaves the world, so `#itemsById` is
	--- not the number of ground items.
	itemsById: { [number]: GroundItem },
	--- The id of each ground item that `spawnStack` or `setItemPosition` has changed since
	--- `mergeItems` last ran. An id may be listed after its ground item has gone.
	idsMovedSinceMerge: { [number]: true },
	--- The `now` that `mergeItems` last received. `nil` until `mergeItems` has run.
	lastMergeTime: number?,
}

--- The time that a ground item lasts, in seconds: `removeExpiredItems` removes a ground item
--- spawned this long before `now`.
GroundItems.LIFETIME_SECONDS = 300

--- The time after a ground item's spawn time during which `getIdsInPickupReach` leaves the ground
--- item out, in seconds.
GroundItems.PICKUP_DELAY_SECONDS = 1.5

--- The greatest distance, along the ground, between a position and a ground item that is in pickup
--- reach of it, in studs.
GroundItems.PICKUP_RADIUS = 4

--- The greatest height of a ground item above a position at which it is in pickup reach of the
--- position, in studs.
GroundItems.PICKUP_REACH_UP = 7

--- The greatest depth of a ground item below a position at which it is in pickup reach of the
--- position, in studs.
GroundItems.PICKUP_REACH_DOWN = 2

--- The width, depth, and height of a ground item, in studs: a ground item fills a cube this wide,
--- standing on its `position`.
GroundItems.ITEM_WIDTH = 1.2

--- The distance within which `mergeItems` merges two ground items of the same item, in studs: their
--- positions are less than `MERGE_REACH` apart along x, less than `MERGE_REACH` apart along z, and
--- less than `ITEM_WIDTH` apart in height.
GroundItems.MERGE_REACH = 2 + GroundItems.ITEM_WIDTH

--- The time between one merge check of a ground item and the next, in seconds, while
--- `setItemPosition` does not move the ground item.
GroundItems.MERGE_CHECK_SECONDS = 2

local function isInMergeReach(from: Position, to: Position): boolean
	return math.abs(to.x - from.x) < GroundItems.MERGE_REACH
		and math.abs(to.z - from.z) < GroundItems.MERGE_REACH
		and math.abs(to.y - from.y) < GroundItems.ITEM_WIDTH
end

local function isInPickupReach(from: Position, to: Position): boolean
	local height = to.y - from.y
	return Position.getGroundDistance(from, to) <= GroundItems.PICKUP_RADIUS
		and height <= GroundItems.PICKUP_REACH_UP
		and height >= -GroundItems.PICKUP_REACH_DOWN
end

local function idsNearestFirst(
	groundItems: GroundItems,
	position: Position,
	isInReach: (from: Position, to: Position) -> boolean
): { number }
	local distances: { [number]: number } = {}
	local ids: { number } = {}
	for id, groundItem in groundItems.itemsById do
		if isInReach(position, groundItem.position) then
			distances[id] = Position.getDistance(position, groundItem.position)
			table.insert(ids, id)
		end
	end
	table.sort(ids, function(a: number, b: number): boolean
		return distances[a] < distances[b] or (distances[a] == distances[b] and a < b)
	end)
	return ids
end

--- Returns a new `GroundItems` that holds no ground items.
function GroundItems.new(): GroundItems
	return { nextId = 1, itemsById = {}, idsMovedSinceMerge = {} }
end

--- Adds a ground item that holds `stack` at `position`. Its spawn velocity is `velocity`, and its
--- spawn time is `now`. Returns the ground item's id.
--- Note: `spawnStack` takes `stack` from nowhere, so the items of `stack` exist twice if they are
--- also left where they were.
function GroundItems.spawnStack(
	groundItems: GroundItems,
	stack: ItemStack,
	position: Position,
	velocity: Velocity,
	now: number
): number
	local id = groundItems.nextId
	groundItems.itemsById[id] = table.freeze({
		stack = stack,
		position = Position.new(position.x, position.y, position.z),
		spawnVelocity = table.freeze({ x = velocity.x, y = velocity.y, z = velocity.z }),
		spawnTime = now,
	})
	groundItems.nextId = id + 1
	groundItems.idsMovedSinceMerge[id] = true
	return id
end

--- Sets the position of the ground item `id` to `position`, and keeps its stack, spawn velocity,
--- and spawn time. The ground item gets a merge check the next time `mergeItems` runs. Does nothing
--- if no ground item has that id.
function GroundItems.setItemPosition(groundItems: GroundItems, id: number, position: Position)
	local groundItem = groundItems.itemsById[id]
	if groundItem == nil then
		return
	end
	groundItems.itemsById[id] = table.freeze({
		stack = groundItem.stack,
		position = Position.new(position.x, position.y, position.z),
		spawnVelocity = groundItem.spawnVelocity,
		spawnTime = groundItem.spawnTime,
	})
	groundItems.idsMovedSinceMerge[id] = true
end

local function mergeItemInto(groundItems: GroundItems, fromId: number, intoId: number)
	local from, into = groundItems.itemsById[fromId], groundItems.itemsById[intoId]
	groundItems.itemsById[fromId] = nil
	groundItems.itemsById[intoId] = table.freeze({
		stack = (ItemStack.merge(into.stack, from.stack)),
		position = into.position,
		spawnVelocity = into.spawnVelocity,
		spawnTime = math.max(into.spawnTime, from.spawnTime),
	})
end

local function canMergeStacks(stack: ItemStack, other: ItemStack): boolean
	return ItemStack.isSameItem(stack, other) and ItemStack.getSpaceLeft(other) >= stack.count
end

local function mergeItemWithNearbyItems(groundItems: GroundItems, id: number)
	local position = groundItems.itemsById[id].position
	for _, otherId in idsNearestFirst(groundItems, position, isInMergeReach) do
		local stack, other = groundItems.itemsById[id].stack, groundItems.itemsById[otherId].stack
		local canMerge = otherId ~= id and canMergeStacks(stack, other)
		if canMerge and other.count < stack.count then
			mergeItemInto(groundItems, otherId, id)
		elseif canMerge then
			mergeItemInto(groundItems, id, otherId)
			return
		end
	end
end

local function needsMergeCheck(groundItems: GroundItems, id: number, since: number, now: number): boolean
	local spawnTime = groundItems.itemsById[id].spawnTime
	local checksBySince = math.floor((since - spawnTime) / GroundItems.MERGE_CHECK_SECONDS)
	local checksByNow = math.floor((now - spawnTime) / GroundItems.MERGE_CHECK_SECONDS)
	return groundItems.idsMovedSinceMerge[id] == true or checksByNow > checksBySince
end

--- Merges ground items of the same item that lie within `MERGE_REACH` of each other. Only some
--- ground items get a merge check each time `mergeItems` runs, and `now` decides which.
---
--- A ground item gets a merge check if `spawnStack` or `setItemPosition` has changed it since
--- `mergeItems` last ran, or if another whole `MERGE_CHECK_SECONDS`, counted from its `spawnTime`,
--- has passed since then. `mergeItems` checks them one by one, the lowest id first.
---
--- A merge check tries the ground item with each ground item of the same item in reach of it, the
--- nearest first, and of two equally near, the one with the lower id first. The other ground item
--- need not be one that gets a merge check. Two merge only if both stacks fit in one stack. The one
--- with the bigger stack then holds both, stays where it is, keeps its spawn velocity, and gets the
--- later of the two spawn times. The other goes, and its id with it. If the two stacks are the same
--- size, the ground item being checked goes. A ground item that takes in another is tried with the
--- next nearest, and so on until it goes or no ground item is left to try.
---
--- If `now` is no later than the `now` that `mergeItems` last received, only the ground items that
--- `spawnStack` or `setItemPosition` has changed since then get a merge check.
function GroundItems.mergeItems(groundItems: GroundItems, now: number)
	local since = groundItems.lastMergeTime or now
	local idsToCheck = {}
	for id in groundItems.itemsById do
		if needsMergeCheck(groundItems, id, since, now) then
			table.insert(idsToCheck, id)
		end
	end
	table.sort(idsToCheck)
	table.clear(groundItems.idsMovedSinceMerge)
	groundItems.lastMergeTime = now
	for _, id in idsToCheck do
		if groundItems.itemsById[id] ~= nil then
			mergeItemWithNearbyItems(groundItems, id)
		end
	end
end

--- Removes the ground item `id` from the world and returns its stack. Returns `nil` and changes
--- nothing if no ground item has that id.
function GroundItems.removeItem(groundItems: GroundItems, id: number): ItemStack?
	local groundItem = groundItems.itemsById[id]
	groundItems.itemsById[id] = nil
	return if groundItem then groundItem.stack else nil
end

--- Returns the ids of the ground items in pickup reach of `position` at the time `now`, as a new
--- list: the nearest in a straight line first, and of two equally near, the one with the lower
--- id. A ground item is in pickup reach if it is within `PICKUP_RADIUS` of `position` along the
--- ground, and no more than `PICKUP_REACH_UP` above it or `PICKUP_REACH_DOWN` below it. The list
--- leaves out a ground item spawned less than `PICKUP_DELAY_SECONDS` before `now`.
function GroundItems.getIdsInPickupReach(groundItems: GroundItems, position: Position, now: number): { number }
	local ids = {}
	for _, id in idsNearestFirst(groundItems, position, isInPickupReach) do
		if now - groundItems.itemsById[id].spawnTime >= GroundItems.PICKUP_DELAY_SECONDS then
			table.insert(ids, id)
		end
	end
	return ids
end

--- Takes up to `count` items out of the ground item `id` and returns them as a stack. If `count` is
--- at least the size of the ground item's stack, the ground item leaves the world and the function
--- returns the whole stack. Otherwise the ground item stays where it is under the same id, with its
--- spawn velocity and spawn time, and holds what is left. Returns `nil`, and changes nothing, if
--- `count` is `0`. Raises an error if no ground item has that id. Raises an error, and changes
--- nothing, if `count` is below `0`, or is not a whole number and is below the size of the stack.
function GroundItems.takeFromItem(groundItems: GroundItems, id: number, count: number): ItemStack?
	local groundItem = groundItems.itemsById[id]
	if groundItem == nil then
		error(`no ground item has the id {id}`, 2)
	end
	local stack = groundItem.stack
	if count == 0 then
		return nil
	end
	if count >= stack.count then
		groundItems.itemsById[id] = nil
		return stack
	end
	local taken = ItemStack.new(stack.itemId, count)
	groundItems.itemsById[id] = table.freeze({
		stack = ItemStack.new(stack.itemId, stack.count - count),
		position = groundItem.position,
		spawnVelocity = groundItem.spawnVelocity,
		spawnTime = groundItem.spawnTime,
	})
	return taken
end

--- Removes every ground item that was spawned `LIFETIME_SECONDS` or more before `now`. The stacks
--- of the removed ground items are gone.
function GroundItems.removeExpiredItems(groundItems: GroundItems, now: number)
	for id, groundItem in groundItems.itemsById do
		if now - groundItem.spawnTime >= GroundItems.LIFETIME_SECONDS then
			groundItems.itemsById[id] = nil
		end
	end
end

return GroundItems
