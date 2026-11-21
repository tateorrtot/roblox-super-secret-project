--!strict
--- A stove: a placed object that cooks one item into another while its fire burns.
---
--- A stove has three slots, a fire, and the work it is doing. `INPUT_SLOT` holds what is to be
--- cooked, `FUEL_SLOT` holds fuel, and what is made collects in `OUTPUT_SLOT`. `RECIPES` says what
--- a stove cooks, and `FUEL_SECONDS` what burns in it. `place` stands a stove on a tile of a plot.
---
--- `advance`, `interact`, `getScreenData`, and `breakPlacedObject` are the stove's script.
--- `advance` burns the fire and does the work as time passes: it lights the fire only when there is
--- something to cook, and a lit fire burns its fuel out. `interact` opens the stove's slots on a
--- player's screen. `getScreenData` returns a `Progress`, from which `getFuelLeftRatio` and
--- `getWorkDoneRatio` read the two gauges on that screen. `breakPlacedObject` takes the stove off
--- the plot and throws a stove item, and everything that was in the stove's slots, onto the ground.
---
--- Note: the script is for a stove that `place` placed. Its functions raise an error for a placed
--- object of another kind, and for one of the stove's kind with no fire on it.
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local World = require("../world/World")

local Stove = {}

--- What a stove makes from one item.
export type Recipe = {
	--- The id of the item that the stove makes.
	read output: string,
	--- How long making it takes, in seconds.
	read seconds: number,
}

--- A placed object of the stove's kind, with its slots, its fire, and its work on it.
export type Stove = Plot.PlacedObject & {
	--- The stove's inventory, which has its three slots.
	read inventory: Inventory.Inventory,
	--- The stove's fire.
	read fire: {
		--- How many seconds longer the fuel now burning will burn. `0` when the fire is out.
		burnSecondsLeft: number,
		--- How many seconds the item of fuel now burning burns in all. `0` when the fire is out.
		burnSecondsTotal: number,
	},
	--- The work the stove is doing on what is in its input slot.
	read work: {
		--- The id of the item that is being worked on. `nil` when nothing is.
		itemId: string?,
		--- How many seconds that item has been worked on. `0` when nothing is being worked on.
		workedSeconds: number,
	},
}

--- How far a stove's fire and work have got, as times on the world's clock. `getProgress` makes
--- one, and `getFuelLeftRatio` and `getWorkDoneRatio` read the two gauges off it at any time. A
--- progress made at one time describes the stove at any later time, until the fuel now burning
--- burns out, the work on the item is done, or a slot of the stove changes. A progress never
--- changes.
export type Progress = {
	--- The time at which the fuel now burning will burn out, in seconds. `nil` when the fire is
	--- out.
	read fuelBurnsOutAt: number?,
	--- How long the item of fuel now burning burns in all, in seconds. `0` when the fire is out.
	read fuelBurnSeconds: number,
	--- The time at which the item being worked on will be done if the fire burns until then, in
	--- seconds. `nil` when nothing is being worked on.
	read workDoneAt: number?,
	--- How long the work on that item takes in all, in seconds. `0` when nothing is being worked
	--- on.
	read workSeconds: number,
}

--- The `kindId` that every stove has.
Stove.PLACED_OBJECT_KIND_ID = "stove"

--- The name shown for a stove.
Stove.NAME = "Stove"

--- The id of the item that `breakPlacedObject` throws onto the ground.
Stove.ITEM_ID_WHEN_BROKEN = "stove"

--- The number of the slot that holds what is to be cooked.
Stove.INPUT_SLOT = 1

--- The number of the slot that holds fuel.
Stove.FUEL_SLOT = 2

--- The number of the slot where what the stove has made collects.
Stove.OUTPUT_SLOT = 3

--- How many slots a stove has.
Stove.SLOT_COUNT = 3

--- The recipe for each item that a stove cooks, by that item's id. Each time the work on an item
--- is done, `advance` uses up one of the item and makes one of the recipe's `output`.
Stove.RECIPES = table.freeze({
	fish = table.freeze({ output = "cooked_fish", seconds = 8 }),
	apple = table.freeze({ output = "baked_apple", seconds = 6 }),
} :: { [string]: Recipe })

--- How long one of each item that burns in a stove's fire burns, in seconds, by that item's id.
Stove.FUEL_SECONDS = table.freeze({
	log = 16,
} :: { [string]: number })

--- Two times that differ by less than this, in seconds, count as the same time.
local SAME_TIME_SECONDS = 1e-9

--- Stands a stove on the tile at `tileX`, `tileZ` of `plot`, and returns the placed object's id.
--- The stove has `SLOT_COUNT` slots on it, holding nothing, no fire, and no work begun. Raises an
--- error if `Plot.canPlaceObject` would return `false` for that tile.
--- Note: `place` does not ask `World.canPlaceObject`, so a character that stands on the tile does
--- not stop it.
function Stove.place(plot: Plot.Plot, tileX: number, tileZ: number): number
	local stove: Stove = {
		kindId = Stove.PLACED_OBJECT_KIND_ID,
		tileX = tileX,
		tileZ = tileZ,
		inventory = Inventory.new(Stove.SLOT_COUNT),
		fire = { burnSecondsLeft = 0, burnSecondsTotal = 0 },
		work = { workedSeconds = 0 },
	}
	return Plot.placeObject(plot, stove)
end

local function getStove(plot: Plot.Plot, placedObjectId: number): Stove
	local placedObject = plot.placedObjectsById[placedObjectId]
	local isStove = placedObject ~= nil
		and placedObject.kindId == Stove.PLACED_OBJECT_KIND_ID
		and (placedObject :: any).fire ~= nil
	if not isStove then
		error(`the placed object {placedObjectId} is not a stove that Stove.place placed`, 3)
	end
	return placedObject :: Stove
end

--- Returns the stove `placedObjectId` on `plot`. Raises an error if no placed object has that id,
--- or if the one that has is not of the stove's kind or has no fire on it.
function Stove.get(plot: Plot.Plot, placedObjectId: number): Stove
	return getStove(plot, placedObjectId)
end

--- Returns `true` if the stove's fire is burning.
function Stove.isBurning(stove: Stove): boolean
	return stove.fire.burnSecondsLeft > 0
end

--- Returns `true` if `slot` of a stove accepts the item `itemId`. The input slot accepts an item
--- that `RECIPES` has a recipe for, the fuel slot accepts an item that `FUEL_SECONDS` lists, and
--- the output slot accepts nothing. Returns `false` for a slot that a stove does not have.
function Stove.slotAcceptsItem(slot: number, itemId: string): boolean
	if slot == Stove.INPUT_SLOT then
		return Stove.RECIPES[itemId] ~= nil
	end
	return slot == Stove.FUEL_SLOT and Stove.FUEL_SECONDS[itemId] ~= nil
end

local function findItemToWorkOn(stove: Stove): (string?, Recipe?)
	local input = Inventory.getStack(stove.inventory, Stove.INPUT_SLOT)
	local recipe = if input then Stove.RECIPES[input.itemId] else nil
	if input == nil or recipe == nil then
		return nil, nil
	end
	local output = Inventory.getStack(stove.inventory, Stove.OUTPUT_SLOT)
	local hasRoom = output == nil or (output.itemId == recipe.output and not ItemStack.isFull(output))
	if not hasRoom then
		return nil, nil
	end
	return input.itemId, recipe
end

local function setWorkingOn(stove: Stove, itemId: string?)
	if itemId ~= stove.work.itemId then
		stove.work.itemId = itemId
		stove.work.workedSeconds = 0
	end
end

local function light(stove: Stove): boolean
	local stack = Inventory.getStack(stove.inventory, Stove.FUEL_SLOT)
	local seconds = if stack then Stove.FUEL_SECONDS[stack.itemId] else nil
	if seconds == nil then
		return false
	end
	Inventory.takeFromSlot(stove.inventory, Stove.FUEL_SLOT, 1)
	stove.fire.burnSecondsLeft = seconds
	stove.fire.burnSecondsTotal = seconds
	return true
end

local function burn(stove: Stove, seconds: number)
	stove.fire.burnSecondsLeft -= seconds
	if stove.fire.burnSecondsLeft < SAME_TIME_SECONDS then
		stove.fire.burnSecondsLeft = 0
		stove.fire.burnSecondsTotal = 0
	end
end

local function work(stove: Stove, recipe: Recipe, seconds: number)
	stove.work.workedSeconds += seconds
	if stove.work.workedSeconds >= recipe.seconds - SAME_TIME_SECONDS then
		Inventory.takeFromSlot(stove.inventory, Stove.INPUT_SLOT, 1)
		Inventory.putInSlot(stove.inventory, Stove.OUTPUT_SLOT, ItemStack.new(recipe.output, 1))
		stove.work.workedSeconds = 0
	end
end

--- Burns the fire of the stove `placedObjectId` on the world's plot, and does its work, for
--- `seconds`. While the input slot holds an item that `RECIPES` has a recipe for, and the output
--- slot has room for what the recipe makes, the stove lights a fire that is out with one item from
--- the fuel slot, and works on the item in the input slot. Each time an item has been worked on for
--- its recipe's `seconds`, one of it becomes one of the recipe's `output` in the output slot. A lit
--- fire burns its fuel out even with nothing to work on. The work done on an item is lost if the
--- fire goes out for want of fuel, if the item in the input slot changes, or if the output slot has
--- no room. Raises an error, and changes nothing, if no placed object has that id, or if the one
--- that has is not of the stove's kind or has no fire on it.
function Stove.advance(world: World.World, placedObjectId: number, seconds: number)
	local stove = getStove(world.plot, placedObjectId)
	local left = seconds
	while left > 0 do
		local itemId, recipe = findItemToWorkOn(stove)
		setWorkingOn(stove, itemId)
		local isLit = Stove.isBurning(stove) or (recipe ~= nil and light(stove))
		if not isLit then
			setWorkingOn(stove, nil)
			return
		end
		local workLeft = if recipe then recipe.seconds - stove.work.workedSeconds else left
		local passed = math.min(left, stove.fire.burnSecondsLeft, workLeft)
		left -= passed
		burn(stove, passed)
		if recipe ~= nil then
			work(stove, recipe, passed)
		end
	end
end

--- Opens the inventory of the stove `placedObjectId` on the world's plot, beside the pack on the
--- player's screen, as `World.openPlacedObjectScreen` does. It closes any screen that the player
--- had open first. Each slot of the stove's inventory accepts what `slotAcceptsItem` says it
--- accepts. Raises an error, and changes nothing, if the player has no character, if no placed
--- object has that id, or if the one that has is not of the stove's kind or has no fire on it.
function Stove.interact(world: World.World, player: PlayerState.PlayerState, placedObjectId: number)
	local stove = getStove(world.plot, placedObjectId)
	World.openPlacedObjectScreen(world, player, placedObjectId, stove.inventory, Stove.slotAcceptsItem)
end

--- Breaks the stove `placedObjectId` on the world's plot. Takes the stove off the plot, which
--- closes every screen that was open on it. The fuel that was burning is lost. Throws one of the
--- item `ITEM_ID_WHEN_BROKEN`, and then each stack that was in the stove's slots, from the lowest
--- slot up, from the middle of the stove's tile, upwards and outwards, each a different way, as
--- `World.throwStacksFromTile` does. Raises an error, and changes nothing, if no placed object has
--- that id, or if the one that has is not of the stove's kind or has no fire on it.
function Stove.breakPlacedObject(world: World.World, placedObjectId: number)
	local stove = getStove(world.plot, placedObjectId)
	local stacks = Inventory.takeEveryStack(stove.inventory)
	table.insert(stacks, 1, ItemStack.new(Stove.ITEM_ID_WHEN_BROKEN, 1))
	Plot.removePlacedObject(world.plot, placedObjectId)
	World.throwStacksFromTile(world, stacks, stove.tileX, stove.tileZ)
end

local function roundToMillisecond(time: number): number
	return math.floor(time * 1000 + 0.5) / 1000
end

--- Returns the progress of `stove` at the time `now`, in seconds. Its two times are rounded to the
--- millisecond, so that a progress made later equals this one, field for field, as long as the
--- stove has only burnt and worked in between.
--- Note: the progress holds no work until `advance` has begun work on the item in the input slot.
function Stove.getProgress(stove: Stove, now: number): Progress
	local itemId, recipe = findItemToWorkOn(stove)
	local isBurning = Stove.isBurning(stove)
	local isWorking = recipe ~= nil and itemId == stove.work.itemId
	return table.freeze({
		fuelBurnsOutAt = if isBurning then roundToMillisecond(now + stove.fire.burnSecondsLeft) else nil,
		fuelBurnSeconds = if isBurning then stove.fire.burnSecondsTotal else 0,
		workDoneAt = if recipe ~= nil and isWorking
			then roundToMillisecond(now + recipe.seconds - stove.work.workedSeconds)
			else nil,
		workSeconds = if recipe ~= nil and isWorking then recipe.seconds else 0,
	})
end

--- Returns how much of the fuel now burning is left at the time `now`, as a number from `1`, when
--- it was lit, down to `0`, when it has burnt out. Returns `0` if `progress` has no fire.
function Stove.getFuelLeftRatio(progress: Progress, now: number): number
	local burnsOutAt = progress.fuelBurnsOutAt
	if burnsOutAt == nil then
		return 0
	end
	return math.clamp((burnsOutAt - now) / progress.fuelBurnSeconds, 0, 1)
end

--- Returns how far the work has got at the time `now`, as a number from `0`, when it has not
--- begun, up to `1`, when it is done. Returns `0` if `progress` has no work.
function Stove.getWorkDoneRatio(progress: Progress, now: number): number
	local doneAt = progress.workDoneAt
	if doneAt == nil then
		return 0
	end
	return math.clamp(1 - (doneAt - now) / progress.workSeconds, 0, 1)
end

--- Returns the progress, at `world.now`, of the stove `placedObjectId` on the world's plot, as
--- `getProgress` makes it. It is what the client is told of the stove besides its inventory. Raises
--- an error if no placed object has that id, or if the one that has is not of the stove's kind or
--- has no fire on it.
function Stove.getScreenData(world: World.World, placedObjectId: number): Progress
	return Stove.getProgress(getStove(world.plot, placedObjectId), world.now)
end

return Stove
