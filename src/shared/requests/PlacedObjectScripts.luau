--!strict
--- The script of each kind of placed object: what happens when a player interacts with an object
--- of that kind, and when one is broken.
---
--- A script is a table of functions, one for each thing a player can do to an object of the
--- kind. It is registered once, when the game starts, under the id of its kind, with `register`,
--- and `find` returns it. A kind need not have a script, and a script need not have every
--- function.
local PlayerState = require("../players/PlayerState")
local World = require("../world/World")

local PlacedObjectScripts = {}

--- What one kind of placed object does when an object of that kind is acted on. A script has
--- only the functions that its kind has a use for.
export type PlacedObjectScript = {
	--- Called when `player` interacts with the placed object that has the id `placedObjectId`,
	--- which is of the script's kind and stands on the plot of `world`.
	read interact: ((world: World.World, player: PlayerState.PlayerState, placedObjectId: number) -> ())?,
	--- Called when the placed object that has the id `placedObjectId`, which is of the script's
	--- kind and stands on the plot of `world`, is broken. It is not told who or what broke it.
	read breakPlacedObject: ((world: World.World, placedObjectId: number) -> ())?,
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
