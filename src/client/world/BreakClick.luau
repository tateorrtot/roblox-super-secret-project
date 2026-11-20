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
BreakClick.WITHIN_SECONDS = 0.35

--- The camera faces the same way at two moments if the dot product of the two directions it
--- looked in is this or more.
BreakClick.SAME_DIRECTION = 0.9995

local function getCameraLook(): Vector3
	local camera = Workspace.CurrentCamera
	return if camera then camera.CFrame.LookVector else Vector3.zero
end

--- Connects `callback` to the clicks of `breakAction`. From then on it is called, with nothing,
--- each time the action is released within `WITHIN_SECONDS` of being pressed while the camera
--- faces the way it did at the press, as `SAME_DIRECTION` measures it.
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
			heldSeconds < BreakClick.WITHIN_SECONDS
			and getCameraLook():Dot(lookWhenPressed) >= BreakClick.SAME_DIRECTION
		then
			callback()
		end
	end)
end

return BreakClick
