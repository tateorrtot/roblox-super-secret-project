--!strict
-- Tests for PlacedObjectKinds, and for the written rows beside it: PlaceableItems and
-- PlacedObjectLooks. Run from the repository root: lune run tests/placedObjectKinds/PlacedObjectKinds.test.luau

local Check = require("../Check")
local Crate = require("../../src/shared/placedObjectKinds/Crate")
local ItemDefinitions = require("../../src/shared/items/ItemDefinitions")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local PlaceableItems = require("../../src/shared/placedObjectKinds/PlaceableItems")
local PlacedObjectKinds = require("../../src/shared/placedObjectKinds/PlacedObjectKinds")
local PlacedObjectLooks = require("../../src/shared/placedObjectKinds/PlacedObjectLooks")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local Stove = require("../../src/shared/placedObjectKinds/Stove")
local World = require("../../src/shared/world/World")

local check = Check.that

for _, definition in ItemDefinitions do
	ItemRegistry.register(definition)
end

-- Every kind there is, as the modules these tests know of.
local kindIds = { Crate.KIND_ID, Stove.KIND_ID }

-- True if a kind of placed object has the id `kindId`.
local function isKind(kindId: string): boolean
	return Check.errorFrom(function()
		return PlacedObjectKinds.get(kindId)
	end) == nil
end

do -- get
	check(
		PlacedObjectKinds.get(Crate.KIND_ID) == Crate :: any,
		"get: the kind with the crate's id is the crate's module"
	)
	check(
		PlacedObjectKinds.get(Stove.KIND_ID) == Stove :: any,
		"get: the kind with the stove's id is the stove's module"
	)
	check(Crate.KIND_ID ~= Stove.KIND_ID, "KIND_ID: each kind has an id of its own")
	check(
		Check.raises('no kind of placed object has the id "anvil"', function()
			PlacedObjectKinds.get("anvil")
		end),
		"get: fails for an id that no kind has"
	)
end

do -- a kind got by its id places an object of that kind
	local world = World.new(Plot.new(3, 3), Position.new(0, 0, 0), 0)
	for index, kindId in kindIds do
		local id = PlacedObjectKinds.get(kindId).place(world, index, 1)
		check(
			world.plot.placedObjectsById[id].kindId == kindId,
			'place: the kind "' .. kindId .. '" places an object of its own kind'
		)
	end
end

do -- PlaceableItems
	check(table.isfrozen(PlaceableItems), "PlaceableItems: the rows cannot be changed")
	local rowCount = 0
	for itemId, kindId in PlaceableItems do
		rowCount += 1
		check(ItemRegistry.has(itemId), 'PlaceableItems: "' .. itemId .. '" is an item that exists')
		check(isKind(kindId), 'PlaceableItems: "' .. itemId .. '" places a kind that exists, "' .. kindId .. '"')
	end
	check(rowCount > 0, "PlaceableItems: at least one item places an object")
	check(PlaceableItems.log == nil, "PlaceableItems: an item that places nothing has no row")
end

do -- PlacedObjectLooks
	check(table.isfrozen(PlacedObjectLooks), "PlacedObjectLooks: the rows cannot be changed")
	for _, kindId in kindIds do
		local look = PlacedObjectLooks[kindId]
		check(look ~= nil, 'PlacedObjectLooks: the kind "' .. kindId .. '" has a look')
		if look ~= nil then
			check(type(look.name) == "string" and #look.name > 0, 'the look of the kind "' .. kindId .. '" has a name')
			local color = look.color
			local isColor = type(color) == "table" and #color == 3
			if isColor then
				for _, part in color do
					if type(part) ~= "number" or part ~= math.floor(part) or part < 0 or part > 255 then
						isColor = false
					end
				end
			end
			check(isColor, 'the colour of the kind "' .. kindId .. '" is three whole numbers from 0 to 255')
		end
	end
	for kindId in PlacedObjectLooks do
		check(isKind(kindId), 'PlacedObjectLooks: the look "' .. kindId .. '" belongs to a kind that exists')
	end
end

Check.finish("PlacedObjectKinds")
