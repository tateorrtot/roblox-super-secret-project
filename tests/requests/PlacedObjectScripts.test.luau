--!strict
-- Tests for PlacedObjectScripts. Run from the repository root: lune run tests/requests/PlacedObjectScripts.test.luau
-- The kinds here are made up for the tests: none is a kind the game has.

local Check = require("../Check")
local PlacedObjectScripts = require("../../src/shared/requests/PlacedObjectScripts")
local PlayerState = require("../../src/shared/players/PlayerState")
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

Check.finish("PlacedObjectScripts")
