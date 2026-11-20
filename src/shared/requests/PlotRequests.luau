--!strict
--- What a player's machine may ask for on the plot.
---
--- Each function is one request. `world` is the world and `player` is the player who asks. Every
--- argument after them is what the player's machine sent, and may be any value at all. A request
--- that makes no sense for the player as they are now does nothing.
local Hotbar = require("../inventory/Hotbar")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local World = require("../world/World")

local PlotRequests = {}

type World = World.World
type PlayerState = PlayerState.PlayerState

local function isPlacedObjectInReach(world: World, player: PlayerState, placedObjectId: unknown): boolean
	local placedObject = world.plot.placedObjectsById[placedObjectId :: number]
	return placedObject ~= nil and World.canReachTile(world, player, placedObject.x, placedObject.z)
end

--- Places one of the item in the player's selected hotbar slot on the tile `x`, `z` of the plot,
--- and takes it out of that slot. Ground items lying where it now stands are pushed out of it.
--- Does nothing if that slot holds nothing, if they have a screen open, if the plot has no such
--- tile, if they stand more than `World.REACH` from it, if a player stands on it, if something
--- already stands on it, or if the item is not one that can be placed.
function PlotRequests.placeSelectedItem(world: World, player: PlayerState, x: unknown, z: unknown)
	local selected = Hotbar.getSelectedStack(player.hotbar)
	if selected == nil or player.screen ~= nil or not Plot.hasTile(world.plot, x, z) then
		return
	end
	local tileX, tileZ = x :: number, z :: number
	local canPlace = World.canReachTile(world, player, tileX, tileZ)
		and World.canPlaceObject(world, selected.itemId, tileX, tileZ)
	if canPlace then
		Plot.placeObject(world.plot, selected.itemId, tileX, tileZ)
		Hotbar.takeFromSelectedSlot(player.hotbar, 1)
	end
end

--- The player uses the placed object with the id `placedObjectId`: its inventory opens on their
--- screen, beside their pack, in place of any screen they had open. Does nothing if no placed object
--- has that id, if it has no inventory, or if the player stands more than `World.REACH` from it.
function PlotRequests.usePlacedObject(world: World, player: PlayerState, placedObjectId: unknown)
	local canOpen = isPlacedObjectInReach(world, player, placedObjectId)
		and World.canOpenPlacedObjectScreen(world, player, placedObjectId :: number)
	if canOpen then
		World.openPlacedObjectScreen(world, player, placedObjectId :: number)
	end
end

--- The player hits the placed object with the id `placedObjectId`, which knocks it off the plot: it
--- is taken off the plot and thrown into the world as a ground item, and so is every stack that
--- was inside it. Any screen open on it closes. Does nothing if no placed object has that id, or if
--- the player stands more than `World.REACH` from it.
function PlotRequests.hitPlacedObject(world: World, player: PlayerState, placedObjectId: unknown)
	if not isPlacedObjectInReach(world, player, placedObjectId) then
		return
	end
	local placedObject = Plot.removePlacedObject(world.plot, placedObjectId :: number)
	if placedObject ~= nil then
		World.throwPlacedObjectAndContents(world, placedObject)
	end
end

return PlotRequests
