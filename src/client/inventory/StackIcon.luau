--!strict
--- The icon of a stack on the screen: a plain grey block with the item's name across it and the
--- count in the corner.
---
--- `setStack` shows a stack in the icon, or shows nothing. A stack of one item shows no count. The
--- block stands in for art that the items do not have.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Items = require(Shared.content.Items)
local ItemStack = require(Shared.items.ItemStack)

local StackIcon = {}

--- A stack's icon: the grey block, and the two labels on it.
export type StackIcon = {
	--- The grey block. It is hidden while the icon shows nothing.
	read block: Frame,
	--- The label across the block that holds the item's name.
	read nameLabel: TextLabel,
	--- The label in the corner of the block that holds the number of items. Its text is empty for a
	--- stack of one item.
	read countLabel: TextLabel,
}

--- Returns a new icon in `parent`, showing nothing. The block is centered in `parent`, and is 10
--- pixels narrower and 10 pixels shorter than `parent`.
function StackIcon.new(parent: Instance): StackIcon
	local block = Instance.new("Frame")
	block.Name = "StackIcon"
	block.AnchorPoint = Vector2.new(0.5, 0.5)
	block.Position = UDim2.fromScale(0.5, 0.5)
	block.Size = UDim2.new(1, -10, 1, -10)
	block.BorderSizePixel = 0
	block.BackgroundColor3 = Color3.fromRGB(110, 112, 120)
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

--- Shows `stack` in the icon: the name of its item, and its count if the count is above `1`. Shows
--- nothing if `stack` is `nil`.
function StackIcon.setStack(icon: StackIcon, stack: ItemStack.ItemStack?)
	if stack == nil then
		icon.block.Visible = false
		return
	end
	icon.nameLabel.Text = Items.get(stack.itemId).name
	icon.countLabel.Text = if stack.count > 1 then tostring(stack.count) else ""
	icon.block.Visible = true
end

return StackIcon
