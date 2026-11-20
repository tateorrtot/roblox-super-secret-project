--!strict
-- Tests for Stove. Run from the repository root: lune run tests/placedObjectKinds/Stove.test.luau

local Check = require("../Check")
local GroundItems = require("../../src/shared/world/GroundItems")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemDefinitions = require("../../src/shared/items/ItemDefinitions")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlaceableItems = require("../../src/shared/placedObjectKinds/PlaceableItems")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local RecipeDefinitions = require("../../src/shared/stations/RecipeDefinitions")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")
local Station = require("../../src/shared/stations/Station")
local Stove = require("../../src/shared/placedObjectKinds/Stove")
local World = require("../../src/shared/world/World")

local check = Check.that
local at = Position.new

-- The game's own items and recipes: a stove cooks by the recipes written for it.
for _, definition in ItemDefinitions do
	ItemRegistry.register(definition)
end
for _, recipe in RecipeDefinitions do
	RecipeRegistry.register(recipe)
end

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

-- How many ground items a world has.
local function groundItemCount(world: World.World): number
	local count = 0
	for _ in world.groundItems.itemsById do
		count += 1
	end
	return count
end

-- A world at time 50 with a plot of 4 by 4 tiles whose corner is at the origin, so that the middle of
-- tile x, z is at x * 4 - 2, z * 4 - 2. A stove stands on tile 2, 2 (its middle is 6, 6). Player 1
-- stands at 6, 0, 0 with a pack that holds nothing.
local function newWorld(): (World.World, PlayerState.PlayerState, number)
	local world = World.new(Plot.new(4, 4), at(0, 0, 0), 50)
	local stoveId = Stove.place(world, 2, 2)
	local player = World.addPlayer(world, 1)
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	return world, player, stoveId
end

do -- a stove as names, and its recipes
	check(Stove.KIND_ID == "stove", 'KIND_ID: a stove is of the kind "stove"')
	check(
		PlaceableItems[Stove.ITEM_ID] == Stove.KIND_ID,
		"ITEM_ID: the item that a broken stove leaves is the item that places a stove"
	)
	for index, recipe in RecipeDefinitions do
		check(
			recipe.station == Stove.KIND_ID,
			"RecipeDefinitions: row " .. index .. " is a recipe for the stove, the one kind of station there is"
		)
	end
end

do -- place
	local world = World.new(Plot.new(4, 4), at(0, 0, 0), 0)
	local id = Stove.place(world, 2, 3)
	local placed = world.plot.placedObjectsById[id]
	check(
		placed ~= nil and placed.kindId == Stove.KIND_ID and placed.tileX == 2 and placed.tileZ == 3,
		"place: a placed object of the stove's kind stands on the tile, and its id is returned"
	)
	local station = world.stations[id]
	check(station ~= nil and station.kindId == Stove.KIND_ID, "place: the stove is made a station of its own kind")
	check(
		station ~= nil and station.inventory.slotCount == Station.SLOT_COUNT and Inventory.isEmpty(station.inventory),
		"place: with a station's slots, holding nothing"
	)
	check(
		station ~= nil and not Station.isBurning(station) and station.workedSeconds == 0,
		"place: and with no fire and no work done"
	)
	check(world.placedObjectInventories[id] == nil, "place: a stove is given no inventory besides its station's own")

	local second = Stove.place(world, 1, 1)
	check(
		second ~= id and world.stations[second] ~= station and world.stations[second].inventory ~= station.inventory,
		"place: each stove has an id, a station and slots of its own"
	)
	check(Check.errorFrom(function()
		Stove.place(world, 2, 3)
	end) ~= nil, "place: fails on a tile that is taken")
	check(
		world.plot.nextId == second + 1 and world.stations[second + 1] == nil,
		"place: a placing that fails places nothing and makes no station"
	)
end

do -- a placed stove cooks
	local world = World.new(Plot.new(4, 4), at(0, 0, 0), 0)
	local id = Stove.place(world, 1, 1)
	local slots = world.stations[id].inventory
	Inventory.setStack(slots, Station.INPUT_SLOT, ItemStack.new("fish", 2))
	Inventory.setStack(slots, Station.FUEL_SLOT, ItemStack.new("log", 1))
	World.advanceTo(world, 8)
	check(
		is(Inventory.getStack(slots, Station.OUTPUT_SLOT), "cooked_fish", 1)
			and is(Inventory.getStack(slots, Station.INPUT_SLOT), "fish", 1),
		"place: a placed stove cooks by the recipes written for the stove as the world's time passes"
	)
end

do -- interact
	local world, player, stoveId = newWorld()
	local slots = world.stations[stoveId].inventory
	Stove.interact(world, player, stoveId)
	local screen = player.screen :: InventoryScreen.InventoryScreen
	check(
		screen ~= nil and screen.pack == player.pack and screen.otherInventory == slots,
		"interact: the slots of the stove's station open on the player's screen, beside their pack"
	)
	check(World.getOpenedPlacedObjectId(world, player) == stoveId, "interact: as the screen of that stove")
	check(
		InventoryScreen.slotAcceptsItem(screen, "other", Station.INPUT_SLOT, "fish")
			and not InventoryScreen.slotAcceptsItem(screen, "other", Station.INPUT_SLOT, "log"),
		"interact: the input slot takes only what a stove has a recipe for"
	)
	check(
		InventoryScreen.slotAcceptsItem(screen, "other", Station.FUEL_SLOT, "log")
			and not InventoryScreen.slotAcceptsItem(screen, "other", Station.FUEL_SLOT, "fish"),
		"interact: the fuel slot takes only what burns"
	)
	check(
		not InventoryScreen.slotAcceptsItem(screen, "other", Station.OUTPUT_SLOT, "cooked_fish"),
		"interact: nothing can be put in the output slot"
	)
	check(InventoryScreen.slotAcceptsItem(screen, "pack", 1, "fish"), "interact: while the pack takes anything")

	Inventory.setStack(player.pack, 1, ItemStack.new("log", 6))
	InventoryScreen.pickUpFromSlot(screen, "pack", 1)
	Stove.interact(world, player, stoveId)
	check(
		player.screen ~= screen and player.screen ~= nil,
		"interact: a screen that was open is closed, and a new one opens"
	)
	check(
		Inventory.countItems(player.pack, "log") == 6,
		"interact: and what was carried on the old screen is in the player's pack"
	)

	World.setCharacterPosition(world, 1, at(500, 0, 500))
	Stove.interact(world, player, stoveId)
	check(
		World.getOpenedPlacedObjectId(world, player) == stoveId,
		"interact: it does not ask how far from the stove the player stands"
	)

	local second = World.addPlayer(world, 2)
	check(Check.errorFrom(function()
		Stove.interact(world, second, stoveId)
	end) ~= nil and second.screen == nil, "interact: fails for a player with no character")
end

do -- breakPlacedObject
	local world, breaker, stoveId = newWorld()
	local station = world.stations[stoveId]
	local slots = station.inventory
	Inventory.setStack(slots, Station.INPUT_SLOT, ItemStack.new("fish", 3))
	Inventory.setStack(slots, Station.FUEL_SLOT, ItemStack.new("log", 4))
	World.advanceTo(world, 54)
	check(
		Station.isBurning(station) and is(Inventory.getStack(slots, Station.FUEL_SLOT), "log", 3),
		"breakPlacedObject: (set up) the stove is lit, and one log is burning"
	)
	local watcher = World.addPlayer(world, 2)
	World.setCharacterPosition(world, 2, at(10, 0, 10))
	Stove.interact(world, watcher, stoveId)

	Stove.breakPlacedObject(world, breaker, stoveId)
	check(world.plot.placedObjectsById[stoveId] == nil, "breakPlacedObject: the stove is off the plot")
	check(Plot.canPlaceObject(world.plot, 2, 2), "breakPlacedObject: and its tile holds nothing")
	check(world.stations[stoveId] == nil, "breakPlacedObject: it is a station no longer")
	check(
		watcher.screen == nil and World.getOpenedPlacedObjectId(world, watcher) == nil,
		"breakPlacedObject: a screen that was open on the stove is closed"
	)

	local ground = world.groundItems.itemsById
	check(
		groundItemCount(world) == 3,
		"breakPlacedObject: one ground item for the stove and one for each stack in its slots"
	)
	check(is(ground[1].stack, Stove.ITEM_ID, 1), "breakPlacedObject: one of the item ITEM_ID is thrown first")
	check(
		is(ground[2].stack, "fish", 3) and is(ground[3].stack, "log", 3),
		"breakPlacedObject: then each stack that was in its slots, from the lowest slot up"
	)
	check(Inventory.isEmpty(slots), "breakPlacedObject: and the slots hold nothing")
	local middleHeight = (Plot.TILE_SIZE - GroundItems.ITEM_WIDTH) / 2
	local allFromTheMiddle, allUpwards = true, true
	local ways: { [string]: boolean } = {}
	local wayCount = 0
	for _, groundItem in ground do
		local position, velocity = groundItem.position, groundItem.spawnVelocity
		if Position.getDistance(position, at(6, middleHeight, 6)) > 1e-9 or groundItem.spawnTime ~= 54 then
			allFromTheMiddle = false
		end
		if velocity.y <= 0 or (velocity.x == 0 and velocity.z == 0) then
			allUpwards = false
		end
		local way = string.format("%.3f %.3f", velocity.x, velocity.z)
		wayCount += if ways[way] then 0 else 1
		ways[way] = true
	end
	check(
		allFromTheMiddle,
		"breakPlacedObject: each is thrown from the middle of the stove's tile, at the world's time"
	)
	check(allUpwards, "breakPlacedObject: upwards and outwards")
	check(wayCount == 3, "breakPlacedObject: each a different way")

	World.advanceTo(world, 200)
	local cooked = 0
	for _, groundItem in ground do
		cooked += if groundItem.stack.itemId == "cooked_fish" then groundItem.stack.count else 0
	end
	check(
		cooked == 0 and Inventory.isEmpty(slots),
		"breakPlacedObject: the fuel that was burning is lost, and nothing more is cooked"
	)
	check(
		breaker.screen == nil and Inventory.countItems(breaker.pack, "stove") == 0,
		"breakPlacedObject: the player who broke it is given nothing and has no screen opened"
	)

	local emptyWorld, emptyBreaker, emptyStoveId = newWorld()
	Stove.breakPlacedObject(emptyWorld, emptyBreaker, emptyStoveId)
	check(
		groundItemCount(emptyWorld) == 1 and is(emptyWorld.groundItems.itemsById[1].stack, Stove.ITEM_ID, 1),
		"breakPlacedObject: a stove whose slots hold nothing leaves one of the item ITEM_ID and no more"
	)
end

Check.finish("Stove")
