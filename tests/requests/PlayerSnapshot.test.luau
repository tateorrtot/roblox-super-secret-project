--!strict
-- Tests for PlayerSnapshot. Run from the repository root: lune run tests/requests/PlayerSnapshot.test.luau

local Check = require("../Check")
local Hotbar = require("../../src/shared/inventory/Hotbar")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlacedObjectScripts = require("../../src/shared/requests/PlacedObjectScripts")
local PlayerSnapshot = require("../../src/shared/requests/PlayerSnapshot")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local World = require("../../src/shared/world/World")

local check = Check.that

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "apple", stackSize = 16 })

-- The kinds of placed object the tests use, all made up. "chest" has no script. "bell" has a script
-- with a getScreenData that returns `bellData` and notes each call. "drum" has a script with no
-- getScreenData.
local bellData = { rings = 3, tones = { "low", "high" } }
local bellCalls: { { world: World.World, placedObjectId: number } } = {}
PlacedObjectScripts.register("bell", {
	getScreenData = function(world, placedObjectId)
		table.insert(bellCalls, { world = world, placedObjectId = placedObjectId })
		return bellData
	end,
})
PlacedObjectScripts.register("drum", {
	interact = function() end,
})

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

-- The inventory that a placed object that is known to have one has on it.
local function insideOf(world: World.World, placedObjectId: number): Inventory.Inventory
	local placedObject = world.plot.placedObjectsById[placedObjectId] :: any
	return placedObject.inventory
end

-- Opens a player's screen on the inventory inside a placed object, with no rule for its slots.
local function openOn(world: World.World, state: PlayerState.PlayerState, placedObjectId: number)
	World.openPlacedObjectScreen(world, state, placedObjectId, insideOf(world, placedObjectId))
end

-- A world with a chest holding 5 fish on tile 2, 2, a bell on tile 4, 2 and a drum on tile 1, 5, each
-- with an inventory. Player 1 stands near them with 12 logs and 4 apples in their pack.
local function newWorld(): (World.World, number, number, number)
	local world = World.new(Plot.new(6, 6), at(0, 0, 0), 0)
	local chestId =
		Plot.placeObject(world.plot, { kindId = "chest", tileX = 2, tileZ = 2, inventory = Inventory.new(27) })
	Inventory.setStack(insideOf(world, chestId), 1, ItemStack.new("fish", 5))
	local bellId = Plot.placeObject(world.plot, { kindId = "bell", tileX = 4, tileZ = 2, inventory = Inventory.new(3) })
	local drumId = Plot.placeObject(world.plot, { kindId = "drum", tileX = 1, tileZ = 5, inventory = Inventory.new(2) })
	local state = World.addPlayer(world, 1)
	Inventory.setStack(state.pack, 1, ItemStack.new("log", 12))
	Inventory.setStack(state.pack, 7, ItemStack.new("apple", 4))
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	return world, chestId, bellId, drumId
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
	check(view.placedObjectKindId == nil and view.screenData == nil, "decode: and no placed object and no screen data")
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
	PlayerState.openScreen(state)
	local encoded = PlayerSnapshot.encode(world, 1)
	check(encoded.screen ~= nil, "encode: a player with the pack open has a screen in their view")
	local screen = encoded.screen
	check(
		screen ~= nil
			and screen.otherInventory == nil
			and screen.placedObjectKindId == nil
			and screen.carriedStack == nil
			and screen.screenData == nil,
		"encode: with nothing beside the pack, nothing carried and no screen data"
	)
	check(isPlain(encoded), "encode: all of it is plain data")

	local view = PlayerSnapshot.decode(encoded)
	check(view.screen ~= nil, "decode: the screen is open")
	check(view.screen ~= nil and view.screen.pack == view.pack, "decode: and shows the pack of the view")
	check(
		view.screen ~= nil and view.screen.otherInventory == nil and view.screen.carriedStack == nil,
		"decode: with nothing beside it and nothing carried"
	)
	check(view.placedObjectKindId == nil and view.screenData == nil, "decode: and no placed object and no screen data")
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
	PlayerState.openScreen(state)
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
	check(
		view.screen ~= nil and view.screen.otherSlotAcceptsItem == nil,
		"decode: the screen read back has no rule for the slots of another inventory"
	)
end

do -- a chest open
	local world, chestId = newWorld()
	local state = world.players[1]
	openOn(world, state, chestId)
	local encoded = PlayerSnapshot.encode(world, 1)
	local screen = encoded.screen
	check(screen ~= nil and screen.placedObjectKindId == "chest", "encode: says what kind of placed object is open")
	check(
		screen ~= nil
			and screen.otherInventory ~= nil
			and screen.otherInventory.slotCount == 27
			and #screen.otherInventory.stacks == 1,
		"encode: and what is in it"
	)
	check(
		screen ~= nil and screen.carriedStack == nil and screen.screenData == nil,
		"encode: with nothing carried, and no screen data for a kind with no script"
	)
	check(isPlain(encoded), "encode: all of it is plain data")

	local view = PlayerSnapshot.decode(encoded)
	check(
		view.placedObjectKindId == "chest" and view.screenData == nil,
		"decode: knows it is a chest, and has no screen data"
	)
	check(
		view.screen ~= nil
			and view.screen.otherInventory ~= nil
			and sameInventory(
				view.screen.otherInventory,
				(state.screen :: InventoryScreen.InventoryScreen).otherInventory :: Inventory.Inventory
			),
		"decode: the screen shows what is in the chest"
	)
	check(view.screen ~= nil and view.screen.pack == view.pack, "decode: beside the pack of the view")
	check(
		view.screen ~= nil
			and view.screen.otherInventory ~= (state.screen :: InventoryScreen.InventoryScreen).otherInventory,
		"decode: as a copy, not the chest itself"
	)

	-- With the fish carried.
	InventoryScreen.pickUpFromSlot(state.screen :: InventoryScreen.InventoryScreen, "other", 1, 4)
	local carrying = PlayerSnapshot.encode(world, 1)
	check(
		carrying.screen ~= nil and carrying.screen.carriedStack ~= nil and carrying.screen.carriedStack.count == 4,
		"encode: shows the stack being carried out of the chest"
	)
	check(isPlain(carrying), "encode: and it is plain data")
	local carryingView = PlayerSnapshot.decode(carrying)
	check(
		carryingView.screen ~= nil
			and is(carryingView.screen.carriedStack, "fish", 4)
			and carryingView.screen.otherInventory ~= nil
			and is(Inventory.getStack(carryingView.screen.otherInventory, 1), "fish", 1),
		"decode: gives back the stack carried and what was left in the chest"
	)
	check(carryingView.placedObjectKindId == "chest", "decode: and the kind of placed object")
end

do -- a bell open, a kind whose script has a getScreenData
	local world, _, bellId = newWorld()
	local state = world.players[1]
	local inside = insideOf(world, bellId)
	Inventory.setStack(inside, 1, ItemStack.new("fish", 3))
	openOn(world, state, bellId)

	local callsBefore = #bellCalls
	local encoded = PlayerSnapshot.encode(world, 1)
	local screen = encoded.screen
	check(screen ~= nil and screen.placedObjectKindId == "bell", "encode: says a bell is open")
	check(
		screen ~= nil and screen.screenData == bellData,
		"encode: the screen data is what the getScreenData of the script of the kind returned, as it was returned"
	)
	check(
		#bellCalls == callsBefore + 1
			and bellCalls[#bellCalls].world == world
			and bellCalls[#bellCalls].placedObjectId == bellId,
		"encode: calls the getScreenData of the script once, with the world and the id of the placed object that the screen is open on"
	)
	check(
		screen ~= nil and screen.otherInventory ~= nil and #screen.otherInventory.stacks == 1,
		"encode: and what is in the bell"
	)
	check(isPlain(encoded), "encode: all of it is plain data")
	PlayerSnapshot.encode(world, 1)
	check(#bellCalls == callsBefore + 2, "encode: calls the getScreenData again for each encode")

	local view = PlayerSnapshot.decode(encoded)
	check(view.placedObjectKindId == "bell", "decode: knows it is a bell")
	check(view.screenData == bellData, "decode: gives back the screen data")
	check(
		view.screen ~= nil and view.screen.otherInventory ~= nil and sameInventory(view.screen.otherInventory, inside),
		"decode: and what is in the bell"
	)
	check(#bellCalls == callsBefore + 2, "decode: does not call the getScreenData")

	-- Carrying a stack too.
	InventoryScreen.pickUpFromSlot(state.screen :: InventoryScreen.InventoryScreen, "pack", 7)
	local both = PlayerSnapshot.decode(PlayerSnapshot.encode(world, 1))
	check(
		both.screen ~= nil
			and is(both.screen.carriedStack, "apple", 4)
			and both.screenData == bellData
			and both.placedObjectKindId == "bell",
		"decode: a bell open and a stack carried come back together"
	)
end

do -- a drum open, a kind whose script has no getScreenData
	local world, _, _, drumId = newWorld()
	openOn(world, world.players[1], drumId)
	local encoded = PlayerSnapshot.encode(world, 1)
	local screen = encoded.screen
	check(
		screen ~= nil and screen.placedObjectKindId == "drum" and screen.screenData == nil,
		"encode: a kind whose script has no getScreenData has no screen data"
	)
	local view = PlayerSnapshot.decode(encoded)
	check(
		view.placedObjectKindId == "drum" and view.screenData == nil,
		"decode: and the view has none, with the kind still known"
	)
end

do -- the placed object is not on the plot any more
	local world, chestId = newWorld()
	openOn(world, world.players[1], chestId)
	Plot.removePlacedObject(world.plot, chestId)
	local encoded = PlayerSnapshot.encode(world, 1)
	check(
		encoded.screen == nil,
		"encode: a player whose placed object was taken off the plot has no screen, since the world closed it"
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
	local world, chestId, bellId = newWorld()
	local state = world.players[1]
	local ids = { chestId, bellId }
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
			openOn(world, state, ids[random(#ids)])
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
