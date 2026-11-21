--!strict
--- The crate item: an item that stands a crate on a tile of the plot.
---
--- The table holds the item's id, its stack size, and its name. `interactWithTile` is the item's
--- script.
local Crate = require("./Crate")
local World = require("../world/World")

local CrateItem = {
	id = "crate",
	stackSize = 1,
	name = Crate.NAME,
}

--- Returns how many crate items were used up when someone holding the crate item interacted with
--- the tile at `tileX`, `tileZ` of the world's plot. If `World.canPlaceObject` returns `true` for
--- the tile, places a crate on it as `Crate.place` does and returns `1`. Otherwise changes nothing
--- and returns `0`.
--- Note: `interactWithTile` takes no item from anywhere.
function CrateItem.interactWithTile(world: World.World, tileX: number, tileZ: number): number
	if not World.canPlaceObject(world, tileX, tileZ) then
		return 0
	end
	Crate.place(world.plot, tileX, tileZ)
	return 1
end

return CrateItem
