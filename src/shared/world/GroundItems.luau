--!strict
--- The stacks of items loose in the world of one running game: lying on the ground, or flying
--- towards it.
---
--- A ground item is a stack, the throw it set off with, the position it has got to and the time
--- it was dropped. `throwStack` makes one. Nothing here moves a ground item afterwards:
--- `moveItemTo` records where it has got to. Two ground items of the same item that come close
--- together become one. `moveNearbyStacksToInventory` moves ground items into an inventory,
--- `takeStack` takes one out of the world, and `removeExpiredStacks` removes the ones that have
--- been out too long. Ground items are numbered from 1 in the order they were thrown, and a number
--- is never used twice. Time is a number of seconds, passed in as `now`, from any clock that only
--- goes forward. Positions and distances are in studs. Ground items are never saved.
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local Position = require("../Position")
local Throw = require("./Throw")

local GroundItems = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory
type Throw = Throw.Throw

--- A point in the world, in studs.
export type Position = Position.Position

--- One stack loose in the world. It never changes: when it moves, or part of it is picked up, a
--- new ground item takes its place under the same id.
export type GroundItem = {
	read stack: ItemStack,
	--- How it set off: where from, and how fast.
	read throw: Throw,
	--- Where it is now: the middle of its underside. It starts at `throw.from`.
	read position: Position,
	--- The time it was dropped, in seconds.
	read droppedAt: number,
}

--- Every ground item in one running game.
export type GroundItems = {
	--- The id the next ground item will get.
	nextId: number,
	--- Every ground item, by id. An id with no entry is not in the world.
	--- Note: ids are not consecutive, because a ground item that is picked up or expires leaves
	--- its id unused. `#itemsById` is not the number of ground items.
	itemsById: { [number]: GroundItem },
}

--- How long a ground item lasts before `removeExpiredStacks` removes it, in seconds.
GroundItems.LIFETIME_SECONDS = 300

--- How long after it was dropped a ground item cannot be picked up, in seconds.
GroundItems.PICKUP_DELAY_SECONDS = 1.5

--- How near a position must be to a ground item, along the ground, for
--- `moveNearbyStacksToInventory` to pick it up, in studs.
GroundItems.PICKUP_RADIUS = 4

--- How far above the position a ground item may be for `moveNearbyStacksToInventory` to pick it
--- up, in studs.
GroundItems.PICKUP_HEIGHT_ABOVE = 7

--- How far below the position a ground item may be for `moveNearbyStacksToInventory` to pick it
--- up, in studs.
GroundItems.PICKUP_HEIGHT_BELOW = 2

--- How near two ground items of the same item must come to become one, in studs.
GroundItems.MERGE_RADIUS = 1.5

--- The length of each side of the cube that a ground item takes up, in studs. The cube stands on
--- the ground item's `position`.
GroundItems.ITEM_SIZE = 1.2

local function isInMergeReach(from: Position, to: Position): boolean
	return Position.getDistance(from, to) <= GroundItems.MERGE_RADIUS
end

local function isInPickupReach(from: Position, to: Position): boolean
	local height = to.y - from.y
	return Position.getGroundDistance(from, to) <= GroundItems.PICKUP_RADIUS
		and height <= GroundItems.PICKUP_HEIGHT_ABOVE
		and height >= -GroundItems.PICKUP_HEIGHT_BELOW
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

local function findItemToJoin(groundItems: GroundItems, stack: ItemStack, position: Position): number?
	for _, id in idsNearestFirst(groundItems, position, isInMergeReach) do
		local joined = groundItems.itemsById[id].stack
		if ItemStack.isSameItem(joined, stack) and ItemStack.getSpaceLeft(joined) >= stack.count then
			return id
		end
	end
	return nil
end

local function joinItem(groundItems: GroundItems, id: number, stack: ItemStack, droppedAt: number)
	local joined = groundItems.itemsById[id]
	groundItems.itemsById[id] = table.freeze({
		stack = (ItemStack.merge(joined.stack, stack)),
		throw = joined.throw,
		position = joined.position,
		droppedAt = math.max(joined.droppedAt, droppedAt),
	})
end

--- Returns a new set of ground items with nothing in the world.
function GroundItems.new(): GroundItems
	return { nextId = 1, itemsById = {} }
end

--- Throws `stack` into the world as `throw` says, at the time `now`, and returns the id of the
--- ground item that holds it. If a ground item of the same item is within `MERGE_RADIUS` of
--- where the throw leaves from and has room for all of `stack`, the stack joins it: that ground
--- item holds more, stays where it is and counts as dropped at `now`. With several such ground
--- items it joins the nearest, and of two equally near, the one with the lower id. Otherwise a
--- new ground item is made at `throw.from`.
--- Note: `throwStack` does not take the stack from anywhere. A stack that is also left where it
--- came from exists twice.
function GroundItems.throwStack(groundItems: GroundItems, stack: ItemStack, throw: Throw, now: number): number
	local joinedId = findItemToJoin(groundItems, stack, throw.from)
	if joinedId ~= nil then
		joinItem(groundItems, joinedId, stack, now)
		return joinedId
	end

	local id = groundItems.nextId
	groundItems.itemsById[id] = table.freeze({
		stack = stack,
		throw = throw,
		position = throw.from,
		droppedAt = now,
	})
	groundItems.nextId = id + 1
	return id
end

--- Records that the ground item `id` has got to `position`. If that brings it within
--- `MERGE_RADIUS` of another ground item of the same item that has room for all of its stack, it
--- joins that one: the other holds both stacks, stays where it is and counts as dropped at the
--- later of their two times, and the ground item `id` is gone. With several such ground items it
--- joins the nearest, and of two equally near, the one with the lower id. Does nothing if no
--- ground item has the id `id`.
function GroundItems.moveItemTo(groundItems: GroundItems, id: number, position: Position)
	local groundItem = groundItems.itemsById[id]
	if groundItem == nil then
		return
	end
	groundItems.itemsById[id] = nil
	local joinedId = findItemToJoin(groundItems, groundItem.stack, position)
	if joinedId ~= nil then
		joinItem(groundItems, joinedId, groundItem.stack, groundItem.droppedAt)
		return
	end
	groundItems.itemsById[id] = table.freeze({
		stack = groundItem.stack,
		throw = groundItem.throw,
		position = Position.new(position.x, position.y, position.z),
		droppedAt = groundItem.droppedAt,
	})
end

--- Takes the ground item `id` out of the world and returns its stack. Returns `nil`, changing
--- nothing, if no ground item has that id.
function GroundItems.takeStack(groundItems: GroundItems, id: number): ItemStack?
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
			throw = groundItem.throw,
			position = groundItem.position,
			droppedAt = groundItem.droppedAt,
		})
	end
	return added
end

--- Moves the ground items in reach of `position` into `inventory`, as far as they fit, and
--- returns how many items moved. A ground item is in reach if it is within `PICKUP_RADIUS` of
--- `position` along the ground, and no more than `PICKUP_HEIGHT_ABOVE` above it or
--- `PICKUP_HEIGHT_BELOW` below it. A ground item dropped less than `PICKUP_DELAY_SECONDS` before
--- `now` is left alone. The nearest in a straight line is picked up first, and of two equally
--- near, the one with the lower id. In the inventory, stacks of the same item are topped up first
--- and then slots that hold nothing are filled, lowest slot first. When only part of a ground item
--- fits, the rest stays in the world under the same id, dropped at the same time.
function GroundItems.moveNearbyStacksToInventory(
	groundItems: GroundItems,
	position: Position,
	inventory: Inventory,
	now: number
): number
	local moved = 0
	for _, id in idsNearestFirst(groundItems, position, isInPickupReach) do
		if now - groundItems.itemsById[id].droppedAt >= GroundItems.PICKUP_DELAY_SECONDS then
			moved += moveIntoInventory(groundItems, id, inventory)
		end
	end
	return moved
end

--- Removes every ground item that was dropped `LIFETIME_SECONDS` or more before `now`. Their items
--- are gone.
function GroundItems.removeExpiredStacks(groundItems: GroundItems, now: number)
	for id, groundItem in groundItems.itemsById do
		if now - groundItem.droppedAt >= GroundItems.LIFETIME_SECONDS then
			groundItems.itemsById[id] = nil
		end
	end
end

return GroundItems
