--!strict
-- Tests for Requests and Messages. Run from the repository root: lune run tests/requests/Requests.test.luau
-- The items and the kind of placed object here are made up for the tests. The game's own things are
-- sent every request there is in tests/content/Content.test.luau.

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryRequests = require("../../src/shared/requests/InventoryRequests")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local Messages = require("../../src/shared/requests/Messages")
local PlacedObjectScripts = require("../../src/shared/requests/PlacedObjectScripts")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local PlotRequests = require("../../src/shared/requests/PlotRequests")
local Position = require("../../src/shared/Position")
local Requests = require("../../src/shared/requests/Requests")
local World = require("../../src/shared/world/World")

local check = Check.that
local carryOut = Requests.carryOut :: (world: World.World, playerId: any, name: any, ...any) -> ()

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "post", stackSize = 8 })

-- The players who have interacted with a bell, in order. A bell is a kind of placed object made up
-- for these tests, whose script records who interacts with one and does nothing else.
local bellInteractedBy: { PlayerState.PlayerState } = {}
PlacedObjectScripts.register("bell", {
	interact = function(_world: World.World, player: PlayerState.PlayerState, _placedObjectId: number)
		table.insert(bellInteractedBy, player)
	end,
})

local itemIds = { "log", "fish", "post" }
local at = Position.new
local ALONG_X = { x = 1, y = 0, z = 0 }

-- The name of every function in a table of requests, sorted.
local function namesIn(requests: any): { string }
	local names = {}
	for name in requests do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

-- How many of one item the world holds in all: in packs, carried, and on the ground.
local function inWorld(world: World.World, itemId: string): number
	local count = 0
	for _, groundItem in world.groundItems.itemsById do
		if groundItem.stack.itemId == itemId then
			count += groundItem.stack.count
		end
	end
	for _, state in world.players do
		count += Inventory.countItems(state.pack, itemId)
		local screen = state.screen
		if screen ~= nil and screen.carriedStack ~= nil and screen.carriedStack.itemId == itemId then
			count += screen.carriedStack.count
		end
	end
	return count
end

-- A world at time 100 with a plot of 6 by 6 tiles whose corner is at the origin, so that the middle of
-- tile x, z is at x * 4 - 2, z * 4 - 2. A bell stands on tile 2, 2 (its middle is 6, 6). Players 1 and 2
-- stand at 6, 0, 0 and at 10, 0, 10, and each has 12 logs in slot 1, 5 fish in slot 2 and 3 posts in
-- slot 3.
local function newWorld(): (World.World, PlayerState.PlayerState, PlayerState.PlayerState, number)
	local world = World.new(Plot.new(6, 6), at(0, 0, 0), 100)
	local bellId = Plot.placeObject(world.plot, "bell", 2, 2)
	local players = {}
	for playerId, position in { at(6, 0, 0), at(10, 0, 10) } do
		local state = World.addPlayer(world, playerId)
		Inventory.setStack(state.pack, 1, ItemStack.new("log", 12))
		Inventory.setStack(state.pack, 2, ItemStack.new("fish", 5))
		Inventory.setStack(state.pack, 3, ItemStack.new("post", 3))
		World.setCharacterPosition(world, playerId, position)
		players[playerId] = state
	end
	return world, players[1], players[2], bellId
end

do -- the names of the requests
	local names = Requests.NAMES
	check(table.isfrozen(names), "NAMES: the list cannot be changed")
	local inventoryNames, plotNames = namesIn(InventoryRequests), namesIn(PlotRequests)
	check(
		#names == #inventoryNames + #plotNames,
		"NAMES: lists every request of InventoryRequests and PlotRequests, each once"
	)
	local listed: { [string]: boolean } = {}
	for position, name in names do
		check(not listed[name], '"' .. name .. '" is listed once')
		listed[name] = true
		check(
			type(name) == "string" and string.match(name, "^%l%a*$") ~= nil,
			'"' .. tostring(name) .. '" is one word in camelCase'
		)
		check(
			position == 1 or names[position - 1] < name,
			'"' .. name .. '" comes after the name before it, in alphabetical order'
		)
	end
	for _, name in inventoryNames do
		check(listed[name] == true, 'NAMES: lists the inventory request "' .. name .. '"')
	end
	for _, name in plotNames do
		check(listed[name] == true, 'NAMES: lists the plot request "' .. name .. '"')
	end
	for _, name in plotNames do
		check((InventoryRequests :: any)[name] == nil, '"' .. name .. '" is not a request of InventoryRequests too')
	end
	check(
		not listed.askForSnapshot and not listed.NAMES and not listed.carryOut,
		"NAMES: lists nothing that is not a request"
	)
end

do -- Messages
	check(
		table.isfrozen(Messages.toServer) and table.isfrozen(Messages.toClient),
		"Messages: the lists cannot be changed"
	)
	local sent: { [string]: boolean } = {}
	for _, name in Messages.toServer do
		sent[name] = true
	end
	for _, name in Requests.NAMES do
		check(
			sent[name] == true,
			'"' .. name .. "\" is a message a player's machine sends, listed in Messages.toServer"
		)
	end
	check(sent.askForSnapshot == true, "Messages.toServer: lists askForSnapshot")
	check(
		#Messages.toServer == #Requests.NAMES + 1,
		"Messages.toServer: lists the requests and askForSnapshot, and nothing else"
	)
	check(
		not table.find(Requests.NAMES, "askForSnapshot"),
		"Messages: askForSnapshot is not a request, so Requests.NAMES lacks it"
	)
	check(
		#Messages.toClient == 1 and Messages.toClient[1] == "snapshotChanged",
		"Messages.toClient: lists snapshotChanged only"
	)

	local seen: { [string]: boolean } = {}
	for _, list: { string } in { Messages.toServer, Messages.toClient } do
		check(#list > 0, "Messages: each direction has at least one message")
		for _, name in list do
			check(
				string.match(name, "^%l%a*$") ~= nil,
				'"' .. name .. '" is one word in camelCase, so it can be a field name'
			)
			check(not seen[name], '"' .. name .. '" is listed once, in one direction only')
			seen[name] = true
		end
	end
end

do -- carryOut
	local world, first, second, bellId = newWorld()
	carryOut(world, 1, "openPack")
	check(
		first.screen ~= nil and second.screen == nil,
		"carryOut: carries out an inventory request for the player who asked"
	)
	carryOut(world, 1, "pickUpFromSlot", "pack", 1, 5)
	check(
		is((first.screen :: InventoryScreen.InventoryScreen).carriedStack, "log", 5)
			and is(Inventory.getStack(first.pack, 1), "log", 7),
		"carryOut: passes on what the player's machine sent after the name"
	)
	carryOut(world, 1, "closeScreen", "pack", 1, 5, "more", "than", "needed")
	check(
		first.screen == nil and Inventory.countItems(first.pack, "log") == 12,
		"carryOut: more arguments than a request takes are left unused"
	)
	carryOut(world, 2, "interactWithPlacedObject", bellId)
	check(
		#bellInteractedBy == 1 and bellInteractedBy[1] == second,
		"carryOut: carries out a plot request for the player who asked"
	)
	carryOut(world, 2, "selectHotbarSlot", 4)
	check(second.hotbar.selectedSlot == 4 and first.hotbar.selectedSlot == 1, "carryOut: and only for them")
	carryOut(world, 2, "pickUpFromSlot")
	carryOut(world, 2, "pickUpFromSlot", "pack")
	carryOut(world, 2, "swapSlots", "pack", 1, "other")
	check(
		Inventory.countItems(second.pack, "log") == 12,
		"carryOut: fewer arguments than a request takes are the same as arguments that make no sense"
	)

	local before = {}
	for _, itemId in itemIds do
		before[itemId] = inWorld(world, itemId)
	end
	for _, name in
		{
			"askForSnapshot",
			"askForInventory",
			"nonsense",
			"",
			"NAMES",
			"carryOut",
			"__index",
			"OpenPack",
			"openpack",
			" openPack",
		}
	do
		carryOut(world, 1, name, "pack", 1, 5)
	end
	for _, name in { 7, true, false, {}, 0 / 0, math.huge } :: { any } do
		carryOut(world, 1, name, "pack", 1, 5)
	end
	carryOut(world, 1, nil)
	check(
		first.screen == nil and Inventory.countItems(first.pack, "log") == 12,
		"carryOut: does nothing when no request has that name"
	)
	for _, playerId in { 0, 3, -1, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		carryOut(world, playerId, "openPack")
		carryOut(world, playerId, "dropFromSelectedSlot", ALONG_X, 1)
	end
	carryOut(world, nil, "openPack")
	check(
		first.screen == nil and inWorld(world, "log") == before.log,
		"carryOut: does nothing when no player has that id"
	)
	local sameWorld = true
	for _, itemId in itemIds do
		sameWorld = sameWorld and inWorld(world, itemId) == before[itemId]
	end
	check(sameWorld, "carryOut: and nothing is made or lost")

	World.removePlayer(world, 2)
	carryOut(world, 2, "openPack")
	check(second.screen == nil, "carryOut: does nothing for a player who has left")
end

do -- whatever a player's machine sends, nothing raises an error and no item is made or lost
	local seed = 90210
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
		"pack",
		"other",
		"left",
		"1",
		true,
		false,
		{},
		{ 1 },
		{ side = "pack" },
	}
	-- One thing a request might be sent with: mostly what a real machine would send, sometimes junk or nothing.
	local function argument(): any
		local kind = random(12)
		if kind <= 3 then
			return if random(4) == 1 then "other" else "pack"
		elseif kind <= 7 then
			return if random(3) == 1 then random(6) else random(40)
		elseif kind == 8 then
			return nil
		elseif kind == 9 then
			-- The slots of a spread: mostly ones a screen might have, now and then with junk among them.
			local screenSlots: { any } = {}
			for _ = 1, random(5) do
				local screenSlot: any = { side = if random(4) == 1 then "other" else "pack", slot = random(40) }
				table.insert(screenSlots, if random(8) == 1 then junk[random(#junk)] else screenSlot)
			end
			return screenSlots
		end
		return junk[random(#junk)]
	end
	local names: { any } = table.clone(Requests.NAMES)
	for _, extra in { "askForSnapshot", "nonsense", 12, false, "NAMES" } :: { any } do
		table.insert(names, extra)
	end

	local errors, firstError = 0, ""
	local allConserved = true
	local interactedBefore = #bellInteractedBy
	for _ = 1, 40 do
		local world, _, _, bellId = newWorld()
		World.addPlayer(world, 3)
		World.setCharacterPosition(world, 3, at(20, 0, 20))
		local total: { [string]: number } = {}
		for _, itemId in itemIds do
			total[itemId] = inWorld(world, itemId)
		end
		local now = 100
		for _ = 1, 300 do
			-- Players walk about, and now and then lose their character.
			if random(4) == 1 then
				local playerId = random(3)
				if random(8) == 1 then
					World.removeCharacter(world, playerId)
				else
					World.setCharacterPosition(world, playerId, at(random(30), 0, random(30)))
				end
			end
			-- Now and then a player interacts with the bell, as a real machine would ask.
			if random(25) == 1 then
				carryOut(world, random(3), "interactWithPlacedObject", bellId)
			end
			local playerId: any = if random(10) == 1 then junk[random(#junk)] else random(4)
			local name = names[random(#names)]
			local ok, result =
				pcall(carryOut, world, playerId, name, argument(), argument(), argument(), argument(), argument())
			if not ok then
				errors += 1
				firstError = if firstError == "" then tostring(name) .. ": " .. tostring(result) else firstError
			end
			now += 0.5
			World.advanceTo(world, now)
			for _, itemId in itemIds do
				if inWorld(world, itemId) ~= total[itemId] then
					allConserved = false
				end
			end
		end
	end
	check(errors == 0, "random run: none of 12,000 requests raises an error (first: " .. firstError .. ")")
	check(allConserved, "random run: after every request every item is in a pack, carried, or on the ground")
	check(#bellInteractedBy > interactedBefore, "random run: and a plot request reached a script, so that was tried")
end

Check.finish("Requests")
