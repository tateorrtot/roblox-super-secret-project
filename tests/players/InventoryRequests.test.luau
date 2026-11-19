--!strict
-- Tests for InventoryRequests. Run from the repository root: lune run tests/players/InventoryRequests.test.luau

local Check = require("../Check")
local Inventory = require("../../src/shared/inventory/Inventory")
local InventoryRequests = require("../../src/shared/players/InventoryRequests")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")
local ItemStack = require("../../src/shared/items/ItemStack")
local Messages = require("../../src/shared/Messages")
local PlayerState = require("../../src/shared/players/PlayerState")

local check = Check.that
local answer = InventoryRequests.answer :: (state: PlayerState.PlayerState, name: any, ...any) -> ItemStack.ItemStack?

ItemRegistry.register({ id = "log", stackSize = 16 })
ItemRegistry.register({ id = "fish", stackSize = 8 })
ItemRegistry.register({ id = "stove", stackSize = 1 })

local itemIds = { "log", "fish", "stove" }

-- True if `stack` is `count` of the item `itemId`.
local function is(stack: ItemStack.ItemStack?, itemId: string, count: number): boolean
	return stack ~= nil and stack.itemId == itemId and stack.count == count
end

-- A player with 12 logs in slot 1, 5 fish in slot 2 and 4 logs in slot 10.
local function newPlayer(): PlayerState.PlayerState
	local state = PlayerState.new()
	Inventory.setStack(state.pack, 1, ItemStack.new("log", 12))
	Inventory.setStack(state.pack, 2, ItemStack.new("fish", 5))
	Inventory.setStack(state.pack, 10, ItemStack.new("log", 4))
	return state
end

-- How many of one item a player has in all: in the pack, in the open other inventory, and carried.
local function held(state: PlayerState.PlayerState, other: Inventory.Inventory?, itemId: string): number
	local count = Inventory.countItems(state.pack, itemId)
	if other ~= nil then
		count += Inventory.countItems(other, itemId)
	end
	local session = state.session
	if session ~= nil and session.carried ~= nil and session.carried.itemId == itemId then
		count += session.carried.count
	end
	return count
end

do -- the names
	local sent: { [string]: boolean } = {}
	for _, name in Messages.toServer do
		sent[name] = true
	end
	for _, name in InventoryRequests.NAMES do
		check(sent[name] == true, '"' .. name .. "\" is a message a player's machine sends, listed in Messages")
	end
	check(#InventoryRequests.NAMES == 10, "ten requests are answered here")
end

do -- the screen
	local state = newPlayer()
	check(answer(state, "openPack") == nil and state.session ~= nil, "openPack: opens the inventory screen on the pack")
	local session = state.session
	check(answer(state, "openPack") == nil and state.session == session, "openPack: does nothing when a screen is open")
	check(answer(state, "closeInventory") == nil and state.session == nil, "closeInventory: closes it")
	check(
		answer(state, "closeInventory") == nil and state.session == nil,
		"closeInventory: does nothing when none is open"
	)
end

do -- clicks
	local state = newPlayer()
	answer(state, "clickSlot", "pack", 1, "left")
	check(Inventory.countItems(state.pack, "log") == 16, "clickSlot: ignored when no screen is open")
	answer(state, "openPack")
	local session = state.session :: any
	answer(state, "clickSlot", "pack", 1, "left")
	check(is(session.carried, "log", 12), "clickSlot: a left click picks the stack up")
	answer(state, "clickSlot", "pack", 3, "right")
	check(
		is(session.carried, "log", 11) and is(Inventory.getStack(state.pack, 3), "log", 1),
		"clickSlot: a right click puts one down"
	)
	answer(state, "clickSlot", "pack", 3, "middle")
	answer(state, "clickSlot", "pack", 37, "left")
	answer(state, "clickSlot", "other", 1, "left")
	answer(state, "clickSlot", "pack", "3", "left")
	answer(state, "clickSlot")
	check(
		is(session.carried, "log", 11),
		"clickSlot: ignored with a bad button, a slot that is not there, or nothing at all"
	)
	answer(state, "clickSlot", "pack", 4, "left")
	answer(state, "clickSlot", "pack", 4, "left")
	answer(state, "doubleClickSlot", "pack", 4)
	check(is(session.carried, "log", 16), "doubleClickSlot: gathers the kind that is carried")
	answer(state, "doubleClickSlot", "pack", 99)
	check(is(session.carried, "log", 16), "doubleClickSlot: ignored for a slot that is not there")
	answer(state, "clickSlot", "pack", 1, "left")

	answer(state, "quickMoveSlot", "pack", 1)
	check(
		is(Inventory.getStack(state.pack, 10), "log", 16) and Inventory.getStack(state.pack, 1) == nil,
		"quickMoveSlot: sends a hotbar stack to the rest of the pack"
	)
	answer(state, "quickMoveSlot", "other", 1)
	answer(state, "quickMoveSlot", "pack", 0)
	check(is(Inventory.getStack(state.pack, 10), "log", 16), "quickMoveSlot: ignored for a slot that is not there")

	answer(state, "swapWithHotbarSlot", "pack", 10, 9)
	check(
		is(Inventory.getStack(state.pack, 9), "log", 16) and Inventory.getStack(state.pack, 10) == nil,
		"swapWithHotbarSlot: swaps a slot with a hotbar slot"
	)
	answer(state, "swapWithHotbarSlot", "pack", 9, 1)
	check(
		is(Inventory.getStack(state.pack, 1), "log", 16) and Inventory.getStack(state.pack, 9) == nil,
		"swapWithHotbarSlot: the first hotbar slot can be swapped with"
	)
	answer(state, "swapWithHotbarSlot", "pack", 1, 9)
	answer(state, "swapWithHotbarSlot", "pack", 9, 10)
	answer(state, "swapWithHotbarSlot", "pack", 9, 0)
	answer(state, "swapWithHotbarSlot", "pack", 9, 1.5)
	answer(state, "swapWithHotbarSlot", "pack", 9)
	answer(state, "swapWithHotbarSlot", "pack", 40, 1)
	check(
		is(Inventory.getStack(state.pack, 9), "log", 16),
		"swapWithHotbarSlot: ignored for a hotbar slot or a slot that is not there"
	)
end

do -- with a crate open
	local state = newPlayer()
	local crate = Inventory.new(3)
	Inventory.addItems(crate, "stove", 1)
	PlayerState.openInventory(state, crate)
	answer(state, "openPack")
	check((state.session :: any).other == crate, "openPack: does nothing while a crate is open")
	answer(state, "quickMoveSlot", "other", 1)
	check(
		Inventory.isEmpty(crate) and Inventory.countItems(state.pack, "stove") == 1,
		"quickMoveSlot: sends the crate's stack to the pack"
	)
	answer(state, "clickSlot", "other", 4, "left")
	check((state.session :: any).carried == nil, "clickSlot: ignored for a slot the crate lacks")
	answer(state, "clickSlot", "pack", 1, "left")
	answer(state, "clickSlot", "other", 3, "left")
	check(is(Inventory.getStack(crate, 3), "log", 12), "clickSlot: carries a stack from the pack into the crate")
end

do -- dropping
	local state = newPlayer()
	check(is(answer(state, "dropSelected"), "log", 1), "dropSelected: returns one of what is in hand")
	check(is(Inventory.getStack(state.pack, 1), "log", 11), "dropSelected: and it has left the pack")
	answer(state, "selectHotbarSlot", 2)
	check(
		state.hotbar.selectedSlot == 2 and is(answer(state, "dropSelected"), "fish", 1),
		"selectHotbarSlot: changes what is in hand"
	)
	for _, bad in { 0, 10, -1, 2.5, 0 / 0, math.huge, "3", true, {} } :: { any } do
		answer(state, "selectHotbarSlot", bad)
	end
	answer(state, "selectHotbarSlot")
	check(state.hotbar.selectedSlot == 2, "selectHotbarSlot: ignored for anything that is not a hotbar slot")
	answer(state, "selectHotbarSlot", 9)
	check(state.hotbar.selectedSlot == 9, "selectHotbarSlot: the last hotbar slot can be picked")
	answer(state, "selectHotbarSlot", 1)
	check(state.hotbar.selectedSlot == 1, "selectHotbarSlot: and the first")
	answer(state, "selectHotbarSlot", 5)
	check(answer(state, "dropSelected") == nil, "dropSelected: nil when the hand holds nothing")

	check(answer(state, "dropCarried") == nil, "dropCarried: nil when no screen is open")
	check(answer(state, "dropFromSlot", "pack", 1, 1) == nil, "dropFromSlot: nil when no screen is open")
	answer(state, "openPack")
	check(
		answer(state, "dropSelected") == nil and is(Inventory.getStack(state.pack, 1), "log", 11),
		"dropSelected: ignored while a screen is open"
	)
	check(is(answer(state, "dropFromSlot", "pack", 1, 1), "log", 1), "dropFromSlot: returns that many from the slot")
	check(
		is(answer(state, "dropFromSlot", "pack", 1), "log", 10),
		"dropFromSlot: with no count, returns the whole stack"
	)
	check(answer(state, "dropFromSlot", "pack", 1) == nil, "dropFromSlot: nil from a slot that holds nothing")
	for _, bad in { -1, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
		check(
			answer(state, "dropFromSlot", "pack", 2, bad) == nil,
			"dropFromSlot: ignored with the count " .. tostring(bad)
		)
		check(answer(state, "dropCarried", bad) == nil, "dropCarried: ignored with the count " .. tostring(bad))
	end
	check(answer(state, "dropFromSlot", "pack", 99, 1) == nil, "dropFromSlot: ignored for a slot that is not there")
	check(is(Inventory.getStack(state.pack, 2), "fish", 4), "dropFromSlot: an ignored request takes nothing")

	answer(state, "clickSlot", "pack", 2, "left")
	check(is(answer(state, "dropCarried", 1), "fish", 1), "dropCarried: returns that many of what is carried")
	check(is(answer(state, "dropCarried"), "fish", 3), "dropCarried: with no count, returns all of it")
	check(answer(state, "dropCarried") == nil, "dropCarried: nil when nothing is carried")

	answer(state, "clickSlot", "pack", 10, "left")
	for slot = 1, PlayerState.PACK_SLOTS do
		Inventory.setStack(state.pack, slot, ItemStack.new("stove", 1))
	end
	check(
		is(answer(state, "closeInventory"), "log", 4),
		"closeInventory: returns what was carried when the pack has no room for it"
	)
end

do -- names that are not requests
	local state = newPlayer()
	for _, name in { "askForInventory", "placeSelected", "noSuchRequest", "", "__index", 7, true, {} } :: { any } do
		check(answer(state, name, "pack", 1, "left") == nil, "answer: ignores the name " .. tostring(name))
	end
	check(answer(state, nil) == nil, "answer: ignores no name at all")
	check(state.session == nil and Inventory.countItems(state.pack, "log") == 16, "answer: and nothing changes")
end

do -- whatever a player's machine sends, nothing raises an error and no item is made or lost
	local seed = 771
	local function random(limit: number): number
		seed = (seed * 1103515245 + 12345) % 2147483648
		return math.floor(seed / 65536) % limit + 1
	end
	local junk: { any } = {
		-1,
		0,
		0.5,
		1e300,
		-1e300,
		0 / 0,
		math.huge,
		-math.huge,
		"",
		"pack",
		"other",
		"left",
		"1",
		true,
		false,
		{},
		{ 1 },
		{ side = "pack" },
	}
	-- One thing a request might be sent with: mostly what a real screen would send, sometimes junk or nothing.
	local function argument(): any
		local kind = random(10)
		if kind <= 3 then
			return if random(4) == 1 then "other" else "pack"
		elseif kind <= 6 then
			return random(40)
		elseif kind == 7 then
			return if random(2) == 1 then "left" else "right"
		elseif kind == 8 then
			return nil
		end
		return junk[random(#junk)]
	end
	local names: { any } = table.clone(InventoryRequests.NAMES)
	for _, extra in { "askForInventory", "nonsense", 12, false } :: { any } do
		table.insert(names, extra)
	end

	local errors, firstError = 0, ""
	local allConserved = true
	for _ = 1, 30 do
		local state = PlayerState.new()
		local crate = Inventory.new(6)
		local total: { [string]: number } = { log = 0, fish = 0, stove = 0 }
		for _ = 1, 14 do
			local itemId = itemIds[random(3)]
			local count = random(ItemRegistry.get(itemId).stackSize)
			local target = if random(3) == 1 then crate else state.pack
			total[itemId] += Inventory.addItems(target, itemId, count)
		end
		local onGround: { [string]: number } = { log = 0, fish = 0, stove = 0 }
		for _ = 1, 400 do
			-- Now and then the server itself opens the crate for the player, as a use of it in the world would.
			if state.session == nil and random(12) == 1 then
				PlayerState.openInventory(state, crate)
			end
			local name = names[random(#names)]
			local ok, result = pcall(answer, state, name, argument(), argument(), argument())
			if not ok then
				errors += 1
				firstError = if firstError == "" then tostring(name) .. ": " .. tostring(result) else firstError
			elseif result ~= nil then
				if ItemStack.validate(result) ~= nil then
					allConserved = false
				else
					onGround[result.itemId] += result.count
				end
			end
			for _, itemId in itemIds do
				if held(state, crate, itemId) + onGround[itemId] ~= total[itemId] then
					allConserved = false
				end
			end
		end
	end
	check(errors == 0, "12,000 random requests: none raises an error (first: " .. firstError .. ")")
	check(
		allConserved,
		"12,000 random requests: every item is in the pack, in the crate, carried or handed back for the ground"
	)
end

Check.finish("InventoryRequests")
