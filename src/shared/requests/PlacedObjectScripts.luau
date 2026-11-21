--!strict
--- The script of each kind of placed object: what happens when a player interacts with an object
--- of that kind, when one is broken, and when time passes for one.
---
--- A script is a table of functions, one for each thing that can happen to a placed object of
--- the kind. `register` registers it under the id of its kind. `find` returns a kind's script, and
--- `findOfPlacedObject` returns the script of a placed object's kind. `advancePlacedObjects` tells
--- the script of each placed object on the plot that time has passed. A kind need not have a
--- script, and a script need not have every function.
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
	--- Called when `seconds` have passed in `world`, for the placed object that has the id
	--- `placedObjectId`, which is of the script's kind and stands on the plot of `world`.
	read advance: ((world: World.World, placedObjectId: number, seconds: number) -> ())?,
	--- Called when the client is to be told of the placed object that has the id
	--- `placedObjectId`, which is of the script's kind, stands on the plot of `world`, and is the
	--- one that the player's screen is open on. Returns what the client is told of it besides the
	--- inventory on the screen, as plain data that a remote carries unchanged.
	read getScreenData: ((world: World.World, placedObjectId: number) -> unknown)?,
}

local scriptsByKindId: { [string]: PlacedObjectScript } = {}

--- Registers `placedObjectScript` for the kind of placed object with the id `kindId`. Fails, and
--- changes nothing, if that kind has a script already.
function PlacedObjectScripts.register(kindId: string, placedObjectScript: PlacedObjectScript)
	if scriptsByKindId[kindId] ~= nil then
		error(`the kind of placed object "{kindId}" has a script already`, 2)
	end
	scriptsByKindId[kindId] = placedObjectScript
end

--- Returns the script that `register` registered for the kind with the id `kindId`, or `nil` if
--- that kind has none.
function PlacedObjectScripts.find(kindId: string): PlacedObjectScript?
	return scriptsByKindId[kindId]
end

--- Returns the script that `register` registered for the kind of the placed object that has the
--- id `placedObjectId` on the plot of `world`. Returns `nil` if no placed object has that id, or
--- if its kind has no script.
function PlacedObjectScripts.findOfPlacedObject(world: World.World, placedObjectId: number): PlacedObjectScript?
	local placedObject = world.plot.placedObjectsById[placedObjectId]
	if placedObject == nil then
		return nil
	end
	return scriptsByKindId[placedObject.kindId]
end

type Advance = (world: World.World, placedObjectId: number, seconds: number) -> ()

local function findAdvanceOfPlacedObject(world: World.World, placedObjectId: number): Advance?
	local placedObjectScript = PlacedObjectScripts.findOfPlacedObject(world, placedObjectId)
	if placedObjectScript == nil then
		return nil
	end
	return placedObjectScript.advance
end

--- Tells the script of each placed object on the plot of `world` that `seconds` have passed, by
--- calling its `advance`, if it has one, with the placed object's id and `seconds`. It tells the
--- placed objects one at a time, the lowest id first. It skips one that an earlier `advance` took
--- off the plot, and does not tell one that an `advance` placed during the call until the next
--- call. If an `advance` fails, the error passes out of this function, and it tells no placed
--- object after that one.
function PlacedObjectScripts.advancePlacedObjects(world: World.World, seconds: number)
	local placedObjectIds = {}
	for placedObjectId in world.plot.placedObjectsById do
		table.insert(placedObjectIds, placedObjectId)
	end
	table.sort(placedObjectIds)
	for _, placedObjectId in placedObjectIds do
		local advance = findAdvanceOfPlacedObject(world, placedObjectId)
		if advance ~= nil then
			advance(world, placedObjectId, seconds)
		end
	end
end

return PlacedObjectScripts
