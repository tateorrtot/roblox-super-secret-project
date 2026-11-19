--!strict
--[=[
	One player's open inventory screen, as far as the rules go: which
	inventories it shows, the stack being carried between slots, and what
	each action on a slot does.

	The player's own pack is always shown. A second inventory, such as a
	crate, is shown beside it when one is open. When a player has no screen
	open they have no session at all.

	The other inventory may have slots that take only some items, as a
	stove's fuel slot takes only what burns, and the slot its cooking comes
	out of takes nothing. A session is told so with slot rules when it is
	opened. The rules stop a player putting the wrong thing into a slot; they
	never stop one taking a thing out. [method canPut] asks.

	A session may be told how many of the pack's first slots are its hotbar.
	That is only for [method quickMove], which sends a stack between the
	hotbar and the rest of the pack when the pack is open alone.

	The stack being carried is `session.carried`, or `nil` when nothing is
	carried. It belongs to the session, not to either inventory.

	The actions are named for what they do. [method pickUp] takes items out
	of a slot and carries them. [method putDown] puts carried items into a
	slot. [method swap] exchanges the carried stack with a slot's.
	[method quickMove] sends a slot's stack straight to the other inventory.
	[method swapWithHotbar] exchanges a slot's stack with a hotbar slot's.
	[method gather] fills the carried stack from every slot that holds its kind.
	[method spread] puts the carried stack down across several slots.
	[method drop] hands carried items to the caller, to go on the ground.
	A touch screen calls these directly, as Minecraft does on phones.
	[method click] turns a Minecraft left or right mouse click into them,
	[method doubleClick] the second click of a double click, and
	[method drag] a drag across several slots with a button held.

	[method pickUp], [method putDown], [method quickMove], [method gather] and
	[method spread] return how many items they moved. [method swap],
	[method click], [method doubleClick] and [method drag] return `true` if
	anything changed. No action makes or loses an item: what does not fit
	stays where it was. [method drop] and [method close] return a stack that
	is no longer in the session, and the caller must put it on the ground.

	An action changes the session and the inventories it is given. Naming a
	slot that does not exist, or the other inventory when none is open, is a
	mistake in the calling code and raises an error. Code acting on a request
	from somewhere it does not trust, such as a player's own machine, asks
	[method hasSlot] first, or [method hasSlots] for a list of slots.

	This is the rules only. It draws nothing and reads no input.

	```lua
	local session = InventorySession.open(pack, crate)
	InventorySession.pickUp(session, "pack", 1) -- carries what slot 1 of the pack held
	session.carried --> that stack
	InventorySession.putDown(session, "other", 5) -- puts it in slot 5 of the crate
	session.carried --> nil, or what did not fit
	InventorySession.close(session) --> nil, or a stack to put on the ground
	```
]=]
local Inventory = require("./Inventory")
local ItemStack = require("../items/ItemStack")

local InventorySession = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory

--- Which of the session's two inventories is meant: `"pack"` is the player's own, and `"other"` is
--- the second one that is open, such as a crate's.
export type Side = "pack" | "other"

--- A mouse button, for [method click] and [method drag].
export type Button = "left" | "right"

--- One slot of the screen: which of the two inventories it is in, and its slot number there.
export type ScreenSlot = { read side: Side, read slot: number }

--- Which items each slot of an inventory takes, by slot number. A slot with no entry takes any
--- item. A slot with an entry takes only the items whose ids are in it, and nothing at all if it
--- is empty: `{ [2] = { log = true }, [3] = {} }` leaves slot 1 open to anything.
export type SlotRules = { read [number]: { read [string]: boolean } }

--- `read` means code outside this module cannot assign the field. The actions below change `carried`.
export type InventorySession = {
	--- The player's own inventory.
	read pack: Inventory,
	--- The second inventory that is open, such as a crate's, or `nil` when the pack is open alone.
	read other: Inventory?,
	--- The stack being carried between slots, or `nil` when nothing is carried.
	read carried: ItemStack?,
	--- How many of the pack's slots, counting from slot 1, are its hotbar. `nil` if the session was not told.
	read hotbarSlotCount: number?,
	--- Which items each slot of the other inventory takes, or `nil` if every slot takes anything.
	read otherSlotRules: SlotRules?,
}

local function isWholeNumber(value: unknown): boolean
	return type(value) == "number" and value == math.floor(value) and value ~= math.huge and value ~= -math.huge
end

local function carry(session: InventorySession, stack: ItemStack?)
	(session :: any).carried = stack
end

-- Raises `problem` as an error that names the public function and blames the code that called it.
local function failIf(problem: string?, functionName: string)
	if problem ~= nil then
		error(functionName .. ": " .. problem, 3)
	end
end

local function slotProblem(session: InventorySession, side: Side, slot: number): string?
	if side ~= "pack" and side ~= "other" then
		return string.format('side must be "pack" or "other"; got %s', tostring(side))
	end
	local inventory = if side == "pack" then session.pack else session.other
	if inventory == nil then
		return 'side is "other", but this session has no other inventory open'
	end
	if isWholeNumber(slot) and slot >= 1 and slot <= inventory.slotCount then
		return nil
	end
	return string.format(
		"slot %s is out of range; that inventory has slots 1 to %d",
		tostring(slot),
		inventory.slotCount
	)
end

local function countProblem(count: number?): string?
	if count == nil or (isWholeNumber(count) and count >= 0) then
		return nil
	end
	return string.format("count must be a whole number, 0 or more; got %s", tostring(count))
end

-- Returns what is wrong with `screenSlots` as a list of slots this session shows, or nil if nothing is.
local function screenSlotsProblem(session: InventorySession, screenSlots: unknown): string?
	if type(screenSlots) ~= "table" then
		return string.format("screenSlots must be a list of slots; got %s", tostring(screenSlots))
	end
	local list = screenSlots :: { unknown }
	local entries = 0
	for _ in list do
		entries += 1
		if entries > #list then
			return "screenSlots must be a list of slots, numbered from 1; this table has other keys"
		end
	end
	for index = 1, #list do
		local screenSlot = list[index]
		if type(screenSlot) ~= "table" then
			return string.format(
				"screenSlots[%d] must be a table with a side and a slot; got %s",
				index,
				tostring(screenSlot)
			)
		end
		local named = screenSlot :: { side: Side, slot: number }
		local problem = slotProblem(session, named.side, named.slot)
		if problem ~= nil then
			return string.format("screenSlots[%d]: %s", index, problem)
		end
	end
	return nil
end

-- True if the slot takes the item. Every slot of the pack takes anything, and so does a slot of the
-- other inventory unless the session's slot rules have an entry for it that leaves the item out.
local function takes(session: InventorySession, side: Side, slot: number, itemId: string): boolean
	local rules = session.otherSlotRules
	if side == "pack" or rules == nil then
		return true
	end
	local taken = rules[slot]
	return taken == nil or taken[itemId] == true
end

local function inventoryOn(session: InventorySession, side: Side): Inventory
	return if side == "pack" then session.pack else session.other :: Inventory
end

-- Adds a stack to the other inventory, using only the slots that take its item: stacks of the same
-- item are topped up first, then slots that hold nothing are filled. Returns the stack of what did
-- not fit, or nil.
local function addToOther(session: InventorySession, other: Inventory, stack: ItemStack): ItemStack?
	local left: ItemStack? = stack
	for _, toppingUp in { true, false } do
		for slot = 1, other.slotCount do
			if left == nil then
				return nil
			end
			local holdsSomething = Inventory.getStack(other, slot) ~= nil
			if holdsSomething == toppingUp and takes(session, "other", slot, left.itemId) then
				left = Inventory.putInSlot(other, slot, left)
			end
		end
	end
	return left
end

--[=[
	Returns a new session over `pack`, and over `other` as well if one is
	given, with nothing carried.

	The session holds the inventories it is given, not copies of them.
	`hotbarSlotCount` says how many of the pack's first slots are its hotbar,
	and may be left out. `otherSlotRules` says which items each slot of the
	other inventory takes, and may be left out if every slot takes anything.

	Raises an error if `hotbarSlotCount` is given and is not a whole number
	from 1 to the number of slots the pack has.
]=]
function InventorySession.open(
	pack: Inventory,
	other: Inventory?,
	hotbarSlotCount: number?,
	otherSlotRules: SlotRules?
): InventorySession
	if hotbarSlotCount ~= nil then
		if not isWholeNumber(hotbarSlotCount) or hotbarSlotCount < 1 or hotbarSlotCount > pack.slotCount then
			error(
				string.format(
					"InventorySession.open: hotbarSlotCount must be a whole number from 1 to %d, the number of slots the pack has; got %s",
					pack.slotCount,
					tostring(hotbarSlotCount)
				),
				2
			)
		end
	end
	return { pack = pack, other = other, hotbarSlotCount = hotbarSlotCount, otherSlotRules = otherSlotRules }
end

--[=[
	Returns `true` if a slot takes the item with the id `itemId`: whether a
	stack of it may be put there, leaving aside whether there is room.

	Every slot of the pack takes any item. A slot of the other inventory takes
	any item unless the session was opened with slot rules that say otherwise.

	Raises an error if `slot` is not one of that inventory's slots, or if
	`side` is `"other"` and no other inventory is open.
]=]
function InventorySession.canPut(session: InventorySession, side: Side, slot: number, itemId: string): boolean
	failIf(slotProblem(session, side, slot), "InventorySession.canPut")
	return takes(session, side, slot, itemId)
end

--[=[
	Returns `true` if `side` and `slot` name a slot this session shows: `side`
	is `"pack"`, or `"other"` when another inventory is open, and `slot` is
	one of that inventory's slot numbers.

	`side` and `slot` may be any values at all, and nothing raises an error.
	An action given a side and slot that pass this check will not refuse them.
]=]
function InventorySession.hasSlot(session: InventorySession, side: unknown, slot: unknown): boolean
	return slotProblem(session, side :: any, slot :: any) == nil
end

--[=[
	Returns `true` if `screenSlots` is a list of slots this session shows:
	a list of tables, each with a `side` and a `slot` that [method hasSlot]
	would say yes to. A list of none is one.

	`screenSlots` may be any value at all, and nothing raises an error.
	[method spread] and [method drag] will not refuse a list that passes this
	check.
]=]
function InventorySession.hasSlots(session: InventorySession, screenSlots: unknown): boolean
	return screenSlotsProblem(session, screenSlots) == nil
end

--[=[
	Picks up to `count` items up out of a slot, and returns how many were picked up.

	Leaving out `count` picks up the whole stack. With nothing carried, the
	items become the carried stack. When the same item is already carried,
	they are added to it, up to that item's stack size. Returns 0, and changes
	nothing, if the slot holds nothing or a different item is carried.

	Raises an error if `slot` is not one of that inventory's slots, if `side`
	is `"other"` and no other inventory is open, or if `count` is not a whole
	number of 0 or more.
]=]
function InventorySession.pickUp(session: InventorySession, side: Side, slot: number, count: number?): number
	failIf(slotProblem(session, side, slot), "InventorySession.pickUp")
	failIf(countProblem(count), "InventorySession.pickUp")
	local inventory = inventoryOn(session, side)
	local there = Inventory.getStack(inventory, slot)
	local carried = session.carried
	if there == nil or (carried ~= nil and not ItemStack.isSameItem(carried, there)) then
		return 0
	end
	local room = if carried then ItemStack.spaceLeft(carried) else there.count
	local taken = Inventory.takeFromSlot(inventory, slot, math.min(count or there.count, room))
	if taken == nil then
		return 0
	end
	carry(session, if carried then (ItemStack.merge(carried, taken)) else taken)
	return taken.count
end

--[=[
	Puts up to `count` of the carried items down into a slot, and returns how
	many were put down.

	Leaving out `count` puts down the whole carried stack. A slot that holds
	nothing takes them. A slot holding the same item is topped up to that
	item's stack size. What does not fit stays carried. Returns 0, and changes
	nothing, if nothing is carried, if the slot holds a different item, if
	the slot is full, or if the slot does not take the carried item.

	Raises an error if `slot` is not one of that inventory's slots, if `side`
	is `"other"` and no other inventory is open, or if `count` is not a whole
	number of 0 or more.
]=]
function InventorySession.putDown(session: InventorySession, side: Side, slot: number, count: number?): number
	failIf(slotProblem(session, side, slot), "InventorySession.putDown")
	failIf(countProblem(count), "InventorySession.putDown")
	local carried = session.carried
	if carried == nil or not takes(session, side, slot, carried.itemId) then
		return 0
	end
	local amount = math.min(count or carried.count, carried.count)
	if amount == 0 then
		return 0
	end
	local offered, kept = ItemStack.split(carried, amount)
	local leftover = Inventory.putInSlot(inventoryOn(session, side), slot, offered)
	local stillCarried = (if kept then kept.count else 0) + (if leftover then leftover.count else 0)
	carry(session, if stillCarried > 0 then ItemStack.new(carried.itemId, stillCarried) else nil)
	return amount - (if leftover then leftover.count else 0)
end

--[=[
	Exchanges the carried stack with the stack in a slot, and returns `true`
	if anything changed. Either may be nothing: swapping with a slot that
	holds nothing puts the carried stack down, and swapping while carrying
	nothing picks the slot's stack up.

	Returns `false`, and changes nothing, if the slot does not take the
	carried item, or if nothing is carried and the slot holds nothing.

	Raises an error if `slot` is not one of that inventory's slots, or if
	`side` is `"other"` and no other inventory is open.
]=]
function InventorySession.swap(session: InventorySession, side: Side, slot: number): boolean
	failIf(slotProblem(session, side, slot), "InventorySession.swap")
	local inventory = inventoryOn(session, side)
	local there = Inventory.getStack(inventory, slot)
	local carried = session.carried
	if carried ~= nil and not takes(session, side, slot, carried.itemId) then
		return false
	end
	Inventory.setStack(inventory, slot, carried)
	carry(session, there)
	return there ~= nil or carried ~= nil
end

--[=[
	Exchanges the stack in a slot with the stack in a hotbar slot of the pack.
	Either may be nothing. This is Minecraft's number key pressed over a slot:
	what the pointer is over goes to that hotbar slot, and what was there
	comes back. The carried stack is not involved. Naming the hotbar slot
	itself as the slot changes nothing, and nor does a slot that does not
	take the item in the hotbar slot.

	Raises an error if `slot` is not one of that inventory's slots, if `side`
	is `"other"` and no other inventory is open, if the session was not told
	how many slots the hotbar has, or if `hotbarSlot` is not a whole number
	from 1 to that many.
]=]
function InventorySession.swapWithHotbar(session: InventorySession, side: Side, slot: number, hotbarSlot: number)
	failIf(slotProblem(session, side, slot), "InventorySession.swapWithHotbar")
	local hotbarSlotCount = session.hotbarSlotCount
	if hotbarSlotCount == nil then
		error("InventorySession.swapWithHotbar: this session was not told how many slots the hotbar has", 2)
	end
	if not isWholeNumber(hotbarSlot) or hotbarSlot < 1 or hotbarSlot > hotbarSlotCount then
		error(
			string.format(
				"InventorySession.swapWithHotbar: hotbarSlot %s is out of range; the hotbar has slots 1 to %d",
				tostring(hotbarSlot),
				hotbarSlotCount
			),
			2
		)
	end
	local inventory = inventoryOn(session, side)
	local there = Inventory.getStack(inventory, slot)
	local inHotbar = Inventory.getStack(session.pack, hotbarSlot)
	if inHotbar ~= nil and not takes(session, side, slot, inHotbar.itemId) then
		return
	end
	Inventory.setStack(inventory, slot, inHotbar)
	Inventory.setStack(session.pack, hotbarSlot, there)
end

--[=[
	Does what a Minecraft mouse click on a slot does, and returns `true` if
	anything changed.

	With nothing carried:
	- a left click picks up the whole stack in the slot;
	- a right click picks up half of it. From an odd count the larger half is
	  picked up, so 5 gives 3 carried and 2 left;
	- either click on a slot that holds nothing does nothing.

	With a stack carried:
	- a left click puts the whole stack down, and what does not fit stays carried;
	- a right click puts one item down;
	- either click on a slot holding a different item swaps the two stacks;
	- either click on a full stack of the same item does nothing;
	- either click on a slot that does not take the carried item does nothing.

	Raises an error if `slot` is not one of that inventory's slots, if `side`
	is `"other"` and no other inventory is open, or if `button` is not
	`"left"` or `"right"`.
]=]
function InventorySession.click(session: InventorySession, side: Side, slot: number, button: Button): boolean
	failIf(slotProblem(session, side, slot), "InventorySession.click")
	if button ~= "left" and button ~= "right" then
		error(string.format('InventorySession.click: button must be "left" or "right"; got %s', tostring(button)), 2)
	end
	local carried = session.carried
	local there = Inventory.getStack(inventoryOn(session, side), slot)
	if carried == nil then
		if there == nil then
			return false
		end
		InventorySession.pickUp(
			session,
			side,
			slot,
			if button == "left" then there.count else math.ceil(there.count / 2)
		)
		return true
	end
	if there == nil or ItemStack.isSameItem(there, carried) then
		return InventorySession.putDown(session, side, slot, if button == "left" then carried.count else 1) > 0
	end
	return InventorySession.swap(session, side, slot)
end

--[=[
	Fills the carried stack with items of its kind taken from the slots of
	the screen, until it is a full stack, and returns how many were gathered.

	Stacks that are not full are taken from first, so that odd lots are
	tidied away before a full stack is broken into. Within each, the other
	inventory's slots come before the pack's, lowest slot first.

	Returns 0, and changes nothing, if nothing is carried, if the carried
	stack is already full, or if no slot holds its kind.
]=]
function InventorySession.gather(session: InventorySession): number
	local carried = session.carried
	if carried == nil then
		return 0
	end
	local stackSize = carried.count + ItemStack.spaceLeft(carried)
	local wanted = ItemStack.spaceLeft(carried)
	local inventories = { session.other, session.pack } :: { Inventory? }
	for _, fullStacks in { false, true } do
		for index = 1, 2 do
			local inventory = inventories[index]
			if inventory ~= nil then
				for slot = 1, inventory.slotCount do
					local there = Inventory.getStack(inventory, slot)
					local isWanted = there ~= nil
						and ItemStack.isSameItem(there, carried)
						and (there.count == stackSize) == fullStacks
					if isWanted and wanted > 0 then
						local taken = Inventory.takeFromSlot(inventory, slot, wanted) :: ItemStack
						wanted -= taken.count
					end
				end
			end
		end
	end
	local gathered = ItemStack.spaceLeft(carried) - wanted
	if gathered > 0 then
		carry(session, ItemStack.new(carried.itemId, carried.count + gathered))
	end
	return gathered
end

--[=[
	Does what the second click of a Minecraft double left click on a slot
	does, and returns `true` if anything changed.

	If a stack is carried and the slot holds nothing, as when the first click
	has just picked the slot's stack up, it gathers: the carried stack is
	filled from every slot that holds its kind, as [method gather] does.
	Otherwise it is an ordinary left click, as [method click] does.

	Raises an error if `slot` is not one of that inventory's slots, or if
	`side` is `"other"` and no other inventory is open.
]=]
function InventorySession.doubleClick(session: InventorySession, side: Side, slot: number): boolean
	failIf(slotProblem(session, side, slot), "InventorySession.doubleClick")
	if session.carried ~= nil and Inventory.getStack(inventoryOn(session, side), slot) == nil then
		return InventorySession.gather(session) > 0
	end
	return InventorySession.click(session, side, slot, "left")
end

-- Returns the slots among `screenSlots` that a spread of the `carried` stack takes in, in the order
-- they are named: those that hold nothing or hold the carried item, and that take it. A slot named
-- twice counts once, and no more slots take part than there are items carried.
local function slotsToSpreadOver(
	session: InventorySession,
	carried: ItemStack,
	screenSlots: { ScreenSlot }
): { ScreenSlot }
	local takingPart: { ScreenSlot } = {}
	local isTakingPart: { [string]: boolean } = {}
	for index = 1, #screenSlots do
		local screenSlot = screenSlots[index]
		local name = screenSlot.side .. screenSlot.slot
		local there = Inventory.getStack(inventoryOn(session, screenSlot.side), screenSlot.slot)
		if
			#takingPart < carried.count
			and not isTakingPart[name]
			and (there == nil or ItemStack.isSameItem(there, carried))
			and takes(session, screenSlot.side, screenSlot.slot, carried.itemId)
		then
			isTakingPart[name] = true
			table.insert(takingPart, screenSlot)
		end
	end
	return takingPart
end

--[=[
	Puts the carried stack down across several slots, and returns how many
	items were put down. This is what dragging a carried stack across slots
	does in Minecraft.

	Each slot gets an equal share: the carried count divided by the number of
	slots taking part, rounded down. If `count` is given, each slot gets
	`count` items instead, for as long as the carried stack lasts. A slot
	takes only as much as it has room for. What is not put down stays carried.

	The slots that take part are those that hold nothing or hold the carried
	item, and that take it. The others are passed over, and a slot named twice
	counts once. No more slots take part than there are items carried: the
	first ones named do. A full stack of the carried item takes part, and
	gets nothing.

	Returns 0, and changes nothing, if nothing is carried or no slot takes part.

	Raises an error if `screenSlots` is not a list of slots this session
	shows, or if `count` is not a whole number of 0 or more.

	```lua
	-- Carrying 7 logs:
	InventorySession.spread(session, { { side = "pack", slot = 1 }, { side = "pack", slot = 2 } }) --> 6
	-- Each of the two slots got 3, and 1 log is still carried.
	```
]=]
function InventorySession.spread(session: InventorySession, screenSlots: { ScreenSlot }, count: number?): number
	failIf(screenSlotsProblem(session, screenSlots), "InventorySession.spread")
	failIf(countProblem(count), "InventorySession.spread")
	local carried = session.carried
	if carried == nil then
		return 0
	end
	local takingPart = slotsToSpreadOver(session, carried, screenSlots)
	if #takingPart == 0 then
		return 0
	end
	local each = count or math.floor(carried.count / #takingPart)
	local moved = 0
	for _, screenSlot in takingPart do
		moved += InventorySession.putDown(session, screenSlot.side, screenSlot.slot, each)
	end
	return moved
end

--[=[
	Does what dragging the mouse across slots with a button held does in
	Minecraft, and returns `true` if anything changed.

	With a stack carried, a left drag spreads it across the slots in equal
	shares, and a right drag puts one item in each, as [method spread] does.
	With nothing carried it does nothing.

	Raises an error if `screenSlots` is not a list of slots this session
	shows, or if `button` is not `"left"` or `"right"`.
]=]
function InventorySession.drag(session: InventorySession, screenSlots: { ScreenSlot }, button: Button): boolean
	failIf(screenSlotsProblem(session, screenSlots), "InventorySession.drag")
	if button ~= "left" and button ~= "right" then
		error(string.format('InventorySession.drag: button must be "left" or "right"; got %s', tostring(button)), 2)
	end
	return InventorySession.spread(session, screenSlots, if button == "left" then nil else 1) > 0
end

--[=[
	Sends the stack in a slot straight to the other side, wherever it fits
	there, and returns how many items moved. This is Minecraft's shift-click.

	With another inventory open, a stack in the pack goes to the other
	inventory, and a stack in the other inventory goes to the pack. With the
	pack open alone, a stack in a hotbar slot goes to the rest of the pack,
	and a stack in the rest of the pack goes to the hotbar.

	Stacks of the same item are topped up first, then slots that hold nothing
	are filled. Only slots that take the item are used, so a stack sent to a
	stove lands in the slot meant for it. What does not fit stays in its slot.
	The carried stack is not involved.

	Returns 0 if the slot holds nothing. With the pack open alone it also
	returns 0 if the session was not told the hotbar's size, or if the hotbar
	is the whole pack, since there is then nowhere to send the stack.

	Raises an error if `slot` is not one of that inventory's slots, or if
	`side` is `"other"` and no other inventory is open.
]=]
function InventorySession.quickMove(session: InventorySession, side: Side, slot: number): number
	failIf(slotProblem(session, side, slot), "InventorySession.quickMove")
	local from = inventoryOn(session, side)
	local across = if side == "pack" then session.other else session.pack
	local to = from
	local firstSlot: number?, lastSlot: number? = nil, nil
	if across ~= nil then
		to = across
	else
		local hotbarSlotCount = session.hotbarSlotCount
		if hotbarSlotCount == nil or hotbarSlotCount == from.slotCount then
			return 0
		end
		if slot <= hotbarSlotCount then
			firstSlot, lastSlot = hotbarSlotCount + 1, from.slotCount
		else
			firstSlot, lastSlot = 1, hotbarSlotCount
		end
	end
	local stack = Inventory.takeFromSlot(from, slot)
	if stack == nil then
		return 0
	end
	local leftover: ItemStack?
	if across ~= nil and side == "pack" then
		leftover = addToOther(session, across, stack)
	else
		leftover = Inventory.addStack(to, stack, firstSlot, lastSlot)
	end
	if leftover == nil then
		return stack.count
	end
	Inventory.putInSlot(from, slot, leftover)
	return stack.count - leftover.count
end

--[=[
	Takes up to `count` items off the carried stack and returns them as a
	stack, for the caller to put on the ground. A screen calls this when the
	player drops what they are carrying, as a click outside a Minecraft
	inventory window does.

	Leaving out `count` drops the whole carried stack. Returns `nil` if
	nothing was dropped, because nothing is carried or `count` is 0.

	The stack returned is no longer carried and is in no inventory. If the
	caller does nothing with it, the items are lost.

	Raises an error if `count` is not a whole number of 0 or more.
]=]
function InventorySession.drop(session: InventorySession, count: number?): ItemStack?
	failIf(countProblem(count), "InventorySession.drop")
	local carried = session.carried
	if carried == nil or count == 0 then
		return nil
	end
	if count == nil or count >= carried.count then
		carry(session, nil)
		return carried
	end
	local dropped, kept = ItemStack.split(carried, count)
	carry(session, kept)
	return dropped
end

--[=[
	Puts the carried stack into the pack, wherever it fits, and returns the
	stack of what did not fit, or `nil` if all of it fitted or nothing was
	carried. A screen calls this when it closes.

	Afterwards nothing is carried. The stack returned is in no inventory: the
	caller must put it on the ground, or the items are lost.

	Nothing else about the session changes. A closed screen's session is
	normally thrown away.
]=]
function InventorySession.close(session: InventorySession): ItemStack?
	local carried = session.carried
	if carried == nil then
		return nil
	end
	carry(session, nil)
	return Inventory.addStack(session.pack, carried)
end

return InventorySession
