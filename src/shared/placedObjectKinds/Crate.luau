--!strict
--- A crate: a placed object that holds stacks of items.
---
--- `place` stands a crate on a tile of the world's plot and gives it an inventory. `interact`
--- opens that inventory on a player's screen. `breakPlacedObject` takes the crate off the plot,
--- and throws a crate item and everything that was in the crate onto the ground.
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local World = require("../world/World")

local Crate = {}

--- The id of the kind of placed object that a crate is.
Crate.KIND_ID = "crate"

--- The id of the item that a broken crate leaves.
Crate.ITEM_ID = "crate"

--- How many slots a crate's inventory has.
Crate.SLOT_COUNT = 27

--- Places a crate on the tile `tileX`, `tileZ` of the world's plot, and returns the placed
--- object's id. The crate is given an inventory of `SLOT_COUNT` slots, holding nothing. Fails if
--- `Plot.canPlaceObject` would return `false` for that tile.
function Crate.place(world: World.World, tileX: number, tileZ: number): number
	local placedObjectId = Plot.placeObject(world.plot, Crate.KIND_ID, tileX, tileZ)
	World.addPlacedObjectInventory(world, placedObjectId, Inventory.new(Crate.SLOT_COUNT))
	return placedObjectId
end

--- A player interacts with the crate that has the id `placedObjectId`. The crate's inventory
--- opens on the player's screen, beside their pack, in place of any screen they had open. Every
--- slot of it takes every item. Fails if the player has no character.
function Crate.interact(world: World.World, player: PlayerState.PlayerState, placedObjectId: number)
	World.openPlacedObjectScreen(world, player, placedObjectId, world.placedObjectInventories[placedObjectId])
end

--- A player breaks the crate that has the id `placedObjectId`. The crate is taken off the plot,
--- which closes every screen that was open on it. One of the item `ITEM_ID`, and then each stack
--- that was in the crate from the lowest slot up, is thrown onto the ground from the middle of
--- the crate's tile, upwards and outwards, each a different way.
function Crate.breakPlacedObject(world: World.World, _player: PlayerState.PlayerState, placedObjectId: number)
	local placedObject = world.plot.placedObjectsById[placedObjectId]
	local stacks = Inventory.takeEveryStack(world.placedObjectInventories[placedObjectId])
	table.insert(stacks, 1, ItemStack.new(Crate.ITEM_ID, 1))
	Plot.removePlacedObject(world.plot, placedObjectId)
	World.throwStacksFromTile(world, stacks, placedObject.tileX, placedObject.tileZ)
end

return Crate
