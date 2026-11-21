-- Probes that the faults which the review found are mended. Run: lune run gyms/items/probe
local Inventory = require("@inventory/Inventory")
local Slot = require("@inventory/Slot")
local Stack = require("@inventory/Stack")
local Drop = require("@drops/Drop")
local Ground = require("@drops/Ground")
local function max()
	return 64
end

-- 1. Two drops at one place that is not a round number, with a reach that is not round, must merge.
local ground = Ground.new()
Ground.addDrop(ground, Drop.new(vector.create(8.25, 0, 0), 1, 0, nil))
Ground.addDrop(ground, Drop.new(vector.create(8.25, 0, 0), 1, 0, nil))
local _, removed = Ground.mergeNearDrops(ground, vector.create(1.1, 1.1, 1.1), function(a, b)
	return a + b, nil
end)
print("ground-items 1: two drops at 8.25 with a reach of 1.1 merge:", #removed == 1 and ground.drops[1].contents == 2)

-- 2. What the library writes it must read: a drop at an infinite place.
local okNew, whyNew = pcall(Drop.new, vector.create(math.huge, 0, 0), 1, 0, nil)
print(
	"ground-items 2: a drop at an infinite place is refused when it is made:",
	not okNew,
	okNew and "" or tostring(whyNew)
)

-- 3. A reach with an infinite component.
local okReach, whyReach = pcall(Ground.mergeNearDrops, ground, vector.create(math.huge, 1, 1), function(a, b)
	return a + b, nil
end)
print("ground-items 3: an infinite reach is refused, or merges:", (not okReach) and tostring(whyReach) or "no error")

-- 4. A list with a gap is not saved in silence.
local bag = Inventory.new(3, max)
Slot.setStack(bag[3], Stack.new("ore", 5))
local okGap, whyGap = pcall(Inventory.encode, { bag[1], nil, bag[3] } :: any)
print("inventory 1: a list with a gap is refused by encode:", not okGap, okGap and "" or tostring(whyGap))

-- 5. A rule for a slot that the inventory does not have.
local okRule, whyRule = pcall(Inventory.new, 2, max, {
	[5] = function()
		return false
	end,
})
print("inventory 2: a rule for slot 5 of 2 is refused:", not okRule, okRule and "" or tostring(whyRule))

-- 6. The mover, when the destination holds the source slot.
local sorted = Inventory.new(3, max)
Slot.setStack(sorted[2], Stack.new("ore", 10))
local count = math.min(sorted[2].stack.count, Inventory.countRoom(sorted, "ore"))
local taken = Slot.takeItems(sorted[2], count)
if taken ~= nil then
	Inventory.addStack(sorted, taken)
end
print(
	"inventory 3: moving a stack into a list that holds its own slot keeps all 10:",
	Inventory.countItem(sorted, "ore") == 10
)

-- 7. A limit function that returns a fraction.
local okLimit, whyLimit = pcall(
	Slot.putStack,
	Slot.new(function()
		return 2.5
	end),
	Stack.new("a", 5)
)
print(
	"inventory 4: a limit of 2.5 is refused in words that name getMaxCount:",
	(not okLimit) and tostring(whyLimit) or "no error"
)
