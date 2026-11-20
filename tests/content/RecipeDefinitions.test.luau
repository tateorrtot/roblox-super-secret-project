--!strict
-- Tests for the written rows of recipes. Run from the repository root: lune run tests/content/RecipeDefinitions.test.luau

local Check = require("../Check")
local FuelDefinitions = require("../../src/shared/content/FuelDefinitions")
local FuelRegistry = require("../../src/shared/stations/FuelRegistry")
local ItemDefinitions = require("../../src/shared/content/ItemDefinitions")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local RecipeDefinitions = require("../../src/shared/content/RecipeDefinitions")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")
local Station = require("../../src/shared/stations/Station")

local check = Check.that

for _, definition in ItemDefinitions do
	ItemRegistry.register(definition)
end

check(#RecipeDefinitions > 0, "there is at least one recipe")
for index, recipe in RecipeDefinitions do
	local problem = Check.errorFrom(function()
		RecipeRegistry.register(recipe)
	end)
	check(problem == nil, "row " .. index .. " is a recipe the registry accepts: " .. tostring(problem))
	check(recipe.input ~= recipe.output, "row " .. index .. " turns its item into a different one")
end

check(#FuelDefinitions > 0, "there is at least one fuel, so that a station can be lit")
for index, fuel in FuelDefinitions do
	local problem = Check.errorFrom(function()
		FuelRegistry.register(fuel)
	end)
	check(problem == nil, "fuel row " .. index .. " is a fuel the registry accepts: " .. tostring(problem))
	check(
		Station.slotAcceptsItem("stove", Station.FUEL_SLOT, fuel.item),
		'a station takes "' .. fuel.item .. '" in its fuel slot'
	)
end

for _, recipe in RecipeDefinitions do
	check(
		Station.slotAcceptsItem(recipe.station, Station.INPUT_SLOT, recipe.input),
		'the station "' .. recipe.station .. '" takes "' .. recipe.input .. '" in its input slot'
	)
end

Check.finish("RecipeDefinitions")
