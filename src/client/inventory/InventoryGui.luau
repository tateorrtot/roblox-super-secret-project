--!strict
--[=[
	The inventory screen: the player's pack, the other inventory that is open
	beside it if there is one, such as a crate's, and the stack being carried,
	which follows the pointer.

	It is laid out as Minecraft's is. The other inventory is at the top. Under
	it is the pack, with its hotbar slots as the bottom row, a little apart
	from the rest.

	It draws what it is shown and reports what the player clicks. It changes
	nothing itself: the code that made it decides what a click does, and shows
	the screen again when the inventories have changed.

	```lua
	local inventoryGui = InventoryGui.new(playerGui, 9, {
		onSlotClicked = function(side, slot, button, shiftHeld) end, -- side is "pack" or "other", button "left" or "right"
		onOutsideClicked = function(button) end, -- a click on the dimmed world around the screen
		onCloseClicked = function() end, -- a click on the screen's close button
	})
	InventoryGui.show(inventoryGui, pack, crate, "Crate", carried) -- the screen opens, or redraws if it was open
	InventoryGui.hide(inventoryGui)
	```
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Inventory = require(Shared.inventory.Inventory)
local ItemStack = require(Shared.items.ItemStack)

local ScreenScale = require(script.Parent.Parent.ScreenScale)
local SlotGui = require(script.Parent.SlotGui)
local StackIcon = require(script.Parent.StackIcon)

local InventoryGui = {}

export type Side = "pack" | "other"
export type Button = "left" | "right"

export type Callbacks = {
	--- Called when the player clicks a slot. `shiftHeld` is `true` if a Shift key was down.
	onSlotClicked: (side: Side, slot: number, button: Button, shiftHeld: boolean) -> (),
	--- Called when the player clicks outside the screen, on the dimmed world.
	onOutsideClicked: (button: Button) -> (),
	--- Called when the player clicks the screen's close button.
	onCloseClicked: () -> (),
}

export type InventoryGui = {
	read screenGui: ScreenGui,
	--- The panel the slots are on.
	read panel: Frame,
	--- The words at the top of the panel: the name of the other inventory, or of the pack when it is shown alone.
	read title: TextLabel,
	--- The word "Pack" above the pack's slots, shown when another inventory is above them.
	read packTitle: TextLabel,
	--- How many of the pack's slots are its hotbar, drawn as the bottom row.
	read hotbarSlotCount: number,
	read callbacks: Callbacks,
	--- The pack's slots, in order. Made when the screen is first shown.
	read packSlots: { SlotGui.SlotGui },
	--- The other inventory's slots, in order. Empty when the pack is shown alone.
	read otherSlots: { SlotGui.SlotGui },
	--- The picture of the carried stack, and the frame that moves it with the pointer.
	read carriedIcon: StackIcon.StackIcon,
	read carriedFrame: Frame,
	--- The connection that moves the carried stack each frame while the screen is open.
	read following: RBXScriptConnection?,
}

local COLUMNS = 9
local GAP = 4
local PADDING = 14
local TITLE_HEIGHT = 26
local HOTBAR_GAP = 10
local HINT_HEIGHT = 34
local PACK_NAME = "Pack"

local function isShiftHeld(): boolean
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
end

-- Makes one slot on the panel and connects its clicks.
local function makeSlot(inventoryGui: InventoryGui, side: Side, slot: number): SlotGui.SlotGui
	local slotGui = SlotGui.new(inventoryGui.panel)
	slotGui.button.Name = (if side == "pack" then "PackSlot" else "OtherSlot") .. slot
	slotGui.button.MouseButton1Click:Connect(function()
		inventoryGui.callbacks.onSlotClicked(side, slot, "left", isShiftHeld())
	end)
	slotGui.button.MouseButton2Click:Connect(function()
		inventoryGui.callbacks.onSlotClicked(side, slot, "right", isShiftHeld())
	end)
	return slotGui
end

-- Makes `slots` hold exactly `slotCount` slots for one side, making or destroying slots as needed.
local function resizeSlots(inventoryGui: InventoryGui, slots: { SlotGui.SlotGui }, side: Side, slotCount: number)
	for slot = #slots + 1, slotCount do
		slots[slot] = makeSlot(inventoryGui, side, slot)
	end
	for slot = #slots, slotCount + 1, -1 do
		slots[slot].button:Destroy()
		slots[slot] = nil
	end
end

-- Places `count` slots of `slots`, starting from the slot numbered `first`, in rows of nine from
-- `top` downwards. Returns the height the rows take.
local function placeRows(slots: { SlotGui.SlotGui }, first: number, count: number, top: number): number
	local step = SlotGui.SIZE + GAP
	for index = 0, count - 1 do
		local column = index % COLUMNS
		local row = math.floor(index / COLUMNS)
		slots[first + index].button.Position = UDim2.fromOffset(PADDING + column * step, top + row * step)
	end
	local rows = math.ceil(count / COLUMNS)
	return if rows > 0 then rows * step - GAP else 0
end

-- Lays the panel out for the slots there are now: the other inventory, then the pack, then the pack's hotbar.
local function layOut(inventoryGui: InventoryGui)
	local packSlots = inventoryGui.packSlots
	local otherSlots = inventoryGui.otherSlots
	local hotbarSlotCount = math.min(inventoryGui.hotbarSlotCount, #packSlots)
	local top = PADDING + TITLE_HEIGHT
	inventoryGui.packTitle.Visible = #otherSlots > 0
	if #otherSlots > 0 then
		top += placeRows(otherSlots, 1, #otherSlots, top) + HOTBAR_GAP
		inventoryGui.packTitle.Position = UDim2.fromOffset(PADDING, top)
		top += TITLE_HEIGHT
	end
	local restCount = #packSlots - hotbarSlotCount
	if restCount > 0 then
		top += placeRows(packSlots, hotbarSlotCount + 1, restCount, top) + HOTBAR_GAP
	end
	top += placeRows(packSlots, 1, hotbarSlotCount, top)
	local width = PADDING * 2 + COLUMNS * (SlotGui.SIZE + GAP) - GAP
	inventoryGui.panel.Size = UDim2.fromOffset(width, top + HINT_HEIGHT + PADDING)
end

--[=[
	Returns a new inventory screen in a ScreenGui inside `parent`, hidden.
	`hotbarSlotCount` is how many of the pack's first slots are its hotbar.
]=]
function InventoryGui.new(parent: Instance, hotbarSlotCount: number, callbacks: Callbacks): InventoryGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Inventory"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 10
	screenGui.Enabled = false

	-- The dimmed world around the panel. Being modal, it frees the pointer even in first person.
	local outside = Instance.new("TextButton")
	outside.Name = "Outside"
	outside.Size = UDim2.fromScale(1, 1)
	outside.BackgroundColor3 = Color3.new(0, 0, 0)
	outside.BackgroundTransparency = 0.5
	outside.BorderSizePixel = 0
	outside.AutoButtonColor = false
	outside.Modal = true
	outside.Text = ""
	outside.Parent = screenGui
	outside.MouseButton1Click:Connect(function()
		callbacks.onOutsideClicked("left")
	end)
	outside.MouseButton2Click:Connect(function()
		callbacks.onOutsideClicked("right")
	end)

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.BackgroundColor3 = Color3.fromRGB(40, 41, 46)
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.Parent = screenGui
	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 10)
	panelCorner.Parent = panel
	ScreenScale.apply(panel)

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Position = UDim2.fromOffset(PADDING, PADDING - 4)
	title.Size = UDim2.new(1, -PADDING * 2, 0, TITLE_HEIGHT - 6)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(225, 225, 230)
	title.Text = PACK_NAME
	title.Parent = panel

	local packTitle = title:Clone()
	packTitle.Name = "PackTitle"
	packTitle.Visible = false
	packTitle.Parent = panel

	local close = Instance.new("TextButton")
	close.Name = "Close"
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, -PADDING + 4, 0, PADDING - 6)
	close.Size = UDim2.fromOffset(24, 24)
	close.BackgroundColor3 = Color3.fromRGB(72, 73, 80)
	close.BorderSizePixel = 0
	close.Font = Enum.Font.GothamBold
	close.TextSize = 14
	close.TextColor3 = Color3.new(1, 1, 1)
	close.Text = "X"
	close.Parent = panel
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = close
	close.MouseButton1Click:Connect(callbacks.onCloseClicked)

	local hint = Instance.new("TextLabel")
	hint.Name = "Hint"
	hint.AnchorPoint = Vector2.new(0, 1)
	hint.Position = UDim2.new(0, PADDING, 1, -PADDING + 6)
	hint.Size = UDim2.new(1, -PADDING * 2, 0, HINT_HEIGHT - 6)
	hint.BackgroundTransparency = 1
	hint.Font = Enum.Font.Gotham
	hint.TextSize = 11
	hint.TextWrapped = true
	hint.TextXAlignment = Enum.TextXAlignment.Left
	hint.TextYAlignment = Enum.TextYAlignment.Bottom
	hint.TextColor3 = Color3.fromRGB(165, 166, 175)
	hint.Text = "Left click: pick up or put down a stack.  Right click: take half, or put one down.\n"
		.. "Shift and click: send to the other side.  Click outside: drop.  E: close."
	hint.Parent = panel

	local carriedFrame = Instance.new("Frame")
	carriedFrame.Name = "Carried"
	carriedFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	carriedFrame.Size = UDim2.fromOffset(SlotGui.SIZE, SlotGui.SIZE)
	carriedFrame.BackgroundTransparency = 1
	carriedFrame.ZIndex = 10
	carriedFrame.Parent = screenGui
	ScreenScale.apply(carriedFrame)
	local carriedIcon = StackIcon.new(carriedFrame)
	carriedIcon.block.ZIndex = 10
	carriedIcon.nameLabel.ZIndex = 10
	carriedIcon.countLabel.ZIndex = 11

	screenGui.Parent = parent
	return {
		screenGui = screenGui,
		panel = panel,
		title = title,
		packTitle = packTitle,
		hotbarSlotCount = hotbarSlotCount,
		callbacks = callbacks,
		packSlots = {},
		otherSlots = {},
		carriedIcon = carriedIcon,
		carriedFrame = carriedFrame,
	}
end

--[=[
	Opens the screen, or redraws it if it is open, to show `pack`, the `other`
	inventory above it if one is given, and the `carried` stack at the pointer
	if there is one. `otherName` is written over the other inventory, and is
	not used when there is none.
]=]
function InventoryGui.show(
	inventoryGui: InventoryGui,
	pack: Inventory.Inventory,
	other: Inventory.Inventory?,
	otherName: string,
	carried: ItemStack.ItemStack?
)
	inventoryGui.title.Text = if other ~= nil then otherName else PACK_NAME
	local otherSlotCount = if other ~= nil then other.slotCount else 0
	if #inventoryGui.packSlots ~= pack.slotCount or #inventoryGui.otherSlots ~= otherSlotCount then
		resizeSlots(inventoryGui, inventoryGui.packSlots, "pack", pack.slotCount)
		resizeSlots(inventoryGui, inventoryGui.otherSlots, "other", otherSlotCount)
		layOut(inventoryGui)
	end
	for slot, slotGui in inventoryGui.packSlots do
		SlotGui.show(slotGui, Inventory.getStack(pack, slot))
	end
	if other ~= nil then
		for slot, slotGui in inventoryGui.otherSlots do
			SlotGui.show(slotGui, Inventory.getStack(other, slot))
		end
	end
	StackIcon.show(inventoryGui.carriedIcon, carried)

	if inventoryGui.following == nil then
		local carriedFrame = inventoryGui.carriedFrame
		local function follow()
			local pointer = UserInputService:GetMouseLocation()
			carriedFrame.Position = UDim2.fromOffset(pointer.X, pointer.Y)
		end
		follow();
		(inventoryGui :: any).following = RunService.RenderStepped:Connect(follow)
	end
	inventoryGui.screenGui.Enabled = true
end

--[=[
	Closes the screen. Does nothing if it is closed already.
]=]
function InventoryGui.hide(inventoryGui: InventoryGui)
	inventoryGui.screenGui.Enabled = false
	local following = inventoryGui.following
	if following ~= nil then
		following:Disconnect();
		(inventoryGui :: any).following = nil
	end
end

return InventoryGui
