--!strict
--- Everything the game has in it: its items, and its kinds of placed object.
---
--- `register` hands each one to the registry that the rules read it from. `Items.ALL` and
--- `PlacedObjectKinds.ALL` are the two lists of what is in the game: the rules name none of it.
local ItemRegistry = require("../items/ItemRegistry")
local ItemScripts = require("../requests/ItemScripts")
local Items = require("./Items")
local PlacedObjectKinds = require("./PlacedObjectKinds")
local PlacedObjectScripts = require("../requests/PlacedObjectScripts")

local Content = {}

--- Registers everything the game has. Each item of `Items.ALL` is handed to `ItemRegistry`, which
--- keeps its id and stack size, and to `ItemScripts`, as the script of the item with its id. Each
--- kind of `PlacedObjectKinds.ALL` is handed to `PlacedObjectScripts`, as the script of the kind
--- of placed object with its id. It is called once, before the rules are used. Fails if it is
--- called a second time, since everything is registered already.
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
