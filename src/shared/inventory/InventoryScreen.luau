--!strict
--- What a player has open: their pack, another inventory beside it, and the stack they carry.
---
--- A player moves items by carrying them. `pickUpFromSlot` moves items from a slot onto the carried
--- stack, and `putDownInSlot` moves them from the carried stack into a slot. The carried stack
--- belongs to the screen and to neither inventory. The inventories outlast the screen.
--- Note: a screen that is discarded while it carries a stack loses that stack. `takeCarriedStack`
--- takes the stack off the screen.
local Inventory = require("./Inventory")
local ItemStack = require("../items/ItemStack")

local InventoryScreen = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory

--- Which of the screen's two inventories a slot is in: `"pack"` for the player's pack, or
--- `"other"` for `otherInventory`.
export type Side = "pack" | "other"

--- One slot of the screen: the `side` of its inventory, and its `slot` number.
export type ScreenSlot = { read side: Side, read slot: number }

--- What a player has open: the pack, `otherInventory`, and the carried stack.
export type InventoryScreen = {
	--- The player's pack.
	read pack: Inventory,
	--- The inventory open beside the pack, or `nil` if the pack is open alone.
	read otherInventory: Inventory?,
	--- The stack that the player moves between slots, or `nil` if nothing is carried.
	carriedStack: ItemStack?,
	--- A function that returns `true` if the slot `slot` of `otherInventory` accepts the item with
	--- the id `itemId`. `nil` if every slot of `otherInventory` accepts every item.
	read otherSlotAcceptsItem: ((slot: number, itemId: string) -> boolean)?,
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

--- Returns a new screen that shows `pack`, and `otherInventory` beside it if `otherInventory` is
--- not `nil`. `otherSlotAcceptsItem` decides which items each slot of `otherInventory` accepts. The
--- screen starts with `carriedStack` carried, or with nothing carried if `carriedStack` is `nil`.
--- Note: `new` does not take `carriedStack` out of any inventory.
function InventoryScreen.new(
	pack: Inventory,
	otherInventory: Inventory?,
	otherSlotAcceptsItem: ((slot: number, itemId: string) -> boolean)?,
	carriedStack: ItemStack?
): InventoryScreen
	return {
		pack = pack,
		otherInventory = otherInventory,
		otherSlotAcceptsItem = otherSlotAcceptsItem,
		carriedStack = carriedStack,
	}
end

--- Returns the inventory on `side`. Fails if `side` is `"other"` and `otherInventory` is `nil`.
function InventoryScreen.getInventoryOnSide(screen: InventoryScreen, side: Side): Inventory
	return assert(if side == "pack" then screen.pack else screen.otherInventory, "no other inventory is open")
end

--- Returns `true` if `side` is `"pack"` or `"other"`, and the inventory on that side has the slot
--- `slot`. Returns `false` for `"other"` if `otherInventory` is `nil`. Accepts a value of any type
--- for each, and never fails.
function InventoryScreen.hasSlot(screen: InventoryScreen, side: unknown, slot: unknown): boolean
	local inventory = if side == "pack" then screen.pack elseif side == "other" then screen.otherInventory else nil
	return inventory ~= nil and Inventory.hasSlot(inventory, slot)
end

--- Returns `true` if `slots` is a list, numbered from `1` with no gaps, of tables whose `side` and
--- `slot` pass `hasSlot`. Returns `true` for an empty list. Accepts a value of any type, and never
--- fails.
function InventoryScreen.hasEverySlot(screen: InventoryScreen, slots: unknown): boolean
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

--- Returns `true` if the slot `slot` on `side` accepts the item with the id `itemId`, whatever the
--- slot holds and whether or not it has room. Every slot on `"pack"` accepts every item. A slot on
--- `"other"` accepts the items that `otherSlotAcceptsItem` returns `true` for, or every item if
--- `otherSlotAcceptsItem` is `nil`.
function InventoryScreen.slotAcceptsItem(screen: InventoryScreen, side: Side, slot: number, itemId: string): boolean
	local otherSlotAcceptsItem = screen.otherSlotAcceptsItem
	return side == "pack" or otherSlotAcceptsItem == nil or otherSlotAcceptsItem(slot, itemId)
end

--- Moves items from the slot `slot` on `side` onto the carried stack, and returns how many moved.
--- Moves `count` items, or everything in the slot if `count` is `nil`, but never more than the slot
--- holds or the carried stack has room for. Moves nothing, and returns `0`, if the slot holds
--- nothing or the carried stack is of a different item. Fails if the screen has no such slot.
--- Note: `pickUpFromSlot` does not check that `count` is a whole number of `0` or more.
function InventoryScreen.pickUpFromSlot(screen: InventoryScreen, side: Side, slot: number, count: number?): number
	local inventory = InventoryScreen.getInventoryOnSide(screen, side)
	local there = Inventory.getStack(inventory, slot)
	local carried = screen.carriedStack
	if there == nil or (carried ~= nil and not ItemStack.isSameItem(carried, there)) then
		return 0
	end
	local room = if carried then ItemStack.getSpaceLeft(carried) else there.count
	local taken = Inventory.takeFromSlot(inventory, slot, math.min(count or there.count, room))
	if taken == nil then
		return 0
	end
	local nowCarried = if carried then ItemStack.merge(carried, taken) else taken
	screen.carriedStack = nowCarried
	return taken.count
end

--- Moves items from the carried stack into the slot `slot` on `side`, and returns how many moved.
--- Moves `count` items, or the whole carried stack if `count` is `nil`, but never more than the
--- carried stack holds or the slot has room for. Moves nothing, and returns `0`, if nothing is
--- carried, if the slot holds a different item, or if `slotAcceptsItem` returns `false` for the
--- carried item. Fails if the screen has no such slot.
function InventoryScreen.putDownInSlot(screen: InventoryScreen, side: Side, slot: number, count: number?): number
	local inventory = InventoryScreen.getInventoryOnSide(screen, side)
	local there = Inventory.getStack(inventory, slot)
	local carried = screen.carriedStack
	if carried == nil or (there ~= nil and not ItemStack.isSameItem(there, carried)) then
		return 0
	end
	if not InventoryScreen.slotAcceptsItem(screen, side, slot, carried.itemId) then
		return 0
	end
	local room = if there then ItemStack.getSpaceLeft(there) else carried.count
	local moved = math.min(count or carried.count, carried.count, room)
	if moved == 0 then
		return 0
	end
	local put, kept = ItemStack.split(carried, moved)
	Inventory.putInSlot(inventory, slot, put)
	screen.carriedStack = kept
	return moved
end

--- Returns `true` if nothing is carried, or if the slot `slot` on `side` accepts the carried item.
--- The carried stack accepts any item, so the slot's own stack is never asked about.
function InventoryScreen.canSwapCarriedStackWithSlot(screen: InventoryScreen, side: Side, slot: number): boolean
	local carried = screen.carriedStack
	return carried == nil or InventoryScreen.slotAcceptsItem(screen, side, slot, carried.itemId)
end

--- Exchanges the carried stack with the stack in the slot `slot` on `side`, even if both are of the
--- same item. Either may be nothing: with nothing carried, the slot's stack becomes the carried
--- stack, and a slot that holds nothing takes the carried stack. Fails, and changes nothing, if the
--- screen has no such slot.
--- Note: `swapCarriedStackWithSlot` does not check that the slot accepts the carried item.
--- `canSwapCarriedStackWithSlot` checks.
function InventoryScreen.swapCarriedStackWithSlot(screen: InventoryScreen, side: Side, slot: number)
	local inventory = InventoryScreen.getInventoryOnSide(screen, side)
	local there = Inventory.getStack(inventory, slot)
	Inventory.setStack(inventory, slot, screen.carriedStack)
	screen.carriedStack = there
end

--- Returns `true` if the slot `slot` on `side` accepts the stack in the slot `withSlot` on
--- `withSide`, and `withSlot` accepts the stack in `slot`. A slot that holds nothing gives the
--- other slot nothing to accept. Fails if the screen lacks either slot.
function InventoryScreen.canSwapSlots(
	screen: InventoryScreen,
	side: Side,
	slot: number,
	withSide: Side,
	withSlot: number
): boolean
	local stack = Inventory.getStack(InventoryScreen.getInventoryOnSide(screen, side), slot)
	local withStack = Inventory.getStack(InventoryScreen.getInventoryOnSide(screen, withSide), withSlot)
	local slotAccepts = withStack == nil or InventoryScreen.slotAcceptsItem(screen, side, slot, withStack.itemId)
	local withSlotAccepts = stack == nil or InventoryScreen.slotAcceptsItem(screen, withSide, withSlot, stack.itemId)
	return slotAccepts and withSlotAccepts
end

--- Exchanges the stacks in the slot `slot` on `side` and the slot `withSlot` on `withSide`. Either
--- slot may hold nothing. Fails, and changes nothing, if the screen lacks either slot.
--- Note: `swapSlots` does not check that each slot accepts the other's stack. `canSwapSlots`
--- checks.
function InventoryScreen.swapSlots(screen: InventoryScreen, side: Side, slot: number, withSide: Side, withSlot: number)
	local inventory = InventoryScreen.getInventoryOnSide(screen, side)
	local withInventory = InventoryScreen.getInventoryOnSide(screen, withSide)
	local stack = Inventory.getStack(inventory, slot)
	Inventory.setStack(inventory, slot, Inventory.getStack(withInventory, withSlot))
	Inventory.setStack(withInventory, withSlot, stack)
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
		if slot ~= except and InventoryScreen.slotAcceptsItem(screen, side, slot, itemId) then
			table.insert(accepting, slot)
		end
	end
	return accepting
end

--- Moves the stack in the slot `slot` on `side` into the inventory on `toSide`, and returns how
--- many items moved. Tops up the stacks of the same item there first, and then fills the slots that
--- hold nothing, each in the order of `toSlots`. Uses only the slots in `toSlots`, or every slot of
--- that inventory if `toSlots` is `nil`, and never a slot that does not accept the item, nor, if
--- `side` equals `toSide`, the slot `slot`. Items that do not fit stay in the slot `slot`. Moves
--- nothing, and returns `0`, if the slot holds nothing. Fails if the screen has no such slot.
--- Note: `moveFromSlotToInventory` takes the stack out of the slot `slot` before it checks
--- `toSlots`, so if `toSlots` lists a slot that the inventory on `toSide` lacks, it fails and the
--- stack is lost.
function InventoryScreen.moveFromSlotToInventory(
	screen: InventoryScreen,
	side: Side,
	slot: number,
	toSide: Side,
	toSlots: { number }?
): number
	local from = InventoryScreen.getInventoryOnSide(screen, side)
	local to = InventoryScreen.getInventoryOnSide(screen, toSide)
	local stack = Inventory.takeFromSlot(from, slot)
	if stack == nil then
		return 0
	end
	local itself = if from == to then slot else nil
	local accepting = slotsAccepting(screen, toSide, toSlots or Inventory.getSlotNumbers(to), stack.itemId, itself)
	local leftover = Inventory.addStack(to, stack, accepting)
	if leftover ~= nil then
		Inventory.putInSlot(from, slot, leftover)
	end
	return stack.count - (if leftover then leftover.count else 0)
end

local function holdsFullStack(screen: InventoryScreen, screenSlot: ScreenSlot): boolean
	local there = Inventory.getStack(InventoryScreen.getInventoryOnSide(screen, screenSlot.side), screenSlot.slot)
	return there ~= nil and ItemStack.isFull(there)
end

local function slotsWithFullStacksLast(screen: InventoryScreen): { ScreenSlot }
	local slots, full = {}, {}
	for _, screenSlot in slotsOf("other", screen.otherInventory) do
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

--- Fills the carried stack with items of its own `itemId` from the screen's slots, and returns how
--- many were taken. Takes nothing more once the carried stack is full. Takes from slots that hold
--- less than a full stack first, and then from slots that hold a full stack. Within each of those
--- two groups, the slots of `otherInventory` come before the slots of the pack, each lowest first.
--- Leaves slots that hold other items alone. Takes nothing, and returns `0`, if nothing is
--- carried.
function InventoryScreen.fillCarriedStackFromAllSlots(screen: InventoryScreen): number
	if screen.carriedStack == nil then
		return 0
	end
	local gathered = 0
	for _, screenSlot in slotsWithFullStacksLast(screen) do
		gathered += InventoryScreen.pickUpFromSlot(screen, screenSlot.side, screenSlot.slot)
	end
	return gathered
end

local function canSpreadInto(screen: InventoryScreen, carried: ItemStack, screenSlot: ScreenSlot): boolean
	local there = Inventory.getStack(InventoryScreen.getInventoryOnSide(screen, screenSlot.side), screenSlot.slot)
	return (there == nil or ItemStack.isSameItem(there, carried))
		and InventoryScreen.slotAcceptsItem(screen, screenSlot.side, screenSlot.slot, carried.itemId)
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

--- Puts the carried stack down across the slots in `slots`, and returns how many items were put
--- down. A slot takes part if it holds nothing or the carried item, and accepts the carried item.
--- A slot that holds a full stack of the carried item takes part too, and receives nothing. A slot
--- that `slots` lists twice takes part once. No more slots take part than there are carried items,
--- chosen in the order of `slots`. Each slot that takes part receives `countEach` items, or, if
--- `countEach` is `nil`, the carried stack's count divided by the number of slots that take part,
--- rounded down. A slot receives fewer if the carried stack or the slot's room runs out. What is
--- not put down stays carried. Returns `0` if nothing is carried or no slot takes part.
function InventoryScreen.spreadCarriedStackOverSlots(
	screen: InventoryScreen,
	slots: { ScreenSlot },
	countEach: number?
): number
	local carried = screen.carriedStack
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
		moved += InventoryScreen.putDownInSlot(screen, screenSlot.side, screenSlot.slot, share)
	end
	return moved
end

--- Takes up to `count` items off the carried stack and returns them as a stack. Takes all of it if
--- `count` is `nil` or at least the carried stack's count. Returns `nil` if nothing is carried or
--- `count` is `0`.
--- Note: `takeCarriedStack` does not check that `count` is a whole number of `0` or more.
function InventoryScreen.takeCarriedStack(screen: InventoryScreen, count: number?): ItemStack?
	local carried = screen.carriedStack
	if carried == nil or count == 0 then
		return nil
	end
	if count == nil or count >= carried.count then
		screen.carriedStack = nil
		return carried
	end
	local taken, kept = ItemStack.split(carried, count)
	screen.carriedStack = kept
	return taken
end

return InventoryScreen
