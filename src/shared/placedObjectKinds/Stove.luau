--!strict
--- A stove: a placed object that cooks one item into another while its fire burns.
---
--- `place` stands a stove on a tile of the world's plot and makes it a station. `interact` opens
--- the station's slots on a player's screen. `breakPlacedObject` takes the stove off the plot, and
--- throws a stove item and everything that was in its slots onto the ground.
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local Station = require("../stations/Station")
local World = require("../world/World")

local Stove = {}

--- The id of the kind of placed object that a stove is. A stove's recipes are the ones
--- registered for a station of this kind.
Stove.KIND_ID = "stove"

--- The id of the item that a broken stove leaves.
Stove.ITEM_ID = "stove"

local function slotAcceptsItem(slot: number, itemId: string): boolean
	return Station.slotAcceptsItem(Stove.KIND_ID, slot, itemId)
end

--- Places a stove on the tile `tileX`, `tileZ` of the world's plot, and returns the placed
--- object's id. The stove is made a station of the kind `KIND_ID`, with no fire and with slots
--- that hold nothing. Fails if `Plot.canPlaceObject` would return `false` for that tile.
function Stove.place(world: World.World, tileX: number, tileZ: number): number
	local placedObjectId = Plot.placeObject(world.plot, Stove.KIND_ID, tileX, tileZ)
	local station = Station.new(Stove.KIND_ID, Inventory.new(Station.SLOT_COUNT))
	World.addStation(world, placedObjectId, station)
	return placedObjectId
end

--- A player interacts with the stove that has the id `placedObjectId`. The slots of the stove's
--- station open on the player's screen, beside their pack, in place of any screen they had open.
--- The input slot takes only what a stove has a recipe for, the fuel slot takes only what burns,
--- and nothing can be put in the output slot. Fails if the player has no character.
function Stove.interact(world: World.World, player: PlayerState.PlayerState, placedObjectId: number)
	local station = world.stations[placedObjectId]
	World.openPlacedObjectScreen(world, player, placedObjectId, station.inventory, slotAcceptsItem)
end

--- A player breaks the stove that has the id `placedObjectId`. The stove is taken off the plot,
--- which closes every screen that was open on it and puts its fire out: the fuel that was burning
--- is lost. One of the item `ITEM_ID`, and then each stack that was in the stove's slots from the
--- lowest slot up, is thrown onto the ground from the middle of the stove's tile, upwards and
--- outwards, each a different way.
function Stove.breakPlacedObject(world: World.World, _player: PlayerState.PlayerState, placedObjectId: number)
	local placedObject = world.plot.placedObjectsById[placedObjectId]
	local stacks = Inventory.takeEveryStack(world.stations[placedObjectId].inventory)
	table.insert(stacks, 1, ItemStack.new(Stove.ITEM_ID, 1))
	Plot.removePlacedObject(world.plot, placedObjectId)
	World.throwStacksFromTile(world, stacks, placedObject.tileX, placedObject.tileZ)
end

return Stove
