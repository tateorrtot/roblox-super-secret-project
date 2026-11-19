--!strict
-- Tests for GroundItems. Run from the repository root: lune run tests/world/GroundItems.test.luau

local Check = require("../Check")
local GroundItems = require("../../src/shared/world/GroundItems")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")

local check = Check.that
local raises = Check.raises

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "stove", stackSize = 1 })

local DELAY = GroundItems.PICKUP_DELAY
local RADIUS = GroundItems.PICKUP_RADIUS
local LIFETIME = GroundItems.LIFETIME
local MERGE = GroundItems.MERGE_RADIUS

local function at(x: number, y: number, z: number): GroundItems.Position
	return { x = x, y = y, z = z }
end

-- How many ground items there are.
local function groundItemCount(ground: GroundItems.GroundItems): number
	local count = 0
	for _ in ground.byId :: any do
		count += 1
	end
	return count
end

-- How many of one item lie on the ground, over every ground item.
local function itemsOnGround(ground: GroundItems.GroundItems, itemId: string): number
	local count = 0
	for _, groundItem: GroundItems.GroundItem in ground.byId :: any do
		if groundItem.stack.itemId == itemId then
			count += groundItem.stack.count
		end
	end
	return count
end

-- True if the ground item `id` is `count` of the item `itemId`.
local function holds(ground: GroundItems.GroundItems, id: number, itemId: string, count: number): boolean
	local groundItem = ground.byId[id]
	return groundItem ~= nil and groundItem.stack.itemId == itemId and groundItem.stack.count == count
end

do -- the rules as numbers
	check(LIFETIME == 300, "a ground item lies for five minutes")
	check(DELAY == 1.5, "a ground item cannot be picked up for its first second and a half")
	check(RADIUS == 4, "a ground item is picked up from 4 studs away")
	check(MERGE == 1.5, "a stack dropped within a stud and a half of its own kind joins it")
end

do -- nothing on the ground
	local ground = GroundItems.new()
	check(ground.nextId == 1, "new: the first ground item will be number 1")
	check(groundItemCount(ground) == 0, "new: nothing is on the ground")
	local pack = Inventory.new(3)
	check(GroundItems.pickUpNear(ground, at(0, 0, 0), pack, 100) == 0, "pickUpNear: 0 when nothing is on the ground")
	check(Inventory.isEmpty(pack), "pickUpNear: and the inventory is as it was")
	GroundItems.expire(ground, 1000)
	check(groundItemCount(ground) == 0 and ground.nextId == 1, "expire: does nothing when nothing is on the ground")
end

do -- dropping
	local ground = GroundItems.new()
	local logs = ItemStack.new("log", 5)
	local where = { x = 10, y = 2, z = -3 }
	local id = GroundItems.drop(ground, logs, where, 12)
	check(id == 1, "drop: the first ground item is number 1")
	check(ground.nextId == 2, "drop: the next one will be number 2")
	local groundItem = ground.byId[1]
	check(groundItem ~= nil and ItemStack.equals(groundItem.stack, logs), "drop: the ground item holds the stack")
	check(
		groundItem.position.x == 10 and groundItem.position.y == 2 and groundItem.position.z == -3,
		"drop: it lies where it was dropped"
	)
	check(groundItem.droppedAt == 12, "drop: it remembers when it was dropped")
	where.x = 99
	check(ground.byId[1].position.x == 10, "drop: changing the caller's position table afterwards does not move it")
	check(table.isfrozen(groundItem) and table.isfrozen(groundItem.position), "drop: a ground item is a frozen value")

	local second = GroundItems.drop(ground, ItemStack.new("fish", 2), at(0, 0, 0), 13)
	check(second == 2 and ground.nextId == 3, "drop: ids count up")
	check(groundItemCount(ground) == 2, "drop: both are on the ground")

	local handWritten = { itemId = "log", count = 3 }
	local third = GroundItems.drop(ground, handWritten, at(1, 0, 1), 14)
	check(
		holds(ground, third, "log", 3) and table.isfrozen(ground.byId[third].stack),
		"drop: a stack written by hand is stored as a real stack"
	)
end

do -- a stack dropped beside its own kind joins it
	local ground = GroundItems.new()
	local first = GroundItems.drop(ground, ItemStack.new("log", 5), at(10, 0, 0), 100)
	local joined = GroundItems.drop(ground, ItemStack.new("log", 3), at(10 + MERGE, 0, 0), 130)
	check(joined == first, "drop: returns the id of the ground item the stack joined")
	check(groundItemCount(ground) == 1 and holds(ground, first, "log", 8), "drop: the ground item holds both stacks")
	check(ground.nextId == 2, "drop: joining uses no new id")
	check(ground.byId[first].position.x == 10, "drop: the ground item stays where it lay")
	check(ground.byId[first].droppedAt == 130, "drop: and counts as dropped when the second stack was")
	check(table.isfrozen(ground.byId[first]), "drop: the joined ground item is a frozen value")

	local beyond = GroundItems.drop(ground, ItemStack.new("log", 1), at(10 + MERGE + 0.01, 0, 0), 130)
	check(beyond == 2 and holds(ground, first, "log", 8), "drop: a stack dropped just beyond the radius lies apart")
	local above = GroundItems.drop(ground, ItemStack.new("log", 1), at(10, MERGE + 0.01, 0), 130)
	check(above == 3 and holds(ground, first, "log", 8), "drop: height counts towards the distance")

	local other = GroundItems.drop(ground, ItemStack.new("fish", 2), at(10, 0, 0), 130)
	check(other == 4 and holds(ground, first, "log", 8), "drop: a different item does not join")

	local full = GroundItems.new()
	GroundItems.drop(full, ItemStack.new("log", 12), at(0, 0, 0), 0)
	local apart = GroundItems.drop(full, ItemStack.new("log", 5), at(0, 0, 0), 0)
	check(
		apart == 2 and holds(full, 1, "log", 12) and holds(full, 2, "log", 5),
		"drop: a stack that does not wholly fit lies apart"
	)
	check(
		GroundItems.drop(full, ItemStack.new("log", 4), at(0, 0, 0), 0) == 1,
		"drop: a stack that exactly fills joins"
	)
	check(holds(full, 1, "log", 16), "drop: and the ground item is a full stack")
	check(GroundItems.drop(full, ItemStack.new("stove", 1), at(5, 0, 0), 0) == 3, "drop: a stove lies on the ground")
	check(
		GroundItems.drop(full, ItemStack.new("stove", 1), at(5, 0, 0), 0) == 4,
		"drop: an item that does not stack never joins"
	)

	local choice = GroundItems.new()
	local farther = GroundItems.drop(choice, ItemStack.new("log", 1), at(-1.2, 0, 0), 0)
	local nearer = GroundItems.drop(choice, ItemStack.new("log", 1), at(0.5, 0, 0), 0)
	check(GroundItems.drop(choice, ItemStack.new("log", 1), at(0, 0, 0), 0) == nearer, "drop: joins the nearest of two")
	check(
		holds(choice, farther, "log", 1) and holds(choice, nearer, "log", 2),
		"drop: and leaves the farther as it was"
	)

	local tied = GroundItems.new()
	for index = 1, 60 do
		GroundItems.drop(tied, ItemStack.new("fish", 1), at(index * 10, 0, 500), 0)
	end
	GroundItems.expire(tied, LIFETIME)
	local allFirst = true
	for round = 1, 20 do
		local x = round * 100
		local left = GroundItems.drop(tied, ItemStack.new("log", 1), at(x - 1, 0, 0), LIFETIME)
		GroundItems.drop(tied, ItemStack.new("log", 1), at(x + 1, 0, 0), LIFETIME)
		if GroundItems.drop(tied, ItemStack.new("log", 1), at(x, 0, 0), LIFETIME) ~= left then
			allFirst = false
		end
	end
	check(allFirst, "drop: of two equally near, joins the one dropped first, whatever their ids")

	local delayed = GroundItems.new()
	local pack = Inventory.new(3)
	GroundItems.drop(delayed, ItemStack.new("log", 5), at(0, 0, 0), 0)
	GroundItems.drop(delayed, ItemStack.new("log", 1), at(0, 0, 0), 100)
	check(
		GroundItems.pickUpNear(delayed, at(1, 0, 0), pack, 100 + DELAY - 0.01) == 0,
		"drop: a ground item that was joined cannot be picked up straight away"
	)
	GroundItems.expire(delayed, LIFETIME + 50)
	check(holds(delayed, 1, "log", 6), "drop: a ground item that was joined lasts from when it was joined")
	check(GroundItems.pickUpNear(delayed, at(1, 0, 0), pack, 100 + DELAY) == 6, "drop: and is picked up whole")
end

do -- walking over a ground item
	local ground = GroundItems.new()
	local pack = Inventory.new(3)
	GroundItems.drop(ground, ItemStack.new("log", 5), at(10, 0, 0), 12)

	check(GroundItems.pickUpNear(ground, at(9, 0, 0), pack, 12) == 0, "pickUpNear: not in the moment it was dropped")
	check(
		GroundItems.pickUpNear(ground, at(9, 0, 0), pack, 12 + DELAY - 0.01) == 0,
		"pickUpNear: not just before the delay is over"
	)
	check(holds(ground, 1, "log", 5) and Inventory.isEmpty(pack), "pickUpNear: a refused pickup changes nothing")
	check(
		GroundItems.pickUpNear(ground, at(10 + RADIUS + 0.01, 0, 0), pack, 100) == 0,
		"pickUpNear: not from just beyond the radius"
	)
	check(GroundItems.pickUpNear(ground, at(10, RADIUS + 0.01, 0), pack, 100) == 0, "pickUpNear: height counts")
	check(
		GroundItems.pickUpNear(ground, at(10 - 3, 0, 3), pack, 100) == 0,
		"pickUpNear: the distance is measured in a straight line"
	)
	check(
		GroundItems.pickUpNear(ground, at(9, 0, 0), pack, 12 + DELAY) == 5,
		"pickUpNear: returns how many items moved"
	)
	check(Inventory.countItems(pack, "log") == 5, "pickUpNear: the items are in the inventory")
	check(groundItemCount(ground) == 0, "pickUpNear: the ground item is gone")
	check(ground.nextId == 2, "pickUpNear: the id is not used again")
	check(
		GroundItems.drop(ground, ItemStack.new("fish", 1), at(0, 0, 0), 200) == 2,
		"drop: a new ground item gets a new id"
	)
end

do -- distance is measured on all three axes, between any two positions
	local ground = GroundItems.new()
	local pack = Inventory.new(3)
	GroundItems.drop(ground, ItemStack.new("log", 1), at(10, 5, -7), 0)
	check(GroundItems.pickUpNear(ground, at(-10, 5, -7), pack, 10) == 0, "pickUpNear: not from 20 studs away along x")
	check(GroundItems.pickUpNear(ground, at(10, -5, -7), pack, 10) == 0, "pickUpNear: not from 10 studs below")
	check(GroundItems.pickUpNear(ground, at(10, 5, 7), pack, 10) == 0, "pickUpNear: not from 14 studs away along z")
	check(GroundItems.pickUpNear(ground, at(11, 4, -6), pack, 10) == 1, "pickUpNear: from a step away on every axis")
end

do -- equally near ground items are picked up in the order they were dropped, whatever their ids
	local ground = GroundItems.new()
	for index = 1, 100 do
		GroundItems.drop(ground, ItemStack.new("log", 1), at(500 + index * 10, 0, 500), 0)
	end
	GroundItems.expire(ground, LIFETIME)
	for _ = 1, 40 do
		GroundItems.drop(ground, ItemStack.new("stove", 1), at(0, 0, 0), LIFETIME)
	end
	local inOrder = true
	local pack = Inventory.new(1)
	for expected = 101, 140 do
		GroundItems.pickUpNear(ground, at(1, 0, 0), pack, LIFETIME + 10)
		Inventory.clear(pack)
		if ground.byId[expected] ~= nil or groundItemCount(ground) ~= 140 - expected then
			inOrder = false
		end
	end
	check(inOrder, "pickUpNear: 40 stoves in one spot are picked up one at a time, first dropped first")
end

do -- the edge of the radius, and several at once
	local ground = GroundItems.new()
	local pack = Inventory.new(9)
	GroundItems.drop(ground, ItemStack.new("log", 4), at(RADIUS, 0, 0), 0)
	GroundItems.drop(ground, ItemStack.new("fish", 2), at(0, 0, -RADIUS), 0)
	GroundItems.drop(ground, ItemStack.new("stove", 1), at(0, -RADIUS, 0), 0)
	GroundItems.drop(ground, ItemStack.new("log", 7), at(RADIUS + 3, 0, 0), 0)
	check(GroundItems.pickUpNear(ground, at(0, 0, 0), pack, 10) == 7, "pickUpNear: everything exactly at the radius")
	check(
		Inventory.countItems(pack, "log") == 4
			and Inventory.countItems(pack, "fish") == 2
			and Inventory.countItems(pack, "stove") == 1,
		"pickUpNear: each kind of item is picked up"
	)
	check(groundItemCount(ground) == 1 and holds(ground, 4, "log", 7), "pickUpNear: what was out of reach stays")
end

do -- an inventory with too little room
	local ground = GroundItems.new()
	local pack = Inventory.new(1)
	Inventory.addItems(pack, "log", 10)
	GroundItems.drop(ground, ItemStack.new("log", 16), at(2, 0, 0), 5)
	check(GroundItems.pickUpNear(ground, at(0, 0, 0), pack, 50) == 6, "pickUpNear: takes only what fits")
	check(Inventory.countItems(pack, "log") == 16, "pickUpNear: the inventory is full")
	check(holds(ground, 1, "log", 10), "pickUpNear: the rest stays on the ground under the same id")
	local rest = ground.byId[1]
	check(rest.position.x == 2 and rest.droppedAt == 5, "pickUpNear: the rest lies where it was and is no younger")
	check(table.isfrozen(rest), "pickUpNear: the rest is a frozen value too")
	check(GroundItems.pickUpNear(ground, at(0, 0, 0), pack, 60) == 0, "pickUpNear: 0 when nothing fits")
	check(holds(ground, 1, "log", 10), "pickUpNear: and the ground item is as it was")

	GroundItems.drop(ground, ItemStack.new("fish", 3), at(1, 0, 0), 5)
	check(
		GroundItems.pickUpNear(ground, at(0, 0, 0), pack, 60) == 0,
		"pickUpNear: 0 when the only slot holds another item"
	)
	check(groundItemCount(ground) == 2, "pickUpNear: both are still on the ground")
end

do -- the nearest first
	local ground = GroundItems.new()
	local pack = Inventory.new(1)
	local far = GroundItems.drop(ground, ItemStack.new("log", 16), at(3, 0, 0), 0)
	local near = GroundItems.drop(ground, ItemStack.new("fish", 8), at(1, 0, 0), 0)
	check(GroundItems.pickUpNear(ground, at(0, 0, 0), pack, 10) == 8, "pickUpNear: one slot takes one of them")
	check(Inventory.countItems(pack, "fish") == 8, "pickUpNear: the nearest is picked up first")
	check(ground.byId[near] == nil and holds(ground, far, "log", 16), "pickUpNear: the farther one stays")

	local tied = GroundItems.new()
	local onePack = Inventory.new(1)
	local first = GroundItems.drop(tied, ItemStack.new("log", 16), at(2, 0, 0), 0)
	local second = GroundItems.drop(tied, ItemStack.new("fish", 8), at(-2, 0, 0), 0)
	GroundItems.pickUpNear(tied, at(0, 0, 0), onePack, 10)
	check(
		tied.byId[first] == nil and holds(tied, second, "fish", 8),
		"pickUpNear: of two equally near, the one dropped first is picked up first"
	)

	local filling = GroundItems.new()
	local smallPack = Inventory.new(2)
	GroundItems.drop(filling, ItemStack.new("log", 12), at(1, 0, 0), 0)
	GroundItems.drop(filling, ItemStack.new("log", 12), at(2, 0, 0), 0)
	GroundItems.drop(filling, ItemStack.new("log", 12), at(3, 0, 0), 0)
	check(GroundItems.pickUpNear(filling, at(0, 0, 0), smallPack, 10) == 32, "pickUpNear: stacks top each other up")
	check(
		filling.byId[1] == nil and filling.byId[2] == nil and holds(filling, 3, "log", 4),
		"pickUpNear: the farthest is the one left short"
	)
end

do -- lying too long
	local ground = GroundItems.new()
	GroundItems.drop(ground, ItemStack.new("log", 5), at(0, 0, 0), 100)
	GroundItems.drop(ground, ItemStack.new("fish", 2), at(0, 0, 0), 250)
	GroundItems.expire(ground, 100 + LIFETIME - 0.01)
	check(groundItemCount(ground) == 2, "expire: nothing goes before its time")
	GroundItems.expire(ground, 100 + LIFETIME)
	check(ground.byId[1] == nil, "expire: a ground item is gone once it has lain for the lifetime")
	check(holds(ground, 2, "fish", 2), "expire: a younger one stays")
	check(ground.nextId == 3, "expire: ids are not used again")
	GroundItems.expire(ground, 100000)
	check(groundItemCount(ground) == 0, "expire: in the end everything goes")

	local partly = GroundItems.new()
	local pack = Inventory.new(1)
	Inventory.addItems(pack, "log", 10)
	GroundItems.drop(partly, ItemStack.new("log", 16), at(0, 0, 0), 0)
	GroundItems.pickUpNear(partly, at(0, 0, 0), pack, LIFETIME - 1)
	GroundItems.expire(partly, LIFETIME)
	check(groundItemCount(partly) == 0, "expire: picking part of a ground item up does not make the rest last longer")
end

do -- mistakes in the calling code
	local ground = GroundItems.new()
	local pack = Inventory.new(3)
	local logs = ItemStack.new("log", 5)
	GroundItems.drop(ground, logs, at(0, 0, 0), 0)

	check(
		raises("GroundItems.drop: a stack is a table, not a nil", function()
			GroundItems.drop(ground, nil :: any, at(0, 0, 0), 0)
		end),
		"drop: refuses nothing in place of a stack"
	)
	check(
		raises('GroundItems.drop: no item has the id "anvil"', function()
			GroundItems.drop(ground, { itemId = "anvil", count = 1 }, at(0, 0, 0), 0)
		end),
		"drop: refuses an item that does not exist"
	)
	for _, badCount in { 0, 17, -1, 2.5 } do
		check(
			raises('GroundItems.drop: a stack of "log" holds 1 to 16, not ' .. tostring(badCount), function()
				GroundItems.drop(ground, { itemId = "log", count = badCount }, at(0, 0, 0), 0)
			end),
			"drop: refuses a stack of " .. tostring(badCount) .. " logs"
		)
	end
	check(
		raises("GroundItems.drop: a position is a table with x, y and z, not a string", function()
			GroundItems.drop(ground, logs, "here" :: any, 0)
		end),
		"drop: refuses a position that is not a table"
	)
	local badPositions: { [string]: any } = {
		["position.x must be a number; got nil"] = { y = 0, z = 0 },
		["position.y must be a number; got high"] = { x = 0, y = "high", z = 0 },
		["position.z must be a number; got nan"] = { x = 0, y = 0, z = 0 / 0 },
		["position.x must be a number; got inf"] = { x = math.huge, y = 0, z = 0 },
		["position.y must be a number; got -inf"] = { x = 0, y = -math.huge, z = 0 },
	}
	for message, position in badPositions do
		check(
			raises("GroundItems.drop: " .. message, function()
				GroundItems.drop(ground, logs, position, 0)
			end),
			"drop: refuses a bad position (" .. message .. ")"
		)
		check(
			raises("GroundItems.pickUpNear: " .. message, function()
				GroundItems.pickUpNear(ground, position, pack, 100)
			end),
			"pickUpNear: refuses a bad position (" .. message .. ")"
		)
	end
	check(
		raises("GroundItems.pickUpNear: a position is a table with x, y and z, not a nil", function()
			GroundItems.pickUpNear(ground, nil :: any, pack, 100)
		end),
		"pickUpNear: refuses nothing in place of a position"
	)
	for _, badTime in { "now", 0 / 0, math.huge, -math.huge } do
		local shown = tostring(badTime)
		check(
			raises("GroundItems.drop: now must be a number of seconds; got " .. shown, function()
				GroundItems.drop(ground, logs, at(0, 0, 0), badTime :: any)
			end),
			"drop: refuses the time " .. shown
		)
		check(
			raises("GroundItems.pickUpNear: now must be a number of seconds; got " .. shown, function()
				GroundItems.pickUpNear(ground, at(0, 0, 0), pack, badTime :: any)
			end),
			"pickUpNear: refuses the time " .. shown
		)
		check(
			raises("GroundItems.expire: now must be a number of seconds; got " .. shown, function()
				GroundItems.expire(ground, badTime :: any)
			end),
			"expire: refuses the time " .. shown
		)
	end
	check(
		groundItemCount(ground) == 1 and holds(ground, 1, "log", 5) and ground.nextId == 2 and Inventory.isEmpty(pack),
		"a refused call changes nothing"
	)
end

do -- many random drops, pickups and expiries: no item is made, and none is lost except by expiring
	local seed = 20261119
	local function random(limit: number): number
		seed = (seed * 1103515245 + 12345) % 2147483648
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
			if action <= 5 then
				local itemId = itemIds[random(3)]
				local count = random(stackSizes[itemId])
				GroundItems.drop(ground, ItemStack.new(itemId, count), at(random(12), 0, random(12)), now)
				dropped[itemId] += count
			elseif action <= 9 then
				local pack = packs[random(2)]
				local before = Inventory.countItems(pack, "log")
					+ Inventory.countItems(pack, "fish")
					+ Inventory.countItems(pack, "stove")
				local moved = GroundItems.pickUpNear(ground, at(random(12), 0, random(12)), pack, now)
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
				GroundItems.expire(ground, now)
				for _, itemId in itemIds do
					expired[itemId] += before[itemId] - itemsOnGround(ground, itemId)
				end
			end
			for id, groundItem: GroundItems.GroundItem in ground.byId :: any do
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
