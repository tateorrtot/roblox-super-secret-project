--!strict
--- A click of an input action: a press that ends quickly, with the camera facing the same way at
--- both moments.
---
--- `connect` calls a callback for each click. A press that lasts, or that turns the camera, is not
--- a click.
local Workspace = game:GetService("Workspace")

local BreakClick = {}

--- The time, in seconds, that a press must be shorter than to be a click.
BreakClick.RELEASED_WITHIN_SECONDS = 0.35

--- The camera has turned between the press and the release if the dot product of the two
--- directions that it looked in is below this. The dot product of two directions is from `-1` to
--- `1`.
BreakClick.CAMERA_TURNED_BELOW = 0.9995

local function getCameraLook(): Vector3
	local camera = Workspace.CurrentCamera
	return if camera then camera.CFrame.LookVector else Vector3.zero
end

--- Connects `callback` to the clicks of `breakAction`. Calls `callback`, with no arguments, each
--- time `breakAction` is released within `RELEASED_WITHIN_SECONDS` of being pressed, unless the
--- camera has turned since the press, as `CAMERA_TURNED_BELOW` measures it. A release with no
--- press before it calls nothing.
function BreakClick.connect(breakAction: InputAction, callback: () -> ())
	local pressedAt: number? = nil
	local lookWhenPressed = Vector3.zero

	breakAction.Pressed:Connect(function()
		pressedAt = os.clock()
		lookWhenPressed = getCameraLook()
	end)

	breakAction.Released:Connect(function()
		local heldSeconds = if pressedAt ~= nil then os.clock() - pressedAt else math.huge
		pressedAt = nil
		if
			heldSeconds < BreakClick.RELEASED_WITHIN_SECONDS
			and getCameraLook():Dot(lookWhenPressed) >= BreakClick.CAMERA_TURNED_BELOW
		then
			callback()
		end
	end)
end

return BreakClick
