--!strict
-- Tests for World. Run from the repository root: lune run tests/world/World.test.luau

local Check = require("../Check")
local GroundItems = require("../../src/shared/world/GroundItems")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")
local Station = require("../../src/shared/stations/Station")
local StationProgress = require("../../src/shared/stations/StationProgress")
local World = require("../../src/shared/world/World")

local check = Check.that
local STILL = { x = 0, y = 0, z = 0 }

ItemRegistry.register({ id = "log", stackSize = 16, burnSeconds = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "apple", stackSize = 16 })
ItemRegistry.register({ id = "stove", stackSize = 1 })
ItemRegistry.register({ id = "crate", stackSize = 1 })
ItemRegistry.register({ id = "post", stackSize = 8 })
ItemRegistry.register({ id = "cooked_fish", stackSize = 8 })
ItemRegistry.register({ id = "oven", stackSize = 1 })
RecipeRegistry.register({ station = "oven", input = "fish", output = "cooked_fish", seconds = 8 })

local itemIds = { "log", "fish", "apple", "stove", "crate", "post" }
local at = Position.new
local ALONG_X = { x = 1, y = 0, z = 0 }

-- True if `groundItem` is at `x`, `y`, `z`, to within a rounding error.
local function isAt(groundItem: GroundItems.GroundItem, x: number, y: number, z: number): boolean
	return Position.getDistance(groundItem.position, at(x, y, z)) < 1e-9
end

-- True if `groundItem` was spawned moving at `x`, `y`, `z` studs a second, to within a rounding error.
local function wasSpawnedMovingAt(groundItem: GroundItems.GroundItem, x: number, y: number, z: number): boolean
	local velocity = groundItem.spawnVelocity
	return math.abs(velocity.x - x) < 1e-9 and math.abs(velocity.y - y) < 1e-9 and math.abs(velocity.z - z) < 1e-9
end

-- How many ground items there are.
local function groundItemCount(world: World.World): number
	local count = 0
	for _ in world.groundItems.itemsById do
		count += 1
	end
	return count
end

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

-- The ground items that hold one item, as a list sorted by count.
local function groundStacks(world: World.World, itemId: string): { GroundItems.GroundItem }
	local found: { GroundItems.GroundItem } = {}
	for _, groundItem in world.groundItems.itemsById do
		if groundItem.stack.itemId == itemId then
			table.insert(found, groundItem)
		end
	end
	table.sort(found, function(a: GroundItems.GroundItem, b: GroundItems.GroundItem): boolean
		return a.stack.count < b.stack.count
	end)
	return found
end

-- How many of one item lie on the ground.
local function onGround(world: World.World, itemId: string): number
	local total = 0
	for _, groundItem in groundStacks(world, itemId) do
		total += groundItem.stack.count
	end
	return total
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

-- How many of one item the whole world holds: in packs, carried, standing on the plot, inside what
-- stands on the plot, and on the ground. A placed object counts as one of the item that its kind is
-- named for.
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

-- The ids of everything that stands on the plot, lowest first.
local function placedIds(world: World.World): { number }
	local ids = {}
	for id in world.plot.placedObjectsById do
		table.insert(ids, id)
	end
	table.sort(ids)
	return ids
end

-- Stands an object of the kind `kindId` on a tile of the world's plot, and gives it what these
-- tests give one of that kind: a crate an inventory of 27 slots, and an oven a station of its own.
-- Any other kind is given nothing.
local function place(world: World.World, kindId: string, tileX: number, tileZ: number): number
	local placedObjectId = Plot.placeObject(world.plot, kindId, tileX, tileZ)
	if kindId == "crate" then
		World.addPlacedObjectInventory(world, placedObjectId, Inventory.new(27))
	elseif kindId == "oven" then
		World.addStation(world, placedObjectId, Station.new("oven", Inventory.new(3)))
	end
	return placedObjectId
end

-- A world at time 100 with a plot of 6 by 6 tiles whose corner is at the origin, so that the middle of
-- tile x, z is at x * 4 - 2, z * 4 - 2. A crate holding 5 fish stands on tile 2, 2 (its middle is 6, 6),
-- a stove, which was given nothing, on tile 5, 5 (its middle is 18, 18) and an oven on tile 4, 2 (its
-- middle is 14, 6). Player 1 has 12 logs in their first slot, and their character is at 6, 0.
local function newWorld(): (World.World, PlayerState.PlayerState, { crate: number, stove: number, oven: number })
	local world = World.new(Plot.new(6, 6), at(0, 0, 0), 100)
	local crateId = place(world, "crate", 2, 2)
	Inventory.addItems(insideOf(world, crateId), "fish", 5)
	local stoveId = place(world, "stove", 5, 5)
	local ovenId = place(world, "oven", 4, 2)
	local state = World.addPlayer(world, 1)
	Inventory.setStack(state.pack, 1, ItemStack.new("log", 12))
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	return world, state, { crate = crateId, stove = stoveId, oven = ovenId }
end

-- Opens a player's screen on the inventory inside a placed object, with no rule for its slots.
local function openOn(world: World.World, state: PlayerState.PlayerState, placedObjectId: number)
	World.openPlacedObjectScreen(world, state, placedObjectId, insideOf(world, placedObjectId))
end

-- Takes a placed object off the plot, and throws one of the item its kind is named for and then
-- every stack that was inside it from its tile, as a hit does. Does nothing if no placed object has
-- that id.
local function knockOff(world: World.World, placedObjectId: number)
	local placedObject = world.plot.placedObjectsById[placedObjectId]
	if placedObject == nil then
		return
	end
	local inside = findInside(world, placedObjectId)
	local stacks = if inside ~= nil then Inventory.takeEveryStack(inside) else {}
	table.insert(stacks, 1, ItemStack.new(placedObject.kindId, 1))
	Plot.removePlacedObject(world.plot, placedObjectId)
	World.throwStacksFromTile(world, stacks, placedObject.tileX, placedObject.tileZ)
end

do -- the numbers the world goes by
	check(World.SCREEN_CLOSES_BEYOND == World.REACH + 4, "CLOSES_BEYOND: a screen closes 4 studs beyond reach")
	check(
		World.TILE_STOOD_ON_WITHIN == Plot.TILE_SIZE * 0.75,
		"TILE_STOOD_ON_WITHIN: a player stands on a tile within three quarters of its width of its middle"
	)
end

do -- a new world
	local plot = Plot.new(3, 3)
	local corner = at(4, 1, -8)
	local world = World.new(plot, corner, 50)
	check(world.plot == plot, "new: holds the plot it was given")
	check(world.plotCorner == corner, "new: knows where the plot's corner is")
	check(world.now == 50, "new: starts at the time it was given")
	check(next(world.players) == nil, "new: has no players")
	check(next(world.groundItems.itemsById) == nil, "new: has nothing on the ground")
	check(
		next(world.placedObjectInventories) == nil and next(world.stations) == nil,
		"new: no placed object has an inventory or is a station"
	)
end

do -- what a placed object is given
	local plot = Plot.new(4, 4)
	local early = Plot.placeObject(plot, "crate", 1, 1)
	local world = World.new(plot, at(0, 0, 0), 0)
	check(
		world.placedObjectInventories[early] == nil and world.stations[early] == nil,
		"new: a placed object that already stood on the plot has no inventory and is no station"
	)
	local inventory = Inventory.new(27)
	World.addPlacedObjectInventory(world, early, inventory)
	check(
		world.placedObjectInventories[early] == inventory,
		"addPlacedObjectInventory: the world keeps the inventory given, by the placed object's id"
	)
	check(world.stations[early] == nil, "addPlacedObjectInventory: and the placed object is no station for it")
	check(
		Check.raises("the placed object 1 was given an inventory already", function()
			World.addPlacedObjectInventory(world, early, Inventory.new(3))
		end) and world.placedObjectInventories[early] == inventory,
		"addPlacedObjectInventory: fails for a placed object that was given one, which keeps the one it had"
	)
	check(
		Check.raises("no placed object has the id 99", function()
			World.addPlacedObjectInventory(world, 99, Inventory.new(3))
		end) and world.placedObjectInventories[99] == nil,
		"addPlacedObjectInventory: fails for an id that no placed object has"
	)

	local ovenId = Plot.placeObject(plot, "oven", 2, 1)
	local station = Station.new("oven", Inventory.new(3))
	World.addStation(world, ovenId, station)
	check(world.stations[ovenId] == station, "addStation: the world keeps the station given, by the placed object's id")
	check(
		world.placedObjectInventories[ovenId] == nil,
		"addStation: and the placed object is given no inventory besides the station's own"
	)
	check(
		Check.raises("the placed object 2 was made a station already", function()
			World.addStation(world, ovenId, Station.new("oven", Inventory.new(3)))
		end) and world.stations[ovenId] == station,
		"addStation: fails for a placed object that was made one, which stays the one it was"
	)
	check(Check.raises("no placed object has the id 99", function()
		World.addStation(world, 99, Station.new("oven", Inventory.new(3)))
	end) and world.stations[99] == nil, "addStation: fails for an id that no placed object has")
	World.addStation(world, early, Station.new("oven", inventory))
	check(
		world.stations[early] ~= nil and world.placedObjectInventories[early] == inventory,
		"addStation: a placed object that was given an inventory may be made a station too"
	)

	local plain = Plot.placeObject(plot, "stove", 3, 1)
	check(
		world.placedObjectInventories[plain] == nil and world.stations[plain] == nil,
		"Plot.placeObject on the world's plot: a placed object is given nothing by being placed"
	)

	Plot.removePlacedObject(plot, early)
	check(
		world.placedObjectInventories[early] == nil and world.stations[early] == nil,
		"Plot.removePlacedObject on the world's plot: the inventory and the station it was given go with it"
	)
	check(
		world.stations[ovenId] == station,
		"Plot.removePlacedObject on the world's plot: and another placed object keeps what it was given"
	)
	local again = Plot.placeObject(plot, "crate", 1, 1)
	check(
		world.placedObjectInventories[again] == nil and world.stations[again] == nil,
		"Plot.placeObject on the world's plot: an object placed where one stood before is given nothing of the old one's"
	)
end

do -- players come and go
	local world = World.new(Plot.new(3, 3), at(0, 0, 0), 0)
	local state = World.addPlayer(world, 7)
	check(world.players[7] == state, "addPlayer: returns the player now in the world")
	check(Inventory.isEmpty(state.pack), "addPlayer: with no pack given, the pack holds nothing")
	check(state.pack.slotCount == PlayerState.PACK_SLOT_COUNT, "addPlayer: and has the slots of any pack")
	check(
		state.screen == nil and World.getOpenedPlacedObjectId(world, state) == nil,
		"addPlayer: a new player has no screen open"
	)
	check(state.character == nil, "addPlayer: and has no character yet")
	local second = World.addPlayer(world, -3)
	check(
		second ~= state and world.players[-3] == second,
		"addPlayer: a second player is another state, and an id may be negative"
	)

	local pack = Inventory.new(PlayerState.PACK_SLOT_COUNT)
	Inventory.setStack(pack, 4, ItemStack.new("apple", 6))
	local carrying = World.addPlayer(world, 8, pack)
	check(carrying.pack == pack, "addPlayer: a player given a pack carries that pack")
	check(is(Inventory.getStack(carrying.pack, 4), "apple", 6), "addPlayer: with what is in it")
	local alreadyThere = Check.errorFrom(function()
		World.addPlayer(world, 7)
	end)
	check(
		alreadyThere ~= nil and string.find(alreadyThere, "player 7 is already in the world", 1, true) ~= nil,
		"addPlayer: fails if a player already has that id"
	)
	check(world.players[7] == state, "addPlayer: and the player who was there stays")

	check(World.removePlayer(world, 7) == state, "removePlayer: returns the player it took out")
	check(world.players[7] == nil and world.players[-3] == second, "removePlayer: and leaves the others")
	check(World.removePlayer(world, 7) == nil, "removePlayer: returns nothing for an id that is not in the world")
	check(World.removePlayer(world, 999) == nil, "removePlayer: nor for an id that never was")
	check(world.players[-3] == second and world.players[8] == carrying, "removePlayer: and changes nothing then")
	check(World.addPlayer(world, 7) ~= state, "addPlayer: a player who comes back starts afresh")
end

do -- a player's character
	local world, state = newWorld()
	local character = state.character
	check(
		character ~= nil and character.position.x == 6 and character.position.z == 0,
		"setCharacterPosition: the player's character is at the position given"
	)
	World.setCharacterPosition(world, 1, at(3, 0, 3))
	local moved = state.character
	check(
		moved ~= nil and moved.position.x == 3 and moved.position.z == 3,
		"setCharacterPosition: a later position takes its place"
	)
	World.removeCharacter(world, 1)
	check(state.character == nil, "removeCharacter: the player has no character")
	World.removeCharacter(world, 1)
	check(state.character == nil, "removeCharacter: does nothing for a player with no character")
	World.setCharacterPosition(world, 1, at(3, 0, 3))
	check(state.character ~= nil, "setCharacterPosition: a player who had no character has one from now on")
	local nobodyToRemove = Check.errorFrom(function()
		World.removeCharacter(world, 2)
	end)
	check(
		nobodyToRemove ~= nil and string.find(nobodyToRemove, "no player has the id 2", 1, true) ~= nil,
		"removeCharacter: fails if no player has that id"
	)
	local nobody = Check.errorFrom(function()
		World.setCharacterPosition(world, 2, at(0, 0, 0))
	end)
	check(
		nobody ~= nil and string.find(nobody, "no player has the id 2", 1, true) ~= nil,
		"setCharacterPosition: fails if no player has that id"
	)

	-- Losing the character closes the screen, while there is still a character to throw from.
	local full, fullState, fullIds = newWorld()
	for slot = 1, PlayerState.PACK_SLOT_COUNT do
		Inventory.setStack(fullState.pack, slot, ItemStack.new("stove", 1))
	end
	openOn(full, fullState, fullIds.crate)
	InventoryScreen.pickUpFromSlot(fullState.screen :: any, "other", 1)
	World.removeCharacter(full, 1)
	check(
		fullState.screen == nil and World.getOpenedPlacedObjectId(full, fullState) == nil and fullState.character == nil,
		"removeCharacter: a player who loses their character has their screen closed"
	)
	local fish = groundStacks(full, "fish")
	check(
		#fish == 1 and is(fish[1].stack, "fish", 5) and isAt(fish[1], 6, World.CHARACTER_THROW_START_HEIGHT, 0),
		"removeCharacter: and what they carried is thrown from where the character was"
	)
end

do -- spawning a stack
	local world = newWorld()
	local id = World.spawnStack(world, ItemStack.new("apple", 3), at(60, 3, 60), { x = 2, y = 5, z = -1 })
	local apple = world.groundItems.itemsById[id]
	check(is(apple.stack, "apple", 3), "spawnStack: the stack is a ground item, and its id is returned")
	check(isAt(apple, 60, 3, 60), "spawnStack: at the position given")
	check(wasSpawnedMovingAt(apple, 2, 5, -1), "spawnStack: moving at the velocity given")
	check(apple.spawnTime == 100, "spawnStack: spawned at the world's time")
	World.advanceTo(world, 150)
	local beside = World.spawnStack(world, ItemStack.new("apple", 2), at(60.5, 3, 60), STILL)
	check(
		beside ~= id and #groundStacks(world, "apple") == 2,
		"spawnStack: a stack spawned beside its own kind is a new ground item all the same"
	)
	check(world.groundItems.itemsById[beside].spawnTime == 150, "spawnStack: spawned at the time the world has reached")
end

do -- throwing a stack from a character
	local world = newWorld()
	World.throwStackFromCharacter(world, ItemStack.new("apple", 3), at(60, 2, 60), ALONG_X)
	local apples = groundStacks(world, "apple")
	check(#apples == 1 and is(apples[1].stack, "apple", 3), "throwStackFromCharacter: the stack is a ground item")
	check(
		isAt(apples[1], 60, 2 + World.CHARACTER_THROW_START_HEIGHT, 60),
		"throwStackFromCharacter: it spawns above the character's feet"
	)
	check(
		wasSpawnedMovingAt(apples[1], World.CHARACTER_THROW_FORWARD_SPEED, World.CHARACTER_THROW_UPWARD_SPEED, 0),
		"throwStackFromCharacter: a direction along the ground throws at the forward speed that way, and at the upward speed upwards"
	)
	World.throwStackFromCharacter(world, ItemStack.new("fish", 1), at(0, 0, 0), { x = 0, y = 0, z = -1 })
	check(
		wasSpawnedMovingAt(
			groundStacks(world, "fish")[1],
			0,
			World.CHARACTER_THROW_UPWARD_SPEED,
			-World.CHARACTER_THROW_FORWARD_SPEED
		),
		"throwStackFromCharacter: another direction throws that way"
	)
	World.throwStackFromCharacter(world, ItemStack.new("log", 1), at(0, 0, 0), { x = 0.6, y = 0.8, z = 0 })
	check(
		wasSpawnedMovingAt(
			groundStacks(world, "log")[1],
			0.6 * World.CHARACTER_THROW_FORWARD_SPEED,
			0.8 * World.CHARACTER_THROW_FORWARD_SPEED + World.CHARACTER_THROW_UPWARD_SPEED,
			0
		),
		"throwStackFromCharacter: a direction that points up throws at the forward speed along it, with the upward speed added"
	)
	World.throwStackFromCharacter(world, ItemStack.new("post", 1), at(0, 0, 0), { x = 0, y = -1, z = 0 })
	check(
		wasSpawnedMovingAt(
			groundStacks(world, "post")[1],
			0,
			World.CHARACTER_THROW_UPWARD_SPEED - World.CHARACTER_THROW_FORWARD_SPEED,
			0
		),
		"throwStackFromCharacter: a direction straight down throws straight down, slowed by the upward speed"
	)
	check(
		World.CHARACTER_THROW_START_HEIGHT == 3
			and World.CHARACTER_THROW_FORWARD_SPEED == 24
			and World.CHARACTER_THROW_UPWARD_SPEED == 8,
		"a character throws from 3 studs above its feet, at 24 studs a second forwards and 8 upwards"
	)
end

do -- a ground item's position
	local world = newWorld()
	local flying = World.spawnStack(world, ItemStack.new("apple", 3), at(60, 3, 60), { x = 24, y = 8, z = 0 })
	World.setGroundItemPosition(world, flying, at(66, 0, 60))
	local moved = world.groundItems.itemsById[flying]
	check(isAt(moved, 66, 0, 60), "setGroundItemPosition: the ground item is at the position given")
	check(
		is(moved.stack, "apple", 3) and moved.spawnTime == 100 and wasSpawnedMovingAt(moved, 24, 8, 0),
		"setGroundItemPosition: and is otherwise as it was"
	)

	World.spawnStack(world, ItemStack.new("apple", 2), at(80, 0, 60), STILL)
	World.setGroundItemPosition(world, flying, at(80.5, 0, 60))
	check(
		#groundStacks(world, "apple") == 2 and isAt(world.groundItems.itemsById[flying], 80.5, 0, 60),
		"setGroundItemPosition: a ground item that comes to be beside its own kind is still a ground item of its own"
	)
	World.setGroundItemPosition(world, 999, at(0, 0, 0))
	check(
		groundItemCount(world) == 2 and onGround(world, "apple") == 5,
		"setGroundItemPosition: does nothing for an id that no ground item has"
	)
end

do -- time passing: ground items merge
	local world = newWorld()
	local lying = World.spawnStack(world, ItemStack.new("apple", 2), at(80, 0, 60), STILL)
	local flying = World.spawnStack(world, ItemStack.new("apple", 3), at(60, 3, 60), { x = 24, y = 8, z = 0 })
	World.advanceTo(world, 101)
	check(#groundStacks(world, "apple") == 2, "advanceTo: ground items of one kind that are apart stay apart")
	World.setGroundItemPosition(world, flying, at(80.5, 0, 60))
	World.advanceTo(world, 101)
	local apples = groundStacks(world, "apple")
	check(
		#apples == 1 and is(apples[1].stack, "apple", 5) and world.groundItems.itemsById[lying] == nil,
		"advanceTo: of two ground items of one kind that have come close together, the bigger takes in the smaller"
	)
	check(isAt(world.groundItems.itemsById[flying], 80.5, 0, 60), "advanceTo: the bigger one stays where it is")
	local spawned = World.spawnStack(world, ItemStack.new("apple", 4), at(80.5, 0, 60), STILL)
	World.advanceTo(world, 101)
	check(
		#groundStacks(world, "apple") == 1
			and onGround(world, "apple") == 9
			and world.groundItems.itemsById[spawned] == nil,
		"advanceTo: a stack spawned beside a bigger one of its kind is taken in by it"
	)

	World.spawnStack(world, ItemStack.new("apple", 16), at(80.5, 0, 60), STILL)
	World.advanceTo(world, 104)
	check(
		#groundStacks(world, "apple") == 2 and onGround(world, "apple") == 25,
		"advanceTo: one that does not fit with its own kind stays a ground item of its own"
	)

	-- Ground items that lie still are checked again when they have been in the world for another
	-- `GroundItems.MERGE_CHECK_SECONDS`. A full stack, spawned at the time 100, and a part stack lie
	-- side by side. Player 2 has room for six apples, comes to stand on the full stack and picks six
	-- of it up, which moves neither ground item.
	local still = newWorld()
	local onePack = Inventory.new(1)
	Inventory.addItems(onePack, "apple", 10)
	World.addPlayer(still, 2, onePack)
	local full = World.spawnStack(still, ItemStack.new("apple", 16), at(80, 0, 60), STILL)
	World.advanceTo(still, 101)
	local part = World.spawnStack(still, ItemStack.new("apple", 3), at(81, 0, 60), STILL)
	World.advanceTo(still, 101.6)
	World.setCharacterPosition(still, 2, at(80, 0, 60))
	World.advanceTo(still, 101.7)
	check(
		is(still.groundItems.itemsById[full].stack, "apple", 10)
			and is(still.groundItems.itemsById[part].stack, "apple", 3),
		"advanceTo: (set up) six of the full stack are picked up, which leaves room in it for the part stack"
	)
	World.advanceTo(still, 101.99)
	check(
		#groundStacks(still, "apple") == 2,
		"advanceTo: ground items that lie still are not checked again until two seconds after they were spawned"
	)
	World.advanceTo(still, 102)
	check(
		still.groundItems.itemsById[part] == nil and is(still.groundItems.itemsById[full].stack, "apple", 13),
		"advanceTo: a ground item that has lain for two seconds is checked again, and takes in one beside it that now fits"
	)

	-- Merging comes before picking up. Player 1 stands at 6, 0, 0.
	local order, orderState = newWorld()
	World.spawnStack(order, ItemStack.new("apple", 2), at(7, 0, 1), STILL)
	World.advanceTo(order, 100 + GroundItems.PICKUP_DELAY_SECONDS - 0.1)
	World.spawnStack(order, ItemStack.new("apple", 3), at(7.5, 0, 1), STILL)
	World.advanceTo(order, 100 + GroundItems.PICKUP_DELAY_SECONDS)
	check(
		Inventory.countItems(orderState.pack, "apple") == 0 and #groundStacks(order, "apple") == 1,
		"advanceTo: merging comes before picking up, so two stacks that merged are not picked up until the newer could be"
	)
end

do -- closing a player's screen
	local world, state, ids = newWorld()
	World.closeScreen(world, state)
	check(
		state.screen == nil and next(world.groundItems.itemsById) == nil,
		"closeScreen: does nothing if no screen is open"
	)

	PlayerState.openScreen(state)
	World.closeScreen(world, state)
	check(state.screen == nil, "closeScreen: the screen is gone")

	openOn(world, state, ids.crate)
	InventoryScreen.pickUpFromSlot(state.screen :: any, "other", 1)
	check(
		is((state.screen :: any).carriedStack, "fish", 5) and Inventory.countItems(state.pack, "fish") == 0,
		"closeScreen: (set up) the player carries the fish out of the crate"
	)
	World.closeScreen(world, state)
	check(
		state.screen == nil and World.getOpenedPlacedObjectId(world, state) == nil,
		"closeScreen: nothing is open afterwards"
	)
	check(Inventory.countItems(state.pack, "fish") == 5, "closeScreen: what was carried goes back into the pack")
	check(Inventory.isEmpty(insideOf(world, ids.crate)), "closeScreen: and not into the crate")
	check(
		next(world.groundItems.itemsById) == nil,
		"closeScreen: and nothing lands on the ground when the pack has room"
	)

	-- A pack with no room for the carried stack: it is dropped at the player's character.
	for slot = 1, PlayerState.PACK_SLOT_COUNT do
		Inventory.setStack(state.pack, slot, ItemStack.new("stove", 1))
	end
	Inventory.setStack(insideOf(world, ids.crate), 1, ItemStack.new("fish", 5))
	openOn(world, state, ids.crate)
	InventoryScreen.pickUpFromSlot(state.screen :: any, "other", 1)
	World.closeScreen(world, state)
	local fish = groundStacks(world, "fish")
	check(
		#fish == 1 and is(fish[1].stack, "fish", 5),
		"closeScreen: what the pack has no room for is loose in the world"
	)
	check(
		isAt(fish[1], 6, World.CHARACTER_THROW_START_HEIGHT, 0) and wasSpawnedMovingAt(fish[1], 0, 0, 0),
		"closeScreen: dropped where a throw from the player's character starts, not moving"
	)
	check(state.screen == nil, "closeScreen: and the screen is closed all the same")

	-- A part fits and the rest is left over.
	local world2, state2, ids2 = newWorld()
	for slot = 1, PlayerState.PACK_SLOT_COUNT do
		Inventory.setStack(state2.pack, slot, ItemStack.new("fish", 8))
	end
	Inventory.setStack(state2.pack, 10, ItemStack.new("fish", 6))
	openOn(world2, state2, ids2.crate)
	InventoryScreen.pickUpFromSlot(state2.screen :: any, "other", 1)
	World.closeScreen(world2, state2)
	check(
		is(Inventory.getStack(state2.pack, 10), "fish", 8) and onGround(world2, "fish") == 3,
		"closeScreen: the carried stack fills what room there is, and the rest lies on the ground"
	)

	-- A screen with nothing carried puts nothing anywhere.
	local world3, state3, ids3 = newWorld()
	PlayerState.openScreen(state3)
	World.closeScreen(world3, state3)
	check(
		Inventory.countItems(state3.pack, "log") == 12 and next(world3.groundItems.itemsById) == nil,
		"closeScreen: a screen with nothing carried changes nothing else"
	)

	-- A screen closed behind the world's back leaves nothing that a later screen could be taken for.
	openOn(world3, state3, ids3.crate)
	PlayerState.closeScreen(state3)
	PlayerState.openScreen(state3)
	check(
		World.getOpenedPlacedObjectId(world3, state3) == nil,
		"getOpenedPlacedObjectId: nil for a pack opened after a placed object's screen was closed by PlayerState.closeScreen"
	)
end

do -- opening a placed object's screen
	local world, state, ids = newWorld()
	check(
		World.getOpenedPlacedObjectId(world, state) == nil,
		"getOpenedPlacedObjectId: nil for a player with no screen open"
	)
	PlayerState.openScreen(state)
	check(
		World.getOpenedPlacedObjectId(world, state) == nil,
		"getOpenedPlacedObjectId: nil while the player's pack is open alone"
	)
	World.closeScreen(world, state)

	local crateInside = insideOf(world, ids.crate)
	World.openPlacedObjectScreen(world, state, ids.crate, crateInside)
	local screen = state.screen
	check(screen ~= nil and screen.pack == state.pack, "openPlacedObjectScreen: the screen shows the player's pack")
	check(
		screen ~= nil and screen.otherInventory == crateInside,
		"openPlacedObjectScreen: and the inventory given beside it"
	)
	check(
		World.getOpenedPlacedObjectId(world, state) == ids.crate,
		"getOpenedPlacedObjectId: the placed object that the player's screen was opened on"
	)
	check(
		screen ~= nil and screen.otherSlotAcceptsItem == nil,
		"openPlacedObjectScreen: with no rule given, the inventory's slots take anything"
	)

	local first = state.screen
	World.openPlacedObjectScreen(world, state, ids.crate, crateInside)
	check(state.screen ~= first and state.screen ~= nil, "openPlacedObjectScreen: opening it again opens it afresh")

	-- Another screen is closed first, as closeScreen does.
	InventoryScreen.pickUpFromSlot(state.screen :: any, "other", 1)
	local ovenInside = insideOf(world, ids.oven)
	local onlyLogsInSlotOne = function(slot: number, itemId: string): boolean
		return slot == 1 and itemId == "log"
	end
	World.openPlacedObjectScreen(world, state, ids.oven, ovenInside, onlyLogsInSlotOne)
	check(
		World.getOpenedPlacedObjectId(world, state) == ids.oven,
		"openPlacedObjectScreen: another placed object's screen opens in place of the first"
	)
	check(
		Inventory.countItems(state.pack, "fish") == 5 and onGround(world, "fish") == 0,
		"openPlacedObjectScreen: what was carried on the screen it replaces is back in the pack"
	)
	local ovenScreen = state.screen :: InventoryScreen.InventoryScreen
	check(ovenScreen.otherInventory == ovenInside, "openPlacedObjectScreen: beside the inventory given this time")
	check(
		InventoryScreen.slotAcceptsItem(ovenScreen, "other", 1, "log")
			and not InventoryScreen.slotAcceptsItem(ovenScreen, "other", 1, "fish")
			and not InventoryScreen.slotAcceptsItem(ovenScreen, "other", 2, "log"),
		"openPlacedObjectScreen: the inventory's slots take what the rule given says"
	)
	check(
		InventoryScreen.slotAcceptsItem(ovenScreen, "pack", 1, "fish"),
		"openPlacedObjectScreen: while the pack takes anything"
	)

	-- The inventory need not be one the world keeps for that placed object.
	local loose = Inventory.new(2)
	World.openPlacedObjectScreen(world, state, ids.stove, loose)
	check(
		(state.screen :: InventoryScreen.InventoryScreen).otherInventory == loose
			and World.getOpenedPlacedObjectId(world, state) == ids.stove,
		"openPlacedObjectScreen: any inventory may be shown as the screen of a placed object"
	)

	-- Nothing to open: the screen stays as it was.
	local before = state.screen
	check(
		Check.raises("no placed object has the id 999", function()
			World.openPlacedObjectScreen(world, state, 999, loose)
		end),
		"openPlacedObjectScreen: fails for an id that no placed object has"
	)
	check(
		state.screen == before and World.getOpenedPlacedObjectId(world, state) == ids.stove,
		"openPlacedObjectScreen: and changes nothing then, the screen that was open stays open"
	)
	local other = World.addPlayer(world, 2)
	check(Check.raises("a screen can be opened only for a player who has a character", function()
		World.openPlacedObjectScreen(world, other, ids.oven, ovenInside)
	end) and other.screen == nil, "openPlacedObjectScreen: fails for a player with no character")
	World.setCharacterPosition(world, 2, at(14, 0, 6))
	openOn(world, other, ids.oven)
	openOn(world, state, ids.oven)
	check(
		World.getOpenedPlacedObjectId(world, other) == ids.oven
			and World.getOpenedPlacedObjectId(world, state) == ids.oven,
		"openPlacedObjectScreen: two players may have the same placed object open"
	)
	check(
		other.screen ~= nil and (other.screen :: any).otherInventory == (state.screen :: any).otherInventory,
		"openPlacedObjectScreen: looking into the same inventory"
	)
end

do -- reaching a tile
	local world, state = newWorld()
	check(World.canReachTile(world, state, 2, 2), "canReach: a tile near the player is in reach")
	-- Tile 6, 1 has its middle at 22, 2. From 6, 2 it is exactly 16 studs away.
	World.setCharacterPosition(world, 1, at(6, 5, 2))
	check(
		World.canReachTile(world, state, 6, 1),
		"canReach: a tile exactly World.REACH away is in reach, whatever the height"
	)
	World.setCharacterPosition(world, 1, at(5.99, 0, 2))
	check(not World.canReachTile(world, state, 6, 1), "canReach: a tile a little further is not")
	World.removeCharacter(world, 1)
	check(not World.canReachTile(world, state, 2, 2), "canReach: a player with no character reaches nothing")
	local corner = World.new(Plot.new(3, 3), at(100, 0, 100), 0)
	local cornerState = World.addPlayer(corner, 1)
	World.setCharacterPosition(corner, 1, at(102, 0, 102))
	check(World.canReachTile(corner, cornerState, 1, 1), "canReach: measured from the plot's own corner")
	check(not World.canReachTile(corner, cornerState, 100, 100), "canReach: a tile far off the plot is not in reach")
end

do -- standing on a tile
	local world, state = newWorld()
	-- The middle of tile 3, 1 is at 10, 2.
	check(World.isTileStoodOn(world, 3, 1) == false, "isTileStoodOn: a tile nobody is near is not stood on")
	World.setCharacterPosition(world, 1, at(13, 0, 2))
	check(
		World.isTileStoodOn(world, 3, 1),
		"isTileStoodOn: a player exactly STANDS_ON_WITHIN from its middle stands on it"
	)
	World.setCharacterPosition(world, 1, at(13.01, 0, 2))
	check(not World.isTileStoodOn(world, 3, 1), "isTileStoodOn: a little further they do not")
	World.setCharacterPosition(world, 1, at(10, 40, 2))
	check(World.isTileStoodOn(world, 3, 1), "isTileStoodOn: height does not matter")
	World.removeCharacter(world, 1)
	check(not World.isTileStoodOn(world, 3, 1), "isTileStoodOn: a player with no character stands on nothing")
	local second = World.addPlayer(world, 2)
	World.setCharacterPosition(world, 2, at(10, 0, 2))
	check(World.isTileStoodOn(world, 3, 1), "isTileStoodOn: any player will do")
	check(
		second.character ~= nil and state.character == nil,
		"isTileStoodOn: (set up) the first still has no character"
	)
end

do -- placing an object
	local world = newWorld()
	local placedObjectId = Plot.placeObject(world.plot, "crate", 1, 1)
	check(
		placedObjectId ~= nil and world.plot.placedObjectsById[placedObjectId].kindId == "crate",
		"Plot.placeObject on the world's plot: returns the id of the placed object"
	)
	check(
		placedObjectId ~= nil
			and world.plot.placedObjectsById[placedObjectId].tileX == 1
			and world.plot.placedObjectsById[placedObjectId].tileZ == 1,
		"Plot.placeObject on the world's plot: on the tile it was asked for"
	)
	check(
		placedObjectId ~= nil
			and world.placedObjectInventories[placedObjectId] == nil
			and world.stations[placedObjectId] == nil,
		"Plot.placeObject on the world's plot: and it is given nothing by being placed"
	)
	check(
		World.canPlaceObject(world, 1, 2) and not World.canPlaceObject(world, 1, 1),
		"canPlaceObject: true for a tile that holds nothing, and false for a tile something stands on"
	)
	check(not World.canPlaceObject(world, 7, 1), "canPlaceObject: false for a tile the plot does not have")
	check(Check.errorFrom(function()
		Plot.placeObject(world.plot, "crate", 1, 1)
	end) ~= nil, "Plot.placeObject on the world's plot: fails where the plot cannot take an object")
	check(
		world.plot.nextId == (placedObjectId :: number) + 1,
		"Plot.placeObject on the world's plot: and places nothing then"
	)

	-- Tile 3, 3 has its middle at 10, 10. Player 1 stands 3 studs from it.
	World.setCharacterPosition(world, 1, at(13, 0, 10))
	check(not World.canPlaceObject(world, 3, 3), "canPlaceObject: false for a tile a player stands on")
	World.setCharacterPosition(world, 1, at(13.01, 0, 10))
	check(World.canPlaceObject(world, 3, 3), "canPlaceObject: true once the player has stepped off")
	World.setCharacterPosition(world, 1, at(13, 0, 10))
	local forced = Plot.placeObject(world.plot, "stove", 3, 3)
	check(
		world.plot.placedObjectsById[forced].kindId == "stove",
		"Plot.placeObject on the world's plot: it does not ask whether a player stands on the tile"
	)

	-- A world needs no player to place in it.
	local empty = World.new(Plot.new(2, 2), at(0, 0, 0), 0)
	check(
		World.canPlaceObject(empty, 2, 2) and Plot.placeObject(empty.plot, "post", 2, 2) == 1,
		"canPlaceObject, Plot.placeObject: work with no player in the world"
	)
	local nowhere = World.new(Plot.new(2, 2), at(0, 0, 0), 0)
	local lost = World.addPlayer(nowhere, 1)
	check(
		lost.character == nil and Plot.placeObject(nowhere.plot, "post", 1, 1) == 1,
		"Plot.placeObject on the world's plot: a player with no character stands on nothing"
	)
end

do -- placing an object where ground items lie
	-- Tile 3, 3 reaches from 8 to 12 along x and z, and its middle is 10, 10.
	local touching = (Plot.TILE_SIZE + GroundItems.ITEM_WIDTH) / 2
	local world = newWorld()
	local inside = GroundItems.spawnStack(world.groundItems, ItemStack.new("apple", 1), at(9, 0, 10.5), STILL, 0)
	World.advanceTo(world, 140)
	check(
		Plot.placeObject(world.plot, "crate", 3, 3) ~= nil,
		"Plot.placeObject on the world's plot: (set up) a crate is placed where an apple lies"
	)
	local apples = groundStacks(world, "apple")
	check(
		world.groundItems.itemsById[inside] == nil and #apples == 1 and is(apples[1].stack, "apple", 1),
		"Plot.placeObject on the world's plot: a ground item that lay in the tile is pushed out of it, whole"
	)
	check(
		isAt(apples[1], 10 - touching, 0, 10.5) and apples[1].spawnTime == 140,
		"Plot.placeObject on the world's plot: to just outside the tile, spawned again at the world's time"
	)

	local refused = newWorld()
	local stays = GroundItems.spawnStack(refused.groundItems, ItemStack.new("apple", 1), at(6, 0, 6.5), STILL, 0)
	check(
		Check.errorFrom(function()
				Plot.placeObject(refused.plot, "post", 2, 2)
			end) ~= nil and refused.groundItems.itemsById[stays] ~= nil,
		"Plot.placeObject on the world's plot: a placing that fails pushes nothing"
	)
end

do -- taking a placed object off
	local world, state, ids = newWorld()
	local other = World.addPlayer(world, 2)
	World.setCharacterPosition(world, 2, at(10, 0, 10))
	openOn(world, state, ids.crate)
	openOn(world, other, ids.crate)
	InventoryScreen.pickUpFromSlot(other.screen :: any, "other", 1, 3)
	knockOff(world, ids.crate)
	check(
		world.plot.placedObjectsById[ids.crate] == nil,
		"Plot.removePlacedObject on the world's plot: the placed object is off the plot"
	)
	check(
		state.screen == nil
			and World.getOpenedPlacedObjectId(world, state) == nil
			and other.screen == nil
			and World.getOpenedPlacedObjectId(world, other) == nil,
		"Plot.removePlacedObject on the world's plot: every screen open on it is closed"
	)
	check(
		Inventory.countItems(other.pack, "fish") == 3,
		"Plot.removePlacedObject on the world's plot: what a player carried is back in their pack"
	)
	local crates = groundStacks(world, "crate")
	check(
		#crates == 1 and is(crates[1].stack, "crate", 1),
		"throwStacksFromTile: the item is loose in the world, one of it"
	)
	local middleHeight = (Plot.TILE_SIZE - GroundItems.ITEM_WIDTH) / 2
	check(
		isAt(crates[1], 6, middleHeight, 6) and crates[1].spawnTime == 100,
		"throwStacksFromTile: it leaves from the middle of where it stood, dropped at the world's time"
	)
	local fish = groundStacks(world, "fish")
	check(#fish == 1 and is(fish[1].stack, "fish", 2), "throwStacksFromTile: what was left in it is loose in the world")
	check(isAt(fish[1], 6, middleHeight, 6), "throwStacksFromTile: and leaves from the same place")
	check(
		crates[1].spawnVelocity.y == World.TILE_THROW_UPWARD_SPEED
			and fish[1].spawnVelocity.y == World.TILE_THROW_UPWARD_SPEED,
		"throwStacksFromTile: the item and what was in it are thrown upwards"
	)
	local function outwardSpeed(groundItem: GroundItems.GroundItem): number
		return math.sqrt(groundItem.spawnVelocity.x ^ 2 + groundItem.spawnVelocity.z ^ 2)
	end
	check(
		math.abs(outwardSpeed(crates[1]) - World.TILE_THROW_OUTWARD_SPEED) < 1e-9
			and math.abs(outwardSpeed(fish[1]) - World.TILE_THROW_OUTWARD_SPEED) < 1e-9,
		"throwStacksFromTile: and outwards along the ground"
	)
	check(
		math.abs(crates[1].spawnVelocity.x - fish[1].spawnVelocity.x) > 1,
		"throwStacksFromTile: each a different way"
	)
	check(
		World.TILE_THROW_UPWARD_SPEED == 20 and World.TILE_THROW_OUTWARD_SPEED == 6,
		"TILE_THROW_UPWARD_SPEED, TILE_THROW_OUTWARD_SPEED: stacks thrown from a tile start at 20 studs a second upwards and 6 outwards"
	)
	check(inWorld(world, "fish") == 5 and inWorld(world, "crate") == 1, "throwStacksFromTile: nothing was made or lost")
	check(
		Plot.canPlaceObject(world.plot, 2, 2) and Plot.placeObject(world.plot, "stove", 2, 2) ~= nil,
		"Plot.removePlacedObject on the world's plot: the tile holds nothing, so another object can be placed there"
	)

	-- Each stack from inside is thrown a way of its own.
	local ringWorld = World.new(Plot.new(3, 3), at(0, 0, 0), 0)
	local ringCrate = place(ringWorld, "crate", 2, 2)
	local inRing = insideOf(ringWorld, ringCrate)
	Inventory.setStack(inRing, 2, ItemStack.new("fish", 2))
	Inventory.setStack(inRing, 9, ItemStack.new("apple", 3))
	Inventory.setStack(inRing, 20, ItemStack.new("log", 4))
	knockOff(ringWorld, ringCrate)
	local ways: { [string]: boolean } = {}
	local wayCount = 0
	for _, groundItem in ringWorld.groundItems.itemsById do
		local key = string.format("%.3f %.3f", groundItem.spawnVelocity.x, groundItem.spawnVelocity.z)
		if not ways[key] then
			ways[key] = true
			wayCount += 1
		end
	end
	check(
		wayCount == 4,
		"throwStacksFromTile: the item and each of the three stacks that were in it are thrown a way of their own"
	)
	check(
		onGround(ringWorld, "fish") == 2 and onGround(ringWorld, "apple") == 3 and onGround(ringWorld, "log") == 4,
		"throwStacksFromTile: and each is whole"
	)
	local function idOf(itemId: string): number
		for id, groundItem in ringWorld.groundItems.itemsById do
			if groundItem.stack.itemId == itemId then
				return id
			end
		end
		return 0
	end
	check(
		idOf("crate") == 1 and idOf("fish") == 2 and idOf("apple") == 3 and idOf("log") == 4,
		"throwStacksFromTile: the item is spawned first, then each stack from the lowest slot up"
	)

	-- Two part stacks of one kind that were inside come out as one.
	local partsWorld = World.new(Plot.new(3, 3), at(0, 0, 0), 0)
	local partsCrate = place(partsWorld, "crate", 2, 2)
	local inParts = insideOf(partsWorld, partsCrate)
	Inventory.setStack(inParts, 3, ItemStack.new("fish", 2))
	Inventory.setStack(inParts, 8, ItemStack.new("fish", 5))
	Inventory.setStack(inParts, 9, ItemStack.new("fish", 8))
	knockOff(partsWorld, partsCrate)
	check(
		#groundStacks(partsWorld, "fish") == 3,
		"throwStacksFromTile: each stack that was inside is a ground item of its own"
	)
	World.advanceTo(partsWorld, 0.1)
	local spilled = groundStacks(partsWorld, "fish")
	check(
		#spilled == 2 and is(spilled[1].stack, "fish", 7) and is(spilled[2].stack, "fish", 8),
		"advanceTo: two part stacks of one kind thrown from one place merge, and a full stack stays apart"
	)

	-- A placed object with nothing in it, and one with nothing to hold.
	knockOff(world, ids.stove)
	check(
		world.plot.placedObjectsById[ids.stove] == nil and #groundStacks(world, "stove") == 1,
		"throwStacksFromTile: a placed object that holds nothing just becomes a ground item"
	)
	local groundBefore = groundItemCount(world)
	Plot.removePlacedObject(world.plot, 999)
	Plot.removePlacedObject(world.plot, ids.stove)
	check(
		groundItemCount(world) == groundBefore,
		"Plot.removePlacedObject on the world's plot: changes nothing for an id that no placed object has"
	)
	check(
		world.plot.placedObjectsById[ids.oven] ~= nil,
		"Plot.removePlacedObject on the world's plot: and takes nothing else off the plot"
	)

	-- A player's screen open on something else is left alone.
	local keep, keepState, keepIds = newWorld()
	openOn(keep, keepState, keepIds.crate)
	knockOff(keep, keepIds.oven)
	check(
		keepState.screen ~= nil and World.getOpenedPlacedObjectId(keep, keepState) == keepIds.crate,
		"Plot.removePlacedObject on the world's plot: a screen open on another placed object stays open"
	)
end

do -- taking a placed object off the plot, and throwing stacks from a tile, each by itself
	local world, _, ids = newWorld()
	local inside = insideOf(world, ids.crate)
	local taken = Plot.removePlacedObject(world.plot, ids.crate)
	check(
		taken ~= nil and taken.kindId == "crate" and taken.tileX == 2 and taken.tileZ == 2,
		"Plot.removePlacedObject on the world's plot: returns the placed object"
	)
	check(
		world.placedObjectInventories[ids.crate] == nil and Inventory.countItems(inside, "fish") == 5,
		"Plot.removePlacedObject on the world's plot: the inventory it was given is the world's no longer, and holds what it held"
	)
	check(groundItemCount(world) == 0, "Plot.removePlacedObject on the world's plot: nothing is thrown into the world")
	check(
		Plot.removePlacedObject(world.plot, ids.crate) == nil and Plot.removePlacedObject(world.plot, 999) == nil,
		"Plot.removePlacedObject on the world's plot: returns nil for an id that no placed object has"
	)

	-- Tile 5, 5 has its middle at 18, 18, and the stove still stands on it.
	local stacks = { ItemStack.new("apple", 2), ItemStack.new("log", 4) }
	World.throwStacksFromTile(world, stacks, 5, 5)
	local apples, logs = groundStacks(world, "apple"), groundStacks(world, "log")
	local middleHeight = (Plot.TILE_SIZE - GroundItems.ITEM_WIDTH) / 2
	check(
		#apples == 1 and #logs == 1 and is(apples[1].stack, "apple", 2) and is(logs[1].stack, "log", 4),
		"throwStacksFromTile: each stack given is a ground item"
	)
	check(
		isAt(apples[1], 18, middleHeight, 18) and isAt(logs[1], 18, middleHeight, 18),
		"throwStacksFromTile: spawned in the middle of the cube over the tile"
	)
	check(
		world.plot.placedObjectsById[ids.stove] ~= nil and #stacks == 2,
		"throwStacksFromTile: it takes nothing off the plot, and leaves the list it was given as it was"
	)
	local groundBefore = groundItemCount(world)
	World.throwStacksFromTile(world, {}, 5, 5)
	check(groundItemCount(world) == groundBefore, "throwStacksFromTile: a list of no stacks throws nothing")
end

do -- an oven taken off the plot
	local world, state, ids = newWorld()
	local inside = insideOf(world, ids.oven)
	Inventory.setStack(inside, Station.INPUT_SLOT, ItemStack.new("fish", 3))
	Inventory.setStack(inside, Station.FUEL_SLOT, ItemStack.new("log", 4))
	Inventory.setStack(state.pack, 1, nil)
	World.advanceTo(world, 104)
	check(
		world.stations[ids.oven] ~= nil,
		"Plot.removePlacedObject on the world's plot: (set up) the oven is a station with a fire lit"
	)
	check(
		Station.isBurning(world.stations[ids.oven]),
		"Plot.removePlacedObject on the world's plot: (set up) and burning"
	)
	knockOff(world, ids.oven)
	check(
		world.stations[ids.oven] == nil,
		"Plot.removePlacedObject on the world's plot: its station goes with it, and its fire is out"
	)
	check(
		#groundStacks(world, "oven") == 1 and onGround(world, "fish") == 3 and onGround(world, "log") == 3,
		"throwStacksFromTile: what was in it lies on the ground, and the log that was burning is gone"
	)
	World.advanceTo(world, 200)
	check(
		onGround(world, "cooked_fish") == 0,
		"Plot.removePlacedObject on the world's plot: nothing more is cooked once it is off the plot"
	)
end

do -- time passing: picking up
	local world, state = newWorld()
	World.spawnStack(world, ItemStack.new("apple", 3), at(7, 0, 1), STILL)
	World.advanceTo(world, 100.5)
	check(world.now == 100.5, "advanceTo: the world moves on to the time it was given")
	check(Inventory.countItems(state.pack, "apple") == 0, "advanceTo: a ground item just dropped is not picked up yet")
	World.advanceTo(world, 100 + GroundItems.PICKUP_DELAY_SECONDS)
	check(
		Inventory.countItems(state.pack, "apple") == 3 and onGround(world, "apple") == 0,
		"advanceTo: a player picks up what lies near them"
	)

	World.addPlayer(world, 2)
	World.addPlayer(world, -5)
	World.setCharacterPosition(world, 2, at(30, 0, 30))
	World.setCharacterPosition(world, -5, at(30, 0, 30))
	World.spawnStack(world, ItemStack.new("stove", 1), at(31, 0, 30), STILL)
	World.advanceTo(world, 110)
	check(
		Inventory.countItems(world.players[-5].pack, "stove") == 1
			and Inventory.countItems(world.players[2].pack, "stove") == 0,
		"advanceTo: of two players equally near, the one with the lowest id picks up first"
	)

	World.removeCharacter(world, -5)
	World.spawnStack(world, ItemStack.new("stove", 1), at(100, 0, 100), STILL)
	World.setCharacterPosition(world, 2, at(100, 0, 100))
	World.spawnStack(world, ItemStack.new("fish", 2), at(30, 0, 30), STILL)
	World.advanceTo(world, 120)
	check(
		Inventory.countItems(world.players[2].pack, "stove") == 1,
		"advanceTo: a player picks up where they stand now"
	)
	check(onGround(world, "fish") == 2, "advanceTo: a player with no character picks nothing up")

	World.setCharacterPosition(world, -5, at(30, 0, 30))
	World.setCharacterPosition(world, 2, at(500, 0, 500))
	World.advanceTo(world, 121)
	check(
		Inventory.countItems(world.players[-5].pack, "fish") == 2,
		"advanceTo: and a character that is back picks up again"
	)
end

do -- time passing: ground items expire
	local world = newWorld()
	World.spawnStack(world, ItemStack.new("fish", 2), at(30, 0, 30), STILL)
	World.advanceTo(world, 100 + GroundItems.LIFETIME_SECONDS - 0.01)
	check(onGround(world, "fish") == 2, "advanceTo: a ground item lies until its time is up")
	World.advanceTo(world, 100 + GroundItems.LIFETIME_SECONDS)
	check(onGround(world, "fish") == 0, "advanceTo: and then is gone")
end

do -- time passing: screens close
	local world, state, ids = newWorld()
	openOn(world, state, ids.crate)
	World.setCharacterPosition(world, 1, at(6, 0, 6 + World.SCREEN_CLOSES_BEYOND))
	World.advanceTo(world, 101)
	check(state.screen ~= nil, "advanceTo: a screen stays open at exactly the distance it closes beyond")
	World.setCharacterPosition(world, 1, at(6, 0, 6.01 + World.SCREEN_CLOSES_BEYOND))
	World.advanceTo(world, 102)
	check(
		state.screen == nil and World.getOpenedPlacedObjectId(world, state) == nil,
		"advanceTo: and closes once the player is beyond it"
	)

	World.setCharacterPosition(world, 1, at(6, 0, 0))
	openOn(world, state, ids.crate)
	InventoryScreen.pickUpFromSlot(state.screen :: any, "other", 1)
	World.removeCharacter(world, 1)
	check(
		state.screen == nil,
		"removeCharacter: a screen on a placed object closes when the player loses their character"
	)
	World.advanceTo(world, 103)
	check(Inventory.countItems(state.pack, "fish") == 5, "advanceTo: and what they carried is in their pack")

	World.setCharacterPosition(world, 1, at(6, 0, 0))
	openOn(world, state, ids.crate)
	Plot.removePlacedObject(world.plot, ids.crate)
	check(
		state.screen == nil and World.getOpenedPlacedObjectId(world, state) == nil,
		"Plot.removePlacedObject on the world's plot: a screen open on the placed object closes at once"
	)
	World.advanceTo(world, 104)

	openOn(world, state, ids.oven)
	World.setCharacterPosition(world, 1, at(6, 0, 6))
	World.advanceTo(world, 105)
	check(state.screen ~= nil, "advanceTo: a screen stays open for a player who stays near")

	World.closeScreen(world, state)
	PlayerState.openScreen(state)
	World.setCharacterPosition(world, 1, at(500, 0, 500))
	World.advanceTo(world, 106)
	check(state.screen ~= nil, "advanceTo: the pack open alone stays open wherever the player goes")
	World.removeCharacter(world, 1)
	check(state.screen == nil, "removeCharacter: the pack open alone closes too when the player loses their character")

	-- The pack is full, so what is carried is dropped at the player's character.
	local full, fullState, fullIds = newWorld()
	openOn(full, fullState, fullIds.crate)
	InventoryScreen.pickUpFromSlot(fullState.screen :: any, "other", 1)
	for slot = 1, PlayerState.PACK_SLOT_COUNT do
		Inventory.setStack(fullState.pack, slot, ItemStack.new("stove", 1))
	end
	World.setCharacterPosition(full, 1, at(6, 0, 200))
	World.advanceTo(full, 101)
	local fish = groundStacks(full, "fish")
	check(
		fullState.screen == nil
			and #fish == 1
			and isAt(fish[1], 6, World.CHARACTER_THROW_START_HEIGHT, 200)
			and wasSpawnedMovingAt(fish[1], 0, 0, 0),
		"advanceTo: a screen closed for being out of reach drops what is left of the carried stack at the character"
	)
end

do -- time passing: stations
	local world, _, ids = newWorld()
	local inside = insideOf(world, ids.oven)
	Inventory.setStack(inside, Station.INPUT_SLOT, ItemStack.new("fish", 3))
	Inventory.setStack(inside, Station.FUEL_SLOT, ItemStack.new("log", 4))
	World.advanceTo(world, 104)
	local progress = StationProgress.new(world.stations[ids.oven], 104)
	check(
		math.abs(StationProgress.getFuelLeftRatio(progress, 104) - 0.75) < 1e-6
			and math.abs(StationProgress.getWorkDoneRatio(progress, 104) - 0.5) < 1e-6,
		"advanceTo: a station burns and works for the time that has passed since the world was last advanced"
	)
	check(is(Inventory.getStack(inside, Station.FUEL_SLOT), "log", 3), "advanceTo: lighting it used a log")
	World.advanceTo(world, 108)
	check(
		is(Inventory.getStack(inside, Station.OUTPUT_SLOT), "cooked_fish", 1)
			and is(Inventory.getStack(inside, Station.INPUT_SLOT), "fish", 2),
		"advanceTo: and in time turns a fish into a cooked fish"
	)
	World.advanceTo(world, 110)
	check(world.stations[ids.oven].workedSeconds > 0, "advanceTo: (set up) the second fish is being worked on")
	local worked = world.stations[ids.oven].workedSeconds
	World.advanceTo(world, 108)
	check(
		world.stations[ids.oven].workedSeconds == worked,
		"advanceTo: no time passes for a station when the time given is earlier"
	)
	World.advanceTo(world, 108)
	check(world.stations[ids.oven].workedSeconds == worked, "advanceTo: nor when it is the same as the time before")

	-- Work goes on whether or not a player is near, or there is one at all.
	local idleWorld = World.new(Plot.new(3, 3), at(0, 0, 0), 0)
	local idleOven = place(idleWorld, "oven", 1, 1)
	local idleInside = insideOf(idleWorld, idleOven)
	Inventory.setStack(idleInside, Station.INPUT_SLOT, ItemStack.new("fish", 2))
	Inventory.setStack(idleInside, Station.FUEL_SLOT, ItemStack.new("log", 1))
	World.advanceTo(idleWorld, 16)
	check(
		is(Inventory.getStack(idleInside, Station.OUTPUT_SLOT), "cooked_fish", 2),
		"advanceTo: a station works with no player in the world at all"
	)
	check(not Station.isBurning(idleWorld.stations[idleOven]), "advanceTo: and its fire is out once the log has burnt")

	-- Every station works, each on its own.
	local twoWorld = World.new(Plot.new(3, 3), at(0, 0, 0), 0)
	local first = place(twoWorld, "oven", 1, 1)
	local second = place(twoWorld, "oven", 2, 1)
	for _, id in { first, second } do
		local oven = insideOf(twoWorld, id)
		Inventory.setStack(oven, Station.INPUT_SLOT, ItemStack.new("fish", 1))
		Inventory.setStack(oven, Station.FUEL_SLOT, ItemStack.new("log", 1))
	end
	World.advanceTo(twoWorld, 8)
	check(
		is(Inventory.getStack(insideOf(twoWorld, first), Station.OUTPUT_SLOT), "cooked_fish", 1)
			and is(Inventory.getStack(insideOf(twoWorld, second), Station.OUTPUT_SLOT), "cooked_fish", 1),
		"advanceTo: every station on the plot works, each on its own"
	)

	-- A placed oven starts working at the next step, from the time then.
	local fresh = newWorld()
	local newOven = place(fresh, "oven", 6, 6)
	Inventory.setStack(insideOf(fresh, newOven), Station.INPUT_SLOT, ItemStack.new("fish", 1))
	Inventory.setStack(insideOf(fresh, newOven), Station.FUEL_SLOT, ItemStack.new("log", 1))
	World.advanceTo(fresh, 108)
	check(
		is(Inventory.getStack(insideOf(fresh, newOven), Station.OUTPUT_SLOT), "cooked_fish", 1),
		"advanceTo: a placed object made a station in a running world works at once"
	)
end

do -- a player leaves
	local world, state, ids = newWorld()
	openOn(world, state, ids.crate)
	InventoryScreen.pickUpFromSlot(state.screen :: any, "other", 1)
	local removed = World.removePlayer(world, 1)
	check(removed == state and world.players[1] == nil, "removePlayer: the player is out of the world")
	check(
		state.screen == nil and Inventory.countItems(state.pack, "fish") == 5,
		"removePlayer: what they carried is in the pack they leave with"
	)
	check(Inventory.isEmpty(insideOf(world, ids.crate)), "removePlayer: and not in the crate")

	local full, fullState, fullIds = newWorld()
	for slot = 1, PlayerState.PACK_SLOT_COUNT do
		Inventory.setStack(fullState.pack, slot, ItemStack.new("stove", 1))
	end
	openOn(full, fullState, fullIds.crate)
	InventoryScreen.pickUpFromSlot(fullState.screen :: any, "other", 1)
	World.removePlayer(full, 1)
	local fish = groundStacks(full, "fish")
	check(
		#fish == 1 and is(fish[1].stack, "fish", 5),
		"removePlayer: a carried stack the pack has no room for is dropped into the world"
	)
	check(
		isAt(fish[1], 6, World.CHARACTER_THROW_START_HEIGHT, 0) and wasSpawnedMovingAt(fish[1], 0, 0, 0),
		"removePlayer: where a throw from their character starts, not moving"
	)
end

do -- several players, several things at once, and no item is made or lost
	local seed = 9001
	local function random(limit: number): number
		seed = (seed * 16807) % 2147483647
		return math.floor(seed / 65536) % limit + 1
	end
	local function randomPack(): Inventory.Inventory
		local pack = Inventory.new(PlayerState.PACK_SLOT_COUNT)
		for _ = 1, 6 do
			local itemId = itemIds[random(#itemIds)]
			Inventory.addItems(pack, itemId, random(ItemRegistry.get(itemId).stackSize))
		end
		return pack
	end

	local problems, firstProblem = 0, ""
	local function expect(condition: boolean, what: string)
		if not condition then
			problems += 1
			firstProblem = if firstProblem == "" then what else firstProblem
		end
	end
	local errors, firstError = 0, ""
	local neverMore, constantBetweenSteps, exactWhenYoung = true, true, true
	local tidy = true
	for round = 1, 24 do
		-- In the even rounds time moves slowly, so nothing lies long enough to expire and every item must still be there.
		local slow = round % 2 == 0
		local world = World.new(Plot.new(6, 6), at(0, 0, 0), 0)
		local now = 0
		local playerIds = { 1, 2, 3 }
		-- What has left the world with a player, and what has come in with one. Negative for the second.
		local gone: { [string]: number } = {}
		local function total(itemId: string): number
			return inWorld(world, itemId) + (gone[itemId] or 0)
		end
		for _, playerId in playerIds do
			local pack = randomPack()
			for _, itemId in itemIds do
				gone[itemId] = (gone[itemId] or 0) - Inventory.countItems(pack, itemId)
			end
			World.addPlayer(world, playerId, pack)
		end
		local before: { [string]: number } = {}
		for _, itemId in itemIds do
			before[itemId] = total(itemId)
		end

		local function run(action: () -> ())
			local ok, problem = pcall(action)
			if not ok then
				errors += 1
				firstError = if firstError == "" then tostring(problem) else firstError
			end
		end

		for _ = 1, 500 do
			local action = random(24)
			local playerId = playerIds[random(#playerIds)]
			local state = world.players[playerId]
			local stepped = false
			if action <= 3 then
				if state ~= nil then
					if random(8) == 1 then
						run(function()
							World.removeCharacter(world, playerId)
						end)
					else
						local standing = at(random(28) - 2, 0, random(28) - 2)
						run(function()
							World.setCharacterPosition(world, playerId, standing)
						end)
					end
				end
			elseif action <= 5 then
				now += if slow then 0.2 else random(60)
				stepped = true
				run(function()
					World.advanceTo(world, now)
				end)
			elseif action == 6 then
				if state ~= nil then
					run(function()
						local removed = World.removePlayer(world, playerId)
						expect(removed == state, "removePlayer returns the player it removes")
						for _, itemId in itemIds do
							gone[itemId] = (gone[itemId] or 0) + Inventory.countItems(state.pack, itemId)
						end
					end)
				else
					local pack = randomPack()
					for _, itemId in itemIds do
						gone[itemId] = (gone[itemId] or 0) - Inventory.countItems(pack, itemId)
					end
					run(function()
						World.addPlayer(world, playerId, pack)
					end)
				end
			elseif action <= 9 then
				-- Place one item taken from a slot of the pack, or put it back if it cannot be placed.
				if state ~= nil then
					run(function()
						local slot = random(PlayerState.PACK_SLOT_COUNT)
						local taken = Inventory.takeFromSlot(state.pack, slot, 1)
						if taken ~= nil then
							local x, z = random(6), random(6)
							local isPlaceable = taken.itemId == "stove"
								or taken.itemId == "crate"
								or taken.itemId == "post"
							if isPlaceable and World.canPlaceObject(world, x, z) then
								place(world, taken.itemId, x, z)
							else
								local leftover = Inventory.addStack(state.pack, taken)
								expect(leftover == nil, "an item taken from a slot goes back into the pack")
							end
						end
					end)
				end
			elseif action <= 11 then
				local ids = placedIds(world)
				run(function()
					knockOff(world, if #ids > 0 and random(5) > 1 then ids[random(#ids)] else random(40))
				end)
			elseif action <= 13 then
				if state ~= nil then
					local ids = placedIds(world)
					run(function()
						local id = if #ids > 0 and random(5) > 1 then ids[random(#ids)] else random(40)
						local openedBefore = World.getOpenedPlacedObjectId(world, state)
						local canOpen = state.character ~= nil and findInside(world, id) ~= nil
						if canOpen then
							openOn(world, state, id)
						end
						expect(
							World.getOpenedPlacedObjectId(world, state) == (if canOpen then id else openedBefore),
							"openPlacedObjectScreen opens the screen of the placed object it is given"
						)
					end)
				end
			elseif action == 14 then
				if state ~= nil then
					run(function()
						World.closeScreen(world, state)
						expect(
							state.screen == nil and World.getOpenedPlacedObjectId(world, state) == nil,
							"closeScreen leaves nothing open"
						)
					end)
				end
			elseif action == 15 then
				if state ~= nil and PlayerState.canOpenScreen(state) then
					PlayerState.openScreen(state)
				end
			elseif action <= 20 then
				-- What a player does with an open screen.
				local screen = if state ~= nil then state.screen else nil
				if screen ~= nil then
					run(function()
						local side: InventoryScreen.Side = if screen.otherInventory ~= nil and random(2) == 1
							then "other"
							else "pack"
						local inventory = InventoryScreen.getInventoryOnSide(screen, side)
						local slot = random(inventory.slotCount)
						local kind = random(5)
						if kind == 1 then
							InventoryScreen.pickUpFromSlot(
								screen,
								side,
								slot,
								if random(2) == 1 then nil else random(8)
							)
						elseif kind == 2 then
							InventoryScreen.putDownInSlot(screen, side, slot, if random(2) == 1 then nil else random(8))
						elseif kind == 3 then
							InventoryScreen.swapCarriedStackWithSlot(screen, side, slot)
						elseif kind == 4 then
							InventoryScreen.moveFromSlotToInventory(
								screen,
								side,
								slot,
								if side == "pack" and screen.otherInventory ~= nil then "other" else "pack"
							)
						else
							local taken = InventoryScreen.takeCarriedStack(screen, random(4))
							local character = (state :: PlayerState.PlayerState).character
							expect(character ~= nil, "a player with a screen open has a character")
							if taken ~= nil and character ~= nil then
								World.throwStackFromCharacter(world, taken, character.position, ALONG_X)
							end
						end
					end)
				end
			else
				-- Drop part of a slot of the pack, or say that a ground item has moved.
				if state ~= nil then
					run(function()
						local character = state.character
						local taken = if character
							then Inventory.takeFromSlot(state.pack, random(PlayerState.PACK_SLOT_COUNT), random(4))
							else nil
						if taken ~= nil and character ~= nil then
							World.throwStackFromCharacter(world, taken, character.position, ALONG_X)
						end
						local moved = random(math.max(world.groundItems.nextId - 1, 1))
						World.setGroundItemPosition(world, moved, at(random(28) - 2, 0, random(28) - 2))
					end)
				end
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

			for _, other in world.players do
				local placedObjectId = World.getOpenedPlacedObjectId(world, other)
				expect(
					placedObjectId == nil
						or (other.screen ~= nil and world.plot.placedObjectsById[placedObjectId] ~= nil),
					"a player has a placed object open only if they have a screen and it is on the plot"
				)
				expect(other.screen == nil or other.character ~= nil, "a player with a screen open has a character")
			end
			for id in world.stations do
				tidy = tidy and world.plot.placedObjectsById[id] ~= nil
			end
		end
	end
	check(errors == 0, "12,000 random moves: none raises an error (first: " .. firstError .. ")")
	check(neverMore, "12,000 random moves: no item is ever made")
	check(constantBetweenSteps, "12,000 random moves: no item is lost except when time passes")
	check(exactWhenYoung, "12,000 random moves: and none is lost then either, until it has lain on the ground too long")
	check(problems == 0, "12,000 random moves: every call does what it says (first: " .. firstProblem .. ")")
	check(tidy, "12,000 random moves: a station is kept only while its placed object stands on the plot")
end

Check.finish("World")
