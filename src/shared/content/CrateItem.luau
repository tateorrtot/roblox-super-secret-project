--!strict
--- The crate item: an item that a player stands on a tile of the plot as a crate.
---
--- `interactWithTile` is what happens when a player interacts with a tile while the crate item is
--- in their selected hotbar slot.
local Crate = require("./Crate")
local Hotbar = require("../inventory/Hotbar")
local PlayerState = require("../players/PlayerState")
local World = require("../world/World")

local CrateItem = {}

--- The id of the crate item.
CrateItem.ITEM_ID = "crate"

--- A player interacts with the tile `tileX`, `tileZ` of the world's plot. If
--- `World.canReachTile` says that the player's character reaches the tile, and
--- `World.canPlaceObject` says that an object can be placed on it, a crate is placed on the tile
--- as `Crate.place` does, and one item is taken out of the player's selected hotbar slot.
--- Otherwise nothing happens.
--- Note: it is for a player whose selected hotbar slot holds the crate item. It does not look at
--- what that slot holds.
function CrateItem.interactWithTile(world: World.World, player: PlayerState.PlayerState, tileX: number, tileZ: number)
	if World.canReachTile(world, player, tileX, tileZ) and World.canPlaceObject(world, tileX, tileZ) then
		Crate.place(world, tileX, tileZ)
		Hotbar.takeFromSelectedSlot(player.hotbar, 1)
	end
end

return CrateItem
