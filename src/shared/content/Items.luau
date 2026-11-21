--!strict
--- Every item in the game.
---
--- An item is one table. It holds the item's id and stack size, which `ItemRegistry` keeps, its
--- name and colour, which are how it is shown, and whichever functions of
--- `ItemScripts.ItemScript` it has a use for: what happens when someone holding it acts on the
--- world. An item with such a function is written in a file of its own, as `CrateItem` is. The
--- others are written here. `ALL` lists every item, and `get` returns one by its id. The names
--- and colours are placeholders until the items have art.
local CrateItem = require("./CrateItem")
local ItemRegistry = require("../items/ItemRegistry")
local ItemScripts = require("../requests/ItemScripts")
local StoveItem = require("./StoveItem")

local Items = {}

--- One item of the game: what `ItemRegistry.ItemDefinition` and `ItemScripts.ItemScript` list,
--- and how the item is shown.
export type Item = ItemRegistry.ItemDefinition & ItemScripts.ItemScript & {
	--- The name shown for the item.
	read name: string,
	--- The colour of the item's placeholder block, as red, green and blue, each from 0 to 255.
	read color: { number },
}

local all: { Item } = {
	{ id = "log", stackSize = 16, name = "Log", color = { 133, 94, 66 } },
	{ id = "stone", stackSize = 16, name = "Stone", color = { 128, 128, 128 } },
	{ id = "crystal", stackSize = 32, name = "Crystal", color = { 150, 110, 220 } },
	{ id = "apple", stackSize = 16, name = "Apple", color = { 200, 50, 50 } },
	{ id = "fish", stackSize = 8, name = "Fish", color = { 90, 150, 200 } },
	{ id = "cheese", stackSize = 8, name = "Cheese", color = { 235, 200, 80 } },
	{ id = "cooked_fish", stackSize = 8, name = "Cooked fish", color = { 205, 140, 85 } },
	{ id = "baked_apple", stackSize = 16, name = "Baked apple", color = { 165, 85, 45 } },
	StoveItem,
	CrateItem,
}

local itemsById: { [string]: Item } = {}
for _, item in all do
	itemsById[item.id] = item
end

--- Every item in the game, in the order they are written.
Items.ALL = table.freeze(all)

--- Returns the item with the id `itemId`. Fails if the game has no item with that id.
function Items.get(itemId: string): Item
	return itemsById[itemId] or error(`the game has no item with the id "{itemId}"`, 2)
end

return Items
