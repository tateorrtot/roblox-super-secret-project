--!strict
--[=[
	Every recipe the game has: what a station turns into what, and how long
	it takes.

	A station is a placed item that works on what is put into it, as a stove
	cooks. A recipe belongs to one kind of station and turns one of an item
	into one of another: on a stove, a fish becomes a cooked fish in 8
	seconds. A station can have many recipes, one for each item it works on.

	An item is a station because it has recipes. There is nothing else to
	declare. A station's item must be placeable and have exactly three slots:
	one for what goes in, one for fuel and one for what comes out.

	Recipes are registered once, when the game starts, and never change
	after that. There is one registry for the whole game, as there is one
	ItemRegistry, and every item a recipe names must be registered there
	first.

	```lua
	RecipeRegistry.register({ station = "stove", input = "fish", output = "cooked_fish", seconds = 8 })

	RecipeRegistry.find("stove", "fish").output --> "cooked_fish"
	RecipeRegistry.find("stove", "log") --> nil: a stove does nothing with a log
	RecipeRegistry.isStation("stove") --> true
	RecipeRegistry.isStation("crate") --> false
	```
]=]
local ItemRegistry = require("../items/ItemRegistry")

local RecipeRegistry = {}

--- What one kind of station does with one item. `read` means code outside this module cannot
--- assign the field, and nothing inside it does either: a recipe never changes.
export type Recipe = {
	--- The id of the item that is the station, such as `"stove"`.
	read station: string,
	--- The id of the item that goes in. One of it is used each time.
	read input: string,
	--- The id of the item that comes out. One of it is made each time.
	read output: string,
	--- How long it takes, in seconds: a number above 0.
	read seconds: number,
}

--- How many slots a station's item must have: what goes in, fuel, and what comes out.
RecipeRegistry.STATION_SLOTS = 3

-- Every recipe, by its station's item id and then by its input's item id.
local recipes: { [string]: { [string]: Recipe } } = {}

local function fail(problem: string)
	error("RecipeRegistry.register: " .. problem, 3)
end

--[=[
	Adds a recipe to the registry.

	The registry keeps its own copy, so changing the given table afterwards
	changes nothing.

	Raises an error if `station`, `input` or `output` is not the id of a
	registered item, if the station's item is not placeable or does not have
	exactly three slots, if `seconds` is not a finite number above 0, if the table
	has any other field, or if that station already has a recipe for that
	input.
]=]
function RecipeRegistry.register(recipe: Recipe)
	if type(recipe) ~= "table" then
		fail("a recipe is a table, not a " .. type(recipe))
	end
	local fields = recipe :: { [unknown]: unknown }
	for _, name in { "station", "input", "output" } do
		local itemId = fields[name]
		if type(itemId) ~= "string" or not ItemRegistry.has(itemId) then
			fail(string.format('%s: no item has the id "%s"', name, tostring(itemId)))
		end
	end
	local station, input, output = fields.station :: string, fields.input :: string, fields.output :: string
	local stationItem = ItemRegistry.get(station)
	if stationItem.placeable ~= true or stationItem.slotCount ~= RecipeRegistry.STATION_SLOTS then
		fail(
			string.format(
				'the station "%s" must be a placeable item with %d slots: what goes in, fuel, and what comes out',
				station,
				RecipeRegistry.STATION_SLOTS
			)
		)
	end
	local seconds = fields.seconds
	if type(seconds) ~= "number" or not (seconds > 0) or seconds == math.huge then
		fail(string.format("seconds must be a finite number above 0; got %s", tostring(seconds)))
	end
	local known = { station = true, input = true, output = true, seconds = true }
	for field in fields do
		if known[field :: any] ~= true then
			fail(string.format("a recipe has no field called %s", tostring(field)))
		end
	end
	if recipes[station] ~= nil and recipes[station][input] ~= nil then
		fail(string.format('the station "%s" already has a recipe for "%s"', station, input))
	end
	recipes[station] = recipes[station] or {}
	recipes[station][input] =
		table.freeze({ station = station, input = input, output = output, seconds = seconds :: number })
end

--[=[
	Returns the recipe by which the station with the item id `station` works
	on the item with the id `input`, or `nil` if it has none.

	`station` and `input` may be any ids, registered or not: an item that is
	not a station, or one a station does nothing with, simply has no recipe.
]=]
function RecipeRegistry.find(station: string, input: string): Recipe?
	local ofStation = recipes[station]
	return if ofStation ~= nil then ofStation[input] else nil
end

--[=[
	Returns `true` if the item with the id `itemId` is a station: at least
	one recipe has been registered for it.
]=]
function RecipeRegistry.isStation(itemId: string): boolean
	return recipes[itemId] ~= nil
end

--[=[
	Returns the ids of the items that the station with the item id `station`
	works on, in alphabetical order. Empty for an item that is not a station.
]=]
function RecipeRegistry.inputsOf(station: string): { string }
	local inputs = {}
	for input in recipes[station] or {} do
		table.insert(inputs, input)
	end
	table.sort(inputs)
	return inputs
end

return RecipeRegistry
