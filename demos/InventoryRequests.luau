--!strict
-- A client's requests, carried out on the server: a player opens a crate and moves a stack into it.
-- Run from the repository root: lune run demos/InventoryRequests

local Content = require("../src/shared/content/Content")
local Crate = require("../src/shared/content/Crate")
local Inventory = require("../src/shared/inventory/Inventory")
local ItemStack = require("../src/shared/items/ItemStack")
local Plot = require("../src/shared/plots/Plot")
local Position = require("../src/shared/Position")
local Requests = require("../src/shared/requests/Requests")
local World = require("../src/shared/world/World")

local function describe(stack: ItemStack.ItemStack?): string
	return if stack then stack.count .. " " .. stack.itemId else "nothing"
end

Content.register()

local world = World.new(Plot.new(8, 8), Position.new(0, 0, 0), 0)
local PLAYER_ID = 1
local player = World.addPlayer(world, PLAYER_ID)
World.setCharacterPosition(world, PLAYER_ID, Position.new(6, 0, 6))
Inventory.addItems(player.pack, "log", 12)

local crateId = Crate.place(world.plot, 2, 2)
local crate = Crate.get(world.plot, crateId)

print("A player stands by a crate, with 12 logs in slot 1 of their pack.")
print("Each request below is a name and the values that the player's client sent.\n")

print(`"interactWithPlacedObject", {crateId}`)
Requests.carryOut(world, PLAYER_ID, "interactWithPlacedObject", crateId)
print(`  the player has a screen open: {player.screen ~= nil}`)

local crateSlots = Inventory.getSlotNumbers(crate.inventory)
print(`\n"moveFromSlotToInventory", "pack", 1, "other", a list of the numbers 1 to {#crateSlots}`)
print("  takes the stack out of slot 1 of the pack, and adds it to the listed slots of the other inventory, the crate")
Requests.carryOut(world, PLAYER_ID, "moveFromSlotToInventory", "pack", 1, "other", crateSlots)
print(`  slot 1 of the pack:  {describe(Inventory.getStack(player.pack, 1))}`)
print(`  slot 1 of the crate: {describe(Inventory.getStack(crate.inventory, 1))}`)

print('\n"moveFromSlotToInventory", "other", 1, "pack", a list of the numbers 1 and 999')
print("  the pack has no slot 999, so the request does nothing")
Requests.carryOut(world, PLAYER_ID, "moveFromSlotToInventory", "other", 1, "pack", { 1, 999 })
print(`  slot 1 of the crate: {describe(Inventory.getStack(crate.inventory, 1))}`)

print('\n"closeScreen"')
Requests.carryOut(world, PLAYER_ID, "closeScreen")
print(`  the player has a screen open: {player.screen ~= nil}`)
