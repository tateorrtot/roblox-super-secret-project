--!strict
--- Everything in one running copy of the game: the plot, the stacks on the ground, and the players.
---
--- The server keeps one world. It adds and removes players, says where each one stands with
--- `setPlayerPosition`, and moves time on with `advanceTo`. The other functions are what can be done
--- in the world: dropping a stack, opening a placed item, closing a player's screen, placing an
--- item on the plot and taking it off again.
local GroundItems = require("./GroundItems")
local Inventory = require("../inventory/Inventory")
local InventoryScreen = require("../inventory/InventoryScreen")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local Position = require("../Position")
local RecipeRegistry = require("../stations/RecipeRegistry")
local Station = require("../stations/Station")

local World = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory
type PlayerState = PlayerState.PlayerState
type Position = Position.Position

export type World = {
	--- The one plot there is for now, shared by every player.
	read plot: Plot.Plot,
	--- The point in the world at the outer corner of the plot's tile x 1, z 1.
	read plotCorner: Position,
	--- The stacks lying on the ground.
	read groundItems: GroundItems.GroundItems,
	--- Every player in the world, by id. On Roblox the id is the UserId.
	read players: { [number]: PlayerState },
	--- The station that each placed item which is one works as, by the placed item's id. A
	--- placed item that is not a station has no entry.
	read stations: { [number]: Station.Station },
	--- The time `advanceTo` was last given, in seconds.
	now: number,
}

--- How far a player's character may stand from the middle of a tile and still reach it, in
--- studs along the ground.
World.REACH = 16

--- How far a player may walk from a placed item they have open before its screen closes, in
--- studs along the ground. It is a little more than `REACH`, so that a screen opened from the
--- edge of reach does not close at the first step back.
World.SCREEN_CLOSES_BEYOND = World.REACH + 4

--- A player standing this near the middle of a tile, in studs along the ground, stands on it.
World.TILE_STOOD_ON_WITHIN = Plot.TILE_SIZE * 0.75

local SPILL_DISTANCE = 1.7
local SPILL_ANGLE = 2.4

local function tileCenter(world: World, x: number, z: number): Position
	return Plot.getTileCenter(world.plotCorner, x, z)
end

local function sortedPlayerIds(world: World): { number }
	local ids = {}
	for playerId in world.players do
		table.insert(ids, playerId)
	end
	table.sort(ids)
	return ids
end

local function newStationFor(placedItem: Plot.PlacedItem): Station.Station?
	local inventory = placedItem.inventory
	local isStation = RecipeRegistry.isStation(placedItem.itemId)
	return if inventory ~= nil and isStation then Station.new(placedItem.itemId, inventory) else nil
end

--- Returns a new world with no players and nothing on the ground, at the time `now`. `plot` is
--- the plot, with whatever already stands on it, and `plotCorner` is the outer corner of its tile
--- x 1, z 1. Each item on the plot that is a station starts as a station with no fire.
function World.new(plot: Plot.Plot, plotCorner: Position, now: number): World
	local world: World = {
		plot = plot,
		plotCorner = plotCorner,
		groundItems = GroundItems.new(),
		players = {},
		stations = {},
		now = now,
	}
	for placedItemId, placedItem in plot.placedItemsById do
		world.stations[placedItemId] = newStationFor(placedItem)
	end
	return world
end

--- Puts a stack on the ground at a position.
function World.dropStackAt(world: World, stack: ItemStack, position: Position)
	GroundItems.dropStackAt(world.groundItems, stack, position, world.now)
end

--- Closes a player's inventory screen. The stack they were carrying goes back into their pack,
--- and what does not fit lands on the ground at their `dropPosition`. Does nothing if they have no
--- screen open.
function World.closeScreen(world: World, player: PlayerState)
	local screen = player.screen
	if screen == nil then
		return
	end
	local carried = InventoryScreen.takeCarriedStack(screen)
	local leftover = if carried then Inventory.addStack(player.pack, carried) else nil
	if leftover ~= nil then
		World.dropStackAt(world, leftover, player.dropPosition)
	end
	player.screen = nil
	player.openedPlacedItemId = nil
end

--- Opens the inventory of a placed item on a player's screen, beside their pack, and returns
--- `true`. Any screen they had open is closed first, as `closeScreen` does. Returns `false`,
--- changing nothing, if no placed item has that id or it has no inventory.
function World.openPlacedItem(world: World, player: PlayerState, placedItemId: number): boolean
	local placedItem = world.plot.placedItemsById[placedItemId]
	local inventory = if placedItem then placedItem.inventory else nil
	if placedItem == nil or inventory == nil then
		return false
	end
	World.closeScreen(world, player)
	local itemId = placedItem.itemId
	local stationAccepts = function(slot: number, putItemId: string): boolean
		return Station.slotAcceptsItem(itemId, slot, putItemId)
	end
	player.screen =
		InventoryScreen.new(player.pack, inventory, if world.stations[placedItemId] then stationAccepts else nil)
	player.openedPlacedItemId = placedItemId
	return true
end

--- Adds a new player to the world and returns them. They have no character yet, and a stack
--- they drop lands at `dropPosition` until `setPlayerPosition` says where they stand. They carry
--- `pack`, or a pack that holds nothing if none is given. Fails if a player already has that id.
function World.addPlayer(world: World, playerId: number, dropPosition: Position, pack: Inventory?): PlayerState
	assert(world.players[playerId] == nil, `player {playerId} is already in the world`)
	local player = PlayerState.new(dropPosition, pack)
	world.players[playerId] = player
	return player
end

--- Takes a player out of the world and returns them, or `nil` if no player has that id. Their
--- inventory screen is closed first, as `closeScreen` does.
function World.removePlayer(world: World, playerId: number): PlayerState?
	local player = world.players[playerId]
	if player == nil then
		return nil
	end
	World.closeScreen(world, player)
	world.players[playerId] = nil
	return player
end

--- Sets where a player's character stands to `position`, a point on the ground, or to `nil` if
--- they have no living character. With a `position`, it also sets where a stack they drop lands:
--- at `dropPosition`, or at `position` if `dropPosition` is left out. With no `position`, where
--- their drops land stays as it was. Fails if no player has that id.
function World.setPlayerPosition(world: World, playerId: number, position: Position?, dropPosition: Position?)
	local player = assert(world.players[playerId], `no player has the id {playerId}`)
	player.position = position
	if position ~= nil then
		player.dropPosition = dropPosition or position
	end
end

--- Returns `true` if a player's character stands within `World.REACH` of the middle of a tile,
--- in studs along the ground. A player with no character reaches nothing.
function World.canReachTile(world: World, player: PlayerState, x: number, z: number): boolean
	local position = player.position
	return position ~= nil and Position.getGroundDistance(position, tileCenter(world, x, z)) <= World.REACH
end

--- Returns `true` if any player's character stands on a tile: within `TILE_STOOD_ON_WITHIN` of its
--- middle.
function World.isTileStoodOn(world: World, x: number, z: number): boolean
	local center = tileCenter(world, x, z)
	for _, player in world.players do
		local position = player.position
		if position ~= nil and Position.getGroundDistance(position, center) <= World.TILE_STOOD_ON_WITHIN then
			return true
		end
	end
	return false
end

--- Places one of an item on a tile and returns the placed item's id. Returns `nil`, placing
--- nothing, if the plot has no such tile, if a player stands on the tile, if something already
--- stands on it, or if the item is not one that can be placed. The item is not taken from
--- anywhere. An item that is a station starts as a station with no fire.
function World.placeItem(world: World, itemId: string, x: number, z: number): number?
	if World.isTileStoodOn(world, x, z) then
		return nil
	end
	local placedItemId = Plot.placeItem(world.plot, itemId, x, z)
	if placedItemId ~= nil then
		world.stations[placedItemId] = newStationFor(world.plot.placedItemsById[placedItemId])
	end
	return placedItemId
end

local function closeScreensOn(world: World, placedItemId: number)
	for _, playerId in sortedPlayerIds(world) do
		local player = world.players[playerId]
		if player.openedPlacedItemId == placedItemId then
			World.closeScreen(world, player)
		end
	end
end

local function spill(world: World, inventory: Inventory, center: Position)
	local spilled = 0
	for slot = 1, inventory.slotCount do
		local stack = Inventory.takeFromSlot(inventory, slot)
		if stack ~= nil then
			spilled += 1
			local angle = spilled * SPILL_ANGLE
			local x = center.x + math.cos(angle) * SPILL_DISTANCE
			local z = center.z + math.sin(angle) * SPILL_DISTANCE
			World.dropStackAt(world, stack, { x = x, y = center.y, z = z })
		end
	end
end

--- Takes a placed item off the plot. Every screen open on it is closed first, as `closeScreen`
--- does. The item then lies on its tile as a ground item, and each stack that was inside it lies
--- on the ground in a ring around it. If it was a station its fire goes out, and the fuel that was
--- burning is lost. Does nothing if no placed item has that id.
function World.removePlacedItem(world: World, placedItemId: number)
	local placedItem = world.plot.placedItemsById[placedItemId]
	if placedItem == nil then
		return
	end
	closeScreensOn(world, placedItemId)
	Plot.removePlacedItem(world.plot, placedItemId)
	world.stations[placedItemId] = nil
	local center = tileCenter(world, placedItem.x, placedItem.z)
	World.dropStackAt(world, ItemStack.new(placedItem.itemId, 1), center)
	if placedItem.inventory ~= nil then
		spill(world, placedItem.inventory, center)
	end
end

local function pickUpNearbyStacks(world: World, player: PlayerState)
	local position = player.position
	if position ~= nil then
		GroundItems.moveNearbyStacksToInventory(world.groundItems, position, player.pack, world.now)
	end
end

local function closeIfOutOfReach(world: World, player: PlayerState)
	local placedItemId = player.openedPlacedItemId
	if placedItemId == nil then
		return
	end
	local placedItem = world.plot.placedItemsById[placedItemId]
	local position = player.position
	local isInReach = placedItem ~= nil
		and position ~= nil
		and Position.getGroundDistance(position, tileCenter(world, placedItem.x, placedItem.z))
			<= World.SCREEN_CLOSES_BEYOND
	if not isInReach then
		World.closeScreen(world, player)
	end
end

--- Moves the world on to the time `now`. Each player with a character picks up the ground items
--- near them, the player with the lowest id first. A player whose screen is open on a placed item
--- has it closed, as `closeScreen` does, if they stand more than `SCREEN_CLOSES_BEYOND` from it,
--- if they have no character, or if it is no longer on the plot. Every station burns and works
--- for the time that has passed. Ground items that have lain too long are removed. If `now` is
--- earlier than the time `advanceTo` was last given, no time passes for the stations.
function World.advanceTo(world: World, now: number)
	local elapsed = math.max(now - world.now, 0)
	world.now = now
	for _, playerId in sortedPlayerIds(world) do
		local player = world.players[playerId]
		pickUpNearbyStacks(world, player)
		closeIfOutOfReach(world, player)
	end
	for _, station in world.stations do
		Station.advance(station, elapsed)
	end
	GroundItems.removeExpiredStacks(world.groundItems, now)
end

return World
