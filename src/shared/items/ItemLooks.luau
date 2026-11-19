--!strict
--[=[
	How each item is shown while it has no art of its own: the name a player
	reads, and the colour of the plain block that stands in for it.

	There is one row for each item in ItemDefinitions, under the item's id.
	Nothing in the rules reads this. Only code that draws does.

	The names are a draft for review, and the colours are placeholders that go
	when an item gets a model and an icon.

	```lua
	ItemLooks.log.name --> "Log"
	ItemLooks.log.color --> { 133, 94, 66 }
	```
]=]

export type ItemLook = {
	--- The name a player reads.
	read name: string,
	--- The colour of its placeholder block, as red, green and blue, each from 0 to 255.
	read color: { number },
}

local looks: { [string]: ItemLook } = {
	log = { name = "Log", color = { 133, 94, 66 } },
	stone = { name = "Stone", color = { 128, 128, 128 } },
	crystal = { name = "Crystal", color = { 150, 110, 220 } },
	apple = { name = "Apple", color = { 200, 50, 50 } },
	fish = { name = "Fish", color = { 90, 150, 200 } },
	cheese = { name = "Cheese", color = { 235, 200, 80 } },
	stove = { name = "Stove", color = { 60, 60, 70 } },
	crate = { name = "Crate", color = { 170, 130, 80 } },
}

return table.freeze(looks)
