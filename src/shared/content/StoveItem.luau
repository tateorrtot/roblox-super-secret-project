--!strict
--- The stove item: an item that is stood on a tile of the plot as a stove.
---
--- The table holds the item's id, its stack size, and the name and colour it is shown with.
--- `interactWithTile` is what happens when someone holding the stove item interacts with a tile.
local Stove = require("./Stove")
local World = require("../world/World")

local StoveItem = {
	id = "stove",
	stackSize = 1,
	name = Stove.NAME,
	color = { 60, 60, 70 },
}

--- Someone holding the stove item interacts with the tile `tileX`, `tileZ` of the world's plot. If
--- `World.canPlaceObject` says that an object can be placed on the tile, a stove is placed on it as
--- `Stove.place` does, and 1 is returned: one stove item was used up. Otherwise nothing happens, and
--- 0 is returned.
--- Note: it takes the item from nowhere. Whoever held it takes away what was used up.
function StoveItem.interactWithTile(world: World.World, tileX: number, tileZ: number): number
	if not World.canPlaceObject(world, tileX, tileZ) then
		return 0
	end
	Stove.place(world.plot, tileX, tileZ)
	return 1
end

return StoveItem
