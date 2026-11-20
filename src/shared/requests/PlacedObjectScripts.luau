--!strict
--- The script of each kind of placed object: what happens when a player interacts with an object
--- of that kind, and when a player breaks one.
---
--- A script is a table of functions. It is registered once, when the game starts, under the id
--- of its kind, with `register`. `PlotRequests` asks `find` for the script of the placed object
--- that a player acted on, and calls the function for what the player did. Nothing happens to an
--- object whose kind has no script, or whose script lacks that function.
local PlayerState = require("../players/PlayerState")
local World = require("../world/World")

local PlacedObjectScripts = {}

--- What one kind of placed object does when a player acts on an object of that kind. A script
--- has only the functions that its kind has a use for.
export type PlacedObjectScript = {
	--- Called when `player` interacts with the placed object that has the id `placedObjectId`,
	--- which is of the script's kind and stands on the plot of `world`.
	read interact: ((world: World.World, player: PlayerState.PlayerState, placedObjectId: number) -> ())?,
	--- Called when `player` breaks the placed object that has the id `placedObjectId`, which is
	--- of the script's kind and stands on the plot of `world`.
	read breakPlacedObject: ((world: World.World, player: PlayerState.PlayerState, placedObjectId: number) -> ())?,
}

local scriptsByKindId: { [string]: PlacedObjectScript } = {}

--- Registers `placedObjectScript` as the script of the kind of placed object with the id
--- `kindId`. Fails if that kind has a script already.
function PlacedObjectScripts.register(kindId: string, placedObjectScript: PlacedObjectScript)
	if scriptsByKindId[kindId] ~= nil then
		error(`the kind of placed object "{kindId}" has a script already`, 2)
	end
	scriptsByKindId[kindId] = placedObjectScript
end

--- Returns the script of the kind of placed object with the id `kindId`, or `nil` if that kind
--- has none.
function PlacedObjectScripts.find(kindId: string): PlacedObjectScript?
	return scriptsByKindId[kindId]
end

return PlacedObjectScripts
