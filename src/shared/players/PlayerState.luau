--!strict
--[=[
	One player in a running game, as far as the rules go: the pack they
	carry, their hotbar, and the inventory screen they have open, if any.

	The pack is an Inventory of `PlayerState.PACK_SLOTS` slots. The hotbar is
	the first `PlayerState.HOTBAR_SLOTS` of them, and its selected slot is what
	the player has in their hands.

	A player has at most one inventory screen open. `session` is that screen,
	an InventorySession, or `nil` when no screen is open.
	[method openInventory] opens one and [method closeInventory] closes it.

	```lua
	local state = PlayerState.new()
	state.session --> nil: no screen is open
	PlayerState.openInventory(state, crate) --> the session, showing the pack and the crate
	InventorySession.click(state.session, "other", 1, "left")
	PlayerState.closeInventory(state) --> nil, or a stack to put on the ground
	state.session --> nil
	```
]=]
local Hotbar = require("../inventory/Hotbar")
local Inventory = require("../inventory/Inventory")
local InventorySession = require("../inventory/InventorySession")
local ItemStack = require("../items/ItemStack")

local PlayerState = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory
type Hotbar = Hotbar.Hotbar
type InventorySession = InventorySession.InventorySession

--- `read` means code outside this module cannot assign the field. The functions below change `session`.
export type PlayerState = {
	--- What the player carries.
	read pack: Inventory,
	--- The first slots of the pack, and which of them is selected.
	read hotbar: Hotbar,
	--- The inventory screen the player has open, or `nil` when none is open.
	read session: InventorySession?,
}

--- How many slots a player's pack has.
PlayerState.PACK_SLOTS = 36

--- How many of the pack's slots, counting from slot 1, are the hotbar.
PlayerState.HOTBAR_SLOTS = 9

local function setSession(state: PlayerState, session: InventorySession?)
	(state :: any).session = session
end

--[=[
	Returns a new player with a pack that holds nothing, hotbar slot 1
	selected, and no inventory screen open.
]=]
function PlayerState.new(): PlayerState
	local pack = Inventory.new(PlayerState.PACK_SLOTS)
	return { pack = pack, hotbar = Hotbar.new(pack, PlayerState.HOTBAR_SLOTS) }
end

--[=[
	Opens the player's inventory screen and returns its session.

	The screen shows the pack. If `other` is given, such as a crate's
	inventory, it shows that beside the pack.

	Raises an error if a screen is already open: close it first with
	[method closeInventory].
]=]
function PlayerState.openInventory(state: PlayerState, other: Inventory?): InventorySession
	if state.session ~= nil then
		error("PlayerState.openInventory: an inventory screen is already open; close it first", 2)
	end
	local session = InventorySession.open(state.pack, other)
	setSession(state, session)
	return session
end

--[=[
	Closes the player's inventory screen, as `InventorySession.close` does:
	the stack being carried goes into the pack, and the stack of what did not
	fit is returned. The caller must put that stack on the ground, or its
	items are lost.

	Returns `nil` if everything fitted, if nothing was carried, or if no
	screen was open. Afterwards `session` is `nil`.
]=]
function PlayerState.closeInventory(state: PlayerState): ItemStack?
	local session = state.session
	if session == nil then
		return nil
	end
	setSession(state, nil)
	return InventorySession.close(session)
end

return PlayerState
