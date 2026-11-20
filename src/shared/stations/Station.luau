--!strict
--- A fire and three slots that turn one item into another while the fire burns, as a stove's do.
---
--- A station has three slots. `INPUT_SLOT` holds what is to be worked on, `FUEL_SLOT` holds fuel,
--- and what is made collects in `OUTPUT_SLOT`. `advance` burns the fire and does the work. The fire
--- is lit only when there is something to work on, and once lit it burns its fuel out.
local FuelRegistry = require("./FuelRegistry")
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local RecipeRegistry = require("./RecipeRegistry")

local Station = {}

type Inventory = Inventory.Inventory

export type Station = {
	--- The id of the kind of station it is, such as `"stove"`. Its recipes are the ones registered
	--- for that kind.
	read kindId: string,
	--- Its three slots.
	read inventory: Inventory,
	--- How many seconds longer the fuel now burning will burn. 0 when the fire is out.
	burnSecondsLeft: number,
	--- How many seconds the item of fuel now burning burns in all. 0 when the fire is out.
	burnSecondsTotal: number,
	--- How many seconds the item in the input slot has been worked on. 0 when nothing is being
	--- worked on.
	workedSeconds: number,
	--- The id of the item that work is being done on. `nil` when nothing is being worked on.
	workingOnItemId: string?,
}

--- The slot that holds what is to be worked on.
Station.INPUT_SLOT = 1

--- The slot that holds fuel.
Station.FUEL_SLOT = 2

--- The slot where what has been made collects.
Station.OUTPUT_SLOT = 3

--- How many slots a station's inventory has.
Station.SLOT_COUNT = 3

--- Two times closer together than this, in seconds, count as the same time.
local SAME_TIME = 1e-9

--- Returns a new station of the kind `kindId` over `inventory`, with no fire and nothing worked
--- on.
--- Note: `inventory` must have `SLOT_COUNT` slots. It is not checked.
function Station.new(kindId: string, inventory: Inventory): Station
	return { kindId = kindId, inventory = inventory, burnSecondsLeft = 0, burnSecondsTotal = 0, workedSeconds = 0 }
end

--- Returns `true` if the station's fire is burning.
function Station.isBurning(station: Station): boolean
	return station.burnSecondsLeft > 0
end

--- Returns `true` if a slot of a station of the kind `kindId` accepts the item `itemId`. The
--- input slot accepts what that kind of station has a recipe for, the fuel slot accepts what
--- burns, and the output slot accepts nothing.
function Station.slotAcceptsItem(kindId: string, slot: number, itemId: string): boolean
	if slot == Station.INPUT_SLOT then
		return RecipeRegistry.find(kindId, itemId) ~= nil
	end
	return slot == Station.FUEL_SLOT and FuelRegistry.find(itemId) ~= nil
end

--- Returns the recipe for the item in the input slot. Returns `nil` if that slot holds nothing,
--- if the station has no recipe for what it holds, or if the output slot has no room for what the
--- recipe makes.
function Station.getWorkableRecipe(station: Station): RecipeRegistry.Recipe?
	local input = Inventory.getStack(station.inventory, Station.INPUT_SLOT)
	local recipe = if input then RecipeRegistry.find(station.kindId, input.itemId) else nil
	local output = Inventory.getStack(station.inventory, Station.OUTPUT_SLOT)
	if recipe == nil or output == nil then
		return recipe
	end
	return if output.itemId == recipe.output and not ItemStack.isFull(output) then recipe else nil
end

local function setWorkingOn(station: Station, itemId: string?)
	if itemId ~= station.workingOnItemId then
		station.workingOnItemId = itemId
		station.workedSeconds = 0
	end
end

local function light(station: Station): boolean
	local stack = Inventory.getStack(station.inventory, Station.FUEL_SLOT)
	local fuel = if stack then FuelRegistry.find(stack.itemId) else nil
	if fuel == nil then
		return false
	end
	Inventory.takeFromSlot(station.inventory, Station.FUEL_SLOT, 1)
	station.burnSecondsLeft = fuel.seconds
	station.burnSecondsTotal = fuel.seconds
	return true
end

local function burn(station: Station, seconds: number)
	station.burnSecondsLeft -= seconds
	if station.burnSecondsLeft < SAME_TIME then
		station.burnSecondsLeft = 0
		station.burnSecondsTotal = 0
	end
end

local function work(station: Station, recipe: RecipeRegistry.Recipe, seconds: number)
	station.workedSeconds += seconds
	if station.workedSeconds >= recipe.seconds - SAME_TIME then
		Inventory.takeFromSlot(station.inventory, Station.INPUT_SLOT, 1)
		Inventory.putInSlot(station.inventory, Station.OUTPUT_SLOT, ItemStack.new(recipe.output, 1))
		station.workedSeconds = 0
	end
end

--- Burns the fire and works for `seconds`. While `getWorkableRecipe` returns a recipe, a fire
--- that is out is lit with one item from the fuel slot, and the item in the input slot is worked
--- on. Each time it has been worked on for its recipe's seconds, one of it becomes one of
--- the recipe's output in the output slot. A lit fire burns its fuel out even with nothing to work
--- on. Work done on an item is lost if the fire goes out for want of fuel, if the item in the
--- input slot changes, or if the output slot has no room.
function Station.advance(station: Station, seconds: number)
	local left = seconds
	while left > 0 do
		local recipe = Station.getWorkableRecipe(station)
		setWorkingOn(station, if recipe then recipe.input else nil)
		local isLit = Station.isBurning(station) or (recipe ~= nil and light(station))
		if not isLit then
			setWorkingOn(station, nil)
			return
		end
		local passed =
			math.min(left, station.burnSecondsLeft, if recipe then recipe.seconds - station.workedSeconds else left)
		left -= passed
		burn(station, passed)
		if recipe ~= nil then
			work(station, recipe, passed)
		end
	end
end

return Station
