--!strict
--- What a player's machine may ask for on the plot.
---
--- Each function is one request. `world` is the world and `player` is the player who asks. Every
--- argument after them is what the player's machine sent, and may be any value at all. A request
--- that makes no sense for the player as they are now does nothing.
---
--- A request says what the player did, and to what. Nothing else is decided here: not whether
--- the player has a character, nor how far they stand, nor what they have open. What interacting
--- with a tile does is for the script of the item in the player's selected hotbar slot to say, in
--- `ItemScripts`. What interacting with a placed object does, and what breaking one does, is for
--- the script of that object's kind to say, in `PlacedObjectScripts`.
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

--- The player interacts with the tile `tileX`, `tileZ` of the plot: the `interactWithTile` of the
--- script of the item in their selected hotbar slot is called. Does nothing if that slot holds
--- nothing, if its item has no script or a script without that function, or if the plot has no
--- such tile.
function PlotRequests.interactWithTile(world: World, player: PlayerState, tileX: unknown, tileZ: unknown)
	local itemScript = findScriptOfSelectedItem(player)
	local interactWithTile = if itemScript ~= nil then itemScript.interactWithTile else nil
	if interactWithTile ~= nil and Plot.hasTile(world.plot, tileX, tileZ) then
		interactWithTile(world, player, tileX :: number, tileZ :: number)
	end
end

--- The player interacts with the placed object that has the id `placedObjectId`: the `interact`
--- of the script of that placed object's kind is called. Does nothing if no placed object has that
--- id, or if its kind has no script or a script without that function.
function PlotRequests.interactWithPlacedObject(world: World, player: PlayerState, placedObjectId: unknown)
	local placedObjectScript = findScriptOfPlacedObject(world, placedObjectId)
	local interact = if placedObjectScript ~= nil then placedObjectScript.interact else nil
	if interact ~= nil then
		interact(world, player, placedObjectId :: number)
	end
end

--- The player breaks the placed object that has the id `placedObjectId`: the `breakPlacedObject`
--- of the script of that placed object's kind is called. Does nothing if no placed object has that
--- id, or if its kind has no script or a script without that function.
function PlotRequests.breakPlacedObject(world: World, player: PlayerState, placedObjectId: unknown)
	local placedObjectScript = findScriptOfPlacedObject(world, placedObjectId)
	local breakPlacedObject = if placedObjectScript ~= nil then placedObjectScript.breakPlacedObject else nil
	if breakPlacedObject ~= nil then
		breakPlacedObject(world, player, placedObjectId :: number)
	end
end

return PlotRequests
