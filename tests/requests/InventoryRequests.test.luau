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
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")
local World = require("../../src/shared/world/World")

local check = Check.that

ItemRegistry.register({ id = "log", stackSize = 16, burnSeconds = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "cooked_fish", stackSize = 8 })
ItemRegistry.register({ id = "stove", stackSize = 1 })
ItemRegistry.register({ id = "crate", stackSize = 1, placeable = true, slotCount = 3 })
ItemRegistry.register({ id = "oven", stackSize = 1, placeable = true, slotCount = 3 })
RecipeRegistry.register({ station = "oven", input = "fish", output = "cooked_fish", seconds = 8 })

local itemIds = { "log", "fish", "cooked_fish", "stove", "crate", "oven" }
local at = Position.new

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
	local state = World.addPlayer(world, 1, at(12, 0, 0))
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
	return screenOf(state).carried
end

-- Places the item `itemId` on tile 6, 6, opens it on the player's screen beside their pack, and
-- returns what is inside it.
local function openPlaced(world: World.World, state: PlayerState.PlayerState, itemId: string): Inventory.Inventory
	local placedId = World.placeItem(world, itemId, 6, 6) :: number
	World.openPlaced(world, state, placedId)
	return world.plot.placedById[placedId].inventory :: Inventory.Inventory
end

-- How many of one item lie on the ground, in all.
local function onGround(world: World.World, itemId: string): number
	local count = 0
	for _, groundItem in world.groundItems.byId do
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
		if screen ~= nil and screen.carried ~= nil and screen.carried.itemId == itemId then
			count += screen.carried.count
		end
	end
	for _, placedItem in world.plot.placedById do
		if placedItem.itemId == itemId then
			count += 1
		end
		if placedItem.inventory ~= nil then
			count += Inventory.countItems(placedItem.inventory, itemId)
		end
	end
	return count
end

do -- openPack
	local world, state = newWorld()
	send("openPack", world, state)
	local screen = screenOf(state)
	check(screen.pack == state.pack, "openPack: opens a screen on the player's pack")
	check(screen.other == nil and screen.carried == nil, "openPack: with no other inventory and nothing carried")
	send("openPack", world, state)
	check(state.screen == screen, "openPack: does nothing when a screen is already open")

	local crateWorld, crateState = newWorld()
	local crate = openPlaced(crateWorld, crateState, "crate")
	send("openPack", crateWorld, crateState)
	check(screenOf(crateState).other == crate, "openPack: leaves a crate that is open beside the pack")
end

do -- closeScreen
	local world, state = newWorld()
	send("closeScreen", world, state)
	check(state.screen == nil and onGround(world, "log") == 0, "closeScreen: does nothing when no screen is open")

	send("openPack", world, state)
	send("closeScreen", world, state)
	check(state.screen == nil, "closeScreen: closes the screen")

	send("openPack", world, state)
	send("pickUp", world, state, "pack", 1)
	send("closeScreen", world, state)
	check(
		Inventory.countItems(state.pack, "log") == 16 and state.screen == nil,
		"closeScreen: the carried stack goes back into the pack"
	)
	check(onGround(world, "log") == 0, "closeScreen: and nothing lands on the ground when it fits")

	local fullWorld, full = newWorld()
	send("openPack", fullWorld, full)
	send("pickUp", fullWorld, full, "pack", 1)
	for slot = 1, PlayerState.PACK_SLOTS do
		Inventory.setStack(full.pack, slot, ItemStack.new("stove", 1))
	end
	send("closeScreen", fullWorld, full)
	check(
		full.screen == nil and onGround(fullWorld, "log") == 12,
		"closeScreen: what does not fit in the pack lands on the ground"
	)
	for _, groundItem in fullWorld.groundItems.byId do
		check(
			groundItem.position.x == 12 and groundItem.position.z == 0 and groundItem.droppedAt == 100,
			"closeScreen: it lands at the player's drop position, at the world's time"
		)
	end

	local placedWorld, placedState = newWorld()
	openPlaced(placedWorld, placedState, "crate")
	send("closeScreen", placedWorld, placedState)
	check(
		placedState.screen == nil and placedState.openedPlacedId == nil,
		"closeScreen: a player who had a crate open has nothing open any more"
	)
end

do -- pickUp
	local world, state = newWorld()
	send("pickUp", world, state, "pack", 1, 5)
	check(is(inSlot(state, 1), "log", 12) and state.screen == nil, "pickUp: does nothing when no screen is open")

	send("openPack", world, state)
	send("pickUp", world, state, "pack", 1, 5)
	check(
		is(carriedBy(state), "log", 5) and is(inSlot(state, 1), "log", 7),
		"pickUp: moves that many items from the slot onto the carried stack"
	)
	send("pickUp", world, state, "pack", 10, nil)
	check(
		is(carriedBy(state), "log", 9) and inSlot(state, 10) == nil,
		"pickUp: with no count moves everything in the slot when there is room for it"
	)
	send("pickUp", world, state, "pack", 1, nil)
	check(
		is(carriedBy(state), "log", 16) and inSlot(state, 1) == nil,
		"pickUp: with no count moves what the carried stack has room for, here all of what the slot held"
	)
	Inventory.setStack(state.pack, 7, ItemStack.new("log", 9))
	send("pickUp", world, state, "pack", 7, nil)
	check(
		is(carriedBy(state), "log", 16) and is(inSlot(state, 7), "log", 9),
		"pickUp: a full carried stack takes nothing more"
	)
	send("pickUp", world, state, "pack", 2, nil)
	check(
		is(inSlot(state, 2), "fish", 5),
		"pickUp: nothing moves from a slot that holds another item than the carried one"
	)
	send("pickUp", world, state, "pack", 3, nil)
	check(is(carriedBy(state), "log", 16), "pickUp: nothing moves from a slot that holds nothing")

	local topWorld, top = newWorld()
	send("openPack", topWorld, top)
	send("pickUp", topWorld, top, "pack", 1, 10)
	send("pickUp", topWorld, top, "pack", 10, nil)
	send("pickUp", topWorld, top, "pack", 1, nil)
	check(
		is(carriedBy(top), "log", 16) and inSlot(top, 1) == nil and inSlot(top, 10) == nil,
		"pickUp: stacks of the same item are gathered up to the stack size"
	)
	Inventory.setStack(top.pack, 4, ItemStack.new("log", 9))
	send("pickUp", topWorld, top, "pack", 4, 3)
	check(is(inSlot(top, 4), "log", 9), "pickUp: a count that does not fit moves nothing")

	local moreWorld, more = newWorld()
	send("openPack", moreWorld, more)
	send("pickUp", moreWorld, more, "pack", 2, 99)
	check(
		is(carriedBy(more), "fish", 5) and inSlot(more, 2) == nil,
		"pickUp: a count of more than the slot holds moves what it holds"
	)

	local zeroWorld, zero = newWorld()
	send("openPack", zeroWorld, zero)
	send("pickUp", zeroWorld, zero, "pack", 1, 0)
	check(carriedBy(zero) == nil and is(inSlot(zero, 1), "log", 12), "pickUp: a count of 0 moves nothing")

	for _, bad in badCounts do
		send("pickUp", zeroWorld, zero, "pack", 1, bad)
		check(
			carriedBy(zero) == nil and is(inSlot(zero, 1), "log", 12),
			"pickUp: moves nothing with the count " .. tostring(bad)
		)
	end
	for _, side in { "other", "Pack", "", 1, true, {} } :: { any } do
		send("pickUp", zeroWorld, zero, side, 1, nil)
	end
	for _, slot in { 0, -1, 37, 99, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		send("pickUp", zeroWorld, zero, "pack", slot, nil)
	end
	send("pickUp", zeroWorld, zero)
	send("pickUp", zeroWorld, zero, "pack")
	check(
		carriedBy(zero) == nil and inWorld(zeroWorld, "log") == 16,
		"pickUp: moves nothing for a side that is not there, a slot that is not there, or nothing at all"
	)

	local crateWorld, withCrate = newWorld()
	local crate = openPlaced(crateWorld, withCrate, "crate")
	Inventory.setStack(crate, 2, ItemStack.new("fish", 3))
	send("pickUp", crateWorld, withCrate, "other", 2, 2)
	check(
		is(carriedBy(withCrate), "fish", 2) and is(Inventory.getStack(crate, 2), "fish", 1),
		"pickUp: takes from the other inventory too"
	)
	send("pickUp", crateWorld, withCrate, "other", 4, nil)
	check(is(carriedBy(withCrate), "fish", 2), "pickUp: not from a slot the other inventory lacks")
end

do -- putDown
	local world, state = newWorld()
	send("putDown", world, state, "pack", 3, 1)
	check(inSlot(state, 3) == nil, "putDown: does nothing when no screen is open")

	send("openPack", world, state)
	send("putDown", world, state, "pack", 3, 1)
	check(inSlot(state, 3) == nil, "putDown: does nothing when nothing is carried")

	send("pickUp", world, state, "pack", 1)
	send("putDown", world, state, "pack", 3, 5)
	check(
		is(inSlot(state, 3), "log", 5) and is(carriedBy(state), "log", 7),
		"putDown: moves that many items from the carried stack into the slot"
	)
	send("putDown", world, state, "pack", 2, nil)
	check(
		is(inSlot(state, 2), "fish", 5) and is(carriedBy(state), "log", 7),
		"putDown: nothing goes into a slot that holds another item"
	)
	Inventory.setStack(state.pack, 5, ItemStack.new("log", 12))
	send("putDown", world, state, "pack", 5, nil)
	check(
		is(inSlot(state, 5), "log", 16) and is(carriedBy(state), "log", 3),
		"putDown: with no count moves only what the slot has room for"
	)
	send("putDown", world, state, "pack", 3, 99)
	check(
		is(inSlot(state, 3), "log", 8) and carriedBy(state) == nil,
		"putDown: a count of more than is carried moves all of what is carried"
	)

	local zeroWorld, zero = newWorld()
	send("openPack", zeroWorld, zero)
	send("pickUp", zeroWorld, zero, "pack", 1)
	send("putDown", zeroWorld, zero, "pack", 3, 0)
	check(inSlot(zero, 3) == nil and is(carriedBy(zero), "log", 12), "putDown: a count of 0 moves nothing")
	for _, bad in badCounts do
		send("putDown", zeroWorld, zero, "pack", 3, bad)
		check(
			inSlot(zero, 3) == nil and is(carriedBy(zero), "log", 12),
			"putDown: moves nothing with the count " .. tostring(bad)
		)
	end
	for _, side in { "other", "Pack", "", 1, true, {} } :: { any } do
		send("putDown", zeroWorld, zero, side, 3, nil)
	end
	for _, slot in { 0, -1, 37, 99, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		send("putDown", zeroWorld, zero, "pack", slot, nil)
	end
	send("putDown", zeroWorld, zero)
	check(
		is(carriedBy(zero), "log", 12) and inWorld(zeroWorld, "log") == 16,
		"putDown: moves nothing into a slot that is not there, or with nothing at all"
	)

	local ovenWorld, withOven = newWorld()
	local oven = openPlaced(ovenWorld, withOven, "oven")
	send("pickUp", ovenWorld, withOven, "pack", 1)
	send("putDown", ovenWorld, withOven, "other", 1, nil)
	send("putDown", ovenWorld, withOven, "other", 3, nil)
	check(
		Inventory.isEmpty(oven) and is(carriedBy(withOven), "log", 12),
		"putDown: an oven's input slot takes no logs and its output slot takes nothing"
	)
	send("putDown", ovenWorld, withOven, "other", 2, 5)
	check(
		is(Inventory.getStack(oven, 2), "log", 5) and is(carriedBy(withOven), "log", 7),
		"putDown: an oven's fuel slot takes logs"
	)
end

do -- swapCarried
	local world, state = newWorld()
	send("swapCarried", world, state, "pack", 1)
	check(is(inSlot(state, 1), "log", 12) and state.screen == nil, "swapCarried: does nothing when no screen is open")

	send("openPack", world, state)
	send("swapCarried", world, state, "pack", 1)
	check(
		is(carriedBy(state), "log", 12) and inSlot(state, 1) == nil,
		"swapCarried: with nothing carried, the slot's whole stack becomes the carried stack"
	)
	send("swapCarried", world, state, "pack", 2)
	check(
		is(inSlot(state, 2), "log", 12) and is(carriedBy(state), "fish", 5),
		"swapCarried: exchanges the carried stack with the slot's stack"
	)
	send("swapCarried", world, state, "pack", 10)
	check(
		is(inSlot(state, 10), "fish", 5) and is(carriedBy(state), "log", 4),
		"swapCarried: exchanges rather than merges stacks of different items"
	)
	send("swapCarried", world, state, "pack", 2)
	check(
		is(inSlot(state, 2), "log", 4) and is(carriedBy(state), "log", 12),
		"swapCarried: exchanges rather than merges stacks of the same item"
	)
	send("swapCarried", world, state, "pack", 3)
	check(
		is(inSlot(state, 3), "log", 12) and carriedBy(state) == nil,
		"swapCarried: a slot that holds nothing takes the carried stack"
	)
	send("swapCarried", world, state, "pack", 4)
	check(
		inSlot(state, 4) == nil and carriedBy(state) == nil,
		"swapCarried: with nothing on either side, nothing happens"
	)
	for _, side in { "other", "Pack", "", 1, true, {} } :: { any } do
		send("swapCarried", world, state, side, 3)
	end
	for _, slot in { 0, -1, 37, 99, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		send("swapCarried", world, state, "pack", slot)
	end
	send("swapCarried", world, state)
	check(
		is(inSlot(state, 3), "log", 12) and carriedBy(state) == nil,
		"swapCarried: ignored for a side or slot that is not there, or nothing at all"
	)

	local ovenWorld, withOven = newWorld()
	local oven = openPlaced(ovenWorld, withOven, "oven")
	send("pickUp", ovenWorld, withOven, "pack", 1)
	send("swapCarried", ovenWorld, withOven, "other", 1)
	check(
		Inventory.isEmpty(oven) and is(carriedBy(withOven), "log", 12),
		"swapCarried: changes nothing when the slot does not accept what is carried"
	)
	send("swapCarried", ovenWorld, withOven, "other", 2)
	check(
		is(Inventory.getStack(oven, 2), "log", 12) and carriedBy(withOven) == nil,
		"swapCarried: but does when it does"
	)
	send("swapCarried", ovenWorld, withOven, "other", 2)
	check(
		Inventory.isEmpty(oven) and is(carriedBy(withOven), "log", 12),
		"swapCarried: and takes what a slot holds back out"
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

do -- moveStack
	local world, state = newWorld()
	send("moveStack", world, state, "pack", 1, "pack", 20, 22)
	check(is(inSlot(state, 1), "log", 12), "moveStack: does nothing when no screen is open")

	send("openPack", world, state)
	send("moveStack", world, state, "pack", 1, "pack", 20, 22)
	check(
		inSlot(state, 1) == nil and is(inSlot(state, 20), "log", 12) and inSlot(state, 21) == nil,
		"moveStack: moves the stack into the first slot of the range that holds nothing"
	)
	send("moveStack", world, state, "pack", 10, "pack", 18, 20)
	check(
		inSlot(state, 10) == nil and is(inSlot(state, 20), "log", 16) and inSlot(state, 18) == nil,
		"moveStack: tops up a stack of the same item before filling a slot that holds nothing"
	)
	send("moveStack", world, state, "pack", 2, "pack", 20, 22)
	check(
		inSlot(state, 2) == nil and is(inSlot(state, 20), "log", 16) and is(inSlot(state, 21), "fish", 5),
		"moveStack: a different item goes past a stack of another item into a slot that holds nothing"
	)
	send("moveStack", world, state, "pack", 4, "pack", 1, 3)
	check(inSlot(state, 4) == nil and inSlot(state, 1) == nil, "moveStack: a slot that holds nothing moves nothing")

	local splitWorld, split = newWorld()
	send("openPack", splitWorld, split)
	Inventory.setStack(split.pack, 20, ItemStack.new("log", 14))
	send("moveStack", splitWorld, split, "pack", 1, "pack", 20, 21)
	check(
		is(inSlot(split, 20), "log", 16) and is(inSlot(split, 21), "log", 10) and inSlot(split, 1) == nil,
		"moveStack: fills one slot and puts the rest in the next"
	)
	local shortWorld, short = newWorld()
	send("openPack", shortWorld, short)
	Inventory.setStack(short.pack, 20, ItemStack.new("log", 14))
	send("moveStack", shortWorld, short, "pack", 1, "pack", 20, 20)
	check(
		is(inSlot(short, 20), "log", 16) and is(inSlot(short, 1), "log", 10),
		"moveStack: what does not fit stays where it was"
	)
	send("moveStack", shortWorld, short, "pack", 1, "pack", 1, 1)
	check(is(inSlot(short, 1), "log", 10), "moveStack: a stack is not moved into its own slot")
	send("moveStack", shortWorld, short, "pack", 1, "pack", 5, 3)
	check(
		is(inSlot(short, 1), "log", 10) and inSlot(short, 4) == nil,
		"moveStack: a range that ends before it begins holds no slots"
	)
	send("moveStack", shortWorld, short, "pack", 1, "pack", 1, 36)
	check(
		inSlot(short, 1) == nil and is(inSlot(short, 10), "log", 14),
		"moveStack: a stack may go anywhere in the range except its own slot, here topping up the stack in slot 10"
	)

	local crateWorld, withCrate = newWorld()
	local crate = openPlaced(crateWorld, withCrate, "crate")
	send("moveStack", crateWorld, withCrate, "pack", 1, "other", 1, 3)
	check(
		inSlot(withCrate, 1) == nil and is(Inventory.getStack(crate, 1), "log", 12),
		"moveStack: moves a stack from the pack into the other inventory"
	)
	send("moveStack", crateWorld, withCrate, "other", 1, "pack", 1, 9)
	check(
		is(inSlot(withCrate, 1), "log", 12) and Inventory.isEmpty(crate),
		"moveStack: moves a stack from the other inventory into the pack"
	)
	send("moveStack", crateWorld, withCrate, "other", 2, "pack", 1, 9)
	check(inWorld(crateWorld, "log") == 16, "moveStack: a slot of the other inventory that holds nothing moves nothing")
	send("moveStack", crateWorld, withCrate, "pack", 1, "other", 2, 99)
	send("moveStack", crateWorld, withCrate, "pack", 1, "other", 0, 3)
	send("moveStack", crateWorld, withCrate, "pack", 1, "other", 1.5, 3)
	send("moveStack", crateWorld, withCrate, "pack", 1, "other", 1, "3")
	send("moveStack", crateWorld, withCrate, "pack", 1, "nowhere", 1, 3)
	send("moveStack", crateWorld, withCrate, "pack", 99, "other", 1, 3)
	send("moveStack", crateWorld, withCrate, "nowhere", 1, "other", 1, 3)
	send("moveStack", crateWorld, withCrate, "pack", 1, "other", 1)
	send("moveStack", crateWorld, withCrate, "pack", 1)
	send("moveStack", crateWorld, withCrate)
	check(
		is(inSlot(withCrate, 1), "log", 12) and Inventory.isEmpty(crate),
		"moveStack: ignored when a slot or the range is not there, or when arguments are missing"
	)

	local ovenWorld, withOven = newWorld()
	local oven = openPlaced(ovenWorld, withOven, "oven")
	send("moveStack", ovenWorld, withOven, "pack", 1, "other", 1, 1)
	check(
		is(inSlot(withOven, 1), "log", 12) and Inventory.isEmpty(oven),
		"moveStack: never into a slot that does not accept the item"
	)
	send("moveStack", ovenWorld, withOven, "pack", 1, "other", 1, 3)
	check(
		inSlot(withOven, 1) == nil and is(Inventory.getStack(oven, 2), "log", 12),
		"moveStack: a stack of logs goes to an oven's fuel slot"
	)
	send("moveStack", ovenWorld, withOven, "pack", 2, "other", 1, 3)
	check(
		inSlot(withOven, 2) == nil and is(Inventory.getStack(oven, 1), "fish", 5),
		"moveStack: and a stack of fish to its input slot"
	)
end

do -- gatherCarried
	local world, state = newWorld()
	send("gatherCarried", world, state)
	check(is(inSlot(state, 1), "log", 12), "gatherCarried: does nothing when no screen is open")

	send("openPack", world, state)
	send("gatherCarried", world, state)
	check(
		carriedBy(state) == nil and inWorld(world, "log") == 16,
		"gatherCarried: does nothing when nothing is carried"
	)

	send("pickUp", world, state, "pack", 10)
	Inventory.setStack(state.pack, 20, ItemStack.new("log", 5))
	send("gatherCarried", world, state)
	check(is(carriedBy(state), "log", 16), "gatherCarried: fills the carried stack with items of its kind")
	check(
		inSlot(state, 1) == nil and is(inSlot(state, 20), "log", 5) and is(inSlot(state, 2), "fish", 5),
		"gatherCarried: from the slots that hold them, lowest first, and from no others"
	)

	local crateWorld, withCrate = newWorld()
	local crate = openPlaced(crateWorld, withCrate, "crate")
	Inventory.setStack(crate, 3, ItemStack.new("log", 3))
	send("pickUp", crateWorld, withCrate, "pack", 10)
	send("gatherCarried", crateWorld, withCrate)
	check(
		is(carriedBy(withCrate), "log", 16) and Inventory.isEmpty(crate) and is(inSlot(withCrate, 1), "log", 3),
		"gatherCarried: gathers from the other inventory too"
	)
end

do -- spreadCarried
	local function at2(side: string, slot: number): { side: string, slot: number }
		return { side = side, slot = slot }
	end
	local world, state = newWorld()
	send("spreadCarried", world, state, { at2("pack", 3), at2("pack", 4) }, nil)
	check(inSlot(state, 3) == nil, "spreadCarried: does nothing when no screen is open")

	send("openPack", world, state)
	send("spreadCarried", world, state, { at2("pack", 3), at2("pack", 4) }, nil)
	check(
		inSlot(state, 3) == nil and is(inSlot(state, 1), "log", 12),
		"spreadCarried: does nothing when nothing is carried"
	)

	send("pickUp", world, state, "pack", 1)
	send("spreadCarried", world, state, { at2("pack", 3), at2("pack", 4), at2("pack", 5) }, nil)
	check(
		is(inSlot(state, 3), "log", 4) and is(inSlot(state, 4), "log", 4) and is(inSlot(state, 5), "log", 4),
		"spreadCarried: with no count each slot gets an equal share"
	)
	check(carriedBy(state) == nil, "spreadCarried: and nothing stays carried when the shares come out even")

	local eachWorld, each = newWorld()
	send("openPack", eachWorld, each)
	send("pickUp", eachWorld, each, "pack", 1)
	send("spreadCarried", eachWorld, each, { at2("pack", 3), at2("pack", 4), at2("pack", 5) }, 1)
	check(
		is(inSlot(each, 3), "log", 1) and is(inSlot(each, 4), "log", 1) and is(inSlot(each, 5), "log", 1),
		"spreadCarried: with a count each slot gets that many"
	)
	check(is(carriedBy(each), "log", 9), "spreadCarried: and the rest stays carried")
	send("spreadCarried", eachWorld, each, { at2("pack", 6), at2("pack", 7) }, nil)
	check(
		is(inSlot(each, 6), "log", 4) and is(inSlot(each, 7), "log", 4) and is(carriedBy(each), "log", 1),
		"spreadCarried: a share is rounded down and the remainder stays carried"
	)
	send("spreadCarried", eachWorld, each, {}, nil)
	check(is(carriedBy(each), "log", 1), "spreadCarried: a list of no slots puts nothing down")
	send("spreadCarried", eachWorld, each, { at2("pack", 8) }, 0)
	check(inSlot(each, 8) == nil and is(carriedBy(each), "log", 1), "spreadCarried: a count of 0 puts nothing down")

	local badWorld, bad = newWorld()
	send("openPack", badWorld, bad)
	send("pickUp", badWorld, bad, "pack", 1)
	for _, count in badCounts do
		send("spreadCarried", badWorld, bad, { at2("pack", 8) }, count)
	end
	check(inSlot(bad, 8) == nil, "spreadCarried: ignored with a count that is not a whole number of 0 or more")
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
		send("spreadCarried", badWorld, bad, list, nil)
	end
	send("spreadCarried", badWorld, bad, nil, nil)
	send("spreadCarried", badWorld, bad)
	check(
		inSlot(bad, 8) == nil and inSlot(bad, 9) == nil and is(carriedBy(bad), "log", 12),
		"spreadCarried: ignored with what is not a list of slots of the screen, even when part of it is"
	)

	local tooMany = {}
	for _ = 1, PlayerState.PACK_SLOTS + 1 do
		table.insert(tooMany, at2("pack", 8))
	end
	send("spreadCarried", badWorld, bad, tooMany, nil)
	check(inSlot(bad, 8) == nil, "spreadCarried: ignored with more slots listed than the screen has")
	table.remove(tooMany)
	send("spreadCarried", badWorld, bad, tooMany, nil)
	check(
		is(inSlot(bad, 8), "log", 12) and carriedBy(bad) == nil,
		"spreadCarried: but as many as the screen has is a spread, and a slot listed twice counts once"
	)

	local crateWorld, withCrate = newWorld()
	local crate = openPlaced(crateWorld, withCrate, "crate")
	send("pickUp", crateWorld, withCrate, "pack", 2)
	local long = {}
	for _ = 1, PlayerState.PACK_SLOTS + crate.slotCount + 1 do
		table.insert(long, at2("other", 2))
	end
	send("spreadCarried", crateWorld, withCrate, long, nil)
	check(
		Inventory.isEmpty(crate),
		"spreadCarried: with a crate open, ignored with more slots listed than the two have"
	)
	table.remove(long)
	send("spreadCarried", crateWorld, withCrate, long, nil)
	check(
		is(Inventory.getStack(crate, 2), "fish", 5),
		"spreadCarried: but as many as the pack and the crate have is a spread, here into the crate"
	)

	local ovenWorld, withOven = newWorld()
	local oven = openPlaced(ovenWorld, withOven, "oven")
	send("pickUp", ovenWorld, withOven, "pack", 1)
	send("spreadCarried", ovenWorld, withOven, { at2("other", 1), at2("other", 2), at2("other", 3) }, nil)
	check(
		Inventory.getStack(oven, 1) == nil
			and is(Inventory.getStack(oven, 2), "log", 12)
			and Inventory.getStack(oven, 3) == nil,
		"spreadCarried: only the slots that accept the carried item take part"
	)
end

do -- dropCarried
	local world, state = newWorld()
	send("dropCarried", world, state, 1)
	check(onGround(world, "log") == 0, "dropCarried: does nothing when no screen is open")

	send("openPack", world, state)
	send("dropCarried", world, state, 1)
	check(onGround(world, "log") == 0, "dropCarried: does nothing when nothing is carried")

	send("pickUp", world, state, "pack", 1)
	send("dropCarried", world, state, 5)
	check(
		onGround(world, "log") == 5 and is(carriedBy(state), "log", 7),
		"dropCarried: puts that many of the carried items on the ground"
	)
	local landed = next(world.groundItems.byId)
	local groundItem = world.groundItems.byId[landed :: number]
	check(
		groundItem.position.x == 12 and groundItem.position.y == 0 and groundItem.position.z == 0,
		"dropCarried: where the player's drops land"
	)
	check(groundItem.droppedAt == 100, "dropCarried: dropped at the world's time")
	send("dropCarried", world, state, 0)
	check(onGround(world, "log") == 5 and is(carriedBy(state), "log", 7), "dropCarried: a count of 0 drops nothing")
	for _, bad in badCounts do
		send("dropCarried", world, state, bad)
	end
	check(
		onGround(world, "log") == 5 and is(carriedBy(state), "log", 7),
		"dropCarried: ignored with a count that is not a whole number of 0 or more"
	)
	send("dropCarried", world, state, 99)
	check(
		onGround(world, "log") == 12 and carriedBy(state) == nil,
		"dropCarried: a count of more than is carried drops all of it"
	)

	local allWorld, all = newWorld()
	send("openPack", allWorld, all)
	send("pickUp", allWorld, all, "pack", 1)
	send("dropCarried", allWorld, all, nil)
	check(onGround(allWorld, "log") == 12 and carriedBy(all) == nil, "dropCarried: with no count drops all of it")
	send("dropCarried", allWorld, all)
	check(onGround(allWorld, "log") == 12, "dropCarried: and again drops nothing")

	local movedWorld, moved = newWorld()
	World.setPlayerPosition(movedWorld, 1, at(1, 0, 1), at(3, 0, 4))
	send("openPack", movedWorld, moved)
	send("pickUp", movedWorld, moved, "pack", 1)
	send("dropCarried", movedWorld, moved, nil)
	local movedItem = movedWorld.groundItems.byId[next(movedWorld.groundItems.byId) :: number]
	check(
		movedItem.position.x == 3 and movedItem.position.z == 4,
		"dropCarried: drops at the player's drop position as it is now"
	)
	World.setPlayerPosition(movedWorld, 1, nil)
	send("pickUp", movedWorld, moved, "pack", 10)
	send("dropCarried", movedWorld, moved, nil)
	check(onGround(movedWorld, "log") == 16, "dropCarried: a player with no character can drop, where they last could")
end

do -- dropFromSlot
	local world, state = newWorld()
	send("dropFromSlot", world, state, "pack", 1, 1)
	check(
		onGround(world, "log") == 0 and is(inSlot(state, 1), "log", 12),
		"dropFromSlot: does nothing when no screen is open"
	)

	send("openPack", world, state)
	send("dropFromSlot", world, state, "pack", 1, 1)
	check(
		onGround(world, "log") == 1 and is(inSlot(state, 1), "log", 11),
		"dropFromSlot: puts that many items out of the slot on the ground"
	)
	local landed = world.groundItems.byId[next(world.groundItems.byId) :: number]
	check(
		landed.position.x == 12 and landed.position.z == 0 and landed.droppedAt == 100,
		"dropFromSlot: at the player's drop position, at the world's time"
	)
	send("dropFromSlot", world, state, "pack", 1, 99)
	check(
		onGround(world, "log") == 12 and inSlot(state, 1) == nil,
		"dropFromSlot: a count of more than the slot holds drops all of it"
	)
	send("dropFromSlot", world, state, "pack", 2)
	check(
		onGround(world, "fish") == 5 and inSlot(state, 2) == nil,
		"dropFromSlot: with no count drops everything in the slot"
	)
	send("dropFromSlot", world, state, "pack", 2)
	send("dropFromSlot", world, state, "pack", 3, 1)
	check(onGround(world, "fish") == 5, "dropFromSlot: a slot that holds nothing drops nothing")
	send("dropFromSlot", world, state, "pack", 10, 0)
	check(is(inSlot(state, 10), "log", 4), "dropFromSlot: a count of 0 drops nothing")
	for _, bad in badCounts do
		send("dropFromSlot", world, state, "pack", 10, bad)
	end
	for _, side in { "other", "Pack", "", 1, true, {} } :: { any } do
		send("dropFromSlot", world, state, side, 10, 1)
	end
	for _, slot in { 0, -1, 37, 99, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		send("dropFromSlot", world, state, "pack", slot, 1)
	end
	send("dropFromSlot", world, state)
	check(
		is(inSlot(state, 10), "log", 4) and onGround(world, "log") == 12,
		"dropFromSlot: ignored for a count that is not a whole number of 0 or more, or a side or slot that is not there"
	)

	send("pickUp", world, state, "pack", 10)
	send("dropFromSlot", world, state, "pack", 10, 1)
	check(is(carriedBy(state), "log", 4), "dropFromSlot: what is carried is not dropped")

	local crateWorld, withCrate = newWorld()
	local crate = openPlaced(crateWorld, withCrate, "crate")
	Inventory.setStack(crate, 3, ItemStack.new("fish", 4))
	send("dropFromSlot", crateWorld, withCrate, "other", 3, 3)
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

do -- dropSelected
	local world, state = newWorld()
	send("dropSelected", world, state, 1)
	check(
		is(inSlot(state, 1), "log", 11) and onGround(world, "log") == 1,
		"dropSelected: puts that many of what is in hand on the ground"
	)
	local landed = world.groundItems.byId[next(world.groundItems.byId) :: number]
	check(
		landed.position.x == 12 and landed.position.z == 0 and landed.droppedAt == 100,
		"dropSelected: at the player's drop position, at the world's time"
	)
	send("dropSelected", world, state, 99)
	check(
		inSlot(state, 1) == nil and onGround(world, "log") == 12,
		"dropSelected: a count of more than is in hand drops all of it"
	)
	send("dropSelected", world, state, 1)
	send("dropSelected", world, state, nil)
	check(onGround(world, "log") == 12, "dropSelected: an empty hand drops nothing")

	send("selectHotbarSlot", world, state, 10)
	send("selectHotbarSlot", world, state, 9)
	Inventory.setStack(state.pack, 9, ItemStack.new("fish", 7))
	send("dropSelected", world, state)
	check(
		onGround(world, "fish") == 7 and inSlot(state, 9) == nil,
		"dropSelected: with no count drops the whole stack in hand"
	)

	local zeroWorld, zero = newWorld()
	send("dropSelected", zeroWorld, zero, 0)
	for _, bad in badCounts do
		send("dropSelected", zeroWorld, zero, bad)
	end
	check(
		is(inSlot(zero, 1), "log", 12) and onGround(zeroWorld, "log") == 0,
		"dropSelected: a count of 0, or one that is not a whole number of 0 or more, drops nothing"
	)
	send("openPack", zeroWorld, zero)
	send("dropSelected", zeroWorld, zero, 2)
	check(
		is(inSlot(zero, 1), "log", 10) and onGround(zeroWorld, "log") == 2,
		"dropSelected: works while a screen is open too"
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
		World.setPlayerPosition(world, 1, at(6, 0, 0), at(12, 0, 0))
		local crateId = World.placeItem(world, "crate", 6, 6) :: number
		local ovenId = World.placeItem(world, "oven", 6, 5) :: number
		local crate = world.plot.placedById[crateId].inventory :: Inventory.Inventory
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
			-- Now and then the world itself opens a screen for the player, as using a placed item would.
			if state.screen == nil and random(12) == 1 then
				World.openPlaced(world, state, if random(2) == 1 then crateId else ovenId)
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
			for _, inventory in { state.pack, crate, world.plot.placedById[ovenId].inventory :: Inventory.Inventory } do
				for slot, stack in inventory.slots do
					if ItemStack.validate(stack) ~= nil or not Inventory.hasSlot(inventory, slot) then
						allValid = false
					end
				end
			end
			local carried = if state.screen then state.screen.carried else nil
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
	check(allValid, "random run: every stack in a pack or a placed item is a valid stack in a slot that exists")
end

Check.finish("InventoryRequests")
