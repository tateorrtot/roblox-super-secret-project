--!strict
--- What each wheel's motor and steering does, worked out from what the driver wants.
---
--- A gym. It tries one idea: a vehicle is any body with wheels at any places, and one function turns
--- a `Command` into an output for each wheel. It knows no Roblox instance, so `lune` runs it.
local Drive = {}

--- One wheel, by where it is on the body and what it can do.
export type Wheel = {
	--- Studs to the right of the body's middle. Negative is to the left.
	right: number,
	--- Studs ahead of the body's middle. Negative is behind.
	forward: number,
	--- If `true`, the wheel turns about a vertical axis to steer.
	steers: boolean,
	--- If `true`, a motor spins the wheel.
	drives: boolean,
}

--- What the driver wants. A person's input and a helper's brain both make one.
export type Command = {
	--- From `-1`, full reverse, to `1`, full ahead.
	throttle: number,
	--- From `-1`, full left, to `1`, full right.
	steer: number,
}

--- The numbers of one vehicle.
export type Tuning = {
	--- The speed at a throttle of `1`, in studs a second.
	topSpeed: number,
	--- The radius of every wheel, in studs.
	wheelRadius: number,
	--- The angle of a steering wheel at a steer of `1`, in degrees.
	maxSteerDegrees: number,
	--- How much of the throttle's range a steer of `1` takes from one side and gives to the other,
	--- for a body with no wheel that steers. From `0` to `1`.
	skidRatio: number,
}

--- What one wheel is told to do.
export type WheelOutput = {
	--- How fast the wheel spins, in radians a second. Positive rolls the body ahead.
	angularVelocity: number,
	--- The angle of the wheel about the vertical axis, in degrees. Positive points it to the right.
	steerDegrees: number,
}

local function hasSteeringWheel(wheels: { Wheel }): boolean
	for _, wheel in wheels do
		if wheel.steers then
			return true
		end
	end
	return false
end

--- Returns a `WheelOutput` for each of `wheels`, in the same order.
---
--- A wheel that drives spins at `command.throttle * tuning.topSpeed / tuning.wheelRadius`. A wheel
--- that steers is turned by `command.steer * tuning.maxSteerDegrees`, and the other way if it is
--- behind the body's middle. If no wheel steers, the body turns as a tank does: each driving wheel
--- on the right spins slower by `command.steer * tuning.skidRatio` of the throttle's range, and each
--- on the left faster.
function Drive.getWheelOutputs(wheels: { Wheel }, command: Command, tuning: Tuning): { WheelOutput }
	local steersByWheels = hasSteeringWheel(wheels)
	local fullSpin = tuning.topSpeed / tuning.wheelRadius
	local outputs: { WheelOutput } = {}
	for index, wheel in wheels do
		local throttle = command.throttle
		if wheel.drives and not steersByWheels then
			local side = if wheel.right >= 0 then 1 else -1
			throttle = math.clamp(command.throttle - command.steer * side * tuning.skidRatio, -1, 1)
		end
		local steerDegrees = 0
		if wheel.steers then
			local side = if wheel.forward >= 0 then 1 else -1
			steerDegrees = command.steer * tuning.maxSteerDegrees * side
		end
		outputs[index] = {
			angularVelocity = if wheel.drives then throttle * fullSpin else 0,
			steerDegrees = steerDegrees,
		}
	end
	return outputs
end

return Drive
