--!strict
--[=[
	Answers the requests a player's machine sends about that player's own
	inventories: opening and closing the inventory screen, clicks and keys on
	its slots, picking a hotbar slot, and dropping things.

	A player's machine is not trusted. It may send any request, with anything
	at all, at any time. [method answer] checks a request against the
	player's state and carries it out, through the rules, only if it makes
	sense: the screen it speaks of is open, the slot it names is on that
	screen, a count is a count. A request that makes no sense is ignored.
	Whatever a request is sent with, nothing raises an error, and no item is
	made or lost.

	Some requests take items out of the player's inventories to go on the
	ground. [method answer] returns that stack, and the caller must put it on
	the ground.

	The requests, what each is sent with, and what each does:

	| Name | Sent with | Does |
	|---|---|---|
	| `openPack` | nothing | opens the inventory screen on the pack alone, unless a screen is open |
	| `closeInventory` | nothing | closes the screen; returns what was carried if the pack has no room for it |
	| `clickSlot` | side, slot, button | a left or right mouse click on a slot, as `InventorySession.click` does |
	| `doubleClickSlot` | side, slot | the second click of a double click, as `InventorySession.doubleClick` does |
	| `dragOverSlots` | slots, button | a drag across several slots with a mouse button held, as `InventorySession.drag` does |
	| `quickMoveSlot` | side, slot | sends the slot's stack to the other side, as `InventorySession.quickMove` does |
	| `swapWithHotbarSlot` | side, slot, hotbar slot | exchanges the slot's stack with a hotbar slot's |
	| `dropFromSlot` | side, slot, count | returns up to `count` items out of the slot, or all of them with no count |
	| `dropCarried` | count | returns up to `count` of the carried items, or all of them with no count |
	| `selectHotbarSlot` | slot | selects that hotbar slot |
	| `dropSelected` | count | returns up to `count` items out of the selected hotbar slot, or all of them with no count |

	Every request but the last two and `openPack` needs a screen to be open,
	and is ignored when none is. A screen opened here knows the hotbar's
	size, so `quickMoveSlot` and `swapWithHotbarSlot` work on the pack alone.

	The slots of `dragOverSlots` are a list of tables, each naming one slot
	with a `side` and a `slot`: `{ { side = "pack", slot = 3 }, { side = "pack", slot = 4 } }`.
	A list longer than the number of slots on the screen is ignored, since
	no drag could name so many.

	Requests about the world, such as placing an item on a plot, are not
	answered here: they need more than one player's state. Messages lists
	every request there is.

	```lua
	InventoryRequests.answer(state, "openPack") --> nil; state.session is now the open screen
	InventoryRequests.answer(state, "clickSlot", "pack", 3, "left") --> nil; the click was done
	InventoryRequests.answer(state, "clickSlot", "pack", 999, "left") --> nil; ignored: no such slot
	InventoryRequests.answer(state, "dropCarried") --> the stack that was carried, to put on the ground
	```
]=]
local Hotbar = require("../inventory/Hotbar")
local Inventory = require("../inventory/Inventory")
local InventorySession = require("../inventory/InventorySession")
local ItemStack = require("../items/ItemStack")
local PlayerState = require("./PlayerState")

local InventoryRequests = {}

type ItemStack = ItemStack.ItemStack
type Inventory = Inventory.Inventory
type PlayerState = PlayerState.PlayerState

local function isWholeNumber(value: unknown): boolean
	return type(value) == "number" and value == math.floor(value) and value ~= math.huge and value ~= -math.huge
end

-- True for what a request may give as a count: nothing, meaning all, or a whole number of 0 or more.
local function isCountOrNothing(value: unknown): boolean
	return value == nil or (isWholeNumber(value) and (value :: number) >= 0)
end

-- True if `value` could be the slots of a drag across the open screen: a list of slots that the
-- screen shows, no longer than the number of slots it has.
local function isDragOnScreen(session: InventorySession.InventorySession, value: unknown): boolean
	if type(value) ~= "table" then
		return false
	end
	local other = session.other
	local slotsOnScreen = session.pack.slotCount + (if other ~= nil then other.slotCount else 0)
	return #(value :: { unknown }) <= slotsOnScreen and InventorySession.hasSlots(session, value)
end

-- What each request does, given the player's state and whatever the request was sent with.
-- Each returns the stack that must go on the ground, or nil.
local answers: { [string]: (state: PlayerState, ...any) -> ItemStack? } = {
	openPack = function(state)
		if state.session == nil then
			PlayerState.openInventory(state)
		end
		return nil
	end,

	closeInventory = function(state)
		return PlayerState.closeInventory(state)
	end,

	clickSlot = function(state, side, slot, button)
		local session = state.session
		if
			session ~= nil
			and InventorySession.hasSlot(session, side, slot)
			and (button == "left" or button == "right")
		then
			InventorySession.click(session, side, slot, button)
		end
		return nil
	end,

	doubleClickSlot = function(state, side, slot)
		local session = state.session
		if session ~= nil and InventorySession.hasSlot(session, side, slot) then
			InventorySession.doubleClick(session, side, slot)
		end
		return nil
	end,

	dragOverSlots = function(state, screenSlots, button)
		local session = state.session
		if session ~= nil and isDragOnScreen(session, screenSlots) and (button == "left" or button == "right") then
			InventorySession.drag(session, screenSlots, button)
		end
		return nil
	end,

	quickMoveSlot = function(state, side, slot)
		local session = state.session
		if session ~= nil and InventorySession.hasSlot(session, side, slot) then
			InventorySession.quickMove(session, side, slot)
		end
		return nil
	end,

	swapWithHotbarSlot = function(state, side, slot, hotbarSlot)
		local session = state.session
		if session == nil or not InventorySession.hasSlot(session, side, slot) then
			return nil
		end
		if isWholeNumber(hotbarSlot) and hotbarSlot >= 1 and hotbarSlot <= state.hotbar.slotCount then
			InventorySession.swapWithHotbar(session, side, slot, hotbarSlot)
		end
		return nil
	end,

	dropFromSlot = function(state, side, slot, count)
		local session = state.session
		if session == nil or not InventorySession.hasSlot(session, side, slot) or not isCountOrNothing(count) then
			return nil
		end
		local inventory = if side == "pack" then session.pack else session.other :: Inventory
		return Inventory.takeFromSlot(inventory, slot, count)
	end,

	dropCarried = function(state, count)
		local session = state.session
		if session == nil or not isCountOrNothing(count) then
			return nil
		end
		return InventorySession.drop(session, count)
	end,

	selectHotbarSlot = function(state, slot)
		if isWholeNumber(slot) and slot >= 1 and slot <= state.hotbar.slotCount then
			Hotbar.select(state.hotbar, slot)
		end
		return nil
	end,

	dropSelected = function(state, count)
		if not isCountOrNothing(count) then
			return nil
		end
		return Inventory.takeFromSlot(state.pack, state.hotbar.selectedSlot, count)
	end,
}

--- The name of every request that [method answer] answers, in the order they are listed in Messages.
InventoryRequests.NAMES = table.freeze({
	"openPack",
	"closeInventory",
	"clickSlot",
	"doubleClickSlot",
	"dragOverSlots",
	"quickMoveSlot",
	"swapWithHotbarSlot",
	"dropFromSlot",
	"dropCarried",
	"selectHotbarSlot",
	"dropSelected",
})

--[=[
	Carries out the request called `name` for the player whose state is
	`state`, if it makes sense, and returns the stack that must be put on the
	ground, or `nil` if there is none.

	`name` and everything after it are what the player's machine sent, and
	may be any values at all. A name that is not in `InventoryRequests.NAMES`,
	or a request that makes no sense for the player as they are now, changes
	nothing and returns `nil`. Nothing raises an error.
]=]
function InventoryRequests.answer(state: PlayerState, name: unknown, ...: unknown): ItemStack?
	local answerRequest = if type(name) == "string" then answers[name] else nil
	if answerRequest == nil then
		return nil
	end
	return answerRequest(state, ...)
end

return InventoryRequests
