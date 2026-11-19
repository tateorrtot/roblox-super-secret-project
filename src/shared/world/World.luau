--!strict
--[=[
	Everything in one running copy of the game, as far as the rules go: the
	plot and what stands on it, the stacks lying on the ground, and every
	player with what they carry and where they stand.

	The server keeps one world. Four things change it:
	- Players come and go: [method addPlayer] and [method removePlayer].
	- Characters move. The server reads where each one stands and says so
	  with [method setPlayerPosition].
	- A player's machine sends a request. [method answer] checks it and
	  carries it out, if it makes sense.
	- Time passes. [method step] lets players pick up what lies near them,
	  closes what a player has walked away from, lets every station on the
	  plot burn and work, and clears ground items that have lain too long.

	Everything that may change the game goes through these, so the server
	has no rules of its own. It tells the world what happened, then draws
	the world, and tells each player's machine what that player holds,
	which [method encodeView] gives it as plain data.

	A player is known by a number, their id. On Roblox that is the UserId.

	Time is a number of seconds, from any clock that only goes forward. The
	world keeps the time [method step] last gave it in `now`, and uses that
	for whatever happens before the next step.

	This is the rules only. It makes no Roblox calls and draws nothing.

	```lua
	local world = World.new(plot, plotCorner, now)
	World.addPlayer(world, 12, spawnPosition)
	World.setPlayerPosition(world, 12, whereTheyStand, whereADropWouldLand)
	World.answer(world, 12, "placeSelected", 3, 5) -- player 12 asks to place what is in hand on tile x 3, z 5
	World.step(world, now)
	local pack, screen = World.encodeView(world, 12) -- what to tell player 12's machine
	```
]=]
local GroundItems = require("./GroundItems")
local Hotbar = require("../inventory/Hotbar")
local Inventory = require("../inventory/Inventory")
local InventoryRequests = require("../players/InventoryRequests")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local Position = require("./Position")
local RecipeRegistry = require("../stations/RecipeRegistry")
local Station = require("../stations/Station")

local World = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory
type PlayerState = PlayerState.PlayerState
type Position = Position.Position

--- One player in the world. `read` means code outside this module cannot assign the field.
export type WorldPlayer = {
	--- What the player carries, their hotbar, and their open inventory screen.
	read state: PlayerState,
	--- Where the player stands: the point on the ground under their character.
	--- `nil` while they have no living character.
	read position: Position?,
	--- Where a stack the player drops will land.
	read dropPosition: Position,
	--- The id of the placed item whose inventory the player has open, or `nil`.
	read openedPlacedId: number?,
}

--- `read` means code outside this module cannot assign the field. Change a world with the functions below.
export type World = {
	--- The one plot there is for now, shared by every player.
	read plot: Plot.Plot,
	--- Where the plot's corner is in the world, as `Plot.tileAt` wants it.
	read plotCorner: Position,
	--- The stacks lying on the ground.
	read groundItems: GroundItems.GroundItems,
	--- Every player in the world, by id.
	read players: { read [number]: WorldPlayer },
	--- The fire and the work of each placed item that is a station, by the placed item's id.
	--- A station has an entry from the first step after it is placed, or from when it is first used.
	read stations: { read [number]: Station.Station },
	--- The time [method step] was last given, in seconds.
	read now: number,
}

--- What a player's machine is told about their open inventory screen, as plain data.
export type ScreenView = {
	--- The other inventory that is open beside the pack, as `Inventory.encode` makes it. `nil` if the pack is open alone.
	other: Inventory.EncodedInventory?,
	--- The id of the item whose inventory that is, such as `"crate"`.
	otherItemId: string?,
	--- The stack being carried, or `nil`.
	carried: ItemStack?,
	--- If what is open is a station: how far its fire has burnt and its work has got, as `Station.encodeView` makes it.
	station: Station.StationView?,
}

--- How far a player may walk from a placed item they have open before its screen closes, in studs along the ground.
World.CLOSES_BEYOND = Plot.REACH + 4

--- The name of every request that [method answer] answers: those about a player's own inventories,
--- which InventoryRequests answers, and those about the plot.
World.REQUEST_NAMES = table.freeze(
	table.move(
		{ "placeSelected", "usePlaced", "hitPlaced" },
		1,
		3,
		#InventoryRequests.NAMES + 1,
		table.clone(InventoryRequests.NAMES)
	)
)

-- A player standing this near the middle of a tile, along the ground, is standing on it.
local STANDS_ON_WITHIN = Plot.TILE_SIZE * 0.75

-- What was inside a placed item that is knocked off the plot lands in a ring this far from the middle of its tile.
local SPILL_DISTANCE = 1.7

local isInventoryRequest: { [string]: boolean } = {}
for _, name in InventoryRequests.NAMES do
	isInventoryRequest[name] = true
end

-- Raises `problem` as an error that names the public function and blames the code that called it.
local function failIf(problem: string?, functionName: string)
	if problem ~= nil then
		error(functionName .. ": " .. problem, 3)
	end
end

local function timeProblem(now: number): string?
	if type(now) == "number" and now == now and now ~= math.huge and now ~= -math.huge then
		return nil
	end
	return string.format("now must be a number of seconds; got %s", tostring(now))
end

local function playerIdProblem(playerId: number): string?
	if type(playerId) == "number" and playerId == playerId then
		return nil
	end
	return string.format("playerId must be a number; got %s", tostring(playerId))
end

local function frozenCopy(position: Position): Position
	return table.freeze({ x = position.x, y = position.y, z = position.z })
end

-- Returns the ids of the players in the world, lowest first, so that what happens to several players
-- happens in the same order every time.
local function sortedPlayerIds(world: World): { number }
	local ids = {}
	for playerId in world.players do
		table.insert(ids, playerId)
	end
	table.sort(ids)
	return ids
end

local function tileCenter(world: World, x: number, z: number): Position
	return Plot.tileCenter(world.plotCorner, x, z)
end

-- Returns the station that a placed item is, making its record if this is the first anyone has asked.
-- Returns nil for a placed item that is not a station, or an id that is not on the plot.
local function stationOf(world: World, placedId: number): Station.Station?
	local station = world.stations[placedId]
	if station ~= nil then
		return station
	end
	local placedItem = world.plot.placedById[placedId]
	local inventory = if placedItem ~= nil then placedItem.inventory else nil
	if placedItem == nil or inventory == nil or not RecipeRegistry.isStation(placedItem.itemId) then
		return nil
	end
	local made = Station.new(placedItem.itemId, inventory)
	local stations = world.stations :: any
	stations[placedId] = made
	return made
end

-- Puts a stack that has left a player's inventories on the ground where their drops land. Does nothing given nil.
local function dropFor(world: World, player: WorldPlayer, stack: ItemStack?)
	if stack ~= nil then
		GroundItems.drop(world.groundItems, stack, player.dropPosition, world.now)
	end
end

local function closeInventoryOf(world: World, player: WorldPlayer)
	dropFor(world, player, PlayerState.closeInventory(player.state));
	(player :: any).openedPlacedId = nil
end

-- True if the player's character stands near enough to the tile to place on it, or to use or hit what stands on it.
local function canReach(world: World, player: WorldPlayer, x: number, z: number): boolean
	local position = player.position
	return position ~= nil and Position.groundDistance(position, tileCenter(world, x, z)) <= Plot.REACH
end

-- True if any player's character stands on the tile, so that a thing placed there would land on them.
local function isTileStoodOn(world: World, x: number, z: number): boolean
	local center = tileCenter(world, x, z)
	for _, player in world.players do
		local position = player.position
		if position ~= nil and Position.groundDistance(position, center) <= STANDS_ON_WITHIN then
			return true
		end
	end
	return false
end

-- Places one of the item in the player's hand on a tile, if the tile is theirs to reach, nobody
-- stands on it, nothing stands on it, and the item is one that can be placed.
local function placeSelected(world: World, player: WorldPlayer, x: unknown, z: unknown)
	local state = player.state
	local inHand = Hotbar.selectedStack(state.hotbar)
	if inHand == nil or state.session ~= nil or not Plot.hasTile(world.plot, x, z) then
		return
	end
	local tileX, tileZ = x :: number, z :: number
	if not canReach(world, player, tileX, tileZ) or isTileStoodOn(world, tileX, tileZ) then
		return
	end
	if Plot.canPlace(world.plot, inHand.itemId, tileX, tileZ) then
		Inventory.takeFromSlot(state.pack, state.hotbar.selectedSlot, 1)
		Plot.place(world.plot, inHand.itemId, tileX, tileZ)
	end
end

-- Opens the inventory of a placed item for the player, if it has one and is in their reach.
local function usePlaced(world: World, player: WorldPlayer, id: unknown)
	-- Whatever `id` is, looking it up is safe: anything that is not the id of a placed item finds nothing.
	local placedId = id :: number
	local placedItem = world.plot.placedById[placedId]
	if placedItem == nil or placedItem.inventory == nil or not canReach(world, player, placedItem.x, placedItem.z) then
		return
	end
	closeInventoryOf(world, player)
	-- A station's slots each take only what belongs in them.
	local slotRules = if stationOf(world, placedId) ~= nil then Station.slotRules(placedItem.itemId) else nil
	PlayerState.openInventory(player.state, placedItem.inventory, slotRules);
	(player :: any).openedPlacedId = placedId
end

-- Knocks a placed item off the plot, if it is in the player's reach. It lies on its tile as an item
-- again, and what was in it is spilled around it.
local function hitPlaced(world: World, player: WorldPlayer, id: unknown)
	local placedId = id :: number
	local placedItem = world.plot.placedById[placedId]
	if placedItem == nil or not canReach(world, player, placedItem.x, placedItem.z) then
		return
	end
	-- Anyone looking into it stops first, so that what they were carrying is back in their pack.
	for _, playerId in sortedPlayerIds(world) do
		local viewer = world.players[playerId]
		if viewer.openedPlacedId == placedId then
			closeInventoryOf(world, viewer)
		end
	end
	Plot.remove(world.plot, placedId)
	-- A station's fire goes out with it. The fuel that was burning is gone.
	local stations = world.stations :: any
	stations[placedId] = nil

	local center = tileCenter(world, placedItem.x, placedItem.z)
	GroundItems.drop(world.groundItems, ItemStack.new(placedItem.itemId, 1), center, world.now)
	local inside = placedItem.inventory
	if inside ~= nil then
		local spilled = 0
		for slot = 1, inside.slotCount do
			local stack = Inventory.takeFromSlot(inside, slot)
			if stack ~= nil then
				spilled += 1
				local angle = spilled * 2.4
				GroundItems.drop(world.groundItems, stack, {
					x = center.x + math.cos(angle) * SPILL_DISTANCE,
					y = center.y,
					z = center.z + math.sin(angle) * SPILL_DISTANCE,
				}, world.now)
			end
		end
	end
end

--[=[
	Returns a new world with no players and nothing on the ground, at the
	time `now`.

	`plot` is the plot, with whatever already stands on it, and `plotCorner`
	is where its corner is in the world. The world holds the plot it is
	given, not a copy.

	Raises an error if `plotCorner` is not a position, or if `now` is not a
	number.
]=]
function World.new(plot: Plot.Plot, plotCorner: Position, now: number): World
	local cornerProblem = Position.validate(plotCorner)
	failIf(if cornerProblem ~= nil then "plotCorner: " .. cornerProblem else nil, "World.new")
	failIf(timeProblem(now), "World.new")
	return {
		plot = plot,
		plotCorner = frozenCopy(plotCorner),
		groundItems = GroundItems.new(),
		players = {},
		stations = {},
		now = now,
	}
end

--[=[
	Adds a new player to the world, with a pack that holds nothing, and
	returns their PlayerState.

	They have no character yet, so they stand nowhere. `position` is only
	where a stack of theirs would be dropped until [method setPlayerPosition]
	says where they stand.

	Raises an error if `playerId` is not a number, if a player with that id
	is already in the world, or if `position` is not a position.
]=]
function World.addPlayer(world: World, playerId: number, position: Position): PlayerState
	failIf(playerIdProblem(playerId), "World.addPlayer")
	if world.players[playerId] ~= nil then
		error(string.format("World.addPlayer: player %s is already in the world", tostring(playerId)), 2)
	end
	failIf(Position.validate(position), "World.addPlayer")
	local state = PlayerState.new()
	local players = world.players :: any
	players[playerId] = { state = state, dropPosition = frozenCopy(position) }
	return state
end

--[=[
	Takes a player out of the world. Does nothing if no player has that id.

	Their inventory screen is closed first, so a stack they were carrying is
	back in their pack, or on the ground if the pack had no room. Their
	PlayerState is no longer in the world: a caller that means to save it
	reads it from `world.players` before calling this.
]=]
function World.removePlayer(world: World, playerId: number)
	local player = world.players[playerId]
	if player == nil then
		return
	end
	closeInventoryOf(world, player)
	local players = world.players :: any
	players[playerId] = nil
end

--[=[
	Says where a player's character stands now, and where a stack they drop
	would land.

	`position` is the point on the ground under their character, or `nil` if
	they have no living character. `dropPosition` is a point on the ground a
	little in front of them, beyond `GroundItems.PICKUP_RADIUS`, so that they
	do not take straight back what they drop. If it is left out, their drops
	land where they stand. A player with no character keeps the drop
	position they had.

	Raises an error if no player has that id, or if `position` or
	`dropPosition` is given and is not a position.
]=]
function World.setPlayerPosition(world: World, playerId: number, position: Position?, dropPosition: Position?)
	local player = world.players[playerId]
	if player == nil then
		error(string.format("World.setPlayerPosition: no player in the world has the id %s", tostring(playerId)), 2)
	end
	local writable = player :: any
	if position == nil then
		writable.position = nil
		return
	end
	failIf(Position.validate(position), "World.setPlayerPosition")
	if dropPosition ~= nil then
		local problem = Position.validate(dropPosition)
		failIf(if problem ~= nil then "dropPosition: " .. problem else nil, "World.setPlayerPosition")
	end
	writable.position = frozenCopy(position)
	writable.dropPosition = frozenCopy(dropPosition or position)
end

--[=[
	Carries out the request called `name` from the machine of the player
	with the id `playerId`, if it makes sense.

	`name` and everything after it are what that machine sent, and may be
	any values at all. A request that makes no sense for the world as it is
	now is ignored, and so is one from a player who is not in the world.
	Nothing a machine sends raises an error, and no request makes or loses
	an item.

	The requests about a player's own inventories are answered as
	InventoryRequests answers them, and a stack that comes out goes on the
	ground where the player's drops land. The requests about the plot:

	| Name | Sent with | Does |
	|---|---|---|
	| `placeSelected` | x, z | places one of the item in hand on that tile |
	| `usePlaced` | id | opens the inventory of that placed item, if it has one |
	| `hitPlaced` | id | knocks that placed item off the plot, to lie on its tile as an item with what was in it spilled around it |

	Each of the three needs the player's character to stand within
	`Plot.REACH` of the tile. `placeSelected` also needs the inventory screen
	to be closed, the tile to hold nothing, the item to be one that can be
	placed, and no player to be standing on the tile. Before a placed item is
	knocked off, every player looking into it has their screen closed.
]=]
function World.answer(world: World, playerId: number, name: unknown, ...: unknown)
	local player = world.players[playerId]
	if player == nil or type(name) ~= "string" then
		return
	end
	if isInventoryRequest[name] then
		dropFor(world, player, InventoryRequests.answer(player.state, name, ...))
		if player.state.session == nil then
			(player :: any).openedPlacedId = nil
		end
	elseif name == "placeSelected" then
		placeSelected(world, player, ...)
	elseif name == "usePlaced" then
		usePlaced(world, player, (...))
	elseif name == "hitPlaced" then
		hitPlaced(world, player, (...))
	end
end

--[=[
	Moves the world on to the time `now`.

	Each player whose character stands somewhere picks up the ground items
	near them, as `GroundItems.pickUpNear` does, the player with the lowest
	id first. A player who has a placed item open has its screen closed if
	they have no character, if they stand more than `World.CLOSES_BEYOND`
	from it, or if it is no longer on the plot. Every station on the plot
	burns and works for the time that has passed since the last step, as
	`Station.step` does. Then the ground items that have lain too long are
	removed.

	Raises an error if `now` is not a number.
]=]
function World.step(world: World, now: number)
	failIf(timeProblem(now), "World.step")
	local elapsed = math.max(now - world.now, 0);
	(world :: any).now = now
	for _, playerId in sortedPlayerIds(world) do
		local player = world.players[playerId]
		local position = player.position
		if position ~= nil then
			GroundItems.pickUpNear(world.groundItems, position, player.state.pack, now)
		end
		local openedId = player.openedPlacedId
		if openedId ~= nil then
			local placedItem = world.plot.placedById[openedId]
			local isInReach = position ~= nil
				and placedItem ~= nil
				and Position.groundDistance(position, tileCenter(world, placedItem.x, placedItem.z))
					<= World.CLOSES_BEYOND
			if not isInReach then
				closeInventoryOf(world, player)
			end
		end
	end
	local placedIds = {}
	for placedId in world.plot.placedById do
		table.insert(placedIds, placedId)
	end
	table.sort(placedIds)
	for _, placedId in placedIds do
		local station = stationOf(world, placedId)
		if station ~= nil then
			Station.step(station, elapsed)
		end
	end
	GroundItems.expire(world.groundItems, now)
end

--[=[
	Returns what to tell a player's machine about what they hold, as plain
	data that can be sent as it is: their pack as `Inventory.encode` makes
	it, and their open inventory screen, or `nil` if no screen is open.

	Raises an error if no player has that id.
]=]
function World.encodeView(world: World, playerId: number): (Inventory.EncodedInventory, ScreenView?)
	local player = world.players[playerId]
	if player == nil then
		error(string.format("World.encodeView: no player in the world has the id %s", tostring(playerId)), 2)
	end
	local state = player.state
	local session = state.session
	if session == nil then
		return Inventory.encode(state.pack), nil
	end
	local openedId = player.openedPlacedId
	local placedItem = if openedId ~= nil then world.plot.placedById[openedId] else nil
	local station = if openedId ~= nil then world.stations[openedId] else nil
	return Inventory.encode(state.pack),
		{
			other = if session.other ~= nil then Inventory.encode(session.other) else nil,
			otherItemId = if placedItem ~= nil then placedItem.itemId else nil,
			carried = session.carried,
			station = if station ~= nil then Station.encodeView(station) else nil,
		}
end

return World
