--!strict
-- Tests for Messages. Run from the repository root: lune run tests/Messages.test.luau

local Check = require("./Check")
local Messages = require("../src/shared/Messages")

local check = Check.that

local seen: { [string]: boolean } = {}
for _, list in { Messages.toServer, Messages.toClient } do
	check(#list > 0, "each direction has at least one message")
	for _, name in list do
		check(
			string.match(name, "^%l%a*$") ~= nil,
			'"' .. name .. '" is one word in camelCase, so it can be a field name'
		)
		check(not seen[name], '"' .. name .. '" is listed once')
		seen[name] = true
	end
end

Check.finish("Messages")
