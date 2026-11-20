--!strict
--- What the crate item shows in the world while it is in the selected hotbar slot: a see-through
--- crate on the tile under the pointer.
---
--- It is only a picture on this player's machine. Whether a crate is placed is for
--- `CrateItem.interactWithTile` to say, on the server.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Crate = require(Shared.content.Crate)
local LocalCharacter = require(script.Parent.Parent.world.LocalCharacter)
local PlacedObjectLooks = require(Shared.content.PlacedObjectLooks)
local PlacementGhost = require(script.Parent.Parent.world.PlacementGhost)
local PlotPointer = require(script.Parent.Parent.world.PlotPointer)

local CrateItemGhost = {}

local look = PlacedObjectLooks[Crate.PLACED_OBJECT_KIND_ID]
local COLOR = Color3.fromRGB(look.color[1], look.color[2], look.color[3])
local ghost = PlacementGhost.new()

--- Shows the ghost as a crate on the tile that `pointerTarget` is, if it is a tile that the
--- player's character reaches. Hides the ghost if it is anything else, or `nil`.
function CrateItemGhost.update(pointerTarget: PlotPointer.Target?)
	if pointerTarget ~= nil and pointerTarget.kind == "tile" and LocalCharacter.canReachPoint(pointerTarget.center) then
		PlacementGhost.show(ghost, COLOR, pointerTarget.center)
	else
		PlacementGhost.hide(ghost)
	end
end

--- Hides the ghost. Does nothing if it is hidden already.
function CrateItemGhost.hide()
	PlacementGhost.hide(ghost)
end

return CrateItemGhost
