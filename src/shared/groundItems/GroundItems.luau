--!strict
--- The stacks of items loose in the world of one running game: lying on the ground, or flying
--- towards it.
---
--- A ground item is a stack, the position it is at, the velocity it was spawned with and the time
--- it was spawned. `spawnStack` makes one. Nothing here moves a ground item afterwards:
--- `setItemPosition` records where it has got to. `mergeItems` makes ground items of the same item
--- that are close together into one. `getIdsInPickupReach` says which ground items are in pickup
--- reach of a position. `takeFromItem` takes some of a ground item's stack and leaves the rest
--- where it lies, and `removeItem` takes a whole ground item out of the world.
--- `removeExpiredItems` removes the ones that have been out too long. Ground items are numbered
--- from 1 in the order they were spawned, and a number is never used twice. Time is a number of
--- seconds, passed in as `now`, from any clock that only goes forward. Positions and distances are
--- in studs. Ground items are never saved.
local ItemStack = require("../items/ItemStack")
local Position = require("../Position")

local GroundItems = {}

type ItemStack = ItemStack.ItemStack

--- A point in the world, in studs.
export type Position = Position.Position

--- How fast a thing moves along each axis, in studs a second. `y` is upwards.
export type Velocity = { read x: number, read y: number, read z: number }

--- One stack loose in the world. It never changes: when its position is set, or part of its stack
--- is taken, a new ground item takes its place under the same id.
export type GroundItem = {
	read stack: ItemStack,
	--- Where it is: the middle of its underside.
	read position: Position,
	--- How fast it was moving when it was spawned. It is not kept up to date as the item moves.
	read spawnVelocity: Velocity,
	--- The time it was spawned, in seconds. When another ground item merges into it, this becomes
	--- the later of the two items' times.
	read spawnTime: number,
}

--- Every ground item in one running game.
export type GroundItems = {
	--- The id the next ground item will get.
	nextId: number,
	--- Every ground item, by id. An id with no entry is not in the world.
	--- Note: ids are not consecutive, because a ground item that is picked up, merged or expired
	--- leaves its id unused. `#itemsById` is not the number of ground items.
	itemsById: { [number]: GroundItem },
	--- The ids of the ground items spawned, or given a new position, since `mergeItems` last ran.
	--- An id may be listed after its ground item has gone.
	idsMovedSinceMerge: { [number]: true },
	--- The time `mergeItems` was last given. `nil` until it has run.
	lastMergeTime: number?,
}

--- How long a ground item lasts before `removeExpiredItems` removes it, in seconds.
GroundItems.LIFETIME_SECONDS = 300

--- How long after it was spawned a ground item is left out of what `getIdsInPickupReach` returns,
--- in seconds.
GroundItems.PICKUP_DELAY_SECONDS = 1.5

--- How near a position must be to a ground item, along the ground, for the ground item to be in
--- pickup reach of it, in studs.
GroundItems.PICKUP_RADIUS = 4

--- How far above a position a ground item may be and still be in pickup reach of it, in studs.
GroundItems.PICKUP_REACH_UP = 7

--- How far below a position a ground item may be and still be in pickup reach of it, in studs.
GroundItems.PICKUP_REACH_DOWN = 2

--- How wide, deep and tall a ground item is, in studs: it takes up a cube this wide, standing on
--- its `position`.
GroundItems.ITEM_WIDTH = 1.2

--- How near two ground items of the same item must be for `mergeItems` to make them one, in
--- studs: their positions are less than this apart along x, and along z, which leaves a gap of
--- less than 2 studs between their sides. They must also be less than `ITEM_WIDTH` apart in
--- height, so that neither lies wholly above the other.
GroundItems.MERGE_REACH = 2 + GroundItems.ITEM_WIDTH

--- How long a ground item that is not given a new position lies between one merge check by
--- `mergeItems` and the next, in seconds.
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

--- Returns a new set of ground items with nothing in the world.
function GroundItems.new(): GroundItems
	return { nextId = 1, itemsById = {}, idsMovedSinceMerge = {} }
end

--- Makes a new ground item that holds `stack`, at `position` and moving at `velocity`, spawned at
--- the time `now`, and returns its id.
--- Note: `spawnStack` does not take the stack from anywhere. A stack that is also left where it
--- came from exists twice.
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

--- Records that the ground item `id` is now at `position`. Does nothing if no ground item has
--- that id.
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

--- Merges ground items of the same item that are within `MERGE_REACH` of each other, by giving
--- some of the ground items a merge check. Not every ground item gets one each time: `now` is the
--- time, and decides which do.
---
--- A ground item gets a merge check if it was spawned or given a new position since `mergeItems`
--- last ran, or if it has since been in the world for another whole `MERGE_CHECK_SECONDS`,
--- counted from its `spawnTime`. They are checked one by one, the lowest id first.
---
--- In a merge check the ground item is tried with each ground item of the same item in reach of
--- it, the nearest first, and of two equally near, the lower id first. The other need not be one
--- that is being checked. Two merge only if both stacks fit in one stack. The one with the bigger
--- stack then holds both, stays where it is, keeps the velocity it was spawned with, and counts as
--- spawned at the later of the two items' times. The other is gone, and its id with it. If the
--- two stacks are the same size, the one being checked is the one that goes. One that took the
--- other in is tried with the next nearest, and so on until it is gone or there are no more.
---
--- If `now` is no later than the time `mergeItems` was last given, only the ground items spawned
--- or given a new position since then get a merge check.
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

--- Takes the ground item `id` out of the world and returns its stack. Returns `nil`, changing
--- nothing, if no ground item has that id.
function GroundItems.removeItem(groundItems: GroundItems, id: number): ItemStack?
	local groundItem = groundItems.itemsById[id]
	groundItems.itemsById[id] = nil
	return if groundItem then groundItem.stack else nil
end

--- Returns the ids of the ground items in pickup reach of `position` at the time `now`, as a new
--- list: the nearest in a straight line first, and of two equally near, the one with the lower
--- id. A ground item is in pickup reach if it is within `PICKUP_RADIUS` of `position` along the
--- ground, and no more than `PICKUP_REACH_UP` above it or `PICKUP_REACH_DOWN` below it. A ground
--- item spawned less than `PICKUP_DELAY_SECONDS` before `now` is left out.
function GroundItems.getIdsInPickupReach(groundItems: GroundItems, position: Position, now: number): { number }
	local ids = {}
	for _, id in idsNearestFirst(groundItems, position, isInPickupReach) do
		if now - groundItems.itemsById[id].spawnTime >= GroundItems.PICKUP_DELAY_SECONDS then
			table.insert(ids, id)
		end
	end
	return ids
end

--- Takes up to `count` items out of the ground item `id` and returns them as a stack. If that is
--- all it held, the ground item is gone from the world. Otherwise it stays where it is under the
--- same id, with the velocity and the time it was spawned with, holding what is left. Returns
--- `nil`, changing nothing, if `count` is 0. Fails if no ground item has that id, or if `count` is
--- not a whole number of 0 or more.
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

--- Removes every ground item that was spawned `LIFETIME_SECONDS` or more before `now`. Their
--- items are gone.
function GroundItems.removeExpiredItems(groundItems: GroundItems, now: number)
	for id, groundItem in groundItems.itemsById do
		if now - groundItem.spawnTime >= GroundItems.LIFETIME_SECONDS then
			groundItems.itemsById[id] = nil
		end
	end
end

return GroundItems
