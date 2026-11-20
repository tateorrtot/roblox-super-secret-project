--!strict
--- The two actions a player takes on the world: Use and Hit.
---
--- Use is a left click, or a tap on a touch screen. Hit is a short right click: holding the right
--- button turns the camera, so only a quick press that did not turn it is a Hit. Hit has no touch
--- control yet. Both act on the placed object or the bare tile under the pointer, if the player's
--- character stands within `World.CHARACTER_REACH` of it. With a mouse, a placed object under the
--- pointer gets a white outline while it is in reach.
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local World = require(ReplicatedStorage:WaitForChild("Shared").world.World)
local PlotPointer = require(script.Parent.PlotPointer)

local UseAndHit = {}

export type Callbacks = {
	--- Returns `true` while the world takes no clicks, as when a screen is open over it.
	isBlocked: () -> boolean,
	--- Called every frame with what the mouse is over, if the player's character reaches it.
	--- Called with `nil` if it is over nothing in reach, while the world takes no clicks, and
	--- on a machine with no mouse.
	onPointerMoved: (target: PlotPointer.Target?) -> (),
	--- Called with a placed object's id when the player uses it.
	onPlacedObjectUsed: (placedObjectId: number) -> (),
	--- Called with a tile when the player uses it.
	onTileUsed: (x: number, z: number) -> (),
	--- Called with a placed object's id when the player hits it.
	onPlacedObjectHit: (placedObjectId: number) -> (),
}

--- A right click is a Hit only if the button comes up within this many seconds.
local HIT_WITHIN_SECONDS = 0.35

--- The camera has turned during a right click if the dot product of the directions it faced
--- when the button went down and when it came up is below this.
local SAME_DIRECTION = 0.9995

local function targetInReach(viewportPoint: Vector2): PlotPointer.Target?
	local target = PlotPointer.getTargetAt(viewportPoint)
	local character = Players.LocalPlayer.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if target == nil or root == nil or not root:IsA("BasePart") then
		return nil
	end
	local away = target.center - root.Position
	return if Vector3.new(away.X, 0, away.Z).Magnitude <= World.CHARACTER_REACH then target else nil
end

local function makeOutline(): SelectionBox
	local outline = Instance.new("SelectionBox")
	outline.Name = "PointerOutline"
	outline.LineThickness = 0.05
	outline.Color3 = Color3.new(1, 1, 1)
	outline.Parent = Workspace
	return outline
end

local function lookDirection(): Vector3
	local camera = Workspace.CurrentCamera
	return if camera then camera.CFrame.LookVector else Vector3.zero
end

--- Starts listening for Use and Hit and marking what the mouse is over. Each action is reported
--- through `callbacks`, and nothing is reported or marked while `callbacks.isBlocked` returns
--- `true`.
function UseAndHit.startListening(callbacks: Callbacks)
	local outline = makeOutline()
	local rightPressedAt: number? = nil
	local lookWhenPressed = Vector3.zero

	local function targetAt(viewportPoint: Vector2): PlotPointer.Target?
		return if callbacks.isBlocked() then nil else targetInReach(viewportPoint)
	end

	local function use(target: PlotPointer.Target?)
		if target ~= nil and target.kind == "placedObject" then
			callbacks.onPlacedObjectUsed(target.placedObjectId)
		elseif target ~= nil and target.kind == "tile" then
			callbacks.onTileUsed(target.x, target.z)
		end
	end

	local function hit(target: PlotPointer.Target?)
		if target ~= nil and target.kind == "placedObject" then
			callbacks.onPlacedObjectHit(target.placedObjectId)
		end
	end

	RunService.RenderStepped:Connect(function()
		local target = if UserInputService.MouseEnabled then targetAt(UserInputService:GetMouseLocation()) else nil
		callbacks.onPointerMoved(target)
		outline.Adornee = if target ~= nil and target.kind == "placedObject" then target.part else nil
	end)

	UserInputService.InputBegan:Connect(function(input: InputObject, handledElsewhere: boolean)
		if handledElsewhere then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			use(targetAt(UserInputService:GetMouseLocation()))
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			rightPressedAt = os.clock()
			lookWhenPressed = lookDirection()
		end
	end)

	UserInputService.InputEnded:Connect(function(input: InputObject)
		local pressedAt = rightPressedAt
		if input.UserInputType ~= Enum.UserInputType.MouseButton2 or pressedAt == nil then
			return
		end
		rightPressedAt = nil
		local turned = lookDirection():Dot(lookWhenPressed) < SAME_DIRECTION
		if os.clock() - pressedAt < HIT_WITHIN_SECONDS and not turned then
			hit(targetAt(UserInputService:GetMouseLocation()))
		end
	end)

	-- Note: a tap's place is measured from under the strip along the top of the screen, and
	-- PlotPointer measures from the top of the window, so the strip's height is added back.
	UserInputService.TouchTapInWorld:Connect(function(position: Vector2, handledElsewhere: boolean)
		if not handledElsewhere then
			use(targetAt(position + GuiService:GetGuiInset()))
		end
	end)
end

return UseAndHit
