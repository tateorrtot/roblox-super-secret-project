--!strict
--- A direction in the world.
---
--- A direction is a table with numbers under `x`, `y` and `z` that together have a length of 1,
--- so `x = 1, y = 0, z = 0` points along x, and `x = 0, y = 1, z = 0` points straight up. One
--- with a `y` of 0 lies along the ground. It says which way a thing faces or moves, and nothing
--- about how fast or how far. Any such table is a direction. `new` makes one out of any three
--- numbers.
local Direction = {}

--- A direction: how far it goes along x, upwards, and along z, for each stud travelled.
export type Direction = { read x: number, read y: number, read z: number }

--- Returns the direction in which `x`, `y` and `z` point, whatever their length, as a value that
--- cannot be changed. They are any three numbers that are not infinite, however small or large.
--- Returns `nil` if all three are 0, which points nowhere.
function Direction.new(x: number, y: number, z: number): Direction?
	local largest = math.max(math.abs(x), math.abs(y), math.abs(z))
	if largest == 0 then
		return nil
	end
	local scaledX, scaledY, scaledZ = x / largest, y / largest, z / largest
	local length = math.sqrt(scaledX * scaledX + scaledY * scaledY + scaledZ * scaledZ)
	return table.freeze({ x = scaledX / length, y = scaledY / length, z = scaledZ / length })
end

return Direction
