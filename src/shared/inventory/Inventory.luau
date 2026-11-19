--!strict
--[=[
	Slots that hold stacks of items: a player's pack, the inside of a crate.

	An inventory has a fixed number of slots, numbered from 1. Each slot holds
	one ItemStack or nothing. A slot that holds nothing has no entry at all, so
	a new inventory with 3 slots is `{ slotCount = 3, slots = {} }`, and with
	5 logs in slot 2 it is
	`{ slotCount = 3, slots = { [2] = { itemId = "log", count = 5 } } }`.

	[method getStack], [method setStack], [method takeFromSlot] and
	[method putInSlot] work on one numbered slot. The other functions work on
	the whole inventory, wherever the items are.

	A function that changes an inventory changes the one it is given. It does
	not return a new one.

	Items move between the inventory and the caller, and none is made or lost
	on the way. A function that is given a count returns how many items it
	moved. A function that is given a stack returns the stack of what did not
	fit, and a function that takes a stack out returns that stack. Only
	[method setStack] and [method clear] discard what a slot held.

	A full inventory, or a slot that holds nothing, is ordinary: the function
	does what it can and says so in what it returns. A mistake in the calling
	code raises an error: a slot number that is not from 1 to `slotCount`, a
	count that is not a whole number of 0 or more, or adding or removing an
	item that does not exist.

	Nothing here announces a change. Code that shows an inventory reads it
	again after changing it.

	To save an inventory, or send it to another machine, use [method encode]
	and [method decode]. Never hand an inventory itself to a data store or a
	remote: its `slots` table has gaps, and Roblox drops or re-keys the
	entries of a table with gaps.

	```lua
	local pack = Inventory.new(27)
	Inventory.addItems(pack, "log", 40) --> 40: all of them were added, as 16, 16 and 8 in slots 1 to 3
	Inventory.countItems(pack, "log") --> 40
	Inventory.getStack(pack, 3) --> 8 logs
	Inventory.getStack(pack, 4) --> nil: slot 4 holds nothing
	Inventory.getStack(pack, 28) --> error: slot 28 is out of range
	```
]=]
local ItemRegistry = require("../items/ItemRegistry")
local ItemStack = require("../items/ItemStack")

local Inventory = {}

type ItemStack = ItemStack.ItemStack

--- `read` means code outside this module cannot assign the field. Change an inventory with the functions below.
export type Inventory = {
	--- How many slots it has. Fixed when the inventory is made.
	read slotCount: number,
	--- What each slot holds, by slot number. A slot that holds nothing has no entry.
	--- The table has gaps, so do not use `#` or `ipairs` on it: to visit the slots in order, loop
	--- from 1 to `slotCount` and call [method getStack].
	read slots: { read [number]: ItemStack? },
}

--- An inventory as plain data, made by [method encode] and read by [method decode].
--- Every table in it is a list with no gaps or a record with named fields, so it survives a data store or a remote.
export type EncodedInventory = {
	slotCount: number,
	--- One entry for each slot that holds something, lowest slot first.
	stacks: { { slot: number, itemId: string, count: number } },
}

local function isWholeNumber(value: unknown): boolean
	return type(value) == "number" and value == math.floor(value) and value ~= math.huge and value ~= -math.huge
end

local function writableSlots(inventory: Inventory): { [number]: ItemStack? }
	return inventory.slots :: any
end

-- Raises `problem` as an error that names the public function and blames the code that called it.
local function failIf(problem: string?, functionName: string)
	if problem ~= nil then
		error(functionName .. ": " .. problem, 3)
	end
end

local function slotProblem(inventory: Inventory, slot: number): string?
	if isWholeNumber(slot) and slot >= 1 and slot <= inventory.slotCount then
		return nil
	end
	return string.format(
		"slot %s is out of range; this inventory has slots 1 to %d",
		tostring(slot),
		inventory.slotCount
	)
end

local function countProblem(count: number): string?
	if isWholeNumber(count) and count >= 0 then
		return nil
	end
	return string.format("count must be a whole number, 0 or more; got %s", tostring(count))
end

local function rangeProblem(inventory: Inventory, firstSlot: number?, lastSlot: number?): string?
	if firstSlot == nil and lastSlot == nil then
		return nil
	end
	local isRange = isWholeNumber(firstSlot)
		and isWholeNumber(lastSlot)
		and (firstSlot :: number) >= 1
		and (lastSlot :: number) <= inventory.slotCount
		and (firstSlot :: number) <= (lastSlot :: number)
	if isRange then
		return nil
	end
	return string.format(
		"slots %s to %s are not a run of this inventory's slots; it has slots 1 to %d",
		tostring(firstSlot),
		tostring(lastSlot),
		inventory.slotCount
	)
end

local function itemProblem(itemId: string): string?
	if type(itemId) == "string" and ItemRegistry.has(itemId) then
		return nil
	end
	return string.format('no item has the id "%s"', tostring(itemId))
end

--[=[
	Returns a new inventory with `slotCount` slots, all holding nothing.

	Raises an error if `slotCount` is not a whole number of 1 or more.
]=]
function Inventory.new(slotCount: number): Inventory
	if not isWholeNumber(slotCount) or slotCount < 1 then
		error(
			string.format("Inventory.new: slotCount must be a whole number, 1 or more; got %s", tostring(slotCount)),
			2
		)
	end
	return table.freeze({ slotCount = slotCount, slots = {} })
end

--[=[
	Returns `true` if no slot holds anything.
]=]
function Inventory.isEmpty(inventory: Inventory): boolean
	return next(writableSlots(inventory)) == nil
end

--[=[
	Returns the stack in the slot numbered `slot`, or `nil` if the slot holds nothing.

	Raises an error if `slot` is not from 1 to `slotCount`.
]=]
function Inventory.getStack(inventory: Inventory, slot: number): ItemStack?
	failIf(slotProblem(inventory, slot), "Inventory.getStack")
	return inventory.slots[slot]
end

--[=[
	Makes the slot numbered `slot` hold `stack`, in place of whatever it held.
	Passing `nil` leaves the slot holding nothing.

	What the slot held before is discarded. To keep it, use [method takeFromSlot] first.

	Raises an error if `slot` is not from 1 to `slotCount`, or if `stack` is
	not a stack that `ItemStack.new` could have made.
]=]
function Inventory.setStack(inventory: Inventory, slot: number, stack: ItemStack?)
	failIf(slotProblem(inventory, slot), "Inventory.setStack")
	if stack == nil then
		writableSlots(inventory)[slot] = nil
		return
	end
	failIf(ItemStack.validate(stack), "Inventory.setStack")
	writableSlots(inventory)[slot] = ItemStack.new(stack.itemId, stack.count)
end

--[=[
	Takes up to `count` items out of the slot numbered `slot` and returns them as a stack.

	Leaving out `count` takes everything in the slot. Asking for more than the
	slot holds takes what is there. Returns `nil` if nothing was taken, because
	the slot holds nothing or `count` is 0.

	Raises an error if `slot` is not from 1 to `slotCount`, or if `count` is
	not a whole number of 0 or more.
]=]
function Inventory.takeFromSlot(inventory: Inventory, slot: number, count: number?): ItemStack?
	failIf(slotProblem(inventory, slot), "Inventory.takeFromSlot")
	if count ~= nil then
		failIf(countProblem(count), "Inventory.takeFromSlot")
	end
	local slots = writableSlots(inventory)
	local stack = slots[slot]
	if stack == nil or count == 0 then
		return nil
	end
	if count == nil or count >= stack.count then
		slots[slot] = nil
		return stack
	end
	local taken, rest = ItemStack.split(stack, count)
	slots[slot] = rest
	return taken
end

--[=[
	Puts `stack` into the slot numbered `slot`, and returns the stack of what
	did not fit, or `nil` if all of it went in.

	A slot that holds nothing takes the whole stack. A slot holding the same
	item is topped up to that item's stack size. A slot holding a different
	item takes nothing, and the whole of `stack` is returned.

	Raises an error if `slot` is not from 1 to `slotCount`, or if `stack` is
	not a stack that `ItemStack.new` could have made.
]=]
function Inventory.putInSlot(inventory: Inventory, slot: number, stack: ItemStack): ItemStack?
	failIf(slotProblem(inventory, slot), "Inventory.putInSlot")
	failIf(ItemStack.validate(stack), "Inventory.putInSlot")
	local slots = writableSlots(inventory)
	local there = slots[slot]
	if there == nil then
		slots[slot] = ItemStack.new(stack.itemId, stack.count)
		return nil
	end
	local merged, leftover = ItemStack.merge(there, stack)
	slots[slot] = merged
	return leftover
end

--[=[
	Adds up to `count` of the item with the id `itemId`, wherever they fit,
	and returns how many were added.

	Stacks of the same item are topped up first, lowest slot first. Then slots
	that hold nothing are filled, lowest slot first. What fits is added even
	when the rest does not; ask [method spaceFor] first if it must be all or nothing.

	Given `firstSlot` and `lastSlot`, only the slots from the one to the other
	are used, and the rest of the inventory is left alone: that is how items
	are sent to a hotbar and nowhere else. Leave both out to use every slot.

	Raises an error if no item has the id `itemId`, if `count` is not a whole
	number of 0 or more, or if `firstSlot` and `lastSlot` are given and are
	not two of this inventory's slots with `firstSlot` no greater than
	`lastSlot`.
]=]
function Inventory.addItems(
	inventory: Inventory,
	itemId: string,
	count: number,
	firstSlot: number?,
	lastSlot: number?
): number
	failIf(itemProblem(itemId), "Inventory.addItems")
	failIf(countProblem(count), "Inventory.addItems")
	failIf(rangeProblem(inventory, firstSlot, lastSlot), "Inventory.addItems")
	local first = firstSlot or 1
	local last = lastSlot or inventory.slotCount
	local stackSize = ItemRegistry.get(itemId).stackSize
	local slots = writableSlots(inventory)
	local left = count
	for slot = first, last do
		if left == 0 then
			break
		end
		local there = slots[slot]
		if there ~= nil and there.itemId == itemId and there.count < stackSize then
			local added = math.min(left, stackSize - there.count)
			slots[slot] = ItemStack.new(itemId, there.count + added)
			left -= added
		end
	end
	for slot = first, last do
		if left == 0 then
			break
		end
		if slots[slot] == nil then
			local added = math.min(left, stackSize)
			slots[slot] = ItemStack.new(itemId, added)
			left -= added
		end
	end
	return count - left
end

--[=[
	Adds the items of `stack`, wherever they fit, and returns the stack of
	what did not fit, or `nil` if all of it went in.

	This is [method addItems] for a caller that is holding a stack. The items
	go in the same order: stacks of the same item first, then slots that hold
	nothing. Given `firstSlot` and `lastSlot`, only the slots from the one to
	the other are used.

	Raises an error if `stack` is not a stack that `ItemStack.new` could have
	made, or if `firstSlot` and `lastSlot` are given and are not two of this
	inventory's slots with `firstSlot` no greater than `lastSlot`.
]=]
function Inventory.addStack(inventory: Inventory, stack: ItemStack, firstSlot: number?, lastSlot: number?): ItemStack?
	failIf(ItemStack.validate(stack), "Inventory.addStack")
	failIf(rangeProblem(inventory, firstSlot, lastSlot), "Inventory.addStack")
	local added = Inventory.addItems(inventory, stack.itemId, stack.count, firstSlot, lastSlot)
	if added == stack.count then
		return nil
	end
	return ItemStack.new(stack.itemId, stack.count - added)
end

--[=[
	Removes up to `count` of the item with the id `itemId`, from whichever
	slots hold them, and returns how many were removed.

	Items are taken from the lowest slot first. If the inventory holds fewer
	than `count`, all of them are removed; ask [method hasItems] first if it
	must be all or nothing.

	Raises an error if no item has the id `itemId`, or if `count` is not a
	whole number of 0 or more.
]=]
function Inventory.removeItems(inventory: Inventory, itemId: string, count: number): number
	failIf(itemProblem(itemId), "Inventory.removeItems")
	failIf(countProblem(count), "Inventory.removeItems")
	local slots = writableSlots(inventory)
	local left = count
	for slot = 1, inventory.slotCount do
		if left == 0 then
			break
		end
		local there = slots[slot]
		if there ~= nil and there.itemId == itemId then
			if there.count <= left then
				slots[slot] = nil
				left -= there.count
			else
				slots[slot] = ItemStack.new(itemId, there.count - left)
				left = 0
			end
		end
	end
	return count - left
end

--[=[
	Returns how many of the item with the id `itemId` the inventory holds,
	over all its slots. 0 if it holds none, which is also the answer for an
	id that no item has.
]=]
function Inventory.countItems(inventory: Inventory, itemId: string): number
	local total = 0
	for _, stack in writableSlots(inventory) do
		if stack ~= nil and stack.itemId == itemId then
			total += stack.count
		end
	end
	return total
end

--[=[
	Returns `true` if the inventory holds at least `count` of the item with
	the id `itemId`.

	Raises an error if `count` is not a whole number of 0 or more.
]=]
function Inventory.hasItems(inventory: Inventory, itemId: string, count: number): boolean
	failIf(countProblem(count), "Inventory.hasItems")
	return Inventory.countItems(inventory, itemId) >= count
end

--[=[
	Returns how many more of the item with the id `itemId` would fit: the room
	left in stacks of that item, plus a full stack for every slot that holds nothing.

	[method addItems] with a count up to this number adds all of them.

	Raises an error if no item has the id `itemId`, since how many fit depends
	on the item's stack size.
]=]
function Inventory.spaceFor(inventory: Inventory, itemId: string): number
	failIf(itemProblem(itemId), "Inventory.spaceFor")
	local stackSize = ItemRegistry.get(itemId).stackSize
	local space = 0
	for slot = 1, inventory.slotCount do
		local there = inventory.slots[slot]
		if there == nil then
			space += stackSize
		elseif there.itemId == itemId then
			space += stackSize - there.count
		end
	end
	return space
end

--[=[
	Leaves every slot holding nothing. The items that were in them are discarded.
]=]
function Inventory.clear(inventory: Inventory)
	table.clear(writableSlots(inventory))
end

--[=[
	Returns `inventory` as plain data, for saving or for sending to another machine.

	The result holds only numbers, strings and lists with no gaps, and shares
	nothing with the inventory. A slot that holds nothing is left out. An
	inventory with 3 slots and 5 logs in slot 2 becomes
	`{ slotCount = 3, stacks = { { slot = 2, itemId = "log", count = 5 } } }`.
]=]
function Inventory.encode(inventory: Inventory): EncodedInventory
	local stacks = {}
	for slot = 1, inventory.slotCount do
		local stack = inventory.slots[slot]
		if stack ~= nil then
			table.insert(stacks, { slot = slot, itemId = stack.itemId, count = stack.count })
		end
	end
	return { slotCount = inventory.slotCount, stacks = stacks }
end

--[=[
	Returns a new inventory built from data that [method encode] made.

	The data comes from outside the game, so nothing about it is trusted. If
	any part of it is not what [method encode] would have written, no inventory
	is made: the function returns `nil` and a sentence saying what was wrong.
	That covers a missing or extra field, a slot number that is out of range
	or used twice, an id that no item has, and a count that a stack could not
	have.
]=]
function Inventory.decode(encoded: unknown): (Inventory?, string?)
	if type(encoded) ~= "table" then
		return nil, "an encoded inventory is a table, not a " .. type(encoded)
	end
	local fields = encoded :: { [unknown]: unknown }
	for field in fields do
		if field ~= "slotCount" and field ~= "stacks" then
			return nil, "an encoded inventory has no field called " .. tostring(field)
		end
	end
	local slotCount = fields.slotCount
	if not isWholeNumber(slotCount) or (slotCount :: number) < 1 then
		return nil, "slotCount must be a whole number, 1 or more; got " .. tostring(slotCount)
	end
	local stacks = fields.stacks
	if type(stacks) ~= "table" then
		return nil, "stacks must be a list, not a " .. type(stacks)
	end
	local entries = stacks :: { [unknown]: unknown }
	local entryCount = 0
	for _ in entries do
		entryCount += 1
	end
	local inventory = Inventory.new(slotCount :: number)
	local slots = writableSlots(inventory)
	for index = 1, entryCount do
		local entry = entries[index]
		if type(entry) ~= "table" then
			return nil, string.format("stacks must be a list with no gaps; entry %d is a %s", index, type(entry))
		end
		local stack = entry :: { [unknown]: unknown }
		for field in stack do
			if field ~= "slot" and field ~= "itemId" and field ~= "count" then
				return nil, string.format("stacks[%d] has no field called %s", index, tostring(field))
			end
		end
		local slot, itemId, count = stack.slot, stack.itemId, stack.count
		if not isWholeNumber(slot) or (slot :: number) < 1 or (slot :: number) > (slotCount :: number) then
			return nil,
				string.format(
					"stacks[%d].slot must be from 1 to %d; got %s",
					index,
					slotCount :: number,
					tostring(slot)
				)
		end
		if slots[slot :: number] ~= nil then
			return nil,
				string.format("stacks[%d].slot is %d, which an earlier entry already used", index, slot :: number)
		end
		if type(itemId) ~= "string" or not ItemRegistry.has(itemId) then
			return nil, string.format('stacks[%d].itemId: no item has the id "%s"', index, tostring(itemId))
		end
		local stackSize = ItemRegistry.get(itemId).stackSize
		if not isWholeNumber(count) or (count :: number) < 1 or (count :: number) > stackSize then
			return nil,
				string.format(
					'stacks[%d].count: a stack of "%s" holds 1 to %d, not %s',
					index,
					itemId,
					stackSize,
					tostring(count)
				)
		end
		slots[slot :: number] = ItemStack.new(itemId, count :: number)
	end
	return inventory, nil
end

return Inventory
