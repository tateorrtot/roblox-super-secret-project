--!strict
--- The stacks of items lying on the ground in one running game.
---
--- A ground item is a stack, the position where it lies and the time it was dropped. Ground items
--- are numbered from 1 in the order they were dropped, and a number is never used twice. `drop`
--- puts a stack on the ground, `pickUpNear` moves ground items into an inventory, and `expire`
--- removes the ones that have lain too long. Time is a number of seconds, passed in as `now`, from
--- any clock that only goes forward. Positions and distances are in studs. Ground items are never
--- saved.
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local Position = require("../Position")

local GroundItems = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory

--- A point in the world, in studs.
export type Position = Position.Position

--- One stack lying on the ground. It never changes: when part of it is picked up, a new ground item
--- with the smaller stack takes its place under the same id.
export type GroundItem = {
	read stack: ItemStack,
	--- Where it lies.
	read position: Position,
	--- The time it was dropped, in seconds.
	read droppedAt: number,
}

export type GroundItems = {
	--- The id the next ground item will get.
	nextId: number,
	--- Every ground item, by id. An id with no entry is not on the ground. The ids have gaps, so
	--- loop with `for id, groundItem in groundItems.byId`, not with `#` or `ipairs`.
	byId: { [number]: GroundItem },
}

--- How long a ground item lies before `expire` removes it, in seconds.
GroundItems.LIFETIME = 300

--- How long after it was dropped a ground item cannot be picked up, in seconds.
GroundItems.PICKUP_DELAY = 1.5

--- How near a position must be to a ground item for `pickUpNear` to pick it up, in studs.
GroundItems.PICKUP_RADIUS = 4

--- How near a stack must be dropped to a ground item of the same item to join it, in studs.
GroundItems.MERGE_RADIUS = 1.5

local function idsWithin(groundItems: GroundItems, position: Position, radius: number): { number }
	local distances: { [number]: number } = {}
	local ids: { number } = {}
	for id, groundItem in groundItems.byId do
		local distance = Position.distance(position, groundItem.position)
		if distance <= radius then
			distances[id] = distance
			table.insert(ids, id)
		end
	end
	table.sort(ids, function(a: number, b: number): boolean
		return distances[a] < distances[b] or (distances[a] == distances[b] and a < b)
	end)
	return ids
end

--- Returns a new set of ground items with nothing on the ground.
function GroundItems.new(): GroundItems
	return { nextId = 1, byId = {} }
end

--- Puts `stack` on the ground at `position`, dropped at the time `now`, and returns the id of the
--- ground item that holds it. If a ground item of the same item lies within `MERGE_RADIUS` of
--- `position` and has room for all of `stack`, the stack joins it: that ground item holds more,
--- stays where it lies and counts as dropped at `now`. With several such ground items it joins the
--- nearest, and of two equally near, the one with the lower id. Otherwise a new ground item is
--- made at `position`.
function GroundItems.drop(groundItems: GroundItems, stack: ItemStack, position: Position, now: number): number
	for _, id in idsWithin(groundItems, position, GroundItems.MERGE_RADIUS) do
		local joined = groundItems.byId[id]
		if ItemStack.isSameItem(joined.stack, stack) and ItemStack.spaceLeft(joined.stack) >= stack.count then
			groundItems.byId[id] = table.freeze({
				stack = (ItemStack.merge(joined.stack, stack)),
				position = joined.position,
				droppedAt = now,
			})
			return id
		end
	end

	local id = groundItems.nextId
	groundItems.byId[id] = table.freeze({
		stack = stack,
		position = table.freeze({ x = position.x, y = position.y, z = position.z }),
		droppedAt = now,
	})
	groundItems.nextId = id + 1
	return id
end

local function moveIntoInventory(groundItems: GroundItems, id: number, inventory: Inventory): number
	local groundItem = groundItems.byId[id]
	local stack = groundItem.stack
	local added = Inventory.addItems(inventory, stack.itemId, stack.count)
	if added == stack.count then
		groundItems.byId[id] = nil
	elseif added > 0 then
		groundItems.byId[id] = table.freeze({
			stack = ItemStack.new(stack.itemId, stack.count - added),
			position = groundItem.position,
			droppedAt = groundItem.droppedAt,
		})
	end
	return added
end

--- Moves the ground items within `PICKUP_RADIUS` of `position` into `inventory`, as far as they
--- fit, and returns how many items moved. A ground item dropped less than `PICKUP_DELAY` seconds
--- before `now` is left alone. The nearest is picked up first, and of two equally near, the one
--- with the lower id. Items go in as `Inventory.addItems` puts them. When only part of a ground
--- item fits, the rest stays on the ground under the same id, dropped at the same time. Returns 0
--- if nothing is picked up.
function GroundItems.pickUpNear(groundItems: GroundItems, position: Position, inventory: Inventory, now: number): number
	local moved = 0
	for _, id in idsWithin(groundItems, position, GroundItems.PICKUP_RADIUS) do
		if now - groundItems.byId[id].droppedAt >= GroundItems.PICKUP_DELAY then
			moved += moveIntoInventory(groundItems, id, inventory)
		end
	end
	return moved
end

--- Removes every ground item that was dropped `LIFETIME` seconds or more before `now`. Their items
--- are gone.
function GroundItems.expire(groundItems: GroundItems, now: number)
	for id, groundItem in groundItems.byId do
		if now - groundItem.droppedAt >= GroundItems.LIFETIME then
			groundItems.byId[id] = nil
		end
	end
end

return GroundItems
