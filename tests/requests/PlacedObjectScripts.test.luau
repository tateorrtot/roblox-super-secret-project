--!strict
-- Tests for PlacedObjectScripts. Run from the repository root: lune run tests/requests/PlacedObjectScripts.test.luau
-- The kinds here are made up for the tests: none is a kind the game has.

local Check = require("../Check")
local PlacedObjectScripts = require("../../src/shared/requests/PlacedObjectScripts")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local World = require("../../src/shared/world/World")

local check = Check.that

type PlacedObjectScript = PlacedObjectScripts.PlacedObjectScript

local function doNothing(_world: World.World, _player: PlayerState.PlayerState, _placedObjectId: number) end

local function breakNothing(_world: World.World, _placedObjectId: number) end

local bell: PlacedObjectScript = { interact = doNothing, breakPlacedObject = breakNothing }
local gong: PlacedObjectScript = { interact = doNothing }
local post: PlacedObjectScript = {}

do -- an empty registry
	check(PlacedObjectScripts.find("bell") == nil, "find: nil before any script is registered")
end

do -- register, then find
	PlacedObjectScripts.register("bell", bell)
	check(PlacedObjectScripts.find("bell") == bell, "find: the script that was registered for the kind, itself")
	check(not table.isfrozen(bell), "register: the script is kept as it is, and is not frozen")
	PlacedObjectScripts.register("gong", gong)
	local foundGong = PlacedObjectScripts.find("gong")
	check(
		foundGong == gong and foundGong ~= nil and foundGong.breakPlacedObject == nil,
		"register: a script may lack a function"
	)
	PlacedObjectScripts.register("post", post)
	check(PlacedObjectScripts.find("post") == post, "register: a script may have no function at all")
	check(PlacedObjectScripts.find("bell") == bell, "find: each kind has a script of its own")
	check(PlacedObjectScripts.find("rock") == nil, "find: nil for a kind that has no script")
	check(PlacedObjectScripts.find("") == nil, "find: nil for an id that is no text at all")
end

do -- the same script for two kinds
	PlacedObjectScripts.register("big_bell", bell)
	check(
		PlacedObjectScripts.find("big_bell") == bell and PlacedObjectScripts.find("bell") == bell,
		"register: one script may be registered for two kinds"
	)
end

do -- what register refuses
	check(
		Check.raises('the kind of placed object "bell" has a script already', function()
			PlacedObjectScripts.register("bell", gong)
		end),
		"register: fails for a kind that has a script already"
	)
	check(PlacedObjectScripts.find("bell") == bell, "register: and the script that was there stays")
	check(
		Check.raises('the kind of placed object "post" has a script already', function()
			PlacedObjectScripts.register("post", post)
		end),
		"register: fails for a kind that has a script already, even the same script"
	)
end

local function newWorld(): World.World
	return World.new(Plot.new(4, 4), Position.new(0, 0, 0), 0)
end

type Call = { placedObjectId: number, seconds: number, world: World.World }

do -- a script with advance and getScreenData
	local function advanceNothing(_world: World.World, _placedObjectId: number, _seconds: number) end
	local function getNoScreenData(_world: World.World, _placedObjectId: number): unknown
		return nil
	end
	local clock: PlacedObjectScript = { advance = advanceNothing, getScreenData = getNoScreenData }
	PlacedObjectScripts.register("clock", clock)
	local foundClock = PlacedObjectScripts.find("clock")
	check(
		foundClock ~= nil and foundClock.advance == advanceNothing and foundClock.getScreenData == getNoScreenData,
		"find: a script with advance and getScreenData is found with those very functions"
	)
	check(
		foundClock ~= nil and foundClock.interact == nil and foundClock.breakPlacedObject == nil,
		"register: a script with advance and getScreenData lacks the functions it was not given"
	)
	local advanceOnly: PlacedObjectScript = { advance = advanceNothing }
	PlacedObjectScripts.register("sundial", advanceOnly)
	local foundSundial = PlacedObjectScripts.find("sundial")
	check(
		foundSundial ~= nil and foundSundial.advance == advanceNothing and foundSundial.getScreenData == nil,
		"register: a script may have advance and no getScreenData"
	)
	local screenOnly: PlacedObjectScript = { getScreenData = getNoScreenData }
	PlacedObjectScripts.register("sign", screenOnly)
	local foundSign = PlacedObjectScripts.find("sign")
	check(
		foundSign ~= nil and foundSign.getScreenData == getNoScreenData and foundSign.advance == nil,
		"register: a script may have getScreenData and no advance"
	)
end

do -- findOfPlacedObject
	local world = newWorld()
	local bellId = Plot.placeObject(world.plot, { kindId = "bell", tileX = 1, tileZ = 1 })
	local gongId = Plot.placeObject(world.plot, { kindId = "gong", tileX = 2, tileZ = 1 })
	local rockId = Plot.placeObject(world.plot, { kindId = "rock", tileX = 3, tileZ = 1 })
	check(
		PlacedObjectScripts.findOfPlacedObject(world, bellId) == bell,
		"findOfPlacedObject: the script of the kind of the placed object"
	)
	check(
		PlacedObjectScripts.findOfPlacedObject(world, gongId) == gong,
		"findOfPlacedObject: each placed object has the script of its own kind"
	)
	check(
		PlacedObjectScripts.findOfPlacedObject(world, rockId) == nil,
		"findOfPlacedObject: nil for a placed object whose kind has no script"
	)
	check(
		PlacedObjectScripts.findOfPlacedObject(world, rockId + 100) == nil,
		"findOfPlacedObject: nil for an id that no placed object has"
	)
	Plot.removePlacedObject(world.plot, bellId)
	check(
		PlacedObjectScripts.findOfPlacedObject(world, bellId) == nil,
		"findOfPlacedObject: nil for the id of a placed object that was removed"
	)
end

do -- advancePlacedObjects
	local calls: { Call } = {}
	local function record(world: World.World, placedObjectId: number, seconds: number)
		table.insert(calls, { placedObjectId = placedObjectId, seconds = seconds, world = world })
	end
	local ticker: PlacedObjectScript = { advance = record }
	PlacedObjectScripts.register("ticker", ticker)

	local emptyWorld = newWorld()
	PlacedObjectScripts.advancePlacedObjects(emptyWorld, 1)
	check(#calls == 0, "advancePlacedObjects: nothing happens with nothing on the plot")

	local world = newWorld()
	local ids = {}
	for tileX = 1, 4 do
		for tileZ = 1, 3 do
			table.insert(ids, Plot.placeObject(world.plot, { kindId = "ticker", tileX = tileX, tileZ = tileZ }))
		end
	end
	local gongId = Plot.placeObject(world.plot, { kindId = "gong", tileX = 1, tileZ = 4 })
	local rockId = Plot.placeObject(world.plot, { kindId = "rock", tileX = 2, tileZ = 4 })
	local postId = Plot.placeObject(world.plot, { kindId = "post", tileX = 3, tileZ = 4 })
	PlacedObjectScripts.advancePlacedObjects(world, 2.5)
	check(#calls == #ids, "advancePlacedObjects: each placed object whose script has advance is told, once")
	local told = true
	local inOrder = true
	for index, call in calls do
		if call.placedObjectId ~= ids[index] then
			inOrder = false
		end
		if call.seconds ~= 2.5 or call.world ~= world then
			told = false
		end
	end
	check(told, "advancePlacedObjects: each is told the world and the seconds that were given")
	check(inOrder, "advancePlacedObjects: the placed objects are told one at a time, the lowest id first")
	local toldOthers = false
	for _, call in calls do
		if call.placedObjectId == gongId or call.placedObjectId == rockId or call.placedObjectId == postId then
			toldOthers = true
		end
	end
	check(
		not toldOthers,
		"advancePlacedObjects: a placed object whose script has no advance, or whose kind has no script, is passed over"
	)
end

do -- a placed object taken off the plot during the call
	local calls: { number } = {}
	local world = newWorld()
	local firstId = 0
	local secondId = 0
	local thirdId = 0
	local function removeSecond(_world: World.World, placedObjectId: number, _seconds: number)
		table.insert(calls, placedObjectId)
		Plot.removePlacedObject(world.plot, secondId)
	end
	local function record(_world: World.World, placedObjectId: number, _seconds: number)
		table.insert(calls, placedObjectId)
	end
	PlacedObjectScripts.register("remover", { advance = removeSecond })
	PlacedObjectScripts.register("watcher", { advance = record })
	firstId = Plot.placeObject(world.plot, { kindId = "remover", tileX = 1, tileZ = 1 })
	secondId = Plot.placeObject(world.plot, { kindId = "watcher", tileX = 2, tileZ = 1 })
	thirdId = Plot.placeObject(world.plot, { kindId = "watcher", tileX = 3, tileZ = 1 })
	PlacedObjectScripts.advancePlacedObjects(world, 1)
	check(
		#calls == 2 and calls[1] == firstId and calls[2] == thirdId,
		"advancePlacedObjects: a placed object that an earlier one's advance took off the plot is not told"
	)
end

do -- a placed object placed during the call
	local calls: { number } = {}
	local world = newWorld()
	local placedId = 0
	local planted = false
	local function plant(_world: World.World, placedObjectId: number, _seconds: number)
		table.insert(calls, placedObjectId)
		if not planted then
			planted = true
			placedId = Plot.placeObject(world.plot, { kindId = "seed", tileX = 4, tileZ = 4 })
		end
	end
	PlacedObjectScripts.register("seed", { advance = plant })
	local firstId = Plot.placeObject(world.plot, { kindId = "seed", tileX = 1, tileZ = 1 })
	PlacedObjectScripts.advancePlacedObjects(world, 1)
	check(
		#calls == 1 and calls[1] == firstId and placedId ~= 0,
		"advancePlacedObjects: a placed object placed during the call is not told in that call"
	)
	PlacedObjectScripts.advancePlacedObjects(world, 1)
	check(
		#calls == 3 and calls[2] == firstId and calls[3] == placedId,
		"advancePlacedObjects: a placed object placed during a call is told in the next call"
	)
end

do -- the order of the ids when the ids are far apart
	local calls: { number } = {}
	local function record(_world: World.World, placedObjectId: number, _seconds: number)
		table.insert(calls, placedObjectId)
	end
	PlacedObjectScripts.register("spaced", { advance = record })
	local world = newWorld()
	local keptIds: { number } = {}
	for index = 1, 16 do
		local tileX = (index - 1) % 4 + 1
		local tileZ = (index - 1) // 4 + 1
		local id = Plot.placeObject(world.plot, { kindId = "spaced", tileX = tileX, tileZ = tileZ })
		if index % 3 == 0 then
			table.insert(keptIds, id)
		else
			Plot.removePlacedObject(world.plot, id)
		end
	end
	for _, tileX in { 1, 2, 4 } do
		table.insert(keptIds, Plot.placeObject(world.plot, { kindId = "spaced", tileX = tileX, tileZ = 1 }))
	end
	table.sort(keptIds)
	PlacedObjectScripts.advancePlacedObjects(world, 1)
	local sameOrder = #calls == #keptIds
	for index, id in keptIds do
		if calls[index] ~= id then
			sameOrder = false
		end
	end
	check(sameOrder, "advancePlacedObjects: the lowest id is told first when the ids are far apart")
end

Check.finish("PlacedObjectScripts")
