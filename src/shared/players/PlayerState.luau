--!strict
--- One player: their pack, their hotbar, the inventory screen they have open, and their character
--- in the world.
---
--- `openPackScreen` and `openPlacedItemScreen` open the player's inventory screen, and
--- `closeScreen` closes it. Only a player with a character can have a screen open, and
--- `canOpenScreen` says whether one can be opened now.
local Hotbar = require("../inventory/Hotbar")
local Inventory = require("../inventory/Inventory")
local InventoryScreen = require("../inventory/InventoryScreen")
local ItemStack = require("../items/ItemStack")
local Position = require("../Position")

local PlayerState = {}

--- A player's character in the world.
export type Character = {
	--- Where it is: the point at its feet.
	read position: Position.Position,
}

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
	--- The player's character. `nil` while they have no living character.
	character: Character?,
}

--- How many slots a new player's pack has.
PlayerState.PACK_SLOT_COUNT = 36

--- How many of the pack's slots, counting from slot 1, are the hotbar.
PlayerState.HOTBAR_SLOT_COUNT = 9

--- Returns a new player with hotbar slot 1 selected, no screen open and no character. They carry
--- `pack`, or a pack that holds nothing if none is given.
function PlayerState.new(pack: Inventory.Inventory?): PlayerState
	local playerPack = pack or Inventory.new(PlayerState.PACK_SLOT_COUNT)
	return {
		pack = playerPack,
		hotbar = Hotbar.new(playerPack, PlayerState.HOTBAR_SLOT_COUNT),
	}
end

--- Sets where the player's character is, at its feet. A player who had no character has one from
--- now on.
function PlayerState.setCharacterPosition(player: PlayerState, position: Position.Position)
	player.character = table.freeze({ position = position })
end

--- Removes the player's character: they have none until `setCharacterPosition` is next called.
--- Does nothing if they have no character. Fails if the player has a screen open: close it first.
function PlayerState.removeCharacter(player: PlayerState)
	if player.screen ~= nil then
		error("a player with a screen open must keep their character", 2)
	end
	player.character = nil
end

--- Returns `true` if a screen can be opened for the player: they have a character, and no
--- screen open.
function PlayerState.canOpenScreen(player: PlayerState): boolean
	return player.screen == nil and player.character ~= nil
end

--- Opens the player's inventory screen on their pack alone. Fails if `canOpenScreen` would return
--- `false`: a screen opened over another would lose the stack that was carried, and only a player
--- with a character has a screen.
function PlayerState.openPackScreen(player: PlayerState)
	if not PlayerState.canOpenScreen(player) then
		error("a screen can be opened only for a player with a character and no screen open", 2)
	end
	player.screen = InventoryScreen.new(player.pack)
end

--- Opens the player's inventory screen on their pack with the inventory of a placed item beside
--- it. `placedItemId` is the placed item's id and `inventory` is what is inside it.
--- `slotAcceptsItem`, if given, says whether a slot of `inventory` takes an item: it is called
--- with the slot and the item's id. Fails if `canOpenScreen` would return `false`.
function PlayerState.openPlacedItemScreen(
	player: PlayerState,
	placedItemId: number,
	inventory: Inventory.Inventory,
	slotAcceptsItem: ((slot: number, itemId: string) -> boolean)?
)
	if not PlayerState.canOpenScreen(player) then
		error("a screen can be opened only for a player with a character and no screen open", 2)
	end
	player.screen = InventoryScreen.new(player.pack, inventory, slotAcceptsItem)
	player.openedPlacedItemId = placedItemId
end

--- Closes the player's inventory screen. The stack they were carrying goes back into their pack,
--- and what does not fit is returned. Returns `nil` if all of it fitted, if they carried nothing,
--- or if no screen was open.
function PlayerState.closeScreen(player: PlayerState): ItemStack.ItemStack?
	local screen = player.screen
	if screen == nil then
		return nil
	end
	local carriedStack = InventoryScreen.takeCarriedStack(screen)
	player.screen = nil
	player.openedPlacedItemId = nil
	return if carriedStack then Inventory.addStack(player.pack, carriedStack) else nil
end

return PlayerState
