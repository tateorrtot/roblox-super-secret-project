--!strict
--- The written rows of every recipe in the game, as a list for `RecipeRegistry.register`.
---
--- Each row names a station, the item that goes in, the item that comes out and the seconds it
--- takes. How long an item burns as fuel is not here: it is the item's own `burnSeconds`. These
--- rows are placeholders.
local RecipeRegistry = require("./RecipeRegistry")

local recipes: { RecipeRegistry.Recipe } = {
	{ station = "stove", input = "fish", output = "cooked_fish", seconds = 8 },
	{ station = "stove", input = "apple", output = "baked_apple", seconds = 6 },
}

return table.freeze(recipes)
