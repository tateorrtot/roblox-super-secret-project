--!strict
--- The Model that shows a crate in the world.
---
--- `make` returns a `PlaceholderBlock` named for the crate. Nothing else in the game knows what a
--- crate looks like.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Crate = require(ReplicatedStorage:WaitForChild("Shared").content.Crate)
local PlaceholderBlock = require(script.Parent.Parent.world.PlaceholderBlock)

local CrateModel = {}

--- Returns a new Model that shows one crate, standing on its pivot, with the label `Crate.NAME`.
function CrateModel.make(): Model
	return PlaceholderBlock.make(Crate.NAME)
end

return CrateModel
