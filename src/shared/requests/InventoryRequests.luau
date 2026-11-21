--!strict
--- The requests that a client makes about its player's open inventories and hotbar.
---
--- Each function is one request. `Requests.carryOut` calls it with the `World`, then the
--- `PlayerState` of the player whose client sent the request, and then the values that the client
--- sent. Each of those values is a `Variant`: a client can send a value of any type, so the request
--- checks every one before it uses it. A request whose values do not pass its checks does nothing.
--- Every request takes the `World`, also a request that does not read it, so that
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
--- A client cannot send an `Inventory`, so it sends a `Side`: `"pack"` picks `player.screen.pack`,
--- and `"other"` picks `player.screen.otherInventory`. The request turns the `Side` into that
--- `Inventory`, and every function that it then calls takes the `Inventory` itself. A `slot` is a
--- slot number in the inventory that the `Side` picks, from `1` to that inventory's `slotCount`.
---
--- A request that drops takes a `direction`: the way to throw the items. It is a table with numbers
--- from `-1` to `1` under `x`, `y`, and `z`, not all `0`, where `y` is upwards. Only the way it
--- points counts, not its length.
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

--- The word that a client sends for one of the two inventories of `player.screen`: `"pack"` for
--- `player.screen.pack`, or `"other"` for `player.screen.otherInventory`. Only the requests know
--- the word.
export type Side = "pack" | "other"

--- A value that a client sent. It may be of any type, whatever `T` says: `T` is the type that the
--- request checks for before it uses the value.
export type Variant<T> = unknown

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

local function findInventoryOnSide(screen: InventoryScreen, side: unknown): Inventory.Inventory?
	if side == "pack" then
		return screen.pack
	end
	return if side == "other" then screen.otherInventory else nil
end

local function findInventoryWithSlot(player: PlayerState, side: unknown, slot: unknown): Inventory.Inventory?
	local screen = player.screen
	local inventory = if screen ~= nil then findInventoryOnSide(screen, side) else nil
	return if inventory ~= nil and Inventory.hasSlot(inventory, slot) then inventory else nil
end

local function decodeScreenSlots(screen: InventoryScreen, slots: unknown): { InventoryScreen.ScreenSlot }?
	if type(slots) ~= "table" then
		return nil
	end
	local other = screen.otherInventory
	local most = screen.pack.slotCount + (if other then other.slotCount else 0)
	local keys = 0
	for _ in slots :: { [unknown]: unknown } do
		keys += 1
		if keys > most then
			return nil
		end
	end
	local screenSlots = {}
	for index = 1, keys do
		local sent = (slots :: { unknown })[index]
		local inventory = if type(sent) == "table" then findInventoryOnSide(screen, (sent :: any).side) else nil
		if inventory == nil or not Inventory.hasSlot(inventory, (sent :: any).slot) then
			return nil
		end
		table.insert(screenSlots, { inventory = inventory, slot = (sent :: any).slot })
	end
	return screenSlots
end

local function isListOfSlots(inventory: Inventory.Inventory, slots: unknown): boolean
	if type(slots) ~= "table" then
		return false
	end
	local keys = 0
	for _ in slots :: { [unknown]: unknown } do
		keys += 1
		if keys > inventory.slotCount then
			return false
		end
	end
	for index = 1, keys do
		if not Inventory.hasSlot(inventory, (slots :: { unknown })[index]) then
			return false
		end
	end
	return true
end

local function getSlotsAccepting(
	screen: InventoryScreen,
	inventory: Inventory.Inventory,
	slots: { number },
	itemId: string
): { number }
	local accepting = {}
	for _, slot in slots do
		if InventoryScreen.slotAcceptsItem(screen, inventory, slot, itemId) then
			table.insert(accepting, slot)
		end
	end
	return accepting
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

--- Opens `player.screen` on `player.pack` alone, as `PlayerState.openScreen` does.
--- - `player`: the `PlayerState` of the player whose client sent the request.
---
--- Does nothing if `PlayerState.canOpenScreen` returns `false` for `player`: `player.screen` is not
--- `nil`, or `player.character` is `nil`.
function InventoryRequests.openPack(_world: World, player: PlayerState)
	if PlayerState.canOpenScreen(player) then
		PlayerState.openScreen(player)
	end
end

--- Closes `player.screen`, as `World.closeScreen` does. Adds `player.screen.carriedStack` to
--- `player.pack`, and spawns the items that do not fit as a `GroundItems.GroundItem`,
--- `World.CHARACTER_THROW_START_HEIGHT` above `player.character.position`.
--- - `world`: the `World` that the `GroundItems.GroundItem` spawns in.
--- - `player`: the `PlayerState` of the player whose client sent the request.
---
--- Does nothing if `player.screen` is `nil`.
function InventoryRequests.closeScreen(world: World, player: PlayerState)
	World.closeScreen(world, player)
end

--- Moves items from the `ItemStack` in `slot` onto `player.screen.carriedStack`, as
--- `InventoryScreen.pickUpFromSlot` does.
--- - `player`: the `PlayerState` of the player whose client sent the request.
--- - `side`: a `Side`, which is `"pack"` or `"other"`. It picks the inventory that `slot` is in:
--- `"pack"` picks `player.screen.pack`, and `"other"` picks `player.screen.otherInventory`.
--- - `slot`: a `number`. A slot number in the inventory that `side` picks, from `1` to that
--- inventory's `slotCount`.
--- - `count`: a whole `number` of `0` or more, or `nil`. How many items to move. `nil` moves every
--- item in `slot`.
---
--- Does nothing if `player.screen` is `nil`, if `side` picks no inventory, if `Inventory.hasSlot`
--- returns `false` for that inventory and `slot`, or if `count` is neither `nil` nor a whole number
--- of `0` or more.
function InventoryRequests.pickUpFromSlot(
	_world: World,
	player: PlayerState,
	side: Variant<Side>,
	slot: Variant<number>,
	count: Variant<number?>
)
	local screen = player.screen
	local inventory = findInventoryWithSlot(player, side, slot)
	if screen ~= nil and inventory ~= nil and isCountOrNil(count) then
		InventoryScreen.pickUpFromSlot(screen, inventory, slot :: any, count :: any)
	end
end

--- Moves items from `player.screen.carriedStack` into `slot`, as `InventoryScreen.putDownInSlot`
--- does.
--- - `player`: the `PlayerState` of the player whose client sent the request.
--- - `side`: a `Side`, which is `"pack"` or `"other"`. It picks the inventory that `slot` is in:
--- `"pack"` picks `player.screen.pack`, and `"other"` picks `player.screen.otherInventory`.
--- - `slot`: a `number`. A slot number in the inventory that `side` picks, from `1` to that
--- inventory's `slotCount`.
--- - `count`: a whole `number` of `0` or more, or `nil`. How many items to move. `nil` moves every
--- item of `player.screen.carriedStack`.
---
--- Does nothing if `player.screen` is `nil`, if `side` picks no inventory, if `Inventory.hasSlot`
--- returns `false` for that inventory and `slot`, or if `count` is neither `nil` nor a whole number
--- of `0` or more.
function InventoryRequests.putDownInSlot(
	_world: World,
	player: PlayerState,
	side: Variant<Side>,
	slot: Variant<number>,
	count: Variant<number?>
)
	local screen = player.screen
	local inventory = findInventoryWithSlot(player, side, slot)
	if screen ~= nil and inventory ~= nil and isCountOrNil(count) then
		InventoryScreen.putDownInSlot(screen, inventory, slot :: any, count :: any)
	end
end

--- Exchanges `player.screen.carriedStack` with the `ItemStack` in `slot`, as
--- `InventoryScreen.swapCarriedStackWithSlot` does. Either may be `nil`.
--- - `player`: the `PlayerState` of the player whose client sent the request.
--- - `side`: a `Side`, which is `"pack"` or `"other"`. It picks the inventory that `slot` is in:
--- `"pack"` picks `player.screen.pack`, and `"other"` picks `player.screen.otherInventory`.
--- - `slot`: a `number`. A slot number in the inventory that `side` picks, from `1` to that
--- inventory's `slotCount`.
---
--- Does nothing if `player.screen` is `nil`, if `side` picks no inventory, if `Inventory.hasSlot`
--- returns `false` for that inventory and `slot`, or if
--- `InventoryScreen.canSwapCarriedStackWithSlot` returns `false` for that inventory and `slot`.
function InventoryRequests.swapCarriedStackWithSlot(
	_world: World,
	player: PlayerState,
	side: Variant<Side>,
	slot: Variant<number>
)
	local screen = player.screen
	local inventory = findInventoryWithSlot(player, side, slot)
	if screen == nil or inventory == nil then
		return
	end
	if InventoryScreen.canSwapCarriedStackWithSlot(screen, inventory, slot :: any) then
		InventoryScreen.swapCarriedStackWithSlot(screen, inventory, slot :: any)
	end
end

--- Exchanges the `ItemStack` in `slot` with the `ItemStack` in `withSlot`. Either slot may hold
--- `nil`. It calls `Inventory.getStack` for each slot, and then `Inventory.setStack` for each.
--- - `player`: the `PlayerState` of the player whose client sent the request.
--- - `side`: a `Side`, which is `"pack"` or `"other"`. It picks the inventory that `slot` is in:
--- `"pack"` picks `player.screen.pack`, and `"other"` picks `player.screen.otherInventory`.
--- - `slot`: a `number`. A slot number in the inventory that `side` picks, from `1` to that
--- inventory's `slotCount`.
--- - `withSide`: a `Side`. It picks the inventory that `withSlot` is in, as `side` does.
--- - `withSlot`: a `number`. A slot number in the inventory that `withSide` picks.
---
--- Does nothing if `player.screen` is `nil`, if `side` or `withSide` picks no inventory, if
--- `Inventory.hasSlot` returns `false` for either inventory and its slot, or if
--- `InventoryScreen.canSwapSlots` returns `false` for the two slots.
function InventoryRequests.swapSlots(
	_world: World,
	player: PlayerState,
	side: Variant<Side>,
	slot: Variant<number>,
	withSide: Variant<Side>,
	withSlot: Variant<number>
)
	local screen = player.screen
	local inventory = findInventoryWithSlot(player, side, slot)
	local withInventory = findInventoryWithSlot(player, withSide, withSlot)
	if screen == nil or inventory == nil or withInventory == nil then
		return
	end
	if InventoryScreen.canSwapSlots(screen, inventory, slot :: any, withInventory, withSlot :: any) then
		local stack = Inventory.getStack(inventory, slot :: any)
		Inventory.setStack(inventory, slot :: any, Inventory.getStack(withInventory, withSlot :: any))
		Inventory.setStack(withInventory, withSlot :: any, stack)
	end
end

--- Takes the `ItemStack` out of `slot`, and adds it to the slots in `toSlots`. It calls
--- `Inventory.takeFromSlot`, then `Inventory.addStack`, and then `Inventory.putInSlot` for the
--- items that did not fit.
--- - `player`: the `PlayerState` of the player whose client sent the request.
--- - `side`: a `Side`, which is `"pack"` or `"other"`. It picks the inventory that `slot` is in:
--- `"pack"` picks `player.screen.pack`, and `"other"` picks `player.screen.otherInventory`.
--- - `slot`: a `number`. A slot number in the inventory that `side` picks, from `1` to that
--- inventory's `slotCount`.
--- - `toSide`: a `Side`. It picks the inventory that the `ItemStack` is added to, as `side` does.
--- - `toSlots`: a list of `number`s. Slot numbers in the inventory that `toSide` picks.
--- `Inventory.addStack` uses only these slots, in this order.
---
--- `Inventory.addStack` adds as many `count` items of that `ItemStack` as fit: first to each slot
--- in `toSlots` that holds an `ItemStack` with the same `itemId`, and then to each slot in
--- `toSlots` that holds `nil`. The request leaves out each slot in `toSlots` that
--- `InventoryScreen.slotAcceptsItem` returns `false` for. `Inventory.putInSlot` puts the items that
--- did not fit back in `slot`. If `side` equals `toSide` and `toSlots` lists `slot`, items can go
--- back into `slot`.
---
--- Does nothing if `player.screen` is `nil`, if `side` picks no inventory, if `Inventory.hasSlot`
--- returns `false` for that inventory and `slot`, if `slot` holds `nil`, if `toSide` picks no
--- inventory, or if `toSlots` is not a list of slot numbers of the inventory that `toSide` picks. A
--- list with more entries than that inventory has slots is not such a list.
function InventoryRequests.moveFromSlotToInventory(
	_world: World,
	player: PlayerState,
	side: Variant<Side>,
	slot: Variant<number>,
	toSide: Variant<Side>,
	toSlots: Variant<{ number }>
)
	local screen = player.screen
	local from = findInventoryWithSlot(player, side, slot)
	local to = if screen ~= nil then findInventoryOnSide(screen, toSide) else nil
	if screen == nil or from == nil or to == nil or not isListOfSlots(to, toSlots) then
		return
	end
	local stack = Inventory.getStack(from, slot :: any)
	if stack == nil then
		return
	end
	local accepting = getSlotsAccepting(screen, to, toSlots :: any, stack.itemId)
	Inventory.takeFromSlot(from, slot :: any)
	local leftover = Inventory.addStack(to, stack, accepting)
	if leftover ~= nil then
		Inventory.putInSlot(from, slot :: any, leftover)
	end
end

--- Adds items to `player.screen.carriedStack` from every slot of `player.screen.pack` and
--- `player.screen.otherInventory` that holds an `ItemStack` with the same `itemId` as
--- `player.screen.carriedStack`, as `InventoryScreen.fillCarriedStackFromAllSlots` does. Stops when
--- `player.screen.carriedStack` reaches the `stackSize` of its `ItemRegistry.ItemDefinition`.
--- - `player`: the `PlayerState` of the player whose client sent the request.
---
--- Does nothing if `player.screen` is `nil`, or if `player.screen.carriedStack` is `nil`.
function InventoryRequests.fillCarriedStackFromAllSlots(_world: World, player: PlayerState)
	local screen = player.screen
	if screen ~= nil then
		InventoryScreen.fillCarriedStackFromAllSlots(screen)
	end
end

--- Puts items of `player.screen.carriedStack` into the slots in `slots`, as
--- `InventoryScreen.spreadCarriedStackOverSlots` does.
--- - `player`: the `PlayerState` of the player whose client sent the request.
--- - `slots`: a list of tables. Each has a `side`, which is a `Side`, and a `slot`, which is a slot
--- number in the inventory that its `side` picks.
--- - `countEach`: a whole `number` of `0` or more, or `nil`. How many items to put in each slot.
--- `nil` gives each slot an equal share of the `count` of `player.screen.carriedStack`, rounded
--- down. `InventoryScreen.spreadCarriedStackOverSlots` says which of the slots in `slots` get
--- items.
---
--- The items that are not put down stay in `player.screen.carriedStack`.
---
--- Does nothing if `player.screen` is `nil`, if `slots` is not such a list, if `slots` has more
--- entries than `player.screen.pack` and `player.screen.otherInventory` have slots together, or if
--- `countEach` is neither `nil` nor a whole number of `0` or more.
function InventoryRequests.spreadCarriedStackOverSlots(
	_world: World,
	player: PlayerState,
	slots: Variant<{ { side: Side, slot: number } }>,
	countEach: Variant<number?>
)
	local screen = player.screen
	local screenSlots = if screen ~= nil then decodeScreenSlots(screen, slots) else nil
	if screen ~= nil and screenSlots ~= nil and isCountOrNil(countEach) then
		InventoryScreen.spreadCarriedStackOverSlots(screen, screenSlots, countEach :: any)
	end
end

--- Takes items off `player.screen.carriedStack`, as `InventoryScreen.takeCarriedStack` does, and
--- throws them from `World.CHARACTER_THROW_START_HEIGHT` above `player.character.position`, as
--- `World.throwStackFromCharacter` does.
--- - `world`: the `World` that the thrown items spawn in.
--- - `player`: the `PlayerState` of the player whose client sent the request.
--- - `direction`: a table with a `number` from `-1` to `1` under each of `x`, `y`, and `z`, not all
--- `0`. The way to throw the items. `y` is upwards. Only the way that the three numbers point
--- counts, not how large they are.
--- - `count`: a whole `number` of `0` or more, or `nil`. How many items to take. `nil` takes every
--- item of `player.screen.carriedStack`.
---
--- Throws nothing if `player.screen.carriedStack` is `nil`.
---
--- Does nothing if `player.screen` is `nil`, if `player.character` is `nil`, if `direction` is not
--- such a table, or if `count` is neither `nil` nor a whole number of `0` or more.
function InventoryRequests.dropCarriedStack(
	world: World,
	player: PlayerState,
	direction: Variant<Direction.Direction>,
	count: Variant<number?>
)
	local screen = player.screen
	local character = player.character
	local way = decodeDirection(direction)
	if screen ~= nil and character ~= nil and way ~= nil and isCountOrNil(count) then
		throwFromCharacter(world, InventoryScreen.takeCarriedStack(screen, count :: any), character, way)
	end
end

--- Takes items out of `slot`, as `Inventory.takeFromSlot` does, and throws them from
--- `World.CHARACTER_THROW_START_HEIGHT` above `player.character.position`, as
--- `World.throwStackFromCharacter` does.
--- - `world`: the `World` that the thrown items spawn in.
--- - `player`: the `PlayerState` of the player whose client sent the request.
--- - `side`: a `Side`, which is `"pack"` or `"other"`. It picks the inventory that `slot` is in:
--- `"pack"` picks `player.screen.pack`, and `"other"` picks `player.screen.otherInventory`.
--- - `slot`: a `number`. A slot number in the inventory that `side` picks, from `1` to that
--- inventory's `slotCount`.
--- - `direction`: a table with a `number` from `-1` to `1` under each of `x`, `y`, and `z`, not all
--- `0`. The way to throw the items. `y` is upwards. Only the way that the three numbers point
--- counts, not how large they are.
--- - `count`: a whole `number` of `0` or more, or `nil`. How many items to take. `nil` takes every
--- item in `slot`.
---
--- Throws nothing if `slot` holds `nil`.
---
--- Does nothing if `player.screen` is `nil`, if `side` picks no inventory, if `Inventory.hasSlot`
--- returns `false` for that inventory and `slot`, if `player.character` is `nil`, if `direction` is
--- not such a table, or if `count` is neither `nil` nor a whole number of `0` or more.
function InventoryRequests.dropFromSlot(
	world: World,
	player: PlayerState,
	side: Variant<Side>,
	slot: Variant<number>,
	direction: Variant<Direction.Direction>,
	count: Variant<number?>
)
	local inventory = findInventoryWithSlot(player, side, slot)
	local character = player.character
	local way = decodeDirection(direction)
	if inventory ~= nil and character ~= nil and way ~= nil and isCountOrNil(count) then
		throwFromCharacter(world, Inventory.takeFromSlot(inventory, slot :: any, count :: any), character, way)
	end
end

--- Sets `player.hotbar.selectedSlot` to `slot`, as `Hotbar.selectSlot` does.
--- - `player`: the `PlayerState` of the player whose client sent the request.
--- - `slot`: a `number`. A slot number of `player.hotbar`, from `1` to `player.hotbar.slotCount`.
---
--- Does nothing if `Hotbar.hasSlot` returns `false` for `slot`.
function InventoryRequests.selectHotbarSlot(_world: World, player: PlayerState, slot: Variant<number>)
	if Hotbar.hasSlot(player.hotbar, slot) then
		Hotbar.selectSlot(player.hotbar, slot :: number)
	end
end

--- Takes items out of the slot `player.hotbar.selectedSlot` of `player.hotbar.inventory`, as
--- `Hotbar.takeFromSelectedSlot` does, and throws them from `World.CHARACTER_THROW_START_HEIGHT`
--- above `player.character.position`, as `World.throwStackFromCharacter` does.
--- - `world`: the `World` that the thrown items spawn in.
--- - `player`: the `PlayerState` of the player whose client sent the request.
--- - `direction`: a table with a `number` from `-1` to `1` under each of `x`, `y`, and `z`, not all
--- `0`. The way to throw the items. `y` is upwards. Only the way that the three numbers point
--- counts, not how large they are.
--- - `count`: a whole `number` of `0` or more, or `nil`. How many items to take. `nil` takes every
--- item in that slot.
---
--- Throws nothing if that slot holds `nil`.
---
--- Does nothing if `player.character` is `nil`, if `direction` is not such a table, or if `count`
--- is neither `nil` nor a whole number of `0` or more.
function InventoryRequests.dropFromSelectedSlot(
	world: World,
	player: PlayerState,
	direction: Variant<Direction.Direction>,
	count: Variant<number?>
)
	local character = player.character
	local way = decodeDirection(direction)
	if character ~= nil and way ~= nil and isCountOrNil(count) then
		throwFromCharacter(world, Hotbar.takeFromSelectedSlot(player.hotbar, count :: any), character, way)
	end
end

return InventoryRequests
