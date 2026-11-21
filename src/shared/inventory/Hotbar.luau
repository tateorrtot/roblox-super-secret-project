--!strict
--- The first slots of a player's pack, and which one is selected.
---
--- A hotbar holds no items: its slots are the first `slotCount` slots of `inventory`.
--- `selectSlot` selects a slot. `getSelectedStack` and `takeFromSelectedSlot` act on the selected
--- slot, and the stack in it is in the player's hand.
local Inventory = require("./Inventory")
local ItemStack = require("../items/ItemStack")

local Hotbar = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory

--- The first slots of an inventory, and which one is selected.
export type Hotbar = {
	--- The inventory whose first slots the hotbar covers.
	read inventory: Inventory,
	--- How many slots the hotbar covers, counting from slot `1`.
	read slotCount: number,
	--- The number of the selected slot. `selectSlot` assigns it.
	selectedSlot: number,
}

--- Returns a new hotbar over the first `slotCount` slots of `inventory`, with slot `1` selected.
--- Note: `new` does not check that `inventory` has `slotCount` slots.
function Hotbar.new(inventory: Inventory, slotCount: number): Hotbar
	return { inventory = inventory, slotCount = slotCount, selectedSlot = 1 }
end

--- Returns `true` if `slot` is a whole number from `1` to the hotbar's `slotCount`, and the
--- hotbar's inventory has that slot. Accepts a value of any type, and never raises an error.
function Hotbar.hasSlot(hotbar: Hotbar, slot: unknown): boolean
	return Inventory.hasSlot(hotbar.inventory, slot) and (slot :: number) <= hotbar.slotCount
end

--- Makes `slot` the selected slot. Raises an error, and changes nothing, if `hasSlot` returns
--- `false` for `slot`.
function Hotbar.selectSlot(hotbar: Hotbar, slot: number)
	assert(Hotbar.hasSlot(hotbar, slot), `the hotbar has no slot {slot}`)
	hotbar.selectedSlot = slot
end

--- Returns the stack in the selected slot, or `nil` if the slot holds nothing.
function Hotbar.getSelectedStack(hotbar: Hotbar): ItemStack?
	return Inventory.getStack(hotbar.inventory, hotbar.selectedSlot)
end

--- Takes up to `count` items out of the selected slot and returns them as a stack. Takes everything
--- in the slot if `count` is `nil` or at least what the slot holds. Returns `nil` if the slot holds
--- nothing or `count` is `0`.
--- Note: `takeFromSelectedSlot` does not check that `count` is a whole number of `0` or more.
function Hotbar.takeFromSelectedSlot(hotbar: Hotbar, count: number?): ItemStack?
	return Inventory.takeFromSlot(hotbar.inventory, hotbar.selectedSlot, count)
end

return Hotbar
