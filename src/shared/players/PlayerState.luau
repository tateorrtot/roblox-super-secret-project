--!strict
--- One player: the pack they carry, their hotbar, the inventory screen they have open, and where
--- they stand.
local Hotbar = require("../inventory/Hotbar")
local Inventory = require("../inventory/Inventory")
local InventoryScreen = require("../inventory/InventoryScreen")
local Position = require("../Position")

local PlayerState = {}

export type PlayerState = {
	--- What the player carries.
	read pack: Inventory.Inventory,
	--- The first slots of the pack, and which of them is in the player's hand.
	read hotbar: Hotbar.Hotbar,
	--- The inventory screen the player has open. `nil` when none is open.
	screen: InventoryScreen.InventoryScreen?,
	--- The id of the placed item whose inventory `screen` shows beside the pack. `nil` when the pack
	--- is open alone, or no screen is open.
	openedPlacedId: number?,
	--- The point on the ground under the player's character. `nil` while they have no living character.
	position: Position.Position?,
	--- The point on the ground where a stack the player drops lands.
	dropPosition: Position.Position,
}

--- How many slots a new player's pack has.
PlayerState.PACK_SLOTS = 36

--- How many of the pack's slots, counting from slot 1, are the hotbar.
PlayerState.HOTBAR_SLOTS = 9

--- Returns a new player with hotbar slot 1 selected, no screen open and no character. A stack
--- they drop lands at `dropPosition`. They carry `pack`, or a pack that holds nothing if none is
--- given.
function PlayerState.new(dropPosition: Position.Position, pack: Inventory.Inventory?): PlayerState
	local playerPack = pack or Inventory.new(PlayerState.PACK_SLOTS)
	return {
		pack = playerPack,
		hotbar = Hotbar.new(playerPack, PlayerState.HOTBAR_SLOTS),
		dropPosition = dropPosition,
	}
end

return PlayerState
