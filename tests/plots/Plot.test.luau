--!strict
-- Tests for Plot. Run from the repository root: lune run tests/plots/Plot.test.luau

local Check = require("../Check")
local Plot = require("../../src/shared/plots/Plot")
local Signal = require("../../src/shared/Signal")

local check = Check.that

-- How many placed objects a plot has.
local function placedCount(plot: Plot.Plot): number
	local count = 0
	for _ in plot.placedObjectsById :: any do
		count += 1
	end
	return count
end

do -- the rules as numbers
	check(Plot.TILE_SIZE == 4, "a tile is 4 studs on a side")
end

do -- a new plot
	local plot = Plot.new(18, 12)
	check(plot.widthInTiles == 18 and plot.depthInTiles == 12, "new: has the size asked for")
	check(plot.nextId == 1 and placedCount(plot) == 0, "new: nothing is placed, and the first placed object will be 1")
	check(Plot.new(1, 1).widthInTiles == 1, "new: a plot may be a single tile")
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
	check(Plot.canPlaceObject(plot, 2, 3), "canPlaceObject: true for a tile that holds nothing")
	check(Plot.isTileTaken(plot, 2, 3) == false, "isTileTaken: false, and not nil, for a tile that holds nothing")
	local given = { kindId = "stove", tileX = 2, tileZ = 3, lit = true }
	local stove = Plot.placeObject(plot, given)
	check(Plot.isTileTaken(plot, 2, 3), "isTileTaken: true once an object stands on the tile")
	check(not Plot.isTileTaken(plot, 3, 2), "isTileTaken: x and z are not swapped")
	check(
		not Plot.isTileTaken(plot, 0, 3) and not Plot.isTileTaken(plot, 5, 3) and not Plot.isTileTaken(plot, 2, -1),
		"isTileTaken: false for a tile the plot does not have"
	)
	check(stove == 1 and plot.nextId == 2, "placeObject: the first placed object is 1, and the next will be 2")
	local placed = plot.placedObjectsById[1]
	check(
		placed.kindId == "stove" and placed.tileX == 2 and placed.tileZ == 3,
		"placeObject: the placed object is of that kind, on that tile"
	)
	check(
		placed == given and (placed :: any).lit == true,
		"placeObject: the plot keeps the table it was given, with a field on it that a plot does not read"
	)

	check(not Plot.canPlaceObject(plot, 2, 3), "canPlaceObject: false for a tile that is taken")
	check(
		Check.raises("nothing can be placed on the tile 2, 3", function()
			Plot.placeObject(plot, { kindId = "crate", tileX = 2, tileZ = 3 })
		end),
		"placeObject: fails on a tile that is taken"
	)
	check(placedCount(plot) == 1 and plot.nextId == 2, "placeObject: a placing that fails changes nothing")
	check(Plot.canPlaceObject(plot, 3, 2), "canPlaceObject: x and z are not swapped")

	local crate = Plot.placeObject(plot, { kindId = "crate", tileX = 1, tileZ = 1 })
	check(crate == 2, "placeObject: ids count up")
	local unheardOf = Plot.placeObject(plot, { kindId = "a kind nobody has heard of", tileX = 2, tileZ = 2 })
	check(
		plot.placedObjectsById[unheardOf].kindId == "a kind nobody has heard of",
		"placeObject: the plot takes any kind id as it is given"
	)
	check(
		Plot.placeObject(plot, { kindId = "stove", tileX = 4, tileZ = 1 }) == 4
			and Plot.placeObject(plot, { kindId = "stove", tileX = 1, tileZ = 4 }) == 5,
		"placeObject: the corner tiles can be used"
	)
end

do -- removing
	local plot = Plot.new(4, 4)
	local given = { kindId = "crate", tileX = 3, tileZ = 3 }
	local crate = Plot.placeObject(plot, given) :: number
	local stove = Plot.placeObject(plot, { kindId = "stove", tileX = 1, tileZ = 1 }) :: number

	local removed = Plot.removePlacedObject(plot, crate)
	check(
		removed ~= nil and removed.kindId == "crate" and removed.tileX == 3 and removed.tileZ == 3,
		"removePlacedObject: returns the placed object"
	)
	check(removed == given, "removePlacedObject: and it is the table that was placed")
	check(
		plot.placedObjectsById[crate] == nil and placedCount(plot) == 1,
		"removePlacedObject: it is no longer on the plot"
	)
	check(plot.placedObjectsById[stove] ~= nil, "removePlacedObject: other placed objects stay")
	check(
		Plot.removePlacedObject(plot, crate) == nil,
		"removePlacedObject: nil for an id that is no longer on the plot"
	)
	check(Plot.removePlacedObject(plot, 99) == nil, "removePlacedObject: nil for an id that never was")
	check(placedCount(plot) == 1, "removePlacedObject: a removal that found nothing changes nothing")

	check(Plot.canPlaceObject(plot, 3, 3), "canPlaceObject: true again once the placed object is taken off")
	check(not Plot.isTileTaken(plot, 3, 3), "isTileTaken: false again once the placed object is taken off")
	check(
		Plot.placeObject(plot, { kindId = "stove", tileX = 3, tileZ = 3 }) == 3,
		"placeObject: a new placed object gets a new id, not the old one"
	)
end

do -- where a plot's tiles are in the world
	local corner = { x = -36, y = 0.4, z = 10 }
	local x, z = Plot.getTileAt(corner, { x = -36, y = 5, z = 10 })
	check(x == 1 and z == 1, "getTileAt: the corner itself is over tile 1, 1")
	x, z = Plot.getTileAt(corner, { x = -32.01, y = 0, z = 13.99 })
	check(x == 1 and z == 1, "getTileAt: just inside the far edges of tile 1, 1")
	x, z = Plot.getTileAt(corner, { x = -32, y = 0, z = 14 })
	check(x == 2 and z == 2, "getTileAt: on the edge is the next tile")
	x, z = Plot.getTileAt(corner, { x = -36.01, y = 0, z = 9.99 })
	check(x == 0 and z == 0, "getTileAt: just outside the corner is tile 0, 0, which no plot has")
	x, z = Plot.getTileAt(corner, { x = -36 + 4 * 6 + 1, y = 0, z = 10 + 4 * 2 + 3 })
	check(x == 7 and z == 3, "getTileAt: x and z are counted separately")

	local center = Plot.getTileCenter(corner, 1, 1)
	check(
		center.x == -34 and center.y == 0.4 and center.z == 12,
		"getTileCenter: the middle of tile 1, 1, at the corner's height"
	)
	center = Plot.getTileCenter(corner, 7, 3)
	check(center.x == -36 + 6.5 * 4 and center.z == 10 + 2.5 * 4, "getTileCenter: the middle of another tile")
	local allBack = true
	for tileX = 1, 5 do
		for tileZ = 1, 5 do
			local backX, backZ = Plot.getTileAt(corner, Plot.getTileCenter(corner, tileX, tileZ))
			if backX ~= tileX or backZ ~= tileZ then
				allBack = false
			end
		end
	end
	check(allBack, "getTileAt: the middle of a tile is over that tile")
end

do -- a tile the plot does not have
	local plot = Plot.new(3, 2)
	local offPlot = { { 0, 1 }, { 4, 1 }, { 1, 3 }, { 1, 0 }, { 1.5, 1 }, { 1, "2" } } :: { { any } }
	for _, tile in offPlot do
		check(
			not Plot.canPlaceObject(plot, tile[1], tile[2]),
			`canPlace: false for tile x {tile[1]}, z {tile[2]}, which the plot does not have`
		)
		check(Check.errorFrom(function()
			Plot.placeObject(plot, { kindId = "stove", tileX = tile[1], tileZ = tile[2] })
		end) ~= nil, `placeObject: fails for tile x {tile[1]}, z {tile[2]}, which the plot does not have`)
	end
	check(placedCount(plot) == 0 and plot.nextId == 1, "placeObject: a placing that fails changes nothing")
end

do -- the two signals
	local plot = Plot.new(4, 4)
	local heard: { string } = {}
	Signal.connect(plot.placedObjectAdded, function(id: number, placedObject: Plot.PlacedObject)
		local stands = plot.placedObjectsById[id] == placedObject
		table.insert(heard, `added {id} {placedObject.kindId} {placedObject.tileX} {placedObject.tileZ} {stands}`)
	end)
	Signal.connect(plot.placedObjectRemoved, function(id: number, placedObject: Plot.PlacedObject)
		local gone = plot.placedObjectsById[id] == nil
		table.insert(heard, `removed {id} {placedObject.kindId} {gone}`)
	end)
	local crate = Plot.placeObject(plot, { kindId = "crate", tileX = 2, tileZ = 3 })
	check(
		#heard == 1 and heard[1] == `added {crate} crate 2 3 true`,
		"placeObject: fires placedObjectAdded with the id and the placed object, once the object stands on the plot"
	)
	Check.errorFrom(function()
		Plot.placeObject(plot, { kindId = "stove", tileX = 2, tileZ = 3 })
	end)
	check(#heard == 1, "placeObject: a placing that fails fires nothing")
	local removed = Plot.removePlacedObject(plot, crate)
	check(
		#heard == 2 and heard[2] == `removed {crate} crate true`,
		"removePlacedObject: fires placedObjectRemoved with the id and the placed object, once it is off the plot"
	)
	check(removed ~= nil, "removePlacedObject: and returns the placed object that the signal was fired with")
	Plot.removePlacedObject(plot, crate)
	Plot.removePlacedObject(plot, 99)
	check(#heard == 2, "removePlacedObject: fires nothing for an id that no placed object has")

	local quiet = Plot.new(2, 2)
	Plot.placeObject(quiet, { kindId = "stove", tileX = 1, tileZ = 1 })
	check(#heard == 2, "placeObject: one plot's signals are not fired by another plot")
end

Check.finish("Plot")
