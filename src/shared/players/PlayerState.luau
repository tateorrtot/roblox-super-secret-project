--!strict
--- One player: their pack, their hotbar, the inventory screen they have open, where their
--- character is, and how a stack they drop sets off.
local Hotbar = require("../inventory/Hotbar")
local Inventory = require("../inventory/Inventory")
local InventoryScreen = require("../inventory/InventoryScreen")
local Position = require("../Position")
local Throw = require("../Throw")

local PlayerState = {}

export type PlayerState = {
	--- The player's own inventory, which goes where they go.
	read pack: Inventory.Inventory,
	--- The first slots of the pack, and which of them is selected.
	read hotbar: Hotbar.Hotbar,
	--- The inventory screen the player has open. `nil` when none is open.
	screen: InventoryScreen.InventoryScreen?,
	--- The id of the placed item whose inventory `screen` shows beside the pack. `nil` when the
	--- pack is open alone, or no screen is open.
	openedPlacedItemId: number?,
	--- The point at the feet of the player's character. `nil` while they have no living
	--- character.
	position: Position.Position?,
	--- How a stack the player drops sets off into the world. While they have no living character
	--- it stays as it last was.
	throw: Throw.Throw,
}

--- How many slots a new player's pack has.
PlayerState.PACK_SLOT_COUNT = 36

--- How many of the pack's slots, counting from slot 1, are the hotbar.
PlayerState.HOTBAR_SLOT_COUNT = 9

--- Returns a new player with hotbar slot 1 selected, no screen open and no character. A stack
--- they drop sets off as `throw` says. They carry `pack`, or a pack that holds nothing if none is
--- given.
function PlayerState.new(throw: Throw.Throw, pack: Inventory.Inventory?): PlayerState
	local playerPack = pack or Inventory.new(PlayerState.PACK_SLOT_COUNT)
	return {
		pack = playerPack,
		hotbar = Hotbar.new(playerPack, PlayerState.HOTBAR_SLOT_COUNT),
		throw = throw,
	}
end

return PlayerState
