--!strict
-- Tests for Inventory. Run from the repository root: lune run tests/inventory/Inventory.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")

local check = Check.that
local raises = Check.raises

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "stone", stackSize = 16 })
ItemRegistry.register({ id = "stove", stackSize = 1 })

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

-- How many slots of `inventory` have an entry stored for them.
local function entryCount(inventory: Inventory.Inventory): number
	local entries = 0
	for _ in inventory.slots do
		entries += 1
	end
	return entries
end

-- Describes what an inventory holds, slot by slot, such as "log 16, -, stone 3".
local function contents(inventory: Inventory.Inventory): string
	local parts = {}
	for slot = 1, inventory.slotCount do
		local stack = Inventory.getStack(inventory, slot)
		table.insert(parts, if stack then stack.itemId .. " " .. stack.count else "-")
	end
	return table.concat(parts, ", ")
end

-- Returns an inventory holding what `text` describes, in the form `contents` gives.
local function inventoryOf(text: string): Inventory.Inventory
	local parts = string.split(text, ", ")
	local inventory = Inventory.new(#parts)
	for slot, part in parts do
		if part ~= "-" then
			local itemId, count = string.match(part, "^(%S+) (%d+)$")
			assert(itemId and count, "bad test inventory: " .. text)
			Inventory.setStack(inventory, slot, ItemStack.new(itemId, tonumber(count) :: number))
		end
	end
	return inventory
end

-- True if `value` could be saved or sent as it is: numbers, strings and booleans, in tables that are
-- either lists with no gaps or records with string keys.
local function isPlain(value: unknown): boolean
	if type(value) == "number" then
		return value == value and value ~= math.huge and value ~= -math.huge
	end
	if type(value) ~= "table" then
		return type(value) == "string" or type(value) == "boolean"
	end
	local entries, strings = 0, 0
	for key, inner in value :: { [unknown]: unknown } do
		entries += 1
		if type(key) == "string" then
			strings += 1
		end
		if not isPlain(inner) then
			return false
		end
	end
	if strings == entries then
		return true
	end
	for index = 1, entries do
		if (value :: { [unknown]: unknown })[index] == nil then
			return false
		end
	end
	return strings == 0
end

do -- a new inventory: its slots exist and hold nothing
	local pack = Inventory.new(3)
	check(pack.slotCount == 3, "new: has the number of slots asked for")
	check(entryCount(pack) == 0, "new: nothing is stored for a slot that holds nothing")
	check(Inventory.isEmpty(pack), "new: holds nothing")
	check(
		Inventory.getStack(pack, 1) == nil and Inventory.getStack(pack, 3) == nil,
		"getStack: nil for a slot that holds nothing"
	)
	check(contents(pack) == "-, -, -", "new: three slots, all holding nothing")
	check(Inventory.new(1).slotCount == 1, "new: one slot is the smallest inventory")
end

do -- setStack and getStack
	local pack = Inventory.new(3)
	Inventory.setStack(pack, 2, ItemStack.new("log", 5))
	check(is(Inventory.getStack(pack, 2), "log", 5), "setStack: the slot holds the stack")
	check(
		is(pack.slots[2], "log", 5) and pack.slots[1] == nil and pack.slots[3] == nil,
		"setStack: only that slot has an entry"
	)
	check(entryCount(pack) == 1 and pack.slotCount == 3, "setStack: one entry, and still three slots")
	check(Inventory.isEmpty(pack) == false, "isEmpty: false once a slot holds something")
	Inventory.setStack(pack, 2, ItemStack.new("stone", 1))
	check(contents(pack) == "-, stone 1, -", "setStack: replaces what the slot held")
	Inventory.setStack(pack, 2, nil)
	check(
		contents(pack) == "-, -, -" and entryCount(pack) == 0,
		"setStack: nil leaves the slot holding nothing, with no entry"
	)
	check(Inventory.isEmpty(pack), "isEmpty: true again once the last stack is gone")
end

do -- addItems
	local pack = Inventory.new(3)
	check(Inventory.addItems(pack, "log", 5) == 5, "addItems: returns how many were added")
	check(contents(pack) == "log 5, -, -", "addItems: uses the lowest slot that holds nothing")
	check(Inventory.addItems(pack, "log", 14) == 14, "addItems: a second lot fits")
	check(contents(pack) == "log 16, log 3, -", "addItems: tops up a stack before starting another")

	local empty = Inventory.new(3)
	check(Inventory.addItems(empty, "log", 40) == 40, "addItems: 40 logs fit in three slots")
	check(contents(empty) == "log 16, log 16, log 8", "addItems: 40 logs fill slots as 16, 16 and 8")

	local small = Inventory.new(3)
	check(Inventory.addItems(small, "log", 60) == 48, "addItems: returns only what fitted when the rest did not")
	check(contents(small) == "log 16, log 16, log 16", "addItems: adds what fits")
	check(
		Inventory.addItems(small, "log", 1) == 0 and Inventory.addItems(small, "stone", 1) == 0,
		"addItems: a full inventory takes nothing, and says 0"
	)

	local mixed = inventoryOf("stone 3, -, log 10")
	check(Inventory.addItems(mixed, "log", 8) == 8, "addItems: fits around other items")
	check(
		contents(mixed) == "stone 3, log 2, log 16",
		"addItems: tops up the log stack, then uses the empty slot, and leaves the stone alone"
	)

	local order = inventoryOf("-, log 10, -, log 15")
	check(Inventory.addItems(order, "log", 9) == 9, "addItems: tops up several stacks")
	check(
		contents(order) == "log 2, log 16, -, log 16",
		"addItems: tops up stacks lowest slot first, then fills empty slots lowest first"
	)

	local stoves = Inventory.new(2)
	check(Inventory.addItems(stoves, "stove", 3) == 2, "addItems: only two stoves fit in two slots")
	check(contents(stoves) == "stove 1, stove 1", "addItems: an item that does not stack takes a slot each")

	local untouched = inventoryOf("log 5, -")
	check(
		Inventory.addItems(untouched, "log", 0) == 0 and contents(untouched) == "log 5, -",
		"addItems: adding 0 changes nothing and returns 0"
	)
end

do -- addStack
	local pack = inventoryOf("log 10, -")
	check(Inventory.addStack(pack, ItemStack.new("log", 4)) == nil, "addStack: nil when all of it went in")
	check(contents(pack) == "log 14, -", "addStack: tops up the same item first")
	check(
		Inventory.addStack(pack, ItemStack.new("stone", 7)) == nil and contents(pack) == "log 14, stone 7",
		"addStack: uses a slot that holds nothing"
	)
	check(
		is(Inventory.addStack(pack, ItemStack.new("log", 12)), "log", 10),
		"addStack: returns the stack of what did not fit"
	)
	check(contents(pack) == "log 16, stone 7", "addStack: what fitted went in")
	check(
		is(Inventory.addStack(pack, ItemStack.new("stove", 1)), "stove", 1),
		"addStack: returns the whole stack when none of it fits"
	)
end

do -- addItems, one item at a time
	local stoves = inventoryOf("-, -, -")
	check(
		Inventory.addItems(stoves, "stove", 3) == 3,
		"addItems: three of an item that does not stack fill three slots"
	)
	check(contents(stoves) == "stove 1, stove 1, stove 1", "addItems: the last one of them is added too")
	local logs = inventoryOf("-, log 15")
	check(Inventory.addItems(logs, "log", 1) == 1, "addItems: a single item is added")
	check(contents(logs) == "-, log 16", "addItems: a single item tops up a stack before it takes an empty slot")
end

do -- addItems and addStack into listed slots
	local pack = inventoryOf("log 10, -, -, log 14, -, -")
	check(
		Inventory.addItems(pack, "log", 20, { 3, 4, 5 }) == 20,
		"addItems: into the listed slots only, returns how many went in"
	)
	check(
		contents(pack) == "log 10, -, log 16, log 16, log 2, -",
		"addItems: tops up among the listed slots, then fills them; the rest is left alone"
	)
	check(
		Inventory.addItems(pack, "log", 40, { 3, 4, 5 }) == 14,
		"addItems: returns only what fitted in the listed slots"
	)
	check(
		contents(pack) == "log 10, -, log 16, log 16, log 16, -",
		"addItems: full listed slots leave the others as they were"
	)
	check(Inventory.addItems(pack, "log", 5, { 2 }) == 5, "addItems: one slot may be listed")
	check(contents(pack) == "log 10, log 5, log 16, log 16, log 16, -", "addItems: and only that slot is used")
	check(Inventory.addItems(pack, "log", 3, { 6 }) == 3, "addItems: the last slot may be listed")
	check(Inventory.addItems(pack, "log", 9) == 9, "addItems: with no list, every slot is used")
	check(
		contents(pack) == "log 16, log 8, log 16, log 16, log 16, log 3",
		"addItems: lowest slot first when no slots are listed"
	)
	local ordered = inventoryOf("-, -, -")
	Inventory.addItems(ordered, "log", 20, { 3, 1 })
	check(contents(ordered) == "log 4, -, log 16", "addItems: listed slots are filled in the order they are listed")
	check(Inventory.addItems(ordered, "log", 5, {}) == 0, "addItems: an empty list adds nothing")

	local other = inventoryOf("stone 2, -, -, stone 16")
	check(
		Inventory.addStack(other, ItemStack.new("stone", 16), { 3, 4 }) == nil,
		"addStack: nil when the stack fitted in the listed slots"
	)
	check(
		contents(other) == "stone 2, -, stone 16, stone 16",
		"addStack: it went into the listed slots, not the slots before them"
	)
	local leftover = Inventory.addStack(other, ItemStack.new("stone", 5), { 3, 4 })
	check(is(leftover, "stone", 5), "addStack: returns the whole stack when the listed slots have no room")
	leftover = Inventory.addStack(other, ItemStack.new("log", 12), { 1, 2 })
	check(
		leftover == nil and contents(other) == "stone 2, log 12, stone 16, stone 16",
		"addStack: a different item takes the empty slot that is listed"
	)
	leftover = Inventory.addStack(other, ItemStack.new("stone", 16), { 1, 2 })
	check(is(leftover, "stone", 2), "addStack: returns the stack of what did not fit in the listed slots")
	check(contents(other) == "stone 16, log 12, stone 16, stone 16", "addStack: after topping up what it could")
end

do -- countItems
	local pack = inventoryOf("log 16, stone 3, log 4, -")
	check(Inventory.countItems(pack, "log") == 20, "countItems: adds up every slot holding the item")
	check(Inventory.countItems(pack, "stove") == 0, "countItems: 0 for an item it does not hold")
	check(Inventory.countItems(pack, "anvil") == 0, "countItems: 0 for an id that no item has")
end

do -- takeFromSlot
	local pack = inventoryOf("log 5, -")
	check(is(Inventory.takeFromSlot(pack, 1, 2), "log", 2), "takeFromSlot: returns the stack taken")
	check(contents(pack) == "log 3, -", "takeFromSlot: leaves the rest in the slot")
	check(
		Inventory.takeFromSlot(pack, 1, 0) == nil and contents(pack) == "log 3, -",
		"takeFromSlot: taking 0 changes nothing and returns nil"
	)
	check(
		is(Inventory.takeFromSlot(pack, 1, 10), "log", 3),
		"takeFromSlot: asked for more than there is, returns what there was"
	)
	check(contents(pack) == "-, -" and entryCount(pack) == 0, "takeFromSlot: an emptied slot has no entry")
	check(
		Inventory.takeFromSlot(pack, 2) == nil and Inventory.takeFromSlot(pack, 2, 1) == nil,
		"takeFromSlot: nil from a slot that holds nothing"
	)
	Inventory.setStack(pack, 2, ItemStack.new("stone", 7))
	check(
		is(Inventory.takeFromSlot(pack, 2), "stone", 7) and Inventory.isEmpty(pack),
		"takeFromSlot: with no count, takes the whole stack"
	)
	Inventory.setStack(pack, 1, ItemStack.new("log", 5))
	check(
		is(Inventory.takeFromSlot(pack, 1, 5), "log", 5) and Inventory.isEmpty(pack),
		"takeFromSlot: taking exactly what is there empties the slot"
	)
end

do -- takeEveryStack
	local pack = inventoryOf("-, stone 7, -, log 16, log 3")
	local second = Inventory.getStack(pack, 2)
	local stacks = Inventory.takeEveryStack(pack)
	check(#stacks == 3, "takeEveryStack: returns one stack for each slot that held something")
	check(
		is(stacks[1], "stone", 7) and is(stacks[2], "log", 16) and is(stacks[3], "log", 3),
		"takeEveryStack: the stack from the lowest slot first, and two stacks of one item are not merged"
	)
	check(stacks[1] == second, "takeEveryStack: the stacks returned are the ones the slots held")
	check(
		Inventory.isEmpty(pack) and entryCount(pack) == 0 and contents(pack) == "-, -, -, -, -",
		"takeEveryStack: every slot then holds nothing"
	)
	check(pack.slotCount == 5, "takeEveryStack: and the inventory still has its slots")
	local again = Inventory.takeEveryStack(pack)
	check(#again == 0, "takeEveryStack: an inventory that holds nothing gives a list of nothing")
	check(again ~= stacks, "takeEveryStack: each call returns a list of its own")
	Inventory.setStack(pack, 5, ItemStack.new("stove", 1))
	check(
		is(Inventory.takeEveryStack(pack)[1], "stove", 1) and Inventory.isEmpty(pack),
		"takeEveryStack: the last slot is taken too"
	)
end

do -- putInSlot
	local pack = inventoryOf("-, log 12, stone 1")
	check(
		Inventory.putInSlot(pack, 1, ItemStack.new("log", 5)) == nil,
		"putInSlot: a slot that holds nothing takes the whole stack"
	)
	check(contents(pack) == "log 5, log 12, stone 1", "putInSlot: the stack is in the slot")
	check(is(Inventory.putInSlot(pack, 2, ItemStack.new("log", 10)), "log", 6), "putInSlot: returns what did not fit")
	check(contents(pack) == "log 5, log 16, stone 1", "putInSlot: tops the slot up to the stack size")
	check(
		is(Inventory.putInSlot(pack, 2, ItemStack.new("log", 1)), "log", 1),
		"putInSlot: nothing goes onto a full stack"
	)
	check(
		is(Inventory.putInSlot(pack, 3, ItemStack.new("log", 4)), "log", 4),
		"putInSlot: a different item takes nothing, and the whole stack comes back"
	)
	check(contents(pack) == "log 5, log 16, stone 1", "putInSlot: a refused stack changes nothing")
	check(
		Inventory.putInSlot(pack, 1, ItemStack.new("log", 11)) == nil and contents(pack) == "log 16, log 16, stone 1",
		"putInSlot: exactly filling leaves nothing"
	)
end

do -- encode
	local empty = Inventory.encode(Inventory.new(3))
	check(empty.slotCount == 3 and #empty.stacks == 0, "encode: an inventory holding nothing has no stacks listed")

	local pack = inventoryOf("-, log 5, -, stone 16")
	local encoded = Inventory.encode(pack)
	check(encoded.slotCount == 4 and #encoded.stacks == 2, "encode: one entry for each slot that holds something")
	local first, second = encoded.stacks[1], encoded.stacks[2]
	check(
		first.slot == 2 and first.itemId == "log" and first.count == 5,
		"encode: an entry has its slot, item id and count"
	)
	check(second.slot == 4 and second.itemId == "stone" and second.count == 16, "encode: entries are in slot order")
	check(isPlain(encoded), "encode: the result is only numbers, strings and tables with no gaps")
	check(
		isPlain(Inventory.encode(inventoryOf("log 1, -, -, -, stone 2"))),
		"encode: still plain when later slots hold nothing"
	)
	first.count = 99
	table.remove(encoded.stacks)
	check(contents(pack) == "-, log 5, -, stone 16", "encode: changing the result does not change the inventory")
end

do -- decode gives back what encode was given
	for _, text in { "-", "log 5", "-, log 5, -, stone 16", "log 16, -, -, stove 1, -", "stone 1, stone 2, stone 3" } do
		local decoded, problem = Inventory.decode(Inventory.encode(inventoryOf(text)))
		check(decoded ~= nil and problem == nil and contents(decoded) == text, "decode: gives back " .. text)
	end
	local decoded = Inventory.decode({ slotCount = 2, stacks = { { slot = 2, itemId = "log", count = 3 } } })
	check(decoded ~= nil and contents(decoded) == "-, log 3", "decode: reads data written by hand in the same form")
	check(decoded ~= nil and Check.errorFrom(function()
		((decoded :: any).slots[2] :: any).count = 9
	end) ~= nil, "decode: the stacks it makes cannot be changed, like any other stack")
	local reordered = Inventory.decode({
		slotCount = 3,
		stacks = { { slot = 3, itemId = "log", count = 1 }, { slot = 1, itemId = "stone", count = 2 } },
	})
	check(reordered ~= nil and contents(reordered) == "stone 2, -, log 1", "decode: entries may come in any order")
end

do -- decode refuses anything encode would not have written, and says what was wrong
	local function refuses(what: string, part: string, encoded: unknown)
		local decoded, problem = Inventory.decode(encoded)
		check(
			decoded == nil and problem ~= nil and string.find(problem, part, 1, true) ~= nil,
			"decode: refuses " .. what .. ", saying: " .. part
		)
	end
	local function one(slot: unknown, itemId: unknown, count: unknown): { [string]: unknown }
		return { slotCount = 3, stacks = { { slot = slot, itemId = itemId, count = count } } }
	end
	local log = { slot = 1, itemId = "log", count = 3 }
	refuses("nothing at all", "must be a table; got a nil", nil)
	refuses("a string", "must be a table; got a string", "inventory")
	refuses("no slotCount", "slotCount must be a whole number, 1 or more; got nil", { stacks = {} })
	refuses("a slotCount of 0", "slotCount must be a whole number", { slotCount = 0, stacks = {} })
	refuses("a slotCount that is not whole", "slotCount must be a whole number", { slotCount = 2.5, stacks = {} })
	refuses("a slotCount that is not a number", "slotCount must be a whole number", { slotCount = "3", stacks = {} })
	refuses("no stacks", "stacks must be a list; got a nil", { slotCount = 3 })
	refuses("a field it does not have", "a field it should not have: size", { slotCount = 3, stacks = {}, size = 3 })
	refuses("a list of stacks with a gap", "no gaps", { slotCount = 3, stacks = { [1] = log, [3] = log } })
	refuses("stacks keyed by name", "no gaps", { slotCount = 3, stacks = { first = log } })
	refuses("an entry that is not a table", "entry 1 is a number", { slotCount = 3, stacks = { 5 } })
	refuses("a slot of 0", "stacks[1].slot must be from 1 to 3; got 0", one(0, "log", 3))
	refuses("a slot past the end", "stacks[1].slot must be from 1 to 3; got 4", one(4, "log", 3))
	refuses("a slot that is not whole", "stacks[1].slot must be", one(1.5, "log", 3))
	refuses("an entry with no slot", "stacks[1].slot must be", one(nil, "log", 3))
	refuses("the same slot twice", "stacks[2].slot is 1, which an earlier entry already used", {
		slotCount = 3,
		stacks = { log, log },
	})
	refuses("an item that does not exist", 'stacks[1]: no item has the id "anvil"', one(1, "anvil", 1))
	refuses("an item id that is not a string", "stacks[1]: no item has the id", one(1, 7, 1))
	refuses("a count of 0", 'stacks[1]: a stack of "log" holds 1 to 16, not 0', one(1, "log", 0))
	refuses("a count above the stack size", "holds 1 to 16, not 17", one(1, "log", 17))
	refuses("a count that is not whole", "holds 1 to 16, not 2.5", one(1, "log", 2.5))
	refuses("a count that is not a number", "stacks[1]: a stack of", one(1, "log", 0 / 0))
	refuses("an entry with a field it does not have", "stacks[1] has a field it should not have: wear", {
		slotCount = 3,
		stacks = { { slot = 1, itemId = "log", count = 3, wear = 2 } },
	})
	refuses("a bad entry after a good one", "stacks[2]: a stack of", {
		slotCount = 3,
		stacks = { log, { slot = 2, itemId = "log", count = 0 } },
	})
end

do -- decode never raises an error, whatever it is given
	local junk: { unknown } = {
		0,
		-1,
		0 / 0,
		math.huge,
		"",
		"log",
		true,
		false,
		{},
		{ 1, 2, 3 },
		{ slotCount = 1 },
		{ stacks = {} },
		{ slotCount = math.huge, stacks = {} },
		{ slotCount = 2, stacks = "none" },
		{ slotCount = 2, stacks = { {} } },
		{ slotCount = 2, stacks = { { slot = "1", itemId = "log", count = 1 } } },
		{ slotCount = 2, stacks = { { slot = 1, itemId = {}, count = 1 } } },
		{ slotCount = 2, stacks = { { slot = 1, itemId = "log", count = "1" } } },
		{ slotCount = 2, stacks = { [2] = { slot = 1, itemId = "log", count = 1 } } },
		{ slotCount = 2, stacks = { false } },
		function() end,
	}
	local wrong: string? = nil
	for index, value in junk do
		local ok, decoded, problem = pcall(Inventory.decode, value)
		if not ok then
			wrong = wrong or string.format("junk %d raised: %s", index, tostring(decoded))
		elseif decoded ~= nil or type(problem) ~= "string" then
			wrong = wrong or string.format("junk %d was accepted", index)
		end
	end
	check(
		wrong == nil,
		"decode: bad data is refused with a reason and never raises" .. (if wrong then "; " .. wrong else "")
	)
end

do -- stacks handed out never change, and an inventory's shape cannot be changed from outside
	local pack = inventoryOf("log 5")
	local held = Inventory.getStack(pack, 1)
	check(Check.errorFrom(function()
		(held :: any).count = 99
	end) ~= nil, "getStack: the stack it returns cannot be changed")
	Inventory.addItems(pack, "log", 3)
	check(
		is(held, "log", 5) and is(Inventory.getStack(pack, 1), "log", 8),
		"getStack: a stack read earlier stays as it was when the slot changes"
	)
	check(Check.errorFrom(function()
		(pack :: any).slotCount = 9
	end) ~= nil, "an inventory's number of slots cannot be changed")
	check(Check.errorFrom(function()
		(pack :: any).slots = {}
	end) ~= nil, "an inventory's slots table cannot be replaced")
end

do -- the guards that stop an inventory being corrupted
	local pack = inventoryOf("log 5, -")
	for _, badSlot in { 0, 3, -1, 1.5, 0 / 0, math.huge } do
		check(
			raises("an inventory of 2 slots has no slot", function()
				return Inventory.getStack(pack, badSlot)
			end),
			"getStack: fails for slot " .. tostring(badSlot) .. " of 2, and blames the caller"
		)
	end
	check(Check.errorFrom(function()
		Inventory.setStack(pack, 3, ItemStack.new("log", 1))
	end) ~= nil, "setStack: fails for a slot the inventory lacks")
	check(Check.errorFrom(function()
		return Inventory.takeFromSlot(pack, 3)
	end) ~= nil, "takeFromSlot: fails for a slot the inventory lacks")
	check(Check.errorFrom(function()
		return Inventory.putInSlot(pack, 3, ItemStack.new("log", 1))
	end) ~= nil, "putInSlot: fails for a slot the inventory lacks")
	for _, badCount in { -1, 1.5, 0 / 0, math.huge } do
		check(
			raises("cannot add", function()
				return Inventory.addItems(pack, "log", badCount)
			end),
			"addItems: fails for a count of " .. tostring(badCount)
		)
	end
	check(Check.errorFrom(function()
		return Inventory.takeFromSlot(pack, 1, -1)
	end) ~= nil, "takeFromSlot: fails for a count below 0")
	check(Check.errorFrom(function()
		return Inventory.addItems(pack, "log", 20, { 2, 3 })
	end) ~= nil, "addItems: fails if the inventory lacks a listed slot")
	check(contents(pack) == "log 5, -", "nothing that failed changed the inventory")
end

do -- no item is ever made or lost
	local seed = 20261119
	local function random(limit: number): number
		seed = (seed * 16807) % 2147483647
		return math.floor(seed / 65536) % limit + 1
	end
	local itemIds = { "log", "stone", "stove" }
	local a, b = Inventory.new(5), Inventory.new(2)
	local held: { [string]: number } = { log = 0, stone = 0, stove = 0 }
	local broken: string? = nil
	for step = 1, 20000 do
		local inventory = if random(2) == 1 then a else b
		local itemId = itemIds[random(3)]
		local action = random(7)
		if action == 1 then
			held[itemId] += Inventory.addItems(inventory, itemId, random(41) - 1)
		elseif action == 2 then
			local taken = Inventory.takeFromSlot(inventory, random(inventory.slotCount))
			if taken then
				held[taken.itemId] -= taken.count
			end
		elseif action == 3 then
			local taken = Inventory.takeFromSlot(inventory, random(inventory.slotCount), random(21) - 1)
			if taken then
				held[taken.itemId] -= taken.count
			end
		elseif action == 4 then
			local from, to = a, b
			if random(2) == 1 then
				from, to = b, a
			end
			local fromSlot = random(from.slotCount)
			local taken = Inventory.takeFromSlot(from, fromSlot, random(20))
			if taken then
				local leftover = Inventory.putInSlot(to, random(to.slotCount), taken)
				if leftover and Inventory.putInSlot(from, fromSlot, leftover) ~= nil then
					broken = broken
						or string.format("step %d: what was taken from a slot did not fit back into it", step)
				end
			end
		elseif action == 5 then
			local count = math.min(random(20), ItemRegistry.get(itemId).stackSize)
			local leftover = Inventory.addStack(inventory, ItemStack.new(itemId, count))
			held[itemId] += count - (if leftover then leftover.count else 0)
		elseif action == 6 then
			local listed = { random(inventory.slotCount), random(inventory.slotCount) }
			held[itemId] += Inventory.addItems(inventory, itemId, random(20), listed)
		else
			local decoded = Inventory.decode(Inventory.encode(inventory))
			if decoded == nil or contents(decoded) ~= contents(inventory) then
				broken = broken or string.format("step %d: decode did not give back what encode was given", step)
			end
		end
		for _, name in itemIds do
			if Inventory.countItems(a, name) + Inventory.countItems(b, name) ~= held[name] then
				broken = broken or string.format("step %d: the number of %s is wrong", step, name)
			end
		end
		for _, each in { a, b } do
			for slot, stack in each.slots do
				if
					stack == nil
					or slot < 1
					or slot > each.slotCount
					or stack.count < 1
					or ItemStack.getSpaceLeft(stack) < 0
				then
					broken = broken or string.format("step %d: slot %d holds a stack that could not exist", step, slot)
				end
			end
			if Inventory.isEmpty(each) ~= (entryCount(each) == 0) then
				broken = broken or string.format("step %d: isEmpty disagrees with the slots", step)
			end
		end
		if broken then
			break
		end
	end
	check(
		broken == nil,
		"20,000 random operations: "
			.. (broken or "every item is accounted for and every stack is one that could exist")
	)
end

Check.finish("Inventory")
