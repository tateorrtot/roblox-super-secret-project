--!strict
--- What gives way when an item is placed on a plot.
---
--- A placed item fills its tile as a cube `Plot.TILE_SIZE` on each side, standing on the tile, and
--- no ground item lies inside one. `pushGroundItemsOutOfTile` moves the ground items out of a tile
--- that has just had an item placed on it.
local GroundItems = require("./GroundItems")
local ItemStack = require("../items/ItemStack")
local Plot = require("../plots/Plot")
local Position = require("../Position")

local PlotCollision = {}

type GroundItems = GroundItems.GroundItems
type ItemStack = ItemStack.ItemStack
type Position = Position.Position
type Tile = { plot: Plot.Plot, x: number, z: number, center: Position }
type Side = { x: number, z: number }

--- How fast a ground item that `pushGroundItemsOutOfTile` pushes out of a side of a tile starts
--- moving away from the tile along the ground, in studs a second.
PlotCollision.PUSHED_GROUND_ITEM_SPEED = 6

local NO_VELOCITY: GroundItems.Velocity = table.freeze({ x = 0, y = 0, z = 0 })
local SIDES: { Side } = {
	{ x = 1, z = 0 },
	{ x = -1, z = 0 },
	{ x = 0, z = 1 },
	{ x = 0, z = -1 },
}
local CENTER_DISTANCE_WHEN_TOUCHING = (Plot.TILE_SIZE + GroundItems.ITEM_WIDTH) / 2
local OVERLAP_TOLERANCE = 0.1

local function isLyingInTile(position: Position, tile: Tile): boolean
	local center = tile.center
	local reach = CENTER_DISTANCE_WHEN_TOUCHING - OVERLAP_TOLERANCE
	return math.abs(position.x - center.x) < reach
		and math.abs(position.z - center.z) < reach
		and position.y < center.y + Plot.TILE_SIZE - OVERLAP_TOLERANCE
		and position.y + GroundItems.ITEM_WIDTH > center.y + OVERLAP_TOLERANCE
end

local function findNearestFreeSideOfTile(position: Position, tile: Tile): (Side?, number)
	local center = tile.center
	local nearestSide: Side? = nil
	local nearestDistance = math.huge
	for _, side in SIDES do
		local towardsSide = (position.x - center.x) * side.x + (position.z - center.z) * side.z
		local distance = CENTER_DISTANCE_WHEN_TOUCHING - towardsSide
		if distance < nearestDistance and not Plot.isTileTaken(tile.plot, tile.x + side.x, tile.z + side.z) then
			nearestSide, nearestDistance = side, distance
		end
	end
	return nearestSide, nearestDistance
end

local function pushGroundItemOutOfTile(groundItems: GroundItems, id: number, tile: Tile, now: number)
	local position = groundItems.itemsById[id].position
	local stack = GroundItems.removeItem(groundItems, id) :: ItemStack
	local side, distance = findNearestFreeSideOfTile(position, tile)
	if side == nil then
		local top = tile.center.y + Plot.TILE_SIZE
		GroundItems.spawnStack(groundItems, stack, Position.new(position.x, top, position.z), NO_VELOCITY, now)
		return
	end
	local outside = Position.new(position.x + side.x * distance, position.y, position.z + side.z * distance)
	GroundItems.spawnStack(groundItems, stack, outside, {
		x = side.x * PlotCollision.PUSHED_GROUND_ITEM_SPEED,
		y = 0,
		z = side.z * PlotCollision.PUSHED_GROUND_ITEM_SPEED,
	}, now)
end

--- Pushes the ground items out of the tile `x`, `z` of `plot`, whose tile x 1, z 1 has its outer
--- corner at `plotCorner`. A ground item is pushed if it reaches more than a tenth of a stud into
--- the cube a placed item fills on that tile. It is taken out of the world and its stack is
--- spawned again at the time `now`, as a new ground item with a new id: just outside the nearest
--- side of the tile that has no placed item against it, no higher and no further along that side
--- than it was, moving away from the tile along the ground at `PUSHED_GROUND_ITEM_SPEED`. A side
--- at the edge of the plot has nothing against it. Of sides equally near, the one towards greater
--- x is used first, then lesser x, then greater z, then lesser z. If all four sides have a placed
--- item against them, the stack is spawned again on top of the cube instead, not moving. Ground
--- items are pushed in the order of their ids, lowest first.
--- Note: it does not check that anything stands on the tile, and where a pushed ground item
--- lands is not checked either. One that lay across a corner of the tile can land partly inside a
--- placed item that stands on the tile diagonally across that corner.
function PlotCollision.pushGroundItemsOutOfTile(
	groundItems: GroundItems,
	plot: Plot.Plot,
	plotCorner: Position,
	x: number,
	z: number,
	now: number
)
	local tile: Tile = { plot = plot, x = x, z = z, center = Plot.getTileCenter(plotCorner, x, z) }
	local ids = {}
	for id, groundItem in groundItems.itemsById do
		if isLyingInTile(groundItem.position, tile) then
			table.insert(ids, id)
		end
	end
	table.sort(ids)
	for _, id in ids do
		pushGroundItemOutOfTile(groundItems, id, tile, now)
	end
end

return PlotCollision
