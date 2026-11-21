--!strict
--- Every item in the game.
---
--- An item is one table. It holds the item's id and stack size, which `ItemRegistry` keeps, its
--- name, and whichever functions of `ItemScripts.ItemScript` it has a use for: what happens when
--- someone holding it acts on the world. An item with such a function is written in a file of its
--- own, as `CrateItem` is. The others are written here. `ALL` lists every item, and `get` returns
--- one by its id. An item never changes: its table is frozen. How an item looks is not here.
local CrateItem = require("./CrateItem")
local ItemRegistry = require("../items/ItemRegistry")
local ItemScripts = require("../requests/ItemScripts")
local StoveItem = require("./StoveItem")

local Items = {}

--- One item of the game: what `ItemRegistry.ItemDefinition` and `ItemScripts.ItemScript` list,
--- and the item's name.
export type Item = ItemRegistry.ItemDefinition & ItemScripts.ItemScript & {
	--- The name shown for the item.
	read name: string,
}

local all: { Item } = {
	{ id = "log", stackSize = 16, name = "Log" },
	{ id = "stone", stackSize = 16, name = "Stone" },
	{ id = "crystal", stackSize = 32, name = "Crystal" },
	{ id = "apple", stackSize = 16, name = "Apple" },
	{ id = "fish", stackSize = 8, name = "Fish" },
	{ id = "cheese", stackSize = 8, name = "Cheese" },
	{ id = "cooked_fish", stackSize = 8, name = "Cooked fish" },
	{ id = "baked_apple", stackSize = 16, name = "Baked apple" },
	StoveItem,
	CrateItem,
}

local itemsById: { [string]: Item } = {}
for _, item in all do
	table.freeze(item)
	itemsById[item.id] = item
end

--- Every item in the game.
Items.ALL = table.freeze(all)

--- Returns the item with the id `itemId`. Fails if the game has no item with that id.
function Items.get(itemId: string): Item
	return itemsById[itemId] or error(`the game has no item with the id "{itemId}"`, 2)
end

return Items
