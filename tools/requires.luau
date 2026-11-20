--!nocheck
--[=[
	Prints what requires what in `src`, read from the code, and checks that
	the requires only run one way.

	Run it from the repository root:

		lune run tools/requires
		lune run tools/requires --chart

	It prints each folder with the folders it requires something from, then
	each module with the modules it requires, then the rules it checked:
	1. Nothing in `src/shared` requires the server or the client.
	2. The server and the client require nothing from each other.
	3. No module requires itself through other modules.
	4. No folder requires itself through other folders. The two `Main`
	   scripts are left out of this one: their job is to join every piece,
	   so they require from every folder.
	5. The chart in `docs/code/requires.svg` is the one the code gives now.

	The chart is a picture of the same thing: a box for each folder, with its
	modules listed inside, and a box for each of the two `Main` scripts. An
	arrow means requires. A require that the arrows already imply through
	another box is not drawn, so that the picture can be read. `--chart` writes
	the chart again. Without it the chart is only compared, and rule 5 fails
	if the code has changed since it was written.

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
local CHART = "docs/code/requires.svg"

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

-- The chart: a box for each folder and for each Main script, in rows, each row requiring only rows below it.

local TITLE_HEIGHT = 30
local LINE_HEIGHT = 16
local GAP_ACROSS = 28
local GAP_DOWN = 64
local MARGIN = 32
local BEND_WIDTH = 12
local CAPTION_WIDTH = 470
local CAPTION = {
	"An arrow means requires.",
	"A require that the arrows already imply through another box is not drawn.",
	"Grey is the rules, blue the server, green the player's machine.",
	"Drawn from the code by: lune run tools/requires --chart",
}
local FILLS = { shared = "#f4f3ee", server = "#e6f1fb", client = "#e1f5ee" }
local STROKES = { shared = "#8c8a82", server = "#378add", client = "#1d9e75" }

-- Returns the box a module is drawn in: its folder, or the module itself if it is a Main script.
local function boxOf(module: string): string
	return if isMain(module) then module else folderOf(module)
end

-- Returns whether `to` can be reached from `from` by following requires, not counting `from` itself.
local function reaches(requiredBy: { [string]: { string } }, from: string, to: string): boolean
	local seen = {}
	local function visit(name: string): boolean
		for _, required in requiredBy[name] or {} do
			local isNew = not seen[required]
			seen[required] = true
			if required == to or (isNew and visit(required)) then
				return true
			end
		end
		return false
	end
	return visit(from)
end

-- Returns the requires that no chain of other requires already implies, in order.
local function withoutImplied(names: { string }, requiredBy: { [string]: { string } }): { [string]: { string } }
	local kept = {}
	for _, name in names do
		kept[name] = {}
		for _, required in requiredBy[name] or {} do
			local implied = false
			for _, other in requiredBy[name] do
				implied = implied or (other ~= required and reaches(requiredBy, other, required))
			end
			if not implied then
				table.insert(kept[name], required)
			end
		end
		table.sort(kept[name])
	end
	return kept
end

-- Returns the row of each name: 0 for one that requires nothing, and otherwise one more than the
-- highest row among what it requires.
local function rowsOf(names: { string }, requiredBy: { [string]: { string } }): { [string]: number }
	local rows = {}
	local function rowOf(name: string): number
		if rows[name] == nil then
			rows[name] = 0
			local row = 0
			for _, required in requiredBy[name] or {} do
				row = math.max(row, rowOf(required) + 1)
			end
			rows[name] = row
		end
		return rows[name]
	end
	for _, name in names do
		rowOf(name)
	end
	return rows
end

local boxes = {}
local modulesInBox: { [string]: { string } } = {}
local requiredByBox: { [string]: { string } } = {}
for _, module in modules do
	local box = boxOf(module)
	if modulesInBox[box] == nil then
		modulesInBox[box] = {}
		table.insert(boxes, box)
	end
	if not isMain(module) then
		table.insert(modulesInBox[box], (string.match(module, "[^/]*$")))
	end
	for _, required in requiredByModule[module] or {} do
		if boxOf(required) ~= box then
			addOnce(requiredByBox, box, boxOf(required))
		end
	end
end
table.sort(boxes)

local drawnRequires = withoutImplied(boxes, requiredByBox)
local rowOfPlace = rowsOf(boxes, requiredByBox)

-- An arrow is the list of places it goes through, from the box that requires down to the box
-- required. Where the two are more than a row apart, it has a bend in each row between them, so
-- that it goes round the boxes of that row and not behind them.
local arrows: { { string } } = {}
local places = table.clone(boxes)
local isBend: { [string]: boolean } = {}
local joinedTo: { [string]: { string } } = {}
for _, box in boxes do
	for _, required in drawnRequires[box] do
		local through = { box }
		for row = rowOfPlace[box] - 1, rowOfPlace[required] + 1, -1 do
			local bend = string.format("%s to %s, row %d", box, required, row)
			isBend[bend] = true
			rowOfPlace[bend] = row
			table.insert(places, bend)
			table.insert(through, bend)
		end
		table.insert(through, required)
		table.insert(arrows, through)
		for index = 1, #through - 1 do
			addOnce(joinedTo, through[index], through[index + 1])
			addOnce(joinedTo, through[index + 1], through[index])
		end
	end
end

-- Returns how wide and how tall a place is drawn: a box by its name and its modules, and a bend as
-- a narrow gap with no height.
local function sizeOf(place: string): (number, number)
	if isBend[place] then
		return BEND_WIDTH, 0
	end
	local width = #place * 8
	for _, name in modulesInBox[place] do
		width = math.max(width, #name * 7)
	end
	return width + 28, TITLE_HEIGHT + #modulesInBox[place] * LINE_HEIGHT + 10
end

-- Returns the places of each row, the lowest row first.
local function placesByRow(): { { string } }
	local byRow = {}
	for _, place in places do
		local row = rowOfPlace[place] + 1
		byRow[row] = byRow[row] or {}
		table.insert(byRow[row], place)
	end
	return byRow
end

-- Returns how wide a row is drawn, with the gaps between its places.
local function widthOfRow(row: { string }): number
	local total = -GAP_ACROSS
	for _, place in row do
		total += sizeOf(place) + GAP_ACROSS
	end
	return total
end

-- Gives each place of a row its left edge, in the order the row lists them, with the row centred
-- on `middle`.
local function placeRow(row: { string }, middle: number, left: { [string]: number })
	local x = middle - widthOfRow(row) / 2
	for _, place in row do
		left[place] = x
		x += sizeOf(place) + GAP_ACROSS
	end
end

-- Returns the middle, across, of a place.
local function middleOf(place: string, left: { [string]: number }): number
	return left[place] + sizeOf(place) / 2
end

-- Returns the middle, across, of the places an arrow joins `place` to. A place no arrow touches
-- stays where it is.
local function middleOfJoined(place: string, left: { [string]: number }): number
	local joined = joinedTo[place] or {}
	if #joined == 0 then
		return middleOf(place, left)
	end
	local sum = 0
	for _, other in joined do
		sum += middleOf(other, left)
	end
	return sum / #joined
end

-- Returns where each place's left edge is, and how wide the whole chart is. Each row is put in the
-- order that keeps its places nearest to the places they are joined to, which keeps arrows short.
local function layOutAcross(byRow: { { string } }): ({ [string]: number }, number)
	local width = CAPTION_WIDTH
	for _, row in byRow do
		width = math.max(width, widthOfRow(row))
	end
	width += MARGIN * 2
	local left = {}
	for _, row in byRow do
		placeRow(row, width / 2, left)
	end
	for _ = 1, 6 do
		for _, row in byRow do
			local wanted = {}
			for _, place in row do
				wanted[place] = middleOfJoined(place, left)
			end
			table.sort(row, function(a: string, b: string): boolean
				return wanted[a] < wanted[b] or (wanted[a] == wanted[b] and a < b)
			end)
			placeRow(row, width / 2, left)
		end
	end
	return left, width
end

-- Returns where the top edge of each row is and how tall each row is, both by row number from 0,
-- and where the lowest row ends. The highest row is drawn at the top.
local function layOutDown(byRow: { { string } }): ({ [number]: number }, { [number]: number }, number)
	local top, tall = {}, {}
	local y = MARGIN
	for row = #byRow, 1, -1 do
		local tallest = 0
		for _, place in byRow[row] do
			local _, height = sizeOf(place)
			tallest = math.max(tallest, height)
		end
		top[row - 1], tall[row - 1] = y, tallest
		y += tallest + GAP_DOWN
	end
	return top, tall, y - GAP_DOWN
end

-- Returns the SVG for one box: its outline, its name, and its modules.
local function drawBox(box: string, x: number, y: number): string
	local width, height = sizeOf(box)
	local side = sideOf(box)
	local lines = {
		string.format(
			'<rect x="%.0f" y="%.0f" width="%.0f" height="%.0f" rx="5" fill="%s" stroke="%s"/>',
			x,
			y,
			width,
			height,
			FILLS[side],
			STROKES[side]
		),
		string.format(
			'<text x="%.0f" y="%.0f" font-size="14" font-weight="600" fill="#2c2c2a">%s</text>',
			x + 14,
			y + 20,
			box
		),
	}
	for index, name in modulesInBox[box] do
		local line = y + TITLE_HEIGHT + index * LINE_HEIGHT - 2
		table.insert(
			lines,
			string.format('<text x="%.0f" y="%.0f" font-size="12" fill="#5f5e5a">%s</text>', x + 14, line, name)
		)
	end
	return table.concat(lines, "\n")
end

-- Returns where along the edge of `box` its arrow to or from `other` meets it. `others` is every
-- place the box has an arrow to or from on that edge: the arrows are spread along the edge in the
-- order those places lie across the chart, so that they do not cross at the box.
local function meetingPoint(box: string, others: { string }, other: string, left: { [string]: number }): number
	local sorted = table.clone(others)
	table.sort(sorted, function(a: string, b: string): boolean
		local middleA, middleB = middleOf(a, left), middleOf(b, left)
		return middleA < middleB or (middleA == middleB and a < b)
	end)
	return left[box] + sizeOf(box) * table.find(sorted, other) / (#sorted + 1)
end

-- Returns the places joined to `place` by an arrow that lie in the row above it, or in the row below.
local function joinedInRow(place: string, above: boolean): { string }
	local found = {}
	for _, other in joinedTo[place] or {} do
		if (rowOfPlace[other] > rowOfPlace[place]) == above then
			table.insert(found, other)
		end
	end
	return found
end

-- Returns the SVG for one arrow, drawn as a curve from each place to the next and straight down
-- through each bend.
local function drawArrow(
	through: { string },
	left: { [string]: number },
	top: { [number]: number },
	tall: { [number]: number }
): string
	local first, last = through[1], through[#through]
	local _, firstHeight = sizeOf(first)
	local x = meetingPoint(first, joinedInRow(first, false), through[2], left)
	local y = top[rowOfPlace[first]] + firstHeight
	local path = { string.format("M%.0f %.0f", x, y) }
	for index = 2, #through do
		local place = through[index]
		local row = rowOfPlace[place]
		local nextX = if place == last
			then meetingPoint(last, joinedInRow(last, true), through[index - 1], left)
			else middleOf(place, left)
		local nextY = if place == last then top[row] - 3 else top[row]
		local bend = (nextY - y) * 0.45
		table.insert(
			path,
			string.format("C%.0f %.0f %.0f %.0f %.0f %.0f", x, y + bend, nextX, nextY - bend, nextX, nextY)
		)
		x, y = nextX, nextY
		if place ~= last then
			y += tall[row]
			table.insert(path, string.format("L%.0f %.0f", x, y))
		end
	end
	return string.format(
		'<path d="%s" fill="none" stroke="#73726c" stroke-width="1.2" marker-end="url(#arrow)"/>',
		table.concat(path, " ")
	)
end

-- Returns the whole chart as the text of an SVG file.
local function drawChart(): string
	local byRow = placesByRow()
	local left, width = layOutAcross(byRow)
	local top, tall, bottom = layOutDown(byRow)
	local height = bottom + 24 + #CAPTION * 18 + MARGIN / 2
	local parts = {
		string.format(
			'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %.0f %.0f" width="%.0f" height="%.0f" font-family="Segoe UI, Helvetica, Arial, sans-serif">',
			width,
			height,
			width,
			height
		),
		"<title>What requires what in src</title>",
		'<defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M1 1L9 5L1 9" fill="none" stroke="#73726c" stroke-width="1.5"/></marker></defs>',
		string.format('<rect width="%.0f" height="%.0f" fill="#ffffff"/>', width, height),
	}
	for _, through in arrows do
		table.insert(parts, drawArrow(through, left, top, tall))
	end
	for _, box in boxes do
		table.insert(parts, drawBox(box, left[box], top[rowOfPlace[box]]))
	end
	for index, line in CAPTION do
		table.insert(
			parts,
			string.format(
				'<text x="%.0f" y="%.0f" font-size="12" fill="#5f5e5a">%s</text>',
				MARGIN,
				bottom + 12 + index * 18,
				line
			)
		)
	end
	table.insert(parts, "</svg>")
	return table.concat(parts, "\n") .. "\n"
end

-- A loop in the requires has no rows, so there is no chart to draw until it is undone.
if moduleLoop ~= nil or folderLoop ~= nil then
	print("the chart is not drawn while something requires itself through others")
elseif table.find(process.args, "--chart") ~= nil then
	fs.writeFile(CHART, drawChart())
	print("wrote " .. CHART)
else
	local onDisk = if fs.isFile(CHART) then string.gsub(fs.readFile(CHART), "\r", "") else ""
	rule(
		onDisk == drawChart(),
		"the chart in " .. CHART .. " is the one the code gives now",
		"run: lune run tools/requires --chart"
	)
end

if #problems > 0 then
	print("")
	for _, problem in problems do
		print(problem)
	end
	process.exit(1)
end
