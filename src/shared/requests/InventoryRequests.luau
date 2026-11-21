--!strict
--- The requests that a client makes about its player's inventory screen and hotbar.
---
--- Each function is one request. `world` is the world and `player` is the player who asks. Every
--- argument after them is what the client sent, and may be a value of any type. A request that does
--- not fit the player's state, or whose arguments are not valid, does nothing. A player with no
--- character can open no screen and drop nothing.
---
--- A request that drops takes a `direction`: the way the stack is thrown. It is a table with
--- numbers from `-1` to `1` under `x`, `y`, and `z`, not all `0`, where `y` is upwards. Only the
--- way it points counts, not its length.
local Direction = require("../Direction")
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

local function isFromMinusOneToOne(value: unknown): boolean
	return type(value) == "number" and value >= -1 and value <= 1
end

local function decodeDirection(sent: unknown): Direction.Direction?
	if type(sent) ~= "table" then
		return nil
	end
	local x, y, z = (sent :: any).x, (sent :: any).y, (sent :: any).z
	local isInRange = isFromMinusOneToOne(x) and isFromMinusOneToOne(y) and isFromMinusOneToOne(z)
	return if isInRange then Direction.new(x, y, z) else nil
end

local function findScreenWithSlot(player: PlayerState, side: unknown, slot: unknown): InventoryScreen?
	local screen = player.screen
	return if screen ~= nil and InventoryScreen.hasSlot(screen, side, slot) then screen else nil
end

local function throwFromCharacter(
	world: World,
	stack: ItemStack.ItemStack?,
	character: PlayerState.Character,
	direction: Direction.Direction
)
	if stack ~= nil then
		World.throwStackFromCharacter(world, stack, character.position, direction)
	end
end

--- Opens the player's inventory screen on their pack alone. Does nothing if the player has a
--- screen open or has no character.
function InventoryRequests.openPack(_world: World, player: PlayerState)
	if PlayerState.canOpenScreen(player) then
		PlayerState.openScreen(player)
	end
end

--- Closes the player's inventory screen, as `World.closeScreen` does: the carried stack goes back
--- into the player's pack, and what does not fit is dropped at the player's character. Does
--- nothing if no screen is open.
function InventoryRequests.closeScreen(world: World, player: PlayerState)
	World.closeScreen(world, player)
end

--- Moves items from the slot `slot` on the side `side` of the open screen onto the carried stack,
--- as `InventoryScreen.pickUpFromSlot` does: `count` items, or all that the slot holds if `count`
--- is `nil`, but never more than the carried stack has room for. Does nothing if no screen is
--- open, if `side` and `slot` name no slot of it, or if `count` is neither `nil` nor a whole
--- number of `0` or more.
function InventoryRequests.pickUpFromSlot(
	_world: World,
	player: PlayerState,
	side: unknown,
	slot: unknown,
	count: unknown
)
	local screen = findScreenWithSlot(player, side, slot)
	if screen ~= nil and isCountOrNil(count) then
		InventoryScreen.pickUpFromSlot(screen, side :: any, slot :: any, count :: any)
	end
end

--- Moves items from the carried stack into the slot `slot` on the side `side` of the open screen,
--- as `InventoryScreen.putDownInSlot` does: `count` items, or all that is carried if `count` is
--- `nil`, but never more than the slot has room for. Does nothing if no screen is open, if `side`
--- and `slot` name no slot of it, or if `count` is neither `nil` nor a whole number of `0` or more.
function InventoryRequests.putDownInSlot(
	_world: World,
	player: PlayerState,
	side: unknown,
	slot: unknown,
	count: unknown
)
	local screen = findScreenWithSlot(player, side, slot)
	if screen ~= nil and isCountOrNil(count) then
		InventoryScreen.putDownInSlot(screen, side :: any, slot :: any, count :: any)
	end
end

--- Exchanges the carried stack with the stack in the slot `slot` on the side `side` of the open
--- screen, as `InventoryScreen.swapCarriedStackWithSlot` does. Does nothing if no screen is open,
--- if `side` and `slot` name no slot of it, or if the slot does not accept the carried item.
function InventoryRequests.swapCarriedStackWithSlot(_world: World, player: PlayerState, side: unknown, slot: unknown)
	local screen = findScreenWithSlot(player, side, slot)
	if screen ~= nil and InventoryScreen.canSwapCarriedStackWithSlot(screen, side :: any, slot :: any) then
		InventoryScreen.swapCarriedStackWithSlot(screen, side :: any, slot :: any)
	end
end

--- Exchanges the stacks in the slot `slot` on the side `side` and the slot `withSlot` on the side
--- `withSide` of the open screen, as `InventoryScreen.swapSlots` does. Does nothing if no screen
--- is open, if either pair names no slot of it, or if either slot does not accept the stack in the
--- other.
function InventoryRequests.swapSlots(
	_world: World,
	player: PlayerState,
	side: unknown,
	slot: unknown,
	withSide: unknown,
	withSlot: unknown
)
	local screen = findScreenWithSlot(player, side, slot)
	if screen == nil or not InventoryScreen.hasSlot(screen, withSide, withSlot) then
		return
	end
	if InventoryScreen.canSwapSlots(screen, side :: any, slot :: any, withSide :: any, withSlot :: any) then
		InventoryScreen.swapSlots(screen, side :: any, slot :: any, withSide :: any, withSlot :: any)
	end
end

--- Moves the stack in the slot `slot` on the side `side` of the open screen into the slots
--- `toFirstSlot` to `toLastSlot` on the side `toSide`, as `InventoryScreen.moveFromSlotToInventory`
--- does: it tops up the stacks of the same item there first, and then fills the slots that hold
--- nothing. What does not fit stays in the slot `slot`. Does nothing if no screen is open, or if
--- `side` and `slot`, `toSide` and `toFirstSlot`, or `toSide` and `toLastSlot` name no slot of it.
function InventoryRequests.moveFromSlotToInventory(
	_world: World,
	player: PlayerState,
	side: unknown,
	slot: unknown,
	toSide: unknown,
	toFirstSlot: unknown,
	toLastSlot: unknown
)
	local screen = findScreenWithSlot(player, side, slot)
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
	InventoryScreen.moveFromSlotToInventory(screen, side :: any, slot :: any, toSide :: any, toSlots)
end

--- Fills the carried stack with items of its own `itemId`, taken from the slots of the open screen,
--- as `InventoryScreen.fillCarriedStackFromAllSlots` does. Does nothing if no screen is open.
function InventoryRequests.fillCarriedStackFromAllSlots(_world: World, player: PlayerState)
	local screen = player.screen
	if screen ~= nil then
		InventoryScreen.fillCarriedStackFromAllSlots(screen)
	end
end

--- Puts the carried stack down across `slots`, as `InventoryScreen.spreadCarriedStackOverSlots`
--- does: `countEach` items in each slot, or an equal share if `countEach` is `nil`. `slots` is a
--- list of tables, each with a `side` and a `slot`. Does nothing if no screen is open, if `slots`
--- is not a list of slots of it, if it lists more entries than the screen has slots, or if
--- `countEach` is neither `nil` nor a whole number of `0` or more.
function InventoryRequests.spreadCarriedStackOverSlots(
	_world: World,
	player: PlayerState,
	slots: unknown,
	countEach: unknown
)
	local screen = player.screen
	if screen == nil or not InventoryScreen.hasEverySlot(screen, slots) or not isCountOrNil(countEach) then
		return
	end
	local list = slots :: { InventoryScreen.ScreenSlot }
	local other = screen.otherInventory
	if #list <= screen.pack.slotCount + (if other then other.slotCount else 0) then
		InventoryScreen.spreadCarriedStackOverSlots(screen, list, countEach :: any)
	end
end

--- Takes `count` items off the carried stack, or all of it if `count` is `nil`, and throws them
--- from the player's character the way `direction` points, as `World.throwStackFromCharacter`
--- does. Does nothing if no screen is open, if the player has no character, if `direction` is not
--- a direction, or if `count` is neither `nil` nor a whole number of `0` or more.
function InventoryRequests.dropCarriedStack(world: World, player: PlayerState, direction: unknown, count: unknown)
	local screen = player.screen
	local character = player.character
	local way = decodeDirection(direction)
	if screen ~= nil and character ~= nil and way ~= nil and isCountOrNil(count) then
		throwFromCharacter(world, InventoryScreen.takeCarriedStack(screen, count :: any), character, way)
	end
end

--- Takes `count` items out of the slot `slot` on the side `side` of the open screen, or everything
--- in the slot if `count` is `nil`, and throws them from the player's character the way
--- `direction` points, as `World.throwStackFromCharacter` does. Does nothing if no screen is open,
--- if `side` and `slot` name no slot of it, if the player has no character, if `direction` is not
--- a direction, or if `count` is neither `nil` nor a whole number of `0` or more.
function InventoryRequests.dropFromSlot(
	world: World,
	player: PlayerState,
	side: unknown,
	slot: unknown,
	direction: unknown,
	count: unknown
)
	local screen = findScreenWithSlot(player, side, slot)
	local character = player.character
	local way = decodeDirection(direction)
	if screen ~= nil and character ~= nil and way ~= nil and isCountOrNil(count) then
		local inventory = InventoryScreen.getInventoryOnSide(screen, side :: any)
		throwFromCharacter(world, Inventory.takeFromSlot(inventory, slot :: any, count :: any), character, way)
	end
end

--- Selects the slot `slot` of the player's hotbar. What it holds is then in the player's hand.
--- Does nothing if the hotbar has no such slot.
function InventoryRequests.selectHotbarSlot(_world: World, player: PlayerState, slot: unknown)
	if Hotbar.hasSlot(player.hotbar, slot) then
		Hotbar.selectSlot(player.hotbar, slot :: number)
	end
end

--- Takes `count` items out of the selected hotbar slot, or everything in the slot if `count` is
--- `nil`, and throws them from the player's character the way `direction` points, as
--- `World.throwStackFromCharacter` does. Does nothing if the player has no character, if
--- `direction` is not a direction, or if `count` is neither `nil` nor a whole number of `0` or
--- more.
function InventoryRequests.dropFromSelectedSlot(world: World, player: PlayerState, direction: unknown, count: unknown)
	local character = player.character
	local way = decodeDirection(direction)
	if character ~= nil and way ~= nil and isCountOrNil(count) then
		throwFromCharacter(world, Hotbar.takeFromSelectedSlot(player.hotbar, count :: any), character, way)
	end
end

return InventoryRequests
