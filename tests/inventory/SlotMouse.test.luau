--!strict
-- Tests for SlotMouse. Run from the repository root: lune run tests/inventory/SlotMouse.test.luau

local Check = require("../Check")
local SlotMouse = require("../../src/shared/inventory/SlotMouse")

local check = Check.that
local click = SlotMouse.click
local press = SlotMouse.press
local enter = SlotMouse.enter
local release = SlotMouse.release

-- Names a slot of the screen.
local function at(side: string, slot: number): SlotMouse.ScreenSlot
	return { side = side, slot = slot }
end

-- Describes a list of slots, such as "pack 3, other 1", or "none" for nil.
local function describe(screenSlots: { SlotMouse.ScreenSlot }?): string
	if screenSlots == nil then
		return "none"
	end
	local parts = {}
	for _, screenSlot in screenSlots do
		table.insert(parts, screenSlot.side .. " " .. screenSlot.slot)
	end
	return table.concat(parts, ", ")
end

do -- the rules as numbers
	check(SlotMouse.DOUBLE_CLICK_SECONDS == 0.4, "a double click is two clicks within four tenths of a second")
end

do -- ordinary clicks
	local mouse = SlotMouse.new()
	check(
		mouse.lastPlainLeft == nil and mouse.pressed == nil and mouse.endedDragOn == nil,
		"new: nothing is remembered"
	)
	check(click(mouse, "pack", 3, "left", false, 10) == "clickSlot", "click: a first left click is a click")
	check(click(mouse, "pack", 3, "right", false, 10.1) == "clickSlot", "click: a right click is a click")
	check(click(mouse, "pack", 3, "right", false, 10.2) == "clickSlot", "click: two right clicks are two clicks")
	check(
		click(mouse, "pack", 3, "right", true, 10.3) == "clickSlot",
		"click: a right click with Shift held is a click"
	)
end

do -- double clicks
	local mouse = SlotMouse.new()
	click(mouse, "pack", 3, "left", false, 10)
	check(
		click(mouse, "pack", 3, "left", false, 10.39) == "doubleClickSlot",
		"click: a second left click on the slot just in time is a double click"
	)
	check(
		click(mouse, "pack", 3, "left", false, 10.5) == "clickSlot",
		"click: a third quick click is a first click again"
	)
	check(click(mouse, "pack", 3, "left", false, 10.6) == "doubleClickSlot", "click: and a fourth is its double")

	local late = SlotMouse.new()
	click(late, "pack", 3, "left", false, 0)
	check(
		click(late, "pack", 3, "left", false, SlotMouse.DOUBLE_CLICK_SECONDS) == "clickSlot",
		"click: a second click exactly four tenths later is too late"
	)
	check(
		click(late, "pack", 3, "left", false, SlotMouse.DOUBLE_CLICK_SECONDS + 0.3) == "doubleClickSlot",
		"click: but it can itself begin a double click"
	)

	local elsewhere = SlotMouse.new()
	click(elsewhere, "pack", 3, "left", false, 10)
	check(
		click(elsewhere, "pack", 4, "left", false, 10.1) == "clickSlot",
		"click: a click on another slot is not a double click"
	)
	check(
		click(elsewhere, "other", 4, "left", false, 10.2) == "clickSlot",
		"click: nor is one on the same slot number of the other side"
	)
	check(
		click(elsewhere, "other", 4, "left", false, 10.3) == "doubleClickSlot",
		"click: each click is measured against the one before it"
	)

	local mixed = SlotMouse.new()
	click(mixed, "pack", 3, "left", false, 10)
	click(mixed, "pack", 3, "right", false, 10.1)
	check(
		click(mixed, "pack", 3, "left", false, 10.2) == "clickSlot",
		"click: a right click in between breaks a double click"
	)
end

do -- Shift and a click
	local mouse = SlotMouse.new()
	check(
		click(mouse, "pack", 3, "left", true, 10) == "quickMoveSlot",
		"click: a left click with Shift held is a quick move"
	)
	check(click(mouse, "pack", 3, "left", true, 10.1) == "quickMoveSlot", "click: and so is the next one, however soon")
	check(mouse.lastPlainLeft == nil, "click: a Shift and click is not remembered")
	check(
		click(mouse, "pack", 3, "left", false, 10.2) == "clickSlot",
		"click: a plain click straight after a Shift and click is a click, not a double click"
	)

	local between = SlotMouse.new()
	click(between, "pack", 3, "left", false, 10)
	click(between, "pack", 3, "left", true, 10.1)
	check(
		click(between, "pack", 3, "left", false, 10.2) == "clickSlot",
		"click: a Shift and click in between breaks a double click"
	)
end

do -- a drag across slots
	local mouse = SlotMouse.new()
	press(mouse, "pack", 3, "left", true)
	check(#SlotMouse.getDraggedSlots(mouse) == 0, "press: a press on one slot is not yet a drag")
	enter(mouse, "pack", 4)
	check(
		describe(SlotMouse.getDraggedSlots(mouse)) == "pack 3, pack 4",
		"enter: it is a drag once the pointer has been over two slots"
	)
	enter(mouse, "pack", 4)
	enter(mouse, "pack", 3)
	check(#SlotMouse.getDraggedSlots(mouse) == 2, "enter: a slot the pointer comes back onto is not added again")
	enter(mouse, "other", 4)
	enter(mouse, "other", 3)
	check(
		describe(SlotMouse.getDraggedSlots(mouse)) == "pack 3, pack 4, other 4, other 3",
		"enter: the same slot number on the other side is another slot"
	)
	local inProgress = SlotMouse.getDraggedSlots(mouse)
	table.remove(inProgress)
	check(#SlotMouse.getDraggedSlots(mouse) == 4, "getDraggedSlots: the list returned is the caller's own")
	check(
		describe(release(mouse, "left")) == "pack 3, pack 4, other 4, other 3",
		"release: returns the slots of the drag, in the order the pointer came onto them"
	)
	check(mouse.pressed == nil and #SlotMouse.getDraggedSlots(mouse) == 0, "release: and the drag is over")
	check(release(mouse, "left") == nil, "release: a second release ends nothing")

	local right = SlotMouse.new()
	press(right, "other", 1, "right", true)
	enter(right, "other", 2)
	check(
		describe(release(right, "right")) == "other 1, other 2",
		"release: a drag with the right button is a drag too"
	)
end

do -- what is not a drag
	local empty = SlotMouse.new()
	press(empty, "pack", 3, "left", false)
	check(empty.pressed == nil, "press: with nothing carried, no drag can begin")
	enter(empty, "pack", 4)
	check(release(empty, "left") == nil, "release: so moving across slots with nothing carried is no drag")

	local still = SlotMouse.new()
	press(still, "pack", 3, "left", true)
	check(release(still, "left") == nil, "release: a press and a release on one slot is no drag")
	check(still.pressed == nil, "release: and the press is over")
	press(still, "pack", 3, "left", true)
	enter(still, "pack", 3)
	check(release(still, "left") == nil, "release: nor is one where the pointer left the slot and came back")

	local unpressed = SlotMouse.new()
	enter(unpressed, "pack", 3)
	enter(unpressed, "pack", 4)
	check(unpressed.pressed == nil, "enter: does nothing when no button went down on a slot")
	check(release(unpressed, "left") == nil, "release: nothing to end when no button went down on a slot")

	local other = SlotMouse.new()
	press(other, "pack", 3, "left", true)
	enter(other, "pack", 4)
	check(release(other, "right") == nil, "release: the other button coming up does not end a drag")
	check(#SlotMouse.getDraggedSlots(other) == 2, "release: and the drag goes on")
	check(describe(release(other, "left")) == "pack 3, pack 4", "release: until the button that began it comes up")

	local second = SlotMouse.new()
	press(second, "pack", 3, "left", true)
	enter(second, "pack", 4)
	press(second, "pack", 5, "right", true)
	check(#SlotMouse.getDraggedSlots(second) == 0, "press: a second button going down ends the drag the first began")
	check(release(second, "left") == nil, "release: so the first button coming up ends nothing")
	enter(second, "pack", 6)
	check(describe(release(second, "right")) == "pack 5, pack 6", "release: and the second may drag in its turn")

	local dropped = SlotMouse.new()
	press(dropped, "pack", 3, "left", true)
	enter(dropped, "pack", 4)
	press(dropped, "pack", 5, "left", false)
	check(release(dropped, "left") == nil, "press: a press with nothing carried ends a drag as well")
end

do -- the click that the screen reports when a drag ends on the slot it began on
	-- The release is reported first.
	local mouse = SlotMouse.new()
	press(mouse, "pack", 3, "left", true)
	enter(mouse, "pack", 4)
	enter(mouse, "pack", 3)
	release(mouse, "left", at("pack", 3))
	check(click(mouse, "pack", 3, "left", false, 10) == nil, "click: the click that ends a drag asks for nothing")
	check(mouse.lastPlainLeft == nil, "click: and is not remembered")
	check(click(mouse, "pack", 3, "left", false, 10.1) == "clickSlot", "click: the click after it is a click again")

	-- The click is reported first.
	local early = SlotMouse.new()
	press(early, "pack", 3, "left", true)
	enter(early, "pack", 4)
	check(
		click(early, "pack", 3, "left", false, 10) == nil,
		"click: nor does it when it is reported before the release"
	)
	check(
		describe(release(early, "left", at("pack", 3))) == "pack 3, pack 4",
		"release: and the release still returns the drag"
	)
	check(early.endedDragOn == nil, "release: with no click still to come")
	check(click(early, "pack", 3, "left", false, 10.1) == "clickSlot", "click: so the next click is a click")

	-- Only the click on the slot the drag began on, with the button that dragged, is its end.
	local elsewhere = SlotMouse.new()
	press(elsewhere, "pack", 3, "left", true)
	enter(elsewhere, "pack", 4)
	check(
		click(elsewhere, "pack", 4, "left", false, 10) == "clickSlot",
		"click: a click on another slot while a drag goes on is a click"
	)
	check(
		click(elsewhere, "other", 3, "left", false, 10.5) == "clickSlot",
		"click: so is one on the same slot number of the other side"
	)
	check(click(elsewhere, "pack", 3, "right", false, 11) == "clickSlot", "click: and one with the other button")
	release(elsewhere, "left", at("pack", 3))
	check(
		click(elsewhere, "pack", 4, "left", false, 12) == "clickSlot",
		"click: after a drag, a click on another slot is a click"
	)
	check(elsewhere.endedDragOn == nil, "click: and the drag is no longer waiting for its own")
	press(elsewhere, "pack", 3, "left", true)
	enter(elsewhere, "pack", 4)
	release(elsewhere, "left", at("pack", 3))
	check(
		click(elsewhere, "other", 3, "left", false, 13) == "clickSlot",
		"click: after a drag, so is one on the same slot number of the other side"
	)
	press(elsewhere, "pack", 3, "left", true)
	enter(elsewhere, "pack", 4)
	release(elsewhere, "left", at("pack", 3))
	check(click(elsewhere, "pack", 3, "right", false, 14) == "clickSlot", "click: and one with the other button")

	-- A drag that ends on another slot, or over none, is followed by no click, so none is waited for.
	local away = SlotMouse.new()
	press(away, "pack", 3, "left", true)
	enter(away, "pack", 4)
	release(away, "left", at("pack", 4))
	check(away.endedDragOn == nil, "release: a drag that ends on another slot waits for no click")
	check(
		click(away, "pack", 3, "left", false, 10) == "clickSlot",
		"click: so the next click on the slot it began on is a click"
	)
	press(away, "pack", 3, "left", true)
	enter(away, "pack", 4)
	release(away, "left", at("other", 3))
	check(away.endedDragOn == nil, "release: the same slot number on the other side is another slot")
	press(away, "pack", 3, "left", true)
	enter(away, "pack", 4)
	release(away, "left", at("other", 4))
	check(away.endedDragOn == nil, "release: and so is another slot of the other side")
	press(away, "pack", 3, "left", true)
	enter(away, "pack", 4)
	release(away, "left")
	check(away.endedDragOn == nil, "release: nor does a drag that ends over no slot wait for one")

	-- If the click for a drag never comes, the next press stops the wait.
	local waiting = SlotMouse.new()
	press(waiting, "pack", 3, "left", true)
	enter(waiting, "pack", 4)
	release(waiting, "left", at("pack", 3))
	check(
		waiting.endedDragOn ~= nil,
		"release: a drag that ends where it began waits for the click the screen reports for it"
	)
	press(waiting, "pack", 3, "left", false)
	check(waiting.endedDragOn == nil, "press: and stops waiting when a button next goes down")
	check(click(waiting, "pack", 3, "left", false, 10) == "clickSlot", "click: so that press and release is a click")

	-- A drag is not half of a double click.
	local double = SlotMouse.new()
	click(double, "pack", 3, "left", false, 10)
	press(double, "pack", 3, "left", true)
	enter(double, "pack", 4)
	release(double, "left", at("pack", 4))
	check(double.lastPlainLeft == nil, "release: a drag forgets the click before it")
	check(
		click(double, "pack", 3, "left", false, 10.1) == "clickSlot",
		"click: so a click straight after a drag is not a double click"
	)

	-- A press and a release on one slot with a stack carried is a click, whichever is reported first.
	local before = SlotMouse.new()
	press(before, "pack", 3, "left", true)
	check(
		click(before, "pack", 3, "left", false, 10) == "clickSlot",
		"click: a press on one slot is a click, also when the click is reported before the release"
	)
	check(release(before, "left", at("pack", 3)) == nil, "release: and the release ends no drag")
	check(before.endedDragOn == nil, "release: nor does it wait for a click")

	-- A press that never became a drag leaves the click before it remembered.
	local quick = SlotMouse.new()
	click(quick, "pack", 3, "left", false, 10)
	press(quick, "pack", 3, "left", true)
	release(quick, "left", at("pack", 3))
	check(
		click(quick, "pack", 3, "left", false, 10.2) == "doubleClickSlot",
		"click: a press and release on one slot, with a stack carried, can still be the second half of a double click"
	)
end

do -- forgetting
	local mouse = SlotMouse.new()
	click(mouse, "pack", 3, "left", false, 10)
	check(
		mouse.lastPlainLeft ~= nil and mouse.lastPlainLeft.slot == 3 and mouse.lastPlainLeft.at == 10,
		"click: a plain left click is remembered"
	)
	SlotMouse.forget(mouse)
	check(mouse.lastPlainLeft == nil, "forget: no click is remembered")
	check(click(mouse, "pack", 3, "left", false, 10.1) == "clickSlot", "forget: so the next click is a first click")

	press(mouse, "pack", 3, "left", true)
	enter(mouse, "pack", 4)
	SlotMouse.forget(mouse)
	check(mouse.pressed == nil and release(mouse, "left") == nil, "forget: a drag in progress is forgotten")

	press(mouse, "pack", 3, "left", true)
	enter(mouse, "pack", 4)
	release(mouse, "left", at("pack", 3))
	SlotMouse.forget(mouse)
	check(mouse.endedDragOn == nil, "forget: and so is a drag that has just ended where it began")
	check(click(mouse, "pack", 3, "left", false, 20) == "clickSlot", "forget: so the next click is a click")
	SlotMouse.forget(SlotMouse.new())
end

Check.finish("SlotMouse")
