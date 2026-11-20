--!strict
--- The first slots of a player's pack, and which of them is selected.
---
--- A hotbar holds no items of its own: an item on the hotbar is in the pack. The stack in the
--- selected slot is what the player has in their hand.
local Inventory = require("./Inventory")
local ItemStack = require("../items/ItemStack")

local Hotbar = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory

export type Hotbar = {
	--- The inventory whose first slots these are.
	read inventory: Inventory,
	--- How many of the inventory's slots the hotbar covers, counting from slot 1.
	read slotCount: number,
	--- The number of the selected slot.
	selectedSlot: number,
}

--- Returns a hotbar over the first `slotCount` slots of `inventory`, with slot 1 selected.
function Hotbar.new(inventory: Inventory, slotCount: number): Hotbar
	return { inventory = inventory, slotCount = slotCount, selectedSlot = 1 }
end

--- Returns `true` if `slot` is the number of one of the hotbar's slots. `slot` may be any value
--- at all, so this is the check for a slot number that arrives from outside the game.
function Hotbar.hasSlot(hotbar: Hotbar, slot: unknown): boolean
	return Inventory.hasSlot(hotbar.inventory, slot) and (slot :: number) <= hotbar.slotCount
end

--- Selects a slot. Fails if the hotbar has no such slot.
function Hotbar.select(hotbar: Hotbar, slot: number)
	assert(Hotbar.hasSlot(hotbar, slot), `the hotbar has no slot {slot}`)
	hotbar.selectedSlot = slot
end

--- Returns the stack in the selected slot, or `nil` if that slot holds nothing.
function Hotbar.getSelectedStack(hotbar: Hotbar): ItemStack?
	return Inventory.getStack(hotbar.inventory, hotbar.selectedSlot)
end

--- Takes up to `count` items out of the selected slot and returns them as a stack. Takes
--- everything in the slot if `count` is left out. Returns `nil` if nothing was taken.
function Hotbar.takeSelected(hotbar: Hotbar, count: number?): ItemStack?
	return Inventory.takeFromSlot(hotbar.inventory, hotbar.selectedSlot, count)
end

return Hotbar
