--!strict
--- A grey stand-in for a map: a plot with some placed objects and ground items on it.
---
--- `build` makes a slab with a post at each corner and a plot on it, beside the place where
--- players appear. `placeStartingObjects` stands a crate and a stove on the plot,
--- `restockGroundItems` keeps a few ground items lying on it, and `addStartingItemsToPack` adds
--- items to a pack. Code makes all of it.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Crate = require(Shared.content.Crate)
local Inventory = require(Shared.inventory.Inventory)
local ItemRegistry = require(Shared.items.ItemRegistry)
local ItemStack = require(Shared.items.ItemStack)
local Plot = require(Shared.plots.Plot)
local Stove = require(Shared.content.Stove)
local World = require(Shared.world.World)

local PlaceholderWorld = {}

--- What `build` made: the slab, the plot, and the spawn point.
export type PlaceholderWorld = {
	--- The grey slab that the plot lies on. The plot lies on its top.
	read slab: Part,
	--- The plot that lies on the slab, shared by every player.
	read plot: Plot.Plot,
	--- The position of the SpawnLocation where players appear.
	read spawnPoint: Vector3,
}

--- The plot's width and its depth, in tiles.
PlaceholderWorld.PLOT_SIZE_IN_TILES = 18

--- The slab's thickness, in studs.
local SLAB_HEIGHT = 0.4
--- How far the slab's edge of least x is from the spawn point, along x, in studs.
local PLOT_FROM_SPAWN = 12
--- How many ground items `restockGroundItems` keeps lying about: it spawns none once this many lie.
local GROUND_ITEMS_KEPT = 10
--- The time after `restockGroundItems` chooses a tile before it chooses again, in seconds.
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

--- Builds a slab, a post at each corner of it, and a new plot, and returns the slab, the plot, and
--- the spawn point. Puts the slab and the posts in a Folder called `PlaceholderWorld` in the
--- Workspace. Makes a part called `Baseplate` in the Folder unless the Workspace has a child of
--- that name, and a SpawnLocation in the Folder unless the Workspace has one. The plot lies beside
--- the spawn point, not under it.
function PlaceholderWorld.build(): PlaceholderWorld
	local folder = Instance.new("Folder")
	folder.Name = "PlaceholderWorld"
	addGroundIfMissing(folder)
	local spawnPoint = findOrMakeSpawnPoint(folder)

	local side = PlaceholderWorld.PLOT_SIZE_IN_TILES * Plot.TILE_SIZE
	local center = Vector3.new(spawnPoint.X + side / 2 + PLOT_FROM_SPAWN, 0, spawnPoint.Z)
	local slab = makeSlab(folder, center, side)
	makePosts(folder, center, side)
	local plot = Plot.new(PlaceholderWorld.PLOT_SIZE_IN_TILES, PlaceholderWorld.PLOT_SIZE_IN_TILES)

	folder.Parent = Workspace
	return { slab = slab, plot = plot, spawnPoint = spawnPoint }
end

--- Stands a crate on the tile x `13`, z `7` of `world.plot`, with eight `"cheese"`, five `"fish"`,
--- 40 `"crystal"`, and one `"crate"` in it, and a stove on the tile x `6`, z `13`. Fails if
--- `Plot.placeObject` fails for either tile.
function PlaceholderWorld.placeStartingObjects(world: World.World)
	local crateId = Crate.place(world.plot, 13, 7)
	local inCrate = Crate.get(world.plot, crateId).inventory
	Inventory.addItems(inCrate, "cheese", 8)
	Inventory.addItems(inCrate, "fish", 5)
	Inventory.addItems(inCrate, "crystal", 40)
	Inventory.addItems(inCrate, "crate", 1)
	Stove.place(world.plot, 6, 13)
end

--- Adds four `"apple"`, 20 `"log"`, and one `"crate"` to `pack`.
function PlaceholderWorld.addStartingItemsToPack(pack: Inventory.Inventory)
	Inventory.addItems(pack, "apple", 4)
	Inventory.addItems(pack, "log", 20)
	Inventory.addItems(pack, "crate", 1)
end

--- Chooses a random tile of the plot, and spawns on it a stack of a random item, with a random
--- count from `1` to the item's stack size, at the tile's middle and not moving. Does nothing if
--- the Workspace attribute `PlaceholderRestock` is `false`, if `world.now` is less than
--- `SECONDS_BETWEEN_RESTOCKS` after the last time it chose a tile, or if `GROUND_ITEMS_KEPT` ground
--- items lie about already. If a placed object stands on the chosen tile, it spawns nothing.
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
	local tileX = random:NextInteger(1, plot.widthInTiles)
	local tileZ = random:NextInteger(1, plot.depthInTiles)
	local corner = {
		x = slab.Position.X - slab.Size.X / 2,
		y = slab.Position.Y + slab.Size.Y / 2,
		z = slab.Position.Z - slab.Size.Z / 2,
	}
	local spot = Plot.getTileCenter(corner, tileX, tileZ)
	if Plot.isTileTaken(plot, tileX, tileZ) then
		return
	end

	local definitions = ItemRegistry.getAll()
	local definition = definitions[random:NextInteger(1, #definitions)]
	local count = random:NextInteger(1, definition.stackSize)
	World.spawnStack(world, ItemStack.new(definition.id, count), spot, { x = 0, y = 0, z = 0 })
end

return PlaceholderWorld
