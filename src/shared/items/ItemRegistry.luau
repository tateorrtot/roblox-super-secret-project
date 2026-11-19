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
	ItemRegistry.register({ id = "crate", stackSize = 1, placeable = true, slotCount = 27 })

	ItemRegistry.get("log").stackSize --> 16
	ItemRegistry.get("log").placeable --> nil: a log cannot be placed
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
	--- `true` for an item that can be placed on a plot, where it stands as a thing in the world.
	--- Left out for an item that cannot.
	read placeable: boolean?,
	--- How many inventory slots the item has inside it once it is placed, as a crate does: a whole
	--- number, 1 or more. Left out for an item that holds nothing. Only a placeable item may have it.
	read slotCount: number?,
	--- How long one of this item burns as fuel, in seconds: a number above 0. Left out for an item
	--- that does not burn.
	read burnSeconds: number?,
}

local definitions: { [string]: ItemDefinition } = {}

--[=[
	Adds an item definition to the registry.

	The registry keeps its own copy, so changing the given table afterwards
	changes nothing.

	Raises an error if `id` is not lowercase letters, digits and underscores
	starting with a letter, if `stackSize` is not a whole number of 1 or more,
	if `placeable` is given and is not `true`, if `slotCount` is given and is
	not a whole number of 1 or more, if `slotCount` is given for an item that
	is not placeable, if `burnSeconds` is given and is not a number above 0,
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
	local placeable, slotCount = fields.placeable, fields.slotCount
	if placeable ~= nil and placeable ~= true then
		error(
			string.format(
				'ItemRegistry.register: placeable of "%s" must be true, or left out; got %s',
				id,
				tostring(placeable)
			),
			2
		)
	end
	if slotCount ~= nil then
		if
			type(slotCount) ~= "number"
			or slotCount < 1
			or slotCount == math.huge
			or slotCount ~= math.floor(slotCount)
		then
			error(
				string.format(
					'ItemRegistry.register: slotCount of "%s" must be a whole number, 1 or more, or left out; got %s',
					id,
					tostring(slotCount)
				),
				2
			)
		end
		if placeable ~= true then
			error(
				string.format(
					'ItemRegistry.register: "%s" has a slotCount but is not placeable; only an item that can be placed holds things',
					id
				),
				2
			)
		end
	end
	local burnSeconds = fields.burnSeconds
	if burnSeconds ~= nil then
		if type(burnSeconds) ~= "number" or not (burnSeconds > 0) or burnSeconds == math.huge then
			error(
				string.format(
					'ItemRegistry.register: burnSeconds of "%s" must be a number above 0, or left out; got %s',
					id,
					tostring(burnSeconds)
				),
				2
			)
		end
	end
	local known = { id = true, stackSize = true, placeable = true, slotCount = true, burnSeconds = true }
	for field in fields do
		if known[field :: any] ~= true then
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
	definitions[id] = table.freeze({
		id = id,
		stackSize = stackSize,
		placeable = placeable :: boolean?,
		slotCount = slotCount :: number?,
		burnSeconds = burnSeconds :: number?,
	})
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
