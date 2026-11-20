--!strict
--- What a player has open: their pack, another inventory beside it, and the stack they carry.
---
--- A player moves items by carrying them. `pickUp` moves items from a slot onto the carried stack
--- and `putDown` moves them from the carried stack into a slot. The carried stack belongs to the
--- screen, not to either inventory. No function here makes or loses an item.
local Inventory = require("./Inventory")
local ItemStack = require("../items/ItemStack")

local InventoryScreen = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory

--- Which of the screen's inventories a slot is in: the player's pack, or the other one that is open.
export type Side = "pack" | "other"

--- One slot of the screen.
export type ScreenSlot = { read side: Side, read slot: number }

export type InventoryScreen = {
	--- The player's own inventory.
	read pack: Inventory,
	--- The other inventory that is open, such as a crate's. `nil` when the pack is open alone.
	read other: Inventory?,
	--- The stack being carried between slots. `nil` when nothing is carried.
	carried: ItemStack?,
	--- Returns `true` if a slot of `other` accepts an item. `nil` when every slot accepts everything.
	read otherAccepts: ((slot: number, itemId: string) -> boolean)?,
}

local function slotName(side: Side, slot: number): string
	return side .. slot
end

local function slotsOf(side: Side, inventory: Inventory?): { ScreenSlot }
	local slots = {}
	for slot = 1, if inventory then inventory.slotCount else 0 do
		table.insert(slots, { side = side, slot = slot })
	end
	return slots
end

--- Returns a screen that shows `pack`, and `other` beside it if one is given, with nothing
--- carried. `otherAccepts` says which items each slot of `other` accepts.
function InventoryScreen.new(
	pack: Inventory,
	other: Inventory?,
	otherAccepts: ((slot: number, itemId: string) -> boolean)?
): InventoryScreen
	return { pack = pack, other = other, otherAccepts = otherAccepts }
end

--- Returns the inventory on a side. Fails if `side` is `"other"` and no other inventory is open.
function InventoryScreen.getInventory(screen: InventoryScreen, side: Side): Inventory
	return assert(if side == "pack" then screen.pack else screen.other, "no other inventory is open")
end

--- Returns `true` if `side` and `slot` name one of the screen's slots. Both may be any value at
--- all, so this is the check for a slot named from outside the game.
function InventoryScreen.hasSlot(screen: InventoryScreen, side: unknown, slot: unknown): boolean
	local inventory = if side == "pack" then screen.pack elseif side == "other" then screen.other else nil
	return inventory ~= nil and Inventory.hasSlot(inventory, slot)
end

--- Returns `true` if `slots` is a list of the screen's slots, each a table with a `side` and a
--- `slot`. `slots` may be any value at all.
function InventoryScreen.hasSlots(screen: InventoryScreen, slots: unknown): boolean
	if type(slots) ~= "table" then
		return false
	end
	local entries = 0
	for _, screenSlot in slots :: { [unknown]: any } do
		entries += 1
		if type(screenSlot) ~= "table" or not InventoryScreen.hasSlot(screen, screenSlot.side, screenSlot.slot) then
			return false
		end
	end
	return entries == #(slots :: { unknown })
end

--- Returns `true` if a slot accepts an item, whether or not it has room. Every slot of the pack
--- accepts every item.
function InventoryScreen.accepts(screen: InventoryScreen, side: Side, slot: number, itemId: string): boolean
	local otherAccepts = screen.otherAccepts
	return side == "pack" or otherAccepts == nil or otherAccepts(slot, itemId)
end

--- Moves up to `count` items from a slot onto the carried stack, and returns how many moved.
--- Moves as many as the carried stack has room for if `count` is left out. Moves nothing if the
--- slot holds nothing or a different item is carried.
function InventoryScreen.pickUp(screen: InventoryScreen, side: Side, slot: number, count: number?): number
	local inventory = InventoryScreen.getInventory(screen, side)
	local there = Inventory.getStack(inventory, slot)
	local carried = screen.carried
	if there == nil or (carried ~= nil and not ItemStack.isSameItem(carried, there)) then
		return 0
	end
	local room = if carried then ItemStack.spaceLeft(carried) else there.count
	local taken = Inventory.takeFromSlot(inventory, slot, math.min(count or there.count, room))
	if taken == nil then
		return 0
	end
	screen.carried = if carried then (ItemStack.merge(carried, taken)) else taken
	return taken.count
end

--- Moves up to `count` items from the carried stack into a slot, and returns how many moved.
--- Moves as many as the slot has room for if `count` is left out. Moves nothing if nothing is
--- carried, if the slot holds a different item, or if the slot does not accept the carried item.
function InventoryScreen.putDown(screen: InventoryScreen, side: Side, slot: number, count: number?): number
	local inventory = InventoryScreen.getInventory(screen, side)
	local there = Inventory.getStack(inventory, slot)
	local carried = screen.carried
	if carried == nil or (there ~= nil and not ItemStack.isSameItem(there, carried)) then
		return 0
	end
	if not InventoryScreen.accepts(screen, side, slot, carried.itemId) then
		return 0
	end
	local room = if there then ItemStack.spaceLeft(there) else carried.count
	local moved = math.min(count or carried.count, carried.count, room)
	if moved == 0 then
		return 0
	end
	local put, kept = ItemStack.split(carried, moved)
	Inventory.putInSlot(inventory, slot, put)
	screen.carried = kept
	return moved
end

--- Exchanges the carried stack with the stack in a slot. Either may be nothing: with nothing
--- carried the slot's whole stack becomes the carried stack, and a slot that holds nothing takes
--- the carried stack. Returns `false`, changing nothing, if the slot does not accept the carried
--- item or if there is nothing on either side.
function InventoryScreen.swap(screen: InventoryScreen, side: Side, slot: number): boolean
	local inventory = InventoryScreen.getInventory(screen, side)
	local there = Inventory.getStack(inventory, slot)
	local carried = screen.carried
	if carried ~= nil and not InventoryScreen.accepts(screen, side, slot, carried.itemId) then
		return false
	end
	Inventory.setStack(inventory, slot, carried)
	screen.carried = there
	return there ~= nil or carried ~= nil
end

--- Exchanges the stacks in two slots. Either slot may hold nothing. Returns `false`, changing
--- nothing, if either slot does not accept the stack from the other.
function InventoryScreen.swapSlots(
	screen: InventoryScreen,
	side: Side,
	slot: number,
	withSide: Side,
	withSlot: number
): boolean
	local inventory = InventoryScreen.getInventory(screen, side)
	local withInventory = InventoryScreen.getInventory(screen, withSide)
	local stack = Inventory.getStack(inventory, slot)
	local withStack = Inventory.getStack(withInventory, withSlot)
	if withStack ~= nil and not InventoryScreen.accepts(screen, side, slot, withStack.itemId) then
		return false
	end
	if stack ~= nil and not InventoryScreen.accepts(screen, withSide, withSlot, stack.itemId) then
		return false
	end
	Inventory.setStack(inventory, slot, withStack)
	Inventory.setStack(withInventory, withSlot, stack)
	return true
end

--- Moves the stack in a slot into the inventory on `toSide`, and returns how many items moved.
--- Stacks of the same item are topped up first, and then slots that hold nothing are filled. Only
--- the slots listed in `toSlots` are used, or every slot if it is left out, and never one that
--- does not accept the item. What does not fit stays in its slot.
function InventoryScreen.moveStack(
	screen: InventoryScreen,
	side: Side,
	slot: number,
	toSide: Side,
	toSlots: { number }?
): number
	local from = InventoryScreen.getInventory(screen, side)
	local to = InventoryScreen.getInventory(screen, toSide)
	local stack = Inventory.takeFromSlot(from, slot)
	if stack == nil then
		return 0
	end
	local accepting = {}
	for _, toSlot in toSlots or Inventory.getSlots(to) do
		local isItself = from == to and toSlot == slot
		if not isItself and InventoryScreen.accepts(screen, toSide, toSlot, stack.itemId) then
			table.insert(accepting, toSlot)
		end
	end
	local leftover = Inventory.addStack(to, stack, accepting)
	if leftover ~= nil then
		Inventory.putInSlot(from, slot, leftover)
	end
	return stack.count - (if leftover then leftover.count else 0)
end

local function holdsFullStack(screen: InventoryScreen, screenSlot: ScreenSlot): boolean
	local there = Inventory.getStack(InventoryScreen.getInventory(screen, screenSlot.side), screenSlot.slot)
	return there ~= nil and ItemStack.isFull(there)
end

local function slotsWithFullStacksLast(screen: InventoryScreen): { ScreenSlot }
	local slots, full = {}, {}
	for _, screenSlot in slotsOf("other", screen.other) do
		table.insert(if holdsFullStack(screen, screenSlot) then full else slots, screenSlot)
	end
	for _, screenSlot in slotsOf("pack", screen.pack) do
		table.insert(if holdsFullStack(screen, screenSlot) then full else slots, screenSlot)
	end
	for _, screenSlot in full do
		table.insert(slots, screenSlot)
	end
	return slots
end

--- Fills the carried stack with items of its kind taken from the screen's slots, and returns how
--- many were taken. Slots that hold less than a full stack are taken from first, then full ones;
--- within each, the other inventory's slots come before the pack's, lowest first. Takes nothing if
--- nothing is carried.
function InventoryScreen.gather(screen: InventoryScreen): number
	if screen.carried == nil then
		return 0
	end
	local gathered = 0
	for _, screenSlot in slotsWithFullStacksLast(screen) do
		gathered += InventoryScreen.pickUp(screen, screenSlot.side, screenSlot.slot)
	end
	return gathered
end

local function slotsTakingPart(screen: InventoryScreen, carried: ItemStack, slots: { ScreenSlot }): { ScreenSlot }
	local takingPart: { ScreenSlot } = {}
	local isTakingPart: { [string]: boolean } = {}
	for _, screenSlot in slots do
		local side, slot = screenSlot.side, screenSlot.slot
		local there = Inventory.getStack(InventoryScreen.getInventory(screen, side), slot)
		if
			#takingPart < carried.count
			and not isTakingPart[slotName(side, slot)]
			and (there == nil or ItemStack.isSameItem(there, carried))
			and InventoryScreen.accepts(screen, side, slot, carried.itemId)
		then
			isTakingPart[slotName(side, slot)] = true
			table.insert(takingPart, screenSlot)
		end
	end
	return takingPart
end

--- Puts the carried stack down across several slots, and returns how many items were put down.
--- Each slot gets `countEach` items, or an equal share of the carried stack, rounded down, if
--- `countEach` is left out. A slot takes part only if it holds nothing or the carried item, and
--- accepts it. A slot listed twice counts once, and no more slots take part than there are items
--- carried. What is not put down stays carried.
--- Note: a slot holding a full stack of the carried item takes part and gets nothing, which makes
--- the other shares smaller.
function InventoryScreen.spread(screen: InventoryScreen, slots: { ScreenSlot }, countEach: number?): number
	local carried = screen.carried
	if carried == nil then
		return 0
	end
	local takingPart = slotsTakingPart(screen, carried, slots)
	if #takingPart == 0 then
		return 0
	end
	local share = countEach or math.floor(carried.count / #takingPart)
	local moved = 0
	for _, screenSlot in takingPart do
		moved += InventoryScreen.putDown(screen, screenSlot.side, screenSlot.slot, share)
	end
	return moved
end

--- Takes up to `count` items off the carried stack and returns them as a stack. Takes all of it
--- if `count` is left out or is more than is carried. Returns `nil` if nothing is carried or
--- `count` is 0.
function InventoryScreen.takeCarried(screen: InventoryScreen, count: number?): ItemStack?
	local carried = screen.carried
	if carried == nil or count == 0 then
		return nil
	end
	if count == nil or count >= carried.count then
		screen.carried = nil
		return carried
	end
	local taken, kept = ItemStack.split(carried, count)
	screen.carried = kept
	return taken
end

return InventoryScreen
