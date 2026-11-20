--!strict
--- Every recipe in the game, one row each.
---
--- Each row names a kind of station, the item that goes in, the item that comes out and the
--- seconds it takes. These rows are placeholders.
local RecipeRegistry = require("./RecipeRegistry")

local recipes: { RecipeRegistry.Recipe } = {
	{ station = "stove", input = "fish", output = "cooked_fish", seconds = 8 },
	{ station = "stove", input = "apple", output = "baked_apple", seconds = 6 },
}

return table.freeze(recipes)
