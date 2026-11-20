--!strict
--- Every fuel the game has: which items burn in a station's fire, and for how long.
---
--- A fuel is an item's id and the seconds that one of that item burns. Fuels are registered once,
--- when the game starts, and never change. There is one registry for the whole game.
local ItemRegistry = require("../items/ItemRegistry")

local FuelRegistry = {}

--- One item that burns. It never changes once registered.
export type Fuel = {
	--- The id of the item that burns.
	read item: string,
	--- How long one of the item burns, in seconds: a finite number above 0.
	read seconds: number,
}

local fuelsByItemId: { [string]: Fuel } = {}

--- Adds a copy of `fuel` to the registry, so that changing `fuel` afterwards changes nothing. Only
--- the two fields of `Fuel` are copied. Fails if `fuel.item` is not a registered item, if
--- `fuel.seconds` is not a finite number above 0, or if that item is a fuel already.
function FuelRegistry.register(fuel: Fuel)
	local item, seconds = fuel.item, fuel.seconds
	if not ItemRegistry.has(item) then
		error(`fuel "{item}": no item has the id "{item}"`, 2)
	end
	if not (seconds > 0 and seconds < math.huge) then
		error(`fuel "{item}": seconds must be above 0 and finite, not {seconds}`, 2)
	end
	if fuelsByItemId[item] ~= nil then
		error(`fuel "{item}": is a fuel already`, 2)
	end
	fuelsByItemId[item] = table.freeze({ item = item, seconds = seconds })
end

--- Returns the fuel that the item `itemId` is. Returns `nil` if that item does not burn, including
--- when no item has that id.
function FuelRegistry.find(itemId: string): Fuel?
	return fuelsByItemId[itemId]
end

return FuelRegistry
