-- Probes that the faults which the first review of the two libraries found are mended. Each probe
-- is a check that can fail: the script ends with an error if any does.
-- Run from the repository root: lune run gyms/items/probe
local Inventory = require("@inventory/Inventory")
local Slot = require("@inventory/Slot")
local Stack = require("@inventory/Stack")
local Drop = require("@drops/Drop")
local Ground = require("@drops/Ground")

local failed = 0
local function expect(holds: boolean, what: string)
	print((if holds then "ok    " else "FAIL  ") .. what)
	if not holds then
		failed += 1
	end
end

local function max()
	return 64
end

local function sum(a: number, b: number): (number, number?)
	return a + b, nil
end

-- 1. Two drops at one place that is not a round number, with a reach that is not round, must merge.
local ground = Ground.new()
Ground.addDrop(ground, Drop.new(vector.create(8.25, 0, 0), 1, 0, nil))
Ground.addDrop(ground, Drop.new(vector.create(8.25, 0, 0), 1, 0, nil))
local _, removed = Ground.mergeNearDrops(ground, vector.create(1.1, 1.1, 1.1), sum)
expect(
	#removed == 1 and ground.drops[1].contents == 2,
	"ground-items: two drops at 8.25 with a reach of 1.1 merge into one"
)

-- 2. What the library writes it must read: a drop at an infinite place is refused when it is made.
local okNew = pcall(Drop.new, vector.create(math.huge, 0, 0), 1, 0, nil)
expect(not okNew, "ground-items: Drop.new refuses a position with an infinite component")

-- 3. A reach with an infinite component is refused, or reaches every drop along that axis. It never
-- leaves two drops apart that lie within it.
local wide = Ground.new()
Ground.addDrop(wide, Drop.new(vector.create(0.5, 0, 0), 1, 0, nil))
Ground.addDrop(wide, Drop.new(vector.create(1000.75, 0, 0), 1, 0, nil))
local okReach = pcall(Ground.mergeNearDrops, wide, vector.create(math.huge, 1.1, 1.1), sum)
expect(
	not okReach or (#wide.drops == 1 and wide.drops[1].contents == 2),
	"ground-items: a reach that is infinite along x is refused, or merges two drops 1000.25 apart along x"
)

-- 4. A list with a gap is not saved in silence.
local bag = Inventory.new(3, max)
Slot.setStack(bag[3], Stack.new("ore", 5))
local okGap = pcall(Inventory.encode, { bag[1], nil, bag[3] } :: any)
expect(not okGap, "inventory: Inventory.encode refuses a list of slots with a gap")

-- 5. A rule for a slot that the inventory does not have.
local okRule = pcall(Inventory.new, 2, max, {
	[5] = function()
		return false
	end,
})
expect(not okRule, "inventory: Inventory.new refuses a rule for slot 5 of 2")

-- 6. The mover, when the destination holds the source slot.
local sorted = Inventory.new(3, max)
Slot.setStack(sorted[2], Stack.new("ore", 10))
local count = math.min(sorted[2].stack.count, Inventory.countRoom(sorted, "ore"))
local taken = Slot.takeItems(sorted[2], count)
if taken ~= nil then
	Inventory.addStack(sorted, taken)
end
expect(
	Inventory.countItem(sorted, "ore") == 10,
	"inventory: moving a stack into a list that holds its own slot keeps all 10"
)

-- 7. A limit function that returns a fraction is refused in words that name it.
local okLimit, whyLimit = pcall(
	Slot.putStack,
	Slot.new(function()
		return 2.5
	end),
	Stack.new("a", 5)
)
expect(
	not okLimit and string.find(tostring(whyLimit), "getMaxCount", 1, true) ~= nil,
	"inventory: a limit of 2.5 is refused, in words that name getMaxCount"
)

if failed > 0 then
	error(`{failed} probe(s) failed`, 0)
end
print("every probe holds")
