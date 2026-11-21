--!strict
--- The script of each kind of placed object: what happens when a player interacts with an object
--- of that kind, when one is broken, and when time passes for one.
---
--- A script is a table of functions, one for each thing that can happen to an object of the
--- kind. It is registered once, when the game starts, under the id of its kind, with `register`.
--- `find` returns the script of a kind, and `findOfPlacedObject` the script of the kind of one
--- placed object. `advancePlacedObjects` tells every placed object's script that time has passed.
--- A kind need not have a script, and a script need not have every function.
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
	--- Called when a player's machine is to be told of the placed object that has the id
	--- `placedObjectId`, which is of the script's kind, stands on the plot of `world`, and is the
	--- one that the player's screen is open on. Returns what the machine is told of it besides the
	--- inventory on the screen, as plain data that a remote carries unchanged.
	read getScreenData: ((world: World.World, placedObjectId: number) -> unknown)?,
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

--- Returns the script of the kind of the placed object that has the id `placedObjectId` on the
--- plot of `world`. Returns `nil` if no placed object has that id, or if its kind has no script.
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

--- Tells the script of each placed object on the plot of `world` that `seconds` have passed: its
--- `advance`, if it has one, is called with the placed object's id and `seconds`. The placed
--- objects are told one at a time, the lowest id first. One that was taken off the plot by then
--- is not told, and one that was placed during the call is not told until the next call. If an
--- `advance` fails, the error passes out of this call, and the placed objects after that one are
--- not told.
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
