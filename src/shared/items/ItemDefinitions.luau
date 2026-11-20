--!strict
--- The written definition of every item in the game, one row each.
---
--- A row is an `ItemRegistry.ItemDefinition`: its id, its stack size, and for an item that burns
--- as fuel, how long it burns. These rows are placeholders.
local ItemRegistry = require("./ItemRegistry")

local definitions: { ItemRegistry.ItemDefinition } = {
	{ id = "log", stackSize = 16, burnSeconds = 16 },
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
