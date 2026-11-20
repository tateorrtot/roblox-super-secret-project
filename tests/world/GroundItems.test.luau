--!strict
-- Tests for GroundItems. Run from the repository root: lune run tests/world/GroundItems.test.luau

local Check = require("../Check")
local GroundItems = require("../../src/shared/world/GroundItems")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local Throw = require("../../src/shared/Throw")

local check = Check.that

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "stove", stackSize = 1 })

local DELAY = GroundItems.PICKUP_DELAY_SECONDS
local RADIUS = GroundItems.PICKUP_RADIUS
local LIFETIME = GroundItems.LIFETIME_SECONDS
local MERGE = GroundItems.MERGE_RADIUS
local ABOVE = GroundItems.PICKUP_HEIGHT_ABOVE
local BELOW = GroundItems.PICKUP_HEIGHT_BELOW

local function at(x: number, y: number, z: number): GroundItems.Position
	return { x = x, y = y, z = z }
end

-- Throws `stack` with no speed from `position`, and returns the id of the ground item that holds it.
local function dropAt(
	ground: GroundItems.GroundItems,
	stack: ItemStack.ItemStack,
	position: GroundItems.Position,
	now: number
): number
	return GroundItems.throwStack(ground, stack, Throw.newAtRest(position), now)
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
	check(GroundItems.ITEM_SIZE == 1.2, "a ground item takes up a cube 1.2 studs on a side")
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
	GroundItems.removeExpiredStacks(ground, 1000)
	check(
		groundItemCount(ground) == 0 and ground.nextId == 1,
		"removeExpiredStacks: does nothing when nothing is on the ground"
	)
end

do -- dropping
	local ground = GroundItems.new()
	local logs = ItemStack.new("log", 5)
	local where = { x = 10, y = 2, z = -3 }
	local id = dropAt(ground, logs, where, 12)
	check(id == 1, "throwStack: the first ground item is number 1")
	check(ground.nextId == 2, "throwStack: the next one will be number 2")
	local groundItem = ground.itemsById[1]
	check(
		groundItem ~= nil and groundItem.stack.itemId == "log" and groundItem.stack.count == 5,
		"throwStack: the ground item holds the stack"
	)
	check(
		groundItem.position.x == 10 and groundItem.position.y == 2 and groundItem.position.z == -3,
		"throwStack: it lies where it was dropped"
	)
	check(groundItem.droppedAt == 12, "throwStack: it remembers when it was dropped")
	check(
		groundItem.throw.from.x == 10 and groundItem.throw.velocity.y == 0,
		"throwStack: and the throw it set off with"
	)
	where.x = 99
	check(
		ground.itemsById[1].position.x == 10,
		"throwStack: changing the caller's position table afterwards does not move it"
	)
	check(
		table.isfrozen(groundItem) and table.isfrozen(groundItem.position),
		"throwStack: a ground item is a frozen value"
	)

	local second = dropAt(ground, ItemStack.new("fish", 2), at(0, 0, 0), 13)
	check(second == 2 and ground.nextId == 3, "throwStack: ids count up")
	check(groundItemCount(ground) == 2, "throwStack: both are on the ground")
end

do -- a stack dropped beside its own kind joins it
	local ground = GroundItems.new()
	local first = dropAt(ground, ItemStack.new("log", 5), at(10, 0, 0), 100)
	local joined = dropAt(ground, ItemStack.new("log", 3), at(10 + MERGE, 0, 0), 130)
	check(joined == first, "throwStack: returns the id of the ground item the stack joined")
	check(
		groundItemCount(ground) == 1 and holds(ground, first, "log", 8),
		"throwStack: the ground item holds both stacks"
	)
	check(ground.nextId == 2, "throwStack: joining uses no new id")
	check(ground.itemsById[first].position.x == 10, "throwStack: the ground item stays where it lay")
	check(ground.itemsById[first].droppedAt == 130, "throwStack: and counts as dropped when the second stack was")
	check(table.isfrozen(ground.itemsById[first]), "throwStack: the joined ground item is a frozen value")

	local beyond = dropAt(ground, ItemStack.new("log", 1), at(10 + MERGE + 0.01, 0, 0), 130)
	check(
		beyond == 2 and holds(ground, first, "log", 8),
		"throwStack: a stack dropped just beyond the radius lies apart"
	)
	local above = dropAt(ground, ItemStack.new("log", 1), at(10, MERGE + 0.01, 0), 130)
	check(above == 3 and holds(ground, first, "log", 8), "throwStack: height counts towards the distance")

	local other = dropAt(ground, ItemStack.new("fish", 2), at(10, 0, 0), 130)
	check(other == 4 and holds(ground, first, "log", 8), "throwStack: a different item does not join")

	local full = GroundItems.new()
	dropAt(full, ItemStack.new("log", 12), at(0, 0, 0), 0)
	local apart = dropAt(full, ItemStack.new("log", 5), at(0, 0, 0), 0)
	check(
		apart == 2 and holds(full, 1, "log", 12) and holds(full, 2, "log", 5),
		"throwStack: a stack that does not wholly fit lies apart"
	)
	check(dropAt(full, ItemStack.new("log", 4), at(0, 0, 0), 0) == 1, "throwStack: a stack that exactly fills joins")
	check(holds(full, 1, "log", 16), "throwStack: and the ground item is a full stack")
	check(dropAt(full, ItemStack.new("stove", 1), at(5, 0, 0), 0) == 3, "throwStack: a stove lies on the ground")
	check(
		dropAt(full, ItemStack.new("stove", 1), at(5, 0, 0), 0) == 4,
		"throwStack: an item that does not stack never joins"
	)

	local choice = GroundItems.new()
	local farther = dropAt(choice, ItemStack.new("log", 1), at(-1.2, 0, 0), 0)
	local nearer = dropAt(choice, ItemStack.new("log", 1), at(0.5, 0, 0), 0)
	check(dropAt(choice, ItemStack.new("log", 1), at(0, 0, 0), 0) == nearer, "throwStack: joins the nearest of two")
	check(
		holds(choice, farther, "log", 1) and holds(choice, nearer, "log", 2),
		"throwStack: and leaves the farther as it was"
	)

	local tied = GroundItems.new()
	for index = 1, 60 do
		dropAt(tied, ItemStack.new("fish", 1), at(index * 10, 0, 500), 0)
	end
	GroundItems.removeExpiredStacks(tied, LIFETIME)
	local allFirst = true
	for round = 1, 20 do
		local x = round * 100
		local left = dropAt(tied, ItemStack.new("log", 1), at(x - 1, 0, 0), LIFETIME)
		dropAt(tied, ItemStack.new("log", 1), at(x + 1, 0, 0), LIFETIME)
		if dropAt(tied, ItemStack.new("log", 1), at(x, 0, 0), LIFETIME) ~= left then
			allFirst = false
		end
	end
	check(allFirst, "throwStack: of two equally near, joins the one dropped first, whatever their ids")

	local delayed = GroundItems.new()
	local pack = Inventory.new(3)
	dropAt(delayed, ItemStack.new("log", 5), at(0, 0, 0), 0)
	dropAt(delayed, ItemStack.new("log", 1), at(0, 0, 0), 100)
	check(
		GroundItems.moveNearbyStacksToInventory(delayed, at(1, 0, 0), pack, 100 + DELAY - 0.01) == 0,
		"throwStack: a ground item that was joined cannot be picked up straight away"
	)
	GroundItems.removeExpiredStacks(delayed, LIFETIME + 50)
	check(holds(delayed, 1, "log", 6), "throwStack: a ground item that was joined lasts from when it was joined")
	check(
		GroundItems.moveNearbyStacksToInventory(delayed, at(1, 0, 0), pack, 100 + DELAY) == 6,
		"throwStack: and is picked up whole"
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
		"throwStack: a new ground item gets a new id"
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
	GroundItems.removeExpiredStacks(ground, LIFETIME)
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
		rest.position.x == 2 and rest.droppedAt == 5,
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
	GroundItems.removeExpiredStacks(ground, 100 + LIFETIME - 0.01)
	check(groundItemCount(ground) == 2, "removeExpiredStacks: nothing goes before its time")
	GroundItems.removeExpiredStacks(ground, 100 + LIFETIME)
	check(ground.itemsById[1] == nil, "removeExpiredStacks: a ground item is gone once it has lain for the lifetime")
	check(holds(ground, 2, "fish", 2), "removeExpiredStacks: a younger one stays")
	check(ground.nextId == 3, "removeExpiredStacks: ids are not used again")
	GroundItems.removeExpiredStacks(ground, 100000)
	check(groundItemCount(ground) == 0, "removeExpiredStacks: in the end everything goes")

	local partly = GroundItems.new()
	local pack = Inventory.new(1)
	Inventory.addItems(pack, "log", 10)
	dropAt(partly, ItemStack.new("log", 16), at(0, 0, 0), 0)
	GroundItems.moveNearbyStacksToInventory(partly, at(0, 0, 0), pack, LIFETIME - 1)
	GroundItems.removeExpiredStacks(partly, LIFETIME)
	check(
		groundItemCount(partly) == 0,
		"removeExpiredStacks: picking part of a ground item up does not make the rest last longer"
	)
end

do -- thrown with speed
	local ground = GroundItems.new()
	local throw = Throw.newFromCharacter(at(10, 2, -3), { x = 1, z = 0 })
	local id = GroundItems.throwStack(ground, ItemStack.new("log", 5), throw, 12)
	local groundItem = ground.itemsById[id]
	check(groundItem.throw == throw, "throwStack: the ground item keeps the throw it was given")
	check(
		groundItem.position.x == 10 and groundItem.position.y == 2 + Throw.CHARACTER_THROW_HEIGHT,
		"throwStack: it starts where the throw leaves from"
	)
	check(table.isfrozen(groundItem), "throwStack: a thrown ground item is a frozen value")

	local beside = GroundItems.throwStack(ground, ItemStack.new("log", 3), throw, 20)
	check(
		beside == id and holds(ground, id, "log", 8),
		"throwStack: a stack thrown from where its own kind still is joins it"
	)
	local onFloor = GroundItems.throwStack(ground, ItemStack.new("log", 3), Throw.newAtRest(at(10, 2, -3)), 20)
	check(onFloor ~= id, "throwStack: joining goes by where the throw leaves from, not by where the thrower stands")
end

do -- moving
	local ground = GroundItems.new()
	local throw = Throw.newFromCharacter(at(0, 0, 0), { x = 1, z = 0 })
	local id = GroundItems.throwStack(ground, ItemStack.new("log", 5), throw, 12)
	local before = ground.itemsById[id]
	local to = { x = 6, y = 0.5, z = 1 }
	GroundItems.moveItemTo(ground, id, to)
	local moved = ground.itemsById[id]
	check(
		moved.position.x == 6 and moved.position.y == 0.5 and moved.position.z == 1,
		"moveItemTo: the ground item is where it was said to have got to"
	)
	check(
		moved.stack == before.stack and moved.throw == throw and moved.droppedAt == 12,
		"moveItemTo: its stack, its throw and the time it was dropped are as they were"
	)
	check(before.position.x == 0, "moveItemTo: the ground item it replaced is unchanged")
	check(
		table.isfrozen(moved) and table.isfrozen(moved.position),
		"moveItemTo: the moved ground item is a frozen value"
	)
	to.x = 99
	check(
		ground.itemsById[id].position.x == 6,
		"moveItemTo: changing the caller's position table afterwards does not move it"
	)
	check(ground.nextId == 2 and groundItemCount(ground) == 1, "moveItemTo: moving uses no new id")

	GroundItems.moveItemTo(ground, 77, at(1, 1, 1))
	check(
		groundItemCount(ground) == 1 and ground.itemsById[77] == nil,
		"moveItemTo: does nothing when no ground item has the id"
	)

	local pack = Inventory.new(3)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(0, 0, 0), pack, 100) == 0,
		"moveItemTo: a ground item that has moved away is not picked up where it was thrown from"
	)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(6, 0, 0), pack, 100) == 5,
		"moveItemTo: it is picked up where it has got to"
	)
end

do -- two of one kind that come together become one
	local ground = GroundItems.new()
	local lying = dropAt(ground, ItemStack.new("log", 5), at(10, 0, 0), 100)
	local flying = dropAt(ground, ItemStack.new("log", 3), at(0, 3, 0), 130)
	GroundItems.moveItemTo(ground, flying, at(10 - MERGE - 0.01, 0, 0))
	check(
		holds(ground, lying, "log", 5) and holds(ground, flying, "log", 3),
		"moveItemTo: two of a kind just beyond the radius of each other stay two"
	)
	GroundItems.moveItemTo(ground, flying, at(10 - MERGE, 0, 0))
	check(ground.itemsById[flying] == nil, "moveItemTo: the ground item that came near is gone")
	check(holds(ground, lying, "log", 8), "moveItemTo: the one it came near holds both stacks")
	check(ground.itemsById[lying].position.x == 10, "moveItemTo: and stays where it was")
	check(ground.itemsById[lying].droppedAt == 130, "moveItemTo: and counts as dropped at the later of the two times")
	check(table.isfrozen(ground.itemsById[lying]), "moveItemTo: the joined ground item is a frozen value")
	check(groundItemCount(ground) == 1 and itemsOnGround(ground, "log") == 8, "moveItemTo: no item is made or lost")

	local older = GroundItems.new()
	local first = dropAt(older, ItemStack.new("log", 5), at(0, 0, 0), 50)
	local second = dropAt(older, ItemStack.new("log", 3), at(20, 0, 0), 90)
	GroundItems.moveItemTo(older, first, at(20, 0, 0))
	check(
		older.itemsById[first] == nil and holds(older, second, "log", 8) and older.itemsById[second].droppedAt == 90,
		"moveItemTo: when the older one moves, it still joins the other, which keeps the later time"
	)

	local apart = GroundItems.new()
	local logs = dropAt(apart, ItemStack.new("log", 12), at(0, 0, 0), 0)
	local more = dropAt(apart, ItemStack.new("log", 5), at(20, 0, 0), 0)
	local fish = dropAt(apart, ItemStack.new("fish", 2), at(40, 0, 0), 0)
	GroundItems.moveItemTo(apart, more, at(0, 0, 0))
	check(
		holds(apart, logs, "log", 12) and holds(apart, more, "log", 5),
		"moveItemTo: two that would not fit in one stack stay two"
	)
	check(apart.itemsById[more].position.x == 0, "moveItemTo: and the one that moved lies where it got to")
	GroundItems.moveItemTo(apart, fish, at(0, 0, 0))
	check(holds(apart, fish, "fish", 2) and groundItemCount(apart) == 3, "moveItemTo: a different item does not join")
	GroundItems.moveItemTo(apart, more, at(0, MERGE + 0.01, 0))
	local four = dropAt(apart, ItemStack.new("log", 4), at(20, 0, 0), 0)
	GroundItems.moveItemTo(apart, four, at(0, 0, 0))
	check(
		apart.itemsById[four] == nil and holds(apart, logs, "log", 16) and holds(apart, more, "log", 5),
		"moveItemTo: of two it could join, it joins the nearer"
	)

	local tied = GroundItems.new()
	local left = dropAt(tied, ItemStack.new("log", 1), at(-1, 0, 0), 0)
	local right = dropAt(tied, ItemStack.new("log", 1), at(1, 0, 0), 0)
	local between = dropAt(tied, ItemStack.new("log", 1), at(0, 20, 0), 0)
	GroundItems.moveItemTo(tied, between, at(0, 0, 0))
	check(
		holds(tied, left, "log", 2) and holds(tied, right, "log", 1),
		"moveItemTo: of two equally near, it joins the one thrown first"
	)

	local still = GroundItems.new()
	local alone = dropAt(still, ItemStack.new("log", 5), at(0, 0, 0), 0)
	GroundItems.moveItemTo(still, alone, at(0, 0, 0))
	check(holds(still, alone, "log", 5), "moveItemTo: a ground item does not join itself")
end

do -- taking one out of the world
	local ground = GroundItems.new()
	local id = dropAt(ground, ItemStack.new("log", 5), at(0, 0, 0), 0)
	local other = dropAt(ground, ItemStack.new("fish", 2), at(0, 0, 0), 0)
	local taken = GroundItems.takeStack(ground, id)
	check(taken ~= nil and taken.itemId == "log" and taken.count == 5, "takeStack: returns the ground item's stack")
	check(ground.itemsById[id] == nil, "takeStack: the ground item is gone from the world")
	check(holds(ground, other, "fish", 2), "takeStack: the others are as they were")
	check(GroundItems.takeStack(ground, id) == nil, "takeStack: nil when no ground item has the id")
	check(groundItemCount(ground) == 1 and ground.nextId == 3, "takeStack: and then nothing changes")
	check(dropAt(ground, ItemStack.new("log", 1), at(9, 0, 0), 0) == 3, "takeStack: the id is not used again")
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
				GroundItems.moveItemTo(ground, random(math.max(ground.nextId - 1, 1)), at(random(12), 0, random(12)))
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
				GroundItems.removeExpiredStacks(ground, now)
				for _, itemId in itemIds do
					expired[itemId] += before[itemId] - itemsOnGround(ground, itemId)
				end
			end
			for id, groundItem: GroundItems.GroundItem in ground.itemsById :: any do
				if ItemStack.validate(groundItem.stack) ~= nil or id >= ground.nextId then
					allValid = false
				end
				if now - groundItem.droppedAt >= LIFETIME and action == 10 then
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

Check.finish("GroundItems")
