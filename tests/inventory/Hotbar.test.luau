--!strict
-- Tests for Hotbar. Run from the repository root: lune run tests/inventory/Hotbar.test.luau

local Check = require("../Check")
local Hotbar = require("../../src/shared/inventory/Hotbar")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")

local check = Check.that
local errorFrom = Check.errorFrom

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "stone", stackSize = 16 })

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

do -- a new hotbar
	local pack = Inventory.new(27)
	local hotbar = Hotbar.new(pack, 9)
	check(hotbar.inventory == pack, "new: it is over the inventory it was given")
	check(hotbar.slotCount == 9, "new: covers the number of slots asked for")
	check(hotbar.selectedSlot == 1, "new: slot 1 is selected")
	check(Hotbar.getSelectedStack(hotbar) == nil, "getSelectedStack: nil when the selected slot holds nothing")
	check(Hotbar.new(pack, 27).slotCount == 27, "new: may cover the whole inventory")
	check(Hotbar.new(pack, 1).slotCount == 1, "new: may be a single slot")
end

do -- which slots the hotbar has
	local hotbar = Hotbar.new(Inventory.new(27), 9)
	check(Hotbar.hasSlot(hotbar, 1), "hasSlot: slot 1 is on the hotbar")
	check(Hotbar.hasSlot(hotbar, 9), "hasSlot: the last hotbar slot is on the hotbar")
	check(not Hotbar.hasSlot(hotbar, 10), "hasSlot: a pack slot after the hotbar is not on it")
	check(not Hotbar.hasSlot(hotbar, 27), "hasSlot: the last pack slot is not on the hotbar")
	check(not Hotbar.hasSlot(hotbar, 28), "hasSlot: a slot past the inventory is not on the hotbar")
	for _, bad in { 0, -1, 1.5, 0 / 0, math.huge, -math.huge } do
		check(not Hotbar.hasSlot(hotbar, bad), "hasSlot: " .. tostring(bad) .. " is not a hotbar slot")
	end
	for _, bad in { "1", true, false, {}, print } :: { unknown } do
		check(not Hotbar.hasSlot(hotbar, bad), "hasSlot: a " .. type(bad) .. " is not a hotbar slot")
	end
	check(not Hotbar.hasSlot(hotbar, nil), "hasSlot: nil is not a hotbar slot")
	check(
		Hotbar.hasSlot(Hotbar.new(Inventory.new(5), 5), 5),
		"hasSlot: a hotbar over the whole inventory has all its slots"
	)
end

do -- it is the inventory's own slots, not a copy
	local pack = Inventory.new(27)
	local hotbar = Hotbar.new(pack, 9)
	Inventory.setStack(pack, 1, ItemStack.new("log", 5))
	Inventory.setStack(pack, 3, ItemStack.new("stone", 2))
	check(
		is(Hotbar.getSelectedStack(hotbar), "log", 5),
		"getSelectedStack: what the inventory holds in the selected slot"
	)
	Hotbar.select(hotbar, 3)
	check(
		hotbar.selectedSlot == 3 and is(Hotbar.getSelectedStack(hotbar), "stone", 2),
		"select: changes which slot is in hand"
	)
	Inventory.takeFromSlot(pack, 3)
	check(Hotbar.getSelectedStack(hotbar) == nil, "getSelectedStack: follows the inventory when the slot is emptied")
	Inventory.addItems(pack, "log", 40)
	check(
		is(Hotbar.getSelectedStack(hotbar), "log", 13),
		"getSelectedStack: follows the inventory when the slot is filled"
	)
	check(
		pack.slotCount == 27 and Inventory.countItems(pack, "log") == 45,
		"the hotbar changes nothing in the inventory"
	)
	Hotbar.getSelectedStack(hotbar)
	check(Inventory.countItems(pack, "log") == 45, "getSelectedStack: takes nothing out")
end

do -- taking from the selected slot
	local pack = Inventory.new(27)
	local hotbar = Hotbar.new(pack, 9)
	check(Hotbar.takeSelected(hotbar) == nil, "takeSelected: nil when the selected slot holds nothing")
	check(Hotbar.takeSelected(hotbar, 3) == nil, "takeSelected: nil when asked for some and the slot holds nothing")

	Inventory.setStack(pack, 1, ItemStack.new("log", 10))
	Inventory.setStack(pack, 2, ItemStack.new("stone", 4))
	check(is(Hotbar.takeSelected(hotbar, 3), "log", 3), "takeSelected: returns the count asked for")
	check(is(Inventory.getStack(pack, 1), "log", 7), "takeSelected: the rest stays in the slot")
	check(Hotbar.takeSelected(hotbar, 0) == nil, "takeSelected: 0 takes nothing")
	check(is(Inventory.getStack(pack, 1), "log", 7), "takeSelected: 0 leaves the slot as it was")
	check(is(Hotbar.takeSelected(hotbar, 50), "log", 7), "takeSelected: asked for more than there is, takes all of it")
	check(Inventory.getStack(pack, 1) == nil, "takeSelected: the slot then holds nothing")

	Inventory.setStack(pack, 1, ItemStack.new("log", 6))
	check(is(Hotbar.takeSelected(hotbar), "log", 6), "takeSelected: with no count takes everything in the slot")
	check(Inventory.getStack(pack, 1) == nil, "takeSelected: with no count empties the slot")

	Hotbar.select(hotbar, 2)
	check(is(Hotbar.takeSelected(hotbar, 1), "stone", 1), "takeSelected: takes from the selected slot")
	check(is(Inventory.getStack(pack, 2), "stone", 3), "takeSelected: and from no other")
	check(
		Inventory.countItems(pack, "log") == 0 and Inventory.countItems(pack, "stone") == 3,
		"takeSelected: loses no items"
	)
end

do -- selecting
	local pack = Inventory.new(5)
	local hotbar = Hotbar.new(pack, 3)
	Hotbar.select(hotbar, 3)
	check(hotbar.selectedSlot == 3, "select: the last hotbar slot can be selected")
	Hotbar.select(hotbar, 1)
	check(hotbar.selectedSlot == 1, "select: slot 1 can be selected again")
	Hotbar.select(hotbar, 2)
	for _, badSlot in { 0, 4, 5, 6, -1, 1.5, 0 / 0, math.huge } do
		local message = errorFrom(function()
			Hotbar.select(hotbar, badSlot)
		end)
		check(
			message ~= nil and string.find(message, "the hotbar has no slot " .. tostring(badSlot), 1, true) ~= nil,
			"select: refuses slot " .. tostring(badSlot) .. " and says the hotbar has no such slot"
		)
	end
	check(hotbar.selectedSlot == 2, "select: a refused slot leaves the selection as it was")
end

Check.finish("Hotbar")
