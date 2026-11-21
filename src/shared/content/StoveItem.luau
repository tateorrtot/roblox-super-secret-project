--!strict
--- The stove item: an item that stands a stove on a tile of the plot.
---
--- The table holds the item's id, its stack size, and its name. `interactWithTile` is the item's
--- script.
local Stove = require("./Stove")
local World = require("../world/World")

local StoveItem = {
	id = "stove",
	stackSize = 1,
	name = Stove.NAME,
}

--- Returns how many stove items were used up when someone holding the stove item interacted with
--- the tile at `tileX`, `tileZ` of the world's plot. If `World.canPlaceObject` returns `true` for
--- the tile, places a stove on it as `Stove.place` does and returns `1`. Otherwise changes nothing
--- and returns `0`.
--- Note: `interactWithTile` takes no item from anywhere.
function StoveItem.interactWithTile(world: World.World, tileX: number, tileZ: number): number
	if not World.canPlaceObject(world, tileX, tileZ) then
		return 0
	end
	Stove.place(world.plot, tileX, tileZ)
	return 1
end

return StoveItem
