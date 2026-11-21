--!strict
--- How a stove looks in the world, and how it shows its fire.
---
--- `make` returns the Model of one stove, and `update` makes a stove's Model glow while its fire
--- is burning. The Model has the attribute `burning`, which is `true` while it glows. It is a
--- plain block until stoves have a model of their own: nothing else in the game knows what a
--- stove looks like.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlaceholderBlock = require(script.Parent.Parent.world.PlaceholderBlock)
local Plot = require(Shared.plots.Plot)
local Stove = require(Shared.content.Stove)

local StoveModel = {}

local UNLIT_COLOR = PlaceholderBlock.COLOR
local LIT_COLOR = UNLIT_COLOR:Lerp(Color3.fromRGB(255, 140, 40), 0.6)

local function showFire(block: BasePart, burning: boolean)
	block.Color = if burning then LIT_COLOR else UNLIT_COLOR
	block.Material = if burning then Enum.Material.Neon else Enum.Material.SmoothPlastic
	local light = block:FindFirstChild("Fire")
	if burning and light == nil then
		local fire = Instance.new("PointLight")
		fire.Name = "Fire"
		fire.Color = Color3.fromRGB(255, 160, 70)
		fire.Range = 14
		fire.Brightness = 1.5
		fire.Parent = block
	elseif not burning and light ~= nil then
		light:Destroy()
	end
end

--- Returns a new Model that shows one stove, with no fire, standing on its pivot.
function StoveModel.make(): Model
	return PlaceholderBlock.make(Stove.NAME)
end

--- Makes `model` glow if the fire of the stove that has the id `placedObjectId` on `plot` is
--- burning, and not if it is out. `model` is the Model that `make` returned for that stove.
--- Changes nothing if the Model shows that already.
function StoveModel.update(model: Model, plot: Plot.Plot, placedObjectId: number)
	local burning = Stove.isBurning(Stove.get(plot, placedObjectId))
	if model:GetAttribute("burning") ~= burning then
		model:SetAttribute("burning", burning)
		showFire(model.PrimaryPart :: BasePart, burning)
	end
end

return StoveModel
