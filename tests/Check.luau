--!strict
--[=[
	The helpers every test script uses.

	A test script is a plain script with no framework. It calls [method that]
	once for each thing that should be true, and [method finish] at the end.

	```lua
	local Check = require("../Check")
	local check = Check.that

	check(1 + 2 == 3, "1 + 2 should be 3")
	Check.finish("Adding")
	```
]=]
local Check = {}

local passed = 0
local failed = 0

--[=[
	Counts one check. If `condition` is false, prints `what`, which says what
	should have been true.
]=]
function Check.that(condition: boolean, what: string)
	if condition then
		passed += 1
	else
		failed += 1
		print("FAIL  " .. what)
	end
end

--[=[
	Returns the message of the error that `callback` raises, or `nil` if it raises none.
]=]
function Check.errorFrom(callback: () -> ...unknown): string?
	local ok, message = pcall(callback)
	if ok then
		return nil
	end
	return tostring(message)
end

--[=[
	Returns `true` if `callback` raises an error whose message contains `part`
	and which blames the script `callback` was written in.

	An error blames a script by starting its message with that script's name
	and a line number. A module that refuses a bad argument should blame the
	code that passed it, not itself.
]=]
function Check.raises(part: string, callback: () -> ...unknown): boolean
	local message = Check.errorFrom(callback)
	if message == nil or string.find(message, part, 1, true) == nil then
		return false
	end
	local callerScript = debug.info(callback, "s")
	return string.find(message, callerScript, 1, true) == 1
end

--[=[
	Prints how many checks passed and failed, as `name: N passed, M failed`,
	and raises an error if any failed, so that the script exits with a failure.
]=]
function Check.finish(name: string)
	print(string.format("%s: %d passed, %d failed", name, passed, failed))
	if failed > 0 then
		error(name .. " tests failed", 0)
	end
end

return Check
