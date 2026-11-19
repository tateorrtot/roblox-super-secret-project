--!strict
-- Tests for InventorySession. Run from the repository root: lune run tests/inventory/InventorySession.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventorySession = require("../../src/shared/inventory/InventorySession")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")

local check = Check.that
local raises = Check.raises

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "stone", stackSize = 16 })
ItemRegistry.register({ id = "stove", stackSize = 1 })

-- Describes a stack, such as "log 5", or "-" for no stack.
local function describe(stack: ItemStack.ItemStack?): string
	return if stack then stack.itemId .. " " .. stack.count else "-"
end

-- Returns a stack from a description in the form `describe` gives, or nil for "-".
local function stackOf(text: string): ItemStack.ItemStack?
	if text == "-" then
		return nil
	end
	local itemId, count = string.match(text, "^(%S+) (%d+)$")
	assert(itemId and count, "bad test stack: " .. text)
	return ItemStack.new(itemId, tonumber(count) :: number)
end

-- Describes what an inventory holds, slot by slot, such as "log 16, -, stone 3".
local function contents(inventory: Inventory.Inventory): string
	local parts = {}
	for slot = 1, inventory.slotCount do
		table.insert(parts, describe(Inventory.getStack(inventory, slot)))
	end
	return table.concat(parts, ", ")
end

-- Returns an inventory holding what `text` describes, in the form `contents` gives.
local function inventoryOf(text: string): Inventory.Inventory
	local parts = string.split(text, ", ")
	local inventory = Inventory.new(#parts)
	for slot, part in parts do
		Inventory.setStack(inventory, slot, stackOf(part))
	end
	return inventory
end

-- Returns a session over a one-slot pack holding `inSlot`, already carrying `carried`.
local function sessionWith(carried: string, inSlot: string): InventorySession.InventorySession
	local session = InventorySession.open(inventoryOf(inSlot), inventoryOf(carried))
	InventorySession.pickUp(session, "other", 1)
	return session
end

-- Carries `carried`, clicks a slot holding `inSlot`, and returns "carried / slot" as they are afterwards.
local function click(button: InventorySession.Button, carried: string, inSlot: string): string
	local session = sessionWith(carried, inSlot)
	InventorySession.click(session, "pack", 1, button)
	return describe(session.carried) .. " / " .. contents(session.pack)
end

do -- open
	local pack, crate = Inventory.new(2), Inventory.new(3)
	local alone = InventorySession.open(pack)
	check(alone.pack == pack and alone.other == nil, "open: with the pack alone there is no other inventory")
	check(alone.carried == nil, "open: nothing is carried")
	local both = InventorySession.open(pack, crate)
	check(both.pack == pack and both.other == crate, "open: holds the inventories it was given, not copies")
end

do -- pickUp
	local session = InventorySession.open(inventoryOf("log 12, stone 5, -"))
	check(
		InventorySession.pickUp(session, "pack", 3) == 0 and session.carried == nil,
		"pickUp: 0 from a slot that holds nothing"
	)
	check(InventorySession.pickUp(session, "pack", 1, 5) == 5, "pickUp: returns how many were picked up")
	check(
		describe(session.carried) == "log 5" and contents(session.pack) == "log 7, stone 5, -",
		"pickUp: part of a stack is carried and the rest stays"
	)
	check(
		InventorySession.pickUp(session, "pack", 1, 3) == 3 and describe(session.carried) == "log 8",
		"pickUp: more of the same item is added to what is carried"
	)
	check(InventorySession.pickUp(session, "pack", 2) == 0, "pickUp: 0 when a different item is carried")
	check(
		describe(session.carried) == "log 8" and contents(session.pack) == "log 4, stone 5, -",
		"pickUp: a refused take changes nothing"
	)
	check(
		InventorySession.pickUp(session, "pack", 1, 0) == 0 and describe(session.carried) == "log 8",
		"pickUp: taking 0 changes nothing"
	)
	check(
		InventorySession.pickUp(session, "pack", 1) == 4 and contents(session.pack) == "-, stone 5, -",
		"pickUp: with no count, the whole stack"
	)
	check(describe(session.carried) == "log 12", "pickUp: the carried stack holds everything picked up")

	local full = InventorySession.open(inventoryOf("log 16, log 10"))
	InventorySession.pickUp(full, "pack", 2)
	check(InventorySession.pickUp(full, "pack", 1) == 6, "pickUp: only what the carried stack has room for")
	check(
		describe(full.carried) == "log 16" and contents(full.pack) == "log 10, -",
		"pickUp: the rest stays in the slot"
	)
	check(InventorySession.pickUp(full, "pack", 1) == 0, "pickUp: nothing more when the carried stack is full")
end

do -- putDown
	local session = InventorySession.open(inventoryOf("-, log 12, stone 5"), inventoryOf("log 10"))
	check(InventorySession.putDown(session, "pack", 1) == 0, "putDown: 0 when nothing is carried")
	InventorySession.pickUp(session, "other", 1)
	check(InventorySession.putDown(session, "pack", 1, 3) == 3, "putDown: returns how many were put down")
	check(
		describe(session.carried) == "log 7" and contents(session.pack) == "log 3, log 12, stone 5",
		"putDown: part is put down and the rest stays carried"
	)
	check(InventorySession.putDown(session, "pack", 3) == 0, "putDown: 0 onto a different item")
	check(
		describe(session.carried) == "log 7" and contents(session.pack) == "log 3, log 12, stone 5",
		"putDown: a refused place changes nothing"
	)
	check(InventorySession.putDown(session, "pack", 2) == 4, "putDown: only what the slot has room for")
	check(
		describe(session.carried) == "log 3" and contents(session.pack) == "log 3, log 16, stone 5",
		"putDown: what does not fit stays carried"
	)
	check(InventorySession.putDown(session, "pack", 2) == 0, "putDown: 0 onto a full stack")
	check(
		InventorySession.putDown(session, "pack", 1, 0) == 0 and describe(session.carried) == "log 3",
		"putDown: placing 0 changes nothing"
	)
	check(
		InventorySession.putDown(session, "pack", 1, 99) == 3,
		"putDown: asked for more than is carried, puts down what is carried"
	)
	check(
		session.carried == nil and contents(session.pack) == "log 6, log 16, stone 5",
		"putDown: nothing is carried once the last item is put down"
	)
end

do -- swap
	local session = InventorySession.open(inventoryOf("log 12, stone 5, -"))
	InventorySession.swap(session, "pack", 1)
	check(
		describe(session.carried) == "log 12" and contents(session.pack) == "-, stone 5, -",
		"swap: carrying nothing, it picks the slot's stack up"
	)
	InventorySession.swap(session, "pack", 2)
	check(
		describe(session.carried) == "stone 5" and contents(session.pack) == "-, log 12, -",
		"swap: exchanges the carried stack with the slot's"
	)
	InventorySession.swap(session, "pack", 3)
	check(
		session.carried == nil and contents(session.pack) == "-, log 12, stone 5",
		"swap: into a slot that holds nothing, it puts the carried stack down"
	)
	InventorySession.swap(session, "pack", 1)
	check(
		session.carried == nil and contents(session.pack) == "-, log 12, stone 5",
		"swap: nothing with nothing changes nothing"
	)
end

do -- click, left, carrying nothing
	check(click("left", "-", "-") == "- / -", "left click, carrying nothing, on nothing: nothing happens")
	check(click("left", "-", "log 12") == "log 12 / -", "left click, carrying nothing: picks up the whole stack")
	check(
		click("left", "-", "stove 1") == "stove 1 / -",
		"left click, carrying nothing: picks up an item that does not stack"
	)
end

do -- click, left, carrying a stack
	check(click("left", "log 10", "-") == "- / log 10", "left click on nothing: puts the whole stack down")
	check(click("left", "log 10", "log 3") == "- / log 13", "left click on the same item: all of it fits")
	check(
		click("left", "log 10", "log 12") == "log 6 / log 16",
		"left click on the same item: what does not fit stays carried"
	)
	check(
		click("left", "log 10", "log 16") == "log 10 / log 16",
		"left click on a full stack of the same item: nothing moves"
	)
	check(click("left", "log 10", "stone 4") == "stone 4 / log 10", "left click on a different item: swaps")
	check(
		click("left", "stove 1", "stove 1") == "stove 1 / stove 1",
		"left click with an item that does not stack onto another: nothing moves"
	)
	check(
		click("left", "log 16", "log 1") == "log 1 / log 16",
		"left click with a full stack onto one: fills the slot and carries the one left"
	)
end

do -- click, right, carrying nothing
	check(click("right", "-", "-") == "- / -", "right click, carrying nothing, on nothing: nothing happens")
	check(click("right", "-", "log 12") == "log 6 / log 6", "right click, carrying nothing: picks up half")
	check(click("right", "-", "log 5") == "log 3 / log 2", "right click on an odd count: picks up the larger half")
	check(click("right", "-", "log 1") == "log 1 / -", "right click on one item: picks it up and leaves nothing")
	check(click("right", "-", "log 16") == "log 8 / log 8", "right click on a full stack: half each")
end

do -- click, right, carrying a stack
	check(click("right", "log 10", "-") == "log 9 / log 1", "right click on nothing: puts one down")
	check(click("right", "log 10", "log 3") == "log 9 / log 4", "right click on the same item: puts one down")
	check(
		click("right", "log 1", "log 3") == "- / log 4",
		"right click with the last item: nothing is carried afterwards"
	)
	check(
		click("right", "log 10", "log 16") == "log 10 / log 16",
		"right click on a full stack of the same item: nothing moves"
	)
	check(click("right", "log 10", "stone 4") == "stone 4 / log 10", "right click on a different item: swaps")
end

do -- click says whether anything changed
	local session = sessionWith("log 10", "log 16")
	check(InventorySession.click(session, "pack", 1, "left") == false, "click: false when nothing moved")
	check(
		InventorySession.click(session, "pack", 1, "right") == false,
		"click: false for a right click that moved nothing"
	)
	local other = sessionWith("log 10", "log 3")
	check(InventorySession.click(other, "pack", 1, "right") == true, "click: true when an item was put down")
	check(InventorySession.click(other, "pack", 1, "left") == true, "click: true when the stack was put down")
	check(InventorySession.click(other, "pack", 1, "left") == true, "click: true when a stack was picked up")
	local swapping = sessionWith("log 10", "stone 4")
	check(InventorySession.click(swapping, "pack", 1, "left") == true, "click: true for a swap")
	local empty = InventorySession.open(Inventory.new(1))
	check(InventorySession.click(empty, "pack", 1, "left") == false, "click: false on nothing while carrying nothing")
	local single = InventorySession.open(inventoryOf("stove 1, log 1"))
	check(
		InventorySession.click(single, "pack", 2, "right") == true,
		"click: true when a single item is picked up with a right click"
	)
	InventorySession.drop(single)
	check(
		InventorySession.click(single, "pack", 1, "left") == true,
		"click: true when a single item is picked up with a left click"
	)
end

do -- quickMove
	local pack, crate = inventoryOf("log 12, stone 5, -"), inventoryOf("log 10, -")
	local session = InventorySession.open(pack, crate)
	check(InventorySession.quickMove(session, "pack", 3) == 0, "quickMove: 0 from a slot that holds nothing")
	check(InventorySession.quickMove(session, "pack", 1) == 12, "quickMove: returns how many moved")
	check(
		contents(pack) == "-, stone 5, -" and contents(crate) == "log 16, log 6",
		"quickMove: tops up the same item in the other inventory, then uses an empty slot"
	)
	check(InventorySession.quickMove(session, "pack", 2) == 0, "quickMove: 0 when the other inventory has no room")
	check(
		contents(pack) == "-, stone 5, -" and contents(crate) == "log 16, log 6",
		"quickMove: a stack that does not fit stays where it was"
	)
	check(
		InventorySession.quickMove(session, "other", 2) == 6,
		"quickMove: from the other inventory it goes to the pack"
	)
	check(
		contents(pack) == "log 6, stone 5, -" and contents(crate) == "log 16, -",
		"quickMove: lands in the lowest slot that holds nothing"
	)
	check(session.carried == nil, "quickMove: the carried stack is not involved")

	local partPack, partCrate = inventoryOf("log 16"), inventoryOf("log 10, stone 1")
	local part = InventorySession.open(partPack, partCrate)
	check(InventorySession.quickMove(part, "pack", 1) == 6, "quickMove: moves what fits")
	check(
		contents(partPack) == "log 10" and contents(partCrate) == "log 16, stone 1",
		"quickMove: what does not fit stays in its slot"
	)

	local alone = InventorySession.open(inventoryOf("log 12, -"))
	check(InventorySession.quickMove(alone, "pack", 1) == 0, "quickMove: 0 when the pack is open alone")
	check(contents(alone.pack) == "log 12, -", "quickMove: with the pack alone, nothing moves")
end

do -- drop: handing carried items to the caller, to put on the ground
	local session = InventorySession.open(inventoryOf("log 10"))
	check(InventorySession.drop(session) == nil, "drop: nil when nothing is carried")
	check(InventorySession.drop(session, 2) == nil, "drop: nil when nothing is carried, whatever count is asked for")
	InventorySession.pickUp(session, "pack", 1)
	check(describe(InventorySession.drop(session, 1)) == "log 1", "drop: returns that many as a stack")
	check(describe(session.carried) == "log 9", "drop: the rest stays carried")
	check(
		InventorySession.drop(session, 0) == nil and describe(session.carried) == "log 9",
		"drop: taking 0 changes nothing"
	)
	check(
		describe(InventorySession.drop(session, 50)) == "log 9",
		"drop: asked for more than is carried, returns what is carried"
	)
	check(session.carried == nil, "drop: nothing is carried afterwards")
	Inventory.addItems(session.pack, "log", 4)
	InventorySession.pickUp(session, "pack", 1)
	check(
		describe(InventorySession.drop(session)) == "log 4" and session.carried == nil,
		"drop: with no count, the whole carried stack"
	)
end

do -- close
	local nothing = InventorySession.open(inventoryOf("log 10"))
	check(InventorySession.close(nothing) == nil, "close: nil when nothing is carried")

	local session = InventorySession.open(inventoryOf("log 16, log 4, -"))
	InventorySession.pickUp(session, "pack", 1)
	check(
		InventorySession.close(session) == nil and session.carried == nil,
		"close: all of it fits, and nothing is carried afterwards"
	)
	check(
		contents(session.pack) == "log 4, log 16, -",
		"close: tops up the same item first, then uses the lowest empty slot"
	)

	local crate = inventoryOf("log 16")
	local tight = InventorySession.open(inventoryOf("log 10"), crate)
	InventorySession.pickUp(tight, "other", 1)
	check(
		describe(InventorySession.close(tight)) == "log 10",
		"close: returns the stack of what did not fit in the pack"
	)
	check(
		tight.carried == nil and contents(tight.pack) == "log 16",
		"close: what fitted went in, and nothing is carried"
	)
	check(contents(crate) == "-", "close: nothing goes back to the other inventory")

	local stones = inventoryOf("stone 1")
	local none = InventorySession.open(stones, inventoryOf("log 3"))
	InventorySession.pickUp(none, "other", 1)
	check(
		describe(InventorySession.close(none)) == "log 3" and contents(stones) == "stone 1",
		"close: a pack with no room returns the whole stack"
	)
end

do -- mistakes in the calling code
	local session = InventorySession.open(inventoryOf("log 5, -"), inventoryOf("stone 2"))
	local alone = InventorySession.open(inventoryOf("log 5, -"))
	check(
		raises("InventorySession.pickUp: slot 3 is out of range; that inventory has slots 1 to 2", function()
			return InventorySession.pickUp(session, "pack", 3)
		end),
		"pickUp: refuses a slot the pack does not have"
	)
	check(
		raises("InventorySession.putDown: slot 2 is out of range; that inventory has slots 1 to 1", function()
			return InventorySession.putDown(session, "other", 2)
		end),
		"putDown: refuses a slot the other inventory does not have"
	)
	check(
		raises("InventorySession.swap: slot 0 is out of range", function()
			InventorySession.swap(session, "pack", 0)
		end),
		"swap: refuses slot 0"
	)
	check(
		raises("InventorySession.click: slot 1.5 is out of range", function()
			return InventorySession.click(session, "pack", 1.5, "left")
		end),
		"click: refuses a slot number that is not whole"
	)
	check(
		raises('InventorySession.quickMove: side is "other", but this session has no other inventory open', function()
			return InventorySession.quickMove(alone, "other", 1)
		end),
		"quickMove: refuses the other inventory when the pack is open alone"
	)
	check(
		raises('InventorySession.pickUp: side must be "pack" or "other"; got crate', function()
			return InventorySession.pickUp(session, "crate" :: any, 1)
		end),
		"pickUp: refuses a side that is neither pack nor other"
	)
	check(
		raises('InventorySession.click: button must be "left" or "right"; got middle', function()
			return InventorySession.click(session, "pack", 1, "middle" :: any)
		end),
		"click: refuses a button that is neither left nor right"
	)
	for _, badCount in { -1, 1.5, 0 / 0, math.huge } do
		check(
			raises("InventorySession.pickUp: count must be a whole number, 0 or more", function()
				return InventorySession.pickUp(session, "pack", 1, badCount)
			end),
			"pickUp: refuses a count of " .. tostring(badCount)
		)
		check(
			raises("InventorySession.putDown: count must be a whole number, 0 or more", function()
				return InventorySession.putDown(session, "pack", 1, badCount)
			end),
			"putDown: refuses a count of " .. tostring(badCount)
		)
		check(
			raises("InventorySession.drop: count must be a whole number, 0 or more", function()
				return InventorySession.drop(session, badCount)
			end),
			"drop: refuses a count of " .. tostring(badCount)
		)
	end
	check(session.carried == nil and contents(session.pack) == "log 5, -", "nothing refused changed the session")
end

do -- no action ever makes or loses an item
	local seed = 20261119
	local function random(limit: number): number
		seed = (seed * 1103515245 + 12345) % 2147483648
		return math.floor(seed / 65536) % limit + 1
	end
	local pack, crate = Inventory.new(4), Inventory.new(4)
	Inventory.addItems(pack, "log", 37)
	Inventory.addItems(pack, "stone", 9)
	Inventory.addItems(crate, "stove", 2)
	Inventory.addItems(crate, "stone", 20)
	local itemIds = { "log", "stone", "stove" }
	local totals: { [string]: number } = {}
	for _, itemId in itemIds do
		totals[itemId] = Inventory.countItems(pack, itemId) + Inventory.countItems(crate, itemId)
	end
	local session = InventorySession.open(pack, crate)
	local sides: { InventorySession.Side } = { "pack", "other" }
	local broken: string? = nil
	for step = 1, 30000 do
		local side = sides[random(2)]
		local slot = random(4)
		local action = random(12)
		if action <= 3 then
			InventorySession.click(session, side, slot, "left")
		elseif action <= 6 then
			InventorySession.click(session, side, slot, "right")
		elseif action == 7 then
			InventorySession.pickUp(session, side, slot, random(21) - 1)
		elseif action == 8 then
			InventorySession.putDown(session, side, slot, random(21) - 1)
		elseif action == 9 then
			InventorySession.swap(session, side, slot)
		elseif action == 10 then
			InventorySession.quickMove(session, side, slot)
		elseif action == 11 then
			local dropped = InventorySession.drop(session, random(4) - 1)
			if dropped then
				totals[dropped.itemId] -= dropped.count
			end
		else
			local dropped = InventorySession.close(session)
			if dropped then
				totals[dropped.itemId] -= dropped.count
			end
			if session.carried ~= nil then
				broken = broken or string.format("step %d: something is still carried after close", step)
			end
		end
		local carried = session.carried
		for _, itemId in itemIds do
			local inHand = if carried and carried.itemId == itemId then carried.count else 0
			if Inventory.countItems(pack, itemId) + Inventory.countItems(crate, itemId) + inHand ~= totals[itemId] then
				broken = broken or string.format("step %d: the number of %s is wrong", step, itemId)
			end
		end
		if carried and (carried.count < 1 or ItemStack.spaceLeft(carried) < 0) then
			broken = broken or string.format("step %d: the carried stack is one that could not exist", step)
		end
		if broken then
			break
		end
	end
	check(
		broken == nil,
		"30,000 random actions: " .. (broken or "every item is in a slot, carried, or was handed to the caller")
	)
end

do -- hasSlot
	local pack = Inventory.new(4)
	local alone = InventorySession.open(pack)
	local withCrate = InventorySession.open(pack, Inventory.new(2))
	check(InventorySession.hasSlot(alone, "pack", 1), "hasSlot: the first slot of the pack")
	check(InventorySession.hasSlot(alone, "pack", 4), "hasSlot: the last slot of the pack")
	check(not InventorySession.hasSlot(alone, "pack", 5), "hasSlot: not a slot past the last")
	check(not InventorySession.hasSlot(alone, "pack", 0), "hasSlot: not slot 0")
	check(not InventorySession.hasSlot(alone, "other", 1), "hasSlot: not the other side when the pack is open alone")
	check(InventorySession.hasSlot(withCrate, "other", 2), "hasSlot: the last slot of the other inventory")
	check(not InventorySession.hasSlot(withCrate, "other", 3), "hasSlot: not a slot the other inventory lacks")
	check(InventorySession.hasSlot(withCrate, "pack", 4), "hasSlot: the pack, when another inventory is open too")
	for _, badSide in { "crate", "", 1, true, {} } :: { any } do
		check(not InventorySession.hasSlot(withCrate, badSide, 1), "hasSlot: not the side " .. tostring(badSide))
	end
	check(not InventorySession.hasSlot(withCrate, nil, 1), "hasSlot: not without a side")
	for _, badSlot in { 1.5, -1, 0 / 0, math.huge, "1", true, {} } :: { any } do
		check(not InventorySession.hasSlot(withCrate, "pack", badSlot), "hasSlot: not the slot " .. tostring(badSlot))
	end
	check(not InventorySession.hasSlot(withCrate, "pack", nil), "hasSlot: not without a slot")
end

Check.finish("InventorySession")
