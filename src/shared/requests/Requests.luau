--!strict
--- Carries out the requests that clients make, by name.
---
--- A request is a name and whatever the client sent with it. `InventoryRequests` and
--- `PlotRequests` hold one function for each request, and say what it does. `NAMES` lists the
--- names, and `carryOut` carries out the request that has one.
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

--- The name of every request, which is the name of a function of `InventoryRequests` or
--- `PlotRequests`, in alphabetical order.
Requests.NAMES = table.freeze(names)

--- Carries out the request called `name` for the player `playerId`, with the arguments after
--- `name`, which the client sent. `name` and the arguments may be values of any type. Does nothing
--- if `name` is not the name of a request, or if no player has the id `playerId`.
function Requests.carryOut(world: World.World, playerId: number, name: unknown, ...: unknown)
	local player = world.players[playerId]
	local request = if type(name) == "string" then requests[name] else nil
	if player ~= nil and request ~= nil then
		request(world, player, ...)
	end
end

return Requests
