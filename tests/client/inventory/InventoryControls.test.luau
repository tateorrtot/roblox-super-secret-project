--!strict
-- Tests for InventoryControls. Run from the repository root: lune run tests/client/inventory/InventoryControls.test.luau

local Check = require("../../Check")
local Inventory = require("../../../src/shared/inventory/Inventory")
local InventoryControls = require("../../../src/client/inventory/InventoryControls")
local InventoryScreen = require("../../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../../src/shared/items/ItemRegistry")
local ItemStack = require("../../../src/shared/items/ItemStack")
local PlayerState = require("../../../src/shared/players/PlayerState")
local Plot = require("../../../src/shared/plots/Plot")
local Position = require("../../../src/shared/Position")
local Requests = require("../../../src/shared/requests/Requests")
local SlotGestures = require("../../../src/client/inventory/SlotGestures")
local World = require("../../../src/shared/world/World")

local check = Check.that

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "stone", stackSize = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })

type Slot = SlotGestures.Slot
type Screen = InventoryControls.Screen
type Request = InventoryControls.Request

-- Names a slot of the screen.
local function at(side: string, slot: number): Slot
	return { side = side, slot = slot }
end

-- Describes a request such as `moveFromSlotToInventory("pack", 3, "other", 1, 27)`, with "nil" for a missing argument
-- and "none" for no request. The arguments are counted up to `argumentCount`, so that a missing last
-- argument is not hidden.
local function describe(request: Request?, argumentCount: number): string
	if request == nil then
		return "none"
	end
	local parts = {}
	for index = 1, argumentCount do
		local argument = request.arguments[index]
		table.insert(parts, if argument == nil then "nil" else tostring(argument))
	end
	return request.name .. "(" .. table.concat(parts, ", ") .. ")"
end

-- Returns a gesture as SlotGestures would, for the test of what the controls ask for.
local function gestureOf(
	kind: "click" | "doubleClick" | "drag",
	button: SlotGestures.Button,
	shiftHeld: boolean,
	slots: { Slot },
	releasedOn: Slot?
): SlotGestures.Gesture
	return { kind = kind, button = button, shiftHeld = shiftHeld, slots = slots, releasedOn = releasedOn }
end

-- Returns a screen with the stacks that `held` names, by "side slot", such as `{ ["pack 3"] = "log 5" }`.
local function screenOf(
	held: { [string]: string },
	carried: string?,
	otherSlotCount: number?,
	packSlotCount: number?,
	hotbarSlotCount: number?
): Screen
	local function stackOf(text: string?): InventoryControls.Stack?
		if text == nil then
			return nil
		end
		local itemId, count = string.match(text, "^(%S+) (%d+)$")
		assert(itemId and count, "bad test stack: " .. text)
		return { itemId = itemId, count = tonumber(count) :: number }
	end
	return {
		packSlotCount = packSlotCount or 36,
		hotbarSlotCount = hotbarSlotCount or 9,
		otherSlotCount = otherSlotCount,
		carriedStack = stackOf(carried),
		getStack = function(slot: Slot): InventoryControls.Stack?
			return stackOf(held[slot.side .. " " .. slot.slot])
		end,
	}
end

local function click(button: SlotGestures.Button, slot: Slot, shiftHeld: boolean?): SlotGestures.Gesture
	return gestureOf("click", button, shiftHeld == true, { slot }, slot)
end

do -- a click with nothing carried
	local screen = screenOf({ ["pack 3"] = "log 5", ["pack 4"] = "log 1", ["other 2"] = "stone 8" }, nil, 27)
	check(
		describe(InventoryControls.getRequestForGesture(screen, click("left", at("pack", 3))), 3)
			== "pickUpFromSlot(pack, 3, nil)",
		"getRequestForGesture: a left click on a stack, with nothing carried, picks up all of it"
	)
	check(
		describe(InventoryControls.getRequestForGesture(screen, click("right", at("pack", 3))), 3)
			== "pickUpFromSlot(pack, 3, 3)",
		"getRequestForGesture: a right click on a stack of 5, with nothing carried, picks up the larger half, 3"
	)
	check(
		describe(InventoryControls.getRequestForGesture(screen, click("right", at("pack", 4))), 3)
			== "pickUpFromSlot(pack, 4, 1)",
		"getRequestForGesture: a right click on a stack of 1 picks up that 1"
	)
	check(
		describe(InventoryControls.getRequestForGesture(screen, click("right", at("other", 2))), 3)
			== "pickUpFromSlot(other, 2, 4)",
		"getRequestForGesture: a right click on a stack of 8 picks up 4, and names the other inventory's slot"
	)
	check(
		describe(InventoryControls.getRequestForGesture(screen, click("left", at("other", 2))), 3)
			== "pickUpFromSlot(other, 2, nil)",
		"getRequestForGesture: a left click on the other inventory's stack picks up all of it"
	)
	check(
		InventoryControls.getRequestForGesture(screen, click("left", at("pack", 5))) == nil,
		"getRequestForGesture: a left click on a slot that holds nothing, with nothing carried, asks for nothing"
	)
	check(
		InventoryControls.getRequestForGesture(screen, click("right", at("pack", 5))) == nil,
		"getRequestForGesture: nor does a right click on a slot that holds nothing"
	)
end

do -- a click with a stack carried
	local screen = screenOf({ ["pack 3"] = "log 5", ["pack 4"] = "stone 2", ["other 2"] = "log 1" }, "log 7", 27)
	check(
		describe(InventoryControls.getRequestForGesture(screen, click("left", at("pack", 6))), 3)
			== "putDownInSlot(pack, 6, nil)",
		"getRequestForGesture: a left click on a slot that holds nothing, with a stack carried, puts all of it down"
	)
	check(
		describe(InventoryControls.getRequestForGesture(screen, click("right", at("pack", 6))), 3)
			== "putDownInSlot(pack, 6, 1)",
		"getRequestForGesture: a right click on a slot that holds nothing puts one down"
	)
	check(
		describe(InventoryControls.getRequestForGesture(screen, click("left", at("pack", 3))), 3)
			== "putDownInSlot(pack, 3, nil)",
		"getRequestForGesture: a left click on a slot that holds the carried item puts all of it down"
	)
	check(
		describe(InventoryControls.getRequestForGesture(screen, click("right", at("other", 2))), 3)
			== "putDownInSlot(other, 2, 1)",
		"getRequestForGesture: a right click on a slot of the other inventory that holds the carried item puts one down"
	)
	check(
		describe(InventoryControls.getRequestForGesture(screen, click("left", at("pack", 4))), 2)
			== "swapCarriedStackWithSlot(pack, 4)",
		"getRequestForGesture: a left click on a slot that holds a different item exchanges the two stacks"
	)
	check(
		describe(InventoryControls.getRequestForGesture(screen, click("right", at("pack", 4))), 2)
			== "swapCarriedStackWithSlot(pack, 4)",
		"getRequestForGesture: and so does a right click"
	)
	check(
		#(InventoryControls.getRequestForGesture(screen, click("left", at("pack", 4))) :: Request).arguments == 2,
		"getRequestForGesture: and an exchange is sent with the side and slot only"
	)
end

do -- Shift and a click
	local withOther = screenOf({ ["pack 3"] = "log 5", ["pack 20"] = "log 5", ["other 2"] = "stone 8" }, nil, 27)
	check(
		describe(InventoryControls.getRequestForGesture(withOther, click("left", at("pack", 3), true)), 6)
			== "moveFromSlotToInventory(pack, 3, other, 1, 27, nil)",
		"getRequestForGesture: a left click with Shift held, with another inventory open, moves a pack stack to all of its slots"
	)
	check(
		describe(InventoryControls.getRequestForGesture(withOther, click("left", at("other", 2), true)), 6)
			== "moveFromSlotToInventory(other, 2, pack, 1, 36, nil)",
		"getRequestForGesture: and moves a stack of the other inventory to all of the pack's slots"
	)
	local small = screenOf({}, nil, 3, 20, 5)
	check(
		describe(InventoryControls.getRequestForGesture(small, click("left", at("pack", 20), true)), 5)
			== "moveFromSlotToInventory(pack, 20, other, 1, 3)",
		"getRequestForGesture: the last slot named is the size of the other inventory"
	)
	check(
		describe(InventoryControls.getRequestForGesture(small, click("left", at("other", 1), true)), 5)
			== "moveFromSlotToInventory(other, 1, pack, 1, 20)",
		"getRequestForGesture: and the size of the pack when going the other way"
	)

	local alone = screenOf({ ["pack 3"] = "log 5", ["pack 20"] = "log 5" }, nil, nil)
	check(
		describe(InventoryControls.getRequestForGesture(alone, click("left", at("pack", 3), true)), 5)
			== "moveFromSlotToInventory(pack, 3, pack, 10, 36)",
		"getRequestForGesture: with the pack open alone, a left click with Shift held on a hotbar slot moves the stack to the rest of the pack"
	)
	check(
		describe(InventoryControls.getRequestForGesture(alone, click("left", at("pack", 9), true)), 5)
			== "moveFromSlotToInventory(pack, 9, pack, 10, 36)",
		"getRequestForGesture: the last hotbar slot is a hotbar slot"
	)
	check(
		describe(InventoryControls.getRequestForGesture(alone, click("left", at("pack", 20), true)), 5)
			== "moveFromSlotToInventory(pack, 20, pack, 1, 9)",
		"getRequestForGesture: and on a slot of the rest of the pack moves it to the hotbar"
	)
	check(
		describe(InventoryControls.getRequestForGesture(alone, click("left", at("pack", 10), true)), 5)
			== "moveFromSlotToInventory(pack, 10, pack, 1, 9)",
		"getRequestForGesture: the first slot after the hotbar is not a hotbar slot"
	)

	local allHotbar = screenOf({ ["pack 1"] = "log 5" }, nil, nil, 9, 9)
	check(
		InventoryControls.getRequestForGesture(allHotbar, click("left", at("pack", 1), true)) == nil,
		"getRequestForGesture: with a pack that is all hotbar and no other inventory open, there is nowhere to move to and it asks for nothing"
	)

	check(
		describe(InventoryControls.getRequestForGesture(withOther, click("right", at("pack", 3), true)), 3)
			== "pickUpFromSlot(pack, 3, 3)",
		"getRequestForGesture: a right click with Shift held is a right click"
	)

	local carrying = screenOf({ ["pack 3"] = "log 5" }, "log 2", 27)
	check(
		describe(InventoryControls.getRequestForGesture(carrying, click("left", at("pack", 3), true)), 3) ~= "none",
		"getRequestForGesture: a left click with Shift held asks for a move whatever is carried"
	)
end

do -- a double click
	local screen = screenOf({ ["pack 3"] = "log 5", ["pack 4"] = "stone 2" }, "log 7", 27)
	local double = gestureOf("doubleClick", "left", false, { at("pack", 6) }, at("pack", 6))
	check(
		describe(InventoryControls.getRequestForGesture(screen, double), 1) == "fillCarriedStackFromAllSlots(nil)"
			and #(InventoryControls.getRequestForGesture(screen, double) :: Request).arguments == 0,
		"getRequestForGesture: a double click on a slot that holds nothing, with a stack carried, gathers into the carried stack, with nothing sent"
	)
	check(
		describe(
			InventoryControls.getRequestForGesture(
				screen,
				gestureOf("doubleClick", "left", false, { at("pack", 3) }, at("pack", 3))
			),
			3
		) == "putDownInSlot(pack, 3, nil)",
		"getRequestForGesture: a double click on a slot that holds the carried item is a left click"
	)
	check(
		describe(
			InventoryControls.getRequestForGesture(
				screen,
				gestureOf("doubleClick", "left", false, { at("pack", 4) }, at("pack", 4))
			),
			3
		) == "swapCarriedStackWithSlot(pack, 4, nil)",
		"getRequestForGesture: a double click on a slot that holds a different item is a left click"
	)

	local empty = screenOf({ ["pack 3"] = "log 5" }, nil, 27)
	check(
		describe(
			InventoryControls.getRequestForGesture(
				empty,
				gestureOf("doubleClick", "left", false, { at("pack", 3) }, at("pack", 3))
			),
			3
		) == "pickUpFromSlot(pack, 3, nil)",
		"getRequestForGesture: a double click with nothing carried is a left click"
	)
	check(
		InventoryControls.getRequestForGesture(
			empty,
			gestureOf("doubleClick", "left", false, { at("pack", 6) }, at("pack", 6))
		) == nil,
		"getRequestForGesture: a double click on a slot that holds nothing, with nothing carried, asks for nothing"
	)
end

do -- a drag
	local screen = screenOf({ ["pack 1"] = "log 5" }, "log 7", 27)
	local slots = { at("pack", 2), at("pack", 3), at("other", 1) }
	local left = InventoryControls.getRequestForGesture(screen, gestureOf("drag", "left", false, slots, at("other", 1)))
	check(
		left ~= nil and left.name == "spreadCarriedStackOverSlots",
		"getRequestForGesture: a drag with the left button, with a stack carried, spreads it in equal shares"
	)
	check(
		left ~= nil and left.arguments[1] == slots and left.arguments[2] == nil,
		"getRequestForGesture: and sends the slots crossed, and no count for each"
	)
	local right =
		InventoryControls.getRequestForGesture(screen, gestureOf("drag", "right", false, slots, at("other", 1)))
	check(
		right ~= nil
			and right.name == "spreadCarriedStackOverSlots"
			and right.arguments[1] == slots
			and right.arguments[2] == 1,
		"getRequestForGesture: a drag with the right button spreads it one item in each"
	)
	local over = InventoryControls.getRequestForGesture(screen, gestureOf("drag", "left", false, slots, nil))
	check(
		over ~= nil and over.name == "spreadCarriedStackOverSlots",
		"getRequestForGesture: a drag with a stack carried spreads it wherever the button comes up"
	)
	local shifted =
		InventoryControls.getRequestForGesture(screen, gestureOf("drag", "left", true, slots, at("other", 1)))
	check(
		shifted ~= nil and shifted.name == "spreadCarriedStackOverSlots",
		"getRequestForGesture: a drag with Shift held, with a stack carried, spreads it"
	)

	local nothing = screenOf({ ["pack 2"] = "log 5" }, nil, 27)
	local back = { at("pack", 2), at("pack", 3) }
	check(
		describe(
			InventoryControls.getRequestForGesture(nothing, gestureOf("drag", "left", false, back, at("pack", 2))),
			3
		) == "pickUpFromSlot(pack, 2, nil)",
		"getRequestForGesture: a drag with nothing carried that ends on the slot it began on is a left click"
	)
	check(
		describe(
			InventoryControls.getRequestForGesture(nothing, gestureOf("drag", "right", false, back, at("pack", 2))),
			3
		) == "pickUpFromSlot(pack, 2, 3)",
		"getRequestForGesture: and with the right button is a right click"
	)
	check(
		describe(
			InventoryControls.getRequestForGesture(nothing, gestureOf("drag", "left", true, back, at("pack", 2))),
			5
		) == "moveFromSlotToInventory(pack, 2, other, 1, 27)",
		"getRequestForGesture: and with Shift held is a click with Shift held"
	)
	check(
		InventoryControls.getRequestForGesture(nothing, gestureOf("drag", "left", false, back, at("pack", 3))) == nil,
		"getRequestForGesture: a drag with nothing carried that ends on another slot asks for nothing"
	)
	check(
		InventoryControls.getRequestForGesture(nothing, gestureOf("drag", "left", false, back, at("other", 2))) == nil,
		"getRequestForGesture: nor does one that ends on the same slot number of the other side"
	)
	check(
		InventoryControls.getRequestForGesture(nothing, gestureOf("drag", "left", false, back, nil)) == nil,
		"getRequestForGesture: nor does one that ends over no slot"
	)
	check(
		InventoryControls.getRequestForGesture(
			nothing,
			gestureOf("drag", "left", false, { at("other", 2), at("other", 1) }, at("other", 2))
		) == nil,
		"getRequestForGesture: a drag that ends on the slot it began on, where that slot holds nothing, asks for nothing"
	)
end

do -- getRequestForDigitKeyOverSlot
	check(
		describe(InventoryControls.getRequestForDigitKeyOverSlot(at("pack", 20), 3), 4)
			== "swapSlots(pack, 20, pack, 3)",
		"getRequestForDigitKeyOverSlot: a number key over a pack slot swaps it with the hotbar slot of that number"
	)
	check(
		describe(InventoryControls.getRequestForDigitKeyOverSlot(at("other", 5), 9), 4)
			== "swapSlots(other, 5, pack, 9)",
		"getRequestForDigitKeyOverSlot: over a slot of the other inventory swaps it with the pack's hotbar slot"
	)
	check(
		describe(InventoryControls.getRequestForDigitKeyOverSlot(at("pack", 1), 1), 4) == "swapSlots(pack, 1, pack, 1)",
		"getRequestForDigitKeyOverSlot: over a hotbar slot itself asks for the swap all the same"
	)
end

do -- getRequestForDropKeyOverSlot
	check(
		describe(InventoryControls.getRequestForDropKeyOverSlot(at("pack", 4), false), 3) == "dropFromSlot(pack, 4, 1)",
		"getRequestForDropKeyOverSlot: drops one item from the slot"
	)
	check(
		describe(InventoryControls.getRequestForDropKeyOverSlot(at("other", 7), true), 3)
			== "dropFromSlot(other, 7, nil)",
		"getRequestForDropKeyOverSlot: with the whole stack asked for, drops everything in the slot"
	)
end

do -- getRequestForOutsideClick
	check(
		describe(InventoryControls.getRequestForOutsideClick("left"), 1) == "dropCarriedStack(nil)",
		"getRequestForOutsideClick: a left click drops all of the carried stack"
	)
	check(
		describe(InventoryControls.getRequestForOutsideClick("right"), 1) == "dropCarriedStack(1)",
		"getRequestForOutsideClick: a right click drops one item of it"
	)
end

-- From here on the requests are carried out by the server's rules, to see what each gesture does.

local DROP_AT = Position.new(0, 0, 0)

-- Returns a new world with one player, id 1, who has an open screen. If `otherSlotCount` is given the
-- screen has another inventory of that size beside the pack.
local function openedWorld(otherSlotCount: number?): (World.World, PlayerState.PlayerState)
	local world = World.new(Plot.new(3, 3), DROP_AT, 0)
	local state = World.addPlayer(world, 1, DROP_AT)
	state.screen = InventoryScreen.new(state.pack, if otherSlotCount then Inventory.new(otherSlotCount) else nil)
	return world, state
end

-- Puts `text`, such as "log 5", in a slot of the screen.
local function put(state: PlayerState.PlayerState, side: string, slot: number, text: string)
	local screen = state.screen :: InventoryScreen.InventoryScreen
	local itemId, count = string.match(text, "^(%S+) (%d+)$")
	assert(itemId and count, "bad test stack: " .. text)
	Inventory.setStack(
		InventoryScreen.getInventoryOnSide(screen, side :: any),
		slot,
		ItemStack.new(itemId, tonumber(count) :: number)
	)
end

-- Describes what a slot of the screen holds, such as "log 5" or "-".
local function held(state: PlayerState.PlayerState, side: string, slot: number): string
	local screen = state.screen :: InventoryScreen.InventoryScreen
	local stack = Inventory.getStack(InventoryScreen.getInventoryOnSide(screen, side :: any), slot)
	return if stack then stack.itemId .. " " .. stack.count else "-"
end

-- Describes what the player carries, such as "log 5" or "-".
local function carriedBy(state: PlayerState.PlayerState): string
	local screen = state.screen :: InventoryScreen.InventoryScreen
	return if screen.carriedStack then screen.carriedStack.itemId .. " " .. screen.carriedStack.count else "-"
end

-- Describes what lies on the ground, such as "log 3" or "-". Items of one kind are added together.
local function onGround(world: World.World): string
	local totals: { [string]: number } = {}
	for _, groundItem in world.groundItems.itemsById do
		totals[groundItem.stack.itemId] = (totals[groundItem.stack.itemId] or 0) + groundItem.stack.count
	end
	local parts = {}
	for itemId, count in totals do
		table.insert(parts, itemId .. " " .. count)
	end
	table.sort(parts)
	return if #parts == 0 then "-" else table.concat(parts, ", ")
end

-- What the controls need to know of a player's open screen.
local function screenOfPlayer(state: PlayerState.PlayerState): Screen
	local screen = state.screen :: InventoryScreen.InventoryScreen
	return {
		packSlotCount = screen.pack.slotCount,
		hotbarSlotCount = PlayerState.HOTBAR_SLOT_COUNT,
		otherSlotCount = if screen.otherInventory then screen.otherInventory.slotCount else nil,
		carriedStack = screen.carriedStack,
		getStack = function(slot: Slot): InventoryControls.Stack?
			return Inventory.getStack(InventoryScreen.getInventoryOnSide(screen, slot.side :: any), slot.slot)
		end,
	}
end

-- Sends a request to the world as the server receives it.
local function send(world: World.World, request: Request?)
	if request ~= nil then
		Requests.carryOut(world, 1, request.name, table.unpack(request.arguments, 1, 7))
	end
end

-- Does what the player's controls do for `gesture`, and returns the request it asked for.
local function perform(world: World.World, state: PlayerState.PlayerState, gesture: SlotGestures.Gesture): Request?
	local request = InventoryControls.getRequestForGesture(screenOfPlayer(state), gesture)
	send(world, request)
	return request
end

-- Moves the mouse as the screen reports it: presses `button` on the first of `slots`, comes onto
-- each of the others, and lets go on the last. Returns the request that was carried out, if any.
local function mouse(
	world: World.World,
	state: PlayerState.PlayerState,
	gestures: SlotGestures.SlotGestures,
	button: SlotGestures.Button,
	slots: { Slot },
	shiftHeld: boolean?,
	now: number?
): Request?
	SlotGestures.beginGesture(gestures, button, slots[1])
	for index = 2, #slots do
		SlotGestures.dragOverSlot(gestures, slots[index])
	end
	local gesture = SlotGestures.endGesture(gestures, button, slots[#slots], shiftHeld == true, now or 0)
	if gesture == nil then
		return nil
	end
	return perform(world, state, gesture)
end

do -- picking up and putting down
	local world, state = openedWorld(nil)
	local gestures = SlotGestures.new()
	put(state, "pack", 1, "log 5")
	mouse(world, state, gestures, "left", { at("pack", 1) })
	check(carriedBy(state) == "log 5" and held(state, "pack", 1) == "-", "a left click on a stack carries all of it")
	mouse(world, state, gestures, "left", { at("pack", 12) })
	check(
		carriedBy(state) == "-" and held(state, "pack", 12) == "log 5",
		"a left click on an empty slot puts it all down"
	)

	mouse(world, state, gestures, "right", { at("pack", 12) })
	check(
		carriedBy(state) == "log 3" and held(state, "pack", 12) == "log 2",
		"a right click on a stack of 5 carries 3 and leaves 2"
	)
	mouse(world, state, gestures, "right", { at("pack", 13) })
	check(
		carriedBy(state) == "log 2" and held(state, "pack", 13) == "log 1",
		"a right click on an empty slot, with a stack carried, puts one down"
	)
	mouse(world, state, gestures, "right", { at("pack", 13) })
	check(
		carriedBy(state) == "log 1" and held(state, "pack", 13) == "log 2",
		"a right click on a slot of the same item puts one more down"
	)

	put(state, "pack", 14, "stone 4")
	mouse(world, state, gestures, "left", { at("pack", 14) })
	check(
		carriedBy(state) == "stone 4" and held(state, "pack", 14) == "log 1",
		"a left click on a slot of another item exchanges the stacks"
	)
	mouse(world, state, gestures, "right", { at("pack", 14) })
	check(carriedBy(state) == "log 1" and held(state, "pack", 14) == "stone 4", "and so does a right click")

	put(state, "pack", 15, "log 15")
	mouse(world, state, gestures, "left", { at("pack", 15) })
	check(
		carriedBy(state) == "-" and held(state, "pack", 15) == "log 16",
		"a left click on a stack of the carried item adds the carried stack to it, up to the stack size"
	)
	check(onGround(world) == "-", "none of this puts anything on the ground")
end

do -- the carried stack with nothing under it
	local world, state = openedWorld(nil)
	local gestures = SlotGestures.new()
	check(
		mouse(world, state, gestures, "left", { at("pack", 1) }) == nil and carriedBy(state) == "-",
		"a click on an empty slot with nothing carried does nothing"
	)
end

do -- Shift and a click
	local world, state = openedWorld(27)
	local gestures = SlotGestures.new()
	put(state, "pack", 20, "log 5")
	put(state, "other", 1, "log 14")
	put(state, "other", 3, "stone 2")
	mouse(world, state, gestures, "left", { at("pack", 20) }, true)
	check(
		held(state, "pack", 20) == "-" and held(state, "other", 1) == "log 16" and held(state, "other", 2) == "log 3",
		"a left click with Shift held on a pack stack tops up the other inventory's stack and then fills an empty slot"
	)
	mouse(world, state, gestures, "left", { at("other", 3) }, true)
	check(
		held(state, "other", 3) == "-" and held(state, "pack", 1) == "stone 2",
		"a left click with Shift held on a stack of the other inventory moves it to the first free slot of the pack"
	)
	put(state, "pack", 5, "log 4")
	mouse(world, state, gestures, "left", { at("other", 2) }, true)
	check(
		held(state, "other", 2) == "-" and held(state, "pack", 5) == "log 7",
		"and tops up a stack of the same item in the pack first"
	)
	check(carriedBy(state) == "-", "and carries nothing")

	local fullWorld, fullState = openedWorld(2)
	local fullGestures = SlotGestures.new()
	put(fullState, "other", 1, "stone 1")
	put(fullState, "other", 2, "stone 1")
	put(fullState, "pack", 3, "log 5")
	mouse(fullWorld, fullState, fullGestures, "left", { at("pack", 3) }, true)
	check(
		held(fullState, "pack", 3) == "log 5",
		"a Shift and click with no room in the other inventory leaves the stack where it was"
	)
end

do -- Shift and a click with the pack alone
	local world, state = openedWorld(nil)
	local gestures = SlotGestures.new()
	put(state, "pack", 2, "log 5")
	mouse(world, state, gestures, "left", { at("pack", 2) }, true)
	check(
		held(state, "pack", 2) == "-" and held(state, "pack", 10) == "log 5",
		"a Shift and click on a hotbar slot moves the stack to the first slot after the hotbar"
	)
	mouse(world, state, gestures, "left", { at("pack", 10) }, true)
	check(
		held(state, "pack", 10) == "-" and held(state, "pack", 1) == "log 5",
		"and one on a slot after the hotbar moves it to the first free hotbar slot"
	)
	put(state, "pack", 9, "log 8")
	mouse(world, state, gestures, "left", { at("pack", 9) }, true)
	check(
		held(state, "pack", 9) == "-" and held(state, "pack", 10) == "log 8",
		"a Shift and click on the last hotbar slot moves it past the hotbar"
	)
	put(state, "pack", 1, "log 10")
	put(state, "pack", 11, "log 10")
	mouse(world, state, gestures, "left", { at("pack", 11) }, true)
	check(
		held(state, "pack", 1) == "log 16" and held(state, "pack", 11) == "-" and held(state, "pack", 2) == "log 4",
		"a Shift and click tops up a stack of the same item in the hotbar first, then fills the next free hotbar slot"
	)
end

do -- a double click gathers
	local world, state = openedWorld(3)
	local gestures = SlotGestures.new()
	put(state, "pack", 1, "log 4")
	put(state, "pack", 2, "log 3")
	put(state, "pack", 5, "stone 2")
	put(state, "pack", 7, "log 16")
	put(state, "other", 2, "log 2")
	mouse(world, state, gestures, "left", { at("pack", 1) }, nil, 10)
	check(carriedBy(state) == "log 4", "the first click of a double click carries the stack")
	local request = mouse(world, state, gestures, "left", { at("pack", 1) }, nil, 10.2)
	check(
		request ~= nil and request.name == "fillCarriedStackFromAllSlots",
		"the second click of a double click on the emptied slot asks to gather"
	)
	check(carriedBy(state) == "log 16", "the carried stack is filled from the others")
	check(
		held(state, "other", 2) == "-" and held(state, "pack", 2) == "-",
		"the partial stacks are taken from first, whichever inventory they are in"
	)
	check(held(state, "pack", 7) == "log 9", "and then a full stack gives what is still needed")
	check(held(state, "pack", 5) == "stone 2", "an item of another kind is left alone")
	check(onGround(world) == "-", "nothing is dropped")

	local next = mouse(world, state, gestures, "left", { at("pack", 1) }, nil, 10.3)
	check(
		next ~= nil and next.name == "putDownInSlot",
		"a third click straight after is a first click again, and puts the stack down"
	)
	check(
		held(state, "pack", 1) == "log 16" and carriedBy(state) == "-",
		"and the whole carried stack lands in the slot"
	)

	local plainWorld, plainState = openedWorld(nil)
	local plainGestures = SlotGestures.new()
	put(plainState, "pack", 1, "log 4")
	put(plainState, "pack", 2, "log 3")
	mouse(plainWorld, plainState, plainGestures, "left", { at("pack", 6) }, nil, 10)
	mouse(plainWorld, plainState, plainGestures, "left", { at("pack", 6) }, nil, 10.1)
	check(
		held(plainState, "pack", 1) == "log 4" and held(plainState, "pack", 2) == "log 3",
		"a double click on an empty slot, with nothing carried, takes nothing"
	)
end

do -- dragging a carried stack across slots
	local world, state = openedWorld(4)
	local gestures = SlotGestures.new()
	put(state, "pack", 1, "log 7")
	mouse(world, state, gestures, "left", { at("pack", 1) })
	mouse(world, state, gestures, "left", { at("pack", 10), at("pack", 11), at("pack", 12) })
	check(
		held(state, "pack", 10) == "log 2" and held(state, "pack", 11) == "log 2" and held(state, "pack", 12) == "log 2",
		"a drag with the left button over three empty slots puts an equal share in each"
	)
	check(carriedBy(state) == "log 1", "and what does not divide stays carried")

	mouse(world, state, gestures, "right", { at("pack", 13) })
	check(carriedBy(state) == "-" and held(state, "pack", 13) == "log 1", "a right click puts the last one down")

	mouse(world, state, gestures, "left", { at("pack", 10) })
	check(carriedBy(state) == "log 2", "a stack is carried again")
	mouse(world, state, gestures, "right", { at("pack", 14), at("other", 1), at("pack", 15) })
	check(
		held(state, "pack", 14) == "log 1" and held(state, "other", 1) == "log 1" and carriedBy(state) == "-",
		"a drag with the right button puts one item in each slot, until the carried stack is gone"
	)
	check(held(state, "pack", 15) == "-", "and no more slots take part than there are items carried")

	mouse(world, state, gestures, "left", { at("pack", 11) })
	check(carriedBy(state) == "log 2", "a stack of 2 is carried")
	mouse(world, state, gestures, "left", { at("pack", 20), at("pack", 21), at("pack", 20) })
	check(
		held(state, "pack", 20) == "log 1" and held(state, "pack", 21) == "log 1" and carriedBy(state) == "-",
		"a slot crossed twice gets one share"
	)

	mouse(world, state, gestures, "left", { at("pack", 20) })
	put(state, "pack", 22, "stone 3")
	mouse(world, state, gestures, "left", { at("pack", 23), at("pack", 22), at("pack", 24) })
	check(
		held(state, "pack", 22) == "stone 3" and held(state, "pack", 23) == "log 1" and held(state, "pack", 24) == "-",
		"a slot that holds another item is not given a share and keeps what it holds"
	)
end

do -- a drag with nothing carried
	local world, state = openedWorld(nil)
	local gestures = SlotGestures.new()
	put(state, "pack", 1, "log 7")
	local request = mouse(world, state, gestures, "left", { at("pack", 1), at("pack", 2) })
	check(request == nil, "a drag with nothing carried that ends on another slot asks for nothing")
	check(held(state, "pack", 1) == "log 7" and carriedBy(state) == "-", "and changes nothing")
	local back = mouse(world, state, gestures, "left", { at("pack", 1), at("pack", 2), at("pack", 1) })
	check(back ~= nil and back.name == "pickUpFromSlot", "a drag that comes back to the slot it began on is a click")
	check(carriedBy(state) == "log 7", "and picks the stack up")
end

do -- a number key
	local world, state = openedWorld(5)
	put(state, "pack", 20, "stone 3")
	put(state, "pack", 3, "log 4")
	send(world, InventoryControls.getRequestForDigitKeyOverSlot(at("pack", 20), 3))
	check(
		held(state, "pack", 20) == "log 4" and held(state, "pack", 3) == "stone 3",
		"a number key swaps a pack slot with that hotbar slot"
	)
	put(state, "other", 2, "fish 2")
	send(world, InventoryControls.getRequestForDigitKeyOverSlot(at("other", 2), 3))
	check(
		held(state, "other", 2) == "stone 3" and held(state, "pack", 3) == "fish 2",
		"and a slot of the other inventory with it"
	)
	send(world, InventoryControls.getRequestForDigitKeyOverSlot(at("pack", 9), 9))
	check(held(state, "pack", 9) == "-", "a number key over the hotbar slot of its own number changes nothing")
end

do -- the drop key and a click outside
	local world, state = openedWorld(nil)
	put(state, "pack", 4, "log 5")
	send(world, InventoryControls.getRequestForDropKeyOverSlot(at("pack", 4), false))
	check(held(state, "pack", 4) == "log 4" and onGround(world) == "log 1", "the drop key drops one item of the slot")
	send(world, InventoryControls.getRequestForDropKeyOverSlot(at("pack", 4), true))
	check(
		held(state, "pack", 4) == "-" and onGround(world) == "log 5",
		"the drop key with the whole stack asked for drops all of it"
	)
	send(world, InventoryControls.getRequestForDropKeyOverSlot(at("pack", 4), false))
	check(onGround(world) == "log 5", "the drop key over an empty slot drops nothing")

	put(state, "pack", 6, "stone 6")
	local gestures = SlotGestures.new()
	mouse(world, state, gestures, "left", { at("pack", 6) })
	send(world, InventoryControls.getRequestForOutsideClick("right"))
	check(
		carriedBy(state) == "stone 5" and onGround(world) == "log 5, stone 1",
		"a right click outside the screen drops one item of the carried stack"
	)
	send(world, InventoryControls.getRequestForOutsideClick("left"))
	check(
		carriedBy(state) == "-" and onGround(world) == "log 5, stone 6",
		"a left click outside the screen drops all of it"
	)
	send(world, InventoryControls.getRequestForOutsideClick("left"))
	check(onGround(world) == "log 5, stone 6", "a click outside the screen with nothing carried drops nothing")
end

do -- every request the controls make is one the server knows
	local screen = screenOf({ ["pack 3"] = "log 5", ["pack 4"] = "stone 2" }, "log 7", 27)
	local names: { [string]: boolean } = {}
	for _, name in Requests.NAMES do
		names[name] = true
	end
	local requests: { Request? } = {
		InventoryControls.getRequestForGesture(screen, click("left", at("pack", 3))),
		InventoryControls.getRequestForGesture(screen, click("left", at("pack", 4))),
		InventoryControls.getRequestForGesture(screen, click("left", at("pack", 3), true)),
		InventoryControls.getRequestForGesture(
			screen,
			gestureOf("doubleClick", "left", false, { at("pack", 6) }, at("pack", 6))
		),
		InventoryControls.getRequestForGesture(
			screen,
			gestureOf("drag", "left", false, { at("pack", 6), at("pack", 7) }, nil)
		),
		InventoryControls.getRequestForDigitKeyOverSlot(at("pack", 3), 2),
		InventoryControls.getRequestForDropKeyOverSlot(at("pack", 3), true),
		InventoryControls.getRequestForOutsideClick("left"),
		InventoryControls.getRequestForGesture(
			screenOf({ ["pack 3"] = "log 5" }, nil, 27),
			click("left", at("pack", 3))
		),
	}
	for _, request in requests do
		check(
			request ~= nil and names[request.name] == true,
			"every request the controls make is named in Requests.NAMES"
		)
	end
end

-- Every item in one player's screen and on the ground, counted by kind, such as "log 12, stone 3".
local function everything(world: World.World, state: PlayerState.PlayerState): string
	local totals: { [string]: number } = {}
	local screen = state.screen :: InventoryScreen.InventoryScreen
	local function add(stack: ItemStack.ItemStack?)
		if stack then
			totals[stack.itemId] = (totals[stack.itemId] or 0) + stack.count
		end
	end
	for _, inventory in { screen.pack, screen.otherInventory } do
		for slot = 1, inventory.slotCount do
			add(Inventory.getStack(inventory, slot))
		end
	end
	add(screen.carriedStack)
	for _, groundItem in world.groundItems.itemsById do
		add(groundItem.stack)
	end
	local parts = {}
	for itemId, count in totals do
		table.insert(parts, itemId .. " " .. count)
	end
	table.sort(parts)
	return table.concat(parts, ", ")
end

do -- a long run of random mouse and key use: no item is made and none is lost
	local seed = 2024
	local function random(limit: number): number
		seed = (seed * 16807) % 2147483647
		return math.floor(seed / 65536) % limit + 1
	end
	local itemIds = { "log", "stone", "fish" }
	for _, withOther in { false, true } do
		local world, state = openedWorld(if withOther then 9 else nil)
		local gestures = SlotGestures.new()
		for _ = 1, 20 do
			if random(3) > 1 then
				put(state, "pack", random(36), itemIds[random(3)] .. " " .. random(8))
			end
		end
		if withOther then
			for slot = 1, 9 do
				if random(2) == 1 then
					put(state, "other", slot, itemIds[random(3)] .. " " .. random(8))
				end
			end
		end
		local total = everything(world, state)
		local lost = 0
		local now = 0
		local function randomSlot(): Slot
			if withOther and random(3) == 1 then
				return at("other", random(9))
			end
			return at("pack", random(14))
		end
		for step = 1, 4000 do
			now += random(6) / 10
			local kind = random(8)
			local button: SlotGestures.Button = if random(2) == 1 then "left" else "right"
			if kind <= 4 then
				mouse(world, state, gestures, button, { randomSlot() }, random(5) == 1, now)
			elseif kind == 5 then
				local slots = {}
				for _ = 1, random(5) + 1 do
					table.insert(slots, randomSlot())
				end
				mouse(world, state, gestures, button, slots, random(5) == 1, now)
			elseif kind == 6 then
				send(world, InventoryControls.getRequestForDigitKeyOverSlot(randomSlot(), random(9)))
			elseif kind == 7 then
				send(world, InventoryControls.getRequestForDropKeyOverSlot(randomSlot(), random(2) == 1))
			else
				send(world, InventoryControls.getRequestForOutsideClick(button))
			end
			local after = everything(world, state)
			if after ~= total then
				lost += 1
				if lost == 1 then
					print("run " .. tostring(withOther) .. " step " .. step .. ": " .. total .. " became " .. after)
				end
				total = after
			end
		end
		check(
			lost == 0,
			"getRequestForGesture: after 4000 random clicks, drags and keys "
				.. (if withOther then "with another inventory open" else "on the pack alone")
				.. ", no item was made or lost"
		)
	end
end

Check.finish("InventoryControls")
