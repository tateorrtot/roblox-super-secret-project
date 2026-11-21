--!strict
--- Starts the game on the server and runs it. This is the only Script.
---
--- The rules are in ReplicatedStorage.Shared, and one World holds the whole game. This script
--- tells the World what happens: a player joins or leaves, where each character is, where
--- Roblox's physics has carried each ground item, what a player's machine asks for, and that time
--- has passed. When time passes in the World, the script of each placed object is told. Then
--- this script draws the World, and tells each player's machine what that player holds.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Content = require(Shared.content.Content)
local Crate = require(Shared.content.Crate)
local PlacedObjectScripts = require(Shared.requests.PlacedObjectScripts)
local PlayerSnapshot = require(Shared.requests.PlayerSnapshot)
local Position = require(Shared.Position)
local Requests = require(Shared.requests.Requests)
local Signal = require(Shared.Signal)
local Stove = require(Shared.content.Stove)
local World = require(Shared.world.World)

local CollisionGroups = require(script.Parent.world.CollisionGroups)
local CrateModel = require(script.Parent.content.CrateModel)
local GroundItemParts = require(script.Parent.world.GroundItemParts)
local PlaceholderWorld = require(script.Parent.world.PlaceholderWorld)
local PlotParts = require(script.Parent.world.PlotParts)
local Remotes = require(script.Parent.Remotes)
local StoveModel = require(script.Parent.content.StoveModel)

--- How long the server waits between advancing the World, in seconds.
local SECONDS_BETWEEN_ADVANCES = 0.1

--- How many requests one player's machine may make in a second. The rest of that second's are
--- ignored. A person clicking as fast as they can makes far fewer.
local REQUESTS_PER_SECOND = 60

--- How far below the bottom of its root part an R6 character's feet are, in studs. An R15
--- character's `HipHeight` says this already, and an R6 character's `HipHeight` is 0.
local R6_LEG_LENGTH = 2

--- The piece that says how each kind of placed object is shown in the world, by the kind's id.
local placedObjectPieces: { [string]: PlotParts.PlacedObjectPiece } = {
	[Crate.PLACED_OBJECT_KIND_ID] = CrateModel,
	[Stove.PLACED_OBJECT_KIND_ID] = StoveModel,
}

Content.register()

CollisionGroups.register()
local remotes = Remotes.create()
local placeholder = PlaceholderWorld.build()
local plotParts = PlotParts.new(placeholder.slab, placeholder.plot)
local groundItemParts = GroundItemParts.new(Workspace)
local world = World.new(placeholder.plot, plotParts.corner, os.clock())
Signal.connect(world.timePassed, function(seconds: number)
	PlacedObjectScripts.advancePlacedObjects(world, seconds)
end)
PlaceholderWorld.placeStartingObjects(world)

--- What each player's machine was last told, as text, to tell whether it has changed since.
local lastSent: { [Player]: string } = {}
--- How many requests each player's machine has made in the second now passing.
local requestsThisSecond: { [Player]: number } = {}
--- Whether anything has happened since the players were last shown the World.
local needsShow = false

local function toPosition(point: Vector3): Position.Position
	return { x = point.X, y = point.Y, z = point.Z }
end

local function getLivingCharacter(player: Player): (BasePart?, Humanoid?)
	local character = player.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if humanoid ~= nil and humanoid.Health > 0 and root ~= nil and root:IsA("BasePart") then
		return root, humanoid
	end
	return nil, nil
end

local function getFeet(root: BasePart, humanoid: Humanoid): Vector3
	local legs = if humanoid.RigType == Enum.HumanoidRigType.R6 then R6_LEG_LENGTH else 0
	return root.Position - Vector3.new(0, root.Size.Y / 2 + humanoid.HipHeight + legs, 0)
end

local function isFinitePoint(point: Vector3): boolean
	return point == point and point.Magnitude < math.huge
end

local function tellCharacter(player: Player)
	local root, humanoid = getLivingCharacter(player)
	if root == nil or humanoid == nil or not isFinitePoint(root.Position) then
		World.removeCharacter(world, player.UserId)
		return
	end
	World.setCharacterPosition(world, player.UserId, toPosition(getFeet(root, humanoid)))
end

local function tellGroundItemPositions()
	for id, position in GroundItemParts.getMovedPositions(groundItemParts, world.groundItems) do
		World.setGroundItemPosition(world, id, position)
	end
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
		remotes.snapshotChanged:FireClient(player, snapshot, os.clock())
	end
end

local function showWorldToPlayers()
	needsShow = false
	PlotParts.update(plotParts, world.plot, placedObjectPieces)
	GroundItemParts.update(groundItemParts, world.groundItems)
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
			tellCharacter(player)
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
	if world.players[player.UserId] ~= nil then
		return
	end
	local state = World.addPlayer(world, player.UserId)
	PlaceholderWorld.addStartingItemsToPack(state.pack)
	player.CharacterAdded:Connect(CollisionGroups.addCharacter)
	if player.Character ~= nil then
		CollisionGroups.addCharacter(player.Character)
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
			try("reading where a player's character is", tellCharacter, player)
		end
	end
	try("reading where the ground items are", tellGroundItemPositions)
	try("advancing the World", World.advanceTo, world, os.clock())
	try("restocking the plot", PlaceholderWorld.restockGroundItems, placeholder, world)
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
