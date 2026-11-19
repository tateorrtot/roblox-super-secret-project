--!strict
--[=[
	Shows the ground items as parts in the world: one plain block for each
	stack lying on the ground, in the colour of its item, with a label that
	says what it is and how many.

	The rules in GroundItems know nothing of this. [method update] reads them
	and makes the parts match: a new block for each new ground item, a changed
	label when part of a stack was picked up, and no block for what is gone.
	Call it after anything may have changed the ground items.

	The blocks are placeholders. They stand in until items have models.

	```lua
	local groundItemParts = GroundItemParts.new(workspace)
	GroundItems.drop(groundItems, stack, position, now)
	GroundItemParts.update(groundItemParts, groundItems) -- a block appears at that position
	```
]=]
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
	return part
end

-- Makes a block show its ground item: a fuller stack is a bigger block, resting on the ground where the stack lies.
local function showGroundItem(part: Part, id: number, groundItem: GroundItems.GroundItem)
	local stack = groundItem.stack
	local fullness = stack.count / ItemRegistry.get(stack.itemId).stackSize
	local side = 1.2 + 1.2 * fullness
	local position = groundItem.position
	part.Size = Vector3.new(side, side, side)
	part.CFrame = CFrame.new(position.x, position.y + side / 2, position.z) * CFrame.Angles(0, id * 0.7, 0)
	part:SetAttribute("count", stack.count)

	local name = ItemLooks[stack.itemId].name
	local label = part:FindFirstChild("Label") :: BillboardGui
	local text = label:FindFirstChild("Text") :: TextLabel
	text.Text = if stack.count > 1 then string.format("%s ×%d", name, stack.count) else name
end

--[=[
	Returns a new set of blocks, with none made yet, that will be kept in a
	folder called `GroundItems` inside `parent`.
]=]
function GroundItemParts.new(parent: Instance): GroundItemParts
	local folder = Instance.new("Folder")
	folder.Name = "GroundItems"
	folder.Parent = parent
	return { folder = folder, partsById = {} }
end

--[=[
	Makes the blocks match `groundItems` as they are now.
]=]
function GroundItemParts.update(groundItemParts: GroundItemParts, groundItems: GroundItems.GroundItems)
	local partsById = groundItemParts.partsById
	for id, groundItem in groundItems.byId do
		local part = partsById[id]
		if part == nil then
			part = makePart(groundItem.stack.itemId)
			partsById[id] = part
			showGroundItem(part, id, groundItem)
			part.Parent = groundItemParts.folder
		elseif part:GetAttribute("count") ~= groundItem.stack.count then
			showGroundItem(part, id, groundItem)
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
