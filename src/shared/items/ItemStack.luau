--!strict
--[=[
	Some number of one item: 12 logs.

	A stack is what one inventory slot holds, and what lies on the ground when
	items are dropped. It holds at least 1 item and never more than the stack
	size of its item.

	There is no empty stack. Where there is nothing, there is no stack: a
	variable that may have no stack in it holds `nil`.

	A stack is a value and never changes. A function that splits or merges
	stacks returns new stacks and leaves the ones it was given as they were.

	```lua
	local logs = ItemStack.new("log", 12)
	logs.itemId --> "log"
	logs.count --> 12

	local taken, rest = ItemStack.split(logs, 5) -- taken is 5 logs, rest is 7 logs
	```
]=]
local ItemRegistry = require("./ItemRegistry")

local ItemStack = {}

--- `read` means code outside this module cannot assign the field, and nothing inside it does
--- either: a stack never changes.
export type ItemStack = {
	--- The id of its item, such as `"log"`. `ItemRegistry.get` returns that item's definition.
	read itemId: string,
	--- How many there are: a whole number from 1 up to the stack size of the item.
	read count: number,
}

local function isWholeNumber(value: unknown): boolean
	return type(value) == "number" and value == math.floor(value) and value ~= math.huge and value ~= -math.huge
end

-- Returns what is wrong with `value` as a stack, or nil if it is one that `ItemStack.new` could have made.
local function stackProblem(value: unknown): string?
	if type(value) ~= "table" then
		return "a stack is a table, not a " .. type(value)
	end
	local stack = (value :: any) :: ItemStack
	if type(stack.itemId) ~= "string" or not ItemRegistry.has(stack.itemId) then
		return string.format('no item has the id "%s"', tostring(stack.itemId))
	end
	local stackSize = ItemRegistry.get(stack.itemId).stackSize
	if isWholeNumber(stack.count) and stack.count >= 1 and stack.count <= stackSize then
		return nil
	end
	return string.format('a stack of "%s" holds 1 to %d, not %s', stack.itemId, stackSize, tostring(stack.count))
end

--[=[
	Returns a stack of `count` of the item with the id `itemId`.

	Raises an error if no item has that id, or if `count` is not a whole
	number from 1 up to that item's stack size.
]=]
function ItemStack.new(itemId: string, count: number): ItemStack
	local stack = { itemId = itemId, count = count }
	local problem = stackProblem(stack)
	if problem ~= nil then
		error("ItemStack.new: " .. problem, 2)
	end
	return table.freeze(stack)
end

--[=[
	Returns what is wrong with `value` as a stack, in words, or `nil` if
	nothing is: it is a table with the `itemId` of an item that exists and a
	`count` that is a whole number from 1 up to that item's stack size.

	`value` may be anything at all. This is the check for a stack that was
	written out by hand or arrived from outside, before it is trusted.

	```lua
	ItemStack.validate({ itemId = "log", count = 40 }) --> 'a stack of "log" holds 1 to 16, not 40'
	ItemStack.validate(ItemStack.new("log", 12)) --> nil
	```
]=]
function ItemStack.validate(value: unknown): string?
	return stackProblem(value)
end

--[=[
	Returns how many more items `stack` could hold before it reaches the stack
	size of its item. 0 when it is full.
]=]
function ItemStack.spaceLeft(stack: ItemStack): number
	return ItemRegistry.get(stack.itemId).stackSize - stack.count
end

--[=[
	Returns `true` if `stack` holds as many items as the stack size of its item.
]=]
function ItemStack.isFull(stack: ItemStack): boolean
	return ItemStack.spaceLeft(stack) == 0
end

--[=[
	Returns `true` if `a` and `b` are stacks of the same item, whatever their counts.
]=]
function ItemStack.isSameItem(a: ItemStack, b: ItemStack): boolean
	return a.itemId == b.itemId
end

--[=[
	Returns `true` if `a` and `b` are the same item and the same count.
]=]
function ItemStack.equals(a: ItemStack, b: ItemStack): boolean
	return a.itemId == b.itemId and a.count == b.count
end

--[=[
	Moves as many items as fit from `from` into `into`.

	Returns two stacks. The first is `into` with the moved items added. The
	second is what is left of `from`, or `nil` if all of it moved. Together
	they hold exactly the items the two given stacks held.

	Stacks of different items do not merge: nothing moves, and both come back
	as they were.
]=]
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

--[=[
	Takes `count` items off `stack`.

	Returns two stacks. The first is the `count` items taken. The second is
	what remains, or `nil` if nothing remains.

	Raises an error if `count` is not a whole number from 1 up to the count of `stack`.
]=]
function ItemStack.split(stack: ItemStack, count: number): (ItemStack, ItemStack?)
	if not isWholeNumber(count) or count < 1 or count > stack.count then
		error(
			string.format(
				'ItemStack.split: can take 1 to %d from this stack of "%s", not %s',
				stack.count,
				stack.itemId,
				tostring(count)
			),
			2
		)
	end
	if count == stack.count then
		return stack, nil
	end
	return ItemStack.new(stack.itemId, count), ItemStack.new(stack.itemId, stack.count - count)
end

return ItemStack
