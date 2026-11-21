--!strict
-- A player with a crate open, moving stacks between their pack and the crate, printed as text.
-- Run from the repository root: lune run demos/InventoryScreen

local Inventory = require("../src/shared/inventory/Inventory")
local InventoryScreen = require("../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../src/shared/items/ItemRegistry")
local ItemStack = require("../src/shared/items/ItemStack")

local function describe(stack: ItemStack.ItemStack?): string
	return if stack then stack.count .. " " .. stack.itemId else "nothing"
end

local function contents(inventory: Inventory.Inventory): string
	local parts = {}
	for slot = 1, inventory.slotCount do
		table.insert(parts, describe(Inventory.getStack(inventory, slot)))
	end
	return table.concat(parts, " | ")
end

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })

local pack = Inventory.new(4)
local crate = Inventory.new(3)
Inventory.addItems(pack, "log", 12)
Inventory.addItems(pack, "fish", 5)
Inventory.addItems(crate, "log", 10)

local screen = InventoryScreen.new(pack, crate)
print('The screen has two sides: "pack" is the player\'s pack, and "other" is the crate.\n')
print("pack     " .. contents(pack))
print("crate    " .. contents(crate))

print('\npickUpFromSlot(screen, "pack", 2): pick up the fish in slot 2 of the pack.')
InventoryScreen.pickUpFromSlot(screen, "pack", 2)
print("carried  " .. describe(screen.carriedStack))

print('\nputDownInSlot(screen, "other", 3, 2): put 2 of them down in slot 3 of the crate.')
InventoryScreen.putDownInSlot(screen, "other", 3, 2)
print("carried  " .. describe(screen.carriedStack))
print("crate    " .. contents(crate))

print('\nmoveFromSlotToInventory(screen, "pack", 1, "other"): move the 12 logs in slot 1 of the pack into the crate.')
local moved = InventoryScreen.moveFromSlotToInventory(screen, "pack", 1, "other")
print(
	`{moved} moved: 6 top up the crate's 10 logs to a full stack of 16, and 6 fill the first slot that holds nothing.`
)
print("pack     " .. contents(pack))
print("crate    " .. contents(crate))

print("\ntakeCarriedStack(screen): take the 3 fish that are still carried off the screen.")
local carried = InventoryScreen.takeCarriedStack(screen)
print("taken    " .. describe(carried))
