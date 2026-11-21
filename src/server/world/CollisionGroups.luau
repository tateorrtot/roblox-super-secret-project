--!strict
--- Two collision groups: one for the blocks that show ground items, and one for characters.
---
--- `register` makes the groups `GROUND_ITEMS` and `CHARACTERS`. A part in `GROUND_ITEMS` passes
--- through the other parts in it and through the parts in `CHARACTERS`, and collides with every
--- other part. `addCharacter` puts a character's parts in `CHARACTERS`.
local PhysicsService = game:GetService("PhysicsService")

local CollisionGroups = {}

--- The name of the collision group of the blocks that show ground items.
CollisionGroups.GROUND_ITEMS = "GroundItems"

--- The name of the collision group of the parts of players' characters.
CollisionGroups.CHARACTERS = "Characters"

--- Registers `GROUND_ITEMS` and `CHARACTERS`, and sets that a part in `GROUND_ITEMS` passes
--- through the other parts in it and through the parts in `CHARACTERS`.
--- Note: call `register` once, before any part is put in either group.
function CollisionGroups.register()
	PhysicsService:RegisterCollisionGroup(CollisionGroups.GROUND_ITEMS)
	PhysicsService:RegisterCollisionGroup(CollisionGroups.CHARACTERS)
	PhysicsService:CollisionGroupSetCollidable(CollisionGroups.GROUND_ITEMS, CollisionGroups.GROUND_ITEMS, false)
	PhysicsService:CollisionGroupSetCollidable(CollisionGroups.GROUND_ITEMS, CollisionGroups.CHARACTERS, false)
end

--- Puts every part of `character` in `CHARACTERS`, and every part that `character` gains
--- afterwards, such as the parts of an avatar that load after the character appears.
function CollisionGroups.addCharacter(character: Model)
	local function addPart(instance: Instance)
		if instance:IsA("BasePart") then
			instance.CollisionGroup = CollisionGroups.CHARACTERS
		end
	end
	for _, descendant in character:GetDescendants() do
		addPart(descendant)
	end
	character.DescendantAdded:Connect(addPart)
end

return CollisionGroups
