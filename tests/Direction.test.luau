--!strict
-- Tests for Direction. Run from the repository root: lune run tests/Direction.test.luau

local Check = require("./Check")
local Direction = require("../src/shared/Direction")

local check = Check.that

local function isNear(a: number, b: number): boolean
	return math.abs(a - b) < 1e-9
end

-- True if `direction` points `x`, `y`, `z`, to within a rounding error.
local function points(direction: Direction.Direction, x: number, y: number, z: number): boolean
	return isNear(direction.x, x) and isNear(direction.y, y) and isNear(direction.z, z)
end

do -- making one
	local alongX = Direction.new(1, 0, 0) :: Direction.Direction
	check(alongX.x == 1 and alongX.y == 0 and alongX.z == 0, "new: 1, 0, 0 points along x")
	check(table.isfrozen(alongX), "new: a direction is a frozen value")
	local up = Direction.new(0, 1, 0) :: Direction.Direction
	check(up.x == 0 and up.y == 1 and up.z == 0, "new: 0, 1, 0 points straight up")
	local alongZ = Direction.new(0, 0, 1) :: Direction.Direction
	check(alongZ.x == 0 and alongZ.y == 0 and alongZ.z == 1, "new: 0, 0, 1 points along z")

	local back = Direction.new(0, 0, -7) :: Direction.Direction
	check(back.x == 0 and back.y == 0 and back.z == -1, "new: only the way the numbers point counts, not their length")
	local down = Direction.new(0, -0.25, 0) :: Direction.Direction
	check(down.x == 0 and down.y == -1 and down.z == 0, "new: a short way down is straight down")

	local alongGround = Direction.new(3, 0, 4) :: Direction.Direction
	check(points(alongGround, 0.6, 0, 0.8), "new: 3, 0, 4 points three parts along x to four along z, along the ground")
	local rising = Direction.new(0, 3, -4) :: Direction.Direction
	check(points(rising, 0, 0.6, -0.8), "new: 0, 3, -4 points three parts up to four back along z")
	local slanted = Direction.new(2, -3, 6) :: Direction.Direction
	check(points(slanted, 2 / 7, -3 / 7, 6 / 7), "new: 2, -3, 6 points two parts along x, three down and six along z")
	check(isNear(slanted.x ^ 2 + slanted.y ^ 2 + slanted.z ^ 2, 1), "new: a direction has a length of 1")

	local third = math.sqrt(1 / 3)
	local tiny = Direction.new(-1e-6, 1e-6, 1e-6) :: Direction.Direction
	check(points(tiny, -third, third, third), "new: three very small numbers still point")

	-- Numbers whose squares are too small or too large for a number to hold.
	local faint = Direction.new(2.7e-162, 0, 0) :: Direction.Direction
	check(
		faint.x == 1 and faint.y == 0 and faint.z == 0,
		"new: a number too small to square still points, with a length of 1"
	)
	local faintUp = Direction.new(0, 2.7e-162, 0) :: Direction.Direction
	check(faintUp.x == 0 and faintUp.y == 1 and faintUp.z == 0, "new: so does one that points up")
	local faintAlongZ = Direction.new(0, 0, -2.7e-162) :: Direction.Direction
	check(faintAlongZ.x == 0 and faintAlongZ.y == 0 and faintAlongZ.z == -1, "new: and one that points along z")
	local fainter = Direction.new(1e-170, -1e-170, 1e-170) :: Direction.Direction
	check(points(fainter, third, -third, third), "new: so do three of them")
	local vast = Direction.new(-2e200, 3e200, 6e200) :: Direction.Direction
	check(points(vast, -2 / 7, 3 / 7, 6 / 7), "new: numbers too large to square point with a length of 1")

	check(Direction.new(0, 0, 0) == nil, "new: nil when all three numbers are 0, which points nowhere")
	check(
		Direction.new(1e-300, 0, 0) ~= nil
			and Direction.new(0, -1e-300, 0) ~= nil
			and Direction.new(0, 0, 1e-300) ~= nil,
		"new: but one number that is not 0, however small and whichever it is, points"
	)
end

Check.finish("Direction")
