--!strict
--- A click of the Break action: the action pressed and let go again quickly, with the camera
--- facing the same way at both moments.
---
--- The right mouse button is bound to the Break action, and Roblox's camera turns while that
--- button is held. So a press that lasts, or that turns the camera, is the player looking about,
--- and only a click breaks.
local Workspace = game:GetService("Workspace")

local BreakClick = {}

--- A press is a click only if the action is released within this many seconds of it.
BreakClick.RELEASED_WITHIN_SECONDS = 0.35

--- The camera has turned between two moments if the dot product of the two directions it looked
--- in is below this.
BreakClick.CAMERA_TURNED_BELOW = 0.9995

local function getCameraLook(): Vector3
	local camera = Workspace.CurrentCamera
	return if camera then camera.CFrame.LookVector else Vector3.zero
end

--- Connects `callback` to the clicks of `breakAction`. From then on it is called, with nothing,
--- each time the action is released within `RELEASED_WITHIN_SECONDS` of being pressed, unless the
--- camera has turned since the press, as `CAMERA_TURNED_BELOW` measures it.
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
