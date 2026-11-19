--!strict
-- Tests for ItemRegistry. Run from the repository root: lune run tests/items/ItemRegistry.test.luau

local Check = require("../Check")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")

local check = Check.that
local raises = Check.raises

do -- an empty registry
	check(#ItemRegistry.all() == 0, "all: a registry with nothing registered has no item types")
	check(ItemRegistry.has("log") == false, "has: false before anything is registered")
end

do -- register, then look up
	ItemRegistry.register({ id = "log", stackSize = 16 })
	ItemRegistry.register({ id = "stove", stackSize = 1 })
	check(ItemRegistry.has("log"), "has: true once registered")
	check(ItemRegistry.get("log").id == "log", "get: returns the item type with that id")
	check(ItemRegistry.get("log").stackSize == 16, "get: the item type has its stack size")
	check(ItemRegistry.get("stove").stackSize == 1, "get: an item that does not stack has a stack size of 1")
	check(ItemRegistry.get("log") == ItemRegistry.get("log"), "get: the same item type every time")
end

do -- unknown ids
	check(ItemRegistry.has("anvil") == false, "has: false for an id that was never registered")
	check(
		raises('ItemRegistry.get: no item has the id "anvil"', function()
			return ItemRegistry.get("anvil")
		end),
		"get: an unknown id is an error that names the function and the id"
	)
end

do -- the registry keeps its own copy, and item types never change
	local raw = { id = "plank", stackSize = 16 }
	ItemRegistry.register(raw)
	raw.stackSize = 99
	check(ItemRegistry.get("plank").stackSize == 16, "register: changing the table afterwards changes nothing")
	check(Check.errorFrom(function()
		(ItemRegistry.get("plank") :: any).stackSize = 64
	end) ~= nil, "get: an item type cannot be changed")
	check(ItemRegistry.get("plank").stackSize == 16, "get: still unchanged after the attempt")
end

do -- all
	local all = ItemRegistry.all()
	check(#all == 3, "all: one entry for each registered item type")
	check(all[1].id == "log" and all[2].id == "plank" and all[3].id == "stove", "all: ordered by id")
	table.remove(all)
	check(#ItemRegistry.all() == 3, "all: changing the returned list does not change the registry")
end

do -- what register refuses
	check(
		raises('there is already an item with the id "log"', function()
			ItemRegistry.register({ id = "log", stackSize = 64 })
		end),
		"register: refuses an id that is taken"
	)
	check(ItemRegistry.get("log").stackSize == 16, "register: a refused duplicate does not replace the first")
	for _, badId in { "", "Log", "big log", "2x4", "_log", "log!" } do
		check(
			raises("id must be lowercase", function()
				ItemRegistry.register({ id = badId, stackSize = 16 })
			end),
			string.format("register: refuses the id %q", badId)
		)
		check(ItemRegistry.has(badId) == false, string.format("register: the refused id %q was not registered", badId))
	end
	check(
		raises("starting with a letter; got number", function()
			ItemRegistry.register({ id = 5, stackSize = 16 } :: any)
		end),
		"register: refuses an id that is not a string, and says what it got"
	)
	check(
		raises('starting with a letter; got "Log"', function()
			ItemRegistry.register({ id = "Log", stackSize = 16 })
		end),
		"register: the error shows the id it refused"
	)
	for _, badSize in { 0, -1, 1.5, 0 / 0, math.huge } do
		check(
			raises('stackSize of "odd" must be a whole number, 1 or more', function()
				ItemRegistry.register({ id = "odd", stackSize = badSize })
			end),
			"register: refuses a stack size of " .. tostring(badSize)
		)
	end
	check(
		raises("stackSize", function()
			ItemRegistry.register({ id = "odd" } :: any)
		end),
		"register: refuses an item type with no stack size"
	)
	check(
		raises("a field item definitions do not have: stacksize", function()
			ItemRegistry.register({ id = "odd", stackSize = 16, stacksize = 4 } :: any)
		end),
		"register: refuses a field item types do not have, and names it"
	)
	check(
		raises("an item definition is a table", function()
			ItemRegistry.register("odd" :: any)
		end),
		"register: refuses something that is not a table"
	)
	check(ItemRegistry.has("odd") == false, "register: nothing refused was registered")
	check(#ItemRegistry.all() == 3, "register: the registry still has only the three good item types")
end

do -- ids that are fine
	ItemRegistry.register({ id = "iron_ore", stackSize = 32 })
	ItemRegistry.register({ id = "tier2_pickaxe", stackSize = 1 })
	check(
		ItemRegistry.has("iron_ore") and ItemRegistry.has("tier2_pickaxe"),
		"register: underscores and digits are fine"
	)
end

Check.finish("ItemRegistry")
