--!strict
--- What a stove's block shows of its fire: the block glows while the fire is burning.
---
--- `update` makes one stove's block match its stove. The block has the attribute `burning`, which
--- is `true` while the stove's fire is burning. The glow is a placeholder until stoves have a
--- model.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlacedObjectLooks = require(Shared.content.PlacedObjectLooks)
local Plot = require(Shared.plots.Plot)
local Stove = require(Shared.content.Stove)

local StoveGlow = {}

local look = PlacedObjectLooks[Stove.PLACED_OBJECT_KIND_ID]
local UNLIT_COLOR = Color3.fromRGB(look.color[1], look.color[2], look.color[3])
local LIT_COLOR = UNLIT_COLOR:Lerp(Color3.fromRGB(255, 140, 40), 0.6)

local function showFire(part: Part, burning: boolean)
	part.Color = if burning then LIT_COLOR else UNLIT_COLOR
	part.Material = if burning then Enum.Material.Neon else Enum.Material.SmoothPlastic
	local light = part:FindFirstChild("Fire")
	if burning and light == nil then
		local fire = Instance.new("PointLight")
		fire.Name = "Fire"
		fire.Color = Color3.fromRGB(255, 160, 70)
		fire.Range = 14
		fire.Brightness = 1.5
		fire.Parent = part
	elseif not burning and light ~= nil then
		light:Destroy()
	end
end

--- Makes `part` glow if the fire of the stove that has the id `placedObjectId` on `plot` is
--- burning, and not if it is out. `part` is that stove's block. Changes nothing if the block
--- shows that already.
function StoveGlow.update(part: Part, plot: Plot.Plot, placedObjectId: number)
	local burning = Stove.isBurning(Stove.get(plot, placedObjectId))
	if part:GetAttribute("burning") ~= burning then
		part:SetAttribute("burning", burning)
		showFire(part, burning)
	end
end

return StoveGlow
