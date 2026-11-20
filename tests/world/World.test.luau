--!strict
-- Tests for World. Run from the repository root: lune run tests/world/World.test.luau

local Check = require("../Check")
local GroundItems = require("../../src/shared/world/GroundItems")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")
local Station = require("../../src/shared/stations/Station")
local StationProgress = require("../../src/shared/stations/StationProgress")
local World = require("../../src/shared/world/World")

local check = Check.that
local STILL = { x = 0, y = 0, z = 0 }

ItemRegistry.register({ id = "log", stackSize = 16, burnSeconds = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "apple", stackSize = 16 })
ItemRegistry.register({ id = "stove", stackSize = 1, placeable = true })
ItemRegistry.register({ id = "crate", stackSize = 1, placeable = true, slotCount = 27 })
ItemRegistry.register({ id = "post", stackSize = 8, placeable = true })
ItemRegistry.register({ id = "cooked_fish", stackSize = 8 })
ItemRegistry.register({ id = "oven", stackSize = 1, placeable = true, slotCount = 3 })
RecipeRegistry.register({ station = "oven", input = "fish", output = "cooked_fish", seconds = 8 })

local itemIds = { "log", "fish", "apple", "stove", "crate", "post" }
local at = Position.new
local ALONG_X = { x = 1, z = 0 }

-- True if `groundItem` is at `x`, `y`, `z`, to within a rounding error.
local function isAt(groundItem: GroundItems.GroundItem, x: number, y: number, z: number): boolean
	return Position.getDistance(groundItem.position, at(x, y, z)) < 1e-9
end

-- True if `groundItem` was spawned moving at `x`, `y`, `z` studs a second, to within a rounding error.
local function wasSpawnedMovingAt(groundItem: GroundItems.GroundItem, x: number, y: number, z: number): boolean
	local velocity = groundItem.spawnVelocity
	return math.abs(velocity.x - x) < 1e-9 and math.abs(velocity.y - y) < 1e-9 and math.abs(velocity.z - z) < 1e-9
end

-- How many ground items there are.
local function groundItemCount(world: World.World): number
	local count = 0
	for _ in world.groundItems.itemsById do
		count += 1
	end
	return count
end

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

-- The ground items that hold one item, as a list sorted by count.
local function groundStacks(world: World.World, itemId: string): { GroundItems.GroundItem }
	local found: { GroundItems.GroundItem } = {}
	for _, groundItem in world.groundItems.itemsById do
		if groundItem.stack.itemId == itemId then
			table.insert(found, groundItem)
		end
	end
	table.sort(found, function(a: GroundItems.GroundItem, b: GroundItems.GroundItem): boolean
		return a.stack.count < b.stack.count
	end)
	return found
end

-- How many of one item lie on the ground.
local function onGround(world: World.World, itemId: string): number
	local total = 0
	for _, groundItem in groundStacks(world, itemId) do
		total += groundItem.stack.count
	end
	return total
end

-- How many of one item the whole world holds: in packs, carried, standing on the plot, inside what
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
	for _, placedItem in world.plot.placedItemsById do
		if placedItem.itemId == itemId then
			count += 1
		end
		if placedItem.inventory ~= nil then
			count += Inventory.countItems(placedItem.inventory, itemId)
		end
	end
	return count
end

-- The ids of everything that stands on the plot, lowest first.
local function placedIds(world: World.World): { number }
	local ids = {}
	for id in world.plot.placedItemsById do
		table.insert(ids, id)
	end
	table.sort(ids)
	return ids
end

-- The inventory inside a placed item that is known to have one.
local function insideOf(world: World.World, placedItemId: number): Inventory.Inventory
	return world.plot.placedItemsById[placedItemId].inventory :: Inventory.Inventory
end

-- A world at time 100 with a plot of 6 by 6 tiles whose corner is at the origin, so that the middle of
-- tile x, z is at x * 4 - 2, z * 4 - 2. A crate holding 5 fish stands on tile 2, 2 (its middle is 6, 6),
-- a stove on tile 5, 5 (its middle is 18, 18) and an oven on tile 4, 2 (its middle is 14, 6). Player 1
-- has 12 logs in their first slot, and their character is at 6, 0, facing along x.
local function newWorld(): (World.World, PlayerState.PlayerState, { crate: number, stove: number, oven: number })
	local plot = Plot.new(6, 6)
	local crateId = Plot.placeItem(plot, "crate", 2, 2) :: number
	Inventory.addItems(plot.placedItemsById[crateId].inventory :: Inventory.Inventory, "fish", 5)
	local stoveId = Plot.placeItem(plot, "stove", 5, 5) :: number
	local ovenId = Plot.placeItem(plot, "oven", 4, 2) :: number
	local world = World.new(plot, at(0, 0, 0), 100)
	local state = World.addPlayer(world, 1)
	Inventory.setStack(state.pack, 1, ItemStack.new("log", 12))
	World.setCharacterPositionAndFacing(world, 1, at(6, 0, 0), ALONG_X)
	return world, state, { crate = crateId, stove = stoveId, oven = ovenId }
end

-- Takes a placed item off the plot and throws it into the world with what is inside it, as a hit
-- does.
local function knockOff(world: World.World, placedItemId: number)
	local placedItem = World.takePlacedItemOffPlot(world, placedItemId)
	if placedItem ~= nil then
		World.throwPlacedItemAndContents(world, placedItem)
	end
end

do -- the numbers the world goes by
	check(World.SCREEN_CLOSES_BEYOND == World.REACH + 4, "CLOSES_BEYOND: a screen closes 4 studs beyond reach")
	check(
		World.TILE_STOOD_ON_WITHIN == Plot.TILE_SIZE * 0.75,
		"TILE_STOOD_ON_WITHIN: a player stands on a tile within three quarters of its width of its middle"
	)
end

do -- a new world
	local plot = Plot.new(3, 3)
	local corner = at(4, 1, -8)
	local world = World.new(plot, corner, 50)
	check(world.plot == plot, "new: holds the plot it was given")
	check(world.plotCorner == corner, "new: knows where the plot's corner is")
	check(world.now == 50, "new: starts at the time it was given")
	check(next(world.players) == nil, "new: has no players")
	check(next(world.groundItems.itemsById) == nil, "new: has nothing on the ground")
	check(next(world.stations) == nil, "new: a plot with nothing on it has no stations")
end

do -- a station gets its record when the world is made or when it is placed
	local plot = Plot.new(4, 4)
	local ovenId = Plot.placeItem(plot, "oven", 1, 1) :: number
	local crateId = Plot.placeItem(plot, "crate", 2, 1) :: number
	local stoveId = Plot.placeItem(plot, "stove", 3, 1) :: number
	local world = World.new(plot, at(0, 0, 0), 0)
	local station = world.stations[ovenId]
	check(station ~= nil, "new: an oven already on the plot is a station")
	check(
		station ~= nil and station.itemId == "oven" and station.inventory == insideOf(world, ovenId),
		"new: and it works over the oven's own inventory"
	)
	check(
		station ~= nil and not Station.isBurning(station) and station.workedSeconds == 0,
		"new: with no fire and no work done"
	)
	check(world.stations[crateId] == nil, "new: a crate is not a station, though it has an inventory")
	check(world.stations[stoveId] == nil, "new: nor is a placed item that holds nothing")

	local placedOven = World.placeItem(world, "oven", 4, 4)
	check(placedOven ~= nil and world.stations[placedOven] ~= nil, "placeItem: a placed oven is a station at once")
	check(
		placedOven ~= nil
			and world.stations[placedOven].inventory == insideOf(world, placedOven)
			and not Station.isBurning(world.stations[placedOven]),
		"placeItem: over its own inventory, with no fire"
	)
	local placedCrate = World.placeItem(world, "crate", 4, 3)
	check(placedCrate ~= nil and world.stations[placedCrate] == nil, "placeItem: a placed crate is not a station")
end

do -- players come and go
	local world = World.new(Plot.new(3, 3), at(0, 0, 0), 0)
	local state = World.addPlayer(world, 7)
	check(world.players[7] == state, "addPlayer: returns the player now in the world")
	check(Inventory.isEmpty(state.pack), "addPlayer: with no pack given, the pack holds nothing")
	check(state.pack.slotCount == PlayerState.PACK_SLOT_COUNT, "addPlayer: and has the slots of any pack")
	check(state.screen == nil and state.openedPlacedItemId == nil, "addPlayer: a new player has no screen open")
	check(state.character == nil, "addPlayer: and has no character yet")
	local second = World.addPlayer(world, -3)
	check(
		second ~= state and world.players[-3] == second,
		"addPlayer: a second player is another state, and an id may be negative"
	)

	local pack = Inventory.new(PlayerState.PACK_SLOT_COUNT)
	Inventory.setStack(pack, 4, ItemStack.new("apple", 6))
	local carrying = World.addPlayer(world, 8, pack)
	check(carrying.pack == pack, "addPlayer: a player given a pack carries that pack")
	check(is(Inventory.getStack(carrying.pack, 4), "apple", 6), "addPlayer: with what is in it")
	local alreadyThere = Check.errorFrom(function()
		World.addPlayer(world, 7)
	end)
	check(
		alreadyThere ~= nil and string.find(alreadyThere, "player 7 is already in the world", 1, true) ~= nil,
		"addPlayer: fails if a player already has that id"
	)
	check(world.players[7] == state, "addPlayer: and the player who was there stays")

	check(World.removePlayer(world, 7) == state, "removePlayer: returns the player it took out")
	check(world.players[7] == nil and world.players[-3] == second, "removePlayer: and leaves the others")
	check(World.removePlayer(world, 7) == nil, "removePlayer: returns nothing for an id that is not in the world")
	check(World.removePlayer(world, 999) == nil, "removePlayer: nor for an id that never was")
	check(world.players[-3] == second and world.players[8] == carrying, "removePlayer: and changes nothing then")
	check(World.addPlayer(world, 7) ~= state, "addPlayer: a player who comes back starts afresh")
end

do -- a player's character
	local world, state = newWorld()
	local character = state.character
	check(
		character ~= nil and character.position.x == 6 and character.facing == ALONG_X,
		"setCharacterPositionAndFacing: the player's character is at the position and faces the way given"
	)
	local awayAlongZ = { x = 0, z = -1 }
	World.setCharacterPositionAndFacing(world, 1, at(3, 0, 3), awayAlongZ)
	local moved = state.character
	check(
		moved ~= nil and moved.position.x == 3 and moved.position.z == 3 and moved.facing == awayAlongZ,
		"setCharacterPositionAndFacing: a later position and facing take their place"
	)
	World.removeCharacter(world, 1)
	check(state.character == nil, "removeCharacter: the player has no character")
	World.removeCharacter(world, 1)
	check(state.character == nil, "removeCharacter: does nothing for a player with no character")
	World.setCharacterPositionAndFacing(world, 1, at(3, 0, 3), awayAlongZ)
	check(state.character ~= nil, "setCharacterPositionAndFacing: a player who had no character has one from now on")
	local nobodyToRemove = Check.errorFrom(function()
		World.removeCharacter(world, 2)
	end)
	check(
		nobodyToRemove ~= nil and string.find(nobodyToRemove, "no player has the id 2", 1, true) ~= nil,
		"removeCharacter: fails if no player has that id"
	)
	local nobody = Check.errorFrom(function()
		World.setCharacterPositionAndFacing(world, 2, at(0, 0, 0), ALONG_X)
	end)
	check(
		nobody ~= nil and string.find(nobody, "no player has the id 2", 1, true) ~= nil,
		"setCharacterPositionAndFacing: fails if no player has that id"
	)

	-- Losing the character closes the screen, while there is still a character to throw from.
	local full, fullState, fullIds = newWorld()
	for slot = 1, PlayerState.PACK_SLOT_COUNT do
		Inventory.setStack(fullState.pack, slot, ItemStack.new("stove", 1))
	end
	World.openPlacedItemScreen(full, fullState, fullIds.crate)
	InventoryScreen.pickUpFromSlot(fullState.screen :: any, "other", 1)
	World.removeCharacter(full, 1)
	check(
		fullState.screen == nil and fullState.openedPlacedItemId == nil and fullState.character == nil,
		"removeCharacter: a player who loses their character has their screen closed"
	)
	local fish = groundStacks(full, "fish")
	check(
		#fish == 1 and is(fish[1].stack, "fish", 5) and isAt(fish[1], 6, World.CHARACTER_THROW_START_HEIGHT, 0),
		"removeCharacter: and what they carried is thrown from where the character was"
	)
end

do -- spawning a stack
	local world = newWorld()
	local id = World.spawnStack(world, ItemStack.new("apple", 3), at(60, 3, 60), { x = 2, y = 5, z = -1 })
	local apple = world.groundItems.itemsById[id]
	check(is(apple.stack, "apple", 3), "spawnStack: the stack is a ground item, and its id is returned")
	check(isAt(apple, 60, 3, 60), "spawnStack: at the position given")
	check(wasSpawnedMovingAt(apple, 2, 5, -1), "spawnStack: moving at the velocity given")
	check(apple.spawnTime == 100, "spawnStack: spawned at the world's time")
	World.advanceTo(world, 150)
	local beside = World.spawnStack(world, ItemStack.new("apple", 2), at(60.5, 3, 60), STILL)
	check(
		beside ~= id and #groundStacks(world, "apple") == 2,
		"spawnStack: a stack spawned beside its own kind is a new ground item all the same"
	)
	check(world.groundItems.itemsById[beside].spawnTime == 150, "spawnStack: spawned at the time the world has reached")
end

do -- throwing a stack from a character
	local world = newWorld()
	World.throwStackFromCharacter(world, { position = at(60, 2, 60), facing = ALONG_X }, ItemStack.new("apple", 3))
	local apples = groundStacks(world, "apple")
	check(#apples == 1 and is(apples[1].stack, "apple", 3), "throwStackFromCharacter: the stack is a ground item")
	check(
		isAt(apples[1], 60, 2 + World.CHARACTER_THROW_START_HEIGHT, 60),
		"throwStackFromCharacter: it spawns above the character's feet"
	)
	check(
		wasSpawnedMovingAt(apples[1], World.CHARACTER_THROW_FORWARD_SPEED, World.CHARACTER_THROW_UPWARD_SPEED, 0),
		"throwStackFromCharacter: moving the way the character faces, and upwards"
	)
	World.throwStackFromCharacter(
		world,
		{ position = at(0, 0, 0), facing = { x = 0, z = -1 } },
		ItemStack.new("fish", 1)
	)
	check(
		wasSpawnedMovingAt(
			groundStacks(world, "fish")[1],
			0,
			World.CHARACTER_THROW_UPWARD_SPEED,
			-World.CHARACTER_THROW_FORWARD_SPEED
		),
		"throwStackFromCharacter: a character facing another way throws that way"
	)
	check(
		World.CHARACTER_THROW_START_HEIGHT == 3
			and World.CHARACTER_THROW_FORWARD_SPEED == 24
			and World.CHARACTER_THROW_UPWARD_SPEED == 8,
		"a character throws from 3 studs above its feet, at 24 studs a second forwards and 8 upwards"
	)
end

do -- a ground item's position
	local world = newWorld()
	local flying = World.spawnStack(world, ItemStack.new("apple", 3), at(60, 3, 60), { x = 24, y = 8, z = 0 })
	World.setGroundItemPosition(world, flying, at(66, 0, 60))
	local moved = world.groundItems.itemsById[flying]
	check(isAt(moved, 66, 0, 60), "setGroundItemPosition: the ground item is at the position given")
	check(
		is(moved.stack, "apple", 3) and moved.spawnTime == 100 and wasSpawnedMovingAt(moved, 24, 8, 0),
		"setGroundItemPosition: and is otherwise as it was"
	)

	World.spawnStack(world, ItemStack.new("apple", 2), at(80, 0, 60), STILL)
	World.setGroundItemPosition(world, flying, at(80.5, 0, 60))
	check(
		#groundStacks(world, "apple") == 2 and isAt(world.groundItems.itemsById[flying], 80.5, 0, 60),
		"setGroundItemPosition: a ground item that comes to be beside its own kind is still a ground item of its own"
	)
	World.setGroundItemPosition(world, 999, at(0, 0, 0))
	check(
		groundItemCount(world) == 2 and onGround(world, "apple") == 5,
		"setGroundItemPosition: does nothing for an id that no ground item has"
	)
end

do -- time passing: ground items merge
	local world = newWorld()
	local lying = World.spawnStack(world, ItemStack.new("apple", 2), at(80, 0, 60), STILL)
	local flying = World.spawnStack(world, ItemStack.new("apple", 3), at(60, 3, 60), { x = 24, y = 8, z = 0 })
	World.advanceTo(world, 101)
	check(#groundStacks(world, "apple") == 2, "advanceTo: ground items of one kind that are apart stay apart")
	World.setGroundItemPosition(world, flying, at(80.5, 0, 60))
	World.advanceTo(world, 102)
	local apples = groundStacks(world, "apple")
	check(
		#apples == 1 and is(apples[1].stack, "apple", 5) and world.groundItems.itemsById[flying] == nil,
		"advanceTo: a ground item that has come beside its own kind merges into it"
	)
	check(isAt(world.groundItems.itemsById[lying], 80, 0, 60), "advanceTo: the one it merged into stays where it is")
	World.spawnStack(world, ItemStack.new("apple", 4), at(80.5, 0, 60), STILL)
	World.advanceTo(world, 103)
	check(
		#groundStacks(world, "apple") == 1 and onGround(world, "apple") == 9,
		"advanceTo: a stack spawned beside its own kind merges into it too"
	)
	World.spawnStack(world, ItemStack.new("apple", 16), at(80.5, 0, 60), STILL)
	World.advanceTo(world, 104)
	check(
		#groundStacks(world, "apple") == 2 and onGround(world, "apple") == 25,
		"advanceTo: one that does not fit with its own kind stays a ground item of its own"
	)

	-- Merging comes before picking up. Player 1 stands at 6, 0, 0.
	local order, orderState = newWorld()
	World.spawnStack(order, ItemStack.new("apple", 2), at(7, 0, 1), STILL)
	World.advanceTo(order, 100 + GroundItems.PICKUP_DELAY_SECONDS - 0.1)
	World.spawnStack(order, ItemStack.new("apple", 3), at(7.5, 0, 1), STILL)
	World.advanceTo(order, 100 + GroundItems.PICKUP_DELAY_SECONDS)
	check(
		Inventory.countItems(orderState.pack, "apple") == 0 and #groundStacks(order, "apple") == 1,
		"advanceTo: merging comes before picking up, so a stack that a new one has merged into is not picked up yet"
	)
end

do -- closing a player's screen
	local world, state, ids = newWorld()
	World.closeScreen(world, state)
	check(
		state.screen == nil and next(world.groundItems.itemsById) == nil,
		"closeScreen: does nothing if no screen is open"
	)

	PlayerState.openPackScreen(state)
	World.closeScreen(world, state)
	check(state.screen == nil, "closeScreen: the screen is gone")

	World.openPlacedItemScreen(world, state, ids.crate)
	InventoryScreen.pickUpFromSlot(state.screen :: any, "other", 1)
	check(
		is((state.screen :: any).carriedStack, "fish", 5) and Inventory.countItems(state.pack, "fish") == 0,
		"closeScreen: (set up) the player carries the fish out of the crate"
	)
	World.closeScreen(world, state)
	check(state.screen == nil and state.openedPlacedItemId == nil, "closeScreen: nothing is open afterwards")
	check(Inventory.countItems(state.pack, "fish") == 5, "closeScreen: what was carried goes back into the pack")
	check(Inventory.isEmpty(insideOf(world, ids.crate)), "closeScreen: and not into the crate")
	check(
		next(world.groundItems.itemsById) == nil,
		"closeScreen: and nothing lands on the ground when the pack has room"
	)

	-- A pack with no room for the carried stack: it is thrown from the player's character.
	for slot = 1, PlayerState.PACK_SLOT_COUNT do
		Inventory.setStack(state.pack, slot, ItemStack.new("stove", 1))
	end
	Inventory.setStack(insideOf(world, ids.crate), 1, ItemStack.new("fish", 5))
	World.openPlacedItemScreen(world, state, ids.crate)
	InventoryScreen.pickUpFromSlot(state.screen :: any, "other", 1)
	World.closeScreen(world, state)
	local fish = groundStacks(world, "fish")
	check(
		#fish == 1 and is(fish[1].stack, "fish", 5),
		"closeScreen: what the pack has no room for is loose in the world"
	)
	check(
		isAt(fish[1], 6, World.CHARACTER_THROW_START_HEIGHT, 0)
			and wasSpawnedMovingAt(fish[1], World.CHARACTER_THROW_FORWARD_SPEED, World.CHARACTER_THROW_UPWARD_SPEED, 0),
		"closeScreen: thrown from the player's character, the way it faces"
	)
	check(state.screen == nil, "closeScreen: and the screen is closed all the same")

	-- A part fits and the rest is left over.
	local world2, state2, ids2 = newWorld()
	for slot = 1, PlayerState.PACK_SLOT_COUNT do
		Inventory.setStack(state2.pack, slot, ItemStack.new("fish", 8))
	end
	Inventory.setStack(state2.pack, 10, ItemStack.new("fish", 6))
	World.openPlacedItemScreen(world2, state2, ids2.crate)
	InventoryScreen.pickUpFromSlot(state2.screen :: any, "other", 1)
	World.closeScreen(world2, state2)
	check(
		is(Inventory.getStack(state2.pack, 10), "fish", 8) and onGround(world2, "fish") == 3,
		"closeScreen: the carried stack fills what room there is, and the rest lies on the ground"
	)

	-- A screen with nothing carried puts nothing anywhere.
	local world3, state3 = newWorld()
	PlayerState.openPackScreen(state3)
	World.closeScreen(world3, state3)
	check(
		Inventory.countItems(state3.pack, "log") == 12 and next(world3.groundItems.itemsById) == nil,
		"closeScreen: a screen with nothing carried changes nothing else"
	)
end

do -- opening a placed item
	local world, state, ids = newWorld()
	check(World.openPlacedItemScreen(world, state, ids.crate), "openPlacedItemScreen: returns true for a crate")
	local screen = state.screen
	check(screen ~= nil and screen.pack == state.pack, "openPlacedItemScreen: the screen shows the player's pack")
	check(
		screen ~= nil and screen.otherInventory == insideOf(world, ids.crate),
		"openPlacedItemScreen: and the crate's own inventory beside it"
	)
	check(state.openedPlacedItemId == ids.crate, "openPlacedItemScreen: and the player has that placed item open")
	check(screen ~= nil and screen.otherSlotAcceptsItem == nil, "openPlacedItemScreen: a crate's slots take anything")

	local first = state.screen
	check(World.openPlacedItemScreen(world, state, ids.crate), "openPlacedItemScreen: opening it again returns true")
	check(state.screen ~= first and state.screen ~= nil, "openPlacedItemScreen: and opens it afresh")

	-- Another screen is closed first, as closeScreen does.
	InventoryScreen.pickUpFromSlot(state.screen :: any, "other", 1)
	check(World.openPlacedItemScreen(world, state, ids.oven), "openPlacedItemScreen: an oven opens")
	check(
		Inventory.countItems(state.pack, "fish") == 5 and onGround(world, "fish") == 0,
		"openPlacedItemScreen: what was carried on the screen it replaces is back in the pack"
	)
	check(state.openedPlacedItemId == ids.oven, "openPlacedItemScreen: and the oven is what the player has open")
	local ovenScreen = state.screen :: InventoryScreen.InventoryScreen
	check(
		ovenScreen.otherInventory == insideOf(world, ids.oven),
		"openPlacedItemScreen: beside the oven's own inventory"
	)
	check(ovenScreen.otherSlotAcceptsItem ~= nil, "openPlacedItemScreen: a station's slots have rules")
	check(
		InventoryScreen.slotAcceptsItem(ovenScreen, "other", Station.INPUT_SLOT, "fish"),
		"openPlacedItemScreen: the input slot takes what the oven works on"
	)
	check(
		not InventoryScreen.slotAcceptsItem(ovenScreen, "other", Station.INPUT_SLOT, "log"),
		"openPlacedItemScreen: but not what it has no recipe for"
	)
	check(
		InventoryScreen.slotAcceptsItem(ovenScreen, "other", Station.FUEL_SLOT, "log"),
		"openPlacedItemScreen: the fuel slot takes fuel"
	)
	check(
		not InventoryScreen.slotAcceptsItem(ovenScreen, "other", Station.FUEL_SLOT, "fish"),
		"openPlacedItemScreen: but not what does not burn"
	)
	check(
		not InventoryScreen.slotAcceptsItem(ovenScreen, "other", Station.OUTPUT_SLOT, "cooked_fish"),
		"openPlacedItemScreen: and nothing is put in the output slot"
	)
	check(
		InventoryScreen.slotAcceptsItem(ovenScreen, "pack", 1, "fish"),
		"openPlacedItemScreen: while the pack takes anything"
	)

	-- Nothing to open: the screen stays as it was.
	local before = state.screen
	check(
		not World.openPlacedItemScreen(world, state, ids.stove),
		"openPlacedItemScreen: returns false for a placed item that holds nothing"
	)
	check(
		not World.openPlacedItemScreen(world, state, 999),
		"openPlacedItemScreen: and false for an id that no placed item has"
	)
	check(
		state.screen == before and state.openedPlacedItemId == ids.oven,
		"openPlacedItemScreen: and changes nothing then, the screen that was open stays open"
	)
	local other = World.addPlayer(world, 2)
	check(
		not World.openPlacedItemScreen(world, other, 999) and other.screen == nil,
		"openPlacedItemScreen: a player with no screen still has none"
	)
	check(
		not World.openPlacedItemScreen(world, other, ids.oven) and other.screen == nil,
		"openPlacedItemScreen: returns false for a player with no character, and opens nothing"
	)
	World.setCharacterPositionAndFacing(world, 2, at(14, 0, 6), ALONG_X)
	check(
		World.openPlacedItemScreen(world, other, ids.oven),
		"openPlacedItemScreen: two players may have the same oven open"
	)
	check(
		other.screen ~= nil and (other.screen :: any).otherInventory == (state.screen :: any).otherInventory,
		"openPlacedItemScreen: looking into the same inventory"
	)
end

do -- reaching a tile
	local world, state = newWorld()
	check(World.canReachTile(world, state, 2, 2), "canReach: a tile near the player is in reach")
	-- Tile 6, 1 has its middle at 22, 2. From 6, 2 it is exactly 16 studs away.
	World.setCharacterPositionAndFacing(world, 1, at(6, 5, 2), ALONG_X)
	check(
		World.canReachTile(world, state, 6, 1),
		"canReach: a tile exactly World.REACH away is in reach, whatever the height"
	)
	World.setCharacterPositionAndFacing(world, 1, at(5.99, 0, 2), ALONG_X)
	check(not World.canReachTile(world, state, 6, 1), "canReach: a tile a little further is not")
	World.removeCharacter(world, 1)
	check(not World.canReachTile(world, state, 2, 2), "canReach: a player with no character reaches nothing")
	local corner = World.new(Plot.new(3, 3), at(100, 0, 100), 0)
	local cornerState = World.addPlayer(corner, 1)
	World.setCharacterPositionAndFacing(corner, 1, at(102, 0, 102), ALONG_X)
	check(World.canReachTile(corner, cornerState, 1, 1), "canReach: measured from the plot's own corner")
	check(not World.canReachTile(corner, cornerState, 100, 100), "canReach: a tile far off the plot is not in reach")
end

do -- standing on a tile
	local world, state = newWorld()
	-- The middle of tile 3, 1 is at 10, 2.
	check(World.isTileStoodOn(world, 3, 1) == false, "isTileStoodOn: a tile nobody is near is not stood on")
	World.setCharacterPositionAndFacing(world, 1, at(13, 0, 2), ALONG_X)
	check(
		World.isTileStoodOn(world, 3, 1),
		"isTileStoodOn: a player exactly STANDS_ON_WITHIN from its middle stands on it"
	)
	World.setCharacterPositionAndFacing(world, 1, at(13.01, 0, 2), ALONG_X)
	check(not World.isTileStoodOn(world, 3, 1), "isTileStoodOn: a little further they do not")
	World.setCharacterPositionAndFacing(world, 1, at(10, 40, 2), ALONG_X)
	check(World.isTileStoodOn(world, 3, 1), "isTileStoodOn: height does not matter")
	World.removeCharacter(world, 1)
	check(not World.isTileStoodOn(world, 3, 1), "isTileStoodOn: a player with no character stands on nothing")
	local second = World.addPlayer(world, 2)
	World.setCharacterPositionAndFacing(world, 2, at(10, 0, 2), ALONG_X)
	check(World.isTileStoodOn(world, 3, 1), "isTileStoodOn: any player will do")
	check(
		second.character ~= nil and state.character == nil,
		"isTileStoodOn: (set up) the first still has no character"
	)
end

do -- placing an item
	local world = newWorld()
	local placedItemId = World.placeItem(world, "crate", 1, 1)
	check(
		placedItemId ~= nil and world.plot.placedItemsById[placedItemId].itemId == "crate",
		"placeItem: returns the id of the placed item"
	)
	check(
		placedItemId ~= nil
			and world.plot.placedItemsById[placedItemId].x == 1
			and world.plot.placedItemsById[placedItemId].z == 1,
		"placeItem: on the tile it was asked for"
	)
	check(
		placedItemId ~= nil and insideOf(world, placedItemId).slotCount == 27,
		"placeItem: with an inventory of its own"
	)
	check(World.placeItem(world, "crate", 1, 1) == nil, "placeItem: returns nil for a tile something stands on")
	check(World.placeItem(world, "log", 3, 1) == nil, "placeItem: and for an item that cannot be placed")
	check(world.plot.nextId == (placedItemId :: number) + 1, "placeItem: and places nothing then")

	-- Tile 3, 3 has its middle at 10, 10. Player 1 stands 3 studs from it.
	World.setCharacterPositionAndFacing(world, 1, at(13, 0, 10), ALONG_X)
	local nextId = world.plot.nextId
	check(World.placeItem(world, "stove", 3, 3) == nil, "placeItem: returns nil for a tile a player stands on")
	check(
		world.plot.nextId == nextId
			and not Plot.hasTile(world.plot, 3.5, 3)
			and world.plot.placedItemsById[nextId] == nil,
		"placeItem: and places nothing then"
	)
	World.setCharacterPositionAndFacing(world, 1, at(13.01, 0, 10), ALONG_X)
	check(World.placeItem(world, "stove", 3, 3) ~= nil, "placeItem: but places on it once the player has stepped off")

	-- A world needs no player to place in it.
	local empty = World.new(Plot.new(2, 2), at(0, 0, 0), 0)
	check(World.placeItem(empty, "post", 2, 2) == 1, "placeItem: works with no player in the world")
	local nowhere = World.new(Plot.new(2, 2), at(0, 0, 0), 0)
	local lost = World.addPlayer(nowhere, 1)
	check(
		lost.character == nil and World.placeItem(nowhere, "post", 1, 1) == 1,
		"placeItem: a player with no character stands on nothing"
	)
end

do -- placing an item where ground items lie
	-- Tile 3, 3 reaches from 8 to 12 along x and z, and its middle is 10, 10.
	local touching = (Plot.TILE_SIZE + GroundItems.ITEM_WIDTH) / 2
	local world = newWorld()
	local inside = GroundItems.spawnStack(world.groundItems, ItemStack.new("apple", 1), at(9, 0, 10.5), STILL, 0)
	World.advanceTo(world, 140)
	check(World.placeItem(world, "crate", 3, 3) ~= nil, "placeItem: (set up) a crate is placed where an apple lies")
	local apples = groundStacks(world, "apple")
	check(
		world.groundItems.itemsById[inside] == nil and #apples == 1 and is(apples[1].stack, "apple", 1),
		"placeItem: a ground item that lay in the tile is pushed out of it, whole"
	)
	check(
		isAt(apples[1], 10 - touching, 0, 10.5) and apples[1].spawnTime == 140,
		"placeItem: to just outside the tile, spawned again at the world's time"
	)

	local refused = newWorld()
	local stays = GroundItems.spawnStack(refused.groundItems, ItemStack.new("apple", 1), at(6, 0, 6.5), STILL, 0)
	check(
		World.placeItem(refused, "post", 2, 2) == nil and refused.groundItems.itemsById[stays] ~= nil,
		"placeItem: a placing that is refused pushes nothing"
	)
end

do -- taking a placed item off
	local world, state, ids = newWorld()
	local other = World.addPlayer(world, 2)
	World.setCharacterPositionAndFacing(world, 2, at(10, 0, 10), ALONG_X)
	World.openPlacedItemScreen(world, state, ids.crate)
	World.openPlacedItemScreen(world, other, ids.crate)
	InventoryScreen.pickUpFromSlot(other.screen :: any, "other", 1, 3)
	knockOff(world, ids.crate)
	check(world.plot.placedItemsById[ids.crate] == nil, "takePlacedItemOffPlot: the placed item is off the plot")
	check(
		state.screen == nil
			and state.openedPlacedItemId == nil
			and other.screen == nil
			and other.openedPlacedItemId == nil,
		"takePlacedItemOffPlot: every screen open on it is closed"
	)
	check(
		Inventory.countItems(other.pack, "fish") == 3,
		"takePlacedItemOffPlot: what a player carried is back in their pack"
	)
	local crates = groundStacks(world, "crate")
	check(
		#crates == 1 and is(crates[1].stack, "crate", 1),
		"throwPlacedItemAndContents: the item is loose in the world, one of it"
	)
	local middleHeight = (Plot.TILE_SIZE - GroundItems.ITEM_WIDTH) / 2
	check(
		isAt(crates[1], 6, middleHeight, 6) and crates[1].spawnTime == 100,
		"throwPlacedItemAndContents: it leaves from the middle of where it stood, dropped at the world's time"
	)
	local fish = groundStacks(world, "fish")
	check(
		#fish == 1 and is(fish[1].stack, "fish", 2),
		"throwPlacedItemAndContents: what was left in it is loose in the world"
	)
	check(isAt(fish[1], 6, middleHeight, 6), "throwPlacedItemAndContents: and leaves from the same place")
	check(
		crates[1].spawnVelocity.y == World.PLACED_ITEM_THROW_UPWARD_SPEED
			and fish[1].spawnVelocity.y == World.PLACED_ITEM_THROW_UPWARD_SPEED,
		"throwPlacedItemAndContents: the item and what was in it are thrown upwards"
	)
	local function outwardSpeed(groundItem: GroundItems.GroundItem): number
		return math.sqrt(groundItem.spawnVelocity.x ^ 2 + groundItem.spawnVelocity.z ^ 2)
	end
	check(
		math.abs(outwardSpeed(crates[1]) - World.PLACED_ITEM_THROW_OUTWARD_SPEED) < 1e-9
			and math.abs(outwardSpeed(fish[1]) - World.PLACED_ITEM_THROW_OUTWARD_SPEED) < 1e-9,
		"throwPlacedItemAndContents: and outwards along the ground"
	)
	check(
		math.abs(crates[1].spawnVelocity.x - fish[1].spawnVelocity.x) > 1,
		"throwPlacedItemAndContents: each a different way"
	)
	check(
		World.PLACED_ITEM_THROW_UPWARD_SPEED == 20 and World.PLACED_ITEM_THROW_OUTWARD_SPEED == 6,
		"a placed item and what was in it are thrown at 20 studs a second upwards and 6 outwards"
	)
	check(
		inWorld(world, "fish") == 5 and inWorld(world, "crate") == 1,
		"throwPlacedItemAndContents: nothing was made or lost"
	)
	check(
		Plot.canPlaceItem(world.plot, "stove", 2, 2) and World.placeItem(world, "stove", 2, 2) ~= nil,
		"takePlacedItemOffPlot: the tile holds nothing, so another item can be placed there"
	)

	-- Each stack from inside is thrown a way of its own.
	local ring = Plot.new(3, 3)
	local ringCrate = Plot.placeItem(ring, "crate", 2, 2) :: number
	local inRing = ring.placedItemsById[ringCrate].inventory :: Inventory.Inventory
	Inventory.setStack(inRing, 2, ItemStack.new("fish", 2))
	Inventory.setStack(inRing, 9, ItemStack.new("apple", 3))
	Inventory.setStack(inRing, 20, ItemStack.new("log", 4))
	local ringWorld = World.new(ring, at(0, 0, 0), 0)
	knockOff(ringWorld, ringCrate)
	local ways: { [string]: boolean } = {}
	local wayCount = 0
	for _, groundItem in ringWorld.groundItems.itemsById do
		local key = string.format("%.3f %.3f", groundItem.spawnVelocity.x, groundItem.spawnVelocity.z)
		if not ways[key] then
			ways[key] = true
			wayCount += 1
		end
	end
	check(
		wayCount == 4,
		"throwPlacedItemAndContents: the item and each of the three stacks that were in it are thrown a way of their own"
	)
	check(
		onGround(ringWorld, "fish") == 2 and onGround(ringWorld, "apple") == 3 and onGround(ringWorld, "log") == 4,
		"throwPlacedItemAndContents: and each is whole"
	)
	local function idOf(itemId: string): number
		for id, groundItem in ringWorld.groundItems.itemsById do
			if groundItem.stack.itemId == itemId then
				return id
			end
		end
		return 0
	end
	check(
		idOf("crate") == 1 and idOf("fish") == 2 and idOf("apple") == 3 and idOf("log") == 4,
		"throwPlacedItemAndContents: the item is spawned first, then each stack from the lowest slot up"
	)

	-- Two part stacks of one kind that were inside come out as one.
	local parts = Plot.new(3, 3)
	local partsCrate = Plot.placeItem(parts, "crate", 2, 2) :: number
	local inParts = parts.placedItemsById[partsCrate].inventory :: Inventory.Inventory
	Inventory.setStack(inParts, 3, ItemStack.new("fish", 2))
	Inventory.setStack(inParts, 8, ItemStack.new("fish", 5))
	Inventory.setStack(inParts, 9, ItemStack.new("fish", 8))
	local partsWorld = World.new(parts, at(0, 0, 0), 0)
	knockOff(partsWorld, partsCrate)
	check(
		#groundStacks(partsWorld, "fish") == 3,
		"throwPlacedItemAndContents: each stack that was inside is a ground item of its own"
	)
	World.advanceTo(partsWorld, 0.1)
	local spilled = groundStacks(partsWorld, "fish")
	check(
		#spilled == 2 and is(spilled[1].stack, "fish", 7) and is(spilled[2].stack, "fish", 8),
		"advanceTo: two part stacks of one kind thrown from one place merge, and a full stack stays apart"
	)

	-- A placed item with nothing in it, and one with nothing to hold.
	knockOff(world, ids.stove)
	check(
		world.plot.placedItemsById[ids.stove] == nil and #groundStacks(world, "stove") == 1,
		"throwPlacedItemAndContents: a placed item that holds nothing just becomes a ground item"
	)
	local groundBefore = groundItemCount(world)
	knockOff(world, 999)
	knockOff(world, ids.stove)
	check(
		groundItemCount(world) == groundBefore,
		"takePlacedItemOffPlot: changes nothing for an id that no placed item has"
	)
	check(world.plot.placedItemsById[ids.oven] ~= nil, "takePlacedItemOffPlot: and takes nothing else off the plot")

	-- A player's screen open on something else is left alone.
	local keep, keepState, keepIds = newWorld()
	World.openPlacedItemScreen(keep, keepState, keepIds.crate)
	knockOff(keep, keepIds.oven)
	check(
		keepState.screen ~= nil and keepState.openedPlacedItemId == keepIds.crate,
		"takePlacedItemOffPlot: a screen open on another placed item stays open"
	)
end

do -- taking a placed item off the plot, and throwing one, each by itself
	local world, _, ids = newWorld()
	local taken = World.takePlacedItemOffPlot(world, ids.crate)
	check(
		taken ~= nil and taken.itemId == "crate" and taken.x == 2 and taken.z == 2,
		"takePlacedItemOffPlot: returns the placed item"
	)
	local inside = if taken then taken.inventory else nil
	check(
		inside ~= nil and Inventory.countItems(inside, "fish") == 5,
		"takePlacedItemOffPlot: with what was inside it still inside it"
	)
	check(groundItemCount(world) == 0, "takePlacedItemOffPlot: nothing is thrown into the world")
	check(
		World.takePlacedItemOffPlot(world, ids.crate) == nil and World.takePlacedItemOffPlot(world, 999) == nil,
		"takePlacedItemOffPlot: returns nil for an id that no placed item has"
	)

	local standing = world.plot.placedItemsById[ids.stove]
	World.throwPlacedItemAndContents(world, standing)
	check(
		#groundStacks(world, "stove") == 1 and world.plot.placedItemsById[ids.stove] == standing,
		"throwPlacedItemAndContents: does not take the placed item off the plot, so one that still stands there exists twice"
	)
end

do -- an oven taken off the plot
	local world, state, ids = newWorld()
	local inside = insideOf(world, ids.oven)
	Inventory.setStack(inside, Station.INPUT_SLOT, ItemStack.new("fish", 3))
	Inventory.setStack(inside, Station.FUEL_SLOT, ItemStack.new("log", 4))
	Inventory.setStack(state.pack, 1, nil)
	World.advanceTo(world, 104)
	check(world.stations[ids.oven] ~= nil, "takePlacedItemOffPlot: (set up) the oven is a station with a fire lit")
	check(Station.isBurning(world.stations[ids.oven]), "takePlacedItemOffPlot: (set up) and burning")
	knockOff(world, ids.oven)
	check(world.stations[ids.oven] == nil, "takePlacedItemOffPlot: its station goes with it, and its fire is out")
	check(
		#groundStacks(world, "oven") == 1 and onGround(world, "fish") == 3 and onGround(world, "log") == 3,
		"throwPlacedItemAndContents: what was in it lies on the ground, and the log that was burning is gone"
	)
	World.advanceTo(world, 200)
	check(onGround(world, "cooked_fish") == 0, "takePlacedItemOffPlot: nothing more is cooked once it is off the plot")
end

do -- time passing: picking up
	local world, state = newWorld()
	World.spawnStack(world, ItemStack.new("apple", 3), at(7, 0, 1), STILL)
	World.advanceTo(world, 100.5)
	check(world.now == 100.5, "advanceTo: the world moves on to the time it was given")
	check(Inventory.countItems(state.pack, "apple") == 0, "advanceTo: a ground item just dropped is not picked up yet")
	World.advanceTo(world, 100 + GroundItems.PICKUP_DELAY_SECONDS)
	check(
		Inventory.countItems(state.pack, "apple") == 3 and onGround(world, "apple") == 0,
		"advanceTo: a player picks up what lies near them"
	)

	World.addPlayer(world, 2)
	World.addPlayer(world, -5)
	World.setCharacterPositionAndFacing(world, 2, at(30, 0, 30), ALONG_X)
	World.setCharacterPositionAndFacing(world, -5, at(30, 0, 30), ALONG_X)
	World.spawnStack(world, ItemStack.new("stove", 1), at(31, 0, 30), STILL)
	World.advanceTo(world, 110)
	check(
		Inventory.countItems(world.players[-5].pack, "stove") == 1
			and Inventory.countItems(world.players[2].pack, "stove") == 0,
		"advanceTo: of two players equally near, the one with the lowest id picks up first"
	)

	World.removeCharacter(world, -5)
	World.spawnStack(world, ItemStack.new("stove", 1), at(100, 0, 100), STILL)
	World.setCharacterPositionAndFacing(world, 2, at(100, 0, 100), ALONG_X)
	World.spawnStack(world, ItemStack.new("fish", 2), at(30, 0, 30), STILL)
	World.advanceTo(world, 120)
	check(
		Inventory.countItems(world.players[2].pack, "stove") == 1,
		"advanceTo: a player picks up where they stand now"
	)
	check(onGround(world, "fish") == 2, "advanceTo: a player with no character picks nothing up")

	World.setCharacterPositionAndFacing(world, -5, at(30, 0, 30), ALONG_X)
	World.setCharacterPositionAndFacing(world, 2, at(500, 0, 500), ALONG_X)
	World.advanceTo(world, 121)
	check(
		Inventory.countItems(world.players[-5].pack, "fish") == 2,
		"advanceTo: and a character that is back picks up again"
	)
end

do -- time passing: ground items expire
	local world = newWorld()
	World.spawnStack(world, ItemStack.new("fish", 2), at(30, 0, 30), STILL)
	World.advanceTo(world, 100 + GroundItems.LIFETIME_SECONDS - 0.01)
	check(onGround(world, "fish") == 2, "advanceTo: a ground item lies until its time is up")
	World.advanceTo(world, 100 + GroundItems.LIFETIME_SECONDS)
	check(onGround(world, "fish") == 0, "advanceTo: and then is gone")
end

do -- time passing: screens close
	local world, state, ids = newWorld()
	World.openPlacedItemScreen(world, state, ids.crate)
	World.setCharacterPositionAndFacing(world, 1, at(6, 0, 6 + World.SCREEN_CLOSES_BEYOND), ALONG_X)
	World.advanceTo(world, 101)
	check(state.screen ~= nil, "advanceTo: a screen stays open at exactly the distance it closes beyond")
	World.setCharacterPositionAndFacing(world, 1, at(6, 0, 6.01 + World.SCREEN_CLOSES_BEYOND), ALONG_X)
	World.advanceTo(world, 102)
	check(state.screen == nil and state.openedPlacedItemId == nil, "advanceTo: and closes once the player is beyond it")

	World.setCharacterPositionAndFacing(world, 1, at(6, 0, 0), ALONG_X)
	World.openPlacedItemScreen(world, state, ids.crate)
	InventoryScreen.pickUpFromSlot(state.screen :: any, "other", 1)
	World.removeCharacter(world, 1)
	check(
		state.screen == nil,
		"removeCharacter: a screen on a placed item closes when the player loses their character"
	)
	World.advanceTo(world, 103)
	check(Inventory.countItems(state.pack, "fish") == 5, "advanceTo: and what they carried is in their pack")

	World.setCharacterPositionAndFacing(world, 1, at(6, 0, 0), ALONG_X)
	World.openPlacedItemScreen(world, state, ids.crate)
	Plot.removePlacedItem(world.plot, ids.crate)
	World.advanceTo(world, 104)
	check(state.screen == nil, "advanceTo: a screen closes when its placed item is no longer on the plot")

	World.openPlacedItemScreen(world, state, ids.oven)
	World.setCharacterPositionAndFacing(world, 1, at(6, 0, 6), ALONG_X)
	World.advanceTo(world, 105)
	check(state.screen ~= nil, "advanceTo: a screen stays open for a player who stays near")

	World.closeScreen(world, state)
	PlayerState.openPackScreen(state)
	World.setCharacterPositionAndFacing(world, 1, at(500, 0, 500), ALONG_X)
	World.advanceTo(world, 106)
	check(state.screen ~= nil, "advanceTo: the pack open alone stays open wherever the player goes")
	World.removeCharacter(world, 1)
	check(state.screen == nil, "removeCharacter: the pack open alone closes too when the player loses their character")

	-- The pack is full, so what is carried is thrown from the player's character.
	local full, fullState, fullIds = newWorld()
	World.openPlacedItemScreen(full, fullState, fullIds.crate)
	InventoryScreen.pickUpFromSlot(fullState.screen :: any, "other", 1)
	for slot = 1, PlayerState.PACK_SLOT_COUNT do
		Inventory.setStack(fullState.pack, slot, ItemStack.new("stove", 1))
	end
	World.setCharacterPositionAndFacing(full, 1, at(6, 0, 200), { x = 0, z = 1 })
	World.advanceTo(full, 101)
	local fish = groundStacks(full, "fish")
	check(
		fullState.screen == nil
			and #fish == 1
			and isAt(fish[1], 6, World.CHARACTER_THROW_START_HEIGHT, 200)
			and wasSpawnedMovingAt(fish[1], 0, World.CHARACTER_THROW_UPWARD_SPEED, World.CHARACTER_THROW_FORWARD_SPEED),
		"advanceTo: a screen closed for being out of reach throws what is left of the carried stack into the world"
	)
end

do -- time passing: stations
	local world, _, ids = newWorld()
	local inside = insideOf(world, ids.oven)
	Inventory.setStack(inside, Station.INPUT_SLOT, ItemStack.new("fish", 3))
	Inventory.setStack(inside, Station.FUEL_SLOT, ItemStack.new("log", 4))
	World.advanceTo(world, 104)
	local progress = StationProgress.new(world.stations[ids.oven], 104)
	check(
		math.abs(StationProgress.getFuelLeftRatio(progress, 104) - 0.75) < 1e-6
			and math.abs(StationProgress.getWorkDoneRatio(progress, 104) - 0.5) < 1e-6,
		"advanceTo: a station burns and works for the time that has passed since the world was last advanced"
	)
	check(is(Inventory.getStack(inside, Station.FUEL_SLOT), "log", 3), "advanceTo: lighting it used a log")
	World.advanceTo(world, 108)
	check(
		is(Inventory.getStack(inside, Station.OUTPUT_SLOT), "cooked_fish", 1)
			and is(Inventory.getStack(inside, Station.INPUT_SLOT), "fish", 2),
		"advanceTo: and in time turns a fish into a cooked fish"
	)
	World.advanceTo(world, 110)
	check(world.stations[ids.oven].workedSeconds > 0, "advanceTo: (set up) the second fish is being worked on")
	local worked = world.stations[ids.oven].workedSeconds
	World.advanceTo(world, 108)
	check(
		world.stations[ids.oven].workedSeconds == worked,
		"advanceTo: no time passes for a station when the time given is earlier"
	)
	World.advanceTo(world, 108)
	check(world.stations[ids.oven].workedSeconds == worked, "advanceTo: nor when it is the same as the time before")

	-- Work goes on whether or not a player is near, or there is one at all.
	local idle = Plot.new(3, 3)
	local idleOven = Plot.placeItem(idle, "oven", 1, 1) :: number
	local idleInside = idle.placedItemsById[idleOven].inventory :: Inventory.Inventory
	Inventory.setStack(idleInside, Station.INPUT_SLOT, ItemStack.new("fish", 2))
	Inventory.setStack(idleInside, Station.FUEL_SLOT, ItemStack.new("log", 1))
	local idleWorld = World.new(idle, at(0, 0, 0), 0)
	World.advanceTo(idleWorld, 16)
	check(
		is(Inventory.getStack(idleInside, Station.OUTPUT_SLOT), "cooked_fish", 2),
		"advanceTo: a station works with no player in the world at all"
	)
	check(not Station.isBurning(idleWorld.stations[idleOven]), "advanceTo: and its fire is out once the log has burnt")

	-- Every station works, each on its own.
	local two = Plot.new(3, 3)
	local first = Plot.placeItem(two, "oven", 1, 1) :: number
	local second = Plot.placeItem(two, "oven", 2, 1) :: number
	for _, id in { first, second } do
		local oven = two.placedItemsById[id].inventory :: Inventory.Inventory
		Inventory.setStack(oven, Station.INPUT_SLOT, ItemStack.new("fish", 1))
		Inventory.setStack(oven, Station.FUEL_SLOT, ItemStack.new("log", 1))
	end
	local twoWorld = World.new(two, at(0, 0, 0), 0)
	World.advanceTo(twoWorld, 8)
	check(
		is(Inventory.getStack(insideOf(twoWorld, first), Station.OUTPUT_SLOT), "cooked_fish", 1)
			and is(Inventory.getStack(insideOf(twoWorld, second), Station.OUTPUT_SLOT), "cooked_fish", 1),
		"advanceTo: every station on the plot works, each on its own"
	)

	-- A placed oven starts working at the next step, from the time then.
	local fresh = newWorld()
	local newOven = World.placeItem(fresh, "oven", 6, 6) :: number
	Inventory.setStack(insideOf(fresh, newOven), Station.INPUT_SLOT, ItemStack.new("fish", 1))
	Inventory.setStack(insideOf(fresh, newOven), Station.FUEL_SLOT, ItemStack.new("log", 1))
	World.advanceTo(fresh, 108)
	check(
		is(Inventory.getStack(insideOf(fresh, newOven), Station.OUTPUT_SLOT), "cooked_fish", 1),
		"advanceTo: an oven placed in a running world works at once"
	)
end

do -- a player leaves
	local world, state, ids = newWorld()
	World.openPlacedItemScreen(world, state, ids.crate)
	InventoryScreen.pickUpFromSlot(state.screen :: any, "other", 1)
	local removed = World.removePlayer(world, 1)
	check(removed == state and world.players[1] == nil, "removePlayer: the player is out of the world")
	check(
		state.screen == nil and Inventory.countItems(state.pack, "fish") == 5,
		"removePlayer: what they carried is in the pack they leave with"
	)
	check(Inventory.isEmpty(insideOf(world, ids.crate)), "removePlayer: and not in the crate")

	local full, fullState, fullIds = newWorld()
	for slot = 1, PlayerState.PACK_SLOT_COUNT do
		Inventory.setStack(fullState.pack, slot, ItemStack.new("stove", 1))
	end
	World.openPlacedItemScreen(full, fullState, fullIds.crate)
	InventoryScreen.pickUpFromSlot(fullState.screen :: any, "other", 1)
	World.removePlayer(full, 1)
	local fish = groundStacks(full, "fish")
	check(
		#fish == 1 and is(fish[1].stack, "fish", 5),
		"removePlayer: a carried stack the pack has no room for is thrown into the world"
	)
	check(
		isAt(fish[1], 6, World.CHARACTER_THROW_START_HEIGHT, 0)
			and wasSpawnedMovingAt(fish[1], World.CHARACTER_THROW_FORWARD_SPEED, World.CHARACTER_THROW_UPWARD_SPEED, 0),
		"removePlayer: from their character, the way it faces"
	)
end

do -- several players, several things at once, and no item is made or lost
	local seed = 9001
	local function random(limit: number): number
		seed = (seed * 16807) % 2147483647
		return math.floor(seed / 65536) % limit + 1
	end
	local function randomPack(): Inventory.Inventory
		local pack = Inventory.new(PlayerState.PACK_SLOT_COUNT)
		for _ = 1, 6 do
			local itemId = itemIds[random(#itemIds)]
			Inventory.addItems(pack, itemId, random(ItemRegistry.get(itemId).stackSize))
		end
		return pack
	end

	local problems, firstProblem = 0, ""
	local function expect(condition: boolean, what: string)
		if not condition then
			problems += 1
			firstProblem = if firstProblem == "" then what else firstProblem
		end
	end
	local errors, firstError = 0, ""
	local neverMore, constantBetweenSteps, exactWhenYoung = true, true, true
	local tidy = true
	for round = 1, 24 do
		-- In the even rounds time moves slowly, so nothing lies long enough to expire and every item must still be there.
		local slow = round % 2 == 0
		local world = World.new(Plot.new(6, 6), at(0, 0, 0), 0)
		local now = 0
		local playerIds = { 1, 2, 3 }
		-- What has left the world with a player, and what has come in with one. Negative for the second.
		local gone: { [string]: number } = {}
		local function total(itemId: string): number
			return inWorld(world, itemId) + (gone[itemId] or 0)
		end
		for _, playerId in playerIds do
			local pack = randomPack()
			for _, itemId in itemIds do
				gone[itemId] = (gone[itemId] or 0) - Inventory.countItems(pack, itemId)
			end
			World.addPlayer(world, playerId, pack)
		end
		local before: { [string]: number } = {}
		for _, itemId in itemIds do
			before[itemId] = total(itemId)
		end

		local function run(action: () -> ())
			local ok, problem = pcall(action)
			if not ok then
				errors += 1
				firstError = if firstError == "" then tostring(problem) else firstError
			end
		end

		for _ = 1, 500 do
			local action = random(24)
			local playerId = playerIds[random(#playerIds)]
			local state = world.players[playerId]
			local stepped = false
			if action <= 3 then
				if state ~= nil then
					if random(8) == 1 then
						run(function()
							World.removeCharacter(world, playerId)
						end)
					else
						local standing = at(random(28) - 2, 0, random(28) - 2)
						run(function()
							local facing = if random(2) == 1 then ALONG_X else { x = 0, z = -1 }
							World.setCharacterPositionAndFacing(world, playerId, standing, facing)
						end)
					end
				end
			elseif action <= 5 then
				now += if slow then 0.2 else random(60)
				stepped = true
				run(function()
					World.advanceTo(world, now)
				end)
			elseif action == 6 then
				if state ~= nil then
					run(function()
						local removed = World.removePlayer(world, playerId)
						expect(removed == state, "removePlayer returns the player it removes")
						for _, itemId in itemIds do
							gone[itemId] = (gone[itemId] or 0) + Inventory.countItems(state.pack, itemId)
						end
					end)
				else
					local pack = randomPack()
					for _, itemId in itemIds do
						gone[itemId] = (gone[itemId] or 0) - Inventory.countItems(pack, itemId)
					end
					run(function()
						World.addPlayer(world, playerId, pack)
					end)
				end
			elseif action <= 9 then
				-- Place one item taken from a slot of the pack, or put it back if it cannot be placed.
				if state ~= nil then
					run(function()
						local slot = random(PlayerState.PACK_SLOT_COUNT)
						local taken = Inventory.takeFromSlot(state.pack, slot, 1)
						if taken ~= nil then
							if World.placeItem(world, taken.itemId, random(6), random(6)) == nil then
								local leftover = Inventory.addStack(state.pack, taken)
								expect(leftover == nil, "an item taken from a slot goes back into the pack")
							end
						end
					end)
				end
			elseif action <= 11 then
				local ids = placedIds(world)
				run(function()
					knockOff(world, if #ids > 0 and random(5) > 1 then ids[random(#ids)] else random(40))
				end)
			elseif action <= 13 then
				if state ~= nil then
					local ids = placedIds(world)
					run(function()
						local id = if #ids > 0 and random(5) > 1 then ids[random(#ids)] else random(40)
						local openedBefore = state.openedPlacedItemId
						local opened = World.openPlacedItemScreen(world, state, id)
						expect(
							state.openedPlacedItemId == (if opened then id else openedBefore),
							"openPlaced opens that placed item, or changes nothing and says so"
						)
					end)
				end
			elseif action == 14 then
				if state ~= nil then
					run(function()
						World.closeScreen(world, state)
						expect(
							state.screen == nil and state.openedPlacedItemId == nil,
							"closeScreen leaves nothing open"
						)
					end)
				end
			elseif action == 15 then
				if state ~= nil then
					PlayerState.openPackScreen(state)
				end
			elseif action <= 20 then
				-- What a player does with an open screen.
				local screen = if state ~= nil then state.screen else nil
				if screen ~= nil then
					run(function()
						local side: InventoryScreen.Side = if screen.otherInventory ~= nil and random(2) == 1
							then "other"
							else "pack"
						local inventory = InventoryScreen.getInventoryOnSide(screen, side)
						local slot = random(inventory.slotCount)
						local kind = random(5)
						if kind == 1 then
							InventoryScreen.pickUpFromSlot(
								screen,
								side,
								slot,
								if random(2) == 1 then nil else random(8)
							)
						elseif kind == 2 then
							InventoryScreen.putDownInSlot(screen, side, slot, if random(2) == 1 then nil else random(8))
						elseif kind == 3 then
							InventoryScreen.swapCarriedStackWithSlot(screen, side, slot)
						elseif kind == 4 then
							InventoryScreen.moveFromSlotToInventory(
								screen,
								side,
								slot,
								if side == "pack" and screen.otherInventory ~= nil then "other" else "pack"
							)
						else
							local taken = InventoryScreen.takeCarriedStack(screen, random(4))
							local character = (state :: PlayerState.PlayerState).character
							expect(character ~= nil, "a player with a screen open has a character")
							if taken ~= nil and character ~= nil then
								World.throwStackFromCharacter(world, character, taken)
							end
						end
					end)
				end
			else
				-- Drop part of a slot of the pack, or say that a ground item has moved.
				if state ~= nil then
					run(function()
						local character = state.character
						local taken = if character
							then Inventory.takeFromSlot(state.pack, random(PlayerState.PACK_SLOT_COUNT), random(4))
							else nil
						if taken ~= nil and character ~= nil then
							World.throwStackFromCharacter(world, character, taken)
						end
						local moved = random(math.max(world.groundItems.nextId - 1, 1))
						World.setGroundItemPosition(world, moved, at(random(28) - 2, 0, random(28) - 2))
					end)
				end
			end

			for _, itemId in itemIds do
				local after = total(itemId)
				if after > before[itemId] then
					neverMore = false
				elseif after < before[itemId] and not stepped then
					constantBetweenSteps = false
				elseif after < before[itemId] and slow then
					exactWhenYoung = false
				end
				before[itemId] = after
			end

			for _, other in world.players do
				local placedItemId = other.openedPlacedItemId
				expect(
					placedItemId == nil or (other.screen ~= nil and world.plot.placedItemsById[placedItemId] ~= nil),
					"a player has a placed item open only if they have a screen and it is on the plot"
				)
				expect(other.screen == nil or other.character ~= nil, "a player with a screen open has a character")
			end
			for id in world.stations do
				tidy = tidy and world.plot.placedItemsById[id] ~= nil
			end
		end
	end
	check(errors == 0, "12,000 random moves: none raises an error (first: " .. firstError .. ")")
	check(neverMore, "12,000 random moves: no item is ever made")
	check(constantBetweenSteps, "12,000 random moves: no item is lost except when time passes")
	check(exactWhenYoung, "12,000 random moves: and none is lost then either, until it has lain on the ground too long")
	check(problems == 0, "12,000 random moves: every call does what it says (first: " .. firstProblem .. ")")
	check(tidy, "12,000 random moves: a station is kept only while its placed item stands on the plot")
end

Check.finish("World")
