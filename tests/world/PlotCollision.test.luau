--!strict
-- Tests for PlotCollision. Run from the repository root: lune run tests/world/PlotCollision.test.luau

local Check = require("../Check")
local GroundItems = require("../../src/shared/world/GroundItems")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local Plot = require("../../src/shared/plots/Plot")
local PlotCollision = require("../../src/shared/world/PlotCollision")
local Position = require("../../src/shared/Position")

local check = Check.that
local at = Position.new
local STILL = { x = 0, y = 0, z = 0 }
local CORNER = at(0, 0, 0)
local SPEED = PlotCollision.PUSHED_GROUND_ITEM_SPEED

ItemRegistry.register({ id = "apple", stackSize = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "stove", stackSize = 1 })
ItemRegistry.register({ id = "crate", stackSize = 1 })
ItemRegistry.register({ id = "post", stackSize = 8 })

-- A ground item touches the side of what stands on a tile when its middle is this far from the
-- tile's middle along x or z.
local TOUCHING = (Plot.TILE_SIZE + GroundItems.ITEM_WIDTH) / 2

-- True if `groundItem` is at `x`, `y`, `z`, to within a rounding error.
local function isAt(groundItem: GroundItems.GroundItem, x: number, y: number, z: number): boolean
	return Position.getDistance(groundItem.position, at(x, y, z)) < 1e-9
end

-- True if `groundItem` was spawned moving at `x`, `y`, `z` studs a second.
local function wasSpawnedMovingAt(groundItem: GroundItems.GroundItem, x: number, y: number, z: number): boolean
	local velocity = groundItem.spawnVelocity
	return velocity.x == x and velocity.y == y and velocity.z == z
end

-- The ground items that hold one item, as a list sorted by count.
local function groundStacks(groundItems: GroundItems.GroundItems, itemId: string): { GroundItems.GroundItem }
	local found: { GroundItems.GroundItem } = {}
	for _, groundItem in groundItems.itemsById do
		if groundItem.stack.itemId == itemId then
			table.insert(found, groundItem)
		end
	end
	table.sort(found, function(a: GroundItems.GroundItem, b: GroundItems.GroundItem): boolean
		return a.stack.count < b.stack.count
	end)
	return found
end

-- How many of one item lie on the ground.
local function onGround(groundItems: GroundItems.GroundItems, itemId: string): number
	local total = 0
	for _, groundItem in groundStacks(groundItems, itemId) do
		total += groundItem.stack.count
	end
	return total
end

-- A plot of 6 by 6 tiles with nothing on it, whose corner is at the origin, so that the middle of
-- tile x, z is at x * 4 - 2, z * 4 - 2: tile 3, 3 reaches from 8 to 12 along x and z, and its middle
-- is 10, 10. With it, a set of ground items with nothing in the world.
local function newPlot(): (Plot.Plot, GroundItems.GroundItems)
	return Plot.new(6, 6), GroundItems.new()
end

-- Spawns one of an item as a ground item at rest at `x`, `y`, `z`, at time 0, and returns its id.
local function lyingAt(groundItems: GroundItems.GroundItems, itemId: string, x: number, y: number, z: number): number
	return GroundItems.spawnStack(groundItems, ItemStack.new(itemId, 1), at(x, y, z), STILL, 0)
end

-- Places a crate on tile 3, 3 and pushes the ground items out of that tile at the time `now`.
local function placeCrateAndPush(plot: Plot.Plot, groundItems: GroundItems.GroundItems, now: number)
	Plot.placeObject(plot, "crate", 3, 3)
	PlotCollision.pushGroundItemsOutOfTile(groundItems, plot, CORNER, 3, 3, now)
end

do -- the number it goes by
	check(SPEED == 6, "a ground item pushed out of a tile starts moving at 6 studs a second")
end

do -- a ground item in the tile, one touching it and one on the next tile
	local plot, groundItems = newPlot()
	local inside = lyingAt(groundItems, "apple", 9, 0, 10.5)
	local outside = lyingAt(groundItems, "fish", 10 - TOUCHING, 0, 10)
	local onNextTile = lyingAt(groundItems, "post", 14, 0, 10)
	placeCrateAndPush(plot, groundItems, 140)
	check(
		groundItems.itemsById[inside] == nil,
		"pushGroundItemsOutOfTile: a ground item that lay in the tile is taken out of the world"
	)
	local apples = groundStacks(groundItems, "apple")
	check(
		#apples == 1 and apples[1].stack.count == 1,
		"pushGroundItemsOutOfTile: and its stack is spawned again, whole"
	)
	check(
		isAt(apples[1], 10 - TOUCHING, 0, 10.5),
		"pushGroundItemsOutOfTile: just outside the nearest side of the tile, no higher and no further along that side"
	)
	check(
		wasSpawnedMovingAt(apples[1], -SPEED, 0, 0),
		"pushGroundItemsOutOfTile: moving along the ground and away from the tile"
	)
	check(apples[1].spawnTime == 140, "pushGroundItemsOutOfTile: spawned at the time given")
	check(
		groundItems.itemsById[outside] ~= nil and groundItems.itemsById[onNextTile] ~= nil,
		"pushGroundItemsOutOfTile: a ground item that only touches the tile's side stays, and so does one on the next tile"
	)
	check(
		onGround(groundItems, "apple") == 1
			and onGround(groundItems, "fish") == 1
			and onGround(groundItems, "post") == 1,
		"pushGroundItemsOutOfTile: nothing is made or lost"
	)
end

do -- which side a ground item is pushed out of
	-- The nearest side has a placed object against it, so the next nearest is used.
	local plot, groundItems = newPlot()
	Plot.placeObject(plot, "post", 2, 3)
	lyingAt(groundItems, "apple", 9, 0, 10.5)
	placeCrateAndPush(plot, groundItems, 0)
	local pushed = groundStacks(groundItems, "apple")[1]
	check(
		isAt(pushed, 9, 0, 10 + TOUCHING) and wasSpawnedMovingAt(pushed, 0, 0, SPEED),
		"pushGroundItemsOutOfTile: a side with a placed object against it is not used, and the next nearest is"
	)

	-- Each of the four sides is used when it is the nearest.
	local sidesPlot, sides = newPlot()
	lyingAt(sides, "apple", 11, 0, 10)
	lyingAt(sides, "fish", 9, 0, 10)
	lyingAt(sides, "post", 10, 0, 11)
	lyingAt(sides, "stove", 10, 0, 9)
	placeCrateAndPush(sidesPlot, sides, 0)
	local apple = groundStacks(sides, "apple")[1]
	local fish = groundStacks(sides, "fish")[1]
	local post = groundStacks(sides, "post")[1]
	local stove = groundStacks(sides, "stove")[1]
	check(
		isAt(apple, 10 + TOUCHING, 0, 10) and wasSpawnedMovingAt(apple, SPEED, 0, 0),
		"pushGroundItemsOutOfTile: a ground item nearest the side of greater x is pushed out of that side"
	)
	check(
		isAt(fish, 10 - TOUCHING, 0, 10) and wasSpawnedMovingAt(fish, -SPEED, 0, 0),
		"pushGroundItemsOutOfTile: one nearest the side of lesser x, out of that side"
	)
	check(
		isAt(post, 10, 0, 10 + TOUCHING) and wasSpawnedMovingAt(post, 0, 0, SPEED),
		"pushGroundItemsOutOfTile: one nearest the side of greater z, out of that side"
	)
	check(
		isAt(stove, 10, 0, 10 - TOUCHING) and wasSpawnedMovingAt(stove, 0, 0, -SPEED),
		"pushGroundItemsOutOfTile: one nearest the side of lesser z, out of that side"
	)

	-- A side along z has a placed object against it, so it is not used either.
	local alongZPlot, alongZ = newPlot()
	Plot.placeObject(alongZPlot, "post", 3, 4)
	lyingAt(alongZ, "apple", 10, 0, 11)
	placeCrateAndPush(alongZPlot, alongZ, 0)
	check(
		isAt(groundStacks(alongZ, "apple")[1], 10 + TOUCHING, 0, 11),
		"pushGroundItemsOutOfTile: a side along z with a placed object against it is not used"
	)

	-- Every side has a placed object against it, so the stack is spawned on top.
	local walledPlot, walled = newPlot()
	for _, tile in { { 2, 3 }, { 4, 3 }, { 3, 2 }, { 3, 4 } } do
		Plot.placeObject(walledPlot, "post", tile[1], tile[2])
	end
	lyingAt(walled, "apple", 9, 0, 10.5)
	placeCrateAndPush(walledPlot, walled, 0)
	local lifted = groundStacks(walled, "apple")[1]
	check(
		isAt(lifted, 9, Plot.TILE_SIZE, 10.5) and wasSpawnedMovingAt(lifted, 0, 0, 0),
		"pushGroundItemsOutOfTile: with a placed object against all four sides, the stack is spawned on top, not moving"
	)

	-- Equally near every side: the sides are tried towards greater x, lesser x, greater z, then
	-- lesser z, and one with a placed object against it is passed over.
	local function pushedFromMiddle(blocked: { { number } }): GroundItems.GroundItem
		local tiePlot, tie = newPlot()
		for _, tile in blocked do
			Plot.placeObject(tiePlot, "post", tile[1], tile[2])
		end
		lyingAt(tie, "fish", 10, 0, 10)
		placeCrateAndPush(tiePlot, tie, 0)
		return groundStacks(tie, "fish")[1]
	end
	check(
		isAt(pushedFromMiddle({}), 10 + TOUCHING, 0, 10),
		"pushGroundItemsOutOfTile: of sides equally near, the one towards greater x is used first"
	)
	check(
		isAt(pushedFromMiddle({ { 4, 3 } }), 10 - TOUCHING, 0, 10),
		"pushGroundItemsOutOfTile: then the one towards lesser x"
	)
	check(
		isAt(pushedFromMiddle({ { 4, 3 }, { 2, 3 } }), 10, 0, 10 + TOUCHING),
		"pushGroundItemsOutOfTile: then the one towards greater z"
	)
	check(
		isAt(pushedFromMiddle({ { 4, 3 }, { 2, 3 }, { 3, 4 } }), 10, 0, 10 - TOUCHING),
		"pushGroundItemsOutOfTile: then the one towards lesser z"
	)

	-- A ground item above the floor of the tile.
	local raisedPlot, raised = newPlot()
	lyingAt(raised, "apple", 9, 3, 10.5)
	placeCrateAndPush(raisedPlot, raised, 0)
	check(
		isAt(groundStacks(raised, "apple")[1], 10 - TOUCHING, 3, 10.5),
		"pushGroundItemsOutOfTile: a ground item above the floor comes out no higher and no lower than it was"
	)

	-- The edge of the plot: there is nothing off the plot to be in the way.
	local cornerPlot, corner = newPlot()
	lyingAt(corner, "apple", 0.5, 0, 2)
	Plot.placeObject(cornerPlot, "crate", 1, 1)
	PlotCollision.pushGroundItemsOutOfTile(corner, cornerPlot, CORNER, 1, 1, 0)
	check(
		isAt(groundStacks(corner, "apple")[1], 2 - TOUCHING, 0, 2),
		"pushGroundItemsOutOfTile: at the edge of the plot a ground item is pushed off the plot"
	)

	-- The plot's corner is not at the origin.
	local movedPlot, moved = newPlot()
	lyingAt(moved, "apple", 109, 50, 210.5)
	Plot.placeObject(movedPlot, "crate", 3, 3)
	PlotCollision.pushGroundItemsOutOfTile(moved, movedPlot, at(100, 50, 200), 3, 3, 0)
	check(
		isAt(groundStacks(moved, "apple")[1], 110 - TOUCHING, 50, 210.5),
		"pushGroundItemsOutOfTile: the tile is where the plot's corner puts it"
	)
end

do -- how far in a ground item must reach, and how high it may be
	local plot, groundItems = newPlot()
	local justIn = lyingAt(groundItems, "apple", 10 - TOUCHING + 0.11, 0, 10)
	local justOut = lyingAt(groundItems, "fish", 10, 0, 10 + TOUCHING - 0.09)
	local onTop = lyingAt(groundItems, "post", 10, Plot.TILE_SIZE - 0.09, 10)
	local inTheAir = lyingAt(groundItems, "stove", 10, Plot.TILE_SIZE - 0.11, 10)
	placeCrateAndPush(plot, groundItems, 0)
	check(
		groundItems.itemsById[justIn] == nil and groundItems.itemsById[inTheAir] == nil,
		"pushGroundItemsOutOfTile: a ground item that reaches more than a tenth of a stud into the cube is pushed out"
	)
	check(
		groundItems.itemsById[justOut] ~= nil and groundItems.itemsById[onTop] ~= nil,
		"pushGroundItemsOutOfTile: one that reaches in less than that, from the side or from above, is left alone"
	)

	-- Exactly a tenth of a stud in is not more than a tenth.
	local edgePlot, edge = newPlot()
	local atSideAlongX = lyingAt(edge, "apple", 10 + TOUCHING - 0.1, 0, 10)
	local atSideAlongZ = lyingAt(edge, "fish", 10, 0, 10 - (TOUCHING - 0.1))
	local atTop = lyingAt(edge, "post", 10, Plot.TILE_SIZE - 0.1, 10)
	placeCrateAndPush(edgePlot, edge, 0)
	check(
		edge.itemsById[atSideAlongX] ~= nil and edge.itemsById[atSideAlongZ] ~= nil,
		"pushGroundItemsOutOfTile: a ground item that reaches exactly a tenth of a stud in from a side is left alone"
	)
	check(
		edge.itemsById[atTop] ~= nil,
		"pushGroundItemsOutOfTile: and so is one that reaches exactly a tenth of a stud in from above"
	)

	local underPlot, under = newPlot()
	local below = lyingAt(under, "apple", 10, -GroundItems.ITEM_WIDTH + 0.09, 10)
	local reachingUp = lyingAt(under, "fish", 10, -GroundItems.ITEM_WIDTH + 0.11, 10)
	placeCrateAndPush(underPlot, under, 0)
	check(
		under.itemsById[below] ~= nil and under.itemsById[reachingUp] == nil,
		"pushGroundItemsOutOfTile: a ground item under the cube is left alone, unless it reaches up into it"
	)
end

do -- several at once
	local plot, groundItems = newPlot()
	lyingAt(groundItems, "apple", 9, 0, 10)
	lyingAt(groundItems, "apple", 9, 0, 10)
	lyingAt(groundItems, "fish", 11, 0, 10)
	lyingAt(groundItems, "stove", 10, 0, 9)
	placeCrateAndPush(plot, groundItems, 0)
	check(
		onGround(groundItems, "apple") == 2
			and onGround(groundItems, "fish") == 1
			and onGround(groundItems, "stove") == 1,
		"pushGroundItemsOutOfTile: every ground item that lay there is pushed out, and none is lost"
	)
	check(
		#groundStacks(groundItems, "apple") == 2,
		"pushGroundItemsOutOfTile: two of one item pushed out to the same place are still two ground items"
	)
	for _, groundItem in groundItems.itemsById do
		local alongX = math.abs(groundItem.position.x - 10)
		local alongZ = math.abs(groundItem.position.z - 10)
		check(
			math.max(alongX, alongZ) >= TOUCHING - 1e-9,
			"pushGroundItemsOutOfTile: each ground item is clear of the tile afterwards"
		)
	end

	-- Ground items are pushed in the order of their ids, whatever order the table gives them in.
	local orderedPlot, ordered = newPlot()
	for index = 1, 100 do
		lyingAt(ordered, "stove", 500 + index * 10, 0, 500)
	end
	GroundItems.removeExpiredItems(ordered, GroundItems.LIFETIME_SECONDS)
	for index = 1, 30 do
		lyingAt(ordered, "stove", 8.25 + index * 0.1, 0, 10)
	end
	placeCrateAndPush(orderedPlot, ordered, 0)
	local inOrder = true
	for index = 1, 30 do
		local pushedAgain = ordered.itemsById[130 + index]
		local wentTowardsLesserX = pushedAgain ~= nil and pushedAgain.spawnVelocity.x < 0
		if pushedAgain == nil or wentTowardsLesserX ~= (index <= 17) then
			inOrder = false
		end
	end
	check(inOrder, "pushGroundItemsOutOfTile: ground items are pushed in the order of their ids, lowest first")
end

do -- a tile with nothing on it
	local plot, groundItems = newPlot()
	local lying = lyingAt(groundItems, "apple", 9, 0, 10.5)
	PlotCollision.pushGroundItemsOutOfTile(groundItems, plot, CORNER, 3, 3, 0)
	check(
		groundItems.itemsById[lying] == nil and isAt(groundStacks(groundItems, "apple")[1], 10 - TOUCHING, 0, 10.5),
		"pushGroundItemsOutOfTile: it pushes whether or not anything stands on the tile"
	)
	local empty = GroundItems.new()
	PlotCollision.pushGroundItemsOutOfTile(empty, plot, CORNER, 3, 3, 0)
	check(next(empty.itemsById) == nil, "pushGroundItemsOutOfTile: does nothing when no ground item lies in the tile")
end

Check.finish("PlotCollision")
