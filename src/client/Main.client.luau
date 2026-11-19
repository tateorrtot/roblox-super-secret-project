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
	one of what is in hand. With the inventory screen open, 1 to 9 and Q act
	on the slot under the pointer instead, and a stack carried across slots
	with a mouse button held is spread over them when the button comes up.

	In the world there are two actions, Use and Hit. Use is a left click or a
	tap: on a placed item it opens it, and on a bare tile of the plot it
	places the item in hand, if that item can be placed. Hit is a short right
	click: on a placed item it knocks it off the plot, to lie on the ground as
	an item. Hit has no touch control yet. Both reach `Plot.REACH` studs from
	the player's character, and with a mouse the thing in reach under the
	pointer is marked: a faint block on a tile, a white outline on a placed item.
]=]
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Inventory = require(Shared.inventory.Inventory)
local ItemDefinitions = require(Shared.items.ItemDefinitions)
local ItemLooks = require(Shared.items.ItemLooks)
local ItemRegistry = require(Shared.items.ItemRegistry)
local ItemStack = require(Shared.items.ItemStack)
local PlayerState = require(Shared.players.PlayerState)
local SlotMouse = require(Shared.inventory.SlotMouse)
local Plot = require(Shared.plots.Plot)
local RecipeDefinitions = require(Shared.stations.RecipeDefinitions)
local RecipeRegistry = require(Shared.stations.RecipeRegistry)

local inventoryFolder = script.Parent:WaitForChild("inventory")
local HotbarGui = require(inventoryFolder:WaitForChild("HotbarGui"))
local InventoryGui = require(inventoryFolder:WaitForChild("InventoryGui"))
local Remotes = require(script.Parent:WaitForChild("Remotes"))
local worldFolder = script.Parent:WaitForChild("world")
local PlacementGhost = require(worldFolder:WaitForChild("PlacementGhost"))
local PlotPointer = require(worldFolder:WaitForChild("PlotPointer"))

for _, definition in ItemDefinitions do
	ItemRegistry.register(definition)
end
for _, recipe in RecipeDefinitions do
	RecipeRegistry.register(recipe)
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

--- Whether the server last said a stack is being carried on the inventory screen.
local carrying = false

--- What the mouse has lately done on the slots of the inventory screen: it tells clicks, double
--- clicks, Shift and clicks, and drags across slots apart.
local slotMouse = SlotMouse.new()

local hotbarGui: HotbarGui.HotbarGui
local inventoryGui: InventoryGui.InventoryGui

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

inventoryGui = InventoryGui.new(playerGui, PlayerState.HOTBAR_SLOTS, {
	onSlotClicked = function(side, slot, button, shiftHeld)
		local request = SlotMouse.click(slotMouse, side, slot, button, shiftHeld, os.clock())
		if request == "clickSlot" then
			remotes.clickSlot:FireServer(side, slot, button)
		elseif request ~= nil then
			remotes[request]:FireServer(side, slot)
		end
	end,
	onSlotPressed = function(side, slot, button)
		SlotMouse.press(slotMouse, side, slot, button, carrying)
	end,
	onSlotDraggedOver = function(side, slot)
		-- As in Minecraft: a stack carried across slots with a button held is spread over them when
		-- the button comes up. Until then the slots are marked.
		SlotMouse.enter(slotMouse, side, slot)
		InventoryGui.markSlots(inventoryGui, SlotMouse.getDraggedSlots(slotMouse))
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
		SlotMouse.forget(slotMouse)
	end
end

type ScreenMessage = {
	other: unknown,
	otherItemId: string?,
	carried: { itemId: string, count: number }?,
	station: { burning: number, working: number }?,
}

remotes.inventoryChanged.OnClientEvent:Connect(function(encodedPack: unknown, screen: ScreenMessage?)
	pack = decode(encodedPack)
	carrying = screen ~= nil and screen.carried ~= nil
	HotbarGui.show(hotbarGui, pack, selectedSlot)
	setScreenOpen(screen ~= nil)
	if screen ~= nil then
		local other = if screen.other ~= nil then decode(screen.other) else nil
		local otherLook = if screen.otherItemId ~= nil then ItemLooks[screen.otherItemId] else nil
		local carried = if screen.carried ~= nil
			then ItemStack.new(screen.carried.itemId, screen.carried.count)
			else nil
		local otherName = if otherLook ~= nil then otherLook.name else ""
		InventoryGui.show(inventoryGui, pack, other, otherName, carried, screen.station)
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

-- Returns the id of the item in hand if it is one that can be placed, or nil.
local function placeableInHand(): string?
	local held = Inventory.getStack(pack, selectedSlot)
	if held ~= nil and ItemRegistry.get(held.itemId).placeable == true then
		return held.itemId
	end
	return nil
end

-- Returns what a point on the screen is over, if the player's character stands near enough to reach it.
local function pointedInReach(viewportPoint: Vector2): PlotPointer.Pointed?
	local pointed = PlotPointer.at(viewportPoint)
	local character = Players.LocalPlayer.Character
	local root = if character ~= nil then character:FindFirstChild("HumanoidRootPart") else nil
	if pointed == nil or root == nil or not root:IsA("BasePart") then
		return nil
	end
	local away = pointed.center - root.Position
	if Vector3.new(away.X, 0, away.Z).Magnitude > Plot.REACH then
		return nil
	end
	return pointed
end

-- The Use action on what a point on the screen is over: opens a placed item, or places the item in hand on a bare tile.
local function use(pointed: PlotPointer.Pointed?)
	if pointed == nil or screenOpen then
		return
	end
	if pointed.kind == "placedItem" then
		remotes.usePlaced:FireServer(pointed.id)
	elseif placeableInHand() ~= nil then
		remotes.placeSelected:FireServer(pointed.x, pointed.z)
	end
end

-- The Hit action on what a point on the screen is over: knocks a placed item off the plot.
local function hit(pointed: PlotPointer.Pointed?)
	if pointed ~= nil and not screenOpen and pointed.kind == "placedItem" then
		remotes.hitPlaced:FireServer(pointed.id)
	end
end

-- With a mouse, what is in reach under the pointer is marked: a faint block where the item in hand
-- would stand, or a white outline on the placed item that a click would open or knock off.
local ghost = PlacementGhost.new()
local outline = Instance.new("SelectionBox")
outline.Name = "PointerOutline"
outline.LineThickness = 0.05
outline.Color3 = Color3.new(1, 1, 1)
outline.Parent = Workspace
RunService.RenderStepped:Connect(function()
	local pointed = if screenOpen or not UserInputService.MouseEnabled
		then nil
		else pointedInReach(UserInputService:GetMouseLocation())
	local itemId = placeableInHand()
	if pointed ~= nil and pointed.kind == "tile" and itemId ~= nil then
		PlacementGhost.show(ghost, itemId, pointed.center)
	else
		PlacementGhost.hide(ghost)
	end
	outline.Adornee = if pointed ~= nil and pointed.kind == "placedItem" then pointed.part else nil
end)

-- Holding the right button turns Roblox's camera, so only a short press that did not turn it is a Hit.
local rightPressedAt: number? = nil
local lookWhenPressed = Vector3.zero

UserInputService.InputBegan:Connect(function(input: InputObject, handledElsewhere: boolean)
	-- Typing in the chat, or a click on a button, is not for the game.
	if handledElsewhere then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		use(pointedInReach(UserInputService:GetMouseLocation()))
		return
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		local camera = Workspace.CurrentCamera
		rightPressedAt = os.clock()
		lookWhenPressed = if camera ~= nil then camera.CFrame.LookVector else Vector3.zero
		return
	end
	local digit = digitKeys[input.KeyCode]
	if input.KeyCode == Enum.KeyCode.E then
		togglePack()
	elseif input.KeyCode == Enum.KeyCode.Q then
		-- As in Minecraft: in the world Q drops one of what is in hand, and over a slot of the open
		-- screen it drops one from that slot, or the whole stack with Ctrl held.
		local hovered = inventoryGui.hovered
		local count = if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then nil else 1
		if not screenOpen then
			remotes.dropSelected:FireServer(count)
		elseif hovered ~= nil then
			remotes.dropFromSlot:FireServer(hovered.side, hovered.slot, count)
		end
	elseif digit ~= nil and digit <= PlayerState.HOTBAR_SLOTS then
		-- As in Minecraft: in the world a number picks the hotbar slot in hand, and over a slot of the
		-- open screen it swaps that slot with the hotbar slot of that number.
		local hovered = inventoryGui.hovered
		if not screenOpen then
			selectSlot(digit)
		elseif hovered ~= nil then
			remotes.swapWithHotbarSlot:FireServer(hovered.side, hovered.slot, digit)
		end
	end
end)

local mouseButtons: { [Enum.UserInputType]: string } = {
	[Enum.UserInputType.MouseButton1] = "left",
	[Enum.UserInputType.MouseButton2] = "right",
}

UserInputService.InputEnded:Connect(function(input: InputObject)
	-- A mouse button coming up ends a drag across the slots of the inventory screen, if there was one.
	local button = mouseButtons[input.UserInputType]
	if button ~= nil then
		local dragged = SlotMouse.release(slotMouse, button, inventoryGui.hovered)
		InventoryGui.markSlots(inventoryGui, SlotMouse.getDraggedSlots(slotMouse))
		if dragged ~= nil then
			remotes.dragOverSlots:FireServer(dragged, button)
		end
	end
	if input.UserInputType ~= Enum.UserInputType.MouseButton2 or rightPressedAt == nil then
		return
	end
	local camera = Workspace.CurrentCamera
	local heldFor = os.clock() - rightPressedAt
	local turned = camera ~= nil and camera.CFrame.LookVector:Dot(lookWhenPressed) < 0.9995
	rightPressedAt = nil
	if heldFor < 0.35 and not turned then
		hit(pointedInReach(UserInputService:GetMouseLocation()))
	end
end)

-- A tap on the world is Use. Roblox gives the tap's place measured from under the strip along the
-- top of the screen, and PlotPointer wants it from the top of the window, so the strip is added back.
UserInputService.TouchTapInWorld:Connect(function(position: Vector2, handledElsewhere: boolean)
	if not handledElsewhere then
		use(pointedInReach(position + GuiService:GetGuiInset()))
	end
end)
