--!strict
--- The picture of a stack on the screen: a block in the item's colour with the item's name across
--- it and the count in the corner.
---
--- `setStack` makes it show a stack, or nothing. A stack of one shows no count. The block stands in
--- for an icon until items have art.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Items = require(Shared.content.Items)
local ItemStack = require(Shared.items.ItemStack)

local StackIcon = {}

export type StackIcon = {
	--- The coloured block. It is hidden while there is no stack to show.
	read block: Frame,
	--- The item's name, across the block.
	read nameLabel: TextLabel,
	--- The number of items, in the corner of the block. It is empty for a stack of one.
	read countLabel: TextLabel,
}

--- Returns a new picture inside `parent`, filling it to a little inside its edge, and showing
--- nothing yet.
function StackIcon.new(parent: Instance): StackIcon
	local block = Instance.new("Frame")
	block.Name = "StackIcon"
	block.AnchorPoint = Vector2.new(0.5, 0.5)
	block.Position = UDim2.fromScale(0.5, 0.5)
	block.Size = UDim2.new(1, -10, 1, -10)
	block.BorderSizePixel = 0
	block.Visible = false

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = block

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "ItemName"
	nameLabel.Size = UDim2.new(1, -4, 0.6, 0)
	nameLabel.Position = UDim2.fromOffset(2, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.Parent = block
	local nameSize = Instance.new("UITextSizeConstraint")
	nameSize.MinTextSize = 6
	nameSize.MaxTextSize = 11
	nameSize.Parent = nameLabel

	local countLabel = Instance.new("TextLabel")
	countLabel.Name = "Count"
	countLabel.AnchorPoint = Vector2.new(1, 1)
	countLabel.Position = UDim2.new(1, 3, 1, 4)
	countLabel.Size = UDim2.fromOffset(40, 18)
	countLabel.BackgroundTransparency = 1
	countLabel.Font = Enum.Font.GothamBold
	countLabel.TextSize = 15
	countLabel.TextXAlignment = Enum.TextXAlignment.Right
	countLabel.TextColor3 = Color3.new(1, 1, 1)
	countLabel.TextStrokeTransparency = 0
	countLabel.ZIndex = 2
	countLabel.Parent = block

	block.Parent = parent
	return { block = block, nameLabel = nameLabel, countLabel = countLabel }
end

--- Makes the picture show `stack`, or nothing if `stack` is `nil`.
function StackIcon.setStack(icon: StackIcon, stack: ItemStack.ItemStack?)
	if stack == nil then
		icon.block.Visible = false
		return
	end
	local look = Items.get(stack.itemId)
	icon.block.BackgroundColor3 = Color3.fromRGB(look.color[1], look.color[2], look.color[3])
	icon.nameLabel.Text = look.name
	icon.countLabel.Text = if stack.count > 1 then tostring(stack.count) else ""
	icon.block.Visible = true
end

return StackIcon
