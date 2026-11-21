--!strict
--- A see-through block on the tile under the pointer, shown while the crate item is in the selected
--- hotbar slot.
---
--- `update` shows or hides the block, and `hide` hides it. The block is a picture on the client and
--- places nothing: `CrateItem.interactWithTile` runs on the server and decides whether a crate is
--- placed.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CrateItem = require(Shared.content.CrateItem)
local LocalCharacter = require(script.Parent.Parent.world.LocalCharacter)
local PlacementGhost = require(script.Parent.Parent.world.PlacementGhost)
local PlotPointer = require(script.Parent.Parent.world.PlotPointer)

local CrateItemGhost = {}

local ghost = PlacementGhost.new()
ghost.part:SetAttribute("itemId", CrateItem.id)

--- Shows the block on the tile that `pointerTarget` is, if `pointerTarget` is a tile that the
--- player's character reaches. Hides the block for anything else, `nil` included.
function CrateItemGhost.update(pointerTarget: PlotPointer.Target?)
	if pointerTarget ~= nil and pointerTarget.kind == "tile" and LocalCharacter.canReachPoint(pointerTarget.center) then
		PlacementGhost.show(ghost, pointerTarget.center)
	else
		PlacementGhost.hide(ghost)
	end
end

--- Hides the block. Does nothing if the block is hidden already.
function CrateItemGhost.hide()
	PlacementGhost.hide(ghost)
end

return CrateItemGhost
