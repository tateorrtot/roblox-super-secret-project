--!strict
--- A grid of square tiles that holds placed objects, at most one to a tile.
---
--- A plot is `widthInTiles` tiles along x and `depthInTiles` tiles along z. Two whole numbers name
--- a tile, each counted from `1`, so the corner tile is x `1`, z `1`. `placeObject` adds a placed
--- object to the tile that the placed object names, and `removePlacedObject` removes it. The plot
--- fires `placedObjectAdded` or `placedObjectRemoved` after each. A plot reads only a placed
--- object's tile. The plot keeps a placed object's other fields, `kindId` among them, and never
--- reads them. The plot numbers placed objects from `1` in the order `placeObject` adds them, and
--- never gives an id to a second placed object. `getTileAt` returns the tile under a position in
--- the world, and `getTileCenter` returns the position of a tile's middle.
local Position = require("../Position")
local Signal = require("../Signal")

local Plot = {}

--- A point in the world, in studs.
export type Position = Position.Position

--- An object on one of a plot's tiles. A plot reads only `tileX` and `tileZ`. Code outside the plot
--- reads `kindId` to tell one kind of placed object from another. A placed object may have more
--- fields, which belong to its kind. `placeObject` freezes the placed object, so nothing can assign
--- its fields afterwards.
export type PlacedObject = {
	--- The id of the placed object's kind, such as `"crate"`.
	read kindId: string,
	--- The number along x of the tile that the placed object stands on.
	read tileX: number,
	--- The number along z of the tile that the placed object stands on.
	read tileZ: number,
}

--- A plot: its size, its two signals, and its placed objects.
export type Plot = {
	--- The plot's width, in tiles along x.
	read widthInTiles: number,
	--- The plot's depth, in tiles along z.
	read depthInTiles: number,
	--- Fires after `placeObject` adds a placed object. Passes the placed object's id and the placed
	--- object.
	read placedObjectAdded: Signal.Signal<number, PlacedObject>,
	--- Fires after `removePlacedObject` removes a placed object. Passes the id that the placed
	--- object had and the placed object.
	read placedObjectRemoved: Signal.Signal<number, PlacedObject>,
	--- The id that `placeObject` gives the next placed object.
	nextId: number,
	--- Every placed object on the plot, by id. An id with no entry is not on the plot.
	--- Note: the ids stop being consecutive once `removePlacedObject` removes a placed object, so
	--- `#placedObjectsById` is not the number of placed objects.
	placedObjectsById: { [number]: PlacedObject },
}

--- The length of a tile's side, in studs.
Plot.TILE_SIZE = 4

local function isWholeNumber(value: unknown): boolean
	return type(value) == "number" and value == math.floor(value) and value ~= math.huge and value ~= -math.huge
end

--- Returns a new plot of `widthInTiles` by `depthInTiles` tiles that holds no placed objects.
--- Note: `new` does not check that `widthInTiles` and `depthInTiles` are whole numbers of `1` or
--- more.
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

--- Returns `true` if `tileX` and `tileZ` name one of the plot's tiles: both are whole numbers,
--- `tileX` is from `1` to `widthInTiles`, and `tileZ` is from `1` to `depthInTiles`. Accepts a
--- value of any type for each, and never fails.
function Plot.hasTile(plot: Plot, tileX: unknown, tileZ: unknown): boolean
	return isWholeNumber(tileX)
		and isWholeNumber(tileZ)
		and (tileX :: number) >= 1
		and (tileX :: number) <= plot.widthInTiles
		and (tileZ :: number) >= 1
		and (tileZ :: number) <= plot.depthInTiles
end

--- Returns `true` if a placed object stands on the tile `tileX`, `tileZ`. Returns `false` for a
--- tile that the plot does not have.
function Plot.isTileTaken(plot: Plot, tileX: number, tileZ: number): boolean
	for _, placedObject in plot.placedObjectsById do
		if placedObject.tileX == tileX and placedObject.tileZ == tileZ then
			return true
		end
	end
	return false
end

--- Returns `true` if `placeObject` would accept a placed object on the tile `tileX`, `tileZ`: the
--- plot has the tile, and no placed object stands on it.
function Plot.canPlaceObject(plot: Plot, tileX: number, tileZ: number): boolean
	return Plot.hasTile(plot, tileX, tileZ) and not Plot.isTileTaken(plot, tileX, tileZ)
end

--- Adds `placedObject` to the plot, on the tile `placedObject.tileX`, `placedObject.tileZ`. The
--- plot keeps `placedObject` itself and not a copy, so the fields that `PlacedObject` does not list
--- stay on it. The plot never reads those fields. Freezes `placedObject`: nothing can assign its
--- fields afterwards, but a table that one of its fields holds can still change. Fires
--- `placedObjectAdded` after adding it. Returns the placed object's id. Fails, and changes nothing,
--- if `canPlaceObject` would return `false` for the tile.
--- Note: `placeObject` does not check `placedObject.kindId`. A plot does not know which kinds
--- exist.
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

--- Removes the placed object with the id `id` from the plot and returns it. The placed object's
--- tile then holds nothing, and the plot never gives `id` to another placed object. Fires
--- `placedObjectRemoved` after removing it. Returns `nil`, changes nothing, and fires nothing if no
--- placed object has the id `id`.
function Plot.removePlacedObject(plot: Plot, id: number): PlacedObject?
	local placedObject = plot.placedObjectsById[id]
	plot.placedObjectsById[id] = nil
	if placedObject ~= nil then
		Signal.fire(plot.placedObjectRemoved, id, placedObject)
	end
	return placedObject
end

--- Returns the numbers along x and along z of the tile under `position`, for a plot whose tile x
--- `1`, z `1` has its outer corner at `corner`. The plot extends from `corner` towards greater x
--- and greater z. The tile may lie outside the plot, with a number below `1` or above the plot's
--- size: `hasTile` returns `false` for such a tile.
function Plot.getTileAt(corner: Position, position: Position): (number, number)
	return math.floor((position.x - corner.x) / Plot.TILE_SIZE) + 1,
		math.floor((position.z - corner.z) / Plot.TILE_SIZE) + 1
end

--- Returns the middle of the tile `tileX`, `tileZ`, as a position at the height of `corner`, for a
--- plot whose tile x `1`, z `1` has its outer corner at `corner`.
function Plot.getTileCenter(corner: Position, tileX: number, tileZ: number): Position
	return table.freeze({
		x = corner.x + (tileX - 0.5) * Plot.TILE_SIZE,
		y = corner.y,
		z = corner.z + (tileZ - 0.5) * Plot.TILE_SIZE,
	})
end

return Plot
