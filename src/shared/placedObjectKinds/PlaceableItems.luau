--!strict
--- The kind of placed object that each item places, by the item's id.
---
--- A row is the id of an item and the id of a kind of placed object. A player who holds the item
--- can place an object of that kind on a plot, which uses up one of the item. An item with no row
--- places nothing. These rows are placeholders.

local kindIdsByItemId: { [string]: string } = {
	crate = "crate",
	stove = "stove",
}

return table.freeze(kindIdsByItemId)
