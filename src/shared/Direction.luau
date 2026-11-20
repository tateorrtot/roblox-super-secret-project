--!strict
--- A direction along the ground.
---
--- A direction is a table with numbers under `x` and `z` that together have a length of 1, so
--- `x = 1, z = 0` points along x. It says which way a thing faces or moves, and nothing about
--- height. Any such table is a direction. `new` makes one out of any two numbers.
local Direction = {}

--- A direction along the ground: how far it goes along x and along z for each stud travelled.
export type Direction = { read x: number, read z: number }

--- Returns the direction in which `x` and `z` point, whatever their length, as a value that cannot
--- be changed. `x` and `z` are any two numbers that are not infinite, however small or large.
--- Returns `nil` if both are 0, which points nowhere.
function Direction.new(x: number, z: number): Direction?
	local largest = math.max(math.abs(x), math.abs(z))
	if largest == 0 then
		return nil
	end
	local scaledX, scaledZ = x / largest, z / largest
	local length = math.sqrt(scaledX * scaledX + scaledZ * scaledZ)
	return table.freeze({ x = scaledX / length, z = scaledZ / length })
end

return Direction
