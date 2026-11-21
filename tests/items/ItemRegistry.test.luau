--!strict
-- Tests for ItemRegistry. Run from the repository root: lune run tests/items/ItemRegistry.test.luau

local Check = require("../Check")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")

local check = Check.that
local raises = Check.raises

do -- an empty registry
	check(#ItemRegistry.getAll() == 0, "getAll: a registry with nothing registered has no item types")
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
		raises('no item has the id "anvil"', function()
			return ItemRegistry.get("anvil")
		end),
		"get: an unknown id is an error that names the id"
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

do -- getAll
	local all = ItemRegistry.getAll()
	check(#all == 3, "getAll: one entry for each registered item type")
	check(all[1].id == "log" and all[2].id == "plank" and all[3].id == "stove", "getAll: ordered by id")
	table.remove(all)
	check(#ItemRegistry.getAll() == 3, "getAll: changing the returned list does not change the registry")
end

local function refuses(definition: any): boolean
	return Check.errorFrom(function()
		ItemRegistry.register(definition)
	end) ~= nil
end

do -- what register refuses
	check(refuses({ id = "log", stackSize = 64 }), "register: refuses an id that is taken")
	check(ItemRegistry.get("log").stackSize == 16, "register: a refused duplicate does not replace the first")
	for _, badId in { "", "Log", "big log", "2x4", "_log", "log!" } do
		check(refuses({ id = badId, stackSize = 16 }), string.format("register: refuses the id %q", badId))
		check(ItemRegistry.has(badId) == false, string.format("register: the refused id %q was not registered", badId))
	end
	check(refuses({ id = 5, stackSize = 16 }), "register: refuses an id that is not a string")
	for _, badSize in { 0, -1, 1.5, 0 / 0, math.huge, "16" } do
		check(refuses({ id = "odd", stackSize = badSize }), "register: refuses a stack size of " .. tostring(badSize))
	end
	check(refuses({ id = "odd" }), "register: refuses an item type with no stack size")
	check(ItemRegistry.has("odd") == false, "register: nothing refused was registered")
	check(#ItemRegistry.getAll() == 3, "register: the registry still has only the three good item types")
end

do -- a table with more fields than an item definition has
	local whole = { id = "lantern", stackSize = 4, name = "Lantern", glows = true }
	ItemRegistry.register(whole)
	local kept = ItemRegistry.get("lantern") :: any
	check(kept.id == "lantern" and kept.stackSize == 4, "register: a table with more fields is registered")
	check(
		kept ~= whole and kept.name == nil and kept.glows == nil,
		"register: and the registry keeps only its id and its stack size"
	)
	check(not table.isfrozen(whole), "register: the table it was given is left as it was")
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
