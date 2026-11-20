--!strict
--- Blocks that show a plot in the world.
---
--- Draws thin lines on the plot's slab to mark the tiles, and one block a tile wide for each
--- object standing on the plot, in the colour of its kind and with the kind's name above it.
--- `update` makes the blocks match what is placed: a new block for each newly placed object and
--- none for one that was removed. The slab is tagged `Plot` and has the attributes `widthInTiles`
--- and `depthInTiles`, and `cornerX`, `cornerY` and `cornerZ`, the plot's corner as
--- `Plot.getTileAt` wants it. Each block has the attribute `placedObjectId`, the id of its placed
--- object, and the attribute `burning`, which is `true` while the block is a station whose fire is
--- burning. The blocks are placeholders until placed objects have models, and the plot must lie
--- square to the world's x and z axes.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlacedObjectLooks = require(Shared.content.PlacedObjectLooks)
local Plot = require(Shared.plots.Plot)
local Station = require(Shared.stations.Station)

local PlotParts = {}

export type PlotParts = {
	--- The part the plot lies on. Its top is the plot's surface.
	read slab: Part,
	--- The position of the plot's corner: the outer corner of tile x 1, z 1, on the slab's top.
	read corner: Plot.Position,
	--- The folder that holds the blocks, and the lines between the tiles.
	read folder: Folder,
	--- The block that shows each placed object, by the placed object's id.
	read partsById: { [number]: Part },
}

local function makeLabel(part: Part, text: string, side: number)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(200, 26)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, side / 2 + 1.2, 0)
	billboard.MaxDistance = 70
	billboard.Parent = part
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 17
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.2
	label.Text = text
	label.Parent = billboard
end

local function makePart(kindId: string, id: number, center: Plot.Position): Part
	local look = PlacedObjectLooks[kindId]
	local side = Plot.TILE_SIZE
	local part = Instance.new("Part")
	part.Name = kindId
	part.Anchored = true
	part.Size = Vector3.new(side, side, side)
	part.Position = Vector3.new(center.x, center.y + side / 2, center.z)
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Color = Color3.fromRGB(look.color[1], look.color[2], look.color[3])
	part:SetAttribute("placedObjectId", id)

	makeLabel(part, look.name, side)
	return part
end

local function makeTileLine(folder: Folder, color: Color3, size: Vector3, position: Vector3)
	local line = Instance.new("Part")
	line.Name = "TileLine"
	line.Anchored = true
	line.CanCollide = false
	line.CanQuery = false
	line.CanTouch = false
	line.CastShadow = false
	line.Material = Enum.Material.SmoothPlastic
	line.Color = color
	line.Size = size
	line.Position = position
	line.Parent = folder
end

local function makeTileLines(folder: Folder, corner: Plot.Position, plot: Plot.Plot, color: Color3)
	local side = Plot.TILE_SIZE
	local length = plot.depthInTiles * side
	for index = 0, plot.widthInTiles do
		makeTileLine(
			folder,
			color,
			Vector3.new(0.12, 0.04, length),
			Vector3.new(corner.x + index * side, corner.y, corner.z + length / 2)
		)
	end
	local breadth = plot.widthInTiles * side
	for index = 0, plot.depthInTiles do
		makeTileLine(
			folder,
			color,
			Vector3.new(breadth, 0.04, 0.12),
			Vector3.new(corner.x + breadth / 2, corner.y, corner.z + index * side)
		)
	end
end

--- Returns a new set of blocks for the plot that lies on `slab`, with no block made yet, and draws
--- the lines between the plot's tiles. The blocks and the lines are kept in a folder called
--- `PlacedObjects` beside the slab. `plot` is read once, for its size. The plot starts at the
--- slab's corner of least x and z, and the slab's top must be at least as large as the plot.
function PlotParts.new(slab: Part, plot: Plot.Plot): PlotParts
	local corner = table.freeze({
		x = slab.Position.X - slab.Size.X / 2,
		y = slab.Position.Y + slab.Size.Y / 2,
		z = slab.Position.Z - slab.Size.Z / 2,
	})
	slab:SetAttribute("widthInTiles", plot.widthInTiles)
	slab:SetAttribute("depthInTiles", plot.depthInTiles)
	slab:SetAttribute("cornerX", corner.x)
	slab:SetAttribute("cornerY", corner.y)
	slab:SetAttribute("cornerZ", corner.z)
	CollectionService:AddTag(slab, "Plot")

	local folder = Instance.new("Folder")
	folder.Name = "PlacedObjects"
	makeTileLines(folder, corner, plot, slab.Color:Lerp(Color3.new(0, 0, 0), 0.18))
	folder.Parent = slab.Parent
	return { slab = slab, corner = corner, folder = folder, partsById = {} }
end

local function showFire(part: Part, burning: boolean)
	local color = PlacedObjectLooks[part.Name].color
	local unlit = Color3.fromRGB(color[1], color[2], color[3])
	part.Color = if burning then unlit:Lerp(Color3.fromRGB(255, 140, 40), 0.6) else unlit
	part.Material = if burning then Enum.Material.Neon else Enum.Material.SmoothPlastic
	local light = part:FindFirstChild("Fire")
	if burning and light == nil then
		local fire = Instance.new("PointLight")
		fire.Name = "Fire"
		fire.Color = Color3.fromRGB(255, 160, 70)
		fire.Range = 14
		fire.Brightness = 1.5
		fire.Parent = part
	elseif not burning and light ~= nil then
		light:Destroy()
	end
end

local function addMissingParts(plotParts: PlotParts, plot: Plot.Plot)
	for id, placedObject in plot.placedObjectsById do
		if plotParts.partsById[id] == nil then
			local center = Plot.getTileCenter(plotParts.corner, placedObject.tileX, placedObject.tileZ)
			local part = makePart(placedObject.kindId, id, center)
			plotParts.partsById[id] = part
			part.Parent = plotParts.folder
		end
	end
end

local function showFireIfChanged(part: Part, station: Station.Station?)
	local burning = station ~= nil and Station.isBurning(station)
	if part:GetAttribute("burning") ~= burning then
		part:SetAttribute("burning", burning)
		showFire(part, burning)
	end
end

local function removeStaleParts(plotParts: PlotParts, plot: Plot.Plot)
	for id, part in plotParts.partsById do
		if plot.placedObjectsById[id] == nil then
			part:Destroy()
			plotParts.partsById[id] = nil
		end
	end
end

local function showFires(plotParts: PlotParts, stations: { [number]: Station.Station })
	for id, part in plotParts.partsById do
		showFireIfChanged(part, stations[id])
	end
end

--- Makes the blocks match what is placed on `plot` now: a new block for each placed object that has
--- none, and no block for an item that is gone. Each station's block glows while its fire is
--- burning. `stations` holds the station of each placed object that has one, by placed object id.
function PlotParts.update(plotParts: PlotParts, plot: Plot.Plot, stations: { [number]: Station.Station })
	addMissingParts(plotParts, plot)
	removeStaleParts(plotParts, plot)
	showFires(plotParts, stations)
end

return PlotParts
