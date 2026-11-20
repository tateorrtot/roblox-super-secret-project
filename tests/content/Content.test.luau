--!strict
-- Tests for Content: the game's own things, registered together as the game registers them, and then
-- sent every request there is. Run from the repository root: lune run tests/content/Content.test.luau

local Check = require("../Check")
local Content = require("../../src/shared/content/Content")
local Crate = require("../../src/shared/content/Crate")
local CrateItem = require("../../src/shared/content/CrateItem")
local FuelDefinitions = require("../../src/shared/stations/FuelDefinitions")
local FuelRegistry = require("../../src/shared/stations/FuelRegistry")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemDefinitions = require("../../src/shared/items/ItemDefinitions")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemScripts = require("../../src/shared/requests/ItemScripts")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlacedObjectLooks = require("../../src/shared/content/PlacedObjectLooks")
local PlacedObjectScripts = require("../../src/shared/requests/PlacedObjectScripts")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local RecipeDefinitions = require("../../src/shared/stations/RecipeDefinitions")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")
local Requests = require("../../src/shared/requests/Requests")
local Station = require("../../src/shared/stations/Station")
local Stove = require("../../src/shared/content/Stove")
local StoveItem = require("../../src/shared/content/StoveItem")
local World = require("../../src/shared/world/World")

local check = Check.that
local at = Position.new
local carryOut = Requests.carryOut :: (world: World.World, playerId: any, name: any, ...any) -> ()

-- The item that each kind of placed object leaves when it is broken, by the kind's id.
local itemIdWhenBroken = {
	[Crate.PLACED_OBJECT_KIND_ID] = Crate.ITEM_ID_WHEN_BROKEN,
	[Stove.PLACED_OBJECT_KIND_ID] = Stove.ITEM_ID_WHEN_BROKEN,
}

do -- register
	check(Check.errorFrom(Content.register) == nil, "register: registers everything without an error")
	for _, definition in ItemDefinitions do
		check(
			ItemRegistry.has(definition.id) and ItemRegistry.get(definition.id).stackSize == definition.stackSize,
			'register: the item "' .. definition.id .. '" is registered'
		)
	end
	for _, recipe in RecipeDefinitions do
		local found = RecipeRegistry.find(recipe.station, recipe.input)
		check(
			found ~= nil and found.output == recipe.output,
			'register: the recipe for "' .. recipe.input .. '" is registered'
		)
	end
	for _, fuel in FuelDefinitions do
		local found = FuelRegistry.find(fuel.item)
		check(found ~= nil and found.seconds == fuel.seconds, 'register: the fuel "' .. fuel.item .. '" is registered')
	end
	check(
		ItemScripts.find(CrateItem.ITEM_ID) == CrateItem :: any,
		"register: the crate item's script is registered for the crate item"
	)
	check(
		ItemScripts.find(StoveItem.ITEM_ID) == StoveItem :: any,
		"register: the stove item's script is registered for the stove item"
	)
	check(
		PlacedObjectScripts.find(Crate.PLACED_OBJECT_KIND_ID) == Crate :: any,
		"register: the crate's script is registered for the crate's kind"
	)
	check(
		PlacedObjectScripts.find(Stove.PLACED_OBJECT_KIND_ID) == Stove :: any,
		"register: the stove's script is registered for the stove's kind"
	)
	check(
		ItemScripts.find("log") == nil and PlacedObjectScripts.find("log") == nil,
		"register: an item that only lies in a slot has no script"
	)
	check(
		Check.errorFrom(Content.register) ~= nil,
		"register: fails when called a second time, since everything is registered already"
	)
end

do -- what must agree between the things
	check(
		Crate.PLACED_OBJECT_KIND_ID ~= Stove.PLACED_OBJECT_KIND_ID,
		"PLACED_OBJECT_KIND_ID: each kind of placed object has an id of its own"
	)
	check(table.isfrozen(PlacedObjectLooks), "PlacedObjectLooks: the rows cannot be changed")
	for kindId, itemId in itemIdWhenBroken do
		check(ItemRegistry.has(itemId), 'ITEM_ID_WHEN_BROKEN: what a broken "' .. kindId .. '" leaves is an item')
		local look = PlacedObjectLooks[kindId]
		check(look ~= nil, 'PlacedObjectLooks: the kind "' .. kindId .. '" has a look')
		if look ~= nil then
			check(type(look.name) == "string" and #look.name > 0, 'the look of the kind "' .. kindId .. '" has a name')
			local color = look.color
			local isColor = type(color) == "table" and #color == 3
			if isColor then
				for _, part in color do
					if type(part) ~= "number" or part ~= math.floor(part) or part < 0 or part > 255 then
						isColor = false
					end
				end
			end
			check(isColor, 'the colour of the kind "' .. kindId .. '" is three whole numbers from 0 to 255')
		end
	end
	for kindId in PlacedObjectLooks do
		check(
			PlacedObjectScripts.find(kindId) ~= nil,
			'PlacedObjectLooks: the look "' .. kindId .. '" belongs to a kind that has a script'
		)
	end
end

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

-- How many of one item the world holds in all: in packs, carried, standing on the plot, inside what
-- stands on the plot, and on the ground. A placed object counts as one of the item that it leaves
-- when it is broken.
local function inWorld(world: World.World, itemId: string): number
	local count = onGround(world, itemId)
	for _, player in world.players do
		count += Inventory.countItems(player.pack, itemId)
		local screen = player.screen
		if screen ~= nil and screen.carriedStack ~= nil and screen.carriedStack.itemId == itemId then
			count += screen.carriedStack.count
		end
	end
	for placedObjectId, placedObject in world.plot.placedObjectsById do
		local inside = findInside(world, placedObjectId)
		count += if itemIdWhenBroken[placedObject.kindId] == itemId then 1 else 0
		count += if inside ~= nil then Inventory.countItems(inside, itemId) else 0
	end
	return count
end

-- A world at time 100 with a plot of 6 by 6 tiles whose corner is at the origin, so that the middle of
-- tile x, z is at x * 4 - 2, z * 4 - 2. Nothing stands on it. Players 1, 2 and 3 stand at 6, 0, 0, at
-- 10, 0, 10 and at 20, 0, 20, and each has a crate in hotbar slot 1, a stove in slot 2, 12 logs in
-- slot 3, 5 fish in slot 4 and 4 cheeses in slot 5.
local function newWorld(): (World.World, PlayerState.PlayerState)
	local world = World.new(Plot.new(6, 6), at(0, 0, 0), 100)
	for playerId, position in { at(6, 0, 0), at(10, 0, 10), at(20, 0, 20) } do
		local player = World.addPlayer(world, playerId)
		Inventory.setStack(player.pack, 1, ItemStack.new("crate", 1))
		Inventory.setStack(player.pack, 2, ItemStack.new("stove", 1))
		Inventory.setStack(player.pack, 3, ItemStack.new("log", 12))
		Inventory.setStack(player.pack, 4, ItemStack.new("fish", 5))
		Inventory.setStack(player.pack, 5, ItemStack.new("cheese", 4))
		World.setCharacterPosition(world, playerId, position)
	end
	return world, world.players[1]
end

do -- the crate item and the crate, through the requests
	local world, player = newWorld()
	carryOut(world, 1, "interactWithTile", 1, 1)
	local crateId = world.plot.nextId - 1
	local crate = world.plot.placedObjectsById[crateId]
	check(
		crate ~= nil and crate.kindId == Crate.PLACED_OBJECT_KIND_ID and crate.tileX == 1 and crate.tileZ == 1,
		"interactWithTile: with the crate item in the selected hotbar slot, a crate stands on the tile"
	)
	check(Inventory.getStack(player.pack, 1) == nil, "interactWithTile: and the crate item has left the slot")
	check(inWorld(world, "crate") == 3, "interactWithTile: and no crate was made or lost")

	carryOut(world, 1, "interactWithPlacedObject", crateId)
	local screen = player.screen
	check(
		screen ~= nil
			and screen.otherInventory == world.placedObjectInventories[crateId]
			and World.getOpenedPlacedObjectId(world, player) == crateId,
		"interactWithPlacedObject: the crate's inventory opens on the player's screen"
	)
	carryOut(world, 1, "moveFromSlotToInventory", "pack", 4, "other", 1, Crate.SLOT_COUNT)
	check(
		Inventory.countItems(world.placedObjectInventories[crateId], "fish") == 5,
		"an inventory request puts the player's fish in the crate"
	)
	carryOut(world, 1, "closeScreen")

	carryOut(world, 1, "breakPlacedObject", crateId)
	check(world.plot.placedObjectsById[crateId] == nil, "breakPlacedObject: the crate is off the plot")
	check(
		onGround(world, "crate") == 1 and onGround(world, "fish") == 5,
		"breakPlacedObject: a crate item and what was in the crate lie on the ground"
	)
	check(
		inWorld(world, "crate") == 3 and inWorld(world, "fish") == 15,
		"breakPlacedObject: and nothing was made or lost"
	)
end

do -- the stove item and the stove, through the requests
	local world, player = newWorld()
	carryOut(world, 1, "selectHotbarSlot", 2)
	carryOut(world, 1, "interactWithTile", 3, 1)
	local stoveId = world.plot.nextId - 1
	local stove = world.plot.placedObjectsById[stoveId]
	check(
		stove ~= nil and stove.kindId == Stove.PLACED_OBJECT_KIND_ID and world.stations[stoveId] ~= nil,
		"interactWithTile: with the stove item in the selected hotbar slot, a stove stands on the tile, as a station"
	)
	check(Inventory.getStack(player.pack, 2) == nil, "interactWithTile: and the stove item has left the slot")

	carryOut(world, 1, "interactWithPlacedObject", stoveId)
	local screen = player.screen :: InventoryScreen.InventoryScreen
	check(
		screen ~= nil and screen.otherInventory == world.stations[stoveId].inventory,
		"interactWithPlacedObject: the stove's slots open on the player's screen"
	)
	check(
		screen ~= nil
			and InventoryScreen.slotAcceptsItem(screen, "other", Station.INPUT_SLOT, "fish")
			and not InventoryScreen.slotAcceptsItem(screen, "other", Station.INPUT_SLOT, "cheese"),
		"interactWithPlacedObject: and its input slot takes only what the stove has a recipe for"
	)
	carryOut(world, 1, "closeScreen")

	carryOut(world, 1, "breakPlacedObject", stoveId)
	check(
		world.plot.placedObjectsById[stoveId] == nil and world.stations[stoveId] == nil,
		"breakPlacedObject: the stove is off the plot, and is a station no longer"
	)
	check(onGround(world, "stove") == 1, "breakPlacedObject: a stove item lies on the ground")
end

do -- an item that has no script
	local world, player = newWorld()
	carryOut(world, 1, "selectHotbarSlot", 3)
	carryOut(world, 1, "interactWithTile", 3, 1)
	check(
		world.plot.nextId == 1 and is(Inventory.getStack(player.pack, 3), "log", 12),
		"interactWithTile: nothing happens with an item in hand that has no script"
	)
end

-- What stays the same however the requests go. An item that is neither burned nor cooked is counted
-- by itself. An item that a recipe cooks is counted together with what it is cooked into, since one
-- becomes one of the other.
local function getConservedCounts(world: World.World): { [string]: number }
	local counts: { [string]: number } = {}
	local burnedOrCooked: { [string]: boolean } = {}
	for _, recipe in RecipeDefinitions do
		counts[recipe.input .. " and " .. recipe.output] = inWorld(world, recipe.input) + inWorld(world, recipe.output)
		burnedOrCooked[recipe.input] = true
		burnedOrCooked[recipe.output] = true
	end
	for _, fuel in FuelDefinitions do
		burnedOrCooked[fuel.item] = true
	end
	for _, definition in ItemDefinitions do
		if not burnedOrCooked[definition.id] then
			counts[definition.id] = inWorld(world, definition.id)
		end
	end
	return counts
end

-- How many items that burn the world holds in all.
local function countFuels(world: World.World): number
	local count = 0
	for _, fuel in FuelDefinitions do
		count += inWorld(world, fuel.item)
	end
	return count
end

do -- whatever players' machines send, nothing raises an error and no item is made or lost
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
	local allConserved, noFuelMade = true, true
	local someOpened, somePlaced, someTakenOff, someBurned = false, false, false, false
	for _ = 1, 40 do
		-- A crate holding 5 fish stands on tile 2, 2, and a stove holding 3 fish and 2 logs on tile 4, 4.
		local world = newWorld()
		local crateId = Crate.place(world, 2, 2)
		Inventory.addItems(world.placedObjectInventories[crateId], "fish", 5)
		local stoveId = Stove.place(world, 4, 4)
		Inventory.setStack(world.stations[stoveId].inventory, Station.INPUT_SLOT, ItemStack.new("fish", 3))
		Inventory.setStack(world.stations[stoveId].inventory, Station.FUEL_SLOT, ItemStack.new("log", 2))
		local conserved = getConservedCounts(world)
		local fuels = countFuels(world)
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
			-- Now and then a player interacts with the crate or the stove, as a real machine would ask, so
			-- that the requests that follow find a screen open on it.
			if random(25) == 1 then
				carryOut(world, random(3), "interactWithPlacedObject", if random(2) == 1 then crateId else stoveId)
			end
			local playerId: any = if random(10) == 1 then junk[random(#junk)] else random(4)
			local name = names[random(#names)]
			local ok, result =
				pcall(carryOut, world, playerId, name, argument(), argument(), argument(), argument(), argument())
			if not ok then
				errors += 1
				firstError = if firstError == "" then tostring(name) .. ": " .. tostring(result) else firstError
			end
			somePlaced = somePlaced or world.plot.nextId > stoveId + 1
			someTakenOff = someTakenOff or world.plot.placedObjectsById[crateId] == nil
			for _, player in world.players do
				someOpened = someOpened or World.getOpenedPlacedObjectId(world, player) ~= nil
			end
			now += 0.5
			World.advanceTo(world, now)
			for what, count in getConservedCounts(world) do
				if count ~= conserved[what] then
					allConserved = false
				end
			end
			local fuelsNow = countFuels(world)
			noFuelMade = noFuelMade and fuelsNow <= fuels
			someBurned = someBurned or fuelsNow < fuels
			fuels = fuelsNow
		end
	end
	check(errors == 0, "random run: none of 12,000 requests raises an error (first: " .. firstError .. ")")
	check(
		allConserved,
		"random run: after every request every item is in a pack, carried, standing on the plot, inside it, or on the ground"
	)
	check(noFuelMade, "random run: and the items that burn only ever grow fewer")
	check(someOpened, "random run: a placed object was opened by a player, so that was tried")
	check(somePlaced, "random run: an object was placed by a player, so that was tried")
	check(someTakenOff, "random run: a crate was taken off the plot, so that was tried")
	check(someBurned, "random run: a stove burned fuel, so that was tried")
end

Check.finish("Content")
