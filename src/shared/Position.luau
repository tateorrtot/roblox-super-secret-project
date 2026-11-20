--!strict
--- A point in the world, in studs.
---
--- A position is a table with numbers under `x`, `y` and `z`, where `y` is height. Any such table
--- is a position, and `new` makes a frozen one. Positions never change: `distance` and
--- `groundDistance` measure between two of them. Use `validate` on a value that arrives from
--- outside the game.
local Position = {}

--- A point in the world: `x` and `z` run along the ground and `y` is height, all in studs.
export type Position = { read x: number, read y: number, read z: number }

local function isFiniteNumber(value: unknown): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

--- Returns what is wrong with `value` as a position, in words, or `nil` if nothing is. A position
--- is a table with a number under each of `x`, `y` and `z`, none of them infinite or NaN. `value`
--- may be any value at all.
function Position.validate(value: unknown): string?
	if type(value) ~= "table" then
		return `a position is a table with x, y and z, not a {type(value)}`
	end
	for _, axis in { "x", "y", "z" } do
		local coordinate = (value :: any)[axis]
		if not isFiniteNumber(coordinate) then
			return `position.{axis} must be a number; got {coordinate}`
		end
	end
	return nil
end

--- Returns a frozen position at `x`, `y`, `z`.
function Position.new(x: number, y: number, z: number): Position
	return table.freeze({ x = x, y = y, z = z })
end

--- Returns the straight-line distance between `a` and `b`, in studs, counting height.
function Position.distance(a: Position, b: Position): number
	return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2)
end

--- Returns the distance between `a` and `b` along the ground, in studs. This is `distance` with
--- height left out, so it is 0 for two positions directly above one another.
function Position.groundDistance(a: Position, b: Position): number
	return math.sqrt((a.x - b.x) ^ 2 + (a.z - b.z) ^ 2)
end

return Position
