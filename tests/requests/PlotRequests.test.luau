--!strict
-- Tests for PlotRequests. Run from the repository root: lune run tests/requests/PlotRequests.test.luau

local Check = require("../Check")
local Crate = require("../../src/shared/placedObjectKinds/Crate")
local FuelRegistry = require("../../src/shared/stations/FuelRegistry")
local Hotbar = require("../../src/shared/inventory/Hotbar")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local PlotRequests = require("../../src/shared/requests/PlotRequests")
local Position = require("../../src/shared/Position")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")
local Station = require("../../src/shared/stations/Station")
local Stove = require("../../src/shared/placedObjectKinds/Stove")
local World = require("../../src/shared/world/World")

local check = Check.that

ItemRegistry.register({ id = "log", stackSize = 16 })
FuelRegistry.register({ item = "log", seconds = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "apple", stackSize = 16 })
ItemRegistry.register({ id = "cooked_fish", stackSize = 8 })
ItemRegistry.register({ id = "crate", stackSize = 8 })
ItemRegistry.register({ id = "stove", stackSize = 1 })
RecipeRegistry.register({ station = "stove", input = "fish", output = "cooked_fish", seconds = 8 })

local itemIds = { "log", "fish", "apple", "crate", "stove" }
local at = Position.new

-- The requests are called with whatever a player's machine might send, so they are called through
-- this, which does not check their arguments.
local requests = PlotRequests :: any
local function send(name: string, world: World.World, state: PlayerState.PlayerState, ...: any)
	(requests[name] :: (...any) -> ())(world, state, ...)
end

-- Something that is not the id of a placed object.
local badIds: { any } = { 0, -1, 99, 1.5, 0 / 0, math.huge, -math.huge, "1", true, {} }

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

-- How many of one item lie on the ground, in all.
local function onGround(world: World.World, itemId: string): number
	local count = 0
	for _, groundItem in world.groundItems.itemsById do
		if groundItem.stack.itemId == itemId then
			count += groundItem.stack.count
		end
	end
	return count
end

-- The inventory that a placed object was given, or the inventory of the station it was made. Nil
-- if it was given neither.
local function findInside(world: World.World, placedObjectId: number): Inventory.Inventory?
	local station = world.stations[placedObjectId]
	return if station ~= nil then station.inventory else world.placedObjectInventories[placedObjectId]
end

-- The inventory inside a placed object that is known to have one.
local function insideOf(world: World.World, placedObjectId: number): Inventory.Inventory
	return findInside(world, placedObjectId) :: Inventory.Inventory
end

-- How many of one item the world holds in all: in packs, carried, standing on the plot, inside what
-- stands on the plot, and on the ground. A placed crate counts as one crate, and a placed stove as
-- one stove.
local function inWorld(world: World.World, itemId: string): number
	local count = onGround(world, itemId)
	for _, state in world.players do
		count += Inventory.countItems(state.pack, itemId)
		local screen = state.screen
		if screen ~= nil and screen.carriedStack ~= nil and screen.carriedStack.itemId == itemId then
			count += screen.carriedStack.count
		end
	end
	for placedObjectId, placedObject in world.plot.placedObjectsById do
		local inside = findInside(world, placedObjectId)
		count += if placedObject.kindId == itemId then 1 else 0
		count += if inside ~= nil then Inventory.countItems(inside, itemId) else 0
	end
	return count
end

-- A world at time 100 with a plot of 6 by 6 tiles whose corner is at the origin, so that the middle of
-- tile x, z is at x * 4 - 2, z * 4 - 2. A crate holding 5 fish stands on tile 2, 2 (its middle is 6, 6),
-- and a stove on tile 5, 5 (its middle is 18, 18). Player 1 stands at 6, 0, 0 with 12 logs, 3 crates
-- and a stove in their first three hotbar slots.
local function newWorld(): (World.World, PlayerState.PlayerState, number, number)
	local world = World.new(Plot.new(6, 6), at(0, 0, 0), 100)
	local crateId = Crate.place(world, 2, 2)
	Inventory.addItems(insideOf(world, crateId), "fish", 5)
	local stoveId = Stove.place(world, 5, 5)
	local state = World.addPlayer(world, 1)
	Inventory.setStack(state.pack, 1, ItemStack.new("log", 12))
	Inventory.setStack(state.pack, 2, ItemStack.new("crate", 3))
	Inventory.setStack(state.pack, 3, ItemStack.new("stove", 1))
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	return world, state, crateId, stoveId
end

do -- interactWithTile
	local world, state = newWorld()
	Hotbar.selectSlot(state.hotbar, 2)
	send("interactWithTile", world, state, 1, 1)
	local placedObjectId = world.plot.nextId - 1
	local placed = world.plot.placedObjectsById[placedObjectId]
	check(
		placed ~= nil and placed.kindId == "crate" and placed.tileX == 1 and placed.tileZ == 1,
		"interactWithTile: an object of the kind that the item in hand places stands on the tile"
	)
	check(
		is(Inventory.getStack(state.pack, 2), "crate", 2),
		"interactWithTile: and one of the item has left the hand, and no more"
	)
	check(inWorld(world, "crate") == 4, "interactWithTile: and no crate was made or lost")
	local inside = findInside(world, placedObjectId)
	check(
		inside ~= nil and Inventory.isEmpty(inside) and inside.slotCount == Crate.SLOT_COUNT,
		"interactWithTile: the crate was placed as Crate.place does, with an inventory that holds nothing"
	)

	Hotbar.selectSlot(state.hotbar, 3)
	send("interactWithTile", world, state, 1, 1)
	check(is(Inventory.getStack(state.pack, 3), "stove", 1), "interactWithTile: not on a tile that something stands on")
	send("interactWithTile", world, state, 2, 1)
	check(is(Inventory.getStack(state.pack, 3), "stove", 1), "interactWithTile: not on the tile the player stands on")
	for _, bad in { 0, 7, -1, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		send("interactWithTile", world, state, bad, 1)
		send("interactWithTile", world, state, 1, bad)
		send("interactWithTile", world, state, 3, bad)
	end
	send("interactWithTile", world, state, 3)
	send("interactWithTile", world, state)
	check(
		is(Inventory.getStack(state.pack, 3), "stove", 1) and world.plot.nextId == placedObjectId + 1,
		"interactWithTile: not on a tile that is not on the plot, or with nonsense"
	)

	Hotbar.selectSlot(state.hotbar, 1)
	send("interactWithTile", world, state, 3, 1)
	check(
		is(Inventory.getStack(state.pack, 1), "log", 12) and world.plot.nextId == placedObjectId + 1,
		"interactWithTile: nothing is placed by an item that places nothing"
	)
	Hotbar.selectSlot(state.hotbar, 9)
	send("interactWithTile", world, state, 3, 1)
	check(world.plot.nextId == placedObjectId + 1, "interactWithTile: not with an empty hand")

	Hotbar.selectSlot(state.hotbar, 3)
	PlayerState.openScreen(state)
	send("interactWithTile", world, state, 3, 1)
	check(
		is(Inventory.getStack(state.pack, 3), "stove", 1) and world.plot.nextId == placedObjectId + 1,
		"interactWithTile: not while the inventory screen is open"
	)
	PlayerState.closeScreen(state)

	-- The middle of tile 6, 1 is at 22, 2. Standing at 6, 2 it is exactly 16 studs away.
	World.setCharacterPosition(world, 1, at(6, 0, 2))
	send("interactWithTile", world, state, 6, 1)
	check(Inventory.getStack(state.pack, 3) == nil, "interactWithTile: a tile exactly at reach can be placed on")
	local farId = world.plot.nextId - 1
	check(world.plot.placedObjectsById[farId].tileX == 6, "interactWithTile: and the object stands there")
	check(
		world.stations[farId] ~= nil and world.stations[farId].kindId == "stove",
		"interactWithTile: the stove was placed as Stove.place does, as a station"
	)
end

do -- reach, and standing on a tile
	local world, state = newWorld()
	Hotbar.selectSlot(state.hotbar, 3)
	World.setCharacterPosition(world, 1, at(5.99, 0, 2))
	send("interactWithTile", world, state, 6, 1)
	check(is(Inventory.getStack(state.pack, 3), "stove", 1), "interactWithTile: not a tile just beyond reach")
	World.removeCharacter(world, 1)
	send("interactWithTile", world, state, 3, 1)
	check(is(Inventory.getStack(state.pack, 3), "stove", 1), "interactWithTile: not by a player with no character")

	-- The middle of tile 3, 1 is at 10, 2. A player 3 studs from it stands on the tile; one a little further does not.
	World.setCharacterPosition(world, 1, at(2, 0, 2))
	World.addPlayer(world, 2)
	World.setCharacterPosition(world, 2, at(13, 0, 2))
	send("interactWithTile", world, state, 3, 1)
	check(is(Inventory.getStack(state.pack, 3), "stove", 1), "interactWithTile: not on a tile another player stands on")
	World.setCharacterPosition(world, 2, at(13.01, 0, 2))
	send("interactWithTile", world, state, 3, 1)
	check(Inventory.getStack(state.pack, 3) == nil, "interactWithTile: on the tile once that player has stepped off it")
	World.removeCharacter(world, 2)
	Hotbar.selectSlot(state.hotbar, 2)
	send("interactWithTile", world, state, 4, 1)
	check(
		is(Inventory.getStack(state.pack, 2), "crate", 2),
		"interactWithTile: a player with no character stands on no tile"
	)
end

do -- interactWithPlacedObject
	local world, state, crateId, stoveId = newWorld()
	send("interactWithPlacedObject", world, state, crateId)
	local screen = state.screen
	check(
		screen ~= nil and screen.otherInventory == insideOf(world, crateId) and screen.pack == state.pack,
		"interactWithPlacedObject: opens the crate's inventory on the player's screen, beside their pack"
	)
	check(
		World.getOpenedPlacedObjectId(world, state) == crateId,
		"interactWithPlacedObject: and the player has that crate open"
	)
	check(
		screen ~= nil and screen.otherSlotAcceptsItem == nil,
		"interactWithPlacedObject: every slot of a crate accepts every item"
	)

	InventoryScreen.pickUpFromSlot(state.screen :: InventoryScreen.InventoryScreen, "other", 1)
	send("interactWithPlacedObject", world, state, crateId)
	check(
		state.screen ~= screen and state.screen ~= nil,
		"interactWithPlacedObject: using it again opens a screen afresh"
	)
	check(
		Inventory.countItems(state.pack, "fish") == 5,
		"interactWithPlacedObject: after putting what was carried back in the pack"
	)

	-- From 18, 10 both the crate and the stove are in reach.
	World.setCharacterPosition(world, 1, at(18, 0, 10))
	send("interactWithPlacedObject", world, state, stoveId)
	local stoveScreen = state.screen :: InventoryScreen.InventoryScreen
	check(
		stoveScreen.otherInventory == insideOf(world, stoveId)
			and World.getOpenedPlacedObjectId(world, state) == stoveId,
		"interactWithPlacedObject: using another placed object opens that one in place of the first"
	)
	check(
		stoveScreen.otherSlotAcceptsItem ~= nil
			and stoveScreen.otherSlotAcceptsItem(Station.INPUT_SLOT, "fish")
			and not stoveScreen.otherSlotAcceptsItem(Station.INPUT_SLOT, "log")
			and stoveScreen.otherSlotAcceptsItem(Station.FUEL_SLOT, "log")
			and not stoveScreen.otherSlotAcceptsItem(Station.OUTPUT_SLOT, "cooked_fish"),
		"interactWithPlacedObject: a stove's slots take only what a stove works on or burns"
	)
	for _, bad in badIds do
		send("interactWithPlacedObject", world, state, bad)
	end
	send("interactWithPlacedObject", world, state)
	check(
		state.screen == stoveScreen and World.getOpenedPlacedObjectId(world, state) == stoveId,
		"interactWithPlacedObject: ignored for an id that is not a placed object, and what was open stays open"
	)
	World.closeScreen(world, state)

	World.setCharacterPosition(world, 1, at(6, 0, 22.01))
	send("interactWithPlacedObject", world, state, crateId)
	check(state.screen == nil, "interactWithPlacedObject: not from beyond reach")
	World.setCharacterPosition(world, 1, at(6, 0, 22))
	send("interactWithPlacedObject", world, state, crateId)
	check(state.screen ~= nil, "interactWithPlacedObject: from exactly at reach")
	World.closeScreen(world, state)
	World.removeCharacter(world, 1)
	send("interactWithPlacedObject", world, state, crateId)
	check(state.screen == nil, "interactWithPlacedObject: not by a player with no character")

	local twoWorld, first, twoCrate = newWorld()
	local second = World.addPlayer(twoWorld, 2)
	World.setCharacterPosition(twoWorld, 2, at(10, 0, 10))
	send("interactWithPlacedObject", twoWorld, first, twoCrate)
	send("interactWithPlacedObject", twoWorld, second, twoCrate)
	check(
		(first.screen :: InventoryScreen.InventoryScreen).otherInventory
			== (second.screen :: InventoryScreen.InventoryScreen).otherInventory,
		"interactWithPlacedObject: two players may have the same crate open"
	)
end

do -- breakPlacedObject
	local world, state, crateId, stoveId = newWorld()
	local other = World.addPlayer(world, 2)
	World.setCharacterPosition(world, 2, at(10, 0, 10))
	send("interactWithPlacedObject", world, other, crateId)
	InventoryScreen.pickUpFromSlot(other.screen :: InventoryScreen.InventoryScreen, "other", 1, 3)
	check(
		is((other.screen :: InventoryScreen.InventoryScreen).carriedStack, "fish", 3),
		"a second player looks into the crate and picks up three fish"
	)

	World.setCharacterPosition(world, 1, at(6, 0, 22.01))
	send("breakPlacedObject", world, state, crateId)
	check(world.plot.placedObjectsById[crateId] ~= nil, "breakPlacedObject: not from beyond reach")
	World.removeCharacter(world, 1)
	send("breakPlacedObject", world, state, crateId)
	check(world.plot.placedObjectsById[crateId] ~= nil, "breakPlacedObject: not by a player with no character")
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	for _, bad in badIds do
		send("breakPlacedObject", world, state, bad)
	end
	send("breakPlacedObject", world, state)
	check(
		world.plot.placedObjectsById[crateId] ~= nil and world.plot.placedObjectsById[stoveId] ~= nil,
		"breakPlacedObject: ignored for an id that is not a placed object"
	)

	send("breakPlacedObject", world, state, crateId)
	check(world.plot.placedObjectsById[crateId] == nil, "breakPlacedObject: the crate is off the plot")
	check(
		other.screen == nil and World.getOpenedPlacedObjectId(world, other) == nil,
		"breakPlacedObject: the player who was looking into it is not any more"
	)
	check(Inventory.countItems(other.pack, "fish") == 3, "breakPlacedObject: what they carried is in their pack")
	check(onGround(world, "crate") == 1, "breakPlacedObject: a crate lies on the ground as an item")
	check(onGround(world, "fish") == 2, "breakPlacedObject: what was left in it is spilled on the ground")
	check(inWorld(world, "fish") == 5 and inWorld(world, "crate") == 4, "breakPlacedObject: nothing was made or lost")
	local allNear = true
	for _, groundItem in world.groundItems.itemsById do
		if Position.getGroundDistance(groundItem.position, at(6, 0, 6)) > 2 or groundItem.spawnTime ~= 100 then
			allNear = false
		end
	end
	check(allNear, "breakPlacedObject: it all lies on the crate's tile, dropped at the world's time")
	check(Plot.canPlaceObject(world.plot, 2, 2), "breakPlacedObject: and its tile holds nothing")

	World.setCharacterPosition(world, 1, at(18, 0, 10))
	send("breakPlacedObject", world, state, stoveId)
	check(
		world.plot.placedObjectsById[stoveId] == nil and onGround(world, "stove") == 1,
		"breakPlacedObject: a stove that holds nothing just leaves a stove on the ground"
	)
	check(world.stations[stoveId] == nil, "breakPlacedObject: and is a station no longer")
	check(state.screen == nil, "breakPlacedObject: the player who hit it has no screen open")

	local stoveWorld, withStove, _, fullStoveId = newWorld()
	World.setCharacterPosition(stoveWorld, 1, at(18, 0, 10))
	Inventory.setStack(insideOf(stoveWorld, fullStoveId), Station.INPUT_SLOT, ItemStack.new("fish", 3))
	Inventory.setStack(insideOf(stoveWorld, fullStoveId), Station.FUEL_SLOT, ItemStack.new("log", 4))
	send("breakPlacedObject", stoveWorld, withStove, fullStoveId)
	check(
		onGround(stoveWorld, "stove") == 1 and onGround(stoveWorld, "fish") == 3 and onGround(stoveWorld, "log") == 4,
		"breakPlacedObject: what was in a stove's slots is spilled on the ground too"
	)

	local ringWorld = World.new(Plot.new(3, 3), at(0, 0, 0), 0)
	local ringCrate = Crate.place(ringWorld, 2, 2)
	local inRingCrate = insideOf(ringWorld, ringCrate)
	Inventory.addItems(inRingCrate, "fish", 2)
	Inventory.addItems(inRingCrate, "apple", 3)
	Inventory.addItems(inRingCrate, "log", 4)
	local ringState = World.addPlayer(ringWorld, 1)
	World.setCharacterPosition(ringWorld, 1, at(0, 0, 0))
	send("breakPlacedObject", ringWorld, ringState, ringCrate)
	local ways: { [string]: boolean } = {}
	local wayCount, fromMiddle = 0, true
	for _, groundItem in ringWorld.groundItems.itemsById do
		local key = string.format("%.3f %.3f", groundItem.spawnVelocity.x, groundItem.spawnVelocity.z)
		if not ways[key] then
			ways[key] = true
			wayCount += 1
		end
		if Position.getGroundDistance(groundItem.position, at(6, 0, 6)) > 0 or groundItem.spawnVelocity.y <= 0 then
			fromMiddle = false
		end
	end
	check(
		wayCount == 4,
		"breakPlacedObject: the crate and each of the three stacks that were in it are thrown a way of their own"
	)
	check(fromMiddle, "breakPlacedObject: each upwards, out of the middle of the tile")
end

do -- whatever a player's machine sends, nothing raises an error and no item is made or lost
	local seed = 4121
	local function random(limit: number): number
		seed = (seed * 16807) % 2147483647
		return math.floor(seed / 8) % limit + 1
	end
	local junk: { any } = {
		-1,
		0,
		0.5,
		1e300,
		-1e300,
		0 / 0,
		math.huge,
		-math.huge,
		"",
		"1",
		true,
		false,
		{},
		{ 1 },
	}
	-- One thing a request might be sent with: mostly a tile or an id a real machine might send, sometimes junk or nothing.
	local function argument(): any
		local kind = random(10)
		if kind <= 4 then
			return random(7)
		elseif kind <= 6 then
			return random(14)
		elseif kind == 7 then
			return nil
		end
		return junk[random(#junk)]
	end
	local names: { string } = {}
	for name in requests do
		table.insert(names, name)
	end
	table.sort(names)

	local errors, firstError = 0, ""
	local allConserved, placedOnTheGround = true, 0
	for _ = 1, 40 do
		local world, firstPlayer = newWorld()
		local secondPlayer = World.addPlayer(world, 2)
		World.setCharacterPosition(world, 2, at(10, 0, 10))
		local players = { firstPlayer, secondPlayer }
		for _, player in players do
			for slot = 4, 12 do
				local itemId = itemIds[random(#itemIds)]
				Inventory.setStack(player.pack, slot, ItemStack.new(itemId, random(ItemRegistry.get(itemId).stackSize)))
			end
		end
		local total: { [string]: number } = {}
		for _, itemId in itemIds do
			total[itemId] = inWorld(world, itemId)
		end
		local now = 100
		for _ = 1, 300 do
			local playerId = random(2)
			local player = players[playerId]
			-- Players walk about, and now and then lose their character.
			if random(4) == 1 then
				if random(8) == 1 then
					World.removeCharacter(world, playerId)
				else
					World.setCharacterPosition(world, playerId, at(random(30), 0, random(30)))
				end
			end
			-- Players change what is in hand, and open a screen, as other requests would.
			Hotbar.selectSlot(player.hotbar, random(9))
			if random(10) == 1 and PlayerState.canOpenScreen(player) then
				PlayerState.openScreen(player)
			end
			local name = names[random(#names)]
			local ok, result = pcall(send, name, world, player, argument(), argument(), argument())
			if not ok then
				errors += 1
				firstError = if firstError == "" then name .. ": " .. tostring(result) else firstError
			end
			now += 0.5
			World.advanceTo(world, now)
			for _, itemId in itemIds do
				if inWorld(world, itemId) ~= total[itemId] then
					allConserved = false
				end
			end
		end
		placedOnTheGround += onGround(world, "crate") + onGround(world, "stove")
	end
	check(errors == 0, "random run: none of 12,000 requests raises an error (first: " .. firstError .. ")")
	check(
		allConserved,
		"random run: after every request every item is in a pack, carried, standing on the plot, inside it, or on the ground"
	)
	check(placedOnTheGround > 0, "random run: and some things were taken off the plot, so that was tried")
end

Check.finish("PlotRequests")
