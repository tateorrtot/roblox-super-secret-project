--!strict
--[=[
	A grey stand-in for the world, to build and test the game's machinery on:
	a flat plot with a post at each corner, one crate with a few things in it,
	and items that keep turning up on the ground.

	None of this is the game's world. It is made by code so that the project
	folder alone is enough to run the game, and it goes when there is a real
	map. What it puts in the crate, on the ground and in a new player's pack
	is there so that a tester has something to move about.

	```lua
	local placeholder = PlaceholderWorld.build()
	placeholder.crateClicks.MouseClick:Connect(function(player) end) -- a player used the crate
	PlaceholderWorld.restock(placeholder, groundItems, now) -- call often; it drops something now and then
	```
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GroundItems = require(Shared.world.GroundItems)
local Inventory = require(Shared.inventory.Inventory)
local ItemLooks = require(Shared.items.ItemLooks)
local ItemRegistry = require(Shared.items.ItemRegistry)
local ItemStack = require(Shared.items.ItemStack)

local PlaceholderWorld = {}

export type PlaceholderWorld = {
	--- The grey slab players walk on.
	read plot: Part,
	--- The crate in the world.
	read cratePart: Part,
	--- What is in the crate.
	read crateInventory: Inventory.Inventory,
	--- Fires `MouseClick` with the player when a player clicks or taps the crate from near enough.
	read crateClicks: ClickDetector,
	--- A point on the ground where players appear.
	read spawnPoint: Vector3,
}

--- How long the side of the square plot is, in studs.
PlaceholderWorld.PLOT_SIDE = 72

--- How near a player must be to the crate to open it, in studs.
PlaceholderWorld.CRATE_REACH = 14

local PLOT_HEIGHT = 0.4
local GROUND_ITEMS_KEPT = 10
local SECONDS_BETWEEN_RESTOCKS = 4

local random = Random.new()
local nextRestockAt = 0

local function makeBlock(name: string, size: Vector3, position: Vector3, color: Color3): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

local function makeLabel(text: string, studsAbove: number): BillboardGui
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(240, 28)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, studsAbove, 0)
	billboard.MaxDistance = 80
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.2
	label.Text = text
	label.Parent = billboard
	return billboard
end

--[=[
	Builds the placeholder world in the Workspace and returns it.

	Makes a ground to stand on and a place to appear only if the Workspace
	has none, so it works both in an empty place and in Studio's baseplate
	template. Call it once, after the items are registered.
]=]
function PlaceholderWorld.build(): PlaceholderWorld
	local folder = Instance.new("Folder")
	folder.Name = "PlaceholderWorld"

	if Workspace:FindFirstChild("Baseplate") == nil then
		local ground =
			makeBlock("Baseplate", Vector3.new(1024, 16, 1024), Vector3.new(0, -8, 0), Color3.fromRGB(91, 93, 105))
		ground.Parent = folder
	end

	local spawnLocation = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	if spawnLocation == nil then
		local newSpawn = Instance.new("SpawnLocation")
		newSpawn.Name = "SpawnLocation"
		newSpawn.Anchored = true
		newSpawn.Size = Vector3.new(12, 1, 12)
		newSpawn.Position = Vector3.new(0, 0.5, 0)
		newSpawn.Parent = folder
		spawnLocation = newSpawn
	end
	local spawnPoint = (spawnLocation :: SpawnLocation).Position

	local side = PlaceholderWorld.PLOT_SIDE
	local center = Vector3.new(spawnPoint.X, 0, spawnPoint.Z)
	local plot = makeBlock(
		"Plot",
		Vector3.new(side, PLOT_HEIGHT, side),
		center + Vector3.new(0, PLOT_HEIGHT / 2, 0),
		Color3.fromRGB(150, 151, 156)
	)
	plot.Parent = folder
	for _, corner in { Vector3.new(1, 0, 1), Vector3.new(1, 0, -1), Vector3.new(-1, 0, 1), Vector3.new(-1, 0, -1) } do
		local post = makeBlock(
			"Post",
			Vector3.new(1.5, 5, 1.5),
			center + corner * (side / 2 - 0.75) + Vector3.new(0, PLOT_HEIGHT + 2.5, 0),
			Color3.fromRGB(70, 71, 78)
		)
		post.Parent = folder
	end

	local crateColor = ItemLooks.crate.color
	local cratePart = makeBlock(
		"Crate",
		Vector3.new(4, 4, 4),
		center + Vector3.new(12, PLOT_HEIGHT + 2, -10),
		Color3.fromRGB(crateColor[1], crateColor[2], crateColor[3])
	)
	makeLabel(ItemLooks.crate.name .. " (click to open)", 3.4).Parent = cratePart
	local crateClicks = Instance.new("ClickDetector")
	crateClicks.MaxActivationDistance = PlaceholderWorld.CRATE_REACH
	crateClicks.Parent = cratePart
	cratePart.Parent = folder

	local crateInventory = Inventory.new(27)
	Inventory.addItems(crateInventory, "cheese", 8)
	Inventory.addItems(crateInventory, "fish", 5)
	Inventory.addItems(crateInventory, "crystal", 40)
	Inventory.addItems(crateInventory, "stove", 1)

	folder.Parent = Workspace
	return {
		plot = plot,
		cratePart = cratePart,
		crateInventory = crateInventory,
		crateClicks = crateClicks,
		spawnPoint = spawnPoint,
	}
end

--[=[
	Puts a few things in a new player's pack, so that their hotbar is not bare.
]=]
function PlaceholderWorld.fillPack(pack: Inventory.Inventory)
	Inventory.addItems(pack, "apple", 4)
	Inventory.addItems(pack, "log", 20)
end

--[=[
	Drops a stack of some item at a random spot on the plot, if fewer than a
	handful of ground items lie about and one was not dropped a moment ago.
	Call it often: it keeps the plot stocked however long the game runs.
]=]
function PlaceholderWorld.restock(placeholder: PlaceholderWorld, groundItems: GroundItems.GroundItems, now: number)
	if now < nextRestockAt then
		return
	end
	local lying = 0
	for _ in groundItems.byId do
		lying += 1
	end
	if lying >= GROUND_ITEMS_KEPT then
		return
	end
	nextRestockAt = now + SECONDS_BETWEEN_RESTOCKS

	local definitions = ItemRegistry.all()
	local definition = definitions[random:NextInteger(1, #definitions)]
	local count = random:NextInteger(1, definition.stackSize)
	local reach = PlaceholderWorld.PLOT_SIDE / 2 - 4
	local plot = placeholder.plot
	local spot = Vector3.new(
		plot.Position.X + random:NextNumber(-reach, reach),
		plot.Position.Y + plot.Size.Y / 2,
		plot.Position.Z + random:NextNumber(-reach, reach)
	)
	-- Nothing lands on the crate or where players appear. A spot that would is skipped until the next time.
	for _, keepClear in { placeholder.cratePart.Position, placeholder.spawnPoint } do
		if (Vector3.new(spot.X, 0, spot.Z) - Vector3.new(keepClear.X, 0, keepClear.Z)).Magnitude < 9 then
			return
		end
	end
	GroundItems.drop(groundItems, ItemStack.new(definition.id, count), { x = spot.X, y = spot.Y, z = spot.Z }, now)
end

return PlaceholderWorld
