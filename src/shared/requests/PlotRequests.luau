--!strict
--- What a player's machine may ask for on the plot.
---
--- Each function is one request. `world` is the world and `player` is the player who asks. Every
--- argument after them is what the player's machine sent, and may be any value at all. A request
--- that makes no sense for the player as they are now does nothing.
---
--- A request says what the player did, and to what. What is about the player is settled here:
--- that they have a character, that it stands within `World.CHARACTER_REACH` of what they act on,
--- and that the item they hold is the one in their selected hotbar slot. What follows is not. What
--- interacting with a tile does is for the script of the held item to say, in `ItemScripts`. What
--- interacting with a placed object does, and what breaking one does, is for the script of that
--- object's kind to say, in `PlacedObjectScripts`.
local Hotbar = require("../inventory/Hotbar")
local ItemScripts = require("./ItemScripts")
local PlacedObjectScripts = require("./PlacedObjectScripts")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local World = require("../world/World")

local PlotRequests = {}

type World = World.World
type PlayerState = PlayerState.PlayerState
type ItemScript = ItemScripts.ItemScript
type PlacedObjectScript = PlacedObjectScripts.PlacedObjectScript

local function findScriptOfSelectedItem(player: PlayerState): ItemScript?
	local selected = Hotbar.getSelectedStack(player.hotbar)
	if selected == nil then
		return nil
	end
	return ItemScripts.find(selected.itemId)
end

local function findScriptOfPlacedObject(world: World, placedObjectId: unknown): PlacedObjectScript?
	local placedObject = world.plot.placedObjectsById[placedObjectId :: number]
	if placedObject == nil then
		return nil
	end
	return PlacedObjectScripts.find(placedObject.kindId)
end

--- The player interacts with the tile `tileX`, `tileZ` of the plot, holding the item in their
--- selected hotbar slot: the `interactWithTile` of that item's script is called, and as many items
--- as it says were used up are taken out of the slot, or all that the slot holds if that is fewer.
--- Does nothing if that slot holds nothing, if its item has no script or a script without that
--- function, if the plot has no such tile, if the player has no character, or if they stand more
--- than `World.CHARACTER_REACH` from the tile. Fails if the script returns anything but a whole
--- number of 0 or more.
function PlotRequests.interactWithTile(world: World, player: PlayerState, tileX: unknown, tileZ: unknown)
	local itemScript = findScriptOfSelectedItem(player)
	local interactWithTile = if itemScript ~= nil then itemScript.interactWithTile else nil
	if interactWithTile == nil or not Plot.hasTile(world.plot, tileX, tileZ) then
		return
	end
	local x, z = tileX :: number, tileZ :: number
	if World.canReachTile(world, player, x, z) then
		Hotbar.takeFromSelectedSlot(player.hotbar, interactWithTile(world, x, z))
	end
end

--- The player interacts with the placed object that has the id `placedObjectId`: the `interact`
--- of the script of that placed object's kind is called. Does nothing if no placed object has that
--- id, if its kind has no script or a script without that function, if the player has no
--- character, or if they stand more than `World.CHARACTER_REACH` from it.
function PlotRequests.interactWithPlacedObject(world: World, player: PlayerState, placedObjectId: unknown)
	local placedObjectScript = findScriptOfPlacedObject(world, placedObjectId)
	local interact = if placedObjectScript ~= nil then placedObjectScript.interact else nil
	if interact == nil then
		return
	end
	local placedObject = world.plot.placedObjectsById[placedObjectId :: number]
	if World.canReachTile(world, player, placedObject.tileX, placedObject.tileZ) then
		interact(world, player, placedObjectId :: number)
	end
end

--- The player breaks the placed object that has the id `placedObjectId`: the `breakPlacedObject`
--- of the script of that placed object's kind is called. Does nothing if no placed object has that
--- id, if its kind has no script or a script without that function, if the player has no
--- character, or if they stand more than `World.CHARACTER_REACH` from it.
function PlotRequests.breakPlacedObject(world: World, player: PlayerState, placedObjectId: unknown)
	local placedObjectScript = findScriptOfPlacedObject(world, placedObjectId)
	local breakPlacedObject = if placedObjectScript ~= nil then placedObjectScript.breakPlacedObject else nil
	if breakPlacedObject == nil then
		return
	end
	local placedObject = world.plot.placedObjectsById[placedObjectId :: number]
	if World.canReachTile(world, player, placedObject.tileX, placedObject.tileZ) then
		breakPlacedObject(world, placedObjectId :: number)
	end
end

return PlotRequests
