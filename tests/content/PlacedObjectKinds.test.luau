--!strict
-- Tests for PlacedObjectKinds: every kind of placed object of the game, as one table each.
-- Run from the repository root: lune run tests/content/PlacedObjectKinds.test.luau

local Check = require("../Check")
local Crate = require("../../src/shared/content/Crate")
local PlacedObjectKinds = require("../../src/shared/content/PlacedObjectKinds")
local Stove = require("../../src/shared/content/Stove")

local check = Check.that

do -- ALL
	check(#PlacedObjectKinds.ALL > 0, "ALL: there is at least one kind")
	check(table.isfrozen(PlacedObjectKinds.ALL), "ALL: the list cannot be changed")
	local seen: { [string]: boolean } = {}
	for index, kind in PlacedObjectKinds.ALL do
		local id = kind.PLACED_OBJECT_KIND_ID
		check(type(id) == "string" and #id > 0, "ALL: kind " .. index .. " has an id")
		check(not seen[id], 'ALL: the id "' .. tostring(id) .. '" is the id of one kind only')
		seen[id] = true
		check(type(kind.NAME) == "string" and #kind.NAME > 0, 'ALL: the kind "' .. tostring(id) .. '" has a name')
	end
	check(
		table.find(PlacedObjectKinds.ALL, Crate :: any) ~= nil
			and table.find(PlacedObjectKinds.ALL, Stove :: any) ~= nil,
		"ALL: the crate and the stove are in the list, each as its own file's table"
	)
end

do -- get
	for _, kind in PlacedObjectKinds.ALL do
		check(
			PlacedObjectKinds.get(kind.PLACED_OBJECT_KIND_ID) == kind,
			'get: returns the kind "' .. kind.PLACED_OBJECT_KIND_ID .. '"'
		)
	end
	local crate = PlacedObjectKinds.get(Crate.PLACED_OBJECT_KIND_ID)
	check(
		crate.NAME == Crate.NAME and crate.interact == Crate.interact and crate.advance == nil,
		"get: a kind has its name and the functions of its script, and not the ones it has no use for"
	)
	check(
		PlacedObjectKinds.get(Stove.PLACED_OBJECT_KIND_ID).advance == Stove.advance,
		"get: the stove's kind has the stove's own advance"
	)
	check(
		Check.raises('the game has no kind of placed object with the id "bell"', function()
			PlacedObjectKinds.get("bell")
		end),
		"get: fails for an id that no kind of the game has, saying so"
	)
end

Check.finish("PlacedObjectKinds")
