--!strict
--- A number of one kind of item: 12 logs.
---
--- A stack holds at least 1 item and never more than its item's stack size. There is no empty
--- stack: where there is nothing, there is no stack. A stack never changes. `merge` and `split`
--- return new stacks.
local ItemRegistry = require("./ItemRegistry")

local ItemStack = {}

export type ItemStack = {
	--- The id of the item, such as `"log"`.
	read itemId: string,
	--- How many there are.
	read count: number,
}

--- Returns a stack of `count` of the item with the id `itemId`. Fails if no item has that id, or
--- if `count` is not a whole number from 1 to the item's stack size.
function ItemStack.new(itemId: string, count: number): ItemStack
	local stackSize = ItemRegistry.get(itemId).stackSize
	if count % 1 ~= 0 or count < 1 or count > stackSize then
		error(`a stack of "{itemId}" holds 1 to {stackSize}, not {count}`, 2)
	end
	return table.freeze({ itemId = itemId, count = count })
end

--- Returns what is wrong with `value` as a stack, in words, or `nil` if it is a table with the id
--- of an item that exists and a whole `count` from 1 to that item's stack size. `value` may be
--- anything at all, so this is the check for data that arrives from outside the game.
function ItemStack.validate(value: unknown): string?
	if type(value) ~= "table" then
		return "a stack must be a table; got a " .. type(value)
	end
	local itemId, count = (value :: any).itemId, (value :: any).count
	if type(itemId) ~= "string" or not ItemRegistry.has(itemId) then
		return `no item has the id "{itemId}"`
	end
	local stackSize = ItemRegistry.get(itemId).stackSize
	if type(count) ~= "number" or count % 1 ~= 0 or count < 1 or count > stackSize then
		return `a stack of "{itemId}" holds 1 to {stackSize}, not {count}`
	end
	return nil
end

--- Returns how many more items the stack could hold before it is full.
function ItemStack.spaceLeft(stack: ItemStack): number
	return ItemRegistry.get(stack.itemId).stackSize - stack.count
end

--- Returns `true` if the stack holds as many items as its item's stack size.
function ItemStack.isFull(stack: ItemStack): boolean
	return ItemStack.spaceLeft(stack) == 0
end

--- Returns `true` if both stacks are of the same item, whatever their counts.
function ItemStack.isSameItem(a: ItemStack, b: ItemStack): boolean
	return a.itemId == b.itemId
end

--- Moves as many items as fit from `from` into `into`. Returns `into` with those items added, and
--- then what is left of `from`, or `nil` if all of it moved. Stacks of different items do not
--- merge: both come back as they were.
function ItemStack.merge(into: ItemStack, from: ItemStack): (ItemStack, ItemStack?)
	if into.itemId ~= from.itemId then
		return into, from
	end
	local moved = math.min(from.count, ItemStack.spaceLeft(into))
	local merged = ItemStack.new(into.itemId, into.count + moved)
	if moved == from.count then
		return merged, nil
	end
	return merged, ItemStack.new(from.itemId, from.count - moved)
end

--- Takes `count` items off the stack. Returns the stack taken, and then the stack that remains,
--- or `nil` if nothing remains. Fails if `count` is not a whole number from 1 to the stack's count.
function ItemStack.split(stack: ItemStack, count: number): (ItemStack, ItemStack?)
	if count == stack.count then
		return stack, nil
	end
	return ItemStack.new(stack.itemId, count), ItemStack.new(stack.itemId, stack.count - count)
end

return ItemStack
