--!strict
-- Tests for ItemScripts. Run from the repository root: lune run tests/requests/ItemScripts.test.luau
-- The items here are made up for the tests: none is an item the game has.

local Check = require("../Check")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemScripts = require("../../src/shared/requests/ItemScripts")
local World = require("../../src/shared/world/World")

local check = Check.that

type ItemScript = ItemScripts.ItemScript

ItemRegistry.register({ id = "wand", stackSize = 1 })
ItemRegistry.register({ id = "stick", stackSize = 16 })
ItemRegistry.register({ id = "big_wand", stackSize = 1 })
ItemRegistry.register({ id = "feather", stackSize = 16 })

local function useNoneUp(_world: World.World, _tileX: number, _tileZ: number): number
	return 0
end

local wand: ItemScript = { interactWithTile = useNoneUp }
local stick: ItemScript = {}

do -- an empty registry
	check(ItemScripts.find("wand") == nil, "find: nil before any script is registered")
end

do -- register, then find
	ItemScripts.register("wand", wand)
	check(ItemScripts.find("wand") == wand, "find: the script that was registered for the item, itself")
	check(not table.isfrozen(wand), "register: the script is kept as it is, and is not frozen")
	ItemScripts.register("stick", stick)
	local foundStick = ItemScripts.find("stick")
	check(
		foundStick == stick and foundStick ~= nil and foundStick.interactWithTile == nil,
		"register: a script may have no function at all"
	)
	check(ItemScripts.find("wand") == wand, "find: each item has a script of its own")
	check(ItemScripts.find("feather") == nil, "find: nil for an item that has no script")
	check(ItemScripts.find("anvil") == nil, "find: nil for an id that no item has")
end

do -- the same script for two items
	ItemScripts.register("big_wand", wand)
	check(
		ItemScripts.find("big_wand") == wand and ItemScripts.find("wand") == wand,
		"register: one script may be registered for two items"
	)
end

do -- what register refuses
	check(
		Check.raises('no item has the id "anvil"', function()
			ItemScripts.register("anvil", wand)
		end),
		"register: fails for an id that no item has"
	)
	check(ItemScripts.find("anvil") == nil, "register: and registers nothing for it")
	check(
		Check.raises('the item "wand" has a script already', function()
			ItemScripts.register("wand", stick)
		end),
		"register: fails for an item that has a script already"
	)
	check(ItemScripts.find("wand") == wand, "register: and the script that was there stays")
	check(
		Check.raises('the item "stick" has a script already', function()
			ItemScripts.register("stick", stick)
		end),
		"register: fails for an item that has a script already, even the same script"
	)
end

Check.finish("ItemScripts")
