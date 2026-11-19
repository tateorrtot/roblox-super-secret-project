--!strict
--[=[
	The first few slots of a player's pack, and which one of them is selected.
	The stack in the selected slot is what the player has in their hands.

	A hotbar holds no items of its own. It is slots 1 to `slotCount` of an
	inventory, plus one number. An item "on the hotbar" is in that inventory,
	and moving a stack into inventory slot 3 puts it in hotbar slot 3.

	One slot is always selected. Empty hands means the selected slot holds
	nothing, so [method selectedStack] returns `nil`.

	```lua
	local pack = Inventory.new(27)
	local hotbar = Hotbar.new(pack, 9) -- slots 1 to 9 of the pack, with slot 1 selected
	Hotbar.select(hotbar, 3)
	Hotbar.selectedStack(hotbar) --> what slot 3 of the pack holds, or nil
	```
]=]
local Inventory = require("./Inventory")
local ItemStack = require("../items/ItemStack")

local Hotbar = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory

--- `read` means code outside this module cannot assign the field. Change the selection with the functions below.
export type Hotbar = {
	--- The inventory whose first slots this is.
	read inventory: Inventory,
	--- How many of that inventory's slots the hotbar covers, counting from slot 1.
	--- This is the hotbar's own number, and is usually smaller than `inventory.slotCount`.
	read slotCount: number,
	--- The number of the selected slot, from 1 to `slotCount`.
	read selectedSlot: number,
}

local function isWholeNumber(value: unknown): boolean
	return type(value) == "number" and value == math.floor(value) and value ~= math.huge and value ~= -math.huge
end

--[=[
	Returns a hotbar over slots 1 to `slotCount` of `inventory`, with slot 1 selected.

	Raises an error if `slotCount` is not a whole number from 1 up to the
	number of slots the inventory has.
]=]
function Hotbar.new(inventory: Inventory, slotCount: number): Hotbar
	if not isWholeNumber(slotCount) or slotCount < 1 or slotCount > inventory.slotCount then
		error(
			string.format(
				"Hotbar.new: slotCount must be a whole number from 1 to %d, the number of slots the inventory has; got %s",
				inventory.slotCount,
				tostring(slotCount)
			),
			2
		)
	end
	return { inventory = inventory, slotCount = slotCount, selectedSlot = 1 }
end

--[=[
	Selects the slot numbered `slot`.

	Raises an error if `slot` is not a whole number from 1 to the hotbar's `slotCount`.
]=]
function Hotbar.select(hotbar: Hotbar, slot: number)
	if not isWholeNumber(slot) or slot < 1 or slot > hotbar.slotCount then
		error(
			string.format(
				"Hotbar.select: slot %s is out of range; this hotbar has slots 1 to %d",
				tostring(slot),
				hotbar.slotCount
			),
			2
		)
	end
	(hotbar :: any).selectedSlot = slot
end

--[=[
	Selects the slot after the selected one. After the last slot comes slot 1.
]=]
function Hotbar.selectNext(hotbar: Hotbar)
	Hotbar.select(hotbar, hotbar.selectedSlot % hotbar.slotCount + 1)
end

--[=[
	Selects the slot before the selected one. Before slot 1 comes the last slot.
]=]
function Hotbar.selectPrevious(hotbar: Hotbar)
	Hotbar.select(hotbar, (hotbar.selectedSlot - 2) % hotbar.slotCount + 1)
end

--[=[
	Returns the stack in the selected slot, which is what the player has in
	their hands, or `nil` if that slot holds nothing.
]=]
function Hotbar.selectedStack(hotbar: Hotbar): ItemStack?
	return Inventory.getStack(hotbar.inventory, hotbar.selectedSlot)
end

return Hotbar
