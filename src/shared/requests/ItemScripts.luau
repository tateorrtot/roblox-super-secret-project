--!strict
--- The script of each item: what happens when someone holding that item acts on the world.
---
--- A script is a table of functions, one for each thing a player can do that the item answers.
--- It is registered once, when the game starts, under the id of its item, with `register`, and
--- `find` returns it. An item need not have a script, and a script need not have every function.
local ItemRegistry = require("../items/ItemRegistry")
local World = require("../world/World")

local ItemScripts = {}

--- What one item does when someone holding it acts on the world. A script has only the functions
--- that its item has a use for. It is not told who holds the item, or where they keep it.
export type ItemScript = {
	--- Called when someone holding the script's item interacts with the tile `tileX`, `tileZ` of
	--- the plot of `world`, which is a tile that the plot has. Returns how many of the item that
	--- used up, a whole number: 0 if none. Whoever called it takes that many away from wherever
	--- the item was held.
	read interactWithTile: ((world: World.World, tileX: number, tileZ: number) -> number)?,
}

local scriptsByItemId: { [string]: ItemScript } = {}

--- Registers `itemScript` as the script of the item with the id `itemId`. Fails if no item has
--- that id, or if that item has a script already.
function ItemScripts.register(itemId: string, itemScript: ItemScript)
	if not ItemRegistry.has(itemId) then
		error(`no item has the id "{itemId}"`, 2)
	end
	if scriptsByItemId[itemId] ~= nil then
		error(`the item "{itemId}" has a script already`, 2)
	end
	scriptsByItemId[itemId] = itemScript
end

--- Returns the script of the item with the id `itemId`, or `nil` if that item has none.
function ItemScripts.find(itemId: string): ItemScript?
	return scriptsByItemId[itemId]
end

return ItemScripts
