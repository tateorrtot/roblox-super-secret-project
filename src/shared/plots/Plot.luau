--!strict
--- A grid of square tiles with the items standing on them.
---
--- A plot is `width` tiles along x and `depth` tiles along z. A tile is named by two whole numbers
--- counted from 1, so the corner tile is x 1, z 1. Each tile holds one placed object or nothing.
--- `placeObject` stands an item on a tile and `removePlacedObject` takes it off, and the plot fires a
--- signal for each: `placedObjectAdded` and `placedObjectRemoved`. A placed object whose definition has a
--- `slotCount` has an inventory inside it. Placed objects are numbered from 1 in the
--- order they were placed, and a number is never used twice. `getTileAt` and `getTileCenter` turn a
--- position in the world into a tile and back.
local Inventory = require("../inventory/Inventory")
local ItemRegistry = require("../items/ItemRegistry")
local Position = require("../Position")
local Signal = require("../Signal")

local Plot = {}

type Inventory = Inventory.Inventory

--- A point in the world, in studs.
export type Position = Position.Position

--- One item standing on a tile.
export type PlacedObject = {
	--- The id of the item it is, such as `"crate"`.
	read itemId: string,
	--- The number of the tile it stands on along x.
	read x: number,
	--- The number of the tile it stands on along z.
	read z: number,
	--- What is inside it, which changes as items are put in and taken out. `nil` if the item's
	--- definition has no `slotCount`.
	read inventory: Inventory?,
}

export type Plot = {
	--- How many tiles it has along x.
	read width: number,
	--- How many tiles it has along z.
	read depth: number,
	--- Fired when an item has been placed, with the placed object's id and the placed object.
	read placedObjectAdded: Signal.Signal<number, PlacedObject>,
	--- Fired when a placed object has been taken off the plot, with the id it had and the placed
	--- item, whose inventory is still inside it.
	read placedObjectRemoved: Signal.Signal<number, PlacedObject>,
	--- The id the next placed object will get.
	nextId: number,
	--- Every placed object, by id. An id with no entry is not on the plot.
	--- Note: ids are not consecutive once an item has been removed, so `#placedObjectsById` is not
	--- the number of placed objects.
	placedObjectsById: { [number]: PlacedObject },
}

--- The length of a tile's side, in studs.
Plot.TILE_SIZE = 4

local function isWholeNumber(value: unknown): boolean
	return type(value) == "number" and value == math.floor(value) and value ~= math.huge and value ~= -math.huge
end

--- Returns a new plot of `width` by `depth` tiles with nothing placed on it.
--- Note: `width` and `depth` must be whole numbers of 1 or more. They are not checked.
function Plot.new(width: number, depth: number): Plot
	return {
		width = width,
		depth = depth,
		placedObjectAdded = Signal.new(),
		placedObjectRemoved = Signal.new(),
		nextId = 1,
		placedObjectsById = {},
	}
end

--- Returns `true` if `x` and `z` name a tile of this plot: whole numbers, with `x` from 1 to
--- `width` and `z` from 1 to `depth`. `x` and `z` may be any values at all, and nothing fails.
function Plot.hasTile(plot: Plot, x: unknown, z: unknown): boolean
	return isWholeNumber(x)
		and isWholeNumber(z)
		and (x :: number) >= 1
		and (x :: number) <= plot.width
		and (z :: number) >= 1
		and (z :: number) <= plot.depth
end

--- Returns `true` if a placed object stands on the tile `x`, `z`. A tile the plot does not have
--- holds nothing, so it is never taken.
function Plot.isTileTaken(plot: Plot, x: number, z: number): boolean
	for _, placedObject in plot.placedObjectsById do
		if placedObject.x == x and placedObject.z == z then
			return true
		end
	end
	return false
end

--- Returns `true` if the item `itemId` could be placed on the tile `x`, `z`: the plot has that
--- tile, the item's definition says it is `placeable`, and the tile holds nothing. Fails if no
--- item has that id.
function Plot.canPlaceObject(plot: Plot, itemId: string, x: number, z: number): boolean
	local isPlaceable = ItemRegistry.get(itemId).placeable == true
	return isPlaceable and Plot.hasTile(plot, x, z) and not Plot.isTileTaken(plot, x, z)
end

--- Places one of the item `itemId` on the tile `x`, `z`, and returns the id of the placed object. If
--- the item's definition has a `slotCount`, the placed object gets a new inventory of that many
--- slots, holding nothing. Fires `placedObjectAdded` once the item stands there. Fails if
--- `canPlaceObject` would return `false`: a tile holds one item, and only an item that can be placed
--- stands on the plot. Fails if no item has that id.
function Plot.placeObject(plot: Plot, itemId: string, x: number, z: number): number
	if not Plot.canPlaceObject(plot, itemId, x, z) then
		error(`the item "{itemId}" cannot be placed on the tile {x}, {z}`, 2)
	end
	local definition = ItemRegistry.get(itemId)
	local id = plot.nextId
	plot.placedObjectsById[id] = table.freeze({
		itemId = itemId,
		x = x,
		z = z,
		inventory = if definition.slotCount ~= nil then Inventory.new(definition.slotCount) else nil,
	})
	plot.nextId = id + 1
	Signal.fire(plot.placedObjectAdded, id, plot.placedObjectsById[id])
	return id
end

--- Takes the placed object with the id `id` off the plot and returns it, with its inventory still
--- inside it. Its tile then holds nothing, and its id is never given out again. Fires
--- `placedObjectRemoved` once it is off. Returns `nil`, changing nothing and firing nothing, if no
--- placed object has that id.
function Plot.removePlacedObject(plot: Plot, id: number): PlacedObject?
	local placedObject = plot.placedObjectsById[id]
	plot.placedObjectsById[id] = nil
	if placedObject ~= nil then
		Signal.fire(plot.placedObjectRemoved, id, placedObject)
	end
	return placedObject
end

--- Returns the `x` and `z` of the tile that `position` is over, for a plot whose tile x 1, z 1 has
--- its outer corner at `corner`. The plot reaches from `corner` towards greater x and greater z.
--- The tile returned may be off the plot, with a number below 1 or above the plot's size; see
--- `hasTile`.
function Plot.getTileAt(corner: Position, position: Position): (number, number)
	return math.floor((position.x - corner.x) / Plot.TILE_SIZE) + 1,
		math.floor((position.z - corner.z) / Plot.TILE_SIZE) + 1
end

--- Returns the position of the middle of the tile `x`, `z`, at the height of `corner`, for a plot
--- whose tile x 1, z 1 has its outer corner at `corner`.
function Plot.getTileCenter(corner: Position, x: number, z: number): Position
	return table.freeze({
		x = corner.x + (x - 0.5) * Plot.TILE_SIZE,
		y = corner.y,
		z = corner.z + (z - 0.5) * Plot.TILE_SIZE,
	})
end

return Plot
