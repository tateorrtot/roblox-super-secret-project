--!strict
--- What a player's machine may ask for about the inventories on the player's screen, and their
--- hotbar.
---
--- Each function is one request. `world` is the world and `state` is the player who asks. Every
--- argument after them is what the player's machine sent, and may be any value at all. A request
--- that makes no sense for the player as they are now does nothing.
local Hotbar = require("../inventory/Hotbar")
local Inventory = require("../inventory/Inventory")
local InventoryScreen = require("../inventory/InventoryScreen")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local World = require("../world/World")

local InventoryRequests = {}

type World = World.World
type PlayerState = PlayerState.PlayerState
type InventoryScreen = InventoryScreen.InventoryScreen

local function isCountOrNil(value: unknown): boolean
	return value == nil or (type(value) == "number" and value % 1 == 0 and value >= 0)
end

local function screenWithSlot(state: PlayerState, side: unknown, slot: unknown): InventoryScreen?
	local screen = state.screen
	return if screen ~= nil and InventoryScreen.hasSlot(screen, side, slot) then screen else nil
end

local function dropAtPlayer(world: World, state: PlayerState, stack: ItemStack.ItemStack?)
	if stack ~= nil then
		World.dropStack(world, stack, state.dropPosition)
	end
end

--- Opens the player's inventory screen on their pack alone. Does nothing if they have a screen open.
function InventoryRequests.openPack(_world: World, state: PlayerState)
	if state.screen == nil then
		state.screen = InventoryScreen.new(state.pack)
	end
end

--- Closes the player's inventory screen. The stack they were carrying goes back into their pack,
--- and what does not fit is dropped on the ground.
function InventoryRequests.closeScreen(world: World, state: PlayerState)
	World.closeScreen(world, state)
end

--- Moves up to `count` items from a slot of the open screen onto the carried stack, or as many
--- as the carried stack has room for if `count` is `nil`.
function InventoryRequests.pickUp(_world: World, state: PlayerState, side: unknown, slot: unknown, count: unknown)
	local screen = screenWithSlot(state, side, slot)
	if screen ~= nil and isCountOrNil(count) then
		InventoryScreen.pickUp(screen, side :: any, slot :: any, count :: any)
	end
end

--- Moves up to `count` items from the carried stack into a slot of the open screen, or as many
--- as the slot has room for if `count` is `nil`.
function InventoryRequests.putDown(_world: World, state: PlayerState, side: unknown, slot: unknown, count: unknown)
	local screen = screenWithSlot(state, side, slot)
	if screen ~= nil and isCountOrNil(count) then
		InventoryScreen.putDown(screen, side :: any, slot :: any, count :: any)
	end
end

--- Exchanges the carried stack with the stack in a slot of the open screen.
function InventoryRequests.swapCarried(_world: World, state: PlayerState, side: unknown, slot: unknown)
	local screen = screenWithSlot(state, side, slot)
	if screen ~= nil then
		InventoryScreen.swapCarried(screen, side :: any, slot :: any)
	end
end

--- Exchanges the stacks in two slots of the open screen.
function InventoryRequests.swapSlots(
	_world: World,
	state: PlayerState,
	side: unknown,
	slot: unknown,
	withSide: unknown,
	withSlot: unknown
)
	local screen = screenWithSlot(state, side, slot)
	if screen ~= nil and InventoryScreen.hasSlot(screen, withSide, withSlot) then
		InventoryScreen.swapSlots(screen, side :: any, slot :: any, withSide :: any, withSlot :: any)
	end
end

--- Moves the stack in a slot of the open screen into the slots `toFirstSlot` to `toLastSlot` of
--- the inventory on `toSide`: stacks of the same item are topped up first, then slots that hold
--- nothing are filled, and what does not fit stays where it was.
function InventoryRequests.moveStack(
	_world: World,
	state: PlayerState,
	side: unknown,
	slot: unknown,
	toSide: unknown,
	toFirstSlot: unknown,
	toLastSlot: unknown
)
	local screen = screenWithSlot(state, side, slot)
	if screen == nil or not InventoryScreen.hasSlot(screen, toSide, toFirstSlot) then
		return
	end
	if not InventoryScreen.hasSlot(screen, toSide, toLastSlot) then
		return
	end
	local toSlots = {}
	for toSlot = toFirstSlot :: number, toLastSlot :: number do
		table.insert(toSlots, toSlot)
	end
	InventoryScreen.moveStack(screen, side :: any, slot :: any, toSide :: any, toSlots)
end

--- Fills the carried stack with items of its kind taken from the slots of the open screen.
function InventoryRequests.gatherCarried(_world: World, state: PlayerState)
	local screen = state.screen
	if screen ~= nil then
		InventoryScreen.gather(screen)
	end
end

--- Puts the carried stack down across `slots`, a list of slots of the open screen: `countEach`
--- items in each, or an equal share in each if `countEach` is `nil`. Does nothing if `slots` lists
--- more slots than the screen has.
function InventoryRequests.spreadCarried(_world: World, state: PlayerState, slots: unknown, countEach: unknown)
	local screen = state.screen
	if screen == nil or not InventoryScreen.hasSlots(screen, slots) or not isCountOrNil(countEach) then
		return
	end
	local list = slots :: { InventoryScreen.ScreenSlot }
	local other = screen.other
	if #list <= screen.pack.slotCount + (if other then other.slotCount else 0) then
		InventoryScreen.spread(screen, list, countEach :: any)
	end
end

--- Drops up to `count` items of the carried stack on the ground at the player's `dropPosition`,
--- or all of it if `count` is `nil`.
function InventoryRequests.dropCarried(world: World, state: PlayerState, count: unknown)
	local screen = state.screen
	if screen ~= nil and isCountOrNil(count) then
		dropAtPlayer(world, state, InventoryScreen.takeCarried(screen, count :: any))
	end
end

--- Drops up to `count` items out of a slot of the open screen on the ground at the player's
--- `dropPosition`, or everything in the slot if `count` is `nil`.
function InventoryRequests.dropFromSlot(world: World, state: PlayerState, side: unknown, slot: unknown, count: unknown)
	local screen = screenWithSlot(state, side, slot)
	if screen ~= nil and isCountOrNil(count) then
		local inventory = InventoryScreen.getInventory(screen, side :: any)
		dropAtPlayer(world, state, Inventory.takeFromSlot(inventory, slot :: any, count :: any))
	end
end

--- Selects a slot of the player's hotbar. What it holds is then in the player's hand.
function InventoryRequests.selectHotbarSlot(_world: World, state: PlayerState, slot: unknown)
	if Hotbar.hasSlot(state.hotbar, slot) then
		Hotbar.select(state.hotbar, slot :: number)
	end
end

--- Drops up to `count` items out of the selected hotbar slot on the ground at the player's
--- `dropPosition`, or everything in the slot if `count` is `nil`.
function InventoryRequests.dropSelected(world: World, state: PlayerState, count: unknown)
	if isCountOrNil(count) then
		dropAtPlayer(world, state, Hotbar.takeSelected(state.hotbar, count :: any))
	end
end

return InventoryRequests
