--!strict
--- What a player's machine is told about what the player holds: their pack, and their open
--- inventory screen.
---
--- `encode` makes plain data on the server, and `decode` reads it back on the player's machine.
local Inventory = require("../inventory/Inventory")
local InventoryScreen = require("../inventory/InventoryScreen")
local ItemStack = require("../items/ItemStack")
local StationProgress = require("../stations/StationProgress")
local World = require("./World")

local PlayerSnapshot = {}

export type EncodedSnapshot = {
	pack: Inventory.EncodedInventory,
	--- The open inventory screen. `nil` when none is open.
	screen: {
		--- The other inventory that is open. `nil` when the pack is open alone.
		otherInventory: Inventory.EncodedInventory?,
		--- The item id of the placed item that `otherInventory` is inside, such as `"crate"`. `nil`
		--- when the pack is open alone.
		otherInventoryItemId: string?,
		carriedStack: { itemId: string, count: number }?,
		--- How far the fire and the work have got, as times on the world's clock. `nil` unless
		--- `otherInventory` is a station's inventory.
		stationProgress: StationProgress.StationProgress?,
	}?,
}

export type PlayerSnapshot = {
	pack: Inventory.Inventory,
	--- The open inventory screen, over `pack`. `nil` when none is open.
	screen: InventoryScreen.InventoryScreen?,
	--- The item id of the placed item whose inventory is shown beside the pack, such as `"crate"`.
	--- `nil` when the pack is open alone.
	otherInventoryItemId: string?,
	--- How far the fire and the work have got, as times on the world's clock. `nil` unless that
	--- placed item is a station.
	stationProgress: StationProgress.StationProgress?,
}

--- Returns what to tell the machine of the player with the id `playerId`, as plain data. Fails if
--- no player has that id.
function PlayerSnapshot.encode(world: World.World, playerId: number): EncodedSnapshot
	local player = assert(world.players[playerId], `no player has the id {playerId}`)
	local screen = player.screen
	if screen == nil then
		return { pack = Inventory.encode(player.pack) }
	end
	local placedItemId = player.openedPlacedItemId
	local placedItem = if placedItemId then world.plot.placedItemsById[placedItemId] else nil
	local station = if placedItemId then world.stations[placedItemId] else nil
	local carried = screen.carriedStack
	return {
		pack = Inventory.encode(player.pack),
		screen = {
			otherInventory = if screen.otherInventory then Inventory.encode(screen.otherInventory) else nil,
			otherInventoryItemId = if placedItem then placedItem.itemId else nil,
			carriedStack = if carried then { itemId = carried.itemId, count = carried.count } else nil,
			stationProgress = if station then StationProgress.new(station, world.now) else nil,
		},
	}
end

--- Returns the snapshot read from data that `encode` made. Fails if the data holds an inventory or
--- a stack that cannot be read.
function PlayerSnapshot.decode(encoded: EncodedSnapshot): PlayerSnapshot
	local pack = assert(Inventory.decode(encoded.pack))
	local encodedScreen = encoded.screen
	if encodedScreen == nil then
		return { pack = pack }
	end
	local carried = encodedScreen.carriedStack
	local screen = InventoryScreen.new(
		pack,
		if encodedScreen.otherInventory then assert(Inventory.decode(encodedScreen.otherInventory)) else nil
	)
	screen.carriedStack = if carried then ItemStack.new(carried.itemId, carried.count) else nil
	return {
		pack = pack,
		screen = screen,
		otherInventoryItemId = encodedScreen.otherInventoryItemId,
		stationProgress = encodedScreen.stationProgress,
	}
end

return PlayerSnapshot
