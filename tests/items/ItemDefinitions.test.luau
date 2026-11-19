--!strict
-- Tests for the written rows: ItemDefinitions and ItemLooks.
-- Run from the repository root: lune run tests/items/ItemDefinitions.test.luau

local Check = require("../Check")
local ItemDefinitions = require("../../src/shared/items/ItemDefinitions")
local ItemLooks = require("../../src/shared/items/ItemLooks")
local ItemRegistry = require("../../src/shared/items/ItemRegistry")

local check = Check.that

check(#ItemDefinitions > 0, "there is at least one item")

for index, definition in ItemDefinitions do
	local problem = Check.errorFrom(function()
		ItemRegistry.register(definition)
	end)
	check(problem == nil, "row " .. index .. " is a definition the registry accepts: " .. tostring(problem))
end
check(#ItemRegistry.all() == #ItemDefinitions, "every row is registered under an id of its own")

for _, definition in ItemDefinitions do
	local look = ItemLooks[definition.id]
	check(look ~= nil, '"' .. definition.id .. '" has a look')
	if look ~= nil then
		check(type(look.name) == "string" and #look.name > 0, 'the look of "' .. definition.id .. '" has a name')
		local color = look.color
		local isColor = type(color) == "table" and #color == 3
		if isColor then
			for _, part in color do
				if type(part) ~= "number" or part ~= math.floor(part) or part < 0 or part > 255 then
					isColor = false
				end
			end
		end
		check(isColor, 'the colour of "' .. definition.id .. '" is three whole numbers from 0 to 255')
	end
end

for itemId in ItemLooks do
	check(ItemRegistry.has(itemId), 'the look "' .. itemId .. '" belongs to an item that exists')
end

Check.finish("ItemDefinitions")
