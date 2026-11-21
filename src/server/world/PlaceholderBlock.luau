--!strict
--- A plain block with a name above it, standing in for a model that has not been made yet.
---
--- `make` returns one as a Model. It goes when the game's things have models of their own.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Plot = require(ReplicatedStorage:WaitForChild("Shared").plots.Plot)

local PlaceholderBlock = {}

local function makeLabel(block: Part, text: string)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(200, 26)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, block.Size.Y / 2 + 1.2, 0)
	billboard.MaxDistance = 70
	billboard.Parent = block
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

--- Returns a new Model that holds one anchored block, a tile wide, deep and tall, in the colour
--- `color`, with `name` written above it. The block is the Model's `PrimaryPart` and is called
--- `Block`. The Model's pivot is the middle of the block's underside, so a Model pivoted to a
--- point stands on that point.
function PlaceholderBlock.make(name: string, color: Color3): Model
	local side = Plot.TILE_SIZE
	local block = Instance.new("Part")
	block.Name = "Block"
	block.Anchored = true
	block.Size = Vector3.new(side, side, side)
	block.PivotOffset = CFrame.new(0, -side / 2, 0)
	block.Material = Enum.Material.SmoothPlastic
	block.TopSurface = Enum.SurfaceType.Smooth
	block.BottomSurface = Enum.SurfaceType.Smooth
	block.Color = color
	makeLabel(block, name)
	local model = Instance.new("Model")
	block.Parent = model
	model.PrimaryPart = block
	return model
end

return PlaceholderBlock
