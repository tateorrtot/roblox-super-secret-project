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

	-- Numbers whose squares are too small or too large for a number to hold.
	local faint = Direction.new(2.7e-162, 0) :: Direction.Direction
	check(faint.x == 1 and faint.z == 0, "new: a number too small to square still points, with a length of 1")
	local fainter = Direction.new(1e-170, -1e-170) :: Direction.Direction
	check(isNear(fainter.x, math.sqrt(0.5)) and isNear(fainter.z, -math.sqrt(0.5)), "new: so do two of them")
	local vast = Direction.new(-3e200, 4e200) :: Direction.Direction
	check(isNear(vast.x, -0.6) and isNear(vast.z, 0.8), "new: numbers too large to square point with a length of 1")

	check(Direction.new(0, 0) == nil, "new: nil when both numbers are 0, which points nowhere")
end

Check.finish("Direction")
