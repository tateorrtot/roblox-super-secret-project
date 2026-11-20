--!strict
-- Tests for PlotRequests. Run from the repository root: lune run tests/requests/PlotRequests.test.luau

local Check = require("../Check")
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
local World = require("../../src/shared/world/World")

local check = Check.that

ItemRegistry.register({ id = "log", stackSize = 16, burnSeconds = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "apple", stackSize = 16 })
ItemRegistry.register({ id = "cooked_fish", stackSize = 8 })
ItemRegistry.register({ id = "post", stackSize = 8, placeable = true })
ItemRegistry.register({ id = "crate", stackSize = 1, placeable = true, slotCount = 27 })
ItemRegistry.register({ id = "oven", stackSize = 1, placeable = true, slotCount = 3 })
RecipeRegistry.register({ station = "oven", input = "fish", output = "cooked_fish", seconds = 8 })

local itemIds = { "log", "fish", "apple", "post", "crate", "oven" }
local at = Position.new

-- The requests are called with whatever a player's machine might send, so they are called through
-- this, which does not check their arguments.
local requests = PlotRequests :: any
local function send(name: string, world: World.World, state: PlayerState.PlayerState, ...: any)
	(requests[name] :: (...any) -> ())(world, state, ...)
end

-- Something that is not the id of a placed item.
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

-- How many of one item the world holds in all: in packs, carried, standing on the plot, inside what
-- stands on the plot, and on the ground.
local function inWorld(world: World.World, itemId: string): number
	local count = onGround(world, itemId)
	for _, state in world.players do
		count += Inventory.countItems(state.pack, itemId)
		local screen = state.screen
		if screen ~= nil and screen.carriedStack ~= nil and screen.carriedStack.itemId == itemId then
			count += screen.carriedStack.count
		end
	end
	for _, placedItem in world.plot.placedItemsById do
		if placedItem.itemId == itemId then
			count += 1
		end
		if placedItem.inventory ~= nil then
			count += Inventory.countItems(placedItem.inventory, itemId)
		end
	end
	return count
end

-- A world at time 100 with a plot of 6 by 6 tiles whose corner is at the origin, so that the middle of
-- tile x, z is at x * 4 - 2, z * 4 - 2. A crate holding 5 fish stands on tile 2, 2 (its middle is 6, 6),
-- and a post on tile 5, 5 (its middle is 18, 18). Player 1 stands at 6, 0, 0 with 12 logs, a crate and
-- an oven in their first three hotbar slots, and drops land 6 studs further along x.
local function newWorld(): (World.World, PlayerState.PlayerState, number, number)
	local plot = Plot.new(6, 6)
	local crateId = Plot.placeItem(plot, "crate", 2, 2) :: number
	Inventory.addItems(plot.placedItemsById[crateId].inventory :: Inventory.Inventory, "fish", 5)
	local postId = Plot.placeItem(plot, "post", 5, 5) :: number
	local world = World.new(plot, at(0, 0, 0), 100)
	local state = World.addPlayer(world, 1)
	Inventory.setStack(state.pack, 1, ItemStack.new("log", 12))
	Inventory.setStack(state.pack, 2, ItemStack.new("crate", 1))
	Inventory.setStack(state.pack, 3, ItemStack.new("oven", 1))
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	return world, state, crateId, postId
end

do -- placeSelectedItem
	local world, state = newWorld()
	Hotbar.selectSlot(state.hotbar, 2)
	send("placeSelectedItem", world, state, 1, 1)
	local placedItemId = world.plot.nextId - 1
	local placed = world.plot.placedItemsById[placedItemId]
	check(
		placed ~= nil and placed.itemId == "crate" and placed.x == 1 and placed.z == 1,
		"placeSelectedItem: the item in hand stands on the tile"
	)
	check(Inventory.getStack(state.pack, 2) == nil, "placeSelectedItem: and has left the hand")
	check(inWorld(world, "crate") == 2, "placeSelectedItem: and no crate was made or lost")
	check(
		placed.inventory ~= nil and Inventory.isEmpty(placed.inventory),
		"placeSelectedItem: a crate placed has an inventory that holds nothing"
	)

	Hotbar.selectSlot(state.hotbar, 3)
	send("placeSelectedItem", world, state, 1, 1)
	check(is(Inventory.getStack(state.pack, 3), "oven", 1), "placeSelectedItem: not on a tile that something stands on")
	send("placeSelectedItem", world, state, 2, 1)
	check(is(Inventory.getStack(state.pack, 3), "oven", 1), "placeSelectedItem: not on the tile the player stands on")
	for _, bad in { 0, 7, -1, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		send("placeSelectedItem", world, state, bad, 1)
		send("placeSelectedItem", world, state, 1, bad)
		send("placeSelectedItem", world, state, 3, bad)
	end
	send("placeSelectedItem", world, state, 3)
	send("placeSelectedItem", world, state)
	check(
		is(Inventory.getStack(state.pack, 3), "oven", 1) and world.plot.nextId == placedItemId + 1,
		"placeSelectedItem: not on a tile that is not on the plot, or with nonsense"
	)

	Hotbar.selectSlot(state.hotbar, 1)
	send("placeSelectedItem", world, state, 3, 1)
	check(
		is(Inventory.getStack(state.pack, 1), "log", 12) and world.plot.nextId == placedItemId + 1,
		"placeSelectedItem: not an item that cannot be placed"
	)
	Hotbar.selectSlot(state.hotbar, 9)
	send("placeSelectedItem", world, state, 3, 1)
	check(world.plot.nextId == placedItemId + 1, "placeSelectedItem: not with an empty hand")

	Hotbar.selectSlot(state.hotbar, 3)
	PlayerState.openPackScreen(state)
	send("placeSelectedItem", world, state, 3, 1)
	check(
		is(Inventory.getStack(state.pack, 3), "oven", 1) and world.plot.nextId == placedItemId + 1,
		"placeSelectedItem: not while the inventory screen is open"
	)
	PlayerState.closeScreen(state)

	Inventory.setStack(state.pack, 5, ItemStack.new("post", 3))
	Hotbar.selectSlot(state.hotbar, 5)
	send("placeSelectedItem", world, state, 4, 1)
	check(is(Inventory.getStack(state.pack, 5), "post", 2), "placeSelectedItem: only one of a stack in hand is placed")
	check(inWorld(world, "post") == 4, "placeSelectedItem: and the rest of the stack is still in hand")
	local postId = world.plot.nextId - 1
	check(
		world.plot.placedItemsById[postId].itemId == "post" and world.plot.placedItemsById[postId].inventory == nil,
		"placeSelectedItem: an item with no slots is placed with no inventory"
	)

	-- The middle of tile 6, 1 is at 22, 2. Standing at 6, 2 it is exactly 16 studs away.
	Hotbar.selectSlot(state.hotbar, 3)
	World.setCharacterPosition(world, 1, at(6, 0, 2))
	send("placeSelectedItem", world, state, 6, 1)
	check(Inventory.getStack(state.pack, 3) == nil, "placeSelectedItem: a tile exactly at reach can be placed on")
	local farId = world.plot.nextId - 1
	check(world.plot.placedItemsById[farId].x == 6, "placeSelectedItem: and the item stands there")
	check(
		world.stations[farId] ~= nil and world.stations[farId].itemId == "oven",
		"placeSelectedItem: an oven placed is a station"
	)
end

do -- reach, and standing on a tile
	local world, state = newWorld()
	Hotbar.selectSlot(state.hotbar, 3)
	World.setCharacterPosition(world, 1, at(5.99, 0, 2))
	send("placeSelectedItem", world, state, 6, 1)
	check(is(Inventory.getStack(state.pack, 3), "oven", 1), "placeSelectedItem: not a tile just beyond reach")
	World.removeCharacter(world, 1)
	send("placeSelectedItem", world, state, 3, 1)
	check(is(Inventory.getStack(state.pack, 3), "oven", 1), "placeSelectedItem: not by a player with no character")

	-- The middle of tile 3, 1 is at 10, 2. A player 3 studs from it stands on the tile; one a little further does not.
	World.setCharacterPosition(world, 1, at(2, 0, 2))
	World.addPlayer(world, 2)
	World.setCharacterPosition(world, 2, at(13, 0, 2))
	send("placeSelectedItem", world, state, 3, 1)
	check(is(Inventory.getStack(state.pack, 3), "oven", 1), "placeSelectedItem: not on a tile another player stands on")
	World.setCharacterPosition(world, 2, at(13.01, 0, 2))
	send("placeSelectedItem", world, state, 3, 1)
	check(
		Inventory.getStack(state.pack, 3) == nil,
		"placeSelectedItem: on the tile once that player has stepped off it"
	)
	World.removeCharacter(world, 2)
	Hotbar.selectSlot(state.hotbar, 2)
	send("placeSelectedItem", world, state, 4, 1)
	check(Inventory.getStack(state.pack, 2) == nil, "placeSelectedItem: a player with no character stands on no tile")
end

do -- usePlacedItem
	local world, state, crateId, postId = newWorld()
	send("usePlacedItem", world, state, crateId)
	local screen = state.screen
	check(
		screen ~= nil
			and screen.otherInventory == world.plot.placedItemsById[crateId].inventory
			and screen.pack == state.pack,
		"usePlacedItem: opens the crate's inventory on the player's screen, beside their pack"
	)
	check(state.openedPlacedItemId == crateId, "usePlacedItem: and the player has that crate open")
	check(
		screen ~= nil and screen.otherSlotAcceptsItem == nil,
		"usePlacedItem: every slot of a crate accepts every item"
	)

	InventoryScreen.pickUpFromSlot(state.screen :: InventoryScreen.InventoryScreen, "other", 1)
	send("usePlacedItem", world, state, crateId)
	check(state.screen ~= screen and state.screen ~= nil, "usePlacedItem: using it again opens a screen afresh")
	check(
		Inventory.countItems(state.pack, "fish") == 5,
		"usePlacedItem: after putting what was carried back in the pack"
	)

	-- From 18, 10 both the crate and the post are in reach.
	World.setCharacterPosition(world, 1, at(18, 0, 10))
	send("usePlacedItem", world, state, postId)
	check(
		(state.screen :: InventoryScreen.InventoryScreen).otherInventory
				== world.plot.placedItemsById[crateId].inventory
			and state.openedPlacedItemId == crateId,
		"usePlacedItem: ignored for a placed item that holds nothing, even in reach, and what was open stays open"
	)
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	for _, bad in badIds do
		send("usePlacedItem", world, state, bad)
	end
	send("usePlacedItem", world, state)
	check(state.openedPlacedItemId == crateId, "usePlacedItem: ignored for an id that is not a placed item")
	World.closeScreen(world, state)

	World.setCharacterPosition(world, 1, at(6, 0, 22.01))
	send("usePlacedItem", world, state, crateId)
	check(state.screen == nil, "usePlacedItem: not from beyond reach")
	World.setCharacterPosition(world, 1, at(6, 0, 22))
	send("usePlacedItem", world, state, crateId)
	check(state.screen ~= nil, "usePlacedItem: from exactly at reach")
	World.closeScreen(world, state)
	World.removeCharacter(world, 1)
	send("usePlacedItem", world, state, crateId)
	check(state.screen == nil, "usePlacedItem: not by a player with no character")

	local ovenWorld, withOven = newWorld()
	local ovenId = Plot.placeItem(ovenWorld.plot, "oven", 3, 1) :: number
	send("usePlacedItem", ovenWorld, withOven, ovenId)
	local ovenScreen = withOven.screen
	check(
		ovenScreen ~= nil and ovenScreen.otherInventory == ovenWorld.plot.placedItemsById[ovenId].inventory,
		"usePlacedItem: opens an oven's slots beside the pack"
	)
	check(
		ovenScreen ~= nil and ovenScreen.otherSlotAcceptsItem ~= nil and not ovenScreen.otherSlotAcceptsItem(1, "log"),
		"usePlacedItem: and the slots take only what an oven works on or burns"
	)

	local twoWorld, first, twoCrate = newWorld()
	local second = World.addPlayer(twoWorld, 2)
	World.setCharacterPosition(twoWorld, 2, at(10, 0, 10))
	send("usePlacedItem", twoWorld, first, twoCrate)
	local secondCall = requests.usePlacedItem :: (...any) -> ()
	secondCall(twoWorld, second, twoCrate)
	check(
		(first.screen :: InventoryScreen.InventoryScreen).otherInventory
			== (second.screen :: InventoryScreen.InventoryScreen).otherInventory,
		"usePlacedItem: two players may have the same crate open"
	)
end

do -- hitPlacedItem
	local world, state, crateId, postId = newWorld()
	local other = World.addPlayer(world, 2)
	World.setCharacterPosition(world, 2, at(10, 0, 10))
	local otherCall = requests.usePlacedItem :: (...any) -> ()
	otherCall(world, other, crateId)
	InventoryScreen.pickUpFromSlot(other.screen :: InventoryScreen.InventoryScreen, "other", 1, 3)
	check(
		is((other.screen :: InventoryScreen.InventoryScreen).carriedStack, "fish", 3),
		"a second player looks into the crate and picks up three fish"
	)

	World.setCharacterPosition(world, 1, at(6, 0, 22.01))
	send("hitPlacedItem", world, state, crateId)
	check(world.plot.placedItemsById[crateId] ~= nil, "hitPlacedItem: not from beyond reach")
	World.removeCharacter(world, 1)
	send("hitPlacedItem", world, state, crateId)
	check(world.plot.placedItemsById[crateId] ~= nil, "hitPlacedItem: not by a player with no character")
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	for _, bad in badIds do
		send("hitPlacedItem", world, state, bad)
	end
	send("hitPlacedItem", world, state)
	check(
		world.plot.placedItemsById[crateId] ~= nil and world.plot.placedItemsById[postId] ~= nil,
		"hitPlacedItem: ignored for an id that is not a placed item"
	)

	send("hitPlacedItem", world, state, crateId)
	check(world.plot.placedItemsById[crateId] == nil, "hitPlacedItem: the crate is off the plot")
	check(
		other.screen == nil and other.openedPlacedItemId == nil,
		"hitPlacedItem: the player who was looking into it is not any more"
	)
	check(Inventory.countItems(other.pack, "fish") == 3, "hitPlacedItem: what they carried is in their pack")
	check(onGround(world, "crate") == 1, "hitPlacedItem: the crate lies on the ground as an item")
	check(onGround(world, "fish") == 2, "hitPlacedItem: what was left in it is spilled on the ground")
	check(inWorld(world, "fish") == 5 and inWorld(world, "crate") == 2, "hitPlacedItem: nothing was made or lost")
	local allNear = true
	for _, groundItem in world.groundItems.itemsById do
		if Position.getGroundDistance(groundItem.position, at(6, 0, 6)) > 2 or groundItem.spawnTime ~= 100 then
			allNear = false
		end
	end
	check(allNear, "hitPlacedItem: it all lies on the crate's tile, dropped at the world's time")
	check(Plot.canPlaceItem(world.plot, "post", 2, 2), "hitPlacedItem: and its tile holds nothing")

	World.setCharacterPosition(world, 1, at(18, 0, 10))
	send("hitPlacedItem", world, state, postId)
	check(
		world.plot.placedItemsById[postId] == nil and onGround(world, "post") == 1,
		"hitPlacedItem: a placed item that holds nothing just becomes an item"
	)
	check(state.screen == nil, "hitPlacedItem: the player who hit it has no screen open")

	local ovenWorld, withOven = newWorld()
	local ovenId = Plot.placeItem(ovenWorld.plot, "oven", 3, 1) :: number
	send("hitPlacedItem", ovenWorld, withOven, ovenId)
	check(
		ovenWorld.plot.placedItemsById[ovenId] == nil
			and ovenWorld.stations[ovenId] == nil
			and onGround(ovenWorld, "oven") == 1,
		"hitPlacedItem: an oven is taken off the plot and stops being a station"
	)

	local ring = Plot.new(3, 3)
	local ringCrate = Plot.placeItem(ring, "crate", 2, 2) :: number
	local inRingCrate = ring.placedItemsById[ringCrate].inventory :: Inventory.Inventory
	Inventory.addItems(inRingCrate, "fish", 2)
	Inventory.addItems(inRingCrate, "apple", 3)
	Inventory.addItems(inRingCrate, "log", 4)
	local ringWorld = World.new(ring, at(0, 0, 0), 0)
	local ringState = World.addPlayer(ringWorld, 1)
	World.setCharacterPosition(ringWorld, 1, at(0, 0, 0))
	send("hitPlacedItem", ringWorld, ringState, ringCrate)
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
		"hitPlacedItem: the crate and each of the three stacks that were in it are thrown a way of their own"
	)
	check(fromMiddle, "hitPlacedItem: each upwards, out of the middle of the tile")
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
				PlayerState.openPackScreen(player)
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
		placedOnTheGround += onGround(world, "crate") + onGround(world, "oven") + onGround(world, "post")
	end
	check(errors == 0, "random run: none of 12,000 requests raises an error (first: " .. firstError .. ")")
	check(
		allConserved,
		"random run: after every request every item is in a pack, carried, standing on the plot, inside it, or on the ground"
	)
	check(placedOnTheGround > 0, "random run: and some things were taken off the plot, so that was tried")
end

Check.finish("PlotRequests")
