--!strict
--[=[
	A placed item that works on what is put into it, as a Minecraft furnace
	does: a stove with a fish and a log in it turns out a cooked fish.

	A station has three slots. `Station.INPUT_SLOT` holds what is to be worked
	on, `Station.FUEL_SLOT` holds what will burn, and `Station.OUTPUT_SLOT` is
	where what has been made collects. What a station makes is decided by the
	recipes registered for its item in RecipeRegistry, and how long an item
	burns by that item's `burnSeconds`.

	[method step] moves a station on by some seconds:
	- It works only while its fire burns. When the fire is out, it lights
	  again by using up one item of fuel, but only if there is something it
	  can work on. A fire is never lit for nothing.
	- Once lit, a fire burns its fuel out whether or not there is work left.
	- While the fire burns, the item in the input slot is worked on. When it
	  has been worked on for as long as its recipe says, one of it becomes one
	  of the recipe's output, in the output slot.
	- Nothing can be worked on if the input slot holds nothing, if the station
	  has no recipe for what it holds, or if the output slot has no room for
	  what would be made. Work already done on an item is lost if the fire
	  goes out for want of fuel, or if a step finds a different item in the
	  input slot, or none.

	A station holds the inventory it is given, which is the placed item's own.
	Players put things in and take them out through an InventorySession opened
	with [method slotRules].

	This is the rules only. It draws nothing.

	```lua
	local station = Station.new("stove", stoveInventory) -- a fish in slot 1, a log in slot 2
	Station.step(station, 8)
	Inventory.getStack(stoveInventory, Station.OUTPUT_SLOT) --> 1 cooked fish
	Station.isBurning(station) --> true: the log burns for 8 seconds more
	```
]=]
local Inventory = require("../inventory/Inventory")
local InventorySession = require("../inventory/InventorySession")
local ItemRegistry = require("../items/ItemRegistry")
local ItemStack = require("../items/ItemStack")
local RecipeRegistry = require("./RecipeRegistry")

local Station = {}

type Inventory = Inventory.Inventory

--- `read` means code outside this module cannot assign the field. [method step] changes the last three.
export type Station = {
	--- The id of the item this station is, such as `"stove"`. Its recipes are the ones registered for that item.
	read itemId: string,
	--- Its three slots.
	read inventory: Inventory,
	--- How many seconds longer the fuel now burning will burn. 0 when the fire is out.
	read burnLeft: number,
	--- How many seconds the item of fuel now burning burns in all. 0 until a fire has been lit.
	read burnTotal: number,
	--- How many seconds the item in the input slot has been worked on. 0 when nothing is being worked on.
	read worked: number,
	--- The id of the item that work was done on, or `nil` when nothing is being worked on.
	read workingOn: string?,
}

--- What a player's machine is told about a station, to draw its two gauges. Plain data.
export type StationView = {
	--- How much of the fuel now burning is left, from 1 just lit to 0 burnt out.
	burning: number,
	--- How far the item in the input slot is from done, from 0 not begun to 1 done.
	working: number,
}

--- The slot that holds what is to be worked on.
Station.INPUT_SLOT = 1

--- The slot that holds fuel.
Station.FUEL_SLOT = 2

--- The slot where what has been made collects.
Station.OUTPUT_SLOT = 3

-- Two times closer together than this, in seconds, are taken to be the same time.
local SAME_TIME = 1e-9

--[=[
	Returns a new station of the kind `itemId` over `inventory`, with no fire
	and nothing worked on.

	Raises an error if no recipe is registered for `itemId`, or if `inventory`
	does not have exactly three slots.
]=]
function Station.new(itemId: string, inventory: Inventory): Station
	if not RecipeRegistry.isStation(itemId) then
		error(string.format('Station.new: "%s" is not a station; no recipe is registered for it', tostring(itemId)), 2)
	end
	if inventory.slotCount ~= RecipeRegistry.STATION_SLOTS then
		error(
			string.format(
				"Station.new: a station's inventory has %d slots; got one with %d",
				RecipeRegistry.STATION_SLOTS,
				inventory.slotCount
			),
			2
		)
	end
	return { itemId = itemId, inventory = inventory, burnLeft = 0, burnTotal = 0, worked = 0 }
end

--[=[
	Returns `true` if the station's fire is burning.
]=]
function Station.isBurning(station: Station): boolean
	return station.burnLeft > 0
end

--[=[
	Returns the recipe the station can work on now: the one for the item in
	its input slot, if the output slot has room for what that makes. Returns
	`nil` if the input slot holds nothing, if the station has no recipe for
	what it holds, or if the output slot holds something else or is full.

	Whether the fire is burning makes no difference to this.
]=]
function Station.recipe(station: Station): RecipeRegistry.Recipe?
	local input = Inventory.getStack(station.inventory, Station.INPUT_SLOT)
	if input == nil then
		return nil
	end
	local recipe = RecipeRegistry.find(station.itemId, input.itemId)
	if recipe == nil then
		return nil
	end
	local output = Inventory.getStack(station.inventory, Station.OUTPUT_SLOT)
	if output ~= nil and (output.itemId ~= recipe.output or ItemStack.isFull(output)) then
		return nil
	end
	return recipe
end

--[=[
	Moves the station on by `seconds`: its fire burns, its fuel is used, and
	what is in its input slot is worked on, as the top of this file describes.

	One long step ends as many short steps of the same total would. A step of
	0 does nothing.

	Raises an error if `seconds` is not a number of 0 or more.
]=]
function Station.step(station: Station, seconds: number)
	if type(seconds) ~= "number" or not (seconds >= 0) or seconds == math.huge then
		error(string.format("Station.step: seconds must be a number, 0 or more; got %s", tostring(seconds)), 2)
	end
	local writable = station :: any
	local inventory = station.inventory
	local left = seconds
	while left > 0 do
		local recipe = Station.recipe(station)
		local workingOn = if recipe ~= nil then recipe.input else nil
		if workingOn ~= station.workingOn then
			-- A different item is in the input slot, or nothing that can be worked on: the work done before is lost.
			writable.workingOn = workingOn
			writable.worked = 0
		end
		if station.burnLeft <= 0 then
			-- The fire is out. It is lit again only if there is something to work on and something to burn.
			local fuel = Inventory.getStack(inventory, Station.FUEL_SLOT)
			local burnSeconds = if fuel ~= nil then ItemRegistry.get(fuel.itemId).burnSeconds else nil
			if recipe == nil or burnSeconds == nil then
				writable.worked = 0
				writable.workingOn = nil
				return
			end
			Inventory.takeFromSlot(inventory, Station.FUEL_SLOT, 1)
			writable.burnLeft = burnSeconds
			writable.burnTotal = burnSeconds
		end

		-- The fire burns on until it goes out, the item is done, or the time is up, whichever comes first.
		local advance = math.min(left, station.burnLeft)
		if recipe ~= nil then
			advance = math.min(advance, recipe.seconds - station.worked)
		end
		left -= advance
		writable.burnLeft = station.burnLeft - advance
		if recipe ~= nil then
			writable.worked = station.worked + advance
			if station.worked >= recipe.seconds - SAME_TIME then
				Inventory.takeFromSlot(inventory, Station.INPUT_SLOT, 1)
				Inventory.putInSlot(inventory, Station.OUTPUT_SLOT, ItemStack.new(recipe.output, 1))
				writable.worked = 0
			end
		end
	end
end

--[=[
	Returns which items each slot of a station of the kind `itemId` takes,
	for `InventorySession.open`: the input slot takes the items that station
	has recipes for, the fuel slot takes every item that burns, and the
	output slot takes nothing, since only the station puts things there.

	Raises an error if no recipe is registered for `itemId`.
]=]
function Station.slotRules(itemId: string): InventorySession.SlotRules
	if not RecipeRegistry.isStation(itemId) then
		error(
			string.format('Station.slotRules: "%s" is not a station; no recipe is registered for it', tostring(itemId)),
			2
		)
	end
	local inputs: { [string]: boolean } = {}
	for _, input in RecipeRegistry.inputsOf(itemId) do
		inputs[input] = true
	end
	local fuels: { [string]: boolean } = {}
	for _, definition in ItemRegistry.all() do
		if definition.burnSeconds ~= nil then
			fuels[definition.id] = true
		end
	end
	return {
		[Station.INPUT_SLOT] = inputs,
		[Station.FUEL_SLOT] = fuels,
		[Station.OUTPUT_SLOT] = {},
	}
end

--[=[
	Returns what to tell a player's machine about the station, as plain data:
	how much of the burning fuel is left, and how far the work on the item in
	the input slot has got, each as a number from 0 to 1.
]=]
function Station.encodeView(station: Station): StationView
	local recipe = Station.recipe(station)
	return {
		burning = if station.burnLeft > 0 then station.burnLeft / station.burnTotal else 0,
		working = if recipe ~= nil then station.worked / recipe.seconds else 0,
	}
end

return Station
