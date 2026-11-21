--!strict
--- The gesture in progress on the slots of the inventory screen, which tells a click, a double
--- click, and a drag apart.
---
--- A gesture begins when a mouse button goes down on a slot (`beginGesture`), takes in each other
--- slot that the pointer comes onto while the button is held (`dragOverSlot`), and ends when the
--- button comes up (`endGesture`), which returns the gesture that was made. `getDraggedSlots`
--- returns the slots that the gesture in progress has crossed.
local SlotGestures = {}

--- A mouse button.
export type Button = "left" | "right"

--- One slot of the inventory screen: the side it is on, `"pack"` or `"other"`, and its number
--- there.
export type Slot = { read side: string, read slot: number }

--- What the player did with a mouse button on the slots: a click, a double click, or a drag.
export type Gesture = {
	--- The sort of gesture. A click is a press and a release on one slot. A double click is a left
	--- click without Shift on a slot, less than `DOUBLE_CLICK_SECONDS` after another such click on
	--- it. A drag is a press that crossed two or more slots.
	read kind: "click" | "doubleClick" | "drag",
	--- The mouse button that was held.
	read button: Button,
	--- If `true`, a Shift key was down when the button came up. A double click always has `false`.
	read shiftHeld: boolean,
	--- The slots that the pointer crossed while the button was held, in order. A click and a double
	--- click have one.
	read slots: { Slot },
	--- The slot that the pointer was over when the button came up. `nil` if it was over none.
	read releasedOn: Slot?,
}

--- The gesture in progress, and the left click that a double click could follow.
export type SlotGestures = {
	--- The gesture in progress: the button that is down, and the slots crossed so far. `nil` if no
	--- button is down.
	gestureInProgress: { button: Button, slots: { Slot } }?,
	--- The last left click that could be the first half of a double click, with the time `at` that
	--- it ended, in seconds. `nil` if no click could be.
	lastLeftClick: { slot: Slot, at: number }?,
}

--- The time, in seconds, below which a left click on a slot is a double click if it comes after
--- another left click on the same slot.
SlotGestures.DOUBLE_CLICK_SECONDS = 0.4

local function isSameSlot(a: Slot, b: Slot?): boolean
	return b ~= nil and a.side == b.side and a.slot == b.slot
end

--- Returns a new `SlotGestures` with no gesture in progress and no click remembered.
function SlotGestures.new(): SlotGestures
	return {}
end

--- Begins a gesture when `button` goes down on `slot`, and discards the gesture that was in
--- progress, if there was one.
function SlotGestures.beginGesture(gestures: SlotGestures, button: Button, slot: Slot)
	gestures.gestureInProgress = { button = button, slots = { slot } }
end

--- Adds `slot` to the slots that the gesture in progress has crossed, when the pointer comes onto
--- it while the button is held. Does nothing if no gesture is in progress, or if the gesture has
--- crossed `slot` already.
function SlotGestures.dragOverSlot(gestures: SlotGestures, slot: Slot)
	local inProgress = gestures.gestureInProgress
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

--- Returns a copy of the list of slots that the gesture in progress has crossed, in order, if it
--- has crossed two or more. Returns an empty list if it has crossed fewer, or if no gesture is in
--- progress.
function SlotGestures.getDraggedSlots(gestures: SlotGestures): { Slot }
	local inProgress = gestures.gestureInProgress
	if inProgress == nil or #inProgress.slots < 2 then
		return {}
	end
	return table.clone(inProgress.slots)
end

--- Ends the gesture in progress when `button` comes up at the time `now`, in seconds, over the slot
--- `over`, or over no slot if `over` is `nil`, and returns the gesture that was made. Returns `nil`
--- and changes nothing if no gesture is in progress, or if `button` is not the button that began
--- it. Returns `nil` and ends the gesture if it began on one slot and `button` came up on another,
--- or on none, without the pointer crossing a second slot. A left click without Shift is a double
--- click if the one before it was on the same slot, within `DOUBLE_CLICK_SECONDS`. A click with
--- Shift, a right click, and a drag end the memory of the click before them, and are never the
--- first half of a double click.
function SlotGestures.endGesture(
	gestures: SlotGestures,
	button: Button,
	over: Slot?,
	shiftHeld: boolean,
	now: number
): Gesture?
	local inProgress = gestures.gestureInProgress
	if inProgress == nil or inProgress.button ~= button then
		return nil
	end
	gestures.gestureInProgress = nil
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

--- Discards the gesture in progress and the click remembered for a double click.
function SlotGestures.reset(gestures: SlotGestures)
	gestures.gestureInProgress = nil
	gestures.lastLeftClick = nil
end

return SlotGestures
