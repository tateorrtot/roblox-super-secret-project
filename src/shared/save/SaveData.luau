--!strict
--[=[
	What is kept of one player between visits, as plain data with a version
	number: at present, what is in their pack.

	[method encode] turns a PlayerState into saved data, and [method decode]
	turns saved data back into a PlayerState. Saved data is made only of
	numbers, strings, lists with no gaps and records with named fields, so it
	can go to a data store as it is. A player's saved data now looks like

	`{ version = 1, pack = { slotCount = 36, stacks = { { slot = 1, itemId = "log", count = 12 } } } }`

	The version is `SaveData.CURRENT_VERSION`. It goes up by one whenever the
	shape of saved data changes, and [method decode] is then taught to read
	the older shape as well, so that no player's save is ever left unreadable.

	Data from a data store is not trusted. [method decode] never raises an
	error: given anything it cannot read, it returns `nil` and says why. Code
	that gets `nil` must not save over what was there.

	This is only the shape of the data. Fetching and storing it is done by
	the server.

	```lua
	local saved = SaveData.encode(state) --> plain data, ready to store
	local state, problem = SaveData.decode(saved) --> a PlayerState; or nil and what was wrong
	```
]=]
local Inventory = require("../inventory/Inventory")
local PlayerState = require("../players/PlayerState")

local SaveData = {}

type PlayerState = PlayerState.PlayerState

--- One player's saved data, made by [method encode] and read by [method decode].
export type SavedPlayer = {
	--- The version of this shape: `SaveData.CURRENT_VERSION` when it was saved.
	version: number,
	--- What their pack held, as `Inventory.encode` makes it.
	pack: Inventory.EncodedInventory,
}

--- The version of saved data that [method encode] makes.
SaveData.CURRENT_VERSION = 1

--[=[
	Returns the saved data for a player as they are now.

	Raises an error if the player has an inventory screen open. Close it
	first with `PlayerState.closeInventory`, so that a stack they are carrying
	is back in their pack and is saved with it.
]=]
function SaveData.encode(state: PlayerState): SavedPlayer
	if state.session ~= nil then
		error("SaveData.encode: the player has an inventory screen open; close it first", 2)
	end
	return { version = SaveData.CURRENT_VERSION, pack = Inventory.encode(state.pack) }
end

--[=[
	Returns a new PlayerState holding what `saved` says, with hotbar slot 1
	selected and no inventory screen open.

	`saved` may be anything at all. If it is not saved data that this version
	of the game can read, returns `nil` and a sentence saying what is wrong:
	it is not a table, its version is not a whole number of 1 or more, it was
	saved by a newer version of the game, it has a field saved data does not
	have, its pack is not an inventory `Inventory.decode` can read, or its
	pack has the wrong number of slots.
]=]
function SaveData.decode(saved: unknown): (PlayerState?, string?)
	if type(saved) ~= "table" then
		return nil, "saved data is a table, not a " .. type(saved)
	end
	local fields = saved :: { [unknown]: unknown }
	local version = fields.version
	if type(version) ~= "number" or version < 1 or version ~= math.floor(version) or version == math.huge then
		return nil, string.format("version must be a whole number, 1 or more; got %s", tostring(version))
	end
	if version > SaveData.CURRENT_VERSION then
		return nil,
			string.format(
				"this was saved by a newer version of the game: version %d, and this game reads up to version %d",
				version,
				SaveData.CURRENT_VERSION
			)
	end
	for field in fields do
		if field ~= "version" and field ~= "pack" then
			return nil, string.format("saved data has no field called %s", tostring(field))
		end
	end
	local pack, problem = Inventory.decode(fields.pack)
	if pack == nil then
		return nil, "pack: " .. tostring(problem)
	end
	if pack.slotCount ~= PlayerState.PACK_SLOTS then
		return nil, string.format("pack has %d slots, and a pack has %d", pack.slotCount, PlayerState.PACK_SLOTS)
	end

	local state = PlayerState.new()
	for slot = 1, pack.slotCount do
		Inventory.setStack(state.pack, slot, Inventory.getStack(pack, slot))
	end
	return state, nil
end

return SaveData
