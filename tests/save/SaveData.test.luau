--!strict
-- Tests for SaveData. Run from the repository root: lune run tests/save/SaveData.test.luau

local Check = require("../Check")
local Hotbar = require("../../src/shared/inventory/Hotbar")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventorySession = require("../../src/shared/inventory/InventorySession")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlayerState = require("../../src/shared/players/PlayerState")
local SaveData = require("../../src/shared/save/SaveData")

local check = Check.that
local raises = Check.raises

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "stove", stackSize = 1 })

-- True if `value` is made only of numbers, strings, booleans, lists with no gaps and records with string
-- keys: the kinds of thing a data store keeps as they are.
local function isPlain(value: any): boolean
	if type(value) ~= "table" then
		return type(value) == "number" or type(value) == "string" or type(value) == "boolean"
	end
	local keys, stringKeys = 0, 0
	for key, inner in value do
		keys += 1
		if type(key) == "string" then
			stringKeys += 1
		end
		if not isPlain(inner) then
			return false
		end
	end
	return stringKeys == keys or (stringKeys == 0 and #value == keys)
end

-- True if two packs hold the same stacks in the same slots.
local function samePack(a: Inventory.Inventory, b: Inventory.Inventory): boolean
	if a.slotCount ~= b.slotCount then
		return false
	end
	for slot = 1, a.slotCount do
		local inA, inB = Inventory.getStack(a, slot), Inventory.getStack(b, slot)
		if (inA == nil) ~= (inB == nil) or (inA ~= nil and inB ~= nil and not ItemStack.equals(inA, inB)) then
			return false
		end
	end
	return true
end

-- Returns saved data that decode reads, for the checks below to spoil one field of.
local function goodSave(): { [string]: any }
	return { version = 1, pack = { slotCount = 36, stacks = { { slot = 2, itemId = "log", count = 5 } } } }
end

do -- the rules as numbers
	check(SaveData.CURRENT_VERSION == 1, "saved data is at version 1")
end

do -- a new player
	local saved = SaveData.encode(PlayerState.new())
	check(saved.version == 1, "encode: carries the current version")
	check(saved.pack.slotCount == 36 and #saved.pack.stacks == 0, "encode: an empty pack is 36 slots and no stacks")
	check(isPlain(saved), "encode: the data is plain")
	local state, problem = SaveData.decode(saved)
	check(state ~= nil and problem == nil, "decode: reads what encode made")
	check(
		state ~= nil and Inventory.isEmpty(state.pack) and state.pack.slotCount == 36,
		"decode: an empty pack of 36 slots"
	)
end

do -- a player with things
	local state = PlayerState.new()
	Inventory.setStack(state.pack, 1, ItemStack.new("log", 12))
	Inventory.setStack(state.pack, 9, ItemStack.new("stove", 1))
	Inventory.setStack(state.pack, 36, ItemStack.new("fish", 8))
	Hotbar.select(state.hotbar, 9)
	local saved = SaveData.encode(state)
	check(#saved.pack.stacks == 3 and isPlain(saved), "encode: one entry for each slot that holds something")
	check(
		saved.pack.stacks[1].slot == 1 and saved.pack.stacks[1].itemId == "log" and saved.pack.stacks[1].count == 12,
		"encode: an entry says its slot, its item and its count"
	)

	local loaded = SaveData.decode(saved) :: PlayerState.PlayerState
	check(samePack(loaded.pack, state.pack), "decode: the pack holds the same stacks in the same slots")
	check(loaded.pack ~= state.pack, "decode: it is a new player, not the one that was saved")
	check(loaded.hotbar.inventory == loaded.pack, "decode: the hotbar is over the new pack")
	check(loaded.hotbar.selectedSlot == 1 and loaded.session == nil, "decode: slot 1 is selected and no screen is open")

	Inventory.clear(loaded.pack)
	check(
		Inventory.countItems(state.pack, "log") == 12,
		"decode: changing the loaded player changes nothing in the saved one"
	)
	local again = SaveData.decode(saved) :: PlayerState.PlayerState
	check(samePack(again.pack, state.pack), "decode: the same saved data can be read again")
end

do -- a screen that is open
	local state = PlayerState.new()
	Inventory.setStack(state.pack, 1, ItemStack.new("log", 12))
	local session = PlayerState.openInventory(state)
	InventorySession.pickUp(session, "pack", 1)
	check(
		raises("SaveData.encode: the player has an inventory screen open; close it first", function()
			return SaveData.encode(state)
		end),
		"encode: refuses while an inventory screen is open"
	)
	PlayerState.closeInventory(state)
	check(#SaveData.encode(state).pack.stacks == 1, "encode: after closing, what was carried is saved with the pack")
end

do -- data that cannot be read
	local function refuses(what: string, expected: string, saved: any)
		local ok, state, problem = pcall(SaveData.decode, saved)
		check(ok, "decode: raises no error for " .. what)
		check(state == nil, "decode: refuses " .. what)
		check(
			type(problem) == "string" and string.find(problem, expected, 1, true) ~= nil,
			"decode: says what is wrong with " .. what .. " (got: " .. tostring(problem) .. ")"
		)
	end
	refuses("nothing", "saved data is a table, not a nil", nil)
	refuses("a string", "saved data is a table, not a string", "pack")
	refuses("a number", "saved data is a table, not a number", 1)

	for _, bad in { 0, -1, 1.5, 0 / 0, math.huge, "1" } :: { any } do
		local saved = goodSave()
		saved.version = bad
		refuses("version " .. tostring(bad), "version must be a whole number, 1 or more; got " .. tostring(bad), saved)
	end
	local noVersion = goodSave()
	noVersion.version = nil
	refuses("no version", "version must be a whole number, 1 or more; got nil", noVersion)

	local newer = goodSave()
	newer.version = 2
	refuses(
		"a newer version",
		"saved by a newer version of the game: version 2, and this game reads up to version 1",
		newer
	)

	local extra = goodSave()
	extra.coins = 5
	refuses("a field that does not belong", "saved data has no field called coins", extra)

	local noPack = goodSave()
	noPack.pack = nil
	refuses("no pack", "pack: ", noPack)
	local badItem = goodSave()
	badItem.pack.stacks[1].itemId = "anvil"
	refuses("an item that does not exist", 'pack: stacks[1].itemId: no item has the id "anvil"', badItem)
	local badCount = goodSave()
	badCount.pack.stacks[1].count = 99
	refuses("a stack over its size", "pack: stacks[1].count", badCount)
	local smallPack = goodSave()
	smallPack.pack.slotCount = 27
	refuses("a pack of the wrong size", "pack has 27 slots, and a pack has 36", smallPack)
	local bigPack = goodSave()
	bigPack.pack.slotCount = 37
	refuses("a pack that is too big", "pack has 37 slots, and a pack has 36", bigPack)

	check(SaveData.decode(goodSave()) ~= nil, "decode: the data these were spoiled from is itself readable")
end

do -- many random players: what is saved is what comes back
	local seed = 4242
	local function random(limit: number): number
		seed = (seed * 1103515245 + 12345) % 2147483648
		return math.floor(seed / 65536) % limit + 1
	end
	local itemIds = { "log", "fish", "stove" }
	local stackSizes: { [string]: number } = { log = 16, fish = 8, stove = 1 }
	local allSame, allPlain = true, true
	for _ = 1, 60 do
		local state = PlayerState.new()
		for _ = 1, random(40) do
			local itemId = itemIds[random(3)]
			Inventory.setStack(state.pack, random(36), ItemStack.new(itemId, random(stackSizes[itemId])))
		end
		local saved = SaveData.encode(state)
		local loaded = SaveData.decode(saved)
		if loaded == nil or not samePack(loaded.pack, state.pack) then
			allSame = false
		end
		if not isPlain(saved) then
			allPlain = false
		end
	end
	check(allSame, "random players: every pack comes back as it was saved")
	check(allPlain, "random players: every save is plain data")
end

Check.finish("SaveData")
