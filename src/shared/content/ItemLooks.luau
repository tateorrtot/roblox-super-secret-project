--!strict
--- How each item is shown while it has no art of its own, by item id.
---
--- There is one row for each item in `ItemDefinitions`. The names and colours are placeholders.

export type ItemLook = {
	--- The name shown for the item.
	read name: string,
	--- The colour of the item's placeholder block, as red, green and blue, each from 0 to 255.
	read color: { number },
}

local looks: { [string]: ItemLook } = {
	log = { name = "Log", color = { 133, 94, 66 } },
	stone = { name = "Stone", color = { 128, 128, 128 } },
	crystal = { name = "Crystal", color = { 150, 110, 220 } },
	apple = { name = "Apple", color = { 200, 50, 50 } },
	fish = { name = "Fish", color = { 90, 150, 200 } },
	cheese = { name = "Cheese", color = { 235, 200, 80 } },
	cooked_fish = { name = "Cooked fish", color = { 205, 140, 85 } },
	baked_apple = { name = "Baked apple", color = { 165, 85, 45 } },
	stove = { name = "Stove", color = { 60, 60, 70 } },
	crate = { name = "Crate", color = { 170, 130, 80 } },
}

return table.freeze(looks)
