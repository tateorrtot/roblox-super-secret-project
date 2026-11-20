--!strict
--- What a player's machine may ask for about the inventories on the player's screen, and their
--- hotbar.
---
--- Each function is one request. `world` is the world and `player` is the player who asks. Every
--- argument after them is what the player's machine sent, and may be any value at all. A request
--- that makes no sense for the player as they are now does nothing. A player with no character
--- can open no screen and drop nothing.
---
--- A request that drops takes a `direction`: the way the stack is thrown, chosen by the player's
--- machine. It is a table with numbers from -1 to 1 under `x`, `y` and `z`, not all 0, where `y`
--- is upwards. Only the way it points counts, not its length.
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

local function toDirection(sent: unknown): Direction.Direction?
	if type(sent) ~= "table" then
		return nil
	end
	local x, y, z = (sent :: any).x, (sent :: any).y, (sent :: any).z
	local isInRange = isFromMinusOneToOne(x) and isFromMinusOneToOne(y) and isFromMinusOneToOne(z)
	return if isInRange then Direction.new(x, y, z) else nil
end

local function screenWithSlot(player: PlayerState, side: unknown, slot: unknown): InventoryScreen?
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

--- Opens the player's inventory screen on their pack alone. Does nothing if they have a screen
--- open or have no character.
function InventoryRequests.openPack(_world: World, player: PlayerState)
	if PlayerState.canOpenScreen(player) then
		PlayerState.openPackScreen(player)
	end
end

--- Closes the player's inventory screen. The stack they were carrying goes back into their pack,
--- and what does not fit is dropped into the world at their character.
function InventoryRequests.closeScreen(world: World, player: PlayerState)
	World.closeScreen(world, player)
end

--- Moves up to `count` items from a slot of the open screen onto the carried stack, or as many
--- as the carried stack has room for if `count` is `nil`.
function InventoryRequests.pickUpFromSlot(
	_world: World,
	player: PlayerState,
	side: unknown,
	slot: unknown,
	count: unknown
)
	local screen = screenWithSlot(player, side, slot)
	if screen ~= nil and isCountOrNil(count) then
		InventoryScreen.pickUpFromSlot(screen, side :: any, slot :: any, count :: any)
	end
end

--- Moves up to `count` items from the carried stack into a slot of the open screen, or as many
--- as the slot has room for if `count` is `nil`.
function InventoryRequests.putDownInSlot(
	_world: World,
	player: PlayerState,
	side: unknown,
	slot: unknown,
	count: unknown
)
	local screen = screenWithSlot(player, side, slot)
	if screen ~= nil and isCountOrNil(count) then
		InventoryScreen.putDownInSlot(screen, side :: any, slot :: any, count :: any)
	end
end

--- Exchanges the carried stack with the stack in a slot of the open screen. Does nothing if the
--- slot does not accept the carried item.
function InventoryRequests.swapCarriedStackWithSlot(_world: World, player: PlayerState, side: unknown, slot: unknown)
	local screen = screenWithSlot(player, side, slot)
	if screen ~= nil and InventoryScreen.canSwapCarriedStackWithSlot(screen, side :: any, slot :: any) then
		InventoryScreen.swapCarriedStackWithSlot(screen, side :: any, slot :: any)
	end
end

--- Exchanges the stacks in two slots of the open screen. Does nothing if either slot does not
--- accept the stack in the other.
function InventoryRequests.swapSlots(
	_world: World,
	player: PlayerState,
	side: unknown,
	slot: unknown,
	withSide: unknown,
	withSlot: unknown
)
	local screen = screenWithSlot(player, side, slot)
	if screen == nil or not InventoryScreen.hasSlot(screen, withSide, withSlot) then
		return
	end
	if InventoryScreen.canSwapSlots(screen, side :: any, slot :: any, withSide :: any, withSlot :: any) then
		InventoryScreen.swapSlots(screen, side :: any, slot :: any, withSide :: any, withSlot :: any)
	end
end

--- Moves the stack in a slot of the open screen into the slots `toFirstSlot` to `toLastSlot` of
--- the inventory on `toSide`: stacks of the same item are topped up first, then slots that hold
--- nothing are filled, and what does not fit stays where it was.
function InventoryRequests.moveFromSlotToInventory(
	_world: World,
	player: PlayerState,
	side: unknown,
	slot: unknown,
	toSide: unknown,
	toFirstSlot: unknown,
	toLastSlot: unknown
)
	local screen = screenWithSlot(player, side, slot)
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

--- Fills the carried stack with items of its kind taken from the slots of the open screen.
function InventoryRequests.fillCarriedStackFromAllSlots(_world: World, player: PlayerState)
	local screen = player.screen
	if screen ~= nil then
		InventoryScreen.fillCarriedStackFromAllSlots(screen)
	end
end

--- Puts the carried stack down across `slots`, a list of slots of the open screen: `countEach`
--- items in each, or an equal share in each if `countEach` is `nil`. Does nothing if `slots` lists
--- more slots than the screen has.
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

--- Drops up to `count` items of the carried stack, or all of it if `count` is `nil`: they are
--- thrown into the world from the player's character, the way `direction` points.
function InventoryRequests.dropCarriedStack(world: World, player: PlayerState, direction: unknown, count: unknown)
	local screen = player.screen
	local character = player.character
	local way = toDirection(direction)
	if screen ~= nil and character ~= nil and way ~= nil and isCountOrNil(count) then
		throwFromCharacter(world, InventoryScreen.takeCarriedStack(screen, count :: any), character, way)
	end
end

--- Drops up to `count` items out of a slot of the open screen, or everything in the slot if
--- `count` is `nil`: they are thrown into the world from the player's character, the way
--- `direction` points.
function InventoryRequests.dropFromSlot(
	world: World,
	player: PlayerState,
	side: unknown,
	slot: unknown,
	direction: unknown,
	count: unknown
)
	local screen = screenWithSlot(player, side, slot)
	local character = player.character
	local way = toDirection(direction)
	if screen ~= nil and character ~= nil and way ~= nil and isCountOrNil(count) then
		local inventory = InventoryScreen.getInventoryOnSide(screen, side :: any)
		throwFromCharacter(world, Inventory.takeFromSlot(inventory, slot :: any, count :: any), character, way)
	end
end

--- Selects a slot of the player's hotbar. What it holds is then in the player's hand.
function InventoryRequests.selectHotbarSlot(_world: World, player: PlayerState, slot: unknown)
	if Hotbar.hasSlot(player.hotbar, slot) then
		Hotbar.selectSlot(player.hotbar, slot :: number)
	end
end

--- Drops up to `count` items out of the selected hotbar slot, or everything in the slot if
--- `count` is `nil`: they are thrown into the world from the player's character, the way
--- `direction` points.
function InventoryRequests.dropFromSelectedSlot(world: World, player: PlayerState, direction: unknown, count: unknown)
	local character = player.character
	local way = toDirection(direction)
	if character ~= nil and way ~= nil and isCountOrNil(count) then
		throwFromCharacter(world, Hotbar.takeFromSelectedSlot(player.hotbar, count :: any), character, way)
	end
end

return InventoryRequests
