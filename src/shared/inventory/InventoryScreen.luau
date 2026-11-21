--!strict
--- The inventories that a player has open, and the stack that the player carries between their
--- slots.
---
--- An inventory screen holds state and draws nothing. Its fields are `pack`, `otherInventory`,
--- `carriedStack`, and `otherSlotAcceptsItem`. `pickUpFromSlot` moves items from a slot of an
--- `Inventory` onto `carriedStack`, and `putDownInSlot` moves them from `carriedStack` into a slot.
--- `carriedStack` is in neither inventory. The inventories outlast the screen. Each function that
--- acts on a slot takes the `Inventory` and the slot's number.
--- Note: a screen that is discarded while its `carriedStack` is not `nil` loses that `ItemStack`.
--- `takeCarriedStack` takes it off the screen.
local Inventory = require("./Inventory")
local ItemStack = require("../items/ItemStack")

local InventoryScreen = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory

--- One slot of an `Inventory`: the `inventory`, and the slot's number `slot` in it, from `1` to
--- `inventory.slotCount`.
export type ScreenSlot = { read inventory: Inventory, read slot: number }

--- What a player has open: `pack`, `otherInventory`, and the `carriedStack` that the player moves
--- between their slots.
export type InventoryScreen = {
	--- The player's own `Inventory`.
	read pack: Inventory,
	--- A second `Inventory` that the player has open, such as a crate's. `nil` if `pack` is open
	--- alone.
	read otherInventory: Inventory?,
	--- The `ItemStack` that the player moves between slots. It is in neither inventory. `nil` if
	--- the player carries nothing.
	carriedStack: ItemStack?,
	--- A function that returns `true` if slot number `slot` of `otherInventory` accepts the item
	--- `itemId`. `nil` if every slot of `otherInventory` accepts every item.
	read otherSlotAcceptsItem: ((slot: number, itemId: string) -> boolean)?,
}

local function slotsOf(inventory: Inventory?): { ScreenSlot }
	local slots = {}
	for slot = 1, if inventory then inventory.slotCount else 0 do
		table.insert(slots, { inventory = inventory :: Inventory, slot = slot })
	end
	return slots
end

--- Returns a new screen.
--- - `pack`: the player's own `Inventory`. It becomes the screen's `pack`.
--- - `otherInventory`: a second `Inventory` to open with `pack`, or `nil`. It becomes the screen's
--- `otherInventory`.
--- - `otherSlotAcceptsItem`: the screen's `otherSlotAcceptsItem`, or `nil`.
--- - `carriedStack`: the `ItemStack` that the screen starts with as its `carriedStack`, or `nil`.
---
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

--- Returns `true` if slot number `slot` of `inventory` accepts the item `itemId`. Does not look at
--- what the slot holds, or at whether the slot has room.
--- - `screen`: the screen whose `otherSlotAcceptsItem` decides.
--- - `inventory`: the `Inventory` that `slot` is in.
--- - `slot`: a slot number of `inventory`.
--- - `itemId`: the `id` of an item.
---
--- If `inventory` is `screen.otherInventory` and `screen.otherSlotAcceptsItem` is not `nil`,
--- returns what `screen.otherSlotAcceptsItem` returns for `slot` and `itemId`. Returns `true` in
--- every other case.
function InventoryScreen.slotAcceptsItem(
	screen: InventoryScreen,
	inventory: Inventory,
	slot: number,
	itemId: string
): boolean
	local otherSlotAcceptsItem = screen.otherSlotAcceptsItem
	return inventory ~= screen.otherInventory or otherSlotAcceptsItem == nil or otherSlotAcceptsItem(slot, itemId)
end

--- Moves items from the `ItemStack` in `slot` onto `screen.carriedStack`, and returns how many
--- items moved.
--- - `screen`: the screen whose `carriedStack` receives the items.
--- - `inventory`: the `Inventory` that `slot` is in.
--- - `slot`: a slot number of `inventory`, from `1` to `inventory.slotCount`.
--- - `count`: how many items to move. `nil` moves every item in `slot`.
---
--- Stops when `screen.carriedStack` reaches the `stackSize` of its `ItemRegistry.ItemDefinition`.
--- If `screen.carriedStack` is `nil`, the items that moved become `screen.carriedStack`. Moves
--- nothing, and returns `0`, if `slot` holds `nil`, or if `screen.carriedStack` and the `ItemStack`
--- in `slot` have different `itemId`s. Raises an error if `Inventory.hasSlot` returns `false` for
--- `inventory` and `slot`.
--- Note: `pickUpFromSlot` does not check that `count` is a whole number of `0` or more.
function InventoryScreen.pickUpFromSlot(
	screen: InventoryScreen,
	inventory: Inventory,
	slot: number,
	count: number?
): number
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

--- Moves items from `screen.carriedStack` into `slot`, and returns how many items moved.
--- - `screen`: the screen whose `carriedStack` gives the items.
--- - `inventory`: the `Inventory` that `slot` is in.
--- - `slot`: a slot number of `inventory`, from `1` to `inventory.slotCount`.
--- - `count`: how many items to move. `nil` moves every item of `screen.carriedStack`.
---
--- Stops when the `ItemStack` in `slot` reaches the `stackSize` of its
--- `ItemRegistry.ItemDefinition`. Moves nothing, and returns `0`, if `screen.carriedStack` is
--- `nil`, if `screen.carriedStack` and the `ItemStack` in `slot` have different `itemId`s, or if
--- `slotAcceptsItem` returns `false` for `inventory`, `slot`, and the `itemId` of
--- `screen.carriedStack`. Raises an error if `Inventory.hasSlot` returns `false` for `inventory`
--- and `slot`.
function InventoryScreen.putDownInSlot(
	screen: InventoryScreen,
	inventory: Inventory,
	slot: number,
	count: number?
): number
	local there = Inventory.getStack(inventory, slot)
	local carried = screen.carriedStack
	if carried == nil or (there ~= nil and not ItemStack.isSameItem(there, carried)) then
		return 0
	end
	if not InventoryScreen.slotAcceptsItem(screen, inventory, slot, carried.itemId) then
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

--- Returns `true` if `screen.carriedStack` is `nil`, or if `slotAcceptsItem` returns `true` for
--- `inventory`, `slot`, and the `itemId` of `screen.carriedStack`.
--- - `screen`: the screen whose `carriedStack` and `otherSlotAcceptsItem` decide.
--- - `inventory`: the `Inventory` that `slot` is in.
--- - `slot`: a slot number of `inventory`.
function InventoryScreen.canSwapCarriedStackWithSlot(
	screen: InventoryScreen,
	inventory: Inventory,
	slot: number
): boolean
	local carried = screen.carriedStack
	return carried == nil or InventoryScreen.slotAcceptsItem(screen, inventory, slot, carried.itemId)
end

--- Exchanges `screen.carriedStack` with the `ItemStack` in `slot`. Either may be `nil`.
--- - `screen`: the screen whose `carriedStack` is exchanged.
--- - `inventory`: the `Inventory` that `slot` is in.
--- - `slot`: a slot number of `inventory`, from `1` to `inventory.slotCount`.
---
--- Raises an error, and changes nothing, if `Inventory.hasSlot` returns `false` for `inventory` and
--- `slot`.
--- Note: `swapCarriedStackWithSlot` does not ask `slotAcceptsItem`. `canSwapCarriedStackWithSlot`
--- does.
function InventoryScreen.swapCarriedStackWithSlot(screen: InventoryScreen, inventory: Inventory, slot: number)
	local there = Inventory.getStack(inventory, slot)
	Inventory.setStack(inventory, slot, screen.carriedStack)
	screen.carriedStack = there
end

--- Returns `true` if the `ItemStack` in `slot` and the `ItemStack` in `withSlot` may change places:
--- `slotAcceptsItem` returns `true` for `inventory`, `slot`, and the `itemId` of the `ItemStack` in
--- `withSlot`, and for `withInventory`, `withSlot`, and the `itemId` of the `ItemStack` in `slot`.
--- A slot that holds `nil` has no `itemId` to ask about.
--- - `screen`: the screen whose `otherSlotAcceptsItem` decides.
--- - `inventory`: the `Inventory` that `slot` is in.
--- - `slot`: a slot number of `inventory`.
--- - `withInventory`: the `Inventory` that `withSlot` is in. It may be `inventory` itself.
--- - `withSlot`: a slot number of `withInventory`.
---
--- Raises an error if `Inventory.hasSlot` returns `false` for either `Inventory` and its slot.
function InventoryScreen.canSwapSlots(
	screen: InventoryScreen,
	inventory: Inventory,
	slot: number,
	withInventory: Inventory,
	withSlot: number
): boolean
	local stack = Inventory.getStack(inventory, slot)
	local withStack = Inventory.getStack(withInventory, withSlot)
	local slotAccepts = withStack == nil or InventoryScreen.slotAcceptsItem(screen, inventory, slot, withStack.itemId)
	local withSlotAccepts = stack == nil
		or InventoryScreen.slotAcceptsItem(screen, withInventory, withSlot, stack.itemId)
	return slotAccepts and withSlotAccepts
end

local function holdsFullStack(screenSlot: ScreenSlot): boolean
	local there = Inventory.getStack(screenSlot.inventory, screenSlot.slot)
	return there ~= nil and ItemStack.isFull(there)
end

local function slotsWithFullStacksLast(screen: InventoryScreen): { ScreenSlot }
	local slots, full = {}, {}
	for _, screenSlot in slotsOf(screen.otherInventory) do
		table.insert(if holdsFullStack(screenSlot) then full else slots, screenSlot)
	end
	for _, screenSlot in slotsOf(screen.pack) do
		table.insert(if holdsFullStack(screenSlot) then full else slots, screenSlot)
	end
	for _, screenSlot in full do
		table.insert(slots, screenSlot)
	end
	return slots
end

--- Adds items to `screen.carriedStack` from every slot of `screen.otherInventory` and `screen.pack`
--- that holds an `ItemStack` with the same `itemId`, and returns how many items it added.
--- - `screen`: the screen whose `carriedStack` receives the items.
---
--- Stops when `screen.carriedStack` reaches the `stackSize` of its `ItemRegistry.ItemDefinition`.
--- Takes from the slots whose `ItemStack` is below its `stackSize` first, and then from the slots
--- whose `ItemStack` is at its `stackSize`. Within each of those two groups, it takes from the
--- slots of `screen.otherInventory` before the slots of `screen.pack`, each from slot `1` upwards.
--- Adds nothing, and returns `0`, if `screen.carriedStack` is `nil`.
function InventoryScreen.fillCarriedStackFromAllSlots(screen: InventoryScreen): number
	if screen.carriedStack == nil then
		return 0
	end
	local gathered = 0
	for _, screenSlot in slotsWithFullStacksLast(screen) do
		gathered += InventoryScreen.pickUpFromSlot(screen, screenSlot.inventory, screenSlot.slot)
	end
	return gathered
end

local function canSpreadInto(screen: InventoryScreen, carried: ItemStack, screenSlot: ScreenSlot): boolean
	local there = Inventory.getStack(screenSlot.inventory, screenSlot.slot)
	return (there == nil or ItemStack.isSameItem(there, carried))
		and InventoryScreen.slotAcceptsItem(screen, screenSlot.inventory, screenSlot.slot, carried.itemId)
end

local function slotsToSpreadOver(screen: InventoryScreen, carried: ItemStack, slots: { ScreenSlot }): { ScreenSlot }
	local chosen: { ScreenSlot } = {}
	local isChosen: { [Inventory]: { [number]: boolean } } = {}
	for _, screenSlot in slots do
		local chosenInInventory = isChosen[screenSlot.inventory] or {}
		isChosen[screenSlot.inventory] = chosenInInventory
		local isNew = #chosen < carried.count and not chosenInInventory[screenSlot.slot]
		if isNew and canSpreadInto(screen, carried, screenSlot) then
			chosenInInventory[screenSlot.slot] = true
			table.insert(chosen, screenSlot)
		end
	end
	return chosen
end

--- Puts items of `screen.carriedStack` into the slots in `slots`, and returns how many items it put
--- down.
--- - `screen`: the screen whose `carriedStack` gives the items.
--- - `slots`: a list of `ScreenSlot`s.
--- - `countEach`: how many items to put in each slot that gets items. `nil` gives each an equal
--- share of the `count` of `screen.carriedStack`, rounded down.
---
--- A slot in `slots` gets items if it holds `nil` or an `ItemStack` with the same `itemId` as
--- `screen.carriedStack`, and `slotAcceptsItem` returns `true` for it. A slot whose `ItemStack` is
--- at its `stackSize` counts as a slot that gets items, and receives none. A slot that `slots`
--- lists twice counts once. No more slots get items than `screen.carriedStack` has items: the first
--- ones in `slots` do. A slot receives fewer items than its share if `screen.carriedStack` or the
--- room in the slot runs out. The items that are not put down stay in `screen.carriedStack`.
--- Returns `0` if `screen.carriedStack` is `nil`, or if no slot gets items.
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
		moved += InventoryScreen.putDownInSlot(screen, screenSlot.inventory, screenSlot.slot, share)
	end
	return moved
end

--- Takes items off `screen.carriedStack`, and returns them as an `ItemStack`.
--- - `screen`: the screen whose `carriedStack` loses the items.
--- - `count`: how many items to take. `nil` takes every item.
---
--- If `count` is `nil`, or is at least the `count` of `screen.carriedStack`, `takeCarriedStack`
--- returns that `ItemStack` itself, and `screen.carriedStack` is then `nil`. Otherwise it returns a
--- new `ItemStack` of `count` items, and `screen.carriedStack` is then a new `ItemStack` of the
--- items that are left. Returns `nil`, and changes nothing, if `screen.carriedStack` is `nil` or
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
