--!strict
--- One player: their pack, their hotbar, the inventory screen they have open, and their character
--- in the world.
---
--- `setCharacterPosition` gives the player a character, and `removeCharacter` removes it.
--- `openScreen` opens the player's inventory screen, and `closeScreen` closes it. Only a player
--- with a character can have a screen open, and `canOpenScreen` returns whether `openScreen` would
--- succeed.
local Hotbar = require("../inventory/Hotbar")
local Inventory = require("../inventory/Inventory")
local InventoryScreen = require("../inventory/InventoryScreen")
local ItemStack = require("../items/ItemStack")
local Position = require("../Position")

local PlayerState = {}

--- A player's character in the world.
export type Character = {
	--- The position of the character's feet.
	read position: Position.Position,
}

--- A player: their pack, their hotbar, their open inventory screen, and their character.
export type PlayerState = {
	--- The player's inventory. `new` makes one of `PACK_SLOT_COUNT` slots if it is given none.
	read pack: Inventory.Inventory,
	--- The hotbar over the first `HOTBAR_SLOT_COUNT` slots of `pack`, and its selected slot.
	read hotbar: Hotbar.Hotbar,
	--- The player's open inventory screen, or `nil` if none is open.
	screen: InventoryScreen.InventoryScreen?,
	--- The player's character, or `nil` while they have none.
	character: Character?,
}

--- The number of slots in the pack that `new` makes for a player who is given none.
PlayerState.PACK_SLOT_COUNT = 36

--- The number of slots of the pack, counting from slot `1`, that `new` gives the hotbar.
PlayerState.HOTBAR_SLOT_COUNT = 9

--- Returns a new player with hotbar slot `1` selected, no screen open, and no character. The
--- player's pack is `pack`, or an empty pack of `PACK_SLOT_COUNT` slots if `pack` is `nil`.
function PlayerState.new(pack: Inventory.Inventory?): PlayerState
	local playerPack = pack or Inventory.new(PlayerState.PACK_SLOT_COUNT)
	return {
		pack = playerPack,
		hotbar = Hotbar.new(playerPack, PlayerState.HOTBAR_SLOT_COUNT),
	}
end

--- Sets the position of the player's character, at its feet, to `position`. Gives the player a
--- character if they had none.
function PlayerState.setCharacterPosition(player: PlayerState, position: Position.Position)
	player.character = table.freeze({ position = position })
end

--- Removes the player's character, so the player has none until `setCharacterPosition` runs. Does
--- nothing if they have no character. Fails, and changes nothing, if the player has a screen open.
function PlayerState.removeCharacter(player: PlayerState)
	if player.screen ~= nil then
		error("a player with a screen open must keep their character", 2)
	end
	player.character = nil
end

--- Returns `true` if `openScreen` would succeed for the player: they have a character, and no
--- screen open.
function PlayerState.canOpenScreen(player: PlayerState): boolean
	return player.screen == nil and player.character ~= nil
end

--- Opens the player's inventory screen on their pack. If `otherInventory` is given, the screen
--- shows that inventory beside the pack. `otherSlotAcceptsItem`, if given, takes a slot and an
--- item's id and returns `true` if that slot of `otherInventory` takes that item. Fails, and
--- changes nothing, if `canOpenScreen` would return `false`.
function PlayerState.openScreen(
	player: PlayerState,
	otherInventory: Inventory.Inventory?,
	otherSlotAcceptsItem: ((slot: number, itemId: string) -> boolean)?
)
	if not PlayerState.canOpenScreen(player) then
		error("a screen can be opened only for a player with a character and no screen open", 2)
	end
	player.screen = InventoryScreen.new(player.pack, otherInventory, otherSlotAcceptsItem)
end

--- Closes the player's inventory screen and adds the stack that the screen carried to their pack.
--- Returns the part of that stack that did not fit, or `nil` if all of it fitted, if the screen
--- carried nothing, or if no screen was open.
function PlayerState.closeScreen(player: PlayerState): ItemStack.ItemStack?
	local screen = player.screen
	if screen == nil then
		return nil
	end
	local carriedStack = InventoryScreen.takeCarriedStack(screen)
	player.screen = nil
	return if carriedStack then Inventory.addStack(player.pack, carriedStack) else nil
end

return PlayerState
