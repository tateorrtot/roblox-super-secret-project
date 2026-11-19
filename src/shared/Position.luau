--!strict
--[=[
	A point in the world: `{ x = 10, y = 0, z = -4 }`, in studs. `y` is
	height.

	The rules make no Roblox calls, so they do not use Roblox's Vector3. The
	server turns a Vector3 into a position when it tells the rules where
	something is, and back when it draws.

	A position is a value and never changes. Any table with numbers under
	`x`, `y` and `z` is a position; [method new] makes a frozen one.

	```lua
	local here = Position.new(10, 0, -4)
	Position.distance(here, Position.new(13, 4, -4)) --> 5, in a straight line
	Position.groundDistance(here, Position.new(13, 4, -4)) --> 3, leaving height out
	```
]=]
local Position = {}

--- `read` means code outside this module cannot assign the field, and nothing inside it does
--- either: a position never changes.
export type Position = { read x: number, read y: number, read z: number }

-- True for a number that is not infinite and not NaN.
local function isOrdinaryNumber(value: unknown): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

--[=[
	Returns what is wrong with `value` as a position, in words, or `nil` if
	nothing is: it is a table with a number under each of `x`, `y` and `z`,
	none of them infinite or not-a-number.

	`value` may be anything at all.
]=]
function Position.validate(value: unknown): string?
	if type(value) ~= "table" then
		return "a position is a table with x, y and z, not a " .. type(value)
	end
	for _, axis in { "x", "y", "z" } do
		local coordinate = (value :: any)[axis]
		if not isOrdinaryNumber(coordinate) then
			return string.format("position.%s must be a number; got %s", axis, tostring(coordinate))
		end
	end
	return nil
end

--[=[
	Returns the position `x`, `y`, `z`.

	Raises an error if any of the three is not a number, or is infinite or
	not-a-number.
]=]
function Position.new(x: number, y: number, z: number): Position
	local position = { x = x, y = y, z = z }
	local problem = Position.validate(position)
	if problem ~= nil then
		error("Position.new: " .. problem, 2)
	end
	return table.freeze(position)
end

--[=[
	Returns how far apart two positions are in a straight line, in studs.
]=]
function Position.distance(a: Position, b: Position): number
	return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2)
end

--[=[
	Returns how far apart two positions are along the ground, in studs:
	the distance between them with height left out.
]=]
function Position.groundDistance(a: Position, b: Position): number
	return math.sqrt((a.x - b.x) ^ 2 + (a.z - b.z) ^ 2)
end

return Position
