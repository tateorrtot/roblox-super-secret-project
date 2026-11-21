--!strict
--- Everything the game has in it: its items, and its kinds of placed object.
---
--- `register` hands each one to the registry that the rules read it from. This is the one list of
--- what is in the game: the rules name none of it.
local Crate = require("./Crate")
local ItemRegistry = require("../items/ItemRegistry")
local ItemScripts = require("../requests/ItemScripts")
local Items = require("./Items")
local PlacedObjectScripts = require("../requests/PlacedObjectScripts")
local Stove = require("./Stove")

local Content = {}

--- Registers everything the game has. Each item of `Items.ALL` is handed to `ItemRegistry`, which
--- keeps its id and stack size, and to `ItemScripts`, as the script of the item with its id. The
--- crate and the stove are each registered with `PlacedObjectScripts`, as the script of their
--- kind of placed object. It is called once, before the rules are used. Fails if it is called a
--- second time, since everything is registered already.
function Content.register()
	for _, item in Items.ALL do
		ItemRegistry.register(item)
		ItemScripts.register(item.id, item)
	end
	PlacedObjectScripts.register(Crate.PLACED_OBJECT_KIND_ID, Crate)
	PlacedObjectScripts.register(Stove.PLACED_OBJECT_KIND_ID, Stove)
end

return Content
