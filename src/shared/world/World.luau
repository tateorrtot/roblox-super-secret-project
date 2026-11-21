--!strict
--- Everything in one running game: its plot, the stacks loose in it, its players, and its clock.
---
--- `addPlayer` and `removePlayer` add and remove players. `setCharacterPosition` sets where a
--- player's character is, `setGroundItemPosition` sets where a ground item has got to, and
--- `advanceTo` moves time on. `spawnStack`, `throwStackFromCharacter`, and `throwStacksFromTile`
--- put stacks into the world. `openPlacedObjectScreen` and `closeScreen` open and close a player's
--- screen. `canReachTile`, `isTileStoodOn`, and `canPlaceObject` answer questions about a tile.
---
--- A world connects to its plot's two signals. After `Plot.placeObject` adds a placed object, the
--- world pushes the ground items out of its tile. After `Plot.removePlacedObject` removes one, the
--- world closes every screen open on it. A world reads nothing else of what stands on its plot.
--- `advanceTo` fires `timePassed`, with the seconds that passed, for whatever does something as
--- time passes.
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

local World = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory
type InventoryScreen = InventoryScreen.InventoryScreen
type PlayerState = PlayerState.PlayerState
type Position = Position.Position
type Direction = Direction.Direction

--- One running game: its plot, its ground items, its players, and its clock.
export type World = {
	--- The world's plot, shared by every player.
	read plot: Plot.Plot,
	--- The position of the outer corner of the plot's tile x `1`, z `1`.
	read plotCorner: Position,
	--- The ground items in the world.
	read groundItems: GroundItems.GroundItems,
	--- Every player in the world, by the id that `addPlayer` was given.
	read players: { [number]: PlayerState },
	--- Fires during `advanceTo`. Passes the seconds since the time `advanceTo` was last given, or
	--- `0` if `now` is no later than that time.
	read timePassed: Signal.Signal<number>,
	--- The id of the placed object that each screen is open on, by screen. A screen open on a pack
	--- alone has no entry.
	read placedObjectIdsByScreen: { [InventoryScreen]: number },
	--- The time that `advanceTo` was last given, in seconds. `new` sets it to the time it is given.
	now: number,
}

--- The greatest distance between a character and the middle of a tile at which the character
--- reaches the tile, in studs along the ground.
World.CHARACTER_REACH = 16

--- The distance from the middle of a placed object's tile, in studs along the ground, beyond which
--- `advanceTo` closes a player's screen that is open on the placed object. It is four studs more
--- than `CHARACTER_REACH`.
World.SCREEN_CLOSES_BEYOND = World.CHARACTER_REACH + 4

--- The greatest distance between a character and the middle of a tile at which `isTileStoodOn`
--- counts the character as standing on the tile, in studs along the ground.
World.TILE_STOOD_ON_WITHIN = Plot.TILE_SIZE * 0.75

--- The height above a character's feet at which a stack spawns when `throwStackFromCharacter`
--- throws it or `closeScreen` spawns it, in studs.
World.CHARACTER_THROW_START_HEIGHT = 3

--- The speed in the direction of the throw, in studs a second, that `throwStackFromCharacter`
--- gives a stack.
World.CHARACTER_THROW_FORWARD_SPEED = 24

--- The speed straight up, in studs a second, that `throwStackFromCharacter` adds to the velocity of
--- a stack.
World.CHARACTER_THROW_UPWARD_SPEED = 8

--- The speed outwards along the ground, in studs a second, that `throwStacksFromTile` gives a
--- stack.
World.TILE_THROW_OUTWARD_SPEED = 6

--- The speed straight up, in studs a second, that `throwStacksFromTile` gives a stack.
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
end

--- Returns a new world on `plot`, whose tile x `1`, z `1` has its outer corner at `plotCorner`,
--- with no players, no ground items, and the time `now`.
---
--- `new` connects the world to the plot's two signals:
--- - After `plot` fires `placedObjectAdded`, the world pushes the ground items out of the placed
---   object's tile, as `PlotCollision.pushGroundItemsOutOfTile` does, at the world's `now`.
--- - After `plot` fires `placedObjectRemoved`, the world closes every screen open on that placed
---   object, as `closeScreen` does, the player with the lowest id first.
function World.new(plot: Plot.Plot, plotCorner: Position, now: number): World
	local world: World = {
		plot = plot,
		plotCorner = plotCorner,
		groundItems = GroundItems.new(),
		players = {},
		timePassed = Signal.new(),
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

--- Adds a new player with the id `playerId` to the world and returns them. The player has no
--- character. Their pack is `pack`, or an empty pack if `pack` is `nil`. Fails, and changes
--- nothing, if a player already has the id `playerId`.
function World.addPlayer(world: World, playerId: number, pack: Inventory?): PlayerState
	assert(world.players[playerId] == nil, `player {playerId} is already in the world`)
	local player = PlayerState.new(pack)
	world.players[playerId] = player
	return player
end

--- Removes the player with the id `playerId` from the world, after closing their screen as
--- `closeScreen` does, and returns them. Returns `nil` and changes nothing if no player has the id
--- `playerId`.
function World.removePlayer(world: World, playerId: number): PlayerState?
	local player = world.players[playerId]
	if player == nil then
		return nil
	end
	World.closeScreen(world, player)
	world.players[playerId] = nil
	return player
end

--- Spawns `stack` as a ground item at `position`, with the spawn velocity `velocity` and the
--- world's `now` as its spawn time, as `GroundItems.spawnStack` does. Returns the ground item's id.
--- Note: `spawnStack` takes `stack` from nowhere.
function World.spawnStack(world: World, stack: ItemStack, position: Position, velocity: GroundItems.Velocity): number
	return GroundItems.spawnStack(world.groundItems, stack, position, velocity, world.now)
end

--- Sets the position of the ground item `groundItemId` to `position`, the middle of its underside,
--- as `GroundItems.setItemPosition` does. Does nothing if no ground item has that id.
function World.setGroundItemPosition(world: World, groundItemId: number, position: Position)
	GroundItems.setItemPosition(world.groundItems, groundItemId, position)
end

local function getThrowStart(characterPosition: Position): Position
	local height = characterPosition.y + World.CHARACTER_THROW_START_HEIGHT
	return Position.new(characterPosition.x, height, characterPosition.z)
end

--- Spawns `stack` as a ground item `CHARACTER_THROW_START_HEIGHT` above `characterPosition`, the
--- position of a character's feet. The ground item moves along `direction` at
--- `CHARACTER_THROW_FORWARD_SPEED`, with `CHARACTER_THROW_UPWARD_SPEED` straight up added. A
--- `direction` that points up or down throws the stack up or down.
--- Note: `throwStackFromCharacter` takes `stack` from nowhere.
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

--- Closes the player's inventory screen and adds the stack that it carried to their pack. The part
--- that does not fit spawns as a ground item `CHARACTER_THROW_START_HEIGHT` above their
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

--- Sets the position, at its feet, of the character of the player with the id `playerId` to
--- `position`, and gives the player a character if they had none. Fails if no player has that id.
function World.setCharacterPosition(world: World, playerId: number, position: Position)
	local player = assert(world.players[playerId], `no player has the id {playerId}`)
	PlayerState.setCharacterPosition(player, position)
end

--- Closes the screen of the player with the id `playerId`, as `closeScreen` does, and then removes
--- their character, so they have none until `setCharacterPosition` runs. Does nothing if they have
--- no character. Fails if no player has that id.
function World.removeCharacter(world: World, playerId: number)
	local player = assert(world.players[playerId], `no player has the id {playerId}`)
	World.closeScreen(world, player)
	PlayerState.removeCharacter(player)
end

--- Opens the player's inventory screen on their pack with `inventory` beside it, as the screen of
--- the placed object with the id `placedObjectId`. Closes any screen they had open first, as
--- `closeScreen` does. `slotAcceptsItem`, if given, takes a slot and an item's id and returns
--- `true` if that slot of `inventory` takes that item. The screen closes when
--- `Plot.removePlacedObject` removes that placed object, and when `advanceTo` finds the player's
--- character more than `SCREEN_CLOSES_BEYOND` from it. Fails, and changes nothing, if no placed
--- object has the id `placedObjectId` or if the player has no character.
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

--- Returns the id of the placed object that the player's screen is open on. Returns `nil` if their
--- screen is open on their pack alone, or if they have no screen open.
function World.getOpenedPlacedObjectId(world: World, player: PlayerState): number?
	local screen = player.screen
	return if screen ~= nil then world.placedObjectIdsByScreen[screen] else nil
end

--- Returns `true` if the player's character stands within `CHARACTER_REACH` of the middle of the
--- tile `tileX`, `tileZ` of the plot, along the ground. Returns `false` for a player with no
--- character.
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

--- Returns `true` if `Plot.canPlaceObject` returns `true` for the tile `tileX`, `tileZ` of the
--- plot, and `isTileStoodOn` returns `false` for it.
--- Note: `Plot.placeObject` does not check `isTileStoodOn`, so it places an object on a tile that a
--- character stands on.
function World.canPlaceObject(world: World, tileX: number, tileZ: number): boolean
	return Plot.canPlaceObject(world.plot, tileX, tileZ) and not World.isTileStoodOn(world, tileX, tileZ)
end

--- Spawns each stack of `stacks`, as `spawnStack` does, as a ground item that lies in the middle of
--- the cube that a placed object fills on the tile `tileX`, `tileZ` of the plot. Each ground item
--- moves up at `TILE_THROW_UPWARD_SPEED` and outwards along the ground at
--- `TILE_THROW_OUTWARD_SPEED`. The first goes 2.4 radians from the direction of greater x towards
--- greater z, and each later one 2.4 radians further round than the one before.
--- Note: `throwStacksFromTile` takes `stacks` from nowhere.
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
--- - `GroundItems.mergeItems` merges the ground items of the same item that lie close together.
--- - For each player with a character, the player with the lowest id first, the world adds the
---   stacks of the ground items that `GroundItems.getIdsInPickupReach` returns for the
---   character's position to the player's pack, in the order it returns them. `Inventory.addItems`
---   adds as many items of each stack as fit, and `GroundItems.takeFromItem` takes that many out of
---   the ground item. What did not fit stays in the same ground item, and a ground item of which
---   no item fits stays as it was. Then, if the player's screen is open on a placed object that the
---   character stands more than `SCREEN_CLOSES_BEYOND` from, the world closes the screen, as
---   `closeScreen` does.
--- - `timePassed` fires, passing the seconds since the time `advanceTo` was last given, or `0` if
---   `now` is no later than that time.
--- - `GroundItems.removeExpiredItems` removes every ground item that was spawned
---   `GroundItems.LIFETIME_SECONDS` or more before `now`.
--- Note: an error in a callback connected to `timePassed` passes out of `advanceTo`. By then
--- `advanceTo` has set the world's `now` to `now`, and it does not do the step after `timePassed`.
function World.advanceTo(world: World, now: number)
	local elapsed = math.max(now - world.now, 0)
	world.now = now
	GroundItems.mergeItems(world.groundItems, now)
	for _, playerId in sortedPlayerIds(world) do
		local player = world.players[playerId]
		pickUpNearbyStacks(world, player)
		closeScreenIfOutOfReach(world, player)
	end
	Signal.fire(world.timePassed, elapsed)
	GroundItems.removeExpiredItems(world.groundItems, now)
end

return World
