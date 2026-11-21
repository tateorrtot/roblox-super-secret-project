--!strict
--- The requests that a client makes about its player's open inventories and hotbar.
---
--- Each function is one request. `Requests.carryOut` calls it with the `World`, then the
--- `PlayerState` of the player whose client sent the request, and then the values that the client
--- sent. Each of those values is typed `unknown`: a client can send a value of any type, so the
--- request checks every one before it uses it. A request whose values do not pass its checks does
--- nothing. Every request takes the `World`, also a request that does not read it, so that
--- `Requests.carryOut` calls them all the same way.
---
--- Most requests act on `player.screen`, the `InventoryScreen.InventoryScreen` that the player has
--- open. It has three fields that the requests use: `pack`, which is the same `Inventory` as
--- `player.pack`; `otherInventory`, which is a second `Inventory`, such as a crate's, or `nil`; and
--- `carriedStack`, which is an `ItemStack` that is in neither inventory, or `nil`. It holds state
--- and draws nothing. `openPack`, `selectHotbarSlot`, and `dropFromSelectedSlot` do not need
--- `player.screen`. Every other request does nothing while `player.screen` is `nil`. A player with
--- no character can open no screen and drop nothing.
---
--- Two values pick one slot: a `side` and a `slot`. `side` is an `InventoryScreen.Side`: `"pack"`
--- picks `player.screen.pack`, and `"other"` picks `player.screen.otherInventory`. `slot` is a slot
--- number in the inventory that `side` picks, from `1` to that inventory's `slotCount`.
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

--- Moves items from one slot of the player's open screen onto the stack that the player carries, as
--- `InventoryScreen.pickUpFromSlot` does. `side` and `slot` name the slot, and `side` is an
--- `InventoryScreen.Side`. Moves `count` items, or all that the slot holds if `count` is `nil`, but
--- never more than the carried stack has room for. Does nothing if no screen is open, if `side` and
--- `slot` name no slot of it, or if `count` is neither `nil` nor a whole number of `0` or more.
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

--- Moves items from the stack that the player carries into one slot of the player's open screen, as
--- `InventoryScreen.putDownInSlot` does. `side` and `slot` name the slot, and `side` is an
--- `InventoryScreen.Side`. Moves `count` items, or all that is carried if `count` is `nil`, but
--- never more than the slot has room for. Does nothing if no screen is open, if `side` and `slot`
--- name no slot of it, or if `count` is neither `nil` nor a whole number of `0` or more.
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

--- Exchanges the stack that the player carries with the stack in one slot of the player's open
--- screen, as `InventoryScreen.swapCarriedStackWithSlot` does. `side` and `slot` name the slot, and
--- `side` is an `InventoryScreen.Side`. Does nothing if no screen is open, if `side` and `slot`
--- name no slot of it, or if the slot does not accept the carried item.
function InventoryRequests.swapCarriedStackWithSlot(_world: World, player: PlayerState, side: unknown, slot: unknown)
	local screen = findScreenWithSlot(player, side, slot)
	if screen ~= nil and InventoryScreen.canSwapCarriedStackWithSlot(screen, side :: any, slot :: any) then
		InventoryScreen.swapCarriedStackWithSlot(screen, side :: any, slot :: any)
	end
end

--- Exchanges the stacks in two slots of the player's open screen, as `InventoryScreen.swapSlots`
--- does. `side` and `slot` name one slot, and `withSide` and `withSlot` name the other. `side` and
--- `withSide` are each an `InventoryScreen.Side`. Does nothing if no screen is open, if either pair
--- names no slot of it, or if either slot does not accept the stack in the other.
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

--- Moves the `ItemStack` in `slot` into the slots numbered from `toFirstSlot` to `toLastSlot`.
--- Fills those slots in order, and does not share the items out evenly between them. To share a
--- stack out, the request is `spreadCarriedStackOverSlots`, which takes the carried stack and a
--- list of slots.
--- - `player`: the player whose client sent the request. The request acts on `player.screen`.
--- - `side`: an `InventoryScreen.Side`, which is `"pack"` or `"other"`. It picks the inventory that
--- `slot` is in: `"pack"` picks `player.screen.pack`, and `"other"` picks
--- `player.screen.otherInventory`.
--- - `slot`: a `number`. A slot number in the inventory that `side` picks.
--- - `toSide`: an `InventoryScreen.Side`. It picks the inventory that the stack moves into, as
--- `side` does.
--- - `toFirstSlot`, `toLastSlot`: each a `number`. Slot numbers in the inventory that `toSide`
--- picks. The target slots are the slots numbered from `toFirstSlot` to `toLastSlot`, both
--- included.
---
--- Moves as many of the stack's `count` items as fit. First, adds items to each target slot that
--- holds an `ItemStack` with the same `itemId`, until that stack reaches its item's `stackSize`.
--- Then, puts the items that are left into the target slots that hold `nil`. Skips a target slot
--- that `InventoryScreen.slotAcceptsItem` returns `false` for, and skips `slot` itself if `side`
--- equals `toSide`. The items that do not fit stay in `slot`.
---
--- Does nothing if `player.screen` is `nil`, or if `InventoryScreen.hasSlot` returns `false` for
--- `side` and `slot`, for `toSide` and `toFirstSlot`, or for `toSide` and `toLastSlot`.
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

--- Puts the stack that the player carries down across several slots of the player's open screen, as
--- `InventoryScreen.spreadCarriedStackOverSlots` does: `countEach` items in each slot, or an equal
--- share if `countEach` is `nil`. `slots` is a list of tables, each an
--- `InventoryScreen.ScreenSlot`: a `side` and a `slot`. Does nothing if no screen is open, if
--- `slots` is not a list of slots of it, if it lists more entries than the screen has slots, or if
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

--- Takes items out of one slot of the player's open screen and throws them from the player's
--- character the way `direction` points, as `World.throwStackFromCharacter` does. `side` and `slot`
--- name the slot, and `side` is an `InventoryScreen.Side`. Takes `count` items, or everything in
--- the slot if `count` is `nil`. Does nothing if no screen is open, if `side` and `slot` name no
--- slot of it, if the player has no character, if `direction` is not a direction, or if `count` is
--- neither `nil` nor a whole number of `0` or more.
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

--- Selects `slot` of the player's hotbar. What it holds is then in the player's hand. Does nothing
--- if the hotbar has no such slot.
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
