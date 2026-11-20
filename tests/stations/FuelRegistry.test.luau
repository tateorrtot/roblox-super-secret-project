--!strict
-- Tests for FuelRegistry. Run from the repository root: lune run tests/stations/FuelRegistry.test.luau

local Check = require("../Check")
local FuelRegistry = require("../../src/shared/stations/FuelRegistry")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")

local check = Check.that

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "twig", stackSize = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })

do -- an empty registry
	check(FuelRegistry.find("log") == nil, "find: nil before any fuel is registered")
end

do -- register, then look up
	local written = { item = "log", seconds = 16 }
	FuelRegistry.register(written)
	local fuel = FuelRegistry.find("log")
	check(fuel ~= nil and fuel.item == "log" and fuel.seconds == 16, "find: the fuel that was registered")
	check(fuel ~= nil and table.isfrozen(fuel), "find: a fuel never changes")
	written.seconds = 99
	check(
		(FuelRegistry.find("log") :: any).seconds == 16,
		"register: changing the given table afterwards changes nothing"
	)
	FuelRegistry.register({ item = "twig", seconds = 0.5 })
	check((FuelRegistry.find("twig") :: any).seconds == 0.5, "register: a fraction of a second is fine")
	check((FuelRegistry.find("log") :: any).seconds == 16, "find: each item is a fuel of its own")
	check(FuelRegistry.find("fish") == nil, "find: nil for an item that does not burn")
	check(FuelRegistry.find("anvil") == nil, "find: nil for an id that no item has")
end

do -- what register refuses
	local function refuses(what: string, part: string, fuel: any)
		check(
			Check.raises(part, function()
				FuelRegistry.register(fuel)
			end),
			"register: fails for " .. what .. ', saying "' .. part .. '"'
		)
	end
	refuses("an item that does not exist", 'fuel "anvil": no item has the id "anvil"', { item = "anvil", seconds = 4 })
	for _, bad in { 0, -4, math.huge } do
		refuses(
			"seconds = " .. bad,
			'fuel "fish": seconds must be above 0 and finite, not ' .. bad,
			{ item = "fish", seconds = bad }
		)
	end
	refuses(
		"seconds that is not a number",
		'fuel "fish": seconds must be above 0 and finite, not nan',
		{ item = "fish", seconds = 0 / 0 }
	)
	refuses("an item that is a fuel already", 'fuel "log": is a fuel already', { item = "log", seconds = 4 })
	check(FuelRegistry.find("fish") == nil, "register: a refused fuel is not registered")
	check((FuelRegistry.find("log") :: any).seconds == 16, "register: and the fuel that was there is unchanged")
end

Check.finish("FuelRegistry")
