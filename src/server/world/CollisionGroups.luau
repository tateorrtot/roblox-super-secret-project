--!strict
--- Which things in the Workspace pass through which.
---
--- Roblox sorts parts into named collision groups, and holds for each pair of groups whether
--- their parts collide. `register` makes two groups: one for the blocks that show ground items,
--- which pass through one another and through characters and collide with everything else, and
--- one for characters. `addCharacter` puts a character's parts in the second.
local PhysicsService = game:GetService("PhysicsService")

local CollisionGroups = {}

--- The name of the group that the blocks that show ground items are in.
CollisionGroups.GROUND_ITEMS = "GroundItems"

--- The name of the group that the parts of players' characters are in.
CollisionGroups.CHARACTERS = "Characters"

--- Makes the two groups, and sets that a part in `GROUND_ITEMS` passes through the other parts in
--- it and through the parts in `CHARACTERS`. Call it once, before any part is put in either.
function CollisionGroups.register()
	PhysicsService:RegisterCollisionGroup(CollisionGroups.GROUND_ITEMS)
	PhysicsService:RegisterCollisionGroup(CollisionGroups.CHARACTERS)
	PhysicsService:CollisionGroupSetCollidable(CollisionGroups.GROUND_ITEMS, CollisionGroups.GROUND_ITEMS, false)
	PhysicsService:CollisionGroupSetCollidable(CollisionGroups.GROUND_ITEMS, CollisionGroups.CHARACTERS, false)
end

--- Puts every part of `character` in `CHARACTERS`, and every part it is given afterwards, such as
--- the parts of an avatar that load a moment after the character appears.
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
