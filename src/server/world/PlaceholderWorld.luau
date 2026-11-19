--!strict
--[=[
	A grey stand-in for the world, to build and test the game's machinery on:
	a flat plot beside the place where players appear, with a post at each
	corner, a crate and a stove standing on it, and items that keep turning
	up on the ground.

	None of this is the game's world. It is made by code so that the project
	folder alone is enough to run the game, and it goes when there is a real
	map. What it puts in the crate, on the ground and in a new player's pack
	is there so that a tester has something to move about.

	```lua
	local placeholder = PlaceholderWorld.build()
	placeholder.plot -- the plot's rules: a crate with things in it, and a stove
	placeholder.slab -- the part the plot lies on
	PlaceholderWorld.restock(placeholder, groundItems, now) -- call often; it drops something now and then
	```
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GroundItems = require(Shared.world.GroundItems)
local Inventory = require(Shared.inventory.Inventory)
local ItemRegistry = require(Shared.items.ItemRegistry)
local ItemStack = require(Shared.items.ItemStack)
local Plot = require(Shared.plots.Plot)

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
PlaceholderWorld.PLOT_TILES = 18

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

	-- The plot lies beside the place where players appear, not under it, so that nothing placed on
	-- the plot can be where a player is about to appear.
	local side = PlaceholderWorld.PLOT_TILES * Plot.TILE_SIZE
	local center = Vector3.new(spawnPoint.X + side / 2 + PLOT_FROM_SPAWN, 0, spawnPoint.Z)
	local slab = makeBlock(
		"Plot",
		Vector3.new(side, SLAB_HEIGHT, side),
		center + Vector3.new(0, SLAB_HEIGHT / 2, 0),
		Color3.fromRGB(150, 151, 156)
	)
	slab.Parent = folder
	for _, corner in { Vector3.new(1, 0, 1), Vector3.new(1, 0, -1), Vector3.new(-1, 0, 1), Vector3.new(-1, 0, -1) } do
		local post = makeBlock(
			"Post",
			Vector3.new(1.5, 5, 1.5),
			center + corner * (side / 2 + 0.75) + Vector3.new(0, 2.5, 0),
			Color3.fromRGB(70, 71, 78)
		)
		post.Parent = folder
	end

	local plot = Plot.new(PlaceholderWorld.PLOT_TILES, PlaceholderWorld.PLOT_TILES)
	local crateId = Plot.place(plot, "crate", 13, 7) :: number
	local inCrate = plot.placedById[crateId].inventory :: Inventory.Inventory
	Inventory.addItems(inCrate, "cheese", 8)
	Inventory.addItems(inCrate, "fish", 5)
	Inventory.addItems(inCrate, "crystal", 40)
	Inventory.addItems(inCrate, "crate", 1)
	Plot.place(plot, "stove", 6, 13)

	folder.Parent = Workspace
	return { slab = slab, plot = plot, spawnPoint = spawnPoint }
end

--[=[
	Puts a few things in a new player's pack, so that their hotbar is not bare.
]=]
function PlaceholderWorld.fillPack(pack: Inventory.Inventory)
	Inventory.addItems(pack, "apple", 4)
	Inventory.addItems(pack, "log", 20)
	Inventory.addItems(pack, "crate", 1)
end

--[=[
	Drops a stack of some item on a random tile of the plot, if fewer than a
	handful of ground items lie about and one was not dropped a moment ago.
	Call it often: it keeps the plot stocked however long the game runs.
]=]
function PlaceholderWorld.restock(placeholder: PlaceholderWorld, groundItems: GroundItems.GroundItems, now: number)
	-- The play test in tools/playtest.py switches this off, so that it knows exactly what lies on the ground.
	if now < nextRestockAt or Workspace:GetAttribute("PlaceholderRestock") == false then
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

	local plot = placeholder.plot
	local slab = placeholder.slab
	local tileX = random:NextInteger(1, plot.width)
	local tileZ = random:NextInteger(1, plot.depth)
	local corner = {
		x = slab.Position.X - slab.Size.X / 2,
		y = slab.Position.Y + slab.Size.Y / 2,
		z = slab.Position.Z - slab.Size.Z / 2,
	}
	local spot = Plot.tileCenter(corner, tileX, tileZ)
	-- Nothing lands on a tile that something stands on: a tile a crate could go on is a tile that
	-- holds nothing. A tile that will not do is skipped until the next time.
	if not Plot.canPlace(plot, "crate", tileX, tileZ) then
		return
	end

	local definitions = ItemRegistry.all()
	local definition = definitions[random:NextInteger(1, #definitions)]
	local count = random:NextInteger(1, definition.stackSize)
	GroundItems.drop(groundItems, ItemStack.new(definition.id, count), spot, now)
end

return PlaceholderWorld
