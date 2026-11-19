--!strict
--[=[
	Works out what a point on the screen is over: an item placed on a plot,
	or a tile of a plot that nothing stands on.

	It reads what the server wrote for the purpose: the tag `Plot` and the
	attributes on a plot's slab, and the attribute `placedId` on the block of
	each placed item. The server's PlotParts says what they are.

	```lua
	local pointed = PlotPointer.at(UserInputService:GetMouseLocation())
	-- nil: the pointer is over neither
	-- { kind = "placedItem", id = 7 }: it is over the placed item with the id 7
	-- { kind = "tile", x = 3, z = 5, center = <where> }: it is over the bare tile x 3, z 5
	```
]=]
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Plot = require(Shared.plots.Plot)

local PlotPointer = {}

--- What a point on the screen is over.
export type Pointed = { kind: "placedItem", id: number } | { kind: "tile", x: number, z: number, center: Vector3 }

--- How far from the camera a thing may be and still be pointed at, in studs.
local FARTHEST = 500

--[=[
	Returns what the point `viewportPoint` is over, or `nil` if it is over
	neither a placed item nor a bare tile of a plot.

	`viewportPoint` is in pixels from the top left of the whole window, as
	`UserInputService:GetMouseLocation` gives it. The player's own character
	is looked through. Anything else in the way, such as a wall, hides what
	is behind it.
]=]
function PlotPointer.at(viewportPoint: Vector2): Pointed?
	local camera = Workspace.CurrentCamera
	if camera == nil then
		return nil
	end
	local ray = camera:ViewportPointToRay(viewportPoint.X, viewportPoint.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local character = Players.LocalPlayer.Character
	params.FilterDescendantsInstances = if character ~= nil then { character } else {}
	local hit = Workspace:Raycast(ray.Origin, ray.Direction * FARTHEST, params)
	if hit == nil then
		return nil
	end

	local part = hit.Instance
	local placedId = part:GetAttribute("placedId")
	if type(placedId) == "number" then
		return { kind = "placedItem", id = placedId }
	end
	-- Only the top of a plot's slab is its surface. Its sides are not tiles.
	if hit.Normal.Y > 0.9 and CollectionService:HasTag(part, "Plot") then
		local corner = {
			x = part:GetAttribute("cornerX") :: number,
			y = part:GetAttribute("cornerY") :: number,
			z = part:GetAttribute("cornerZ") :: number,
		}
		local x, z = Plot.tileAt(corner, { x = hit.Position.X, y = hit.Position.Y, z = hit.Position.Z })
		local width = part:GetAttribute("width") :: number
		local depth = part:GetAttribute("depth") :: number
		if x >= 1 and x <= width and z >= 1 and z <= depth then
			local center = Plot.tileCenter(corner, x, z)
			return { kind = "tile", x = x, z = z, center = Vector3.new(center.x, center.y, center.z) }
		end
	end
	return nil
end

return PlotPointer
