--!strict
--- What a player's machine is told about what the player holds: their pack, and their open
--- inventory screen.
---
--- `encode` makes plain data on the server, and `decode` reads it back on the player's machine.
local Inventory = require("../inventory/Inventory")
local InventoryScreen = require("../inventory/InventoryScreen")
local ItemStack = require("../items/ItemStack")
local Station = require("../stations/Station")
local World = require("./World")

local PlayerView = {}

export type EncodedView = {
	pack: Inventory.EncodedInventory,
	--- The open inventory screen. `nil` when none is open.
	screen: {
		--- The other inventory that is open. `nil` when the pack is open alone.
		other: Inventory.EncodedInventory?,
		--- The id of the placed item whose inventory `other` is, such as `"crate"`.
		otherItemId: string?,
		carried: { itemId: string, count: number }?,
		--- How far the fire and the work have got, if `other` is a station's inventory.
		progress: Station.Progress?,
	}?,
}

export type PlayerView = {
	pack: Inventory.Inventory,
	--- The open inventory screen, over `pack`. `nil` when none is open.
	screen: InventoryScreen.InventoryScreen?,
	--- The id of the placed item whose inventory the screen shows beside the pack.
	otherItemId: string?,
	--- How far the fire and the work have got, if that placed item is a station.
	progress: Station.Progress?,
}

--- Returns what to tell the machine of the player with the id `playerId`, as plain data. Fails if
--- no player has that id.
function PlayerView.encode(world: World.World, playerId: number): EncodedView
	local state = assert(world.players[playerId], `no player has the id {playerId}`)
	local screen = state.screen
	if screen == nil then
		return { pack = Inventory.encode(state.pack) }
	end
	local placedId = state.openedPlacedId
	local placedItem = if placedId then world.plot.placedById[placedId] else nil
	local station = if placedId then world.stations[placedId] else nil
	local carried = screen.carried
	return {
		pack = Inventory.encode(state.pack),
		screen = {
			other = if screen.other then Inventory.encode(screen.other) else nil,
			otherItemId = if placedItem then placedItem.itemId else nil,
			carried = if carried then { itemId = carried.itemId, count = carried.count } else nil,
			progress = if station then Station.getProgress(station) else nil,
		},
	}
end

--- Returns the view read from data that `encode` made. Fails if the data holds an inventory or a
--- stack that cannot be read.
function PlayerView.decode(encoded: EncodedView): PlayerView
	local pack = assert(Inventory.decode(encoded.pack))
	local encodedScreen = encoded.screen
	if encodedScreen == nil then
		return { pack = pack }
	end
	local carried = encodedScreen.carried
	local screen =
		InventoryScreen.new(pack, if encodedScreen.other then assert(Inventory.decode(encodedScreen.other)) else nil)
	screen.carried = if carried then ItemStack.new(carried.itemId, carried.count) else nil
	return {
		pack = pack,
		screen = screen,
		otherItemId = encodedScreen.otherItemId,
		progress = encodedScreen.progress,
	}
end

return PlayerView
