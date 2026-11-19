--!strict
-- Tests for ItemStack. Run from the repository root: lune run tests/items/ItemStack.test.luau

local Check = require("../Check")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")

local check = Check.that
local raises = Check.raises

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "stone", stackSize = 16 })
ItemRegistry.register({ id = "stove", stackSize = 1 })

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

do -- new
	local logs = ItemStack.new("log", 12)
	check(logs.itemId == "log" and logs.count == 12, "new: a stack has its item id and its count")
	check(is(ItemStack.new("log", 1), "log", 1), "new: 1 is the smallest stack")
	check(is(ItemStack.new("log", 16), "log", 16), "new: the stack size is the largest stack")
	check(is(ItemStack.new("stove", 1), "stove", 1), "new: an item that does not stack makes a stack of 1")
end

do -- what new refuses
	check(
		raises('ItemStack.new: no item has the id "anvil"', function()
			return ItemStack.new("anvil", 1)
		end),
		"new: refuses an item that does not exist, and names it"
	)
	for _, badCount in { 0, -1, 1.5, 17, 0 / 0, math.huge } do
		check(
			raises('a stack of "log" holds 1 to 16', function()
				return ItemStack.new("log", badCount)
			end),
			"new: refuses a count of " .. tostring(badCount)
		)
	end
	check(
		raises('a stack of "stove" holds 1 to 1', function()
			return ItemStack.new("stove", 2)
		end),
		"new: refuses two of an item that does not stack"
	)
	check(
		raises("holds 1 to 16", function()
			return ItemStack.new("log", "5" :: any)
		end),
		"new: refuses a count that is not a number"
	)
end

do -- a stack never changes
	local logs = ItemStack.new("log", 12)
	check(Check.errorFrom(function()
		(logs :: any).count = 5
	end) ~= nil, "a stack's count cannot be changed")
	check(Check.errorFrom(function()
		(logs :: any).itemId = "stone"
	end) ~= nil, "a stack's item cannot be changed")
	check(is(logs, "log", 12), "the stack is as it was after both attempts")
end

do -- spaceLeft and isFull
	local logs = ItemStack.new("log", 12)
	check(ItemStack.spaceLeft(logs) == 4, "spaceLeft: how many more fit")
	check(ItemStack.isFull(logs) == false, "isFull: false when there is room")
	local full = ItemStack.new("log", 16)
	check(ItemStack.spaceLeft(full) == 0, "spaceLeft: 0 for a full stack")
	check(ItemStack.isFull(full), "isFull: true for a full stack")
	check(ItemStack.spaceLeft(ItemStack.new("log", 1)) == 15, "spaceLeft: 15 for one log")
	check(ItemStack.isFull(ItemStack.new("stove", 1)), "isFull: one of an item that does not stack is full")
end

do -- equals and isSameItem
	local a = ItemStack.new("log", 5)
	check(ItemStack.equals(a, ItemStack.new("log", 5)), "equals: the same item and count")
	check(ItemStack.equals(a, ItemStack.new("log", 6)) == false, "equals: not with a different count")
	check(ItemStack.equals(a, ItemStack.new("stone", 5)) == false, "equals: not with a different item")
	check(ItemStack.isSameItem(a, ItemStack.new("log", 16)), "isSameItem: true whatever the counts")
	check(ItemStack.isSameItem(a, ItemStack.new("stone", 5)) == false, "isSameItem: false for different items")
end

do -- merge
	local ten = ItemStack.new("log", 10)
	local four = ItemStack.new("log", 4)
	local merged, leftover = ItemStack.merge(ten, four)
	check(is(merged, "log", 14) and leftover == nil, "merge: all of it fits, so nothing is left")
	check(is(ten, "log", 10) and is(four, "log", 4), "merge: the stacks given are as they were")

	local filled, rest = ItemStack.merge(ten, ten)
	check(is(filled, "log", 16) and is(rest, "log", 4), "merge: fills to the stack size and returns the rest")

	local exact, none = ItemStack.merge(ItemStack.new("log", 12), four)
	check(is(exact, "log", 16) and none == nil, "merge: exactly filling leaves nothing")

	local full = ItemStack.new("log", 16)
	local same, all = ItemStack.merge(full, four)
	check(is(same, "log", 16) and is(all, "log", 4), "merge: nothing goes into a full stack")

	local stone = ItemStack.new("stone", 1)
	local kept, refused = ItemStack.merge(ten, stone)
	check(kept == ten and refused == stone, "merge: different items do not merge, and both come back as they were")
end

do -- split
	local twelve = ItemStack.new("log", 12)
	local taken, rest = ItemStack.split(twelve, 5)
	check(is(taken, "log", 5) and is(rest, "log", 7), "split: the part taken and the part that remains")
	check(is(twelve, "log", 12), "split: the stack given is as it was")

	local whole, nothing = ItemStack.split(twelve, 12)
	check(is(whole, "log", 12) and nothing == nil, "split: taking all of it leaves no stack behind")

	local one, eleven = ItemStack.split(twelve, 1)
	check(is(one, "log", 1) and is(eleven, "log", 11), "split: taking one")

	for _, badCount in { 0, -1, 2.5, 13, 0 / 0, math.huge } do
		check(
			raises('ItemStack.split: can take 1 to 12 from this stack of "log"', function()
				return ItemStack.split(twelve, badCount)
			end),
			"split: refuses to take " .. tostring(badCount) .. " from 12"
		)
	end
end

do -- no item is made or lost
	local broken: string? = nil
	for intoCount = 1, 16 do
		for fromCount = 1, 16 do
			local merged, leftover = ItemStack.merge(ItemStack.new("log", intoCount), ItemStack.new("log", fromCount))
			local total = merged.count + (if leftover then leftover.count else 0)
			if total ~= intoCount + fromCount or merged.count ~= math.min(16, intoCount + fromCount) then
				broken = broken or string.format("merging %d into %d", fromCount, intoCount)
			end
		end
	end
	check(
		broken == nil,
		"merge: every pair of counts from 1 to 16 keeps every log" .. (if broken then "; wrong when " .. broken else "")
	)
	broken = nil
	for count = 1, 16 do
		for take = 1, count do
			local taken, rest = ItemStack.split(ItemStack.new("log", count), take)
			if taken.count ~= take or (if rest then rest.count else 0) ~= count - take then
				broken = broken or string.format("taking %d from %d", take, count)
			end
		end
	end
	check(
		broken == nil,
		"split: every count from 1 to 16 and every take keeps every log"
			.. (if broken then "; wrong when " .. broken else "")
	)
end

Check.finish("ItemStack")
