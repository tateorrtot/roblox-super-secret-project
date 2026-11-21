--!strict
--- Everything the game has in it: its items, its recipes, its fuels and the scripts of its kinds
--- of placed object.
---
--- `register` hands each one to the registry that the rules read it from. This is the one list of
--- what is in the game: the rules name none of it.
local Crate = require("./Crate")
local FuelDefinitions = require("./FuelDefinitions")
local FuelRegistry = require("../stations/FuelRegistry")
local ItemRegistry = require("../items/ItemRegistry")
local ItemScripts = require("../requests/ItemScripts")
local Items = require("./Items")
local PlacedObjectScripts = require("../requests/PlacedObjectScripts")
local RecipeDefinitions = require("./RecipeDefinitions")
local RecipeRegistry = require("../stations/RecipeRegistry")
local Stove = require("./Stove")

local Content = {}

--- Registers everything the game has. Each item of `Items.ALL` is handed to `ItemRegistry`, which
--- keeps its id and stack size, and to `ItemScripts`, as the script of the item with its id. Each
--- row of `RecipeDefinitions` and of `FuelDefinitions` is registered, and so is the script of the
--- crate and of the stove. It is called once, before the rules are used. Fails if it is called a
--- second time, since everything is registered already.
function Content.register()
	for _, item in Items.ALL do
		ItemRegistry.register(item)
		ItemScripts.register(item.id, item)
	end
	for _, recipe in RecipeDefinitions do
		RecipeRegistry.register(recipe)
	end
	for _, fuel in FuelDefinitions do
		FuelRegistry.register(fuel)
	end
	PlacedObjectScripts.register(Crate.PLACED_OBJECT_KIND_ID, Crate)
	PlacedObjectScripts.register(Stove.PLACED_OBJECT_KIND_ID, Stove)
end

return Content
