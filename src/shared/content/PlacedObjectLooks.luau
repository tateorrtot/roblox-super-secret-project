--!strict
--- How each kind of placed object is shown while it has no art of its own, by the kind's id.
---
--- There is one row for each kind of placed object that the game has. The names and colours are
--- placeholders.

export type PlacedObjectLook = {
	--- The name shown for a placed object of the kind.
	read name: string,
	--- The colour of the kind's placeholder block, as red, green and blue, each from 0 to 255.
	read color: { number },
}

local looks: { [string]: PlacedObjectLook } = {
	crate = { name = "Crate", color = { 170, 130, 80 } },
	stove = { name = "Stove", color = { 60, 60, 70 } },
}

return table.freeze(looks)
