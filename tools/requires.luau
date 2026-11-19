--!nocheck
--[=[
	Prints what requires what in `src`, read from the code, and checks that
	the requires only run one way.

	Run it from the repository root:

		lune run tools/requires

	It prints each folder with the folders it requires something from, then
	each module with the modules it requires, then the rules it checked:
	1. Nothing in `src/shared` requires the server or the client.
	2. The server and the client require nothing from each other.
	3. No module requires itself through other modules.
	4. No folder requires itself through other folders. The two `Main`
	   scripts are left out of this one: their job is to join every piece,
	   so they require from every folder.

	A module goes by its path under `src` without its ending, so
	`src/server/Main.server.luau` is `server/Main`. A folder goes by its path
	in the same way: `shared/items`.

	The process exits with code 1 if a rule is broken, or if it cannot tell
	which file a `require` means.

	This file is not type-checked itself, because it uses Lune's own modules and
	their type definitions are not installed.
]=]
local fs = require("@lune/fs")
local process = require("@lune/process")

local SOURCE = "src"

-- The words in a Roblox expression that are not the name of a folder or a module.
local NOT_NAMES = { script = true, Parent = true, WaitForChild = true, FindFirstChild = true }

-- Returns the paths of every file under `directory`, at any depth, whose name ends in `.luau`.
local function findFiles(directory: string): { string }
	local found = {}
	for _, name in fs.readDir(directory) do
		local path = directory .. "/" .. name
		if fs.isDir(path) then
			for _, deeper in findFiles(path) do
				table.insert(found, deeper)
			end
		elseif string.sub(name, -5) == ".luau" then
			table.insert(found, path)
		end
	end
	table.sort(found)
	return found
end

-- Returns what a file goes by here: "server/Main" for "src/server/Main.server.luau".
local function moduleOf(path: string): string
	local name = string.sub(path, #SOURCE + 2, -6)
	name = string.gsub(name, "%.server$", "")
	name = string.gsub(name, "%.client$", "")
	return name
end

-- Returns the folder a module is in: "shared/items" for "shared/items/ItemStack".
local function folderOf(module: string): string
	return string.match(module, "^(.*)/[^/]*$")
end

-- Returns which of the three sides a module is on: "shared", "server" or "client".
local function sideOf(module: string): string
	return string.match(module, "^[^/]*")
end

-- Returns whether a module is one of the two scripts that run by themselves and join the pieces.
local function isMain(module: string): boolean
	return module == "server/Main" or module == "client/Main"
end

-- Returns the module a string path means when `from` requires it:
-- "../items/ItemStack" from "shared/inventory/Hotbar" is "shared/items/ItemStack".
local function moduleAtPath(from: string, path: string): string
	local parts = string.split(folderOf(from), "/")
	for _, part in string.split(path, "/") do
		if part == ".." then
			table.remove(parts)
		elseif part ~= "." then
			table.insert(parts, part)
		end
	end
	return table.concat(parts, "/")
end

-- Returns the module a Roblox expression means when `from` requires it, or nil if that cannot be told.
-- The module is the one named by the last word, as in `Shared.items.ItemStack` or
-- `script.Parent:WaitForChild("Remotes")`. Where both the server and the client have a module of that
-- name, it is the one on the side of `from`.
local function moduleInExpression(from: string, expression: string, isModule: { [string]: boolean }): string?
	local lastWord = nil
	for word in string.gmatch(expression, "[%a_][%w_]*") do
		if not NOT_NAMES[word] then
			lastWord = word
		end
	end
	local named = {}
	for module in isModule do
		if string.match(module, "[^/]*$") == lastWord then
			table.insert(named, module)
		end
	end
	if #named > 1 then
		local onSameSide = {}
		for _, module in named do
			if sideOf(module) == sideOf(from) then
				table.insert(onSameSide, module)
			end
		end
		named = onSameSide
	end
	return if #named == 1 then named[1] else nil
end

-- Returns the text of a file with its comments taken out, line by line.
local function codeLines(path: string): { string }
	local lines = {}
	local inComment = false
	for _, line in string.split(fs.readFile(path), "\n") do
		if inComment or string.find(line, "--[=[", 1, true) ~= nil then
			inComment = string.find(line, "]=]", 1, true) == nil
			table.insert(lines, "")
		else
			table.insert(lines, (string.gsub(line, "%-%-.*$", "")))
		end
	end
	return lines
end

-- Returns a chain of names in which each requires the next and the last is the first again,
-- or nil if nothing requires itself through others.
local function findLoop(requiredBy: { [string]: { string } }): { string }?
	local visited = {}
	local chain = {}
	local function visit(name: string): boolean
		if visited[name] == "done" then
			return false
		end
		table.insert(chain, name)
		if visited[name] == "on the chain" then
			return true
		end
		visited[name] = "on the chain"
		for _, required in requiredBy[name] or {} do
			if visit(required) then
				return true
			end
		end
		visited[name] = "done"
		table.remove(chain)
		return false
	end
	local names = {}
	for name in requiredBy do
		table.insert(names, name)
	end
	table.sort(names)
	for _, name in names do
		if visit(name) then
			local first = table.find(chain, chain[#chain])
			return table.move(chain, first, #chain, 1, {})
		end
	end
	return nil
end

-- Adds `required` to the list under `name`, once.
local function addOnce(lists: { [string]: { string } }, name: string, required: string)
	lists[name] = lists[name] or {}
	if table.find(lists[name], required) == nil then
		table.insert(lists[name], required)
	end
end

-- Prints each name with what it requires, in order, and then the names that require nothing.
local function printRequires(title: string, names: { string }, requiredBy: { [string]: { string } })
	print(title)
	local width = 0
	for _, name in names do
		width = math.max(width, #name)
	end
	local requireNothing = {}
	for _, name in names do
		local required = requiredBy[name]
		if required == nil then
			table.insert(requireNothing, name)
		else
			table.sort(required)
			print("  " .. name .. string.rep(" ", width - #name) .. "  requires  " .. table.concat(required, ", "))
		end
	end
	print("  These require nothing: " .. table.concat(requireNothing, ", "))
	print("")
end

local files = findFiles(SOURCE)
local modules = {}
local isModule = {}
for _, file in files do
	local module = moduleOf(file)
	table.insert(modules, module)
	isModule[module] = true
end

local problems = {}
local requiredByModule: { [string]: { string } } = {}
for _, file in files do
	local from = moduleOf(file)
	for number, line in codeLines(file) do
		local inBrackets = string.match(line, "require(%b())")
		if inBrackets ~= nil then
			local expression = string.sub(inBrackets, 2, -2)
			local path = string.match(expression, '^%s*"([^"]*)"%s*$')
			local required = if path ~= nil
				then moduleAtPath(from, path)
				else moduleInExpression(from, expression, isModule)
			if required ~= nil and isModule[required] then
				addOnce(requiredByModule, from, required)
			else
				table.insert(
					problems,
					string.format("%s:%d: cannot tell which module require(%s) means", file, number, expression)
				)
			end
		end
	end
end

local folders = {}
local requiredByFolder: { [string]: { string } } = {}
local requiredByFolderWithoutMain: { [string]: { string } } = {}
for _, module in modules do
	if table.find(folders, folderOf(module)) == nil then
		table.insert(folders, folderOf(module))
	end
	for _, required in requiredByModule[module] or {} do
		if folderOf(required) ~= folderOf(module) then
			addOnce(requiredByFolder, folderOf(module), folderOf(required))
			if not isMain(module) then
				addOnce(requiredByFolderWithoutMain, folderOf(module), folderOf(required))
			end
		end
	end
end
table.sort(folders)

print("What requires what in " .. SOURCE .. ", read from the code.\n")
printRequires("Folders", folders, requiredByFolder)
printRequires("Modules", modules, requiredByModule)

-- Prints whether a rule holds, and records it as a problem if it does not.
local function rule(holds: boolean, saying: string, detail: string?)
	if holds then
		print("ok    " .. saying)
	else
		print("FAIL  " .. saying .. (if detail ~= nil then ": " .. detail else ""))
		table.insert(problems, saying)
	end
end

local leavesShared = {}
local crossesSides = {}
for _, module in modules do
	for _, required in requiredByModule[module] or {} do
		local from, to = sideOf(module), sideOf(required)
		if from == "shared" and to ~= "shared" then
			table.insert(leavesShared, module .. " requires " .. required)
		elseif from ~= to and to ~= "shared" then
			table.insert(crossesSides, module .. " requires " .. required)
		end
	end
end
rule(#leavesShared == 0, "nothing in shared requires the server or the client", table.concat(leavesShared, "; "))
rule(#crossesSides == 0, "the server and the client require nothing from each other", table.concat(crossesSides, "; "))

local moduleLoop = findLoop(requiredByModule)
rule(
	moduleLoop == nil,
	"no module requires itself through other modules",
	if moduleLoop ~= nil then table.concat(moduleLoop, " requires ") else nil
)
local folderLoop = findLoop(requiredByFolderWithoutMain)
rule(
	folderLoop == nil,
	"no folder requires itself through other folders, the two Main scripts left out",
	if folderLoop ~= nil then table.concat(folderLoop, " requires ") else nil
)

if #problems > 0 then
	print("")
	for _, problem in problems do
		print(problem)
	end
	process.exit(1)
end
