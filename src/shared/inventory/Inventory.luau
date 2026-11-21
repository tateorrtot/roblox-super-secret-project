--!strict
--- Numbered slots that each hold one `ItemStack` or `nil`.
---
--- An inventory has a fixed number of slots, numbered from `1`. `getStack`, `setStack`,
--- `takeFromSlot` and `putInSlot` act on one slot. `addItems` and `addStack` put items in whichever
--- slots they fit, and `takeEveryStack` empties every slot. `addItems` makes the items that it
--- adds, and `setStack` discards the stack that the slot held. Every other function that changes
--- the inventory moves stacks between the inventory and its caller, so it makes no item and loses
--- none.
local ItemRegistry = require("../items/ItemRegistry")
local ItemStack = require("../items/ItemStack")

local Inventory = {}

type ItemStack = ItemStack.ItemStack

--- Slots that each hold one stack of items or nothing.
export type Inventory = {
	--- How many slots the inventory has, numbered from `1`.
	read slotCount: number,
	--- The stack in each slot, by slot number. A slot that holds nothing has no entry.
	--- Note: the table has gaps, so `#` and `ipairs` do not work on it. Loop from `1` to
	--- `slotCount`.
	read slots: { [number]: ItemStack? },
}

--- An inventory as plain data. `encode` makes it, and `decode` reads it.
export type EncodedInventory = {
	--- How many slots the inventory has.
	slotCount: number,
	--- One entry for each slot that holds a stack, lowest slot first.
	stacks: { { slot: number, itemId: string, count: number } },
}

local function checkSlot(inventory: Inventory, slot: number)
	if slot % 1 ~= 0 or slot < 1 or slot > inventory.slotCount then
		error(`an inventory of {inventory.slotCount} slots has no slot {slot}`, 3)
	end
end

--- Returns a new inventory of `slotCount` slots, all holding nothing.
--- Note: `new` does not check that `slotCount` is a whole number of `1` or more.
function Inventory.new(slotCount: number): Inventory
	return table.freeze({ slotCount = slotCount, slots = {} })
end

--- Returns `true` if `slot` is a whole number from `1` to the inventory's `slotCount`. Accepts a
--- value of any type, and never raises an error.
function Inventory.hasSlot(inventory: Inventory, slot: unknown): boolean
	return type(slot) == "number" and slot % 1 == 0 and slot >= 1 and slot <= inventory.slotCount
end

--- Returns a new list of the numbers of the inventory's slots, from `1` to `slotCount`.
function Inventory.getSlotNumbers(inventory: Inventory): { number }
	local slots = {}
	for slot = 1, inventory.slotCount do
		table.insert(slots, slot)
	end
	return slots
end

--- Returns `true` if no slot holds a stack.
function Inventory.isEmpty(inventory: Inventory): boolean
	return next(inventory.slots) == nil
end

--- Returns the stack in `slot`, or `nil` if the slot holds nothing. Raises an error if the
--- inventory lacks `slot`.
function Inventory.getStack(inventory: Inventory, slot: number): ItemStack?
	checkSlot(inventory, slot)
	return inventory.slots[slot]
end

--- Makes `slot` hold `stack`, or hold nothing if `stack` is `nil`. Discards the stack that the slot
--- held. Raises an error, and changes nothing, if the inventory lacks `slot`.
function Inventory.setStack(inventory: Inventory, slot: number, stack: ItemStack?)
	checkSlot(inventory, slot)
	inventory.slots[slot] = stack
end

--- Takes items out of the `ItemStack` in `slot`, and returns them as an `ItemStack`.
--- - `inventory`: the `Inventory` that `slot` is in.
--- - `slot`: a `number`. A slot number of `inventory`, from `1` to `inventory.slotCount`.
--- - `count`: a whole `number` of `0` or more, or `nil`. How many items to take. `nil` takes every
--- item in `slot`.
---
--- If `count` is `nil`, or is at least the `count` of the `ItemStack` in `slot`, `takeFromSlot`
--- returns that `ItemStack` itself, and `slot` then holds `nil`. Otherwise it returns a new
--- `ItemStack` of `count` items, and `slot` then holds a new `ItemStack` of the items that are
--- left. Returns `nil`, and changes nothing, if `slot` holds `nil` or `count` is `0`. Raises an
--- error if `hasSlot` returns `false` for `slot`.
--- Note: `takeFromSlot` does not check that `count` is a whole number of `0` or more.
function Inventory.takeFromSlot(inventory: Inventory, slot: number, count: number?): ItemStack?
	checkSlot(inventory, slot)
	local stack = inventory.slots[slot]
	if stack == nil or count == 0 then
		return nil
	end
	if count == nil or count >= stack.count then
		inventory.slots[slot] = nil
		return stack
	end
	local taken, rest = ItemStack.split(stack, count)
	inventory.slots[slot] = rest
	return taken
end

--- Adds the items of `stack` to `slot`, and returns an `ItemStack` of the items that did not fit,
--- or `nil` if every item went in.
--- - `inventory`: the `Inventory` that `slot` is in.
--- - `slot`: a `number`. A slot number of `inventory`, from `1` to `inventory.slotCount`.
--- - `stack`: the `ItemStack` to add. `putInSlot` does not change it.
---
--- If `slot` holds `nil`, `slot` then holds `stack` itself. If `slot` holds an `ItemStack` with the
--- same `itemId`, `putInSlot` adds items until that `ItemStack` reaches the `stackSize` of its
--- `ItemRegistry.ItemDefinition`, and returns a new `ItemStack` of the rest. If `slot` holds a
--- different `itemId`, `putInSlot` adds nothing and returns `stack` itself. Raises an error if
--- `hasSlot` returns `false` for `slot`.
function Inventory.putInSlot(inventory: Inventory, slot: number, stack: ItemStack): ItemStack?
	checkSlot(inventory, slot)
	local there = inventory.slots[slot]
	if there == nil then
		inventory.slots[slot] = stack
		return nil
	end
	local merged, leftover = ItemStack.merge(there, stack)
	inventory.slots[slot] = merged
	return leftover
end

local function addToSlot(inventory: Inventory, slot: number, itemId: string, count: number): number
	local offered = math.min(count, ItemRegistry.get(itemId).stackSize)
	local leftover = Inventory.putInSlot(inventory, slot, ItemStack.new(itemId, offered))
	return offered - (if leftover then leftover.count else 0)
end

--- Makes up to `count` items of `itemId`, adds them to `inventory`, and returns how many it added.
--- - `inventory`: the `Inventory` to add to.
--- - `itemId`: the `id` of an item that `ItemRegistry.register` registered, such as `"log"`.
--- - `count`: a whole `number` of `0` or more. The most items to make.
--- - `intoSlots`: a list of slot numbers of `inventory`. The function uses only these slots, in
--- this order. `nil` means every slot, from `1` to `inventory.slotCount`.
---
--- First adds items to each slot in `intoSlots` that holds an `ItemStack` with the same `itemId`,
--- until that `ItemStack` reaches the `stackSize` of its `ItemRegistry.ItemDefinition`. Then puts
--- new `ItemStack`s in the slots in `intoSlots` that hold `nil`. Stops when it has added `count`
--- items, or when no slot in `intoSlots` has room. Raises an error, and changes nothing, if `count`
--- is not a whole number of `0` or more, or if `hasSlot` returns `false` for a slot in `intoSlots`.
--- Note: `addItems` does not check `itemId` if `count` is `0` or `intoSlots` is empty. In every
--- other case, it raises an error for an `itemId` that no item has.
function Inventory.addItems(inventory: Inventory, itemId: string, count: number, intoSlots: { number }?): number
	if count % 1 ~= 0 or count < 0 then
		error(`cannot add {count} items`, 2)
	end
	local slots = intoSlots or Inventory.getSlotNumbers(inventory)
	for _, slot in slots do
		checkSlot(inventory, slot)
	end
	local left = count
	for _, slot in slots do
		if left > 0 and inventory.slots[slot] ~= nil then
			left -= addToSlot(inventory, slot, itemId, left)
		end
	end
	for _, slot in slots do
		if left > 0 and inventory.slots[slot] == nil then
			left -= addToSlot(inventory, slot, itemId, left)
		end
	end
	return count - left
end

--- Adds the items of `stack` to `inventory`, and returns a new `ItemStack` of the items that did
--- not fit, or `nil` if every item went in.
--- - `inventory`: the `Inventory` to add to.
--- - `stack`: the `ItemStack` to add. `addStack` does not change it.
--- - `intoSlots`: a list of slot numbers of `inventory`. The function uses only these slots, in
--- this order. `nil` means every slot, from `1` to `inventory.slotCount`.
---
--- First adds items to each slot in `intoSlots` that holds an `ItemStack` with the same `itemId`,
--- until that `ItemStack` reaches the `stackSize` of its `ItemRegistry.ItemDefinition`. Then puts
--- the items that are left into the slots in `intoSlots` that hold `nil`. Raises an error, and
--- changes nothing, if `hasSlot` returns `false` for a slot in `intoSlots`.
function Inventory.addStack(inventory: Inventory, stack: ItemStack, intoSlots: { number }?): ItemStack?
	local added = Inventory.addItems(inventory, stack.itemId, stack.count, intoSlots)
	if added == stack.count then
		return nil
	end
	return ItemStack.new(stack.itemId, stack.count - added)
end

--- Takes every stack out of the inventory and returns them as a new list, ordered by slot number,
--- lowest first. Every slot then holds nothing.
function Inventory.takeEveryStack(inventory: Inventory): { ItemStack }
	local stacks = {}
	for slot = 1, inventory.slotCount do
		local stack = inventory.slots[slot]
		if stack ~= nil then
			table.insert(stacks, stack)
		end
	end
	table.clear(inventory.slots)
	return stacks
end

--- Returns how many items with the id `itemId` the inventory holds, over all its slots.
function Inventory.countItems(inventory: Inventory, itemId: string): number
	local total = 0
	for _, stack in inventory.slots do
		if stack ~= nil and stack.itemId == itemId then
			total += stack.count
		end
	end
	return total
end

--- Returns the inventory as an `EncodedInventory`, which `decode` reads back.
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

local function unknownField(fields: { [unknown]: unknown }, known: { string }): unknown
	for field in fields do
		if table.find(known, field :: any) == nil then
			return field
		end
	end
	return nil
end

local function addDecodedEntry(inventory: Inventory, index: number, entry: unknown): string?
	if type(entry) ~= "table" then
		return `stacks must be a list with no gaps; entry {index} is a {type(entry)}`
	end
	local fields = entry :: { [unknown]: unknown }
	local extra = unknownField(fields, { "slot", "itemId", "count" })
	if extra ~= nil then
		return `stacks[{index}] has a field it should not have: {extra}`
	end
	local slot = fields.slot
	if not Inventory.hasSlot(inventory, slot) then
		return `stacks[{index}].slot must be from 1 to {inventory.slotCount}; got {slot}`
	end
	if inventory.slots[slot :: number] ~= nil then
		return `stacks[{index}].slot is {slot}, which an earlier entry already used`
	end
	local problem = ItemStack.validate({ itemId = fields.itemId, count = fields.count })
	if problem ~= nil then
		return `stacks[{index}]: {problem}`
	end
	inventory.slots[slot :: number] = ItemStack.new(fields.itemId :: string, fields.count :: number)
	return nil
end

--- Returns a new inventory read from `encoded`, and then `nil`, if `encoded` is what `encode`
--- writes. Otherwise returns `nil`, and then what is wrong with `encoded`, in words. Accepts a
--- value of any type, and never raises an error.
function Inventory.decode(encoded: unknown): (Inventory?, string?)
	if type(encoded) ~= "table" then
		return nil, "an encoded inventory must be a table; got a " .. type(encoded)
	end
	local fields = encoded :: { [unknown]: unknown }
	local extra = unknownField(fields, { "slotCount", "stacks" })
	if extra ~= nil then
		return nil, `an encoded inventory has a field it should not have: {extra}`
	end
	local slotCount, stacks = fields.slotCount, fields.stacks
	if type(slotCount) ~= "number" or slotCount % 1 ~= 0 or slotCount < 1 then
		return nil, `slotCount must be a whole number, 1 or more; got {slotCount}`
	end
	if type(stacks) ~= "table" then
		return nil, "stacks must be a list; got a " .. type(stacks)
	end
	local inventory = Inventory.new(slotCount)
	local entryCount = 0
	for _ in stacks :: { [unknown]: unknown } do
		entryCount += 1
	end
	for index = 1, entryCount do
		local problem = addDecodedEntry(inventory, index, (stacks :: { unknown })[index])
		if problem ~= nil then
			return nil, problem
		end
	end
	return inventory, nil
end

return Inventory
