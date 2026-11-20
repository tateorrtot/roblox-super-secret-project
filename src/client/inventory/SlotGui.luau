--!strict
--- One inventory slot drawn on the screen: a square button that shows the stack in the slot, or
--- nothing when the slot holds nothing.
---
--- The square is `button`: it is placed by setting its `Position`, and a click on the slot is a
--- click on it. `show` changes what the slot shows, and `setSelected` gives it a bright edge.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ItemStack = require(Shared.items.ItemStack)

local StackIcon = require(script.Parent.StackIcon)

local SlotGui = {}

export type SlotGui = {
	--- The square itself. It is a child of the parent given to `new`.
	read button: TextButton,
	--- The picture of the stack inside the square.
	read icon: StackIcon.StackIcon,
	--- The line around the square. It is bright while the slot is selected.
	read edge: UIStroke,
}

--- The length of a slot's side, in pixels before the screen is scaled.
SlotGui.SIZE = 52

local FILL = Color3.fromRGB(72, 73, 80)
local FILL_UNDER_POINTER = Color3.fromRGB(104, 105, 114)
local EDGE = Color3.fromRGB(22, 22, 26)
local EDGE_SELECTED = Color3.fromRGB(255, 255, 255)

--- Returns a new slot inside `parent`, showing nothing, at the top left of `parent`.
function SlotGui.new(parent: Instance): SlotGui
	local button = Instance.new("TextButton")
	button.Name = "Slot"
	button.Size = UDim2.fromOffset(SlotGui.SIZE, SlotGui.SIZE)
	button.BackgroundColor3 = FILL
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = ""

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	local edge = Instance.new("UIStroke")
	edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	edge.Thickness = 2
	edge.Color = EDGE
	edge.Parent = button

	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = FILL_UNDER_POINTER
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = FILL
	end)

	local icon = StackIcon.new(button)
	button.Parent = parent
	return { button = button, icon = icon, edge = edge }
end

--- Makes the slot show `stack`, or nothing if `stack` is `nil`.
function SlotGui.show(slotGui: SlotGui, stack: ItemStack.ItemStack?)
	StackIcon.show(slotGui.icon, stack)
end

--- Gives the slot a bright, thicker edge if `selected` is `true`, and its plain edge if not.
function SlotGui.setSelected(slotGui: SlotGui, selected: boolean)
	slotGui.edge.Color = if selected then EDGE_SELECTED else EDGE
	slotGui.edge.Thickness = if selected then 3 else 2
end

return SlotGui
