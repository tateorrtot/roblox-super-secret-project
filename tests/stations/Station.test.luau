--!strict
-- Tests for Station. Run from the repository root: lune run tests/stations/Station.test.luau

local Check = require("../Check")
local FuelRegistry = require("../../src/shared/stations/FuelRegistry")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")
local Station = require("../../src/shared/stations/Station")

local check = Check.that

ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "cooked_fish", stackSize = 8 })
ItemRegistry.register({ id = "apple", stackSize = 16 })
ItemRegistry.register({ id = "baked_apple", stackSize = 16 })
ItemRegistry.register({ id = "stone", stackSize = 16 })
ItemRegistry.register({ id = "log", stackSize = 16 })
FuelRegistry.register({ item = "log", seconds = 16 })
ItemRegistry.register({ id = "twig", stackSize = 16 })
FuelRegistry.register({ item = "twig", seconds = 2 })
ItemRegistry.register({ id = "stove", stackSize = 1 })
ItemRegistry.register({ id = "crate", stackSize = 1 })
RecipeRegistry.register({ station = "stove", input = "fish", output = "cooked_fish", seconds = 8 })
RecipeRegistry.register({ station = "stove", input = "apple", output = "baked_apple", seconds = 6 })

local INPUT, FUEL, OUTPUT = Station.INPUT_SLOT, Station.FUEL_SLOT, Station.OUTPUT_SLOT

-- Returns the stack that `text` describes, such as "fish 3", or nil for "-".
local function stackOf(text: string): ItemStack.ItemStack?
	if text == "-" then
		return nil
	end
	local itemId, count = string.match(text, "^([%a_]+) (%d+)$")
	return ItemStack.new(itemId :: string, tonumber(count) :: number)
end

-- Returns a stove holding what the three texts describe in its input, fuel and output slots.
local function stoveWith(input: string, fuel: string, output: string): Station.Station
	local inventory = Inventory.new(3)
	Inventory.setStack(inventory, INPUT, stackOf(input))
	Inventory.setStack(inventory, FUEL, stackOf(fuel))
	Inventory.setStack(inventory, OUTPUT, stackOf(output))
	return Station.new("stove", inventory)
end

-- Describes what the station's three slots hold, as "fish 3, log 4, -".
local function contents(station: Station.Station): string
	local parts = {}
	for slot = 1, 3 do
		local stack = Inventory.getStack(station.inventory, slot)
		table.insert(parts, if stack then stack.itemId .. " " .. stack.count else "-")
	end
	return table.concat(parts, ", ")
end

local function near(a: number, b: number): boolean
	return math.abs(a - b) < 1e-6
end

do -- the slots
	check(INPUT == 1 and FUEL == 2 and OUTPUT == 3, "the slots are: what goes in, fuel, what comes out")
	check(Station.SLOT_COUNT == 3, "SLOT_COUNT: a station has three slots")
end

do -- a new station
	local inventory = Inventory.new(3)
	local station = Station.new("stove", inventory)
	check(
		station.kindId == "stove" and station.inventory == inventory,
		"new: is of the kind it was given, over the inventory it was given"
	)
	check(station.burnSecondsLeft == 0 and station.burnSecondsTotal == 0, "new: no fire has been lit")
	check(station.workedSeconds == 0 and station.workingOnItemId == nil, "new: nothing is being worked on")
	check(not Station.isBurning(station), "isBurning: false for a new station")
end

do -- what a station can work on
	check(
		Station.getWorkableRecipe(stoveWith("-", "log 4", "-")) == nil,
		"getRecipe: nil when the input slot holds nothing"
	)
	local recipe = Station.getWorkableRecipe(stoveWith("fish 2", "-", "-"))
	check(
		recipe ~= nil and recipe.output == "cooked_fish",
		"getRecipe: the recipe for what is in the input slot, fire or no fire"
	)
	check(
		(Station.getWorkableRecipe(stoveWith("apple 1", "-", "-")) :: any).seconds == 6,
		"getRecipe: each input has its own"
	)
	check(
		Station.getWorkableRecipe(stoveWith("stone 2", "log 4", "-")) == nil,
		"getRecipe: nil for an item the station does nothing with"
	)
	check(
		Station.getWorkableRecipe(stoveWith("fish 2", "log 4", "baked_apple 1")) == nil,
		"getRecipe: nil when the output slot holds something else"
	)
	check(
		Station.getWorkableRecipe(stoveWith("fish 2", "log 4", "cooked_fish 8")) == nil,
		"getRecipe: nil when the output slot is full"
	)
	check(
		Station.getWorkableRecipe(stoveWith("fish 2", "log 4", "cooked_fish 7")) ~= nil,
		"getRecipe: there when the output slot has room for one more"
	)
end

do -- cooking one fish
	local station = stoveWith("fish 1", "log 4", "-")
	Station.advance(station, 0.5)
	check(contents(station) == "fish 1, log 3, -", "advance: lighting the fire uses up one item of fuel")
	check(
		Station.isBurning(station) and station.burnSecondsLeft == 15.5 and station.burnSecondsTotal == 16,
		"advance: the fire burns for as long as that item burns"
	)
	check(
		station.workedSeconds == 0.5 and station.workingOnItemId == "fish",
		"advance: the fish has been worked on for the time that passed"
	)
	Station.advance(station, 7.5)
	check(
		contents(station) == "-, log 3, cooked_fish 1",
		"advance: after its recipe's time the fish is a cooked fish in the output slot"
	)
	check(
		station.workedSeconds == 0 and station.burnSecondsLeft == 8,
		"advance: nothing is being worked on, and the fire burns on"
	)
	Station.advance(station, 7.9)
	check(
		Station.isBurning(station) and near(station.burnSecondsLeft, 0.1),
		"advance: the fire burns down with nothing to work on"
	)
	Station.advance(station, 100)
	check(not Station.isBurning(station) and station.burnSecondsLeft == 0, "advance: and goes out")
	check(contents(station) == "-, log 3, cooked_fish 1", "advance: no fuel is used when there is nothing to work on")
	check(station.workingOnItemId == nil, "advance: and nothing is being worked on")
end

do -- a fire is never lit for nothing
	local fuelOnly = stoveWith("-", "log 4", "-")
	Station.advance(fuelOnly, 30)
	check(contents(fuelOnly) == "-, log 4, -" and not Station.isBurning(fuelOnly), "advance: fuel alone lights no fire")
	local noFuel = stoveWith("fish 3", "-", "-")
	Station.advance(noFuel, 30)
	check(
		contents(noFuel) == "fish 3, -, -" and noFuel.workedSeconds == 0,
		"advance: with no fuel nothing is worked on"
	)
	local noRecipe = stoveWith("stone 3", "log 4", "-")
	Station.advance(noRecipe, 30)
	check(contents(noRecipe) == "stone 3, log 4, -", "advance: an item the station does nothing with lights no fire")
	local notFuel = stoveWith("fish 3", "stone 4", "-")
	Station.advance(notFuel, 30)
	check(contents(notFuel) == "fish 3, stone 4, -", "advance: an item that does not burn lights no fire")
	local blocked = stoveWith("fish 3", "log 4", "stone 1")
	Station.advance(blocked, 30)
	check(
		contents(blocked) == "fish 3, log 4, stone 1",
		"advance: nor is one lit when the output slot holds something else"
	)
	local full = stoveWith("fish 3", "log 4", "cooked_fish 8")
	Station.advance(full, 30)
	check(contents(full) == "fish 3, log 4, cooked_fish 8", "advance: or is full")
end

do -- many items, and one long step against many short ones
	local long = stoveWith("fish 5", "log 4", "-")
	Station.advance(long, 40)
	check(contents(long) == "-, log 1, cooked_fish 5", "advance: five fish take forty seconds and three logs")
	check(
		near(long.burnSecondsLeft, 8) and long.workedSeconds == 0,
		"advance: the third log has eight seconds left to burn"
	)

	local short = stoveWith("fish 5", "log 4", "-")
	for _ = 1, 400 do
		Station.advance(short, 0.1)
	end
	check(contents(short) == contents(long), "advance: four hundred steps of a tenth of a second end the same way")
	check(
		near(short.burnSecondsLeft, long.burnSecondsLeft) and near(short.workedSeconds, long.workedSeconds),
		"advance: with the same fire and the same work done"
	)

	local whole = stoveWith("fish 1", "log 1", "-")
	Station.advance(whole, 16)
	local pieces = stoveWith("fish 1", "log 1", "-")
	for _ = 1, 160 do
		Station.advance(pieces, 0.1)
	end
	local thirds = stoveWith("fish 1", "log 1", "-")
	for _ = 1, 48 do
		Station.advance(thirds, 1 / 3)
	end
	check(
		not Station.isBurning(whole) and whole.burnSecondsLeft == 0,
		"advance: a log is burnt out after its sixteen seconds"
	)
	check(
		not Station.isBurning(pieces)
			and pieces.burnSecondsLeft == 0
			and not Station.isBurning(thirds)
			and thirds.burnSecondsLeft == 0,
		"advance: and just as burnt out when the sixteen seconds came in small pieces"
	)

	local uneven = stoveWith("fish 5", "log 4", "-")
	for _, seconds in { 3, 0, 9.5, 0.25, 11, 16.25 } do
		Station.advance(uneven, seconds)
	end
	check(
		contents(uneven) == contents(long) and near(uneven.burnSecondsLeft, 8),
		"advance: and so do uneven steps of the same total"
	)

	local partway = stoveWith("fish 5", "log 4", "-")
	Station.advance(partway, 20)
	check(
		contents(partway) == "fish 3, log 2, cooked_fish 2",
		"advance: after twenty seconds two fish are done and a second log is lit"
	)
	check(near(partway.workedSeconds, 4) and near(partway.burnSecondsLeft, 12), "advance: the third fish is half done")
end

do -- the fire going out, and coming back
	local station = stoveWith("fish 1", "twig 1", "-")
	Station.advance(station, 2)
	check(
		contents(station) == "fish 1, -, -" and near(station.workedSeconds, 2),
		"advance: a twig burns for two seconds of work"
	)
	check(not Station.isBurning(station), "advance: and then the fire is out")
	Station.advance(station, 1)
	check(
		station.workedSeconds == 0 and station.workingOnItemId == nil,
		"advance: with no fuel to light it again, the work done is lost"
	)
	check(contents(station) == "fish 1, -, -", "advance: but the fish is still there")
	Inventory.setStack(station.inventory, FUEL, ItemStack.new("twig", 5))
	Station.advance(station, 8)
	check(contents(station) == "-, twig 1, cooked_fish 1", "advance: four twigs, one after another, cook the fish")

	local relit = stoveWith("fish 2", "twig 16", "-")
	Station.advance(relit, 5)
	check(
		near(relit.workedSeconds, 5) and contents(relit) == "fish 2, twig 13, -",
		"advance: a fire that goes out mid-work is lit again at once if there is fuel, and the work goes on"
	)
end

do -- changing what is in the input slot
	local station = stoveWith("fish 1", "log 4", "-")
	Station.advance(station, 5)
	Inventory.setStack(station.inventory, INPUT, ItemStack.new("apple", 1))
	Station.advance(station, 1)
	check(
		station.workingOnItemId == "apple" and near(station.workedSeconds, 1),
		"advance: a different item in the input slot starts from nothing"
	)
	Station.advance(station, 4.9)
	check(contents(station) == "apple 1, log 3, -", "advance: so the apple is not done early")
	Station.advance(station, 0.1)
	check(contents(station) == "-, log 3, baked_apple 1", "advance: it is done after its own recipe's time")

	local taken = stoveWith("fish 1", "log 4", "-")
	Station.advance(taken, 5)
	Inventory.setStack(taken.inventory, INPUT, nil)
	Station.advance(taken, 1)
	check(
		taken.workedSeconds == 0 and taken.workingOnItemId == nil,
		"advance: taking the item away loses the work done on it"
	)
	Inventory.setStack(taken.inventory, INPUT, ItemStack.new("fish", 1))
	Station.advance(taken, 7.9)
	check(contents(taken) == "fish 1, log 3, -", "advance: and one put back is worked on from the start")
end

do -- the output slot filling up
	local station = stoveWith("fish 8", "log 8", "cooked_fish 7")
	Station.advance(station, 8)
	check(contents(station) == "fish 7, log 7, cooked_fish 8", "advance: the last one that fits is made")
	Station.advance(station, 200)
	check(contents(station) == "fish 7, log 7, cooked_fish 8", "advance: and then work stops, and no more fuel is used")
	check(not Station.isBurning(station), "advance: once the log that was burning has burnt out")
	Inventory.takeFromSlot(station.inventory, OUTPUT, 3)
	Station.advance(station, 8)
	check(
		contents(station) == "fish 6, log 6, cooked_fish 6",
		"advance: making room in the output slot starts the work again"
	)
end

do -- which items each slot takes
	check(
		Station.slotAcceptsItem("stove", INPUT, "fish") and Station.slotAcceptsItem("stove", INPUT, "apple"),
		"slotAcceptsItem: the input slot takes what the station has recipes for"
	)
	check(
		not Station.slotAcceptsItem("stove", INPUT, "log")
			and not Station.slotAcceptsItem("stove", INPUT, "stone")
			and not Station.slotAcceptsItem("stove", INPUT, "cooked_fish"),
		"slotAcceptsItem: the input slot takes nothing else"
	)
	check(
		Station.slotAcceptsItem("stove", FUEL, "log") and Station.slotAcceptsItem("stove", FUEL, "twig"),
		"slotAcceptsItem: the fuel slot takes what burns"
	)
	check(
		not Station.slotAcceptsItem("stove", FUEL, "fish") and not Station.slotAcceptsItem("stove", FUEL, "stone"),
		"slotAcceptsItem: the fuel slot takes nothing that does not burn, even what the station has a recipe for"
	)
	check(
		not Station.slotAcceptsItem("stove", OUTPUT, "cooked_fish")
			and not Station.slotAcceptsItem("stove", OUTPUT, "log")
			and not Station.slotAcceptsItem("stove", OUTPUT, "fish"),
		"slotAcceptsItem: the output slot takes nothing"
	)
	check(
		not Station.slotAcceptsItem("crate", INPUT, "fish"),
		"slotAcceptsItem: a kind of item with no recipes takes nothing in its input slot"
	)

	local pack = Inventory.new(4)
	Inventory.setStack(pack, 1, ItemStack.new("log", 6))
	Inventory.setStack(pack, 2, ItemStack.new("fish", 2))
	Inventory.setStack(pack, 3, ItemStack.new("stone", 1))
	local station = stoveWith("-", "-", "cooked_fish 1")
	local screen = InventoryScreen.new(pack, station.inventory, function(slot: number, itemId: string): boolean
		return Station.slotAcceptsItem("stove", slot, itemId)
	end)
	check(
		InventoryScreen.moveFromSlotToInventory(screen, "pack", 1, "other") == 6,
		"moveFromSlotToInventory: logs sent to the stove all go in"
	)
	check(
		InventoryScreen.moveFromSlotToInventory(screen, "pack", 2, "other") == 2,
		"moveFromSlotToInventory: fish sent to the stove all go in"
	)
	check(
		InventoryScreen.moveFromSlotToInventory(screen, "pack", 3, "other") == 0,
		"moveFromSlotToInventory: stone sent to the stove goes nowhere"
	)
	check(
		contents(station) == "fish 2, log 6, cooked_fish 1",
		"moveFromSlotToInventory: each thing sent to the stove lands in its own slot"
	)
	check(
		Inventory.countItems(pack, "stone") == 1,
		"moveFromSlotToInventory: what the station has no use for stays in the pack"
	)
	check(
		InventoryScreen.pickUpFromSlot(screen, "other", OUTPUT) == 1,
		"pickUpFromSlot: what was made can be taken out"
	)
	check(
		InventoryScreen.putDownInSlot(screen, "other", OUTPUT) == 0,
		"putDownInSlot: nothing can be put where it came from"
	)
	local done = stoveWith("fish 1", "log 1", "-")
	Station.advance(done, 8)
	local doneScreen = InventoryScreen.new(
		Inventory.new(4),
		done.inventory,
		function(slot: number, itemId: string): boolean
			return Station.slotAcceptsItem("stove", slot, itemId)
		end
	)
	check(
		InventoryScreen.pickUpFromSlot(doneScreen, "other", OUTPUT) == 1,
		"pickUpFromSlot: a cooked fish made by advance can be taken out"
	)
	check(
		doneScreen.carriedStack ~= nil and doneScreen.carriedStack.itemId == "cooked_fish",
		"pickUpFromSlot: and what is carried is the cooked fish"
	)
end

do -- steps of no time, and of one second at a time
	local station = stoveWith("fish 1", "log 1", "-")
	Station.advance(station, 0)
	check(
		contents(station) == "fish 1, log 1, -" and not Station.isBurning(station),
		"advance: 0 seconds changes nothing"
	)
	check(station.burnSecondsTotal == 0, "advance: and lights no fire")
end

do -- the length of a fire that is out
	local station = stoveWith("fish 1", "log 1", "-")
	check(station.burnSecondsTotal == 0, "burnSecondsTotal: 0 before a fire is lit")
	Station.advance(station, 4)
	check(station.burnSecondsTotal == 16, "burnSecondsTotal: how long the item burning burns in all, while it burns")
	Station.advance(station, 100)
	check(
		station.burnSecondsTotal == 0 and station.burnSecondsLeft == 0,
		"burnSecondsTotal: 0 again once the fire has gone out"
	)
	local twigs = stoveWith("fish 1", "twig 1", "-")
	Station.advance(twigs, 2)
	check(twigs.burnSecondsTotal == 0, "burnSecondsTotal: 0 when the fire went out for want of fuel")
end

do -- many random puts, takes and steps: fuel only burns, and each thing made uses up one thing put in
	local seed = 31337
	local function random(limit: number): number
		seed = (seed * 16807) % 2147483647
		return math.floor(seed / 65536) % limit + 1
	end
	local itemIds = { "fish", "cooked_fish", "apple", "baked_apple", "stone", "log", "twig" }
	local function count(station: Station.Station, itemId: string): number
		return Inventory.countItems(station.inventory, itemId)
	end
	local kept, sane, fuelOnlyBurns = true, true, true
	for _ = 1, 40 do
		local station = Station.new("stove", Inventory.new(3))
		for _ = 1, 150 do
			local action = random(10)
			if action <= 3 then
				local itemId = itemIds[random(#itemIds)]
				local stack = ItemStack.new(itemId, random(ItemRegistry.get(itemId).stackSize))
				Inventory.setStack(station.inventory, random(3), if random(5) == 1 then nil else stack)
			elseif action == 4 then
				Inventory.takeFromSlot(station.inventory, random(3), random(8))
			else
				local fish = count(station, "fish") + count(station, "cooked_fish")
				local apples = count(station, "apple") + count(station, "baked_apple")
				local fuel = count(station, "log") + count(station, "twig")
				local stone = count(station, "stone")
				local raw = count(station, "fish") + count(station, "apple")
				Station.advance(station, random(400) / 10)
				if
					count(station, "fish") + count(station, "cooked_fish") ~= fish
					or count(station, "apple") + count(station, "baked_apple") ~= apples
					or count(station, "stone") ~= stone
				then
					kept = false
				end
				if
					count(station, "log") + count(station, "twig") > fuel
					or count(station, "fish") + count(station, "apple") > raw
				then
					fuelOnlyBurns = false
				end
			end
			if
				station.burnSecondsLeft < 0
				or station.workedSeconds < 0
				or station.workedSeconds >= 8
				or station.burnSecondsLeft > 16
			then
				sane = false
			end
			for slot = 1, 3 do
				local stack = Inventory.getStack(station.inventory, slot)
				if stack ~= nil and ItemStack.validate(stack) ~= nil then
					sane = false
				end
			end
		end
	end
	check(kept, "random use: each thing made uses up one thing put in, and nothing else changes")
	check(fuelOnlyBurns, "random use: fuel and raw things are never made")
	check(sane, "random use: the fire and the work done stay within their bounds, and every stack is a real one")
end

Check.finish("Station")
