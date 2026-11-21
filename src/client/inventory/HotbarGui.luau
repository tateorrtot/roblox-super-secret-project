--!strict
--- The hotbar drawn along the bottom of the screen: one slot for each hotbar slot of the player's
--- pack, a bright edge on the one in hand, the name of what is in hand above the slots, and a
--- button that opens the pack.
---
--- `update` draws the pack's first slots and the one in hand. The hotbar changes no inventory: a
--- click on a slot or on the pack button is reported through the `Callbacks` given to `new`.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Inventory = require(Shared.inventory.Inventory)
local Items = require(Shared.content.Items)

local ScreenScale = require(script.Parent.Parent.ScreenScale)
local SlotGui = require(script.Parent.SlotGui)

local HotbarGui = {}

export type Callbacks = {
	--- Called with the slot number when the player clicks or taps a hotbar slot.
	onSlotChosen: (slot: number) -> (),
	--- Called when the player clicks or taps the pack button.
	onPackClicked: () -> (),
}

export type HotbarGui = {
	read screenGui: ScreenGui,
	--- The slots, in order: `slots[3]` draws hotbar slot 3.
	read slots: { SlotGui.SlotGui },
	--- The name of what is in hand, above the slots. It is empty while the hand is empty.
	read selectedItemLabel: TextLabel,
}

--- The space between two slots, in pixels before the screen is scaled.
local GAP = 4

--- The width of the pack button and the space before it, in pixels before the screen is scaled.
local PACK_BUTTON_WIDTH = 64

local function makeLabel(name: string, textSize: number, font: Enum.Font): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Font = font
	label.TextSize = textSize
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.3
	return label
end

local function makeSlot(row: Frame, slot: number, onSlotChosen: (slot: number) -> ()): SlotGui.SlotGui
	local slotGui = SlotGui.new(row)
	slotGui.button.Name = "Slot" .. slot
	slotGui.button.Position = UDim2.fromOffset((slot - 1) * (SlotGui.SIZE + GAP), 0)
	slotGui.button.MouseButton1Click:Connect(function()
		onSlotChosen(slot)
	end)
	local number = makeLabel("Number", 10, Enum.Font.GothamMedium)
	number.Position = UDim2.fromOffset(4, 2)
	number.Size = UDim2.fromOffset(10, 10)
	number.TextColor3 = Color3.fromRGB(200, 200, 205)
	number.Text = tostring(slot)
	number.ZIndex = 3
	number.Parent = slotGui.button
	return slotGui
end

local function makePackButton(row: Frame, slotCount: number, onPackClicked: () -> ()): TextButton
	local packButton = Instance.new("TextButton")
	packButton.Name = "PackButton"
	packButton.Position = UDim2.fromOffset(slotCount * (SlotGui.SIZE + GAP) + 4, 0)
	packButton.Size = UDim2.fromOffset(PACK_BUTTON_WIDTH - 4, SlotGui.SIZE)
	packButton.BackgroundColor3 = Color3.fromRGB(46, 47, 52)
	packButton.BorderSizePixel = 0
	packButton.Font = Enum.Font.GothamBold
	packButton.TextSize = 13
	packButton.TextColor3 = Color3.new(1, 1, 1)
	packButton.Text = "Pack\n[E]"
	packButton.Parent = row
	local packCorner = Instance.new("UICorner")
	packCorner.CornerRadius = UDim.new(0, 6)
	packCorner.Parent = packButton
	packButton.MouseButton1Click:Connect(onPackClicked)
	return packButton
end

local function makeSelectedItemLabel(row: Frame, slotCount: number): TextLabel
	local selectedItemLabel = makeLabel("Held", 15, Enum.Font.GothamBold)
	selectedItemLabel.AnchorPoint = Vector2.new(0.5, 1)
	selectedItemLabel.Position = UDim2.fromOffset(slotCount * (SlotGui.SIZE + GAP) / 2, -6)
	selectedItemLabel.Size = UDim2.fromOffset(300, 18)
	selectedItemLabel.Text = ""
	selectedItemLabel.Parent = row
	return selectedItemLabel
end

--- Returns a new hotbar of `slotCount` slots, drawn in a `ScreenGui` inside `parent`, showing
--- nothing yet. A click on slot `n` calls `callbacks.onSlotChosen(n)`.
function HotbarGui.new(parent: Instance, slotCount: number, callbacks: Callbacks): HotbarGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Hotbar"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 1

	local row = Instance.new("Frame")
	row.Name = "Row"
	row.AnchorPoint = Vector2.new(0.5, 1)
	row.Position = UDim2.new(0.5, 0, 1, -10)
	row.Size = UDim2.fromOffset(slotCount * (SlotGui.SIZE + GAP) + PACK_BUTTON_WIDTH, SlotGui.SIZE)
	row.BackgroundTransparency = 1
	row.Parent = screenGui
	ScreenScale.applyTo(row)

	local slots = {}
	for slot = 1, slotCount do
		slots[slot] = makeSlot(row, slot, callbacks.onSlotChosen)
	end
	makePackButton(row, slotCount, callbacks.onPackClicked)
	local selectedItemLabel = makeSelectedItemLabel(row, slotCount)

	screenGui.Parent = parent
	return { screenGui = screenGui, slots = slots, selectedItemLabel = selectedItemLabel }
end

--- Draws the first slots of `pack`, with a bright edge on slot `selectedSlot` and the name of the
--- stack in it above the slots. The name is empty if that slot holds nothing.
function HotbarGui.update(hotbarGui: HotbarGui, pack: Inventory.Inventory, selectedSlot: number)
	for slot, slotGui in hotbarGui.slots do
		SlotGui.setStack(slotGui, Inventory.getStack(pack, slot))
		SlotGui.setSelected(slotGui, slot == selectedSlot)
	end
	local held = Inventory.getStack(pack, selectedSlot)
	hotbarGui.selectedItemLabel.Text = if held ~= nil then Items.get(held.itemId).name else ""
end

--- Shows the hotbar if `visible` is `true`, and hides it if not.
function HotbarGui.setVisible(hotbarGui: HotbarGui, visible: boolean)
	hotbarGui.screenGui.Enabled = visible
end

return HotbarGui
