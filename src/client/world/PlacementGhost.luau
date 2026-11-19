--!strict
--[=[
	The see-through block that shows where the item in hand would stand if
	it were placed now: on the tile under the pointer, in the item's colour.

	It is only a picture on this player's machine. Nothing is placed until
	the server says so.

	```lua
	local ghost = PlacementGhost.new()
	PlacementGhost.show(ghost, "crate", tileCenter) -- a faint crate-coloured block on that tile
	PlacementGhost.hide(ghost)
	```
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ItemLooks = require(Shared.items.ItemLooks)
local Plot = require(Shared.plots.Plot)

local PlacementGhost = {}

export type PlacementGhost = {
	--- The block. It is in the Workspace while shown, and nowhere while hidden.
	read part: Part,
}

--[=[
	Returns a new ghost, hidden.
]=]
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

	-- A bright outline, so the tile it stands on is plain to see.
	local outline = Instance.new("SelectionBox")
	outline.Name = "Outline"
	outline.Adornee = part
	outline.LineThickness = 0.06
	outline.Color3 = Color3.new(1, 1, 1)
	outline.Parent = part
	return { part = part }
end

--[=[
	Shows the ghost as the item with the id `itemId`, standing on the tile
	whose middle is at `tileCenter`.
]=]
function PlacementGhost.show(ghost: PlacementGhost, itemId: string, tileCenter: Vector3)
	local color = ItemLooks[itemId].color
	local part = ghost.part
	part.Color = Color3.fromRGB(color[1], color[2], color[3])
	part.Position = tileCenter + Vector3.new(0, part.Size.Y / 2, 0)
	part.Parent = Workspace
end

--[=[
	Hides the ghost. Does nothing if it is hidden already.
]=]
function PlacementGhost.hide(ghost: PlacementGhost)
	ghost.part.Parent = nil
end

return PlacementGhost
