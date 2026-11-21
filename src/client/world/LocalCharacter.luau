--!strict
--- The local player's character, which the pieces that draw in the world ask about.
---
--- Note: the server decides what a character reaches, from where the server last saw the
--- character. `canReachPoint` answers from where the client has the character now.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage:WaitForChild("Shared").world.World)

local LocalCharacter = {}

--- Returns `true` if the character stands within `World.CHARACTER_REACH` of `point`, in studs
--- along the ground. Returns `false` while the local player has no living character: none at all,
--- one with no Humanoid or no root part, or one whose health is `0` or less.
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
