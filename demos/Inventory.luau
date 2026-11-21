--!strict
-- A short session with the inventory pieces, printed as text.
-- Run from the repository root: lune run demos/inventory

local Hotbar = require("../src/shared/inventory/Hotbar")
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

local function say(what: string, result: string)
	print(string.format("%-46s %s", what, result))
end

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "stove", stackSize = 1 })

local pack = Inventory.new(4)
local crate = Inventory.new(3)
local hotbar = Hotbar.new(pack, 2)

print("The player's pack has 4 slots, and the first 2 are the hotbar. A crate has 3 slots.\n")

local leftOnGround = 40 - Inventory.addItems(pack, "log", 40)
say("Walk over 40 logs:", contents(pack))
say("", leftOnGround .. " left on the ground")

leftOnGround = 3 - Inventory.addItems(pack, "stove", 3)
say("Walk over 3 stoves:", contents(pack))
say("", leftOnGround .. " left on the ground, because a stove does not stack")

say("In hand (hotbar slot " .. hotbar.selectedSlot .. "):", describe(Hotbar.getSelectedStack(hotbar)))
Hotbar.selectSlot(hotbar, 2)
say("Select hotbar slot " .. hotbar.selectedSlot .. ":", describe(Hotbar.getSelectedStack(hotbar)))

print("\nThe player opens the crate.\n")
local screen = InventoryScreen.new(pack, crate)

InventoryScreen.pickUpFromSlot(screen, "pack", 3)
say("Pick up the 8 logs in the pack:", "carrying " .. describe(screen.carriedStack))
InventoryScreen.putDownInSlot(screen, "other", 1)
say("Put them down in the crate's first slot:", "carrying " .. describe(screen.carriedStack))
say("", "crate  " .. contents(crate))

InventoryScreen.pickUpFromSlot(screen, "pack", 1, 8)
say("Pick up 8 of the 16 logs in the pack:", "carrying " .. describe(screen.carriedStack))
InventoryScreen.putDownInSlot(screen, "other", 2, 1)
InventoryScreen.putDownInSlot(screen, "other", 2, 1)
say("Put one down in the crate's second slot, twice:", "carrying " .. describe(screen.carriedStack))
say("", "crate  " .. contents(crate))

InventoryScreen.swapCarriedStackWithSlot(screen, "pack", 4)
say("Swap with the stove in the pack:", "carrying " .. describe(screen.carriedStack))
say("", "pack   " .. contents(pack))

local moved = InventoryScreen.moveFromSlotToInventory(screen, "pack", 2, "other")
say("Move 16 logs from the pack to the crate:", moved .. " moved")
say("", "crate  " .. contents(crate))

local carried = InventoryScreen.takeCarriedStack(screen)
local toDrop = if carried then Inventory.addStack(pack, carried) else nil
say("Close the screen while carrying the stove:", "to drop on the ground: " .. describe(toDrop))
say("", "pack   " .. contents(pack))
say("", "crate  " .. contents(crate))

local total = Inventory.countItems(pack, "log") + Inventory.countItems(crate, "log")
print(string.format("\nLogs picked up: 40. Logs in the pack and the crate now: %d.", total))
