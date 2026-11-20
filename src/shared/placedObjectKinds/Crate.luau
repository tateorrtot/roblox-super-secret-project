--!strict
--- A crate: a placed object that holds stacks of items.
---
--- `place` stands a crate on a tile of the world's plot and gives it an inventory.
local Inventory = require("../inventory/Inventory")
local Plot = require("../plots/Plot")
local World = require("../world/World")

local Crate = {}

--- The id of the kind of placed object that a crate is.
Crate.KIND_ID = "crate"

--- How many slots a crate's inventory has.
Crate.SLOT_COUNT = 27

--- Places a crate on the tile `tileX`, `tileZ` of the world's plot, and returns the placed
--- object's id. The crate is given an inventory of `SLOT_COUNT` slots, holding nothing. Fails if
--- `Plot.canPlaceObject` would return `false` for that tile.
function Crate.place(world: World.World, tileX: number, tileZ: number): number
	local placedObjectId = Plot.placeObject(world.plot, Crate.KIND_ID, tileX, tileZ)
	World.addPlacedObjectInventory(world, placedObjectId, Inventory.new(Crate.SLOT_COUNT))
	return placedObjectId
end

return Crate
