--!strict
-- Tests for RecipeRegistry. Run from the repository root: lune run tests/stations/RecipeRegistry.test.luau

local Check = require("../Check")
local FuelRegistry = require("../../src/shared/stations/FuelRegistry")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")

local check = Check.that

ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "cooked_fish", stackSize = 8 })
ItemRegistry.register({ id = "apple", stackSize = 16 })
ItemRegistry.register({ id = "baked_apple", stackSize = 16 })
ItemRegistry.register({ id = "log", stackSize = 16 })
FuelRegistry.register({ item = "log", seconds = 16 })

do -- an empty registry
	check(RecipeRegistry.find("stove", "fish") == nil, "find: nil before any recipe is registered")
end

do -- register, then look up
	local written = { station = "stove", input = "fish", output = "cooked_fish", seconds = 8 }
	RecipeRegistry.register(written)
	local recipe = RecipeRegistry.find("stove", "fish")
	check(
		recipe ~= nil
			and recipe.station == "stove"
			and recipe.input == "fish"
			and recipe.output == "cooked_fish"
			and recipe.seconds == 8,
		"find: the recipe that was registered"
	)
	check(recipe ~= nil and table.isfrozen(recipe), "find: a recipe never changes")
	written.seconds = 99
	check(
		(RecipeRegistry.find("stove", "fish") :: any).seconds == 8,
		"register: changing the given table afterwards changes nothing"
	)

	RecipeRegistry.register({ station = "stove", input = "apple", output = "baked_apple", seconds = 0.5 })
	RecipeRegistry.register({ station = "kiln", input = "fish", output = "apple", seconds = 3 })
	check(
		(RecipeRegistry.find("stove", "apple") :: any).output == "baked_apple",
		"find: a kind of station has a recipe for each item it works on"
	)
	check(
		(RecipeRegistry.find("kiln", "fish") :: any).output == "apple",
		"find: each kind of station has recipes of its own"
	)
	check(RecipeRegistry.find("kiln", "apple") == nil, "find: nil for an item that kind of station does nothing with")
	check(RecipeRegistry.find("stove", "log") == nil, "find: nil for an item no recipe takes")
	check(
		RecipeRegistry.find("anvil", "fish") == nil and RecipeRegistry.find("stove", "anvil") == nil,
		"find: nil for ids that do not exist"
	)
end

do -- what register refuses
	local function refuses(what: string, part: string, recipe: any)
		check(
			Check.raises(part, function()
				RecipeRegistry.register(recipe)
			end),
			"register: fails for " .. what .. ', saying "' .. part .. '"'
		)
	end
	refuses(
		"an input that does not exist",
		'station "kiln" with input "anvil": no item has the id "anvil"',
		{ station = "kiln", input = "anvil", output = "apple", seconds = 1 }
	)
	refuses(
		"an output that does not exist",
		'station "kiln" with input "apple": no item has the id "anvil"',
		{ station = "kiln", input = "apple", output = "anvil", seconds = 1 }
	)
	for _, bad in { 0, -2, math.huge } do
		refuses(
			"seconds = " .. bad,
			'station "kiln" with input "apple": seconds must be above 0 and finite, not ' .. bad,
			{ station = "kiln", input = "apple", output = "fish", seconds = bad }
		)
	end
	refuses(
		"seconds that is not a number",
		'station "kiln" with input "apple": seconds must be above 0 and finite, not nan',
		{ station = "kiln", input = "apple", output = "fish", seconds = 0 / 0 }
	)
	refuses(
		"a second recipe for the same input on the same kind of station",
		'station "stove" with input "fish": already has a recipe',
		{ station = "stove", input = "fish", output = "apple", seconds = 1 }
	)
	check(RecipeRegistry.find("kiln", "apple") == nil, "register: a failed recipe is not registered")
	check(
		(RecipeRegistry.find("stove", "fish") :: any).output == "cooked_fish",
		"register: and the recipe that was there is unchanged"
	)
end

do -- the kind of station is not checked
	RecipeRegistry.register({ station = "a kind nobody has heard of", input = "fish", output = "apple", seconds = 1 })
	check(
		RecipeRegistry.find("a kind nobody has heard of", "fish") ~= nil,
		"register: takes any id for the kind of station, and is not told which kinds there are"
	)
end

Check.finish("RecipeRegistry")
