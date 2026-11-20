--!strict
--- Starts the game on the server and runs it. This is the only Script.
---
--- The rules are in ReplicatedStorage.Shared, and one World holds the whole game. This script
--- tells the World what happens: a player joins or leaves, where each character stands, what a
--- player's machine asks for, and that time has passed. Then it draws the World, and tells each
--- player's machine what that player holds.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ItemDefinitions = require(Shared.items.ItemDefinitions)
local ItemRegistry = require(Shared.items.ItemRegistry)
local PlayerSnapshot = require(Shared.world.PlayerSnapshot)
local Position = require(Shared.Position)
local RecipeDefinitions = require(Shared.stations.RecipeDefinitions)
local RecipeRegistry = require(Shared.stations.RecipeRegistry)
local Requests = require(Shared.requests.Requests)
local World = require(Shared.world.World)

local GroundItemParts = require(script.Parent.world.GroundItemParts)
local PlaceholderWorld = require(script.Parent.world.PlaceholderWorld)
local PlotParts = require(script.Parent.world.PlotParts)
local Remotes = require(script.Parent.Remotes)

--- How long the server waits between advancing the World, in seconds.
local SECONDS_BETWEEN_ADVANCES = 0.1

--- How many requests one player's machine may make in a second. The rest of that second's are
--- ignored. A person clicking as fast as they can makes far fewer.
local REQUESTS_PER_SECOND = 60

--- How far in front of a player a stack they drop lands, in studs. It is farther than
--- `GroundItems.PICKUP_RADIUS`, so that a player standing still does not pick it straight back up.
local DROP_DISTANCE = 6

for _, definition in ItemDefinitions do
	ItemRegistry.register(definition)
end
for _, recipe in RecipeDefinitions do
	RecipeRegistry.register(recipe)
end

local remotes = Remotes.create()
local placeholder = PlaceholderWorld.build()
local plotParts = PlotParts.new(placeholder.slab, placeholder.plot)
local groundItemParts = GroundItemParts.new(Workspace)
local world = World.new(placeholder.plot, plotParts.corner, os.clock())

--- What each player's machine was last told, as text, to tell whether it has changed since.
local lastSent: { [Player]: string } = {}
--- How many requests each player's machine has made in the second now passing.
local requestsThisSecond: { [Player]: number } = {}
--- Whether anything has happened since the players were last shown the World.
local needsShow = false

local function toPosition(point: Vector3): Position.Position
	return { x = point.X, y = point.Y, z = point.Z }
end

local function groundBelow(from: Vector3): Vector3?
	local characters = {}
	for _, player in Players:GetPlayers() do
		table.insert(characters, player.Character)
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = characters
	local hit = Workspace:Raycast(from, Vector3.new(0, -40, 0), params)
	return if hit then hit.Position else nil
end

local function livingRoot(player: Player): BasePart?
	local character = player.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	local isAlive = humanoid ~= nil and humanoid.Health > 0
	return if isAlive and root ~= nil and root:IsA("BasePart") then root else nil
end

local function isFinitePoint(point: Vector3): boolean
	return point == point and point.Magnitude < math.huge
end

local function tellPosition(player: Player)
	local root = livingRoot(player)
	if root == nil or not isFinitePoint(root.Position) then
		World.setPlayerPosition(world, player.UserId, nil)
		return
	end
	local standing = groundBelow(root.Position) or root.Position - Vector3.new(0, 3, 0)
	local ahead = root.Position + root.CFrame.LookVector * DROP_DISTANCE
	local dropSpot = groundBelow(ahead + Vector3.new(0, 4, 0)) or standing
	World.setPlayerPosition(world, player.UserId, toPosition(standing), toPosition(dropSpot))
end

local function try(doing: string, callback: (...any) -> ...any, ...: any)
	local ok, problem = pcall(callback, ...)
	if not ok then
		warn(`An error while {doing}: {problem}`)
	end
end

local function sendSnapshotIfChanged(player: Player)
	local snapshot = PlayerSnapshot.encode(world, player.UserId)
	local asText = HttpService:JSONEncode(snapshot)
	if asText ~= lastSent[player] then
		lastSent[player] = asText
		remotes.snapshotChanged:FireClient(player, snapshot, world.now)
	end
end

local function showWorldToPlayers()
	needsShow = false
	GroundItemParts.update(groundItemParts, world.groundItems)
	PlotParts.update(plotParts, world.plot, world.stations)
	for _, player in Players:GetPlayers() do
		if world.players[player.UserId] ~= nil then
			try("telling a player what they hold", sendSnapshotIfChanged, player)
		end
	end
end

local function countRequest(player: Player): boolean
	if world.players[player.UserId] == nil then
		return false
	end
	local made = (requestsThisSecond[player] or 0) + 1
	requestsThisSecond[player] = made
	return made <= REQUESTS_PER_SECOND
end

for _, name in Requests.NAMES do
	remotes[name].OnServerEvent:Connect(function(player: Player, ...: any)
		if countRequest(player) then
			tellPosition(player)
			Requests.carryOut(world, player.UserId, name, ...)
			needsShow = true
		end
	end)
end

remotes.askForSnapshot.OnServerEvent:Connect(function(player: Player)
	if countRequest(player) then
		lastSent[player] = nil
		needsShow = true
	end
end)

local function addPlayer(player: Player)
	if world.players[player.UserId] == nil then
		local state = World.addPlayer(world, player.UserId, toPosition(placeholder.spawnPoint))
		PlaceholderWorld.addStartingItemsToPack(state.pack)
	end
end

local function removePlayer(player: Player)
	World.removePlayer(world, player.UserId)
	lastSent[player] = nil
	requestsThisSecond[player] = nil
end

Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removePlayer)
for _, player in Players:GetPlayers() do
	addPlayer(player)
end

local function advanceWorld()
	for _, player in Players:GetPlayers() do
		if world.players[player.UserId] ~= nil then
			try("reading where a player stands", tellPosition, player)
		end
	end
	try("advancing the World", World.advanceTo, world, os.clock())
	try("restocking the plot", PlaceholderWorld.restockGroundItems, placeholder, world.groundItems, world.now)
	showWorldToPlayers()
end

local sinceAdvance = 0
local sinceCountsCleared = 0
RunService.Heartbeat:Connect(function(deltaTime: number)
	sinceCountsCleared += deltaTime
	if sinceCountsCleared >= 1 then
		sinceCountsCleared = 0
		table.clear(requestsThisSecond)
	end
	sinceAdvance += deltaTime
	if sinceAdvance >= SECONDS_BETWEEN_ADVANCES then
		sinceAdvance = 0
		advanceWorld()
	elseif needsShow then
		showWorldToPlayers()
	end
end)
