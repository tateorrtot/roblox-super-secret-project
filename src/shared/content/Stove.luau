--!strict
--- A stove: a placed object that cooks one item into another while its fire burns.
---
--- `place` stands a stove on a tile of the world's plot and makes it a station. `interact` and
--- `breakPlacedObject` are what happens when a player interacts with a stove and breaks one: if
--- the player's character reaches it, the first opens the station's slots on the player's screen,
--- and the second takes the stove off the plot and throws a stove item and everything that was in
--- its slots onto the ground.
---
--- Note: `interact` and `breakPlacedObject` are for a stove that `place` placed. A placed object
--- of the stove's kind that was put on the plot any other way is no station, and both fail for
--- it.
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local Station = require("../stations/Station")
local World = require("../world/World")

local Stove = {}

--- The id of the kind of placed object that a stove is.
Stove.PLACED_OBJECT_KIND_ID = "stove"

--- The id of the kind of station that a stove is made. A stove's recipes are the ones registered
--- for a station of this kind.
Stove.STATION_KIND_ID = "stove"

--- The id of the item that a broken stove leaves.
Stove.ITEM_ID_WHEN_BROKEN = "stove"

local function slotAcceptsItem(slot: number, itemId: string): boolean
	return Station.slotAcceptsItem(Stove.STATION_KIND_ID, slot, itemId)
end

--- Places a stove on the tile `tileX`, `tileZ` of the world's plot, and returns the placed
--- object's id. The stove is made a station of the kind `STATION_KIND_ID`, with no fire and with
--- slots that hold nothing. Fails if `Plot.canPlaceObject` would return `false` for that tile.
function Stove.place(world: World.World, tileX: number, tileZ: number): number
	local placedObjectId = Plot.placeObject(world.plot, Stove.PLACED_OBJECT_KIND_ID, tileX, tileZ)
	local station = Station.new(Stove.STATION_KIND_ID, Inventory.new(Station.SLOT_COUNT))
	World.addStation(world, placedObjectId, station)
	return placedObjectId
end

local function getStation(world: World.World, placedObjectId: number): Station.Station
	return world.stations[placedObjectId]
		or error(`the placed object {placedObjectId} is not a stove that Stove.place placed`, 3)
end

local function canPlayerReach(world: World.World, player: PlayerState.PlayerState, placedObjectId: number): boolean
	local placedObject = world.plot.placedObjectsById[placedObjectId]
	return World.canReachTile(world, player, placedObject.tileX, placedObject.tileZ)
end

--- A player interacts with the stove that has the id `placedObjectId`. If `World.canReachTile`
--- says that the player's character reaches the stove's tile, the slots of the stove's station
--- open on the player's screen, beside their pack, in place of any screen they had open. The input
--- slot takes only what a stove has a recipe for, the fuel slot takes only what burns, and nothing
--- can be put in the output slot. Otherwise nothing happens.
function Stove.interact(world: World.World, player: PlayerState.PlayerState, placedObjectId: number)
	local station = getStation(world, placedObjectId)
	if canPlayerReach(world, player, placedObjectId) then
		World.openPlacedObjectScreen(world, player, placedObjectId, station.inventory, slotAcceptsItem)
	end
end

--- A player breaks the stove that has the id `placedObjectId`. If `World.canReachTile` says that
--- the player's character reaches the stove's tile, the stove is taken off the plot, which closes
--- every screen that was open on it and puts its fire out: the fuel that was burning is lost. One
--- of the item `ITEM_ID_WHEN_BROKEN`, and then each stack that was in the stove's slots from the
--- lowest slot up, is thrown onto the ground from the middle of the stove's tile, upwards and
--- outwards, each a different way. Otherwise nothing happens.
function Stove.breakPlacedObject(world: World.World, player: PlayerState.PlayerState, placedObjectId: number)
	local station = getStation(world, placedObjectId)
	if not canPlayerReach(world, player, placedObjectId) then
		return
	end
	local placedObject = world.plot.placedObjectsById[placedObjectId]
	local stacks = Inventory.takeEveryStack(station.inventory)
	table.insert(stacks, 1, ItemStack.new(Stove.ITEM_ID_WHEN_BROKEN, 1))
	Plot.removePlacedObject(world.plot, placedObjectId)
	World.throwStacksFromTile(world, stacks, placedObject.tileX, placedObject.tileZ)
end

return Stove
