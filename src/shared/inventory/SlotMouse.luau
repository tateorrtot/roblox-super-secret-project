--!strict
--[=[
	Works out what the player's mouse asks of the slots of the inventory
	screen: an ordinary click, a double click, a Shift and click, or a drag
	across several slots.

	The screen tells it what the mouse does on the slots, as it happens:
	- [method press] when a button goes down on a slot;
	- [method enter] when the pointer comes onto a slot with a button down;
	- [method release] when a button comes up, wherever the pointer is, with
	  the slot it is over then, if it is over one;
	- [method click] when a button has gone down and come up on one slot.

	[method click] returns the request that a click makes of the server:
	- `"quickMoveSlot"` for a left click with Shift held;
	- `"doubleClickSlot"` for the second of two plain left clicks on the same
	  slot within `SlotMouse.DOUBLE_CLICK_SECONDS`;
	- `"clickSlot"` for every other click.

	[method release] returns the slots of a drag when the button that comes up
	ends one, for a `"dragOverSlots"` request. As in Minecraft, a drag begins
	with a press on a slot while a stack is carried, and it is a drag once the
	pointer has been over two slots or more. A press and a release that stay
	on one slot are a click and no drag.

	A drag that ends on the slot it began on is also a press and a release on
	one slot, so the screen reports a click for it. That click asks for
	nothing more, and [method click] returns `nil` for it, whichever of the
	two the screen reports first.

	To tell a double click, it remembers the last plain left click: which
	slot, and when. A Shift and click is never half of a double click, and
	nor is a right click or a drag. After a double click the memory is empty,
	so a third quick click is a first click again.

	Time is a number of seconds, from any clock that only goes forward.

	```lua
	local slotMouse = SlotMouse.new()
	SlotMouse.click(slotMouse, "pack", 3, "left", false, 10.0) --> "clickSlot"
	SlotMouse.click(slotMouse, "pack", 3, "left", false, 10.2) --> "doubleClickSlot"
	SlotMouse.click(slotMouse, "pack", 3, "left", true, 10.3) --> "quickMoveSlot"

	SlotMouse.press(slotMouse, "pack", 3, "left", true) -- a press with a stack carried
	SlotMouse.enter(slotMouse, "pack", 4)
	SlotMouse.release(slotMouse, "left", { side = "pack", slot = 4 })
	--> { { side = "pack", slot = 3 }, { side = "pack", slot = 4 } }
	```
]=]
local SlotMouse = {}

--- The request a click makes.
export type Request = "clickSlot" | "doubleClickSlot" | "quickMoveSlot"

--- One slot of the screen: which of its inventories it is in, `"pack"` or `"other"`, and its slot number there.
export type ScreenSlot = { read side: string, read slot: number }

--- `read` means code outside this module cannot assign the field. The functions below change them.
export type SlotMouse = {
	--- The last plain left click, or `nil` if there has been none that could still begin a double click.
	read lastPlainLeft: { read side: string, read slot: number, read at: number }?,
	--- The press that may become a drag: the button that is down, and the slots the pointer has been
	--- over since it went down, in order. `nil` when no such button is down. `clicked` is whether the
	--- click that ends the drag has been reported already.
	read pressed: { read button: string, read slots: { ScreenSlot }, read clicked: boolean }?,
	--- The slot on which a drag has just both begun and ended, and the button it was made with, while
	--- the click that the screen reports for it is still to come. `nil` otherwise.
	read endedDragOn: { read side: string, read slot: number, read button: string }?,
}

--- How soon a second plain left click on a slot must follow the first to make a double click, in seconds.
SlotMouse.DOUBLE_CLICK_SECONDS = 0.4

-- True if a click on that slot with that button is the one the screen reports for a drag that began
-- on the slot `began` with the button `dragButton`.
local function endsDrag(began: ScreenSlot, dragButton: string, side: string, slot: number, button: string): boolean
	return began.side == side and began.slot == slot and dragButton == button
end

--[=[
	Returns a new memory of what the mouse has done, with nothing remembered.
]=]
function SlotMouse.new(): SlotMouse
	return {}
end

--[=[
	Tells it that a mouse button has gone down on a slot.

	`button` is `"left"` or `"right"`, and `carrying` is whether a stack is
	being carried. A drag may follow only if one is. A press takes the place
	of any press before it, so a second button going down ends a drag that
	the first began.
]=]
function SlotMouse.press(slotMouse: SlotMouse, side: string, slot: number, button: string, carrying: boolean)
	local writable = slotMouse :: any
	writable.endedDragOn = nil
	writable.pressed = if carrying
		then { button = button, slots = { { side = side, slot = slot } }, clicked = false }
		else nil
end

--[=[
	Tells it that the pointer has come onto a slot while a mouse button is
	down. The slot joins the drag that a press began, unless the pointer has
	been over it already. Does nothing if no press could become a drag.
]=]
function SlotMouse.enter(slotMouse: SlotMouse, side: string, slot: number)
	local pressed = slotMouse.pressed
	if pressed == nil then
		return
	end
	for _, screenSlot in pressed.slots do
		if screenSlot.side == side and screenSlot.slot == slot then
			return
		end
	end
	table.insert(pressed.slots :: { ScreenSlot }, { side = side, slot = slot })
end

--[=[
	Returns the slots of the drag in progress, in the order the pointer came
	onto them, or an empty list while the mouse is not dragging. A press is
	a drag only once the pointer has been over two slots.
]=]
function SlotMouse.getDraggedSlots(slotMouse: SlotMouse): { ScreenSlot }
	local pressed = slotMouse.pressed
	if pressed == nil or #pressed.slots < 2 then
		return {}
	end
	return table.clone(pressed.slots)
end

--[=[
	Tells it that a mouse button has come up. `over` is the slot the pointer
	is over as it does, or `nil` if it is over none.

	Returns the slots of the drag that this ends, in the order the pointer
	came onto them, or `nil` if it ends none: the button is not the one that
	was pressed, or the pointer was over fewer than two slots.
]=]
function SlotMouse.release(slotMouse: SlotMouse, button: string, over: ScreenSlot?): { ScreenSlot }?
	local writable = slotMouse :: any
	local pressed = slotMouse.pressed
	if pressed == nil or pressed.button ~= button then
		return nil
	end
	writable.pressed = nil
	if #pressed.slots < 2 then
		return nil
	end
	-- Only a drag that ends on the slot it began on is followed by a click, unless that came first.
	local began = pressed.slots[1]
	local endedWhereItBegan = over ~= nil and over.side == began.side and over.slot == began.slot
	writable.lastPlainLeft = nil
	writable.endedDragOn = if endedWhereItBegan and not pressed.clicked
		then { side = began.side, slot = began.slot, button = button }
		else nil
	return pressed.slots
end

--[=[
	Returns the request that a click makes, or `nil` if the click is only the
	end of a drag. Remembers the click if it could be the first half of a
	double click.

	`side` and `slot` say which slot was clicked, `button` is `"left"` or
	`"right"`, `shiftHeld` is whether a Shift key was down, and `now` is the
	time of the click.
]=]
function SlotMouse.click(
	slotMouse: SlotMouse,
	side: string,
	slot: number,
	button: string,
	shiftHeld: boolean,
	now: number
): Request?
	local writable = slotMouse :: any
	local pressed = slotMouse.pressed
	if pressed ~= nil and #pressed.slots >= 2 and endsDrag(pressed.slots[1], pressed.button, side, slot, button) then
		(pressed :: any).clicked = true
		return nil
	end
	local ended = slotMouse.endedDragOn
	writable.endedDragOn = nil
	if ended ~= nil and endsDrag(ended, ended.button, side, slot, button) then
		return nil
	end
	local isPlainLeft = button == "left" and not shiftHeld
	local last = slotMouse.lastPlainLeft
	local isDouble = isPlainLeft
		and last ~= nil
		and last.side == side
		and last.slot == slot
		and now - last.at < SlotMouse.DOUBLE_CLICK_SECONDS
	writable.lastPlainLeft = if isPlainLeft and not isDouble then { side = side, slot = slot, at = now } else nil
	if isDouble then
		return "doubleClickSlot"
	elseif button == "left" and shiftHeld then
		return "quickMoveSlot"
	end
	return "clickSlot"
end

--[=[
	Forgets everything, as when the inventory screen closes: the next click
	is a first click, and no drag is in progress.
]=]
function SlotMouse.forget(slotMouse: SlotMouse)
	local writable = slotMouse :: any
	writable.lastPlainLeft = nil
	writable.pressed = nil
	writable.endedDragOn = nil
end

return SlotMouse
