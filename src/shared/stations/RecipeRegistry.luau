--!strict
--- Every recipe the game has: what each kind of station turns into what, and how long it takes.
---
--- A recipe belongs to one kind of station and turns one item into another. A kind of station has
--- at most one recipe for each item.
local ItemRegistry = require("../items/ItemRegistry")

local RecipeRegistry = {}

--- What one kind of station does with one item. It never changes once registered.
export type Recipe = {
	--- The id of the kind of station, such as `"stove"`.
	read station: string,
	--- The id of the item that goes in. One of it is used each time.
	read input: string,
	--- The id of the item that comes out. One of it is made each time.
	read output: string,
	--- How long it takes, in seconds: a finite number above 0.
	read seconds: number,
}

local recipesByStationThenInput: { [string]: { [string]: Recipe } } = {}

--- Adds a copy of `recipe` to the registry, so that changing `recipe` afterwards changes nothing.
--- Only the four fields of `Recipe` are copied. Fails if `recipe.input` or `recipe.output` is not
--- a registered item, if `recipe.seconds` is not a finite number above 0, or if that kind of
--- station already has a recipe for the input.
--- Note: `recipe.station` is not checked. The registry does not know which kinds of station there
--- are.
function RecipeRegistry.register(recipe: Recipe)
	local station, input = recipe.station, recipe.input
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

--- Returns the recipe by which a station of the kind `station` works on the item `input`. Returns
--- `nil` if there is none, including when no item has the id `input`.
function RecipeRegistry.find(station: string, input: string): Recipe?
	local ofStation = recipesByStationThenInput[station]
	return if ofStation ~= nil then ofStation[input] else nil
end

return RecipeRegistry
