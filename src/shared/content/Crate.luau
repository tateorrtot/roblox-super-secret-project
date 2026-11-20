--!strict
--- A crate: a placed object that holds stacks of items.
---
--- `place` stands a crate on a tile of the world's plot and gives it an inventory. `interact`
--- and `breakPlacedObject` are what happens when a player interacts with a crate and breaks one:
--- if the player's character reaches it, the first opens that inventory on the player's screen,
--- and the second takes the crate off the plot and throws a crate item and everything that was in
--- the crate onto the ground.
---
--- Note: `interact` and `breakPlacedObject` are for a crate that `place` placed. A placed object
--- of the crate's kind that was put on the plot any other way has no inventory, and both fail
--- for it.
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local World = require("../world/World")

local Crate = {}

--- The id of the kind of placed object that a crate is.
Crate.PLACED_OBJECT_KIND_ID = "crate"

--- The id of the item that a broken crate leaves.
Crate.ITEM_ID_WHEN_BROKEN = "crate"

--- How many slots a crate's inventory has.
Crate.SLOT_COUNT = 27

--- Places a crate on the tile `tileX`, `tileZ` of the world's plot, and returns the placed
--- object's id. The crate is given an inventory of `SLOT_COUNT` slots, holding nothing. Fails if
--- `Plot.canPlaceObject` would return `false` for that tile.
function Crate.place(world: World.World, tileX: number, tileZ: number): number
	local placedObjectId = Plot.placeObject(world.plot, Crate.PLACED_OBJECT_KIND_ID, tileX, tileZ)
	World.addPlacedObjectInventory(world, placedObjectId, Inventory.new(Crate.SLOT_COUNT))
	return placedObjectId
end

local function getInventory(world: World.World, placedObjectId: number): Inventory.Inventory
	return world.placedObjectInventories[placedObjectId]
		or error(`the placed object {placedObjectId} is not a crate that Crate.place placed`, 3)
end

local function canPlayerReach(world: World.World, player: PlayerState.PlayerState, placedObjectId: number): boolean
	local placedObject = world.plot.placedObjectsById[placedObjectId]
	return World.canReachTile(world, player, placedObject.tileX, placedObject.tileZ)
end

--- A player interacts with the crate that has the id `placedObjectId`. If `World.canReachTile`
--- says that the player's character reaches the crate's tile, the crate's inventory opens on the
--- player's screen, beside their pack, in place of any screen they had open, and every slot of it
--- takes every item. Otherwise nothing happens.
function Crate.interact(world: World.World, player: PlayerState.PlayerState, placedObjectId: number)
	local inventory = getInventory(world, placedObjectId)
	if canPlayerReach(world, player, placedObjectId) then
		World.openPlacedObjectScreen(world, player, placedObjectId, inventory)
	end
end

--- A player breaks the crate that has the id `placedObjectId`. If `World.canReachTile` says that
--- the player's character reaches the crate's tile, the crate is taken off the plot, which closes
--- every screen that was open on it. One of the item `ITEM_ID_WHEN_BROKEN`, and then each stack
--- that was in the crate from the lowest slot up, is thrown onto the ground from the middle of the
--- crate's tile, upwards and outwards, each a different way. Otherwise nothing happens.
function Crate.breakPlacedObject(world: World.World, player: PlayerState.PlayerState, placedObjectId: number)
	local inventory = getInventory(world, placedObjectId)
	if not canPlayerReach(world, player, placedObjectId) then
		return
	end
	local placedObject = world.plot.placedObjectsById[placedObjectId]
	local stacks = Inventory.takeEveryStack(inventory)
	table.insert(stacks, 1, ItemStack.new(Crate.ITEM_ID_WHEN_BROKEN, 1))
	Plot.removePlacedObject(world.plot, placedObjectId)
	World.throwStacksFromTile(world, stacks, placedObject.tileX, placedObject.tileZ)
end

return Crate
