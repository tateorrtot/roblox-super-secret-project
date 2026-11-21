--!strict
--- The lines between a plot's tiles, and a Model for each placed object that stands on the plot.
---
--- `new` draws thin lines on the plot's slab to mark the tiles. `update` makes the Models match
--- the placed objects: it makes a Model for each placed object that has none, and destroys the
--- Model of each placed object that is gone. Each kind of placed object has a `PlacedObjectPiece`
--- that makes its Model, and `update` is handed those pieces. `new` tags the slab `Plot` and gives
--- it the attributes `widthInTiles`, `depthInTiles`, `cornerX`, `cornerY`, and `cornerZ`, the last
--- three being the plot's corner as `Plot.getTileAt` takes it. Each Model has the attribute
--- `placedObjectId`, the id of its placed object, and is named for the id of its kind. The plot
--- must be aligned with the world's x and z axes.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Plot = require(Shared.plots.Plot)

local PlotParts = {}

--- What shows one plot: its slab, its corner, and the Models of its placed objects.
export type PlotParts = {
	--- The part that the plot lies on. Its top is the plot's surface.
	read slab: Part,
	--- The position of the outer corner of the plot's tile x `1`, z `1`, on the slab's top.
	read corner: Plot.Position,
	--- The Folder that holds the Models and the lines between the tiles.
	read folder: Folder,
	--- The Model that shows each placed object, by the placed object's id.
	read modelsById: { [number]: Model },
}

--- The piece that shows one kind of placed object in the world.
export type PlacedObjectPiece = {
	--- Returns a new Model that shows one placed object of the kind, built standing on its pivot.
	--- `PlotParts.update` puts the pivot on the middle of the placed object's tile, on the plot's
	--- surface. The Model may hold anything.
	read make: () -> Model,
	--- `PlotParts.update` calls `update` once for each Model of the kind, each time
	--- `PlotParts.update` runs, with the Model, the plot that the placed object stands on, and the
	--- placed object's id. A kind whose Model never changes has no `update`.
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

--- Returns a new `PlotParts` for `plot`, which lies on `slab`, with no Model made yet. Draws the
--- lines between the plot's tiles, tags `slab` `Plot`, and gives it the attributes `widthInTiles`,
--- `depthInTiles`, `cornerX`, `cornerY`, and `cornerZ`. Keeps the Models and the lines in a Folder
--- called `PlacedObjects`, beside `slab`. Reads `plot` once, for its size. The plot starts at the
--- slab's corner of least x and least z, and the slab's top must be at least as large as the plot.
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

--- Makes the Models match the placed objects on `plot`. `piecesByKindId` holds the piece of each
--- kind of placed object, by the kind's id. Gives each placed object that has no Model one, which
--- the piece of its kind makes: named for the kind's id, with the attribute `placedObjectId`, and
--- with its pivot on the middle of the placed object's tile, on the plot's surface. Destroys the
--- Model of each placed object that is gone. Then calls the `update` of the piece of each Model's
--- kind, if the piece has one, with the Model, `plot`, and the placed object's id. Shows no Model
--- for a placed object whose kind has no piece.
function PlotParts.update(plotParts: PlotParts, plot: Plot.Plot, piecesByKindId: { [string]: PlacedObjectPiece })
	addMissingModels(plotParts, plot, piecesByKindId)
	removeStaleModels(plotParts, plot)
	updateModels(plotParts, plot, piecesByKindId)
end

return PlotParts
