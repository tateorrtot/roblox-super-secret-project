--!strict
--- Tells clicks, double clicks and drags apart on the slots of the inventory screen.
---
--- A gesture begins when a mouse button goes down on a slot (`beginGesture`), takes in each other
--- slot the pointer comes onto while the button is held (`dragOverSlot`), and ends when the button
--- comes up (`endGesture`), which returns the gesture that was made.
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
	--- The gesture in progress: the button that is down, and the slots crossed so far. `nil` when
	--- no button is down.
	inProgress: { button: Button, slots: { Slot } }?,
	--- The last left click that could be the first half of a double click.
	lastLeftClick: { slot: Slot, at: number }?,
}

--- How soon, in seconds, a second left click on a slot must follow the first to be a double click.
SlotGestures.DOUBLE_CLICK_SECONDS = 0.4

local function isSameSlot(a: Slot, b: Slot?): boolean
	return b ~= nil and a.side == b.side and a.slot == b.slot
end

--- Returns a new SlotGestures with no gesture in progress and no click remembered.
function SlotGestures.new(): SlotGestures
	return {}
end

--- Begins a gesture: a mouse button went down on a slot. A gesture already in progress is forgotten.
function SlotGestures.beginGesture(gestures: SlotGestures, button: Button, slot: Slot)
	gestures.inProgress = { button = button, slots = { slot } }
end

--- Adds a slot to the gesture in progress: the pointer came onto it while the button is held.
--- Does nothing if no gesture is in progress, or if the pointer has crossed that slot already.
function SlotGestures.dragOverSlot(gestures: SlotGestures, slot: Slot)
	local inProgress = gestures.inProgress
	if inProgress == nil then
		return
	end
	for _, crossed in inProgress.slots do
		if isSameSlot(crossed, slot) then
			return
		end
	end
	table.insert(inProgress.slots, slot)
end

--- Returns the slots crossed by the gesture in progress, in order, if it has crossed two or more.
--- Returns an empty list otherwise.
function SlotGestures.getDraggedSlots(gestures: SlotGestures): { Slot }
	local inProgress = gestures.inProgress
	if inProgress == nil or #inProgress.slots < 2 then
		return {}
	end
	return table.clone(inProgress.slots)
end

--- Ends the gesture in progress and returns it: a mouse button came up at the time `now`, in
--- seconds, over the slot `over` or over no slot. Returns `nil` if no gesture was begun with that
--- button, or if it began on one slot and the button came up somewhere else without crossing
--- another. A click with Shift held, a right click and a drag are never half of a double click.
function SlotGestures.endGesture(
	gestures: SlotGestures,
	button: Button,
	over: Slot?,
	shiftHeld: boolean,
	now: number
): Gesture?
	local inProgress = gestures.inProgress
	if inProgress == nil or inProgress.button ~= button then
		return nil
	end
	gestures.inProgress = nil
	local last = gestures.lastLeftClick
	gestures.lastLeftClick = nil
	if #inProgress.slots >= 2 then
		return { kind = "drag", button = button, shiftHeld = shiftHeld, slots = inProgress.slots, releasedOn = over }
	end
	local slot = inProgress.slots[1]
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

--- Forgets the gesture in progress and the last click.
function SlotGestures.reset(gestures: SlotGestures)
	gestures.inProgress = nil
	gestures.lastLeftClick = nil
end

return SlotGestures
