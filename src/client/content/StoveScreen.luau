--!strict
--- The layout of a stove's screen: its three slots, a fire gauge, and a work gauge.
---
--- The stove's input slot is above its fuel slot, with the fire gauge between them, and its output
--- slot is to the right, past the work gauge. `place` lays that out on the inventory screen's
--- panel, `hide` hides the gauges and the words, and `update` fills the two gauges. The layout is
--- a picture on the client: `Stove` runs on the server and says what a stove does.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local SlotGui = require(script.Parent.Parent.inventory.SlotGui)
local Stove = require(Shared.content.Stove)

local StoveScreen = {}

type Parts = {
	fireGauge: Frame,
	fireFill: Frame,
	workGauge: Frame,
	workFill: Frame,
	words: { TextLabel },
}

local FIRE_GAUGE_SIZE = Vector2.new(14, 40)
local WORK_GAUGE_HEIGHT = 12

--- The gauges and the words beside the slots. `place` makes them on its first call, on the panel
--- it is given, and they are `nil` until then.
local parts: Parts? = nil

local function makeGauge(panel: Frame, name: string, fill: Color3): (Frame, Frame)
	local gauge = Instance.new("Frame")
	gauge.Name = name
	gauge.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	gauge.BorderSizePixel = 0
	gauge.Visible = false
	gauge.Parent = panel
	local gaugeFill = Instance.new("Frame")
	gaugeFill.Name = "Fill"
	gaugeFill.BackgroundColor3 = fill
	gaugeFill.BorderSizePixel = 0
	gaugeFill.Parent = gauge
	return gauge, gaugeFill
end

local function makeSlotWords(panel: Frame, step: number): { TextLabel }
	local slotWords = {
		{ text = "In", alignment = Enum.TextXAlignment.Right },
		{ text = "Fuel", alignment = Enum.TextXAlignment.Right },
		{ text = "Out", alignment = Enum.TextXAlignment.Left },
	}
	local labels = {}
	for _, word in slotWords do
		local label = Instance.new("TextLabel")
		label.Name = word.text .. "Word"
		label.Size = UDim2.fromOffset(2 * step - 12, SlotGui.SIZE)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 13
		label.TextXAlignment = word.alignment
		label.TextColor3 = Color3.fromRGB(165, 166, 175)
		label.Text = word.text
		label.Visible = false
		label.Parent = panel
		table.insert(labels, label)
	end
	return labels
end

local function makeParts(panel: Frame, step: number): Parts
	local fireGauge, fireFill = makeGauge(panel, "FireGauge", Color3.fromRGB(255, 150, 50))
	fireGauge.Size = UDim2.fromOffset(FIRE_GAUGE_SIZE.X, FIRE_GAUGE_SIZE.Y)
	fireFill.AnchorPoint = Vector2.new(0, 1)
	fireFill.Position = UDim2.fromScale(0, 1)
	fireFill.Size = UDim2.fromScale(1, 0)
	local workGauge, workFill = makeGauge(panel, "WorkGauge", Color3.fromRGB(225, 225, 230))
	workFill.Size = UDim2.fromScale(0, 1)
	return {
		fireGauge = fireGauge,
		fireFill = fireFill,
		workGauge = workGauge,
		workFill = workFill,
		words = makeSlotWords(panel, step),
	}
end

local function setVisible(shown: Parts, visible: boolean)
	shown.fireGauge.Visible = visible
	shown.workGauge.Visible = visible
	for _, word in shown.words do
		word.Visible = visible
	end
end

--- Moves the stove's three slots to their places on `panel`, shows the two gauges and a word beside
--- each slot, and returns the height that the three slots take, in pixels. `slots` holds the slots
--- of the stove's inventory, by slot number. `origin` is the top left corner of the space that the
--- stove's slots take on `panel`, and `step` is the distance from one slot to the next, in pixels.
--- Note: `place` makes the gauges and the words on the first `panel` that it is given. They stay on
--- that panel, whatever `panel` a later call is given.
function StoveScreen.place(panel: Frame, slots: { SlotGui.SlotGui }, origin: Vector2, step: number): number
	local shown = parts or makeParts(panel, step)
	parts = shown
	local function cell(column: number, row: number): Vector2
		return Vector2.new(origin.X + (column - 1) * step, origin.Y + (row - 1) * step)
	end
	local input, fuel, output = cell(3, 1), cell(3, 3), cell(7, 2)
	slots[Stove.INPUT_SLOT].button.Position = UDim2.fromOffset(input.X, input.Y)
	slots[Stove.FUEL_SLOT].button.Position = UDim2.fromOffset(fuel.X, fuel.Y)
	slots[Stove.OUTPUT_SLOT].button.Position = UDim2.fromOffset(output.X, output.Y)

	local between = cell(3, 2)
	shown.fireGauge.Position = UDim2.fromOffset(
		between.X + (SlotGui.SIZE - FIRE_GAUGE_SIZE.X) / 2,
		between.Y + (SlotGui.SIZE - FIRE_GAUGE_SIZE.Y) / 2
	)
	local workLeft = cell(4, 2).X + 6
	shown.workGauge.Position = UDim2.fromOffset(workLeft, between.Y + (SlotGui.SIZE - WORK_GAUGE_HEIGHT) / 2)
	shown.workGauge.Size = UDim2.fromOffset(output.X - 10 - workLeft, WORK_GAUGE_HEIGHT)

	shown.words[1].Position = UDim2.fromOffset(cell(1, 1).X, input.Y)
	shown.words[2].Position = UDim2.fromOffset(cell(1, 3).X, fuel.Y)
	shown.words[3].Position = UDim2.fromOffset(cell(8, 2).X + 4, output.Y)
	setVisible(shown, true)
	return 2 * step + SlotGui.SIZE
end

--- Hides the gauges and the words. Does nothing if `place` was never called.
function StoveScreen.hide()
	if parts ~= nil then
		setVisible(parts, false)
	end
end

--- Fills the fire gauge and the work gauge as they stand at the time `now` on the world's clock,
--- in seconds. `screenData` is a `Stove.Progress`: what the stove's script told the client of the
--- stove whose screen is open. Does nothing if `screenData` is `nil`, or if `place` was never
--- called.
function StoveScreen.update(screenData: unknown, now: number)
	if parts == nil or screenData == nil then
		return
	end
	local progress = screenData :: Stove.Progress
	parts.fireFill.Size = UDim2.fromScale(1, Stove.getFuelLeftRatio(progress, now))
	parts.workFill.Size = UDim2.fromScale(Stove.getWorkDoneRatio(progress, now), 1)
end

return StoveScreen
