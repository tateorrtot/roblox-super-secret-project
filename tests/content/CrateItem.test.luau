--!strict
-- Tests for CrateItem. Run from the repository root: lune run tests/content/CrateItem.test.luau

local Check = require("../Check")
local Crate = require("../../src/shared/content/Crate")
local CrateItem = require("../../src/shared/content/CrateItem")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemScripts = require("../../src/shared/requests/ItemScripts")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local World = require("../../src/shared/world/World")

local check = Check.that
local at = Position.new

ItemRegistry.register(CrateItem)

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

do -- the crate item as names
	check(CrateItem.id == "crate", 'id: the crate item is the item "crate"')
	check(Crate.ITEM_ID_WHEN_BROKEN == CrateItem.id, "id: it is the item that a broken crate leaves")
	check(CrateItem.stackSize == 1, "stackSize: one crate item to a slot")
	check(CrateItem.name == "Crate", 'name: it is shown as "Crate"')
end

do -- the crate item as the script of its item
	ItemScripts.register(CrateItem.id, CrateItem)
	local registered = ItemScripts.find(CrateItem.id)
	check(
		registered ~= nil and registered.interactWithTile == CrateItem.interactWithTile,
		"interactWithTile: is what the registered crate item does when someone holding it interacts with a tile"
	)
end

do -- interactWithTile
	local world = newWorld()
	local usedUp = CrateItem.interactWithTile(world, 1, 1)
	local placedObjectId = world.plot.nextId - 1
	local placed = world.plot.placedObjectsById[placedObjectId]
	check(
		placedCount(world) == 1
			and placed ~= nil
			and placed.kindId == Crate.PLACED_OBJECT_KIND_ID
			and placed.tileX == 1
			and placed.tileZ == 1,
		"interactWithTile: a crate stands on the tile, in a world with no player to hold the item"
	)
	local inventory = (placed :: Crate.Crate).inventory
	check(
		inventory ~= nil and inventory.slotCount == Crate.SLOT_COUNT and Inventory.isEmpty(inventory),
		"interactWithTile: placed as Crate.place does, with an inventory on it that holds nothing"
	)
	check(usedUp == 1, "interactWithTile: returns 1, since one crate item was used up")
	check(next(world.groundItems.itemsById) == nil, "interactWithTile: and nothing is left lying on the ground")

	check(
		CrateItem.interactWithTile(world, 1, 1) == 0 and placedCount(world) == 1,
		"interactWithTile: nothing happens on a tile that something stands on, and 0 is returned"
	)
	check(
		CrateItem.interactWithTile(world, 7, 1) == 0 and placedCount(world) == 1,
		"interactWithTile: nothing happens on a tile the plot does not have, and 0 is returned"
	)
	check(
		CrateItem.interactWithTile(world, 6, 6) == 1 and placedCount(world) == 2,
		"interactWithTile: a second crate is placed on another tile"
	)
end

do -- interactWithTile, and who stands on the tile
	local world = newWorld()
	-- The middle of tile 3, 1 is at 10, 2. A player 3 studs from it stands on the tile; one a little further does not.
	World.addPlayer(world, 1)
	World.setCharacterPosition(world, 1, at(13, 0, 2))
	check(
		CrateItem.interactWithTile(world, 3, 1) == 0 and placedCount(world) == 0,
		"interactWithTile: nothing happens on a tile a player stands on, and 0 is returned"
	)
	World.setCharacterPosition(world, 1, at(13.01, 0, 2))
	check(
		CrateItem.interactWithTile(world, 3, 1) == 1 and placedCount(world) == 1,
		"interactWithTile: a crate is placed once that player has stepped off the tile"
	)
	World.setCharacterPosition(world, 1, at(500, 0, 500))
	check(
		CrateItem.interactWithTile(world, 4, 1) == 1 and placedCount(world) == 2,
		"interactWithTile: it does not ask how far away anybody stands"
	)
	World.removeCharacter(world, 1)
	check(
		CrateItem.interactWithTile(world, 5, 1) == 1 and placedCount(world) == 3,
		"interactWithTile: a player with no character stands on no tile"
	)
end

Check.finish("CrateItem")
