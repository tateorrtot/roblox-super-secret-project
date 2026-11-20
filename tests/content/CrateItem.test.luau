--!strict
-- Tests for CrateItem. Run from the repository root: lune run tests/content/CrateItem.test.luau

local Check = require("../Check")
local Crate = require("../../src/shared/content/Crate")
local CrateItem = require("../../src/shared/content/CrateItem")
local Hotbar = require("../../src/shared/inventory/Hotbar")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemScripts = require("../../src/shared/requests/ItemScripts")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local World = require("../../src/shared/world/World")

local check = Check.that
local at = Position.new

-- A crate stacks to 8 here, so that one crate taken can be told from a whole stack taken.
ItemRegistry.register({ id = "crate", stackSize = 8 })
ItemRegistry.register({ id = "log", stackSize = 16 })

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

-- How many placed objects stand on a world's plot.
local function placedCount(world: World.World): number
	local count = 0
	for _ in world.plot.placedObjectsById do
		count += 1
	end
	return count
end

-- A world at time 100 with a plot of 6 by 6 tiles whose corner is at the origin, so that the middle of
-- tile x, z is at x * 4 - 2, z * 4 - 2. Nothing stands on it. Player 1 stands at 6, 0, 0, with 3 crates
-- in hotbar slot 1, which is selected, and 12 logs in slot 2.
local function newWorld(): (World.World, PlayerState.PlayerState)
	local world = World.new(Plot.new(6, 6), at(0, 0, 0), 100)
	local player = World.addPlayer(world, 1)
	Inventory.setStack(player.pack, 1, ItemStack.new("crate", 3))
	Inventory.setStack(player.pack, 2, ItemStack.new("log", 12))
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	return world, player
end

do -- the crate item as names
	check(CrateItem.ITEM_ID == "crate", 'ITEM_ID: the crate item is the item "crate"')
	check(Crate.ITEM_ID_WHEN_BROKEN == CrateItem.ITEM_ID, "ITEM_ID: it is the item that a broken crate leaves")
end

do -- the crate item as the script of its item
	ItemScripts.register(CrateItem.ITEM_ID, CrateItem)
	local registered = ItemScripts.find(CrateItem.ITEM_ID)
	check(
		registered ~= nil and registered.interactWithTile == CrateItem.interactWithTile,
		"interactWithTile: is what the registered crate item does when a player interacts with a tile"
	)
end

do -- interactWithTile
	local world, player = newWorld()
	CrateItem.interactWithTile(world, player, 1, 1)
	local placedObjectId = world.plot.nextId - 1
	local placed = world.plot.placedObjectsById[placedObjectId]
	check(
		placedCount(world) == 1
			and placed ~= nil
			and placed.kindId == Crate.PLACED_OBJECT_KIND_ID
			and placed.tileX == 1
			and placed.tileZ == 1,
		"interactWithTile: a crate stands on the tile"
	)
	local inventory = world.placedObjectInventories[placedObjectId]
	check(
		inventory ~= nil and inventory.slotCount == Crate.SLOT_COUNT and Inventory.isEmpty(inventory),
		"interactWithTile: placed as Crate.place does, with an inventory that holds nothing"
	)
	check(
		is(Inventory.getStack(player.pack, 1), "crate", 2),
		"interactWithTile: one item has left the selected hotbar slot, and no more"
	)
	check(
		is(Inventory.getStack(player.pack, 2), "log", 12) and next(world.groundItems.itemsById) == nil,
		"interactWithTile: and nothing else has moved"
	)

	CrateItem.interactWithTile(world, player, 1, 1)
	check(
		placedCount(world) == 1 and is(Inventory.getStack(player.pack, 1), "crate", 2),
		"interactWithTile: nothing happens on a tile that something stands on"
	)
	-- The middle of tile 2, 1 is at 6, 2, and the player stands 2 studs from it.
	CrateItem.interactWithTile(world, player, 2, 1)
	check(
		placedCount(world) == 1 and is(Inventory.getStack(player.pack, 1), "crate", 2),
		"interactWithTile: nothing happens on the tile the player stands on"
	)

	PlayerState.openScreen(player)
	CrateItem.interactWithTile(world, player, 3, 1)
	check(
		placedCount(world) == 2 and is(Inventory.getStack(player.pack, 1), "crate", 1),
		"interactWithTile: it does not ask whether the player has a screen open"
	)
	PlayerState.closeScreen(player)

	CrateItem.interactWithTile(world, player, 4, 1)
	check(
		placedCount(world) == 3 and Inventory.getStack(player.pack, 1) == nil,
		"interactWithTile: the last crate of a stack is placed, and the slot holds nothing"
	)

	Hotbar.selectSlot(player.hotbar, 2)
	CrateItem.interactWithTile(world, player, 5, 1)
	check(
		placedCount(world) == 4 and is(Inventory.getStack(player.pack, 2), "log", 11),
		"interactWithTile: it does not look at what the selected slot holds, and takes one of whatever is there"
	)
end

do -- interactWithTile, and how far the player stands
	local world, player = newWorld()
	-- The middle of tile 6, 1 is at 22, 2. Standing at 6, 2 it is exactly 16 studs away.
	World.setCharacterPosition(world, 1, at(5.99, 0, 2))
	CrateItem.interactWithTile(world, player, 6, 1)
	check(
		placedCount(world) == 0 and is(Inventory.getStack(player.pack, 1), "crate", 3),
		"interactWithTile: nothing happens on a tile just beyond the character's reach"
	)
	World.setCharacterPosition(world, 1, at(6, 0, 2))
	CrateItem.interactWithTile(world, player, 6, 1)
	check(
		placedCount(world) == 1 and is(Inventory.getStack(player.pack, 1), "crate", 2),
		"interactWithTile: a crate is placed on a tile exactly at reach"
	)
	World.removeCharacter(world, 1)
	CrateItem.interactWithTile(world, player, 3, 1)
	check(
		placedCount(world) == 1 and is(Inventory.getStack(player.pack, 1), "crate", 2),
		"interactWithTile: nothing happens for a player with no character"
	)
end

do -- interactWithTile, and who stands on the tile
	local world, player = newWorld()
	-- The middle of tile 3, 1 is at 10, 2. A player 3 studs from it stands on the tile; one a little further does not.
	World.addPlayer(world, 2)
	World.setCharacterPosition(world, 2, at(13, 0, 2))
	CrateItem.interactWithTile(world, player, 3, 1)
	check(
		placedCount(world) == 0 and is(Inventory.getStack(player.pack, 1), "crate", 3),
		"interactWithTile: nothing happens on a tile another player stands on"
	)
	World.setCharacterPosition(world, 2, at(13.01, 0, 2))
	CrateItem.interactWithTile(world, player, 3, 1)
	check(
		placedCount(world) == 1 and is(Inventory.getStack(player.pack, 1), "crate", 2),
		"interactWithTile: a crate is placed once that player has stepped off the tile"
	)
	World.removeCharacter(world, 2)
	CrateItem.interactWithTile(world, player, 4, 1)
	check(
		placedCount(world) == 2 and is(Inventory.getStack(player.pack, 1), "crate", 1),
		"interactWithTile: a player with no character stands on no tile"
	)
end

Check.finish("CrateItem")
