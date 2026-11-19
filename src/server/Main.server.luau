--!strict
--[=[
	Starts the game on the server and runs it. This is the only Script.

	When the server starts it registers every item, makes the remotes, and
	builds the placeholder world. Each player who joins gets a PlayerState.

	After that it does two things:
	- It answers the requests that players' machines send, which are listed
	  in Messages. Every request is checked first, and one that makes no sense
	  is ignored.
	- Ten times a second it runs a step. Players pick up what lies near them,
	  ground items that have lain too long go, the blocks that show the ground
	  items are made to match, and each player whose inventories changed is
	  sent them.

	The rules are all in ReplicatedStorage.Shared. This script only joins them
	to Roblox: it reads where characters stand and hands the rules plain
	positions and times.
]=]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GroundItems = require(Shared.world.GroundItems)
local Hotbar = require(Shared.inventory.Hotbar)
local Inventory = require(Shared.inventory.Inventory)
local InventorySession = require(Shared.inventory.InventorySession)
local ItemDefinitions = require(Shared.items.ItemDefinitions)
local ItemRegistry = require(Shared.items.ItemRegistry)
local ItemStack = require(Shared.items.ItemStack)
local PlayerState = require(Shared.players.PlayerState)

local GroundItemParts = require(script.Parent.world.GroundItemParts)
local PlaceholderWorld = require(script.Parent.world.PlaceholderWorld)
local Remotes = require(script.Parent.Remotes)

type PlayerState = PlayerState.PlayerState
type Position = GroundItems.Position

--- How often the step runs, in seconds.
local STEP_SECONDS = 0.1

--- How far in front of a player a stack they drop lands, in studs. It is beyond
--- `GroundItems.PICKUP_RADIUS`, so a player standing still does not take it back.
local DROP_DISTANCE = 6

--- How far a player may walk from a crate they have open before its screen closes, in studs.
local CRATE_CLOSES_BEYOND = PlaceholderWorld.CRATE_REACH + 4

for _, definition in ItemDefinitions do
	ItemRegistry.register(definition)
end

local remotes = Remotes.create()
local groundItems = GroundItems.new()
local groundItemParts = GroundItemParts.new(Workspace)
local placeholder = PlaceholderWorld.build()

--- The rules' record of each player who is in the game.
local playerStates: { [Player]: PlayerState } = {}
--- Where each player last stood. A stack dropped by a player with no character lands here.
local lastPositions: { [Player]: Position } = {}
--- For each player who has a thing in the world open, such as a crate: the id of its item, and where it is.
local openedThings: { [Player]: { itemId: string, position: Vector3 } } = {}
--- The inventories last sent to each player, as text, to tell whether they have changed since.
local lastSent: { [Player]: string } = {}

local function now(): number
	return os.clock()
end

local function toPosition(point: Vector3): Position
	return { x = point.X, y = point.Y, z = point.Z }
end

-- Returns the point on the ground straight below `from`, or nil if there is none within 40 studs.
-- Characters are not ground.
local function groundBelow(from: Vector3): Vector3?
	local characters = {}
	for _, player in Players:GetPlayers() do
		if player.Character ~= nil then
			table.insert(characters, player.Character)
		end
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = characters
	local hit = Workspace:Raycast(from, Vector3.new(0, -40, 0), params)
	return if hit then hit.Position else nil
end

-- Returns the root part of a player's character if the character is alive, or nil.
local function livingRoot(player: Player): BasePart?
	local character = player.Character
	if character == nil then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if humanoid == nil or humanoid.Health <= 0 or root == nil or not root:IsA("BasePart") then
		return nil
	end
	return root
end

-- Returns the point on the ground where a player stands, or nil if they have no living character.
local function standingPosition(player: Player): Position?
	local root = livingRoot(player)
	if root == nil then
		return nil
	end
	return toPosition(groundBelow(root.Position) or root.Position - Vector3.new(0, 3, 0))
end

-- Returns where a stack dropped by a player lands: on the ground a few studs in front of them.
local function dropPosition(player: Player): Position
	local root = livingRoot(player)
	if root ~= nil then
		local ahead = root.Position + root.CFrame.LookVector * DROP_DISTANCE
		local ground = groundBelow(ahead + Vector3.new(0, 4, 0)) or groundBelow(root.Position)
		if ground ~= nil then
			return toPosition(ground)
		end
	end
	return lastPositions[player]
end

-- Puts a stack that has left a player's inventories on the ground in front of them. Does nothing given nil.
local function dropFor(player: Player, stack: ItemStack.ItemStack?)
	if stack ~= nil then
		GroundItems.drop(groundItems, stack, dropPosition(player), now())
	end
end

local function closeInventoryFor(player: Player, state: PlayerState)
	dropFor(player, PlayerState.closeInventory(state))
	openedThings[player] = nil
end

-- Sends a player their inventories, unless they are the same as were last sent.
local function sendInventory(player: Player)
	local state = playerStates[player]
	if state == nil then
		return
	end
	local pack = Inventory.encode(state.pack)
	local screen = nil
	local session = state.session
	if session ~= nil then
		local opened = openedThings[player]
		screen = {
			other = if session.other ~= nil then Inventory.encode(session.other) else nil,
			otherItemId = if opened ~= nil then opened.itemId else nil,
			carried = session.carried,
		}
	end
	local asText = HttpService:JSONEncode({ pack = pack, screen = screen })
	if asText ~= lastSent[player] then
		lastSent[player] = asText
		remotes.inventoryChanged:FireClient(player, pack, screen)
	end
end

local function isWholeNumber(value: unknown): boolean
	return type(value) == "number" and value == math.floor(value) and value ~= math.huge and value ~= -math.huge
end

-- Connects one of the players' requests to the function that answers it. The function is given the player,
-- their state, and whatever the request was sent with, which may be anything. Afterwards the player is sent
-- their inventories if the request changed them.
local function onRequest(name: string, answer: (player: Player, state: PlayerState, ...any) -> ())
	remotes[name].OnServerEvent:Connect(function(player: Player, ...: any)
		local state = playerStates[player]
		if state == nil then
			return
		end
		answer(player, state, ...)
		sendInventory(player)
	end)
end

onRequest("askForInventory", function(player)
	lastSent[player] = nil
end)

onRequest("openPack", function(_, state)
	if state.session == nil then
		PlayerState.openInventory(state)
	end
end)

onRequest("closeInventory", function(player, state)
	closeInventoryFor(player, state)
end)

onRequest("clickSlot", function(_, state, side, slot, button)
	local session = state.session
	if session == nil or not InventorySession.hasSlot(session, side, slot) then
		return
	end
	if button == "left" or button == "right" then
		InventorySession.click(session, side, slot, button)
	end
end)

onRequest("quickMoveSlot", function(_, state, side, slot)
	local session = state.session
	if session ~= nil and InventorySession.hasSlot(session, side, slot) then
		InventorySession.quickMove(session, side, slot)
	end
end)

onRequest("dropCarried", function(player, state, count)
	local session = state.session
	if session == nil then
		return
	end
	if count == nil or (isWholeNumber(count) and count >= 0) then
		dropFor(player, InventorySession.drop(session, count))
	end
end)

onRequest("selectHotbarSlot", function(_, state, slot)
	if isWholeNumber(slot) and slot >= 1 and slot <= state.hotbar.slotCount then
		Hotbar.select(state.hotbar, slot)
	end
end)

onRequest("dropSelected", function(player, state)
	if state.session == nil then
		dropFor(player, Inventory.takeFromSlot(state.pack, state.hotbar.selectedSlot, 1))
	end
end)

placeholder.crateClicks.MouseClick:Connect(function(player: Player)
	local state = playerStates[player]
	if state == nil or livingRoot(player) == nil then
		return
	end
	closeInventoryFor(player, state)
	PlayerState.openInventory(state, placeholder.crateInventory)
	openedThings[player] = { itemId = "crate", position = placeholder.cratePart.Position }
	sendInventory(player)
end)

local function addPlayer(player: Player)
	local state = PlayerState.new()
	PlaceholderWorld.fillPack(state.pack)
	playerStates[player] = state
	lastPositions[player] = toPosition(placeholder.spawnPoint)
end

local function removePlayer(player: Player)
	playerStates[player] = nil
	lastPositions[player] = nil
	openedThings[player] = nil
	lastSent[player] = nil
end

Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removePlayer)
for _, player in Players:GetPlayers() do
	addPlayer(player)
end

local function step()
	local stepTime = now()
	for player, state in playerStates do
		local position = standingPosition(player)
		if position ~= nil then
			lastPositions[player] = position
			GroundItems.pickUpNear(groundItems, position, state.pack, stepTime)
		end
		local opened = openedThings[player]
		if opened ~= nil then
			local root = livingRoot(player)
			if root == nil or (root.Position - opened.position).Magnitude > CRATE_CLOSES_BEYOND then
				closeInventoryFor(player, state)
			end
		end
	end
	GroundItems.expire(groundItems, stepTime)
	PlaceholderWorld.restock(placeholder, groundItems, stepTime)
	GroundItemParts.update(groundItemParts, groundItems)
	for player in playerStates do
		sendInventory(player)
	end
end

local sinceStep = 0
RunService.Heartbeat:Connect(function(deltaTime: number)
	sinceStep += deltaTime
	if sinceStep >= STEP_SECONDS then
		sinceStep = 0
		step()
	end
end)
