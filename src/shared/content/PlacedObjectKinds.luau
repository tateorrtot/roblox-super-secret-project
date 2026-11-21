--!strict
--- Every kind of placed object in the game.
---
--- A kind is one table, written in a file of its own, as `Crate` is. It holds the kind's id, its
--- name, and whichever functions of `PlacedObjectScripts.PlacedObjectScript` it has a use for.
--- `ALL` lists every kind, and `get` returns one by its id.
local Crate = require("./Crate")
local PlacedObjectScripts = require("../requests/PlacedObjectScripts")
local Stove = require("./Stove")

local PlacedObjectKinds = {}

--- A kind's table: the functions of `PlacedObjectScripts.PlacedObjectScript`, and the kind's id
--- and name.
export type PlacedObjectKind = PlacedObjectScripts.PlacedObjectScript & {
	--- The `kindId` that every placed object of the kind has.
	read PLACED_OBJECT_KIND_ID: string,
	--- The name shown for a placed object of the kind.
	read NAME: string,
}

local all: { PlacedObjectKind } = { Crate, Stove }

local kindsById: { [string]: PlacedObjectKind } = {}
for _, kind in all do
	kindsById[kind.PLACED_OBJECT_KIND_ID] = kind
end

--- Every kind of placed object in the game.
PlacedObjectKinds.ALL = table.freeze(all)

--- Returns the kind of placed object with the id `kindId`. Fails if the game has no kind with
--- that id.
function PlacedObjectKinds.get(kindId: string): PlacedObjectKind
	return kindsById[kindId] or error(`the game has no kind of placed object with the id "{kindId}"`, 2)
end

return PlacedObjectKinds
