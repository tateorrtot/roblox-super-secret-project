--!strict
--- Everything the game has in it: its items, its recipes, its fuels, the scripts of its items and
--- the scripts of its kinds of placed object.
---
--- `register` hands each one to the registry that the rules read it from. This is the one list of
--- what is in the game: the rules name none of it.
local Crate = require("./Crate")
local CrateItem = require("./CrateItem")
local FuelDefinitions = require("../stations/FuelDefinitions")
local FuelRegistry = require("../stations/FuelRegistry")
local ItemDefinitions = require("../items/ItemDefinitions")
local ItemRegistry = require("../items/ItemRegistry")
local ItemScripts = require("../requests/ItemScripts")
local PlacedObjectScripts = require("../requests/PlacedObjectScripts")
local RecipeDefinitions = require("../stations/RecipeDefinitions")
local RecipeRegistry = require("../stations/RecipeRegistry")
local Stove = require("./Stove")
local StoveItem = require("./StoveItem")

local Content = {}

--- Registers everything the game has: each row of `ItemDefinitions`, of `RecipeDefinitions` and
--- of `FuelDefinitions`, the script of the crate item and of the stove item, and the script of the
--- crate and of the stove. It is called once, before the rules are used. Fails if it is called a
--- second time, since everything is registered already.
function Content.register()
	for _, definition in ItemDefinitions do
		ItemRegistry.register(definition)
	end
	for _, recipe in RecipeDefinitions do
		RecipeRegistry.register(recipe)
	end
	for _, fuel in FuelDefinitions do
		FuelRegistry.register(fuel)
	end
	ItemScripts.register(CrateItem.ITEM_ID, CrateItem)
	ItemScripts.register(StoveItem.ITEM_ID, StoveItem)
	PlacedObjectScripts.register(Crate.PLACED_OBJECT_KIND_ID, Crate)
	PlacedObjectScripts.register(Stove.PLACED_OBJECT_KIND_ID, Stove)
end

return Content
