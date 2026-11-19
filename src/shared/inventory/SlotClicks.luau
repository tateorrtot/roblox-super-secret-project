--!strict
--[=[
	Works out what a mouse click on a slot of the inventory screen asks for:
	an ordinary click, a double click, or a Shift and click.

	A player's machine tells the server about each click with one of three
	requests, and [method read] says which:
	- `"quickMoveSlot"` for a left click with Shift held;
	- `"doubleClickSlot"` for the second of two plain left clicks on the same
	  slot within `SlotClicks.DOUBLE_CLICK_SECONDS`;
	- `"clickSlot"` for every other click.

	To tell a double click, it remembers the last plain left click: which
	slot, and when. A Shift and click is never half of a double click, and
	nor is a right click. After a double click the memory is empty, so a
	third quick click is a first click again.

	Time is a number of seconds, from any clock that only goes forward.

	```lua
	local slotClicks = SlotClicks.new()
	SlotClicks.read(slotClicks, "pack", 3, "left", false, 10.0) --> "clickSlot"
	SlotClicks.read(slotClicks, "pack", 3, "left", false, 10.2) --> "doubleClickSlot"
	SlotClicks.read(slotClicks, "pack", 3, "left", true, 10.3) --> "quickMoveSlot"
	```
]=]
local SlotClicks = {}

--- The request a click makes.
export type Request = "clickSlot" | "doubleClickSlot" | "quickMoveSlot"

--- `read` means code outside this module cannot assign the field. [method read] and [method forget] change it.
export type SlotClicks = {
	--- The last plain left click, or `nil` if there has been none that could still begin a double click.
	read lastPlainLeft: { read side: string, read slot: number, read at: number }?,
}

--- How soon a second plain left click on a slot must follow the first to make a double click, in seconds.
SlotClicks.DOUBLE_CLICK_SECONDS = 0.4

--[=[
	Returns a new memory of clicks, with nothing remembered.
]=]
function SlotClicks.new(): SlotClicks
	return {}
end

--[=[
	Returns the request that a click makes, and remembers the click if it
	could be the first half of a double click.

	`side` and `slot` say which slot was clicked, `button` is `"left"` or
	`"right"`, `shiftHeld` is whether a Shift key was down, and `now` is the
	time of the click.
]=]
function SlotClicks.read(
	slotClicks: SlotClicks,
	side: string,
	slot: number,
	button: string,
	shiftHeld: boolean,
	now: number
): Request
	local writable = slotClicks :: any
	local isPlainLeft = button == "left" and not shiftHeld
	local last = slotClicks.lastPlainLeft
	local isDouble = isPlainLeft
		and last ~= nil
		and last.side == side
		and last.slot == slot
		and now - last.at < SlotClicks.DOUBLE_CLICK_SECONDS
	writable.lastPlainLeft = if isPlainLeft and not isDouble then { side = side, slot = slot, at = now } else nil
	if isDouble then
		return "doubleClickSlot"
	elseif button == "left" and shiftHeld then
		return "quickMoveSlot"
	end
	return "clickSlot"
end

--[=[
	Forgets the last click, as when the inventory screen closes: the next
	click is a first click.
]=]
function SlotClicks.forget(slotClicks: SlotClicks)
	(slotClicks :: any).lastPlainLeft = nil
end

return SlotClicks
