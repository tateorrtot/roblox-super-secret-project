--!strict
--- A stove: a placed object that cooks one item into another while its fire burns.
---
--- `place` stands a stove on a tile of the world's plot and makes it a station.
local Inventory = require("../inventory/Inventory")
local Plot = require("../plots/Plot")
local Station = require("../stations/Station")
local World = require("../world/World")

local Stove = {}

--- The id of the kind of placed object that a stove is. A stove's recipes are the ones
--- registered for a station of this kind.
Stove.KIND_ID = "stove"

--- Places a stove on the tile `tileX`, `tileZ` of the world's plot, and returns the placed
--- object's id. The stove is made a station of the kind `KIND_ID`, with no fire and with slots
--- that hold nothing. Fails if `Plot.canPlaceObject` would return `false` for that tile.
function Stove.place(world: World.World, tileX: number, tileZ: number): number
	local placedObjectId = Plot.placeObject(world.plot, Stove.KIND_ID, tileX, tileZ)
	local station = Station.new(Stove.KIND_ID, Inventory.new(Station.SLOT_COUNT))
	World.addStation(world, placedObjectId, station)
	return placedObjectId
end

return Stove
