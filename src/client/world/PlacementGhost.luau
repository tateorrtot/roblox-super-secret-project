--!strict
--- A see-through block that shows where an object would stand on a tile.
---
--- `show` puts the block on a tile in the colour of a kind of placed object, and `hide` takes it
--- away. It is only a picture on this player's machine: showing it places nothing.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlacedObjectLooks = require(Shared.content.PlacedObjectLooks)
local Plot = require(Shared.plots.Plot)

local PlacementGhost = {}

export type PlacementGhost = {
	--- The block. It is in the Workspace while shown, and has no parent while hidden.
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

--- Returns a new ghost, hidden.
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
	part.Transparency = 0.45
	makeOutline(part)
	return { part = part }
end

--- Shows the ghost as a placed object of the kind `kindId`, standing on the tile whose middle is
--- at `tileCenter`.
function PlacementGhost.show(ghost: PlacementGhost, kindId: string, tileCenter: Vector3)
	local color = PlacedObjectLooks[kindId].color
	local part = ghost.part
	part.Color = Color3.fromRGB(color[1], color[2], color[3])
	part.Position = tileCenter + Vector3.new(0, part.Size.Y / 2, 0)
	part.Parent = Workspace
end

--- Hides the ghost. Does nothing if it is hidden already.
function PlacementGhost.hide(ghost: PlacementGhost)
	ghost.part.Parent = nil
end

return PlacementGhost
