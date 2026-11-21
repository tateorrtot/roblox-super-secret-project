--!strict
--- How a crate looks in the world.
---
--- `make` returns the Model of one crate. It is a plain block until crates have a model of their
--- own: nothing else in the game knows what a crate looks like.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Crate = require(ReplicatedStorage:WaitForChild("Shared").content.Crate)
local PlaceholderBlock = require(script.Parent.Parent.world.PlaceholderBlock)

local CrateModel = {}

--- Returns a new Model that shows one crate, standing on its pivot.
function CrateModel.make(): Model
	return PlaceholderBlock.make(Crate.NAME)
end

return CrateModel
