-- A gym. Runs on the server of a play test. Builds a floor high above the world, and two bodies of
-- welded blocks with wheels on hinges. `drive.server.luau` then drives one of them.
-- Run it with: python gyms/vehicles/run.py
local Workspace = game:GetService("Workspace")

local GROUND_Y = 600
local WHEEL_RADIUS = 2
local WHEEL_WIDTH = 1.5
local CELL = 4

local old = Workspace:FindFirstChild("VehicleGym")
if old then
	old:Destroy()
end
local gym = Instance.new("Folder")
gym.Name = "VehicleGym"
gym.Parent = Workspace

local ground = Instance.new("Part")
ground.Name = "Ground"
ground.Anchored = true
ground.Size = Vector3.new(700, 2, 700)
ground.Position = Vector3.new(0, GROUND_Y - 1, 0)
ground.Color = Color3.fromRGB(90, 110, 90)
ground.Parent = gym

local function makeBlock(model: Model, size: Vector3, cframe: CFrame, name: string, color: Color3): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = model
	return part
end

local function weld(a: BasePart, b: BasePart): WeldConstraint
	local constraint = Instance.new("WeldConstraint")
	constraint.Part0 = a
	constraint.Part1 = b
	constraint.Parent = b
	return constraint
end

-- Adds one wheel to `root` at the place that `spec` gives, and a record of it for the drive script.
local function addWheel(model: Model, root: BasePart, records: Folder, index: number, spec, bodyCFrame: CFrame)
	-- Ahead is the body's -Z, as Roblox's LookVector is. The axle is half a stud below the deck's middle.
	local wheelCFrame = bodyCFrame * CFrame.new(spec.right, -0.5, -spec.forward)
	local wheel = Instance.new("Part")
	wheel.Name = "Wheel" .. index
	wheel.Shape = Enum.PartType.Cylinder
	wheel.Size = Vector3.new(WHEEL_WIDTH, WHEEL_RADIUS * 2, WHEEL_RADIUS * 2)
	wheel.CFrame = wheelCFrame
	wheel.Color = Color3.fromRGB(40, 40, 40)
	wheel.CustomPhysicalProperties = PhysicalProperties.new(0.7, 1.4, 0, 100, 1)
	wheel.Parent = model
	local wheelAttachment = Instance.new("Attachment")
	wheelAttachment.Parent = wheel

	local mountPart: BasePart = root
	local mountCFrame = root.CFrame:ToObjectSpace(wheelCFrame)
	local servo: HingeConstraint? = nil
	if spec.steers then
		local knuckle = Instance.new("Part")
		knuckle.Name = "Knuckle" .. index
		knuckle.Size = Vector3.new(2, 2, 2)
		knuckle.CFrame = wheelCFrame
		knuckle.CanCollide = false
		knuckle.Transparency = 0.6
		knuckle.CustomPhysicalProperties = PhysicalProperties.new(2, 0.3, 0)
		knuckle.Parent = model
		-- An attachment whose first axis points up, so that the hinge turns about the vertical.
		local up = CFrame.fromMatrix(Vector3.zero, Vector3.yAxis, -Vector3.xAxis)
		local onRoot = Instance.new("Attachment")
		onRoot.CFrame = mountCFrame * up
		onRoot.Parent = root
		local onKnuckle = Instance.new("Attachment")
		onKnuckle.CFrame = up
		onKnuckle.Parent = knuckle
		local hinge = Instance.new("HingeConstraint")
		hinge.Name = "Steer"
		hinge.Attachment0 = onRoot
		hinge.Attachment1 = onKnuckle
		hinge.ActuatorType = Enum.ActuatorType.Servo
		hinge.ServoMaxTorque = 1e7
		hinge.AngularSpeed = 3
		hinge.TargetAngle = 0
		hinge.Parent = knuckle
		servo = hinge
		mountPart = knuckle
		mountCFrame = CFrame.new()
	end

	local mount = Instance.new("Attachment")
	mount.CFrame = mountCFrame
	mount.Parent = mountPart
	local motor = Instance.new("HingeConstraint")
	motor.Name = "Spin"
	motor.Attachment0 = mount
	motor.Attachment1 = wheelAttachment
	if spec.drives then
		motor.ActuatorType = Enum.ActuatorType.Motor
		motor.MotorMaxTorque = 2e5
		motor.MotorMaxAcceleration = 30
		motor.AngularVelocity = 0
	end
	motor.Parent = wheel

	local record = Instance.new("Configuration")
	record.Name = string.format("Wheel%02d", index)
	record:SetAttribute("right", spec.right)
	record:SetAttribute("forward", spec.forward)
	record:SetAttribute("steers", spec.steers)
	record:SetAttribute("drives", spec.drives)
	local motorValue = Instance.new("ObjectValue")
	motorValue.Name = "Motor"
	motorValue.Value = motor
	motorValue.Parent = record
	local servoValue = Instance.new("ObjectValue")
	servoValue.Name = "Servo"
	servoValue.Value = servo
	servoValue.Parent = record
	record.Parent = records
end

-- Builds a body: a deck of cells welded to the first cell, blocks on top, and wheels.
local function buildVehicle(name: string, origin: Vector3, cells, extras, wheelSpecs): Model
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = gym
	local bodyCFrame = CFrame.new(origin)
	local root: Part? = nil
	for _, cell in cells do
		local part = makeBlock(
			model,
			Vector3.new(CELL, 1, CELL),
			bodyCFrame * CFrame.new(cell[1] * CELL, 0, cell[2] * CELL),
			"Deck",
			Color3.fromRGB(160, 130, 90)
		)
		if root == nil then
			root = part
			part.Name = "Root"
		else
			weld(root, part)
		end
	end
	assert(root)
	for _, extra in extras do
		local part = makeBlock(model, extra.size, bodyCFrame * CFrame.new(extra.offset), extra.name, extra.color)
		weld(root, part)
	end
	model.PrimaryPart = root
	local records = Instance.new("Folder")
	records.Name = "Wheels"
	records.Parent = model
	for index, spec in wheelSpecs do
		addWheel(model, root, records, index, spec, bodyCFrame)
	end
	-- A wheel must not collide with the body that it is on. Found by this gym: a steering wheel of
	-- radius 2 that sat half a stud from the deck's edge hit the deck at 18 degrees, and rubbed on it.
	local bodyParts, wheelParts = {}, {}
	for _, child in model:GetChildren() do
		if child:IsA("BasePart") then
			table.insert(if string.sub(child.Name, 1, 5) == "Wheel" then wheelParts else bodyParts, child)
		end
	end
	for _, wheel in wheelParts do
		for _, bodyPart in bodyParts do
			local noCollision = Instance.new("NoCollisionConstraint")
			noCollision.Part0 = wheel
			noCollision.Part1 = bodyPart
			noCollision.Parent = wheel
		end
	end
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			pcall(function()
				descendant:SetNetworkOwner(nil)
			end)
		end
	end
	return model
end

local deckHeight = GROUND_Y + WHEEL_RADIUS + 0.5 + 0.4

-- Body A: a deck of 3 by 5 cells with a cabin and a cargo block off its middle, two steering wheels
-- ahead and two plain driving wheels behind, none of them at an even place.
local cellsA = { { 0, 0 } }
for x = -1, 1 do
	for z = -2, 2 do
		if not (x == 0 and z == 0) then
			table.insert(cellsA, { x, z })
		end
	end
end
buildVehicle("A", Vector3.new(-40, deckHeight, 200), cellsA, {
	{
		name = "Cabin",
		size = Vector3.new(4, 4, 4),
		offset = Vector3.new(-4, 2.5, -6),
		color = Color3.fromRGB(200, 80, 60),
	},
	{
		name = "Cargo",
		size = Vector3.new(4, 3, 4),
		offset = Vector3.new(4, 2, 6),
		color = Color3.fromRGB(70, 120, 200),
	},
}, {
	{ right = -7.25, forward = 6.1, steers = true, drives = true },
	{ right = 7.25, forward = 5.4, steers = true, drives = true },
	{ right = -7.25, forward = -6.3, steers = false, drives = true },
	{ right = 7.25, forward = -5.8, steers = false, drives = true },
})

-- Body B: an uneven deck with four driving wheels and none that steers, so it turns as a tank does.
buildVehicle("B", Vector3.new(40, deckHeight, 200), { { 0, 0 }, { 1, 0 }, { 0, 1 }, { 0, -1 }, { 1, -1 }, { -1, 0 } }, {
	{
		name = "Tower",
		size = Vector3.new(3, 5, 3),
		offset = Vector3.new(3.5, 3, -3.5),
		color = Color3.fromRGB(120, 180, 90),
	},
}, {
	{ right = -7.3, forward = 2.9, steers = false, drives = true },
	{ right = 7.3, forward = 3.6, steers = false, drives = true },
	{ right = -7.3, forward = -3.4, steers = false, drives = true },
	{ right = 7.3, forward = -2.7, steers = false, drives = true },
})

task.wait(1.5)
local report = {}
for _, name in { "A", "B" } do
	local model = gym:FindFirstChild(name) :: Model
	local root = model.PrimaryPart :: BasePart
	local partCount = 0
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			partCount += 1
		end
	end
	report[name] = {
		parts = partCount,
		massOfBody = root.AssemblyMass,
		heightOfDeckAboveGround = root.Position.Y - GROUND_Y,
		tiltDegrees = math.deg(math.acos(math.clamp(root.CFrame.UpVector.Y, -1, 1))),
		speedAtRest = root.AssemblyLinearVelocity.Magnitude,
	}
end
return report
