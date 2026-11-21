--!strict
-- Tests for StoveItem. Run from the repository root: lune run tests/content/StoveItem.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemScripts = require("../../src/shared/requests/ItemScripts")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local Stove = require("../../src/shared/content/Stove")
local StoveItem = require("../../src/shared/content/StoveItem")
local World = require("../../src/shared/world/World")

local check = Check.that
local at = Position.new

ItemRegistry.register(StoveItem)

-- How many placed objects stand on a world's plot.
local function placedCount(world: World.World): number
	local count = 0
	for _ in world.plot.placedObjectsById do
		count += 1
	end
	return count
end

-- A world at time 100 with a plot of 6 by 6 tiles whose corner is at the origin, so that the middle of
-- tile x, z is at x * 4 - 2, z * 4 - 2. Nothing stands on it, and nobody is in it.
local function newWorld(): World.World
	return World.new(Plot.new(6, 6), at(0, 0, 0), 100)
end

do -- the stove item as names
	check(StoveItem.id == "stove", 'id: the stove item is the item "stove"')
	check(StoveItem.stackSize == 1, "stackSize: one stove item to a slot")
	check(StoveItem.name == "Stove" and #StoveItem.color == 3, "name, color: it is shown as a stove, in a colour")
	check(Stove.ITEM_ID_WHEN_BROKEN == StoveItem.id, "id: it is the item that a broken stove leaves")
end

do -- the stove item as the script of its item
	ItemScripts.register(StoveItem.id, StoveItem)
	local registered = ItemScripts.find(StoveItem.id)
	check(
		registered ~= nil and registered.interactWithTile == StoveItem.interactWithTile,
		"interactWithTile: is what the registered stove item does when someone holding it interacts with a tile"
	)
end

do -- interactWithTile
	local world = newWorld()
	local usedUp = StoveItem.interactWithTile(world, 1, 1)
	local placedObjectId = world.plot.nextId - 1
	local placed = world.plot.placedObjectsById[placedObjectId]
	check(
		placedCount(world) == 1
			and placed ~= nil
			and placed.kindId == Stove.PLACED_OBJECT_KIND_ID
			and placed.tileX == 1
			and placed.tileZ == 1,
		"interactWithTile: a stove stands on the tile, in a world with no player to hold the item"
	)
	local station = world.stations[placedObjectId]
	check(
		station ~= nil and station.kindId == Stove.STATION_KIND_ID and Inventory.isEmpty(station.inventory),
		"interactWithTile: placed as Stove.place does, as a station whose slots hold nothing"
	)
	check(usedUp == 1, "interactWithTile: returns 1, since one stove item was used up")
	check(next(world.groundItems.itemsById) == nil, "interactWithTile: and nothing is left lying on the ground")

	check(
		StoveItem.interactWithTile(world, 1, 1) == 0 and placedCount(world) == 1,
		"interactWithTile: nothing happens on a tile that something stands on, and 0 is returned"
	)
	check(
		StoveItem.interactWithTile(world, 7, 1) == 0 and placedCount(world) == 1,
		"interactWithTile: nothing happens on a tile the plot does not have, and 0 is returned"
	)
	check(
		StoveItem.interactWithTile(world, 6, 6) == 1 and placedCount(world) == 2,
		"interactWithTile: a second stove is placed on another tile"
	)
end

do -- interactWithTile, and who stands on the tile
	local world = newWorld()
	-- The middle of tile 3, 1 is at 10, 2. A player 3 studs from it stands on the tile; one a little further does not.
	World.addPlayer(world, 1)
	World.setCharacterPosition(world, 1, at(13, 0, 2))
	check(
		StoveItem.interactWithTile(world, 3, 1) == 0 and placedCount(world) == 0,
		"interactWithTile: nothing happens on a tile a player stands on, and 0 is returned"
	)
	World.setCharacterPosition(world, 1, at(13.01, 0, 2))
	check(
		StoveItem.interactWithTile(world, 3, 1) == 1 and placedCount(world) == 1,
		"interactWithTile: a stove is placed once that player has stepped off the tile"
	)
	World.setCharacterPosition(world, 1, at(500, 0, 500))
	check(
		StoveItem.interactWithTile(world, 4, 1) == 1 and placedCount(world) == 2,
		"interactWithTile: it does not ask how far away anybody stands"
	)
	World.removeCharacter(world, 1)
	check(
		StoveItem.interactWithTile(world, 5, 1) == 1 and placedCount(world) == 3,
		"interactWithTile: a player with no character stands on no tile"
	)
end

Check.finish("StoveItem")
