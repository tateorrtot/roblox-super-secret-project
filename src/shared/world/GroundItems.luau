--!strict
--[=[
	The stacks of items lying on the ground in one running copy of the game.

	Each is a ground item: a stack, the position where it lies, and the time
	it was dropped. Ground items are numbered from 1 in the order they were
	dropped, and a number is never used twice. With 5 logs dropped at time 12,
	the whole thing is

	`{ nextId = 2, byId = { [1] = { stack = <5 logs>, position = { x = 0, y = 0, z = 0 }, droppedAt = 12 } } }`

	and with nothing on the ground `byId` is empty.

	A stack dropped right beside a ground item of the same item joins it, if
	that ground item's stack has room for all of it. So dropping one log at a
	time in one spot makes one ground item, not a heap of them.

	Three things happen to a ground item:
	- A player who comes within `GroundItems.PICKUP_RADIUS` of it picks it up,
	  as far as their inventory has room. See [method pickUpNear].
	- For its first `GroundItems.PICKUP_DELAY` seconds it cannot be picked up,
	  so that a player who drops something does not take it straight back.
	- After `GroundItems.LIFETIME` seconds on the ground it is gone. See
	  [method expire].

	Time is a number of seconds, passed in as `now`. It may come from any
	clock that only goes forward, as long as every call uses the same clock.
	Positions and distances are in studs.

	Ground items are never saved. They belong to a running game, not to a
	player.

	This is the rules only. It draws nothing: code that shows the ground items
	reads `byId`.

	```lua
	local ground = GroundItems.new()
	GroundItems.drop(ground, ItemStack.new("log", 5), { x = 10, y = 0, z = 0 }, 12) --> 1, the id of the new ground item
	GroundItems.pickUpNear(ground, { x = 9, y = 0, z = 0 }, pack, 12) --> 0: it was only just dropped
	GroundItems.pickUpNear(ground, { x = 9, y = 0, z = 0 }, pack, 20) --> 5: the logs are in the pack now
	```
]=]
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")

local GroundItems = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory

--- A point in the world, in studs. `y` is height.
export type Position = { read x: number, read y: number, read z: number }

--- One stack lying on the ground. It is a value and never changes: when part of it is picked up,
--- a new ground item with the smaller stack takes its place under the same id.
export type GroundItem = {
	read stack: ItemStack,
	--- Where it lies.
	read position: Position,
	--- The time it was dropped, in seconds.
	read droppedAt: number,
}

--- `read` means code outside this module cannot assign the field. Change the ground items with the functions below.
export type GroundItems = {
	--- The id the next ground item will get.
	read nextId: number,
	--- Every ground item, by id. An id with no entry is not on the ground.
	--- The table has gaps, so use `for id, groundItem in groundItems.byId`, not `#` or `ipairs`.
	read byId: { read [number]: GroundItem },
}

--- How long a ground item lies before [method expire] removes it, in seconds: five minutes.
GroundItems.LIFETIME = 300

--- How long after it was dropped a ground item cannot be picked up, in seconds.
GroundItems.PICKUP_DELAY = 1.5

--- How near a position must be to a ground item for [method pickUpNear] to pick it up, in studs.
GroundItems.PICKUP_RADIUS = 4

--- How near a stack must be dropped to a ground item of the same item to join it, in studs.
GroundItems.MERGE_RADIUS = 1.5

type NearGroundItem = { id: number, distance: number }

-- True for a number that is not infinite and not NaN.
local function isOrdinaryNumber(value: unknown): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function writableById(groundItems: GroundItems): { [number]: GroundItem }
	return groundItems.byId :: any
end

-- Raises `problem` as an error that names the public function and blames the code that called it.
local function failIf(problem: string?, functionName: string)
	if problem ~= nil then
		error(functionName .. ": " .. problem, 3)
	end
end

local function positionProblem(position: Position): string?
	if type(position) ~= "table" then
		return "a position is a table with x, y and z, not a " .. type(position)
	end
	for _, axis in { "x", "y", "z" } do
		local value = (position :: any)[axis]
		if not isOrdinaryNumber(value) then
			return string.format("position.%s must be a number; got %s", axis, tostring(value))
		end
	end
	return nil
end

local function timeProblem(now: number): string?
	if isOrdinaryNumber(now) then
		return nil
	end
	return string.format("now must be a number of seconds; got %s", tostring(now))
end

local function distanceBetween(a: Position, b: Position): number
	return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2)
end

--[=[
	Returns a new set of ground items with nothing on the ground.
]=]
function GroundItems.new(): GroundItems
	return { nextId = 1, byId = {} }
end

--[=[
	Puts `stack` on the ground at `position`, dropped at the time `now`, and
	returns the id of the ground item that holds it.

	If a ground item of the same item lies within `GroundItems.MERGE_RADIUS`
	of `position`, and its stack has room for all of `stack`, the stack joins
	it: that ground item holds more, stays where it lies, and counts as
	dropped at `now`. With several such ground items it joins the nearest,
	and of two equally near, the one with the lower id. Otherwise a new ground
	item is made at `position`.

	The stack is now on the ground: the caller must not also keep it somewhere
	else, or the items are doubled.

	Raises an error if `stack` is not a stack that `ItemStack.new` could have
	made, if `position` is not a table of three numbers `x`, `y` and `z`, or
	if `now` is not a number.
]=]
function GroundItems.drop(groundItems: GroundItems, stack: ItemStack, position: Position, now: number): number
	failIf(ItemStack.validate(stack), "GroundItems.drop")
	failIf(positionProblem(position), "GroundItems.drop")
	failIf(timeProblem(now), "GroundItems.drop")
	local byId = writableById(groundItems)

	local joinedId: number? = nil
	local joinedDistance = math.huge
	for id, groundItem in byId do
		if ItemStack.isSameItem(groundItem.stack, stack) and ItemStack.spaceLeft(groundItem.stack) >= stack.count then
			local distance = distanceBetween(position, groundItem.position)
			local isNearer = distance < joinedDistance
				or (distance == joinedDistance and joinedId ~= nil and id < joinedId)
			if distance <= GroundItems.MERGE_RADIUS and isNearer then
				joinedId = id
				joinedDistance = distance
			end
		end
	end
	if joinedId ~= nil then
		local joined = byId[joinedId]
		byId[joinedId] = table.freeze({
			stack = ItemStack.new(stack.itemId, joined.stack.count + stack.count),
			position = joined.position,
			droppedAt = now,
		})
		return joinedId
	end

	local id = groundItems.nextId
	byId[id] = table.freeze({
		stack = ItemStack.new(stack.itemId, stack.count),
		position = table.freeze({ x = position.x, y = position.y, z = position.z }),
		droppedAt = now,
	})
	local writable = groundItems :: any
	writable.nextId = id + 1
	return id
end

--[=[
	Moves the ground items near `position` into `inventory`, as far as they
	fit, and returns how many items moved. This is a player walking over
	what lies on the ground.

	A ground item is near if it lies within `GroundItems.PICKUP_RADIUS` of
	`position`, measured in a straight line, and was dropped at least
	`GroundItems.PICKUP_DELAY` seconds before `now`. The nearest is picked up
	first, and of two equally near, the one with the lower id.

	Items go into the inventory as `Inventory.addItems` puts them. When only
	part of a ground item fits, the rest stays on the ground where it was,
	under the same id and no younger. Returns 0 if nothing is near or nothing
	fits.

	Raises an error if `position` is not a table of three numbers `x`, `y`
	and `z`, or if `now` is not a number.
]=]
function GroundItems.pickUpNear(groundItems: GroundItems, position: Position, inventory: Inventory, now: number): number
	failIf(positionProblem(position), "GroundItems.pickUpNear")
	failIf(timeProblem(now), "GroundItems.pickUpNear")
	local byId = writableById(groundItems)
	local near: { NearGroundItem } = {}
	for id, groundItem in byId do
		if now - groundItem.droppedAt >= GroundItems.PICKUP_DELAY then
			local distance = distanceBetween(position, groundItem.position)
			if distance <= GroundItems.PICKUP_RADIUS then
				table.insert(near, { id = id, distance = distance })
			end
		end
	end
	table.sort(near, function(a: NearGroundItem, b: NearGroundItem): boolean
		return a.distance < b.distance or (a.distance == b.distance and a.id < b.id)
	end)

	local moved = 0
	for _, entry in near do
		local groundItem = byId[entry.id]
		local stack = groundItem.stack
		local added = Inventory.addItems(inventory, stack.itemId, stack.count)
		if added == stack.count then
			byId[entry.id] = nil
		elseif added > 0 then
			byId[entry.id] = table.freeze({
				stack = ItemStack.new(stack.itemId, stack.count - added),
				position = groundItem.position,
				droppedAt = groundItem.droppedAt,
			})
		end
		moved += added
	end
	return moved
end

--[=[
	Removes every ground item that was dropped `GroundItems.LIFETIME` seconds
	or more before `now`. Their items are gone for good.

	Raises an error if `now` is not a number.
]=]
function GroundItems.expire(groundItems: GroundItems, now: number)
	failIf(timeProblem(now), "GroundItems.expire")
	local byId = writableById(groundItems)
	for id, groundItem in byId do
		if now - groundItem.droppedAt >= GroundItems.LIFETIME then
			byId[id] = nil
		end
	end
end

return GroundItems
