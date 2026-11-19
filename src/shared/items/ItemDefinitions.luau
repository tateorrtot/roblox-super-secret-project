--!strict
--[=[
	The written definition of every item in the game, one row each.

	A row says what the rules need to know about an item: its id, and how many
	of it fit in one stack. Bulky things stack small, and a thing that is
	placed whole, such as a stove, does not stack at all.

	When the game starts, on the server and on each player's machine, every
	row is given to `ItemRegistry.register`. How an item looks is not here: see
	ItemLooks.

	These first rows are placeholders to build the game's machinery with. They
	are a draft, and which items the game really has is still to be decided.

	```lua
	for _, definition in ItemDefinitions do
		ItemRegistry.register(definition)
	end
	```
]=]
local ItemRegistry = require("./ItemRegistry")

local definitions: { ItemRegistry.ItemDefinition } = {
	{ id = "log", stackSize = 16 },
	{ id = "stone", stackSize = 16 },
	{ id = "crystal", stackSize = 32 },
	{ id = "apple", stackSize = 16 },
	{ id = "fish", stackSize = 8 },
	{ id = "cheese", stackSize = 8 },
	{ id = "stove", stackSize = 1 },
	{ id = "crate", stackSize = 1 },
}

return table.freeze(definitions)
