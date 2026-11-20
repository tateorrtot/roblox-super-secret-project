--!strict
--- What the stove item shows in the world while it is in the selected hotbar slot: a see-through
--- stove on the tile under the pointer.
---
--- It is only a picture on this player's machine. Whether a stove is placed is for
--- `StoveItem.interactWithTile` to say, on the server.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalCharacter = require(script.Parent.Parent.world.LocalCharacter)
local PlacementGhost = require(script.Parent.Parent.world.PlacementGhost)
local PlotPointer = require(script.Parent.Parent.world.PlotPointer)
local Stove = require(ReplicatedStorage:WaitForChild("Shared").content.Stove)

local StoveItemGhost = {}

local ghost = PlacementGhost.new()

--- Shows the ghost as a stove on the tile that `pointerTarget` is, if it is a tile that the
--- player's character reaches. Hides the ghost if it is anything else, or `nil`.
function StoveItemGhost.update(pointerTarget: PlotPointer.Target?)
	if pointerTarget ~= nil and pointerTarget.kind == "tile" and LocalCharacter.canReachPoint(pointerTarget.center) then
		PlacementGhost.show(ghost, Stove.PLACED_OBJECT_KIND_ID, pointerTarget.center)
	else
		PlacementGhost.hide(ghost)
	end
end

--- Hides the ghost. Does nothing if it is hidden already.
function StoveItemGhost.hide()
	PlacementGhost.hide(ghost)
end

return StoveItemGhost
