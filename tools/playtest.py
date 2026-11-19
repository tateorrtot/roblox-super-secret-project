"""Plays the game in Roblox Studio by itself and checks what happens: the end-to-end test of the
Roblox side, which the tests in tests/ cannot reach.

Run it from the repository root, with Studio open on the place and in Edit mode:

    python tools/playtest.py

It copies src/ into the place, starts a play test, and drives the test character with keys, clicks
and walking: the hotbar, the inventory screen, dropping and picking up, the crate, and placing,
using and hitting on the plot. After each step it looks at what a player would see (the slots on
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
	outsideX = math.max(8, panel.AbsolutePosition.X - 40),
	outsideY = panel.AbsolutePosition.Y + 120,
	hotbar = {},
	pack = {},
	other = {},
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
			table.insert(world.placed, { item = part.Name, id = id, x = part.Position.X, y = part.Position.Y, z = part.Position.Z })
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

PANEL = 'LocalPlayer.PlayerGui.Inventory.Panel.'


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
        check(view['held'] == 'Log' and view['hotbar'].get('s3') == 'Log 3', 'Q drops one of what is in hand', view['hotbar'])
        check(self.ground('log') == [1], 'and it lies on the ground')
        apples = [entry for entry in self.world()['ground'] if entry['item'] == 'apple'][0]
        time.sleep(1.6)
        self.walk_to(apples['x'], apples['z'])
        time.sleep(0.6)
        view = self.view()
        check(view['hotbar'].get('s1') == 'Apple 4' and view['hotbar'].get('s3') == 'Log 4',
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

        # Out of reach.
        self.walk_to(crate['x'] - 30, crate['z'] + 30)
        point, on_screen = self.screen_point(crate['x'], crate['y'], crate['z'])
        if on_screen:
            self.click(point)
            check(not self.view()['open'], 'a click on a crate that is out of reach does nothing')


if __name__ == '__main__':
    Playtest().run()
