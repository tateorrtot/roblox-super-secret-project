--!strict
--- Starts the game on a player's machine. This is the only LocalScript.
---
--- It draws what the server says the player holds, and turns what the player does with the keys
--- and the mouse into requests to the server. The only thing it decides by itself is which hotbar
--- slot is selected, and it tells the server that too.
---
--- Keys: E opens the pack or closes the inventory screen, 1 to 9 select a hotbar slot, and Q drops
--- one of what is in hand, or all of it with the left Ctrl key held. With the inventory screen
--- open, 1 to 9 and Q act on the slot under the pointer instead.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Inventory = require(Shared.inventory.Inventory)
local InventoryScreen = require(Shared.inventory.InventoryScreen)
local ItemDefinitions = require(Shared.items.ItemDefinitions)
local ItemLooks = require(Shared.items.ItemLooks)
local ItemRegistry = require(Shared.items.ItemRegistry)
local PlayerState = require(Shared.players.PlayerState)
local PlayerSnapshot = require(Shared.world.PlayerSnapshot)

local HotbarGui = require(script.Parent.inventory.HotbarGui)
local InventoryControls = require(script.Parent.inventory.InventoryControls)
local InventoryGui = require(script.Parent.inventory.InventoryGui)
local Remotes = require(script.Parent.Remotes)
local SlotGestures = require(script.Parent.inventory.SlotGestures)
local UseAndHit = require(script.Parent.world.UseAndHit)

for _, definition in ItemDefinitions do
	ItemRegistry.register(definition)
end

local remotes = Remotes.find()
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

--- What the server last said the player holds.
local snapshot: PlayerSnapshot.PlayerSnapshot = { pack = Inventory.new(PlayerState.PACK_SLOTS) }
--- The hotbar slot in the player's hand.
local selectedSlot = 1
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

local function send(request: InventoryControls.Request?)
	if request ~= nil then
		remotes[request.name]:FireServer(table.unpack(request.arguments))
	end
end

local function selectSlot(slot: number)
	selectedSlot = slot
	remotes.selectHotbarSlot:FireServer(slot)
	HotbarGui.show(hotbarGui, snapshot.pack, selectedSlot)
end

local function toggleScreen()
	local name = if snapshot.screen then "closeScreen" else "openPack"
	remotes[name]:FireServer()
end

local function isShiftHeld(): boolean
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
end

local function controlsScreen(screen: InventoryScreen.InventoryScreen): InventoryControls.Screen
	local other = screen.other
	return {
		packSlots = screen.pack.slotCount,
		hotbarSlots = PlayerState.HOTBAR_SLOTS,
		otherSlots = if other then other.slotCount else nil,
		carried = screen.carried,
		getStack = function(slot)
			return Inventory.getStack(InventoryScreen.getInventory(screen, slot.side :: any), slot.slot)
		end,
	}
end

local function placeableInHand(): string?
	local held = Inventory.getStack(snapshot.pack, selectedSlot)
	return if held ~= nil and ItemRegistry.get(held.itemId).placeable then held.itemId else nil
end

hotbarGui = HotbarGui.new(playerGui, PlayerState.HOTBAR_SLOTS, {
	onSlotChosen = selectSlot,
	onPackClicked = toggleScreen,
})

inventoryGui = InventoryGui.new(playerGui, PlayerState.HOTBAR_SLOTS, {
	onSlotPressed = function(side, slot, button)
		SlotGestures.press(gestures, button, { side = side, slot = slot })
	end,
	onSlotEntered = function(side, slot)
		SlotGestures.enter(gestures, { side = side, slot = slot })
		InventoryGui.markSlots(inventoryGui, SlotGestures.getDraggedSlots(gestures))
	end,
	onOutsideClicked = function(button)
		send(InventoryControls.requestForOutsideClick(button))
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

remotes.snapshotChanged.OnClientEvent:Connect(function(encoded: PlayerSnapshot.EncodedSnapshot)
	local wasOpen = snapshot.screen ~= nil
	snapshot = PlayerSnapshot.decode(encoded)
	local screen = snapshot.screen
	HotbarGui.show(hotbarGui, snapshot.pack, selectedSlot)
	if (screen ~= nil) ~= wasOpen then
		onScreenOpenedOrClosed(screen ~= nil)
	end
	if screen ~= nil then
		local otherLook = if snapshot.otherItemId then ItemLooks[snapshot.otherItemId] else nil
		local otherName = if otherLook then otherLook.name else ""
		InventoryGui.show(inventoryGui, snapshot.pack, screen.other, otherName, screen.carried, snapshot.progress)
	end
end)
remotes.askForSnapshot:FireServer()

-- Roblox's own backpack bar would sit on top of ours, and its tools are not our items.
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

UseAndHit.start({
	isBlocked = function()
		return snapshot.screen ~= nil
	end,
	getPlaceableInHand = placeableInHand,
	onPlacedUsed = function(placedId)
		remotes.usePlaced:FireServer(placedId)
	end,
	onTileUsed = function(x, z)
		remotes.placeSelected:FireServer(x, z)
	end,
	onPlacedHit = function(placedId)
		remotes.hitPlaced:FireServer(placedId)
	end,
})

local function onDropKey()
	local over = inventoryGui.hovered
	local wholeStack = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
	if snapshot.screen == nil then
		remotes.dropSelected:FireServer(if wholeStack then nil else 1)
	elseif over ~= nil then
		send(InventoryControls.requestForDropKey(over, wholeStack))
	end
end

local function onDigitKey(digit: number)
	local over = inventoryGui.hovered
	if snapshot.screen == nil then
		selectSlot(digit)
	elseif over ~= nil then
		send(InventoryControls.requestForDigitKey(over, digit))
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
	elseif digit ~= nil and digit <= PlayerState.HOTBAR_SLOTS then
		onDigitKey(digit)
	end
end)

UserInputService.InputEnded:Connect(function(input: InputObject)
	local button = mouseButtons[input.UserInputType]
	local screen = snapshot.screen
	if button == nil or screen == nil then
		return
	end
	local gesture = SlotGestures.release(gestures, button, inventoryGui.hovered, isShiftHeld(), os.clock())
	InventoryGui.markSlots(inventoryGui, {})
	if gesture ~= nil then
		send(InventoryControls.requestForGesture(controlsScreen(screen), gesture))
	end
end)
