--!strict
--- A crate: a placed object that has an inventory.
---
--- `place` stands a crate on a tile of a plot, with an inventory on it that holds nothing.
--- `interact` and `breakPlacedObject` are the crate's script. `interact` opens the crate's
--- inventory on a player's screen. `breakPlacedObject` takes the crate off the plot and throws a
--- crate item, and everything that was in the crate, onto the ground.
---
--- Note: `interact` and `breakPlacedObject` are for a crate that `place` placed. Both raise an
--- error for a placed object of another kind, and for one of the crate's kind with no inventory on
--- it.
local Inventory = require("../inventory/Inventory")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("../players/PlayerState")
local Plot = require("../plots/Plot")
local World = require("../world/World")

local Crate = {}

--- A placed object of the crate's kind, with an inventory on it.
export type Crate = Plot.PlacedObject & {
	--- The crate's inventory, which holds what is in the crate.
	read inventory: Inventory.Inventory,
}

--- The `kindId` that every crate has.
Crate.PLACED_OBJECT_KIND_ID = "crate"

--- The name shown for a crate.
Crate.NAME = "Crate"

--- The id of the item that `breakPlacedObject` throws onto the ground.
Crate.ITEM_ID_WHEN_BROKEN = "crate"

--- How many slots a crate's inventory has.
Crate.SLOT_COUNT = 27

--- Stands a crate on the tile at `tileX`, `tileZ` of `plot`, and returns the placed object's id.
--- The crate has an inventory of `SLOT_COUNT` slots on it, holding nothing. Raises an error if
--- `Plot.canPlaceObject` would return `false` for that tile.
--- Note: `place` does not ask `World.canPlaceObject`, so a character that stands on the tile does
--- not stop it.
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

--- Returns the crate `placedObjectId` on `plot`. Raises an error if no placed object has that id,
--- or if the one that has is not of the crate's kind or has no inventory on it.
function Crate.get(plot: Plot.Plot, placedObjectId: number): Crate
	return getCrate(plot, placedObjectId)
end

--- Opens the inventory of the crate `placedObjectId` on the world's plot, beside the pack on the
--- player's screen, as `World.openPlacedObjectScreen` does. It closes any screen that the player
--- had open first. Every slot of the crate's inventory accepts every item. Raises an error, and
--- changes nothing, if the player has no character, if no placed object has that id, or if the one
--- that has is not of the crate's kind or has no inventory on it.
function Crate.interact(world: World.World, player: PlayerState.PlayerState, placedObjectId: number)
	local crate = getCrate(world.plot, placedObjectId)
	World.openPlacedObjectScreen(world, player, placedObjectId, crate.inventory)
end

--- Breaks the crate `placedObjectId` on the world's plot. Takes the crate off the plot, which
--- closes every screen that was open on it. Throws one of the item `ITEM_ID_WHEN_BROKEN`, and then
--- each stack that was in the crate, from the lowest slot up, from the middle of the crate's tile,
--- upwards and outwards, each a different way, as `World.throwStacksFromTile` does. The crate's
--- inventory then holds nothing. Raises an error, and changes nothing, if no placed object has that
--- id, or if the one that has is not of the crate's kind or has no inventory on it.
function Crate.breakPlacedObject(world: World.World, placedObjectId: number)
	local crate = getCrate(world.plot, placedObjectId)
	local stacks = Inventory.takeEveryStack(crate.inventory)
	table.insert(stacks, 1, ItemStack.new(Crate.ITEM_ID_WHEN_BROKEN, 1))
	Plot.removePlacedObject(world.plot, placedObjectId)
	World.throwStacksFromTile(world, stacks, crate.tileX, crate.tileZ)
end

return Crate
