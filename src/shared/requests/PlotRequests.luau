--!strict
--- What a player's machine may ask for on the plot.
---
--- Each function is one request. `world` is the world and `player` is the player who asks. Every
--- argument after them is what the player's machine sent, and may be any value at all. A request
--- that makes no sense for the player as they are now does nothing.
local Hotbar = require("../inventory/Hotbar")
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local PlaceableItems = require("../placedObjectKinds/PlaceableItems")
local PlacedObjectKinds = require("../placedObjectKinds/PlacedObjectKinds")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local Station = require("../stations/Station")
local World = require("../world/World")

local PlotRequests = {}

type World = World.World
type PlayerState = PlayerState.PlayerState

local function isPlacedObjectInReach(world: World, player: PlayerState, placedObjectId: unknown): boolean
	local placedObject = world.plot.placedObjectsById[placedObjectId :: number]
	return placedObject ~= nil and World.canReachTile(world, player, placedObject.tileX, placedObject.tileZ)
end

local function findInventoryOf(world: World, placedObjectId: number): Inventory.Inventory?
	local station = world.stations[placedObjectId]
	return if station ~= nil then station.inventory else world.placedObjectInventories[placedObjectId]
end

local function findItemIdThatPlaces(kindId: string): string?
	for itemId, placedKindId in PlaceableItems do
		if placedKindId == kindId then
			return itemId
		end
	end
	return nil
end

--- The player places what the item in their selected hotbar slot places, on the tile `tileX`,
--- `tileZ` of the plot. If `PlaceableItems` has a row for that item, an object of the row's kind
--- is placed on the tile as that kind's `place` does, and one of the item is taken out of the
--- slot. Ground items lying where the object now stands are pushed out of its tile. Does nothing
--- if that slot holds nothing, if its item places nothing, if they have a screen open, if the
--- plot has no such tile, if they stand more than `World.REACH` from it, if a player stands on it,
--- or if something already stands on it.
function PlotRequests.placeSelectedItem(world: World, player: PlayerState, tileX: unknown, tileZ: unknown)
	local selected = Hotbar.getSelectedStack(player.hotbar)
	local kindId = if selected ~= nil then PlaceableItems[selected.itemId] else nil
	if kindId == nil or player.screen ~= nil or not Plot.hasTile(world.plot, tileX, tileZ) then
		return
	end
	local x, z = tileX :: number, tileZ :: number
	if World.canReachTile(world, player, x, z) and World.canPlaceObject(world, x, z) then
		PlacedObjectKinds.get(kindId).place(world, x, z)
		Hotbar.takeFromSelectedSlot(player.hotbar, 1)
	end
end

--- The player uses the placed object with the id `placedObjectId`: its inventory opens on their
--- screen, beside their pack, in place of any screen they had open. If it is a station, each of
--- its slots takes only what a station's slot takes. Does nothing if no placed object has that id,
--- if it has no inventory, or if the player stands more than `World.REACH` from it.
function PlotRequests.usePlacedObject(world: World, player: PlayerState, placedObjectId: unknown)
	if not isPlacedObjectInReach(world, player, placedObjectId) then
		return
	end
	local id = placedObjectId :: number
	local inventory = findInventoryOf(world, id)
	local kindId = world.plot.placedObjectsById[id].kindId
	local stationSlotAcceptsItem = function(slot: number, itemId: string): boolean
		return Station.slotAcceptsItem(kindId, slot, itemId)
	end
	if inventory ~= nil then
		local isStation = world.stations[id] ~= nil
		World.openPlacedObjectScreen(world, player, id, inventory, if isStation then stationSlotAcceptsItem else nil)
	end
end

--- The player hits the placed object with the id `placedObjectId`, which knocks it off the plot:
--- it is taken off the plot, and one of the item that places its kind and then every stack that
--- was inside it are thrown onto the ground from its tile, as `World.throwStacksFromTile` does.
--- Any screen open on it closes. Does nothing if no placed object has that id, or if the player
--- stands more than `World.REACH` from it.
function PlotRequests.hitPlacedObject(world: World, player: PlayerState, placedObjectId: unknown)
	if not isPlacedObjectInReach(world, player, placedObjectId) then
		return
	end
	local id = placedObjectId :: number
	local placedObject = world.plot.placedObjectsById[id]
	local inventory = findInventoryOf(world, id)
	local itemId = findItemIdThatPlaces(placedObject.kindId)
	local stacks = if inventory ~= nil then Inventory.takeEveryStack(inventory) else {}
	if itemId ~= nil then
		table.insert(stacks, 1, ItemStack.new(itemId, 1))
	end
	Plot.removePlacedObject(world.plot, id)
	World.throwStacksFromTile(world, stacks, placedObject.tileX, placedObject.tileZ)
end

return PlotRequests
