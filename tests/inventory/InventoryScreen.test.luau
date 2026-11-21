--!strict
-- Tests for InventoryScreen. Run from the repository root: lune run tests/inventory/InventoryScreen.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")

local check = Check.that

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

-- Describes the other inventory of a screen.
local function otherContents(screen: InventoryScreen.InventoryScreen): string
	return contents(screen.otherInventory :: Inventory.Inventory)
end

-- Returns a screen over a pack holding `inPack`, already carrying `carried`.
local function carrying(carried: string, inPack: string): InventoryScreen.InventoryScreen
	local screen = InventoryScreen.new(inventoryOf(inPack), inventoryOf(carried))
	InventoryScreen.pickUpFromSlot(screen, "other", 1)
	return screen
end

-- Names a slot of the screen, for a list of them.
local function at(side: InventoryScreen.Side, slot: number): InventoryScreen.ScreenSlot
	return { side = side, slot = slot }
end

-- A stove: slot 1 accepts only stone, slot 2 only logs, and slot 3 nothing.
local function stoveAccepts(slot: number, itemId: string): boolean
	if slot == 1 then
		return itemId == "stone"
	elseif slot == 2 then
		return itemId == "log"
	end
	return false
end

-- Returns a screen over `pack` and a stove holding `stove`.
local function stoveScreen(pack: string, stove: string): InventoryScreen.InventoryScreen
	return InventoryScreen.new(inventoryOf(pack), inventoryOf(stove), stoveAccepts)
end

do -- new
	local pack, crate = Inventory.new(2), Inventory.new(3)
	local alone = InventoryScreen.new(pack)
	check(alone.pack == pack and alone.otherInventory == nil, "new: with the pack alone there is no other inventory")
	check(alone.carriedStack == nil, "new: nothing is carried")
	check(alone.otherSlotAcceptsItem == nil, "new: with no rule given there is none")
	local both = InventoryScreen.new(pack, crate, stoveAccepts)
	check(both.pack == pack and both.otherInventory == crate, "new: holds the inventories it was given, not copies")
	check(both.otherSlotAcceptsItem == stoveAccepts, "new: keeps the rule it was given")
	check(both.carriedStack == nil, "new: nothing is carried when another inventory is open")
end

do -- getInventoryOnSide
	local pack, crate = Inventory.new(2), Inventory.new(3)
	local screen = InventoryScreen.new(pack, crate)
	check(InventoryScreen.getInventoryOnSide(screen, "pack") == pack, "getInventoryOnSide: the pack is the pack")
	check(
		InventoryScreen.getInventoryOnSide(screen, "other") == crate,
		"getInventoryOnSide: other is the other inventory"
	)
	local alone = InventoryScreen.new(pack)
	check(InventoryScreen.getInventoryOnSide(alone, "pack") == pack, "getInventoryOnSide: the pack, when open alone")
	local message = Check.errorFrom(function()
		return InventoryScreen.getInventoryOnSide(alone, "other")
	end)
	check(
		message ~= nil and string.find(message, "no other inventory is open", 1, true) ~= nil,
		"getInventoryOnSide: fails for the other side when the pack is open alone"
	)
end

do -- hasSlot
	local pack = Inventory.new(4)
	local alone = InventoryScreen.new(pack)
	local withCrate = InventoryScreen.new(pack, Inventory.new(2))
	check(InventoryScreen.hasSlot(alone, "pack", 1), "hasSlot: the first slot of the pack")
	check(InventoryScreen.hasSlot(alone, "pack", 4), "hasSlot: the last slot of the pack")
	check(not InventoryScreen.hasSlot(alone, "pack", 5), "hasSlot: not a slot past the last")
	check(not InventoryScreen.hasSlot(alone, "pack", 0), "hasSlot: not slot 0")
	check(not InventoryScreen.hasSlot(alone, "other", 1), "hasSlot: not the other side when the pack is open alone")
	check(InventoryScreen.hasSlot(withCrate, "other", 2), "hasSlot: the last slot of the other inventory")
	check(not InventoryScreen.hasSlot(withCrate, "other", 3), "hasSlot: not a slot the other inventory lacks")
	check(InventoryScreen.hasSlot(withCrate, "pack", 4), "hasSlot: the pack, when another inventory is open too")
	for _, badSide in { "crate", "", 1, true, {} } :: { any } do
		check(not InventoryScreen.hasSlot(withCrate, badSide, 1), "hasSlot: not the side " .. tostring(badSide))
	end
	check(not InventoryScreen.hasSlot(withCrate, nil, 1), "hasSlot: not without a side")
	for _, badSlot in { 1.5, -1, 0 / 0, math.huge, "1", true, {} } :: { any } do
		check(not InventoryScreen.hasSlot(withCrate, "pack", badSlot), "hasSlot: not the slot " .. tostring(badSlot))
	end
	check(not InventoryScreen.hasSlot(withCrate, "pack", nil), "hasSlot: not without a slot")
end

do -- hasEverySlot
	local alone = InventoryScreen.new(Inventory.new(4))
	local withCrate = InventoryScreen.new(Inventory.new(4), Inventory.new(2))
	check(InventoryScreen.hasEverySlot(withCrate, {}), "hasEverySlot: a list of none")
	check(
		InventoryScreen.hasEverySlot(withCrate, { at("pack", 4), at("other", 2), at("pack", 4) }),
		"hasEverySlot: slots of both inventories, even one named twice"
	)
	check(
		not InventoryScreen.hasEverySlot(withCrate, { at("pack", 4), at("other", 3) }),
		"hasEverySlot: not if one of them is not a slot"
	)
	check(
		not InventoryScreen.hasEverySlot(alone, { at("other", 1) }),
		"hasEverySlot: not the other side when the pack is open alone"
	)
	check(not InventoryScreen.hasEverySlot(withCrate, nil), "hasEverySlot: not nothing at all")
	for _, notList in { "pack", 7, true } :: { any } do
		check(not InventoryScreen.hasEverySlot(withCrate, notList), "hasEverySlot: not " .. tostring(notList))
	end
	check(not InventoryScreen.hasEverySlot(withCrate, { "pack" }), "hasEverySlot: not a list of something else")
	check(
		not InventoryScreen.hasEverySlot(withCrate, { {} }),
		"hasEverySlot: not a list with an entry that names no slot"
	)
	check(
		not InventoryScreen.hasEverySlot(withCrate, { { side = "pack" } }),
		"hasEverySlot: not an entry with no slot number"
	)
	check(
		not InventoryScreen.hasEverySlot(withCrate, { at("pack", 1), 5 }),
		"hasEverySlot: not a list whose second entry is not a slot"
	)
	check(
		not InventoryScreen.hasEverySlot(withCrate, { side = "pack", slot = 1 }),
		"hasEverySlot: not one slot given where a list is wanted"
	)
	local withOtherKeys: any = { at("pack", 1) }
	withOtherKeys.extra = at("pack", 2)
	check(
		not InventoryScreen.hasEverySlot(withCrate, withOtherKeys),
		"hasEverySlot: not a list with other keys as well"
	)
end

do -- slotAcceptsItem
	local screen = stoveScreen("-", "-, -, -")
	check(
		InventoryScreen.slotAcceptsItem(screen, "other", 1, "stone"),
		"slotAcceptsItem: a slot accepts an item its rule names"
	)
	check(
		not InventoryScreen.slotAcceptsItem(screen, "other", 1, "log"),
		"slotAcceptsItem: and not one the rule leaves out"
	)
	check(
		InventoryScreen.slotAcceptsItem(screen, "other", 2, "log"),
		"slotAcceptsItem: each slot has a rule of its own"
	)
	check(
		not InventoryScreen.slotAcceptsItem(screen, "other", 3, "log"),
		"slotAcceptsItem: a slot that accepts nothing says no"
	)
	check(
		InventoryScreen.slotAcceptsItem(screen, "pack", 1, "stove"),
		"slotAcceptsItem: every slot of the pack accepts anything"
	)
	local plain = InventoryScreen.new(inventoryOf("-"), inventoryOf("-"))
	check(
		InventoryScreen.slotAcceptsItem(plain, "other", 1, "stove"),
		"slotAcceptsItem: with no rule, every slot accepts everything"
	)
	local full = inventoryOf("log 16")
	check(
		InventoryScreen.slotAcceptsItem(InventoryScreen.new(inventoryOf("-"), full), "other", 1, "log"),
		"slotAcceptsItem: a slot with no room may still accept the item"
	)
end

do -- pickUpFromSlot
	local screen = InventoryScreen.new(inventoryOf("log 12, stone 5, -"))
	check(
		InventoryScreen.pickUpFromSlot(screen, "pack", 3) == 0 and screen.carriedStack == nil,
		"pickUpFromSlot: a slot that holds nothing gives 0 and nothing is carried"
	)
	check(InventoryScreen.pickUpFromSlot(screen, "pack", 1, 5) == 5, "pickUpFromSlot: returns how many were picked up")
	check(
		describe(screen.carriedStack) == "log 5" and contents(screen.pack) == "log 7, stone 5, -",
		"pickUpFromSlot: part of a stack is carried and the rest stays in the slot"
	)
	check(
		InventoryScreen.pickUpFromSlot(screen, "pack", 1, 3) == 3 and describe(screen.carriedStack) == "log 8",
		"pickUpFromSlot: more of the same item is added to what is carried"
	)
	check(InventoryScreen.pickUpFromSlot(screen, "pack", 2) == 0, "pickUpFromSlot: 0 when a different item is carried")
	check(
		describe(screen.carriedStack) == "log 8" and contents(screen.pack) == "log 4, stone 5, -",
		"pickUpFromSlot: a refused pick up changes nothing"
	)
	check(
		InventoryScreen.pickUpFromSlot(screen, "pack", 1, 0) == 0 and describe(screen.carriedStack) == "log 8",
		"pickUpFromSlot: a count of 0 changes nothing"
	)
	check(
		InventoryScreen.pickUpFromSlot(screen, "pack", 1) == 4 and contents(screen.pack) == "-, stone 5, -",
		"pickUpFromSlot: with no count, all of the stack that the carried stack has room for"
	)
	check(describe(screen.carriedStack) == "log 12", "pickUpFromSlot: the carried stack holds everything picked up")
	check(
		InventoryScreen.pickUpFromSlot(screen, "pack", 1, 50) == 0,
		"pickUpFromSlot: a slot that holds nothing gives 0 whatever count is asked for"
	)

	local full = InventoryScreen.new(inventoryOf("log 16, log 10"))
	InventoryScreen.pickUpFromSlot(full, "pack", 2)
	check(
		InventoryScreen.pickUpFromSlot(full, "pack", 1) == 6,
		"pickUpFromSlot: only what the carried stack has room for"
	)
	check(
		describe(full.carriedStack) == "log 16" and contents(full.pack) == "log 10, -",
		"pickUpFromSlot: the rest stays in the slot"
	)
	check(
		InventoryScreen.pickUpFromSlot(full, "pack", 1) == 0,
		"pickUpFromSlot: nothing more when the carried stack is full"
	)

	local crate = InventoryScreen.new(inventoryOf("-"), inventoryOf("log 4"))
	check(InventoryScreen.pickUpFromSlot(crate, "other", 1) == 4, "pickUpFromSlot: from the other inventory too")
	check(
		otherContents(crate) == "-" and describe(crate.carriedStack) == "log 4",
		"pickUpFromSlot: it is carried, not copied"
	)

	local stoves = InventoryScreen.new(inventoryOf("stove 1"))
	check(
		InventoryScreen.pickUpFromSlot(stoves, "pack", 1) == 1,
		"pickUpFromSlot: picks up an item that does not stack"
	)
	check(describe(stoves.carriedStack) == "stove 1", "pickUpFromSlot: and it is carried")

	local half = InventoryScreen.new(inventoryOf("log 5"))
	check(
		InventoryScreen.pickUpFromSlot(half, "pack", 1, 3) == 3,
		"pickUpFromSlot: half of an odd stack, rounded up, is the larger half"
	)
	check(
		contents(half.pack) == "log 2" and describe(half.carriedStack) == "log 3",
		"pickUpFromSlot: and the smaller half stays"
	)
end

do -- putDownInSlot
	local screen = InventoryScreen.new(inventoryOf("-, log 12, stone 5"), inventoryOf("log 10"))
	check(InventoryScreen.putDownInSlot(screen, "pack", 1) == 0, "putDownInSlot: 0 when nothing is carried")
	InventoryScreen.pickUpFromSlot(screen, "other", 1)
	check(InventoryScreen.putDownInSlot(screen, "pack", 1, 3) == 3, "putDownInSlot: returns how many were put down")
	check(
		describe(screen.carriedStack) == "log 7" and contents(screen.pack) == "log 3, log 12, stone 5",
		"putDownInSlot: part is put down and the rest stays carried"
	)
	check(InventoryScreen.putDownInSlot(screen, "pack", 3) == 0, "putDownInSlot: 0 onto a different item")
	check(
		describe(screen.carriedStack) == "log 7" and contents(screen.pack) == "log 3, log 12, stone 5",
		"putDownInSlot: a refused put down changes nothing"
	)
	check(InventoryScreen.putDownInSlot(screen, "pack", 2) == 4, "putDownInSlot: only what the slot has room for")
	check(
		describe(screen.carriedStack) == "log 3" and contents(screen.pack) == "log 3, log 16, stone 5",
		"putDownInSlot: what does not fit stays carried"
	)
	check(InventoryScreen.putDownInSlot(screen, "pack", 2) == 0, "putDownInSlot: 0 onto a full stack")
	check(
		InventoryScreen.putDownInSlot(screen, "pack", 1, 0) == 0 and describe(screen.carriedStack) == "log 3",
		"putDownInSlot: a count of 0 changes nothing"
	)
	check(
		InventoryScreen.putDownInSlot(screen, "pack", 1, 99) == 3,
		"putDownInSlot: asked for more than is carried, puts down what is carried"
	)
	check(
		screen.carriedStack == nil and contents(screen.pack) == "log 6, log 16, stone 5",
		"putDownInSlot: nothing is carried once the last item is put down"
	)

	local whole = carrying("log 10", "-, -")
	check(InventoryScreen.putDownInSlot(whole, "pack", 2) == 10, "putDownInSlot: with no count, all that is carried")
	check(
		contents(whole.pack) == "-, log 10" and whole.carriedStack == nil,
		"putDownInSlot: into a slot that holds nothing, and nothing is carried afterwards"
	)

	local fits = carrying("log 10", "log 3")
	check(InventoryScreen.putDownInSlot(fits, "pack", 1) == 10, "putDownInSlot: all of it fits on the same item")
	check(contents(fits.pack) == "log 13", "putDownInSlot: and joins the stack there")

	local crate = InventoryScreen.new(inventoryOf("log 5"), inventoryOf("-, -"))
	InventoryScreen.pickUpFromSlot(crate, "pack", 1)
	check(InventoryScreen.putDownInSlot(crate, "other", 2) == 5, "putDownInSlot: into the other inventory too")
	check(otherContents(crate) == "-, log 5", "putDownInSlot: it lands in the slot named")

	local stoves = carrying("stove 1", "stove 1")
	check(
		InventoryScreen.putDownInSlot(stoves, "pack", 1) == 0,
		"putDownInSlot: an item that does not stack never goes onto another"
	)
	check(
		describe(stoves.carriedStack) == "stove 1" and contents(stoves.pack) == "stove 1",
		"putDownInSlot: and nothing changes"
	)
end

do -- putDownInSlot into slots that accept only some items
	local screen = stoveScreen("log 12, stone 5, stove 1, -", "-, -, -")
	InventoryScreen.pickUpFromSlot(screen, "pack", 1)
	check(
		InventoryScreen.putDownInSlot(screen, "other", 1) == 0,
		"putDownInSlot: 0 into a slot that does not accept the item"
	)
	check(InventoryScreen.putDownInSlot(screen, "other", 3) == 0, "putDownInSlot: 0 into a slot that accepts nothing")
	check(
		describe(screen.carriedStack) == "log 12" and otherContents(screen) == "-, -, -",
		"putDownInSlot: a refused put down leaves the stack carried"
	)
	check(
		InventoryScreen.putDownInSlot(screen, "other", 2, 5) == 5,
		"putDownInSlot: into the slot that accepts the item"
	)
	check(InventoryScreen.putDownInSlot(screen, "other", 2) == 7, "putDownInSlot: and the rest of the stack follows")
	check(
		otherContents(screen) == "-, log 12, -" and screen.carriedStack == nil,
		"putDownInSlot: the stack is in the slot meant for it"
	)

	-- What comes out of a stove sits in the slot that accepts nothing, and can always be taken out.
	local cooked = stoveScreen("-, -, -, -", "-, -, stove 1")
	check(
		InventoryScreen.pickUpFromSlot(cooked, "other", 3) == 1,
		"pickUpFromSlot: takes a stack out of a slot that accepts nothing"
	)
	check(describe(cooked.carriedStack) == "stove 1", "pickUpFromSlot: and it is carried")
	check(InventoryScreen.putDownInSlot(cooked, "other", 3) == 0, "putDownInSlot: but it cannot be put back there")
	check(InventoryScreen.putDownInSlot(cooked, "pack", 1) == 1, "putDownInSlot: it can go into the pack")
end

do -- swapCarriedStackWithSlot
	local screen = InventoryScreen.new(inventoryOf("log 12, stone 5, -"))
	InventoryScreen.swapCarriedStackWithSlot(screen, "pack", 1)
	check(
		describe(screen.carriedStack) == "log 12" and contents(screen.pack) == "-, stone 5, -",
		"swapCarriedStackWithSlot: carrying nothing, it carries the slot's whole stack"
	)
	InventoryScreen.swapCarriedStackWithSlot(screen, "pack", 2)
	check(
		describe(screen.carriedStack) == "stone 5" and contents(screen.pack) == "-, log 12, -",
		"swapCarriedStackWithSlot: exchanges the carried stack with the slot's"
	)
	InventoryScreen.swapCarriedStackWithSlot(screen, "pack", 3)
	check(
		screen.carriedStack == nil and contents(screen.pack) == "-, log 12, stone 5",
		"swapCarriedStackWithSlot: into a slot that holds nothing, it puts the carried stack down"
	)
	InventoryScreen.swapCarriedStackWithSlot(screen, "pack", 1)
	check(
		screen.carriedStack == nil and contents(screen.pack) == "-, log 12, stone 5",
		"swapCarriedStackWithSlot: nothing with nothing changes nothing"
	)

	local same = carrying("log 10", "log 16")
	InventoryScreen.swapCarriedStackWithSlot(same, "pack", 1)
	check(
		describe(same.carriedStack) == "log 16" and contents(same.pack) == "log 10",
		"swapCarriedStackWithSlot: the same item is exchanged whole, not merged"
	)

	local different = carrying("log 10", "stone 4")
	InventoryScreen.swapCarriedStackWithSlot(different, "pack", 1)
	check(
		describe(different.carriedStack) == "stone 4" and contents(different.pack) == "log 10",
		"swapCarriedStackWithSlot: a different item is exchanged"
	)

	local crate = InventoryScreen.new(inventoryOf("log 4"), inventoryOf("stone 2"))
	InventoryScreen.swapCarriedStackWithSlot(crate, "other", 1)
	check(
		describe(crate.carriedStack) == "stone 2" and otherContents(crate) == "-",
		"swapCarriedStackWithSlot: picks up from the other inventory"
	)

	-- It exchanges whatever the slot accepts: asking is canSwapCarriedStackWithSlot's.
	local stove = stoveScreen("stove 1, log 12, -, -", "-, log 12, -")
	InventoryScreen.pickUpFromSlot(stove, "pack", 1)
	InventoryScreen.swapCarriedStackWithSlot(stove, "other", 2)
	check(
		describe(stove.carriedStack) == "log 12" and otherContents(stove) == "-, stove 1, -",
		"swapCarriedStackWithSlot: it does not ask whether the slot accepts the carried item"
	)
end

do -- canSwapCarriedStackWithSlot
	local stove = stoveScreen("stove 1, log 12, -, -", "-, log 12, -")
	check(
		InventoryScreen.canSwapCarriedStackWithSlot(stove, "other", 2)
			and InventoryScreen.canSwapCarriedStackWithSlot(stove, "other", 3),
		"canSwapCarriedStackWithSlot: true with nothing carried, whatever the slot accepts"
	)
	InventoryScreen.pickUpFromSlot(stove, "pack", 1)
	check(
		not InventoryScreen.canSwapCarriedStackWithSlot(stove, "other", 2),
		"canSwapCarriedStackWithSlot: false when the slot does not accept the carried item"
	)
	check(
		not InventoryScreen.canSwapCarriedStackWithSlot(stove, "other", 1),
		"canSwapCarriedStackWithSlot: false for a slot that holds nothing and does not accept the carried item"
	)
	check(
		InventoryScreen.canSwapCarriedStackWithSlot(stove, "pack", 3),
		"canSwapCarriedStackWithSlot: true for a slot of the pack, which accepts anything"
	)
	check(
		describe(stove.carriedStack) == "stove 1" and otherContents(stove) == "-, log 12, -",
		"canSwapCarriedStackWithSlot: asking changes nothing"
	)
	InventoryScreen.swapCarriedStackWithSlot(stove, "pack", 3)
	InventoryScreen.swapCarriedStackWithSlot(stove, "other", 2)
	check(
		describe(stove.carriedStack) == "log 12" and InventoryScreen.canSwapCarriedStackWithSlot(stove, "other", 2),
		"canSwapCarriedStackWithSlot: true when the slot accepts the carried item"
	)
	check(
		not InventoryScreen.canSwapCarriedStackWithSlot(stove, "other", 1),
		"canSwapCarriedStackWithSlot: and false for the slot beside it that does not"
	)
end

do -- swapSlots
	local screen = InventoryScreen.new(inventoryOf("log 12, stone 3, -, stove 1"), inventoryOf("log 5, -"))
	InventoryScreen.pickUpFromSlot(screen, "pack", 4)
	InventoryScreen.swapSlots(screen, "other", 1, "pack", 2)
	check(
		contents(screen.pack) == "log 12, log 5, -, -" and otherContents(screen) == "stone 3, -",
		"swapSlots: slots of different inventories change places"
	)
	InventoryScreen.swapSlots(screen, "other", 2, "pack", 1)
	check(
		contents(screen.pack) == "-, log 5, -, -" and otherContents(screen) == "stone 3, log 12",
		"swapSlots: a slot that holds nothing takes the other's stack"
	)
	InventoryScreen.swapSlots(screen, "other", 1, "pack", 1)
	check(
		contents(screen.pack) == "stone 3, log 5, -, -" and otherContents(screen) == "-, log 12",
		"swapSlots: the other slot may be the one that holds nothing"
	)
	InventoryScreen.swapSlots(screen, "pack", 3, "pack", 2)
	check(contents(screen.pack) == "stone 3, -, log 5, -", "swapSlots: two slots of the pack change places")
	InventoryScreen.swapSlots(screen, "pack", 4, "pack", 2)
	check(contents(screen.pack) == "stone 3, -, log 5, -", "swapSlots: two slots that hold nothing stay so")
	InventoryScreen.swapSlots(screen, "pack", 1, "pack", 1)
	check(contents(screen.pack) == "stone 3, -, log 5, -", "swapSlots: a slot swapped with itself is unchanged")
	check(describe(screen.carriedStack) == "stove 1", "swapSlots: the carried stack is not involved")

	local same = InventoryScreen.new(inventoryOf("log 10, log 3"))
	InventoryScreen.swapSlots(same, "pack", 1, "pack", 2)
	check(contents(same.pack) == "log 3, log 10", "swapSlots: stacks of the same item are exchanged, not merged")

	-- It exchanges whatever the slots accept: asking is canSwapSlots's.
	local stove = stoveScreen("log 12, stone 5, -, stove 1", "-, -, stove 1")
	InventoryScreen.swapSlots(stove, "other", 1, "pack", 1)
	check(
		otherContents(stove) == "log 12, -, stove 1" and contents(stove.pack) == "-, stone 5, -, stove 1",
		"swapSlots: it does not ask whether each slot accepts the other's stack"
	)
end

do -- canSwapSlots
	local stove = stoveScreen("log 12, stone 5, -, stove 1", "-, -, stove 1")
	check(
		not InventoryScreen.canSwapSlots(stove, "other", 1, "pack", 1),
		"canSwapSlots: false when a slot does not accept the other slot's stack"
	)
	check(
		not InventoryScreen.canSwapSlots(stove, "pack", 1, "other", 1),
		"canSwapSlots: and the same with the two slots named the other way round"
	)
	check(
		InventoryScreen.canSwapSlots(stove, "other", 1, "pack", 2),
		"canSwapSlots: true when the slot accepts the other slot's stack"
	)
	check(
		InventoryScreen.canSwapSlots(stove, "other", 3, "pack", 3),
		"canSwapSlots: true when a stack comes out of a slot that accepts nothing into a slot that holds nothing"
	)
	check(
		not InventoryScreen.canSwapSlots(stove, "other", 2, "pack", 4),
		"canSwapSlots: false when the slot that holds nothing does not accept the other's stack"
	)
	check(
		InventoryScreen.canSwapSlots(stove, "pack", 3, "other", 2),
		"canSwapSlots: true for two slots that hold nothing"
	)
	check(
		otherContents(stove) == "-, -, stove 1" and contents(stove.pack) == "log 12, stone 5, -, stove 1",
		"canSwapSlots: asking changes nothing"
	)
	local half = stoveScreen("stove 1, log 4", "-, log 3, -")
	check(
		not InventoryScreen.canSwapSlots(half, "pack", 1, "other", 2),
		"canSwapSlots: false when only one of the two slots would accept the other's stack"
	)
	local pack = InventoryScreen.new(inventoryOf("log 12, stone 5"))
	check(InventoryScreen.canSwapSlots(pack, "pack", 1, "pack", 2), "canSwapSlots: true for any two slots of the pack")
end

do -- fillCarriedStackFromAllSlots
	local screen =
		InventoryScreen.new(inventoryOf("log 16, log 3, stone 5, log 2"), inventoryOf("log 4, log 16, stone 1"))
	local other = screen.otherInventory :: Inventory.Inventory
	check(
		InventoryScreen.fillCarriedStackFromAllSlots(screen) == 0,
		"fillCarriedStackFromAllSlots: 0 when nothing is carried"
	)
	InventoryScreen.pickUpFromSlot(screen, "pack", 2)
	check(
		InventoryScreen.fillCarriedStackFromAllSlots(screen) == 13,
		"fillCarriedStackFromAllSlots: returns how many were gathered"
	)
	check(
		describe(screen.carriedStack) == "log 16",
		"fillCarriedStackFromAllSlots: they join the carried stack, until it is full"
	)
	check(
		contents(other) == "-, log 9, stone 1" and contents(screen.pack) == "log 16, -, stone 5, -",
		"fillCarriedStackFromAllSlots: slots that are not full go first, then a full stack is broken into, the other inventory's before the pack's"
	)
	check(
		InventoryScreen.fillCarriedStackFromAllSlots(screen) == 0,
		"fillCarriedStackFromAllSlots: 0 when the carried stack is full"
	)
	check(
		contents(other) == "-, log 9, stone 1" and contents(screen.pack) == "log 16, -, stone 5, -",
		"fillCarriedStackFromAllSlots: and nothing moves"
	)

	local few = InventoryScreen.new(inventoryOf("stone 2, log 1, stone 3, stone 16"))
	InventoryScreen.pickUpFromSlot(few, "pack", 1)
	check(
		InventoryScreen.fillCarriedStackFromAllSlots(few) == 14,
		"fillCarriedStackFromAllSlots: stops at the stack size"
	)
	check(describe(few.carriedStack) == "stone 16", "fillCarriedStackFromAllSlots: with a full stack carried")
	check(
		contents(few.pack) == "-, log 1, -, stone 5",
		"fillCarriedStackFromAllSlots: a slot that is not full is taken whole before a full stack is broken into, and other items are left"
	)

	local odd = InventoryScreen.new(inventoryOf("stone 16, stone 2, stone 3, stone 4"))
	InventoryScreen.pickUpFromSlot(odd, "pack", 2)
	check(
		InventoryScreen.fillCarriedStackFromAllSlots(odd) == 14,
		"fillCarriedStackFromAllSlots: fills the stack from slots that are not full and then a full stack"
	)
	check(
		contents(odd.pack) == "stone 9, -, -, -",
		"fillCarriedStackFromAllSlots: every slot that is not full went before the full stack was touched"
	)

	local lots = InventoryScreen.new(inventoryOf("stove 1, log 2, log 3, log 4"))
	InventoryScreen.pickUpFromSlot(lots, "pack", 2)
	check(
		InventoryScreen.fillCarriedStackFromAllSlots(lots) == 7,
		"fillCarriedStackFromAllSlots: takes every slot that is not full when they do not fill the stack"
	)
	check(
		describe(lots.carriedStack) == "log 9" and contents(lots.pack) == "stove 1, -, -, -",
		"fillCarriedStackFromAllSlots: and the carried stack holds them all"
	)

	local oneShort = InventoryScreen.new(inventoryOf("log 15, log 3"))
	InventoryScreen.pickUpFromSlot(oneShort, "pack", 1)
	check(
		InventoryScreen.fillCarriedStackFromAllSlots(oneShort) == 1,
		"fillCarriedStackFromAllSlots: takes a single item when that is all the stack lacks"
	)
	check(
		describe(oneShort.carriedStack) == "log 16" and contents(oneShort.pack) == "-, log 2",
		"fillCarriedStackFromAllSlots: and that one item is carried, not lost"
	)
	local oneThere = InventoryScreen.new(inventoryOf("log 4, log 1, -"))
	InventoryScreen.pickUpFromSlot(oneThere, "pack", 1)
	check(
		InventoryScreen.fillCarriedStackFromAllSlots(oneThere) == 1,
		"fillCarriedStackFromAllSlots: gathers a single item"
	)
	check(describe(oneThere.carriedStack) == "log 5", "fillCarriedStackFromAllSlots: and that item is carried")

	local nothing = InventoryScreen.new(inventoryOf("stove 1, log 4"))
	InventoryScreen.pickUpFromSlot(nothing, "pack", 2)
	check(
		InventoryScreen.fillCarriedStackFromAllSlots(nothing) == 0,
		"fillCarriedStackFromAllSlots: 0 when no slot holds its kind"
	)
	check(
		describe(nothing.carriedStack) == "log 4" and contents(nothing.pack) == "stove 1, -",
		"fillCarriedStackFromAllSlots: and nothing changes"
	)

	local order = InventoryScreen.new(inventoryOf("log 5, log 4, stone 5, -"))
	InventoryScreen.pickUpFromSlot(order, "pack", 1)
	check(
		InventoryScreen.fillCarriedStackFromAllSlots(order) == 4,
		"fillCarriedStackFromAllSlots: takes from the slot that holds the carried kind"
	)
	check(
		describe(order.carriedStack) == "log 9" and contents(order.pack) == "-, -, stone 5, -",
		"fillCarriedStackFromAllSlots: the empty slot the stack came from is not refilled"
	)

	-- The slot rule does not apply to taking items out.
	local gathering = stoveScreen("log 2, -, -, -", "-, log 5, log 3")
	InventoryScreen.pickUpFromSlot(gathering, "pack", 1)
	check(
		InventoryScreen.fillCarriedStackFromAllSlots(gathering) == 8,
		"fillCarriedStackFromAllSlots: takes from slots whatever their rule"
	)
	check(describe(gathering.carriedStack) == "log 10", "fillCarriedStackFromAllSlots: into the carried stack")
	check(
		otherContents(gathering) == "-, -, -",
		"fillCarriedStackFromAllSlots: the other inventory's slots are emptied"
	)

	local ties = InventoryScreen.new(inventoryOf("log 2, log 2, -"), inventoryOf("log 2, log 2"))
	InventoryScreen.pickUpFromSlot(ties, "pack", 1)
	InventoryScreen.fillCarriedStackFromAllSlots(ties)
	check(
		describe(ties.carriedStack) == "log 8",
		"fillCarriedStackFromAllSlots: takes from every slot of both inventories"
	)
	check(
		contents(ties.pack) == "-, -, -" and otherContents(ties) == "-, -",
		"fillCarriedStackFromAllSlots: that holds the carried kind"
	)

	local partly = InventoryScreen.new(inventoryOf("log 6, log 16, log 8"), inventoryOf("log 7"))
	InventoryScreen.pickUpFromSlot(partly, "pack", 1)
	check(
		InventoryScreen.fillCarriedStackFromAllSlots(partly) == 10,
		"fillCarriedStackFromAllSlots: takes from slots that are not full, other inventory first"
	)
	check(
		otherContents(partly) == "-" and contents(partly.pack) == "-, log 16, log 5",
		"fillCarriedStackFromAllSlots: and from the pack's lowest slot first when the stack fills up"
	)
end

do -- spreadCarriedStackOverSlots
	local screen = carrying("log 7", "-, -, -, -")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(screen, { at("pack", 1), at("pack", 2) }) == 6,
		"spreadCarriedStackOverSlots: returns how many items were put down"
	)
	check(
		contents(screen.pack) == "log 3, log 3, -, -",
		"spreadCarriedStackOverSlots: each slot gets an equal share, rounded down"
	)
	check(describe(screen.carriedStack) == "log 1", "spreadCarriedStackOverSlots: and what is left over stays carried")

	local exact = carrying("log 12", "-, -, -, -")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(exact, { at("pack", 4), at("pack", 1), at("pack", 2) }) == 12,
		"spreadCarriedStackOverSlots: a stack that divides exactly is all put down"
	)
	check(
		contents(exact.pack) == "log 4, log 4, -, log 4" and exact.carriedStack == nil,
		"spreadCarriedStackOverSlots: into the slots named and no others, and nothing is carried"
	)

	local topping = carrying("log 12", "log 14, -, log 3")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(topping, { at("pack", 1), at("pack", 2), at("pack", 3) }) == 10,
		"spreadCarriedStackOverSlots: a slot takes only as much as it has room for"
	)
	check(
		contents(topping.pack) == "log 16, log 4, log 7" and describe(topping.carriedStack) == "log 2",
		"spreadCarriedStackOverSlots: stacks of the carried item are topped up, and what found no room stays carried"
	)

	local mixed = carrying("log 8", "stone 5, -, -")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(mixed, { at("pack", 1), at("pack", 2), at("pack", 3) }) == 8,
		"spreadCarriedStackOverSlots: a slot holding a different item is passed over"
	)
	check(
		contents(mixed.pack) == "stone 5, log 4, log 4" and mixed.carriedStack == nil,
		"spreadCarriedStackOverSlots: and the share is worked out without it"
	)

	local full = carrying("log 9", "log 16, -, -")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(full, { at("pack", 1), at("pack", 2), at("pack", 3) }) == 6,
		"spreadCarriedStackOverSlots: a full stack of the carried item takes part, and gets nothing"
	)
	check(
		contents(full.pack) == "log 16, log 3, log 3" and describe(full.carriedStack) == "log 3",
		"spreadCarriedStackOverSlots: so its share stays carried"
	)

	local twice = carrying("log 8", "-, -")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(
			twice,
			{ at("pack", 1), at("pack", 1), at("pack", 2), at("pack", 1) }
		) == 8,
		"spreadCarriedStackOverSlots: a slot named twice counts once"
	)
	check(contents(twice.pack) == "log 4, log 4", "spreadCarriedStackOverSlots: so two slots get half each")

	local few = carrying("log 2", "-, -, -, -")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(few, { at("pack", 3), at("pack", 1), at("pack", 2), at("pack", 4) })
			== 2,
		"spreadCarriedStackOverSlots: no more slots take part than there are items carried"
	)
	check(
		contents(few.pack) == "log 1, -, log 1, -",
		"spreadCarriedStackOverSlots: the first ones named do, and get one each"
	)
	check(few.carriedStack == nil, "spreadCarriedStackOverSlots: and nothing is left carried")

	local passedOver = carrying("log 2", "stone 1, -, -, -")
	InventoryScreen.spreadCarriedStackOverSlots(
		passedOver,
		{ at("pack", 1), at("pack", 2), at("pack", 3), at("pack", 4) }
	)
	check(
		contents(passedOver.pack) == "stone 1, log 1, log 1, -",
		"spreadCarriedStackOverSlots: a slot that is passed over does not count towards that number"
	)

	local ones = carrying("log 5", "-, -, -")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(ones, { at("pack", 1), at("pack", 2), at("pack", 3) }, 1) == 3,
		"spreadCarriedStackOverSlots: with a count, each slot gets that many"
	)
	check(
		contents(ones.pack) == "log 1, log 1, log 1" and describe(ones.carriedStack) == "log 2",
		"spreadCarriedStackOverSlots: and the rest stays carried"
	)
	local twos = carrying("log 5", "-, -, -")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(twos, { at("pack", 1), at("pack", 2), at("pack", 3) }, 2) == 5,
		"spreadCarriedStackOverSlots: a count is given out for as long as the carried stack lasts"
	)
	check(
		contents(twos.pack) == "log 2, log 2, log 1" and twos.carriedStack == nil,
		"spreadCarriedStackOverSlots: so the last slot may get less"
	)
	local zero = carrying("log 5", "-, -")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(zero, { at("pack", 1), at("pack", 2) }, 0) == 0,
		"spreadCarriedStackOverSlots: a count of 0 puts nothing down"
	)
	check(
		contents(zero.pack) == "-, -" and describe(zero.carriedStack) == "log 5",
		"spreadCarriedStackOverSlots: and changes nothing"
	)

	local both = InventoryScreen.new(inventoryOf("log 6, -"), inventoryOf("-, -"))
	InventoryScreen.pickUpFromSlot(both, "pack", 1)
	check(
		InventoryScreen.spreadCarriedStackOverSlots(both, { at("other", 2), at("pack", 2), at("other", 1) }) == 6,
		"spreadCarriedStackOverSlots: the slots may be in both inventories"
	)
	check(
		contents(both.pack) == "-, log 2" and otherContents(both) == "log 2, log 2",
		"spreadCarriedStackOverSlots: each gets its share"
	)

	local stove = stoveScreen("log 6, -", "-, -, -")
	InventoryScreen.pickUpFromSlot(stove, "pack", 1)
	check(
		InventoryScreen.spreadCarriedStackOverSlots(
			stove,
			{ at("other", 1), at("other", 2), at("other", 3), at("pack", 2) }
		) == 6,
		"spreadCarriedStackOverSlots: a slot that does not accept the carried item is passed over"
	)
	check(
		otherContents(stove) == "-, log 3, -" and contents(stove.pack) == "-, log 3",
		"spreadCarriedStackOverSlots: so the logs go to the slot meant for them and to the pack"
	)

	local single = carrying("log 6", "log 12, -")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(single, { at("pack", 1) }) == 4,
		"spreadCarriedStackOverSlots: over one slot, it is a putting down"
	)
	check(
		contents(single.pack) == "log 16, -" and describe(single.carriedStack) == "log 2",
		"spreadCarriedStackOverSlots: as far as there is room"
	)

	local ones2 = carrying("log 6", "-")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(ones2, { at("pack", 1) }, 1) == 1,
		"spreadCarriedStackOverSlots: over one slot with a count of 1, puts one down"
	)
	check(
		contents(ones2.pack) == "log 1" and describe(ones2.carriedStack) == "log 5",
		"spreadCarriedStackOverSlots: and the rest stays carried"
	)

	local nothing = InventoryScreen.new(inventoryOf("log 6, -"))
	check(
		InventoryScreen.spreadCarriedStackOverSlots(nothing, { at("pack", 2) }) == 0,
		"spreadCarriedStackOverSlots: 0 with nothing carried"
	)
	check(contents(nothing.pack) == "log 6, -", "spreadCarriedStackOverSlots: and nothing changes")
	local blocked = carrying("log 6", "stone 1, stone 2")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(blocked, { at("pack", 1), at("pack", 2) }) == 0,
		"spreadCarriedStackOverSlots: 0 when no slot named takes part"
	)
	check(
		InventoryScreen.spreadCarriedStackOverSlots(blocked, {}) == 0,
		"spreadCarriedStackOverSlots: 0 over no slots at all"
	)
	check(
		contents(blocked.pack) == "stone 1, stone 2" and describe(blocked.carriedStack) == "log 6",
		"spreadCarriedStackOverSlots: and the stack is still carried"
	)

	local three = carrying("log 7", "-, log 16, -")
	check(
		InventoryScreen.spreadCarriedStackOverSlots(three, { at("pack", 1), at("pack", 2), at("pack", 3) }, 1) == 2,
		"spreadCarriedStackOverSlots: one in each slot that has room, with a full stack getting nothing"
	)
	check(
		contents(three.pack) == "log 1, log 16, log 1" and describe(three.carriedStack) == "log 5",
		"spreadCarriedStackOverSlots: and the rest stays carried"
	)
end

do -- takeCarriedStack
	local screen = InventoryScreen.new(inventoryOf("log 10"))
	check(InventoryScreen.takeCarriedStack(screen) == nil, "takeCarriedStack: nothing when nothing is carried")
	check(
		InventoryScreen.takeCarriedStack(screen, 2) == nil,
		"takeCarriedStack: nothing when nothing is carried, whatever count is asked for"
	)
	InventoryScreen.pickUpFromSlot(screen, "pack", 1)
	check(
		describe(InventoryScreen.takeCarriedStack(screen, 1)) == "log 1",
		"takeCarriedStack: returns that many as a stack"
	)
	check(describe(screen.carriedStack) == "log 9", "takeCarriedStack: the rest stays carried")
	check(
		InventoryScreen.takeCarriedStack(screen, 0) == nil and describe(screen.carriedStack) == "log 9",
		"takeCarriedStack: a count of 0 takes nothing and changes nothing"
	)
	check(
		describe(InventoryScreen.takeCarriedStack(screen, 9)) == "log 9" and screen.carriedStack == nil,
		"takeCarriedStack: a count of exactly what is carried takes it all"
	)
	Inventory.addItems(screen.pack, "log", 6)
	InventoryScreen.pickUpFromSlot(screen, "pack", 1)
	check(
		describe(InventoryScreen.takeCarriedStack(screen, 50)) == "log 6",
		"takeCarriedStack: asked for more than is carried, returns what is carried"
	)
	check(screen.carriedStack == nil, "takeCarriedStack: nothing is carried afterwards")
	Inventory.addItems(screen.pack, "log", 4)
	InventoryScreen.pickUpFromSlot(screen, "pack", 1)
	check(
		describe(InventoryScreen.takeCarriedStack(screen)) == "log 4" and screen.carriedStack == nil,
		"takeCarriedStack: with no count, the whole carried stack"
	)
	check(contents(screen.pack) == "-", "takeCarriedStack: what it returns is no longer in any slot")
end

do -- what the mouse's clicks come to: a left click, carrying nothing
	local pickedUp = carrying("-", "log 12")
	check(
		InventoryScreen.pickUpFromSlot(pickedUp, "pack", 1) == 12 and describe(pickedUp.carriedStack) == "log 12",
		"pickUpFromSlot: picks up the whole stack"
	)
	local stove = carrying("-", "stove 1")
	InventoryScreen.pickUpFromSlot(stove, "pack", 1)
	check(
		describe(stove.carriedStack) == "stove 1" and contents(stove.pack) == "-",
		"pickUpFromSlot: an item that does not stack"
	)
end

do -- pickUpFromSlot, putDownInSlot and swapCarriedStackWithSlot together do what clicks on a slot need
	-- A left click carrying a stack: putDownInSlot, then swapCarriedStackWithSlot if the slot holds a different item.
	local onNothing = carrying("log 10", "-")
	InventoryScreen.putDownInSlot(onNothing, "pack", 1)
	check(
		onNothing.carriedStack == nil and contents(onNothing.pack) == "log 10",
		"putDownInSlot: the whole stack onto nothing"
	)

	local onSame = carrying("log 10", "log 12")
	InventoryScreen.putDownInSlot(onSame, "pack", 1)
	check(
		describe(onSame.carriedStack) == "log 6" and contents(onSame.pack) == "log 16",
		"putDownInSlot: what does not fit stays carried"
	)

	local onFull = carrying("log 10", "log 16")
	check(
		InventoryScreen.putDownInSlot(onFull, "pack", 1) == 0,
		"putDownInSlot: nothing onto a full stack of the same item"
	)
	check(
		describe(onFull.carriedStack) == "log 10" and contents(onFull.pack) == "log 16",
		"putDownInSlot: so nothing moves"
	)

	local filling = carrying("log 16", "log 1")
	InventoryScreen.putDownInSlot(filling, "pack", 1)
	check(
		describe(filling.carriedStack) == "log 1" and contents(filling.pack) == "log 16",
		"putDownInSlot: a full stack onto a smaller one fills the slot and the rest stays carried"
	)

	-- A right click carrying nothing: pickUpFromSlot of the larger half.
	for _, case in { { "log 12", 6 }, { "log 5", 3 }, { "log 1", 1 }, { "log 16", 8 } } :: { { any } } do
		local count = tonumber(string.match(case[1], "%d+")) :: number
		local halved = carrying("-", case[1])
		InventoryScreen.pickUpFromSlot(halved, "pack", 1, math.ceil(count / 2))
		check(
			halved.carriedStack ~= nil and halved.carriedStack.count == case[2],
			"pickUpFromSlot: half of " .. case[1] .. " is " .. tostring(case[2])
		)
		check(
			(Inventory.getStack(halved.pack, 1) :: ItemStack.ItemStack?) == nil
				or (Inventory.getStack(halved.pack, 1) :: ItemStack.ItemStack).count == count - case[2],
			"pickUpFromSlot: the other half of " .. case[1] .. " stays"
		)
	end

	-- A right click carrying a stack: one is put down.
	local oneDown = carrying("log 10", "log 3")
	InventoryScreen.putDownInSlot(oneDown, "pack", 1, 1)
	check(
		describe(oneDown.carriedStack) == "log 9" and contents(oneDown.pack) == "log 4",
		"putDownInSlot: one item onto the same item"
	)
	local last = carrying("log 1", "log 3")
	InventoryScreen.putDownInSlot(last, "pack", 1, 1)
	check(
		last.carriedStack == nil and contents(last.pack) == "log 4",
		"putDownInSlot: the last item leaves nothing carried"
	)
	local fullOne = carrying("log 10", "log 16")
	check(
		InventoryScreen.putDownInSlot(fullOne, "pack", 1, 1) == 0 and describe(fullOne.carriedStack) == "log 10",
		"putDownInSlot: one item onto a full stack does not move"
	)
end

do -- no action ever makes or loses an item
	local seed = 20261119
	local function random(limit: number): number
		seed = (seed * 16807) % 2147483647
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
	local function crateAccepts(slot: number, itemId: string): boolean
		return slot ~= 3 and (slot ~= 1 or itemId ~= "log")
	end
	local screen = InventoryScreen.new(pack, crate, crateAccepts)
	local sides: { InventoryScreen.Side } = { "pack", "other" }
	local broken: string? = nil
	for step = 1, 30000 do
		local side = sides[random(2)]
		local slot = random(4)
		local action = random(10)
		if action == 1 then
			InventoryScreen.pickUpFromSlot(screen, side, slot, if random(2) == 1 then nil else random(21) - 1)
		elseif action == 2 then
			InventoryScreen.putDownInSlot(screen, side, slot, if random(2) == 1 then nil else random(21) - 1)
		elseif action == 3 then
			if InventoryScreen.canSwapCarriedStackWithSlot(screen, side, slot) then
				InventoryScreen.swapCarriedStackWithSlot(screen, side, slot)
			end
		elseif action == 4 then
			local withSide, withSlot = sides[random(2)], random(4)
			if InventoryScreen.canSwapSlots(screen, side, slot, withSide, withSlot) then
				InventoryScreen.swapSlots(screen, side, slot, withSide, withSlot)
			end
		elseif action == 5 or action == 6 then
			InventoryScreen.fillCarriedStackFromAllSlots(screen)
		elseif action == 7 or action == 8 then
			local screenSlots: { InventoryScreen.ScreenSlot } = {}
			for _ = 1, random(5) do
				table.insert(screenSlots, { side = sides[random(2)], slot = random(4) })
			end
			InventoryScreen.spreadCarriedStackOverSlots(
				screen,
				screenSlots,
				if random(2) == 1 then nil else random(4) - 1
			)
		else
			local taken = InventoryScreen.takeCarriedStack(screen, if random(2) == 1 then nil else random(4) - 1)
			if taken then
				totals[taken.itemId] -= taken.count
				if random(2) == 1 then
					-- Hand the items back, as a player picking them up from the ground would.
					totals[taken.itemId] += Inventory.addItems(pack, taken.itemId, taken.count)
				end
			end
		end
		local carried = screen.carriedStack
		for _, itemId in itemIds do
			local inHand = if carried and carried.itemId == itemId then carried.count else 0
			if Inventory.countItems(pack, itemId) + Inventory.countItems(crate, itemId) + inHand ~= totals[itemId] then
				broken = broken or string.format("step %d: the number of %s is wrong", step, itemId)
			end
		end
		if carried and (carried.count < 1 or ItemStack.getSpaceLeft(carried) < 0) then
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

Check.finish("InventoryScreen")
