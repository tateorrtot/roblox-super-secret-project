--!strict
--- Tells clicks, double clicks and drags apart on the slots of the inventory screen.
---
--- It is told when a mouse button goes down on a slot (`press`), when the pointer comes onto
--- another slot while the button is held (`enter`), and when the button comes up (`release`).
--- `release` returns the gesture that the press and the release made.
local SlotGestures = {}

export type Button = "left" | "right"

--- One slot of the inventory screen: the side it is on, `"pack"` or `"other"`, and its number there.
export type Slot = { read side: string, read slot: number }

export type Gesture = {
	--- A click is a press and a release on one slot. A double click is the second left click on a
	--- slot within `DOUBLE_CLICK_SECONDS`. A drag is a press that crossed two or more slots.
	read kind: "click" | "doubleClick" | "drag",
	read button: Button,
	--- Whether a Shift key was held when the button came up.
	read shiftHeld: boolean,
	--- The slots the pointer crossed while the button was held, in order. A click has one.
	read slots: { Slot },
	--- The slot the pointer was over when the button came up. `nil` if it was over none.
	read releasedOn: Slot?,
}

export type SlotGestures = {
	--- The press in progress: the button that is down, and the slots crossed so far.
	pressed: { button: Button, slots: { Slot } }?,
	--- The last left click that could be the first half of a double click.
	lastLeftClick: { slot: Slot, at: number }?,
}

--- How soon, in seconds, a second left click on a slot must follow the first to be a double click.
SlotGestures.DOUBLE_CLICK_SECONDS = 0.4

local function isSameSlot(a: Slot, b: Slot?): boolean
	return b ~= nil and a.side == b.side and a.slot == b.slot
end

--- Returns a new SlotGestures with no press in progress and no click remembered.
function SlotGestures.new(): SlotGestures
	return {}
end

--- Records that a mouse button went down on a slot. A press already in progress is forgotten.
function SlotGestures.press(gestures: SlotGestures, button: Button, slot: Slot)
	gestures.pressed = { button = button, slots = { slot } }
end

--- Records that the pointer came onto a slot while a button is held. Does nothing if no press
--- is in progress, or if the pointer has crossed that slot already.
function SlotGestures.enter(gestures: SlotGestures, slot: Slot)
	local pressed = gestures.pressed
	if pressed == nil then
		return
	end
	for _, crossed in pressed.slots do
		if isSameSlot(crossed, slot) then
			return
		end
	end
	table.insert(pressed.slots, slot)
end

--- Returns the slots crossed by the press in progress, in order, if it has crossed two or more.
--- Returns an empty list otherwise.
function SlotGestures.getDraggedSlots(gestures: SlotGestures): { Slot }
	local pressed = gestures.pressed
	if pressed == nil or #pressed.slots < 2 then
		return {}
	end
	return table.clone(pressed.slots)
end

--- Records that a mouse button came up at the time `now`, in seconds, over the slot `over` or
--- over no slot, and returns the gesture this completes. Returns `nil` if that button was not
--- pressed on a slot, or if it was pressed on one slot and came up somewhere else without
--- crossing another. A click with Shift held, a right click and a drag are never half of a
--- double click.
function SlotGestures.release(
	gestures: SlotGestures,
	button: Button,
	over: Slot?,
	shiftHeld: boolean,
	now: number
): Gesture?
	local pressed = gestures.pressed
	if pressed == nil or pressed.button ~= button then
		return nil
	end
	gestures.pressed = nil
	local last = gestures.lastLeftClick
	gestures.lastLeftClick = nil
	if #pressed.slots >= 2 then
		return { kind = "drag", button = button, shiftHeld = shiftHeld, slots = pressed.slots, releasedOn = over }
	end
	local slot = pressed.slots[1]
	if not isSameSlot(slot, over) then
		return nil
	end
	local isPlainLeft = button == "left" and not shiftHeld
	local isSecond = last ~= nil and isSameSlot(last.slot, slot) and now - last.at < SlotGestures.DOUBLE_CLICK_SECONDS
	if isPlainLeft and isSecond then
		return { kind = "doubleClick", button = button, shiftHeld = false, slots = { slot }, releasedOn = over }
	end
	gestures.lastLeftClick = if isPlainLeft then { slot = slot, at = now } else nil
	return { kind = "click", button = button, shiftHeld = shiftHeld, slots = { slot }, releasedOn = over }
end

--- Forgets the press in progress and the last click.
function SlotGestures.reset(gestures: SlotGestures)
	gestures.pressed = nil
	gestures.lastLeftClick = nil
end

return SlotGestures
