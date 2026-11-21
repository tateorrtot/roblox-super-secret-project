--!strict
--- The Model that shows a stove in the world, and glows while the stove's fire burns.
---
--- `make` returns a `PlaceholderBlock` named for the stove. `update` makes the Model glow while the
--- stove's fire is burning, and sets the Model's attribute `burning` to `true` or `false` to match.
--- Nothing else in the game knows what a stove looks like.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlaceholderBlock = require(script.Parent.Parent.world.PlaceholderBlock)
local Plot = require(Shared.plots.Plot)
local Stove = require(Shared.content.Stove)

local StoveModel = {}

--- The colour of the block while the stove's fire is out.
local UNLIT_COLOR = PlaceholderBlock.COLOR
--- The colour of the block while the stove's fire is burning: `UNLIT_COLOR`, 60 percent of the way
--- to orange.
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

--- Returns a new Model that shows one stove, standing on its pivot, with the label `Stove.NAME`.
--- The Model does not glow until `update` finds the stove's fire burning.
function StoveModel.make(): Model
	return PlaceholderBlock.make(Stove.NAME)
end

--- Makes `model` glow if the stove's fire is burning, and stop glowing if it is out. The stove is
--- the placed object with the id `placedObjectId` on `plot`, and `model` is the Model that `make`
--- returned for it. Changes nothing if `model` shows the fire's state already. Fails if
--- `Stove.get` fails for `plot` and `placedObjectId`.
function StoveModel.update(model: Model, plot: Plot.Plot, placedObjectId: number)
	local burning = Stove.isBurning(Stove.get(plot, placedObjectId))
	if model:GetAttribute("burning") ~= burning then
		model:SetAttribute("burning", burning)
		showFire(model.PrimaryPart :: BasePart, burning)
	end
end

return StoveModel
