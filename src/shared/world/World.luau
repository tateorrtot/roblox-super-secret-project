--!strict
--- Everything in one running copy of the game: the plot, the stacks on the ground, and the players.
---
--- The server keeps one world. It adds and removes players, says where each one stands with
--- `setPlayerPosition`, and moves time on with `step`. The other functions are what can be done
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
	--- Where the plot's corner is in the world.
	read plotCorner: Position,
	--- The stacks lying on the ground.
	read groundItems: GroundItems.GroundItems,
	--- Every player in the world, by id. On Roblox the id is the UserId.
	read players: { [number]: PlayerState },
	--- The station that each placed stove is, by the placed item's id.
	read stations: { [number]: Station.Station },
	--- The time `step` was last given, in seconds.
	now: number,
}

--- How far a player may walk from a placed item they have open before its screen closes, in
--- studs along the ground.
World.CLOSES_BEYOND = Plot.REACH + 4

--- A player standing this near the middle of a tile, in studs along the ground, stands on it.
World.STANDS_ON_WITHIN = Plot.TILE_SIZE * 0.75

local SPILL_DISTANCE = 1.7
local SPILL_ANGLE = 2.4

local function tileCenter(world: World, x: number, z: number): Position
	return Plot.tileCenter(world.plotCorner, x, z)
end

local function sortedPlayerIds(world: World): { number }
	local ids = {}
	for playerId in world.players do
		table.insert(ids, playerId)
	end
	table.sort(ids)
	return ids
end

local function addStation(world: World, placedId: number, placedItem: Plot.PlacedItem)
	local inventory = placedItem.inventory
	if inventory ~= nil and RecipeRegistry.isStation(placedItem.itemId) then
		world.stations[placedId] = Station.new(placedItem.itemId, inventory)
	end
end

--- Returns a new world with no players and nothing on the ground, at the time `now`. `plot` is
--- the plot, with whatever already stands on it, and `plotCorner` is where its corner is.
function World.new(plot: Plot.Plot, plotCorner: Position, now: number): World
	local world: World = {
		plot = plot,
		plotCorner = plotCorner,
		groundItems = GroundItems.new(),
		players = {},
		stations = {},
		now = now,
	}
	for placedId, placedItem in plot.placedById do
		addStation(world, placedId, placedItem)
	end
	return world
end

--- Puts a stack on the ground at a position.
function World.dropStack(world: World, stack: ItemStack, position: Position)
	GroundItems.drop(world.groundItems, stack, position, world.now)
end

--- Closes a player's inventory screen. The stack they were carrying goes back into their pack,
--- and what does not fit lands on the ground at their `dropPosition`. Does nothing if they have no
--- screen open.
function World.closeScreen(world: World, state: PlayerState)
	local screen = state.screen
	if screen == nil then
		return
	end
	local carried = InventoryScreen.takeCarried(screen)
	local leftover = if carried then Inventory.addStack(state.pack, carried) else nil
	if leftover ~= nil then
		World.dropStack(world, leftover, state.dropPosition)
	end
	state.screen = nil
	state.openedPlacedId = nil
end

--- Opens the inventory of a placed item on a player's screen, beside their pack, and returns
--- `true`. Any screen they had open is closed first, as `closeScreen` does. Returns `false`,
--- changing nothing, if no placed item has that id or it has no inventory.
function World.openPlaced(world: World, state: PlayerState, placedId: number): boolean
	local placedItem = world.plot.placedById[placedId]
	local inventory = if placedItem then placedItem.inventory else nil
	if placedItem == nil or inventory == nil then
		return false
	end
	World.closeScreen(world, state)
	local itemId = placedItem.itemId
	local stationAccepts = function(slot: number, putItemId: string): boolean
		return Station.accepts(itemId, slot, putItemId)
	end
	state.screen = InventoryScreen.new(state.pack, inventory, if world.stations[placedId] then stationAccepts else nil)
	state.openedPlacedId = placedId
	return true
end

--- Adds a new player to the world and returns them. They have no character yet, and a stack
--- they drop lands at `dropPosition` until `setPlayerPosition` says where they stand. They carry
--- `pack`, or a pack that holds nothing if none is given. Fails if a player already has that id.
function World.addPlayer(world: World, playerId: number, dropPosition: Position, pack: Inventory?): PlayerState
	assert(world.players[playerId] == nil, `player {playerId} is already in the world`)
	local state = PlayerState.new(dropPosition, pack)
	world.players[playerId] = state
	return state
end

--- Takes a player out of the world and returns them, or `nil` if no player has that id. Their
--- inventory screen is closed first, as `closeScreen` does.
function World.removePlayer(world: World, playerId: number): PlayerState?
	local state = world.players[playerId]
	if state == nil then
		return nil
	end
	World.closeScreen(world, state)
	world.players[playerId] = nil
	return state
end

--- Says where a player's character stands, and where a stack they drop lands. `position` is the
--- point on the ground under the character, or `nil` if they have no living character, in which
--- case their `dropPosition` stays as it was. Their drops land at `dropPosition`, or at `position`
--- if it is left out. Fails if no player has that id.
function World.setPlayerPosition(world: World, playerId: number, position: Position?, dropPosition: Position?)
	local state = assert(world.players[playerId], `no player has the id {playerId}`)
	state.position = position
	if position ~= nil then
		state.dropPosition = dropPosition or position
	end
end

--- Returns `true` if a player's character stands within `Plot.REACH` of the middle of a tile,
--- in studs along the ground. A player with no character reaches nothing.
function World.canReach(world: World, state: PlayerState, x: number, z: number): boolean
	local position = state.position
	return position ~= nil and Position.groundDistance(position, tileCenter(world, x, z)) <= Plot.REACH
end

--- Returns `true` if any player's character stands on a tile: within `STANDS_ON_WITHIN` of its
--- middle.
function World.isStoodOn(world: World, x: number, z: number): boolean
	local center = tileCenter(world, x, z)
	for _, state in world.players do
		local position = state.position
		if position ~= nil and Position.groundDistance(position, center) <= World.STANDS_ON_WITHIN then
			return true
		end
	end
	return false
end

--- Places one of an item on a tile and returns the placed item's id. Returns `nil`, placing
--- nothing, if a player stands on the tile, if something already stands on it, or if the item
--- cannot be placed. A placed stove starts as a station with no fire.
function World.placeItem(world: World, itemId: string, x: number, z: number): number?
	if World.isStoodOn(world, x, z) then
		return nil
	end
	local placedId = Plot.place(world.plot, itemId, x, z)
	if placedId ~= nil then
		addStation(world, placedId, world.plot.placedById[placedId])
	end
	return placedId
end

local function closeScreensOn(world: World, placedId: number)
	for _, playerId in sortedPlayerIds(world) do
		local state = world.players[playerId]
		if state.openedPlacedId == placedId then
			World.closeScreen(world, state)
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
			World.dropStack(world, stack, { x = x, y = center.y, z = z })
		end
	end
end

--- Takes a placed item off the plot. Every screen open on it is closed first, as `closeScreen`
--- does. The item then lies on its tile as a ground item, and each stack that was inside it lies
--- on the ground in a ring around it. If it was a station its fire goes out, and the fuel that was
--- burning is lost. Does nothing if no placed item has that id.
function World.removePlaced(world: World, placedId: number)
	local placedItem = world.plot.placedById[placedId]
	if placedItem == nil then
		return
	end
	closeScreensOn(world, placedId)
	Plot.remove(world.plot, placedId)
	world.stations[placedId] = nil
	local center = tileCenter(world, placedItem.x, placedItem.z)
	World.dropStack(world, ItemStack.new(placedItem.itemId, 1), center)
	if placedItem.inventory ~= nil then
		spill(world, placedItem.inventory, center)
	end
end

local function pickUpNear(world: World, state: PlayerState)
	local position = state.position
	if position ~= nil then
		GroundItems.pickUpNear(world.groundItems, position, state.pack, world.now)
	end
end

local function closeIfOutOfReach(world: World, state: PlayerState)
	local placedId = state.openedPlacedId
	if placedId == nil then
		return
	end
	local placedItem = world.plot.placedById[placedId]
	local position = state.position
	local isInReach = placedItem ~= nil
		and position ~= nil
		and Position.groundDistance(position, tileCenter(world, placedItem.x, placedItem.z)) <= World.CLOSES_BEYOND
	if not isInReach then
		World.closeScreen(world, state)
	end
end

--- Moves the world on to the time `now`. Each player with a character picks up the ground items
--- near them, the player with the lowest id first. A player whose screen is open on a placed item
--- has it closed, as `closeScreen` does, if they stand more than `CLOSES_BEYOND` from it, if they
--- have no character, or if it is no longer on the plot. Every station burns and works for the
--- time that has passed. Ground items that have lain too long are removed.
function World.step(world: World, now: number)
	local elapsed = math.max(now - world.now, 0)
	world.now = now
	for _, playerId in sortedPlayerIds(world) do
		local state = world.players[playerId]
		pickUpNear(world, state)
		closeIfOutOfReach(world, state)
	end
	for _, station in world.stations do
		Station.step(station, elapsed)
	end
	GroundItems.expire(world.groundItems, now)
end

return World
