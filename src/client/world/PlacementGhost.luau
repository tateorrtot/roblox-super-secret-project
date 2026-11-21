--!strict
--- A see-through block that shows where an object would stand on a tile.
---
--- `new` makes the block, `show` stands it on a tile, and `hide` removes it from the world. The
--- block is a picture on the client and places nothing.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Plot = require(ReplicatedStorage:WaitForChild("Shared").plots.Plot)

local PlacementGhost = {}

--- A ghost: the block that `show` and `hide` move into and out of the world.
export type PlacementGhost = {
	--- The block: a grey cube of `Plot.TILE_SIZE` studs a side with a white outline. Its parent is
	--- the Workspace while the ghost is shown, and `nil` while the ghost is hidden.
	read part: Part,
}

local function makeOutline(part: Part): SelectionBox
	local outline = Instance.new("SelectionBox")
	outline.Name = "Outline"
	outline.Adornee = part
	outline.LineThickness = 0.06
	outline.Color3 = Color3.new(1, 1, 1)
	outline.Parent = part
	return outline
end

--- Returns a new ghost that is hidden.
function PlacementGhost.new(): PlacementGhost
	local side = Plot.TILE_SIZE
	local part = Instance.new("Part")
	part.Name = "PlacementGhost"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Size = Vector3.new(side, side, side)
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.fromRGB(110, 112, 120)
	part.Transparency = 0.45
	makeOutline(part)
	return { part = part }
end

--- Puts the ghost's block in the Workspace, standing on `tileCenter`, the middle of a tile. Moves
--- the block there if the ghost is shown already.
function PlacementGhost.show(ghost: PlacementGhost, tileCenter: Vector3)
	local part = ghost.part
	part.Position = tileCenter + Vector3.new(0, part.Size.Y / 2, 0)
	part.Parent = Workspace
end

--- Removes the ghost's block from the world. Does nothing if the ghost is hidden already.
function PlacementGhost.hide(ghost: PlacementGhost)
	ghost.part.Parent = nil
end

return PlacementGhost
