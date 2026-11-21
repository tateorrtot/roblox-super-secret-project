--!strict
--- A stove: a placed object that cooks one item into another while its fire burns.
---
--- A stove has three slots, a fire, and the work it is doing. `INPUT_SLOT` holds what is to be
--- cooked, `FUEL_SLOT` holds fuel, and what is made collects in `OUTPUT_SLOT`. `RECIPES` says what a
--- stove cooks, and `FUEL_SECONDS` what burns in it. `place` stands a stove on a tile of a plot.
---
--- Four functions are the stove's script, which the game calls when something happens to a stove.
--- `advance` burns the fire and does the work as time passes: the fire is lit only when there is
--- something to cook, and once lit it burns its fuel out. `interact` opens the stove's slots on a
--- player's screen. `getScreenData` says how far the fire and the work have got, for the two
--- gauges on that screen. `breakPlacedObject` takes the stove off the plot and throws a stove item
--- and everything that was in its slots onto the ground.
---
--- Note: the script is for a stove that `place` placed. Its functions fail for a placed object of
--- another kind, and for one of the stove's kind with no fire on it.
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local World = require("../world/World")

local Stove = {}

--- What a stove does with one item.
export type Recipe = {
	--- The id of the item that one of the item becomes.
	read output: string,
	--- How long that takes, in seconds.
	read seconds: number,
}

--- A stove standing on a plot: a placed object of the stove's kind, with its slots, its fire and
--- its work on it.
export type Stove = Plot.PlacedObject & {
	--- The stove's three slots.
	read inventory: Inventory.Inventory,
	--- The stove's fire.
	read fire: {
		--- How many seconds longer the fuel now burning will burn. 0 when the fire is out.
		burnSecondsLeft: number,
		--- How many seconds the item of fuel now burning burns in all. 0 when the fire is out.
		burnSecondsTotal: number,
	},
	--- The work the stove is doing on what is in its input slot.
	read work: {
		--- The id of the item that is being worked on. `nil` when nothing is.
		itemId: string?,
		--- How many seconds that item has been worked on. 0 when nothing is being worked on.
		workedSeconds: number,
	},
}

--- How far a stove's fire and work have got, as times on the world's clock. A stove's gauges move
--- all the time, but the time at which its fuel will burn out and the time at which its work will
--- be done stay the same until something happens to the stove. So a progress made at one moment
--- still describes the stove later, and `getFuelLeftRatio` and `getWorkDoneRatio` read the gauges
--- off it at any time. A progress never changes.
export type Progress = {
	--- The time at which the fuel now burning will burn out, in seconds. `nil` when the fire is out.
	read fuelBurnsOutAt: number?,
	--- How long the item of fuel now burning burns in all, in seconds. 0 when the fire is out.
	read fuelBurnSeconds: number,
	--- The time at which the item being worked on will be done if the fire burns until then, in
	--- seconds. `nil` when nothing is being worked on.
	read workDoneAt: number?,
	--- How long the work on that item takes in all, in seconds. 0 when nothing is being worked on.
	read workSeconds: number,
}

--- The id of the kind of placed object that a stove is.
Stove.PLACED_OBJECT_KIND_ID = "stove"

--- The name shown for a stove.
Stove.NAME = "Stove"

--- The id of the item that a broken stove leaves.
Stove.ITEM_ID_WHEN_BROKEN = "stove"

--- The slot that holds what is to be cooked.
Stove.INPUT_SLOT = 1

--- The slot that holds fuel.
Stove.FUEL_SLOT = 2

--- The slot where what has been made collects.
Stove.OUTPUT_SLOT = 3

--- How many slots a stove has.
Stove.SLOT_COUNT = 3

--- What a stove cooks: the recipe for each item that it cooks, by that item's id. One of the item
--- is used each time, and one of the recipe's output is made. These rows are placeholders.
Stove.RECIPES = table.freeze({
	fish = table.freeze({ output = "cooked_fish", seconds = 8 }),
	apple = table.freeze({ output = "baked_apple", seconds = 6 }),
} :: { [string]: Recipe })

--- What burns in a stove's fire: how long one of each item burns, in seconds, by that item's id.
--- These rows are placeholders.
Stove.FUEL_SECONDS = table.freeze({
	log = 16,
} :: { [string]: number })

--- Two times closer together than this count as the same time.
local SAME_TIME_SECONDS = 1e-9

--- Places a stove on the tile `tileX`, `tileZ` of `plot`, and returns the placed object's id. The
--- stove has `SLOT_COUNT` slots on it, holding nothing, no fire, and no work begun. Fails if
--- `Plot.canPlaceObject` would return `false` for that tile.
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

--- Returns the stove that has the id `placedObjectId` on `plot`. Fails if no placed object has
--- that id, or if the one that has is not of the stove's kind or has no fire on it.
function Stove.get(plot: Plot.Plot, placedObjectId: number): Stove
	return getStove(plot, placedObjectId)
end

--- Returns `true` if the stove's fire is burning.
function Stove.isBurning(stove: Stove): boolean
	return stove.fire.burnSecondsLeft > 0
end

--- Returns `true` if the slot `slot` of a stove accepts the item `itemId`. The input slot accepts
--- what `RECIPES` has a recipe for, the fuel slot accepts what `FUEL_SECONDS` lists, and the output
--- slot accepts nothing.
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

--- `seconds` have passed for the stove that has the id `placedObjectId` on the world's plot. Its
--- fire burns and it works for that long. While the input slot holds an item that `RECIPES` has a
--- recipe for, and the output slot has room for what the recipe makes, a fire that is out is lit
--- with one item from the fuel slot, and the item in the input slot is worked on. Each time it has
--- been worked on for its recipe's seconds, one of it becomes one of the recipe's output in the
--- output slot. A lit fire burns its fuel out even with nothing to work on. Work done on an item is
--- lost if the fire goes out for want of fuel, if the item in the input slot changes, or if the
--- output slot has no room. Fails if no placed object has that id, or if the one that has is not
--- of the stove's kind or has no fire on it.
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

--- A player interacts with the stove that has the id `placedObjectId` on the world's plot. The
--- stove's slots open on the player's screen, beside their pack, in place of any screen they had
--- open, and each slot takes what `slotAcceptsItem` says it accepts. Fails if the player has no
--- character. Fails if no placed object has that id, or if the one that has is not of the stove's
--- kind or has no fire on it.
function Stove.interact(world: World.World, player: PlayerState.PlayerState, placedObjectId: number)
	local stove = getStove(world.plot, placedObjectId)
	World.openPlacedObjectScreen(world, player, placedObjectId, stove.inventory, Stove.slotAcceptsItem)
end

--- The stove that has the id `placedObjectId` on the world's plot is broken. The stove is taken
--- off the plot, which closes every screen that was open on it. Its fire goes with it: the fuel
--- that was burning is lost. One of the item `ITEM_ID_WHEN_BROKEN`, and then each stack that was
--- in the stove's slots from the lowest slot up, is thrown onto the ground from the middle of the
--- stove's tile, upwards and outwards, each a different way. Fails, changing nothing, if no placed
--- object has that id, or if the one that has is not of the stove's kind or has no fire on it.
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

--- Returns how much of the fuel is left at the time `now`, as a number from 1, when it was just
--- lit, down to 0, when it has burnt out. Returns 0 if the fire was out.
function Stove.getFuelLeftRatio(progress: Progress, now: number): number
	local burnsOutAt = progress.fuelBurnsOutAt
	if burnsOutAt == nil then
		return 0
	end
	return math.clamp((burnsOutAt - now) / progress.fuelBurnSeconds, 0, 1)
end

--- Returns how far the work has got at the time `now`, as a number from 0, when it has not begun,
--- up to 1, when it is done. Returns 0 if nothing was being worked on.
function Stove.getWorkDoneRatio(progress: Progress, now: number): number
	local doneAt = progress.workDoneAt
	if doneAt == nil then
		return 0
	end
	return math.clamp(1 - (doneAt - now) / progress.workSeconds, 0, 1)
end

--- A player's machine is to be told of the stove that has the id `placedObjectId` on the world's
--- plot, which that player's screen is open on. Returns `getProgress` of the stove at the world's
--- time, which is plain data. Fails if no placed object has that id, or if the one that has is not
--- of the stove's kind or has no fire on it.
function Stove.getScreenData(world: World.World, placedObjectId: number): Progress
	return Stove.getProgress(getStove(world.plot, placedObjectId), world.now)
end

return Stove
