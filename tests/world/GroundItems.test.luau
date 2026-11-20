--!strict
-- Tests for GroundItems. Run from the repository root: lune run tests/world/GroundItems.test.luau

local Check = require("../Check")
local GroundItems = require("../../src/shared/world/GroundItems")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")

local check = Check.that
local STILL = { x = 0, y = 0, z = 0 }

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "stove", stackSize = 1 })

local DELAY = GroundItems.PICKUP_DELAY_SECONDS
local RADIUS = GroundItems.PICKUP_RADIUS
local LIFETIME = GroundItems.LIFETIME_SECONDS
local MERGE = GroundItems.MERGE_RADIUS
local ABOVE = GroundItems.PICKUP_REACH_UP
local BELOW = GroundItems.PICKUP_REACH_DOWN

local function at(x: number, y: number, z: number): GroundItems.Position
	return { x = x, y = y, z = z }
end

-- Spawns `stack` at `position`, not moving, and merges it into its own kind if one is near. Returns
-- the id of the ground item that holds it.
local function dropAt(
	ground: GroundItems.GroundItems,
	stack: ItemStack.ItemStack,
	position: GroundItems.Position,
	now: number
): number
	local id = GroundItems.spawnStack(ground, stack, position, STILL, now)
	return GroundItems.mergeItemIntoNearbyItem(ground, id)
end

-- Says that the ground item `id` is now at `position`, and merges it into its own kind if one is
-- near.
local function moveTo(ground: GroundItems.GroundItems, id: number, position: GroundItems.Position)
	GroundItems.setItemPosition(ground, id, position)
	GroundItems.mergeItemIntoNearbyItem(ground, id)
end

-- How many ground items there are.
local function groundItemCount(ground: GroundItems.GroundItems): number
	local count = 0
	for _ in ground.itemsById :: any do
		count += 1
	end
	return count
end

-- How many of one item lie on the ground, over every ground item.
local function itemsOnGround(ground: GroundItems.GroundItems, itemId: string): number
	local count = 0
	for _, groundItem: GroundItems.GroundItem in ground.itemsById :: any do
		if groundItem.stack.itemId == itemId then
			count += groundItem.stack.count
		end
	end
	return count
end

-- True if the ground item `id` is `count` of the item `itemId`.
local function holds(ground: GroundItems.GroundItems, id: number, itemId: string, count: number): boolean
	local groundItem = ground.itemsById[id]
	return groundItem ~= nil and groundItem.stack.itemId == itemId and groundItem.stack.count == count
end

do -- the rules as numbers
	check(LIFETIME == 300, "a ground item lies for five minutes")
	check(DELAY == 1.5, "a ground item cannot be picked up for its first second and a half")
	check(RADIUS == 4, "a ground item is picked up from 4 studs away along the ground")
	check(ABOVE == 7 and BELOW == 2, "a ground item up to 7 studs above the position, or 2 studs below it, is in reach")
	check(MERGE == 1.5, "two ground items of one kind within a stud and a half of each other become one")
	check(GroundItems.ITEM_WIDTH == 1.2, "a ground item takes up a cube 1.2 studs on a side")
end

do -- nothing on the ground
	local ground = GroundItems.new()
	check(ground.nextId == 1, "new: the first ground item will be number 1")
	check(groundItemCount(ground) == 0, "new: nothing is on the ground")
	local pack = Inventory.new(3)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(0, 0, 0), pack, 100) == 0,
		"moveNearbyStacksToInventory: 0 when nothing is on the ground"
	)
	check(Inventory.isEmpty(pack), "moveNearbyStacksToInventory: and the inventory is as it was")
	GroundItems.removeExpiredItems(ground, 1000)
	check(
		groundItemCount(ground) == 0 and ground.nextId == 1,
		"removeExpiredItems: does nothing when nothing is on the ground"
	)
end

do -- spawning
	local ground = GroundItems.new()
	local logs = ItemStack.new("log", 5)
	local where = { x = 10, y = 2, z = -3 }
	local velocity = { x = 24, y = 8, z = -1 }
	local id = GroundItems.spawnStack(ground, logs, where, velocity, 12)
	check(id == 1, "spawnStack: the first ground item is number 1")
	check(ground.nextId == 2, "spawnStack: the next one will be number 2")
	local groundItem = ground.itemsById[1]
	check(groundItem ~= nil and groundItem.stack == logs, "spawnStack: the ground item holds the stack")
	check(
		groundItem.position.x == 10 and groundItem.position.y == 2 and groundItem.position.z == -3,
		"spawnStack: it is at the position given"
	)
	check(
		groundItem.spawnVelocity.x == 24 and groundItem.spawnVelocity.y == 8 and groundItem.spawnVelocity.z == -1,
		"spawnStack: it remembers the velocity it was spawned with"
	)
	check(groundItem.spawnTime == 12, "spawnStack: and the time it was spawned")
	where.x = 99
	velocity.y = 99
	check(
		ground.itemsById[1].position.x == 10 and ground.itemsById[1].spawnVelocity.y == 8,
		"spawnStack: changing the caller's tables afterwards does not change the ground item"
	)
	check(
		table.isfrozen(groundItem) and table.isfrozen(groundItem.position) and table.isfrozen(groundItem.spawnVelocity),
		"spawnStack: a ground item is a frozen value, all the way in"
	)

	local second = GroundItems.spawnStack(ground, ItemStack.new("fish", 2), at(0, 0, 0), STILL, 13)
	check(second == 2 and ground.nextId == 3, "spawnStack: ids count up")
	check(groundItemCount(ground) == 2, "spawnStack: both are in the world")

	local beside = GroundItems.spawnStack(ground, ItemStack.new("log", 3), at(10, 2, -3), STILL, 14)
	check(
		beside == 3 and holds(ground, 1, "log", 5) and holds(ground, 3, "log", 3),
		"spawnStack: a stack spawned beside its own kind is a ground item of its own"
	)
end

do -- merging: a ground item beside its own kind
	local ground = GroundItems.new()
	local first = dropAt(ground, ItemStack.new("log", 5), at(10, 0, 0), 100)
	local joined = dropAt(ground, ItemStack.new("log", 3), at(10 + MERGE, 0, 0), 130)
	check(joined == first, "mergeItemIntoNearbyItem: returns the id of the ground item it merged into")
	check(
		groundItemCount(ground) == 1 and holds(ground, first, "log", 8),
		"mergeItemIntoNearbyItem: that ground item holds both stacks"
	)
	check(
		ground.itemsById[2] == nil and ground.nextId == 3,
		"mergeItemIntoNearbyItem: the merged one is gone, id and all"
	)
	check(ground.itemsById[first].position.x == 10, "mergeItemIntoNearbyItem: the other stays where it is")
	check(
		ground.itemsById[first].spawnTime == 130,
		"mergeItemIntoNearbyItem: and counts as spawned at the later of the two times"
	)
	check(table.isfrozen(ground.itemsById[first]), "mergeItemIntoNearbyItem: the other is still a frozen value")

	local beyond = dropAt(ground, ItemStack.new("log", 1), at(10 + MERGE + 0.01, 0, 0), 130)
	check(
		beyond == 3 and holds(ground, first, "log", 8),
		"mergeItemIntoNearbyItem: returns the item's own id when the other is just beyond the radius"
	)
	local above = dropAt(ground, ItemStack.new("log", 1), at(10, MERGE + 0.01, 0), 130)
	check(above == 4 and holds(ground, first, "log", 8), "mergeItemIntoNearbyItem: height counts towards the distance")

	local other = dropAt(ground, ItemStack.new("fish", 2), at(10, 0, 0), 130)
	check(other == 5 and holds(ground, first, "log", 8), "mergeItemIntoNearbyItem: a different item is not merged into")

	local full = GroundItems.new()
	dropAt(full, ItemStack.new("log", 12), at(0, 0, 0), 0)
	local apart = dropAt(full, ItemStack.new("log", 5), at(0, 0, 0), 0)
	check(
		apart == 2 and holds(full, 1, "log", 12) and holds(full, 2, "log", 5),
		"mergeItemIntoNearbyItem: a stack that does not wholly fit stays a ground item of its own"
	)
	check(
		dropAt(full, ItemStack.new("log", 4), at(0, 0, 0), 0) == 1,
		"mergeItemIntoNearbyItem: a stack that exactly fills the other merges"
	)
	check(holds(full, 1, "log", 16), "mergeItemIntoNearbyItem: and the other is a full stack")
	check(dropAt(full, ItemStack.new("stove", 1), at(5, 0, 0), 0) == 4, "mergeItemIntoNearbyItem: a stove lies alone")
	check(
		dropAt(full, ItemStack.new("stove", 1), at(5, 0, 0), 0) == 5,
		"mergeItemIntoNearbyItem: an item that does not stack never merges"
	)

	local choice = GroundItems.new()
	local farther = dropAt(choice, ItemStack.new("log", 1), at(-1.2, 0, 0), 0)
	local nearer = dropAt(choice, ItemStack.new("log", 1), at(0.5, 0, 0), 0)
	check(
		dropAt(choice, ItemStack.new("log", 1), at(0, 0, 0), 0) == nearer,
		"mergeItemIntoNearbyItem: merges into the nearest of two"
	)
	check(
		holds(choice, farther, "log", 1) and holds(choice, nearer, "log", 2),
		"mergeItemIntoNearbyItem: and leaves the farther as it was"
	)

	local tied = GroundItems.new()
	for index = 1, 60 do
		dropAt(tied, ItemStack.new("fish", 1), at(index * 10, 0, 500), 0)
	end
	GroundItems.removeExpiredItems(tied, LIFETIME)
	local allFirst = true
	for round = 1, 20 do
		local x = round * 100
		local left = dropAt(tied, ItemStack.new("log", 1), at(x - 1, 0, 0), LIFETIME)
		dropAt(tied, ItemStack.new("log", 1), at(x + 1, 0, 0), LIFETIME)
		if dropAt(tied, ItemStack.new("log", 1), at(x, 0, 0), LIFETIME) ~= left then
			allFirst = false
		end
	end
	check(
		allFirst,
		"mergeItemIntoNearbyItem: of two equally near, merges into the one spawned first, whatever their ids"
	)

	local delayed = GroundItems.new()
	local pack = Inventory.new(3)
	dropAt(delayed, ItemStack.new("log", 5), at(0, 0, 0), 0)
	dropAt(delayed, ItemStack.new("log", 1), at(0, 0, 0), 100)
	check(
		GroundItems.moveNearbyStacksToInventory(delayed, at(1, 0, 0), pack, 100 + DELAY - 0.01) == 0,
		"mergeItemIntoNearbyItem: a ground item that was merged into cannot be picked up straight away"
	)
	GroundItems.removeExpiredItems(delayed, LIFETIME + 50)
	check(holds(delayed, 1, "log", 6), "mergeItemIntoNearbyItem: a ground item that was merged into lasts from then")
	check(
		GroundItems.moveNearbyStacksToInventory(delayed, at(1, 0, 0), pack, 100 + DELAY) == 6,
		"mergeItemIntoNearbyItem: and is picked up whole"
	)
end

do -- walking over a ground item
	local ground = GroundItems.new()
	local pack = Inventory.new(3)
	dropAt(ground, ItemStack.new("log", 5), at(10, 0, 0), 12)

	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(9, 0, 0), pack, 12) == 0,
		"moveNearbyStacksToInventory: not in the moment it was dropped"
	)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(9, 0, 0), pack, 12 + DELAY - 0.01) == 0,
		"moveNearbyStacksToInventory: not just before the delay is over"
	)
	check(
		holds(ground, 1, "log", 5) and Inventory.isEmpty(pack),
		"moveNearbyStacksToInventory: a refused pickup changes nothing"
	)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(10 + RADIUS + 0.01, 0, 0), pack, 100) == 0,
		"moveNearbyStacksToInventory: not from just beyond the radius"
	)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(10, BELOW + 0.01, 0), pack, 100) == 0,
		"moveNearbyStacksToInventory: not a ground item just more than the reach below the position"
	)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(10, -ABOVE - 0.01, 0), pack, 100) == 0,
		"moveNearbyStacksToInventory: not a ground item just more than the reach above the position"
	)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(10 - 3, 0, 3), pack, 100) == 0,
		"moveNearbyStacksToInventory: the distance along the ground is measured in a straight line"
	)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(9, 0, 0), pack, 12 + DELAY) == 5,
		"moveNearbyStacksToInventory: returns how many items moved"
	)
	check(Inventory.countItems(pack, "log") == 5, "moveNearbyStacksToInventory: the items are in the inventory")
	check(groundItemCount(ground) == 0, "moveNearbyStacksToInventory: the ground item is gone")
	check(ground.nextId == 2, "moveNearbyStacksToInventory: the id is not used again")
	check(
		dropAt(ground, ItemStack.new("fish", 1), at(0, 0, 0), 200) == 2,
		"spawnStack: a new ground item gets a new id"
	)
end

do -- reach is measured along the ground and in height, between any two positions
	local ground = GroundItems.new()
	local pack = Inventory.new(3)
	dropAt(ground, ItemStack.new("log", 1), at(10, 5, -7), 0)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(-10, 5, -7), pack, 10) == 0,
		"moveNearbyStacksToInventory: not from 20 studs away along x"
	)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(10, -5, -7), pack, 10) == 0,
		"moveNearbyStacksToInventory: not from 10 studs below it"
	)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(10, 5, 7), pack, 10) == 0,
		"moveNearbyStacksToInventory: not from 14 studs away along z"
	)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(11, 4, -6), pack, 10) == 1,
		"moveNearbyStacksToInventory: from a step away on every axis"
	)
end

do -- equally near ground items are picked up in the order they were dropped, whatever their ids
	local ground = GroundItems.new()
	for index = 1, 100 do
		dropAt(ground, ItemStack.new("log", 1), at(500 + index * 10, 0, 500), 0)
	end
	GroundItems.removeExpiredItems(ground, LIFETIME)
	for _ = 1, 40 do
		dropAt(ground, ItemStack.new("stove", 1), at(0, 0, 0), LIFETIME)
	end
	local inOrder = true
	local pack = Inventory.new(1)
	for expected = 101, 140 do
		GroundItems.moveNearbyStacksToInventory(ground, at(1, 0, 0), pack, LIFETIME + 10)
		pack = Inventory.new(1)
		if ground.itemsById[expected] ~= nil or groundItemCount(ground) ~= 140 - expected then
			inOrder = false
		end
	end
	check(
		inOrder,
		"moveNearbyStacksToInventory: 40 stoves in one spot are picked up one at a time, first dropped first"
	)
end

do -- the edge of the radius, and several at once
	local ground = GroundItems.new()
	local pack = Inventory.new(9)
	dropAt(ground, ItemStack.new("log", 4), at(RADIUS, 0, 0), 0)
	dropAt(ground, ItemStack.new("fish", 2), at(0, 0, -RADIUS), 0)
	dropAt(ground, ItemStack.new("stove", 1), at(0, -BELOW, 0), 0)
	dropAt(ground, ItemStack.new("log", 7), at(RADIUS + 3, 0, 0), 0)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(0, 0, 0), pack, 10) == 7,
		"moveNearbyStacksToInventory: everything exactly at the edge of reach"
	)
	check(
		Inventory.countItems(pack, "log") == 4
			and Inventory.countItems(pack, "fish") == 2
			and Inventory.countItems(pack, "stove") == 1,
		"moveNearbyStacksToInventory: each kind of item is picked up"
	)
	check(
		groundItemCount(ground) == 1 and holds(ground, 4, "log", 7),
		"moveNearbyStacksToInventory: what was out of reach stays"
	)
end

do -- reaching up and down
	local ground = GroundItems.new()
	local pack = Inventory.new(9)
	local onTop = dropAt(ground, ItemStack.new("log", 1), at(RADIUS, ABOVE, 0), 0)
	local tooHigh = dropAt(ground, ItemStack.new("fish", 1), at(0, ABOVE + 0.01, 0), 0)
	local tooLow = dropAt(ground, ItemStack.new("stove", 1), at(0, -BELOW - 0.01, 0), 0)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(0, 0, 0), pack, 10) == 1,
		"moveNearbyStacksToInventory: only what is within the reach above and below"
	)
	check(
		ground.itemsById[onTop] == nil and Inventory.countItems(pack, "log") == 1,
		"moveNearbyStacksToInventory: a ground item as high as the reach goes, and as far off, is picked up"
	)
	check(
		holds(ground, tooHigh, "fish", 1) and holds(ground, tooLow, "stove", 1),
		"moveNearbyStacksToInventory: one just above the reach stays, and one just below it"
	)

	local stacked = GroundItems.new()
	local onePack = Inventory.new(1)
	local higher = dropAt(stacked, ItemStack.new("log", 16), at(0, 3, 0), 0)
	local lower = dropAt(stacked, ItemStack.new("fish", 8), at(0, 1, 0), 0)
	GroundItems.moveNearbyStacksToInventory(stacked, at(0, 0, 0), onePack, 10)
	check(
		stacked.itemsById[lower] == nil and holds(stacked, higher, "log", 16),
		"moveNearbyStacksToInventory: of two straight above, the nearer in height is picked up first"
	)
end

do -- an inventory with too little room
	local ground = GroundItems.new()
	local pack = Inventory.new(1)
	Inventory.addItems(pack, "log", 10)
	dropAt(ground, ItemStack.new("log", 16), at(2, 0, 0), 5)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(0, 0, 0), pack, 50) == 6,
		"moveNearbyStacksToInventory: takes only what fits"
	)
	check(Inventory.countItems(pack, "log") == 16, "moveNearbyStacksToInventory: the inventory is full")
	check(holds(ground, 1, "log", 10), "moveNearbyStacksToInventory: the rest stays on the ground under the same id")
	local rest = ground.itemsById[1]
	check(
		rest.position.x == 2 and rest.spawnTime == 5,
		"moveNearbyStacksToInventory: the rest lies where it was and is no younger"
	)
	check(table.isfrozen(rest), "moveNearbyStacksToInventory: the rest is a frozen value too")
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(0, 0, 0), pack, 60) == 0,
		"moveNearbyStacksToInventory: 0 when nothing fits"
	)
	check(holds(ground, 1, "log", 10), "moveNearbyStacksToInventory: and the ground item is as it was")

	dropAt(ground, ItemStack.new("fish", 3), at(1, 0, 0), 5)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(0, 0, 0), pack, 60) == 0,
		"moveNearbyStacksToInventory: 0 when the only slot holds another item"
	)
	check(groundItemCount(ground) == 2, "moveNearbyStacksToInventory: both are still on the ground")
end

do -- the nearest first
	local ground = GroundItems.new()
	local pack = Inventory.new(1)
	local far = dropAt(ground, ItemStack.new("log", 16), at(3, 0, 0), 0)
	local near = dropAt(ground, ItemStack.new("fish", 8), at(1, 0, 0), 0)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(0, 0, 0), pack, 10) == 8,
		"moveNearbyStacksToInventory: one slot takes one of them"
	)
	check(Inventory.countItems(pack, "fish") == 8, "moveNearbyStacksToInventory: the nearest is picked up first")
	check(
		ground.itemsById[near] == nil and holds(ground, far, "log", 16),
		"moveNearbyStacksToInventory: the farther one stays"
	)

	local tied = GroundItems.new()
	local onePack = Inventory.new(1)
	local first = dropAt(tied, ItemStack.new("log", 16), at(2, 0, 0), 0)
	local second = dropAt(tied, ItemStack.new("fish", 8), at(-2, 0, 0), 0)
	GroundItems.moveNearbyStacksToInventory(tied, at(0, 0, 0), onePack, 10)
	check(
		tied.itemsById[first] == nil and holds(tied, second, "fish", 8),
		"moveNearbyStacksToInventory: of two equally near, the one dropped first is picked up first"
	)

	local filling = GroundItems.new()
	local smallPack = Inventory.new(2)
	dropAt(filling, ItemStack.new("log", 12), at(1, 0, 0), 0)
	dropAt(filling, ItemStack.new("log", 12), at(2, 0, 0), 0)
	dropAt(filling, ItemStack.new("log", 12), at(3, 0, 0), 0)
	check(
		GroundItems.moveNearbyStacksToInventory(filling, at(0, 0, 0), smallPack, 10) == 32,
		"moveNearbyStacksToInventory: stacks top each other up"
	)
	check(
		filling.itemsById[1] == nil and filling.itemsById[2] == nil and holds(filling, 3, "log", 4),
		"moveNearbyStacksToInventory: the farthest is the one left short"
	)
end

do -- lying too long
	local ground = GroundItems.new()
	dropAt(ground, ItemStack.new("log", 5), at(0, 0, 0), 100)
	dropAt(ground, ItemStack.new("fish", 2), at(0, 0, 0), 250)
	GroundItems.removeExpiredItems(ground, 100 + LIFETIME - 0.01)
	check(groundItemCount(ground) == 2, "removeExpiredItems: nothing goes before its time")
	GroundItems.removeExpiredItems(ground, 100 + LIFETIME)
	check(ground.itemsById[1] == nil, "removeExpiredItems: a ground item is gone once it has lain for the lifetime")
	check(holds(ground, 2, "fish", 2), "removeExpiredItems: a younger one stays")
	check(ground.nextId == 3, "removeExpiredItems: ids are not used again")
	GroundItems.removeExpiredItems(ground, 100000)
	check(groundItemCount(ground) == 0, "removeExpiredItems: in the end everything goes")

	local partly = GroundItems.new()
	local pack = Inventory.new(1)
	Inventory.addItems(pack, "log", 10)
	dropAt(partly, ItemStack.new("log", 16), at(0, 0, 0), 0)
	GroundItems.moveNearbyStacksToInventory(partly, at(0, 0, 0), pack, LIFETIME - 1)
	GroundItems.removeExpiredItems(partly, LIFETIME)
	check(
		groundItemCount(partly) == 0,
		"removeExpiredItems: picking part of a ground item up does not make the rest last longer"
	)
end

do -- setting where a ground item is
	local ground = GroundItems.new()
	local id = GroundItems.spawnStack(ground, ItemStack.new("log", 5), at(0, 3, 0), { x = 24, y = 8, z = 0 }, 12)
	local before = ground.itemsById[id]
	local to = { x = 6, y = 0.5, z = 1 }
	GroundItems.setItemPosition(ground, id, to)
	local moved = ground.itemsById[id]
	check(
		moved.position.x == 6 and moved.position.y == 0.5 and moved.position.z == 1,
		"setItemPosition: the ground item is at the position given"
	)
	check(
		moved.stack == before.stack and moved.spawnVelocity == before.spawnVelocity and moved.spawnTime == 12,
		"setItemPosition: its stack, the velocity it was spawned with and the time it was spawned are as they were"
	)
	check(before.position.x == 0, "setItemPosition: the ground item it replaced is unchanged")
	check(
		table.isfrozen(moved) and table.isfrozen(moved.position),
		"setItemPosition: the ground item is still a frozen value"
	)
	to.x = 99
	check(
		ground.itemsById[id].position.x == 6,
		"setItemPosition: changing the caller's position table afterwards does not move it"
	)
	check(ground.nextId == 2 and groundItemCount(ground) == 1, "setItemPosition: uses no new id")

	GroundItems.setItemPosition(ground, 77, at(1, 1, 1))
	check(
		groundItemCount(ground) == 1 and ground.itemsById[77] == nil,
		"setItemPosition: does nothing when no ground item has the id"
	)

	local beside = GroundItems.spawnStack(ground, ItemStack.new("log", 3), at(50, 0, 0), STILL, 12)
	GroundItems.setItemPosition(ground, beside, at(6, 0.5, 1))
	check(
		holds(ground, id, "log", 5) and holds(ground, beside, "log", 3),
		"setItemPosition: a ground item set down beside its own kind stays a ground item of its own"
	)
	GroundItems.removeItem(ground, beside)

	local pack = Inventory.new(3)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(0, 0, 0), pack, 100) == 0,
		"setItemPosition: a ground item is not picked up from where it was before"
	)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(6, 0, 0), pack, 100) == 5,
		"setItemPosition: it is picked up from where it is now"
	)
end

do -- merging: a ground item that has come beside its own kind
	local ground = GroundItems.new()
	local lying = dropAt(ground, ItemStack.new("log", 5), at(10, 0, 0), 100)
	local flying = dropAt(ground, ItemStack.new("log", 3), at(0, 3, 0), 130)
	moveTo(ground, flying, at(10 - MERGE - 0.01, 0, 0))
	check(
		holds(ground, lying, "log", 5) and holds(ground, flying, "log", 3),
		"mergeItemIntoNearbyItem: two of a kind just beyond the radius of each other stay two"
	)
	GroundItems.setItemPosition(ground, flying, at(10 - MERGE, 0, 0))
	check(
		GroundItems.mergeItemIntoNearbyItem(ground, flying) == lying,
		"mergeItemIntoNearbyItem: returns the id of the one it merged into"
	)
	check(ground.itemsById[flying] == nil, "mergeItemIntoNearbyItem: the ground item that merged is gone")
	check(holds(ground, lying, "log", 8), "mergeItemIntoNearbyItem: the other holds both stacks")
	check(ground.itemsById[lying].position.x == 10, "mergeItemIntoNearbyItem: and stays where it was")
	check(
		ground.itemsById[lying].spawnTime == 130,
		"mergeItemIntoNearbyItem: and counts as spawned at the later of the two times"
	)
	check(
		groundItemCount(ground) == 1 and itemsOnGround(ground, "log") == 8,
		"mergeItemIntoNearbyItem: no item is made or lost"
	)
	check(
		GroundItems.mergeItemIntoNearbyItem(ground, flying) == flying and groundItemCount(ground) == 1,
		"mergeItemIntoNearbyItem: returns the id given, and changes nothing, when no ground item has it"
	)

	local older = GroundItems.new()
	local first = dropAt(older, ItemStack.new("log", 5), at(0, 0, 0), 50)
	local second = dropAt(older, ItemStack.new("log", 3), at(20, 0, 0), 90)
	moveTo(older, first, at(20, 0, 0))
	check(
		older.itemsById[first] == nil and holds(older, second, "log", 8) and older.itemsById[second].spawnTime == 90,
		"mergeItemIntoNearbyItem: when the older one merges, the other keeps the later time"
	)

	local apart = GroundItems.new()
	local logs = dropAt(apart, ItemStack.new("log", 12), at(0, 0, 0), 0)
	local more = dropAt(apart, ItemStack.new("log", 5), at(20, 0, 0), 0)
	local fish = dropAt(apart, ItemStack.new("fish", 2), at(40, 0, 0), 0)
	moveTo(apart, more, at(0, 0, 0))
	check(
		holds(apart, logs, "log", 12) and holds(apart, more, "log", 5),
		"mergeItemIntoNearbyItem: two that would not fit in one stack stay two"
	)
	check(
		apart.itemsById[more].position.x == 0,
		"mergeItemIntoNearbyItem: and the one that did not merge is where it was"
	)
	moveTo(apart, fish, at(0, 0, 0))
	check(
		holds(apart, fish, "fish", 2) and groundItemCount(apart) == 3,
		"mergeItemIntoNearbyItem: a different item is not merged into"
	)
	moveTo(apart, more, at(0, MERGE + 0.01, 0))
	local four = dropAt(apart, ItemStack.new("log", 4), at(20, 0, 0), 0)
	moveTo(apart, four, at(0, 0, 0))
	check(
		apart.itemsById[four] == nil and holds(apart, logs, "log", 16) and holds(apart, more, "log", 5),
		"mergeItemIntoNearbyItem: of two it could merge into, it takes the nearer"
	)

	local tied = GroundItems.new()
	local left = dropAt(tied, ItemStack.new("log", 1), at(-1, 0, 0), 0)
	local right = dropAt(tied, ItemStack.new("log", 1), at(1, 0, 0), 0)
	local between = dropAt(tied, ItemStack.new("log", 1), at(0, 20, 0), 0)
	moveTo(tied, between, at(0, 0, 0))
	check(
		holds(tied, left, "log", 2) and holds(tied, right, "log", 1),
		"mergeItemIntoNearbyItem: of two equally near, it takes the one spawned first"
	)

	local still = GroundItems.new()
	local alone = dropAt(still, ItemStack.new("log", 5), at(0, 0, 0), 0)
	check(
		GroundItems.mergeItemIntoNearbyItem(still, alone) == alone and holds(still, alone, "log", 5),
		"mergeItemIntoNearbyItem: a ground item does not merge into itself"
	)
end

do -- taking one out of the world
	local ground = GroundItems.new()
	local id = dropAt(ground, ItemStack.new("log", 5), at(0, 0, 0), 0)
	local other = dropAt(ground, ItemStack.new("fish", 2), at(0, 0, 0), 0)
	local taken = GroundItems.removeItem(ground, id)
	check(taken ~= nil and taken.itemId == "log" and taken.count == 5, "removeItem: returns the ground item's stack")
	check(ground.itemsById[id] == nil, "removeItem: the ground item is gone from the world")
	check(holds(ground, other, "fish", 2), "removeItem: the others are as they were")
	check(GroundItems.removeItem(ground, id) == nil, "removeItem: nil when no ground item has the id")
	check(groundItemCount(ground) == 1 and ground.nextId == 3, "removeItem: and then nothing changes")
	check(dropAt(ground, ItemStack.new("log", 1), at(9, 0, 0), 0) == 3, "removeItem: the id is not used again")
end

do -- many random drops, moves, pickups and expiries: no item is made, and none is lost except by expiring
	local seed = 20261119
	local function random(limit: number): number
		seed = (seed * 16807) % 2147483647
		return math.floor(seed / 65536) % limit + 1
	end
	local itemIds = { "log", "fish", "stove" }
	local stackSizes: { [string]: number } = { log = 16, fish = 8, stove = 1 }

	local allConserved = true
	local allValid = true
	for _ = 1, 40 do
		local ground = GroundItems.new()
		local packs = { Inventory.new(random(6)), Inventory.new(random(6)) }
		local dropped: { [string]: number } = { log = 0, fish = 0, stove = 0 }
		local expired: { [string]: number } = { log = 0, fish = 0, stove = 0 }
		local now = 0
		for _ = 1, 120 do
			now += random(40) / 2
			local action = random(10)
			if action <= 3 then
				local itemId = itemIds[random(3)]
				local count = random(stackSizes[itemId])
				dropAt(ground, ItemStack.new(itemId, count), at(random(12), 0, random(12)), now)
				dropped[itemId] += count
			elseif action <= 5 then
				moveTo(ground, random(math.max(ground.nextId - 1, 1)), at(random(12), 0, random(12)))
			elseif action <= 9 then
				local pack = packs[random(2)]
				local before = Inventory.countItems(pack, "log")
					+ Inventory.countItems(pack, "fish")
					+ Inventory.countItems(pack, "stove")
				local moved = GroundItems.moveNearbyStacksToInventory(ground, at(random(12), 0, random(12)), pack, now)
				local after = Inventory.countItems(pack, "log")
					+ Inventory.countItems(pack, "fish")
					+ Inventory.countItems(pack, "stove")
				if after - before ~= moved then
					allConserved = false
				end
			else
				local before: { [string]: number } = {}
				for _, itemId in itemIds do
					before[itemId] = itemsOnGround(ground, itemId)
				end
				GroundItems.removeExpiredItems(ground, now)
				for _, itemId in itemIds do
					expired[itemId] += before[itemId] - itemsOnGround(ground, itemId)
				end
			end
			for id, groundItem: GroundItems.GroundItem in ground.itemsById :: any do
				if ItemStack.validate(groundItem.stack) ~= nil or id >= ground.nextId then
					allValid = false
				end
				if now - groundItem.spawnTime >= LIFETIME and action == 10 then
					allValid = false
				end
			end
		end
		for _, itemId in itemIds do
			local inPacks = Inventory.countItems(packs[1], itemId) + Inventory.countItems(packs[2], itemId)
			if dropped[itemId] ~= inPacks + itemsOnGround(ground, itemId) + expired[itemId] then
				allConserved = false
			end
		end
	end
	check(allConserved, "random play: every item dropped is in a pack, on the ground or expired")
	check(allValid, "random play: every ground item holds a real stack under an id already given out")
end

do -- merging the ground items that moved
	local ground = GroundItems.new()
	local lying = GroundItems.spawnStack(ground, ItemStack.new("log", 3), at(10, 0, 0), STILL, 0)
	local far = GroundItems.spawnStack(ground, ItemStack.new("log", 4), at(50, 0, 0), STILL, 5)
	GroundItems.mergeMovedItems(ground)
	check(groundItemCount(ground) == 2, "mergeMovedItems: ground items that are apart stay apart")
	GroundItems.setItemPosition(ground, far, at(10.5, 0, 0))
	check(
		groundItemCount(ground) == 2,
		"setItemPosition: a ground item set beside its own kind does not merge by that alone"
	)
	GroundItems.mergeMovedItems(ground)
	check(
		ground.itemsById[far] == nil and holds(ground, lying, "log", 7),
		"mergeMovedItems: a ground item given a new position beside its own kind merges into it"
	)
	check(
		ground.itemsById[lying].spawnTime == 5,
		"mergeMovedItems: which then counts as spawned at the later of the two times"
	)
	local fresh = GroundItems.spawnStack(ground, ItemStack.new("log", 2), at(10.5, 0, 0), STILL, 9)
	check(groundItemCount(ground) == 2, "spawnStack: a stack spawned beside its own kind does not merge by that alone")
	GroundItems.mergeMovedItems(ground)
	check(
		ground.itemsById[fresh] == nil and holds(ground, lying, "log", 9),
		"mergeMovedItems: a ground item spawned beside its own kind merges into it"
	)

	-- Two that moved to the same place: the one with the lower id is merged first, into the other.
	local pair = GroundItems.new()
	local first = GroundItems.spawnStack(pair, ItemStack.new("log", 3), at(0, 0, 0), STILL, 0)
	local second = GroundItems.spawnStack(pair, ItemStack.new("log", 4), at(0, 0, 0), STILL, 0)
	GroundItems.mergeMovedItems(pair)
	check(
		pair.itemsById[first] == nil and holds(pair, second, "log", 7),
		"mergeMovedItems: of two that moved, the one with the lower id is merged first"
	)

	-- The order holds whatever order the ids are kept in. Thirty single logs with ids 101 to 130 lie
	-- in one place: each merges into the next, the stack is full at the sixteenth, and the rest
	-- gather in the last.
	local many = GroundItems.new()
	for index = 1, 100 do
		GroundItems.spawnStack(many, ItemStack.new("stove", 1), at(500 + index * 10, 0, 500), STILL, 0)
	end
	GroundItems.removeExpiredItems(many, LIFETIME)
	GroundItems.mergeMovedItems(many)
	for _ = 1, 30 do
		GroundItems.spawnStack(many, ItemStack.new("log", 1), at(0, 0, 0), STILL, LIFETIME)
	end
	GroundItems.mergeMovedItems(many)
	check(
		groundItemCount(many) == 2 and holds(many, 116, "log", 16) and holds(many, 130, "log", 14),
		"mergeMovedItems: the ground items that moved are merged in the order of their ids, lowest first"
	)

	-- A ground item that has lain still is not looked at. A full stack and a part stack lie side by
	-- side; some of the full one is then picked up, which leaves room, and moves neither.
	local still = GroundItems.new()
	local full = GroundItems.spawnStack(still, ItemStack.new("log", 16), at(0, 0, 0), STILL, 0)
	local part = GroundItems.spawnStack(still, ItemStack.new("log", 3), at(1, 0, 0), STILL, 0)
	GroundItems.mergeMovedItems(still)
	check(groundItemCount(still) == 2, "mergeMovedItems: (set up) a full stack and a part stack side by side stay two")
	local nearlyFull = Inventory.new(1)
	Inventory.addItems(nearlyFull, "log", 10)
	GroundItems.moveNearbyStacksToInventory(still, at(0, 0, 0), nearlyFull, 10)
	check(holds(still, full, "log", 10) and holds(still, part, "log", 3), "mergeMovedItems: (set up) six are picked up")
	GroundItems.mergeMovedItems(still)
	check(
		groundItemCount(still) == 2,
		"mergeMovedItems: ground items that have lain still are not looked at, though they would now fit in one stack"
	)
	GroundItems.setItemPosition(still, part, at(1, 0, 0))
	GroundItems.mergeMovedItems(still)
	check(
		still.itemsById[part] == nil and holds(still, full, "log", 13),
		"mergeMovedItems: until one of them is given a position again"
	)

	-- An id whose ground item has gone is passed over.
	local gone = GroundItems.new()
	local taken = GroundItems.spawnStack(gone, ItemStack.new("log", 3), at(0, 0, 0), STILL, 0)
	GroundItems.removeItem(gone, taken)
	GroundItems.mergeMovedItems(gone)
	check(groundItemCount(gone) == 0, "mergeMovedItems: a ground item that moved and has since gone is passed over")
	local none = GroundItems.new()
	GroundItems.mergeMovedItems(none)
	check(groundItemCount(none) == 0, "mergeMovedItems: does nothing when nothing has moved")
end

Check.finish("GroundItems")
