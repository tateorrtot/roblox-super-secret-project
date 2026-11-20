--!strict
--- What is kept of a player between visits, as plain data: their pack, and the version of the
--- save format it was written in.
---
--- `encode` writes the data and `decode` reads it back. When what is kept changes,
--- `CURRENT_VERSION` goes up by one and `decode` learns to read the older versions too.
local Inventory = require("../inventory/Inventory")
local PlayerState = require("../players/PlayerState")

local SaveData = {}

export type SavedPlayer = {
	--- The version of the save format this was written in.
	version: number,
	pack: Inventory.EncodedInventory,
}

--- The version of the save format that `encode` writes.
SaveData.CURRENT_VERSION = 1

--- Returns a player's pack as data to save.
--- Note: a stack the player is carrying on an open inventory screen is not in their pack. Close
--- the screen first, or that stack is not saved.
function SaveData.encode(pack: Inventory.Inventory): SavedPlayer
	return { version = SaveData.CURRENT_VERSION, pack = Inventory.encode(pack) }
end

--- Returns the pack read from saved data. If the data is not something this version of the game
--- can read, returns `nil` and what is wrong with it, in words: it is not a table, its version is
--- not a whole number from 1 to `CURRENT_VERSION`, it has a field saved data does not have, or its
--- pack is not an inventory of `PlayerState.PACK_SLOTS` slots that `Inventory.decode` can read.
--- The data may be anything at all.
function SaveData.decode(saved: unknown): (Inventory.Inventory?, string?)
	if type(saved) ~= "table" then
		return nil, "saved data must be a table; got a " .. type(saved)
	end
	local fields = saved :: { [unknown]: unknown }
	local version = fields.version
	if type(version) ~= "number" or version % 1 ~= 0 or version < 1 then
		return nil, `version must be a whole number, 1 or more; got {version}`
	end
	if version > SaveData.CURRENT_VERSION then
		return nil,
			`this was saved by a newer version of the game: version {version}, and this game reads up to version {SaveData.CURRENT_VERSION}`
	end
	for field in fields do
		if field ~= "version" and field ~= "pack" then
			return nil, `saved data has a field it should not have: {field}`
		end
	end
	local pack, problem = Inventory.decode(fields.pack)
	if pack == nil then
		return nil, `pack: {problem}`
	end
	if pack.slotCount ~= PlayerState.PACK_SLOTS then
		return nil, `pack has {pack.slotCount} slots, and a pack has {PlayerState.PACK_SLOTS}`
	end
	return pack, nil
end

return SaveData
