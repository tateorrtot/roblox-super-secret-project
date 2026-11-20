--!strict
-- Tests for Direction. Run from the repository root: lune run tests/Direction.test.luau

local Check = require("./Check")
local Direction = require("../src/shared/Direction")

local check = Check.that

local function isNear(a: number, b: number): boolean
	return math.abs(a - b) < 1e-9
end

do -- making one
	local alongX = Direction.new(1, 0) :: Direction.Direction
	check(alongX.x == 1 and alongX.z == 0, "new: 1, 0 points along x")
	check(table.isfrozen(alongX), "new: a direction is a frozen value")

	local back = Direction.new(0, -7) :: Direction.Direction
	check(back.x == 0 and back.z == -1, "new: only the way the numbers point counts, not their length")

	local slanted = Direction.new(3, 4) :: Direction.Direction
	check(isNear(slanted.x, 0.6) and isNear(slanted.z, 0.8), "new: 3, 4 points three parts along x to four along z")
	check(isNear(slanted.x ^ 2 + slanted.z ^ 2, 1), "new: a direction has a length of 1")

	local tiny = Direction.new(-1e-6, 1e-6) :: Direction.Direction
	check(isNear(tiny.x, -math.sqrt(0.5)) and isNear(tiny.z, math.sqrt(0.5)), "new: two very small numbers still point")

	check(Direction.new(0, 0) == nil, "new: nil when both numbers are 0, which points nowhere")
end

Check.finish("Direction")
