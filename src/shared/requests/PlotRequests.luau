--!strict
--- What a player's machine may ask for on the plot.
---
--- Each function is one request. `world` is the world and `state` is the player who asks. Every
--- argument after them is what the player's machine sent, and may be any value at all. A request
--- that makes no sense for the player as they are now does nothing.
local Hotbar = require("../inventory/Hotbar")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local World = require("../world/World")

local PlotRequests = {}

type World = World.World
type PlayerState = PlayerState.PlayerState

local function isPlacedInReach(world: World, state: PlayerState, id: unknown): boolean
	local placedItem = world.plot.placedById[id :: number]
	return placedItem ~= nil and World.canReachTile(world, state, placedItem.x, placedItem.z)
end

--- Places one of the item in the player's hand on the tile `x`, `z` of the plot, and takes it
--- out of their hand. Does nothing if their hand is empty, if they have a screen open, if the plot
--- has no such tile, if they stand more than `World.REACH` from it, if a player stands on it, if
--- something already stands on it, or if the item is not one that can be placed.
function PlotRequests.placeSelected(world: World, state: PlayerState, x: unknown, z: unknown)
	local inHand = Hotbar.getSelectedStack(state.hotbar)
	if inHand == nil or state.screen ~= nil or not Plot.hasTile(world.plot, x, z) then
		return
	end
	local tileX, tileZ = x :: number, z :: number
	if World.canReachTile(world, state, tileX, tileZ) and World.placeItem(world, inHand.itemId, tileX, tileZ) then
		Hotbar.takeSelected(state.hotbar, 1)
	end
end

--- The player uses the placed item with the id `id`: its inventory opens on their screen, beside
--- their pack, in place of any screen they had open. Does nothing if no placed item has that id,
--- if it has no inventory, or if the player stands more than `World.REACH` from it.
function PlotRequests.usePlaced(world: World, state: PlayerState, id: unknown)
	if isPlacedInReach(world, state, id) then
		World.openPlaced(world, state, id :: number)
	end
end

--- The player hits the placed item with the id `id`, which knocks it off the plot: it lies on
--- the ground as an item, and what was inside it lies around it. Does nothing if no placed item
--- has that id, or if the player stands more than `World.REACH` from it.
function PlotRequests.hitPlaced(world: World, state: PlayerState, id: unknown)
	if isPlacedInReach(world, state, id) then
		World.removePlaced(world, id :: number)
	end
end

return PlotRequests
