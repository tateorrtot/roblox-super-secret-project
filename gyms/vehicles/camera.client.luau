-- A gym. Runs on the client of a play test. Keeps the camera on one body of the vehicle gym, from
-- above and behind, so that a screenshot shows it. `run.py` puts the line that sets VEHICLE above.
-- The game's own camera code moves the camera every frame, so this binds a step that runs after it.
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local gym = Workspace:WaitForChild("VehicleGym", 10)
local model = gym and gym:WaitForChild(VEHICLE, 10)
local root = model and (model :: Model):WaitForChild("Root", 10)
if root == nil then
	return "no body named " .. VEHICLE
end
local camera = Workspace.CurrentCamera
pcall(function()
	RunService:UnbindFromRenderStep("VehicleGymCamera")
end)
RunService:BindToRenderStep("VehicleGymCamera", Enum.RenderPriority.Camera.Value + 10, function()
	camera.CameraType = Enum.CameraType.Scriptable
	local target = (root :: BasePart).Position
	camera.CFrame = CFrame.lookAt(target + Vector3.new(22, 15, 24), target)
end)
task.wait(1.5)
local target = (root :: BasePart).Position
return string.format("camera follows %s, at %.1f, %.1f, %.1f", VEHICLE, target.X, target.Y, target.Z)
