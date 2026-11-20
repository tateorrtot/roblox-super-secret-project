--!strict
--- Every kind of item the game has, looked up by id.
---
--- An item definition says what one kind of thing is: a log, a crate, a stove. There is one
--- definition for "log" however many logs exist. Definitions are registered once, when the game
--- starts, and never change. There is one registry for the whole game.
local ItemRegistry = {}

--- What one kind of item is.
export type ItemDefinition = {
	--- The name the item goes by in code and in saved data, such as `"log"`: lowercase letters,
	--- digits and underscores, starting with a letter.
	read id: string,
	--- The most of this item that one inventory slot can hold: a whole number, 1 or more.
	read stackSize: number,
	--- `true` for an item that can be placed on a plot. Left out for an item that cannot.
	read placeable: boolean?,
	--- How many inventory slots the item has once it is placed, as a crate does: a whole number,
	--- 1 or more. Left out for an item that holds nothing. Only a placeable item has it.
	read slotCount: number?,
	--- How long one of this item burns as fuel, in seconds: a number above 0. Left out for an
	--- item that does not burn.
	read burnSeconds: number?,
}

local definitions: { [string]: ItemDefinition } = {}
local FIELDS = { id = true, stackSize = true, placeable = true, slotCount = true, burnSeconds = true }

local function isCount(value: unknown): boolean
	return type(value) == "number" and value >= 1 and value < math.huge and value % 1 == 0
end

local function findUnknownField(definition: ItemDefinition): unknown
	for field in definition :: { [unknown]: unknown } do
		if not FIELDS[field :: string] then
			return field
		end
	end
	return nil
end

--- Adds a copy of `definition` to the registry. The copy is frozen, and changing `definition`
--- afterwards changes nothing. Fails if a field is not what `ItemDefinition` says it must be, if
--- the table has a field that `ItemDefinition` does not list, or if an item with that id is
--- already registered.
function ItemRegistry.register(definition: ItemDefinition)
	local id, slotCount, burnSeconds = definition.id, definition.slotCount, definition.burnSeconds
	local unknownField = findUnknownField(definition)
	assert(
		string.match(id, "^[a-z][a-z0-9_]*$"),
		`id "{id}" is not lowercase letters, digits and underscores, starting with a letter`
	)
	assert(isCount(definition.stackSize), `"{id}" needs a stackSize that is a whole number, 1 or more`)
	assert(definition.placeable == nil or definition.placeable == true, `"{id}" has a placeable that is not true`)
	assert(slotCount == nil or isCount(slotCount), `"{id}" has a slotCount that is not a whole number, 1 or more`)
	assert(slotCount == nil or definition.placeable, `"{id}" has a slotCount but is not placeable`)
	assert(
		burnSeconds == nil or (type(burnSeconds) == "number" and burnSeconds > 0 and burnSeconds < math.huge),
		`"{id}" has a burnSeconds that is not a finite number above 0`
	)
	assert(unknownField == nil, `"{id}" has a field item definitions do not have: {unknownField}`)
	assert(definitions[id] == nil, `there is already an item with the id "{id}"`)
	definitions[id] = table.freeze(table.clone(definition))
end

--- Returns the definition of the item with the id `id`. Fails if no item has that id.
function ItemRegistry.get(id: string): ItemDefinition
	return definitions[id] or error(`no item has the id "{id}"`, 2)
end

--- Returns `true` if an item with the id `id` has been registered.
function ItemRegistry.has(id: string): boolean
	return definitions[id] ~= nil
end

--- Returns a new list of the definition of every registered item, ordered by id.
function ItemRegistry.all(): { ItemDefinition }
	local all: { ItemDefinition } = {}
	for _, definition in definitions do
		table.insert(all, definition)
	end
	table.sort(all, function(a: ItemDefinition, b: ItemDefinition)
		return a.id < b.id
	end)
	return all
end

return ItemRegistry
