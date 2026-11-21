--!strict
--- A crate: a placed object that has an inventory.
---
--- `place` stands a crate on a tile of a plot, with an inventory on it that holds nothing.
--- `interact` and `breakPlacedObject` are what happens when a player interacts with a crate, and
--- when one is broken: the first opens the crate's inventory on the player's screen, and the
--- second takes the crate off the plot and throws a crate item and everything that was in the
--- crate onto the ground.
---
--- Note: `interact` and `breakPlacedObject` are for a crate that `place` placed. A placed object
--- of the crate's kind that was put on the plot with no inventory on it is no `Crate`, and both
--- fail for it.
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local World = require("../world/World")

local Crate = {}

--- A crate standing on a plot: a placed object, and the inventory that is in it.
export type Crate = Plot.PlacedObject & {
	--- What the crate holds. A crate has the same inventory for as long as it stands.
	read inventory: Inventory.Inventory,
}

--- The id of the kind of placed object that a crate is.
Crate.PLACED_OBJECT_KIND_ID = "crate"

--- The id of the item that a broken crate leaves.
Crate.ITEM_ID_WHEN_BROKEN = "crate"

--- How many slots a crate's inventory has.
Crate.SLOT_COUNT = 27

--- Places a crate on the tile `tileX`, `tileZ` of `plot`, and returns the placed object's id. The
--- crate has an inventory of `SLOT_COUNT` slots on it, holding nothing. Fails if
--- `Plot.canPlaceObject` would return `false` for that tile.
function Crate.place(plot: Plot.Plot, tileX: number, tileZ: number): number
	local crate: Crate = {
		kindId = Crate.PLACED_OBJECT_KIND_ID,
		tileX = tileX,
		tileZ = tileZ,
		inventory = Inventory.new(Crate.SLOT_COUNT),
	}
	return Plot.placeObject(plot, crate)
end

local function getCrate(plot: Plot.Plot, placedObjectId: number): Crate
	local crate = plot.placedObjectsById[placedObjectId] :: Crate?
	if crate == nil or crate.inventory == nil then
		error(`the placed object {placedObjectId} is not a crate that Crate.place placed`, 3)
	end
	return crate
end

--- A player interacts with the crate that has the id `placedObjectId` on the world's plot. The
--- crate's inventory opens on the player's screen, beside their pack, in place of any screen they
--- had open, and every slot of it takes every item. Fails if the player has no character.
function Crate.interact(world: World.World, player: PlayerState.PlayerState, placedObjectId: number)
	local crate = getCrate(world.plot, placedObjectId)
	World.openPlacedObjectScreen(world, player, placedObjectId, crate.inventory)
end

--- The crate that has the id `placedObjectId` on the world's plot is broken. The crate is taken
--- off the plot, which closes every screen that was open on it. One of the item
--- `ITEM_ID_WHEN_BROKEN`, and then each stack that was in the crate from the lowest slot up, is
--- thrown onto the ground from the middle of the crate's tile, upwards and outwards, each a
--- different way. The crate's inventory then holds nothing.
function Crate.breakPlacedObject(world: World.World, placedObjectId: number)
	local crate = getCrate(world.plot, placedObjectId)
	local stacks = Inventory.takeEveryStack(crate.inventory)
	table.insert(stacks, 1, ItemStack.new(Crate.ITEM_ID_WHEN_BROKEN, 1))
	Plot.removePlacedObject(world.plot, placedObjectId)
	World.throwStacksFromTile(world, stacks, crate.tileX, crate.tileZ)
end

return Crate
