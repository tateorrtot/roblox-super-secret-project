--!strict
--- The mouse and keyboard controls of the inventory screen: which request each gesture or key
--- press asks the server for.
---
--- Each function returns a request, which is the name of one of the server's requests and what to
--- send with it, or `nil` if the input asks for nothing.
local SlotGestures = require("./SlotGestures")

local InventoryControls = {}

type Slot = SlotGestures.Slot

--- A way in the world: numbers under `x`, `y` and `z` that together have a length of 1. `y` is
--- upwards.
export type Direction = { read x: number, read y: number, read z: number }

--- A stack as the controls see it.
export type Stack = { read itemId: string, read count: number }

export type Request = {
	--- The name of the request, as in `Requests.NAMES`.
	name: string,
	--- What is sent with it, in order.
	arguments: { any },
}

--- What the controls need to know of the open screen.
export type Screen = {
	--- How many slots the pack has.
	read packSlotCount: number,
	--- How many of the pack's first slots are the hotbar.
	read hotbarSlotCount: number,
	--- How many slots the other inventory has. `nil` when the pack is open alone.
	read otherSlotCount: number?,
	--- The stack being carried. `nil` when nothing is carried.
	read carriedStack: Stack?,
	--- Returns the stack in a slot, or `nil` if it holds nothing.
	read getStack: (slot: Slot) -> Stack?,
}

local function request(name: string, ...: any): Request
	return { name = name, arguments = { ... } }
end

local function forShiftClick(screen: Screen, slot: Slot): Request?
	local otherSlotCount = screen.otherSlotCount
	if otherSlotCount ~= nil and slot.side == "pack" then
		return request("moveFromSlotToInventory", "pack", slot.slot, "other", 1, otherSlotCount)
	elseif otherSlotCount ~= nil then
		return request("moveFromSlotToInventory", "other", slot.slot, "pack", 1, screen.packSlotCount)
	elseif screen.hotbarSlotCount >= screen.packSlotCount then
		return nil
	elseif slot.slot <= screen.hotbarSlotCount then
		return request(
			"moveFromSlotToInventory",
			"pack",
			slot.slot,
			"pack",
			screen.hotbarSlotCount + 1,
			screen.packSlotCount
		)
	end
	return request("moveFromSlotToInventory", "pack", slot.slot, "pack", 1, screen.hotbarSlotCount)
end

local function forClick(screen: Screen, slot: Slot, button: SlotGestures.Button): Request?
	local carried, there = screen.carriedStack, screen.getStack(slot)
	if carried == nil and there == nil then
		return nil
	elseif carried == nil and there ~= nil then
		return request(
			"pickUpFromSlot",
			slot.side,
			slot.slot,
			if button == "left" then nil else math.ceil(there.count / 2)
		)
	elseif carried ~= nil and there ~= nil and there.itemId ~= carried.itemId then
		return request("swapCarriedStackWithSlot", slot.side, slot.slot)
	end
	return request("putDownInSlot", slot.side, slot.slot, if button == "left" then nil else 1)
end

--- Returns the request that a gesture on the slots asks for.
--- - A left click picks up the whole stack in the slot, and a right click picks up half of it,
---   the larger half of an odd count. With a stack carried, a left click puts all of it down, a
---   right click puts one item down, and either click on a slot holding a different item
---   exchanges the two stacks.
--- - A left click with Shift held moves the slot's stack to the other inventory. With the pack
---   open alone, it moves it between the hotbar and the rest of the pack.
--- - A double click with a stack carried, on a slot that holds nothing, fills the carried stack
---   from every slot that holds its kind. Any other double click is a left click.
--- - A drag with a stack carried puts it down across the slots it crossed: in equal shares with
---   the left button, and one item in each with the right. With nothing carried, a drag that ends
---   on the slot it began on is a click, and any other drag asks for nothing.
function InventoryControls.getRequestForGesture(screen: Screen, gesture: SlotGestures.Gesture): Request?
	local first, releasedOn = gesture.slots[1], gesture.releasedOn
	if gesture.kind == "drag" and screen.carriedStack ~= nil then
		return request("spreadCarriedStackOverSlots", gesture.slots, if gesture.button == "left" then nil else 1)
	end
	local endedElsewhere = releasedOn == nil or releasedOn.side ~= first.side or releasedOn.slot ~= first.slot
	if gesture.kind == "drag" and endedElsewhere then
		return nil
	elseif gesture.button == "left" and gesture.shiftHeld then
		return forShiftClick(screen, first)
	elseif gesture.kind == "doubleClick" and screen.carriedStack ~= nil and screen.getStack(first) == nil then
		return request("fillCarriedStackFromAllSlots")
	end
	return forClick(screen, first, gesture.button)
end

--- Returns the request that a number key asks for while the pointer is over a slot: the slot's
--- stack and the stack in the hotbar slot of that number change places.
function InventoryControls.getRequestForDigitKeyOverSlot(over: Slot, digit: number): Request
	return request("swapSlots", over.side, over.slot, "pack", digit)
end

--- Returns the request that the drop key asks for while the pointer is over a slot: one item is
--- dropped from the slot, or the whole stack if `wholeStack` is `true`. `direction` is the way it
--- is thrown.
function InventoryControls.getRequestForDropKeyOverSlot(over: Slot, direction: Direction, wholeStack: boolean): Request
	return request("dropFromSlot", over.side, over.slot, direction, if wholeStack then nil else 1)
end

--- Returns the request that a click outside the screen asks for: the carried stack is dropped
--- with the left button, and one item of it with the right. `direction` is the way it is thrown.
function InventoryControls.getRequestForOutsideClick(button: SlotGestures.Button, direction: Direction): Request
	return request("dropCarriedStack", direction, if button == "left" then nil else 1)
end

return InventoryControls
