--!strict
--- A point in the world, in studs.
---
--- A position is a table with numbers under `x`, `y` and `z`, where `y` is height. Any such table
--- is a position. `distance` and `groundDistance` measure between two of them.
local Position = {}

--- A point in the world: `x` and `z` run along the ground and `y` is height, all in studs.
export type Position = { read x: number, read y: number, read z: number }

--- Returns a position at `x`, `y`, `z` that cannot be changed.
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
