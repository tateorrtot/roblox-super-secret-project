--!strict
--[=[
	Starts the game on the server and runs it. This is the only Script.

	The game's rules are in ReplicatedStorage.Shared, and one World holds the
	whole game. This script has no rules of its own. It does four things:
	- When the server starts, it registers every item and recipe, makes the
	  remotes, builds the placeholder world and makes the World.
	- It tells the World what happens: a player joins or leaves, where each
	  character stands, a request arrives from a player's machine, and, ten
	  times a second, that time has passed.
	- It draws the World: the blocks that show the ground items and the
	  placed items.
	- It tells each player's machine what that player holds, whenever that
	  has changed.

	Reading where a character stands is the one thing here that the rules
	cannot do, because it means asking Roblox. The World is told the point
	on the ground under each character, and the point a little in front of
	them where a stack they drop would land.
]=]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ItemDefinitions = require(Shared.items.ItemDefinitions)
local ItemRegistry = require(Shared.items.ItemRegistry)
local Position = require(Shared.world.Position)
local RecipeDefinitions = require(Shared.stations.RecipeDefinitions)
local RecipeRegistry = require(Shared.stations.RecipeRegistry)
local World = require(Shared.world.World)

local GroundItemParts = require(script.Parent.world.GroundItemParts)
local PlaceholderWorld = require(script.Parent.world.PlaceholderWorld)
local PlotParts = require(script.Parent.world.PlotParts)
local Remotes = require(script.Parent.Remotes)

--- How often the World is stepped, in seconds.
local STEP_SECONDS = 0.1

--- How far in front of a player a stack they drop lands, in studs. It is beyond
--- `GroundItems.PICKUP_RADIUS`, so a player standing still does not take it back.
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

--- What each player's machine was last told they hold, as text, to tell whether it has changed since.
local lastSent: { [Player]: string } = {}

local function toPosition(point: Vector3): Position.Position
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

-- Tells the World where a player's character stands now, and where a stack they drop would land.
local function tellPosition(player: Player)
	local root = livingRoot(player)
	if root == nil then
		World.setPlayerPosition(world, player.UserId, nil)
		return
	end
	local standing = groundBelow(root.Position) or root.Position - Vector3.new(0, 3, 0)
	local ahead = root.Position + root.CFrame.LookVector * DROP_DISTANCE
	local dropSpot = groundBelow(ahead + Vector3.new(0, 4, 0)) or standing
	World.setPlayerPosition(world, player.UserId, toPosition(standing), toPosition(dropSpot))
end

-- Tells a player's machine what the player holds, unless it is the same as it was last told.
local function sendInventory(player: Player)
	local pack, screen = World.encodeView(world, player.UserId)
	local asText = HttpService:JSONEncode({ pack = pack, screen = screen })
	if asText ~= lastSent[player] then
		lastSent[player] = asText
		remotes.inventoryChanged:FireClient(player, pack, screen)
	end
end

-- Makes what the players see match the World: the blocks in the world, and what each machine has been told.
local function show()
	GroundItemParts.update(groundItemParts, world.groundItems)
	PlotParts.update(plotParts, world.plot, world.stations)
	for _, player in Players:GetPlayers() do
		if world.players[player.UserId] ~= nil then
			sendInventory(player)
		end
	end
end

-- Every request the World answers is handed to it as it came, with the player's position brought up
-- to date first. The World checks the request; what a machine sends is not trusted here either.
for _, name in World.REQUEST_NAMES do
	remotes[name].OnServerEvent:Connect(function(player: Player, ...: any)
		if world.players[player.UserId] == nil then
			return
		end
		tellPosition(player)
		World.answer(world, player.UserId, name, ...)
		show()
	end)
end

remotes.askForInventory.OnServerEvent:Connect(function(player: Player)
	lastSent[player] = nil
	if world.players[player.UserId] ~= nil then
		sendInventory(player)
	end
end)

local function addPlayer(player: Player)
	if world.players[player.UserId] ~= nil then
		return
	end
	local state = World.addPlayer(world, player.UserId, toPosition(placeholder.spawnPoint))
	PlaceholderWorld.fillPack(state.pack)
end

local function removePlayer(player: Player)
	World.removePlayer(world, player.UserId)
	lastSent[player] = nil
end

Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removePlayer)
for _, player in Players:GetPlayers() do
	addPlayer(player)
end

local function step()
	for _, player in Players:GetPlayers() do
		if world.players[player.UserId] ~= nil then
			tellPosition(player)
		end
	end
	World.step(world, os.clock())
	PlaceholderWorld.restock(placeholder, world.groundItems, world.now)
	show()
end

local sinceStep = 0
RunService.Heartbeat:Connect(function(deltaTime: number)
	sinceStep += deltaTime
	if sinceStep >= STEP_SECONDS then
		sinceStep = 0
		step()
	end
end)
