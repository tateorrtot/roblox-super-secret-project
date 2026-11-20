--!strict
-- Tests for Stove. Run from the repository root: lune run tests/placedObjectKinds/Stove.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemDefinitions = require("../../src/shared/items/ItemDefinitions")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
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

do -- a stove as numbers, and its recipes
	check(Stove.KIND_ID == "stove", 'KIND_ID: a stove is of the kind "stove"')
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

Check.finish("Stove")
