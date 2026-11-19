--!strict
-- Tests for PlayerState. Run from the repository root: lune run tests/players/PlayerState.test.luau

local Check = require("../Check")
local Hotbar = require("../../src/shared/inventory/Hotbar")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventorySession = require("../../src/shared/inventory/InventorySession")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local PlayerState = require("../../src/shared/players/PlayerState")

local check = Check.that
local raises = Check.raises

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "stove", stackSize = 1 })

do -- the rules as numbers
	check(PlayerState.PACK_SLOTS == 36, "a pack has 36 slots")
	check(PlayerState.HOTBAR_SLOTS == 9, "the hotbar is 9 of them")
end

do -- a new player
	local state = PlayerState.new()
	check(state.pack.slotCount == 36 and Inventory.isEmpty(state.pack), "new: the pack has 36 slots and holds nothing")
	check(state.hotbar.inventory == state.pack, "new: the hotbar is over the pack")
	check(
		state.hotbar.slotCount == 9 and state.hotbar.selectedSlot == 1,
		"new: the hotbar has 9 slots, slot 1 selected"
	)
	check(state.session == nil, "new: no inventory screen is open")
	check(PlayerState.new().pack ~= state.pack, "new: each player has a pack of their own")

	Inventory.addItems(state.pack, "log", 5)
	local inHand = Hotbar.selectedStack(state.hotbar)
	check(inHand ~= nil and inHand.count == 5, "what goes into slot 1 of the pack is in the player's hands")
end

do -- opening and closing the pack alone
	local state = PlayerState.new()
	local session = PlayerState.openInventory(state)
	check(state.session == session, "openInventory: returns the session, and it is the player's session")
	check(session.pack == state.pack, "openInventory: the screen shows the pack")
	check(session.other == nil and session.carried == nil, "openInventory: no other inventory, and nothing carried")
	check(PlayerState.closeInventory(state) == nil, "closeInventory: nil when nothing was carried")
	check(state.session == nil, "closeInventory: no screen is open afterwards")
	check(PlayerState.closeInventory(state) == nil, "closeInventory: nil when no screen was open")
	check(state.session == nil, "closeInventory: and still no screen is open")
	check(PlayerState.openInventory(state) ~= session, "openInventory: opening again gives a new session")
end

do -- opening a crate
	local state = PlayerState.new()
	local crate = Inventory.new(27)
	Inventory.addItems(crate, "log", 10)
	local session = PlayerState.openInventory(state, crate)
	check(
		session.pack == state.pack and session.other == crate,
		"openInventory: shows the pack and the other inventory"
	)

	InventorySession.click(session, "other", 1, "left")
	check(session.carried ~= nil, "a click on the crate picks its stack up")
	check(PlayerState.closeInventory(state) == nil, "closeInventory: nil when what was carried fitted in the pack")
	check(Inventory.countItems(state.pack, "log") == 10, "closeInventory: what was carried is in the pack")
	check(Inventory.isEmpty(crate) and state.session == nil, "closeInventory: the crate keeps what was put in it")
end

do -- closing with a full pack
	local state = PlayerState.new()
	for slot = 1, PlayerState.PACK_SLOTS do
		Inventory.setStack(state.pack, slot, ItemStack.new("stove", 1))
	end
	local crate = Inventory.new(3)
	Inventory.addItems(crate, "log", 7)
	local session = PlayerState.openInventory(state, crate)
	InventorySession.click(session, "other", 1, "left")
	local leftover = PlayerState.closeInventory(state)
	check(
		leftover ~= nil and leftover.itemId == "log" and leftover.count == 7,
		"closeInventory: returns the stack that did not fit in the pack"
	)
	check(state.session == nil and session.carried == nil, "closeInventory: and nothing is carried any more")
	check(
		Inventory.countItems(state.pack, "log") == 0 and Inventory.isEmpty(crate),
		"closeInventory: the stack returned is in neither inventory"
	)
end

do -- one screen at a time
	local state = PlayerState.new()
	local crate = Inventory.new(3)
	local session = PlayerState.openInventory(state)
	check(
		raises("PlayerState.openInventory: an inventory screen is already open; close it first", function()
			PlayerState.openInventory(state, crate)
		end),
		"openInventory: refuses to open a second screen"
	)
	check(
		state.session == session and session.other == nil,
		"openInventory: a refused call leaves the open screen as it was"
	)
	PlayerState.closeInventory(state)
	check(
		PlayerState.openInventory(state, crate).other == crate,
		"openInventory: after closing, the other screen opens"
	)
end

Check.finish("PlayerState")
