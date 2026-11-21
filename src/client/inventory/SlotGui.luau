--!strict
--- A square button that shows the stack in one inventory slot, or nothing if the slot holds nothing.
---
--- The square is `button`: its `Position` places the slot, and its events report the clicks on the
--- slot. `setStack` changes the stack that the slot shows, and `setSelected` gives the slot a
--- bright edge. The button's fill brightens while the pointer is over it.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ItemStack = require(Shared.items.ItemStack)

local StackIcon = require(script.Parent.StackIcon)

local SlotGui = {}

--- A slot as drawn on the screen: its button, the icon of its stack, and its edge.
export type SlotGui = {
	--- The square. It is a child of the parent that was given to `new`.
	read button: TextButton,
	--- The icon of the stack, inside the square.
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

--- Returns a new slot in `parent`, at the top left corner of `parent`, with a plain edge and
--- showing nothing.
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

--- Shows `stack` in the slot, or nothing if `stack` is `nil`.
function SlotGui.setStack(slotGui: SlotGui, stack: ItemStack.ItemStack?)
	StackIcon.setStack(slotGui.icon, stack)
end

--- Gives the slot a bright, thicker edge if `selected` is `true`, and a plain edge if `selected` is
--- `false`.
function SlotGui.setSelected(slotGui: SlotGui, selected: boolean)
	slotGui.edge.Color = if selected then EDGE_SELECTED else EDGE
	slotGui.edge.Thickness = if selected then 3 else 2
end

return SlotGui
