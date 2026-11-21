--!strict
--- The requests that a client makes about the plot: interacting with a tile or a placed object, and
--- breaking a placed object.
---
--- Each function is one request. `Requests.carryOut` calls it with the `World`, then the
--- `PlayerState` of the player whose client sent the request, and then the values that the client
--- sent. Each of those values is a `Variant`: a client can send a value of any type, so the request
--- checks every one before it uses it. A request whose values do not pass its checks does nothing.
---
--- Each request checks that `World.canReachTile` returns `true` for `player` and the tile that the
--- request acts on. `World.canReachTile` returns `false` while `player.character` is `nil`. The
--- request then calls one function of a script: `interactWithTile` of an `ItemScripts.ItemScript`,
--- or `interact` or `breakPlacedObject` of a `PlacedObjectScripts.PlacedObjectScript`. That
--- function does whatever the interaction does.
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

--- A value that a client sent. It may be of any type, whatever `T` says: `T` is the type that the
--- request checks for before it uses the value.
export type Variant<T> = unknown

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

--- Calls the `interactWithTile` of the `ItemScripts.ItemScript` that `ItemScripts.find` returns for
--- the `itemId` of the `ItemStack` in the slot `player.hotbar.selectedSlot`, with `world`, `tileX`,
--- and `tileZ`. Then takes out of that slot as many items as the call returned, as
--- `Hotbar.takeFromSelectedSlot` does.
--- - `world`: the `World` whose `plot` has the tile.
--- - `player`: the `PlayerState` of the player whose client sent the request.
--- - `tileX`: a whole `number` from `1` to `world.plot.widthInTiles`. The tile's number along x.
--- - `tileZ`: a whole `number` from `1` to `world.plot.depthInTiles`. The tile's number along z.
---
--- Does nothing if that slot holds `nil`, if `ItemScripts.find` returns `nil`, if the script has no
--- `interactWithTile`, if `Plot.hasTile` returns `false` for `tileX` and `tileZ`, or if
--- `World.canReachTile` returns `false` for `player`, `tileX`, and `tileZ`.
--- Note: the request does not check the number that `interactWithTile` returns.
--- `Hotbar.takeFromSelectedSlot` raises an error if that number is negative, or is not whole and is
--- less than the `count` of the `ItemStack` in the slot.
function PlotRequests.interactWithTile(
	world: World,
	player: PlayerState,
	tileX: Variant<number>,
	tileZ: Variant<number>
)
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

--- Finds the `Plot.PlacedObject` at `world.plot.placedObjectsById[placedObjectId]`, and calls the
--- `interact` of the `PlacedObjectScripts.PlacedObjectScript` that `PlacedObjectScripts.find`
--- returns for its `kindId`, with `world`, `player`, and `placedObjectId`.
--- - `world`: the `World` whose `plot` holds the `Plot.PlacedObject`.
--- - `player`: the `PlayerState` of the player whose client sent the request.
--- - `placedObjectId`: a `number`. A key of `world.plot.placedObjectsById`.
---
--- Does nothing if `world.plot.placedObjectsById[placedObjectId]` is `nil`, if
--- `PlacedObjectScripts.find` returns `nil`, if the script has no `interact`, or if
--- `World.canReachTile` returns `false` for `player` and the `tileX` and `tileZ` of the
--- `Plot.PlacedObject`.
function PlotRequests.interactWithPlacedObject(world: World, player: PlayerState, placedObjectId: Variant<number>)
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

--- Finds the `Plot.PlacedObject` at `world.plot.placedObjectsById[placedObjectId]`, and calls the
--- `breakPlacedObject` of the `PlacedObjectScripts.PlacedObjectScript` that
--- `PlacedObjectScripts.find` returns for its `kindId`, with `world` and `placedObjectId`. The
--- request changes nothing itself: the script's `breakPlacedObject` does whatever breaking does.
--- - `world`: the `World` whose `plot` holds the `Plot.PlacedObject`.
--- - `player`: the `PlayerState` of the player whose client sent the request.
--- - `placedObjectId`: a `number`. A key of `world.plot.placedObjectsById`.
---
--- Does nothing if `world.plot.placedObjectsById[placedObjectId]` is `nil`, if
--- `PlacedObjectScripts.find` returns `nil`, if the script has no `breakPlacedObject`, or if
--- `World.canReachTile` returns `false` for `player` and the `tileX` and `tileZ` of the
--- `Plot.PlacedObject`.
function PlotRequests.breakPlacedObject(world: World, player: PlayerState, placedObjectId: Variant<number>)
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
