--!strict
-- Tests for SaveData. Run from the repository root: lune run tests/save/SaveData.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlayerState = require("../../src/shared/players/PlayerState")
local SaveData = require("../../src/shared/save/SaveData")

local check = Check.that

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
		if
			(inA == nil) ~= (inB == nil)
			or (inA ~= nil and inB ~= nil and (inA.itemId ~= inB.itemId or inA.count ~= inB.count))
		then
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

do -- an empty pack
	local saved = SaveData.encode(Inventory.new(PlayerState.PACK_SLOTS))
	check(saved.version == 1, "encode: carries the current version")
	check(saved.pack.slotCount == 36 and #saved.pack.stacks == 0, "encode: an empty pack is 36 slots and no stacks")
	check(isPlain(saved), "encode: the data is plain")
	local pack, problem = SaveData.decode(saved)
	check(pack ~= nil and problem == nil, "decode: reads what encode made, with nothing wrong")
	check(pack ~= nil and Inventory.isEmpty(pack) and pack.slotCount == 36, "decode: an empty pack of 36 slots")
end

do -- a pack with things
	local pack = Inventory.new(PlayerState.PACK_SLOTS)
	Inventory.setStack(pack, 1, ItemStack.new("log", 12))
	Inventory.setStack(pack, 9, ItemStack.new("stove", 1))
	Inventory.setStack(pack, 36, ItemStack.new("fish", 8))
	local saved = SaveData.encode(pack)
	check(#saved.pack.stacks == 3 and isPlain(saved), "encode: one entry for each slot that holds something")
	check(
		saved.pack.stacks[1].slot == 1 and saved.pack.stacks[1].itemId == "log" and saved.pack.stacks[1].count == 12,
		"encode: an entry says its slot, its item and its count"
	)
	check(Inventory.countItems(pack, "log") == 12, "encode: changes nothing in the pack")

	local loaded = SaveData.decode(saved) :: Inventory.Inventory
	check(samePack(loaded, pack), "decode: the pack holds the same stacks in the same slots")
	check(loaded ~= pack, "decode: it is a new pack, not the one that was saved")

	Inventory.takeFromSlot(loaded, 1)
	check(
		Inventory.countItems(pack, "log") == 12,
		"decode: changing the loaded pack changes nothing in the one that was saved"
	)
	local again = SaveData.decode(saved) :: Inventory.Inventory
	check(samePack(again, pack), "decode: the same saved data can be read again")
	check(again ~= loaded, "decode: reading again gives a new pack each time")
end

do -- encode writes whatever inventory it is given
	local saved = SaveData.encode(Inventory.new(3))
	check(saved.pack.slotCount == 3, "encode: writes the slot count of the inventory given")
	local pack, problem = SaveData.decode(saved)
	check(pack == nil and problem ~= nil, "decode: refuses data written from an inventory that is not a pack")
end

do -- data that cannot be read
	local function refuses(what: string, expected: string, saved: any)
		local ok, pack, problem = pcall(SaveData.decode, saved)
		check(ok, "decode: raises no error for " .. what)
		check(pack == nil, "decode: refuses " .. what)
		check(
			type(problem) == "string" and string.find(problem, expected, 1, true) ~= nil,
			"decode: says what is wrong with " .. what .. " (got: " .. tostring(problem) .. ")"
		)
	end
	refuses("nothing", "saved data is a table, not a nil", nil)
	refuses("a string", "saved data is a table, not a string", "pack")
	refuses("a number", "saved data is a table, not a number", 1)
	refuses("a boolean", "saved data is a table, not a boolean", true)

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
	refuses("an item that does not exist", 'pack: stacks[1]: no item has the id "anvil"', badItem)
	local badCount = goodSave()
	badCount.pack.stacks[1].count = 99
	refuses("a stack over its size", 'pack: stacks[1]: a stack of "log" holds 1 to 16, not 99', badCount)
	local smallPack = goodSave()
	smallPack.pack.slotCount = 27
	refuses("a pack of the wrong size", "pack has 27 slots, and a pack has 36", smallPack)
	local bigPack = goodSave()
	bigPack.pack.slotCount = 37
	refuses("a pack that is too big", "pack has 37 slots, and a pack has 36", bigPack)

	local pack, problem = SaveData.decode(goodSave())
	check(pack ~= nil and problem == nil, "decode: the data these were spoiled from is itself readable")
	check(pack ~= nil and Inventory.countItems(pack, "log") == 5, "decode: reads the stacks of the pack in the data")
end

do -- many random packs: what is saved is what comes back
	local seed = 4242
	local function random(limit: number): number
		seed = (seed * 16807) % 2147483647
		return math.floor(seed / 65536) % limit + 1
	end
	local itemIds = { "log", "fish", "stove" }
	local stackSizes: { [string]: number } = { log = 16, fish = 8, stove = 1 }
	local allSame, allPlain = true, true
	for _ = 1, 60 do
		local pack = Inventory.new(PlayerState.PACK_SLOTS)
		for _ = 1, random(40) do
			local itemId = itemIds[random(3)]
			Inventory.setStack(pack, random(36), ItemStack.new(itemId, random(stackSizes[itemId])))
		end
		local saved = SaveData.encode(pack)
		local loaded = SaveData.decode(saved)
		if loaded == nil or not samePack(loaded, pack) then
			allSame = false
		end
		if not isPlain(saved) then
			allPlain = false
		end
	end
	check(allSame, "random packs: every pack comes back as it was saved")
	check(allPlain, "random packs: every save is plain data")
end

Check.finish("SaveData")
