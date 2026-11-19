"""Plays the game in Roblox Studio by itself and checks what happens: the end-to-end test of the
Roblox side, which the tests in tests/ cannot reach.

Run it from the repository root, with Studio open on the place and in Edit mode:

    python tools/playtest.py

It copies src/ into the place, starts a play test, and drives the test character with keys, clicks
and walking: the hotbar, the inventory screen, dropping and picking up, the crate, and placing,
using and hitting on the plot, and baking an apple in the stove. After each step it looks at what a player would see (the slots on
the screen) and at what is in the world (the blocks on the ground and on the plot). It prints one
line for each thing that should be true, and exits with code 1 if any was not.

It needs a mouse-and-keyboard window: nothing here tries touch. It takes a minute or two, and it
stops the play test when it is done. While it runs, PlaceholderWorld drops nothing on the ground,
so that the test knows exactly what lies there.
"""
import json, os, sys, time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import studio as studio_tool  # noqa: E402

CLIENT_VIEW = '''
local HttpService = game:GetService("HttpService")
local gui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
local hotbarGui = gui and gui:FindFirstChild("Hotbar")
local inventoryGui = gui and gui:FindFirstChild("Inventory")
local character = game:GetService("Players").LocalPlayer.Character
if hotbarGui == nil or inventoryGui == nil or character == nil or character:FindFirstChild("HumanoidRootPart") == nil then
	return HttpService:JSONEncode({ ready = false })
end
local function iconText(icon)
	if icon == nil or not icon.Visible then
		return ""
	end
	local count = icon.Count.Text
	return if count == "" then icon.ItemName.Text else icon.ItemName.Text .. " " .. count
end
local panel = inventoryGui.Panel
local view = {
	ready = true,
	open = inventoryGui.Enabled,
	hotbarShown = hotbarGui.Enabled,
	held = hotbarGui.Row.Held.Text,
	title = panel.Title.Text,
	carried = iconText(inventoryGui.Carried:FindFirstChild("StackIcon")),
	stationShown = panel.FireGauge.Visible,
	fire = panel.FireGauge.Fill.Size.Y.Scale,
	work = panel.WorkGauge.Fill.Size.X.Scale,
	outsideX = math.max(8, panel.AbsolutePosition.X - 40),
	outsideY = panel.AbsolutePosition.Y + 120,
	hotbar = {},
	pack = {},
	other = {},
	marked = {},
}
for _, child in hotbarGui.Row:GetChildren() do
	local slot = string.match(child.Name, "^Slot(%d+)$")
	if slot then
		view.hotbar["s" .. slot] = iconText(child:FindFirstChild("StackIcon"))
	end
end
for _, child in panel:GetChildren() do
	local side, slot = string.match(child.Name, "^(%a+)Slot(%d+)$")
	if side == "Pack" then
		view.pack["s" .. slot] = iconText(child:FindFirstChild("StackIcon"))
	elseif side == "Other" then
		view.other["s" .. slot] = iconText(child:FindFirstChild("StackIcon"))
	end
	-- A slot with the bright, thick edge is one that is marked, as the slots of a drag are.
	local edge = child:FindFirstChildOfClass("UIStroke")
	if side ~= nil and edge ~= nil and edge.Thickness == 3 then
		table.insert(view.marked, child.Name)
	end
end
return HttpService:JSONEncode(view)
'''

SERVER_WORLD = '''
local HttpService = game:GetService("HttpService")
local world = { ground = {}, placed = {}, players = {} }
local groundFolder = workspace:FindFirstChild("GroundItems")
if groundFolder then
	for _, part in groundFolder:GetChildren() do
		table.insert(world.ground, { item = part.Name, count = part:GetAttribute("count"), x = part.Position.X, z = part.Position.Z })
	end
end
local placeholder = workspace:FindFirstChild("PlaceholderWorld")
local placedFolder = placeholder and placeholder:FindFirstChild("PlacedItems")
if placedFolder then
	for _, part in placedFolder:GetChildren() do
		local id = part:GetAttribute("placedId")
		if id ~= nil then
			table.insert(world.placed, { item = part.Name, id = id, x = part.Position.X, y = part.Position.Y, z = part.Position.Z, burning = part:GetAttribute("burning") })
		end
	end
end
for _, player in game:GetService("Players"):GetPlayers() do
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		table.insert(world.players, { x = root.Position.X, z = root.Position.Z })
	end
end
return HttpService:JSONEncode(world)
'''

SCREEN_POINT = '''
local point, onScreen = workspace.CurrentCamera:WorldToScreenPoint(Vector3.new(%f, %f, %f))
return string.format("%%d,%%d,%%s", point.X, point.Y, tostring(onScreen))
'''

# Finds a bare tile of the plot that the test character can reach and the mouse can click: in the
# middle of the window, clear of the hotbar. It asks the game's own PlotPointer what each point is over.
FIND_TILE = '''
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlotPointer = require(player.PlayerScripts.Client.world.PlotPointer)
local root = player.Character.HumanoidRootPart
local inset = game:GetService("GuiService"):GetGuiInset()
local size = workspace.CurrentCamera.ViewportSize
for y = math.floor(size.Y * 0.45), math.floor(size.Y * 0.75), 20 do
	for x = math.floor(size.X * 0.15), math.floor(size.X * 0.85), 20 do
		local pointed = PlotPointer.at(Vector2.new(x, y))
		if pointed ~= nil and pointed.kind == "tile" then
			local away = pointed.center - root.Position
			local distance = Vector3.new(away.X, 0, away.Z).Magnitude
			if distance > 5 and distance < 13 then
				return string.format("%d,%d,%f,%f", x - inset.X, y - inset.Y, pointed.center.X, pointed.center.Z)
			end
		end
	end
end
return "none"
'''

# Sends every request there is with nonsense, as a tampered machine might, and says how many were sent.
JUNK_REQUESTS = '''
local remotes = game:GetService("ReplicatedStorage").Remotes
local Messages = require(game:GetService("ReplicatedStorage").Shared.Messages)
local junk = { 0, -1, 0.5, 1e300, 0 / 0, math.huge, "", "pack", "other", "left", true, false, {}, { 1, 2 }, { side = "pack" } }
local sent = 0
for _, name in Messages.toServer do
	local remote = remotes[name]
	remote:FireServer()
	sent += 1
	for first = 1, #junk do
		remote:FireServer(junk[first], junk[(first * 7) % #junk + 1], junk[(first * 3) % #junk + 1])
		sent += 1
	end
	for id = 1, 6 do
		remote:FireServer(id * 1000, id * 1000, id)
		sent += 1
	end
end
task.wait(1)
return tostring(sent)
'''

# Asks the server outright to use or to hit a placed item, whatever the player's own machine thinks of it.
ASK_OUTRIGHT = '''
game:GetService("ReplicatedStorage").Remotes.%s:FireServer(%d)
task.wait(0.5)
return "asked"
'''

PANEL = 'LocalPlayer.PlayerGui.Inventory.Panel.'


# How many items a slot's text stands for: "Log 14" is 14, "Log" is 1, and "" is 0.
def count_of(text):
    if text == '':
        return 0
    last = text.split(' ')[-1]
    return int(last) if last.isdigit() else 1


class Playtest:
    def __init__(self):
        self.studio = studio_tool.Studio()
        self.passed = 0
        self.failed = 0

    # Counts one check. `seen` is what was really there, printed when the check fails.
    def check(self, condition, what, seen=None):
        if condition:
            self.passed += 1
            print('ok    ' + what)
        else:
            self.failed += 1
            print('FAIL  ' + what)
            if seen is not None:
                print('        saw: ' + json.dumps(seen, sort_keys=True))

    # What a player sees: the slots of the hotbar and the inventory screen, as "Name count" or "".
    def view(self):
        view = json.loads(self.studio.luau(CLIENT_VIEW, 'Client'))
        for name in ('hotbar', 'pack', 'other'):
            if not isinstance(view.get(name), dict):
                view[name] = {}
        return view

    # What is in the world: the blocks on the ground and on the plot, and where the players stand.
    def world(self):
        world = json.loads(self.studio.luau(SERVER_WORLD, 'Server'))
        for name in ('ground', 'placed', 'players'):
            if not isinstance(world.get(name), list):
                world[name] = []
        return world

    def ground(self, item):
        return sorted(entry['count'] for entry in self.world()['ground'] if entry['item'] == item)

    # How far the test character stands from a placed item, along the ground, in studs.
    def distance_to(self, placed):
        player = self.world()['players'][0]
        return ((player['x'] - placed['x']) ** 2 + (player['z'] - placed['z']) ** 2) ** 0.5

    def keys(self, *keys):
        actions = []
        for key in keys:
            actions += [{'action': 'keyPress', 'key_code': key}, {'action': 'wait', 'wait_time_ms': 250}]
        self.studio.call('user_keyboard_input', {'datamodel_type': 'Client', 'actions': actions})

    def hold(self, key, down):
        action = {'action': 'keyDown' if down else 'keyUp', 'key_code': key}
        self.studio.call('user_keyboard_input', {'datamodel_type': 'Client', 'actions': [action]})

    def click(self, where, button='left'):
        move = {'action': 'moveTo'}
        if isinstance(where, tuple):
            move['x'], move['y'] = where
        else:
            move['instance_path'] = where
        self.studio.call('user_mouse_input', {'datamodel_type': 'Client', 'actions': [
            move, {'action': 'wait', 'wait_time_ms': 150},
            {'action': 'mouseButtonClick', 'mouse_button': button}, {'action': 'wait', 'wait_time_ms': 350}]})

    def double_click(self, where):
        self.studio.call('user_mouse_input', {'datamodel_type': 'Client', 'actions': [
            {'action': 'moveTo', 'instance_path': where}, {'action': 'wait', 'wait_time_ms': 150},
            {'action': 'mouseButtonClick', 'mouse_button': 'left'},
            {'action': 'mouseButtonClick', 'mouse_button': 'left'}, {'action': 'wait', 'wait_time_ms': 350}]})

    # Presses a mouse button on the first of some slots and moves the pointer onto the others with it held.
    def press_and_drag(self, slots, button='left'):
        actions = [{'action': 'moveTo', 'instance_path': PANEL + slots[0]}, {'action': 'wait', 'wait_time_ms': 150},
                   {'action': 'mouseButtonDown', 'mouse_button': button}, {'action': 'wait', 'wait_time_ms': 150}]
        for slot in slots[1:]:
            actions += [{'action': 'moveTo', 'instance_path': PANEL + slot}, {'action': 'wait', 'wait_time_ms': 150}]
        self.studio.call('user_mouse_input', {'datamodel_type': 'Client', 'actions': actions})

    # Lets the mouse button go over a slot. The mouse tool wants to be told where the pointer is first.
    def let_go(self, slot, button='left'):
        self.studio.call('user_mouse_input', {'datamodel_type': 'Client', 'actions': [
            {'action': 'moveTo', 'instance_path': PANEL + slot}, {'action': 'wait', 'wait_time_ms': 100},
            {'action': 'mouseButtonUp', 'mouse_button': button}, {'action': 'wait', 'wait_time_ms': 350}]})

    def hover(self, where):
        self.studio.call('user_mouse_input', {'datamodel_type': 'Client', 'actions': [
            {'action': 'moveTo', 'instance_path': where}, {'action': 'wait', 'wait_time_ms': 250}]})

    def walk_to(self, x, z):
        self.studio.call('character_navigation', {'datamodel_type': 'Client', 'x': x, 'y': 1, 'z': z, 'speed_multiplier': 2})

    # Where a point in the world is on the screen, for the mouse.
    def screen_point(self, x, y, z):
        parts = self.studio.luau(SCREEN_POINT % (x, y, z), 'Client').strip().split(',')
        return (float(parts[0]), float(parts[1])), parts[2] == 'true'

    def wait_until_ready(self):
        for _ in range(40):
            if self.view().get('ready'):
                return True
            time.sleep(0.5)
        return False

    def run(self):
        studio = self.studio
        state = ' '.join(studio.call('get_studio_state'))
        if 'Mode: Edit' not in state:
            raise SystemExit('Studio must be in Edit mode to start; it says: ' + state)
        studio_tool.sync(studio)
        studio.luau('workspace:SetAttribute("PlaceholderRestock", false) return "restock off"')
        try:
            studio.call('start_stop_play', {'is_start': True})
            self.check(self.wait_until_ready(), 'the game starts and the screens are made')
            self.steps()
            console = '\n'.join(studio.call('get_console_output'))
            errors = [line for line in console.splitlines()
                      if ('Error' in line or 'error' in line or 'Stack Begin' in line or 'attempt to' in line)
                      and 'ContentId' not in line and 'DataStore' not in line]
            self.check(not errors, 'nothing in the Output window is an error' + ''.join('\n        ' + line for line in errors[:8]))
        finally:
            try:
                studio.call('start_stop_play', {'is_start': False})
                studio.luau('workspace:SetAttribute("PlaceholderRestock", nil) return "restock on"')
            finally:
                studio.close()
        print('\nPlay test: %d passed, %d failed' % (self.passed, self.failed))
        if self.failed:
            raise SystemExit(1)

    def steps(self):
        check = self.check

        view = self.view()
        check(view['hotbar'].get('s1') == 'Apple 4' and view['hotbar'].get('s2') == 'Log 16'
              and view['hotbar'].get('s3') == 'Log 4' and view['hotbar'].get('s4') == 'Crate',
              'the hotbar shows what a new player is given: ' + json.dumps(view['hotbar'], sort_keys=True))
        check(view['held'] == 'Apple' and view['hotbarShown'] and not view['open'], 'slot 1 is in hand, and no screen is open')
        world = self.world()
        check(world['ground'] == [], 'nothing lies on the ground while the placeholder restock is off')
        check(sorted(entry['item'] for entry in world['placed']) == ['crate', 'stove'], 'a crate and a stove stand on the plot')

        # The pack, by mouse.
        self.keys('E')
        view = self.view()
        check(view['open'] and view['title'] == 'Pack' and not view['hotbarShown'], 'E opens the pack, and the hotbar is put away')
        self.hold('LeftShift', True)
        self.click(PANEL + 'PackSlot1')
        view = self.view()
        check(view['pack'].get('s1') == '' and view['pack'].get('s10') == 'Apple 4',
              'Shift and a click sends a hotbar stack to the rest of the pack', view['pack'])
        self.click(PANEL + 'PackSlot10')
        self.hold('LeftShift', False)
        view = self.view()
        check(view['pack'].get('s1') == 'Apple 4' and view['pack'].get('s10') == '', 'and sends it back to the hotbar', view['pack'])
        self.hover(PANEL + 'PackSlot2')
        self.keys('Five')
        view = self.view()
        check(view['pack'].get('s5') == 'Log 16' and view['pack'].get('s2') == '',
              'a number key over a slot swaps it with that hotbar slot', view['pack'])
        self.keys('Five')
        view = self.view()
        check(view['pack'].get('s2') == 'Log 16' and view['pack'].get('s5') == '', 'and again swaps it back', view['pack'])
        self.click(PANEL + 'PackSlot2')
        view = self.view()
        check(view['carried'] == 'Log 16' and view['pack'].get('s2') == '', 'a left click picks up the whole stack')
        self.click(PANEL + 'PackSlot12', 'right')
        self.click(PANEL + 'PackSlot12', 'right')
        view = self.view()
        check(view['pack'].get('s12') == 'Log 2' and view['carried'] == 'Log 14', 'two right clicks put down one each')
        self.click(PANEL + 'PackSlot20')
        view = self.view()
        check(view['pack'].get('s20') == 'Log 14' and view['carried'] == '', 'a left click puts down the rest')
        self.click(PANEL + 'PackSlot1', 'right')
        view = self.view()
        check(view['carried'] == 'Apple 2' and view['pack'].get('s1') == 'Apple 2', 'a right click picks up half')
        self.click(PANEL + 'PackSlot3')
        view = self.view()
        check(view['carried'] == 'Log 4' and view['pack'].get('s3') == 'Apple 2', 'a click on a different item swaps the stacks')
        self.click(PANEL + 'PackSlot3')
        self.click(PANEL + 'PackSlot1')
        view = self.view()
        check(view['pack'].get('s1') == 'Apple 4' and view['pack'].get('s3') == 'Log 4' and view['carried'] == '',
              'swapped back, and a stack put on its own kind tops it up', view['pack'])
        self.hover(PANEL + 'PackSlot3')
        self.keys('Q')
        check(self.view()['pack'].get('s3') == 'Log 3' and self.ground('log') == [1], 'Q over a slot drops one from it',
              self.world()['ground'])
        self.hover(PANEL + 'PackSlot12')
        self.hold('LeftControl', True)
        self.keys('Q')
        self.hold('LeftControl', False)
        check(self.view()['pack'].get('s12') == '' and self.ground('log') == [3],
              'Ctrl and Q over a slot drops the whole stack from it, and it joins the log on the ground', self.world()['ground'])
        self.click(PANEL + 'PackSlot1', 'right')

        # Dropping from the screen.
        outside = (view['outsideX'], view['outsideY'])
        self.click(outside, 'right')
        check(self.view()['carried'] == 'Apple' and self.ground('apple') == [1], 'a right click outside the screen drops one',
              self.world()['ground'])
        self.click(outside)
        check(self.view()['carried'] == '' and self.ground('apple') == [2], 'a left click outside drops the rest, and it joins the first',
              self.world()['ground'])
        self.keys('E')
        view = self.view()
        check(not view['open'] and view['hotbarShown'], 'E closes the pack, and the hotbar comes back')

        # The hotbar, dropping with Q, and picking up by walking.
        self.keys('Three', 'Q')
        view = self.view()
        check(view['held'] == 'Log' and view['hotbar'].get('s3') == 'Log 2', 'Q drops one of what is in hand', view['hotbar'])
        check(self.ground('log') == [4], 'and it joins the logs already on the ground')
        apples = [entry for entry in self.world()['ground'] if entry['item'] == 'apple'][0]
        time.sleep(1.6)
        self.walk_to(apples['x'], apples['z'])
        time.sleep(0.6)
        view = self.view()
        check(view['hotbar'].get('s1') == 'Apple 4' and view['hotbar'].get('s3') == 'Log 6',
              'walking over them picks the stacks up, into the stacks of their kind', view['hotbar'])
        check(self.world()['ground'] == [], 'and nothing is left on the ground')

        # The crate that stands on the plot.
        crate = [entry for entry in self.world()['placed'] if entry['item'] == 'crate'][0]
        self.walk_to(crate['x'] - 7, crate['z'] + 5)
        point, on_screen = self.screen_point(crate['x'], crate['y'], crate['z'])
        check(on_screen, 'the crate is in view from beside it')
        self.click(point)
        view = self.view()
        check(view['open'] and view['title'] == 'Crate', 'a click on the crate opens it')
        check(view['other'].get('s1') == 'Cheese 8' and view['other'].get('s3') == 'Crystal 32' and len(view['other']) == 27,
              'its 27 slots show what is in it')
        self.hold('LeftShift', True)
        self.click(PANEL + 'OtherSlot1')
        self.hold('LeftShift', False)
        view = self.view()
        check(view['other'].get('s1') == '' and view['pack'].get('s2') == 'Cheese 8', 'Shift and a click sends a stack to the pack',
              view['pack'])
        self.keys('E')

        # Placing, using and hitting on the plot.
        self.keys('Four')
        found = self.studio.luau(FIND_TILE, 'Client').strip()
        check(found != 'none' and self.view()['held'] == 'Crate', 'with the crate in hand, a bare tile is in view and in reach', found)
        if found == 'none':
            return
        numbers = [float(part) for part in found.split(',')]
        point, tile_x, tile_z = (numbers[0], numbers[1]), numbers[2], numbers[3]
        self.click(point)
        placed = [entry for entry in self.world()['placed'] if abs(entry['x'] - tile_x) < 0.1 and abs(entry['z'] - tile_z) < 0.1]
        check(len(placed) == 1 and placed[0]['item'] == 'crate', 'a click on the tile places the crate there')
        check(self.view()['hotbar'].get('s4') == '', 'and it has left the hand')
        if placed:
            mine = placed[0]
            point, _ = self.screen_point(mine['x'], mine['y'], mine['z'])
            self.click(point)
            view = self.view()
            check(view['open'] and view['title'] == 'Crate' and all(text == '' for text in view['other'].values()),
                  'the placed crate opens, and holds nothing')
            self.hold('LeftShift', True)
            self.click(PANEL + 'PackSlot1')
            self.hold('LeftShift', False)
            check(self.view()['other'].get('s1') == 'Apple 4', 'a stack is sent into it', self.view()['other'].get('s1'))
            self.keys('E')
            point, _ = self.screen_point(mine['x'], mine['y'], mine['z'])
            self.click(point, 'right')
            world = self.world()
            check(all(entry['id'] != mine['id'] for entry in world['placed']), 'a right click knocks the crate off the plot')
            check(self.ground('crate') == [1] and self.ground('apple') == [4], 'it lies on the ground as an item, and so does what was in it',
                  world['ground'])

        # A double click gathers a kind: the first click picks a stack up, the second fills it.
        self.keys('E')
        before = self.view()['pack']
        logs = sum(count_of(text) for text in before.values() if text.startswith('Log'))
        check(before.get('s3', '').startswith('Log') and logs > count_of(before.get('s3', '')),
              'the pack holds logs in more than one slot', before)
        self.double_click(PANEL + 'PackSlot3')
        view = self.view()
        left = sum(count_of(text) for text in view['pack'].values() if text.startswith('Log'))
        check(count_of(view['carried']) == min(16, logs) and view['carried'].startswith('Log') and left == logs - min(16, logs),
              'a double click gathers the logs into the carried stack, up to a full stack',
              {'carried': view['carried'], 'pack': view['pack']})

        # A drag spreads the carried stack: one in each slot with the right button, equal shares with the left.
        carried = count_of(view['carried'])
        slots = ['s28', 's29', 's30']
        names = ['PackSlot28', 'PackSlot29', 'PackSlot30']
        check(carried >= 8 and all(view['pack'].get(slot) == '' for slot in slots + ['s31', 's32']),
              'logs are carried, and five slots of the pack hold nothing', {'carried': view['carried'], 'pack': view['pack']})
        # A drag that ends on the slot it began on is also a click there, as Roblox sees it. The click must do nothing more.
        self.press_and_drag(['PackSlot31', 'PackSlot32', 'PackSlot31'], 'right')
        self.let_go('PackSlot31', 'right')
        view = self.view()
        check(view['pack'].get('s31') == 'Log' and view['pack'].get('s32') == 'Log' and count_of(view['carried']) == carried - 2,
              'a right drag that ends on the slot it began on puts one in each slot, and no more',
              {'carried': view['carried'], 's31': view['pack'].get('s31'), 's32': view['pack'].get('s32')})
        carried = count_of(view['carried'])
        self.press_and_drag(names, 'right')
        marked = self.view().get('marked')
        check(isinstance(marked, list) and sorted(marked) == names, 'the slots dragged over are marked while the button is down', marked)
        self.let_go(names[-1], 'right')
        view = self.view()
        check(all(view['pack'].get(slot) == 'Log' for slot in slots) and count_of(view['carried']) == carried - 3,
              'a right drag puts one in each slot', {'carried': view['carried'], 'pack': view['pack']})
        check(not view.get('marked'), 'and the marks go when the button comes up', view.get('marked'))
        self.press_and_drag(names, 'left')
        self.let_go(names[-1], 'left')
        view = self.view()
        share, left_over = (carried - 3) // 3, (carried - 3) % 3
        check(all(count_of(view['pack'].get(slot, '')) == 1 + share for slot in slots) and count_of(view['carried']) == left_over,
              'a left drag spreads the rest in equal shares, and what is left over stays carried',
              {'carried': view['carried'], 'pack': view['pack']})
        self.keys('E')

        # Nonsense from a tampered machine.
        before = self.world()
        sent = self.studio.luau(JUNK_REQUESTS, 'Client').strip()
        after = self.world()
        check(sent.isdigit() and int(sent) > 200, 'every request is sent with nonsense, ' + sent + ' times in all', sent)
        check(sorted(entry['id'] for entry in before['placed']) == sorted(entry['id'] for entry in after['placed']),
              'and nothing on the plot has changed', after['placed'])
        self.keys('E')
        check(self.view().get('ready') and self.view()['open'], 'and the game still answers: E opens the pack', self.view())
        self.keys('E')

        # Out of reach. The crate is in view from about 20 studs away, and reach is 16.
        self.walk_to(crate['x'], crate['z'] + 20)
        away = self.distance_to(crate)
        point, on_screen = self.screen_point(crate['x'], crate['y'], crate['z'])
        check(on_screen and away > 16.5, 'the crate is in view from out of reach', {'studs away': away, 'at': point})
        self.click(point)
        check(not self.view()['open'], 'a click on it from there opens nothing')
        self.studio.luau(ASK_OUTRIGHT % ('usePlaced', crate['id']), 'Client')
        self.studio.luau(ASK_OUTRIGHT % ('hitPlaced', crate['id']), 'Client')
        check(not self.view()['open'] and any(entry['id'] == crate['id'] for entry in self.world()['placed']),
              'and nor does asking the server outright to use it and to hit it, as a tampered machine might')
        self.walk_to(crate['x'] - 7, crate['z'] + 5)
        self.studio.luau(ASK_OUTRIGHT % ('usePlaced', crate['id']), 'Client')
        view = self.view()
        check(view['open'] and view['title'] == 'Crate', 'the same request from within reach opens it',
              {'studs away': self.distance_to(crate), 'title': view['title']})
        self.keys('E')

        # The stove works as a furnace. The apples that spilled from the broken crate are picked up to bake.
        apples = [entry for entry in self.world()['ground'] if entry['item'] == 'apple']
        if apples:
            self.walk_to(apples[0]['x'], apples[0]['z'])
            time.sleep(0.6)
        stove = [entry for entry in self.world()['placed'] if entry['item'] == 'stove'][0]
        self.walk_to(stove['x'] + 5, stove['z'] + 8)
        point, on_screen = self.screen_point(stove['x'], stove['y'], stove['z'])
        check(on_screen, 'the stove is in view from beside it', point)
        self.click(point)
        view = self.view()
        check(view['open'] and view['title'] == 'Stove' and len(view['other']) == 3 and view['stationShown'],
              'a click on the stove opens its three slots, laid out as a furnace', {'title': view['title'], 'other': view['other']})
        apple_slot = next((slot for slot, text in view['pack'].items() if text.startswith('Apple')), None)
        # The biggest stack of logs: the stove takes one log into its fire at once, and the rest must still show as fuel.
        log_slots = [slot for slot, text in view['pack'].items() if text.startswith('Log')]
        log_slot = max(log_slots, key=lambda slot: count_of(view['pack'][slot])) if log_slots else None
        check(apple_slot is not None and log_slot is not None and count_of(view['pack'][log_slot]) >= 2,
              'the pack holds apples to bake and logs to burn', view['pack'])
        if apple_slot is None or log_slot is None:
            return
        self.hold('LeftShift', True)
        self.click(PANEL + 'PackSlot' + apple_slot[1:])
        self.click(PANEL + 'PackSlot' + log_slot[1:])
        self.hold('LeftShift', False)
        view = self.view()
        check(view['other'].get('s1', '').startswith('Apple') and view['other'].get('s2', '').startswith('Log'),
              'Shift and a click sends the apples to the top slot and the logs to the fuel slot', view['other'])
        time.sleep(7)
        view = self.view()
        check(view['other'].get('s3', '').startswith('Baked apple'), 'in a few seconds the stove turns out a baked apple', view['other'])
        check(view['fire'] > 0, 'its fire gauge shows fuel burning', view.get('fire'))
        lit = [entry for entry in self.world()['placed'] if entry['id'] == stove['id']][0]
        check(lit.get('burning') is True, 'and the stove in the world shows that it is lit', lit)
        self.click(PANEL + 'OtherSlot3')
        time.sleep(0.6)
        self.click(PANEL + 'OtherSlot3')
        carried = self.view()['carried']
        check(carried.startswith('Baked apple'), 'what it made can be taken out, and cannot be put back', carried)
        self.keys('E')
        check(not self.view()['open'], 'E closes the stove')


if __name__ == '__main__':
    Playtest().run()
