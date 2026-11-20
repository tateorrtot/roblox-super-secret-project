--!strict
-- Tests for Position. Run from the repository root: lune run tests/Position.test.luau

local Check = require("./Check")
local Position = require("../src/shared/Position")

local check = Check.that

do -- making one
	local here = Position.new(10, 2, -4)
	check(here.x == 10 and here.y == 2 and here.z == -4, "new: holds the three numbers it was given")
	check(table.isfrozen(here), "new: a position is a frozen value")
	check(Position.new(0, 0, 0).x == 0, "new: zero is a number like any other")
	check(Position.new(1.5, -0.25, 1e6).y == -0.25, "new: fractions and large numbers are fine")
end

do -- distances
	local here = Position.new(10, 0, -4)
	check(Position.getDistance(here, here) == 0, "getDistance: 0 from a position to itself")
	check(Position.getDistance(here, Position.new(13, 4, -4)) == 5, "getDistance: in a straight line, height counted")
	check(Position.getDistance(Position.new(13, 4, -4), here) == 5, "getDistance: the same both ways")
	check(Position.getDistance(here, Position.new(10, 0, -16)) == 12, "getDistance: along z")
	check(
		Position.getDistance(Position.new(1, 2, 3), Position.new(3, 5, 9)) == 7,
		"getDistance: along all three at once"
	)
	check(Position.getGroundDistance(here, Position.new(13, 4, -4)) == 3, "getGroundDistance: height is left out")
	check(Position.getGroundDistance(here, Position.new(10, 99, -4)) == 0, "getGroundDistance: 0 straight above")
	check(Position.getGroundDistance(here, Position.new(13, -7, 0)) == 5, "getGroundDistance: along x and z together")
	check(Position.getGroundDistance(Position.new(13, -7, 0), here) == 5, "getGroundDistance: the same both ways")
	check(
		Position.getDistance({ x = 0, y = 0, z = 0 }, { x = 0, y = 2, z = 0 }) == 2,
		"getDistance: works on a position written by hand"
	)
end

Check.finish("Position")
