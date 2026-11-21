--!strict
--- A point in the world, as a table of `x`, `y` and `z`, in studs.
---
--- `y` is height. Any table of that shape is a position. `new` makes a frozen one, and
--- `getDistance` and `getGroundDistance` measure the distance between two positions.
local Position = {}

--- A point in the world: `x` and `z` run along the ground, and `y` is height, all in studs.
export type Position = { read x: number, read y: number, read z: number }

--- Returns a new position at `x`, `y`, `z`. The position is frozen, so nothing can assign its
--- fields.
function Position.new(x: number, y: number, z: number): Position
	return table.freeze({ x = x, y = y, z = z })
end

--- Returns the length of the straight line from `a` to `b`, in studs. The length includes the
--- difference in `y`.
function Position.getDistance(a: Position, b: Position): number
	return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2)
end

--- Returns the distance from `a` to `b` along the ground, in studs. Ignores the difference in
--- `y`, so returns `0` for two positions with the same `x` and `z`.
function Position.getGroundDistance(a: Position, b: Position): number
	return math.sqrt((a.x - b.x) ^ 2 + (a.z - b.z) ^ 2)
end

return Position
