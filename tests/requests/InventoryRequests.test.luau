--!strict
-- Tests for InventoryRequests. Run from the repository root: lune run tests/requests/InventoryRequests.test.luau

local Check = require("../Check")
local Hotbar = require("../../src/shared/inventory/Hotbar")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryRequests = require("../../src/shared/requests/InventoryRequests")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local World = require("../../src/shared/world/World")

local check = Check.that

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "cooked_fish", stackSize = 8 })
ItemRegistry.register({ id = "stove", stackSize = 1 })
ItemRegistry.register({ id = "crate", stackSize = 1 })
ItemRegistry.register({ id = "oven", stackSize = 1 })

local itemIds = { "log", "fish", "cooked_fish", "stove", "crate", "oven" }
local at = Position.new
local ALONG_X = { x = 1, y = 0, z = 0 }

-- The requests are called with whatever a player's machine might send, so they are called through
-- this, which does not check their arguments.
local requests = InventoryRequests :: any
local function send(name: string, world: World.World, state: PlayerState.PlayerState, ...: any)
	(requests[name] :: (...any) -> ())(world, state, ...)
end

-- A count that no request may act on.
local badCounts: { any } = { -1, 1.5, 0 / 0, math.huge, -math.huge, "1", true, {} }

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

-- A world at time 100 with a plot of 6 by 6 tiles and one player, id 1, whose drops land at 12, 0, 0.
-- The player has 12 logs in pack slot 1, 5 fish in slot 2 and 4 logs in slot 10, and no screen open.
local function newWorld(): (World.World, PlayerState.PlayerState)
	local world = World.new(Plot.new(6, 6), at(0, 0, 0), 100)
	local state = World.addPlayer(world, 1)
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	Inventory.setStack(state.pack, 1, ItemStack.new("log", 12))
	Inventory.setStack(state.pack, 2, ItemStack.new("fish", 5))
	Inventory.setStack(state.pack, 10, ItemStack.new("log", 4))
	return world, state
end

local function inSlot(state: PlayerState.PlayerState, slot: number): ItemStack.ItemStack?
	return Inventory.getStack(state.pack, slot)
end

local function screenOf(state: PlayerState.PlayerState): InventoryScreen.InventoryScreen
	return state.screen :: InventoryScreen.InventoryScreen
end

local function carriedBy(state: PlayerState.PlayerState): ItemStack.ItemStack?
	return screenOf(state).carriedStack
end

-- The inventory that a placed object has on it. Nil if it has none.
local function findInside(world: World.World, placedObjectId: number): Inventory.Inventory?
	local placedObject = world.plot.placedObjectsById[placedObjectId] :: any
	return if placedObject ~= nil then placedObject.inventory else nil
end

-- The inventory inside a placed object that is known to have one.
local function insideOf(world: World.World, placedObjectId: number): Inventory.Inventory
	return findInside(world, placedObjectId) :: Inventory.Inventory
end

-- Stands an object of the kind `kindId` on a tile of the world's plot, with an inventory of 3 slots
-- on it.
local function place(world: World.World, kindId: string, tileX: number, tileZ: number): number
	local placedObject = { kindId = kindId, tileX = tileX, tileZ = tileZ, inventory = Inventory.new(3) }
	return Plot.placeObject(world.plot, placedObject)
end

-- The slot rule of an oven: slot 1 takes only fish, slot 2 takes only logs, and slot 3 takes nothing.
local function ovenSlotAcceptsItem(slot: number, itemId: string): boolean
	return (slot == 1 and itemId == "fish") or (slot == 2 and itemId == "log")
end

-- Opens a placed object on a player's screen, beside their pack. The slots of an oven take only what
-- ovenSlotAcceptsItem says, and those of any other kind take anything.
local function open(world: World.World, state: PlayerState.PlayerState, placedObjectId: number)
	local placedObject = world.plot.placedObjectsById[placedObjectId]
	local isOven = placedObject.kindId == "oven"
	World.openPlacedObjectScreen(
		world,
		state,
		placedObjectId,
		insideOf(world, placedObjectId),
		if isOven then ovenSlotAcceptsItem else nil
	)
end

-- Stands an object of the kind `kindId` on tile 6, 6, opens it on the player's screen beside their
-- pack, and returns what is inside it.
local function openPlaced(world: World.World, state: PlayerState.PlayerState, kindId: string): Inventory.Inventory
	local placedObjectId = place(world, kindId, 6, 6)
	open(world, state, placedObjectId)
	return insideOf(world, placedObjectId)
end

-- How many of one item lie on the ground, in all.
local function onGround(world: World.World, itemId: string): number
	local count = 0
	for _, groundItem in world.groundItems.itemsById do
		if groundItem.stack.itemId == itemId then
			count += groundItem.stack.count
		end
	end
	return count
end

-- How many of one item the world holds in all: in packs, carried, standing on the plot, inside what
-- stands on the plot, and on the ground.
local function inWorld(world: World.World, itemId: string): number
	local count = onGround(world, itemId)
	for _, state in world.players do
		count += Inventory.countItems(state.pack, itemId)
		local screen = state.screen
		if screen ~= nil and screen.carriedStack ~= nil and screen.carriedStack.itemId == itemId then
			count += screen.carriedStack.count
		end
	end
	for placedObjectId, placedObject in world.plot.placedObjectsById do
		local inside = findInside(world, placedObjectId)
		count += if placedObject.kindId == itemId then 1 else 0
		count += if inside ~= nil then Inventory.countItems(inside, itemId) else 0
	end
	return count
end

do -- openPack
	local world, state = newWorld()
	send("openPack", world, state)
	local screen = screenOf(state)
	check(screen.pack == state.pack, "openPack: opens a screen on the player's pack")
	check(
		screen.otherInventory == nil and screen.carriedStack == nil,
		"openPack: with no other inventory and nothing carried"
	)
	send("openPack", world, state)
	check(state.screen == screen, "openPack: does nothing when a screen is already open")

	local crateWorld, crateState = newWorld()
	local crate = openPlaced(crateWorld, crateState, "crate")
	send("openPack", crateWorld, crateState)
	check(screenOf(crateState).otherInventory == crate, "openPack: leaves a crate that is open beside the pack")
end

do -- closeScreen
	local world, state = newWorld()
	send("closeScreen", world, state)
	check(state.screen == nil and onGround(world, "log") == 0, "closeScreen: does nothing when no screen is open")

	send("openPack", world, state)
	send("closeScreen", world, state)
	check(state.screen == nil, "closeScreen: closes the screen")

	send("openPack", world, state)
	send("pickUpFromSlot", world, state, "pack", 1)
	send("closeScreen", world, state)
	check(
		Inventory.countItems(state.pack, "log") == 16 and state.screen == nil,
		"closeScreen: the carried stack goes back into the pack"
	)
	check(onGround(world, "log") == 0, "closeScreen: and nothing lands on the ground when it fits")

	local fullWorld, full = newWorld()
	send("openPack", fullWorld, full)
	send("pickUpFromSlot", fullWorld, full, "pack", 1)
	for slot = 1, PlayerState.PACK_SLOT_COUNT do
		Inventory.setStack(full.pack, slot, ItemStack.new("stove", 1))
	end
	send("closeScreen", fullWorld, full)
	check(
		full.screen == nil and onGround(fullWorld, "log") == 12,
		"closeScreen: what does not fit in the pack lands on the ground"
	)
	for _, groundItem in fullWorld.groundItems.itemsById do
		check(
			groundItem.position.x == 6
				and groundItem.position.y == World.CHARACTER_THROW_START_HEIGHT
				and groundItem.spawnVelocity.x == 0
				and groundItem.spawnVelocity.y == 0
				and groundItem.spawnTime == 100,
			"closeScreen: it is dropped at the player's character, not moving, at the world's time"
		)
	end

	local placedWorld, placedState = newWorld()
	openPlaced(placedWorld, placedState, "crate")
	send("closeScreen", placedWorld, placedState)
	check(
		placedState.screen == nil and World.getOpenedPlacedObjectId(placedWorld, placedState) == nil,
		"closeScreen: a player who had a crate open has nothing open any more"
	)
end

do -- pickUpFromSlot
	local world, state = newWorld()
	send("pickUpFromSlot", world, state, "pack", 1, 5)
	check(
		is(inSlot(state, 1), "log", 12) and state.screen == nil,
		"pickUpFromSlot: does nothing when no screen is open"
	)

	send("openPack", world, state)
	send("pickUpFromSlot", world, state, "pack", 1, 5)
	check(
		is(carriedBy(state), "log", 5) and is(inSlot(state, 1), "log", 7),
		"pickUpFromSlot: moves that many items from the slot onto the carried stack"
	)
	send("pickUpFromSlot", world, state, "pack", 10, nil)
	check(
		is(carriedBy(state), "log", 9) and inSlot(state, 10) == nil,
		"pickUpFromSlot: with no count moves everything in the slot when there is room for it"
	)
	send("pickUpFromSlot", world, state, "pack", 1, nil)
	check(
		is(carriedBy(state), "log", 16) and inSlot(state, 1) == nil,
		"pickUpFromSlot: with no count moves what the carried stack has room for, here all of what the slot held"
	)
	Inventory.setStack(state.pack, 7, ItemStack.new("log", 9))
	send("pickUpFromSlot", world, state, "pack", 7, nil)
	check(
		is(carriedBy(state), "log", 16) and is(inSlot(state, 7), "log", 9),
		"pickUpFromSlot: a full carried stack takes nothing more"
	)
	send("pickUpFromSlot", world, state, "pack", 2, nil)
	check(
		is(inSlot(state, 2), "fish", 5),
		"pickUpFromSlot: nothing moves from a slot that holds another item than the carried one"
	)
	send("pickUpFromSlot", world, state, "pack", 3, nil)
	check(is(carriedBy(state), "log", 16), "pickUpFromSlot: nothing moves from a slot that holds nothing")

	local topWorld, top = newWorld()
	send("openPack", topWorld, top)
	send("pickUpFromSlot", topWorld, top, "pack", 1, 10)
	send("pickUpFromSlot", topWorld, top, "pack", 10, nil)
	send("pickUpFromSlot", topWorld, top, "pack", 1, nil)
	check(
		is(carriedBy(top), "log", 16) and inSlot(top, 1) == nil and inSlot(top, 10) == nil,
		"pickUpFromSlot: stacks of the same item are gathered up to the stack size"
	)
	Inventory.setStack(top.pack, 4, ItemStack.new("log", 9))
	send("pickUpFromSlot", topWorld, top, "pack", 4, 3)
	check(is(inSlot(top, 4), "log", 9), "pickUpFromSlot: a count that does not fit moves nothing")

	local moreWorld, more = newWorld()
	send("openPack", moreWorld, more)
	send("pickUpFromSlot", moreWorld, more, "pack", 2, 99)
	check(
		is(carriedBy(more), "fish", 5) and inSlot(more, 2) == nil,
		"pickUpFromSlot: a count of more than the slot holds moves what it holds"
	)

	local zeroWorld, zero = newWorld()
	send("openPack", zeroWorld, zero)
	send("pickUpFromSlot", zeroWorld, zero, "pack", 1, 0)
	check(carriedBy(zero) == nil and is(inSlot(zero, 1), "log", 12), "pickUpFromSlot: a count of 0 moves nothing")

	for _, bad in badCounts do
		send("pickUpFromSlot", zeroWorld, zero, "pack", 1, bad)
		check(
			carriedBy(zero) == nil and is(inSlot(zero, 1), "log", 12),
			"pickUpFromSlot: moves nothing with the count " .. tostring(bad)
		)
	end
	for _, side in { "other", "Pack", "", 1, true, {} } :: { any } do
		send("pickUpFromSlot", zeroWorld, zero, side, 1, nil)
	end
	for _, slot in { 0, -1, 37, 99, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		send("pickUpFromSlot", zeroWorld, zero, "pack", slot, nil)
	end
	send("pickUpFromSlot", zeroWorld, zero)
	send("pickUpFromSlot", zeroWorld, zero, "pack")
	check(
		carriedBy(zero) == nil and inWorld(zeroWorld, "log") == 16,
		"pickUpFromSlot: moves nothing for a side that is not there, a slot that is not there, or nothing at all"
	)

	local crateWorld, withCrate = newWorld()
	local crate = openPlaced(crateWorld, withCrate, "crate")
	Inventory.setStack(crate, 2, ItemStack.new("fish", 3))
	send("pickUpFromSlot", crateWorld, withCrate, "other", 2, 2)
	check(
		is(carriedBy(withCrate), "fish", 2) and is(Inventory.getStack(crate, 2), "fish", 1),
		"pickUpFromSlot: takes from the other inventory too"
	)
	send("pickUpFromSlot", crateWorld, withCrate, "other", 4, nil)
	check(is(carriedBy(withCrate), "fish", 2), "pickUpFromSlot: not from a slot the other inventory lacks")
end

do -- putDownInSlot
	local world, state = newWorld()
	send("putDownInSlot", world, state, "pack", 3, 1)
	check(inSlot(state, 3) == nil, "putDownInSlot: does nothing when no screen is open")

	send("openPack", world, state)
	send("putDownInSlot", world, state, "pack", 3, 1)
	check(inSlot(state, 3) == nil, "putDownInSlot: does nothing when nothing is carried")

	send("pickUpFromSlot", world, state, "pack", 1)
	send("putDownInSlot", world, state, "pack", 3, 5)
	check(
		is(inSlot(state, 3), "log", 5) and is(carriedBy(state), "log", 7),
		"putDownInSlot: moves that many items from the carried stack into the slot"
	)
	send("putDownInSlot", world, state, "pack", 2, nil)
	check(
		is(inSlot(state, 2), "fish", 5) and is(carriedBy(state), "log", 7),
		"putDownInSlot: nothing goes into a slot that holds another item"
	)
	Inventory.setStack(state.pack, 5, ItemStack.new("log", 12))
	send("putDownInSlot", world, state, "pack", 5, nil)
	check(
		is(inSlot(state, 5), "log", 16) and is(carriedBy(state), "log", 3),
		"putDownInSlot: with no count moves only what the slot has room for"
	)
	send("putDownInSlot", world, state, "pack", 3, 99)
	check(
		is(inSlot(state, 3), "log", 8) and carriedBy(state) == nil,
		"putDownInSlot: a count of more than is carried moves all of what is carried"
	)

	local zeroWorld, zero = newWorld()
	send("openPack", zeroWorld, zero)
	send("pickUpFromSlot", zeroWorld, zero, "pack", 1)
	send("putDownInSlot", zeroWorld, zero, "pack", 3, 0)
	check(inSlot(zero, 3) == nil and is(carriedBy(zero), "log", 12), "putDownInSlot: a count of 0 moves nothing")
	for _, bad in badCounts do
		send("putDownInSlot", zeroWorld, zero, "pack", 3, bad)
		check(
			inSlot(zero, 3) == nil and is(carriedBy(zero), "log", 12),
			"putDownInSlot: moves nothing with the count " .. tostring(bad)
		)
	end
	for _, side in { "other", "Pack", "", 1, true, {} } :: { any } do
		send("putDownInSlot", zeroWorld, zero, side, 3, nil)
	end
	for _, slot in { 0, -1, 37, 99, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		send("putDownInSlot", zeroWorld, zero, "pack", slot, nil)
	end
	send("putDownInSlot", zeroWorld, zero)
	check(
		is(carriedBy(zero), "log", 12) and inWorld(zeroWorld, "log") == 16,
		"putDownInSlot: moves nothing into a slot that is not there, or with nothing at all"
	)

	local ovenWorld, withOven = newWorld()
	local oven = openPlaced(ovenWorld, withOven, "oven")
	send("pickUpFromSlot", ovenWorld, withOven, "pack", 1)
	send("putDownInSlot", ovenWorld, withOven, "other", 1, nil)
	send("putDownInSlot", ovenWorld, withOven, "other", 3, nil)
	check(
		Inventory.isEmpty(oven) and is(carriedBy(withOven), "log", 12),
		"putDownInSlot: an oven's input slot takes no logs and its output slot takes nothing"
	)
	send("putDownInSlot", ovenWorld, withOven, "other", 2, 5)
	check(
		is(Inventory.getStack(oven, 2), "log", 5) and is(carriedBy(withOven), "log", 7),
		"putDownInSlot: an oven's fuel slot takes logs"
	)
end

do -- swapCarriedStackWithSlot
	local world, state = newWorld()
	send("swapCarriedStackWithSlot", world, state, "pack", 1)
	check(
		is(inSlot(state, 1), "log", 12) and state.screen == nil,
		"swapCarriedStackWithSlot: does nothing when no screen is open"
	)

	send("openPack", world, state)
	send("swapCarriedStackWithSlot", world, state, "pack", 1)
	check(
		is(carriedBy(state), "log", 12) and inSlot(state, 1) == nil,
		"swapCarriedStackWithSlot: with nothing carried, the slot's whole stack becomes the carried stack"
	)
	send("swapCarriedStackWithSlot", world, state, "pack", 2)
	check(
		is(inSlot(state, 2), "log", 12) and is(carriedBy(state), "fish", 5),
		"swapCarriedStackWithSlot: exchanges the carried stack with the slot's stack"
	)
	send("swapCarriedStackWithSlot", world, state, "pack", 10)
	check(
		is(inSlot(state, 10), "fish", 5) and is(carriedBy(state), "log", 4),
		"swapCarriedStackWithSlot: exchanges rather than merges stacks of different items"
	)
	send("swapCarriedStackWithSlot", world, state, "pack", 2)
	check(
		is(inSlot(state, 2), "log", 4) and is(carriedBy(state), "log", 12),
		"swapCarriedStackWithSlot: exchanges rather than merges stacks of the same item"
	)
	send("swapCarriedStackWithSlot", world, state, "pack", 3)
	check(
		is(inSlot(state, 3), "log", 12) and carriedBy(state) == nil,
		"swapCarriedStackWithSlot: a slot that holds nothing takes the carried stack"
	)
	send("swapCarriedStackWithSlot", world, state, "pack", 4)
	check(
		inSlot(state, 4) == nil and carriedBy(state) == nil,
		"swapCarriedStackWithSlot: with nothing on either side, nothing happens"
	)
	for _, side in { "other", "Pack", "", 1, true, {} } :: { any } do
		send("swapCarriedStackWithSlot", world, state, side, 3)
	end
	for _, slot in { 0, -1, 37, 99, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		send("swapCarriedStackWithSlot", world, state, "pack", slot)
	end
	send("swapCarriedStackWithSlot", world, state)
	check(
		is(inSlot(state, 3), "log", 12) and carriedBy(state) == nil,
		"swapCarriedStackWithSlot: ignored for a side or slot that is not there, or nothing at all"
	)

	local ovenWorld, withOven = newWorld()
	local oven = openPlaced(ovenWorld, withOven, "oven")
	send("pickUpFromSlot", ovenWorld, withOven, "pack", 1)
	send("swapCarriedStackWithSlot", ovenWorld, withOven, "other", 1)
	check(
		Inventory.isEmpty(oven) and is(carriedBy(withOven), "log", 12),
		"swapCarriedStackWithSlot: changes nothing when the slot does not accept what is carried"
	)
	send("swapCarriedStackWithSlot", ovenWorld, withOven, "other", 2)
	check(
		is(Inventory.getStack(oven, 2), "log", 12) and carriedBy(withOven) == nil,
		"swapCarriedStackWithSlot: but does when it does"
	)
	send("swapCarriedStackWithSlot", ovenWorld, withOven, "other", 2)
	check(
		Inventory.isEmpty(oven) and is(carriedBy(withOven), "log", 12),
		"swapCarriedStackWithSlot: and takes what a slot holds back out"
	)
end

do -- swapSlots
	local world, state = newWorld()
	send("swapSlots", world, state, "pack", 1, "pack", 2)
	check(is(inSlot(state, 1), "log", 12), "swapSlots: does nothing when no screen is open")

	send("openPack", world, state)
	send("swapSlots", world, state, "pack", 1, "pack", 2)
	check(
		is(inSlot(state, 1), "fish", 5) and is(inSlot(state, 2), "log", 12),
		"swapSlots: exchanges the stacks in two slots"
	)
	send("swapSlots", world, state, "pack", 2, "pack", 3)
	check(
		inSlot(state, 2) == nil and is(inSlot(state, 3), "log", 12),
		"swapSlots: a slot that holds nothing takes the other's stack"
	)
	send("swapSlots", world, state, "pack", 3, "pack", 10)
	check(
		is(inSlot(state, 3), "log", 4) and is(inSlot(state, 10), "log", 12),
		"swapSlots: stacks of the same item are exchanged, not merged"
	)
	send("swapSlots", world, state, "pack", 4, "pack", 5)
	check(inSlot(state, 4) == nil and inSlot(state, 5) == nil, "swapSlots: two slots that hold nothing stay so")
	send("swapSlots", world, state, "pack", 1, "pack", 1)
	check(is(inSlot(state, 1), "fish", 5), "swapSlots: a slot swapped with itself is unchanged")
	check(carriedBy(state) == nil, "swapSlots: and nothing is carried")

	local before = inWorld(world, "log") + inWorld(world, "fish")
	for _, bad in { 0, -1, 37, 99, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		send("swapSlots", world, state, "pack", bad, "pack", 1)
		send("swapSlots", world, state, "pack", 1, "pack", bad)
	end
	for _, side in { "other", "Pack", "", 1, true, {} } :: { any } do
		send("swapSlots", world, state, side, 1, "pack", 2)
		send("swapSlots", world, state, "pack", 1, side, 2)
	end
	send("swapSlots", world, state, "pack", 1)
	send("swapSlots", world, state)
	check(
		is(inSlot(state, 1), "fish", 5) and is(inSlot(state, 3), "log", 4),
		"swapSlots: ignored when either slot is not there, or when arguments are missing"
	)
	check(inWorld(world, "log") + inWorld(world, "fish") == before, "swapSlots: and no item is made or lost")

	local ovenWorld, withOven = newWorld()
	local oven = openPlaced(ovenWorld, withOven, "oven")
	send("swapSlots", ovenWorld, withOven, "pack", 1, "other", 1)
	check(
		is(inSlot(withOven, 1), "log", 12) and Inventory.isEmpty(oven),
		"swapSlots: ignored when a slot does not accept the stack from the other"
	)
	send("swapSlots", ovenWorld, withOven, "other", 1, "pack", 1)
	check(is(inSlot(withOven, 1), "log", 12) and Inventory.isEmpty(oven), "swapSlots: ignored in either order")
	send("swapSlots", ovenWorld, withOven, "pack", 2, "other", 1)
	check(
		inSlot(withOven, 2) == nil and is(Inventory.getStack(oven, 1), "fish", 5),
		"swapSlots: moves a stack between the pack and the other inventory when the slot accepts it"
	)
	Inventory.setStack(oven, 3, ItemStack.new("cooked_fish", 2))
	send("swapSlots", ovenWorld, withOven, "other", 3, "pack", 6)
	check(
		is(inSlot(withOven, 6), "cooked_fish", 2) and Inventory.getStack(oven, 3) == nil,
		"swapSlots: takes what an oven made out of its output slot"
	)
	send("swapSlots", ovenWorld, withOven, "pack", 1, "other", 2)
	check(
		is(Inventory.getStack(oven, 2), "log", 12) and inSlot(withOven, 1) == nil,
		"swapSlots: puts logs in an oven's fuel slot"
	)
end

do -- moveFromSlotToInventory
	-- Returns the slot numbers from `first` to `last`, as a client lists the slots to add a stack to.
	local function slots(first: number, last: number): { number }
		local list = {}
		for slot = first, last do
			table.insert(list, slot)
		end
		return list
	end

	local world, state = newWorld()
	send("moveFromSlotToInventory", world, state, "pack", 1, "pack", slots(20, 22))
	check(is(inSlot(state, 1), "log", 12), "moveFromSlotToInventory: does nothing when no screen is open")

	send("openPack", world, state)
	send("moveFromSlotToInventory", world, state, "pack", 1, "pack", slots(20, 22))
	check(
		inSlot(state, 1) == nil and is(inSlot(state, 20), "log", 12) and inSlot(state, 21) == nil,
		"moveFromSlotToInventory: moves the stack into the first listed slot that holds nothing"
	)
	send("moveFromSlotToInventory", world, state, "pack", 10, "pack", slots(18, 20))
	check(
		inSlot(state, 10) == nil and is(inSlot(state, 20), "log", 16) and inSlot(state, 18) == nil,
		"moveFromSlotToInventory: tops up a stack of the same item before filling a slot that holds nothing"
	)
	send("moveFromSlotToInventory", world, state, "pack", 2, "pack", slots(20, 22))
	check(
		inSlot(state, 2) == nil and is(inSlot(state, 20), "log", 16) and is(inSlot(state, 21), "fish", 5),
		"moveFromSlotToInventory: a different item goes past a stack of another item into a slot that holds nothing"
	)
	send("moveFromSlotToInventory", world, state, "pack", 4, "pack", slots(1, 3))
	check(
		inSlot(state, 4) == nil and inSlot(state, 1) == nil,
		"moveFromSlotToInventory: a slot that holds nothing moves nothing"
	)

	local splitWorld, split = newWorld()
	send("openPack", splitWorld, split)
	Inventory.setStack(split.pack, 20, ItemStack.new("log", 14))
	send("moveFromSlotToInventory", splitWorld, split, "pack", 1, "pack", slots(20, 21))
	check(
		is(inSlot(split, 20), "log", 16) and is(inSlot(split, 21), "log", 10) and inSlot(split, 1) == nil,
		"moveFromSlotToInventory: fills one slot and puts the rest in the next"
	)
	local shortWorld, short = newWorld()
	send("openPack", shortWorld, short)
	Inventory.setStack(short.pack, 20, ItemStack.new("log", 14))
	send("moveFromSlotToInventory", shortWorld, short, "pack", 1, "pack", slots(20, 20))
	check(
		is(inSlot(short, 20), "log", 16) and is(inSlot(short, 1), "log", 10),
		"moveFromSlotToInventory: what does not fit stays where it was"
	)
	send("moveFromSlotToInventory", shortWorld, short, "pack", 1, "pack", slots(1, 1))
	check(
		is(inSlot(short, 1), "log", 10),
		"moveFromSlotToInventory: a stack that is added to its own slot alone stays there"
	)
	send("moveFromSlotToInventory", shortWorld, short, "pack", 1, "pack", slots(5, 3))
	check(
		is(inSlot(short, 1), "log", 10) and inSlot(short, 4) == nil,
		"moveFromSlotToInventory: an empty list of slots moves nothing"
	)
	send("moveFromSlotToInventory", shortWorld, short, "pack", 1, "pack", slots(1, 36))
	check(
		inSlot(short, 1) == nil and is(inSlot(short, 10), "log", 14),
		"moveFromSlotToInventory: a stack tops up a listed slot that holds the same item, here slot 10, before it fills one that holds nothing"
	)

	local crateWorld, withCrate = newWorld()
	local crate = openPlaced(crateWorld, withCrate, "crate")
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 1, "other", slots(1, 3))
	check(
		inSlot(withCrate, 1) == nil and is(Inventory.getStack(crate, 1), "log", 12),
		"moveFromSlotToInventory: moves a stack from the pack into the other inventory"
	)
	send("moveFromSlotToInventory", crateWorld, withCrate, "other", 1, "pack", slots(1, 9))
	check(
		is(inSlot(withCrate, 1), "log", 12) and Inventory.isEmpty(crate),
		"moveFromSlotToInventory: moves a stack from the other inventory into the pack"
	)
	send("moveFromSlotToInventory", crateWorld, withCrate, "other", 2, "pack", slots(1, 9))
	check(
		inWorld(crateWorld, "log") == 16,
		"moveFromSlotToInventory: a slot of the other inventory that holds nothing moves nothing"
	)
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 1, "other", slots(2, 99))
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 1, "other", slots(0, 3))
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 1, "other", { 1.5, 3 })
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 1, "other", { 1, "3" })
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 1, "nowhere", slots(1, 3))
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 99, "other", slots(1, 3))
	send("moveFromSlotToInventory", crateWorld, withCrate, "nowhere", 1, "other", slots(1, 3))
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 1, "other", 1)
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 1, "other", "1")
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 1, "other", { [1] = 1, [3] = 3 })
	local listWithAnotherKey: { [any]: number } = { 1, 2 }
	listWithAnotherKey.extra = 3
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 1, "other", listWithAnotherKey)
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 1, "other", table.create(crate.slotCount + 1, 1))
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 1)
	send("moveFromSlotToInventory", crateWorld, withCrate)
	check(
		is(inSlot(withCrate, 1), "log", 12) and Inventory.isEmpty(crate),
		"moveFromSlotToInventory: ignored when a slot is not there, when the slots are not a list of the inventory's slots no longer than it has slots, or when arguments are missing"
	)
	send("moveFromSlotToInventory", crateWorld, withCrate, "pack", 1, "other", table.create(crate.slotCount, 2))
	check(
		inSlot(withCrate, 1) == nil and is(Inventory.getStack(crate, 2), "log", 12),
		"moveFromSlotToInventory: a list as long as the inventory has slots is allowed, and may name a slot twice"
	)
	send("moveFromSlotToInventory", crateWorld, withCrate, "other", 2, "other", { 3, 1 })
	check(
		Inventory.getStack(crate, 2) == nil and is(Inventory.getStack(crate, 3), "log", 12),
		"moveFromSlotToInventory: fills the listed slots in the order of the list"
	)
	send("moveFromSlotToInventory", crateWorld, withCrate, "other", 3, "pack", { 1 })

	local ovenWorld, withOven = newWorld()
	local oven = openPlaced(ovenWorld, withOven, "oven")
	send("moveFromSlotToInventory", ovenWorld, withOven, "pack", 1, "other", slots(1, 1))
	check(
		is(inSlot(withOven, 1), "log", 12) and Inventory.isEmpty(oven),
		"moveFromSlotToInventory: never into a slot that does not accept the item"
	)
	send("moveFromSlotToInventory", ovenWorld, withOven, "pack", 1, "other", slots(1, 3))
	check(
		inSlot(withOven, 1) == nil and is(Inventory.getStack(oven, 2), "log", 12),
		"moveFromSlotToInventory: a stack of logs goes to an oven's fuel slot"
	)
	send("moveFromSlotToInventory", ovenWorld, withOven, "pack", 2, "other", slots(1, 3))
	check(
		inSlot(withOven, 2) == nil and is(Inventory.getStack(oven, 1), "fish", 5),
		"moveFromSlotToInventory: and a stack of fish to its input slot"
	)

	local fullWorld, withFull = newWorld()
	local full = openPlaced(fullWorld, withFull, "crate")
	for slot = 1, full.slotCount do
		Inventory.setStack(full, slot, ItemStack.new("log", 16))
	end
	send("moveFromSlotToInventory", fullWorld, withFull, "pack", 1, "other", slots(1, full.slotCount))
	check(
		is(inSlot(withFull, 1), "log", 12),
		"moveFromSlotToInventory: moves nothing into an inventory whose slots are full, and the stack stays in its slot"
	)
	Inventory.setStack(full, 2, ItemStack.new("log", 10))
	send("moveFromSlotToInventory", fullWorld, withFull, "pack", 1, "other", slots(1, full.slotCount))
	check(
		is(inSlot(withFull, 1), "log", 6) and is(Inventory.getStack(full, 2), "log", 16),
		"moveFromSlotToInventory: between two inventories, moves the items that fit and leaves the rest in their slot"
	)

	local aloneWorld, alone = newWorld()
	send("openPack", aloneWorld, alone)
	send("moveFromSlotToInventory", aloneWorld, alone, "pack", 1, "other", { 1 })
	check(
		is(inSlot(alone, 1), "log", 12),
		"moveFromSlotToInventory: ignored when the slots are in the other inventory and no other inventory is open"
	)
end

do -- fillCarriedStackFromAllSlots
	local world, state = newWorld()
	send("fillCarriedStackFromAllSlots", world, state)
	check(is(inSlot(state, 1), "log", 12), "fillCarriedStackFromAllSlots: does nothing when no screen is open")

	send("openPack", world, state)
	send("fillCarriedStackFromAllSlots", world, state)
	check(
		carriedBy(state) == nil and inWorld(world, "log") == 16,
		"fillCarriedStackFromAllSlots: does nothing when nothing is carried"
	)

	send("pickUpFromSlot", world, state, "pack", 10)
	Inventory.setStack(state.pack, 20, ItemStack.new("log", 5))
	send("fillCarriedStackFromAllSlots", world, state)
	check(
		is(carriedBy(state), "log", 16),
		"fillCarriedStackFromAllSlots: fills the carried stack with items of its kind"
	)
	check(
		inSlot(state, 1) == nil and is(inSlot(state, 20), "log", 5) and is(inSlot(state, 2), "fish", 5),
		"fillCarriedStackFromAllSlots: from the slots that hold them, lowest first, and from no others"
	)

	local crateWorld, withCrate = newWorld()
	local crate = openPlaced(crateWorld, withCrate, "crate")
	Inventory.setStack(crate, 3, ItemStack.new("log", 3))
	send("pickUpFromSlot", crateWorld, withCrate, "pack", 10)
	send("fillCarriedStackFromAllSlots", crateWorld, withCrate)
	check(
		is(carriedBy(withCrate), "log", 16) and Inventory.isEmpty(crate) and is(inSlot(withCrate, 1), "log", 3),
		"fillCarriedStackFromAllSlots: gathers from the other inventory too"
	)
end

do -- spreadCarriedStackOverSlots
	local function at2(side: string, slot: number): { side: string, slot: number }
		return { side = side, slot = slot }
	end
	local world, state = newWorld()
	send("spreadCarriedStackOverSlots", world, state, { at2("pack", 3), at2("pack", 4) }, nil)
	check(inSlot(state, 3) == nil, "spreadCarriedStackOverSlots: does nothing when no screen is open")

	send("openPack", world, state)
	send("spreadCarriedStackOverSlots", world, state, { at2("pack", 3), at2("pack", 4) }, nil)
	check(
		inSlot(state, 3) == nil and is(inSlot(state, 1), "log", 12),
		"spreadCarriedStackOverSlots: does nothing when nothing is carried"
	)

	send("pickUpFromSlot", world, state, "pack", 1)
	send("spreadCarriedStackOverSlots", world, state, { at2("pack", 3), at2("pack", 4), at2("pack", 5) }, nil)
	check(
		is(inSlot(state, 3), "log", 4) and is(inSlot(state, 4), "log", 4) and is(inSlot(state, 5), "log", 4),
		"spreadCarriedStackOverSlots: with no count each slot gets an equal share"
	)
	check(
		carriedBy(state) == nil,
		"spreadCarriedStackOverSlots: and nothing stays carried when the shares come out even"
	)

	local eachWorld, each = newWorld()
	send("openPack", eachWorld, each)
	send("pickUpFromSlot", eachWorld, each, "pack", 1)
	send("spreadCarriedStackOverSlots", eachWorld, each, { at2("pack", 3), at2("pack", 4), at2("pack", 5) }, 1)
	check(
		is(inSlot(each, 3), "log", 1) and is(inSlot(each, 4), "log", 1) and is(inSlot(each, 5), "log", 1),
		"spreadCarriedStackOverSlots: with a count each slot gets that many"
	)
	check(is(carriedBy(each), "log", 9), "spreadCarriedStackOverSlots: and the rest stays carried")
	send("spreadCarriedStackOverSlots", eachWorld, each, { at2("pack", 6), at2("pack", 7) }, nil)
	check(
		is(inSlot(each, 6), "log", 4) and is(inSlot(each, 7), "log", 4) and is(carriedBy(each), "log", 1),
		"spreadCarriedStackOverSlots: a share is rounded down and the remainder stays carried"
	)
	send("spreadCarriedStackOverSlots", eachWorld, each, {}, nil)
	check(is(carriedBy(each), "log", 1), "spreadCarriedStackOverSlots: a list of no slots puts nothing down")
	send("spreadCarriedStackOverSlots", eachWorld, each, { at2("pack", 8) }, 0)
	check(
		inSlot(each, 8) == nil and is(carriedBy(each), "log", 1),
		"spreadCarriedStackOverSlots: a count of 0 puts nothing down"
	)

	local badWorld, bad = newWorld()
	send("openPack", badWorld, bad)
	send("pickUpFromSlot", badWorld, bad, "pack", 1)
	for _, count in badCounts do
		send("spreadCarriedStackOverSlots", badWorld, bad, { at2("pack", 8) }, count)
	end
	check(
		inSlot(bad, 8) == nil,
		"spreadCarriedStackOverSlots: ignored with a count that is not a whole number of 0 or more"
	)
	local badLists: { any } = {
		{ at2("pack", 8), at2("pack", 37) },
		{ at2("pack", 8), at2("pack", 0) },
		{ at2("pack", 8), at2("other", 1) },
		{ at2("pack", 8), at2("pack", 1.5) },
		{ at2("pack", 8), at2("nowhere", 1) },
		{ at2("pack", 8), 5 },
		{ at2("pack", 8), "pack" },
		{ at2("pack", 8), { side = "pack" } },
		{ at2("pack", 8), { slot = 1 } },
		{ at2("pack", 8), nil, at2("pack", 9) },
		{ [1] = at2("pack", 8), [3] = at2("pack", 9) },
		{ a = at2("pack", 8) },
		at2("pack", 8),
		"pack",
		5,
		true,
	}
	for _, list in badLists do
		send("spreadCarriedStackOverSlots", badWorld, bad, list, nil)
	end
	send("spreadCarriedStackOverSlots", badWorld, bad, nil, nil)
	send("spreadCarriedStackOverSlots", badWorld, bad)
	check(
		inSlot(bad, 8) == nil and inSlot(bad, 9) == nil and is(carriedBy(bad), "log", 12),
		"spreadCarriedStackOverSlots: ignored with what is not a list of slots of the screen, even when part of it is"
	)

	local tooMany = {}
	for _ = 1, PlayerState.PACK_SLOT_COUNT + 1 do
		table.insert(tooMany, at2("pack", 8))
	end
	send("spreadCarriedStackOverSlots", badWorld, bad, tooMany, nil)
	check(inSlot(bad, 8) == nil, "spreadCarriedStackOverSlots: ignored with more slots listed than the screen has")
	table.remove(tooMany)
	send("spreadCarriedStackOverSlots", badWorld, bad, tooMany, nil)
	check(
		is(inSlot(bad, 8), "log", 12) and carriedBy(bad) == nil,
		"spreadCarriedStackOverSlots: but as many as the screen has is a spread, and a slot listed twice counts once"
	)

	local crateWorld, withCrate = newWorld()
	local crate = openPlaced(crateWorld, withCrate, "crate")
	send("pickUpFromSlot", crateWorld, withCrate, "pack", 2)
	local long = {}
	for _ = 1, PlayerState.PACK_SLOT_COUNT + crate.slotCount + 1 do
		table.insert(long, at2("other", 2))
	end
	send("spreadCarriedStackOverSlots", crateWorld, withCrate, long, nil)
	check(
		Inventory.isEmpty(crate),
		"spreadCarriedStackOverSlots: with a crate open, ignored with more slots listed than the two have"
	)
	table.remove(long)
	send("spreadCarriedStackOverSlots", crateWorld, withCrate, long, nil)
	check(
		is(Inventory.getStack(crate, 2), "fish", 5),
		"spreadCarriedStackOverSlots: but as many as the pack and the crate have is a spread, here into the crate"
	)

	local ovenWorld, withOven = newWorld()
	local oven = openPlaced(ovenWorld, withOven, "oven")
	send("pickUpFromSlot", ovenWorld, withOven, "pack", 1)
	send("spreadCarriedStackOverSlots", ovenWorld, withOven, { at2("other", 1), at2("other", 2), at2("other", 3) }, nil)
	check(
		Inventory.getStack(oven, 1) == nil
			and is(Inventory.getStack(oven, 2), "log", 12)
			and Inventory.getStack(oven, 3) == nil,
		"spreadCarriedStackOverSlots: only the slots that accept the carried item take part"
	)
end

do -- dropCarriedStack
	local world, state = newWorld()
	send("dropCarriedStack", world, state, ALONG_X, 1)
	check(onGround(world, "log") == 0, "dropCarriedStack: does nothing when no screen is open")

	send("openPack", world, state)
	send("dropCarriedStack", world, state, ALONG_X, 1)
	check(onGround(world, "log") == 0, "dropCarriedStack: does nothing when nothing is carried")

	send("pickUpFromSlot", world, state, "pack", 1)
	send("dropCarriedStack", world, state, ALONG_X, 5)
	check(
		onGround(world, "log") == 5 and is(carriedBy(state), "log", 7),
		"dropCarriedStack: puts that many of the carried items on the ground"
	)
	local landed = next(world.groundItems.itemsById)
	local groundItem = world.groundItems.itemsById[landed :: number]
	check(
		groundItem.position.x == 6
			and groundItem.position.y == World.CHARACTER_THROW_START_HEIGHT
			and groundItem.spawnVelocity.x == World.CHARACTER_THROW_FORWARD_SPEED,
		"dropCarriedStack: thrown from the player's character, the way the direction points"
	)
	check(groundItem.spawnTime == 100, "dropCarriedStack: dropped at the world's time")
	send("dropCarriedStack", world, state, ALONG_X, 0)
	check(
		onGround(world, "log") == 5 and is(carriedBy(state), "log", 7),
		"dropCarriedStack: a count of 0 drops nothing"
	)
	for _, bad in badCounts do
		send("dropCarriedStack", world, state, ALONG_X, bad)
	end
	check(
		onGround(world, "log") == 5 and is(carriedBy(state), "log", 7),
		"dropCarriedStack: ignored with a count that is not a whole number of 0 or more"
	)
	send("dropCarriedStack", world, state, ALONG_X, 99)
	check(
		onGround(world, "log") == 12 and carriedBy(state) == nil,
		"dropCarriedStack: a count of more than is carried drops all of it"
	)

	local allWorld, all = newWorld()
	send("openPack", allWorld, all)
	send("pickUpFromSlot", allWorld, all, "pack", 1)
	send("dropCarriedStack", allWorld, all, ALONG_X, nil)
	check(onGround(allWorld, "log") == 12 and carriedBy(all) == nil, "dropCarriedStack: with no count drops all of it")
	send("dropCarriedStack", allWorld, all, ALONG_X)
	check(onGround(allWorld, "log") == 12, "dropCarriedStack: and again drops nothing")

	local movedWorld, moved = newWorld()
	World.setCharacterPosition(movedWorld, 1, at(1, 0, 1))
	send("openPack", movedWorld, moved)
	send("pickUpFromSlot", movedWorld, moved, "pack", 1)
	send("dropCarriedStack", movedWorld, moved, { x = 0, y = 0, z = 1 }, nil)
	local movedItem = movedWorld.groundItems.itemsById[next(movedWorld.groundItems.itemsById) :: number]
	check(
		movedItem.position.x == 1
			and movedItem.position.y == World.CHARACTER_THROW_START_HEIGHT
			and movedItem.spawnVelocity.z == World.CHARACTER_THROW_FORWARD_SPEED,
		"dropCarriedStack: throws from the player's character where it is now, the way the direction points"
	)
	send("openPack", movedWorld, moved)
	send("pickUpFromSlot", movedWorld, moved, "pack", 10)
	World.removeCharacter(movedWorld, 1)
	check(
		moved.screen == nil and Inventory.countItems(moved.pack, "log") == 4,
		"dropCarriedStack: (set up) a player who loses their character has their screen closed, the carried stack back in the pack"
	)
	send("openPack", movedWorld, moved)
	send("dropCarriedStack", movedWorld, moved, ALONG_X, nil)
	send("dropFromSlot", movedWorld, moved, "pack", 10, ALONG_X, nil)
	send("dropFromSelectedSlot", movedWorld, moved, ALONG_X, nil)
	check(
		moved.screen == nil and onGround(movedWorld, "log") == 12 and Inventory.countItems(moved.pack, "log") == 4,
		"a player with no character can open no screen and drop nothing"
	)
end

do -- dropFromSlot
	local world, state = newWorld()
	send("dropFromSlot", world, state, "pack", 1, ALONG_X, 1)
	check(
		onGround(world, "log") == 0 and is(inSlot(state, 1), "log", 12),
		"dropFromSlot: does nothing when no screen is open"
	)

	send("openPack", world, state)
	send("dropFromSlot", world, state, "pack", 1, ALONG_X, 1)
	check(
		onGround(world, "log") == 1 and is(inSlot(state, 1), "log", 11),
		"dropFromSlot: puts that many items out of the slot on the ground"
	)
	local landed = world.groundItems.itemsById[next(world.groundItems.itemsById) :: number]
	check(
		landed.position.x == 6
			and landed.position.y == World.CHARACTER_THROW_START_HEIGHT
			and landed.spawnVelocity.x == World.CHARACTER_THROW_FORWARD_SPEED
			and landed.spawnTime == 100,
		"dropFromSlot: thrown from the player's character, at the world's time"
	)
	send("dropFromSlot", world, state, "pack", 1, ALONG_X, 99)
	check(
		onGround(world, "log") == 12 and inSlot(state, 1) == nil,
		"dropFromSlot: a count of more than the slot holds drops all of it"
	)
	send("dropFromSlot", world, state, "pack", 2, ALONG_X)
	check(
		onGround(world, "fish") == 5 and inSlot(state, 2) == nil,
		"dropFromSlot: with no count drops everything in the slot"
	)
	send("dropFromSlot", world, state, "pack", 2, ALONG_X)
	send("dropFromSlot", world, state, "pack", 3, ALONG_X, 1)
	check(onGround(world, "fish") == 5, "dropFromSlot: a slot that holds nothing drops nothing")
	send("dropFromSlot", world, state, "pack", 10, ALONG_X, 0)
	check(is(inSlot(state, 10), "log", 4), "dropFromSlot: a count of 0 drops nothing")
	for _, bad in badCounts do
		send("dropFromSlot", world, state, "pack", 10, ALONG_X, bad)
	end
	for _, side in { "other", "Pack", "", 1, true, {} } :: { any } do
		send("dropFromSlot", world, state, side, 10, ALONG_X, 1)
	end
	for _, slot in { 0, -1, 37, 99, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		send("dropFromSlot", world, state, "pack", slot, ALONG_X, 1)
	end
	send("dropFromSlot", world, state)
	check(
		is(inSlot(state, 10), "log", 4) and onGround(world, "log") == 12,
		"dropFromSlot: ignored for a count that is not a whole number of 0 or more, or a side or slot that is not there"
	)

	send("pickUpFromSlot", world, state, "pack", 10)
	send("dropFromSlot", world, state, "pack", 10, ALONG_X, 1)
	check(is(carriedBy(state), "log", 4), "dropFromSlot: what is carried is not dropped")

	local crateWorld, withCrate = newWorld()
	local crate = openPlaced(crateWorld, withCrate, "crate")
	Inventory.setStack(crate, 3, ItemStack.new("fish", 4))
	send("dropFromSlot", crateWorld, withCrate, "other", 3, ALONG_X, 3)
	check(
		onGround(crateWorld, "fish") == 3 and is(Inventory.getStack(crate, 3), "fish", 1),
		"dropFromSlot: drops out of the other inventory too"
	)
end

do -- selectHotbarSlot
	local world, state = newWorld()
	send("selectHotbarSlot", world, state, 2)
	check(state.hotbar.selectedSlot == 2, "selectHotbarSlot: selects the slot, with no screen open")
	check(is(Hotbar.getSelectedStack(state.hotbar), "fish", 5), "selectHotbarSlot: and what it holds is then in hand")
	for _, bad in { 0, 10, 36, -1, 2.5, 0 / 0, math.huge, -math.huge, "3", true, {} } :: { any } do
		send("selectHotbarSlot", world, state, bad)
	end
	send("selectHotbarSlot", world, state)
	check(state.hotbar.selectedSlot == 2, "selectHotbarSlot: ignored for anything that is not a slot of the hotbar")
	send("selectHotbarSlot", world, state, 9)
	check(state.hotbar.selectedSlot == 9, "selectHotbarSlot: the last slot of the hotbar can be selected")
	send("selectHotbarSlot", world, state, 1)
	check(state.hotbar.selectedSlot == 1, "selectHotbarSlot: and the first")
	send("openPack", world, state)
	send("selectHotbarSlot", world, state, 3)
	check(state.hotbar.selectedSlot == 3, "selectHotbarSlot: also while a screen is open")
end

do -- the direction a drop is thrown in
	local badDirections: { any } = {
		false,
		"x",
		7,
		{},
		{ x = 1 },
		{ x = 1, z = 0 },
		{ x = 1, y = 0 },
		{ y = 1, z = 0 },
		{ x = 0, y = 0, z = 0 },
		{ x = 2, y = 0, z = 0 },
		{ x = 0, y = 0, z = -1.5 },
		{ x = 0, y = 1.5, z = 0 },
		{ x = 1, y = -2, z = 1 },
		{ x = 0 / 0, y = 0, z = 1 },
		{ x = 1, y = 0 / 0, z = 0 },
		{ x = 1, y = 0, z = 0 / 0 },
		{ x = math.huge, y = 0, z = 0 },
		{ x = 0, y = -math.huge, z = 0 },
		{ x = 0, y = 0, z = math.huge },
		{ x = "1", y = 0, z = 0 },
		{ x = 1, y = "0", z = 0 },
		{ x = 1, y = 0, z = "0" },
	}
	for _, bad in badDirections do
		local world, state = newWorld()
		send("dropFromSelectedSlot", world, state, bad, 1)
		send("openPack", world, state)
		send("dropFromSlot", world, state, "pack", 1, bad, 1)
		send("pickUpFromSlot", world, state, "pack", 1)
		send("dropCarriedStack", world, state, bad, 1)
		check(
			onGround(world, "log") == 0 and is(carriedBy(state), "log", 12),
			"a drop with a direction that is not three numbers from -1 to 1, not all 0, drops nothing"
		)
	end

	local world, state = newWorld()
	send("dropFromSelectedSlot", world, state, { x = 0.3, y = 0, z = -0.4 }, 1)
	local thrown = world.groundItems.itemsById[next(world.groundItems.itemsById) :: number]
	check(
		math.abs(thrown.spawnVelocity.x - 0.6 * World.CHARACTER_THROW_FORWARD_SPEED) < 1e-9
			and math.abs(thrown.spawnVelocity.z + 0.8 * World.CHARACTER_THROW_FORWARD_SPEED) < 1e-9
			and thrown.spawnVelocity.y == World.CHARACTER_THROW_UPWARD_SPEED,
		"a drop is thrown at full speed the way its direction points, whatever the direction's length"
	)
	check(is(inSlot(state, 1), "log", 11), "a drop with a short direction still takes the item from the slot")

	-- A direction that points up or down throws up or down.
	local upWorld, upState = newWorld()
	send("dropFromSelectedSlot", upWorld, upState, { x = 0.3, y = 0.4, z = 0 }, 1)
	local thrownUp = upWorld.groundItems.itemsById[next(upWorld.groundItems.itemsById) :: number]
	check(
		math.abs(thrownUp.spawnVelocity.x - 0.6 * World.CHARACTER_THROW_FORWARD_SPEED) < 1e-9
			and math.abs(
				thrownUp.spawnVelocity.y
					- (0.8 * World.CHARACTER_THROW_FORWARD_SPEED + World.CHARACTER_THROW_UPWARD_SPEED)
			) < 1e-9
			and thrownUp.spawnVelocity.z == 0,
		"a drop with a direction that points up is thrown up, the way the direction points"
	)
	local downWorld, downState = newWorld()
	send("dropFromSelectedSlot", downWorld, downState, { x = 0, y = -0.5, z = 0 }, 1)
	local thrownDown = downWorld.groundItems.itemsById[next(downWorld.groundItems.itemsById) :: number]
	check(
		thrownDown.spawnVelocity.x == 0
			and thrownDown.spawnVelocity.y == World.CHARACTER_THROW_UPWARD_SPEED - World.CHARACTER_THROW_FORWARD_SPEED
			and thrownDown.spawnVelocity.z == 0,
		"a drop with a direction straight down is thrown straight down"
	)

	local edgeWorld, edgeState = newWorld()
	local edgeDirections = {
		{ x = -1, y = 0, z = 0 },
		{ x = 0, y = 0, z = 1 },
		{ x = 0, y = -1, z = 0 },
		{ x = 1, y = 1, z = 1 },
		{ x = -1, y = 1, z = -1 },
		{ x = 2.7e-162, y = 0, z = 0 },
		{ x = 0, y = 2.7e-162, z = 0 },
	}
	for _, direction in edgeDirections do
		send("dropFromSelectedSlot", edgeWorld, edgeState, direction, 1)
	end
	local speeds = {}
	for _, groundItem in edgeWorld.groundItems.itemsById do
		local velocity = groundItem.spawnVelocity
		local alongThrow = velocity.y - World.CHARACTER_THROW_UPWARD_SPEED
		table.insert(speeds, math.sqrt(velocity.x ^ 2 + alongThrow ^ 2 + velocity.z ^ 2))
	end
	check(
		#speeds == #edgeDirections,
		"a drop with a direction of exactly -1 or 1 along any axis, or a very faint one, is thrown"
	)
	for _, speed in speeds do
		check(
			math.abs(speed - World.CHARACTER_THROW_FORWARD_SPEED) < 1e-9,
			"no direction a player's machine can send throws faster or slower than a throw goes, the upward speed aside"
		)
	end
end

do -- dropFromSelectedSlot
	local world, state = newWorld()
	send("dropFromSelectedSlot", world, state, ALONG_X, 1)
	check(
		is(inSlot(state, 1), "log", 11) and onGround(world, "log") == 1,
		"dropFromSelectedSlot: puts that many of what is in hand on the ground"
	)
	local landed = world.groundItems.itemsById[next(world.groundItems.itemsById) :: number]
	check(
		landed.position.x == 6
			and landed.position.y == World.CHARACTER_THROW_START_HEIGHT
			and landed.spawnVelocity.x == World.CHARACTER_THROW_FORWARD_SPEED
			and landed.spawnTime == 100,
		"dropFromSelectedSlot: thrown from the player's character, at the world's time"
	)
	send("dropFromSelectedSlot", world, state, ALONG_X, 99)
	check(
		inSlot(state, 1) == nil and onGround(world, "log") == 12,
		"dropFromSelectedSlot: a count of more than is in hand drops all of it"
	)
	send("dropFromSelectedSlot", world, state, ALONG_X, 1)
	send("dropFromSelectedSlot", world, state, ALONG_X, nil)
	check(onGround(world, "log") == 12, "dropFromSelectedSlot: an empty hand drops nothing")

	send("selectHotbarSlot", world, state, 10)
	send("selectHotbarSlot", world, state, 9)
	Inventory.setStack(state.pack, 9, ItemStack.new("fish", 7))
	send("dropFromSelectedSlot", world, state, ALONG_X)
	check(
		onGround(world, "fish") == 7 and inSlot(state, 9) == nil,
		"dropFromSelectedSlot: with no count drops the whole stack in hand"
	)

	local zeroWorld, zero = newWorld()
	send("dropFromSelectedSlot", zeroWorld, zero, ALONG_X, 0)
	for _, bad in badCounts do
		send("dropFromSelectedSlot", zeroWorld, zero, ALONG_X, bad)
	end
	check(
		is(inSlot(zero, 1), "log", 12) and onGround(zeroWorld, "log") == 0,
		"dropFromSelectedSlot: a count of 0, or one that is not a whole number of 0 or more, drops nothing"
	)
	send("openPack", zeroWorld, zero)
	send("dropFromSelectedSlot", zeroWorld, zero, ALONG_X, 2)
	check(
		is(inSlot(zero, 1), "log", 10) and onGround(zeroWorld, "log") == 2,
		"dropFromSelectedSlot: works while a screen is open too"
	)
end

do -- whatever a player's machine sends, nothing raises an error and no item is made or lost
	local seed = 771
	local function random(limit: number): number
		seed = (seed * 16807) % 2147483647
		return math.floor(seed / 8) % limit + 1
	end
	local junk: { any } = {
		-1,
		0,
		0.5,
		1e300,
		-1e300,
		0 / 0,
		math.huge,
		-math.huge,
		"",
		"pack",
		"other",
		"1",
		true,
		false,
		{},
		{ 1 },
		{ side = "pack" },
	}
	-- One thing a request might be sent with: mostly what a real screen would send, sometimes junk or nothing.
	local function argument(): any
		local kind = random(10)
		if kind <= 3 then
			return if random(4) == 1 then "other" else "pack"
		elseif kind <= 6 then
			return random(40)
		elseif kind == 7 then
			return nil
		elseif kind == 8 then
			-- The slots of a spread: mostly ones a screen might have, now and then with junk among them.
			local screenSlots: { any } = {}
			for _ = 1, random(5) do
				local screenSlot: any = { side = if random(4) == 1 then "other" else "pack", slot = random(40) }
				table.insert(screenSlots, if random(8) == 1 then junk[random(#junk)] else screenSlot)
			end
			return screenSlots
		elseif kind == 9 then
			-- The slot numbers to add a stack to: mostly ones an inventory might have, now and then with junk among them.
			local slotNumbers: { any } = {}
			for _ = 1, random(5) do
				table.insert(slotNumbers, if random(8) == 1 then junk[random(#junk)] else random(40))
			end
			return slotNumbers
		end
		return junk[random(#junk)]
	end
	local names: { string } = {}
	for name in requests do
		table.insert(names, name)
	end
	table.sort(names)

	local errors, firstError = 0, ""
	local allConserved, allValid = true, true
	for _ = 1, 40 do
		local world, state = newWorld()
		World.setCharacterPosition(world, 1, at(6, 0, 0))
		local crateId = place(world, "crate", 6, 6)
		local ovenId = place(world, "oven", 6, 5)
		local crate = insideOf(world, crateId)
		for _ = 1, 10 do
			local itemId = itemIds[random(#itemIds)]
			local target = if random(3) == 1 then crate else state.pack
			Inventory.addItems(target, itemId, random(ItemRegistry.get(itemId).stackSize))
		end
		local total: { [string]: number } = {}
		for _, itemId in itemIds do
			total[itemId] = inWorld(world, itemId)
		end
		for _ = 1, 300 do
			-- Now and then the world itself opens a screen for the player, as using a placed object would.
			if state.screen == nil and random(12) == 1 then
				open(world, state, if random(2) == 1 then crateId else ovenId)
			end
			local name = names[random(#names)]
			local ok, result =
				pcall(send, name, world, state, argument(), argument(), argument(), argument(), argument())
			if not ok then
				errors += 1
				firstError = if firstError == "" then name .. ": " .. tostring(result) else firstError
			end
			for _, itemId in itemIds do
				if inWorld(world, itemId) ~= total[itemId] then
					allConserved = false
				end
			end
			for _, inventory in { state.pack, crate, insideOf(world, ovenId) } do
				for slot, stack in inventory.slots do
					if ItemStack.validate(stack) ~= nil or not Inventory.hasSlot(inventory, slot) then
						allValid = false
					end
				end
			end
			local carried = if state.screen then state.screen.carriedStack else nil
			if carried ~= nil and ItemStack.validate(carried) ~= nil then
				allValid = false
			end
		end
	end
	check(errors == 0, "random run: none of 12,000 requests raises an error (first: " .. firstError .. ")")
	check(
		allConserved,
		"random run: after every request every item is in a pack, carried, standing on the plot, inside it, or on the ground"
	)
	check(allValid, "random run: every stack in a pack or a placed object is a valid stack in a slot that exists")
end

Check.finish("InventoryRequests")
