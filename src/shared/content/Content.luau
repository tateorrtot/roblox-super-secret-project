--!strict
--- Everything the game has in it: its items, and its kinds of placed object.
---
--- `register` hands each item to `ItemRegistry` and `ItemScripts`, and each kind of placed object
--- to `PlacedObjectScripts`. `Items.ALL` and `PlacedObjectKinds.ALL` list what the game has.
local ItemRegistry = require("../items/ItemRegistry")
local ItemScripts = require("../requests/ItemScripts")
local Items = require("./Items")
local PlacedObjectKinds = require("./PlacedObjectKinds")
local PlacedObjectScripts = require("../requests/PlacedObjectScripts")

local Content = {}

--- Registers everything the game has. Hands each item of `Items.ALL` to
--- `ItemRegistry.register`, which keeps its id and stack size, and to `ItemScripts.register`, as
--- the script of the item with its id. Hands each kind of `PlacedObjectKinds.ALL` to
--- `PlacedObjectScripts.register`, as the script of the kind with its `PLACED_OBJECT_KIND_ID`.
--- Fails if it is called a second time, since every id is registered already.
function Content.register()
	for _, item in Items.ALL do
		ItemRegistry.register(item)
		ItemScripts.register(item.id, item)
	end
	for _, kind in PlacedObjectKinds.ALL do
		PlacedObjectScripts.register(kind.PLACED_OBJECT_KIND_ID, kind)
	end
end

return Content
