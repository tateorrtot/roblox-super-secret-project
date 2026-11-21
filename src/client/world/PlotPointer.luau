--!strict
--- Finds what a point on the screen is over: a placed object, or a tile of a plot.
---
--- `getTargetAt` casts a ray through the camera at a point and reads the part that it hits. A part
--- inside a Model that has the attribute `placedObjectId` is a placed object, whatever else the
--- Model holds. The top of a part tagged `Plot`, which has the attributes `cornerX`, `cornerY`,
--- `cornerZ`, `widthInTiles` and `depthInTiles`, is a grid of tiles.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Plot = require(Shared.plots.Plot)

local PlotPointer = {}

--- What a point on the screen is over: a placed object or a tile. A placed object has its id,
--- `placedObjectId`, and its `model`. A tile has its numbers `x` along x and `z` along z, each
--- counted from `1`. `center` is the middle of the tile, at the height of the plot's corner, or the
--- middle of the box that the placed object's Model fills.
export type Target =
	{ kind: "placedObject", placedObjectId: number, model: Model, center: Vector3 }
	| { kind: "tile", x: number, z: number, center: Vector3 }

--- How far from the camera a thing may be and still be a target, in studs.
local FARTHEST = 500

--- The surface is flat enough to be a plot's top when its upward direction is above this.
local FLAT = 0.9

local function isOnScreen(camera: Camera, viewportPoint: Vector2): boolean
	local size = camera.ViewportSize
	return viewportPoint.X >= 0 and viewportPoint.Y >= 0 and viewportPoint.X <= size.X and viewportPoint.Y <= size.Y
end

local function raycastThroughPoint(camera: Camera, viewportPoint: Vector2): RaycastResult?
	local ray = camera:ViewportPointToRay(viewportPoint.X, viewportPoint.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local character = Players.LocalPlayer.Character
	params.FilterDescendantsInstances = if character ~= nil then { character } else {}
	return Workspace:Raycast(ray.Origin, ray.Direction * FARTHEST, params)
end

local function findPlacedObjectModel(part: BasePart): Model?
	local model = part:FindFirstAncestorOfClass("Model")
	while model ~= nil and type(model:GetAttribute("placedObjectId")) ~= "number" do
		model = model:FindFirstAncestorOfClass("Model")
	end
	return model
end

local function tileTarget(hit: RaycastResult): Target?
	local part = hit.Instance
	local corner = {
		x = part:GetAttribute("cornerX") :: number,
		y = part:GetAttribute("cornerY") :: number,
		z = part:GetAttribute("cornerZ") :: number,
	}
	local x, z = Plot.getTileAt(corner, { x = hit.Position.X, y = hit.Position.Y, z = hit.Position.Z })
	local widthInTiles = part:GetAttribute("widthInTiles") :: number
	local depthInTiles = part:GetAttribute("depthInTiles") :: number
	if x < 1 or x > widthInTiles or z < 1 or z > depthInTiles then
		return nil
	end
	local center = Plot.getTileCenter(corner, x, z)
	return { kind = "tile", x = x, z = z, center = Vector3.new(center.x, center.y, center.z) }
end

--- Returns what the point `viewportPoint` is over, or `nil` if it is over neither a placed object
--- nor a tile of a plot. The ray passes through the local player's character, and anything else in
--- its way hides what is behind it. Only the top of a plot counts as tiles, not its sides. A point
--- outside the viewport, and a point over a plot's top outside its tiles, are over nothing.
---
--- Note: `viewportPoint` is in pixels from the top left of the whole window, which includes the
--- strip along the top of the screen.
function PlotPointer.getTargetAt(viewportPoint: Vector2): Target?
	local camera = Workspace.CurrentCamera
	if camera == nil or not isOnScreen(camera, viewportPoint) then
		return nil
	end
	local hit = raycastThroughPoint(camera, viewportPoint)
	if hit == nil then
		return nil
	end
	local part = hit.Instance
	local model = findPlacedObjectModel(part)
	if model ~= nil then
		local placedObjectId = model:GetAttribute("placedObjectId") :: number
		local center = model:GetBoundingBox().Position
		return { kind = "placedObject", placedObjectId = placedObjectId, model = model, center = center }
	end
	if hit.Normal.Y > FLAT and CollectionService:HasTag(part, "Plot") then
		return tileTarget(hit)
	end
	return nil
end

return PlotPointer
