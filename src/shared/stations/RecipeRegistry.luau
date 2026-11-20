--!strict
--- Every recipe the game has: what each station turns into what, and how long it takes.
---
--- A recipe belongs to one station and turns one item into another. A station has at most one
--- recipe for each item. An item is a station once a recipe is registered for it.
local ItemRegistry = require("../items/ItemRegistry")

local RecipeRegistry = {}

--- What one station does with one item. It never changes once registered.
export type Recipe = {
	--- The id of the item that is the station, such as `"stove"`.
	read station: string,
	--- The id of the item that goes in. One of it is used each time.
	read input: string,
	--- The id of the item that comes out. One of it is made each time.
	read output: string,
	--- How long it takes, in seconds: a finite number above 0.
	read seconds: number,
}

--- How many slots a station's item has: one for what goes in, one for fuel and one for what comes out.
RecipeRegistry.STATION_SLOT_COUNT = 3

local recipesByStationThenInput: { [string]: { [string]: Recipe } } = {}

--- Adds a copy of `recipe` to the registry, so that changing `recipe` afterwards changes nothing.
--- Only the four fields of `Recipe` are copied. Fails if `recipe.station` is not a registered item
--- that is placeable and has `STATION_SLOT_COUNT` slots, if `recipe.input` or `recipe.output` is not a
--- registered item, if `recipe.seconds` is not a finite number above 0, or if the station already
--- has a recipe for the input.
function RecipeRegistry.register(recipe: Recipe)
	local station, input = recipe.station, recipe.input
	if not ItemRegistry.has(station) then
		error(`station "{station}" with input "{input}": no item has the id "{station}"`, 2)
	end
	local stationItem = ItemRegistry.get(station)
	if stationItem.placeable ~= true or stationItem.slotCount ~= RecipeRegistry.STATION_SLOT_COUNT then
		error(
			`station "{station}" with input "{input}": must be placeable with {RecipeRegistry.STATION_SLOT_COUNT} slots`,
			2
		)
	end
	if not ItemRegistry.has(input) then
		error(`station "{station}" with input "{input}": no item has the id "{input}"`, 2)
	end
	if not ItemRegistry.has(recipe.output) then
		error(`station "{station}" with input "{input}": no item has the id "{recipe.output}"`, 2)
	end
	if not (recipe.seconds > 0 and recipe.seconds < math.huge) then
		error(`station "{station}" with input "{input}": seconds must be above 0 and finite, not {recipe.seconds}`, 2)
	end
	local ofStation = recipesByStationThenInput[station] or {}
	if ofStation[input] ~= nil then
		error(`station "{station}" with input "{input}": already has a recipe`, 2)
	end
	ofStation[input] =
		table.freeze({ station = station, input = input, output = recipe.output, seconds = recipe.seconds })
	recipesByStationThenInput[station] = ofStation
end

--- Returns the recipe by which the station `station` works on the item `input`. Returns `nil` if
--- there is none, including when either id is not a registered item.
function RecipeRegistry.find(station: string, input: string): Recipe?
	local ofStation = recipesByStationThenInput[station]
	return if ofStation ~= nil then ofStation[input] else nil
end

--- Returns `true` if at least one recipe is registered for the item `itemId`.
function RecipeRegistry.isStation(itemId: string): boolean
	return recipesByStationThenInput[itemId] ~= nil
end

return RecipeRegistry
