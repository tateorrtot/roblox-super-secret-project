--!strict
--- Keeps the game's own screens the right size for the window they are in.
---
--- The screens are laid out in pixels for a window 900 wide and 620 tall. `apply` makes a screen
--- shrink in a smaller window and grow a little in a larger one, and keeps it fitted when the
--- window changes size. `current` returns the factor that is used.
local Workspace = game:GetService("Workspace")

local ScreenScale = {}

local DESIGN_WIDTH = 900
local DESIGN_HEIGHT = 620
local SMALLEST = 0.45
local LARGEST = 1.3

--- Returns the factor the screens are scaled by in this window now: 1 draws them at their laid-out
--- size, and 0.5 at half of it. The factor is never below 0.45 or above 1.3, and is 1 while there
--- is no camera.
function ScreenScale.current(): number
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
	local scale = ScreenScale.current()
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

--- Scales `guiObject`, and everything inside it, to fit this window, and keeps it fitted when the
--- window changes size. Returns the `UIScale` that does it, which is now a child of `guiObject`.
function ScreenScale.apply(guiObject: GuiObject): UIScale
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = ScreenScale.current()
	uiScale.Parent = guiObject
	table.insert(uiScales, uiScale)
	return uiScale
end

return ScreenScale
