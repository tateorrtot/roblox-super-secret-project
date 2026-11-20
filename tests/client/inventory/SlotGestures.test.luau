--!strict
-- Tests for SlotGestures. Run from the repository root: lune run tests/client/inventory/SlotGestures.test.luau

local Check = require("../../Check")
local SlotGestures = require("../../../src/client/inventory/SlotGestures")

local check = Check.that

local press = SlotGestures.beginGesture
local enter = SlotGestures.dragOverSlot
local release = SlotGestures.endGesture

-- Names a slot of the screen.
local function at(side: string, slot: number): SlotGestures.Slot
	return { side = side, slot = slot }
end

-- Describes a list of slots, such as "pack 3, other 1", or "none" for nil.
local function describe(slots: { SlotGestures.Slot }?): string
	if slots == nil then
		return "none"
	end
	local parts = {}
	for _, slot in slots do
		table.insert(parts, slot.side .. " " .. slot.slot)
	end
	return table.concat(parts, ", ")
end

-- Presses and releases `button` on one slot at the time `now`, and returns the gesture.
local function clickOn(
	gestures: SlotGestures.SlotGestures,
	button: SlotGestures.Button,
	slot: SlotGestures.Slot,
	shiftHeld: boolean,
	now: number
): SlotGestures.Gesture?
	press(gestures, button, slot)
	return release(gestures, button, slot, shiftHeld, now)
end

-- Returns the kind of the gesture, or "none" for nil.
local function kindOf(gesture: SlotGestures.Gesture?): string
	return if gesture then gesture.kind else "none"
end

do -- the rule as a number
	check(
		SlotGestures.DOUBLE_CLICK_SECONDS == 0.4,
		"DOUBLE_CLICK_SECONDS: a double click is two clicks within four tenths of a second"
	)
end

do -- new
	local gestures = SlotGestures.new()
	check(gestures.inProgress == nil, "new: no gesture is in progress")
	check(gestures.lastLeftClick == nil, "new: no click is remembered")
	check(#SlotGestures.getDraggedSlots(gestures) == 0, "new: no slots are dragged")
end

do -- a click
	local gestures = SlotGestures.new()
	press(gestures, "left", at("pack", 3))
	local gesture = release(gestures, "left", at("pack", 3), false, 10)
	check(gesture ~= nil and gesture.kind == "click", "endGesture: a press and release on one slot is a click")
	if gesture then
		check(gesture.button == "left", "endGesture: the click is of the button that went down")
		check(gesture.shiftHeld == false, "endGesture: the click says Shift was not held")
		check(describe(gesture.slots) == "pack 3", "endGesture: a click has the one slot")
		check(
			gesture.releasedOn ~= nil and describe({ gesture.releasedOn }) == "pack 3",
			"endGesture: the click says where the button came up"
		)
	end
	check(gestures.inProgress == nil, "endGesture: the gesture is over")
	check(
		release(gestures, "left", at("pack", 3), false, 10.1) == nil,
		"endGesture: a second release with no press gives nothing"
	)

	local right = clickOn(SlotGestures.new(), "right", at("other", 2), false, 10)
	check(
		right ~= nil and right.kind == "click" and right.button == "right",
		"endGesture: a right click is a click of the right button"
	)
	check(right ~= nil and describe(right.slots) == "other 2", "endGesture: and has its slot")

	local shifted = clickOn(SlotGestures.new(), "left", at("pack", 3), true, 10)
	check(
		shifted ~= nil and shifted.kind == "click" and shifted.shiftHeld,
		"endGesture: a click with Shift held says so"
	)
	local shiftedRight = clickOn(SlotGestures.new(), "right", at("pack", 3), true, 10)
	check(shiftedRight ~= nil and shiftedRight.shiftHeld, "endGesture: a right click with Shift held says so")
end

do -- the button that comes up is not the one that went down
	local gestures = SlotGestures.new()
	press(gestures, "left", at("pack", 3))
	check(
		release(gestures, "right", at("pack", 3), false, 10) == nil,
		"endGesture: the other button coming up gives nothing"
	)
	check(gestures.inProgress ~= nil, "endGesture: and the gesture goes on")
	check(
		kindOf(release(gestures, "left", at("pack", 3), false, 10.1)) == "click",
		"endGesture: until its own button comes up"
	)

	local unpressed = SlotGestures.new()
	check(
		release(unpressed, "left", at("pack", 3), false, 10) == nil,
		"endGesture: nothing was pressed, so it gives nothing"
	)
	check(release(unpressed, "right", nil, false, 10) == nil, "endGesture: nor over no slot")
end

do -- a button that comes up away from the slot it went down on
	local gestures = SlotGestures.new()
	press(gestures, "left", at("pack", 3))
	check(
		release(gestures, "left", at("pack", 4), false, 10) == nil,
		"endGesture: coming up on another slot, with none crossed, gives nothing"
	)
	check(gestures.inProgress == nil, "endGesture: and the gesture is over")

	press(gestures, "left", at("pack", 3))
	check(
		release(gestures, "left", at("other", 3), false, 10) == nil,
		"endGesture: the same slot number on the other side is another slot"
	)

	press(gestures, "left", at("pack", 3))
	check(release(gestures, "left", nil, false, 10) == nil, "endGesture: coming up over no slot gives nothing")
	check(gestures.inProgress == nil, "endGesture: and the gesture is over again")
end

do -- double clicks
	local gestures = SlotGestures.new()
	check(
		kindOf(clickOn(gestures, "left", at("pack", 3), false, 10)) == "click",
		"endGesture: a first left click is a click"
	)
	check(gestures.lastLeftClick ~= nil, "endGesture: a plain left click is remembered")
	local second = clickOn(gestures, "left", at("pack", 3), false, 10.39)
	check(kindOf(second) == "doubleClick", "endGesture: a second left click on the slot just in time is a double click")
	if second then
		check(
			second.button == "left" and not second.shiftHeld,
			"endGesture: a double click is of the left button, with no Shift"
		)
		check(describe(second.slots) == "pack 3", "endGesture: a double click has its slot")
		check(
			second.releasedOn ~= nil and describe({ second.releasedOn }) == "pack 3",
			"endGesture: a double click says where the button came up"
		)
	end
	check(
		kindOf(clickOn(gestures, "left", at("pack", 3), false, 10.5)) == "click",
		"endGesture: a third quick click is a first click again"
	)
	check(
		kindOf(clickOn(gestures, "left", at("pack", 3), false, 10.6)) == "doubleClick",
		"endGesture: and a fourth is its double"
	)

	local late = SlotGestures.new()
	clickOn(late, "left", at("pack", 3), false, 0)
	check(
		kindOf(clickOn(late, "left", at("pack", 3), false, SlotGestures.DOUBLE_CLICK_SECONDS)) == "click",
		"endGesture: a second click exactly four tenths of a second later is too late"
	)
	check(
		kindOf(clickOn(late, "left", at("pack", 3), false, SlotGestures.DOUBLE_CLICK_SECONDS + 0.3)) == "doubleClick",
		"endGesture: but that late click can itself begin a double click"
	)

	local elsewhere = SlotGestures.new()
	clickOn(elsewhere, "left", at("pack", 3), false, 10)
	check(
		kindOf(clickOn(elsewhere, "left", at("pack", 4), false, 10.1)) == "click",
		"endGesture: a click on another slot is not a double click"
	)
	check(
		kindOf(clickOn(elsewhere, "left", at("other", 4), false, 10.2)) == "click",
		"endGesture: nor is one on the same slot number of the other side"
	)
	check(
		kindOf(clickOn(elsewhere, "left", at("other", 4), false, 10.3)) == "doubleClick",
		"endGesture: each click is measured against the one before it"
	)

	local sameNumber = SlotGestures.new()
	clickOn(sameNumber, "left", at("other", 3), false, 10)
	check(
		kindOf(clickOn(sameNumber, "left", at("pack", 3), false, 10.1)) == "click",
		"endGesture: a click on the same slot number of the other side from the first click is not a double click"
	)
end

do -- what is never half of a double click
	local rightBetween = SlotGestures.new()
	clickOn(rightBetween, "left", at("pack", 3), false, 10)
	clickOn(rightBetween, "right", at("pack", 3), false, 10.1)
	check(
		kindOf(clickOn(rightBetween, "left", at("pack", 3), false, 10.2)) == "click",
		"endGesture: a right click in between breaks a double click"
	)

	local rights = SlotGestures.new()
	clickOn(rights, "right", at("pack", 3), false, 10)
	check(rights.lastLeftClick == nil, "endGesture: a right click is not remembered")
	check(
		kindOf(clickOn(rights, "right", at("pack", 3), false, 10.1)) == "click",
		"endGesture: two right clicks are two clicks"
	)

	local shifted = SlotGestures.new()
	check(
		kindOf(clickOn(shifted, "left", at("pack", 3), true, 10)) == "click",
		"endGesture: a left click with Shift held is a click"
	)
	check(shifted.lastLeftClick == nil, "endGesture: and is not remembered")
	check(
		kindOf(clickOn(shifted, "left", at("pack", 3), true, 10.1)) == "click",
		"endGesture: and the next one, however soon, is a click too"
	)
	check(
		kindOf(clickOn(shifted, "left", at("pack", 3), false, 10.2)) == "click",
		"endGesture: a plain click straight after them is a first click"
	)

	local between = SlotGestures.new()
	clickOn(between, "left", at("pack", 3), false, 10)
	clickOn(between, "left", at("pack", 3), true, 10.1)
	check(
		kindOf(clickOn(between, "left", at("pack", 3), false, 10.2)) == "click",
		"endGesture: a click with Shift held in between breaks a double click"
	)

	local secondShifted = SlotGestures.new()
	clickOn(secondShifted, "left", at("pack", 3), false, 10)
	local shiftedSecond = clickOn(secondShifted, "left", at("pack", 3), true, 10.1)
	check(
		shiftedSecond ~= nil and shiftedSecond.kind == "click" and shiftedSecond.shiftHeld,
		"endGesture: a second click with Shift held is a click with Shift held"
	)

	local secondRight = SlotGestures.new()
	clickOn(secondRight, "left", at("pack", 3), false, 10)
	check(
		kindOf(clickOn(secondRight, "right", at("pack", 3), false, 10.1)) == "click",
		"endGesture: a second click with the right button is a click"
	)

	local afterDrag = SlotGestures.new()
	clickOn(afterDrag, "left", at("pack", 3), false, 10)
	press(afterDrag, "left", at("pack", 3))
	enter(afterDrag, at("pack", 4))
	release(afterDrag, "left", at("pack", 4), false, 10.1)
	check(afterDrag.lastLeftClick == nil, "endGesture: a drag makes the click before it forgotten")
	check(
		kindOf(clickOn(afterDrag, "left", at("pack", 3), false, 10.2)) == "click",
		"endGesture: so a click straight after a drag is a first click"
	)

	local awayAfter = SlotGestures.new()
	clickOn(awayAfter, "left", at("pack", 3), false, 10)
	press(awayAfter, "left", at("pack", 3))
	release(awayAfter, "left", at("pack", 4), false, 10.1)
	check(
		kindOf(clickOn(awayAfter, "left", at("pack", 3), false, 10.2)) == "click",
		"endGesture: a press that came up elsewhere makes the click before it forgotten"
	)
end

do -- a drag across slots
	local gestures = SlotGestures.new()
	press(gestures, "left", at("pack", 3))
	check(#SlotGestures.getDraggedSlots(gestures) == 0, "getDraggedSlots: a press on one slot is not yet a drag")
	enter(gestures, at("pack", 4))
	check(
		describe(SlotGestures.getDraggedSlots(gestures)) == "pack 3, pack 4",
		"getDraggedSlots: the press is a drag once the pointer has been over two slots"
	)
	enter(gestures, at("pack", 4))
	enter(gestures, at("pack", 3))
	check(
		#SlotGestures.getDraggedSlots(gestures) == 2,
		"dragOverSlot: a slot the pointer comes back onto is not added again"
	)
	enter(gestures, at("other", 4))
	enter(gestures, at("other", 3))
	check(
		describe(SlotGestures.getDraggedSlots(gestures)) == "pack 3, pack 4, other 4, other 3",
		"dragOverSlot: the same slot number on the other side is another slot"
	)
	local inProgress = SlotGestures.getDraggedSlots(gestures)
	table.remove(inProgress)
	check(#SlotGestures.getDraggedSlots(gestures) == 4, "getDraggedSlots: the list returned is the caller's own")

	local gesture = release(gestures, "left", at("other", 3), false, 10)
	check(gesture ~= nil and gesture.kind == "drag", "endGesture: a press that crossed slots is a drag")
	if gesture then
		check(
			gesture.button == "left" and not gesture.shiftHeld,
			"endGesture: the drag is of the button that went down"
		)
		check(
			describe(gesture.slots) == "pack 3, pack 4, other 4, other 3",
			"endGesture: the drag has the slots in the order the pointer came onto them"
		)
		check(
			gesture.releasedOn ~= nil and describe({ gesture.releasedOn }) == "other 3",
			"endGesture: the drag says where the button came up"
		)
	end
	check(
		gestures.inProgress == nil and #SlotGestures.getDraggedSlots(gestures) == 0,
		"endGesture: and the drag is over"
	)
	check(release(gestures, "left", at("other", 3), false, 10.1) == nil, "endGesture: a second release ends nothing")

	local right = SlotGestures.new()
	press(right, "right", at("other", 1))
	enter(right, at("other", 2))
	local rightDrag = release(right, "right", at("other", 2), true, 10)
	check(
		rightDrag ~= nil and rightDrag.kind == "drag" and rightDrag.button == "right",
		"endGesture: a drag with the right button is a drag"
	)
	check(rightDrag ~= nil and rightDrag.shiftHeld, "endGesture: and says Shift was held when it came up")

	local over = SlotGestures.new()
	press(over, "left", at("pack", 1))
	enter(over, at("pack", 2))
	local overNone = release(over, "left", nil, false, 10)
	check(
		overNone ~= nil and overNone.kind == "drag" and overNone.releasedOn == nil,
		"endGesture: a drag that comes up over no slot is a drag with no slot released on"
	)
end

do -- a slot crossed twice counts once
	local gestures = SlotGestures.new()
	press(gestures, "left", at("pack", 3))
	enter(gestures, at("pack", 4))
	enter(gestures, at("pack", 3))
	local gesture = release(gestures, "left", at("pack", 3), false, 10)
	check(gesture ~= nil and gesture.kind == "drag", "endGesture: a drag that went away and came back is still a drag")
	check(gesture ~= nil and describe(gesture.slots) == "pack 3, pack 4", "endGesture: and lists each slot once")
	check(
		gesture ~= nil and gesture.releasedOn ~= nil and describe({ gesture.releasedOn }) == "pack 3",
		"endGesture: and says it came up on the slot it began on"
	)

	local still = SlotGestures.new()
	press(still, "left", at("pack", 3))
	enter(still, at("pack", 3))
	check(#SlotGestures.getDraggedSlots(still) == 0, "dragOverSlot: coming onto the slot pressed does not make a drag")
	check(kindOf(release(still, "left", at("pack", 3), false, 10)) == "click", "endGesture: and the press is a click")
end

do -- dragOverSlot and presses that are not alone
	local unpressed = SlotGestures.new()
	enter(unpressed, at("pack", 3))
	enter(unpressed, at("pack", 4))
	check(
		unpressed.inProgress == nil and #SlotGestures.getDraggedSlots(unpressed) == 0,
		"dragOverSlot: does nothing when no button went down on a slot"
	)
	check(release(unpressed, "left", at("pack", 4), false, 10) == nil, "endGesture: so nothing comes of it")

	local second = SlotGestures.new()
	press(second, "left", at("pack", 3))
	enter(second, at("pack", 4))
	press(second, "right", at("pack", 5))
	check(
		#SlotGestures.getDraggedSlots(second) == 0,
		"beginGesture: a second button going down forgets the drag the first began"
	)
	check(
		release(second, "left", at("pack", 5), false, 10) == nil,
		"endGesture: so the first button coming up gives nothing"
	)
	enter(second, at("pack", 6))
	local drag = release(second, "right", at("pack", 6), false, 10.1)
	check(
		drag ~= nil and drag.kind == "drag" and drag.button == "right" and describe(drag.slots) == "pack 5, pack 6",
		"endGesture: and the second button may drag in its turn"
	)

	local other = SlotGestures.new()
	press(other, "left", at("pack", 3))
	enter(other, at("pack", 4))
	check(
		release(other, "right", at("pack", 4), false, 10) == nil,
		"endGesture: the other button coming up does not end a drag"
	)
	check(#SlotGestures.getDraggedSlots(other) == 2, "getDraggedSlots: and the drag goes on")
	check(
		kindOf(release(other, "left", at("pack", 4), false, 10.1)) == "drag",
		"endGesture: until the button that began it comes up"
	)
end

do -- reset
	local gestures = SlotGestures.new()
	clickOn(gestures, "left", at("pack", 3), false, 10)
	SlotGestures.reset(gestures)
	check(gestures.lastLeftClick == nil, "reset: no click is remembered")
	check(
		kindOf(clickOn(gestures, "left", at("pack", 3), false, 10.1)) == "click",
		"reset: so the next click is a first click"
	)

	press(gestures, "left", at("pack", 3))
	enter(gestures, at("pack", 4))
	SlotGestures.reset(gestures)
	check(
		gestures.inProgress == nil and #SlotGestures.getDraggedSlots(gestures) == 0,
		"reset: a press in progress is forgotten"
	)
	check(release(gestures, "left", at("pack", 4), false, 10.2) == nil, "reset: so its button coming up gives nothing")
	SlotGestures.reset(SlotGestures.new())
end

Check.finish("SlotGestures")
