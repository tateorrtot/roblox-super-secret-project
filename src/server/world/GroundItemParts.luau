--!strict
--- Shows each ground item as a block that Roblox's physics moves.
---
--- Each ground item gets one small grey block, with a label that gives the item's name and, if the
--- stack holds more than one, its count. `update` makes the blocks match a `GroundItems`: it makes
--- a block for each ground item that has none, relabels a block whose stack changed in count, and
--- destroys a block whose ground item is gone. A new block starts with its underside at the ground
--- item's `position`, moving at the ground item's `spawnVelocity`. After that the block is an
--- unanchored part: Roblox's physics makes it fall, land, and come to rest, and Roblox decides
--- which client or the server works out its motion. A block passes through the other blocks and
--- through characters, and collides with every other part. A raycast passes through a block.
--- `getMovedPositions` returns where the blocks have got to. The grey blocks stand in until items
--- have models.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GroundItems = require(Shared.groundItems.GroundItems)
local Items = require(Shared.content.Items)

local CollisionGroups = require(script.Parent.CollisionGroups)

local GroundItemParts = {}

--- The colour of every block that shows a ground item.
local PLACEHOLDER_COLOR = Color3.fromRGB(110, 112, 120)

--- The blocks that show the ground items, and the Folder that holds them.
export type GroundItemParts = {
	--- The folder that holds the blocks.
	read folder: Folder,
	--- The block that shows each ground item, by the ground item's id.
	read partsById: { [number]: Part },
}

--- How far a block's underside may be from its ground item's position along each axis, in studs,
--- before `getMovedPositions` returns the block.
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
	local name = Items.get(itemId).name
	local label = part:FindFirstChild("Label") :: BillboardGui
	local text = label:FindFirstChild("Text") :: TextLabel
	text.Text = if count > 1 then string.format("%s ×%d", name, count) else name
	part:SetAttribute("count", count)
end

local function makePart(groundItem: GroundItems.GroundItem): Part
	local itemId = groundItem.stack.itemId
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
	part.Color = PLACEHOLDER_COLOR
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

--- Returns a new `GroundItemParts` with no block made yet. Makes a Folder called `GroundItems`
--- inside `parent`, for the blocks.
--- Note: `parent` must be in the Workspace, because Roblox's physics moves a part only there.
function GroundItemParts.new(parent: Instance): GroundItemParts
	local folder = Instance.new("Folder")
	folder.Name = "GroundItems"
	folder.Parent = parent
	return { folder = folder, partsById = {} }
end

--- Makes the blocks match `groundItems`. Gives each ground item that has no block one, with its
--- underside at the ground item's `position` and moving at its `spawnVelocity`. Relabels a block
--- whose ground item's stack changed in count. Destroys a block whose ground item is gone.
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

--- Returns the position of each block that lies more than `MOVE_TOLERANCE` studs, along any axis,
--- from the position that `groundItems` holds for its ground item. The table returned is by the
--- ground item's id. A position returned is the point half a block below the block's middle, which
--- is the middle of the block's underside once it lies flat. Leaves out a block at a position that
--- is not finite, and a block whose ground item is not in `groundItems`. Returns a block on every
--- call until its ground item is moved to the position returned for it.
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
