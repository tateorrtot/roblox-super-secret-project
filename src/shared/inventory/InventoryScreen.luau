--!strict
--- What a player has open: their pack, another inventory beside it, and the stack they carry.
---
--- A player moves items by carrying them. `pickUp` moves items from a slot onto the carried stack
--- and `putDown` moves them from the carried stack into a slot. The carried stack belongs to the
--- screen, not to either inventory, and the inventories live on after the screen is gone.
--- Note: a screen that is thrown away while a stack is carried loses that stack. Take it out with
--- `takeCarried` first.
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
	--- Says whether a slot of `other` accepts an item, given the slot's number and the item's id.
	--- `nil` when every slot of `other` accepts every item.
	read otherAccepts: ((slot: number, itemId: string) -> boolean)?,
}

local function slotKey(side: Side, slot: number): string
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

--- Returns `true` if `slots` is a list, numbered from 1 with no gaps, of the screen's slots: each
--- entry a table whose `side` and `slot` pass `hasSlot`. `slots` may be any value at all.
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

--- Returns `true` if a slot accepts an item, whatever the slot holds now and whether or not it
--- has room. Every slot of the pack accepts every item.
function InventoryScreen.accepts(screen: InventoryScreen, side: Side, slot: number, itemId: string): boolean
	local otherAccepts = screen.otherAccepts
	return side == "pack" or otherAccepts == nil or otherAccepts(slot, itemId)
end

--- Moves items from a slot onto the carried stack, and returns how many moved. It moves `count`
--- items, or all the slot holds if `count` is left out, but never more than the slot holds or the
--- carried stack has room for. Moves nothing if the slot holds nothing, or if a different item is
--- carried.
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
	local nowCarried = if carried then ItemStack.merge(carried, taken) else taken
	screen.carried = nowCarried
	return taken.count
end

--- Moves items from the carried stack into a slot, and returns how many moved. It moves `count`
--- items, or all that is carried if `count` is left out, but never more than is carried or the
--- slot has room for. Moves nothing if nothing is carried, if the slot holds a different item, or
--- if the slot does not accept the carried item.
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

--- Exchanges the carried stack with the stack in a slot, even when both are of the same item.
--- Either may be nothing: with nothing carried the slot's stack becomes the carried stack, and a
--- slot that holds nothing takes the carried stack. Returns `true` if anything changed. Returns
--- `false`, changing nothing, if the slot does not accept the carried item, or if nothing is
--- carried and the slot holds nothing.
function InventoryScreen.swapCarried(screen: InventoryScreen, side: Side, slot: number): boolean
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

--- Exchanges the stacks in two slots. Either slot may hold nothing. Returns `true` if the stacks
--- were exchanged, and `false`, changing nothing, if either slot does not accept the stack from
--- the other.
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

local function slotsAccepting(
	screen: InventoryScreen,
	side: Side,
	slots: { number },
	itemId: string,
	except: number?
): { number }
	local accepting = {}
	for _, slot in slots do
		if slot ~= except and InventoryScreen.accepts(screen, side, slot, itemId) then
			table.insert(accepting, slot)
		end
	end
	return accepting
end

--- Moves the stack in a slot into the inventory on `toSide`, and returns how many items moved.
--- Stacks of the same item there are topped up first, and then slots that hold nothing are
--- filled. Only the slots listed in `toSlots` are used, or every slot if it is left out, and never
--- a slot that does not accept the item or the slot the stack came from. What does not fit stays
--- in its slot. Moves nothing if the slot holds nothing.
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
	local itself = if from == to then slot else nil
	local accepting = slotsAccepting(screen, toSide, toSlots or Inventory.getSlots(to), stack.itemId, itself)
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
--- many were taken. It stops when the carried stack is full. Slots that hold less than a full
--- stack are taken from first, then full ones; within each, the other inventory's slots come
--- before the pack's, lowest first. Slots holding other items are left alone. Takes nothing if
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

local function canSpreadInto(screen: InventoryScreen, carried: ItemStack, screenSlot: ScreenSlot): boolean
	local there = Inventory.getStack(InventoryScreen.getInventory(screen, screenSlot.side), screenSlot.slot)
	return (there == nil or ItemStack.isSameItem(there, carried))
		and InventoryScreen.accepts(screen, screenSlot.side, screenSlot.slot, carried.itemId)
end

local function slotsToSpreadOver(screen: InventoryScreen, carried: ItemStack, slots: { ScreenSlot }): { ScreenSlot }
	local chosen: { ScreenSlot } = {}
	local isChosen: { [string]: boolean } = {}
	for _, screenSlot in slots do
		local key = slotKey(screenSlot.side, screenSlot.slot)
		if #chosen < carried.count and not isChosen[key] and canSpreadInto(screen, carried, screenSlot) then
			isChosen[key] = true
			table.insert(chosen, screenSlot)
		end
	end
	return chosen
end

--- Puts the carried stack down across several slots, and returns how many items were put down.
--- A slot takes part only if it holds nothing or the carried item, and accepts it. A slot holding
--- a full stack of the carried item also takes part, although it can take nothing. A slot listed
--- twice counts once, and no more slots take part than there are items carried. Each slot taking
--- part gets `countEach` items, or, if `countEach` is left out, the carried count divided by the
--- number of slots taking part, rounded down. What is not put down stays carried.
function InventoryScreen.spread(screen: InventoryScreen, slots: { ScreenSlot }, countEach: number?): number
	local carried = screen.carried
	if carried == nil then
		return 0
	end
	local takingPart = slotsToSpreadOver(screen, carried, slots)
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
