--!strict
--- Works out what a point on the screen is over: an item placed on a plot, or a tile of a plot that
--- nothing stands on.
---
--- `getTargetAt` looks through the camera at a point and reads what it hits. A block with the
--- attribute `placedObjectId` is a placed object. The top of a slab tagged `Plot`, which has the
--- attributes `cornerX`, `cornerY`, `cornerZ`, `width` and `depth`, is a grid of tiles.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Plot = require(Shared.plots.Plot)

local PlotPointer = {}

--- What a point on the screen is over. `center` is the middle of the bare tile, or the middle of
--- the placed object's block.
export type Target =
	{ kind: "placedObject", placedObjectId: number, part: BasePart, center: Vector3 }
	| { kind: "tile", x: number, z: number, center: Vector3 }

--- How far from the camera a thing may be and still be a target, in studs.
local FARTHEST = 500

--- The surface is flat enough to be a plot's top when its upward direction is above this.
local FLAT = 0.9

local function raycastThroughPoint(camera: Camera, viewportPoint: Vector2): RaycastResult?
	local ray = camera:ViewportPointToRay(viewportPoint.X, viewportPoint.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local character = Players.LocalPlayer.Character
	params.FilterDescendantsInstances = if character ~= nil then { character } else {}
	return Workspace:Raycast(ray.Origin, ray.Direction * FARTHEST, params)
end

local function tileTarget(hit: RaycastResult): Target?
	local part = hit.Instance
	local corner = {
		x = part:GetAttribute("cornerX") :: number,
		y = part:GetAttribute("cornerY") :: number,
		z = part:GetAttribute("cornerZ") :: number,
	}
	local x, z = Plot.getTileAt(corner, { x = hit.Position.X, y = hit.Position.Y, z = hit.Position.Z })
	local width = part:GetAttribute("width") :: number
	local depth = part:GetAttribute("depth") :: number
	if x < 1 or x > width or z < 1 or z > depth then
		return nil
	end
	local center = Plot.getTileCenter(corner, x, z)
	return { kind = "tile", x = x, z = z, center = Vector3.new(center.x, center.y, center.z) }
end

--- Returns what the point `viewportPoint` is over, or `nil` if it is over neither a placed object nor
--- a bare tile of a plot. The player's own character is looked through. Anything else in the way
--- hides what is behind it. Only the top of a plot's slab counts as tiles, not its sides.
---
--- Note: `viewportPoint` is in pixels from the top left of the whole window, which includes the
--- strip along the top of the screen.
function PlotPointer.getTargetAt(viewportPoint: Vector2): Target?
	local camera = Workspace.CurrentCamera
	if camera == nil then
		return nil
	end
	local hit = raycastThroughPoint(camera, viewportPoint)
	if hit == nil then
		return nil
	end
	local part = hit.Instance
	local placedObjectId = part:GetAttribute("placedObjectId")
	if type(placedObjectId) == "number" then
		return { kind = "placedObject", placedObjectId = placedObjectId, part = part, center = part.Position }
	end
	if hit.Normal.Y > FLAT and CollectionService:HasTag(part, "Plot") then
		return tileTarget(hit)
	end
	return nil
end

return PlotPointer
