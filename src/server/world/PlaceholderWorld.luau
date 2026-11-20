--!strict
--- A grey stand-in for the game's world.
---
--- `build` makes a flat plot beside the place where players appear, with a post at each corner and
--- a crate and a stove standing on it. `restockGroundItems` keeps a few stacks of items lying on
--- the plot, and `addStartingItemsToPack` gives a new player something to hold. All of it is
--- placeholder content, made by code so that the project folder alone is enough to run the game,
--- and it goes when there is a real map.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Inventory = require(Shared.inventory.Inventory)
local ItemRegistry = require(Shared.items.ItemRegistry)
local ItemStack = require(Shared.items.ItemStack)
local Plot = require(Shared.plots.Plot)
local World = require(Shared.world.World)

local PlaceholderWorld = {}

export type PlaceholderWorld = {
	--- The grey slab players walk on. The plot lies on its top.
	read slab: Part,
	--- The one plot, shared by everyone for now: what stands on which tile.
	read plot: Plot.Plot,
	--- A point on the ground where players appear.
	read spawnPoint: Vector3,
}

--- How many tiles the square plot has along each side.
PlaceholderWorld.PLOT_SIZE_IN_TILES = 18

local SLAB_HEIGHT = 0.4
local PLOT_FROM_SPAWN = 12
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

local function addGroundIfMissing(folder: Folder)
	if Workspace:FindFirstChild("Baseplate") == nil then
		local ground =
			makeBlock("Baseplate", Vector3.new(1024, 16, 1024), Vector3.new(0, -8, 0), Color3.fromRGB(91, 93, 105))
		ground.Parent = folder
	end
end

local function findOrMakeSpawnPoint(folder: Folder): Vector3
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
	return (spawnLocation :: SpawnLocation).Position
end

local function makeSlab(folder: Folder, center: Vector3, side: number): Part
	local slab = makeBlock(
		"Plot",
		Vector3.new(side, SLAB_HEIGHT, side),
		center + Vector3.new(0, SLAB_HEIGHT / 2, 0),
		Color3.fromRGB(150, 151, 156)
	)
	slab.Parent = folder
	return slab
end

local function makePosts(folder: Folder, center: Vector3, side: number)
	for _, corner in { Vector3.new(1, 0, 1), Vector3.new(1, 0, -1), Vector3.new(-1, 0, 1), Vector3.new(-1, 0, -1) } do
		local post = makeBlock(
			"Post",
			Vector3.new(1.5, 5, 1.5),
			center + corner * (side / 2 + 0.75) + Vector3.new(0, 2.5, 0),
			Color3.fromRGB(70, 71, 78)
		)
		post.Parent = folder
	end
end

local function makeStockedPlot(): Plot.Plot
	local plot = Plot.new(PlaceholderWorld.PLOT_SIZE_IN_TILES, PlaceholderWorld.PLOT_SIZE_IN_TILES)
	local crateId = Plot.placeItem(plot, "crate", 13, 7) :: number
	local inCrate = plot.placedItemsById[crateId].inventory :: Inventory.Inventory
	Inventory.addItems(inCrate, "cheese", 8)
	Inventory.addItems(inCrate, "fish", 5)
	Inventory.addItems(inCrate, "crystal", 40)
	Inventory.addItems(inCrate, "crate", 1)
	Plot.placeItem(plot, "stove", 6, 13)
	return plot
end

--- Builds the placeholder world in the Workspace and returns it. Makes a ground and a place to
--- appear only if the Workspace has none, so it works in an empty place and in Studio's baseplate
--- template. The plot lies beside the place where players appear, not under it. Call it once, after
--- the items are registered.
function PlaceholderWorld.build(): PlaceholderWorld
	local folder = Instance.new("Folder")
	folder.Name = "PlaceholderWorld"
	addGroundIfMissing(folder)
	local spawnPoint = findOrMakeSpawnPoint(folder)

	local side = PlaceholderWorld.PLOT_SIZE_IN_TILES * Plot.TILE_SIZE
	local center = Vector3.new(spawnPoint.X + side / 2 + PLOT_FROM_SPAWN, 0, spawnPoint.Z)
	local slab = makeSlab(folder, center, side)
	makePosts(folder, center, side)
	local plot = makeStockedPlot()

	folder.Parent = Workspace
	return { slab = slab, plot = plot, spawnPoint = spawnPoint }
end

--- Adds a few items to `pack`, so that a new player's hotbar is not bare.
function PlaceholderWorld.addStartingItemsToPack(pack: Inventory.Inventory)
	Inventory.addItems(pack, "apple", 4)
	Inventory.addItems(pack, "log", 20)
	Inventory.addItems(pack, "crate", 1)
end

--- Spawns a stack of a random item in the middle of a random tile of the plot, not moving. Does
--- nothing if `GROUND_ITEMS_KEPT` ground items already lie about, or if it last chose a tile less
--- than `SECONDS_BETWEEN_RESTOCKS` before the world's time. If a placed item stands on the tile it
--- chooses, it spawns nothing, and waits `SECONDS_BETWEEN_RESTOCKS` before it chooses again. Does
--- nothing while the Workspace attribute `PlaceholderRestock` is `false`, which the play test sets
--- so that it knows what lies on the ground.
function PlaceholderWorld.restockGroundItems(placeholder: PlaceholderWorld, world: World.World)
	local now = world.now
	if now < nextRestockAt or Workspace:GetAttribute("PlaceholderRestock") == false then
		return
	end
	local lying = 0
	for _ in world.groundItems.itemsById do
		lying += 1
	end
	if lying >= GROUND_ITEMS_KEPT then
		return
	end
	nextRestockAt = now + SECONDS_BETWEEN_RESTOCKS

	local plot = placeholder.plot
	local slab = placeholder.slab
	local tileX = random:NextInteger(1, plot.width)
	local tileZ = random:NextInteger(1, plot.depth)
	local corner = {
		x = slab.Position.X - slab.Size.X / 2,
		y = slab.Position.Y + slab.Size.Y / 2,
		z = slab.Position.Z - slab.Size.Z / 2,
	}
	local spot = Plot.getTileCenter(corner, tileX, tileZ)
	if not Plot.canPlaceItem(plot, "crate", tileX, tileZ) then
		return
	end

	local definitions = ItemRegistry.getAll()
	local definition = definitions[random:NextInteger(1, #definitions)]
	local count = random:NextInteger(1, definition.stackSize)
	World.spawnStack(world, ItemStack.new(definition.id, count), spot, { x = 0, y = 0, z = 0 })
end

return PlaceholderWorld
