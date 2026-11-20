--!strict
--- Carries out what players' machines ask for.
---
--- A request is a name and whatever the machine sent with it. InventoryRequests and PlotRequests
--- hold one function for each request, and say what it does.
local InventoryRequests = require("./InventoryRequests")
local PlayerState = require("../players/PlayerState")
local PlotRequests = require("./PlotRequests")
local World = require("../world/World")

local Requests = {}

type Request = (world: World.World, player: PlayerState.PlayerState, ...any) -> ()

local requests = table.clone(InventoryRequests :: { [string]: Request })
for name, request in PlotRequests :: { [string]: Request } do
	assert(requests[name] == nil, `two requests are called "{name}"`)
	requests[name] = request
end

local names = {}
for name in requests do
	table.insert(names, name)
end
table.sort(names)

--- The name of every request, in alphabetical order.
Requests.NAMES = table.freeze(names)

--- Carries out the request called `name` for the player with the id `playerId`, with what their
--- machine sent after the name. `name` and what follows it may be any values at all. Does nothing
--- if no request has that name or no player has that id.
function Requests.carryOut(world: World.World, playerId: number, name: unknown, ...: unknown)
	local player = world.players[playerId]
	local request = if type(name) == "string" then requests[name] else nil
	if player ~= nil and request ~= nil then
		request(world, player, ...)
	end
end

return Requests
