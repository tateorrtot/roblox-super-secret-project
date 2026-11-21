--!strict
--- What is kept of a player between visits, as plain data: their pack, and the version of the
--- save format it was written in.
---
--- `encode` returns a player's pack as plain data, and `decode` reads the pack back from it.
--- `decode` accepts every version from `1` to `CURRENT_VERSION`.
local Inventory = require("../inventory/Inventory")
local PlayerState = require("../players/PlayerState")

local SaveData = {}

--- A player's saved data: the version of the save format, and the player's pack.
export type SavedPlayer = {
	--- The version of the save format that the data was written in.
	version: number,
	--- The player's pack, as `Inventory.encode` returns it.
	pack: Inventory.EncodedInventory,
}

--- The version of the save format that `encode` writes, and the highest version that `decode`
--- reads.
SaveData.CURRENT_VERSION = 1

--- Returns `pack` as saved data, with the version `CURRENT_VERSION`.
--- Note: `encode` does not save the stack that an open inventory screen carries, because that stack
--- is not in the pack.
function SaveData.encode(pack: Inventory.Inventory): SavedPlayer
	return { version = SaveData.CURRENT_VERSION, pack = Inventory.encode(pack) }
end

--- Returns the pack that `saved` holds. Returns `nil` and what is wrong with `saved`, in words, if
--- `saved` is not a table, its `version` is not a whole number from `1` to `CURRENT_VERSION`, it
--- has a field other than `version` and `pack`, `Inventory.decode` cannot read its `pack`, or its
--- `pack` does not have `PlayerState.PACK_SLOT_COUNT` slots. Accepts a value of any type for
--- `saved`.
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
	if pack.slotCount ~= PlayerState.PACK_SLOT_COUNT then
		return nil, `pack has {pack.slotCount} slots, and a pack has {PlayerState.PACK_SLOT_COUNT}`
	end
	return pack, nil
end

return SaveData
