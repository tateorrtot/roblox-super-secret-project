--!strict
--- A crate: a placed object that has an inventory.
---
--- `place` stands a crate on a tile of a plot, with an inventory on it that holds nothing.
--- `interact` and `breakPlacedObject` are what happens when a player interacts with a crate, and
--- when one is broken: the first opens the crate's inventory on the player's screen, and the
--- second takes the crate off the plot and throws a crate item and everything that was in the
--- crate onto the ground.
---
--- Note: `interact` and `breakPlacedObject` are for a crate that `place` placed. Both fail for a
--- placed object of another kind, and for one of the crate's kind with no inventory on it.
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local World = require("../world/World")

local Crate = {}

--- A crate standing on a plot: a placed object of the crate's kind, and the inventory that is in
--- it.
export type Crate = Plot.PlacedObject & {
	--- What the crate holds.
	read inventory: Inventory.Inventory,
}

--- The id of the kind of placed object that a crate is.
Crate.PLACED_OBJECT_KIND_ID = "crate"

--- The name shown for a crate.
Crate.NAME = "Crate"

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
	local placedObject = plot.placedObjectsById[placedObjectId]
	local isCrate = placedObject ~= nil
		and placedObject.kindId == Crate.PLACED_OBJECT_KIND_ID
		and (placedObject :: any).inventory ~= nil
	if not isCrate then
		error(`the placed object {placedObjectId} is not a crate that Crate.place placed`, 3)
	end
	return placedObject :: Crate
end

--- Returns the crate that has the id `placedObjectId` on `plot`. Fails if no placed object has
--- that id, or if the one that has is not of the crate's kind or has no inventory on it.
function Crate.get(plot: Plot.Plot, placedObjectId: number): Crate
	return getCrate(plot, placedObjectId)
end

--- A player interacts with the crate that has the id `placedObjectId` on the world's plot. The
--- crate's inventory opens on the player's screen, beside their pack, in place of any screen they
--- had open, and every slot of it takes every item. Fails if the player has no character. Fails if
--- no placed object has that id, or if the one that has is not of the crate's kind or has no
--- inventory on it.
function Crate.interact(world: World.World, player: PlayerState.PlayerState, placedObjectId: number)
	local crate = getCrate(world.plot, placedObjectId)
	World.openPlacedObjectScreen(world, player, placedObjectId, crate.inventory)
end

--- The crate that has the id `placedObjectId` on the world's plot is broken. The crate is taken
--- off the plot, which closes every screen that was open on it. One of the item
--- `ITEM_ID_WHEN_BROKEN`, and then each stack that was in the crate from the lowest slot up, is
--- thrown onto the ground from the middle of the crate's tile, upwards and outwards, each a
--- different way. The crate's inventory then holds nothing. Fails, changing nothing, if no placed
--- object has that id, or if the one that has is not of the crate's kind or has no inventory on it.
function Crate.breakPlacedObject(world: World.World, placedObjectId: number)
	local crate = getCrate(world.plot, placedObjectId)
	local stacks = Inventory.takeEveryStack(crate.inventory)
	table.insert(stacks, 1, ItemStack.new(Crate.ITEM_ID_WHEN_BROKEN, 1))
	Plot.removePlacedObject(world.plot, placedObjectId)
	World.throwStacksFromTile(world, stacks, crate.tileX, crate.tileZ)
end

return Crate
