--!strict
--- The requests that a client makes about the plot: interacting with a tile or a placed object,
--- and breaking a placed object.
---
--- Each function is one request. `world` is the world and `player` is the player who asks. Every
--- argument after them is what the client sent, and may be a value of any type. A request that
--- does not fit the player's state, or whose arguments are not valid, does nothing.
---
--- A request checks what is about the player: that the player has a character, that it stands
--- within `World.CHARACTER_REACH` of what the player acts on, and that the item the player holds
--- is the one in their selected hotbar slot. A script says what follows. The script of the held
--- item, found with `ItemScripts.find`, says what interacting with a tile does. The script of a
--- placed object's kind, found with `PlacedObjectScripts.find`, says what interacting with the
--- placed object does, and what breaking it does.
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

--- Interacts with the tile at `tileX`, `tileZ` of the plot, for the player who holds the item in
--- their selected hotbar slot. Calls the `interactWithTile` of that item's script, then takes out
--- of the slot as many items as it returned, or all that the slot holds if that is fewer. Does
--- nothing if the slot holds nothing, if its item has no script or a script without
--- `interactWithTile`, if `tileX` and `tileZ` name no tile of the plot, if the player has no
--- character, or if the character stands more than `World.CHARACTER_REACH` from the tile. Raises an
--- error if `interactWithTile` returns anything but a whole number of `0` or more.
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

--- Interacts with the placed object `placedObjectId`, for the player. Calls the `interact` of the
--- script of that placed object's kind. Does nothing if no placed object has that id, if its kind
--- has no script or a script without `interact`, if the player has no character, or if the
--- character stands more than `World.CHARACTER_REACH` from the placed object's tile.
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

--- Breaks the placed object `placedObjectId`, for the player. Calls the `breakPlacedObject` of the
--- script of that placed object's kind. Does nothing if no placed object has that id, if its kind
--- has no script or a script without `breakPlacedObject`, if the player has no character, or if the
--- character stands more than `World.CHARACTER_REACH` from the placed object's tile.
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
