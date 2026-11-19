--!strict
-- Tests for SlotClicks. Run from the repository root: lune run tests/inventory/SlotClicks.test.luau

local Check = require("../Check")
local SlotClicks = require("../../src/shared/inventory/SlotClicks")

local check = Check.that
local read = SlotClicks.read

do -- the rules as numbers
	check(SlotClicks.DOUBLE_CLICK_SECONDS == 0.4, "a double click is two clicks within four tenths of a second")
end

do -- ordinary clicks
	local clicks = SlotClicks.new()
	check(clicks.lastPlainLeft == nil, "new: nothing is remembered")
	check(read(clicks, "pack", 3, "left", false, 10) == "clickSlot", "read: a first left click is a click")
	check(read(clicks, "pack", 3, "right", false, 10.1) == "clickSlot", "read: a right click is a click")
	check(read(clicks, "pack", 3, "right", false, 10.2) == "clickSlot", "read: two right clicks are two clicks")
	check(read(clicks, "pack", 3, "right", true, 10.3) == "clickSlot", "read: a right click with Shift held is a click")
end

do -- double clicks
	local clicks = SlotClicks.new()
	read(clicks, "pack", 3, "left", false, 10)
	check(
		read(clicks, "pack", 3, "left", false, 10.39) == "doubleClickSlot",
		"read: a second left click on the slot just in time is a double click"
	)
	check(
		read(clicks, "pack", 3, "left", false, 10.5) == "clickSlot",
		"read: a third quick click is a first click again"
	)
	check(read(clicks, "pack", 3, "left", false, 10.6) == "doubleClickSlot", "read: and a fourth is its double")

	local late = SlotClicks.new()
	read(late, "pack", 3, "left", false, 0)
	check(
		read(late, "pack", 3, "left", false, SlotClicks.DOUBLE_CLICK_SECONDS) == "clickSlot",
		"read: a second click exactly four tenths later is too late"
	)
	check(
		read(late, "pack", 3, "left", false, SlotClicks.DOUBLE_CLICK_SECONDS + 0.3) == "doubleClickSlot",
		"read: but it can itself begin a double click"
	)

	local elsewhere = SlotClicks.new()
	read(elsewhere, "pack", 3, "left", false, 10)
	check(
		read(elsewhere, "pack", 4, "left", false, 10.1) == "clickSlot",
		"read: a click on another slot is not a double click"
	)
	check(
		read(elsewhere, "other", 4, "left", false, 10.2) == "clickSlot",
		"read: nor is one on the same slot number of the other side"
	)
	check(
		read(elsewhere, "other", 4, "left", false, 10.3) == "doubleClickSlot",
		"read: each click is measured against the one before it"
	)

	local mixed = SlotClicks.new()
	read(mixed, "pack", 3, "left", false, 10)
	read(mixed, "pack", 3, "right", false, 10.1)
	check(
		read(mixed, "pack", 3, "left", false, 10.2) == "clickSlot",
		"read: a right click in between breaks a double click"
	)
end

do -- Shift and a click
	local clicks = SlotClicks.new()
	check(
		read(clicks, "pack", 3, "left", true, 10) == "quickMoveSlot",
		"read: a left click with Shift held is a quick move"
	)
	check(read(clicks, "pack", 3, "left", true, 10.1) == "quickMoveSlot", "read: and so is the next one, however soon")
	check(clicks.lastPlainLeft == nil, "read: a Shift and click is not remembered")
	check(
		read(clicks, "pack", 3, "left", false, 10.2) == "clickSlot",
		"read: a plain click straight after a Shift and click is a click, not a double click"
	)

	local between = SlotClicks.new()
	read(between, "pack", 3, "left", false, 10)
	read(between, "pack", 3, "left", true, 10.1)
	check(
		read(between, "pack", 3, "left", false, 10.2) == "clickSlot",
		"read: a Shift and click in between breaks a double click"
	)
end

do -- forgetting
	local clicks = SlotClicks.new()
	read(clicks, "pack", 3, "left", false, 10)
	check(
		clicks.lastPlainLeft ~= nil and clicks.lastPlainLeft.slot == 3 and clicks.lastPlainLeft.at == 10,
		"read: a plain left click is remembered"
	)
	SlotClicks.forget(clicks)
	check(clicks.lastPlainLeft == nil, "forget: nothing is remembered")
	check(read(clicks, "pack", 3, "left", false, 10.1) == "clickSlot", "forget: so the next click is a first click")
	SlotClicks.forget(SlotClicks.new())
end

Check.finish("SlotClicks")
