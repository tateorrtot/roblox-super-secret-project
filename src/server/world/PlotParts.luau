--!strict
--- What shows a plot in the world: the lines between its tiles, and a Model for each object
--- standing on it.
---
--- Draws thin lines on the plot's slab to mark the tiles. `update` makes the Models match what is
--- placed: a new Model for each newly placed object and none for one that was removed. What a
--- Model is, is not decided here: each kind of placed object has a piece of its own that makes
--- its Model, and `update` is handed those pieces. The slab is tagged `Plot` and has the
--- attributes `widthInTiles` and `depthInTiles`, and `cornerX`, `cornerY` and `cornerZ`, the
--- plot's corner as `Plot.getTileAt` wants it. Each Model has the attribute `placedObjectId`, the
--- id of its placed object, and is named for the id of its kind. The plot must lie square to the
--- world's x and z axes.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Plot = require(Shared.plots.Plot)

local PlotParts = {}

export type PlotParts = {
	--- The part the plot lies on. Its top is the plot's surface.
	read slab: Part,
	--- The position of the plot's corner: the outer corner of tile x 1, z 1, on the slab's top.
	read corner: Plot.Position,
	--- The folder that holds the Models, and the lines between the tiles.
	read folder: Folder,
	--- The Model that shows each placed object, by the placed object's id.
	read modelsById: { [number]: Model },
}

--- How one kind of placed object is shown in the world: a piece of that kind's own.
export type PlacedObjectPiece = {
	--- Returns a new Model that shows one placed object of the kind. The Model's pivot is put on
	--- the middle of the placed object's tile, on the plot's surface, so the Model is built
	--- standing on its pivot. What is in the Model is the kind's own business.
	read make: () -> Model,
	--- Called each time the Models are updated, with the Model of one placed object of the kind,
	--- the plot that placed object stands on, and its id. A kind whose look never changes has no
	--- `update`.
	read update: ((model: Model, plot: Plot.Plot, placedObjectId: number) -> ())?,
}

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

--- Returns what shows the plot that lies on `slab`, with no Model made yet, and draws the lines
--- between the plot's tiles. The Models and the lines are kept in a folder called
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
	return { slab = slab, corner = corner, folder = folder, modelsById = {} }
end

type Pieces = { [string]: PlacedObjectPiece }

local function addMissingModels(plotParts: PlotParts, plot: Plot.Plot, piecesByKindId: Pieces)
	for id, placedObject in plot.placedObjectsById do
		local piece = piecesByKindId[placedObject.kindId]
		if plotParts.modelsById[id] == nil and piece ~= nil then
			local center = Plot.getTileCenter(plotParts.corner, placedObject.tileX, placedObject.tileZ)
			local model = piece.make()
			model.Name = placedObject.kindId
			model:SetAttribute("placedObjectId", id)
			model:PivotTo(CFrame.new(center.x, center.y, center.z))
			plotParts.modelsById[id] = model
			model.Parent = plotParts.folder
		end
	end
end

local function removeStaleModels(plotParts: PlotParts, plot: Plot.Plot)
	for id, model in plotParts.modelsById do
		if plot.placedObjectsById[id] == nil then
			model:Destroy()
			plotParts.modelsById[id] = nil
		end
	end
end

local function updateModels(plotParts: PlotParts, plot: Plot.Plot, piecesByKindId: Pieces)
	for id, model in plotParts.modelsById do
		local piece = piecesByKindId[plot.placedObjectsById[id].kindId]
		local update = if piece ~= nil then piece.update else nil
		if update ~= nil then
			update(model, plot, id)
		end
	end
end

--- Makes the Models match what is placed on `plot` now. `piecesByKindId` holds the piece of each
--- kind of placed object, by the kind's id. A placed object with no Model gets one, which the
--- piece of its kind makes: it is named for the kind's id, given the attribute `placedObjectId`,
--- and its pivot is put on the middle of the placed object's tile, on the plot's surface. The
--- Model of a placed object that is gone is destroyed. Then, for each Model whose kind's piece
--- has an `update`, that is called with the Model, `plot` and the placed object's id. A placed
--- object whose kind has no piece is not shown.
function PlotParts.update(plotParts: PlotParts, plot: Plot.Plot, piecesByKindId: { [string]: PlacedObjectPiece })
	addMissingModels(plotParts, plot, piecesByKindId)
	removeStaleModels(plotParts, plot)
	updateModels(plotParts, plot, piecesByKindId)
end

return PlotParts
