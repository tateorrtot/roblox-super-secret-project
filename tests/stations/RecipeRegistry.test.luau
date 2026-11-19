--!strict
-- Tests for RecipeRegistry. Run from the repository root: lune run tests/stations/RecipeRegistry.test.luau

local Check = require("../Check")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")

local check = Check.that
local raises = Check.raises

ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "cooked_fish", stackSize = 8 })
ItemRegistry.register({ id = "apple", stackSize = 16 })
ItemRegistry.register({ id = "baked_apple", stackSize = 16 })
ItemRegistry.register({ id = "log", stackSize = 16, burnSeconds = 16 })
ItemRegistry.register({ id = "stove", stackSize = 1, placeable = true, slotCount = 3 })
ItemRegistry.register({ id = "kiln", stackSize = 1, placeable = true, slotCount = 3 })
ItemRegistry.register({ id = "crate", stackSize = 1, placeable = true, slotCount = 27 })
ItemRegistry.register({ id = "post", stackSize = 8, placeable = true })

do -- the rules as numbers
	check(RecipeRegistry.STATION_SLOTS == 3, "a station has three slots")
end

do -- an empty registry
	check(RecipeRegistry.find("stove", "fish") == nil, "find: nil before any recipe is registered")
	check(not RecipeRegistry.isStation("stove"), "isStation: a stove is not a station until it has a recipe")
	check(#RecipeRegistry.inputsOf("stove") == 0, "inputsOf: nothing for an item with no recipes")
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
	check(RecipeRegistry.isStation("stove"), "isStation: an item with a recipe is a station")
	check(
		not RecipeRegistry.isStation("kiln") and not RecipeRegistry.isStation("crate"),
		"isStation: other items are not"
	)
	check(not RecipeRegistry.isStation("anvil"), "isStation: nor is an item that does not exist")

	RecipeRegistry.register({ station = "stove", input = "apple", output = "baked_apple", seconds = 0.5 })
	RecipeRegistry.register({ station = "kiln", input = "fish", output = "apple", seconds = 3 })
	check(
		(RecipeRegistry.find("stove", "apple") :: any).output == "baked_apple",
		"find: a station has a recipe for each item it works on"
	)
	check((RecipeRegistry.find("kiln", "fish") :: any).output == "apple", "find: each station has recipes of its own")
	check(RecipeRegistry.find("kiln", "apple") == nil, "find: nil for an item that station does nothing with")
	check(RecipeRegistry.find("stove", "log") == nil, "find: nil for an item no recipe takes")
	check(
		RecipeRegistry.find("anvil", "fish") == nil and RecipeRegistry.find("stove", "anvil") == nil,
		"find: nil for ids that do not exist"
	)
	local inputs = RecipeRegistry.inputsOf("stove")
	check(
		#inputs == 2 and inputs[1] == "apple" and inputs[2] == "fish",
		"inputsOf: what the station works on, in alphabetical order"
	)
	check(
		#RecipeRegistry.inputsOf("kiln") == 1 and #RecipeRegistry.inputsOf("crate") == 0,
		"inputsOf: for each station its own"
	)
end

do -- what register refuses
	local function refuses(what: string, message: string, recipe: any)
		check(
			raises("RecipeRegistry.register: " .. message, function()
				RecipeRegistry.register(recipe)
			end),
			"register: refuses " .. what
		)
	end
	refuses("something that is not a table", "a recipe is a table, not a string", "fish")
	refuses("nothing", "a recipe is a table, not a nil", nil)
	refuses(
		"a station that does not exist",
		'station: no item has the id "anvil"',
		{ station = "anvil", input = "fish", output = "apple", seconds = 1 }
	)
	refuses(
		"an input that does not exist",
		'input: no item has the id "anvil"',
		{ station = "kiln", input = "anvil", output = "apple", seconds = 1 }
	)
	refuses(
		"an output that does not exist",
		'output: no item has the id "nil"',
		{ station = "kiln", input = "apple", seconds = 1 }
	)
	refuses(
		"an id that is not a string",
		'input: no item has the id "7"',
		{ station = "kiln", input = 7, output = "apple", seconds = 1 }
	)
	refuses(
		"a station with the wrong number of slots",
		'the station "crate" must be a placeable item with 3 slots',
		{ station = "crate", input = "apple", output = "fish", seconds = 1 }
	)
	refuses(
		"a station with no slots",
		'the station "post" must be a placeable item with 3 slots',
		{ station = "post", input = "apple", output = "fish", seconds = 1 }
	)
	refuses(
		"a station that cannot be placed",
		'the station "log" must be a placeable item with 3 slots',
		{ station = "log", input = "apple", output = "fish", seconds = 1 }
	)
	for _, bad in { 0, -2, 0 / 0, math.huge, "8", true } :: { any } do
		refuses(
			"seconds = " .. tostring(bad),
			"seconds must be a number above 0; got " .. tostring(bad),
			{ station = "kiln", input = "apple", output = "fish", seconds = bad }
		)
	end
	refuses(
		"no seconds",
		"seconds must be a number above 0; got nil",
		{ station = "kiln", input = "apple", output = "fish" }
	)
	refuses(
		"a field recipes do not have",
		"a recipe has no field called fuel",
		{ station = "kiln", input = "apple", output = "fish", seconds = 1, fuel = "log" }
	)
	refuses(
		"a second recipe for the same input on the same station",
		'the station "stove" already has a recipe for "fish"',
		{ station = "stove", input = "fish", output = "apple", seconds = 1 }
	)
	check(RecipeRegistry.find("kiln", "apple") == nil, "register: a refused recipe is not registered")
	check(
		(RecipeRegistry.find("stove", "fish") :: any).output == "cooked_fish",
		"register: and the recipe that was there is unchanged"
	)
end

Check.finish("RecipeRegistry")
