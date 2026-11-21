--!strict
--- Starts the game on a player's machine. This is the only LocalScript.
---
--- It draws what the server says the player holds, and turns what the player does with the keys
--- and the mouse into requests to the server. It decides nothing about the game by itself.
---
--- The world: the player interacts with what the pointer is over, and breaks it. Those two are
--- Roblox's input actions `Interact` and `Break`, under ReplicatedStorage.Inputs.World, and which
--- button each is bound to is written there and not here. A tap on a touch screen interacts. Where
--- the pointer is comes from UserInputService.
---
--- Keys: E opens the pack or closes the inventory screen, 1 to 9 select a hotbar slot, and Q drops
--- one of what is in hand, or all of it with the left Ctrl key held. With the inventory screen
--- open, 1 to 9 and Q act on the slot under the pointer instead.
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Content = require(Shared.content.Content)
local CrateItem = require(Shared.content.CrateItem)
local Direction = require(Shared.Direction)
local Inventory = require(Shared.inventory.Inventory)
local InventoryScreen = require(Shared.inventory.InventoryScreen)
local PlacedObjectKinds = require(Shared.content.PlacedObjectKinds)
local PlayerState = require(Shared.players.PlayerState)
local PlayerSnapshot = require(Shared.requests.PlayerSnapshot)
local Stove = require(Shared.content.Stove)
local StoveItem = require(Shared.content.StoveItem)

local BreakClick = require(script.Parent.world.BreakClick)
local CrateItemGhost = require(script.Parent.content.CrateItemGhost)
local HotbarGui = require(script.Parent.inventory.HotbarGui)
local InventoryControls = require(script.Parent.inventory.InventoryControls)
local InventoryGui = require(script.Parent.inventory.InventoryGui)
local LocalCharacter = require(script.Parent.world.LocalCharacter)
local PlotPointer = require(script.Parent.world.PlotPointer)
local Remotes = require(script.Parent.Remotes)
local SlotGestures = require(script.Parent.inventory.SlotGestures)
local StoveItemGhost = require(script.Parent.content.StoveItemGhost)
local StoveScreen = require(script.Parent.content.StoveScreen)

Content.register()

--- What an item shows in the world while it is in the selected hotbar slot.
type SelectedItemPiece = {
	--- Called every frame while the item is in the selected hotbar slot, with what the pointer is
	--- over, or `nil` if it is over nothing.
	update: (pointerTarget: PlotPointer.Target?) -> (),
	--- Called once when the item is in the selected hotbar slot no longer.
	hide: () -> (),
}

--- The piece of each item that shows something while it is selected, by the item's id.
local selectedItemPieces: { [string]: SelectedItemPiece } = {
	[CrateItem.id] = CrateItemGhost,
	[StoveItem.id] = StoveItemGhost,
}

--- How the screen of one kind of placed object is laid out, and what moves on it.
type PlacedObjectScreenPiece = InventoryGui.OtherLayout & {
	--- Called every frame while the screen of a placed object of the kind is open, with what the
	--- kind's script told this machine of that placed object, and the time on the world's clock.
	update: (screenData: unknown, now: number) -> (),
}

--- The piece of each kind of placed object whose screen is more than rows of slots, by the kind's
--- id.
local placedObjectScreenPieces: { [string]: PlacedObjectScreenPiece } = {
	[Stove.PLACED_OBJECT_KIND_ID] = StoveScreen,
}

local remotes = Remotes.waitForAll()
local worldInputs = ReplicatedStorage:WaitForChild("Inputs"):WaitForChild("World")
local interactAction = worldInputs:WaitForChild("Interact") :: InputAction
local breakAction = worldInputs:WaitForChild("Break") :: InputAction
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

--- What the server last said the player holds.
local snapshot: PlayerSnapshot.PlayerSnapshot = {
	pack = Inventory.new(PlayerState.PACK_SLOT_COUNT),
	selectedHotbarSlot = 1,
}
--- How far the world's clock is ahead of this machine's own, in seconds, as of the last snapshot.
local worldClockLead = 0
local gestures = SlotGestures.new()
--- The piece of `selectedItemPieces` that was last updated. `nil` while the item in the selected
--- hotbar slot has none.
local shownSelectedItemPiece: SelectedItemPiece? = nil

local hotbarGui: HotbarGui.HotbarGui
local inventoryGui: InventoryGui.InventoryGui

local digitKeys: { [Enum.KeyCode]: number } = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
}

local mouseButtons: { [Enum.UserInputType]: SlotGestures.Button } = {
	[Enum.UserInputType.MouseButton1] = "left",
	[Enum.UserInputType.MouseButton2] = "right",
	[Enum.UserInputType.Touch] = "left",
}

--- The camera is in first person when it is nearer than this to the point it turns about, in
--- studs.
--- Note: no property of the camera says that it is in first person. Roblox's own camera scripts
--- go into first person below this distance, and then hold the camera half a stud from that point.
local CAMERA_IN_FIRST_PERSON_WITHIN = 1

local function isCameraInFirstPerson(camera: Camera): boolean
	return (camera.Focus.Position - camera.CFrame.Position).Magnitude < CAMERA_IN_FIRST_PERSON_WITHIN
end

--- The way a stack the player drops is thrown. In first person it is the way the camera looks, up
--- and down as well. Otherwise it is the way the camera looks along the ground, or the way the
--- player's character faces if the camera looks straight up or straight down. `nil` if it cannot
--- be told.
local function getThrowDirection(): Direction.Direction?
	local camera = Workspace.CurrentCamera
	local look = if camera then camera.CFrame.LookVector else Vector3.zero
	if camera ~= nil and isCameraInFirstPerson(camera) then
		return Direction.new(look.X, look.Y, look.Z)
	end
	local character = Players.LocalPlayer.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	local facing = if root and root:IsA("BasePart") then root.CFrame.LookVector else Vector3.zero
	return Direction.new(look.X, 0, look.Z) or Direction.new(facing.X, 0, facing.Z)
end

local function send(request: InventoryControls.Request?)
	if request ~= nil then
		remotes[request.name]:FireServer(table.unpack(request.arguments))
	end
end

local function selectSlot(slot: number)
	remotes.selectHotbarSlot:FireServer(slot)
end

local function toggleScreen()
	local name = if snapshot.screen then "closeScreen" else "openPack"
	remotes[name]:FireServer()
end

local function isShiftHeld(): boolean
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
end

local function controlsScreen(screen: InventoryScreen.InventoryScreen): InventoryControls.Screen
	local other = screen.otherInventory
	return {
		packSlotCount = screen.pack.slotCount,
		hotbarSlotCount = PlayerState.HOTBAR_SLOT_COUNT,
		otherSlotCount = if other then other.slotCount else nil,
		carriedStack = screen.carriedStack,
		getStack = function(slot)
			return Inventory.getStack(InventoryScreen.getInventoryOnSide(screen, slot.side :: any), slot.slot)
		end,
	}
end

local function updateSelectedItemPiece(pointerTarget: PlotPointer.Target?)
	local selected = Inventory.getStack(snapshot.pack, snapshot.selectedHotbarSlot)
	local piece = if selected ~= nil then selectedItemPieces[selected.itemId] else nil
	if shownSelectedItemPiece ~= nil and shownSelectedItemPiece ~= piece then
		shownSelectedItemPiece.hide()
	end
	shownSelectedItemPiece = piece
	if piece ~= nil then
		piece.update(pointerTarget)
	end
end

hotbarGui = HotbarGui.new(playerGui, PlayerState.HOTBAR_SLOT_COUNT, {
	onSlotChosen = selectSlot,
	onPackClicked = toggleScreen,
})

inventoryGui = InventoryGui.new(playerGui, PlayerState.HOTBAR_SLOT_COUNT, {
	onSlotPressed = function(side, slot, button)
		SlotGestures.beginGesture(gestures, button, { side = side, slot = slot })
	end,
	onSlotEntered = function(side, slot)
		SlotGestures.dragOverSlot(gestures, { side = side, slot = slot })
		InventoryGui.setHighlightedSlots(inventoryGui, SlotGestures.getDraggedSlots(gestures))
	end,
	onOutsideClicked = function(button)
		local direction = getThrowDirection()
		if direction ~= nil then
			send(InventoryControls.getRequestForOutsideClick(button, direction))
		end
	end,
	onCloseClicked = function()
		remotes.closeScreen:FireServer()
	end,
})

local function onScreenOpenedOrClosed(open: boolean)
	HotbarGui.setVisible(hotbarGui, not open)
	-- Note: Roblox's chat window lies over the top left of the screen and takes the clicks there
	-- even when it has faded from sight, so it is put away while the inventory screen is open.
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not open)
	if not open then
		InventoryGui.hide(inventoryGui)
		SlotGestures.reset(gestures)
	end
end

remotes.snapshotChanged.OnClientEvent:Connect(function(encoded: PlayerSnapshot.EncodedSnapshot, sentAt: number)
	local wasOpen = snapshot.screen ~= nil
	snapshot = PlayerSnapshot.decode(encoded)
	worldClockLead = sentAt - os.clock()
	local screen = snapshot.screen
	HotbarGui.update(hotbarGui, snapshot.pack, snapshot.selectedHotbarSlot)
	if (screen ~= nil) ~= wasOpen then
		onScreenOpenedOrClosed(screen ~= nil)
	end
	if screen ~= nil then
		local kindId = snapshot.placedObjectKindId
		local otherName = if kindId ~= nil then PlacedObjectKinds.get(kindId).NAME else ""
		InventoryGui.show(
			inventoryGui,
			snapshot.pack,
			screen.otherInventory,
			otherName,
			screen.carriedStack,
			if kindId ~= nil then placedObjectScreenPieces[kindId] else nil
		)
	end
end)

-- What moves on a screen with time alone, such as a stove's gauges, is drawn here every frame by
-- the kind's own piece, from what the kind's script put in the snapshot. The server sends nothing
-- while time only passes.
RunService.RenderStepped:Connect(function()
	local kindId = snapshot.placedObjectKindId
	local piece = if kindId ~= nil then placedObjectScreenPieces[kindId] else nil
	if piece ~= nil then
		piece.update(snapshot.screenData, os.clock() + worldClockLead)
	end
end)
remotes.askForSnapshot:FireServer()

-- Roblox's own backpack bar would sit on top of ours, and its tools are not our items.
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

--- A white outline around the placed object that the pointer is over, while the player's
--- character reaches it. It is Roblox's own SelectionBox, and its `Adornee` is the part it is
--- around.
local pointerOutline = Instance.new("SelectionBox")
pointerOutline.Name = "PointerOutline"
pointerOutline.LineThickness = 0.05
pointerOutline.Color3 = Color3.new(1, 1, 1)
pointerOutline.Parent = Workspace

--- What the point `viewportPoint` of the screen is over in the world. `nil` while the inventory
--- screen is open: the pointer is then over the screen.
local function getWorldTargetAt(viewportPoint: Vector2): PlotPointer.Target?
	return if snapshot.screen == nil then PlotPointer.getTargetAt(viewportPoint) else nil
end

local function interactAt(viewportPoint: Vector2)
	local target = getWorldTargetAt(viewportPoint)
	if target ~= nil and target.kind == "placedObject" then
		remotes.interactWithPlacedObject:FireServer(target.placedObjectId)
	elseif target ~= nil and target.kind == "tile" then
		remotes.interactWithTile:FireServer(target.x, target.z)
	end
end

local function breakAt(viewportPoint: Vector2)
	local target = getWorldTargetAt(viewportPoint)
	if target ~= nil and target.kind == "placedObject" then
		remotes.breakPlacedObject:FireServer(target.placedObjectId)
	end
end

interactAction.Pressed:Connect(function()
	interactAt(UserInputService:GetMouseLocation())
end)

BreakClick.connect(breakAction, function()
	breakAt(UserInputService:GetMouseLocation())
end)

-- Note: Roblox's input actions have no tap, so a tap is still read from UserInputService. A tap's
-- place is measured from under the strip along the top of the screen, and PlotPointer measures from
-- the top of the window, so the strip's height is added back.
UserInputService.TouchTapInWorld:Connect(function(position: Vector2, handledElsewhere: boolean)
	if not handledElsewhere then
		interactAt(position + GuiService:GetGuiInset())
	end
end)

-- A machine with no mouse has no pointer to mark the place of.
RunService.RenderStepped:Connect(function()
	local hasPointer = UserInputService.MouseEnabled
	local target = if hasPointer then getWorldTargetAt(UserInputService:GetMouseLocation()) else nil
	local reached = if target ~= nil and LocalCharacter.canReachPoint(target.center) then target else nil
	pointerOutline.Adornee = if reached ~= nil and reached.kind == "placedObject" then reached.model else nil
	updateSelectedItemPiece(target)
end)

local function onDropKey()
	local over = inventoryGui.hoveredSlot
	local wholeStack = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
	local direction = getThrowDirection()
	if direction == nil then
		return
	end
	if snapshot.screen == nil then
		remotes.dropFromSelectedSlot:FireServer(direction, if wholeStack then nil else 1)
	elseif over ~= nil then
		send(InventoryControls.getRequestForDropKeyOverSlot(over, direction, wholeStack))
	end
end

local function onDigitKey(digit: number)
	local over = inventoryGui.hoveredSlot
	if snapshot.screen == nil then
		selectSlot(digit)
	elseif over ~= nil then
		send(InventoryControls.getRequestForDigitKeyOverSlot(over, digit))
	end
end

UserInputService.InputBegan:Connect(function(input: InputObject, handledElsewhere: boolean)
	local digit = digitKeys[input.KeyCode]
	if handledElsewhere then
		return
	elseif input.KeyCode == Enum.KeyCode.E then
		toggleScreen()
	elseif input.KeyCode == Enum.KeyCode.Q then
		onDropKey()
	elseif digit ~= nil and digit <= PlayerState.HOTBAR_SLOT_COUNT then
		onDigitKey(digit)
	end
end)

UserInputService.InputEnded:Connect(function(input: InputObject)
	local button = mouseButtons[input.UserInputType]
	local screen = snapshot.screen
	if button == nil or screen == nil then
		return
	end
	local gesture = SlotGestures.endGesture(gestures, button, inventoryGui.hoveredSlot, isShiftHeld(), os.clock())
	InventoryGui.setHighlightedSlots(inventoryGui, {})
	if gesture ~= nil then
		send(InventoryControls.getRequestForGesture(controlsScreen(screen), gesture))
	end
end)
