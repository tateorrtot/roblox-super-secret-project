--!strict
--- A row of slots along the bottom of the screen that shows the first slots of the player's pack,
--- the selected slot, the name of what it holds, and a button that opens the pack.
---
--- `update` draws the pack's first slots and the selected slot. The hotbar changes no inventory:
--- it calls the `Callbacks` given to `new` when the player clicks a slot or the pack button.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Inventory = require(Shared.inventory.Inventory)
local Items = require(Shared.content.Items)

local ScreenScale = require(script.Parent.Parent.ScreenScale)
local SlotGui = require(script.Parent.SlotGui)

local HotbarGui = {}

--- The functions that a hotbar calls when the player presses on it.
export type Callbacks = {
	--- Called with the number of the slot when the player clicks or taps a slot of the hotbar.
	onSlotChosen: (slot: number) -> (),
	--- Called when the player clicks or taps the pack button.
	onPackClicked: () -> (),
}

--- A hotbar: its `ScreenGui`, its slots, and the label that names the item in the selected slot.
export type HotbarGui = {
	--- The `ScreenGui` that holds the hotbar. `setVisible` enables and disables it.
	read screenGui: ScreenGui,
	--- The slots, in order: `slots[3]` is the third slot.
	read slots: { SlotGui.SlotGui },
	--- The label above the slots that holds the name of the item in the selected slot. Its text is
	--- empty if that slot holds nothing.
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

--- Returns a new hotbar of `slotCount` slots in a `ScreenGui` inside `parent`, with every slot
--- showing nothing. When the player clicks a slot, the hotbar calls `callbacks.onSlotChosen` with
--- that slot's number. When the player clicks the pack button, the hotbar calls
--- `callbacks.onPackClicked`.
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

--- Shows the stack in each slot of `pack` in the hotbar's slot of the same number, gives
--- `selectedSlot` a bright edge, and sets `selectedItemLabel` to the name of the item in that slot,
--- or to empty text if it holds nothing. The hotbar shows no slot of `pack` beyond its own slots.
function HotbarGui.update(hotbarGui: HotbarGui, pack: Inventory.Inventory, selectedSlot: number)
	for slot, slotGui in hotbarGui.slots do
		SlotGui.setStack(slotGui, Inventory.getStack(pack, slot))
		SlotGui.setSelected(slotGui, slot == selectedSlot)
	end
	local held = Inventory.getStack(pack, selectedSlot)
	hotbarGui.selectedItemLabel.Text = if held ~= nil then Items.get(held.itemId).name else ""
end

--- Shows the hotbar if `visible` is `true`, and hides it if `visible` is `false`.
function HotbarGui.setVisible(hotbarGui: HotbarGui, visible: boolean)
	hotbarGui.screenGui.Enabled = visible
end

return HotbarGui
