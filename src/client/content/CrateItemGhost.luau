--!strict
--- What the crate item shows in the world while it is in the selected hotbar slot: a see-through
--- crate on the tile under the pointer.
---
--- It is only a picture on this player's machine. Whether a crate is placed is for
--- `CrateItem.interactWithTile` to say, on the server.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Crate = require(ReplicatedStorage:WaitForChild("Shared").content.Crate)
local LocalCharacter = require(script.Parent.Parent.world.LocalCharacter)
local PlacementGhost = require(script.Parent.Parent.world.PlacementGhost)
local PlotPointer = require(script.Parent.Parent.world.PlotPointer)

local CrateItemGhost = {}

local ghost = PlacementGhost.new()

--- Shows the ghost as a crate on the tile that `pointerTarget` is, if it is a tile that the
--- player's character reaches. Hides the ghost if it is anything else, or `nil`.
function CrateItemGhost.update(pointerTarget: PlotPointer.Target?)
	if pointerTarget ~= nil and pointerTarget.kind == "tile" and LocalCharacter.canReachPoint(pointerTarget.center) then
		PlacementGhost.show(ghost, Crate.PLACED_OBJECT_KIND_ID, pointerTarget.center)
	else
		PlacementGhost.hide(ghost)
	end
end

--- Hides the ghost. Does nothing if it is hidden already.
function CrateItemGhost.hide()
	PlacementGhost.hide(ghost)
end

return CrateItemGhost
