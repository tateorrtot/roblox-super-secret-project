--!strict
--- What a player's machine may ask for on the plot.
---
--- Each function is one request. `world` is the world and `player` is the player who asks. Every
--- argument after them is what the player's machine sent, and may be any value at all. A request
--- that makes no sense for the player as they are now does nothing.
local Hotbar = require("../inventory/Hotbar")
local Inventory = require("../inventory/Inventory")
local ItemRegistry = require("../items/ItemRegistry")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local RecipeRegistry = require("../stations/RecipeRegistry")
local Station = require("../stations/Station")
local World = require("../world/World")

local PlotRequests = {}

type World = World.World
type PlayerState = PlayerState.PlayerState

local function isPlacedObjectInReach(world: World, player: PlayerState, placedObjectId: unknown): boolean
	local placedObject = world.plot.placedObjectsById[placedObjectId :: number]
	return placedObject ~= nil and World.canReachTile(world, player, placedObject.x, placedObject.z)
end

local function findInventoryOf(world: World, placedObjectId: number): Inventory.Inventory?
	local station = world.stations[placedObjectId]
	return if station ~= nil then station.inventory else world.placedObjectInventories[placedObjectId]
end

local function addWhatItemDefines(world: World, placedObjectId: number, itemId: string)
	local slotCount = ItemRegistry.get(itemId).slotCount
	if slotCount == nil then
		return
	end
	if RecipeRegistry.isStation(itemId) then
		World.addStation(world, placedObjectId, Station.new(itemId, Inventory.new(slotCount)))
	else
		World.addPlacedObjectInventory(world, placedObjectId, Inventory.new(slotCount))
	end
end

--- Places one of the item in the player's selected hotbar slot on the tile `x`, `z` of the plot,
--- and takes it out of that slot. Ground items lying where it now stands are pushed out of it. If
--- the item's definition has a `slotCount`, the placed object is given an inventory of that many
--- slots, holding nothing, and if a recipe names the item it is made a station over that
--- inventory. Does nothing if that slot holds nothing, if they have a screen open, if the plot has
--- no such tile, if they stand more than `World.REACH` from it, if a player stands on it, if
--- something already stands on it, or if the item is not one that can be placed.
function PlotRequests.placeSelectedItem(world: World, player: PlayerState, x: unknown, z: unknown)
	local selected = Hotbar.getSelectedStack(player.hotbar)
	if selected == nil or player.screen ~= nil or not Plot.hasTile(world.plot, x, z) then
		return
	end
	local tileX, tileZ = x :: number, z :: number
	local canPlace = World.canReachTile(world, player, tileX, tileZ)
		and World.canPlaceObject(world, selected.itemId, tileX, tileZ)
	if canPlace then
		local placedObjectId = Plot.placeObject(world.plot, selected.itemId, tileX, tileZ)
		addWhatItemDefines(world, placedObjectId, selected.itemId)
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
	local itemId = world.plot.placedObjectsById[id].itemId
	local stationSlotAcceptsItem = function(slot: number, putItemId: string): boolean
		return Station.slotAcceptsItem(itemId, slot, putItemId)
	end
	if inventory ~= nil then
		local isStation = world.stations[id] ~= nil
		World.openPlacedObjectScreen(world, player, id, inventory, if isStation then stationSlotAcceptsItem else nil)
	end
end

--- The player hits the placed object with the id `placedObjectId`, which knocks it off the plot:
--- it is taken off the plot, and one of its item and then every stack that was inside it are
--- thrown onto the ground from its tile, as `World.throwStacksFromTile` does. Any screen open on
--- it closes. Does nothing if no placed object has that id, or if the player stands more than
--- `World.REACH` from it.
function PlotRequests.hitPlacedObject(world: World, player: PlayerState, placedObjectId: unknown)
	if not isPlacedObjectInReach(world, player, placedObjectId) then
		return
	end
	local id = placedObjectId :: number
	local placedObject = world.plot.placedObjectsById[id]
	local inventory = findInventoryOf(world, id)
	local stacks = if inventory ~= nil then Inventory.takeEveryStack(inventory) else {}
	table.insert(stacks, 1, ItemStack.new(placedObject.itemId, 1))
	Plot.removePlacedObject(world.plot, id)
	World.throwStacksFromTile(world, stacks, placedObject.x, placedObject.z)
end

return PlotRequests
