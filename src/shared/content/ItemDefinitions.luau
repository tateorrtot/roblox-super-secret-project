--!strict
--- The written definition of every item in the game, one row each.
---
--- A row is an `ItemRegistry.ItemDefinition`: its id and its stack size. These rows are
--- placeholders.
local ItemRegistry = require("../items/ItemRegistry")

local definitions: { ItemRegistry.ItemDefinition } = {
	{ id = "log", stackSize = 16 },
	{ id = "stone", stackSize = 16 },
	{ id = "crystal", stackSize = 32 },
	{ id = "apple", stackSize = 16 },
	{ id = "fish", stackSize = 8 },
	{ id = "cheese", stackSize = 8 },
	{ id = "cooked_fish", stackSize = 8 },
	{ id = "baked_apple", stackSize = 16 },
	{ id = "stove", stackSize = 1 },
	{ id = "crate", stackSize = 1 },
}

return table.freeze(definitions)
