--!strict
--- How far a station's fire and work have got, as times on the world's clock.
---
--- A station's gauges move all the time, but the time at which its fuel will burn out and the time
--- at which its work will be done stay the same until something happens to the station. So a
--- progress made at one moment still describes the station later, and `getFuelLeftRatio` and
--- `getWorkDoneRatio` read the gauges off it at any time. A progress never changes.
local Station = require("./Station")

local StationProgress = {}

export type StationProgress = {
	--- The time at which the fuel now burning will burn out, in seconds. `nil` when the fire is out.
	read fuelBurnsOutAt: number?,
	--- How long the item of fuel now burning burns in all, in seconds. 0 when the fire is out.
	read fuelBurnSeconds: number,
	--- The time at which the item being worked on will be done if the fire burns until then, in
	--- seconds. `nil` when nothing is being worked on.
	read workDoneAt: number?,
	--- How long the work on that item takes in all, in seconds. 0 when nothing is being worked on.
	read workSeconds: number,
}

local function roundToMillisecond(time: number): number
	return math.floor(time * 1000 + 0.5) / 1000
end

--- Returns the progress of `station` at the time `now`, in seconds. Its two times are rounded to
--- the millisecond, so that a progress made later equals this one, field for field, as long as the
--- station has only burnt and worked in between.
function StationProgress.new(station: Station.Station, now: number): StationProgress
	local recipe = Station.getWorkableRecipe(station)
	local isBurning = Station.isBurning(station)
	local isWorking = recipe ~= nil and recipe.input == station.workingOnItemId
	return table.freeze({
		fuelBurnsOutAt = if isBurning then roundToMillisecond(now + station.burnSecondsLeft) else nil,
		fuelBurnSeconds = if isBurning then station.burnSecondsTotal else 0,
		workDoneAt = if recipe ~= nil and isWorking
			then roundToMillisecond(now + recipe.seconds - station.workedSeconds)
			else nil,
		workSeconds = if recipe ~= nil and isWorking then recipe.seconds else 0,
	})
end

--- Returns how much of the fuel is left at the time `now`, as a number from 1, when it was just
--- lit, down to 0, when it has burnt out. Returns 0 if the fire was out.
function StationProgress.getFuelLeftRatio(progress: StationProgress, now: number): number
	local burnsOutAt = progress.fuelBurnsOutAt
	if burnsOutAt == nil then
		return 0
	end
	return math.clamp((burnsOutAt - now) / progress.fuelBurnSeconds, 0, 1)
end

--- Returns how far the work has got at the time `now`, as a number from 0, when it has not begun,
--- up to 1, when it is done. Returns 0 if nothing was being worked on.
function StationProgress.getWorkDoneRatio(progress: StationProgress, now: number): number
	local doneAt = progress.workDoneAt
	if doneAt == nil then
		return 0
	end
	return math.clamp(1 - (doneAt - now) / progress.workSeconds, 0, 1)
end

return StationProgress
