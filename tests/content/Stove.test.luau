--!strict
-- Tests for Stove. Run from the repository root: lune run tests/content/Stove.test.luau

local Check = require("../Check")
local GroundItems = require("../../src/shared/groundItems/GroundItems")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local Items = require("../../src/shared/content/Items")
local PlacedObjectScripts = require("../../src/shared/requests/PlacedObjectScripts")
local PlayerState = require("../../src/shared/players/PlayerState")
local Plot = require("../../src/shared/plots/Plot")
local Position = require("../../src/shared/Position")
local Signal = require("../../src/shared/Signal")
local Stove = require("../../src/shared/content/Stove")
local World = require("../../src/shared/world/World")

local check = Check.that
local at = Position.new

-- The game's own items: a stove cooks and burns the items of the game.
for _, item in Items.ALL do
	ItemRegistry.register(item)
end

local INPUT, FUEL, OUTPUT = Stove.INPUT_SLOT, Stove.FUEL_SLOT, Stove.OUTPUT_SLOT

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

local function near(a: number, b: number): boolean
	return math.abs(a - b) < 1e-6
end

-- How many ground items a world has.
local function groundItemCount(world: World.World): number
	local count = 0
	for _ in world.groundItems.itemsById do
		count += 1
	end
	return count
end

-- A world on `plot` at time `now`, whose time passes for the placed objects on its plot, as the
-- server connects it.
local function newConnectedWorld(plot: Plot.Plot, now: number): World.World
	local world = World.new(plot, at(0, 0, 0), now)
	Signal.connect(world.advanced, function(seconds: number)
		PlacedObjectScripts.advancePlacedObjects(world, seconds)
	end)
	return world
end

-- A world at time 50 with a plot of 4 by 4 tiles whose corner is at the origin, so that the middle of
-- tile x, z is at x * 4 - 2, z * 4 - 2. A stove stands on tile 2, 2 (its middle is 6, 6). Player 1
-- stands at 6, 0, 0 with a pack that holds nothing.
local function newWorld(): (World.World, PlayerState.PlayerState, number)
	local world = newConnectedWorld(Plot.new(4, 4), 50)
	local stoveId = Stove.place(world.plot, 2, 2)
	local player = World.addPlayer(world, 1)
	World.setCharacterPosition(world, 1, at(6, 0, 0))
	return world, player, stoveId
end

-- A stove, the id it has, and the world at time 0 whose plot it stands on.
type Rig = { world: World.World, stove: Stove.Stove, id: number }

-- Returns the stack that `text` describes, such as "fish 3", or nil for "-".
local function stackOf(text: string): ItemStack.ItemStack?
	if text == "-" then
		return nil
	end
	local itemId, count = string.match(text, "^([%a_]+) (%d+)$")
	return ItemStack.new(itemId :: string, tonumber(count) :: number)
end

-- Returns a stove on tile 1, 1 holding what the three texts describe, such as "fish 3", in its
-- input, fuel and output slots, with "-" for a slot that holds nothing.
local function stoveWith(input: string, fuel: string, output: string): Rig
	local world = World.new(Plot.new(4, 4), at(0, 0, 0), 0)
	local id = Stove.place(world.plot, 1, 1)
	local stove = Stove.get(world.plot, id)
	Inventory.setStack(stove.inventory, INPUT, stackOf(input))
	Inventory.setStack(stove.inventory, FUEL, stackOf(fuel))
	Inventory.setStack(stove.inventory, OUTPUT, stackOf(output))
	return { world = world, stove = stove, id = id }
end

-- Passes `seconds` for the stove of `rig`.
local function advance(rig: Rig, seconds: number)
	Stove.advance(rig.world, rig.id, seconds)
end

-- Describes what the stove's three slots hold, as "fish 3, log 4, -".
local function contents(stove: Stove.Stove): string
	local parts = {}
	for slot = 1, 3 do
		local stack = Inventory.getStack(stove.inventory, slot)
		table.insert(parts, if stack then stack.itemId .. " " .. stack.count else "-")
	end
	return table.concat(parts, ", ")
end

-- True if two progresses are equal, field for field.
local function same(a: Stove.Progress, b: Stove.Progress): boolean
	return a.fuelBurnsOutAt == b.fuelBurnsOutAt
		and a.fuelBurnSeconds == b.fuelBurnSeconds
		and a.workDoneAt == b.workDoneAt
		and a.workSeconds == b.workSeconds
end

-- Stands a placed object of the kind "bell" on tile `tileX`, `tileZ` of `plot`, with a fire field
-- on it as a stove has, and returns its id.
local function placeBellWithFire(plot: Plot.Plot, tileX: number, tileZ: number): number
	local bell: any =
		{ kindId = "bell", tileX = tileX, tileZ = tileZ, fire = { burnSecondsLeft = 0, burnSecondsTotal = 0 } }
	return Plot.placeObject(plot, bell)
end

do -- a stove as names, and its rows
	check(Stove.PLACED_OBJECT_KIND_ID == "stove", 'PLACED_OBJECT_KIND_ID: a stove is of the kind "stove"')
	check(Stove.ITEM_ID_WHEN_BROKEN == "stove", 'ITEM_ID_WHEN_BROKEN: a broken stove leaves the item "stove"')
	check(INPUT == 1 and FUEL == 2 and OUTPUT == 3, "INPUT_SLOT: the slots are what goes in, fuel, what comes out")
	check(Stove.SLOT_COUNT == 3, "SLOT_COUNT: a stove has three slots")
end

do -- the rows of RECIPES and FUEL_SECONDS
	check(table.isfrozen(Stove.RECIPES), "RECIPES: a table that never changes")
	check(table.isfrozen(Stove.FUEL_SECONDS), "FUEL_SECONDS: a table that never changes")
	local recipeCount, fuelCount = 0, 0
	for itemId, recipe in Stove.RECIPES do
		recipeCount += 1
		check(Check.errorFrom(function()
			Items.get(itemId)
		end) == nil, `RECIPES: the input "{itemId}" is an item of the game`)
		check(Check.errorFrom(function()
			Items.get(recipe.output)
		end) == nil, `RECIPES: the output "{recipe.output}" of "{itemId}" is an item of the game`)
		check(recipe.output ~= itemId, `RECIPES: "{itemId}" becomes a different item`)
		check(
			recipe.seconds > 0 and recipe.seconds < math.huge,
			`RECIPES: the work on "{itemId}" takes a finite number of seconds above 0`
		)
		check(Stove.slotAcceptsItem(INPUT, itemId), `RECIPES: the input slot accepts "{itemId}"`)
	end
	for itemId, seconds in Stove.FUEL_SECONDS do
		fuelCount += 1
		check(Check.errorFrom(function()
			Items.get(itemId)
		end) == nil, `FUEL_SECONDS: "{itemId}" is an item of the game`)
		check(
			seconds > 0 and seconds < math.huge,
			`FUEL_SECONDS: "{itemId}" burns for a finite number of seconds above 0`
		)
		check(Stove.slotAcceptsItem(FUEL, itemId), `FUEL_SECONDS: the fuel slot accepts "{itemId}"`)
	end
	check(recipeCount > 0, "RECIPES: there is at least one recipe")
	check(fuelCount > 0, "FUEL_SECONDS: there is at least one fuel, so that a stove can be lit")
	check(
		Stove.RECIPES.fish.output == "cooked_fish" and Stove.RECIPES.fish.seconds == 8,
		"RECIPES: a fish becomes a cooked fish in 8 seconds"
	)
	check(
		Stove.RECIPES.apple.output == "baked_apple" and Stove.RECIPES.apple.seconds == 6,
		"RECIPES: an apple becomes a baked apple in 6 seconds"
	)
	check(Stove.FUEL_SECONDS.log == 16, "FUEL_SECONDS: a log burns for 16 seconds")
end

do -- a stove as the script of its kind
	PlacedObjectScripts.register(Stove.PLACED_OBJECT_KIND_ID, Stove)
	local registered = PlacedObjectScripts.find(Stove.PLACED_OBJECT_KIND_ID)
	check(
		registered ~= nil and registered.interact == Stove.interact,
		"interact: is what a registered stove does when a player interacts with one"
	)
	check(
		registered ~= nil and registered.breakPlacedObject == Stove.breakPlacedObject,
		"breakPlacedObject: is what a registered stove does when a player breaks one"
	)
	check(
		registered ~= nil and registered.advance == Stove.advance,
		"advance: is what a registered stove does as time passes"
	)
	check(
		registered ~= nil and registered.getScreenData == Stove.getScreenData,
		"getScreenData: is what a registered stove says of itself for an open screen"
	)
end

do -- place
	local plot = Plot.new(4, 4)
	local id = Stove.place(plot, 2, 3)
	local placed = plot.placedObjectsById[id]
	check(
		placed ~= nil and placed.kindId == Stove.PLACED_OBJECT_KIND_ID and placed.tileX == 2 and placed.tileZ == 3,
		"place: a placed object of the stove's kind stands on the tile, and its id is returned"
	)
	local stove = Stove.get(plot, id)
	check(stove == placed, "get: returns the placed object that place placed")
	check(
		stove.inventory.slotCount == Stove.SLOT_COUNT and Inventory.isEmpty(stove.inventory),
		"place: with SLOT_COUNT slots, holding nothing"
	)
	check(
		stove.fire.burnSecondsLeft == 0
			and stove.fire.burnSecondsTotal == 0
			and stove.work.workedSeconds == 0
			and stove.work.itemId == nil,
		"place: and with no fire and no work done"
	)
	check(not Stove.isBurning(stove), "isBurning: false for a stove just placed")

	local second = Stove.place(plot, 1, 1)
	check(
		second ~= id and Stove.get(plot, second) ~= stove and Stove.get(plot, second).inventory ~= stove.inventory,
		"place: each stove has an id, a fire and slots of its own"
	)
	check(
		string.find(Check.errorFrom(function()
			Stove.place(plot, 2, 3)
		end) or "", "nothing can be placed on the tile 2, 3", 1, true) ~= nil,
		"place: fails on a tile that is taken, saying so"
	)
	check(plot.nextId == second + 1, "place: a placing that fails places nothing")
end

do -- get
	local world, _, stoveId = newWorld()
	local plot = world.plot
	check(Stove.get(plot, stoveId).kindId == "stove", "get: the stove that has the id")
	local bell = placeBellWithFire(plot, 1, 1)
	local bare = Plot.placeObject(plot, { kindId = Stove.PLACED_OBJECT_KIND_ID, tileX = 3, tileZ = 3 })
	local function refuses(id: number, what: string)
		check(
			Check.raises(`the placed object {id} is not a stove that Stove.place placed`, function()
				Stove.get(plot, id)
			end),
			"get: fails for " .. what
		)
	end
	refuses(99, "an id that no placed object has")
	refuses(bell, "a placed object of another kind, even with a fire field on it")
	refuses(bare, "a placed object of the stove's kind with no fire on it")
end

do -- a placed stove cooks as the world's time passes
	local world = newConnectedWorld(Plot.new(4, 4), 0)
	local id = Stove.place(world.plot, 1, 1)
	local slots = Stove.get(world.plot, id).inventory
	Inventory.setStack(slots, INPUT, ItemStack.new("fish", 2))
	Inventory.setStack(slots, FUEL, ItemStack.new("log", 1))
	World.advanceTo(world, 8)
	check(
		is(Inventory.getStack(slots, OUTPUT), "cooked_fish", 1) and is(Inventory.getStack(slots, INPUT), "fish", 1),
		"advance: a registered, placed stove cooks as the world's time passes"
	)
end

do -- advance: cooking one fish
	local rig = stoveWith("fish 1", "log 4", "-")
	local stove = rig.stove
	advance(rig, 0.5)
	check(contents(stove) == "fish 1, log 3, -", "advance: lighting the fire uses up one item of fuel")
	check(
		Stove.isBurning(stove) and stove.fire.burnSecondsLeft == 15.5 and stove.fire.burnSecondsTotal == 16,
		"advance: the fire burns for as long as that item burns"
	)
	check(
		stove.work.workedSeconds == 0.5 and stove.work.itemId == "fish",
		"advance: the fish has been worked on for the time that passed"
	)
	advance(rig, 7.5)
	check(
		contents(stove) == "-, log 3, cooked_fish 1",
		"advance: after its recipe's time the fish is a cooked fish in the output slot"
	)
	check(
		stove.work.workedSeconds == 0 and stove.fire.burnSecondsLeft == 8,
		"advance: nothing is being worked on, and the fire burns on"
	)
	advance(rig, 7.9)
	check(
		Stove.isBurning(stove) and near(stove.fire.burnSecondsLeft, 0.1),
		"advance: the fire burns down with nothing to work on"
	)
	advance(rig, 100)
	check(not Stove.isBurning(stove) and stove.fire.burnSecondsLeft == 0, "advance: and goes out")
	check(contents(stove) == "-, log 3, cooked_fish 1", "advance: no fuel is used when there is nothing to work on")
	check(stove.work.itemId == nil, "advance: and nothing is being worked on")
end

do -- advance: a fire is never lit for nothing
	local fuelOnly = stoveWith("-", "log 4", "-")
	advance(fuelOnly, 30)
	check(
		contents(fuelOnly.stove) == "-, log 4, -" and not Stove.isBurning(fuelOnly.stove),
		"advance: fuel alone lights no fire"
	)
	local noFuel = stoveWith("fish 3", "-", "-")
	advance(noFuel, 30)
	check(
		contents(noFuel.stove) == "fish 3, -, -" and noFuel.stove.work.workedSeconds == 0,
		"advance: with no fuel nothing is worked on"
	)
	local noRecipe = stoveWith("stone 3", "log 4", "-")
	advance(noRecipe, 30)
	check(
		contents(noRecipe.stove) == "stone 3, log 4, -" and not Stove.isBurning(noRecipe.stove),
		"advance: an item that has no recipe lights no fire"
	)
	local notFuel = stoveWith("fish 3", "stone 4", "-")
	advance(notFuel, 30)
	check(contents(notFuel.stove) == "fish 3, stone 4, -", "advance: an item that does not burn lights no fire")
	local fishFuel = stoveWith("fish 3", "fish 4", "-")
	advance(fishFuel, 30)
	check(
		contents(fishFuel.stove) == "fish 3, fish 4, -",
		"advance: an item with a recipe but no burning is not fuel either"
	)
	local blocked = stoveWith("fish 3", "log 4", "stone 1")
	advance(blocked, 30)
	check(
		contents(blocked.stove) == "fish 3, log 4, stone 1" and not Stove.isBurning(blocked.stove),
		"advance: nor is one lit when the output slot holds something else"
	)
	local wrongOutput = stoveWith("fish 2", "log 4", "baked_apple 1")
	advance(wrongOutput, 30)
	check(
		contents(wrongOutput.stove) == "fish 2, log 4, baked_apple 1",
		"advance: nor when the output slot holds what another recipe makes"
	)
	local full = stoveWith("fish 3", "log 4", "cooked_fish 8")
	advance(full, 30)
	check(contents(full.stove) == "fish 3, log 4, cooked_fish 8", "advance: or is full")
	local room = stoveWith("fish 2", "log 4", "cooked_fish 7")
	advance(room, 8)
	check(
		contents(room.stove) == "fish 1, log 3, cooked_fish 8",
		"advance: but is lit when the output slot has room for one more"
	)
end

do -- advance: many items, and one long step against many short ones
	local long = stoveWith("fish 5", "log 4", "-")
	advance(long, 40)
	check(contents(long.stove) == "-, log 1, cooked_fish 5", "advance: five fish take forty seconds and three logs")
	check(
		near(long.stove.fire.burnSecondsLeft, 8) and long.stove.work.workedSeconds == 0,
		"advance: the third log has eight seconds left to burn"
	)

	local short = stoveWith("fish 5", "log 4", "-")
	for _ = 1, 400 do
		advance(short, 0.1)
	end
	check(
		contents(short.stove) == contents(long.stove),
		"advance: four hundred steps of a tenth of a second end the same way"
	)
	check(
		near(short.stove.fire.burnSecondsLeft, long.stove.fire.burnSecondsLeft)
			and near(short.stove.work.workedSeconds, long.stove.work.workedSeconds),
		"advance: with the same fire and the same work done"
	)

	local whole = stoveWith("fish 1", "log 1", "-")
	advance(whole, 16)
	local pieces = stoveWith("fish 1", "log 1", "-")
	for _ = 1, 160 do
		advance(pieces, 0.1)
	end
	local thirds = stoveWith("fish 1", "log 1", "-")
	for _ = 1, 48 do
		advance(thirds, 1 / 3)
	end
	check(
		not Stove.isBurning(whole.stove) and whole.stove.fire.burnSecondsLeft == 0,
		"advance: a log is burnt out after its sixteen seconds"
	)
	check(
		not Stove.isBurning(pieces.stove)
			and pieces.stove.fire.burnSecondsLeft == 0
			and not Stove.isBurning(thirds.stove)
			and thirds.stove.fire.burnSecondsLeft == 0,
		"advance: and just as burnt out when the sixteen seconds came in small pieces"
	)

	local uneven = stoveWith("fish 5", "log 4", "-")
	for _, seconds in { 3, 0, 9.5, 0.25, 11, 16.25 } do
		advance(uneven, seconds)
	end
	check(
		contents(uneven.stove) == contents(long.stove) and near(uneven.stove.fire.burnSecondsLeft, 8),
		"advance: and so do uneven steps of the same total"
	)

	local partway = stoveWith("fish 5", "log 4", "-")
	advance(partway, 20)
	check(
		contents(partway.stove) == "fish 3, log 2, cooked_fish 2",
		"advance: after twenty seconds two fish are done and a second log is lit"
	)
	check(
		near(partway.stove.work.workedSeconds, 4) and near(partway.stove.fire.burnSecondsLeft, 12),
		"advance: the third fish is half done"
	)
end

do -- advance: the fire going out, and coming back
	local rig = stoveWith("apple 3", "log 1", "-")
	local stove = rig.stove
	advance(rig, 16)
	check(
		contents(stove) == "apple 1, -, baked_apple 2" and near(stove.work.workedSeconds, 4),
		"advance: one log burns for sixteen seconds of work, two apples and four seconds of the third"
	)
	check(not Stove.isBurning(stove), "advance: and then the fire is out")
	check(stove.fire.burnSecondsTotal == 0, "advance: with no length of fire left either")
	advance(rig, 1)
	check(
		stove.work.workedSeconds == 0 and stove.work.itemId == nil,
		"advance: with no fuel to light it again, the work done is lost"
	)
	check(contents(stove) == "apple 1, -, baked_apple 2", "advance: but the apple is still there")
	Inventory.setStack(stove.inventory, FUEL, ItemStack.new("log", 5))
	advance(rig, 6)
	check(contents(stove) == "-, log 4, baked_apple 3", "advance: a log lit again cooks the apple from the start")

	local relit = stoveWith("apple 3", "log 4", "-")
	advance(relit, 17)
	check(
		near(relit.stove.work.workedSeconds, 5) and contents(relit.stove) == "apple 1, log 2, baked_apple 2",
		"advance: a fire that goes out mid-work is lit again at once if there is fuel, and the work goes on"
	)
	check(
		near(relit.stove.fire.burnSecondsLeft, 15) and relit.stove.fire.burnSecondsTotal == 16,
		"advance: with the new log's own length of fire"
	)
end

do -- advance: changing what is in the input slot
	local rig = stoveWith("fish 1", "log 4", "-")
	local stove = rig.stove
	advance(rig, 5)
	Inventory.setStack(stove.inventory, INPUT, ItemStack.new("apple", 1))
	advance(rig, 1)
	check(
		stove.work.itemId == "apple" and near(stove.work.workedSeconds, 1),
		"advance: a different item in the input slot starts from nothing"
	)
	advance(rig, 4.9)
	check(contents(stove) == "apple 1, log 3, -", "advance: so the apple is not done early")
	advance(rig, 0.1)
	check(contents(stove) == "-, log 3, baked_apple 1", "advance: it is done after its own recipe's time")

	local taken = stoveWith("fish 1", "log 4", "-")
	advance(taken, 5)
	Inventory.setStack(taken.stove.inventory, INPUT, nil)
	advance(taken, 1)
	check(
		taken.stove.work.workedSeconds == 0 and taken.stove.work.itemId == nil,
		"advance: taking the item away loses the work done on it"
	)
	Inventory.setStack(taken.stove.inventory, INPUT, ItemStack.new("fish", 1))
	advance(taken, 7.9)
	check(contents(taken.stove) == "fish 1, log 3, -", "advance: and one put back is worked on from the start")
end

do -- advance: the output slot filling up
	local rig = stoveWith("fish 8", "log 8", "cooked_fish 7")
	advance(rig, 8)
	check(contents(rig.stove) == "fish 7, log 7, cooked_fish 8", "advance: the last one that fits is made")
	advance(rig, 200)
	check(
		contents(rig.stove) == "fish 7, log 7, cooked_fish 8",
		"advance: and then work stops, and no more fuel is used"
	)
	check(not Stove.isBurning(rig.stove), "advance: once the log that was burning has burnt out")
	Inventory.takeFromSlot(rig.stove.inventory, OUTPUT, 3)
	advance(rig, 8)
	check(
		contents(rig.stove) == "fish 6, log 6, cooked_fish 6",
		"advance: making room in the output slot starts the work again"
	)
end

do -- advance: steps of no time, and the length of a fire
	local rig = stoveWith("fish 1", "log 1", "-")
	advance(rig, 0)
	check(
		contents(rig.stove) == "fish 1, log 1, -" and not Stove.isBurning(rig.stove),
		"advance: 0 seconds changes nothing"
	)
	check(rig.stove.fire.burnSecondsTotal == 0, "advance: and lights no fire")
	advance(rig, 4)
	check(
		rig.stove.fire.burnSecondsTotal == 16,
		"advance: the fire's length is how long the item burning burns in all, while it burns"
	)
	advance(rig, 100)
	check(
		rig.stove.fire.burnSecondsTotal == 0 and rig.stove.fire.burnSecondsLeft == 0,
		"advance: 0 again once the fire has gone out"
	)
	local starved = stoveWith("apple 3", "log 1", "-")
	advance(starved, 16)
	check(
		starved.stove.fire.burnSecondsTotal == 0,
		"advance: 0 when the fire went out for want of fuel, with work still to do"
	)
end

do -- advance: what is worked on while the fire burns
	local swapped = stoveWith("fish 1", "log 4", "-")
	advance(swapped, 1)
	Inventory.setStack(swapped.stove.inventory, INPUT, ItemStack.new("stone", 1))
	advance(swapped, 1)
	check(
		swapped.stove.work.itemId == nil and swapped.stove.work.workedSeconds == 0,
		"advance: an item with no recipe put in the input slot of a lit stove is not worked on"
	)
	check(Stove.isBurning(swapped.stove), "advance: though the fire burns on")

	local blocked = stoveWith("fish 2", "log 4", "-")
	advance(blocked, 1)
	Inventory.setStack(blocked.stove.inventory, OUTPUT, ItemStack.new("stone", 1))
	advance(blocked, 1)
	check(
		blocked.stove.work.itemId == nil and blocked.stove.work.workedSeconds == 0,
		"advance: nothing is worked on in a lit stove whose output slot holds something else"
	)

	local almost = stoveWith("fish 1", "log 1", "-")
	advance(almost, 8 - 1e-9)
	check(
		contents(almost.stove) == "-, -, cooked_fish 1",
		"advance: a fish worked on for a billionth of a second short of its time is done"
	)
end

do -- slotAcceptsItem
	check(
		Stove.slotAcceptsItem(INPUT, "fish") and Stove.slotAcceptsItem(INPUT, "apple"),
		"slotAcceptsItem: the input slot takes what RECIPES has recipes for"
	)
	check(
		not Stove.slotAcceptsItem(INPUT, "log")
			and not Stove.slotAcceptsItem(INPUT, "stone")
			and not Stove.slotAcceptsItem(INPUT, "cooked_fish"),
		"slotAcceptsItem: the input slot takes nothing else"
	)
	check(Stove.slotAcceptsItem(FUEL, "log"), "slotAcceptsItem: the fuel slot takes what burns")
	check(
		not Stove.slotAcceptsItem(FUEL, "fish") and not Stove.slotAcceptsItem(FUEL, "stone"),
		"slotAcceptsItem: the fuel slot takes nothing that does not burn, even what has a recipe"
	)
	check(
		not Stove.slotAcceptsItem(OUTPUT, "cooked_fish")
			and not Stove.slotAcceptsItem(OUTPUT, "log")
			and not Stove.slotAcceptsItem(OUTPUT, "fish"),
		"slotAcceptsItem: the output slot takes nothing"
	)
	check(
		not Stove.slotAcceptsItem(4, "fish") and not Stove.slotAcceptsItem(4, "log"),
		"slotAcceptsItem: a slot that a stove does not have takes nothing"
	)

	local pack = Inventory.new(4)
	Inventory.setStack(pack, 1, ItemStack.new("log", 6))
	Inventory.setStack(pack, 2, ItemStack.new("fish", 2))
	Inventory.setStack(pack, 3, ItemStack.new("stone", 1))
	local rig = stoveWith("-", "-", "cooked_fish 1")
	local screen = InventoryScreen.new(pack, rig.stove.inventory, Stove.slotAcceptsItem)
	check(
		InventoryScreen.moveFromSlotToInventory(screen, "pack", 1, "other") == 6,
		"moveFromSlotToInventory: logs sent to the stove all go in"
	)
	check(
		InventoryScreen.moveFromSlotToInventory(screen, "pack", 2, "other") == 2,
		"moveFromSlotToInventory: fish sent to the stove all go in"
	)
	check(
		InventoryScreen.moveFromSlotToInventory(screen, "pack", 3, "other") == 0,
		"moveFromSlotToInventory: stone sent to the stove goes nowhere"
	)
	check(
		contents(rig.stove) == "fish 2, log 6, cooked_fish 1",
		"moveFromSlotToInventory: each thing sent to the stove lands in its own slot"
	)
	check(
		Inventory.countItems(pack, "stone") == 1,
		"moveFromSlotToInventory: what the stove has no use for stays in the pack"
	)
	check(
		InventoryScreen.pickUpFromSlot(screen, "other", OUTPUT) == 1,
		"pickUpFromSlot: what was made can be taken out"
	)
	check(
		InventoryScreen.putDownInSlot(screen, "other", OUTPUT) == 0,
		"putDownInSlot: nothing can be put where it came from"
	)
	local done = stoveWith("fish 1", "log 1", "-")
	advance(done, 8)
	local doneScreen = InventoryScreen.new(Inventory.new(4), done.stove.inventory, Stove.slotAcceptsItem)
	check(
		InventoryScreen.pickUpFromSlot(doneScreen, "other", OUTPUT) == 1,
		"pickUpFromSlot: a cooked fish made by advance can be taken out"
	)
	check(
		doneScreen.carriedStack ~= nil and doneScreen.carriedStack.itemId == "cooked_fish",
		"pickUpFromSlot: and what is carried is the cooked fish"
	)
end

do -- getProgress, for a stove that has not been lit
	local rig = stoveWith("fish 2", "log 4", "-")
	local progress = Stove.getProgress(rig.stove, 100)
	check(
		progress.fuelBurnsOutAt == nil and progress.fuelBurnSeconds == 0,
		"getProgress: with the fire out there is no time at which the fuel burns out"
	)
	check(
		progress.workDoneAt == nil and progress.workSeconds == 0,
		"getProgress: with nothing worked on there is no time at which the work is done"
	)
	check(table.isfrozen(progress), "getProgress: a progress never changes")
	check(Stove.getFuelLeftRatio(progress, 100) == 0, "getFuelLeftRatio: 0 if the fire was out")
	check(Stove.getFuelLeftRatio(progress, 500) == 0, "getFuelLeftRatio: and 0 at any later time")
	check(Stove.getWorkDoneRatio(progress, 100) == 0, "getWorkDoneRatio: 0 if nothing was being worked on")
	check(Stove.getWorkDoneRatio(progress, 500) == 0, "getWorkDoneRatio: and 0 at any later time")
end

do -- getProgress, for what the stove can work on
	local function worksOn(input: string, fuel: string, output: string): boolean
		local rig = stoveWith(input, fuel, output)
		advance(rig, 0.5)
		local progress = Stove.getProgress(rig.stove, 0.5)
		return progress.workDoneAt ~= nil and progress.workSeconds > 0
	end
	check(not worksOn("-", "log 4", "-"), "getProgress: no work when the input slot holds nothing")
	check(worksOn("fish 2", "log 4", "-"), "getProgress: work on what is in the input slot, with a fire")
	check(not worksOn("stone 2", "log 4", "-"), "getProgress: no work for an item that has no recipe")
	check(
		not worksOn("fish 2", "log 4", "baked_apple 1"),
		"getProgress: no work when the output slot holds something else"
	)
	check(not worksOn("fish 2", "log 4", "cooked_fish 8"), "getProgress: no work when the output slot is full")
	check(worksOn("fish 2", "log 4", "cooked_fish 7"), "getProgress: work when the output slot has room for one more")

	local fish = stoveWith("fish 2", "log 4", "-")
	advance(fish, 0.5)
	local fishProgress = Stove.getProgress(fish.stove, 10)
	check(
		fishProgress.workSeconds == 8 and fishProgress.workDoneAt == 17.5,
		"getProgress: a fish worked on for half a second takes 8 seconds in all"
	)
	local apple = stoveWith("apple 1", "log 4", "-")
	advance(apple, 0.5)
	check(Stove.getProgress(apple.stove, 10).workSeconds == 6, "getProgress: each input has its own length of work")
	local unworked = stoveWith("fish 2", "log 4", "-")
	check(
		Stove.getProgress(unworked.stove, 10).workDoneAt == nil,
		"getProgress: nothing is worked on in a stove that has not advanced, though it could be"
	)
end

do -- getProgress, for a stove that is burning and working
	local rig = stoveWith("fish 2", "log 4", "-")
	advance(rig, 4)
	local progress = Stove.getProgress(rig.stove, 104)
	check(
		progress.fuelBurnsOutAt == 116 and progress.fuelBurnSeconds == 16,
		"getProgress: a log lit 4 seconds ago burns out 12 seconds from now, and burns for 16 in all"
	)
	check(
		progress.workDoneAt == 108 and progress.workSeconds == 8,
		"getProgress: a fish worked on for 4 seconds is done 4 seconds from now, and takes 8 in all"
	)
	check(near(Stove.getFuelLeftRatio(progress, 104), 0.75), "getFuelLeftRatio: three quarters of the log is left")
	check(near(Stove.getWorkDoneRatio(progress, 104), 0.5), "getWorkDoneRatio: the fish is half done")
end

do -- a progress read at a later time agrees with the stove at that time
	local rig = stoveWith("fish 2", "log 4", "-")
	advance(rig, 4)
	local early = Stove.getProgress(rig.stove, 104)
	advance(rig, 2)
	local late = Stove.getProgress(rig.stove, 106)
	check(
		near(Stove.getFuelLeftRatio(early, 106), Stove.getFuelLeftRatio(late, 106)),
		"getFuelLeftRatio: a progress made 2 seconds ago gives the fuel left now"
	)
	check(near(Stove.getFuelLeftRatio(early, 106), 10 / 16), "getFuelLeftRatio: which is ten sixteenths")
	check(
		near(Stove.getWorkDoneRatio(early, 106), Stove.getWorkDoneRatio(late, 106)),
		"getWorkDoneRatio: a progress made 2 seconds ago gives the work done now"
	)
	check(near(Stove.getWorkDoneRatio(early, 106), 0.75), "getWorkDoneRatio: which is three quarters")
end

do -- a progress made later equals an earlier one while the stove only burns and works
	local rig = stoveWith("fish 2", "log 4", "-")
	advance(rig, 0.1)
	local now = 100.1
	local first = Stove.getProgress(rig.stove, now)
	local stayedTheSame = true
	for _ = 1, 78 do
		advance(rig, 0.1)
		now += 0.1
		stayedTheSame = stayedTheSame and same(first, Stove.getProgress(rig.stove, now))
	end
	check(
		stayedTheSame,
		"getProgress: 78 progresses made a tenth of a second apart, while the first fish cooks, are all equal"
	)
	check(
		first.fuelBurnsOutAt == 116 and first.workDoneAt == 108,
		"getProgress: and each says when the log burns out and when the fish is done"
	)

	advance(rig, 0.2)
	now += 0.2
	local afterTheFish = Stove.getProgress(rig.stove, now)
	check(not same(first, afterTheFish), "getProgress: a progress made after the fish is done is a different one")
	check(afterTheFish.workDoneAt == 116, "getProgress: it says when the second fish will be done")
	check(afterTheFish.fuelBurnsOutAt == 116, "getProgress: and the log still burns out when it did")
end

do -- the times are rounded to the millisecond
	local rig = stoveWith("fish 2", "log 4", "-")
	advance(rig, 0.1)
	local progress = Stove.getProgress(rig.stove, 100.10004)
	check(progress.fuelBurnsOutAt == 116, "getProgress: the time the fuel burns out is rounded to the millisecond")
	check(progress.workDoneAt == 108, "getProgress: and so is the time the work is done")
	local later = Stove.getProgress(rig.stove, 100.1006)
	check(later.fuelBurnsOutAt == 116.001, "getProgress: a time more than half a millisecond on rounds up")
	check(later.workDoneAt == 108.001, "getProgress: for the work as well")
end

do -- the ratios stay between 0 and 1
	local rig = stoveWith("fish 2", "log 4", "-")
	advance(rig, 4)
	local progress = Stove.getProgress(rig.stove, 104)
	check(Stove.getFuelLeftRatio(progress, 116) == 0, "getFuelLeftRatio: 0 at the time the fuel burns out")
	check(Stove.getFuelLeftRatio(progress, 300) == 0, "getFuelLeftRatio: 0 after it, not less")
	check(Stove.getFuelLeftRatio(progress, 100) == 1, "getFuelLeftRatio: 1 at the time it was lit")
	check(Stove.getFuelLeftRatio(progress, 50) == 1, "getFuelLeftRatio: 1 before it, not more")
	check(Stove.getWorkDoneRatio(progress, 108) == 1, "getWorkDoneRatio: 1 at the time the work is done")
	check(Stove.getWorkDoneRatio(progress, 300) == 1, "getWorkDoneRatio: 1 after it, not more")
	check(Stove.getWorkDoneRatio(progress, 100) == 0, "getWorkDoneRatio: 0 at the time the work began")
	check(Stove.getWorkDoneRatio(progress, 50) == 0, "getWorkDoneRatio: 0 before it, not less")
end

do -- what is in the input slot was put there in the place of something else
	local rig = stoveWith("fish 2", "log 4", "-")
	advance(rig, 4)
	Inventory.setStack(rig.stove.inventory, INPUT, ItemStack.new("apple", 2))
	local swapped = Stove.getProgress(rig.stove, 104)
	check(
		swapped.workDoneAt == nil and Stove.getWorkDoneRatio(swapped, 104) == 0,
		"getProgress: nothing is being worked on when the item in the input slot has just replaced another"
	)
	check(swapped.fuelBurnsOutAt == 116, "getProgress: though the fire burns on")
	advance(rig, 3)
	local working = Stove.getProgress(rig.stove, 107)
	check(
		working.workDoneAt == 110 and working.workSeconds == 6,
		"getProgress: an apple worked on for 3 seconds is done 3 seconds from now, and takes 6 in all"
	)
	check(near(Stove.getWorkDoneRatio(working, 107), 0.5), "getWorkDoneRatio: the apple is half done")
end

do -- a fire that is nearly out, and a fire with nothing to work on
	local nearlyOut = stoveWith("fish 2", "log 1", "-")
	advance(nearlyOut, 15.5)
	local progress = Stove.getProgress(nearlyOut.stove, 115.5)
	check(
		near(Stove.getFuelLeftRatio(progress, 115.5), 0.5 / 16),
		"getFuelLeftRatio: above 0 for a fire with half a second left"
	)

	local burningDown = stoveWith("fish 1", "log 1", "-")
	advance(burningDown, 10)
	local down = Stove.getProgress(burningDown.stove, 110)
	check(
		down.fuelBurnsOutAt == 116 and near(Stove.getFuelLeftRatio(down, 110), 6 / 16),
		"getProgress: a fire burns on with nothing to work on"
	)
	check(down.workDoneAt == nil and down.workSeconds == 0, "getProgress: and then nothing is being worked on")

	local out = stoveWith("fish 2", "log 1", "-")
	advance(out, 16)
	advance(out, 1)
	local cold = Stove.getProgress(out.stove, 117)
	check(
		cold.fuelBurnsOutAt == nil and cold.workDoneAt == nil,
		"getProgress: a fire that has burnt out, with no fuel left, is out"
	)
end

do -- getScreenData
	local world, _, stoveId = newWorld()
	local stove = Stove.get(world.plot, stoveId)
	Inventory.setStack(stove.inventory, INPUT, ItemStack.new("fish", 2))
	Inventory.setStack(stove.inventory, FUEL, ItemStack.new("log", 4))
	Stove.advance(world, stoveId, 4)
	local data = Stove.getScreenData(world, stoveId)
	check(same(data, Stove.getProgress(stove, 50)), "getScreenData: the progress of the stove at the world's time")
	check(
		data.fuelBurnsOutAt == 62 and data.workDoneAt == 54,
		"getScreenData: says when the fuel burns out and when the work is done on the world's clock"
	)
	check(table.isfrozen(data), "getScreenData: is plain data that never changes")
end

do -- interact
	local world, player, stoveId = newWorld()
	local slots = Stove.get(world.plot, stoveId).inventory
	Stove.interact(world, player, stoveId)
	local screen = player.screen :: InventoryScreen.InventoryScreen
	check(
		screen ~= nil and screen.pack == player.pack and screen.otherInventory == slots,
		"interact: the slots of the stove open on the player's screen, beside their pack"
	)
	check(World.getOpenedPlacedObjectId(world, player) == stoveId, "interact: as the screen of that stove")
	check(
		InventoryScreen.slotAcceptsItem(screen, "other", INPUT, "fish")
			and not InventoryScreen.slotAcceptsItem(screen, "other", INPUT, "log"),
		"interact: the input slot takes only what a stove has a recipe for"
	)
	check(
		InventoryScreen.slotAcceptsItem(screen, "other", FUEL, "log")
			and not InventoryScreen.slotAcceptsItem(screen, "other", FUEL, "fish"),
		"interact: the fuel slot takes only what burns"
	)
	check(
		not InventoryScreen.slotAcceptsItem(screen, "other", OUTPUT, "cooked_fish"),
		"interact: nothing can be put in the output slot"
	)
	check(InventoryScreen.slotAcceptsItem(screen, "pack", 1, "fish"), "interact: while the pack takes anything")

	Inventory.setStack(player.pack, 1, ItemStack.new("log", 6))
	InventoryScreen.pickUpFromSlot(screen, "pack", 1)
	Stove.interact(world, player, stoveId)
	check(
		player.screen ~= screen and player.screen ~= nil,
		"interact: a screen that was open is closed, and a new one opens"
	)
	check(
		Inventory.countItems(player.pack, "log") == 6,
		"interact: and what was carried on the old screen is in the player's pack"
	)

	World.closeScreen(world, player)
	World.setCharacterPosition(world, 1, at(500, 0, 500))
	Stove.interact(world, player, stoveId)
	check(
		World.getOpenedPlacedObjectId(world, player) == stoveId,
		"interact: it does not ask how far from the stove the player stands"
	)
	World.setCharacterPosition(world, 1, at(6, 0, 0))

	local second = World.addPlayer(world, 2)
	check(
		string.find(Check.errorFrom(function()
			Stove.interact(world, second, stoveId)
		end) or "", "a screen can be opened only for a player who has a character", 1, true)
				~= nil
			and second.screen == nil,
		"interact: fails for a player with no character, saying so"
	)
end

do -- breakPlacedObject
	local world, breaker, stoveId = newWorld()
	local stove = Stove.get(world.plot, stoveId)
	local slots = stove.inventory
	Inventory.setStack(slots, INPUT, ItemStack.new("fish", 3))
	Inventory.setStack(slots, FUEL, ItemStack.new("log", 4))
	World.advanceTo(world, 54)
	check(
		Stove.isBurning(stove) and is(Inventory.getStack(slots, FUEL), "log", 3),
		"breakPlacedObject: (set up) the stove is lit, and one log is burning"
	)
	local watcher = World.addPlayer(world, 2)
	World.setCharacterPosition(world, 2, at(10, 0, 10))
	Stove.interact(world, watcher, stoveId)

	World.setCharacterPosition(world, 1, at(500, 0, 500))
	Stove.breakPlacedObject(world, stoveId)
	check(
		world.plot.placedObjectsById[stoveId] == nil,
		"breakPlacedObject: the stove is off the plot, though no player stands near it"
	)
	check(Plot.canPlaceObject(world.plot, 2, 2), "breakPlacedObject: and its tile holds nothing")
	check(
		watcher.screen == nil and World.getOpenedPlacedObjectId(world, watcher) == nil,
		"breakPlacedObject: a screen that was open on the stove is closed"
	)

	local ground = world.groundItems.itemsById
	check(
		groundItemCount(world) == 3,
		"breakPlacedObject: one ground item for the stove and one for each stack in its slots"
	)
	check(
		is(ground[1].stack, Stove.ITEM_ID_WHEN_BROKEN, 1),
		"breakPlacedObject: one of the item ITEM_ID_WHEN_BROKEN is thrown first"
	)
	check(
		is(ground[2].stack, "fish", 3) and is(ground[3].stack, "log", 3),
		"breakPlacedObject: then each stack that was in its slots, from the lowest slot up"
	)
	check(Inventory.isEmpty(slots), "breakPlacedObject: and the slots hold nothing")
	local middleHeight = (Plot.TILE_SIZE - GroundItems.ITEM_WIDTH) / 2
	local allFromTheMiddle, allUpwards = true, true
	local ways: { [string]: boolean } = {}
	local wayCount = 0
	for _, groundItem in ground do
		local position, velocity = groundItem.position, groundItem.spawnVelocity
		if Position.getDistance(position, at(6, middleHeight, 6)) > 1e-9 or groundItem.spawnTime ~= 54 then
			allFromTheMiddle = false
		end
		if velocity.y <= 0 or (velocity.x == 0 and velocity.z == 0) then
			allUpwards = false
		end
		local way = string.format("%.3f %.3f", velocity.x, velocity.z)
		wayCount += if ways[way] then 0 else 1
		ways[way] = true
	end
	check(
		allFromTheMiddle,
		"breakPlacedObject: each is thrown from the middle of the stove's tile, at the world's time"
	)
	check(allUpwards, "breakPlacedObject: upwards and outwards")
	check(wayCount == 3, "breakPlacedObject: each a different way")

	World.advanceTo(world, 200)
	local cooked = 0
	for _, groundItem in ground do
		cooked += if groundItem.stack.itemId == "cooked_fish" then groundItem.stack.count else 0
	end
	check(
		cooked == 0 and Inventory.isEmpty(slots),
		"breakPlacedObject: the fuel that was burning is lost, and nothing more is cooked"
	)
	check(
		breaker.screen == nil and Inventory.countItems(breaker.pack, "stove") == 0,
		"breakPlacedObject: the player who broke it is given nothing and has no screen opened"
	)

	local emptyWorld, _, emptyStoveId = newWorld()
	Stove.breakPlacedObject(emptyWorld, emptyStoveId)
	check(
		groundItemCount(emptyWorld) == 1 and is(emptyWorld.groundItems.itemsById[1].stack, Stove.ITEM_ID_WHEN_BROKEN, 1),
		"breakPlacedObject: a stove whose slots hold nothing leaves one of the item ITEM_ID_WHEN_BROKEN and no more"
	)
end

do -- what the stove's functions fail for
	local world, player = newWorld()
	local bell = placeBellWithFire(world.plot, 1, 1)
	local bare = Plot.placeObject(world.plot, { kindId = Stove.PLACED_OBJECT_KIND_ID, tileX = 1, tileZ = 2 })
	local cases = {
		{ id = 99, what = "an id that no placed object has" },
		{ id = bell, what = "a placed object of another kind, even with a fire field on it" },
		{ id = bare, what = "a placed object of the stove's kind with no fire on it" },
	}
	for _, case in cases do
		local id = case.id
		local message = `the placed object {id} is not a stove that Stove.place placed`
		check(
			Check.raises(message, function()
				Stove.advance(world, id, 1)
			end),
			"advance: fails for " .. case.what
		)
		check(
			Check.raises(message, function()
				Stove.interact(world, player, id)
			end),
			"interact: fails for " .. case.what
		)
		check(player.screen == nil, "interact: and opens no screen for " .. case.what)
		check(
			Check.raises(message, function()
				Stove.breakPlacedObject(world, id)
			end),
			"breakPlacedObject: fails for " .. case.what
		)
		check(
			Check.raises(message, function()
				Stove.getScreenData(world, id)
			end),
			"getScreenData: fails for " .. case.what
		)
	end
	check(
		world.plot.placedObjectsById[bell] ~= nil
			and world.plot.placedObjectsById[bare] ~= nil
			and groundItemCount(world) == 0,
		"breakPlacedObject: and leaves each standing, with nothing thrown"
	)
end

do -- many random puts, takes and steps: fuel only burns, and each thing made uses up one thing put in
	local seed = 31337
	local function random(limit: number): number
		seed = (seed * 16807) % 2147483647
		return math.floor(seed / 65536) % limit + 1
	end
	local itemIds = { "fish", "cooked_fish", "apple", "baked_apple", "stone", "log" }
	local function count(stove: Stove.Stove, itemId: string): number
		return Inventory.countItems(stove.inventory, itemId)
	end
	local kept, sane, fuelOnlyBurns = true, true, true
	for _ = 1, 40 do
		local rig = stoveWith("-", "-", "-")
		local stove = rig.stove
		for _ = 1, 150 do
			local action = random(10)
			if action <= 3 then
				local itemId = itemIds[random(#itemIds)]
				local stack = ItemStack.new(itemId, random(ItemRegistry.get(itemId).stackSize))
				Inventory.setStack(stove.inventory, random(3), if random(5) == 1 then nil else stack)
			elseif action == 4 then
				Inventory.takeFromSlot(stove.inventory, random(3), random(8))
			else
				local fish = count(stove, "fish") + count(stove, "cooked_fish")
				local apples = count(stove, "apple") + count(stove, "baked_apple")
				local fuel = count(stove, "log")
				local stone = count(stove, "stone")
				local raw = count(stove, "fish") + count(stove, "apple")
				advance(rig, random(400) / 10)
				if
					count(stove, "fish") + count(stove, "cooked_fish") ~= fish
					or count(stove, "apple") + count(stove, "baked_apple") ~= apples
					or count(stove, "stone") ~= stone
				then
					kept = false
				end
				if count(stove, "log") > fuel or count(stove, "fish") + count(stove, "apple") > raw then
					fuelOnlyBurns = false
				end
			end
			if
				stove.fire.burnSecondsLeft < 0
				or stove.work.workedSeconds < 0
				or stove.work.workedSeconds >= 8
				or stove.fire.burnSecondsLeft > 16
			then
				sane = false
			end
			for slot = 1, 3 do
				local stack = Inventory.getStack(stove.inventory, slot)
				if stack ~= nil and ItemStack.validate(stack) ~= nil then
					sane = false
				end
			end
		end
	end
	check(kept, "advance: random use: each thing made uses up one thing put in, and nothing else changes")
	check(fuelOnlyBurns, "advance: random use: fuel and raw things are never made")
	check(sane, "advance: random use: the fire and the work done stay within their bounds, and every stack is real")
end

Check.finish("Stove")
