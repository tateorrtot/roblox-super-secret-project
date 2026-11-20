--!strict
-- Tests for Plot. Run from the repository root: lune run tests/plots/Plot.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local Plot = require("../../src/shared/plots/Plot")

local check = Check.that

ItemRegistry.register({ id = "apple", stackSize = 16 })
ItemRegistry.register({ id = "stove", stackSize = 1, placeable = true })
ItemRegistry.register({ id = "crate", stackSize = 1, placeable = true, slotCount = 27 })
ItemRegistry.register({ id = "pouch", stackSize = 1, placeable = true, slotCount = 2 })

-- How many placed items a plot has.
local function placedCount(plot: Plot.Plot): number
	local count = 0
	for _ in plot.placedById :: any do
		count += 1
	end
	return count
end

do -- the rules as numbers
	check(Plot.TILE_SIZE == 4, "a tile is 4 studs on a side")
	check(Plot.REACH == 16, "a player reaches a tile from 16 studs, which is four tiles")
end

do -- a new plot
	local plot = Plot.new(18, 12)
	check(plot.width == 18 and plot.depth == 12, "new: has the size asked for")
	check(plot.nextId == 1 and placedCount(plot) == 0, "new: nothing is placed, and the first placed item will be 1")
	check(Plot.new(1, 1).width == 1, "new: a plot may be a single tile")
end

do -- which tiles a plot has
	local plot = Plot.new(3, 2)
	check(Plot.hasTile(plot, 1, 1), "hasTile: the corner tile")
	check(Plot.hasTile(plot, 3, 2), "hasTile: the far corner tile")
	check(not Plot.hasTile(plot, 4, 1), "hasTile: not past the width")
	check(not Plot.hasTile(plot, 1, 3), "hasTile: not past the depth")
	check(not Plot.hasTile(plot, 2, 3), "hasTile: width and depth are not swapped")
	check(not Plot.hasTile(plot, 0, 1) and not Plot.hasTile(plot, 1, 0), "hasTile: not tile 0")
	check(not Plot.hasTile(plot, -1, 1) and not Plot.hasTile(plot, 1, -1), "hasTile: not a tile below 1")
	for _, bad in { 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		check(not Plot.hasTile(plot, bad, 1), "hasTile: not x = " .. tostring(bad))
		check(not Plot.hasTile(plot, 1, bad), "hasTile: not z = " .. tostring(bad))
	end
	check(not Plot.hasTile(plot, nil, 1) and not Plot.hasTile(plot, 1, nil), "hasTile: not without a number")
end

do -- placing
	local plot = Plot.new(4, 4)
	check(Plot.canPlace(plot, "stove", 2, 3), "canPlace: a placeable item on a tile that holds nothing")
	local stove = Plot.place(plot, "stove", 2, 3)
	check(stove == 1 and plot.nextId == 2, "place: the first placed item is 1, and the next will be 2")
	local placed = plot.placedById[1]
	check(placed.itemId == "stove" and placed.x == 2 and placed.z == 3, "place: it is that item on that tile")
	check(placed.inventory == nil, "place: an item with no slotCount has no inventory")
	check(table.isfrozen(placed), "place: a placed item's record never changes")

	check(not Plot.canPlace(plot, "crate", 2, 3), "canPlace: not on a tile that is taken")
	check(Plot.place(plot, "crate", 2, 3) == nil, "place: nil on a tile that is taken")
	check(placedCount(plot) == 1 and plot.nextId == 2, "place: a refused placing changes nothing")
	check(Plot.canPlace(plot, "crate", 3, 2), "canPlace: x and z are not swapped")

	check(not Plot.canPlace(plot, "apple", 1, 1), "canPlace: not an item that cannot be placed")
	check(Plot.place(plot, "apple", 1, 1) == nil, "place: nil for an item that cannot be placed")
	check(placedCount(plot) == 1 and plot.nextId == 2, "place: and again nothing changes")

	local crate = Plot.place(plot, "crate", 1, 1)
	check(crate == 2, "place: ids count up")
	local inside = plot.placedById[2].inventory
	check(
		inside ~= nil and inside.slotCount == 27 and Inventory.isEmpty(inside),
		"place: a crate has 27 slots, holding nothing"
	)
	local pouch = Plot.place(plot, "pouch", 4, 4)
	local pouchInside = plot.placedById[pouch :: number].inventory
	check(pouchInside ~= nil and pouchInside.slotCount == 2, "place: the inventory has the slotCount of its item")
	local second = Plot.place(plot, "crate", 1, 2)
	check(plot.placedById[second :: number].inventory ~= inside, "place: each placed crate has an inventory of its own")
	check(
		Plot.place(plot, "stove", 4, 1) == 5 and Plot.place(plot, "stove", 1, 4) == 6,
		"place: the corner tiles can be used"
	)
end

do -- removing
	local plot = Plot.new(4, 4)
	local crate = Plot.place(plot, "crate", 3, 3) :: number
	local stove = Plot.place(plot, "stove", 1, 1) :: number
	local inside = plot.placedById[crate].inventory :: Inventory.Inventory
	Inventory.addItems(inside, "apple", 20)

	local removed = Plot.remove(plot, crate)
	check(
		removed ~= nil and removed.itemId == "crate" and removed.x == 3 and removed.z == 3,
		"remove: returns the placed item"
	)
	check(removed ~= nil and removed.inventory == inside, "remove: with its inventory")
	check(Inventory.countItems(inside, "apple") == 20, "remove: and what was in it")
	check(plot.placedById[crate] == nil and placedCount(plot) == 1, "remove: it is no longer on the plot")
	check(plot.placedById[stove] ~= nil, "remove: other placed items stay")
	check(Plot.remove(plot, crate) == nil, "remove: nil for an id that is no longer on the plot")
	check(Plot.remove(plot, 99) == nil, "remove: nil for an id that never was")
	check(placedCount(plot) == 1, "remove: a removal that found nothing changes nothing")

	check(Plot.canPlace(plot, "stove", 3, 3), "canPlace: the tile holds nothing again")
	check(Plot.place(plot, "stove", 3, 3) == 3, "place: a new placed item gets a new id, not the old one")
end

do -- where a plot's tiles are in the world
	local corner = { x = -36, y = 0.4, z = 10 }
	local x, z = Plot.tileAt(corner, { x = -36, y = 5, z = 10 })
	check(x == 1 and z == 1, "tileAt: the corner itself is over tile 1, 1")
	x, z = Plot.tileAt(corner, { x = -32.01, y = 0, z = 13.99 })
	check(x == 1 and z == 1, "tileAt: just inside the far edges of tile 1, 1")
	x, z = Plot.tileAt(corner, { x = -32, y = 0, z = 14 })
	check(x == 2 and z == 2, "tileAt: on the edge is the next tile")
	x, z = Plot.tileAt(corner, { x = -36.01, y = 0, z = 9.99 })
	check(x == 0 and z == 0, "tileAt: just outside the corner is tile 0, 0, which no plot has")
	x, z = Plot.tileAt(corner, { x = -36 + 4 * 6 + 1, y = 0, z = 10 + 4 * 2 + 3 })
	check(x == 7 and z == 3, "tileAt: x and z are counted separately")

	local center = Plot.tileCenter(corner, 1, 1)
	check(
		center.x == -34 and center.y == 0.4 and center.z == 12,
		"tileCenter: the middle of tile 1, 1, at the corner's height"
	)
	center = Plot.tileCenter(corner, 7, 3)
	check(center.x == -36 + 6.5 * 4 and center.z == 10 + 2.5 * 4, "tileCenter: the middle of another tile")
	local allBack = true
	for tileX = 1, 5 do
		for tileZ = 1, 5 do
			local backX, backZ = Plot.tileAt(corner, Plot.tileCenter(corner, tileX, tileZ))
			if backX ~= tileX or backZ ~= tileZ then
				allBack = false
			end
		end
	end
	check(allBack, "tileAt: the middle of a tile is over that tile")
end

do -- a tile the plot does not have
	local plot = Plot.new(3, 2)
	local offPlot = { { 0, 1 }, { 4, 1 }, { 1, 3 }, { 1, 0 }, { 1.5, 1 }, { 1, "2" } } :: { { any } }
	for _, tile in offPlot do
		check(Check.errorFrom(function()
			return Plot.place(plot, "stove", tile[1], tile[2])
		end) ~= nil, `place: fails for tile x {tile[1]}, z {tile[2]}`)
	end
	check(placedCount(plot) == 0 and plot.nextId == 1, "place: a failed call changes nothing")
end

Check.finish("Plot")
