--!strict
--- The script of each item: what happens when a player acts on the world while that item is in
--- their selected hotbar slot.
---
--- A script is a table of functions. It is registered once, when the game starts, under the id
--- of its item, with `register`. `PlotRequests` asks `find` for the script of the item in a
--- player's selected hotbar slot, and calls the function for what the player did. Nothing happens
--- for an item that has no script, or whose script lacks that function.
local ItemRegistry = require("../items/ItemRegistry")
local PlayerState = require("../players/PlayerState")
local World = require("../world/World")

local ItemScripts = {}

--- What one item does when a player acts on the world while the item is in their selected hotbar
--- slot. A script has only the functions that its item has a use for.
export type ItemScript = {
	--- Called when `player` interacts with the tile `tileX`, `tileZ` of the plot of `world`,
	--- which is a tile that the plot has, while the script's item is in their selected hotbar slot.
	read interactWithTile: ((world: World.World, player: PlayerState.PlayerState, tileX: number, tileZ: number) -> ())?,
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
