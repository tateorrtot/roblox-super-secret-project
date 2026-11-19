--!strict
--[=[
	The written definition of every recipe in the game, one row each: which
	station turns which item into which, and in how many seconds.

	When the game starts, on the server and on each player's machine, every
	row is given to `RecipeRegistry.register`, after the items have been
	registered. How long an item burns as fuel is not here: it is the item's
	own `burnSeconds`, in ItemDefinitions.

	These first rows are placeholders to build the game's machinery with.
	They are a draft, and what the game really cooks is still to be decided.

	```lua
	for _, recipe in RecipeDefinitions do
		RecipeRegistry.register(recipe)
	end
	```
]=]
local RecipeRegistry = require("./RecipeRegistry")

local recipes: { RecipeRegistry.Recipe } = {
	{ station = "stove", input = "fish", output = "cooked_fish", seconds = 8 },
	{ station = "stove", input = "apple", output = "baked_apple", seconds = 6 },
}

return table.freeze(recipes)
