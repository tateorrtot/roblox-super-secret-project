--!nocheck
--[=[
	Runs every check on the code and says which ones failed.

	Run it from the repository root:

		lune run tools/check

	The checks, in order:
	1. Format: StyLua finds nothing to change in `src`, `tests`, `demos` and `tools`.
	2. Lint: Selene finds nothing in those folders.
	3. Types: everything in `src/shared`, `tests` and `demos` passes the strict
	   type checker with no Roblox globals available. That is what keeps the
	   game's rules free of engine calls. The check uses Luau's new type
	   solver, because only the new solver understands read-only fields, which
	   this code uses for values that never change.
	4. Requires: `tools/requires` finds that what requires what in `src` runs
	   one way only. The rules require nothing from the server or the client,
	   and no folder or module requires itself through others.
	5. Members: `tools/members.py` finds that every function, constant, type
	   and message that `src` uses from its own modules exists. The server's
	   and the client's scripts are not type-checked, so this is what catches
	   a misspelt or renamed member there.
	6. Notes: `tools/notes.py` finds that every path the notes mention exists,
	   and that `CLAUDE.md` and the topic files under `docs` have not grown
	   too long to read at a glance.
	7. Comments: `tools/comments.py` finds that every module, public function,
	   exported type, field of an exported type and constant in `src` has a
	   comment, and that no comment uses a word the rules ban.
	8. Tests: every file in `tests` whose name ends in `.test.luau` runs and
	   exits without an error.
	9. Demos: every file in `demos` runs and exits without an error.

	The process exits with code 1 if any check failed.

	This file is not type-checked itself, because it uses Lune's own modules and
	their type definitions are not installed.
]=]
local fs = require("@lune/fs")
local process = require("@lune/process")

local failures = {}

-- Returns the paths of every file under `directory`, at any depth, whose name ends with `suffix`.
local function findFiles(directory: string, suffix: string): { string }
	local found = {}
	if not fs.isDir(directory) then
		return found
	end
	for _, name in fs.readDir(directory) do
		local path = directory .. "/" .. name
		if fs.isDir(path) then
			for _, deeper in findFiles(path, suffix) do
				table.insert(found, deeper)
			end
		elseif string.sub(name, -#suffix) == suffix then
			table.insert(found, path)
		end
	end
	table.sort(found)
	return found
end

-- Runs one program. Prints its output only when it fails, and records the failure under `label`.
local function run(label: string, program: string, arguments: { string }): boolean
	local result = process.exec(program, arguments)
	if result.ok then
		print("ok    " .. label)
		return true
	end
	print("FAIL  " .. label)
	local output = result.stdout .. result.stderr
	if output ~= "" then
		print(output)
	end
	table.insert(failures, label)
	return false
end

local directories = {}
for _, directory in { "src", "tests", "demos", "tools" } do
	if fs.isDir(directory) then
		table.insert(directories, directory)
	end
end

run("format", "stylua", { "--check", table.unpack(directories) })
run("lint", "selene", { "--quiet", table.unpack(directories) })

local plain = findFiles("src/shared", ".luau")
for _, directory in { "tests", "demos" } do
	for _, file in findFiles(directory, ".luau") do
		table.insert(plain, file)
	end
end
if #plain > 0 then
	run("types", "luau-lsp", { "analyze", "--platform=standard", "--flag:LuauSolverV2=true", table.unpack(plain) })
else
	print("skip  types: nothing in src/shared or tests yet")
end

run("requires", "lune", { "run", "tools/requires" })
run("members", "python", { "tools/members.py" })
run("notes", "python", { "tools/notes.py" })
run("comments", "python", { "tools/comments.py" })

local tests = findFiles("tests", ".test.luau")
for _, test in tests do
	local result = process.exec("lune", { "run", test })
	local lastLine = string.match(result.stdout, "([^\r\n]*)[\r\n]*$") or ""
	if result.ok then
		print("ok    test  " .. lastLine)
	else
		print("FAIL  test  " .. test)
		print(result.stdout .. result.stderr)
		table.insert(failures, test)
	end
end
if #tests == 0 then
	print("skip  tests: no file ending in .test.luau under tests")
end

for _, demo in findFiles("demos", ".luau") do
	run("demo  " .. demo, "lune", { "run", demo })
end

if #failures > 0 then
	print(string.format("\n%d check(s) failed: %s", #failures, table.concat(failures, "; ")))
	process.exit(1)
end
print("\nAll checks passed.")
