--!strict
-- Tests for Crate. Run from the repository root: lune run tests/content/Crate.test.luau

local Check = require("../Check")
local Crate = require("../../src/shared/content/Crate")
local GroundItems = require("../../src/shared/groundItems/GroundItems")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlacedObjectScripts = require("../../src/shared/requests/PlacedObjectScripts")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local World = require("../../src/shared/world/World")

local check = Check.that
local at = Position.new

ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "crate", stackSize = 1 })

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

-- How many ground items a world has.
local function groundItemCount(world: World.World): number
	local count = 0
	for _ in world.groundItems.itemsById do
		count += 1
	end
	return count
end

-- A world at time 50 with a plot of 4 by 4 tiles whose corner is at the origin, so that the middle of
-- tile x, z is at x * 4 - 2, z * 4 - 2. A crate stands on tile 2, 2 (its middle is 6, 6). Player 1
-- stands at 6, 0, 0 with a pack that holds nothing.
local function newWorld(): (World.World, PlayerState.PlayerState, number)
	local world = World.new(Plot.new(4, 4), at(0, 0, 0), 50)
	local crateId = Crate.place(world, 2, 2)
	local player = World.addPlayer(world, 1)
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	return world, player, crateId
end

do -- a crate as numbers and names
	check(Crate.PLACED_OBJECT_KIND_ID == "crate", 'PLACED_OBJECT_KIND_ID: a crate is of the kind "crate"')
	check(Crate.SLOT_COUNT == 27, "SLOT_COUNT: a crate has 27 slots")
	check(Crate.ITEM_ID_WHEN_BROKEN == "crate", 'ITEM_ID_WHEN_BROKEN: a broken crate leaves the item "crate"')
end

do -- a crate as the script of its kind
	PlacedObjectScripts.register(Crate.PLACED_OBJECT_KIND_ID, Crate)
	local registered = PlacedObjectScripts.find(Crate.PLACED_OBJECT_KIND_ID)
	check(
		registered ~= nil and registered.interact == Crate.interact,
		"interact: is what a registered crate does when a player interacts with one"
	)
	check(
		registered ~= nil and registered.breakPlacedObject == Crate.breakPlacedObject,
		"breakPlacedObject: is what a registered crate does when a player breaks one"
	)
end

do -- place
	local world = World.new(Plot.new(4, 4), at(0, 0, 0), 0)
	local id = Crate.place(world, 2, 3)
	local placed = world.plot.placedObjectsById[id]
	check(
		placed ~= nil and placed.kindId == Crate.PLACED_OBJECT_KIND_ID and placed.tileX == 2 and placed.tileZ == 3,
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

	check(
		string.find(Check.errorFrom(function()
			Crate.place(world, 2, 3)
		end) or "", "nothing can be placed on the tile 2, 3", 1, true) ~= nil,
		"place: fails on a tile that is taken, saying so"
	)
	check(
		string.find(Check.errorFrom(function()
			Crate.place(world, 5, 1)
		end) or "", "nothing can be placed on the tile 5, 1", 1, true) ~= nil,
		"place: fails on a tile the plot does not have, saying so"
	)
	check(placedCount(world) == 2 and world.plot.nextId == second + 1, "place: a placing that fails places nothing")
	check(
		world.placedObjectInventories[second + 1] == nil,
		"place: and gives no inventory to an id that no placed object has"
	)
end

do -- interact
	local world, player, crateId = newWorld()
	local inventory = world.placedObjectInventories[crateId]
	Inventory.addItems(inventory, "fish", 5)
	Crate.interact(world, player, crateId)
	local screen = player.screen :: InventoryScreen.InventoryScreen
	check(
		screen ~= nil and screen.pack == player.pack and screen.otherInventory == inventory,
		"interact: the crate's inventory opens on the player's screen, beside their pack"
	)
	check(World.getOpenedPlacedObjectId(world, player) == crateId, "interact: as the screen of that crate")
	check(screen.otherSlotAcceptsItem == nil, "interact: every slot of the crate takes every item")

	InventoryScreen.pickUpFromSlot(screen, "other", 1)
	Crate.interact(world, player, crateId)
	check(
		player.screen ~= screen and player.screen ~= nil,
		"interact: a screen that was open is closed, and a new one opens"
	)
	check(
		Inventory.countItems(player.pack, "fish") == 5 and Inventory.isEmpty(inventory),
		"interact: and what was carried on the old screen is in the player's pack"
	)

	World.closeScreen(world, player)
	World.setCharacterPosition(world, 1, at(500, 0, 500))
	Crate.interact(world, player, crateId)
	check(
		World.getOpenedPlacedObjectId(world, player) == crateId,
		"interact: it does not ask how far from the crate the player stands"
	)
	World.setCharacterPosition(world, 1, at(6, 0, 0))

	local otherCrateId = Crate.place(world, 3, 3)
	Crate.interact(world, player, otherCrateId)
	check(
		(player.screen :: InventoryScreen.InventoryScreen).otherInventory == world.placedObjectInventories[otherCrateId]
			and World.getOpenedPlacedObjectId(world, player) == otherCrateId,
		"interact: each crate opens its own inventory"
	)

	local second = World.addPlayer(world, 2)
	check(
		string.find(Check.errorFrom(function()
			Crate.interact(world, second, crateId)
		end) or "", "a screen can be opened only for a player who has a character", 1, true)
				~= nil
			and second.screen == nil,
		"interact: fails for a player with no character, saying so"
	)
	World.setCharacterPosition(world, 2, at(6, 0, 0))
	Crate.interact(world, second, otherCrateId)
	check(
		(second.screen :: InventoryScreen.InventoryScreen).otherInventory
			== (player.screen :: InventoryScreen.InventoryScreen).otherInventory,
		"interact: two players may have the same crate open, looking into the same inventory"
	)
end

do -- breakPlacedObject
	local world, breaker, crateId = newWorld()
	local inventory = world.placedObjectInventories[crateId]
	Inventory.setStack(inventory, 3, ItemStack.new("fish", 5))
	Inventory.setStack(inventory, 20, ItemStack.new("log", 4))
	local watcher = World.addPlayer(world, 2)
	World.setCharacterPosition(world, 2, at(10, 0, 10))
	Crate.interact(world, watcher, crateId)
	InventoryScreen.pickUpFromSlot(watcher.screen :: InventoryScreen.InventoryScreen, "other", 3, 2)

	World.setCharacterPosition(world, 1, at(500, 0, 500))
	Crate.breakPlacedObject(world, crateId)
	check(
		world.plot.placedObjectsById[crateId] == nil,
		"breakPlacedObject: the crate is off the plot, though no player stands near it"
	)
	check(Plot.canPlaceObject(world.plot, 2, 2), "breakPlacedObject: and its tile holds nothing")
	check(
		world.placedObjectInventories[crateId] == nil and Inventory.isEmpty(inventory),
		"breakPlacedObject: the crate's inventory is the world's no longer, and holds nothing"
	)
	check(
		watcher.screen == nil and World.getOpenedPlacedObjectId(world, watcher) == nil,
		"breakPlacedObject: a screen that was open on the crate is closed"
	)
	check(
		Inventory.countItems(watcher.pack, "fish") == 2,
		"breakPlacedObject: and what that player carried is in their pack"
	)

	local ground = world.groundItems.itemsById
	check(
		groundItemCount(world) == 3,
		"breakPlacedObject: one ground item for the crate and one for each stack that was in it"
	)
	check(
		is(ground[1].stack, Crate.ITEM_ID_WHEN_BROKEN, 1),
		"breakPlacedObject: one of the item ITEM_ID_WHEN_BROKEN is thrown first"
	)
	check(
		is(ground[2].stack, "fish", 3) and is(ground[3].stack, "log", 4),
		"breakPlacedObject: then each stack that was in the crate, from the lowest slot up"
	)
	local middleHeight = (Plot.TILE_SIZE - GroundItems.ITEM_WIDTH) / 2
	local allFromTheMiddle, allUpwards = true, true
	local ways: { [string]: boolean } = {}
	local wayCount = 0
	for _, groundItem in ground do
		local position, velocity = groundItem.position, groundItem.spawnVelocity
		if Position.getDistance(position, at(6, middleHeight, 6)) > 1e-9 or groundItem.spawnTime ~= 50 then
			allFromTheMiddle = false
		end
		if velocity.y <= 0 or (velocity.x == 0 and velocity.z == 0) then
			allUpwards = false
		end
		local way = string.format("%.3f %.3f", velocity.x, velocity.z)
		wayCount += if ways[way] then 0 else 1
		ways[way] = true
	end
	check(
		allFromTheMiddle,
		"breakPlacedObject: each is thrown from the middle of the crate's tile, at the world's time"
	)
	check(allUpwards, "breakPlacedObject: upwards and outwards")
	check(wayCount == 3, "breakPlacedObject: each a different way")
	check(
		breaker.screen == nil and Inventory.isEmpty(breaker.pack),
		"breakPlacedObject: the player who broke it is given nothing and has no screen opened"
	)

	local emptyCrateId = Crate.place(world, 4, 4)
	World.removeCharacter(world, 1)
	Crate.breakPlacedObject(world, emptyCrateId)
	check(
		groundItemCount(world) == 4 and is(ground[4].stack, Crate.ITEM_ID_WHEN_BROKEN, 1),
		"breakPlacedObject: a crate that holds nothing leaves one of the item ITEM_ID_WHEN_BROKEN and no more"
	)
	check(placedCount(world) == 0, "breakPlacedObject: and no crate is left standing")
end

do -- a placed object of the crate's kind that `place` did not place
	local world, player = newWorld()
	local bareId = Plot.placeObject(world.plot, Crate.PLACED_OBJECT_KIND_ID, 1, 1)
	local message = "the placed object " .. bareId .. " is not a crate that Crate.place placed"
	check(
		Check.raises(message, function()
			Crate.interact(world, player, bareId)
		end),
		"interact: fails for a placed object of the crate's kind that place did not place"
	)
	check(player.screen == nil, "interact: and opens no screen for it")
	check(
		Check.raises(message, function()
			Crate.breakPlacedObject(world, bareId)
		end),
		"breakPlacedObject: fails for a placed object of the crate's kind that place did not place"
	)
	check(
		world.plot.placedObjectsById[bareId] ~= nil and groundItemCount(world) == 0,
		"breakPlacedObject: and leaves it standing, with nothing thrown"
	)
end

Check.finish("Crate")
