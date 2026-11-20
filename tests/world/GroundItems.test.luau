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
local REACH = GroundItems.MERGE_REACH
local WIDTH = GroundItems.ITEM_WIDTH
local CHECK = GroundItems.MERGE_CHECK_SECONDS
local ABOVE = GroundItems.PICKUP_REACH_UP
local BELOW = GroundItems.PICKUP_REACH_DOWN

local function at(x: number, y: number, z: number): GroundItems.Position
	return { x = x, y = y, z = z }
end

-- Spawns `stack` at `position`, not moving, at the time `now`. Returns the ground item's id.
local function dropAt(
	ground: GroundItems.GroundItems,
	stack: ItemStack.ItemStack,
	position: GroundItems.Position,
	now: number
): number
	return GroundItems.spawnStack(ground, stack, position, STILL, now)
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
	check(WIDTH == 1.2, "a ground item takes up a cube 1.2 studs on a side")
	check(
		math.abs(REACH - 3.2) < 1e-9,
		"two ground items of one kind merge when the gap between their sides is less than 2 studs: 3.2 between their positions"
	)
	check(CHECK == 2, "a ground item that lies still is checked again, for merging, every two seconds")
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

do -- merging: how close two ground items must be
	-- Spawns 5 logs at `first` and 3 at `second` and merges once. True if they became one.
	local function mergesBetween(first: GroundItems.Position, second: GroundItems.Position): boolean
		local ground = GroundItems.new()
		dropAt(ground, ItemStack.new("log", 5), first, 0)
		dropAt(ground, ItemStack.new("log", 3), second, 0)
		GroundItems.mergeItems(ground, 0)
		return groundItemCount(ground) == 1 and itemsOnGround(ground, "log") == 8
	end
	local origin = at(0, 0, 0)
	check(mergesBetween(origin, origin), "mergeItems: two of a kind in the same place merge")
	check(
		mergesBetween(origin, at(REACH - 0.01, 0, 0)) and mergesBetween(origin, at(-REACH + 0.01, 0, 0)),
		"mergeItems: two of a kind just less than the reach apart along x merge"
	)
	check(
		not mergesBetween(origin, at(REACH, 0, 0)) and not mergesBetween(origin, at(-REACH, 0, 0)),
		"mergeItems: two exactly the reach apart along x do not"
	)
	check(
		mergesBetween(origin, at(0, 0, REACH - 0.01)) and mergesBetween(origin, at(0, 0, -REACH + 0.01)),
		"mergeItems: two of a kind just less than the reach apart along z merge"
	)
	check(
		not mergesBetween(origin, at(0, 0, REACH)) and not mergesBetween(origin, at(0, 0, -REACH)),
		"mergeItems: two exactly the reach apart along z do not"
	)
	check(
		mergesBetween(origin, at(REACH - 0.01, 0, REACH - 0.01)),
		"mergeItems: the reach is measured along x and along z, each alone, so two in opposite corners of it merge"
	)
	check(
		mergesBetween(origin, at(0, WIDTH - 0.01, 0)) and mergesBetween(origin, at(0, -WIDTH + 0.01, 0)),
		"mergeItems: two of a kind less than a ground item's width apart in height merge"
	)
	check(
		not mergesBetween(origin, at(0, WIDTH, 0)) and not mergesBetween(origin, at(0, -WIDTH, 0)),
		"mergeItems: one that lies a ground item's width above the other does not merge with it"
	)
	check(
		mergesBetween(at(40, 7, -30), at(41, 7.5, -31)),
		"mergeItems: the reach is between the two positions, wherever in the world they are"
	)
	check(
		not mergesBetween(at(10, 0, 0), at(-10, 0, 0))
			and not mergesBetween(at(0, 0, 10), at(0, 0, -10))
			and not mergesBetween(at(0, 10, 0), at(0, -10, 0)),
		"mergeItems: two ground items 10 studs to either side of the world's origin, along any axis, do not merge"
	)
end

do -- merging: the bigger stack takes in the smaller
	-- Each pair is spawned apart and merged once. After that only a ground item that is given a new
	-- position is checked, so the tests choose which of the two it is.
	local ground = GroundItems.new()
	local lying = GroundItems.spawnStack(ground, ItemStack.new("log", 5), at(10, 0, 0), { x = 1, y = 2, z = 3 }, 100)
	local coming = GroundItems.spawnStack(ground, ItemStack.new("log", 3), at(50, 0, 0), { x = 4, y = 5, z = 6 }, 130)
	GroundItems.mergeItems(ground, 130)
	check(
		holds(ground, lying, "log", 5) and holds(ground, coming, "log", 3),
		"mergeItems: ground items of one kind that are apart stay apart"
	)
	GroundItems.setItemPosition(ground, coming, at(11, 0, 0))
	GroundItems.mergeItems(ground, 130)
	check(
		ground.itemsById[coming] == nil and holds(ground, lying, "log", 8),
		"mergeItems: a smaller stack that has come beside a bigger one of its kind is taken in by it"
	)
	check(groundItemCount(ground) == 1 and ground.nextId == 3, "mergeItems: one ground item is left, and no id is used")
	local merged = ground.itemsById[lying]
	check(merged.position.x == 10, "mergeItems: the one that took the other in stays where it is")
	check(
		merged.spawnVelocity.x == 1 and merged.spawnVelocity.y == 2 and merged.spawnVelocity.z == 3,
		"mergeItems: and keeps the velocity it was spawned with"
	)
	check(merged.spawnTime == 130, "mergeItems: and counts as spawned at the later of the two times")
	check(table.isfrozen(merged), "mergeItems: and is still a frozen value")

	local bigger = GroundItems.new()
	local small = dropAt(bigger, ItemStack.new("log", 3), at(10, 0, 0), 100)
	local big = dropAt(bigger, ItemStack.new("log", 5), at(50, 0, 0), 60)
	GroundItems.mergeItems(bigger, 100)
	GroundItems.setItemPosition(bigger, big, at(11, 0, 0))
	GroundItems.mergeItems(bigger, 100)
	check(
		bigger.itemsById[small] == nil and holds(bigger, big, "log", 8),
		"mergeItems: a bigger stack that has come beside a smaller one of its kind takes it in"
	)
	check(bigger.itemsById[big].position.x == 11, "mergeItems: and stays where it has come to")
	check(
		bigger.itemsById[big].spawnTime == 100,
		"mergeItems: and counts as spawned at the later of the two times, though it was spawned at the earlier"
	)

	local equal = GroundItems.new()
	local stays = dropAt(equal, ItemStack.new("log", 4), at(10, 0, 0), 0)
	local goes = dropAt(equal, ItemStack.new("log", 4), at(50, 0, 0), 0)
	GroundItems.mergeItems(equal, 0)
	GroundItems.setItemPosition(equal, goes, at(11, 0, 0))
	GroundItems.mergeItems(equal, 0)
	check(
		equal.itemsById[goes] == nil and holds(equal, stays, "log", 8) and equal.itemsById[stays].position.x == 10,
		"mergeItems: of two stacks of the same size, the one being checked is taken in by the other"
	)
	local equalToo = GroundItems.new()
	local mover = dropAt(equalToo, ItemStack.new("log", 4), at(50, 0, 0), 0)
	local rests = dropAt(equalToo, ItemStack.new("log", 4), at(10, 0, 0), 0)
	GroundItems.mergeItems(equalToo, 0)
	GroundItems.setItemPosition(equalToo, mover, at(11, 0, 0))
	GroundItems.mergeItems(equalToo, 0)
	check(
		equalToo.itemsById[mover] == nil and holds(equalToo, rests, "log", 8),
		"mergeItems: whichever of the two has the lower id"
	)
end

do -- merging: only stacks of the same item that fit in one stack
	local ground = GroundItems.new()
	local twelve = dropAt(ground, ItemStack.new("log", 12), at(0, 0, 0), 0)
	local five = dropAt(ground, ItemStack.new("log", 5), at(1, 0, 0), 0)
	local fish = dropAt(ground, ItemStack.new("fish", 2), at(0, 0, 1), 0)
	GroundItems.mergeItems(ground, 0)
	check(
		holds(ground, twelve, "log", 12) and holds(ground, five, "log", 5),
		"mergeItems: two stacks that would not fit in one stack stay two"
	)
	check(
		holds(ground, fish, "fish", 2) and groundItemCount(ground) == 3,
		"mergeItems: stacks of different items do not merge"
	)
	local four = dropAt(ground, ItemStack.new("log", 4), at(0, 0, -1), 0)
	GroundItems.mergeItems(ground, 0)
	check(
		ground.itemsById[four] == nil and holds(ground, twelve, "log", 16) and holds(ground, five, "log", 5),
		"mergeItems: two stacks that exactly fill one stack merge"
	)
	local stove = dropAt(ground, ItemStack.new("stove", 1), at(20, 0, 0), 0)
	local otherStove = dropAt(ground, ItemStack.new("stove", 1), at(20, 0, 0), 0)
	GroundItems.mergeItems(ground, 0)
	check(
		holds(ground, stove, "stove", 1) and holds(ground, otherStove, "stove", 1),
		"mergeItems: an item that does not stack never merges"
	)
end

do -- merging: the one being checked is tried with each one in reach, the nearest first
	-- Two ground items lie too far apart to merge with each other, the nearer 2 studs one way and
	-- the farther 3 studs the other way from where a third is then spawned. Only the third is
	-- checked. Returns the ground items, and the ids of the nearer, the farther and the third.
	local function newThree(
		nearerCount: number,
		fartherCount: number,
		thirdCount: number
	): (GroundItems.GroundItems, number, number, number)
		local ground = GroundItems.new()
		local farther = dropAt(ground, ItemStack.new("log", fartherCount), at(3, 0, 0), 0)
		local nearer = dropAt(ground, ItemStack.new("log", nearerCount), at(-2, 0, 0), 0)
		GroundItems.mergeItems(ground, 0)
		local third = dropAt(ground, ItemStack.new("log", thirdCount), at(0, 0, 0), 0)
		GroundItems.mergeItems(ground, 0)
		return ground, nearer, farther, third
	end

	local both, bothNearer, bothFarther, bothThird = newThree(2, 3, 6)
	check(
		holds(both, bothThird, "log", 11) and both.itemsById[bothNearer] == nil and both.itemsById[bothFarther] == nil,
		"mergeItems: a ground item takes in every smaller one of its kind in reach"
	)
	check(both.itemsById[bothThird].position.x == 0, "mergeItems: and stays where it is")

	local into, intoNearer, intoFarther, intoThird = newThree(5, 3, 2)
	check(
		into.itemsById[intoThird] == nil and holds(into, intoNearer, "log", 7) and holds(into, intoFarther, "log", 3),
		"mergeItems: a ground item that is taken in is tried with nothing more, and the nearest is the one that takes it"
	)

	local onward, onwardNearer, onwardFarther, onwardThird = newThree(2, 9, 3)
	check(
		holds(onward, onwardFarther, "log", 14)
			and onward.itemsById[onwardNearer] == nil
			and onward.itemsById[onwardThird] == nil,
		"mergeItems: a ground item that took in the nearest is tried with the next with what it then holds"
	)

	local past, pastNearer, pastFarther, pastThird = newThree(8, 4, 10)
	check(
		holds(past, pastThird, "log", 14) and holds(past, pastNearer, "log", 8) and past.itemsById[pastFarther] == nil,
		"mergeItems: one that does not fit is passed over for the next nearest"
	)

	-- Of two equally near, the lower id is tried first, in whatever order the ids are kept.
	local tied = GroundItems.new()
	for index = 1, 60 do
		dropAt(tied, ItemStack.new("fish", 1), at(index * 10, 0, 500), 0)
	end
	GroundItems.removeExpiredItems(tied, LIFETIME)
	local allLowest = true
	for round = 1, 20 do
		local x = round * 100
		local left = dropAt(tied, ItemStack.new("log", 12), at(x - 2, 0, 0), LIFETIME)
		local right = dropAt(tied, ItemStack.new("log", 12), at(x + 2, 0, 0), LIFETIME)
		GroundItems.mergeItems(tied, LIFETIME)
		dropAt(tied, ItemStack.new("log", 4), at(x, 0, 0), LIFETIME)
		GroundItems.mergeItems(tied, LIFETIME)
		if not (holds(tied, left, "log", 16) and holds(tied, right, "log", 12)) then
			allLowest = false
		end
	end
	check(allLowest, "mergeItems: of two equally near, the one with the lower id is tried first")
end

do -- merging: which ground items are checked
	-- A full stack and a part stack lie side by side. Six of the full one are then picked up, which
	-- leaves room for the part stack and gives neither a new position.
	local ground = GroundItems.new()
	local full = dropAt(ground, ItemStack.new("log", 16), at(0, 0, 0), 0)
	local part = dropAt(ground, ItemStack.new("log", 3), at(1, 0, 0), 1)
	GroundItems.mergeItems(ground, 1)
	check(groundItemCount(ground) == 2, "mergeItems: (set up) a full stack and a part stack side by side stay two")
	local nearlyFull = Inventory.new(1)
	Inventory.addItems(nearlyFull, "log", 10)
	GroundItems.moveNearbyStacksToInventory(ground, at(0, 0, 0), nearlyFull, 1.6)
	check(holds(ground, full, "log", 10) and holds(ground, part, "log", 3), "mergeItems: (set up) six are picked up")
	GroundItems.mergeItems(ground, 1.6)
	GroundItems.mergeItems(ground, 1.99)
	check(
		groundItemCount(ground) == 2,
		"mergeItems: a ground item that has lain still is not checked again before its two seconds are up"
	)
	GroundItems.mergeItems(ground, 2)
	check(
		ground.itemsById[part] == nil and holds(ground, full, "log", 13),
		"mergeItems: a ground item is checked again once it has been in the world for two seconds"
	)

	-- The two seconds are counted from when each was spawned: the full stack is checked again at
	-- the times 2 and 4, and the part stack at the times 3 and 5.
	local phased = GroundItems.new()
	local phasedFull = dropAt(phased, ItemStack.new("log", 16), at(0, 0, 0), 0)
	local phasedPart = dropAt(phased, ItemStack.new("log", 3), at(1, 0, 0), 1)
	GroundItems.mergeItems(phased, 2)
	local phasedPack = Inventory.new(1)
	Inventory.addItems(phasedPack, "log", 10)
	GroundItems.moveNearbyStacksToInventory(phased, at(0, 0, 0), phasedPack, 2.1)
	GroundItems.mergeItems(phased, 2.99)
	check(
		holds(phased, phasedFull, "log", 10) and holds(phased, phasedPart, "log", 3),
		"mergeItems: a ground item is not checked again between one of its two seconds and the next"
	)
	GroundItems.mergeItems(phased, 3)
	check(
		phased.itemsById[phasedPart] == nil and holds(phased, phasedFull, "log", 13),
		"mergeItems: the two seconds are counted from when each ground item was spawned"
	)

	-- The two seconds are counted from a spawn time that is not a whole number just the same. The
	-- times here are ones a number holds exactly, so that the edge falls where the test says.
	local quarter = GroundItems.new()
	local quarterFull = dropAt(quarter, ItemStack.new("log", 16), at(0, 0, 0), 0.25)
	local quarterPart = dropAt(quarter, ItemStack.new("log", 3), at(1, 0, 0), 0.25)
	GroundItems.mergeItems(quarter, 0.25)
	local quarterPack = Inventory.new(1)
	Inventory.addItems(quarterPack, "log", 10)
	GroundItems.moveNearbyStacksToInventory(quarter, at(-RADIUS, 0, 0), quarterPack, 0.25 + DELAY)
	GroundItems.mergeItems(quarter, 2.125)
	check(
		holds(quarter, quarterFull, "log", 10) and holds(quarter, quarterPart, "log", 3),
		"mergeItems: a ground item spawned at a quarter past is not checked again an eighth of a second early"
	)
	GroundItems.mergeItems(quarter, 2.25)
	check(
		groundItemCount(quarter) == 1 and itemsOnGround(quarter, "log") == 13,
		"mergeItems: and is checked again two seconds after it was spawned, to the moment"
	)

	-- A time no later than the last one checks nothing that lies still.
	local back = GroundItems.new()
	local backFull = dropAt(back, ItemStack.new("log", 16), at(0, 0, 0), 0)
	local backPart = dropAt(back, ItemStack.new("log", 3), at(1, 0, 0), 0)
	GroundItems.mergeItems(back, 9)
	local backPack = Inventory.new(1)
	Inventory.addItems(backPack, "log", 10)
	GroundItems.moveNearbyStacksToInventory(back, at(-RADIUS, 0, 0), backPack, 9)
	GroundItems.mergeItems(back, 9)
	check(
		holds(back, backFull, "log", 10) and holds(back, backPart, "log", 3),
		"mergeItems: given the same time again, it checks no ground item that lies still"
	)
	GroundItems.mergeItems(back, 4)
	check(
		holds(back, backFull, "log", 10) and holds(back, backPart, "log", 3),
		"mergeItems: given an earlier time, it checks no ground item that lies still"
	)
	local backSpawned = dropAt(back, ItemStack.new("log", 2), at(1, 0, 0), 4)
	GroundItems.mergeItems(back, 3)
	check(
		back.itemsById[backSpawned] == nil and holds(back, backPart, "log", 5),
		"mergeItems: given an earlier time, it still checks one that was spawned since"
	)
	GroundItems.mergeItems(back, 5)
	check(
		groundItemCount(back) == 1 and itemsOnGround(back, "log") == 15,
		"mergeItems: and when time goes on again, the ones that lie still are checked as before"
	)

	-- One that was spawned since the last run is checked whatever the time. The one it lies
	-- beside is not, and is merged with all the same.
	local fresh = GroundItems.new()
	local lyingStill = dropAt(fresh, ItemStack.new("log", 5), at(0, 0, 0), 0)
	GroundItems.mergeItems(fresh, 0.5)
	local spawned = dropAt(fresh, ItemStack.new("log", 3), at(1, 0, 0), 0.5)
	GroundItems.mergeItems(fresh, 0.5)
	check(
		fresh.itemsById[spawned] == nil and holds(fresh, lyingStill, "log", 8),
		"mergeItems: a ground item that was spawned since the last run is checked, whatever the time"
	)

	-- Of the ground items that are checked, the one with the lower id is checked first.
	local pair = GroundItems.new()
	local first = dropAt(pair, ItemStack.new("log", 3), at(0, 0, 0), 0)
	local second = dropAt(pair, ItemStack.new("log", 3), at(0, 0, 0), 0)
	GroundItems.mergeItems(pair, 0)
	check(
		pair.itemsById[first] == nil and holds(pair, second, "log", 6),
		"mergeItems: of two stacks of the same size that are both checked, the one with the lower id goes"
	)
	local unequal = GroundItems.new()
	local five = dropAt(unequal, ItemStack.new("log", 5), at(0, 0, 0), 0)
	local three = dropAt(unequal, ItemStack.new("log", 3), at(0, 0, 0), 0)
	GroundItems.mergeItems(unequal, 0)
	check(
		unequal.itemsById[three] == nil and holds(unequal, five, "log", 8),
		"mergeItems: a ground item that was taken in before its turn is passed over"
	)

	-- The order holds whatever order the ids are kept in. Thirty single logs with ids 101 to 130 lie
	-- in one place. The first is taken in by the second, which then takes in the next fourteen and
	-- is full. The same happens from the seventeenth on.
	local many = GroundItems.new()
	for index = 1, 100 do
		dropAt(many, ItemStack.new("stove", 1), at(500 + index * 10, 0, 500), 0)
	end
	GroundItems.removeExpiredItems(many, LIFETIME)
	GroundItems.mergeItems(many, LIFETIME)
	for _ = 1, 30 do
		dropAt(many, ItemStack.new("log", 1), at(0, 0, 0), LIFETIME)
	end
	GroundItems.mergeItems(many, LIFETIME)
	check(
		groundItemCount(many) == 2 and holds(many, 102, "log", 16) and holds(many, 118, "log", 14),
		"mergeItems: the ground items are checked in the order of their ids, lowest first"
	)

	local gone = GroundItems.new()
	local taken = dropAt(gone, ItemStack.new("log", 3), at(0, 0, 0), 0)
	GroundItems.removeItem(gone, taken)
	GroundItems.mergeItems(gone, 0)
	check(groundItemCount(gone) == 0, "mergeItems: a ground item that was spawned and has since gone is passed over")
	local none = GroundItems.new()
	GroundItems.mergeItems(none, 0)
	check(groundItemCount(none) == 0 and none.nextId == 1, "mergeItems: does nothing when nothing is on the ground")
end

do -- merging: a ground item that took another in is as new as the newer of the two
	local ground = GroundItems.new()
	local pack = Inventory.new(3)
	local older = dropAt(ground, ItemStack.new("log", 5), at(0, 0, 0), 0)
	dropAt(ground, ItemStack.new("log", 1), at(0, 0, 0), 100)
	GroundItems.mergeItems(ground, 100)
	check(
		groundItemCount(ground) == 1 and holds(ground, older, "log", 6),
		"mergeItems: (set up) the older, bigger stack takes in the newer"
	)
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(1, 0, 0), pack, 100 + DELAY - 0.01) == 0,
		"mergeItems: a ground item that took in a newer one cannot be picked up until the newer one could have been"
	)
	GroundItems.removeExpiredItems(ground, LIFETIME + 50)
	check(holds(ground, older, "log", 6), "mergeItems: and lasts as long as the newer one would have")
	check(
		GroundItems.moveNearbyStacksToInventory(ground, at(1, 0, 0), pack, 100 + DELAY) == 6,
		"mergeItems: and is picked up whole"
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

do -- many random drops, moves, merges, pickups and expiries: no item is made, and none is lost except by expiring
	local seed = 20261119
	local function random(limit: number): number
		seed = (seed * 16807) % 2147483647
		return math.floor(seed / 65536) % limit + 1
	end
	local itemIds = { "log", "fish", "stove" }
	local stackSizes: { [string]: number } = { log = 16, fish = 8, stove = 1 }

	-- True if two ground items are of the same item, fit in one stack, and are in reach of each other.
	local function couldMerge(one: GroundItems.GroundItem, other: GroundItems.GroundItem): boolean
		return one.stack.itemId == other.stack.itemId
			and one.stack.count + other.stack.count <= stackSizes[one.stack.itemId]
			and math.abs(one.position.x - other.position.x) < REACH
			and math.abs(one.position.z - other.position.z) < REACH
			and math.abs(one.position.y - other.position.y) < WIDTH
	end

	-- True if no two ground items could merge.
	local function isMergedThrough(ground: GroundItems.GroundItems): boolean
		for id, groundItem: GroundItems.GroundItem in ground.itemsById :: any do
			for otherId, other: GroundItems.GroundItem in ground.itemsById :: any do
				if id ~= otherId and couldMerge(groundItem, other) then
					return false
				end
			end
		end
		return true
	end

	local allConserved = true
	local allValid = true
	local allMerged = true
	for _ = 1, 40 do
		local ground = GroundItems.new()
		local packs = { Inventory.new(random(6)), Inventory.new(random(6)) }
		local dropped: { [string]: number } = { log = 0, fish = 0, stove = 0 }
		local expired: { [string]: number } = { log = 0, fish = 0, stove = 0 }
		local now = 0
		for _ = 1, 120 do
			now += random(40) / 4
			local action = random(10)
			if action <= 3 then
				local itemId = itemIds[random(3)]
				local count = random(stackSizes[itemId])
				dropAt(ground, ItemStack.new(itemId, count), at(random(12), random(3) * 0.75, random(12)), now)
				dropped[itemId] += count
			elseif action <= 5 then
				local to = at(random(12), random(3) * 0.75, random(12))
				GroundItems.setItemPosition(ground, random(math.max(ground.nextId - 1, 1)), to)
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
			local onGroundBefore: { [string]: number } = {}
			for _, itemId in itemIds do
				onGroundBefore[itemId] = itemsOnGround(ground, itemId)
			end
			GroundItems.mergeItems(ground, now)
			for _, itemId in itemIds do
				if itemsOnGround(ground, itemId) ~= onGroundBefore[itemId] then
					allConserved = false
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
		GroundItems.mergeItems(ground, now + CHECK)
		if not isMergedThrough(ground) then
			allMerged = false
		end
	end
	check(allConserved, "random play: every item dropped is in a pack, on the ground or expired")
	check(allValid, "random play: every ground item holds a real stack under an id already given out")
	check(
		allMerged,
		"random play: two seconds after the last change, no two ground items in reach of each other would fit in one stack"
	)
end

Check.finish("GroundItems")
