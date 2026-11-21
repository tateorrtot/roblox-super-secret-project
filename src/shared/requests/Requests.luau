--!strict
--- Carries out the requests that clients make, by name.
---
--- A request is a name and whatever the client sent with it. `InventoryRequests` and
--- `PlotRequests` hold one function for each request, and say what it does. `NAMES` lists the
--- names, one by one, and `carryOut` carries out the request that has one.
local InventoryRequests = require("./InventoryRequests")
local PlayerState = require("../players/PlayerState")
local PlotRequests = require("./PlotRequests")
local World = require("../world/World")

local Requests = {}

type Request = (world: World.World, player: PlayerState.PlayerState, ...any) -> ()

--- The name of every request that a client may make, in alphabetical order. Each is the name of
--- a function of `InventoryRequests` or `PlotRequests`. `carryOut` carries out no function that is
--- not named here.
Requests.NAMES = table.freeze({
	"breakPlacedObject",
	"closeScreen",
	"dropCarriedStack",
	"dropFromSelectedSlot",
	"dropFromSlot",
	"fillCarriedStackFromAllSlots",
	"interactWithPlacedObject",
	"interactWithTile",
	"moveFromSlotToInventory",
	"openPack",
	"pickUpFromSlot",
	"putDownInSlot",
	"selectHotbarSlot",
	"spreadCarriedStackOverSlots",
	"swapCarriedStackWithSlot",
	"swapSlots",
})

local requests: { [string]: Request } = {}
for _, name in Requests.NAMES do
	local inventoryRequest = (InventoryRequests :: { [string]: Request })[name]
	local plotRequest = (PlotRequests :: { [string]: Request })[name]
	assert(
		(inventoryRequest == nil) ~= (plotRequest == nil),
		`the request "{name}" must be a function of InventoryRequests or of PlotRequests, and not of both`
	)
	requests[name] = inventoryRequest or plotRequest
end

--- Carries out the request called `name` for the player `playerId`, with the arguments after
--- `name`, which the client sent. `name` and the arguments may be values of any type. Before the
--- request, closes the player's screen, as `World.closeScreen` does, if
--- `World.isOpenedPlacedObjectOutOfReach` returns `true` for the player. Does nothing if `name` is
--- not in `NAMES`, or if no player has the id `playerId`.
function Requests.carryOut(world: World.World, playerId: number, name: unknown, ...: unknown)
	local player = world.players[playerId]
	local request = if type(name) == "string" then requests[name] else nil
	if player == nil or request == nil then
		return
	end
	if World.isOpenedPlacedObjectOutOfReach(world, player) then
		World.closeScreen(world, player)
	end
	request(world, player, ...)
end

return Requests
