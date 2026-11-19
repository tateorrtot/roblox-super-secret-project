--!strict
-- Tests for Position. Run from the repository root: lune run tests/world/Position.test.luau

local Check = require("../Check")
local Position = require("../../src/shared/world/Position")

local check = Check.that
local raises = Check.raises

do -- making one
	local here = Position.new(10, 2, -4)
	check(here.x == 10 and here.y == 2 and here.z == -4, "new: holds the three numbers it was given")
	check(table.isfrozen(here), "new: a position is a frozen value")
	check(Position.new(0, 0, 0).x == 0, "new: zero is a number like any other")
	check(Position.new(1.5, -0.25, 1e6).y == -0.25, "new: fractions and large numbers are fine")
end

do -- what is and is not a position
	check(Position.validate(Position.new(1, 2, 3)) == nil, "validate: nothing is wrong with a position new made")
	check(Position.validate({ x = 1, y = 2, z = 3 }) == nil, "validate: nor with one written by hand")
	check(Position.validate({ x = 1, y = 2, z = 3, name = "home" }) == nil, "validate: other fields do not matter")
	check(
		Position.validate(nil) == "a position is a table with x, y and z, not a nil",
		"validate: nothing is not a position"
	)
	check(
		Position.validate("here") == "a position is a table with x, y and z, not a string",
		"validate: nor is a string"
	)
	check(Position.validate(7) == "a position is a table with x, y and z, not a number", "validate: nor is a number")
	check(
		Position.validate({ y = 2, z = 3 }) == "position.x must be a number; got nil",
		"validate: says when x is missing"
	)
	check(
		Position.validate({ x = 1, y = "high", z = 3 }) == "position.y must be a number; got high",
		"validate: says when y is not a number"
	)
	check(
		Position.validate({ x = 1, y = 2 }) == "position.z must be a number; got nil",
		"validate: says when z is missing"
	)
	check(
		Position.validate({ x = 0 / 0, y = 2, z = 3 }) == "position.x must be a number; got nan",
		"validate: not-a-number is refused"
	)
	check(
		Position.validate({ x = 1, y = math.huge, z = 3 }) == "position.y must be a number; got inf",
		"validate: infinity is refused"
	)
	check(
		Position.validate({ x = 1, y = 2, z = -math.huge }) == "position.z must be a number; got -inf",
		"validate: so is minus infinity"
	)
	check(
		Position.validate({ 1, 2, 3 }) == "position.x must be a number; got nil",
		"validate: a list of three numbers is not a position"
	)

	check(
		raises("Position.new: position.y must be a number; got nil", function()
			return Position.new(1, nil :: any, 3)
		end),
		"new: refuses a missing number"
	)
	check(
		raises("Position.new: position.x must be a number; got nan", function()
			return Position.new(0 / 0, 2, 3)
		end),
		"new: refuses not-a-number"
	)
	check(
		raises("Position.new: position.z must be a number; got 3", function()
			return Position.new(1, 2, "3" :: any)
		end),
		"new: refuses a number written as a string"
	)
end

do -- distances
	local here = Position.new(10, 0, -4)
	check(Position.distance(here, here) == 0, "distance: 0 from a position to itself")
	check(Position.distance(here, Position.new(13, 4, -4)) == 5, "distance: in a straight line, height counted")
	check(Position.distance(Position.new(13, 4, -4), here) == 5, "distance: the same both ways")
	check(Position.distance(here, Position.new(10, 0, -16)) == 12, "distance: along z")
	check(Position.distance(Position.new(1, 2, 3), Position.new(3, 5, 9)) == 7, "distance: along all three at once")
	check(Position.groundDistance(here, Position.new(13, 4, -4)) == 3, "groundDistance: height is left out")
	check(Position.groundDistance(here, Position.new(10, 99, -4)) == 0, "groundDistance: 0 straight above")
	check(Position.groundDistance(here, Position.new(13, -7, 0)) == 5, "groundDistance: along x and z together")
	check(Position.groundDistance(Position.new(13, -7, 0), here) == 5, "groundDistance: the same both ways")
	check(
		Position.distance({ x = 0, y = 0, z = 0 }, { x = 0, y = 2, z = 0 }) == 2,
		"distance: works on a position written by hand"
	)
end

Check.finish("Position")
