--!strict
--- Every fuel in the game, one row each.
---
--- Each row names an item and the seconds that one of it burns in a station's fire. These rows
--- are placeholders.
local FuelRegistry = require("../stations/FuelRegistry")

local fuels: { FuelRegistry.Fuel } = {
	{ item = "log", seconds = 16 },
}

return table.freeze(fuels)
