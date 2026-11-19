--!strict
--[=[
	Shows a plot's placed items in the world: one plain block, a tile wide,
	for each item standing on the plot, in the colour of its item and with its
	name above it.

	The rules in Plot know nothing of this. [method update] reads them and
	makes the blocks match: a new block for each newly placed item, and no
	block for one that was removed. Call it after anything may have changed
	what is placed.

	A player's machine has to tell what the pointer is over, so two things
	are written where it can read them:
	- The slab the plot lies on gets the tag `Plot`, and attributes `width`
	  and `depth` in tiles, and `cornerX`, `cornerY` and `cornerZ`: the
	  position of the plot's corner, as `Plot.tileAt` wants it.
	- Each block gets the attribute `placedId`, the id of its placed item.

	The plot must lie square to the world's x and z, not turned.

	The blocks are placeholders. They stand in until items have models.

	```lua
	local plotParts = PlotParts.new(slab, plot)
	Plot.place(plot, "crate", 3, 5)
	PlotParts.update(plotParts, plot) -- a crate-coloured block stands on that tile
	```
]=]
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ItemLooks = require(Shared.items.ItemLooks)
local Plot = require(Shared.plots.Plot)

local PlotParts = {}

export type PlotParts = {
	--- The part the plot lies on. Its top is the plot's surface.
	read slab: Part,
	--- The position of the plot's corner: the outer corner of tile x 1, z 1, on the slab's top.
	read corner: Plot.Position,
	--- The folder that holds the blocks.
	read folder: Folder,
	--- The block that shows each placed item, by the placed item's id.
	read partsById: { [number]: Part },
}

local function makePart(itemId: string, id: number, center: Plot.Position): Part
	local look = ItemLooks[itemId]
	local side = Plot.TILE_SIZE
	local part = Instance.new("Part")
	part.Name = itemId
	part.Anchored = true
	part.Size = Vector3.new(side, side, side)
	part.Position = Vector3.new(center.x, center.y + side / 2, center.z)
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Color = Color3.fromRGB(look.color[1], look.color[2], look.color[3])
	part:SetAttribute("placedId", id)

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(200, 26)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, side / 2 + 1.2, 0)
	billboard.MaxDistance = 70
	billboard.Parent = part
	local text = Instance.new("TextLabel")
	text.Name = "Text"
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextSize = 17
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0.2
	text.Text = look.name
	text.Parent = billboard
	return part
end

--[=[
	Returns a new set of blocks for the plot that lies on `slab`, with none
	made yet. The blocks will be kept in a folder called `PlacedItems` beside
	the slab.

	`plot` is read once, for its size. The slab's top must be at least as
	large as the plot's tiles; the plot starts at the slab's corner of least
	x and z.
]=]
function PlotParts.new(slab: Part, plot: Plot.Plot): PlotParts
	local corner = table.freeze({
		x = slab.Position.X - slab.Size.X / 2,
		y = slab.Position.Y + slab.Size.Y / 2,
		z = slab.Position.Z - slab.Size.Z / 2,
	})
	slab:SetAttribute("width", plot.width)
	slab:SetAttribute("depth", plot.depth)
	slab:SetAttribute("cornerX", corner.x)
	slab:SetAttribute("cornerY", corner.y)
	slab:SetAttribute("cornerZ", corner.z)
	CollectionService:AddTag(slab, "Plot")

	local folder = Instance.new("Folder")
	folder.Name = "PlacedItems"
	folder.Parent = slab.Parent
	return { slab = slab, corner = corner, folder = folder, partsById = {} }
end

--[=[
	Makes the blocks match what is placed on `plot` now.
]=]
function PlotParts.update(plotParts: PlotParts, plot: Plot.Plot)
	local partsById = plotParts.partsById
	for id, placedItem in plot.placedById do
		if partsById[id] == nil then
			local center = Plot.tileCenter(plotParts.corner, placedItem.x, placedItem.z)
			local part = makePart(placedItem.itemId, id, center)
			partsById[id] = part
			part.Parent = plotParts.folder
		end
	end
	for id, part in partsById do
		if plot.placedById[id] == nil then
			part:Destroy()
			partsById[id] = nil
		end
	end
end

return PlotParts
