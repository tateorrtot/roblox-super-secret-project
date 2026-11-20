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

local function isPlacedItemInReach(world: World, player: PlayerState, placedItemId: unknown): boolean
	local placedItem = world.plot.placedItemsById[placedItemId :: number]
	return placedItem ~= nil and World.canReachTile(world, player, placedItem.x, placedItem.z)
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
	if World.canReachTile(world, player, tileX, tileZ) and World.placeItem(world, selected.itemId, tileX, tileZ) then
		Hotbar.takeFromSelectedSlot(player.hotbar, 1)
	end
end

--- The player uses the placed item with the id `placedItemId`: its inventory opens on their
--- screen, beside their pack, in place of any screen they had open. Does nothing if no placed item
--- has that id, if it has no inventory, or if the player stands more than `World.REACH` from it.
function PlotRequests.usePlacedItem(world: World, player: PlayerState, placedItemId: unknown)
	if isPlacedItemInReach(world, player, placedItemId) then
		World.openPlacedItem(world, player, placedItemId :: number)
	end
end

--- The player hits the placed item with the id `placedItemId`, which knocks it off the plot: it
--- spills out of where it stood as a ground item, and what was inside it spills out after it. Does
--- nothing if no placed item has that id, or if the player stands more than `World.REACH` from it.
function PlotRequests.hitPlacedItem(world: World, player: PlayerState, placedItemId: unknown)
	if isPlacedItemInReach(world, player, placedItemId) then
		World.removePlacedItem(world, placedItemId :: number)
	end
end

return PlotRequests
