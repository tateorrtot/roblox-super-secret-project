--!strict
--- Moves ground items out of the tile of a placed object.
---
--- A placed object fills its tile as a cube `Plot.TILE_SIZE` on each side, standing on the tile.
--- `pushGroundItemsOutOfTile` moves the ground items that lie in a tile out of it.
local GroundItems = require("../groundItems/GroundItems")
local ItemStack = require("../items/ItemStack")
local Plot = require("../plots/Plot")
local Position = require("../Position")

local PlotCollision = {}

type GroundItems = GroundItems.GroundItems
type ItemStack = ItemStack.ItemStack
type Position = Position.Position
type Tile = { plot: Plot.Plot, tileX: number, tileZ: number, center: Position }
type Side = { x: number, z: number }

--- The speed along the ground, in studs a second, at which a ground item that
--- `pushGroundItemsOutOfTile` pushes out of a side of a tile starts moving away from the tile.
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
		if distance < nearestDistance and not Plot.isTileTaken(tile.plot, tile.tileX + side.x, tile.tileZ + side.z) then
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

--- Pushes the ground items out of the tile at `tileX`, `tileZ` of `plot`, whose tile x `1`, z `1`
--- has its outer corner at `plotCorner`. A ground item is pushed if it reaches more than a tenth of
--- a stud into the cube that a placed object fills on that tile. Pushing removes the ground item
--- and spawns its stack again at the time `now`, as a new ground item with a new id. The new ground
--- item lies at the same height and at the same place along the side, touching the nearest side of
--- the tile that has no placed object against it, and starts moving away from the tile along the
--- ground at `PUSHED_GROUND_ITEM_SPEED`. A side at the edge of the plot has no placed object
--- against it. Of equally near sides, `pushGroundItemsOutOfTile` uses the side towards greater x
--- first, then lesser x, then greater z, then lesser z. If a placed object stands against all four
--- sides, the stack is spawned on top of the cube instead, at the same x and z, not moving. Ground
--- items are pushed in the order of their ids, lowest first.
--- Note: `pushGroundItemsOutOfTile` does not check that a placed object stands on the tile, and
--- does not check where a pushed ground item lands. A ground item that lay across a corner of the
--- tile can land partly inside a placed object that stands on the tile diagonally across that
--- corner.
function PlotCollision.pushGroundItemsOutOfTile(
	groundItems: GroundItems,
	plot: Plot.Plot,
	plotCorner: Position,
	tileX: number,
	tileZ: number,
	now: number
)
	local center = Plot.getTileCenter(plotCorner, tileX, tileZ)
	local tile: Tile = { plot = plot, tileX = tileX, tileZ = tileZ, center = center }
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
