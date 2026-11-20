--!strict
--- Everything in one running copy of the game: the plot, the stacks loose in the world, and the
--- players.
---
--- The server keeps one world. It adds and removes players, says where each player's character is
--- with `setCharacter` and where each ground item has got to with `setGroundItemPosition`, and
--- moves time on with `advanceTo`. The other functions are what can be done in the world: spawning
--- a stack, throwing one from a character, opening and closing a player's screen, placing an item
--- on the plot and taking it off again.
local Direction = require("../Direction")
local GroundItems = require("./GroundItems")
local Inventory = require("../inventory/Inventory")
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

--- How fast a ground item that `placeItem` pushes out of a tile starts moving away from the tile
--- along the ground, in studs a second.
World.GROUND_ITEM_PUSHED_OUT_OF_TILE_SPEED = 6

local RADIANS_BETWEEN_THROWN_STACKS = 2.4
local NO_VELOCITY: GroundItems.Velocity = table.freeze({ x = 0, y = 0, z = 0 })
local SIDES: { Direction } = {
	{ x = 1, z = 0 },
	{ x = -1, z = 0 },
	{ x = 0, z = 1 },
	{ x = 0, z = -1 },
}
local CENTER_DISTANCE_WHEN_TOUCHING = (Plot.TILE_SIZE + GroundItems.ITEM_WIDTH) / 2
local OVERLAP_TOLERANCE = 0.1

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

--- Spawns a stack into the world as a ground item at `position`, moving at `velocity`, and
--- returns the ground item's id. If that puts it beside a ground item of the same item that has
--- room for all of it, it merges into that one, and that one's id is returned.
--- Note: `spawnStack` does not take the stack from anywhere.
function World.spawnStack(world: World, stack: ItemStack, position: Position, velocity: GroundItems.Velocity): number
	local id = GroundItems.spawnStack(world.groundItems, stack, position, velocity, world.now)
	return GroundItems.mergeItemIntoNearbyItem(world.groundItems, id)
end

--- Records that a ground item is now at `position`, the middle of its underside. If that puts it
--- beside another ground item of the same item that has room for all of its stack, it merges into
--- that one. Does nothing if no ground item has that id.
function World.setGroundItemPosition(world: World, groundItemId: number, position: Position)
	GroundItems.setItemPosition(world.groundItems, groundItemId, position)
	GroundItems.mergeItemIntoNearbyItem(world.groundItems, groundItemId)
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

--- Sets a player's character: where it is and which way it faces, or `nil` if they have no living
--- character. A player who loses their character has their screen closed first, as `closeScreen`
--- does, while there is still a character to throw from. Fails if no player has that id.
function World.setCharacter(world: World, playerId: number, character: PlayerState.Character?)
	local player = assert(world.players[playerId], `no player has the id {playerId}`)
	if character == nil then
		World.closeScreen(world, player)
	end
	PlayerState.setCharacter(player, character)
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

local function isLyingInTile(world: World, position: Position, x: number, z: number): boolean
	local center = tileCenter(world, x, z)
	local reach = CENTER_DISTANCE_WHEN_TOUCHING - OVERLAP_TOLERANCE
	return math.abs(position.x - center.x) < reach
		and math.abs(position.z - center.z) < reach
		and position.y < center.y + Plot.TILE_SIZE - OVERLAP_TOLERANCE
		and position.y + GroundItems.ITEM_WIDTH > center.y + OVERLAP_TOLERANCE
end

local function findNearestFreeSideOfTile(world: World, position: Position, x: number, z: number): (Direction?, number)
	local center = tileCenter(world, x, z)
	local nearestSide: Direction? = nil
	local nearestDistance = math.huge
	for _, side in SIDES do
		local towardsSide = (position.x - center.x) * side.x + (position.z - center.z) * side.z
		local distance = CENTER_DISTANCE_WHEN_TOUCHING - towardsSide
		if distance < nearestDistance and not Plot.isTileTaken(world.plot, x + side.x, z + side.z) then
			nearestSide, nearestDistance = side, distance
		end
	end
	return nearestSide, nearestDistance
end

local function pushGroundItemOutOfTile(world: World, groundItemId: number, x: number, z: number)
	local position = world.groundItems.itemsById[groundItemId].position
	local stack = GroundItems.removeItem(world.groundItems, groundItemId) :: ItemStack
	local side, distance = findNearestFreeSideOfTile(world, position, x, z)
	if side == nil then
		local top = tileCenter(world, x, z).y + Plot.TILE_SIZE
		World.spawnStack(world, stack, Position.new(position.x, top, position.z), NO_VELOCITY)
		return
	end
	local outside = Position.new(position.x + side.x * distance, position.y, position.z + side.z * distance)
	World.spawnStack(world, stack, outside, {
		x = side.x * World.GROUND_ITEM_PUSHED_OUT_OF_TILE_SPEED,
		y = 0,
		z = side.z * World.GROUND_ITEM_PUSHED_OUT_OF_TILE_SPEED,
	})
end

local function pushGroundItemsOutOfTile(world: World, x: number, z: number)
	local ids = {}
	for id, groundItem in world.groundItems.itemsById do
		if isLyingInTile(world, groundItem.position, x, z) then
			table.insert(ids, id)
		end
	end
	table.sort(ids)
	for _, id in ids do
		pushGroundItemOutOfTile(world, id, x, z)
	end
end

--- Places one of an item on a tile and returns the placed item's id. Returns `nil`, placing
--- nothing, if the plot has no such tile, if a player stands on the tile, if something already
--- stands on it, or if the item is not one that can be placed. The item is not taken from
--- anywhere. An item that is a station starts as a station with no fire.
---
--- A placed item fills its tile as a cube `Plot.TILE_SIZE` on each side. Every ground item that
--- reaches more than a tenth of a stud into that cube is pushed out of it: it is spawned again
--- just outside the nearest side of the tile that has no placed item against it, moving away from
--- the tile along the ground at `GROUND_ITEM_PUSHED_OUT_OF_TILE_SPEED`. A side at the edge of the plot has
--- nothing against it. If all four sides have a placed item against them, it is spawned again on
--- top of the cube instead, not moving.
--- Note: a ground item is pushed straight out through that side, and where it lands is not
--- checked. One that lay across a corner of the tile can land partly inside a placed item that
--- stands on the tile diagonally across that corner.
function World.placeItem(world: World, itemId: string, x: number, z: number): number?
	if World.isTileStoodOn(world, x, z) then
		return nil
	end
	local placedItemId = Plot.placeItem(world.plot, itemId, x, z)
	if placedItemId ~= nil then
		world.stations[placedItemId] = newStationFor(world.plot.placedItemsById[placedItemId])
		pushGroundItemsOutOfTile(world, x, z)
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
--- each a different way from the one before. Stacks of the same item that fit in one stack merge
--- as they spawn, and move the way the first of them was thrown.
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

--- Moves the world on to the time `now`. Each player with a character picks up the ground items
--- near them, the player with the lowest id first. A player whose screen is open on a placed item
--- has it closed, as `closeScreen` does, if they stand more than `SCREEN_CLOSES_BEYOND` from it or
--- if it is no longer on the plot. Every station burns and works for the time that has passed.
--- Ground items that have been in the world too long are removed. If `now` is earlier than the
--- time `advanceTo` was last given, no time passes for the stations.
function World.advanceTo(world: World, now: number)
	local elapsed = math.max(now - world.now, 0)
	world.now = now
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
