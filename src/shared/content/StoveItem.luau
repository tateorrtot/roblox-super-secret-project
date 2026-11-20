--!strict
--- The stove item: an item that a player stands on a tile of the plot as a stove.
---
--- `interactWithTile` is what happens when a player interacts with a tile while the stove item is
--- in their selected hotbar slot.
local Hotbar = require("../inventory/Hotbar")
local PlayerState = require("../players/PlayerState")
local Stove = require("./Stove")
local World = require("../world/World")

local StoveItem = {}

--- The id of the stove item.
StoveItem.ITEM_ID = "stove"

--- A player interacts with the tile `tileX`, `tileZ` of the world's plot. If
--- `World.canReachTile` says that the player's character reaches the tile, and
--- `World.canPlaceObject` says that an object can be placed on it, a stove is placed on the tile
--- as `Stove.place` does, and one item is taken out of the player's selected hotbar slot.
--- Otherwise nothing happens.
--- Note: it is for a player whose selected hotbar slot holds the stove item. It does not look at
--- what that slot holds.
function StoveItem.interactWithTile(world: World.World, player: PlayerState.PlayerState, tileX: number, tileZ: number)
	if World.canReachTile(world, player, tileX, tileZ) and World.canPlaceObject(world, tileX, tileZ) then
		Stove.place(world, tileX, tileZ)
		Hotbar.takeFromSelectedSlot(player.hotbar, 1)
	end
end

return StoveItem
