--!strict
--- Everything in one running copy of the game: the plot, the stacks loose in the world, and the
--- players.
---
--- The server keeps one world. It adds and removes players, says where each player's character is
--- with `setCharacterPositionAndFacing` and where each ground item has got to with
--- `setGroundItemPosition`, and moves time on with `advanceTo`. The other functions are what can be done in the world: spawning
--- a stack, throwing one from a character, opening and closing a player's screen, placing an item
--- on the plot and taking it off again.
local Direction = require("../Direction")
local GroundItems = require("./GroundItems")
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local PlotCollision = require("./PlotCollision")
local Position = require("../Position")
local RecipeRegistry = require("../stations/RecipeRegistry")
local Station = require("../stations/Station")

local World = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory
type PlayerState = PlayerState.PlayerState
type Position = Position.Position
type Direction = Direction.Direction

export type World = {
	--- The one plot there is for now, shared by every player.
	read plot: Plot.Plot,
	--- The point in the world at the outer corner of the plot's tile x 1, z 1.
	read plotCorner: Position,
	--- The stacks loose in the world.
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

--- How far above a character's feet a stack that the character throws starts, in studs.
World.CHARACTER_THROW_START_HEIGHT = 3

--- How fast a stack that a character throws starts moving the way the character faces, in studs a
--- second.
World.CHARACTER_THROW_FORWARD_SPEED = 24

--- How fast a stack that a character throws starts moving upwards, in studs a second.
World.CHARACTER_THROW_UPWARD_SPEED = 8

--- How fast a placed item that `throwPlacedItemAndContents` throws, and each stack that was in it,
--- starts moving outwards along the ground, in studs a second.
World.PLACED_ITEM_THROW_OUTWARD_SPEED = 6

--- How fast a placed item that `throwPlacedItemAndContents` throws, and each stack that was in it,
--- starts moving upwards, in studs a second.
World.PLACED_ITEM_THROW_UPWARD_SPEED = 20

local RADIANS_BETWEEN_THROWN_STACKS = 2.4

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

--- Adds a new player to the world and returns them. They have no character yet. They carry
--- `pack`, or a pack that holds nothing if none is given. Fails if a player already has that id.
function World.addPlayer(world: World, playerId: number, pack: Inventory?): PlayerState
	assert(world.players[playerId] == nil, `player {playerId} is already in the world`)
	local player = PlayerState.new(pack)
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

--- Spawns a stack into the world as a new ground item at `position`, moving at `velocity`, at
--- the world's time, and returns the ground item's id.
--- Note: `spawnStack` does not take the stack from anywhere.
function World.spawnStack(world: World, stack: ItemStack, position: Position, velocity: GroundItems.Velocity): number
	return GroundItems.spawnStack(world.groundItems, stack, position, velocity, world.now)
end

--- Records that a ground item is now at `position`, the middle of its underside. Does nothing if
--- no ground item has that id.
function World.setGroundItemPosition(world: World, groundItemId: number, position: Position)
	GroundItems.setItemPosition(world.groundItems, groundItemId, position)
end

--- Throws a stack into the world from a character: it spawns `CHARACTER_THROW_START_HEIGHT` above the
--- character's feet, moving the way the character faces at `CHARACTER_THROW_FORWARD_SPEED` and
--- upwards at `CHARACTER_THROW_UPWARD_SPEED`.
--- Note: it does not take the stack from anywhere.
function World.throwStackFromCharacter(world: World, character: PlayerState.Character, stack: ItemStack)
	local feet = character.position
	local facing = character.facing
	World.spawnStack(world, stack, Position.new(feet.x, feet.y + World.CHARACTER_THROW_START_HEIGHT, feet.z), {
		x = facing.x * World.CHARACTER_THROW_FORWARD_SPEED,
		y = World.CHARACTER_THROW_UPWARD_SPEED,
		z = facing.z * World.CHARACTER_THROW_FORWARD_SPEED,
	})
end

--- Closes a player's inventory screen. The stack they were carrying goes back into their pack,
--- and what does not fit is thrown from their character, as `throwStackFromCharacter` does. Does
--- nothing if they have no screen open.
function World.closeScreen(world: World, player: PlayerState)
	local leftover = PlayerState.closeScreen(player)
	if leftover ~= nil then
		local character = assert(player.character, "a player who had a screen open has a character")
		World.throwStackFromCharacter(world, character, leftover)
	end
end

--- Sets where a player's character is, at its feet, and which way it faces along the ground. A
--- player who had no character has one from now on. Fails if no player has that id.
function World.setCharacterPositionAndFacing(world: World, playerId: number, position: Position, facing: Direction)
	local player = assert(world.players[playerId], `no player has the id {playerId}`)
	PlayerState.setCharacterPositionAndFacing(player, position, facing)
end

--- Removes a player's character: they have none until `setCharacterPositionAndFacing` is next
--- called for them. Their screen is closed first, as `closeScreen` does, while there is still a
--- character to throw from. Does nothing if they have no character. Fails if no player has that
--- id.
function World.removeCharacter(world: World, playerId: number)
	local player = assert(world.players[playerId], `no player has the id {playerId}`)
	World.closeScreen(world, player)
	PlayerState.removeCharacter(player)
end

--- Opens a player's inventory screen on their pack with the inventory of a placed item beside it,
--- and returns `true`. Any screen they had open is closed first, as `closeScreen` does. If the
--- placed item is a station, each of its slots takes only what a station's slot takes. Returns
--- `false`, changing nothing, if no placed item has that id, if it has no inventory, or if the
--- player has no character.
function World.openPlacedItemScreen(world: World, player: PlayerState, placedItemId: number): boolean
	local placedItem = world.plot.placedItemsById[placedItemId]
	local inventory = if placedItem then placedItem.inventory else nil
	if placedItem == nil or inventory == nil or player.character == nil then
		return false
	end
	World.closeScreen(world, player)
	local itemId = placedItem.itemId
	local stationSlotAcceptsItem = function(slot: number, putItemId: string): boolean
		return Station.slotAcceptsItem(itemId, slot, putItemId)
	end
	local isStation = world.stations[placedItemId] ~= nil
	return PlayerState.openPlacedItemScreen(
		player,
		placedItemId,
		inventory,
		if isStation then stationSlotAcceptsItem else nil
	)
end

--- Returns `true` if a player's character stands within `World.REACH` of the middle of a tile,
--- in studs along the ground. A player with no character reaches nothing.
function World.canReachTile(world: World, player: PlayerState, x: number, z: number): boolean
	local character = player.character
	return character ~= nil and Position.getGroundDistance(character.position, tileCenter(world, x, z)) <= World.REACH
end

--- Returns `true` if any player's character stands on a tile: within `TILE_STOOD_ON_WITHIN` of its
--- middle.
function World.isTileStoodOn(world: World, x: number, z: number): boolean
	local center = tileCenter(world, x, z)
	for _, player in world.players do
		local character = player.character
		local isOnTile = character ~= nil
			and Position.getGroundDistance(character.position, center) <= World.TILE_STOOD_ON_WITHIN
		if isOnTile then
			return true
		end
	end
	return false
end

--- Places one of an item on a tile and returns the placed item's id. Returns `nil`, placing
--- nothing, if the plot has no such tile, if a player stands on the tile, if something already
--- stands on it, or if the item is not one that can be placed. The item is not taken from
--- anywhere. An item that is a station starts as a station with no fire.
---
--- The ground items that lie where the placed item now stands are pushed out of its tile. Each is
--- taken out of the world and its stack is spawned again, as a new ground item with a new id:
--- just outside the tile and moving away from it along the ground, or on top of the placed item,
--- not moving, if it is closed in on all four sides.
function World.placeItem(world: World, itemId: string, x: number, z: number): number?
	if World.isTileStoodOn(world, x, z) then
		return nil
	end
	local placedItemId = Plot.placeItem(world.plot, itemId, x, z)
	if placedItemId ~= nil then
		world.stations[placedItemId] = newStationFor(world.plot.placedItemsById[placedItemId])
		PlotCollision.pushGroundItemsOutOfTile(world.groundItems, world.plot, world.plotCorner, x, z, world.now)
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

--- Takes a placed item off the plot and returns it, with whatever is inside it still inside it.
--- Every screen open on it is closed first, as `closeScreen` does. If it was a station it is one
--- no longer: its fire is out, and the fuel that was burning is lost. Returns `nil`, changing
--- nothing, if no placed item has that id.
function World.takePlacedItemOffPlot(world: World, placedItemId: number): Plot.PlacedItem?
	if world.plot.placedItemsById[placedItemId] == nil then
		return nil
	end
	closeScreensOn(world, placedItemId)
	world.stations[placedItemId] = nil
	return Plot.removePlacedItem(world.plot, placedItemId)
end

local function takeEveryStack(inventory: Inventory): { ItemStack }
	local stacks = {}
	for slot = 1, inventory.slotCount do
		local stack = Inventory.takeFromSlot(inventory, slot)
		if stack ~= nil then
			table.insert(stacks, stack)
		end
	end
	return stacks
end

--- Throws a placed item into the world, with everything inside it: the item, and then each stack
--- in its inventory from the lowest slot up, is spawned as `spawnStack` does, and the inventory is
--- left holding nothing. Each spawns in the middle of the tile the placed item stood on, moving
--- upwards at `PLACED_ITEM_THROW_UPWARD_SPEED` and outwards at `PLACED_ITEM_THROW_OUTWARD_SPEED`,
--- each a different way from the one before.
--- Note: it does not take the placed item off the plot. For one that still stands there, the item
--- exists twice.
function World.throwPlacedItemAndContents(world: World, placedItem: Plot.PlacedItem)
	local center = tileCenter(world, placedItem.x, placedItem.z)
	local middle = Position.new(center.x, center.y + (Plot.TILE_SIZE - GroundItems.ITEM_WIDTH) / 2, center.z)
	local stacks = if placedItem.inventory then takeEveryStack(placedItem.inventory) else {}
	table.insert(stacks, 1, ItemStack.new(placedItem.itemId, 1))
	for index, stack in stacks do
		local angle = index * RADIANS_BETWEEN_THROWN_STACKS
		World.spawnStack(world, stack, middle, {
			x = math.cos(angle) * World.PLACED_ITEM_THROW_OUTWARD_SPEED,
			y = World.PLACED_ITEM_THROW_UPWARD_SPEED,
			z = math.sin(angle) * World.PLACED_ITEM_THROW_OUTWARD_SPEED,
		})
	end
end

local function pickUpNearbyStacks(world: World, player: PlayerState)
	local character = player.character
	if character ~= nil then
		GroundItems.moveNearbyStacksToInventory(world.groundItems, character.position, player.pack, world.now)
	end
end

local function closeScreenIfOutOfReach(world: World, player: PlayerState)
	local placedItemId = player.openedPlacedItemId
	local character = player.character
	if placedItemId == nil or character == nil then
		return
	end
	local placedItem = world.plot.placedItemsById[placedItemId]
	local isInReach = placedItem ~= nil
		and Position.getGroundDistance(character.position, tileCenter(world, placedItem.x, placedItem.z))
			<= World.SCREEN_CLOSES_BEYOND
	if not isInReach then
		World.closeScreen(world, player)
	end
end

--- Moves the world on to the time `now`. Each ground item that was spawned, or given a new
--- position, since the world was last moved on merges into a ground item of the same item beside
--- it that has room for all of its stack. Each player with a character then picks up the ground
--- items near them, the player with the lowest id first. A player whose screen is open on a placed item
--- has it closed, as `closeScreen` does, if they stand more than `SCREEN_CLOSES_BEYOND` from it or
--- if it is no longer on the plot. Every station burns and works for the time that has passed.
--- Ground items that have been in the world too long are removed. If `now` is earlier than the
--- time `advanceTo` was last given, no time passes for the stations.
function World.advanceTo(world: World, now: number)
	local elapsed = math.max(now - world.now, 0)
	world.now = now
	GroundItems.mergeMovedItems(world.groundItems)
	for _, playerId in sortedPlayerIds(world) do
		local player = world.players[playerId]
		pickUpNearbyStacks(world, player)
		closeScreenIfOutOfReach(world, player)
	end
	for _, station in world.stations do
		Station.advance(station, elapsed)
	end
	GroundItems.removeExpiredItems(world.groundItems, now)
end

return World
