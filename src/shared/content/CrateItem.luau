--!strict
--- The crate item: an item that is stood on a tile of the plot as a crate.
---
--- The table holds the item's id, its stack size, and the name and colour it is shown with.
--- `interactWithTile` is what happens when someone holding the crate item interacts with a tile.
local Crate = require("./Crate")
local World = require("../world/World")

local CrateItem = {
	id = "crate",
	stackSize = 1,
	name = Crate.NAME,
	color = { 170, 130, 80 },
}

--- Someone holding the crate item interacts with the tile `tileX`, `tileZ` of the world's plot. If
--- `World.canPlaceObject` says that an object can be placed on the tile, a crate is placed on it as
--- `Crate.place` does, and 1 is returned: one crate item was used up. Otherwise nothing happens, and
--- 0 is returned.
--- Note: it takes the item from nowhere. Whoever held it takes away what was used up.
function CrateItem.interactWithTile(world: World.World, tileX: number, tileZ: number): number
	if not World.canPlaceObject(world, tileX, tileZ) then
		return 0
	end
	Crate.place(world.plot, tileX, tileZ)
	return 1
end

return CrateItem
