--!strict
-- Tests for Crate. Run from the repository root: lune run tests/placedObjectKinds/Crate.test.luau

local Check = require("../Check")
local Crate = require("../../src/shared/placedObjectKinds/Crate")
local Inventory = require("../../src/shared/inventory/Inventory")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local World = require("../../src/shared/world/World")

local check = Check.that
local at = Position.new

-- How many placed objects stand on a world's plot.
local function placedCount(world: World.World): number
	local count = 0
	for _ in world.plot.placedObjectsById do
		count += 1
	end
	return count
end

do -- a crate as numbers
	check(Crate.KIND_ID == "crate", 'KIND_ID: a crate is of the kind "crate"')
	check(Crate.SLOT_COUNT == 27, "SLOT_COUNT: a crate has 27 slots")
end

do -- place
	local world = World.new(Plot.new(4, 4), at(0, 0, 0), 0)
	local id = Crate.place(world, 2, 3)
	local placed = world.plot.placedObjectsById[id]
	check(
		placed ~= nil and placed.kindId == Crate.KIND_ID and placed.tileX == 2 and placed.tileZ == 3,
		"place: a placed object of the crate's kind stands on the tile, and its id is returned"
	)
	local inventory = world.placedObjectInventories[id]
	check(
		inventory ~= nil and inventory.slotCount == Crate.SLOT_COUNT and Inventory.isEmpty(inventory),
		"place: the crate is given an inventory of SLOT_COUNT slots, holding nothing"
	)
	check(world.stations[id] == nil, "place: a crate is no station")

	local second = Crate.place(world, 1, 1)
	check(
		second ~= id and world.placedObjectInventories[second] ~= inventory,
		"place: each crate has an id and an inventory of its own"
	)

	check(Check.errorFrom(function()
		Crate.place(world, 2, 3)
	end) ~= nil, "place: fails on a tile that is taken")
	check(Check.errorFrom(function()
		Crate.place(world, 5, 1)
	end) ~= nil, "place: fails on a tile the plot does not have")
	check(placedCount(world) == 2 and world.plot.nextId == second + 1, "place: a placing that fails places nothing")
	check(
		world.placedObjectInventories[second + 1] == nil,
		"place: and gives no inventory to an id that no placed object has"
	)
end

Check.finish("Crate")
