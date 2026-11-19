--!strict
--[=[
	A plot: a grid of square tiles, and the items standing on them.

	A plot is `width` tiles along x and `depth` tiles along z. A tile is
	named by two whole numbers counted from 1, so the corner tile is x 1, z 1.
	Each tile holds one placed item or nothing.

	A placed item is an item standing on a tile as a thing in the world: a
	crate, a stove. Only an item whose definition says `placeable` can be
	placed. If the definition gives the item a `slotCount`, the placed item
	has an inventory of that many slots inside it. Placed items are numbered
	from 1 in the order they were placed, and a number is never used twice.
	A plot of 2 by 2 tiles with a crate on one of them is

	`{ width = 2, depth = 2, nextId = 2, placedById = { [1] = { itemId = "crate", x = 2, z = 1, inventory = <27 slots> } } }`

	and with nothing placed `placedById` is empty.

	Placing takes the item from nobody, and removing gives it to nobody: the
	caller moves the items. Before calling [method place], take one of the
	item out of the player's hands. After [method remove], the caller holds
	what it returns: one of that item, and everything in its inventory.

	A plot lies somewhere in the world. `Plot.TILE_SIZE` is the side of a tile
	in studs, and [method tileAt] and [method tileCenter] turn a position in
	the world into a tile and back, given where the plot's corner is.

	This is the rules only. It draws nothing: code that shows a plot reads
	`placedById`.

	```lua
	local plot = Plot.new(18, 18)
	Plot.place(plot, "crate", 3, 5) --> 1, the id of the placed crate
	Plot.place(plot, "stove", 3, 5) --> nil: the tile is taken
	Plot.place(plot, "apple", 4, 5) --> nil: an apple cannot be placed
	plot.placedById[1].inventory --> the crate's inventory, 27 slots
	Plot.remove(plot, 1) --> the placed crate, which is no longer on the plot
	```
]=]
local Inventory = require("../inventory/Inventory")
local ItemRegistry = require("../items/ItemRegistry")
local Position = require("../world/Position")

local Plot = {}

type Inventory = Inventory.Inventory

--- A point in the world, in studs. See Position.
export type Position = Position.Position

--- One item standing on a tile. The record never changes; what is in its inventory does.
export type PlacedItem = {
	--- The id of the item it is, such as `"crate"`.
	read itemId: string,
	--- The tile it stands on.
	read x: number,
	read z: number,
	--- What is inside it, for an item whose definition has a `slotCount`. `nil` for an item that holds nothing.
	read inventory: Inventory?,
}

--- `read` means code outside this module cannot assign the field. Change a plot with the functions below.
export type Plot = {
	--- How many tiles it has along x.
	read width: number,
	--- How many tiles it has along z.
	read depth: number,
	--- The id the next placed item will get.
	read nextId: number,
	--- Every placed item, by id. An id with no entry is not on the plot.
	--- The table has gaps, so use `for id, placedItem in plot.placedById`, not `#` or `ipairs`.
	read placedById: { read [number]: PlacedItem },
}

--- The length of a tile's side, in studs.
Plot.TILE_SIZE = 4

--- How far from the middle of a tile a player may stand and still place an item on it, or use or hit
--- what stands on it, in studs along the ground.
Plot.REACH = 16

local function isWholeNumber(value: unknown): boolean
	return type(value) == "number" and value == math.floor(value) and value ~= math.huge and value ~= -math.huge
end

local function writablePlaced(plot: Plot): { [number]: PlacedItem }
	return plot.placedById :: any
end

-- Raises `problem` as an error that names the public function and blames the code that called it.
local function failIf(problem: string?, functionName: string)
	if problem ~= nil then
		error(functionName .. ": " .. problem, 3)
	end
end

local function sizeProblem(name: string, size: number): string?
	if isWholeNumber(size) and size >= 1 then
		return nil
	end
	return string.format("%s must be a whole number, 1 or more; got %s", name, tostring(size))
end

local function isTile(plot: Plot, x: unknown, z: unknown): boolean
	return isWholeNumber(x)
		and isWholeNumber(z)
		and (x :: number) >= 1
		and (x :: number) <= plot.width
		and (z :: number) >= 1
		and (z :: number) <= plot.depth
end

local function tileProblem(plot: Plot, x: number, z: number): string?
	if isTile(plot, x, z) then
		return nil
	end
	return string.format(
		"tile x %s, z %s is not on this plot; its tiles are x 1 to %d, z 1 to %d",
		tostring(x),
		tostring(z),
		plot.width,
		plot.depth
	)
end

local function itemProblem(itemId: string): string?
	if type(itemId) == "string" and ItemRegistry.has(itemId) then
		return nil
	end
	return string.format('no item has the id "%s"', tostring(itemId))
end

local function isTileTaken(plot: Plot, x: number, z: number): boolean
	for _, placedItem in plot.placedById do
		if placedItem.x == x and placedItem.z == z then
			return true
		end
	end
	return false
end

--[=[
	Returns a new plot of `width` by `depth` tiles with nothing placed on it.

	Raises an error if `width` or `depth` is not a whole number of 1 or more.
]=]
function Plot.new(width: number, depth: number): Plot
	failIf(sizeProblem("width", width), "Plot.new")
	failIf(sizeProblem("depth", depth), "Plot.new")
	return { width = width, depth = depth, nextId = 1, placedById = {} }
end

--[=[
	Returns `true` if `x` and `z` name a tile of this plot: whole numbers,
	with `x` from 1 to `width` and `z` from 1 to `depth`.

	`x` and `z` may be any values at all, and nothing raises an error. A
	function given a tile that passes this check will not refuse it.
]=]
function Plot.hasTile(plot: Plot, x: unknown, z: unknown): boolean
	return isTile(plot, x, z)
end

--[=[
	Returns `true` if the item with the id `itemId` could be placed on the
	tile `x`, `z` now: the item is placeable, and the tile holds nothing.

	Raises an error if no item has that id, or if `x`, `z` is not a tile of
	this plot.
]=]
function Plot.canPlace(plot: Plot, itemId: string, x: number, z: number): boolean
	failIf(itemProblem(itemId), "Plot.canPlace")
	failIf(tileProblem(plot, x, z), "Plot.canPlace")
	return ItemRegistry.get(itemId).placeable == true and not isTileTaken(plot, x, z)
end

--[=[
	Places one of the item with the id `itemId` on the tile `x`, `z`, and
	returns the id of the placed item made.

	If the item's definition has a `slotCount`, the placed item gets a new
	inventory of that many slots, holding nothing.

	Returns `nil`, and changes nothing, if the item is not placeable or the
	tile already holds something. [method canPlace] asks first.

	Raises an error if no item has that id, or if `x`, `z` is not a tile of
	this plot.
]=]
function Plot.place(plot: Plot, itemId: string, x: number, z: number): number?
	failIf(itemProblem(itemId), "Plot.place")
	failIf(tileProblem(plot, x, z), "Plot.place")
	local definition = ItemRegistry.get(itemId)
	if definition.placeable ~= true or isTileTaken(plot, x, z) then
		return nil
	end
	local id = plot.nextId
	writablePlaced(plot)[id] = table.freeze({
		itemId = itemId,
		x = x,
		z = z,
		inventory = if definition.slotCount ~= nil then Inventory.new(definition.slotCount) else nil,
	})
	local writable = plot :: any
	writable.nextId = id + 1
	return id
end

--[=[
	Takes the placed item with the id `id` off the plot and returns it, or
	returns `nil` if no placed item has that id. Its tile then holds nothing.

	The caller now holds what the placed item was: one of its item, and
	whatever is in its inventory. If the caller does nothing with them, they
	are lost.

	Raises an error if `id` is not a whole number of 1 or more.
]=]
function Plot.remove(plot: Plot, id: number): PlacedItem?
	if not isWholeNumber(id) or id < 1 then
		error(string.format("Plot.remove: id must be a whole number, 1 or more; got %s", tostring(id)), 2)
	end
	local placedItem = plot.placedById[id]
	writablePlaced(plot)[id] = nil
	return placedItem
end

--[=[
	Returns the tile that `position` is over, as its `x` and `z`, for a plot
	whose corner is at `corner`.

	`corner` is the outer corner of tile x 1, z 1: the plot reaches from it
	towards greater x and greater z. The tile returned may be off the plot,
	with a number below 1 or above the plot's size: ask [method hasTile].

	```lua
	local corner = { x = 100, y = 0, z = 200 }
	Plot.tileAt(corner, { x = 101, y = 0, z = 203 }) --> 1, 1: within 4 studs of the corner both ways
	Plot.tileAt(corner, { x = 109, y = 0, z = 204 }) --> 3, 2
	Plot.tileAt(corner, { x = 99, y = 0, z = 200 }) --> 0, 1: off the plot
	```
]=]
function Plot.tileAt(corner: Position, position: Position): (number, number)
	return math.floor((position.x - corner.x) / Plot.TILE_SIZE) + 1,
		math.floor((position.z - corner.z) / Plot.TILE_SIZE) + 1
end

--[=[
	Returns the position of the middle of the tile `x`, `z`, at the height of
	the plot's corner, for a plot whose corner is at `corner`.

	```lua
	Plot.tileCenter({ x = 100, y = 0, z = 200 }, 1, 1) --> { x = 102, y = 0, z = 202 }
	```
]=]
function Plot.tileCenter(corner: Position, x: number, z: number): Position
	return table.freeze({
		x = corner.x + (x - 0.5) * Plot.TILE_SIZE,
		y = corner.y,
		z = corner.z + (z - 0.5) * Plot.TILE_SIZE,
	})
end

return Plot
