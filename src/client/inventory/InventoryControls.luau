--!strict
--- The mouse and keyboard controls of the inventory screen: each function turns an input on the
--- screen into a `Request` that the client sends to the server.
---
--- Each function returns a `Request`, except that `getRequestForGesture` returns `nil` if the
--- gesture asks for nothing. No function changes anything.
local SlotGestures = require("./SlotGestures")

local InventoryControls = {}

type Slot = SlotGestures.Slot

--- A way in the world: numbers under `x`, `y` and `z` that together have a length of `1`. `y` is
--- upwards.
export type Direction = { read x: number, read y: number, read z: number }

--- The item and the count of a stack, which are all that the controls read of it.
export type Stack = { read itemId: string, read count: number }

--- A request for the server: its name, and the arguments to send with it.
export type Request = {
	--- The name of the request, one of `Requests.NAMES`.
	name: string,
	--- The arguments to send with the request, in order.
	arguments: { any },
}

--- What the controls read of the open inventory screen.
export type Screen = {
	--- The number of slots in the pack.
	read packSlotCount: number,
	--- The number of the pack's first slots that are the hotbar.
	read hotbarSlotCount: number,
	--- The number of slots in the other inventory. `nil` if the pack is open alone.
	read otherSlotCount: number?,
	--- The stack being carried. `nil` if nothing is carried.
	read carriedStack: Stack?,
	--- Returns the stack in `slot`, or `nil` if it holds nothing.
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

--- Returns the request that `gesture` asks for on the slots of `screen`, or `nil` if it asks for
--- nothing.
--- - A left click picks up the whole stack in the slot, and a right click picks up the larger half
---   of it. With a stack carried, a left click puts all of it down, a right click puts one item
---   down, and either click on a slot that holds a different item swaps the carried stack with
---   the slot's stack. A click on a slot that holds nothing, with nothing carried, asks for
---   nothing.
--- - A left click with Shift held, whether or not a stack is carried, takes the place of the left
---   click above: it moves the slot's stack to the other inventory, or from the other inventory to
---   the pack. With the pack open alone, it moves the stack between the hotbar and the rest of the
---   pack, and asks for nothing if the pack has no slots beyond the hotbar.
--- - A double click with a stack carried, on a slot that holds nothing, fills the carried stack
---   from every slot that holds its item. Any other double click is a left click.
--- - A drag with a stack carried spreads the stack over the slots the drag crossed: in equal
---   shares with the left button, and one item to each with the right. With nothing carried, a
---   drag that ends on the slot it began on is a click, and any other drag asks for nothing.
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

--- Returns the request that the number key `digit` asks for while the pointer is over the slot
--- `over`: the request swaps the stack in `over` with the stack in the pack's slot `digit`.
function InventoryControls.getRequestForDigitKeyOverSlot(over: Slot, digit: number): Request
	return request("swapSlots", over.side, over.slot, "pack", digit)
end

--- Returns the request that the drop key asks for while the pointer is over the slot `over`: the
--- request drops one item from the slot, or the whole stack if `wholeStack` is `true`, and throws
--- it along `direction`.
function InventoryControls.getRequestForDropKeyOverSlot(over: Slot, direction: Direction, wholeStack: boolean): Request
	return request("dropFromSlot", over.side, over.slot, direction, if wholeStack then nil else 1)
end

--- Returns the request that a click of `button` outside the panel of the screen asks for: the request drops the
--- whole carried stack for the left button, and one item of it for the right, and throws it along
--- `direction`.
function InventoryControls.getRequestForOutsideClick(button: SlotGestures.Button, direction: Direction): Request
	return request("dropCarriedStack", direction, if button == "left" then nil else 1)
end

return InventoryControls
