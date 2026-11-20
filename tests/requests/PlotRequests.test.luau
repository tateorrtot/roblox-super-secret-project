--!strict
-- Tests for PlotRequests. Run from the repository root: lune run tests/requests/PlotRequests.test.luau
-- The items and the kinds of placed object here are made up for the tests, and their scripts only
-- record that they were called. What the game's own things do is tested with those things, in
-- tests/content.

local Check = require("../Check")
local Hotbar = require("../../src/shared/inventory/Hotbar")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemScripts = require("../../src/shared/requests/ItemScripts")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlacedObjectScripts = require("../../src/shared/requests/PlacedObjectScripts")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local PlotRequests = require("../../src/shared/requests/PlotRequests")
local Position = require("../../src/shared/Position")
local World = require("../../src/shared/world/World")

local check = Check.that
local at = Position.new

-- One call of a function of a script: its name and what it was called with. An item's script is
-- handed no player, so a call of one has none.
type Call = {
	name: string,
	world: World.World,
	player: PlayerState.PlayerState?,
	first: number,
	second: number?,
}
local calls: { Call } = {}

-- The calls made since this was last called.
local function takeCalls(): { Call }
	local made = calls
	calls = {}
	return made
end

-- How many seeds the seed's script says each interaction uses up. The tests change it.
local seedsUsedUp = 1

-- A function for an item's script, which records each call under `name` and returns what
-- `getUsedUp` returns: how many of the item the interaction used up.
local function recordTileCall(name: string, getUsedUp: () -> number)
	return function(world: World.World, tileX: number, tileZ: number): number
		table.insert(calls, { name = name, world = world, first = tileX, second = tileZ })
		return getUsedUp()
	end
end

-- A function for a placed object's script, which records each call of `interact` under `name`.
local function recordInteractCall(name: string)
	return function(world: World.World, player: PlayerState.PlayerState, placedObjectId: number)
		table.insert(calls, { name = name, world = world, player = player, first = placedObjectId })
	end
end

-- A function for a placed object's script, which records each call of `breakPlacedObject` under
-- `name`. It is handed no player.
local function recordBreakCall(name: string)
	return function(world: World.World, placedObjectId: number)
		table.insert(calls, { name = name, world = world, first = placedObjectId })
	end
end

-- A wand's script uses up no wand. A seed's script uses up `seedsUsedUp` seeds. A stick has a
-- script with no function, and a feather has no script.
ItemRegistry.register({ id = "wand", stackSize = 1 })
ItemRegistry.register({ id = "seed", stackSize = 16 })
ItemRegistry.register({ id = "stick", stackSize = 16 })
ItemRegistry.register({ id = "feather", stackSize = 16 })
ItemScripts.register("wand", {
	interactWithTile = recordTileCall("wand.interactWithTile", function()
		return 0
	end),
})
ItemScripts.register("seed", {
	interactWithTile = recordTileCall("seed.interactWithTile", function()
		return seedsUsedUp
	end),
})
ItemScripts.register("stick", {})

-- A bell's script has both functions, a gong's has `interact` only, a vase's has
-- `breakPlacedObject` only, a post's has neither, and a rock has no script.
PlacedObjectScripts.register("bell", {
	interact = recordInteractCall("bell.interact"),
	breakPlacedObject = recordBreakCall("bell.breakPlacedObject"),
})
PlacedObjectScripts.register("gong", { interact = recordInteractCall("gong.interact") })
PlacedObjectScripts.register("vase", { breakPlacedObject = recordBreakCall("vase.breakPlacedObject") })
PlacedObjectScripts.register("post", {})

-- The requests are called with whatever a player's machine might send, so they are called through
-- this, which does not check their arguments.
local requests = PlotRequests :: any
local function send(name: string, world: World.World, player: PlayerState.PlayerState, ...: any)
	(requests[name] :: (...any) -> ())(world, player, ...)
end

-- Something that is not the id of a placed object.
local badIds: { any } = { 0, -1, 99, 1.5, 0 / 0, math.huge, -math.huge, "1", true, {} }

type PlacedObjectIds = { bell: number, gong: number, vase: number, post: number, rock: number }

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
-- tile x, z is at x * 4 - 2, z * 4 - 2. A bell stands on tile 2, 2 (its middle is 6, 6), a gong on
-- 3, 2, a vase on 4, 2, a post on 2, 3 and a rock on 3, 3. Player 1 stands at 6, 0, 0, within reach of
-- all five, with a wand in hotbar slot 1, 3 sticks in slot 2, 5 feathers in slot 3 and 5 seeds in
-- slot 4.
local function newWorld(): (World.World, PlayerState.PlayerState, PlacedObjectIds)
	local world = World.new(Plot.new(6, 6), at(0, 0, 0), 100)
	local ids = {
		bell = Plot.placeObject(world.plot, "bell", 2, 2),
		gong = Plot.placeObject(world.plot, "gong", 3, 2),
		vase = Plot.placeObject(world.plot, "vase", 4, 2),
		post = Plot.placeObject(world.plot, "post", 2, 3),
		rock = Plot.placeObject(world.plot, "rock", 3, 3),
	}
	local player = World.addPlayer(world, 1)
	Inventory.setStack(player.pack, 1, ItemStack.new("wand", 1))
	Inventory.setStack(player.pack, 2, ItemStack.new("stick", 3))
	Inventory.setStack(player.pack, 3, ItemStack.new("feather", 5))
	Inventory.setStack(player.pack, 4, ItemStack.new("seed", 5))
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	return world, player, ids
end

-- True if nothing a request might have changed has changed: the pack, the screen and the plot are
-- as `newWorld` made them.
local function isAsNew(world: World.World, player: PlayerState.PlayerState): boolean
	return is(Inventory.getStack(player.pack, 1), "wand", 1)
		and is(Inventory.getStack(player.pack, 2), "stick", 3)
		and is(Inventory.getStack(player.pack, 3), "feather", 5)
		and is(Inventory.getStack(player.pack, 4), "seed", 5)
		and player.screen == nil
		and placedCount(world) == 5
		and next(world.groundItems.itemsById) == nil
end

do -- interactWithTile: which script is called, and with what
	local world, player = newWorld()
	send("interactWithTile", world, player, 5, 1)
	local made = takeCalls()
	check(
		#made == 1 and made[1].name == "wand.interactWithTile",
		"interactWithTile: calls the interactWithTile of the script of the item in the selected hotbar slot, once"
	)
	check(
		#made == 1 and made[1].world == world and made[1].first == 5 and made[1].second == 1,
		"interactWithTile: with the world and the tile"
	)
	check(isAsNew(world, player), "interactWithTile: and takes nothing when the script says it used none up")

	send("interactWithTile", world, player, 2, 2)
	check(#takeCalls() == 1, "interactWithTile: it does not ask whether anything stands on the tile")
	send("interactWithTile", world, player, 2, 1)
	check(#takeCalls() == 1, "interactWithTile: or whether a player stands on it")
	for _, corner in { { 1, 1 }, { 6, 1 }, { 1, 6 }, { 6, 6 } } do
		World.setCharacterPosition(world, 1, at(corner[1] * 4 - 2, 0, corner[2] * 4 - 2))
		send("interactWithTile", world, player, corner[1], corner[2])
	end
	check(#takeCalls() == 4, "interactWithTile: every tile of the plot is one, out to its corners")
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	for _, bad in { 0, 7, -1, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		send("interactWithTile", world, player, bad, 1)
		send("interactWithTile", world, player, 1, bad)
		send("interactWithTile", world, player, bad, bad)
	end
	send("interactWithTile", world, player, 3)
	send("interactWithTile", world, player)
	check(#takeCalls() == 0, "interactWithTile: does nothing for a tile that is not on the plot, or for nonsense")

	Hotbar.selectSlot(player.hotbar, 2)
	send("interactWithTile", world, player, 5, 1)
	check(#takeCalls() == 0, "interactWithTile: does nothing for an item whose script lacks the function")
	Hotbar.selectSlot(player.hotbar, 3)
	send("interactWithTile", world, player, 5, 1)
	check(#takeCalls() == 0, "interactWithTile: does nothing for an item that has no script")
	Hotbar.selectSlot(player.hotbar, 9)
	send("interactWithTile", world, player, 5, 1)
	check(#takeCalls() == 0, "interactWithTile: does nothing when the selected hotbar slot holds nothing")
	check(isAsNew(world, player), "interactWithTile: and none of those raises an error or changes anything")

	Inventory.setStack(player.pack, 9, ItemStack.new("wand", 1))
	send("interactWithTile", world, player, 5, 1)
	check(#takeCalls() == 1, "interactWithTile: the script is that of whatever item the selected slot holds now")
	Inventory.setStack(player.pack, 9, nil)

	Hotbar.selectSlot(player.hotbar, 1)
	PlayerState.openScreen(player)
	send("interactWithTile", world, player, 5, 1)
	check(#takeCalls() == 1, "interactWithTile: it does not ask whether the player has a screen open")
end

do -- interactWithTile: how far the player stands
	local world, player = newWorld()
	-- The middle of tile 6, 1 is at 22, 2. Standing at 6, 2 it is exactly 16 studs away.
	World.setCharacterPosition(world, 1, at(5.99, 0, 2))
	send("interactWithTile", world, player, 6, 1)
	check(#takeCalls() == 0, "interactWithTile: does nothing for a tile just beyond the character's reach")
	World.setCharacterPosition(world, 1, at(6, 0, 2))
	send("interactWithTile", world, player, 6, 1)
	check(#takeCalls() == 1, "interactWithTile: calls the script for a tile exactly at reach")
	World.removeCharacter(world, 1)
	send("interactWithTile", world, player, 3, 1)
	check(#takeCalls() == 0, "interactWithTile: does nothing for a player with no character")
end

do -- interactWithTile: what the script says it used up leaves the selected slot
	local world, player = newWorld()
	Hotbar.selectSlot(player.hotbar, 4)
	Inventory.setStack(player.pack, 5, ItemStack.new("seed", 7))
	seedsUsedUp = 1
	send("interactWithTile", world, player, 5, 1)
	check(
		#takeCalls() == 1 and is(Inventory.getStack(player.pack, 4), "seed", 4),
		"interactWithTile: one item leaves the selected slot when the script says it used one up"
	)
	seedsUsedUp = 2
	send("interactWithTile", world, player, 5, 1)
	check(is(Inventory.getStack(player.pack, 4), "seed", 2), "interactWithTile: and two when it says two")
	seedsUsedUp = 0
	send("interactWithTile", world, player, 5, 1)
	check(
		#takeCalls() == 2 and is(Inventory.getStack(player.pack, 4), "seed", 2),
		"interactWithTile: and none when it says none"
	)
	check(
		is(Inventory.getStack(player.pack, 5), "seed", 7) and is(Inventory.getStack(player.pack, 1), "wand", 1),
		"interactWithTile: they are taken from the selected slot and no other"
	)

	seedsUsedUp = 1
	World.setCharacterPosition(world, 1, at(500, 0, 500))
	send("interactWithTile", world, player, 5, 1)
	check(
		#takeCalls() == 0 and is(Inventory.getStack(player.pack, 4), "seed", 2),
		"interactWithTile: nothing is taken when the script is not called"
	)
	World.setCharacterPosition(world, 1, at(6, 0, 0))

	seedsUsedUp = 5
	send("interactWithTile", world, player, 5, 1)
	check(
		Inventory.getStack(player.pack, 4) == nil and is(Inventory.getStack(player.pack, 5), "seed", 7),
		"interactWithTile: no more is taken than the selected slot holds"
	)
	send("interactWithTile", world, player, 5, 1)
	check(#takeCalls() == 1, "interactWithTile: and with the slot emptied, the script is not called again")
	seedsUsedUp = 1
end

do -- interactWithPlacedObject
	local world, player, ids = newWorld()
	send("interactWithPlacedObject", world, player, ids.bell)
	local made = takeCalls()
	check(
		#made == 1 and made[1].name == "bell.interact",
		"interactWithPlacedObject: calls the interact of the script of the placed object's kind, once"
	)
	check(
		#made == 1 and made[1].world == world and made[1].player == player and made[1].first == ids.bell,
		"interactWithPlacedObject: with the world, the player and the placed object's id"
	)
	send("interactWithPlacedObject", world, player, ids.gong)
	made = takeCalls()
	check(
		#made == 1 and made[1].name == "gong.interact" and made[1].first == ids.gong,
		"interactWithPlacedObject: each placed object is answered by the script of its own kind"
	)
	send("interactWithPlacedObject", world, player, ids.vase)
	check(#takeCalls() == 0, "interactWithPlacedObject: does nothing for a kind whose script lacks the function")
	send("interactWithPlacedObject", world, player, ids.post)
	check(#takeCalls() == 0, "interactWithPlacedObject: does nothing for a kind whose script has no function")
	send("interactWithPlacedObject", world, player, ids.rock)
	check(#takeCalls() == 0, "interactWithPlacedObject: does nothing for a kind that has no script")
	for _, bad in badIds do
		send("interactWithPlacedObject", world, player, bad)
	end
	send("interactWithPlacedObject", world, player)
	check(#takeCalls() == 0, "interactWithPlacedObject: does nothing for an id that is not a placed object's")
	check(isAsNew(world, player), "interactWithPlacedObject: and changes nothing itself")

	-- The middle of the bell's tile is at 6, 6. Standing at 6, 22 it is exactly 16 studs away.
	World.setCharacterPosition(world, 1, at(6, 0, 22.01))
	send("interactWithPlacedObject", world, player, ids.bell)
	check(#takeCalls() == 0, "interactWithPlacedObject: not from beyond reach")
	World.setCharacterPosition(world, 1, at(6, 0, 22))
	send("interactWithPlacedObject", world, player, ids.bell)
	check(#takeCalls() == 1, "interactWithPlacedObject: from exactly at reach")
	World.removeCharacter(world, 1)
	send("interactWithPlacedObject", world, player, ids.bell)
	check(#takeCalls() == 0, "interactWithPlacedObject: not by a player with no character")

	World.setCharacterPosition(world, 1, at(6, 0, 0))
	PlayerState.openScreen(player)
	send("interactWithPlacedObject", world, player, ids.bell)
	check(#takeCalls() == 1, "interactWithPlacedObject: it does not ask whether the player has a screen open")
	Hotbar.selectSlot(player.hotbar, 9)
	send("interactWithPlacedObject", world, player, ids.bell)
	check(#takeCalls() == 1, "interactWithPlacedObject: or what is in their selected hotbar slot")

	Plot.removePlacedObject(world.plot, ids.bell)
	send("interactWithPlacedObject", world, player, ids.bell)
	check(#takeCalls() == 0, "interactWithPlacedObject: not for a placed object that has been taken off the plot")
end

do -- breakPlacedObject
	local world, player, ids = newWorld()
	send("breakPlacedObject", world, player, ids.bell)
	local made = takeCalls()
	check(
		#made == 1 and made[1].name == "bell.breakPlacedObject",
		"breakPlacedObject: calls the breakPlacedObject of the script of the placed object's kind, once"
	)
	check(
		#made == 1 and made[1].world == world and made[1].player == nil and made[1].first == ids.bell,
		"breakPlacedObject: with the world and the placed object's id, and no player"
	)
	check(
		world.plot.placedObjectsById[ids.bell] ~= nil and isAsNew(world, player),
		"breakPlacedObject: and takes nothing off the plot itself"
	)
	send("breakPlacedObject", world, player, ids.vase)
	made = takeCalls()
	check(
		#made == 1 and made[1].name == "vase.breakPlacedObject" and made[1].first == ids.vase,
		"breakPlacedObject: each placed object is answered by the script of its own kind"
	)
	send("breakPlacedObject", world, player, ids.gong)
	check(#takeCalls() == 0, "breakPlacedObject: does nothing for a kind whose script lacks the function")
	send("breakPlacedObject", world, player, ids.post)
	check(#takeCalls() == 0, "breakPlacedObject: does nothing for a kind whose script has no function")
	send("breakPlacedObject", world, player, ids.rock)
	check(#takeCalls() == 0, "breakPlacedObject: does nothing for a kind that has no script")
	for _, bad in badIds do
		send("breakPlacedObject", world, player, bad)
	end
	send("breakPlacedObject", world, player)
	check(#takeCalls() == 0, "breakPlacedObject: does nothing for an id that is not a placed object's")
	check(isAsNew(world, player), "breakPlacedObject: and none of those raises an error or changes anything")

	World.setCharacterPosition(world, 1, at(6, 0, 22.01))
	send("breakPlacedObject", world, player, ids.bell)
	check(#takeCalls() == 0, "breakPlacedObject: not from beyond reach")
	World.setCharacterPosition(world, 1, at(6, 0, 22))
	send("breakPlacedObject", world, player, ids.bell)
	check(#takeCalls() == 1, "breakPlacedObject: from exactly at reach")
	World.removeCharacter(world, 1)
	send("breakPlacedObject", world, player, ids.bell)
	check(#takeCalls() == 0, "breakPlacedObject: not by a player with no character")

	World.setCharacterPosition(world, 1, at(6, 0, 0))
	PlayerState.openScreen(player)
	send("breakPlacedObject", world, player, ids.bell)
	check(#takeCalls() == 1, "breakPlacedObject: it does not ask whether the player has a screen open")

	Plot.removePlacedObject(world.plot, ids.bell)
	send("breakPlacedObject", world, player, ids.bell)
	check(#takeCalls() == 0, "breakPlacedObject: not for a placed object that has been taken off the plot")
end

do -- whatever a player's machine sends, nothing raises an error, and a script is called only as the request says
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

	-- True if a call was one that the request may make: of the script of the item the player who
	-- asked held, for a tile the plot has, or of the script of the kind of a placed object that
	-- stands there, for that player, and in both cases within that player's reach.
	local function isAllowed(
		call: Call,
		world: World.World,
		player: PlayerState.PlayerState,
		held: ItemStack.ItemStack?
	): boolean
		local second = call.second
		if call.world ~= world then
			return false
		elseif second ~= nil then
			return held ~= nil
				and call.name == held.itemId .. ".interactWithTile"
				and Plot.hasTile(world.plot, call.first, second)
				and World.canReachTile(world, player, call.first, second)
		end
		local placedObject = world.plot.placedObjectsById[call.first]
		local isInteract = string.find(call.name, ".interact", 1, true) ~= nil
		return call.player == (if isInteract then player else nil)
			and placedObject ~= nil
			and string.find(call.name, placedObject.kindId .. ".", 1, true) == 1
			and World.canReachTile(world, player, placedObject.tileX, placedObject.tileZ)
	end

	local errors, firstError = 0, ""
	local callCounts: { [string]: number } = {}
	local allAllowed, nothingPlaced = true, true
	for _ = 1, 40 do
		local world, firstPlayer = newWorld()
		local secondPlayer = World.addPlayer(world, 2)
		World.setCharacterPosition(world, 2, at(10, 0, 10))
		Inventory.setStack(secondPlayer.pack, 4, ItemStack.new("wand", 1))
		Inventory.setStack(secondPlayer.pack, 5, ItemStack.new("seed", 16))
		local players = { firstPlayer, secondPlayer }
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
			-- Players change what is in hand, and open and close a screen, as other requests would.
			Hotbar.selectSlot(player.hotbar, random(5))
			if random(10) == 1 and PlayerState.canOpenScreen(player) then
				PlayerState.openScreen(player)
			elseif random(5) == 1 then
				World.closeScreen(world, player)
			end
			local held = Hotbar.getSelectedStack(player.hotbar)
			local name = names[random(#names)]
			local ok, result = pcall(send, name, world, player, argument(), argument(), argument())
			if not ok then
				errors += 1
				firstError = if firstError == "" then name .. ": " .. tostring(result) else firstError
			end
			for _, call in takeCalls() do
				callCounts[call.name] = (callCounts[call.name] or 0) + 1
				allAllowed = allAllowed and isAllowed(call, world, player, held)
			end
			nothingPlaced = nothingPlaced and placedCount(world) == 5 and next(world.groundItems.itemsById) == nil
		end
	end
	check(errors == 0, "random run: none of 12,000 requests raises an error (first: " .. firstError .. ")")
	check(
		allAllowed,
		"random run: a script is called only for what the player who asked holds or reaches, on a tile or a placed object that is there"
	)
	check(nothingPlaced, "random run: and no request places or removes anything itself")
	for _, name in
		{
			"wand.interactWithTile",
			"seed.interactWithTile",
			"bell.interact",
			"bell.breakPlacedObject",
			"gong.interact",
			"vase.breakPlacedObject",
		}
	do
		check((callCounts[name] or 0) > 0, "random run: " .. name .. " was called, so that was tried")
	end
end

Check.finish("PlotRequests")
