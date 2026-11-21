--!strict
-- Tests for Items: every item of the game, as one table each.
-- Run from the repository root: lune run tests/content/Items.test.luau

local Check = require("../Check")
local CrateItem = require("../../src/shared/content/CrateItem")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local Items = require("../../src/shared/content/Items")
local StoveItem = require("../../src/shared/content/StoveItem")

local check = Check.that

do -- ALL
	check(#Items.ALL > 0, "ALL: there is at least one item")
	check(table.isfrozen(Items.ALL), "ALL: the list cannot be changed")
	for index, item in Items.ALL do
		local problem = Check.errorFrom(function()
			ItemRegistry.register(item)
		end)
		check(problem == nil, "ALL: item " .. index .. " is one the registry accepts: " .. tostring(problem))
		check(type(item.name) == "string" and #item.name > 0, 'ALL: the item "' .. item.id .. '" has a name')
		check((item :: any).color == nil, 'ALL: the item "' .. item.id .. '" has no colour: how it looks is not here')
		check(table.isfrozen(item), 'ALL: the item "' .. item.id .. '" never changes: its table is frozen')
	end
	check(#ItemRegistry.getAll() == #Items.ALL, "ALL: every item has an id of its own")
	check(
		table.find(Items.ALL, CrateItem :: any) ~= nil and table.find(Items.ALL, StoveItem :: any) ~= nil,
		"ALL: an item written in a file of its own is in the list as that table"
	)
end

do -- get
	for _, item in Items.ALL do
		check(Items.get(item.id) == item, 'get: returns the item "' .. item.id .. '"')
	end
	local log = Items.get("log")
	check(
		log.stackSize == 16 and log.name == "Log" and log.interactWithTile == nil,
		"get: an item written as a row has its stack size and its name, and no function"
	)
	check(
		Items.get("crate") == CrateItem :: any and Items.get("crate").interactWithTile == CrateItem.interactWithTile,
		"get: an item written in a file of its own is that file's table, with its function"
	)
	check(
		Check.raises('the game has no item with the id "plank"', function()
			Items.get("plank")
		end),
		"get: fails for an id that no item of the game has, saying so"
	)
end

Check.finish("Items")
