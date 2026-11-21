-- A gym. Runs on the server of a play test, after `build.server.luau`. Drives one body through
-- phases of what a driver wants, and returns what the body did. `run.py` puts `Drive.luau` and the
-- two lines that set VEHICLE and PHASES above this text.
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local TUNING = { topSpeed = 30, wheelRadius = 2, maxSteerDegrees = 28, skidRatio = 0.7 }

local gym = Workspace:FindFirstChild("VehicleGym") :: Folder
local model = gym:FindFirstChild(VEHICLE) :: Model
local root = model.PrimaryPart :: BasePart

local wheels, motors, servos = {}, {}, {}
local records = (model:FindFirstChild("Wheels") :: Folder):GetChildren()
table.sort(records, function(a, b)
	return a.Name < b.Name
end)
for index, record in records do
	wheels[index] = {
		right = record:GetAttribute("right"),
		forward = record:GetAttribute("forward"),
		steers = record:GetAttribute("steers"),
		drives = record:GetAttribute("drives"),
	}
	motors[index] = (record:FindFirstChild("Motor") :: ObjectValue).Value
	servos[index] = (record:FindFirstChild("Servo") :: ObjectValue).Value
end

-- The one place where an output of `Drive` meets a Roblox hinge. A positive spin about the axle,
-- which points to the body's right, rolls the body backwards, and a positive angle about the
-- vertical turns a wheel to the left, so both signs are turned over here.
local function apply(command)
	local outputs = Drive.getWheelOutputs(wheels, command, TUNING)
	for index, output in outputs do
		local motor = motors[index]
		if motor ~= nil and wheels[index].drives then
			motor.AngularVelocity = -output.angularVelocity
		end
		local servo = servos[index]
		if servo ~= nil then
			servo.TargetAngle = -output.steerDegrees
		end
	end
end

-- The player's client is sent what is near this body, so that a screenshot can show it.
for _, player in game:GetService("Players"):GetPlayers() do
	player.ReplicationFocus = root
end

local start = root.CFrame
local function round(value: number): number
	return math.round(value * 100) / 100
end

-- The heading is added up frame by frame, so that more than a full turn is still counted.
local turnedRightDegrees = 0
local lastLook = root.CFrame.LookVector
local function addTurn()
	local look = root.CFrame.LookVector
	local right = root.CFrame.RightVector
	-- The angle from the last look to this one: positive when the look has moved to the last right.
	local lastRight = Vector3.yAxis:Cross(-lastLook)
	turnedRightDegrees += math.deg(math.atan2(lastRight:Dot(look), lastLook:Dot(look)))
	lastLook = look
	return right
end

local function measure()
	local moved = root.Position - start.Position
	local steerAngles, spins = {}, {}
	for index, record in records do
		local servo = servos[index]
		steerAngles[index] = if servo ~= nil then round(servo.CurrentAngle) else "none"
		local wheel = model:FindFirstChild("Wheel" .. index) :: BasePart
		spins[index] = round((wheel.AssemblyAngularVelocity - root.AssemblyAngularVelocity):Dot(wheel.CFrame.XVector))
	end
	return {
		aheadStuds = round(moved:Dot(start.LookVector)),
		rightStuds = round(moved:Dot(start.RightVector)),
		speed = round(root.AssemblyLinearVelocity.Magnitude),
		turnedRightDegrees = round(turnedRightDegrees),
		yawRateRightDegrees = round(-math.deg(root.AssemblyAngularVelocity.Y)),
		tiltDegrees = round(math.deg(math.acos(math.clamp(root.CFrame.UpVector.Y, -1, 1)))),
		deckHeight = round(root.Position.Y),
		servoAnglesByWheel = steerAngles,
		spinByWheel = spins,
	}
end

local results = { vehicle = VEHICLE, wheels = #wheels, phases = {} }
for _, phase in PHASES do
	if phase.cut ~= nil then
		local part = model:FindFirstChild(phase.cut) :: BasePart
		local joint = part:FindFirstChildOfClass("WeldConstraint") :: WeldConstraint
		joint:Destroy()
	end
	local worstTilt = 0
	local elapsed = 0
	while elapsed < phase.seconds do
		apply(phase.command)
		elapsed += RunService.Heartbeat:Wait()
		addTurn()
		worstTilt = math.max(worstTilt, math.deg(math.acos(math.clamp(root.CFrame.UpVector.Y, -1, 1))))
	end
	local measured = measure()
	measured.phase = phase.name
	measured.worstTiltDegrees = round(worstTilt)
	if phase.cut ~= nil then
		local part = model:FindFirstChild(phase.cut) :: BasePart
		measured.cutPartIsItsOwnBody = part.AssemblyRootPart ~= root.AssemblyRootPart
		measured.cutPartHeight = round(part.Position.Y)
		measured.cutPartStudsFromRoot = round((part.Position - root.Position).Magnitude)
	end
	table.insert(results.phases, measured)
end
apply({ throttle = 0, steer = 0 })
return results
