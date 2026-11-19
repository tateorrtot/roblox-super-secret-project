--!strict
-- Tests for World. Run from the repository root: lune run tests/world/World.test.luau

local Check = require("../Check")
local GroundItems = require("../../src/shared/world/GroundItems")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local Messages = require("../../src/shared/Messages")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/world/Position")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")
local Station = require("../../src/shared/stations/Station")
local World = require("../../src/shared/world/World")

local check = Check.that
local raises = Check.raises
local answer = World.answer :: (world: World.World, playerId: number, name: any, ...any) -> ()

ItemRegistry.register({ id = "log", stackSize = 16, burnSeconds = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "apple", stackSize = 16 })
ItemRegistry.register({ id = "stove", stackSize = 1, placeable = true })
ItemRegistry.register({ id = "crate", stackSize = 1, placeable = true, slotCount = 27 })
ItemRegistry.register({ id = "post", stackSize = 8, placeable = true })
ItemRegistry.register({ id = "cooked_fish", stackSize = 8 })
ItemRegistry.register({ id = "oven", stackSize = 1, placeable = true, slotCount = 3 })
RecipeRegistry.register({ station = "oven", input = "fish", output = "cooked_fish", seconds = 8 })

local itemIds = { "log", "fish", "apple", "stove", "crate", "post" }
local at = Position.new

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

-- How many of one item lie on the ground, as a sorted list of the counts of the ground items.
local function onGround(world: World.World, itemId: string): { number }
	local counts = {}
	for _, groundItem: GroundItems.GroundItem in world.groundItems.byId :: any do
		if groundItem.stack.itemId == itemId then
			table.insert(counts, groundItem.stack.count)
		end
	end
	table.sort(counts)
	return counts
end

local function sum(counts: { number }): number
	local total = 0
	for _, count in counts do
		total += count
	end
	return total
end

-- How many of one item the whole world holds: in packs, carried, standing on the plot, inside what
-- stands on the plot, and on the ground.
local function inWorld(world: World.World, itemId: string): number
	local count = sum(onGround(world, itemId))
	for _, player: World.WorldPlayer in world.players :: any do
		count += Inventory.countItems(player.state.pack, itemId)
		local session = player.state.session
		if session ~= nil and session.carried ~= nil and session.carried.itemId == itemId then
			count += session.carried.count
		end
	end
	for _, placedItem: Plot.PlacedItem in world.plot.placedById :: any do
		if placedItem.itemId == itemId then
			count += 1
		end
		if placedItem.inventory ~= nil then
			count += Inventory.countItems(placedItem.inventory, itemId)
		end
	end
	return count
end

-- True if `value` is made only of numbers, strings, booleans, lists with no gaps and records with string keys.
local function isPlain(value: any): boolean
	if type(value) ~= "table" then
		return type(value) == "number" or type(value) == "string" or type(value) == "boolean"
	end
	local keys, stringKeys = 0, 0
	for key, inner in value do
		keys += 1
		if type(key) == "string" then
			stringKeys += 1
		end
		if not isPlain(inner) then
			return false
		end
	end
	return stringKeys == keys or (stringKeys == 0 and #value == keys)
end

-- A world at time 100 with a plot of 6 by 6 tiles whose corner is at the origin, so that the middle of
-- tile x, z is at x * 4 - 2, z * 4 - 2. A crate holding 5 fish stands on tile 2, 2 (its middle is 6, 6),
-- and a stove on tile 5, 5 (its middle is 18, 18). Player 1 stands at 6, 0 with 12 logs, a crate and a
-- stove in their first three hotbar slots, and drops land 6 studs further along x.
local function newWorld(): (World.World, PlayerState.PlayerState, number, number)
	local plot = Plot.new(6, 6)
	local crateId = Plot.place(plot, "crate", 2, 2) :: number
	Inventory.addItems(plot.placedById[crateId].inventory :: Inventory.Inventory, "fish", 5)
	local stoveId = Plot.place(plot, "stove", 5, 5) :: number
	local world = World.new(plot, at(0, 0, 0), 100)
	local state = World.addPlayer(world, 1, at(0, 0, 0))
	Inventory.setStack(state.pack, 1, ItemStack.new("log", 12))
	Inventory.setStack(state.pack, 2, ItemStack.new("crate", 1))
	Inventory.setStack(state.pack, 3, ItemStack.new("stove", 1))
	World.setPlayerPosition(world, 1, at(6, 0, 0), at(12, 0, 0))
	return world, state, crateId, stoveId
end

do -- the rules as numbers, and the names
	check(World.CLOSES_BEYOND == Plot.REACH + 4, "a screen closes 4 studs beyond reach")
	local answered: { [string]: boolean } = {}
	for _, name in World.REQUEST_NAMES do
		check(not answered[name], '"' .. name .. '" is named once')
		answered[name] = true
	end
	for _, name in Messages.toServer do
		if name ~= "askForInventory" then
			check(answered[name] == true, 'the world answers "' .. name .. "\", which a player's machine may send")
		end
	end
	check(#World.REQUEST_NAMES == #Messages.toServer - 1, "and answers nothing that is not in Messages")
	check(table.isfrozen(World.REQUEST_NAMES), "the list of names cannot be changed")
end

do -- a new world
	local plot = Plot.new(3, 3)
	local corner = { x = 4, y = 1, z = -8 }
	local world = World.new(plot, corner, 50)
	check(world.plot == plot, "new: holds the plot it was given")
	check(
		world.plotCorner.x == 4 and world.plotCorner.y == 1 and world.plotCorner.z == -8,
		"new: knows where the plot's corner is"
	)
	corner.x = 99
	check(world.plotCorner.x == 4, "new: changing the caller's corner afterwards changes nothing")
	check(world.now == 50, "new: starts at the time it was given")
	check(
		next(world.players :: any) == nil and next(world.groundItems.byId :: any) == nil,
		"new: no players, and nothing on the ground"
	)
	check(
		raises("World.new: plotCorner: position.y must be a number; got nil", function()
			return World.new(plot, { x = 0, z = 0 } :: any, 0)
		end),
		"new: refuses a corner that is not a position"
	)
	check(
		raises("World.new: now must be a number of seconds; got nan", function()
			return World.new(plot, at(0, 0, 0), 0 / 0)
		end),
		"new: refuses a time that is not a number"
	)
end

do -- players come and go
	local world = World.new(Plot.new(3, 3), at(0, 0, 0), 0)
	local state = World.addPlayer(world, 7, at(1, 0, 2))
	local player = world.players[7]
	check(player ~= nil and player.state == state, "addPlayer: returns the state of the player now in the world")
	check(
		Inventory.isEmpty(state.pack) and state.session == nil,
		"addPlayer: a new player holds nothing and has no screen open"
	)
	check(player.position == nil, "addPlayer: a new player stands nowhere yet")
	check(
		player.dropPosition.x == 1 and player.dropPosition.z == 2,
		"addPlayer: their drops would land where they were added"
	)
	check(player.openedPlacedId == nil, "addPlayer: they have nothing open")
	check(
		World.addPlayer(world, -3, at(0, 0, 0)) ~= state,
		"addPlayer: a second player has a state of their own, and an id may be negative"
	)
	check(
		raises("World.addPlayer: player 7 is already in the world", function()
			return World.addPlayer(world, 7, at(0, 0, 0))
		end),
		"addPlayer: refuses an id that is already in the world"
	)
	for _, bad in { "7", 0 / 0, true } :: { any } do
		check(
			raises("World.addPlayer: playerId must be a number; got " .. tostring(bad), function()
				return World.addPlayer(world, bad, at(0, 0, 0))
			end),
			"addPlayer: refuses the id " .. tostring(bad)
		)
	end
	check(
		raises("World.addPlayer: a position is a table with x, y and z, not a nil", function()
			return World.addPlayer(world, 8, nil :: any)
		end),
		"addPlayer: refuses a player with no position"
	)
	check(world.players[8] == nil, "addPlayer: a refused player is not in the world")

	World.removePlayer(world, 7)
	check(
		world.players[7] == nil and world.players[-3] ~= nil,
		"removePlayer: takes that player out and leaves the others"
	)
	World.removePlayer(world, 7)
	World.removePlayer(world, 999)
	check(world.players[-3] ~= nil, "removePlayer: does nothing for an id that is not in the world")
	check(World.addPlayer(world, 7, at(0, 0, 0)) ~= state, "addPlayer: a player who comes back starts afresh")
end

do -- where a player stands
	local world = newWorld()
	local player = world.players[1]
	check(
		player.position ~= nil and player.position.x == 6 and player.dropPosition.x == 12,
		"setPlayerPosition: sets where they stand and where their drops land"
	)
	check(
		table.isfrozen(player.position :: any) and table.isfrozen(player.dropPosition),
		"setPlayerPosition: keeps frozen copies"
	)
	World.setPlayerPosition(world, 1, at(3, 0, 3))
	check(
		world.players[1].dropPosition.x == 3 and world.players[1].dropPosition.z == 3,
		"setPlayerPosition: with no drop position, drops land where they stand"
	)
	World.setPlayerPosition(world, 1, at(6, 0, 0), at(12, 0, 0))
	World.setPlayerPosition(world, 1, nil)
	check(world.players[1].position == nil, "setPlayerPosition: nil means they have no character")
	check(
		world.players[1].dropPosition.x == 12,
		"setPlayerPosition: a player with no character keeps the drop position they had"
	)
	World.setPlayerPosition(world, 1, nil, at(50, 0, 50))
	check(
		world.players[1].dropPosition.x == 12,
		"setPlayerPosition: and a drop position given with no position is not used"
	)
	check(
		raises("World.setPlayerPosition: no player in the world has the id 2", function()
			World.setPlayerPosition(world, 2, at(0, 0, 0))
		end),
		"setPlayerPosition: refuses a player who is not in the world"
	)
	check(
		raises("World.setPlayerPosition: position.x must be a number; got nil", function()
			World.setPlayerPosition(world, 1, { y = 0, z = 0 } :: any)
		end),
		"setPlayerPosition: refuses a position that is not one"
	)
	check(
		raises("World.setPlayerPosition: dropPosition: position.z must be a number; got inf", function()
			World.setPlayerPosition(world, 1, at(1, 0, 1), { x = 0, y = 0, z = math.huge })
		end),
		"setPlayerPosition: refuses a drop position that is not one"
	)
	check(world.players[1].position == nil, "setPlayerPosition: a refused call changes nothing")
end

do -- requests about a player's own inventories
	local world, state = newWorld()
	answer(world, 1, "dropSelected")
	check(is(Inventory.getStack(state.pack, 1), "log", 11), "answer: dropSelected takes one out of the hand")
	local dropped: GroundItems.GroundItem = (world.groundItems.byId :: any)[1]
	check(dropped ~= nil and is(dropped.stack, "log", 1), "answer: and it lies on the ground")
	check(dropped.position.x == 12 and dropped.position.z == 0, "answer: where the player's drops land")
	check(dropped.droppedAt == 100, "answer: dropped at the world's time")

	answer(world, 1, "openPack")
	check(
		state.session ~= nil and world.players[1].openedPlacedId == nil,
		"answer: openPack opens the screen on the pack alone"
	)
	answer(world, 1, "clickSlot", "pack", 1, "left")
	answer(world, 1, "dropCarried", 3)
	check(sum(onGround(world, "log")) == 4, "answer: dropCarried puts carried items on the ground")
	answer(world, 1, "closeInventory")
	check(
		state.session == nil and Inventory.countItems(state.pack, "log") == 8,
		"answer: closeInventory puts what was carried back in the pack"
	)

	World.setPlayerPosition(world, 1, nil)
	answer(world, 1, "dropSelected")
	check(
		sum(onGround(world, "log")) == 5,
		"answer: a player with no character can still drop, where their drops last landed"
	)

	answer(world, 2, "dropSelected")
	answer(world, 2, "openPack")
	check(inWorld(world, "log") == 12, "answer: a request from a player who is not in the world is ignored")
	for _, name in { "askForInventory", "nonsense", "", 7, true, {} } :: { any } do
		answer(world, 1, name, 1, 2, 3)
	end
	answer(world, 1, nil)
	check(inWorld(world, "log") == 12 and state.session == nil, "answer: a name that is not a request is ignored")
end

do -- placing what is in hand
	local world, state = newWorld()
	answer(world, 1, "selectHotbarSlot", 2)
	answer(world, 1, "placeSelected", 1, 1)
	local placedId = world.plot.nextId - 1
	local placed = world.plot.placedById[placedId]
	check(
		placed ~= nil and placed.itemId == "crate" and placed.x == 1 and placed.z == 1,
		"placeSelected: the item in hand stands on the tile"
	)
	check(Inventory.getStack(state.pack, 2) == nil, "placeSelected: and has left the hand")
	check(inWorld(world, "crate") == 2, "placeSelected: no crate was made or lost")

	answer(world, 1, "selectHotbarSlot", 3)
	answer(world, 1, "placeSelected", 1, 1)
	check(is(Inventory.getStack(state.pack, 3), "stove", 1), "placeSelected: not on a tile that something stands on")
	answer(world, 1, "placeSelected", 2, 1)
	check(is(Inventory.getStack(state.pack, 3), "stove", 1), "placeSelected: not on the tile the player stands on")
	answer(world, 1, "placeSelected", 7, 1)
	answer(world, 1, "placeSelected", 0, 1)
	answer(world, 1, "placeSelected", 1.5, 1)
	answer(world, 1, "placeSelected", "1", 1)
	answer(world, 1, "placeSelected", 3)
	answer(world, 1, "placeSelected")
	check(
		is(Inventory.getStack(state.pack, 3), "stove", 1),
		"placeSelected: not on a tile that is not on the plot, or with nonsense"
	)
	answer(world, 1, "selectHotbarSlot", 1)
	answer(world, 1, "placeSelected", 3, 1)
	check(
		is(Inventory.getStack(state.pack, 1), "log", 12) and world.plot.nextId == placedId + 1,
		"placeSelected: not an item that cannot be placed"
	)
	answer(world, 1, "selectHotbarSlot", 9)
	answer(world, 1, "placeSelected", 3, 1)
	check(world.plot.nextId == placedId + 1, "placeSelected: not with an empty hand")

	answer(world, 1, "selectHotbarSlot", 3)
	answer(world, 1, "openPack")
	answer(world, 1, "placeSelected", 3, 1)
	check(is(Inventory.getStack(state.pack, 3), "stove", 1), "placeSelected: not while the inventory screen is open")
	answer(world, 1, "closeInventory")

	Inventory.setStack(state.pack, 5, ItemStack.new("post", 3))
	answer(world, 1, "selectHotbarSlot", 5)
	answer(world, 1, "placeSelected", 4, 1)
	check(is(Inventory.getStack(state.pack, 5), "post", 2), "placeSelected: only one of a stack in hand is placed")
	check(inWorld(world, "post") == 3, "placeSelected: and the rest of the stack is still in hand")
	answer(world, 1, "selectHotbarSlot", 3)

	-- The middle of tile 6, 1 is at 22, 2. Standing at 6, 2 it is exactly 16 studs away.
	World.setPlayerPosition(world, 1, at(6, 0, 2), at(12, 0, 2))
	answer(world, 1, "placeSelected", 6, 1)
	check(Inventory.getStack(state.pack, 3) == nil, "placeSelected: a tile exactly at reach can be placed on")
	local farId = world.plot.nextId - 1
	check(world.plot.placedById[farId].x == 6, "placeSelected: and the item stands there")
end

do -- reach, and standing on a tile
	local world, state = newWorld()
	answer(world, 1, "selectHotbarSlot", 3)
	World.setPlayerPosition(world, 1, at(5.99, 0, 2))
	answer(world, 1, "placeSelected", 6, 1)
	check(is(Inventory.getStack(state.pack, 3), "stove", 1), "placeSelected: not a tile just beyond reach")
	World.setPlayerPosition(world, 1, nil)
	answer(world, 1, "placeSelected", 3, 1)
	check(is(Inventory.getStack(state.pack, 3), "stove", 1), "placeSelected: not by a player with no character")

	-- The middle of tile 3, 1 is at 10, 2. A player 3 studs from it stands on the tile; one a little further does not.
	World.setPlayerPosition(world, 1, at(2, 0, 2))
	World.addPlayer(world, 2, at(0, 0, 0))
	World.setPlayerPosition(world, 2, at(13, 0, 2))
	answer(world, 1, "placeSelected", 3, 1)
	check(is(Inventory.getStack(state.pack, 3), "stove", 1), "placeSelected: not on a tile another player stands on")
	World.setPlayerPosition(world, 2, at(13.01, 0, 2))
	answer(world, 1, "placeSelected", 3, 1)
	check(Inventory.getStack(state.pack, 3) == nil, "placeSelected: on the tile once that player has stepped off it")
	World.setPlayerPosition(world, 2, nil)
	answer(world, 1, "selectHotbarSlot", 2)
	answer(world, 1, "placeSelected", 4, 1)
	check(Inventory.getStack(state.pack, 2) == nil, "placeSelected: a player with no character stands on no tile")
end

do -- using a placed item
	local world, state, crateId, stoveId = newWorld()
	answer(world, 1, "usePlaced", crateId)
	local session = state.session
	check(
		session ~= nil and session.other == world.plot.placedById[crateId].inventory,
		"usePlaced: opens the crate's inventory beside the pack"
	)
	check(world.players[1].openedPlacedId == crateId, "usePlaced: the world knows what the player has open")
	local pack, screen = World.encodeView(world, 1)
	check(screen ~= nil and screen.otherItemId == "crate", "encodeView: says what kind of thing is open")
	check(
		screen ~= nil and screen.other ~= nil and screen.other.slotCount == 27 and #screen.other.stacks == 1,
		"encodeView: and what is in it"
	)
	check(
		pack.slotCount == 36 and #pack.stacks == 3 and screen ~= nil and screen.carried == nil,
		"encodeView: with the pack, and nothing carried"
	)
	check(isPlain(pack) and isPlain(screen), "encodeView: all of it is plain data")

	answer(world, 1, "clickSlot", "other", 1, "left")
	local _, carrying = World.encodeView(world, 1)
	check(
		carrying ~= nil and is(carrying.carried, "fish", 5) and isPlain(carrying),
		"encodeView: shows the stack being carried"
	)
	answer(world, 1, "usePlaced", crateId)
	check(state.session ~= session and state.session ~= nil, "usePlaced: using it again opens it afresh")
	check(Inventory.countItems(state.pack, "fish") == 5, "usePlaced: after putting what was carried back in the pack")

	-- From 18, 10 both the crate and the stove are in reach.
	World.setPlayerPosition(world, 1, at(18, 0, 10), at(24, 0, 10))
	answer(world, 1, "usePlaced", stoveId)
	check(
		(state.session :: any).other == world.plot.placedById[crateId].inventory
			and world.players[1].openedPlacedId == crateId,
		"usePlaced: ignored for a placed item that holds nothing, even in reach"
	)
	World.setPlayerPosition(world, 1, at(6, 0, 0), at(12, 0, 0))
	for _, bad in { 0, -1, 99, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		answer(world, 1, "usePlaced", bad)
	end
	answer(world, 1, "usePlaced")
	check(world.players[1].openedPlacedId == crateId, "usePlaced: ignored for an id that is not a placed item")

	answer(world, 1, "closeInventory")
	check(
		state.session == nil and world.players[1].openedPlacedId == nil,
		"closeInventory: the player has nothing open any more"
	)
	local alone, noScreen = World.encodeView(world, 1)
	check(noScreen == nil and #alone.stacks == 4, "encodeView: no screen when none is open")
	answer(world, 1, "openPack")
	local _, packScreen = World.encodeView(world, 1)
	check(
		packScreen ~= nil and packScreen.other == nil and packScreen.otherItemId == nil,
		"encodeView: the pack open alone has no other inventory"
	)
	answer(world, 1, "closeInventory")

	World.setPlayerPosition(world, 1, at(6, 0, 22.01))
	answer(world, 1, "usePlaced", crateId)
	check(state.session == nil, "usePlaced: not from beyond reach")
	World.setPlayerPosition(world, 1, at(6, 0, 22))
	answer(world, 1, "usePlaced", crateId)
	check(state.session ~= nil, "usePlaced: from exactly at reach")
	check(
		raises("World.encodeView: no player in the world has the id 5", function()
			return World.encodeView(world, 5)
		end),
		"encodeView: refuses a player who is not in the world"
	)
end

do -- hitting a placed item
	local world, state, crateId, stoveId = newWorld()
	local other = World.addPlayer(world, 2, at(0, 0, 0))
	World.setPlayerPosition(world, 2, at(10, 0, 10))
	answer(world, 2, "usePlaced", crateId)
	answer(world, 2, "clickSlot", "other", 1, "right")
	check(is((other.session :: any).carried, "fish", 3), "a second player looks into the crate and picks up three fish")

	World.setPlayerPosition(world, 1, at(6, 0, 22.01))
	answer(world, 1, "hitPlaced", crateId)
	check(world.plot.placedById[crateId] ~= nil, "hitPlaced: not from beyond reach")
	World.setPlayerPosition(world, 1, at(6, 0, 0), at(12, 0, 0))
	for _, bad in { 0, -1, 99, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		answer(world, 1, "hitPlaced", bad)
	end
	answer(world, 1, "hitPlaced")
	check(
		world.plot.placedById[crateId] ~= nil and world.plot.placedById[stoveId] ~= nil,
		"hitPlaced: ignored for an id that is not a placed item"
	)

	answer(world, 1, "hitPlaced", crateId)
	check(world.plot.placedById[crateId] == nil, "hitPlaced: the crate is off the plot")
	check(
		other.session == nil and world.players[2].openedPlacedId == nil,
		"hitPlaced: the player who was looking into it is not any more"
	)
	check(Inventory.countItems(other.pack, "fish") == 3, "hitPlaced: what they carried is in their pack")
	check(sum(onGround(world, "crate")) == 1, "hitPlaced: the crate lies on the ground as an item")
	check(sum(onGround(world, "fish")) == 2, "hitPlaced: what was left in it is spilled on the ground")
	check(inWorld(world, "fish") == 5 and inWorld(world, "crate") == 2, "hitPlaced: nothing was made or lost")
	local allNear = true
	for _, groundItem: GroundItems.GroundItem in world.groundItems.byId :: any do
		if Position.groundDistance(groundItem.position, at(6, 0, 6)) > 2 or groundItem.droppedAt ~= 100 then
			allNear = false
		end
	end
	check(allNear, "hitPlaced: it all lies on the crate's tile, dropped at the world's time")

	local ring = Plot.new(3, 3)
	local ringCrate = Plot.place(ring, "crate", 2, 2) :: number
	local inRingCrate = ring.placedById[ringCrate].inventory :: Inventory.Inventory
	Inventory.addItems(inRingCrate, "fish", 2)
	Inventory.addItems(inRingCrate, "apple", 3)
	Inventory.addItems(inRingCrate, "log", 4)
	local ringWorld = World.new(ring, at(0, 0, 0), 0)
	World.addPlayer(ringWorld, 1, at(0, 0, 0))
	World.setPlayerPosition(ringWorld, 1, at(0, 0, 0))
	answer(ringWorld, 1, "hitPlaced", ringCrate)
	local spots: { [string]: boolean } = {}
	local spotCount, onRing = 0, true
	for _, groundItem: GroundItems.GroundItem in ringWorld.groundItems.byId :: any do
		local key = string.format("%.3f %.3f", groundItem.position.x, groundItem.position.z)
		if not spots[key] then
			spots[key] = true
			spotCount += 1
		end
		local fromMiddle = Position.groundDistance(groundItem.position, at(6, 0, 6))
		if groundItem.stack.itemId ~= "crate" and math.abs(fromMiddle - 1.7) > 0.001 then
			onRing = false
		end
	end
	check(
		spotCount == 4,
		"hitPlaced: the crate and each of the three stacks that were in it lie in a place of their own"
	)
	check(onRing, "hitPlaced: the stacks lie in a ring around the middle of the tile")
	check(Plot.canPlace(world.plot, "stove", 2, 2), "hitPlaced: and the tile holds nothing")

	World.setPlayerPosition(world, 1, at(18, 0, 10))
	answer(world, 1, "hitPlaced", stoveId)
	check(
		world.plot.placedById[stoveId] == nil and sum(onGround(world, "stove")) == 1,
		"hitPlaced: a placed item that holds nothing just becomes an item"
	)
	check(state.session == nil, "hitPlaced: the player who hit it has no screen open")
end

do -- time passing
	local world, state, crateId = newWorld()
	GroundItems.drop(world.groundItems, ItemStack.new("apple", 3), at(7, 0, 1), 100)
	World.step(world, 100.5)
	check(world.now == 100.5, "step: the world moves on to the time it was given")
	check(Inventory.countItems(state.pack, "apple") == 0, "step: a ground item just dropped is not picked up yet")
	World.step(world, 100 + GroundItems.PICKUP_DELAY)
	check(
		Inventory.countItems(state.pack, "apple") == 3 and #onGround(world, "apple") == 0,
		"step: a player picks up what lies near them"
	)

	World.addPlayer(world, 2, at(0, 0, 0))
	World.addPlayer(world, -5, at(0, 0, 0))
	World.setPlayerPosition(world, 2, at(30, 0, 30))
	World.setPlayerPosition(world, -5, at(30, 0, 30))
	GroundItems.drop(world.groundItems, ItemStack.new("stove", 1), at(31, 0, 30), 110)
	World.step(world, 120)
	check(
		Inventory.countItems(world.players[-5].state.pack, "stove") == 1
			and Inventory.countItems(world.players[2].state.pack, "stove") == 0,
		"step: of two players equally near, the one with the lower id picks up first"
	)
	World.setPlayerPosition(world, -5, nil)
	GroundItems.drop(world.groundItems, ItemStack.new("stove", 1), at(100, 0, 100), 120)
	World.setPlayerPosition(world, 2, at(100, 0, 100))
	GroundItems.drop(world.groundItems, ItemStack.new("fish", 2), at(30, 0, 30), 120)
	World.step(world, 130)
	check(
		Inventory.countItems(world.players[2].state.pack, "stove") == 1,
		"step: a player picks up where they stand now"
	)
	check(sum(onGround(world, "fish")) == 2, "step: a player with no character picks nothing up")

	answer(world, 1, "usePlaced", crateId)
	World.setPlayerPosition(world, 1, at(6, 0, 6 + World.CLOSES_BEYOND))
	World.step(world, 131)
	check(state.session ~= nil, "step: a crate stays open at exactly the distance it closes beyond")
	World.setPlayerPosition(world, 1, at(6, 0, 6.01 + World.CLOSES_BEYOND))
	World.step(world, 132)
	check(
		state.session == nil and world.players[1].openedPlacedId == nil,
		"step: and closes once the player is beyond it"
	)

	World.setPlayerPosition(world, 1, at(6, 0, 0), at(12, 0, 0))
	answer(world, 1, "usePlaced", crateId)
	answer(world, 1, "clickSlot", "other", 1, "left")
	World.setPlayerPosition(world, 1, nil)
	World.step(world, 133)
	check(state.session == nil, "step: a crate closes when the player has no character")
	check(Inventory.countItems(state.pack, "fish") == 5, "step: and what they carried is in their pack")

	World.setPlayerPosition(world, 1, at(6, 0, 0), at(12, 0, 0))
	answer(world, 1, "usePlaced", crateId)
	Plot.remove(world.plot, crateId)
	World.step(world, 134)
	check(state.session == nil, "step: a crate closes when it is no longer on the plot")

	answer(world, 1, "openPack")
	World.setPlayerPosition(world, 1, at(500, 0, 500))
	World.step(world, 135)
	check(state.session ~= nil, "step: the pack open alone stays open wherever the player goes")

	World.step(world, 120 + GroundItems.LIFETIME - 0.01)
	check(sum(onGround(world, "fish")) == 2, "step: a ground item lies until its time is up")
	World.step(world, 120 + GroundItems.LIFETIME)
	check(#onGround(world, "fish") == 0, "step: and then is gone")
	for _, bad in { "now", 0 / 0, math.huge } :: { any } do
		check(
			raises("World.step: now must be a number of seconds; got " .. tostring(bad), function()
				World.step(world, bad)
			end),
			"step: refuses the time " .. tostring(bad)
		)
	end
	check(world.now == 120 + GroundItems.LIFETIME, "step: a refused step leaves the time as it was")
end

do -- a station on the plot
	local plot = Plot.new(6, 6)
	local ovenId = Plot.place(plot, "oven", 2, 2) :: number
	local crateId = Plot.place(plot, "crate", 3, 2) :: number
	local inside = plot.placedById[ovenId].inventory :: Inventory.Inventory
	local world = World.new(plot, at(0, 0, 0), 100)
	local state = World.addPlayer(world, 1, at(0, 0, 0))
	World.setPlayerPosition(world, 1, at(6, 0, 0), at(12, 0, 0))
	Inventory.setStack(state.pack, 1, ItemStack.new("fish", 3))
	Inventory.setStack(state.pack, 2, ItemStack.new("log", 4))
	check(next(world.stations :: any) == nil, "new: a station has no record until it is stepped or used")

	answer(world, 1, "usePlaced", crateId)
	local _, crateScreen = World.encodeView(world, 1)
	check((state.session :: any).otherSlotRules == nil, "usePlaced: a crate's slots take anything")
	check(crateScreen ~= nil and crateScreen.station == nil, "encodeView: and a crate has no gauges")
	check(world.stations[crateId] == nil, "usePlaced: a crate is not a station")

	answer(world, 1, "usePlaced", ovenId)
	check((state.session :: any).otherSlotRules ~= nil, "usePlaced: a station opens with rules for its slots")
	check(world.stations[ovenId] ~= nil, "usePlaced: and has a record from then on")
	local _, screen = World.encodeView(world, 1)
	local gauges = if screen ~= nil then screen.station else nil
	check(
		gauges ~= nil and gauges.burning == 0 and gauges.working == 0,
		"encodeView: a station's gauges are sent, at nothing before it is lit"
	)
	check(
		screen ~= nil and screen.otherItemId == "oven" and isPlain(screen),
		"encodeView: with what kind of thing it is, all as plain data"
	)

	answer(world, 1, "quickMoveSlot", "pack", 2)
	answer(world, 1, "quickMoveSlot", "pack", 1)
	check(
		is(Inventory.getStack(inside, Station.INPUT_SLOT), "fish", 3)
			and is(Inventory.getStack(inside, Station.FUEL_SLOT), "log", 4),
		"quickMoveSlot: each thing goes to the slot of the station that is meant for it"
	)
	World.step(world, 104)
	local _, cooking = World.encodeView(world, 1)
	local cookingGauges = (cooking :: any).station
	check(
		math.abs(cookingGauges.burning - 0.75) < 1e-6 and math.abs(cookingGauges.working - 0.5) < 1e-6,
		"step: a station burns and works for the time that passed since the last step"
	)
	check(is(Inventory.getStack(inside, Station.FUEL_SLOT), "log", 3), "step: lighting it used a log")
	World.step(world, 108)
	check(
		is(Inventory.getStack(inside, Station.OUTPUT_SLOT), "cooked_fish", 1)
			and is(Inventory.getStack(inside, Station.INPUT_SLOT), "fish", 2),
		"step: and in time turns a fish into a cooked fish"
	)
	World.step(world, 107)
	check(
		world.stations[ovenId].worked == 0,
		"step: no time has passed for a station when the time given is earlier than the last"
	)
	World.step(world, 107)
	check(world.stations[ovenId].worked == 0, "step: nor when it is the same")
	check(
		is(Inventory.getStack(inside, Station.OUTPUT_SLOT), "cooked_fish", 1),
		"step: a time earlier than the last does nothing to a station"
	)

	answer(world, 1, "hitPlaced", ovenId)
	check(
		world.stations[ovenId] == nil and state.session == nil,
		"hitPlaced: a station's record goes with it, and its screen closes"
	)
	check(
		sum(onGround(world, "oven")) == 1
			and sum(onGround(world, "fish")) == 2
			and sum(onGround(world, "cooked_fish")) == 1
			and sum(onGround(world, "log")) == 3,
		"hitPlaced: what was in it is spilled, and the log that was burning is gone"
	)

	local idle = Plot.new(3, 3)
	local idleOven = Plot.place(idle, "oven", 1, 1) :: number
	local idleInside = idle.placedById[idleOven].inventory :: Inventory.Inventory
	Inventory.setStack(idleInside, Station.INPUT_SLOT, ItemStack.new("fish", 2))
	Inventory.setStack(idleInside, Station.FUEL_SLOT, ItemStack.new("log", 1))
	local idleWorld = World.new(idle, at(0, 0, 0), 0)
	World.step(idleWorld, 0)
	World.step(idleWorld, 16)
	check(
		is(Inventory.getStack(idleInside, Station.OUTPUT_SLOT), "cooked_fish", 2),
		"step: a station works with no player in the world at all"
	)
	check(
		idleWorld.stations[idleOven] ~= nil and not Station.isBurning(idleWorld.stations[idleOven]),
		"step: and its fire is out when the log has burnt"
	)

	local two = Plot.new(3, 3)
	local first = Plot.place(two, "oven", 1, 1) :: number
	local second = Plot.place(two, "oven", 2, 1) :: number
	for _, id in { first, second } do
		local oven = two.placedById[id].inventory :: Inventory.Inventory
		Inventory.setStack(oven, Station.INPUT_SLOT, ItemStack.new("fish", 1))
		Inventory.setStack(oven, Station.FUEL_SLOT, ItemStack.new("log", 1))
	end
	local twoWorld = World.new(two, at(0, 0, 0), 0)
	World.step(twoWorld, 8)
	check(
		is(
			Inventory.getStack(two.placedById[first].inventory :: Inventory.Inventory, Station.OUTPUT_SLOT),
			"cooked_fish",
			1
		)
			and is(
				Inventory.getStack(two.placedById[second].inventory :: Inventory.Inventory, Station.OUTPUT_SLOT),
				"cooked_fish",
				1
			),
		"step: every station on the plot works, each on its own"
	)
end

do -- a player leaves
	local world, state, crateId = newWorld()
	answer(world, 1, "usePlaced", crateId)
	answer(world, 1, "clickSlot", "other", 1, "left")
	World.removePlayer(world, 1)
	check(world.players[1] == nil, "removePlayer: the player is out of the world")
	check(
		state.session == nil and Inventory.countItems(state.pack, "fish") == 5,
		"removePlayer: what they carried is in the pack they leave with"
	)
	check(
		Inventory.isEmpty(world.plot.placedById[crateId].inventory :: Inventory.Inventory),
		"removePlayer: and not in the crate"
	)

	local full, fullState, fullCrate = newWorld()
	for slot = 1, PlayerState.PACK_SLOTS do
		Inventory.setStack(fullState.pack, slot, ItemStack.new("stove", 1))
	end
	answer(full, 1, "usePlaced", fullCrate)
	answer(full, 1, "clickSlot", "other", 1, "left")
	World.removePlayer(full, 1)
	check(
		sum(onGround(full, "fish")) == 5,
		"removePlayer: a carried stack the pack has no room for is left on the ground"
	)
	local left: GroundItems.GroundItem = (full.groundItems.byId :: any)[1]
	check(left.position.x == 12, "removePlayer: where their drops land")
end

do -- whatever players' machines send, and wherever they go, nothing raises an error and no item is made or lost
	local seed = 9001
	local function random(limit: number): number
		seed = (seed * 1103515245 + 12345) % 2147483648
		return math.floor(seed / 65536) % limit + 1
	end
	local junk: { any } =
		{ -1, 0, 0.5, 1e300, 0 / 0, math.huge, "", "pack", "other", "left", "1", true, false, {}, { 1 } }
	local function argument(): any
		local kind = random(10)
		if kind <= 2 then
			return if random(4) == 1 then "other" else "pack"
		elseif kind <= 6 then
			return random(9)
		elseif kind == 7 then
			return if random(2) == 1 then "left" else "right"
		elseif kind == 8 then
			return nil
		end
		return junk[random(#junk)]
	end
	local names: { any } = table.clone(World.REQUEST_NAMES)
	for _ = 1, 3 do
		table.insert(names, "placeSelected")
		table.insert(names, "usePlaced")
		table.insert(names, "hitPlaced")
	end
	for _, extra in { "askForInventory", "nonsense", 12 } :: { any } do
		table.insert(names, extra)
	end

	local errors, firstError = 0, ""
	local constantBetweenSteps, neverMore, exactWhenYoung = true, true, true
	for round = 1, 24 do
		-- In the even rounds time moves slowly, so nothing lies long enough to expire and every item must still be there.
		local slow = round % 2 == 0
		local plot = Plot.new(6, 6)
		local world = World.new(plot, at(0, 0, 0), 0)
		local now = 0
		local playerIds = { 1, 2, 3 }
		local gone: { [string]: number } = {}
		local function total(itemId: string): number
			return inWorld(world, itemId) + (gone[itemId] or 0)
		end
		for _, playerId in playerIds do
			local state = World.addPlayer(world, playerId, at(12, 0, 12))
			for _ = 1, 6 do
				local itemId = itemIds[random(#itemIds)]
				Inventory.addItems(state.pack, itemId, random(ItemRegistry.get(itemId).stackSize))
			end
		end
		local before: { [string]: number } = {}
		for _, itemId in itemIds do
			before[itemId] = total(itemId)
		end
		for _ = 1, 500 do
			local action = random(20)
			local playerId = playerIds[random(#playerIds)]
			local stepped = false
			local ok, problem = true, nil
			if action <= 12 then
				ok, problem = pcall(answer, world, playerId, names[random(#names)], argument(), argument(), argument())
			elseif action <= 16 then
				if world.players[playerId] ~= nil then
					if random(8) == 1 then
						World.setPlayerPosition(world, playerId, nil)
					else
						local standing = at(random(28) - 2, 0, random(28) - 2)
						World.setPlayerPosition(world, playerId, standing, at(standing.x + 6, 0, standing.z))
					end
				end
			elseif action <= 18 then
				now += if slow then 0.2 else random(60)
				stepped = true
				ok, problem = pcall(World.step, world, now)
			elseif action == 19 then
				local player = world.players[playerId]
				if player ~= nil then
					World.removePlayer(world, playerId)
					for _, itemId in itemIds do
						gone[itemId] = (gone[itemId] or 0) + Inventory.countItems(player.state.pack, itemId)
					end
				end
			elseif world.players[playerId] == nil then
				World.addPlayer(world, playerId, at(12, 0, 12))
			end
			if not ok then
				errors += 1
				firstError = if firstError == "" then tostring(problem) else firstError
			end
			for _, itemId in itemIds do
				local after = total(itemId)
				if after > before[itemId] then
					neverMore = false
				elseif after < before[itemId] and not stepped then
					constantBetweenSteps = false
				elseif after < before[itemId] and slow then
					exactWhenYoung = false
				end
				before[itemId] = after
			end
		end
	end
	check(errors == 0, "12,000 random moves: none raises an error (first: " .. firstError .. ")")
	check(neverMore, "12,000 random moves: no item is ever made")
	check(constantBetweenSteps, "12,000 random moves: no item is lost except when time passes")
	check(exactWhenYoung, "12,000 random moves: and none is lost then either, until it has lain on the ground too long")
end

Check.finish("World")
