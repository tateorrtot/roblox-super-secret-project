--!strict
-- Tests for the written rows of recipes. Run from the repository root: lune run tests/stations/RecipeDefinitions.test.luau

local Check = require("../Check")
local ItemDefinitions = require("../../src/shared/items/ItemDefinitions")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local RecipeDefinitions = require("../../src/shared/stations/RecipeDefinitions")
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

local burns = false
for _, definition in ItemRegistry.all() do
	if definition.burnSeconds ~= nil then
		burns = true
	end
end
check(burns, "at least one item burns, so that a station can be lit")

for _, recipe in RecipeDefinitions do
	local rules = Station.slotRules(recipe.station)
	check(
		rules[Station.INPUT_SLOT][recipe.input] == true,
		'the station "' .. recipe.station .. '" takes "' .. recipe.input .. '" in its input slot'
	)
end

Check.finish("RecipeDefinitions")
