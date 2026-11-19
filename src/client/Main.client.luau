--!strict
--[=[
	Starts the game on a player's machine and runs it. This is the only
	LocalScript.

	It registers every item, finds the remotes, and makes the hotbar and the
	inventory screen. After that it does two things:
	- When the server says what the player's inventories hold, it draws them.
	  The screen is open exactly when the server says it is.
	- When the player presses a key or clicks a slot, it asks the server for
	  what that means, using the messages listed in Messages. It changes no
	  inventory itself.

	Keys: E opens and closes the pack, 1 to 9 pick a hotbar slot, and Q drops
	one of what is in hand.
]=]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Inventory = require(Shared.inventory.Inventory)
local ItemDefinitions = require(Shared.items.ItemDefinitions)
local ItemLooks = require(Shared.items.ItemLooks)
local ItemRegistry = require(Shared.items.ItemRegistry)
local ItemStack = require(Shared.items.ItemStack)
local PlayerState = require(Shared.players.PlayerState)

local inventoryFolder = script.Parent:WaitForChild("inventory")
local HotbarGui = require(inventoryFolder:WaitForChild("HotbarGui"))
local InventoryGui = require(inventoryFolder:WaitForChild("InventoryGui"))
local Remotes = require(script.Parent:WaitForChild("Remotes"))

for _, definition in ItemDefinitions do
	ItemRegistry.register(definition)
end

local remotes = Remotes.find()
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Roblox's own backpack bar would sit on top of ours, and its tools are not our items.
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

--- What the server last said the pack holds.
local pack = Inventory.new(PlayerState.PACK_SLOTS)
--- Whether the server last said an inventory screen is open.
local screenOpen = false
--- The hotbar slot in hand. The player chooses it here, and the server is told.
local selectedSlot = 1

local hotbarGui: HotbarGui.HotbarGui

local function selectSlot(slot: number)
	selectedSlot = slot
	remotes.selectHotbarSlot:FireServer(slot)
	HotbarGui.show(hotbarGui, pack, selectedSlot)
end

local function togglePack()
	if screenOpen then
		remotes.closeInventory:FireServer()
	else
		remotes.openPack:FireServer()
	end
end

hotbarGui = HotbarGui.new(playerGui, PlayerState.HOTBAR_SLOTS, {
	onSlotChosen = selectSlot,
	onPackClicked = togglePack,
})

local inventoryGui = InventoryGui.new(playerGui, PlayerState.HOTBAR_SLOTS, {
	onSlotClicked = function(side, slot, button, shiftHeld)
		if shiftHeld and button == "left" then
			remotes.quickMoveSlot:FireServer(side, slot)
		else
			remotes.clickSlot:FireServer(side, slot, button)
		end
	end,
	onOutsideClicked = function(button)
		-- As in Minecraft: a left click outside drops everything carried, and a right click drops one.
		remotes.dropCarried:FireServer(if button == "right" then 1 else nil)
	end,
	onCloseClicked = function()
		remotes.closeInventory:FireServer()
	end,
})

-- Returns the inventory that the server sent as plain data. The server is trusted, so bad data is an error.
local function decode(encoded: unknown): Inventory.Inventory
	local inventory, problem = Inventory.decode(encoded)
	if inventory == nil then
		error("the server sent an inventory that cannot be read: " .. tostring(problem))
	end
	return inventory
end

-- Opens or closes the inventory screen on this machine, to match what the server said.
local function setScreenOpen(open: boolean)
	if open == screenOpen then
		return
	end
	screenOpen = open
	-- The screen draws the hotbar slots itself, so the bar at the bottom is put away while it is open.
	HotbarGui.setVisible(hotbarGui, not open)
	-- Roblox's chat window lies over the top left of the screen and takes the clicks there, even when it
	-- has faded from sight. It is put away while the inventory screen is open, so every slot can be clicked.
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not open)
	if not open then
		InventoryGui.hide(inventoryGui)
	end
end

type ScreenMessage = { other: unknown, otherItemId: string?, carried: { itemId: string, count: number }? }

remotes.inventoryChanged.OnClientEvent:Connect(function(encodedPack: unknown, screen: ScreenMessage?)
	pack = decode(encodedPack)
	HotbarGui.show(hotbarGui, pack, selectedSlot)
	setScreenOpen(screen ~= nil)
	if screen ~= nil then
		local other = if screen.other ~= nil then decode(screen.other) else nil
		local otherLook = if screen.otherItemId ~= nil then ItemLooks[screen.otherItemId] else nil
		local carried = if screen.carried ~= nil
			then ItemStack.new(screen.carried.itemId, screen.carried.count)
			else nil
		InventoryGui.show(inventoryGui, pack, other, if otherLook ~= nil then otherLook.name else "", carried)
	end
end)
remotes.askForInventory:FireServer()

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

UserInputService.InputBegan:Connect(function(input: InputObject, typingElsewhere: boolean)
	if typingElsewhere then
		return
	end
	local digit = digitKeys[input.KeyCode]
	if input.KeyCode == Enum.KeyCode.E then
		togglePack()
	elseif input.KeyCode == Enum.KeyCode.Q then
		if not screenOpen then
			remotes.dropSelected:FireServer()
		end
	elseif digit ~= nil and digit <= PlayerState.HOTBAR_SLOTS then
		selectSlot(digit)
	end
end)
