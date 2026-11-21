--!strict
-- Run with: lune run gyms/vehicles/Drive.test
local Drive = require("./Drive")

local failed = 0
local function check(condition: boolean, what: string)
	if not condition then
		failed += 1
		print("FAIL  " .. what)
	end
end
local function near(a: number, b: number): boolean
	return math.abs(a - b) < 1e-9
end

local tuning = { topSpeed = 37.5, wheelRadius = 1.7, maxSteerDegrees = 31, skidRatio = 0.6 }

-- A body with two steering wheels ahead and two plain driving wheels behind, at uneven places.
local car = {
	{ right = -7.25, forward = 6.1, steers = true, drives = true },
	{ right = 7.25, forward = 5.4, steers = true, drives = true },
	{ right = -7.25, forward = -6.3, steers = false, drives = true },
	{ right = 6.9, forward = -5.8, steers = false, drives = false },
}
local outputs = Drive.getWheelOutputs(car, { throttle = 0.73, steer = 0.41 }, tuning)
check(#outputs == 4, "getWheelOutputs returns one output for each wheel")
check(near(outputs[1].angularVelocity, 0.73 * 37.5 / 1.7), "a driving wheel spins at throttle * topSpeed / wheelRadius")
check(near(outputs[1].steerDegrees, 0.41 * 31), "a steering wheel ahead of the middle turns by steer * maxSteerDegrees")
check(near(outputs[3].steerDegrees, 0), "a wheel that does not steer keeps an angle of 0")
check(near(outputs[4].angularVelocity, 0), "a wheel that does not drive is not spun")
check(
	near(outputs[3].angularVelocity, outputs[1].angularVelocity),
	"with a steering wheel on the body, both sides spin alike"
)

-- A wheel that steers from behind the middle turns the other way.
local rearSteer = { { right = 0.3, forward = -4.7, steers = true, drives = false } }
check(
	near(Drive.getWheelOutputs(rearSteer, { throttle = 0, steer = 0.5 }, tuning)[1].steerDegrees, -0.5 * 31),
	"a steering wheel behind the middle turns the other way"
)

-- A body with no steering wheel turns as a tank does.
local tank = {
	{ right = -5.3, forward = 3.7, steers = false, drives = true },
	{ right = 5.3, forward = 4.4, steers = false, drives = true },
}
local turning = Drive.getWheelOutputs(tank, { throttle = 0.3, steer = 0.8 }, tuning)
check(
	near(turning[1].angularVelocity, (0.3 + 0.8 * 0.6) * 37.5 / 1.7),
	"with no steering wheel, a left wheel spins faster to turn right"
)
check(
	near(turning[2].angularVelocity, (0.3 - 0.8 * 0.6) * 37.5 / 1.7),
	"with no steering wheel, a right wheel spins slower to turn right"
)
local pinned = Drive.getWheelOutputs(tank, { throttle = 0.9, steer = 1 }, tuning)
check(near(pinned[1].angularVelocity, 37.5 / 1.7), "a side never spins faster than the top speed")

print(if failed == 0 then "Drive: all checks passed" else `Drive: {failed} failed`)
if failed > 0 then
	error("Drive tests failed", 0)
end
