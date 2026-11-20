--!strict
--- Shows the stacks loose in the world as blocks, which Roblox's physics moves.
---
--- Each ground item gets one small block in the colour of its item, with a label that says what it
--- is and how many. `update` makes the blocks match a `GroundItems` as it is now: a block for each
--- new ground item, a changed label when a stack grew or shrank, and no block for what is gone. A
--- new block starts where its ground item is, moving as fast as the ground item was spawned. After
--- that it is an ordinary unanchored part: Roblox's physics makes it fall, land and come to rest,
--- and shows its motion to every player. Which machine works its motion out is left to Roblox,
--- which gives a part near a player to that player's machine. A block passes through the other
--- blocks and through characters, and collides with everything else. A pointer passes through it too, to whatever is behind. `getMovedPositions` says where
--- the blocks have got to. The blocks are placeholders until items have models.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GroundItems = require(Shared.world.GroundItems)
local ItemLooks = require(Shared.items.ItemLooks)

local CollisionGroups = require(script.Parent.CollisionGroups)

local GroundItemParts = {}

export type GroundItemParts = {
	--- The folder that holds the blocks.
	read folder: Folder,
	--- The block that shows each ground item, by the ground item's id.
	read partsById: { [number]: Part },
}

local MOVE_TOLERANCE = 0.01

local function makeLabel(part: Part)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(200, 24)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 1.6, 0)
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

local function showCount(part: Part, itemId: string, count: number)
	local name = ItemLooks[itemId].name
	local label = part:FindFirstChild("Label") :: BillboardGui
	local text = label:FindFirstChild("Text") :: TextLabel
	text.Text = if count > 1 then string.format("%s ×%d", name, count) else name
	part:SetAttribute("count", count)
end

local function makePart(groundItem: GroundItems.GroundItem): Part
	local itemId = groundItem.stack.itemId
	local look = ItemLooks[itemId]
	local width = GroundItems.ITEM_WIDTH
	local position = groundItem.position
	local part = Instance.new("Part")
	part.Name = itemId
	part.Size = Vector3.new(width, width, width)
	part.Position = Vector3.new(position.x, position.y + width / 2, position.z)
	part.CollisionGroup = CollisionGroups.GROUND_ITEMS
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.fromRGB(look.color[1], look.color[2], look.color[3])
	makeLabel(part)
	showCount(part, itemId, groundItem.stack.count)
	return part
end

local function putPartInWorld(part: Part, folder: Folder, velocity: GroundItems.Velocity)
	part.Parent = folder
	part.AssemblyLinearVelocity = Vector3.new(velocity.x, velocity.y, velocity.z)
end

local function hasMoved(from: GroundItems.Position, to: Vector3): boolean
	local isFinite = to == to and to.Magnitude < math.huge
	local isElsewhere = math.abs(to.X - from.x) > MOVE_TOLERANCE
		or math.abs(to.Y - from.y) > MOVE_TOLERANCE
		or math.abs(to.Z - from.z) > MOVE_TOLERANCE
	return isFinite and isElsewhere
end

--- Returns a new set of blocks, with none made yet, that will be kept in a folder called
--- `GroundItems` inside `parent`. `parent` must be in the Workspace, because only there does
--- Roblox's physics move a part.
function GroundItemParts.new(parent: Instance): GroundItemParts
	local folder = Instance.new("Folder")
	folder.Name = "GroundItems"
	folder.Parent = parent
	return { folder = folder, partsById = {} }
end

--- Makes the blocks match `groundItems` as it is now. A ground item with no block gets one, where
--- the ground item is and moving at its `spawnVelocity`. A block whose stack changed in size is
--- relabelled. A block whose ground item is gone is destroyed.
function GroundItemParts.update(groundItemParts: GroundItemParts, groundItems: GroundItems.GroundItems)
	local partsById = groundItemParts.partsById
	for id, groundItem in groundItems.itemsById do
		local part = partsById[id]
		if part == nil then
			part = makePart(groundItem)
			partsById[id] = part
			putPartInWorld(part, groundItemParts.folder, groundItem.spawnVelocity)
		elseif part:GetAttribute("count") ~= groundItem.stack.count then
			showCount(part, groundItem.stack.itemId, groundItem.stack.count)
		end
	end
	for id, part in partsById do
		if groundItems.itemsById[id] == nil then
			part:Destroy()
			partsById[id] = nil
		end
	end
end

--- Returns where each block now is, by the id of its ground item, for every block that is more
--- than a hundredth of a stud, along any axis, from where `groundItems` says its ground item is.
--- A position returned is the point half a block below the block's middle: the middle of its
--- underside once it lies flat, as a ground item's position is. A block is returned on every call
--- until its ground item is moved to the position returned for it, so a block at rest is returned
--- once.
function GroundItemParts.getMovedPositions(
	groundItemParts: GroundItemParts,
	groundItems: GroundItems.GroundItems
): { [number]: GroundItems.Position }
	local moved = {}
	for id, part in groundItemParts.partsById do
		local groundItem = groundItems.itemsById[id]
		local underside = part.Position - Vector3.new(0, GroundItems.ITEM_WIDTH / 2, 0)
		if groundItem ~= nil and hasMoved(groundItem.position, underside) then
			moved[id] = { x = underside.X, y = underside.Y, z = underside.Z }
		end
	end
	return moved
end

return GroundItemParts
