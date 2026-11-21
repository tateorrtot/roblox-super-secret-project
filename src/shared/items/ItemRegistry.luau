--!strict
--- Every kind of item the game has, looked up by id.
---
--- An `ItemDefinition` says what one kind of item is, such as a log. The registry holds one
--- definition for the id `"log"`, and that definition serves every log. `register` adds a
--- definition, and `get`, `has` and `getAll` read them. A registered definition never changes. The
--- game has one registry.
local ItemRegistry = {}

--- What one kind of item is.
export type ItemDefinition = {
	--- The item's id, such as `"log"`: lowercase letters, digits and underscores, starting with a
	--- letter.
	read id: string,
	--- The most items that one stack of the item can hold: a whole number of `1` or more.
	read stackSize: number,
}

local definitions: { [string]: ItemDefinition } = {}

local function isCount(value: unknown): boolean
	return type(value) == "number" and value >= 1 and value < math.huge and value % 1 == 0
end

--- Adds the item that `definition` describes to the registry. Copies `id` and `stackSize` into a
--- new frozen table, so the registry keeps no other field of `definition`, and a later change to
--- `definition` does not reach the registry. Fails, and changes nothing, if `id` or `stackSize` is
--- not what `ItemDefinition` says it is, or if an item with the id `id` is registered already.
function ItemRegistry.register(definition: ItemDefinition)
	local id = definition.id
	assert(
		string.match(id, "^[a-z][a-z0-9_]*$"),
		`id "{id}" is not lowercase letters, digits and underscores, starting with a letter`
	)
	assert(isCount(definition.stackSize), `"{id}" needs a stackSize that is a whole number, 1 or more`)
	assert(definitions[id] == nil, `there is already an item with the id "{id}"`)
	definitions[id] = table.freeze({ id = id, stackSize = definition.stackSize })
end

--- Returns the definition of the item with the id `id`. Fails if no item has the id `id`.
function ItemRegistry.get(id: string): ItemDefinition
	return definitions[id] or error(`no item has the id "{id}"`, 2)
end

--- Returns `true` if an item with the id `id` is registered.
function ItemRegistry.has(id: string): boolean
	return definitions[id] ~= nil
end

--- Returns a new list of the definitions of every registered item, ordered by `id`.
function ItemRegistry.getAll(): { ItemDefinition }
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
