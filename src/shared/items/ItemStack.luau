--!strict
--- A count of one kind of item, such as 12 logs.
---
--- A stack holds `1` or more items, and never more than its item's `stackSize`. There is no empty
--- stack: where there are no items, there is `nil`. A stack is frozen, and `merge` and `split`
--- return new stacks.
local ItemRegistry = require("./ItemRegistry")

local ItemStack = {}

--- A count of one kind of item.
export type ItemStack = {
	--- The id of the item, such as `"log"`.
	read itemId: string,
	--- How many items the stack holds: a whole number from `1` to the item's `stackSize`.
	read count: number,
}

--- Returns a new frozen stack of `count` items with the id `itemId`. Raises an error if no item has
--- the id `itemId`, or if `count` is not a whole number from `1` to the item's `stackSize`.
function ItemStack.new(itemId: string, count: number): ItemStack
	local stackSize = ItemRegistry.get(itemId).stackSize
	if count % 1 ~= 0 or count < 1 or count > stackSize then
		error(`a stack of "{itemId}" holds 1 to {stackSize}, not {count}`, 2)
	end
	return table.freeze({ itemId = itemId, count = count })
end

--- Returns `nil` if `value` is a table whose `itemId` is the id of a registered item, and whose
--- `count` is a whole number from `1` to that item's `stackSize`. Otherwise returns what is wrong
--- with `value`, in words. Accepts a value of any type, and never raises an error.
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

--- Returns how many more items the stack can hold: its item's `stackSize` minus `count`.
function ItemStack.getSpaceLeft(stack: ItemStack): number
	return ItemRegistry.get(stack.itemId).stackSize - stack.count
end

--- Returns `true` if the stack's `count` equals its item's `stackSize`.
function ItemStack.isFull(stack: ItemStack): boolean
	return ItemStack.getSpaceLeft(stack) == 0
end

--- Returns `true` if `a` and `b` have the same `itemId`. Ignores their `count`.
function ItemStack.isSameItem(a: ItemStack, b: ItemStack): boolean
	return a.itemId == b.itemId
end

--- Adds as many items of `from` as fit to `into`. Returns a new stack that holds the items of
--- `into` and the items that moved, and then a new stack of what is left of `from`, or `nil` if all
--- of `from` moved. Changes neither argument. If `into` and `from` have different `itemId`s, moves
--- nothing and returns `into` and `from` themselves.
function ItemStack.merge(into: ItemStack, from: ItemStack): (ItemStack, ItemStack?)
	if into.itemId ~= from.itemId then
		return into, from
	end
	local moved = math.min(from.count, ItemStack.getSpaceLeft(into))
	local merged = ItemStack.new(into.itemId, into.count + moved)
	if moved == from.count then
		return merged, nil
	end
	return merged, ItemStack.new(from.itemId, from.count - moved)
end

--- Takes `count` items off `stack`. Returns a stack of those items, and then a stack of the items
--- that remain, or `nil` if none remain. Leaves `stack` unchanged. Raises an error if `count` is
--- not a whole number from `1` to the `count` of `stack`.
function ItemStack.split(stack: ItemStack, count: number): (ItemStack, ItemStack?)
	if count == stack.count then
		return stack, nil
	end
	return ItemStack.new(stack.itemId, count), ItemStack.new(stack.itemId, stack.count - count)
end

return ItemStack
