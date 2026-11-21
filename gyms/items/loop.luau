-- A gym. Tries whether two libraries that know nothing of this game, or of each other, join into the
-- game's first loop with glue alone: a pack, a hotbar, a held stack, a crate, a stove with rules, a
-- mover with nobody there, a helper, things dropped and picked up, and saving.
-- Run it from the repository's root with: lune run gyms/items/loop
-- What it found is in gyms/items/README.md.
local Inventory = require("@inventory/Inventory")
local Slot = require("@inventory/Slot")
local Stack = require("@inventory/Stack")
local Drop = require("@drops/Drop")
local Ground = require("@drops/Ground")

local failed = 0
local function expect(condition: boolean, what: string)
	print((if condition then "ok    " else "FAIL  ") .. what)
	if not condition then
		failed += 1
	end
end

---------------------------------------------------------------------------------------------------
-- CONTENT. The kinds of item. Neither library holds this list: each is handed what it needs of it.
---------------------------------------------------------------------------------------------------
local KINDS = {
	log = { maxCount = 64 },
	stone = { maxCount = 64 },
	coal = { maxCount = 64, isFuel = true },
	plank = { maxCount = 64 },
	pickaxe = { maxCount = 1 },
}
local function getMaxCount(itemId: string): number
	return KINDS[itemId].maxCount
end
local function isFuel(itemId: string): boolean
	return KINDS[itemId].isFuel == true
end
local function acceptsNothing(): boolean
	return false
end

---------------------------------------------------------------------------------------------------
-- SYSTEMS. Each function below is glue: it calls one function of a library, then another.
---------------------------------------------------------------------------------------------------

-- What anything that acts has: a pack, a hotbar that is the pack's first nine slots, the number of
-- the selected slot, and a stack held between slots. A player and a helper are both made by this.
local function newActor()
	local pack = Inventory.new(36, getMaxCount)
	return { pack = pack, hotbar = table.move(pack, 1, 9, 1, {}), selectedSlotIndex = 1, held = nil :: any }
end

-- What a person asks for with a pointer. Each takes the slot itself, of any inventory.
local Moves = {}
function Moves.pickUp(actor, slot)
	if actor.held == nil then
		actor.held = Slot.takeStack(slot)
	end
end
function Moves.pickUpHalf(actor, slot)
	if actor.held == nil then
		actor.held = Slot.takeHalfStack(slot)
	end
end
function Moves.putDown(actor, slot)
	if actor.held ~= nil then
		actor.held = Slot.putStack(slot, actor.held)
	end
end
function Moves.putDownOne(actor, slot)
	if actor.held ~= nil then
		actor.held = Slot.putItems(slot, actor.held, 1)
	end
end
function Moves.swap(actor, slot)
	if actor.held ~= nil and Slot.canSwapStack(slot, actor.held) then
		actor.held = Slot.swapStack(slot, actor.held)
	end
end
function Moves.spread(actor, slots)
	if actor.held ~= nil then
		actor.held = Inventory.spreadStack(slots, actor.held)
	end
end
function Moves.gather(actor, slots)
	local held = actor.held
	if held == nil then
		return
	end
	local room = math.max(0, getMaxCount(held.itemId) - held.count)
	local removed = Inventory.removeItem(slots, held.itemId, room)
	if removed > 0 then
		actor.held = Stack.new(held.itemId, held.count + removed)
	end
end

-- Moves what fits of the stack in `fromSlot` into `toSlots`. Asks, takes, adds: nothing is put back.
-- A person's quick move, a hopper, and a helper's hands all call this one function.
local function moveStack(fromSlot, toSlots): number
	local stack = fromSlot.stack
	if stack == nil then
		return 0
	end
	local count = math.min(stack.count, Inventory.countRoom(toSlots, stack.itemId))
	local taken = Slot.takeItems(fromSlot, count)
	if taken ~= nil then
		Inventory.addStack(toSlots, taken)
	end
	return count
end

-- Dropping and picking up: the one place where the two libraries meet.
local ground = Ground.new()
local PICKUP_DELAY_SECONDS, LIFETIME_SECONDS = 1.5, 300
local REACH = vector.create(8, 9, 8)
local MERGE_REACH = vector.create(2.5, 1, 2.5)

local function mergeStacks(into, from)
	if into.itemId ~= from.itemId then
		return nil
	end
	local moved = math.min(getMaxCount(into.itemId) - into.count, from.count)
	if moved <= 0 then
		return nil
	end
	local rest = if moved == from.count then nil else Stack.new(from.itemId, from.count - moved)
	return Stack.new(into.itemId, into.count + moved), rest
end

local function dropFromSlot(slot, count: number, position: vector, now: number)
	local stack = Slot.takeItems(slot, count)
	if stack ~= nil then
		Ground.addDrop(ground, Drop.new(position, stack, now + PICKUP_DELAY_SECONDS, now + LIFETIME_SECONDS))
	end
end

local function pickUpNear(actor, position: vector, now: number): number
	local pickedCount = 0
	for _, drop in Ground.getDropsInBox(ground, position, REACH) do
		if Drop.canBePickedUp(drop, now) and not Drop.isExpired(drop, now) then
			local stack = drop.contents
			local count = math.min(stack.count, Inventory.countRoom(actor.pack, stack.itemId))
			if count == stack.count then
				Ground.removeDrop(ground, drop)
				Inventory.addStack(actor.pack, stack)
			elseif count > 0 then
				Drop.setContents(drop, Stack.new(stack.itemId, stack.count - count))
				Inventory.addStack(actor.pack, Stack.new(stack.itemId, count))
			end
			pickedCount += count
		end
	end
	return pickedCount
end

---------------------------------------------------------------------------------------------------
-- The loop, played by the script. `countEverything` proves that no item is made or lost.
---------------------------------------------------------------------------------------------------
local player = newActor()
local helper = newActor()
local crate = Inventory.new(27, getMaxCount)
local stove = Inventory.new(3, getMaxCount, { [2] = isFuel, [3] = acceptsNothing })
local INPUT, FUEL, OUTPUT = 1, 2, 3

local function countEverything(): { [string]: number }
	local counts = {}
	local function add(stack)
		if stack ~= nil then
			counts[stack.itemId] = (counts[stack.itemId] or 0) + stack.count
		end
	end
	for _, slots in { player.pack, helper.pack, crate, stove } do
		for _, slot in slots do
			add(slot.stack)
		end
	end
	add(player.held)
	add(helper.held)
	for _, drop in ground.drops do
		add(drop.contents)
	end
	return counts
end
local function sameCounts(a, b): boolean
	for itemId, count in a do
		if b[itemId] ~= count then
			return false
		end
	end
	for itemId, count in b do
		if a[itemId] ~= count then
			return false
		end
	end
	return true
end

print("-- a pack and a hotbar")
expect(Inventory.addStack(player.pack, Stack.new("log", 100)) == nil, "100 logs go into the pack")
Inventory.addStack(player.pack, Stack.new("stone", 20))
Inventory.addStack(player.pack, Stack.new("coal", 10))
Inventory.addStack(player.pack, Stack.new("pickaxe", 1))
expect(
	player.pack[1].stack.count == 64 and player.pack[2].stack.count == 36,
	"the logs fill slot 1 to 64 and leave 36 in slot 2"
)
player.selectedSlotIndex = 2
expect(
	player.hotbar[player.selectedSlotIndex].stack.count == 36,
	"the hotbar's selected slot is the pack's slot 2: 36 logs in hand"
)
local everything = countEverything()

print("-- a held stack, between a pack and a crate")
Moves.pickUpHalf(player, player.pack[1])
expect(player.held.count == 32 and player.pack[1].stack.count == 32, "picking up half of 64 holds 32 and leaves 32")
Moves.putDown(player, crate[5])
expect(player.held == nil and crate[5].stack.count == 32, "putting down fills the crate's slot 5")
Moves.pickUp(player, player.pack[2])
Moves.spread(player, { crate[1], crate[2], player.pack[20], crate[4] })
expect(
	crate[1].stack.count == 9 and player.pack[20].stack.count == 9 and player.held == nil,
	"36 logs spread over slots of two inventories: 9 in each"
)
Moves.pickUp(player, crate[1])
Moves.gather(player, crate)
expect(player.held.count == 9 + 9 + 9 + 32, "gathering takes the crate's other logs into the held stack: 59")
Moves.putDownOne(player, crate[10])
expect(crate[10].stack.count == 1 and player.held.count == 58, "putting down one leaves 1 in the slot and 58 held")
Moves.pickUp(player, crate[10])
expect(player.held.count == 58, "a hand that holds a stack does not pick up another")
Moves.swap(player, player.pack[4])
expect(
	player.held.itemId == "coal" and player.pack[4].stack.itemId == "log",
	"swapping with the coal in slot 4 holds the coal"
)
Moves.putDown(player, player.pack[4])
expect(player.held.itemId == "coal", "coal is not put down on logs: it stays held")
Moves.putDown(player, player.pack[30])
expect(sameCounts(everything, countEverything()), "no item was made or lost")

print("-- a quick move, by the same function as a mover")
expect(moveStack(player.pack[3], crate) == 20, "the 20 stone in slot 3 go to the crate")
expect(
	moveStack(player.pack[5], { player.pack[35], player.pack[36] }) == 1 and player.pack[35].stack.itemId == "pickaxe",
	"a quick move into a list of two slots puts the pickaxe in the first of them"
)

print("-- a stove: slots with rules, which hold for a person and for a mover")
Moves.pickUp(player, player.pack[30])
Moves.putDown(player, stove[OUTPUT])
expect(player.held ~= nil and stove[OUTPUT].stack == nil, "the output slot takes nothing from a person")
Moves.putDown(player, stove[FUEL])
expect(player.held == nil and stove[FUEL].stack.count == 10, "the fuel slot takes the coal")
Moves.pickUp(player, player.pack[4])
Moves.putDown(player, stove[FUEL])
expect(player.held ~= nil, "the fuel slot refuses logs: they stay held")
Moves.putDown(player, stove[INPUT])
expect(stove[INPUT].stack.itemId == "log" and player.held == nil, "the input slot takes the logs")
local logsInStove = stove[INPUT].stack.count

print("-- a mover with nobody there: a hopper from the crate into the stove")
local stoneSlot
for _, slot in crate do
	if slot.stack ~= nil and slot.stack.itemId == "stone" then
		stoneSlot = slot
	end
end
expect(
	moveStack(stoneSlot, stove) == 0,
	"the hopper moves no stone: the input holds logs, and the other two slots refuse it"
)
expect(stoneSlot.stack.count == 20, "the stone stays in the crate")
Inventory.addStack(crate, Stack.new("coal", 7))
everything = countEverything()
local coalSlot
for _, slot in crate do
	if slot.stack ~= nil and slot.stack.itemId == "coal" then
		coalSlot = slot
	end
end
expect(
	moveStack(coalSlot, stove) == 7 and stove[FUEL].stack.count == 17,
	"the hopper's coal goes to the fuel slot, by the slot's own rule"
)
expect(sameCounts(everything, countEverything()), "no item was made or lost")

print("-- the stove works: its owner writes its own slots")
Slot.takeItems(stove[INPUT], 1)
Slot.takeItems(stove[FUEL], 1)
Slot.setStack(stove[OUTPUT], Stack.new("plank", 4))
expect(
	stove[OUTPUT].stack.count == 4 and stove[INPUT].stack.count == logsInStove - 1,
	"one log and one coal became 4 planks in the output slot"
)
everything = countEverything()

print("-- a helper does what a player can: the same glue, and no player")
expect(
	moveStack(stove[OUTPUT], helper.pack) == 4 and helper.pack[1].stack.itemId == "plank",
	"the helper takes the planks out of the stove"
)
expect(moveStack(helper.pack[1], crate) == 4, "and carries them to the crate")
expect(sameCounts(everything, countEverything()), "no item was made or lost")

print("-- dropping and picking up: the two libraries meet in glue")
local here = vector.create(12.5, 3, -7.25)
dropFromSlot(player.pack[1], 5, here, 100)
expect(#ground.drops == 1 and player.pack[1].stack.count == 27, "5 logs lie on the ground")
expect(pickUpNear(player, here, 100.2) == 0, "they cannot be picked up at once")
dropFromSlot(player.pack[1], 3, here + vector.create(0.6, 0, 0.3), 100.4)
local changed, removed = Ground.mergeNearDrops(ground, MERGE_REACH, mergeStacks)
expect(
	#changed == 1 and #removed == 1 and ground.drops[1].contents.count == 8,
	"two stacks of logs that lie near become one of 8"
)
expect(pickUpNear(helper, here + vector.create(40, 0, 0), 102) == 0, "a helper 40 studs away picks up nothing")
expect(pickUpNear(player, here, 102) == 8 and #ground.drops == 0, "after the delay the player picks up all 8")
expect(sameCounts(everything, countEverything()), "no item was made or lost")
dropFromSlot(player.pack[1], 2, here, 200)
local expired = Ground.removeExpiredDrops(ground, 200 + LIFETIME_SECONDS)
expect(
	#expired == 1 and expired[1].contents.count == 2,
	"a drop that nobody picks up is cleared after its lifetime, and the glue is told which"
)

print("-- saving")
local data = Inventory.encode(player.pack)
local loaded, problem = Inventory.decode(data, 36, getMaxCount)
expect(
	loaded ~= nil and problem == nil and Inventory.countItem(loaded, "log") == Inventory.countItem(player.pack, "log"),
	"the pack becomes plain data and comes back"
)
local _, why = Inventory.decode({ { slotIndex = 99, itemId = "log", count = 1 } }, 36, getMaxCount)
expect(why ~= nil, "bad data is refused, with a reason: " .. tostring(why))

print(if failed == 0 then "\nitems gym: every step held" else `\nitems gym: {failed} steps failed`)
if failed > 0 then
	error("items gym failed", 0)
end
