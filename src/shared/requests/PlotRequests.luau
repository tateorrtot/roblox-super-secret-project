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

--- Places one of the item in the player's hand on the tile `x`, `z`, and takes it out of their
--- hand. Does nothing if they have a screen open, if the plot has no such tile, if they stand
--- more than `Plot.REACH` from it, or if the item cannot be placed there (see `World.placeItem`).
function PlotRequests.placeSelected(world: World, state: PlayerState, x: unknown, z: unknown)
	local inHand = Hotbar.getSelectedStack(state.hotbar)
	if inHand == nil or state.screen ~= nil or not Plot.hasTile(world.plot, x, z) then
		return
	end
	local tileX, tileZ = x :: number, z :: number
	if World.canReach(world, state, tileX, tileZ) and World.placeItem(world, inHand.itemId, tileX, tileZ) then
		Hotbar.takeSelected(state.hotbar, 1)
	end
end

--- Opens the inventory of the placed item with the id `id` on the player's screen, beside their
--- pack. Does nothing if no placed item has that id, if it has no inventory, or if the player
--- stands more than `Plot.REACH` from it.
function PlotRequests.usePlaced(world: World, state: PlayerState, id: unknown)
	local placedItem = world.plot.placedById[id :: number]
	if placedItem ~= nil and World.canReach(world, state, placedItem.x, placedItem.z) then
		World.openPlaced(world, state, id :: number)
	end
end

--- Takes the placed item with the id `id` off the plot, to lie on the ground as an item with
--- what was inside it around it. Does nothing if no placed item has that id, or if the player
--- stands more than `Plot.REACH` from it.
function PlotRequests.hitPlaced(world: World, state: PlayerState, id: unknown)
	local placedItem = world.plot.placedById[id :: number]
	if placedItem ~= nil and World.canReach(world, state, placedItem.x, placedItem.z) then
		World.removePlaced(world, id :: number)
	end
end

return PlotRequests
