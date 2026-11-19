--!strict
-- Tests for Station. Run from the repository root: lune run tests/stations/Station.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventorySession = require("../../src/shared/inventory/InventorySession")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")
local Station = require("../../src/shared/stations/Station")

local check = Check.that
local raises = Check.raises

ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "cooked_fish", stackSize = 8 })
ItemRegistry.register({ id = "apple", stackSize = 16 })
ItemRegistry.register({ id = "baked_apple", stackSize = 16 })
ItemRegistry.register({ id = "stone", stackSize = 16 })
ItemRegistry.register({ id = "log", stackSize = 16, burnSeconds = 16 })
ItemRegistry.register({ id = "twig", stackSize = 16, burnSeconds = 2 })
ItemRegistry.register({ id = "stove", stackSize = 1, placeable = true, slotCount = 3 })
ItemRegistry.register({ id = "crate", stackSize = 1, placeable = true, slotCount = 27 })
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
end

do -- a new station
	local inventory = Inventory.new(3)
	local station = Station.new("stove", inventory)
	check(
		station.itemId == "stove" and station.inventory == inventory,
		"new: is of the kind it was given, over the inventory it was given"
	)
	check(station.burnLeft == 0 and station.burnTotal == 0, "new: no fire has been lit")
	check(station.worked == 0 and station.workingOn == nil, "new: nothing is being worked on")
	check(not Station.isBurning(station), "isBurning: false for a new station")
	check(
		raises('Station.new: "crate" is not a station; no recipe is registered for it', function()
			return Station.new("crate", Inventory.new(3))
		end),
		"new: refuses an item that has no recipes"
	)
	check(
		raises("Station.new: a station's inventory has 3 slots; got one with 27", function()
			return Station.new("stove", Inventory.new(27))
		end),
		"new: refuses an inventory of the wrong size"
	)
end

do -- what a station can work on
	check(Station.recipe(stoveWith("-", "log 4", "-")) == nil, "recipe: nil when the input slot holds nothing")
	local recipe = Station.recipe(stoveWith("fish 2", "-", "-"))
	check(
		recipe ~= nil and recipe.output == "cooked_fish",
		"recipe: the recipe for what is in the input slot, fire or no fire"
	)
	check((Station.recipe(stoveWith("apple 1", "-", "-")) :: any).seconds == 6, "recipe: each input has its own")
	check(
		Station.recipe(stoveWith("stone 2", "log 4", "-")) == nil,
		"recipe: nil for an item the station does nothing with"
	)
	check(
		Station.recipe(stoveWith("fish 2", "log 4", "baked_apple 1")) == nil,
		"recipe: nil when the output slot holds something else"
	)
	check(
		Station.recipe(stoveWith("fish 2", "log 4", "cooked_fish 8")) == nil,
		"recipe: nil when the output slot is full"
	)
	check(
		Station.recipe(stoveWith("fish 2", "log 4", "cooked_fish 7")) ~= nil,
		"recipe: there when the output slot has room for one more"
	)
end

do -- cooking one fish
	local station = stoveWith("fish 1", "log 4", "-")
	Station.step(station, 0.5)
	check(contents(station) == "fish 1, log 3, -", "step: lighting the fire uses up one item of fuel")
	check(
		Station.isBurning(station) and station.burnLeft == 15.5 and station.burnTotal == 16,
		"step: the fire burns for as long as that item burns"
	)
	check(
		station.worked == 0.5 and station.workingOn == "fish",
		"step: the fish has been worked on for the time that passed"
	)
	Station.step(station, 7.5)
	check(
		contents(station) == "-, log 3, cooked_fish 1",
		"step: after its recipe's time the fish is a cooked fish in the output slot"
	)
	check(station.worked == 0 and station.burnLeft == 8, "step: nothing is being worked on, and the fire burns on")
	Station.step(station, 7.9)
	check(
		Station.isBurning(station) and near(station.burnLeft, 0.1),
		"step: the fire burns down with nothing to work on"
	)
	Station.step(station, 100)
	check(not Station.isBurning(station) and station.burnLeft == 0, "step: and goes out")
	check(contents(station) == "-, log 3, cooked_fish 1", "step: no fuel is used when there is nothing to work on")
	check(station.workingOn == nil, "step: and nothing is being worked on")
end

do -- a fire is never lit for nothing
	local fuelOnly = stoveWith("-", "log 4", "-")
	Station.step(fuelOnly, 30)
	check(contents(fuelOnly) == "-, log 4, -" and not Station.isBurning(fuelOnly), "step: fuel alone lights no fire")
	local noFuel = stoveWith("fish 3", "-", "-")
	Station.step(noFuel, 30)
	check(contents(noFuel) == "fish 3, -, -" and noFuel.worked == 0, "step: with no fuel nothing is worked on")
	local noRecipe = stoveWith("stone 3", "log 4", "-")
	Station.step(noRecipe, 30)
	check(contents(noRecipe) == "stone 3, log 4, -", "step: an item the station does nothing with lights no fire")
	local notFuel = stoveWith("fish 3", "stone 4", "-")
	Station.step(notFuel, 30)
	check(contents(notFuel) == "fish 3, stone 4, -", "step: an item that does not burn lights no fire")
	local blocked = stoveWith("fish 3", "log 4", "stone 1")
	Station.step(blocked, 30)
	check(
		contents(blocked) == "fish 3, log 4, stone 1",
		"step: nor is one lit when the output slot holds something else"
	)
	local full = stoveWith("fish 3", "log 4", "cooked_fish 8")
	Station.step(full, 30)
	check(contents(full) == "fish 3, log 4, cooked_fish 8", "step: or is full")
end

do -- many items, and one long step against many short ones
	local long = stoveWith("fish 5", "log 4", "-")
	Station.step(long, 40)
	check(contents(long) == "-, log 1, cooked_fish 5", "step: five fish take forty seconds and three logs")
	check(near(long.burnLeft, 8) and long.worked == 0, "step: the third log has eight seconds left to burn")

	local short = stoveWith("fish 5", "log 4", "-")
	for _ = 1, 400 do
		Station.step(short, 0.1)
	end
	check(contents(short) == contents(long), "step: four hundred steps of a tenth of a second end the same way")
	check(
		near(short.burnLeft, long.burnLeft) and near(short.worked, long.worked),
		"step: with the same fire and the same work done"
	)

	local whole = stoveWith("fish 1", "log 1", "-")
	Station.step(whole, 16)
	local pieces = stoveWith("fish 1", "log 1", "-")
	for _ = 1, 160 do
		Station.step(pieces, 0.1)
	end
	local thirds = stoveWith("fish 1", "log 1", "-")
	for _ = 1, 48 do
		Station.step(thirds, 1 / 3)
	end
	check(not Station.isBurning(whole) and whole.burnLeft == 0, "step: a log is burnt out after its sixteen seconds")
	check(
		not Station.isBurning(pieces)
			and pieces.burnLeft == 0
			and not Station.isBurning(thirds)
			and thirds.burnLeft == 0,
		"step: and just as burnt out when the sixteen seconds came in small pieces"
	)

	local uneven = stoveWith("fish 5", "log 4", "-")
	for _, seconds in { 3, 0, 9.5, 0.25, 11, 16.25 } do
		Station.step(uneven, seconds)
	end
	check(
		contents(uneven) == contents(long) and near(uneven.burnLeft, 8),
		"step: and so do uneven steps of the same total"
	)

	local partway = stoveWith("fish 5", "log 4", "-")
	Station.step(partway, 20)
	check(
		contents(partway) == "fish 3, log 2, cooked_fish 2",
		"step: after twenty seconds two fish are done and a second log is lit"
	)
	check(near(partway.worked, 4) and near(partway.burnLeft, 12), "step: the third fish is half done")
end

do -- the fire going out, and coming back
	local station = stoveWith("fish 1", "twig 1", "-")
	Station.step(station, 2)
	check(contents(station) == "fish 1, -, -" and near(station.worked, 2), "step: a twig burns for two seconds of work")
	check(not Station.isBurning(station), "step: and then the fire is out")
	Station.step(station, 1)
	check(
		station.worked == 0 and station.workingOn == nil,
		"step: with no fuel to light it again, the work done is lost"
	)
	check(contents(station) == "fish 1, -, -", "step: but the fish is still there")
	Inventory.setStack(station.inventory, FUEL, ItemStack.new("twig", 5))
	Station.step(station, 8)
	check(contents(station) == "-, twig 1, cooked_fish 1", "step: four twigs, one after another, cook the fish")

	local relit = stoveWith("fish 2", "twig 16", "-")
	Station.step(relit, 5)
	check(
		near(relit.worked, 5) and contents(relit) == "fish 2, twig 13, -",
		"step: a fire that goes out mid-work is lit again at once if there is fuel, and the work goes on"
	)
end

do -- changing what is in the input slot
	local station = stoveWith("fish 1", "log 4", "-")
	Station.step(station, 5)
	Inventory.setStack(station.inventory, INPUT, ItemStack.new("apple", 1))
	Station.step(station, 1)
	check(
		station.workingOn == "apple" and near(station.worked, 1),
		"step: a different item in the input slot starts from nothing"
	)
	Station.step(station, 4.9)
	check(contents(station) == "apple 1, log 3, -", "step: so the apple is not done early")
	Station.step(station, 0.1)
	check(contents(station) == "-, log 3, baked_apple 1", "step: it is done after its own recipe's time")

	local taken = stoveWith("fish 1", "log 4", "-")
	Station.step(taken, 5)
	Inventory.setStack(taken.inventory, INPUT, nil)
	Station.step(taken, 1)
	check(taken.worked == 0 and taken.workingOn == nil, "step: taking the item away loses the work done on it")
	Inventory.setStack(taken.inventory, INPUT, ItemStack.new("fish", 1))
	Station.step(taken, 7.9)
	check(contents(taken) == "fish 1, log 3, -", "step: and one put back is worked on from the start")
end

do -- the output slot filling up
	local station = stoveWith("fish 8", "log 8", "cooked_fish 7")
	Station.step(station, 8)
	check(contents(station) == "fish 7, log 7, cooked_fish 8", "step: the last one that fits is made")
	Station.step(station, 200)
	check(contents(station) == "fish 7, log 7, cooked_fish 8", "step: and then work stops, and no more fuel is used")
	check(not Station.isBurning(station), "step: once the log that was burning has burnt out")
	Inventory.takeFromSlot(station.inventory, OUTPUT, 3)
	Station.step(station, 8)
	check(
		contents(station) == "fish 6, log 6, cooked_fish 6",
		"step: making room in the output slot starts the work again"
	)
end

do -- the gauges
	local station = stoveWith("fish 2", "log 4", "-")
	local view = Station.encodeView(station)
	check(view.burning == 0 and view.working == 0, "encodeView: nothing burning and nothing done at first")
	Station.step(station, 4)
	view = Station.encodeView(station)
	check(
		near(view.burning, 0.75) and near(view.working, 0.5),
		"encodeView: three quarters of the log left, and the fish half done"
	)
	Station.step(station, 12)
	view = Station.encodeView(station)
	check(
		view.burning == 0 and view.working == 0,
		"encodeView: both at nothing when the log has burnt out and the second fish is done"
	)
	check(contents(station) == "-, log 3, cooked_fish 2", "the log lasted exactly two fish")
	local count = 0
	for key, value in view :: any do
		count += 1
		check(type(key) == "string" and type(value) == "number", "encodeView: the view is plain data")
	end
	check(count == 2, "encodeView: two numbers and nothing else")
	local swapped = stoveWith("fish 2", "log 4", "-")
	Station.step(swapped, 4)
	Inventory.setStack(swapped.inventory, INPUT, ItemStack.new("apple", 2))
	check(
		Station.encodeView(swapped).working == 0,
		"encodeView: nothing done on an item that has just been put in the place of another"
	)
	Station.step(swapped, 3)
	check(
		near(Station.encodeView(swapped).working, 0.5),
		"encodeView: and after a step, what has been done on that item"
	)
	local nearlyOut = stoveWith("fish 2", "log 1", "-")
	Station.step(nearlyOut, 15.5)
	check(
		near(Station.encodeView(nearlyOut).burning, 0.5 / 16),
		"encodeView: a fire with half a second left still shows as burning"
	)
	local burningDown = stoveWith("fish 1", "log 1", "-")
	Station.step(burningDown, 10)
	view = Station.encodeView(burningDown)
	check(near(view.burning, 6 / 16) and view.working == 0, "encodeView: a fire can burn with nothing being worked on")
end

do -- which items each slot takes
	local rules = Station.slotRules("stove")
	local inputs, fuels, outputs = rules[INPUT], rules[FUEL], rules[OUTPUT]
	check(
		inputs.fish == true and inputs.apple == true,
		"slotRules: the input slot takes what the station has recipes for"
	)
	check(inputs.log == nil and inputs.stone == nil and inputs.cooked_fish == nil, "slotRules: and nothing else")
	check(fuels.log == true and fuels.twig == true and fuels.fish == nil, "slotRules: the fuel slot takes what burns")
	check(outputs ~= nil and next(outputs :: any) == nil, "slotRules: the output slot takes nothing")
	check(
		raises('Station.slotRules: "crate" is not a station; no recipe is registered for it', function()
			return Station.slotRules("crate")
		end),
		"slotRules: refuses an item that is not a station"
	)

	local pack = Inventory.new(4)
	Inventory.setStack(pack, 1, ItemStack.new("log", 6))
	Inventory.setStack(pack, 2, ItemStack.new("fish", 2))
	Inventory.setStack(pack, 3, ItemStack.new("stone", 1))
	local station = stoveWith("-", "-", "cooked_fish 1")
	local session = InventorySession.open(pack, station.inventory, 2, rules)
	InventorySession.quickMove(session, "pack", 1)
	InventorySession.quickMove(session, "pack", 2)
	InventorySession.quickMove(session, "pack", 3)
	check(
		contents(station) == "fish 2, log 6, cooked_fish 1",
		"with these rules, Shift and a click sends each thing to its own slot"
	)
	check(Inventory.countItems(pack, "stone") == 1, "and what the station has no use for stays in the pack")
	check(InventorySession.pickUp(session, "other", OUTPUT) == 1, "what was made can be taken out")
	check(InventorySession.putDown(session, "other", OUTPUT) == 0, "and nothing can be put where it came from")
end

do -- mistakes in the calling code
	local station = stoveWith("fish 1", "log 1", "-")
	for _, bad in { -1, 0 / 0, math.huge, "8" } :: { any } do
		check(
			raises("Station.step: seconds must be a finite number, 0 or more; got " .. tostring(bad), function()
				Station.step(station, bad)
			end),
			"step: refuses " .. tostring(bad) .. " seconds"
		)
	end
	Station.step(station, 0)
	check(
		contents(station) == "fish 1, log 1, -" and not Station.isBurning(station),
		"step: a refused step, or one of no time, changes nothing"
	)
end

do -- many random puts, takes and steps: fuel only burns, and each thing made uses up one thing put in
	local seed = 31337
	local function random(limit: number): number
		seed = (seed * 1103515245 + 12345) % 2147483648
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
				Station.step(station, random(400) / 10)
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
			if station.burnLeft < 0 or station.worked < 0 or station.worked >= 8 or station.burnLeft > 16 then
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
