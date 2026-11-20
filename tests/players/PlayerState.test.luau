--!strict
-- Tests for PlayerState. Run from the repository root: lune run tests/players/PlayerState.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlayerState = require("../../src/shared/players/PlayerState")
local Position = require("../../src/shared/Position")

local check = Check.that

ItemRegistry.register({ id = "log", stackSize = 16 })

local dropAt = Position.new(1, 2, 3)

do -- the rules as numbers
	check(PlayerState.PACK_SLOTS == 36, "a pack has 36 slots")
	check(PlayerState.HOTBAR_SLOTS == 9, "the hotbar is 9 of them")
end

do -- a new player
	local state = PlayerState.new(dropAt)
	check(state.pack.slotCount == 36 and Inventory.isEmpty(state.pack), "new: the pack has 36 slots and holds nothing")
	check(state.hotbar.inventory == state.pack, "new: the hotbar is over the pack")
	check(
		state.hotbar.slotCount == 9 and state.hotbar.selectedSlot == 1,
		"new: the hotbar has 9 slots, slot 1 selected"
	)
	check(state.screen == nil, "new: no inventory screen is open")
	check(state.openedPlacedId == nil, "new: no placed item is open")
	check(state.position == nil, "new: the player has no character")
	check(state.dropPosition == dropAt, "new: a dropped stack lands at the drop position given")
	check(PlayerState.new(dropAt).pack ~= state.pack, "new: each player has a pack of their own")

	Inventory.addItems(state.pack, "log", 5)
	local inHand = Inventory.getStack(state.hotbar.inventory, state.hotbar.selectedSlot)
	check(inHand ~= nil and inHand.count == 5, "what goes into slot 1 of the pack is in the player's hands")
end

do -- a pack that is given
	local given = Inventory.new(PlayerState.PACK_SLOTS)
	Inventory.setStack(given, 4, ItemStack.new("log", 9))
	local state = PlayerState.new(dropAt, given)
	check(state.pack == given, "new: the player carries the pack given")
	check(state.hotbar.inventory == given, "new: the hotbar is over the pack given")
	check(Inventory.countItems(state.pack, "log") == 9, "new: the pack given keeps what it held")
	check(state.hotbar.slotCount == 9 and state.hotbar.selectedSlot == 1, "new: a given pack has the same hotbar")
	check(
		state.screen == nil and state.position == nil,
		"new: a given pack still starts with no screen and no character"
	)
	check(PlayerState.new(dropAt, nil).pack.slotCount == 36, "new: a pack of nil is the same as none given")
end

do -- the plain fields can be changed
	local state = PlayerState.new(dropAt)
	local there = Position.new(5, 0, 5)
	state.position = there
	check(state.position == there, "position: holds where the character stands once set")
	state.position = nil
	check(state.position == nil, "position: is nil again when set to nil")
	state.openedPlacedId = 7
	check(state.openedPlacedId == 7, "openedPlacedId: holds the id of the open placed item once set")
	local other = Position.new(9, 9, 9)
	state.dropPosition = other
	check(state.dropPosition == other, "dropPosition: can be moved")
end

Check.finish("PlayerState")
