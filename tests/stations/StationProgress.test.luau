--!strict
-- Tests for StationProgress. Run from the repository root: lune run tests/stations/StationProgress.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local RecipeRegistry = require("../../src/shared/stations/RecipeRegistry")
local Station = require("../../src/shared/stations/Station")
local StationProgress = require("../../src/shared/stations/StationProgress")

local check = Check.that

ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "cooked_fish", stackSize = 8 })
ItemRegistry.register({ id = "apple", stackSize = 16 })
ItemRegistry.register({ id = "baked_apple", stackSize = 16 })
ItemRegistry.register({ id = "log", stackSize = 16, burnSeconds = 16 })
ItemRegistry.register({ id = "stove", stackSize = 1, placeable = true, slotCount = 3 })
RecipeRegistry.register({ station = "stove", input = "fish", output = "cooked_fish", seconds = 8 })
RecipeRegistry.register({ station = "stove", input = "apple", output = "baked_apple", seconds = 6 })

-- Returns a stove with `fish` fish to cook and `logs` logs to burn. A log burns for 16 seconds and
-- a fish takes 8, so one log cooks exactly two fish.
local function stoveWith(fish: number, logs: number): Station.Station
	local inventory = Inventory.new(3)
	Inventory.setStack(inventory, Station.INPUT_SLOT, ItemStack.new("fish", fish))
	Inventory.setStack(inventory, Station.FUEL_SLOT, ItemStack.new("log", logs))
	return Station.new("stove", inventory)
end

local function near(a: number, b: number): boolean
	return math.abs(a - b) < 1e-6
end

local function same(a: StationProgress.StationProgress, b: StationProgress.StationProgress): boolean
	return a.fuelBurnsOutAt == b.fuelBurnsOutAt
		and a.fuelBurnSeconds == b.fuelBurnSeconds
		and a.workDoneAt == b.workDoneAt
		and a.workSeconds == b.workSeconds
end

do -- new, for a stove that has not been lit
	local progress = StationProgress.new(stoveWith(2, 4), 100)
	check(
		progress.fuelBurnsOutAt == nil and progress.fuelBurnSeconds == 0,
		"new: with the fire out there is no time at which the fuel burns out"
	)
	check(
		progress.workDoneAt == nil and progress.workSeconds == 0,
		"new: with nothing worked on there is no time at which the work is done"
	)
	check(table.isfrozen(progress), "new: a progress never changes")
	check(StationProgress.getFuelLeftRatio(progress, 100) == 0, "getFuelLeftRatio: 0 if the fire was out")
	check(StationProgress.getFuelLeftRatio(progress, 500) == 0, "getFuelLeftRatio: and 0 at any later time")
	check(StationProgress.getWorkDoneRatio(progress, 100) == 0, "getWorkDoneRatio: 0 if nothing was being worked on")
	check(StationProgress.getWorkDoneRatio(progress, 500) == 0, "getWorkDoneRatio: and 0 at any later time")
end

do -- new, for a stove that is burning and working
	local station = stoveWith(2, 4)
	Station.advance(station, 4)
	local progress = StationProgress.new(station, 104)
	check(
		progress.fuelBurnsOutAt == 116 and progress.fuelBurnSeconds == 16,
		"new: a log lit 4 seconds ago burns out 12 seconds from now, and burns for 16 in all"
	)
	check(
		progress.workDoneAt == 108 and progress.workSeconds == 8,
		"new: a fish worked on for 4 seconds is done 4 seconds from now, and takes 8 in all"
	)
	check(
		near(StationProgress.getFuelLeftRatio(progress, 104), 0.75),
		"getFuelLeftRatio: three quarters of the log is left"
	)
	check(near(StationProgress.getWorkDoneRatio(progress, 104), 0.5), "getWorkDoneRatio: the fish is half done")
end

do -- a progress read at a later time agrees with the station at that time
	local station = stoveWith(2, 4)
	Station.advance(station, 4)
	local early = StationProgress.new(station, 104)
	Station.advance(station, 2)
	local late = StationProgress.new(station, 106)
	check(
		near(StationProgress.getFuelLeftRatio(early, 106), StationProgress.getFuelLeftRatio(late, 106)),
		"getFuelLeftRatio: a progress made 2 seconds ago gives the fuel left now"
	)
	check(near(StationProgress.getFuelLeftRatio(early, 106), 10 / 16), "getFuelLeftRatio: which is ten sixteenths")
	check(
		near(StationProgress.getWorkDoneRatio(early, 106), StationProgress.getWorkDoneRatio(late, 106)),
		"getWorkDoneRatio: a progress made 2 seconds ago gives the work done now"
	)
	check(near(StationProgress.getWorkDoneRatio(early, 106), 0.75), "getWorkDoneRatio: which is three quarters")
end

do -- a progress made later equals an earlier one while the station only burns and works
	local station = stoveWith(2, 4)
	Station.advance(station, 0.1)
	local now = 100.1
	local first = StationProgress.new(station, now)
	local stayedTheSame = true
	for _ = 1, 78 do
		Station.advance(station, 0.1)
		now += 0.1
		stayedTheSame = stayedTheSame and same(first, StationProgress.new(station, now))
	end
	check(stayedTheSame, "new: 78 progresses made a tenth of a second apart, while the first fish cooks, are all equal")
	check(
		first.fuelBurnsOutAt == 116 and first.workDoneAt == 108,
		"new: and each says when the log burns out and when the fish is done"
	)

	Station.advance(station, 0.2)
	now += 0.2
	local afterTheFish = StationProgress.new(station, now)
	check(not same(first, afterTheFish), "new: a progress made after the fish is done is a different one")
	check(afterTheFish.workDoneAt == 116, "new: it says when the second fish will be done")
	check(afterTheFish.fuelBurnsOutAt == 116, "new: and the log still burns out when it did")
end

do -- the times are rounded to the millisecond
	local station = stoveWith(2, 4)
	Station.advance(station, 0.1)
	local progress = StationProgress.new(station, 100.10004)
	check(progress.fuelBurnsOutAt == 116, "new: the time the fuel burns out is rounded to the millisecond")
	check(progress.workDoneAt == 108, "new: and so is the time the work is done")
	local later = StationProgress.new(station, 100.1006)
	check(later.fuelBurnsOutAt == 116.001, "new: a time more than half a millisecond on rounds up")
end

do -- the ratios stay between 0 and 1
	local station = stoveWith(2, 4)
	Station.advance(station, 4)
	local progress = StationProgress.new(station, 104)
	check(StationProgress.getFuelLeftRatio(progress, 116) == 0, "getFuelLeftRatio: 0 at the time the fuel burns out")
	check(StationProgress.getFuelLeftRatio(progress, 300) == 0, "getFuelLeftRatio: 0 after it, not less")
	check(StationProgress.getFuelLeftRatio(progress, 100) == 1, "getFuelLeftRatio: 1 at the time it was lit")
	check(StationProgress.getFuelLeftRatio(progress, 50) == 1, "getFuelLeftRatio: 1 before it, not more")
	check(StationProgress.getWorkDoneRatio(progress, 108) == 1, "getWorkDoneRatio: 1 at the time the work is done")
	check(StationProgress.getWorkDoneRatio(progress, 300) == 1, "getWorkDoneRatio: 1 after it, not more")
	check(StationProgress.getWorkDoneRatio(progress, 100) == 0, "getWorkDoneRatio: 0 at the time the work began")
	check(StationProgress.getWorkDoneRatio(progress, 50) == 0, "getWorkDoneRatio: 0 before it, not less")
end

do -- what is in the input slot was put there in the place of something else
	local station = stoveWith(2, 4)
	Station.advance(station, 4)
	Inventory.setStack(station.inventory, Station.INPUT_SLOT, ItemStack.new("apple", 2))
	local swapped = StationProgress.new(station, 104)
	check(
		swapped.workDoneAt == nil and StationProgress.getWorkDoneRatio(swapped, 104) == 0,
		"new: nothing is being worked on when the item in the input slot has just replaced another"
	)
	check(swapped.fuelBurnsOutAt == 116, "new: though the fire burns on")
	Station.advance(station, 3)
	local working = StationProgress.new(station, 107)
	check(
		working.workDoneAt == 110 and working.workSeconds == 6,
		"new: an apple worked on for 3 seconds is done 3 seconds from now, and takes 6 in all"
	)
	check(near(StationProgress.getWorkDoneRatio(working, 107), 0.5), "getWorkDoneRatio: the apple is half done")
end

do -- a fire that is nearly out, and a fire with nothing to work on
	local nearlyOut = stoveWith(2, 1)
	Station.advance(nearlyOut, 15.5)
	local progress = StationProgress.new(nearlyOut, 115.5)
	check(
		near(StationProgress.getFuelLeftRatio(progress, 115.5), 0.5 / 16),
		"getFuelLeftRatio: above 0 for a fire with half a second left"
	)

	local burningDown = stoveWith(1, 1)
	Station.advance(burningDown, 10)
	local down = StationProgress.new(burningDown, 110)
	check(
		down.fuelBurnsOutAt == 116 and near(StationProgress.getFuelLeftRatio(down, 110), 6 / 16),
		"new: a fire burns on with nothing to work on"
	)
	check(down.workDoneAt == nil and down.workSeconds == 0, "new: and then nothing is being worked on")

	local out = stoveWith(2, 1)
	Station.advance(out, 16)
	Station.advance(out, 1)
	local cold = StationProgress.new(out, 117)
	check(
		cold.fuelBurnsOutAt == nil and cold.workDoneAt == nil,
		"new: a fire that has burnt out, with no fuel left, is out"
	)
end

Check.finish("StationProgress")
