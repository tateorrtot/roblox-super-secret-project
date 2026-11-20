--!strict
--- Starts the game on a player's machine. This is the only LocalScript.
---
--- It draws what the server says the player holds, and turns what the player does with the keys
--- and the mouse into requests to the server. It decides nothing about the game by itself.
---
--- Keys: E opens the pack or closes the inventory screen, 1 to 9 select a hotbar slot, and Q drops
--- one of what is in hand, or all of it with the left Ctrl key held. With the inventory screen
--- open, 1 to 9 and Q act on the slot under the pointer instead.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Direction = require(Shared.Direction)
local Inventory = require(Shared.inventory.Inventory)
local InventoryScreen = require(Shared.inventory.InventoryScreen)
local ItemDefinitions = require(Shared.items.ItemDefinitions)
local ItemLooks = require(Shared.items.ItemLooks)
local ItemRegistry = require(Shared.items.ItemRegistry)
local PlayerState = require(Shared.players.PlayerState)
local PlayerSnapshot = require(Shared.world.PlayerSnapshot)
local StationProgress = require(Shared.stations.StationProgress)

local HotbarGui = require(script.Parent.inventory.HotbarGui)
local InventoryControls = require(script.Parent.inventory.InventoryControls)
local InventoryGui = require(script.Parent.inventory.InventoryGui)
local Remotes = require(script.Parent.Remotes)
local SlotGestures = require(script.Parent.inventory.SlotGestures)
local UseAndHit = require(script.Parent.world.UseAndHit)

for _, definition in ItemDefinitions do
	ItemRegistry.register(definition)
end

local remotes = Remotes.waitForAll()
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

--- What the server last said the player holds.
local snapshot: PlayerSnapshot.PlayerSnapshot = {
	pack = Inventory.new(PlayerState.PACK_SLOT_COUNT),
	selectedHotbarSlot = 1,
}
--- How far the world's clock is ahead of this machine's own, in seconds, as of the last snapshot.
local worldClockLead = 0
local gestures = SlotGestures.new()

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

local function placeableInHand(): string?
	local held = Inventory.getStack(snapshot.pack, snapshot.selectedHotbarSlot)
	return if held ~= nil and ItemRegistry.get(held.itemId).placeable then held.itemId else nil
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
		local otherLook = if snapshot.otherInventoryItemId then ItemLooks[snapshot.otherInventoryItemId] else nil
		local otherName = if otherLook then otherLook.name else ""
		InventoryGui.show(
			inventoryGui,
			snapshot.pack,
			screen.otherInventory,
			otherName,
			screen.carriedStack,
			snapshot.stationProgress ~= nil
		)
	end
end)

-- A station's gauges move with time alone, so they are drawn here every frame from the times in
-- the snapshot, and the server sends nothing while a station only burns and works.
RunService.RenderStepped:Connect(function()
	local progress = snapshot.stationProgress
	if progress ~= nil then
		local now = os.clock() + worldClockLead
		InventoryGui.setStationGauges(
			inventoryGui,
			StationProgress.getFuelLeftRatio(progress, now),
			StationProgress.getWorkDoneRatio(progress, now)
		)
	end
end)
remotes.askForSnapshot:FireServer()

-- Roblox's own backpack bar would sit on top of ours, and its tools are not our items.
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

UseAndHit.startListening({
	isBlocked = function()
		return snapshot.screen ~= nil
	end,
	getPlaceableInHand = placeableInHand,
	onPlacedObjectUsed = function(placedObjectId)
		remotes.usePlacedObject:FireServer(placedObjectId)
	end,
	onTileUsed = function(x, z)
		remotes.placeSelectedItem:FireServer(x, z)
	end,
	onPlacedObjectHit = function(placedObjectId)
		remotes.hitPlacedObject:FireServer(placedObjectId)
	end,
})

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
