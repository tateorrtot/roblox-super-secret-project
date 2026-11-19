--!strict
-- Tests for Hotbar. Run from the repository root: lune run tests/inventory/Hotbar.test.luau

local Check = require("../Check")
local Hotbar = require("../../src/shared/inventory/Hotbar")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")

local check = Check.that
local raises = Check.raises

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
	check(Hotbar.selectedStack(hotbar) == nil, "selectedStack: nil when the selected slot holds nothing")
	check(Hotbar.new(pack, 27).slotCount == 27, "new: may cover the whole inventory")
	check(Hotbar.new(pack, 1).slotCount == 1, "new: may be a single slot")
end

do -- it is the inventory's own slots, not a copy
	local pack = Inventory.new(27)
	local hotbar = Hotbar.new(pack, 9)
	Inventory.setStack(pack, 1, ItemStack.new("log", 5))
	Inventory.setStack(pack, 3, ItemStack.new("stone", 2))
	check(is(Hotbar.selectedStack(hotbar), "log", 5), "selectedStack: what the inventory holds in the selected slot")
	Hotbar.select(hotbar, 3)
	check(
		hotbar.selectedSlot == 3 and is(Hotbar.selectedStack(hotbar), "stone", 2),
		"select: changes which slot is in hand"
	)
	Inventory.takeFromSlot(pack, 3)
	check(Hotbar.selectedStack(hotbar) == nil, "selectedStack: follows the inventory when the slot is emptied")
	Inventory.addItems(pack, "log", 40)
	check(is(Hotbar.selectedStack(hotbar), "log", 13), "selectedStack: follows the inventory when the slot is filled")
	check(
		pack.slotCount == 27 and Inventory.countItems(pack, "log") == 45,
		"the hotbar changes nothing in the inventory"
	)
end

do -- selectNext and selectPrevious go round
	local hotbar = Hotbar.new(Inventory.new(5), 3)
	Hotbar.selectNext(hotbar)
	check(hotbar.selectedSlot == 2, "selectNext: from 1 to 2")
	Hotbar.selectNext(hotbar)
	Hotbar.selectNext(hotbar)
	check(hotbar.selectedSlot == 1, "selectNext: after the last slot comes slot 1")
	Hotbar.selectPrevious(hotbar)
	check(hotbar.selectedSlot == 3, "selectPrevious: before slot 1 comes the last slot")
	Hotbar.selectPrevious(hotbar)
	check(hotbar.selectedSlot == 2, "selectPrevious: from 3 to 2")

	local single = Hotbar.new(Inventory.new(5), 1)
	Hotbar.selectNext(single)
	Hotbar.selectPrevious(single)
	check(single.selectedSlot == 1, "a hotbar of one slot always has slot 1 selected")
end

do -- mistakes in the calling code
	local pack = Inventory.new(5)
	for _, badCount in { 0, 6, -1, 2.5, 0 / 0, math.huge } do
		check(
			raises("Hotbar.new: slotCount must be a whole number from 1 to 5", function()
				return Hotbar.new(pack, badCount)
			end),
			"new: refuses " .. tostring(badCount) .. " slots over an inventory of 5"
		)
	end
	local hotbar = Hotbar.new(pack, 3)
	Hotbar.select(hotbar, 2)
	for _, badSlot in { 0, 4, -1, 1.5, 0 / 0, math.huge } do
		check(
			raises("out of range; this hotbar has slots 1 to 3", function()
				Hotbar.select(hotbar, badSlot)
			end),
			"select: refuses slot " .. tostring(badSlot)
		)
	end
	check(hotbar.selectedSlot == 2, "select: a refused slot leaves the selection as it was")
end

Check.finish("Hotbar")
