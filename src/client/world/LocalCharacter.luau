--!strict
--- The character of the player at this machine, for the pieces that draw in the world.
---
--- Note: what a character reaches is decided on the server, from where the server last saw the
--- character. `canReachPoint` says only what to show.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage:WaitForChild("Shared").world.World)

local LocalCharacter = {}

--- Returns `true` if the character stands within `World.CHARACTER_REACH` of `point`, in studs
--- along the ground. Returns `false` while the player has no living character: none at all, one
--- with no root part, or one whose health is 0.
function LocalCharacter.canReachPoint(point: Vector3): boolean
	local character = Players.LocalPlayer.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if humanoid == nil or humanoid.Health <= 0 or root == nil or not root:IsA("BasePart") then
		return false
	end
	local away = point - root.Position
	return Vector3.new(away.X, 0, away.Z).Magnitude <= World.CHARACTER_REACH
end

return LocalCharacter
