--!strict
--- A scale that fits the screens to the window they are in.
---
--- The screens are laid out in pixels for a window 900 wide and 620 tall. `applyTo` makes a screen
--- shrink in a smaller window and grow in a larger one, and keeps it fitted when the window changes
--- size. `getFactor` returns the factor that `applyTo` scales by.
local Workspace = game:GetService("Workspace")

local ScreenScale = {}

local DESIGN_WIDTH = 900
local DESIGN_HEIGHT = 620
local SMALLEST = 0.45
local LARGEST = 1.3

--- Returns the factor that the screens are scaled by for the camera's current viewport: `1` draws
--- them at their laid-out size, and `0.5` at half of it. The factor is the smaller of the
--- viewport's width over 900 and its height over 620, never below `0.45` or above `1.3`. Returns
--- `1` while there is no camera.
function ScreenScale.getFactor(): number
	local camera = Workspace.CurrentCamera
	if camera == nil then
		return 1
	end
	local size = camera.ViewportSize
	return math.clamp(math.min(size.X / DESIGN_WIDTH, size.Y / DESIGN_HEIGHT), SMALLEST, LARGEST)
end

local uiScales: { UIScale } = {}
local viewportChanged: RBXScriptConnection? = nil

local function refresh()
	local scale = ScreenScale.getFactor()
	for _, uiScale in uiScales do
		uiScale.Scale = scale
	end
end

local function followCamera()
	if viewportChanged ~= nil then
		viewportChanged:Disconnect()
		viewportChanged = nil
	end
	local camera = Workspace.CurrentCamera
	if camera ~= nil then
		viewportChanged = camera:GetPropertyChangedSignal("ViewportSize"):Connect(refresh)
	end
	refresh()
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(followCamera)
followCamera()

--- Adds a `UIScale` to `guiObject` that scales `guiObject`, and everything inside it, by
--- `getFactor`, and keeps its `Scale` equal to `getFactor` as the viewport changes size. Returns
--- the `UIScale`.
function ScreenScale.applyTo(guiObject: GuiObject): UIScale
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = ScreenScale.getFactor()
	uiScale.Parent = guiObject
	table.insert(uiScales, uiScale)
	return uiScale
end

return ScreenScale
