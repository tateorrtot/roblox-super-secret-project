--!strict
-- A short session with the inventory pieces, printed as text.
-- Run from the repository root: lune run demos/inventory

local Hotbar = require("../src/shared/inventory/Hotbar")
local Inventory = require("../src/shared/inventory/Inventory")
local InventorySession = require("../src/shared/inventory/InventorySession")
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

say("In hand (hotbar slot " .. hotbar.selectedSlot .. "):", describe(Hotbar.selectedStack(hotbar)))
Hotbar.selectNext(hotbar)
Hotbar.selectNext(hotbar)
say("Scroll twice, back to slot " .. hotbar.selectedSlot .. ":", describe(Hotbar.selectedStack(hotbar)))

print("\nThe player opens the crate.\n")
local session = InventorySession.open(pack, crate)

InventorySession.click(session, "pack", 3, "left")
say("Left click the 8 logs in the pack:", "carrying " .. describe(session.carried))
InventorySession.click(session, "other", 1, "left")
say("Left click the crate's first slot:", "carrying " .. describe(session.carried))
say("", "crate  " .. contents(crate))

InventorySession.click(session, "pack", 1, "right")
say("Right click 16 logs in the pack:", "carrying " .. describe(session.carried) .. ", half of them")
InventorySession.click(session, "other", 2, "right")
InventorySession.click(session, "other", 2, "right")
say("Right click the crate's second slot twice:", "carrying " .. describe(session.carried))
say("", "crate  " .. contents(crate))

InventorySession.click(session, "pack", 4, "left")
say("Left click the stove in the pack:", "carrying " .. describe(session.carried) .. ", swapped for the logs")
say("", "pack   " .. contents(pack))

local moved = InventorySession.quickMove(session, "pack", 2)
say("Shift-click 16 logs in the pack:", moved .. " moved to the crate")
say("", "crate  " .. contents(crate))

local toDrop = InventorySession.close(session)
say("Close the screen while carrying the stove:", "to drop on the ground: " .. describe(toDrop))
say("", "pack   " .. contents(pack))
say("", "crate  " .. contents(crate))

local total = Inventory.countItems(pack, "log") + Inventory.countItems(crate, "log")
print(string.format("\nLogs picked up: 40. Logs in the pack and the crate now: %d.", total))
