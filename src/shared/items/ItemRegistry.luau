--!strict
--[=[
	Every kind of item the game has, looked up by id.

	An item definition says what one kind of thing is: a log, a crate, a
	stove. There is one definition for "log" however many logs exist. To have
	some logs, make an ItemStack.

	Definitions are registered once, when the game starts, and never change
	after that. There is one registry for the whole game.

	```lua
	ItemRegistry.register({ id = "log", stackSize = 16 })

	ItemRegistry.get("log").stackSize --> 16
	ItemRegistry.has("anvil") --> false
	ItemRegistry.get("anvil") --> error: no item has the id "anvil"
	```
]=]
local ItemRegistry = {}

--- What one kind of item is. `read` means code outside this module cannot assign the field, and
--- nothing inside it does either: a definition never changes.
export type ItemDefinition = {
	--- The name the item goes by in code and in saved data, such as `"log"`.
	--- Lowercase letters, digits and underscores, starting with a letter.
	read id: string,
	--- The most of this item that one inventory slot can hold: a whole number, 1 or more.
	--- 1 for an item that does not stack.
	read stackSize: number,
}

local definitions: { [string]: ItemDefinition } = {}

--[=[
	Adds an item definition to the registry.

	The registry keeps its own copy, so changing the given table afterwards
	changes nothing.

	Raises an error if `id` is not lowercase letters, digits and underscores
	starting with a letter, if `stackSize` is not a whole number of 1 or more,
	if the table has any other field, or if an item with that id is already
	registered.
]=]
function ItemRegistry.register(definition: ItemDefinition)
	if type(definition) ~= "table" then
		error("ItemRegistry.register: an item definition is a table, not a " .. type(definition), 2)
	end
	local fields = definition :: { [unknown]: unknown }
	local id, stackSize = fields.id, fields.stackSize
	if type(id) ~= "string" or string.match(id, "^[a-z][a-z0-9_]*$") == nil then
		error(
			string.format(
				"ItemRegistry.register: id must be lowercase letters, digits and underscores, starting with a letter; got %s",
				if type(id) == "string" then string.format("%q", id) else type(id)
			),
			2
		)
	end
	if type(stackSize) ~= "number" or stackSize < 1 or stackSize == math.huge or stackSize ~= math.floor(stackSize) then
		error(
			string.format(
				'ItemRegistry.register: stackSize of "%s" must be a whole number, 1 or more; got %s',
				id,
				tostring(stackSize)
			),
			2
		)
	end
	for field in fields do
		if field ~= "id" and field ~= "stackSize" then
			error(
				string.format(
					'ItemRegistry.register: "%s" has a field item definitions do not have: %s',
					id,
					tostring(field)
				),
				2
			)
		end
	end
	if definitions[id] ~= nil then
		error(string.format('ItemRegistry.register: there is already an item with the id "%s"', id), 2)
	end
	definitions[id] = table.freeze({ id = id, stackSize = stackSize })
end

--[=[
	Returns the definition of the item with the id `id`.

	Raises an error if no item has that id, so that a mistyped id is found at
	once. Ask [method has] first when the id may not exist.
]=]
function ItemRegistry.get(id: string): ItemDefinition
	local definition = definitions[id]
	if definition == nil then
		error(string.format('ItemRegistry.get: no item has the id "%s"', tostring(id)), 2)
	end
	return definition
end

--[=[
	Returns `true` if an item with the id `id` has been registered.
]=]
function ItemRegistry.has(id: string): boolean
	return definitions[id] ~= nil
end

--[=[
	Returns the definition of every registered item, ordered by id.
]=]
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
