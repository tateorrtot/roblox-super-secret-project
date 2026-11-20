--!strict
--- The stacks of items loose in the world of one running game: lying on the ground, or flying
--- towards it.
---
--- A ground item is a stack, the position it is at, the velocity it was spawned with and the time
--- it was spawned. `spawnStack` makes one. Nothing here moves a ground item afterwards:
--- `setItemPosition` records where it has got to. `mergeMovedItems` makes ground items of the same
--- item that have come close together into one: it looks only at the ones spawned or given a new
--- position since it last ran. `moveNearbyStacksToInventory` moves ground items into an inventory,
--- `removeItem` takes one out of the world, and `removeExpiredItems` removes the ones that have
--- been out too long. Ground items are numbered from 1 in the order
--- they were spawned, and a number is never used twice. Time is a number of seconds, passed in as
--- `now`, from any clock that only goes forward. Positions and distances are in studs. Ground items
--- are never saved.
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local Position = require("../Position")

local GroundItems = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory

--- A point in the world, in studs.
export type Position = Position.Position

--- How fast a thing moves along each axis, in studs a second. `y` is upwards.
export type Velocity = { read x: number, read y: number, read z: number }

--- One stack loose in the world. It never changes: when its position is set, or part of it is
--- picked up, a new ground item takes its place under the same id.
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
	--- The ids of the ground items spawned, or given a new position, since `mergeMovedItems` last
	--- ran. An id may be listed after its ground item has gone.
	movedIds: { [number]: true },
}

--- How long a ground item lasts before `removeExpiredItems` removes it, in seconds.
GroundItems.LIFETIME_SECONDS = 300

--- How long after it was spawned a ground item cannot be picked up, in seconds.
GroundItems.PICKUP_DELAY_SECONDS = 1.5

--- How near a position must be to a ground item, along the ground, for
--- `moveNearbyStacksToInventory` to pick it up, in studs.
GroundItems.PICKUP_RADIUS = 4

--- How far above the position `moveNearbyStacksToInventory` picks up from, in studs.
GroundItems.PICKUP_REACH_UP = 7

--- How far below the position `moveNearbyStacksToInventory` picks up from, in studs.
GroundItems.PICKUP_REACH_DOWN = 2

--- How near two ground items of the same item must be for `mergeItemIntoNearbyItem` and
--- `mergeMovedItems` to make them one, in studs.
GroundItems.MERGE_RADIUS = 1.5

--- How wide, deep and tall a ground item is, in studs: it takes up a cube this wide, standing on
--- its `position`.
GroundItems.ITEM_WIDTH = 1.2

local function isInMergeReach(from: Position, to: Position): boolean
	return Position.getDistance(from, to) <= GroundItems.MERGE_RADIUS
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

local function findItemWithRoomNear(groundItems: GroundItems, stack: ItemStack, position: Position): number?
	for _, id in idsNearestFirst(groundItems, position, isInMergeReach) do
		local other = groundItems.itemsById[id].stack
		if ItemStack.isSameItem(other, stack) and ItemStack.getSpaceLeft(other) >= stack.count then
			return id
		end
	end
	return nil
end

--- Returns a new set of ground items with nothing in the world.
function GroundItems.new(): GroundItems
	return { nextId = 1, itemsById = {}, movedIds = {} }
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
	groundItems.movedIds[id] = true
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
	groundItems.movedIds[id] = true
end

--- Merges the ground item `id` into another ground item of the same item that is within
--- `MERGE_RADIUS` of it and has room for all of its stack. The other then holds both stacks, stays
--- where it is, and counts as spawned at the later of the two items' times, and the ground item
--- `id` is gone. With several such ground items it merges into the nearest, and of two equally
--- near, the one with the lower id.
---
--- Returns the id of the ground item that holds the stack afterwards. That is `id` itself if there
--- was nothing to merge into, or if no ground item has the id `id`.
function GroundItems.mergeItemIntoNearbyItem(groundItems: GroundItems, id: number): number
	local groundItem = groundItems.itemsById[id]
	if groundItem == nil then
		return id
	end
	groundItems.itemsById[id] = nil
	local otherId = findItemWithRoomNear(groundItems, groundItem.stack, groundItem.position)
	if otherId == nil then
		groundItems.itemsById[id] = groundItem
		return id
	end
	local other = groundItems.itemsById[otherId]
	groundItems.itemsById[otherId] = table.freeze({
		stack = (ItemStack.merge(other.stack, groundItem.stack)),
		position = other.position,
		spawnVelocity = other.spawnVelocity,
		spawnTime = math.max(other.spawnTime, groundItem.spawnTime),
	})
	return otherId
end

--- Merges each ground item that was spawned, or given a new position, since this last ran, as
--- `mergeItemIntoNearbyItem` does, the lowest id first. A ground item that has lain still since
--- then is not looked at, though one that moved may merge into it.
function GroundItems.mergeMovedItems(groundItems: GroundItems)
	local ids = {}
	for id in groundItems.movedIds do
		table.insert(ids, id)
	end
	table.sort(ids)
	table.clear(groundItems.movedIds)
	for _, id in ids do
		GroundItems.mergeItemIntoNearbyItem(groundItems, id)
	end
end

--- Takes the ground item `id` out of the world and returns its stack. Returns `nil`, changing
--- nothing, if no ground item has that id.
function GroundItems.removeItem(groundItems: GroundItems, id: number): ItemStack?
	local groundItem = groundItems.itemsById[id]
	groundItems.itemsById[id] = nil
	return if groundItem then groundItem.stack else nil
end

local function moveIntoInventory(groundItems: GroundItems, id: number, inventory: Inventory): number
	local groundItem = groundItems.itemsById[id]
	local stack = groundItem.stack
	local added = Inventory.addItems(inventory, stack.itemId, stack.count)
	if added == stack.count then
		groundItems.itemsById[id] = nil
	elseif added > 0 then
		groundItems.itemsById[id] = table.freeze({
			stack = ItemStack.new(stack.itemId, stack.count - added),
			position = groundItem.position,
			spawnVelocity = groundItem.spawnVelocity,
			spawnTime = groundItem.spawnTime,
		})
	end
	return added
end

--- Moves the ground items in reach of `position` into `inventory`, as far as they fit, and
--- returns how many items moved. A ground item is in reach if it is within `PICKUP_RADIUS` of
--- `position` along the ground, and no more than `PICKUP_REACH_UP` above it or
--- `PICKUP_REACH_DOWN` below it. A ground item spawned less than `PICKUP_DELAY_SECONDS` before
--- `now` is left alone. The nearest in a straight line is picked up first, and of two equally
--- near, the one with the lower id. In the inventory, stacks of the same item are topped up first
--- and then slots that hold nothing are filled, lowest slot first. When only part of a ground item
--- fits, the rest stays in the world under the same id, spawned at the same time.
function GroundItems.moveNearbyStacksToInventory(
	groundItems: GroundItems,
	position: Position,
	inventory: Inventory,
	now: number
): number
	local moved = 0
	for _, id in idsNearestFirst(groundItems, position, isInPickupReach) do
		if now - groundItems.itemsById[id].spawnTime >= GroundItems.PICKUP_DELAY_SECONDS then
			moved += moveIntoInventory(groundItems, id, inventory)
		end
	end
	return moved
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
