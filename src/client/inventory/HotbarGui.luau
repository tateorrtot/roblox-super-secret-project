--!strict
--[=[
	The hotbar drawn along the bottom of the screen: one slot for each hotbar
	slot of the player's pack, with a bright edge on the one in hand, the name
	of what is in hand above it, and a button that opens the pack.

	It draws what it is shown and reports what the player picks. It changes
	nothing itself: the code that made it decides what a pick does.

	```lua
	local hotbarGui = HotbarGui.new(playerGui, 9, {
		onSlotChosen = function(slot) end, -- the player clicked or tapped hotbar slot `slot`
		onPackClicked = function() end, -- the player clicked or tapped the pack button
	})
	HotbarGui.show(hotbarGui, pack, 3) -- draws slots 1 to 9 of the pack, with slot 3 in hand
	```
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Inventory = require(Shared.inventory.Inventory)
local ItemLooks = require(Shared.items.ItemLooks)

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
	--- The name of what is in hand, above the slots.
	read heldLabel: TextLabel,
}

local GAP = 4
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

--[=[
	Returns a new hotbar of `slotCount` slots, drawn in a ScreenGui inside
	`parent`, showing nothing yet.
]=]
function HotbarGui.new(parent: Instance, slotCount: number, callbacks: Callbacks): HotbarGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Hotbar"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 1

	local step = SlotGui.SIZE + GAP
	local row = Instance.new("Frame")
	row.Name = "Row"
	row.AnchorPoint = Vector2.new(0.5, 1)
	row.Position = UDim2.new(0.5, 0, 1, -10)
	row.Size = UDim2.fromOffset(slotCount * step + PACK_BUTTON_WIDTH, SlotGui.SIZE)
	row.BackgroundTransparency = 1
	row.Parent = screenGui
	ScreenScale.apply(row)

	local slots = {}
	for slot = 1, slotCount do
		local slotGui = SlotGui.new(row)
		slotGui.button.Name = "Slot" .. slot
		slotGui.button.Position = UDim2.fromOffset((slot - 1) * step, 0)
		slotGui.button.MouseButton1Click:Connect(function()
			callbacks.onSlotChosen(slot)
		end)
		local number = makeLabel("Number", 10, Enum.Font.GothamMedium)
		number.Position = UDim2.fromOffset(4, 2)
		number.Size = UDim2.fromOffset(10, 10)
		number.TextColor3 = Color3.fromRGB(200, 200, 205)
		number.Text = tostring(slot)
		number.ZIndex = 3
		number.Parent = slotGui.button
		slots[slot] = slotGui
	end

	local packButton = Instance.new("TextButton")
	packButton.Name = "PackButton"
	packButton.Position = UDim2.fromOffset(slotCount * step + 4, 0)
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
	packButton.MouseButton1Click:Connect(callbacks.onPackClicked)

	local heldLabel = makeLabel("Held", 15, Enum.Font.GothamBold)
	heldLabel.AnchorPoint = Vector2.new(0.5, 1)
	heldLabel.Position = UDim2.fromOffset(slotCount * step / 2, -6)
	heldLabel.Size = UDim2.fromOffset(300, 18)
	heldLabel.Text = ""
	heldLabel.Parent = row

	screenGui.Parent = parent
	return { screenGui = screenGui, slots = slots, heldLabel = heldLabel }
end

--[=[
	Draws the first slots of `pack`, with a bright edge on the slot numbered
	`selectedSlot` and the name of the stack in it above the hotbar.
]=]
function HotbarGui.show(hotbarGui: HotbarGui, pack: Inventory.Inventory, selectedSlot: number)
	for slot, slotGui in hotbarGui.slots do
		SlotGui.show(slotGui, Inventory.getStack(pack, slot))
		SlotGui.setSelected(slotGui, slot == selectedSlot)
	end
	local held = Inventory.getStack(pack, selectedSlot)
	hotbarGui.heldLabel.Text = if held ~= nil then ItemLooks[held.itemId].name else ""
end

--[=[
	Shows the hotbar if `visible` is `true`, and hides it if not.
]=]
function HotbarGui.setVisible(hotbarGui: HotbarGui, visible: boolean)
	hotbarGui.screenGui.Enabled = visible
end

return HotbarGui
