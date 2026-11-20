--!strict
-- Tests for PlayerSnapshot. Run from the repository root: lune run tests/world/PlayerSnapshot.test.luau

local Check = require("../Check")
local Hotbar = require("../../src/shared/inventory/Hotbar")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlayerSnapshot = require("../../src/shared/world/PlayerSnapshot")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")
local Station = require("../../src/shared/stations/Station")
local StationProgress = require("../../src/shared/stations/StationProgress")
local World = require("../../src/shared/world/World")

local check = Check.that
local ALONG_X = { x = 1, z = 0 }

ItemRegistry.register({ id = "log", stackSize = 16, burnSeconds = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "apple", stackSize = 16 })
ItemRegistry.register({ id = "crate", stackSize = 1, placeable = true, slotCount = 27 })
ItemRegistry.register({ id = "cooked_fish", stackSize = 8 })
ItemRegistry.register({ id = "oven", stackSize = 1, placeable = true, slotCount = 3 })
RecipeRegistry.register({ station = "oven", input = "fish", output = "cooked_fish", seconds = 8 })

local at = Position.new

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

-- True if two inventories hold the same stacks in the same slots.
local function sameInventory(a: Inventory.Inventory, b: Inventory.Inventory): boolean
	if a.slotCount ~= b.slotCount then
		return false
	end
	for slot = 1, a.slotCount do
		local stackA, stackB = Inventory.getStack(a, slot), Inventory.getStack(b, slot)
		if (stackA == nil) ~= (stackB == nil) then
			return false
		end
		if stackA ~= nil and stackB ~= nil and (stackA.itemId ~= stackB.itemId or stackA.count ~= stackB.count) then
			return false
		end
	end
	return true
end

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

-- A world with a crate holding 5 fish on tile 2, 2 and an oven on tile 4, 2. Player 1 stands near them
-- with 12 logs and 4 apples in their pack.
local function newWorld(): (World.World, number, number)
	local plot = Plot.new(6, 6)
	local crateId = Plot.placeItem(plot, "crate", 2, 2) :: number
	Inventory.setStack(plot.placedItemsById[crateId].inventory :: Inventory.Inventory, 1, ItemStack.new("fish", 5))
	local ovenId = Plot.placeItem(plot, "oven", 4, 2) :: number
	local world = World.new(plot, at(0, 0, 0), 0)
	local state = World.addPlayer(world, 1)
	Inventory.setStack(state.pack, 1, ItemStack.new("log", 12))
	Inventory.setStack(state.pack, 7, ItemStack.new("apple", 4))
	World.setCharacter(world, 1, { position = at(6, 0, 0), facing = ALONG_X })
	return world, crateId, ovenId
end

do -- no screen open
	local world = newWorld()
	local encoded = PlayerSnapshot.encode(world, 1)
	check(encoded.screen == nil, "encode: a player with no screen open has no screen in their view")
	check(isPlain(encoded), "encode: the view is plain data")
	check(
		encoded.pack.slotCount == 36 and #encoded.pack.stacks == 2,
		"encode: the pack is in it, with each stack it holds"
	)
	check(
		encoded.pack.stacks[1].slot == 1
			and encoded.pack.stacks[1].itemId == "log"
			and encoded.pack.stacks[1].count == 12
			and encoded.pack.stacks[2].slot == 7
			and encoded.pack.stacks[2].itemId == "apple",
		"encode: in the form Inventory.encode gives"
	)

	local view = PlayerSnapshot.decode(encoded)
	check(view.screen == nil, "decode: a view with no screen has no screen")
	check(
		view.otherInventoryItemId == nil and view.stationProgress == nil,
		"decode: and no placed item and no progress"
	)
	check(sameInventory(view.pack, world.players[1].pack), "decode: the pack is what the player holds")
	check(view.pack ~= world.players[1].pack, "decode: but is a copy of it")
	check(
		encoded.selectedHotbarSlot == 1 and view.selectedHotbarSlot == 1,
		"encode, decode: the selected hotbar slot is in the view, slot 1 for a new player"
	)
	Hotbar.selectSlot(world.players[1].hotbar, 4)
	local reselected = PlayerSnapshot.encode(world, 1)
	check(
		reselected.selectedHotbarSlot == 4 and PlayerSnapshot.decode(reselected).selectedHotbarSlot == 4,
		"encode, decode: and follows the slot the player's hotbar has selected"
	)

	local state = world.players[1]
	Inventory.setStack(state.pack, 1, nil)
	check(is(Inventory.getStack(view.pack, 1), "log", 12), "decode: the view does not follow the world once it is made")
end

do -- the pack open alone
	local world = newWorld()
	local state = world.players[1]
	PlayerState.openPackScreen(state)
	local encoded = PlayerSnapshot.encode(world, 1)
	check(encoded.screen ~= nil, "encode: a player with the pack open has a screen in their view")
	local screen = encoded.screen
	check(
		screen ~= nil
			and screen.otherInventory == nil
			and screen.otherInventoryItemId == nil
			and screen.carriedStack == nil
			and screen.stationProgress == nil,
		"encode: with nothing beside the pack, nothing carried and no progress"
	)
	check(isPlain(encoded), "encode: all of it is plain data")

	local view = PlayerSnapshot.decode(encoded)
	check(view.screen ~= nil, "decode: the screen is open")
	check(view.screen ~= nil and view.screen.pack == view.pack, "decode: and shows the pack of the view")
	check(
		view.screen ~= nil and view.screen.otherInventory == nil and view.screen.carriedStack == nil,
		"decode: with nothing beside it and nothing carried"
	)
	check(
		view.otherInventoryItemId == nil and view.stationProgress == nil,
		"decode: and no placed item and no progress"
	)
	check(sameInventory(view.pack, state.pack), "decode: the pack is what the player holds")
	Hotbar.selectSlot(state.hotbar, 6)
	local reselected = PlayerSnapshot.encode(world, 1)
	check(
		reselected.selectedHotbarSlot == 6 and PlayerSnapshot.decode(reselected).selectedHotbarSlot == 6,
		"encode, decode: the selected hotbar slot is in the view while a screen is open too"
	)
end

do -- the pack open alone, with a stack carried
	local world = newWorld()
	local state = world.players[1]
	PlayerState.openPackScreen(state)
	InventoryScreen.pickUpFromSlot(state.screen :: InventoryScreen.InventoryScreen, "pack", 7, 3)
	local encoded = PlayerSnapshot.encode(world, 1)
	local encodedScreen = encoded.screen
	check(
		encodedScreen ~= nil
			and encodedScreen.carriedStack ~= nil
			and encodedScreen.carriedStack.itemId == "apple"
			and encodedScreen.carriedStack.count == 3,
		"encode: the stack being carried is in the screen"
	)
	check(isPlain(encoded), "encode: and it is plain data")
	local view = PlayerSnapshot.decode(encoded)
	check(
		view.screen ~= nil and is(view.screen.carriedStack, "apple", 3),
		"decode: the stack that was carried is carried"
	)
	check(is(Inventory.getStack(view.pack, 7), "apple", 1), "decode: and what stayed in the pack is in the pack")
end

do -- a crate open
	local world, crateId = newWorld()
	local state = world.players[1]
	World.openPlacedItemScreen(world, state, crateId)
	local encoded = PlayerSnapshot.encode(world, 1)
	local screen = encoded.screen
	check(screen ~= nil and screen.otherInventoryItemId == "crate", "encode: says what kind of placed item is open")
	check(
		screen ~= nil
			and screen.otherInventory ~= nil
			and screen.otherInventory.slotCount == 27
			and #screen.otherInventory.stacks == 1,
		"encode: and what is in it"
	)
	check(
		screen ~= nil and screen.carriedStack == nil and screen.stationProgress == nil,
		"encode: with nothing carried, and no progress for a crate"
	)
	check(isPlain(encoded), "encode: all of it is plain data")

	local view = PlayerSnapshot.decode(encoded)
	check(
		view.otherInventoryItemId == "crate" and view.stationProgress == nil,
		"decode: knows it is a crate, and has no progress"
	)
	check(
		view.screen ~= nil
			and view.screen.otherInventory ~= nil
			and sameInventory(
				view.screen.otherInventory,
				(state.screen :: InventoryScreen.InventoryScreen).otherInventory :: Inventory.Inventory
			),
		"decode: the screen shows what is in the crate"
	)
	check(view.screen ~= nil and view.screen.pack == view.pack, "decode: beside the pack of the view")
	check(
		view.screen ~= nil
			and view.screen.otherInventory ~= (state.screen :: InventoryScreen.InventoryScreen).otherInventory,
		"decode: as a copy, not the crate itself"
	)

	-- With the fish carried.
	InventoryScreen.pickUpFromSlot(state.screen :: InventoryScreen.InventoryScreen, "other", 1, 4)
	local carrying = PlayerSnapshot.encode(world, 1)
	check(
		carrying.screen ~= nil and carrying.screen.carriedStack ~= nil and carrying.screen.carriedStack.count == 4,
		"encode: shows the stack being carried out of the crate"
	)
	check(isPlain(carrying), "encode: and it is plain data")
	local carryingView = PlayerSnapshot.decode(carrying)
	check(
		carryingView.screen ~= nil
			and is(carryingView.screen.carriedStack, "fish", 4)
			and carryingView.screen.otherInventory ~= nil
			and is(Inventory.getStack(carryingView.screen.otherInventory, 1), "fish", 1),
		"decode: gives back the stack carried and what was left in the crate"
	)
	check(carryingView.otherInventoryItemId == "crate", "decode: and the kind of placed item")
end

do -- an oven open
	local world, _, ovenId = newWorld()
	local state = world.players[1]
	local inside = world.plot.placedItemsById[ovenId].inventory :: Inventory.Inventory
	Inventory.setStack(inside, Station.INPUT_SLOT, ItemStack.new("fish", 3))
	Inventory.setStack(inside, Station.FUEL_SLOT, ItemStack.new("log", 4))
	World.openPlacedItemScreen(world, state, ovenId)

	local idle = PlayerSnapshot.encode(world, 1)
	check(
		idle.screen ~= nil
			and idle.screen.stationProgress ~= nil
			and idle.screen.stationProgress.fuelBurnsOutAt == nil
			and idle.screen.stationProgress.workDoneAt == nil,
		"encode: an oven that has not been lit has a progress with no fire and no work"
	)

	World.advanceTo(world, 4)
	local encoded = PlayerSnapshot.encode(world, 1)
	local screen = encoded.screen
	check(screen ~= nil and screen.otherInventoryItemId == "oven", "encode: says an oven is open")
	check(
		screen ~= nil
			and screen.stationProgress ~= nil
			and screen.stationProgress.fuelBurnsOutAt == 16
			and screen.stationProgress.workDoneAt == 8,
		"encode: with the times at which the log burns out and the fish is done"
	)
	check(
		screen ~= nil
			and screen.stationProgress ~= nil
			and math.abs(StationProgress.getFuelLeftRatio(screen.stationProgress, 4) - 0.75) < 1e-6
			and math.abs(StationProgress.getWorkDoneRatio(screen.stationProgress, 4) - 0.5) < 1e-6,
		"encode: from which the fire is three quarters left and the fish half done"
	)
	check(
		screen ~= nil and screen.otherInventory ~= nil and #screen.otherInventory.stacks == 2,
		"encode: and what is in the oven, a log having been burnt"
	)
	check(isPlain(encoded), "encode: all of it is plain data")

	local view = PlayerSnapshot.decode(encoded)
	check(view.otherInventoryItemId == "oven", "decode: knows it is an oven")
	check(
		view.stationProgress ~= nil
			and view.stationProgress.fuelBurnsOutAt == 16
			and view.stationProgress.fuelBurnSeconds == 16
			and view.stationProgress.workDoneAt == 8
			and view.stationProgress.workSeconds == 8,
		"decode: gives back the progress"
	)
	check(
		view.screen ~= nil and view.screen.otherInventory ~= nil and sameInventory(view.screen.otherInventory, inside),
		"decode: and what is in the oven"
	)

	-- Carrying a stack too.
	InventoryScreen.pickUpFromSlot(state.screen :: InventoryScreen.InventoryScreen, "pack", 7)
	local both = PlayerSnapshot.decode(PlayerSnapshot.encode(world, 1))
	check(
		both.screen ~= nil
			and is(both.screen.carriedStack, "apple", 4)
			and both.stationProgress ~= nil
			and both.otherInventoryItemId == "oven",
		"decode: an oven open and a stack carried come back together"
	)
end

do -- a player watching a lit oven is told again only when something happens
	-- Describes any plain value as text, the same text for the same value.
	local function describe(value: any): string
		if type(value) ~= "table" then
			return tostring(value)
		end
		local keys = {}
		for key in value do
			table.insert(keys, tostring(key))
		end
		table.sort(keys)
		local parts = {}
		for _, key in keys do
			local child = value[key]
			if child == nil then
				child = value[tonumber(key) :: number]
			end
			table.insert(parts, key .. "=" .. describe(child))
		end
		return "{" .. table.concat(parts, ",") .. "}"
	end

	local world, _, ovenId = newWorld()
	local inside = world.plot.placedItemsById[ovenId].inventory :: Inventory.Inventory
	Inventory.setStack(inside, Station.INPUT_SLOT, ItemStack.new("fish", 3))
	Inventory.setStack(inside, Station.FUEL_SLOT, ItemStack.new("log", 4))
	World.openPlacedItemScreen(world, world.players[1], ovenId)

	local told = describe(PlayerSnapshot.encode(world, 1))
	World.advanceTo(world, 0.1)
	local lit = describe(PlayerSnapshot.encode(world, 1))
	check(lit ~= told, "encode: what a player is told changes when the oven is lit")

	local changes = 0
	told = lit
	for tick = 2, 79 do
		World.advanceTo(world, tick / 10)
		local now = describe(PlayerSnapshot.encode(world, 1))
		if now ~= told then
			changes += 1
			told = now
		end
	end
	check(
		changes == 0,
		`encode: what a player is told does not change while the oven only burns and works; it changed {changes} times in 78 tenths of a second`
	)

	World.advanceTo(world, 8.1)
	check(describe(PlayerSnapshot.encode(world, 1)) ~= told, "encode: and changes again when a fish is done")
end

do -- the placed item is not on the plot any more
	local world, crateId = newWorld()
	World.openPlacedItemScreen(world, world.players[1], crateId)
	Plot.removePlacedItem(world.plot, crateId)
	local encoded = PlayerSnapshot.encode(world, 1)
	check(
		encoded.screen ~= nil and encoded.screen.otherInventoryItemId == nil,
		"encode: no kind of placed item for one that is off the plot"
	)
	check(
		encoded.screen ~= nil and encoded.screen.otherInventory ~= nil and encoded.screen.otherInventory.slotCount == 27,
		"encode: but the inventory that was open is still shown"
	)
end

do -- a player that is not in the world, and data that cannot be read
	local world = newWorld()
	local noPlayer = Check.errorFrom(function()
		PlayerSnapshot.encode(world, 5)
	end)
	check(
		noPlayer ~= nil and string.find(noPlayer, "no player has the id 5", 1, true) ~= nil,
		"encode: fails if no player has that id"
	)

	local good = PlayerSnapshot.encode(world, 1)
	local badPack = Check.errorFrom(function()
		PlayerSnapshot.decode({ pack = { slotCount = 0, stacks = {} }, selectedHotbarSlot = 1 })
	end)
	check(badPack ~= nil, "decode: fails if the pack cannot be read")
	local badOther = Check.errorFrom(function()
		PlayerSnapshot.decode({
			pack = good.pack,
			selectedHotbarSlot = 1,
			screen = { otherInventory = { slotCount = 3, stacks = { { slot = 9, itemId = "log", count = 1 } } } },
		})
	end)
	check(badOther ~= nil, "decode: fails if the other inventory cannot be read")
	local badCarried = Check.errorFrom(function()
		PlayerSnapshot.decode({
			pack = good.pack,
			selectedHotbarSlot = 1,
			screen = { carriedStack = { itemId = "log", count = 0 } },
		})
	end)
	check(badCarried ~= nil, "decode: fails if the carried stack cannot be read")
	local unknownCarried = Check.errorFrom(function()
		PlayerSnapshot.decode({
			pack = good.pack,
			selectedHotbarSlot = 1,
			screen = { carriedStack = { itemId = "nothing_like_it", count = 1 } },
		})
	end)
	check(unknownCarried ~= nil, "decode: fails if the carried item is not one that exists")
end

do -- whatever the world holds, a view decodes to the same
	local world, crateId, ovenId = newWorld()
	local state = world.players[1]
	local ids = { crateId, ovenId }
	local seed = 77
	local function random(limit: number): number
		seed = (seed * 16807) % 2147483647
		return math.floor(seed / 65536) % limit + 1
	end
	local itemIds = { "log", "fish", "apple" }
	local differences = 0
	for _ = 1, 300 do
		local kind = random(4)
		if kind == 1 then
			World.openPlacedItemScreen(world, state, ids[random(#ids)])
		elseif kind == 2 then
			World.closeScreen(world, state)
		elseif kind == 3 then
			local itemId = itemIds[random(#itemIds)]
			Inventory.addItems(state.pack, itemId, random(6))
			local screen = state.screen
			if screen ~= nil then
				InventoryScreen.pickUpFromSlot(screen, "pack", random(36), random(5))
			end
		else
			World.advanceTo(world, world.now + random(10))
		end
		local view = PlayerSnapshot.decode(PlayerSnapshot.encode(world, 1))
		local screen = state.screen
		local same = sameInventory(view.pack, state.pack) and (view.screen == nil) == (screen == nil)
		if same and view.screen ~= nil and screen ~= nil then
			local carried, viewCarried = screen.carriedStack, view.screen.carriedStack
			same = (carried == nil) == (viewCarried == nil)
				and (carried == nil or viewCarried == nil or carried.itemId == viewCarried.itemId and carried.count == viewCarried.count)
				and (screen.otherInventory == nil) == (view.screen.otherInventory == nil)
				and (
					screen.otherInventory == nil
					or view.screen.otherInventory == nil
					or sameInventory(screen.otherInventory, view.screen.otherInventory)
				)
		end
		if not same then
			differences += 1
		end
	end
	check(differences == 0, "300 random changes: the decoded view always shows what the player holds and has open")
end

Check.finish("PlayerSnapshot")
