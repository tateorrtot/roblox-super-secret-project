--!strict
--[=[
	Keeps the game's own screens the right size for the window they are in.

	The screens are laid out in pixels for a window 900 wide and 620 tall. In
	a smaller window, such as a phone's, everything shrinks to fit, and in a
	larger one it grows a little.

	```lua
	ScreenScale.apply(panel) -- the panel and everything in it now fits this window, and stays fitted
	```
]=]
local Workspace = game:GetService("Workspace")

local ScreenScale = {}

local DESIGN_WIDTH = 900
local DESIGN_HEIGHT = 620
local SMALLEST = 0.45
local LARGEST = 1.3

--[=[
	Returns how much larger than their laid-out size the screens are drawn in
	this window now: 1 is the laid-out size, and 0.5 is half of it.
]=]
function ScreenScale.current(): number
	local camera = Workspace.CurrentCamera
	if camera == nil then
		return 1
	end
	local size = camera.ViewportSize
	return math.clamp(math.min(size.X / DESIGN_WIDTH, size.Y / DESIGN_HEIGHT), SMALLEST, LARGEST)
end

-- Every UIScale this has made, kept right by the two connections below.
local uiScales: { UIScale } = {}
local viewportChanged: RBXScriptConnection? = nil

local function refresh()
	local scale = ScreenScale.current()
	for _, uiScale in uiScales do
		uiScale.Scale = scale
	end
end

-- Follows the size of the camera there is now. Called again whenever the camera turns up or is replaced.
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

--[=[
	Scales `guiObject`, and everything inside it, to fit this window, and
	keeps it fitted when the window changes size. Returns the UIScale that
	does it.
]=]
function ScreenScale.apply(guiObject: GuiObject): UIScale
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = ScreenScale.current()
	uiScale.Parent = guiObject
	table.insert(uiScales, uiScale)
	return uiScale
end

return ScreenScale
