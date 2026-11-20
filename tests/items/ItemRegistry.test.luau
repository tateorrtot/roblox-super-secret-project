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

do -- all
	local all = ItemRegistry.all()
	check(#all == 3, "all: one entry for each registered item type")
	check(all[1].id == "log" and all[2].id == "plank" and all[3].id == "stove", "all: ordered by id")
	table.remove(all)
	check(#ItemRegistry.all() == 3, "all: changing the returned list does not change the registry")
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
	check(
		refuses({ id = "odd", stackSize = 16, stacksize = 4 }),
		"register: refuses a field item definitions do not have"
	)
	check(ItemRegistry.has("odd") == false, "register: nothing refused was registered")
	check(#ItemRegistry.all() == 3, "register: the registry still has only the three good item types")
end

do -- items that can be placed, and that hold things
	ItemRegistry.register({ id = "placed_plain", stackSize = 1, placeable = true })
	ItemRegistry.register({ id = "placed_holder", stackSize = 1, placeable = true, slotCount = 27 })
	ItemRegistry.register({ id = "not_placed", stackSize = 8 })
	check(ItemRegistry.get("placed_plain").placeable == true, "register: keeps placeable")
	check(ItemRegistry.get("placed_plain").slotCount == nil, "register: a placeable item need not hold things")
	check(ItemRegistry.get("placed_holder").slotCount == 27, "register: keeps slotCount")
	ItemRegistry.register({ id = "placed_one_slot", stackSize = 1, placeable = true, slotCount = 1 })
	check(ItemRegistry.get("placed_one_slot").slotCount == 1, "register: 1 is the fewest slots")
	check(
		ItemRegistry.get("not_placed").placeable == nil and ItemRegistry.get("not_placed").slotCount == nil,
		"register: an item that cannot be placed has neither field"
	)
	for _, bad in { false, "yes", 1, {} } :: { any } do
		check(
			refuses({ id = "bad_placeable", stackSize = 1, placeable = bad }),
			"register: refuses placeable = " .. tostring(bad)
		)
	end
	for _, bad in { 0, -3, 1.5, 0 / 0, math.huge, "9", true } :: { any } do
		check(
			refuses({ id = "bad_slots", stackSize = 1, placeable = true, slotCount = bad }),
			"register: refuses slotCount = " .. tostring(bad)
		)
	end
	check(
		refuses({ id = "loose_slots", stackSize = 1, slotCount = 9 }),
		"register: refuses slots on an item that cannot be placed"
	)
	check(
		not ItemRegistry.has("bad_placeable")
			and not ItemRegistry.has("bad_slots")
			and not ItemRegistry.has("loose_slots"),
		"register: a refused definition is not registered"
	)
end

do -- items that burn
	ItemRegistry.register({ id = "burns_long", stackSize = 16, burnSeconds = 16 })
	ItemRegistry.register({ id = "burns_briefly", stackSize = 16, burnSeconds = 0.5 })
	check(ItemRegistry.get("burns_long").burnSeconds == 16, "register: keeps burnSeconds")
	check(ItemRegistry.get("burns_briefly").burnSeconds == 0.5, "register: a fraction of a second is fine")
	check(ItemRegistry.get("not_placed").burnSeconds == nil, "register: an item that does not burn has no burnSeconds")
	for _, bad in { 0, -4, 0 / 0, math.huge, "16", true } :: { any } do
		check(
			refuses({ id = "bad_fuel", stackSize = 1, burnSeconds = bad }),
			"register: refuses burnSeconds = " .. tostring(bad)
		)
	end
	check(not ItemRegistry.has("bad_fuel"), "register: a refused fuel is not registered")
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
