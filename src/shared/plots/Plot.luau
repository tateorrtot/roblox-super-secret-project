--!strict
--- A grid of square tiles with the objects standing on them.
---
--- A plot is `widthInTiles` tiles along x and `depthInTiles` tiles along z. A tile is named by
--- two whole numbers counted from 1, so the corner tile is x 1, z 1. Each tile holds one placed
--- object or nothing. `placeObject` stands an object on a tile and `removePlacedObject` takes it
--- off, and the plot fires a signal for each: `placedObjectAdded` and `placedObjectRemoved`. A
--- plot reads one thing of a placed object: which tile it stands on. Whatever else a placed object
--- has on it, the id of its kind among it, is for others, and the plot keeps it without looking.
--- Placed objects are numbered from 1 in the order they were placed, and a number is never used
--- twice. `getTileAt` and `getTileCenter` turn a position in the world into a tile and back.
local Position = require("../Position")
local Signal = require("../Signal")

local Plot = {}

--- A point in the world, in studs.
export type Position = Position.Position

--- One object standing on a tile. A plot reads `tileX` and `tileZ` of it. `kindId` is there for
--- whoever must tell one kind of placed object from another: a plot never reads it. A placed
--- object may have more fields, which are its kind's own. It is frozen when it is placed, so no
--- field of it is assigned again.
export type PlacedObject = {
	--- The id of the kind of object it is, such as `"crate"`.
	read kindId: string,
	--- The number of the tile it stands on along x.
	read tileX: number,
	--- The number of the tile it stands on along z.
	read tileZ: number,
}

export type Plot = {
	--- How many tiles it has along x.
	read widthInTiles: number,
	--- How many tiles it has along z.
	read depthInTiles: number,
	--- Fired when an object has been placed, with the placed object's id and the placed object.
	read placedObjectAdded: Signal.Signal<number, PlacedObject>,
	--- Fired when a placed object has been taken off the plot, with the id it had and the placed
	--- object.
	read placedObjectRemoved: Signal.Signal<number, PlacedObject>,
	--- The id the next placed object will get.
	nextId: number,
	--- Every placed object, by id. An id with no entry is not on the plot.
	--- Note: ids are not consecutive once a placed object has been removed, so
	--- `#placedObjectsById` is not the number of placed objects.
	placedObjectsById: { [number]: PlacedObject },
}

--- The length of a tile's side, in studs.
Plot.TILE_SIZE = 4

local function isWholeNumber(value: unknown): boolean
	return type(value) == "number" and value == math.floor(value) and value ~= math.huge and value ~= -math.huge
end

--- Returns a new plot of `widthInTiles` by `depthInTiles` tiles with nothing placed on it.
--- Note: `widthInTiles` and `depthInTiles` must be whole numbers of 1 or more. They are not
--- checked.
function Plot.new(widthInTiles: number, depthInTiles: number): Plot
	return {
		widthInTiles = widthInTiles,
		depthInTiles = depthInTiles,
		placedObjectAdded = Signal.new(),
		placedObjectRemoved = Signal.new(),
		nextId = 1,
		placedObjectsById = {},
	}
end

--- Returns `true` if `tileX` and `tileZ` name a tile of this plot: whole numbers, with `tileX`
--- from 1 to `widthInTiles` and `tileZ` from 1 to `depthInTiles`. `tileX` and `tileZ` may be any
--- values at all, and nothing fails.
function Plot.hasTile(plot: Plot, tileX: unknown, tileZ: unknown): boolean
	return isWholeNumber(tileX)
		and isWholeNumber(tileZ)
		and (tileX :: number) >= 1
		and (tileX :: number) <= plot.widthInTiles
		and (tileZ :: number) >= 1
		and (tileZ :: number) <= plot.depthInTiles
end

--- Returns `true` if a placed object stands on the tile `tileX`, `tileZ`. A tile the plot does
--- not have holds nothing, so it is never taken.
function Plot.isTileTaken(plot: Plot, tileX: number, tileZ: number): boolean
	for _, placedObject in plot.placedObjectsById do
		if placedObject.tileX == tileX and placedObject.tileZ == tileZ then
			return true
		end
	end
	return false
end

--- Returns `true` if an object could be placed on the tile `tileX`, `tileZ`: the plot has that
--- tile, and the tile holds nothing.
function Plot.canPlaceObject(plot: Plot, tileX: number, tileZ: number): boolean
	return Plot.hasTile(plot, tileX, tileZ) and not Plot.isTileTaken(plot, tileX, tileZ)
end

--- Places `placedObject` on the tile it names, `placedObject.tileX`, `placedObject.tileZ`, and
--- returns the id it is given. The plot keeps `placedObject` itself and not a copy, so a table
--- with more fields than `PlacedObject` lists stands on the plot whole: the plot never reads the
--- others, and whoever placed it finds them on it again. The plot freezes `placedObject`: none of
--- its fields can be assigned from then on, though a table that one of them holds can still
--- change. Fires `placedObjectAdded` once the object stands there. Fails, leaving `placedObject`
--- as it was, if `canPlaceObject` would return `false` for that tile: a tile holds one placed
--- object.
--- Note: `placedObject.kindId` is not checked. A plot does not know which kinds there are.
function Plot.placeObject(plot: Plot, placedObject: PlacedObject): number
	if not Plot.canPlaceObject(plot, placedObject.tileX, placedObject.tileZ) then
		error(`nothing can be placed on the tile {placedObject.tileX}, {placedObject.tileZ}`, 2)
	end
	local id = plot.nextId
	plot.placedObjectsById[id] = table.freeze(placedObject)
	plot.nextId = id + 1
	Signal.fire(plot.placedObjectAdded, id, placedObject)
	return id
end

--- Takes the placed object with the id `id` off the plot and returns it. Its tile then holds
--- nothing, and its id is never given out again. Fires `placedObjectRemoved` once it is off.
--- Returns `nil`, changing nothing and firing nothing, if no placed object has that id.
function Plot.removePlacedObject(plot: Plot, id: number): PlacedObject?
	local placedObject = plot.placedObjectsById[id]
	plot.placedObjectsById[id] = nil
	if placedObject ~= nil then
		Signal.fire(plot.placedObjectRemoved, id, placedObject)
	end
	return placedObject
end

--- Returns the numbers along x and along z of the tile that `position` is over, for a plot whose
--- tile x 1, z 1 has its outer corner at `corner`. The plot reaches from `corner` towards greater
--- x and greater z. The tile returned may be off the plot, with a number below 1 or above the
--- plot's size; see `hasTile`.
function Plot.getTileAt(corner: Position, position: Position): (number, number)
	return math.floor((position.x - corner.x) / Plot.TILE_SIZE) + 1,
		math.floor((position.z - corner.z) / Plot.TILE_SIZE) + 1
end

--- Returns the position of the middle of the tile `tileX`, `tileZ`, at the height of `corner`,
--- for a plot whose tile x 1, z 1 has its outer corner at `corner`.
function Plot.getTileCenter(corner: Position, tileX: number, tileZ: number): Position
	return table.freeze({
		x = corner.x + (tileX - 0.5) * Plot.TILE_SIZE,
		y = corner.y,
		z = corner.z + (tileZ - 0.5) * Plot.TILE_SIZE,
	})
end

return Plot
