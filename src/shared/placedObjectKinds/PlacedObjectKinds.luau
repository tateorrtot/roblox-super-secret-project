--!strict
--- Every kind of placed object in the game, by id.
---
--- Each kind is a module of its own, such as `Crate`, and says for itself what an object of that
--- kind has and does. `PlacedObjectKind` lists the functions that every kind has, and `get`
--- returns the kind with an id.
local Crate = require("./Crate")
local Stove = require("./Stove")
local World = require("../world/World")

local PlacedObjectKinds = {}

--- What every kind of placed object can do. Each kind's own module says what the functions do
--- for that kind.
export type PlacedObjectKind = {
	--- Places an object of this kind on the tile `tileX`, `tileZ` of the world's plot, gives it
	--- whatever an object of this kind has, and returns the placed object's id. Fails if
	--- `Plot.canPlaceObject` would return `false` for that tile.
	read place: (world: World.World, tileX: number, tileZ: number) -> number,
}

local kindsById: { [string]: PlacedObjectKind } = {
	[Crate.KIND_ID] = Crate,
	[Stove.KIND_ID] = Stove,
}

--- Returns the kind of placed object with the id `kindId`. Fails if no kind has that id.
function PlacedObjectKinds.get(kindId: string): PlacedObjectKind
	return kindsById[kindId] or error(`no kind of placed object has the id "{kindId}"`, 2)
end

return PlacedObjectKinds
