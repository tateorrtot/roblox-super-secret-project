--!strict
--- The two actions a player takes on the world: Use and Hit.
---
--- Use is a left click, or a tap on a touch screen. Hit is a short right click: holding the right
--- button turns the camera, so only a quick press that did not turn it is a Hit. Hit has no touch
--- control yet. Both act on the placed item or the bare tile under the pointer, if the player's
--- character stands within `World.REACH` of it. With a mouse, the thing under the pointer is
--- marked while it is in reach: a placed item gets a white outline, and a bare tile gets a faint
--- block if the item in hand can be placed.
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local World = require(ReplicatedStorage:WaitForChild("Shared").world.World)
local PlacementGhost = require(script.Parent.PlacementGhost)
local PlotPointer = require(script.Parent.PlotPointer)

local UseAndHit = {}

export type Callbacks = {
	--- Returns `true` while the world takes no clicks, as when a screen is open over it.
	isBlocked: () -> boolean,
	--- Returns the id of the item in the player's hand if it can be placed, or `nil`.
	getPlaceableInHand: () -> string?,
	--- Called with a placed item's id when the player uses it.
	onPlacedUsed: (placedId: number) -> (),
	--- Called with a tile when the player uses it while an item that can be placed is in hand.
	onTileUsed: (x: number, z: number) -> (),
	--- Called with a placed item's id when the player hits it.
	onPlacedHit: (placedId: number) -> (),
}

--- A right click is a Hit only if the button comes up within this many seconds.
local HIT_WITHIN_SECONDS = 0.35

--- The camera has turned during a right click if the dot product of the directions it faced
--- when the button went down and when it came up is below this.
local SAME_DIRECTION = 0.9995

local function pointedInReach(viewportPoint: Vector2): PlotPointer.Pointed?
	local pointed = PlotPointer.at(viewportPoint)
	local character = Players.LocalPlayer.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if pointed == nil or root == nil or not root:IsA("BasePart") then
		return nil
	end
	local away = pointed.center - root.Position
	return if Vector3.new(away.X, 0, away.Z).Magnitude <= World.REACH then pointed else nil
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
--- through `callbacks`, and nothing is reported or marked while `callbacks.isBlocked` returns `true`.
function UseAndHit.start(callbacks: Callbacks)
	local ghost = PlacementGhost.new()
	local outline = makeOutline()
	local rightPressedAt: number? = nil
	local lookWhenPressed = Vector3.zero

	local function pointedAt(viewportPoint: Vector2): PlotPointer.Pointed?
		return if callbacks.isBlocked() then nil else pointedInReach(viewportPoint)
	end

	local function use(pointed: PlotPointer.Pointed?)
		if pointed ~= nil and pointed.kind == "placedItem" then
			callbacks.onPlacedUsed(pointed.id)
		elseif pointed ~= nil and pointed.kind == "tile" and callbacks.getPlaceableInHand() ~= nil then
			callbacks.onTileUsed(pointed.x, pointed.z)
		end
	end

	local function hit(pointed: PlotPointer.Pointed?)
		if pointed ~= nil and pointed.kind == "placedItem" then
			callbacks.onPlacedHit(pointed.id)
		end
	end

	RunService.RenderStepped:Connect(function()
		local pointed = if UserInputService.MouseEnabled then pointedAt(UserInputService:GetMouseLocation()) else nil
		local itemId = callbacks.getPlaceableInHand()
		if pointed ~= nil and pointed.kind == "tile" and itemId ~= nil then
			PlacementGhost.show(ghost, itemId, pointed.center)
		else
			PlacementGhost.hide(ghost)
		end
		outline.Adornee = if pointed ~= nil and pointed.kind == "placedItem" then pointed.part else nil
	end)

	UserInputService.InputBegan:Connect(function(input: InputObject, handledElsewhere: boolean)
		if handledElsewhere then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			use(pointedAt(UserInputService:GetMouseLocation()))
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
			hit(pointedAt(UserInputService:GetMouseLocation()))
		end
	end)

	-- Note: a tap's place is measured from under the strip along the top of the screen, and
	-- PlotPointer measures from the top of the window, so the strip's height is added back.
	UserInputService.TouchTapInWorld:Connect(function(position: Vector2, handledElsewhere: boolean)
		if not handledElsewhere then
			use(pointedAt(position + GuiService:GetGuiInset()))
		end
	end)
end

return UseAndHit
