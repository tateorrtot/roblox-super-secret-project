--!strict
--- How a stack sets off when it leaves an inventory for the world: where from, and how fast.
---
--- A throw is a value: the point a stack leaves from, and its velocity as it leaves. It says
--- nothing of what happens next. `newFromCharacter` is the throw of a character, `newSpill` of a
--- stack that bursts out of something, `newPush` of a stack shoved aside, and `newAtRest` of a
--- stack that is only let go. Every speed here is in studs a second.
local Direction = require("./Direction")
local Position = require("./Position")

local Throw = {}

type Direction = Direction.Direction
type Position = Position.Position

--- How fast a thing moves along each axis, in studs a second. `y` is upwards.
export type Velocity = { read x: number, read y: number, read z: number }

--- One stack's setting off. It never changes.
export type Throw = {
	--- The point the stack leaves from.
	read from: Position,
	--- How fast the stack is moving as it leaves.
	read velocity: Velocity,
}

--- How far above a character's feet a stack that the character throws leaves from, in studs.
Throw.CHARACTER_THROW_HEIGHT = 3

--- How fast a stack that a character throws moves along the ground, the way the character faces.
Throw.CHARACTER_THROW_SPEED = 24

--- How fast a stack that a character throws moves upwards as it leaves.
Throw.CHARACTER_THROW_LIFT = 8

--- How fast a spilled stack moves along the ground.
Throw.SPILL_SPEED = 6

--- How fast a spilled stack moves upwards as it leaves.
Throw.SPILL_LIFT = 20

--- The angle between the way one spilled stack goes and the way the next goes, in radians. It is
--- the angle that never brings a stack round to a direction already taken.
Throw.SPILL_TURN = 2.4

--- How fast a pushed stack moves along the ground.
Throw.PUSH_SPEED = 6

--- Returns a throw that leaves from `from`, moving at `velocity`. It cannot be changed, and it
--- stays as it is if `from` or `velocity` is changed afterwards.
function Throw.new(from: Position, velocity: Velocity): Throw
	return table.freeze({
		from = Position.new(from.x, from.y, from.z),
		velocity = table.freeze({ x = velocity.x, y = velocity.y, z = velocity.z }),
	})
end

--- Returns a throw with no speed at all: the stack is let go at `from`.
function Throw.newAtRest(from: Position): Throw
	return Throw.new(from, { x = 0, y = 0, z = 0 })
end

--- Returns the throw of a character whose feet are at `position` and who faces `facing`. The stack
--- leaves from `CHARACTER_THROW_HEIGHT` above `position`, moving the way the character faces at
--- `CHARACTER_THROW_SPEED` and upwards at `CHARACTER_THROW_LIFT`.
function Throw.newFromCharacter(position: Position, facing: Direction): Throw
	local from = { x = position.x, y = position.y + Throw.CHARACTER_THROW_HEIGHT, z = position.z }
	return Throw.new(from, {
		x = facing.x * Throw.CHARACTER_THROW_SPEED,
		y = Throw.CHARACTER_THROW_LIFT,
		z = facing.z * Throw.CHARACTER_THROW_SPEED,
	})
end

--- Returns the throw of a stack that spills out of something at `from`: upwards at `SPILL_LIFT`,
--- and along the ground at `SPILL_SPEED`. `index` says which of the stacks spilled together it
--- is, counting from 1. Each goes `SPILL_TURN` further round than the one before, so that they
--- land spread out around `from`.
function Throw.newSpill(from: Position, index: number): Throw
	local angle = index * Throw.SPILL_TURN
	return Throw.new(from, {
		x = math.cos(angle) * Throw.SPILL_SPEED,
		y = Throw.SPILL_LIFT,
		z = math.sin(angle) * Throw.SPILL_SPEED,
	})
end

--- Returns the throw of a stack that is pushed aside from `from`: along the ground towards
--- `direction` at `PUSH_SPEED`, and neither up nor down.
function Throw.newPush(from: Position, direction: Direction): Throw
	return Throw.new(from, { x = direction.x * Throw.PUSH_SPEED, y = 0, z = direction.z * Throw.PUSH_SPEED })
end

return Throw
