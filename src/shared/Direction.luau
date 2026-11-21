--!strict
--- A way in the world: a table of `x`, `y` and `z` with a length of `1`.
---
--- `x = 1, y = 0, z = 0` points along x, and `x = 0, y = 1, z = 0` points straight up. A direction
--- with a `y` of `0` lies along the ground. A direction holds no speed and no distance. Any table
--- of that shape is a direction. `new` makes one from three numbers that are not all `0`.
local Direction = {}

--- A way in the world: how far it goes along x, upwards, and along z, for each stud travelled.
export type Direction = { read x: number, read y: number, read z: number }

--- Returns the frozen direction in which `x`, `y` and `z` point, scaled to a length of `1`. Accepts
--- finite numbers of any size. Returns `nil` if all three are `0`, which points nowhere.
--- Note: `new` does not check that the numbers are finite, and the result for an infinite or NaN
--- number is not a direction.
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
