--!nocheck
--[=[
	Runs every check on the library and says which ones failed.

	Run it from the library's root:

		lune run tools/check

	The checks, in order:
	1. Format: StyLua finds nothing to change in `src`, `tests`, `demos` and `tools`.
	2. Lint: Selene finds nothing in those folders.
	3. Types: everything in `src`, `tests` and `demos` passes the strict type
	   checker with no Roblox globals available. That is what keeps a library
	   free of engine calls. The check uses Luau's new type solver, because only
	   the new solver understands read-only fields.
	4. Requires: every string that a file in `src` passes to `require` starts
	   with `./`. A library requires nothing outside its own folder, and a file
	   never requires a file above its own folder, so a string that starts with
	   `../`, contains `/../` or starts with `@` fails.
	5. Notes: `tools/notes.py` finds that every path that `CLAUDE.md`,
	   `README.md` and the files in `docs` mention exists, and that they have not
	   grown too long to read at a glance.
	6. Comments: `tools/comments.py` finds that every module, public function,
	   exported type, field of an exported type and constant in `src` has a
	   comment, and that no comment uses a word the rules ban.
	7. Tests: every file in `tests` whose name ends in `.test.luau` runs and
	   exits without an error.
	8. Demos: every file in `demos` runs and exits without an error.

	A library with no module yet passes.

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

-- Returns the lines that name why a string passed to `require` in a file of `src` leaves the file's own folder.
local function findRequireFaults(path: string): { string }
	local faults = {}
	local number = 0
	for line in string.gmatch(fs.readFile(path) .. "\n", "([^\n]*)\n") do
		number += 1
		for _, quote in { '"', "'" } do
			for target in string.gmatch(line, "require%(%s*" .. quote .. "([^" .. quote .. "]*)" .. quote) do
				if string.sub(target, 1, 2) ~= "./" or string.find(target, "/../", 1, true) then
					table.insert(
						faults,
						string.format(
							'%s:%d: require("%s") leaves the library or goes above its own folder',
							path,
							number,
							target
						)
					)
				end
			end
		end
	end
	return faults
end

local directories = {}
for _, directory in { "src", "tests", "demos", "tools" } do
	if fs.isDir(directory) then
		table.insert(directories, directory)
	end
end

run("format", "stylua", { "--check", table.unpack(directories) })
run("lint", "selene", { "--quiet", table.unpack(directories) })

local plain = {}
for _, directory in { "src", "tests", "demos" } do
	for _, file in findFiles(directory, ".luau") do
		table.insert(plain, file)
	end
end
if #plain > 0 then
	run("types", "luau-lsp", { "analyze", "--platform=standard", "--flag:LuauSolverV2=true", table.unpack(plain) })
else
	print("skip  types: nothing in src, tests or demos yet")
end

local requireFaults = {}
for _, file in findFiles("src", ".luau") do
	for _, fault in findRequireFaults(file) do
		table.insert(requireFaults, fault)
	end
end
if #requireFaults == 0 then
	print("ok    requires")
else
	print("FAIL  requires")
	print(table.concat(requireFaults, "\n"))
	table.insert(failures, "requires")
end

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
