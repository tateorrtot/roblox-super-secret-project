--!strict
--- Everything in one running copy of the game: the plot, the stacks loose in the world, and the
--- players.
---
--- The server keeps one world. It adds and removes players, says where each player's character is
--- with `setCharacterPosition` and where each ground item has got to with
--- `setGroundItemPosition`, and moves time on with `advanceTo`. The other functions are what can
--- be done in the world: spawning a stack, throwing one from a character or from a tile, and
--- opening and closing a player's screen.
---
--- A world listens to its plot, and objects are placed and removed with the plot's own
--- `Plot.placeObject` and `Plot.removePlacedObject`. When an object is placed, the world pushes
--- the ground items out of its tile. `addStation` makes a placed object work as a station. When a
--- placed object is taken off, the world closes every screen open on it, and the station it was
--- made goes with it.
local Direction = require("../Direction")
local GroundItems = require("../groundItems/GroundItems")
local Inventory = require("../inventory/Inventory")
local InventoryScreen = require("../inventory/InventoryScreen")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local PlotCollision = require("./PlotCollision")
local Position = require("../Position")
local Signal = require("../Signal")
local Station = require("../stations/Station")

local World = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory
type InventoryScreen = InventoryScreen.InventoryScreen
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
	--- The station that each placed object which was made one works as, by the placed object's id.
	read stations: { [number]: Station.Station },
	--- The id of the placed object that each open inventory screen was opened on, by the screen. A
	--- screen that is open on a pack alone has no entry.
	read placedObjectIdsByScreen: { [InventoryScreen]: number },
	--- The time `advanceTo` was last given, in seconds.
	now: number,
}

--- How far a player's character may stand from the middle of a tile and still reach it, in
--- studs along the ground.
World.CHARACTER_REACH = 16

--- How far a player may walk from a placed object they have open before its screen closes, in
--- studs along the ground. It is a little more than `CHARACTER_REACH`, so that a screen opened
--- from the edge of reach does not close at the first step back.
World.SCREEN_CLOSES_BEYOND = World.CHARACTER_REACH + 4

--- A player standing this near the middle of a tile, in studs along the ground, stands on it.
World.TILE_STOOD_ON_WITHIN = Plot.TILE_SIZE * 0.75

--- How far above a character's feet a stack that the character throws starts, in studs.
World.CHARACTER_THROW_START_HEIGHT = 3

--- How fast a stack that a character throws starts moving the way it is thrown, in studs a
--- second.
World.CHARACTER_THROW_FORWARD_SPEED = 24

--- How fast a stack that a character throws starts moving straight up, on top of its speed the
--- way it is thrown, in studs a second.
World.CHARACTER_THROW_UPWARD_SPEED = 8

--- How fast a stack that `throwStacksFromTile` throws starts moving outwards along the ground, in
--- studs a second.
World.TILE_THROW_OUTWARD_SPEED = 6

--- How fast a stack that `throwStacksFromTile` throws starts moving upwards, in studs a second.
World.TILE_THROW_UPWARD_SPEED = 20

local RADIANS_BETWEEN_THROWN_STACKS = 2.4
local NO_VELOCITY: GroundItems.Velocity = table.freeze({ x = 0, y = 0, z = 0 })

local function tileCenter(world: World, tileX: number, tileZ: number): Position
	return Plot.getTileCenter(world.plotCorner, tileX, tileZ)
end

local function sortedPlayerIds(world: World): { number }
	local ids = {}
	for playerId in world.players do
		table.insert(ids, playerId)
	end
	table.sort(ids)
	return ids
end

local function checkPlacedObjectId(world: World, placedObjectId: number)
	if world.plot.placedObjectsById[placedObjectId] == nil then
		error(`no placed object has the id {placedObjectId}`, 3)
	end
end

local function closeScreensOn(world: World, placedObjectId: number)
	for _, playerId in sortedPlayerIds(world) do
		local player = world.players[playerId]
		if World.getOpenedPlacedObjectId(world, player) == placedObjectId then
			World.closeScreen(world, player)
		end
	end
end

local function onPlacedObjectAdded(world: World, placedObject: Plot.PlacedObject)
	PlotCollision.pushGroundItemsOutOfTile(
		world.groundItems,
		world.plot,
		world.plotCorner,
		placedObject.tileX,
		placedObject.tileZ,
		world.now
	)
end

local function onPlacedObjectRemoved(world: World, placedObjectId: number)
	closeScreensOn(world, placedObjectId)
	world.stations[placedObjectId] = nil
end

--- Returns a new world with no players and nothing on the ground, at the time `now`. `plot` is
--- the plot, and `plotCorner` is the outer corner of its tile x 1, z 1.
--- Note: a placed object that already stands on `plot` is no station in the new world, until
--- `addStation` is called for it.
---
--- The world connects to the plot's two signals, and from then on:
--- - When an object is placed on the plot, the ground items that lie where it now stands are
---   pushed out of its tile: each is taken out of the world and its stack is spawned again, as a
---   new ground item with a new id, just outside the tile and moving away from it along the
---   ground, or on top of the placed object, not moving, if it is closed in on all four sides.
--- - A placed object taken off the plot has every screen open on it closed, as `closeScreen` does.
---   If it was made a station it is one no longer: its fire is out, and the fuel that was burning
---   is lost.
function World.new(plot: Plot.Plot, plotCorner: Position, now: number): World
	local world: World = {
		plot = plot,
		plotCorner = plotCorner,
		groundItems = GroundItems.new(),
		players = {},
		stations = {},
		placedObjectIdsByScreen = {},
		now = now,
	}
	Signal.connect(plot.placedObjectAdded, function(_placedObjectId: number, placedObject: Plot.PlacedObject)
		onPlacedObjectAdded(world, placedObject)
	end)
	Signal.connect(plot.placedObjectRemoved, function(placedObjectId: number)
		onPlacedObjectRemoved(world, placedObjectId)
	end)
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

local function getThrowStart(characterPosition: Position): Position
	local height = characterPosition.y + World.CHARACTER_THROW_START_HEIGHT
	return Position.new(characterPosition.x, height, characterPosition.z)
end

--- Throws a stack into the world from a character whose feet are at `characterPosition`: it
--- spawns `CHARACTER_THROW_START_HEIGHT` above them, moving the way `direction` points at
--- `CHARACTER_THROW_FORWARD_SPEED`, with `CHARACTER_THROW_UPWARD_SPEED` straight up added to that.
--- A `direction` that points up or down throws it up or down.
--- Note: it does not take the stack from anywhere.
function World.throwStackFromCharacter(
	world: World,
	stack: ItemStack,
	characterPosition: Position,
	direction: Direction
)
	World.spawnStack(world, stack, getThrowStart(characterPosition), {
		x = direction.x * World.CHARACTER_THROW_FORWARD_SPEED,
		y = direction.y * World.CHARACTER_THROW_FORWARD_SPEED + World.CHARACTER_THROW_UPWARD_SPEED,
		z = direction.z * World.CHARACTER_THROW_FORWARD_SPEED,
	})
end

--- Closes a player's inventory screen. The stack they were carrying goes back into their pack,
--- and what does not fit is dropped: it spawns `CHARACTER_THROW_START_HEIGHT` above their
--- character's feet, not moving. Does nothing if they have no screen open.
function World.closeScreen(world: World, player: PlayerState)
	local screen = player.screen
	if screen == nil then
		return
	end
	world.placedObjectIdsByScreen[screen] = nil
	local leftover = PlayerState.closeScreen(player)
	if leftover ~= nil then
		local character = assert(player.character, "a player who had a screen open has a character")
		World.spawnStack(world, leftover, getThrowStart(character.position), NO_VELOCITY)
	end
end

--- Sets where a player's character is, at its feet. A player who had no character has one from
--- now on. Fails if no player has that id.
function World.setCharacterPosition(world: World, playerId: number, position: Position)
	local player = assert(world.players[playerId], `no player has the id {playerId}`)
	PlayerState.setCharacterPosition(player, position)
end

--- Removes a player's character: they have none until `setCharacterPosition` is next called for
--- them. Their screen is closed first, as `closeScreen` does, while there is still a character to
--- drop the carried stack at. Does nothing if they have no character. Fails if no player has that
--- id.
function World.removeCharacter(world: World, playerId: number)
	local player = assert(world.players[playerId], `no player has the id {playerId}`)
	World.closeScreen(world, player)
	PlayerState.removeCharacter(player)
end

--- Makes the placed object with the id `placedObjectId` work as `station`: `advanceTo` burns its
--- fire and does its work for as long as that placed object stands on the plot. Fails if no placed
--- object has that id, or if that placed object was made a station already.
function World.addStation(world: World, placedObjectId: number, station: Station.Station)
	checkPlacedObjectId(world, placedObjectId)
	if world.stations[placedObjectId] ~= nil then
		error(`the placed object {placedObjectId} was made a station already`, 2)
	end
	world.stations[placedObjectId] = station
end

--- Opens a player's inventory screen on their pack with `inventory` beside it, as the screen of
--- the placed object with the id `placedObjectId`. Any screen they had open is closed first, as
--- `closeScreen` does. `slotAcceptsItem`, if given, says whether a slot of `inventory` takes an
--- item: it is called with the slot and the item's id. The screen is closed when that placed
--- object is taken off the plot, and when `advanceTo` finds the player more than
--- `SCREEN_CLOSES_BEYOND` from it. Fails, changing nothing, if no placed object has that id or if
--- the player has no character.
function World.openPlacedObjectScreen(
	world: World,
	player: PlayerState,
	placedObjectId: number,
	inventory: Inventory,
	slotAcceptsItem: ((slot: number, itemId: string) -> boolean)?
)
	checkPlacedObjectId(world, placedObjectId)
	if player.character == nil then
		error("a screen can be opened only for a player who has a character", 2)
	end
	World.closeScreen(world, player)
	PlayerState.openScreen(player, inventory, slotAcceptsItem)
	world.placedObjectIdsByScreen[player.screen :: InventoryScreen] = placedObjectId
end

--- Returns the id of the placed object that a player's screen was opened on. Returns `nil` if
--- their screen is open on their pack alone, or if they have no screen open.
function World.getOpenedPlacedObjectId(world: World, player: PlayerState): number?
	local screen = player.screen
	return if screen ~= nil then world.placedObjectIdsByScreen[screen] else nil
end

--- Returns `true` if a player's character stands within `CHARACTER_REACH` of the middle of the
--- tile `tileX`, `tileZ` of the plot, in studs along the ground. A player with no character
--- reaches nothing.
function World.canReachTile(world: World, player: PlayerState, tileX: number, tileZ: number): boolean
	local character = player.character
	local center = tileCenter(world, tileX, tileZ)
	return character ~= nil and Position.getGroundDistance(character.position, center) <= World.CHARACTER_REACH
end

--- Returns `true` if any player's character stands on the tile `tileX`, `tileZ` of the plot:
--- within `TILE_STOOD_ON_WITHIN` of its middle.
function World.isTileStoodOn(world: World, tileX: number, tileZ: number): boolean
	local center = tileCenter(world, tileX, tileZ)
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

--- Returns `true` if an object can be placed on the tile `tileX`, `tileZ` of the plot:
--- `Plot.canPlaceObject` says the plot can take one there, and no player's character stands on the
--- tile.
--- Note: `Plot.placeObject` does not ask this. Whoever places an object asks it first, if a
--- player standing on the tile should stop them.
function World.canPlaceObject(world: World, tileX: number, tileZ: number): boolean
	return Plot.canPlaceObject(world.plot, tileX, tileZ) and not World.isTileStoodOn(world, tileX, tileZ)
end

--- Throws each stack of `stacks` into the world from the tile `tileX`, `tileZ` of the plot. Each
--- is spawned as `spawnStack` does, in the middle of the cube that a placed object fills on that
--- tile, moving upwards at `TILE_THROW_UPWARD_SPEED` and outwards along the ground at
--- `TILE_THROW_OUTWARD_SPEED`, each a different way from the one before.
--- Note: it does not take the stacks from anywhere.
function World.throwStacksFromTile(world: World, stacks: { ItemStack }, tileX: number, tileZ: number)
	local center = tileCenter(world, tileX, tileZ)
	local middle = Position.new(center.x, center.y + (Plot.TILE_SIZE - GroundItems.ITEM_WIDTH) / 2, center.z)
	for index, stack in stacks do
		local angle = index * RADIANS_BETWEEN_THROWN_STACKS
		World.spawnStack(world, stack, middle, {
			x = math.cos(angle) * World.TILE_THROW_OUTWARD_SPEED,
			y = World.TILE_THROW_UPWARD_SPEED,
			z = math.sin(angle) * World.TILE_THROW_OUTWARD_SPEED,
		})
	end
end

local function pickUpNearbyStacks(world: World, player: PlayerState)
	local character = player.character
	if character == nil then
		return
	end
	for _, id in GroundItems.getIdsInPickupReach(world.groundItems, character.position, world.now) do
		local stack = world.groundItems.itemsById[id].stack
		local added = Inventory.addItems(player.pack, stack.itemId, stack.count)
		GroundItems.takeFromItem(world.groundItems, id, added)
	end
end

local function closeScreenIfOutOfReach(world: World, player: PlayerState)
	local placedObjectId = World.getOpenedPlacedObjectId(world, player)
	local character = player.character
	if placedObjectId == nil or character == nil then
		return
	end
	local placedObject = world.plot.placedObjectsById[placedObjectId]
	local center = tileCenter(world, placedObject.tileX, placedObject.tileZ)
	if Position.getGroundDistance(character.position, center) > World.SCREEN_CLOSES_BEYOND then
		World.closeScreen(world, player)
	end
end

--- Moves the world on to the time `now`, in this order:
--- - Ground items of the same item that lie close together merge. Each one that was spawned or
---   given a new position since the world was last moved on gets a merge check, and so does each
---   one that has been in the world for another `GroundItems.MERGE_CHECK_SECONDS`. Of two whose
---   stacks fit in one stack, the bigger takes in the smaller, and stays where it is.
--- - Each player with a character, the one with the lowest id first, picks up the ground items
---   that `GroundItems.getIdsInPickupReach` returns for where their character stands, in the
---   order it returns them. As many of each one's stack go into their pack as `Inventory.addItems`
---   adds, and those are taken out of the ground item. What did not fit stays on the ground, in
---   the same ground item, and one that none of fitted is left as it was. If their screen is open
---   on a placed object that they stand more than `SCREEN_CLOSES_BEYOND` from, it is then closed,
---   as `closeScreen` does.
--- - Every station burns and works for the time that has passed. If `now` is earlier than the
---   time `advanceTo` was last given, no time passes for the stations.
--- - Ground items that have been in the world too long are removed.
function World.advanceTo(world: World, now: number)
	local elapsed = math.max(now - world.now, 0)
	world.now = now
	GroundItems.mergeItems(world.groundItems, now)
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
