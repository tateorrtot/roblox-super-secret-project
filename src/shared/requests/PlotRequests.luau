--!strict
--- What a player's machine may ask for on the plot.
---
--- Each function is one request. `world` is the world and `player` is the player who asks. Every
--- argument after them is what the player's machine sent, and may be any value at all. A request
--- that makes no sense for the player as they are now does nothing.
---
--- A request says what the player did, and to what. What follows is not decided here: what
--- interacting with a placed object does, and what breaking one leaves, is for its kind to say.
local Hotbar = require("../inventory/Hotbar")
local PlaceableItems = require("../placedObjectKinds/PlaceableItems")
local PlacedObjectKinds = require("../placedObjectKinds/PlacedObjectKinds")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local World = require("../world/World")

local PlotRequests = {}

type World = World.World
type PlayerState = PlayerState.PlayerState

local function findPlacedObjectInReach(world: World, player: PlayerState, placedObjectId: unknown): Plot.PlacedObject?
	local placedObject = world.plot.placedObjectsById[placedObjectId :: number]
	if placedObject == nil or not World.canReachTile(world, player, placedObject.tileX, placedObject.tileZ) then
		return nil
	end
	return placedObject
end

--- The player interacts with the tile `tileX`, `tileZ` of the plot. If `PlaceableItems` has a
--- row for the item in their selected hotbar slot, an object of the row's kind is placed on the
--- tile, as that kind's own `place` does, and one of the item is taken out of the slot. Does
--- nothing if that slot holds nothing, if its item places nothing, if they have a screen open, if
--- the plot has no such tile, if they stand more than `World.REACH` from it, if a player stands
--- on it, or if something already stands on it.
function PlotRequests.interactWithTile(world: World, player: PlayerState, tileX: unknown, tileZ: unknown)
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

--- The player interacts with the placed object that has the id `placedObjectId`: the `interact`
--- of that placed object's kind is called. Does nothing if no placed object has that id, or if
--- the player stands more than `World.REACH` from it.
function PlotRequests.interactWithPlacedObject(world: World, player: PlayerState, placedObjectId: unknown)
	local placedObject = findPlacedObjectInReach(world, player, placedObjectId)
	if placedObject ~= nil then
		PlacedObjectKinds.get(placedObject.kindId).interact(world, player, placedObjectId :: number)
	end
end

--- The player breaks the placed object that has the id `placedObjectId`: the `breakPlacedObject`
--- of that placed object's kind is called. Does nothing if no placed object has that id, or if
--- the player stands more than `World.REACH` from it.
function PlotRequests.breakPlacedObject(world: World, player: PlayerState, placedObjectId: unknown)
	local placedObject = findPlacedObjectInReach(world, player, placedObjectId)
	if placedObject ~= nil then
		PlacedObjectKinds.get(placedObject.kindId).breakPlacedObject(world, player, placedObjectId :: number)
	end
end

return PlotRequests
