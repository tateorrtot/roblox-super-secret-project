--!strict
-- Tests for PlayerView. Run from the repository root: lune run tests/world/PlayerView.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlayerView = require("../../src/shared/world/PlayerView")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")
local Station = require("../../src/shared/stations/Station")
local World = require("../../src/shared/world/World")

local check = Check.that

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
	local crateId = Plot.place(plot, "crate", 2, 2) :: number
	Inventory.setStack(plot.placedById[crateId].inventory :: Inventory.Inventory, 1, ItemStack.new("fish", 5))
	local ovenId = Plot.place(plot, "oven", 4, 2) :: number
	local world = World.new(plot, at(0, 0, 0), 0)
	local state = World.addPlayer(world, 1, at(0, 0, 0))
	Inventory.setStack(state.pack, 1, ItemStack.new("log", 12))
	Inventory.setStack(state.pack, 7, ItemStack.new("apple", 4))
	World.setPlayerPosition(world, 1, at(6, 0, 0))
	return world, crateId, ovenId
end

do -- no screen open
	local world = newWorld()
	local encoded = PlayerView.encode(world, 1)
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

	local view = PlayerView.decode(encoded)
	check(view.screen == nil, "decode: a view with no screen has no screen")
	check(view.otherItemId == nil and view.progress == nil, "decode: and no placed item and no progress")
	check(sameInventory(view.pack, world.players[1].pack), "decode: the pack is what the player holds")
	check(view.pack ~= world.players[1].pack, "decode: but is a copy of it")

	local state = world.players[1]
	Inventory.setStack(state.pack, 1, nil)
	check(is(Inventory.getStack(view.pack, 1), "log", 12), "decode: the view does not follow the world once it is made")
end

do -- the pack open alone
	local world = newWorld()
	local state = world.players[1]
	state.screen = InventoryScreen.new(state.pack)
	local encoded = PlayerView.encode(world, 1)
	check(encoded.screen ~= nil, "encode: a player with the pack open has a screen in their view")
	local screen = encoded.screen
	check(
		screen ~= nil
			and screen.other == nil
			and screen.otherItemId == nil
			and screen.carried == nil
			and screen.progress == nil,
		"encode: with nothing beside the pack, nothing carried and no progress"
	)
	check(isPlain(encoded), "encode: all of it is plain data")

	local view = PlayerView.decode(encoded)
	check(view.screen ~= nil, "decode: the screen is open")
	check(view.screen ~= nil and view.screen.pack == view.pack, "decode: and shows the pack of the view")
	check(
		view.screen ~= nil and view.screen.other == nil and view.screen.carried == nil,
		"decode: with nothing beside it and nothing carried"
	)
	check(view.otherItemId == nil and view.progress == nil, "decode: and no placed item and no progress")
	check(sameInventory(view.pack, state.pack), "decode: the pack is what the player holds")
end

do -- the pack open alone, with a stack carried
	local world = newWorld()
	local state = world.players[1]
	local screen = InventoryScreen.new(state.pack)
	state.screen = screen
	InventoryScreen.pickUp(screen, "pack", 7, 3)
	local encoded = PlayerView.encode(world, 1)
	local encodedScreen = encoded.screen
	check(
		encodedScreen ~= nil
			and encodedScreen.carried ~= nil
			and encodedScreen.carried.itemId == "apple"
			and encodedScreen.carried.count == 3,
		"encode: the stack being carried is in the screen"
	)
	check(isPlain(encoded), "encode: and it is plain data")
	local view = PlayerView.decode(encoded)
	check(view.screen ~= nil and is(view.screen.carried, "apple", 3), "decode: the stack that was carried is carried")
	check(is(Inventory.getStack(view.pack, 7), "apple", 1), "decode: and what stayed in the pack is in the pack")
end

do -- a crate open
	local world, crateId = newWorld()
	local state = world.players[1]
	World.openPlaced(world, state, crateId)
	local encoded = PlayerView.encode(world, 1)
	local screen = encoded.screen
	check(screen ~= nil and screen.otherItemId == "crate", "encode: says what kind of placed item is open")
	check(
		screen ~= nil and screen.other ~= nil and screen.other.slotCount == 27 and #screen.other.stacks == 1,
		"encode: and what is in it"
	)
	check(
		screen ~= nil and screen.carried == nil and screen.progress == nil,
		"encode: with nothing carried, and no progress for a crate"
	)
	check(isPlain(encoded), "encode: all of it is plain data")

	local view = PlayerView.decode(encoded)
	check(view.otherItemId == "crate" and view.progress == nil, "decode: knows it is a crate, and has no progress")
	check(
		view.screen ~= nil
			and view.screen.other ~= nil
			and sameInventory(
				view.screen.other,
				(state.screen :: InventoryScreen.InventoryScreen).other :: Inventory.Inventory
			),
		"decode: the screen shows what is in the crate"
	)
	check(view.screen ~= nil and view.screen.pack == view.pack, "decode: beside the pack of the view")
	check(
		view.screen ~= nil and view.screen.other ~= (state.screen :: InventoryScreen.InventoryScreen).other,
		"decode: as a copy, not the crate itself"
	)

	-- With the fish carried.
	InventoryScreen.pickUp(state.screen :: InventoryScreen.InventoryScreen, "other", 1, 4)
	local carrying = PlayerView.encode(world, 1)
	check(
		carrying.screen ~= nil and carrying.screen.carried ~= nil and carrying.screen.carried.count == 4,
		"encode: shows the stack being carried out of the crate"
	)
	check(isPlain(carrying), "encode: and it is plain data")
	local carryingView = PlayerView.decode(carrying)
	check(
		carryingView.screen ~= nil
			and is(carryingView.screen.carried, "fish", 4)
			and carryingView.screen.other ~= nil
			and is(Inventory.getStack(carryingView.screen.other, 1), "fish", 1),
		"decode: gives back the stack carried and what was left in the crate"
	)
	check(carryingView.otherItemId == "crate", "decode: and the kind of placed item")
end

do -- an oven open
	local world, _, ovenId = newWorld()
	local state = world.players[1]
	local inside = world.plot.placedById[ovenId].inventory :: Inventory.Inventory
	Inventory.setStack(inside, Station.INPUT_SLOT, ItemStack.new("fish", 3))
	Inventory.setStack(inside, Station.FUEL_SLOT, ItemStack.new("log", 4))
	World.openPlaced(world, state, ovenId)

	local idle = PlayerView.encode(world, 1)
	check(
		idle.screen ~= nil
			and idle.screen.progress ~= nil
			and idle.screen.progress.burning == 0
			and idle.screen.progress.working == 0,
		"encode: an oven that has not been lit has progress of nothing"
	)

	World.step(world, 4)
	local encoded = PlayerView.encode(world, 1)
	local screen = encoded.screen
	check(screen ~= nil and screen.otherItemId == "oven", "encode: says an oven is open")
	check(
		screen ~= nil
			and screen.progress ~= nil
			and math.abs(screen.progress.burning - 0.75) < 1e-6
			and math.abs(screen.progress.working - 0.5) < 1e-6,
		"encode: with how far the fire and the work have got"
	)
	check(
		screen ~= nil and screen.other ~= nil and #screen.other.stacks == 2,
		"encode: and what is in the oven, a log having been burnt"
	)
	check(isPlain(encoded), "encode: all of it is plain data")

	local view = PlayerView.decode(encoded)
	check(view.otherItemId == "oven", "decode: knows it is an oven")
	check(
		view.progress ~= nil
			and math.abs(view.progress.burning - 0.75) < 1e-6
			and math.abs(view.progress.working - 0.5) < 1e-6,
		"decode: gives back the progress"
	)
	check(
		view.screen ~= nil and view.screen.other ~= nil and sameInventory(view.screen.other, inside),
		"decode: and what is in the oven"
	)

	-- Carrying a stack too.
	InventoryScreen.pickUp(state.screen :: InventoryScreen.InventoryScreen, "pack", 7)
	local both = PlayerView.decode(PlayerView.encode(world, 1))
	check(
		both.screen ~= nil
			and is(both.screen.carried, "apple", 4)
			and both.progress ~= nil
			and both.otherItemId == "oven",
		"decode: an oven open and a stack carried come back together"
	)
end

do -- the placed item is not on the plot any more
	local world, crateId = newWorld()
	World.openPlaced(world, world.players[1], crateId)
	Plot.remove(world.plot, crateId)
	local encoded = PlayerView.encode(world, 1)
	check(
		encoded.screen ~= nil and encoded.screen.otherItemId == nil,
		"encode: no kind of placed item for one that is off the plot"
	)
	check(
		encoded.screen ~= nil and encoded.screen.other ~= nil and encoded.screen.other.slotCount == 27,
		"encode: but the inventory that was open is still shown"
	)
end

do -- a player that is not in the world, and data that cannot be read
	local world = newWorld()
	local noPlayer = Check.errorFrom(function()
		PlayerView.encode(world, 5)
	end)
	check(
		noPlayer ~= nil and string.find(noPlayer, "no player has the id 5", 1, true) ~= nil,
		"encode: fails if no player has that id"
	)

	local good = PlayerView.encode(world, 1)
	local badPack = Check.errorFrom(function()
		PlayerView.decode({ pack = { slotCount = 0, stacks = {} } })
	end)
	check(badPack ~= nil, "decode: fails if the pack cannot be read")
	local badOther = Check.errorFrom(function()
		PlayerView.decode({
			pack = good.pack,
			screen = { other = { slotCount = 3, stacks = { { slot = 9, itemId = "log", count = 1 } } } },
		})
	end)
	check(badOther ~= nil, "decode: fails if the other inventory cannot be read")
	local badCarried = Check.errorFrom(function()
		PlayerView.decode({ pack = good.pack, screen = { carried = { itemId = "log", count = 0 } } })
	end)
	check(badCarried ~= nil, "decode: fails if the carried stack cannot be read")
	local unknownCarried = Check.errorFrom(function()
		PlayerView.decode({ pack = good.pack, screen = { carried = { itemId = "nothing_like_it", count = 1 } } })
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
			World.openPlaced(world, state, ids[random(#ids)])
		elseif kind == 2 then
			World.closeScreen(world, state)
		elseif kind == 3 then
			local itemId = itemIds[random(#itemIds)]
			Inventory.addItems(state.pack, itemId, random(6))
			local screen = state.screen
			if screen ~= nil then
				InventoryScreen.pickUp(screen, "pack", random(36), random(5))
			end
		else
			World.step(world, world.now + random(10))
		end
		local view = PlayerView.decode(PlayerView.encode(world, 1))
		local screen = state.screen
		local same = sameInventory(view.pack, state.pack) and (view.screen == nil) == (screen == nil)
		if same and view.screen ~= nil and screen ~= nil then
			local carried, viewCarried = screen.carried, view.screen.carried
			same = (carried == nil) == (viewCarried == nil)
				and (carried == nil or viewCarried == nil or carried.itemId == viewCarried.itemId and carried.count == viewCarried.count)
				and (screen.other == nil) == (view.screen.other == nil)
				and (screen.other == nil or view.screen.other == nil or sameInventory(screen.other, view.screen.other))
		end
		if not same then
			differences += 1
		end
	end
	check(differences == 0, "300 random changes: the decoded view always shows what the player holds and has open")
end

Check.finish("PlayerView")
