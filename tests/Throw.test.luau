--!strict
-- Tests for Throw. Run from the repository root: lune run tests/Throw.test.luau

local Check = require("./Check")
local Throw = require("../src/shared/Throw")

local check = Check.that

local HEIGHT = Throw.CHARACTER_THROW_HEIGHT
local SPEED = Throw.CHARACTER_THROW_FORWARD_SPEED
local LIFT = Throw.CHARACTER_THROW_UPWARD_SPEED

local function isNear(a: number, b: number): boolean
	return math.abs(a - b) < 1e-9
end

-- True if `throw` leaves from `x`, `y`, `z`.
local function leavesFrom(throw: Throw.Throw, x: number, y: number, z: number): boolean
	return throw.from.x == x and throw.from.y == y and throw.from.z == z
end

-- How fast `throw` moves along the ground, whichever way.
local function groundSpeed(throw: Throw.Throw): number
	return math.sqrt(throw.velocity.x ^ 2 + throw.velocity.z ^ 2)
end

do -- the throws as numbers
	check(HEIGHT == 3, "a character throws from 3 studs above its feet")
	check(SPEED == 24 and LIFT == 8, "a character throws at 24 studs a second forwards and 8 upwards")
	check(
		Throw.SPILL_OUTWARD_SPEED == 6 and Throw.SPILL_UPWARD_SPEED == 20,
		"a spilled stack leaves at 6 studs a second outwards and 20 upwards"
	)
	check(Throw.SPILL_TURN_RADIANS == 2.4, "each spilled stack goes 2.4 radians further round than the last")
	check(Throw.PUSH_SPEED == 6, "a pushed stack leaves at 6 studs a second")
end

do -- making one
	local from = { x = 10, y = 2, z = -3 }
	local velocity = { x = 1, y = 5, z = -2 }
	local throw = Throw.new(from, velocity)
	check(leavesFrom(throw, 10, 2, -3), "new: leaves from the point given")
	check(
		throw.velocity.x == 1 and throw.velocity.y == 5 and throw.velocity.z == -2,
		"new: moves at the velocity given"
	)
	check(
		table.isfrozen(throw) and table.isfrozen(throw.from) and table.isfrozen(throw.velocity),
		"new: a throw is a frozen value, all the way in"
	)
	from.x = 99
	velocity.y = 99
	check(
		throw.from.x == 10 and throw.velocity.y == 5,
		"new: changing the caller's tables afterwards does not change the throw"
	)
end

do -- let go
	local throw = Throw.newAtRest({ x = 4, y = 0.5, z = 6 })
	check(leavesFrom(throw, 4, 0.5, 6), "newAtRest: leaves from the point given")
	check(
		throw.velocity.x == 0 and throw.velocity.y == 0 and throw.velocity.z == 0,
		"newAtRest: has no speed along any axis"
	)
	check(table.isfrozen(throw), "newAtRest: is a frozen value")
end

do -- thrown by a character
	local alongX = Throw.newFromCharacter({ x = 10, y = 2, z = -3 }, { x = 1, z = 0 })
	check(leavesFrom(alongX, 10, 2 + HEIGHT, -3), "newFromCharacter: leaves from above the character's feet")
	check(
		alongX.velocity.x == SPEED and alongX.velocity.y == LIFT and alongX.velocity.z == 0,
		"newFromCharacter: moves the way the character faces, and upwards"
	)

	local backAlongZ = Throw.newFromCharacter({ x = 0, y = 0, z = 0 }, { x = 0, z = -1 })
	check(
		backAlongZ.velocity.x == 0 and backAlongZ.velocity.z == -SPEED,
		"newFromCharacter: a character facing the other way throws the other way"
	)

	local slanted = Throw.newFromCharacter({ x = 0, y = 0, z = 0 }, { x = 0.6, z = 0.8 })
	check(
		isNear(slanted.velocity.x, 0.6 * SPEED) and isNear(slanted.velocity.z, 0.8 * SPEED),
		"newFromCharacter: a slanted facing splits the speed between x and z"
	)
	check(isNear(groundSpeed(slanted), SPEED), "newFromCharacter: and the speed along the ground is the same")
	check(table.isfrozen(slanted), "newFromCharacter: is a frozen value")
end

do -- spilled out of something
	local from = { x = 10, y = 2, z = -3 }
	local first = Throw.newSpill(from, 1)
	check(leavesFrom(first, 10, 2, -3), "newSpill: leaves from the point given")
	check(first.velocity.y == Throw.SPILL_UPWARD_SPEED, "newSpill: moves upwards")
	check(isNear(groundSpeed(first), Throw.SPILL_OUTWARD_SPEED), "newSpill: and outwards along the ground")
	check(
		isNear(first.velocity.x, math.cos(Throw.SPILL_TURN_RADIANS) * Throw.SPILL_OUTWARD_SPEED)
			and isNear(first.velocity.z, math.sin(Throw.SPILL_TURN_RADIANS) * Throw.SPILL_OUTWARD_SPEED),
		"newSpill: the first goes one turn round from x"
	)
	check(table.isfrozen(first), "newSpill: is a frozen value")

	local allSpread = true
	for index = 1, 30 do
		local one = Throw.newSpill(from, index)
		local next = Throw.newSpill(from, index + 1)
		local cosine = (one.velocity.x * next.velocity.x + one.velocity.z * next.velocity.z)
			/ Throw.SPILL_OUTWARD_SPEED ^ 2
		if
			not isNear(cosine, math.cos(Throw.SPILL_TURN_RADIANS))
			or not isNear(groundSpeed(one), Throw.SPILL_OUTWARD_SPEED)
		then
			allSpread = false
		end
	end
	check(allSpread, "newSpill: each goes the same turn further round than the one before, at the same speed")

	local nearest = math.huge
	for index = 1, 12 do
		for other = index + 1, 12 do
			local one = Throw.newSpill(from, index)
			local another = Throw.newSpill(from, other)
			local apart =
				math.sqrt((one.velocity.x - another.velocity.x) ^ 2 + (one.velocity.z - another.velocity.z) ^ 2)
			nearest = math.min(nearest, apart)
		end
	end
	check(nearest > 1, "newSpill: twelve stacks spilled together all go different ways")
end

do -- pushed aside
	local throw = Throw.newPush({ x = 10, y = 2, z = -3 }, { x = 0, z = -1 })
	check(leavesFrom(throw, 10, 2, -3), "newPush: leaves from the point given")
	check(
		throw.velocity.x == 0 and throw.velocity.y == 0 and throw.velocity.z == -Throw.PUSH_SPEED,
		"newPush: moves along the ground the way it is pushed, and neither up nor down"
	)
	check(Throw.newPush({ x = 0, y = 0, z = 0 }, { x = 1, z = 0 }).velocity.x == Throw.PUSH_SPEED, "newPush: along x")
	check(table.isfrozen(throw), "newPush: is a frozen value")
end

Check.finish("Throw")
