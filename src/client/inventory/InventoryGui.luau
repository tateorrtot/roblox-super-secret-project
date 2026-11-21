--!strict
--- The screen that shows the player's pack, another inventory above it, and the stack being
--- carried.
---
--- The other inventory, such as a crate's, is drawn above the pack, and the pack's hotbar slots are
--- its bottom row, set apart from the rest. The carried stack follows the pointer. The other
--- inventory's slots are drawn in rows, unless `show` is given an `OtherLayout`, which places them
--- its own way and may draw more beside them. `show` opens and redraws the screen,
--- `setHighlightedSlots` gives slots a bright edge, and `hide` closes the screen. The screen
--- changes no inventory: it calls its `callbacks` when the player acts on it.
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

--- Which inventory a slot belongs to: the player's pack, or the other inventory above it.
export type Side = "pack" | "other"

--- A mouse button. A finger on a touch screen counts as `"left"`.
export type Button = "left" | "right"

--- The functions that the screen calls when the player acts on it.
export type Callbacks = {
	--- Called with the slot's side, its number, and the button when a mouse button goes down on a
	--- slot.
	onSlotPressed: (side: Side, slot: number, button: Button) -> (),
	--- Called with the slot's side and its number when the pointer comes onto a slot while a mouse
	--- button is down.
	onSlotEntered: (side: Side, slot: number) -> (),
	--- Called with the button when the player clicks outside the panel, on the dimmed world.
	onOutsideClicked: (button: Button) -> (),
	--- Called when the player clicks the panel's close button.
	onCloseClicked: () -> (),
}

--- A way to place the other inventory's slots on the panel when they are not drawn in rows, and to
--- draw more beside them.
export type OtherLayout = {
	--- Places `slots`, the other inventory's slots in order, on `panel`, and shows whatever else the
	--- layout draws there. `origin` is the top left corner of the space on `panel` that belongs to
	--- the other inventory, and `step` is the distance from one slot to the next. Returns the height
	--- of the space that the layout used, in pixels before the screen is scaled.
	place: (panel: Frame, slots: { SlotGui.SlotGui }, origin: Vector2, step: number) -> number,
	--- Hides whatever else the layout draws.
	hide: () -> (),
}

--- An inventory screen: its `ScreenGui`, its panel, its slots, and the carried stack's icon.
export type InventoryGui = {
	--- The `ScreenGui` that holds the whole screen. It is enabled while the screen is open.
	read screenGui: ScreenGui,
	--- The panel that the slots are on.
	read panel: Frame,
	--- The label at the top of the panel that holds the name of the other inventory, or `"Pack"`
	--- if the pack is shown alone.
	read title: TextLabel,
	--- The label `"Pack"` above the pack's slots. It is visible while another inventory is above them.
	read packTitle: TextLabel,
	--- The number of the pack's first slots that are its hotbar, drawn as the bottom row.
	read hotbarSlotCount: number,
	--- The functions that the screen calls when the player acts on it.
	read callbacks: Callbacks,
	--- The pack's slots, in order. `show` makes them.
	read packSlots: { SlotGui.SlotGui },
	--- The other inventory's slots, in order. The list is empty if the pack is shown alone.
	read otherSlots: { SlotGui.SlotGui },
	--- The icon of the carried stack.
	read carriedIcon: StackIcon.StackIcon,
	--- The frame that holds `carriedIcon`, and that moves with the pointer.
	read carriedFrame: Frame,
	--- The connection that moves `carriedFrame` to the pointer each frame. `nil` before `show` first
	--- opens the screen, and after `hide`.
	pointerConnection: RBXScriptConnection?,
	--- The slot that the pointer is over. `nil` if it is over none.
	hoveredSlot: { side: Side, slot: number }?,
	--- The `OtherLayout` that places the other inventory's slots. `nil` while they are drawn in
	--- rows.
	otherLayout: OtherLayout?,
}

local COLUMNS = 9
local GAP = 4
local PADDING = 14
local TITLE_HEIGHT = 26
local HOTBAR_GAP = 10
local HINT_HEIGHT = 46
local PACK_NAME = "Pack"

local function isMouseButtonDown(): boolean
	return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
		or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end

local function makeSlot(inventoryGui: InventoryGui, side: Side, slot: number): SlotGui.SlotGui
	local slotGui = SlotGui.new(inventoryGui.panel)
	slotGui.button.Name = (if side == "pack" then "PackSlot" else "OtherSlot") .. slot
	local function press(button: Button)
		inventoryGui.hoveredSlot = { side = side, slot = slot }
		inventoryGui.callbacks.onSlotPressed(side, slot, button)
	end
	slotGui.button.MouseButton1Down:Connect(function()
		press("left")
	end)
	slotGui.button.MouseButton2Down:Connect(function()
		press("right")
	end)
	slotGui.button.MouseEnter:Connect(function()
		inventoryGui.hoveredSlot = { side = side, slot = slot }
		if isMouseButtonDown() then
			inventoryGui.callbacks.onSlotEntered(side, slot)
		end
	end)
	slotGui.button.MouseLeave:Connect(function()
		local hovered = inventoryGui.hoveredSlot
		if hovered ~= nil and hovered.side == side and hovered.slot == slot then
			inventoryGui.hoveredSlot = nil
		end
	end)
	return slotGui
end

local function resizeSlots(inventoryGui: InventoryGui, slots: { SlotGui.SlotGui }, side: Side, slotCount: number)
	for slot = #slots + 1, slotCount do
		slots[slot] = makeSlot(inventoryGui, side, slot)
	end
	for slot = #slots, slotCount + 1, -1 do
		slots[slot].button:Destroy()
		slots[slot] = nil
	end
end

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

local function layOut(inventoryGui: InventoryGui)
	local packSlots = inventoryGui.packSlots
	local otherSlots = inventoryGui.otherSlots
	local hotbarSlotCount = math.min(inventoryGui.hotbarSlotCount, #packSlots)
	local top = PADDING + TITLE_HEIGHT
	inventoryGui.packTitle.Visible = #otherSlots > 0
	if #otherSlots > 0 then
		local otherLayout = inventoryGui.otherLayout
		local height = if otherLayout ~= nil
			then otherLayout.place(inventoryGui.panel, otherSlots, Vector2.new(PADDING, top), SlotGui.SIZE + GAP)
			else placeRows(otherSlots, 1, #otherSlots, top)
		top += height + HOTBAR_GAP
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

local function followPointer(inventoryGui: InventoryGui)
	if inventoryGui.pointerConnection ~= nil then
		return
	end
	local carriedFrame = inventoryGui.carriedFrame
	local function moveToPointer()
		local pointer = UserInputService:GetMouseLocation()
		carriedFrame.Position = UDim2.fromOffset(pointer.X, pointer.Y)
	end
	moveToPointer()
	inventoryGui.pointerConnection = RunService.RenderStepped:Connect(moveToPointer)
end

local function makeScreenGui(): ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Inventory"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 10
	screenGui.Enabled = false
	return screenGui
end

local function makeBackdrop(screenGui: ScreenGui, callbacks: Callbacks)
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
end

local function makePanel(screenGui: ScreenGui): Frame
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
	ScreenScale.applyTo(panel)
	return panel
end

local function makeTitle(panel: Frame): TextLabel
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
	return title
end

local function makePackTitle(panel: Frame, title: TextLabel): TextLabel
	local packTitle = title:Clone()
	packTitle.Name = "PackTitle"
	packTitle.Visible = false
	packTitle.Parent = panel
	return packTitle
end

local function makeCloseButton(panel: Frame, callbacks: Callbacks)
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
end

local function makeHint(panel: Frame)
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
		.. "Shift and click: send across.  Drag: spread a stack.  Click outside: drop.  E: close.\n"
		.. "Double click: gather a kind.  Over a slot, 1 to 9: swap with that hotbar slot.  Q: drop one."
	hint.Parent = panel
end

local function makeCarried(screenGui: ScreenGui): (Frame, StackIcon.StackIcon)
	local carriedFrame = Instance.new("Frame")
	carriedFrame.Name = "Carried"
	carriedFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	carriedFrame.Size = UDim2.fromOffset(SlotGui.SIZE, SlotGui.SIZE)
	carriedFrame.BackgroundTransparency = 1
	carriedFrame.ZIndex = 10
	carriedFrame.Parent = screenGui
	ScreenScale.applyTo(carriedFrame)
	local carriedIcon = StackIcon.new(carriedFrame)
	carriedIcon.block.ZIndex = 10
	carriedIcon.nameLabel.ZIndex = 10
	carriedIcon.countLabel.ZIndex = 11
	return carriedFrame, carriedIcon
end

--- Returns a new inventory screen in a `ScreenGui` inside `parent`, closed and with no slots.
--- `hotbarSlotCount` is the number of the pack's first slots that are its hotbar. The screen calls
--- `callbacks` when the player acts on it.
function InventoryGui.new(parent: Instance, hotbarSlotCount: number, callbacks: Callbacks): InventoryGui
	local screenGui = makeScreenGui()
	makeBackdrop(screenGui, callbacks)
	local panel = makePanel(screenGui)
	local title = makeTitle(panel)
	local packTitle = makePackTitle(panel, title)
	makeCloseButton(panel, callbacks)
	makeHint(panel)
	local carriedFrame, carriedIcon = makeCarried(screenGui)

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

--- Opens the screen if it is closed, or redraws it if it is open. Shows `pack`, `carriedStack` at
--- the pointer if it is not `nil`, and `otherInventory` above the pack if it is not `nil`.
--- `otherInventoryName` is the title of the other inventory. The title is `"Pack"` if
--- `otherInventory` is `nil`. The other inventory's slots are drawn in rows, or placed by
--- `otherLayout` if it is not `nil`. If `otherLayout` is not the layout that the screen used
--- before, `show` calls the `hide` of the layout that the screen used before, if there was one.
--- While the screen is open, the pointer moves freely, even in first person.
--- Note: `show` adds or removes slots, and places them, only when the number of slots in the pack
--- or in the other inventory changes, or when `otherLayout` changes. It calls `otherLayout.place`
--- only then, and only if the other inventory has slots.
function InventoryGui.show(
	inventoryGui: InventoryGui,
	pack: Inventory.Inventory,
	otherInventory: Inventory.Inventory?,
	otherInventoryName: string,
	carriedStack: ItemStack.ItemStack?,
	otherLayout: OtherLayout?
)
	inventoryGui.title.Text = if otherInventory ~= nil then otherInventoryName else PACK_NAME
	local otherSlotCount = if otherInventory ~= nil then otherInventory.slotCount else 0
	local formerLayout = inventoryGui.otherLayout
	if
		#inventoryGui.packSlots ~= pack.slotCount
		or #inventoryGui.otherSlots ~= otherSlotCount
		or formerLayout ~= otherLayout
	then
		if formerLayout ~= nil and formerLayout ~= otherLayout then
			formerLayout.hide()
		end
		inventoryGui.otherLayout = otherLayout
		resizeSlots(inventoryGui, inventoryGui.packSlots, "pack", pack.slotCount)
		resizeSlots(inventoryGui, inventoryGui.otherSlots, "other", otherSlotCount)
		layOut(inventoryGui)
	end
	for slot, slotGui in inventoryGui.packSlots do
		SlotGui.setStack(slotGui, Inventory.getStack(pack, slot))
	end
	if otherInventory ~= nil then
		for slot, slotGui in inventoryGui.otherSlots do
			SlotGui.setStack(slotGui, Inventory.getStack(otherInventory, slot))
		end
	end
	StackIcon.setStack(inventoryGui.carriedIcon, carriedStack)
	followPointer(inventoryGui)
	inventoryGui.screenGui.Enabled = true
end

--- Gives the slots in `screenSlots` a bright edge, and every other slot a plain edge. An empty
--- list gives every slot a plain edge. A slot in the list that the screen does not have is
--- ignored.
function InventoryGui.setHighlightedSlots(
	inventoryGui: InventoryGui,
	screenSlots: { { read side: string, read slot: number } }
)
	local marked: { [SlotGui.SlotGui]: boolean } = {}
	for _, screenSlot in screenSlots do
		local slots = if screenSlot.side == "pack" then inventoryGui.packSlots else inventoryGui.otherSlots
		local slotGui = slots[screenSlot.slot]
		if slotGui ~= nil then
			marked[slotGui] = true
		end
	end
	for _, slots in { inventoryGui.packSlots, inventoryGui.otherSlots } do
		for _, slotGui in slots do
			SlotGui.setSelected(slotGui, marked[slotGui] == true)
		end
	end
end

--- Closes the screen, gives every slot a plain edge, sets `hoveredSlot` to `nil`, and stops moving
--- `carriedFrame` to the pointer. Changes nothing if the screen is closed already.
--- Note: `hide` does not call the hide of `otherLayout`.
function InventoryGui.hide(inventoryGui: InventoryGui)
	inventoryGui.screenGui.Enabled = false
	InventoryGui.setHighlightedSlots(inventoryGui, {})
	inventoryGui.hoveredSlot = nil
	local following = inventoryGui.pointerConnection
	if following ~= nil then
		following:Disconnect()
		inventoryGui.pointerConnection = nil
	end
end

return InventoryGui
