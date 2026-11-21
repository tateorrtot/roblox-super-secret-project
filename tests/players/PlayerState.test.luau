--!strict
-- Tests for PlayerState. Run from the repository root: lune run tests/players/PlayerState.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryScreen = require("../../src/shared/inventory/InventoryScreen")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlayerState = require("../../src/shared/players/PlayerState")
local Position = require("../../src/shared/Position")

-- Returns the pack of `screen`, which is open.
local function packOf(screen: any): Inventory.Inventory
	return (screen :: InventoryScreen.InventoryScreen).pack
end

-- Returns the other inventory of `screen`, which has one open.
local function otherOf(screen: any): Inventory.Inventory
	return (screen :: InventoryScreen.InventoryScreen).otherInventory :: Inventory.Inventory
end

local check = Check.that

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "stove", stackSize = 1 })

local here: PlayerState.Character = { position = Position.new(1, 2, 3) }

-- A player with a character, as most of what a player does needs one.
local function newPlayerWithCharacter(): PlayerState.PlayerState
	local player = PlayerState.new()
	PlayerState.setCharacterPosition(player, here.position)
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
	PlayerState.setCharacterPosition(player, here.position)
	local character = player.character
	check(
		character ~= nil and character.position == here.position,
		"setCharacterPosition: the player has a character, at the position given"
	)
	local there: PlayerState.Character = { position = Position.new(9, 0, 9) }
	PlayerState.setCharacterPosition(player, there.position)
	local moved = player.character
	check(moved ~= nil and moved.position == there.position, "setCharacterPosition: a later position takes its place")
	PlayerState.removeCharacter(player)
	check(player.character == nil, "removeCharacter: the player has no character")
	PlayerState.removeCharacter(player)
	check(player.character == nil, "removeCharacter: does nothing for a player with no character")
	PlayerState.setCharacterPosition(player, here.position)
	check(player.character ~= nil, "setCharacterPosition: a player who had no character has one from now on")

	local withScreen = newPlayerWithCharacter()
	PlayerState.openScreen(withScreen)
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
	PlayerState.setCharacterPosition(withScreen, there.position)
	local movedWithScreen = withScreen.character
	check(
		movedWithScreen ~= nil and movedWithScreen.position == there.position,
		"setCharacterPosition: a character can move while a screen is open"
	)
end

do -- opening the pack
	local player = newPlayerWithCharacter()
	check(PlayerState.canOpenScreen(player), "canOpenScreen: true for a player with a character and no screen open")
	PlayerState.openScreen(player)
	local screen = player.screen
	check(
		screen ~= nil and screen.pack == player.pack and screen.otherInventory == nil,
		"openScreen: with no other inventory, the screen shows the pack alone"
	)
	check(screen ~= nil and screen.carriedStack == nil, "openScreen: with nothing carried")
	check(not PlayerState.canOpenScreen(player), "canOpenScreen: false while a screen is open")
	check(
		Check.raises("a screen can be opened only for a player with a character and no screen open", function()
			PlayerState.openScreen(player)
		end),
		"openScreen: fails when a screen is open already"
	)
	check(player.screen == screen, "openScreen: and leaves that screen as it was")

	local noCharacter = PlayerState.new()
	check(not PlayerState.canOpenScreen(noCharacter), "canOpenScreen: false for a player with no character")
	check(Check.raises("a screen can be opened only for a player with a character and no screen open", function()
		PlayerState.openScreen(noCharacter)
	end) and noCharacter.screen == nil, "openScreen: fails for a player with no character")
	PlayerState.closeScreen(player)
	check(PlayerState.canOpenScreen(player), "canOpenScreen: true again once the screen is closed")
end

do -- opening the pack with another inventory beside it
	local player = newPlayerWithCharacter()
	local inside = Inventory.new(3)
	local accepts = function(slot: number, itemId: string): boolean
		return slot == 1 and itemId == "log"
	end
	PlayerState.openScreen(player, inside, accepts)
	local screen = player.screen
	check(
		screen ~= nil and screen.pack == player.pack and screen.otherInventory == inside,
		"openScreen: with another inventory, the screen shows the pack and that inventory"
	)
	check(
		screen ~= nil
			and InventoryScreen.slotAcceptsItem(screen, otherOf(screen), 1, "log")
			and not InventoryScreen.slotAcceptsItem(screen, otherOf(screen), 2, "log"),
		"openScreen: the other inventory's slots take what the rule given says"
	)
	check(
		Check.raises("a screen can be opened only for a player with a character and no screen open", function()
			PlayerState.openScreen(player, Inventory.new(3))
		end),
		"openScreen: with another inventory, fails when a screen is open already"
	)
	check(player.screen == screen, "openScreen: and leaves that screen as it was, with its other inventory")

	local plain = newPlayerWithCharacter()
	PlayerState.openScreen(plain, Inventory.new(3))
	check(
		plain.screen ~= nil and InventoryScreen.slotAcceptsItem(plain.screen, otherOf(plain.screen), 2, "stove"),
		"openScreen: with no rule given, every slot of the other inventory takes every item"
	)

	local noCharacter = PlayerState.new()
	check(Check.raises("a screen can be opened only for a player with a character and no screen open", function()
		PlayerState.openScreen(noCharacter, inside)
	end) and noCharacter.screen == nil, "openScreen: with another inventory, fails for a player with no character")
end

do -- closing the screen
	local player = newPlayerWithCharacter()
	check(PlayerState.closeScreen(player) == nil, "closeScreen: returns nil when no screen is open")

	PlayerState.openScreen(player, Inventory.new(3))
	check(PlayerState.closeScreen(player) == nil, "closeScreen: returns nil when nothing was carried")
	check(player.screen == nil, "closeScreen: no screen is open afterwards")

	Inventory.setStack(player.pack, 1, ItemStack.new("log", 12))
	PlayerState.openScreen(player)
	InventoryScreen.pickUpFromSlot(player.screen :: any, packOf(player.screen), 1)
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
	PlayerState.openScreen(full, crate)
	InventoryScreen.pickUpFromSlot(full.screen :: any, otherOf(full.screen), 1)
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
	PlayerState.openScreen(partly, other)
	InventoryScreen.pickUpFromSlot(partly.screen :: any, otherOf(partly.screen), 1)
	local rest = PlayerState.closeScreen(partly)
	check(
		rest ~= nil and rest.count == 3 and Inventory.countItems(partly.pack, "log") == 16,
		"closeScreen: fills what room the pack has and returns the rest"
	)
end

Check.finish("PlayerState")
