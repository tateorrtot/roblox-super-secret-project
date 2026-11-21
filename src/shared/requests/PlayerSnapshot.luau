--!strict
--- What a player's machine is told about what the player holds: their pack, which hotbar slot is
--- selected, and their open inventory screen.
---
--- `encode` makes plain data on the server, and `decode` reads it back on the player's machine.
local Inventory = require("../inventory/Inventory")
local InventoryScreen = require("../inventory/InventoryScreen")
local ItemStack = require("../items/ItemStack")
local PlacedObjectScripts = require("./PlacedObjectScripts")
local World = require("../world/World")

local PlayerSnapshot = {}

export type EncodedSnapshot = {
	pack: Inventory.EncodedInventory,
	--- The number of the hotbar slot that is selected.
	selectedHotbarSlot: number,
	--- The open inventory screen. `nil` when none is open.
	screen: {
		--- The other inventory that is open. `nil` when the pack is open alone.
		otherInventory: Inventory.EncodedInventory?,
		--- The id of the kind of the placed object that the screen was opened on, such as
		--- `"crate"`. `nil` when the pack is open alone.
		placedObjectKindId: string?,
		carriedStack: { itemId: string, count: number }?,
		--- What the script of that placed object's kind has to tell of it besides
		--- `otherInventory`: what its `getScreenData` returned. `nil` when the pack is open alone,
		--- and when the script has no `getScreenData`.
		screenData: unknown?,
	}?,
}

export type PlayerSnapshot = {
	pack: Inventory.Inventory,
	--- The number of the hotbar slot that is selected.
	selectedHotbarSlot: number,
	--- The open inventory screen, over `pack`. `nil` when none is open.
	screen: InventoryScreen.InventoryScreen?,
	--- The id of the kind of the placed object that the screen was opened on, such as `"crate"`.
	--- `nil` when the pack is open alone.
	placedObjectKindId: string?,
	--- What the script of that placed object's kind has to tell of it besides the inventory on
	--- the screen: what its `getScreenData` returned on the server. `nil` when the pack is open
	--- alone, and when the script has no `getScreenData`.
	screenData: unknown?,
}

local function getScreenData(world: World.World, placedObjectId: number?): unknown
	if placedObjectId == nil then
		return nil
	end
	local placedObjectScript = PlacedObjectScripts.findOfPlacedObject(world, placedObjectId)
	local getData = if placedObjectScript ~= nil then placedObjectScript.getScreenData else nil
	if getData == nil then
		return nil
	end
	return getData(world, placedObjectId)
end

--- Returns what to tell the machine of the player with the id `playerId`, as plain data. If their
--- screen is open on a placed object, the script of that placed object's kind is asked what else
--- to tell: its `getScreenData`, if it has one, is called, and what it returns is sent as it is.
--- Fails if no player has that id.
function PlayerSnapshot.encode(world: World.World, playerId: number): EncodedSnapshot
	local player = assert(world.players[playerId], `no player has the id {playerId}`)
	local screen = player.screen
	local selectedHotbarSlot = player.hotbar.selectedSlot
	if screen == nil then
		return { pack = Inventory.encode(player.pack), selectedHotbarSlot = selectedHotbarSlot }
	end
	local placedObjectId = World.getOpenedPlacedObjectId(world, player)
	local placedObject = if placedObjectId then world.plot.placedObjectsById[placedObjectId] else nil
	local carried = screen.carriedStack
	return {
		pack = Inventory.encode(player.pack),
		selectedHotbarSlot = selectedHotbarSlot,
		screen = {
			otherInventory = if screen.otherInventory then Inventory.encode(screen.otherInventory) else nil,
			placedObjectKindId = if placedObject then placedObject.kindId else nil,
			carriedStack = if carried then { itemId = carried.itemId, count = carried.count } else nil,
			screenData = getScreenData(world, placedObjectId),
		},
	}
end

--- Returns the snapshot read from data that `encode` made. Fails if the data holds an inventory or
--- a stack that cannot be read.
function PlayerSnapshot.decode(encoded: EncodedSnapshot): PlayerSnapshot
	local pack = assert(Inventory.decode(encoded.pack))
	local encodedScreen = encoded.screen
	if encodedScreen == nil then
		return { pack = pack, selectedHotbarSlot = encoded.selectedHotbarSlot }
	end
	local carried = encodedScreen.carriedStack
	local screen = InventoryScreen.new(
		pack,
		if encodedScreen.otherInventory then assert(Inventory.decode(encodedScreen.otherInventory)) else nil,
		nil,
		if carried then ItemStack.new(carried.itemId, carried.count) else nil
	)
	return {
		pack = pack,
		selectedHotbarSlot = encoded.selectedHotbarSlot,
		screen = screen,
		placedObjectKindId = encodedScreen.placedObjectKindId,
		screenData = encodedScreen.screenData,
	}
end

return PlayerSnapshot
