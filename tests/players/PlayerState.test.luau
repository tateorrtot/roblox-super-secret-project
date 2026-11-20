--!strict
-- Tests for PlayerState. Run from the repository root: lune run tests/players/PlayerState.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlayerState = require("../../src/shared/players/PlayerState")
local Position = require("../../src/shared/Position")

local check = Check.that

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "stove", stackSize = 1 })

local here: PlayerState.Character = { position = Position.new(1, 2, 3), facing = { x = 1, z = 0 } }

-- A player with a character, as most of what a player does needs one.
local function newPlayerWithCharacter(): PlayerState.PlayerState
	local player = PlayerState.new()
	PlayerState.setCharacterPositionAndFacing(player, here.position, here.facing)
	return player
end

do -- the rules as numbers
	check(PlayerState.PACK_SLOT_COUNT == 36, "a pack has 36 slots")
	check(PlayerState.HOTBAR_SLOT_COUNT == 9, "the hotbar is 9 of them")
end

do -- a new player
	local player = PlayerState.new()
	check(
		player.pack.slotCount == 36 and Inventory.isEmpty(player.pack),
		"new: the pack has 36 slots and holds nothing"
	)
	check(player.hotbar.inventory == player.pack, "new: the hotbar is over the pack")
	check(
		player.hotbar.slotCount == 9 and player.hotbar.selectedSlot == 1,
		"new: the hotbar has 9 slots, slot 1 selected"
	)
	check(player.screen == nil, "new: no inventory screen is open")
	check(player.openedPlacedItemId == nil, "new: no placed item is open")
	check(player.character == nil, "new: the player has no character")
	check(PlayerState.new().pack ~= player.pack, "new: each player has a pack of their own")

	Inventory.addItems(player.pack, "log", 5)
	local inHand = Inventory.getStack(player.hotbar.inventory, player.hotbar.selectedSlot)
	check(inHand ~= nil and inHand.count == 5, "what goes into slot 1 of the pack is in the player's hands")
end

do -- a pack that is given
	local given = Inventory.new(PlayerState.PACK_SLOT_COUNT)
	Inventory.setStack(given, 4, ItemStack.new("log", 9))
	local player = PlayerState.new(given)
	check(player.pack == given, "new: the player carries the pack given")
	check(player.hotbar.inventory == given, "new: the hotbar is over the pack given")
	check(Inventory.countItems(player.pack, "log") == 9, "new: the pack given keeps what it held")
	check(player.hotbar.slotCount == 9 and player.hotbar.selectedSlot == 1, "new: a given pack has the same hotbar")
	check(
		player.screen == nil and player.character == nil,
		"new: a given pack still starts with no screen and no character"
	)
	check(PlayerState.new(nil).pack.slotCount == 36, "new: a pack of nil is the same as none given")
end

do -- the character
	local player = PlayerState.new()
	PlayerState.setCharacterPositionAndFacing(player, here.position, here.facing)
	local character = player.character
	check(
		character ~= nil and character.position == here.position and character.facing == here.facing,
		"setCharacterPositionAndFacing: the player has a character, at the position and facing the way given"
	)
	local there: PlayerState.Character = { position = Position.new(9, 0, 9), facing = { x = 0, z = -1 } }
	PlayerState.setCharacterPositionAndFacing(player, there.position, there.facing)
	local moved = player.character
	check(
		moved ~= nil and moved.position == there.position and moved.facing == there.facing,
		"setCharacterPositionAndFacing: a later position and facing take their place"
	)
	PlayerState.removeCharacter(player)
	check(player.character == nil, "removeCharacter: the player has no character")
	PlayerState.removeCharacter(player)
	check(player.character == nil, "removeCharacter: does nothing for a player with no character")
	PlayerState.setCharacterPositionAndFacing(player, here.position, here.facing)
	check(player.character ~= nil, "setCharacterPositionAndFacing: a player who had no character has one from now on")

	local withScreen = newPlayerWithCharacter()
	PlayerState.openPackScreen(withScreen)
	check(
		Check.raises("a player with a screen open must keep their character", function()
			PlayerState.removeCharacter(withScreen)
		end),
		"removeCharacter: fails while a screen is open"
	)
	local kept = withScreen.character
	check(
		kept ~= nil and kept.position == here.position and withScreen.screen ~= nil,
		"removeCharacter: and then the character and the screen are as they were"
	)
	PlayerState.setCharacterPositionAndFacing(withScreen, there.position, there.facing)
	local movedWithScreen = withScreen.character
	check(
		movedWithScreen ~= nil and movedWithScreen.position == there.position,
		"setCharacterPositionAndFacing: a character can move while a screen is open"
	)
end

do -- opening the pack
	local player = newPlayerWithCharacter()
	check(PlayerState.openPackScreen(player), "openPackScreen: returns true when it opens the screen")
	local screen = player.screen
	check(
		screen ~= nil and screen.pack == player.pack and screen.otherInventory == nil,
		"openPackScreen: the screen shows the pack alone"
	)
	check(screen ~= nil and screen.carriedStack == nil, "openPackScreen: with nothing carried")
	check(player.openedPlacedItemId == nil, "openPackScreen: and no placed item is open")
	check(not PlayerState.openPackScreen(player), "openPackScreen: returns false when a screen is open already")
	check(player.screen == screen, "openPackScreen: and leaves that screen as it was")

	local noCharacter = PlayerState.new()
	check(
		not PlayerState.openPackScreen(noCharacter) and noCharacter.screen == nil,
		"openPackScreen: does nothing for a player with no character"
	)
end

do -- opening a placed item
	local player = newPlayerWithCharacter()
	local inside = Inventory.new(3)
	local accepts = function(slot: number, itemId: string): boolean
		return slot == 1 and itemId == "log"
	end
	check(
		PlayerState.openPlacedItemScreen(player, 7, inside, accepts),
		"openPlacedItemScreen: returns true when it opens the screen"
	)
	local screen = player.screen
	check(
		screen ~= nil and screen.pack == player.pack and screen.otherInventory == inside,
		"openPlacedItemScreen: the screen shows the pack and the inventory given"
	)
	check(player.openedPlacedItemId == 7, "openPlacedItemScreen: the player has that placed item open")
	check(
		screen ~= nil
			and InventoryScreen.slotAcceptsItem(screen, "other", 1, "log")
			and not InventoryScreen.slotAcceptsItem(screen, "other", 2, "log"),
		"openPlacedItemScreen: its slots take what the rule given says"
	)
	check(
		not PlayerState.openPlacedItemScreen(player, 8, Inventory.new(3)),
		"openPlacedItemScreen: returns false when a screen is open already"
	)
	check(
		player.screen == screen and player.openedPlacedItemId == 7,
		"openPlacedItemScreen: and leaves that screen as it was"
	)

	local plain = newPlayerWithCharacter()
	PlayerState.openPlacedItemScreen(plain, 2, Inventory.new(3))
	check(
		plain.screen ~= nil and InventoryScreen.slotAcceptsItem(plain.screen, "other", 2, "stove"),
		"openPlacedItemScreen: with no rule given, every slot takes every item"
	)

	local noCharacter = PlayerState.new()
	check(
		not PlayerState.openPlacedItemScreen(noCharacter, 7, inside)
			and noCharacter.screen == nil
			and noCharacter.openedPlacedItemId == nil,
		"openPlacedItemScreen: does nothing for a player with no character"
	)
end

do -- closing the screen
	local player = newPlayerWithCharacter()
	check(PlayerState.closeScreen(player) == nil, "closeScreen: returns nil when no screen is open")

	PlayerState.openPlacedItemScreen(player, 7, Inventory.new(3))
	check(PlayerState.closeScreen(player) == nil, "closeScreen: returns nil when nothing was carried")
	check(
		player.screen == nil and player.openedPlacedItemId == nil,
		"closeScreen: no screen and no placed item is open afterwards"
	)

	Inventory.setStack(player.pack, 1, ItemStack.new("log", 12))
	PlayerState.openPackScreen(player)
	InventoryScreen.pickUpFromSlot(player.screen :: any, "pack", 1)
	check(PlayerState.closeScreen(player) == nil, "closeScreen: returns nil when what was carried fits in the pack")
	check(
		player.screen == nil and Inventory.countItems(player.pack, "log") == 12,
		"closeScreen: and what was carried is back in the pack"
	)

	local full = newPlayerWithCharacter()
	for slot = 1, PlayerState.PACK_SLOT_COUNT do
		Inventory.setStack(full.pack, slot, ItemStack.new("stove", 1))
	end
	local crate = Inventory.new(3)
	Inventory.setStack(crate, 1, ItemStack.new("log", 5))
	PlayerState.openPlacedItemScreen(full, 7, crate)
	InventoryScreen.pickUpFromSlot(full.screen :: any, "other", 1)
	local leftover = PlayerState.closeScreen(full)
	check(
		leftover ~= nil and leftover.itemId == "log" and leftover.count == 5,
		"closeScreen: returns the carried stack when the pack has no room for it"
	)
	check(
		full.screen == nil and Inventory.countItems(full.pack, "log") == 0 and Inventory.isEmpty(crate),
		"closeScreen: and it is in neither inventory"
	)

	local partly = newPlayerWithCharacter()
	for slot = 1, PlayerState.PACK_SLOT_COUNT do
		Inventory.setStack(partly.pack, slot, ItemStack.new("stove", 1))
	end
	Inventory.setStack(partly.pack, 10, ItemStack.new("log", 14))
	local other = Inventory.new(3)
	Inventory.setStack(other, 1, ItemStack.new("log", 5))
	PlayerState.openPlacedItemScreen(partly, 7, other)
	InventoryScreen.pickUpFromSlot(partly.screen :: any, "other", 1)
	local rest = PlayerState.closeScreen(partly)
	check(
		rest ~= nil and rest.count == 3 and Inventory.countItems(partly.pack, "log") == 16,
		"closeScreen: fills what room the pack has and returns the rest"
	)
end

Check.finish("PlayerState")
