--!strict
--- The stove item: an item that is stood on a tile of the plot as a stove.
---
--- `interactWithTile` is what happens when someone holding the stove item interacts with a tile.
local Stove = require("./Stove")
local World = require("../world/World")

local StoveItem = {}

--- The id of the stove item.
StoveItem.ITEM_ID = "stove"

--- Someone holding the stove item interacts with the tile `tileX`, `tileZ` of the world's plot. If
--- `World.canPlaceObject` says that an object can be placed on the tile, a stove is placed on it as
--- `Stove.place` does, and 1 is returned: one stove item was used up. Otherwise nothing happens, and
--- 0 is returned.
--- Note: it takes the item from nowhere. Whoever held it takes away what was used up.
function StoveItem.interactWithTile(world: World.World, tileX: number, tileZ: number): number
	if not World.canPlaceObject(world, tileX, tileZ) then
		return 0
	end
	Stove.place(world, tileX, tileZ)
	return 1
end

return StoveItem
