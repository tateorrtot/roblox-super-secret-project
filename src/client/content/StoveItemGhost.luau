--!strict
--- A see-through block on the tile under the pointer, shown while the stove item is in the selected
--- hotbar slot.
---
--- `update` shows or hides the block, and `hide` hides it. The block is a picture on the client and
--- places nothing: `StoveItem.interactWithTile` runs on the server and decides whether a stove is
--- placed.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local LocalCharacter = require(script.Parent.Parent.world.LocalCharacter)
local PlacementGhost = require(script.Parent.Parent.world.PlacementGhost)
local PlotPointer = require(script.Parent.Parent.world.PlotPointer)
local StoveItem = require(Shared.content.StoveItem)

local StoveItemGhost = {}

local ghost = PlacementGhost.new()
ghost.part:SetAttribute("itemId", StoveItem.id)

--- Shows the block on the tile that `pointerTarget` is, if `pointerTarget` is a tile that the
--- player's character reaches. Hides the block for anything else, `nil` included.
function StoveItemGhost.update(pointerTarget: PlotPointer.Target?)
	if pointerTarget ~= nil and pointerTarget.kind == "tile" and LocalCharacter.canReachPoint(pointerTarget.center) then
		PlacementGhost.show(ghost, pointerTarget.center)
	else
		PlacementGhost.hide(ghost)
	end
end

--- Hides the block. Does nothing if the block is hidden already.
function StoveItemGhost.hide()
	PlacementGhost.hide(ghost)
end

return StoveItemGhost
