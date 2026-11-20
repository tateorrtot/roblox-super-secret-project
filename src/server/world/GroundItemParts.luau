--!strict
--- Shows the stacks lying on the ground as blocks in the world.
---
--- Each ground item gets one plain block in the colour of its item, with a label that says what it is
--- and how many. `update` makes the blocks match a `GroundItems` as it is now: a new block for each new
--- ground item, a changed label when part of a stack was picked up, and no block for what is gone. The
--- blocks are placeholders until items have models.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GroundItems = require(Shared.world.GroundItems)
local ItemLooks = require(Shared.items.ItemLooks)
local ItemRegistry = require(Shared.items.ItemRegistry)

local GroundItemParts = {}

export type GroundItemParts = {
	--- The folder that holds the blocks.
	read folder: Folder,
	--- The block that shows each ground item, by the ground item's id.
	read partsById: { [number]: Part },
}

local function makeLabel(part: Part)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(200, 24)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.2, 0)
	billboard.MaxDistance = 60
	billboard.Parent = part

	local text = Instance.new("TextLabel")
	text.Name = "Text"
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextSize = 15
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0.2
	text.Parent = billboard
end

local function makePart(itemId: string): Part
	local look = ItemLooks[itemId]
	local part = Instance.new("Part")
	part.Name = itemId
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.fromRGB(look.color[1], look.color[2], look.color[3])
	makeLabel(part)
	return part
end

local function setLabelText(part: Part, itemId: string, count: number)
	local name = ItemLooks[itemId].name
	local label = part:FindFirstChild("Label") :: BillboardGui
	local text = label:FindFirstChild("Text") :: TextLabel
	text.Text = if count > 1 then string.format("%s ×%d", name, count) else name
end

local function fitPartToGroundItem(part: Part, id: number, groundItem: GroundItems.GroundItem)
	local stack = groundItem.stack
	local fullness = stack.count / ItemRegistry.get(stack.itemId).stackSize
	local side = 1.2 + 1.2 * fullness
	local position = groundItem.position
	part.Size = Vector3.new(side, side, side)
	part.CFrame = CFrame.new(position.x, position.y + side / 2, position.z) * CFrame.Angles(0, id * 0.7, 0)
	part:SetAttribute("count", stack.count)
	setLabelText(part, stack.itemId, stack.count)
end

--- Returns a new set of blocks, with none made yet, that will be kept in a folder called `GroundItems`
--- inside `parent`.
function GroundItemParts.new(parent: Instance): GroundItemParts
	local folder = Instance.new("Folder")
	folder.Name = "GroundItems"
	folder.Parent = parent
	return { folder = folder, partsById = {} }
end

--- Makes the blocks match `groundItems` as they are now. A ground item with no block gets one; a block
--- whose stack changed in size is resized and relabelled; a block whose ground item is gone is destroyed.
--- A bigger stack makes a bigger block, resting on the ground where the stack lies.
function GroundItemParts.update(groundItemParts: GroundItemParts, groundItems: GroundItems.GroundItems)
	local partsById = groundItemParts.partsById
	for id, groundItem in groundItems.byId do
		local part = partsById[id]
		if part == nil then
			part = makePart(groundItem.stack.itemId)
			partsById[id] = part
			fitPartToGroundItem(part, id, groundItem)
			part.Parent = groundItemParts.folder
		elseif part:GetAttribute("count") ~= groundItem.stack.count then
			fitPartToGroundItem(part, id, groundItem)
		end
	end
	for id, part in partsById do
		if groundItems.byId[id] == nil then
			part:Destroy()
			partsById[id] = nil
		end
	end
end

return GroundItemParts
