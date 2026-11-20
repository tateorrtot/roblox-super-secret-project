"""Talks to an open Roblox Studio through Studio's own connector (StudioMCP.exe), from a terminal.

Needs Python 3, and Roblox Studio open on a place with its MCP server enabled
(Studio: Assistant Settings, MCP Permissions). Run it from the repository root:

    python tools/studio.py state                 what Studio is doing (Edit or Play)
    python tools/studio.py sync                  copy src/ into the open place, as Rojo would
    python tools/studio.py run <file.luau>       run a Luau file in Studio and print what it returns
    python tools/studio.py run <file> Server     the same, in the running game's server (or Client)
    python tools/studio.py play | stop           start or stop a play test
    python tools/studio.py console               the Output window
    python tools/studio.py shot <file.jpg>       save a picture of the viewport (Studio sends a JPEG)
    python tools/studio.py key E Q One           press keys in the running game, in order
    python tools/studio.py click <where> [right] click in the running game; <where> is x,y on the
                                                 screen, or a path such as LocalPlayer.PlayerGui.Hotbar.Row.Slot3
    python tools/studio.py tools                 list every tool the connector offers
    python tools/studio.py call <tool> <json>    call any of them

`sync` mirrors the project file: src/shared goes to ReplicatedStorage.Shared, src/server to
ServerScriptService.Server, and src/client to StarterPlayer.StarterPlayerScripts.Client. A folder
becomes a Folder, `Name.luau` a ModuleScript, `Name.server.luau` a Script and `Name.client.luau` a
LocalScript. Everything under those three places is replaced, so the project folder stays the
only source of the code.
"""
import base64, io, json, os, queue, subprocess, sys, threading, time

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BAT = os.path.join(os.environ.get('LOCALAPPDATA', ''), 'Roblox', 'mcp.bat')
TIMEOUT = float(os.environ.get('STUDIO_TIMEOUT', '120'))
ATTACH_SECONDS = 10  # how long to wait for Studio to attach to a connector that has just started
MAPPING = [
    ('src/shared', ['ReplicatedStorage', 'Shared']),
    ('src/server', ['ServerScriptService', 'Server']),
    ('src/client', ['StarterPlayer', 'StarterPlayerScripts', 'Client']),
]


class Studio:
    def __init__(self):
        if not os.path.exists(BAT):
            raise SystemExit('Roblox Studio connector not found at ' + BAT)
        self.proc = subprocess.Popen(['cmd.exe', '/c', BAT], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                     stderr=subprocess.PIPE, cwd=os.path.dirname(BAT))
        self.lines = queue.Queue()
        self.errors = []
        threading.Thread(target=self._read_out, daemon=True).start()
        threading.Thread(target=self._read_err, daemon=True).start()
        self.next_id = 0
        self.request('initialize', {'protocolVersion': '2024-11-05', 'capabilities': {},
                                    'clientInfo': {'name': 'local-client', 'version': '1.0'}})
        self.send({'jsonrpc': '2.0', 'method': 'notifications/initialized'})
        self.studio_id = None

    def _read_out(self):
        for raw in iter(self.proc.stdout.readline, b''):
            self.lines.put(raw.decode('utf-8', 'replace').strip())
        self.lines.put(None)

    def _read_err(self):
        for raw in iter(self.proc.stderr.readline, b''):
            self.errors.append(raw.decode('utf-8', 'replace').rstrip())

    def send(self, message):
        self.proc.stdin.write((json.dumps(message) + '\n').encode('utf-8'))
        self.proc.stdin.flush()

    def request(self, method, params=None):
        self.next_id += 1
        message = {'jsonrpc': '2.0', 'id': self.next_id, 'method': method}
        if params is not None:
            message['params'] = params
        self.send(message)
        while True:
            try:
                line = self.lines.get(timeout=TIMEOUT)
            except queue.Empty:
                raise SystemExit('Studio did not answer %s within %.0f seconds' % (method, TIMEOUT))
            if line is None:
                raise SystemExit('the Studio connector closed: ' + ' | '.join(self.errors[-5:]))
            if not line.startswith('{'):
                continue
            answer = json.loads(line)
            if answer.get('id') == self.next_id:
                if 'error' in answer:
                    raise SystemExit('Studio refused %s: %s' % (method, json.dumps(answer['error'])))
                return answer.get('result')

    def wait_for_studio(self):
        """Returns the first Studio attached to the connector. Studio attaches a moment after the
        connector starts, so an empty answer is asked again for a few seconds before giving up."""
        deadline = time.time() + ATTACH_SECONDS
        while True:
            found = json.loads(self.call('list_roblox_studios', {}, needs_studio=False)[0]).get('studios', [])
            if found:
                return found[0]
            if time.time() > deadline:
                raise SystemExit('No Roblox Studio is connected. Open Studio on a place and enable its MCP server.')
            time.sleep(0.5)

    def call(self, tool, arguments=None, needs_studio=True):
        arguments = dict(arguments or {})
        if needs_studio and 'studio_id' not in arguments:
            if self.studio_id is None:
                self.studio_id = self.wait_for_studio()['id']
            arguments['studio_id'] = self.studio_id
        result = self.request('tools/call', {'name': tool, 'arguments': arguments})
        texts, images = [], []
        for part in result.get('content', []):
            if part.get('type') == 'text':
                texts.append(part['text'])
            elif part.get('type') == 'image':
                images.append(part.get('data', ''))
        if result.get('isError'):
            raise SystemExit('Studio tool %s failed: %s' % (tool, '\n'.join(texts)[:3000]))
        self.images = images
        return texts

    def luau(self, code, datamodel='Edit'):
        return '\n'.join(self.call('execute_luau', {'code': code, 'datamodel_type': datamodel}))

    def close(self):
        try:
            self.proc.stdin.close()
            self.proc.terminate()
        except Exception:
            pass


def collect(directory):
    """Returns every file to sync under one mapped directory, as (path parts, class name, source)."""
    found = []
    root = os.path.join(REPO, directory)
    for folder, _, files in os.walk(root):
        relative = os.path.relpath(folder, root).replace(os.sep, '/')
        parts = [] if relative == '.' else relative.split('/')
        for name in sorted(files):
            if not name.endswith('.luau'):
                continue
            stem, class_name = name[:-len('.luau')], 'ModuleScript'
            if stem.endswith('.server'):
                stem, class_name = stem[:-len('.server')], 'Script'
            elif stem.endswith('.client'):
                stem, class_name = stem[:-len('.client')], 'LocalScript'
            source = io.open(os.path.join(folder, name), encoding='utf-8').read()
            found.append((parts + [stem], class_name, source))
    return found


SYNC_LUAU = '''
local HttpService = game:GetService("HttpService")
local job = HttpService:JSONDecode(%s)
local parent = game:GetService(job.target[1])
for index = 2, #job.target - 1 do
	parent = parent:FindFirstChild(job.target[index]) or error("missing " .. job.target[index])
end
local rootName = job.target[#job.target]
local root = if #job.target == 1 then parent else nil
if #job.target > 1 then
	if job.reset then
		local old = parent:FindFirstChild(rootName)
		if old then
			old:Destroy()
		end
	end
	root = parent:FindFirstChild(rootName)
	if not root then
		root = Instance.new("Folder")
		root.Name = rootName
		root.Parent = parent
	end
end
local made = 0
for _, file in job.files do
	local folder = root
	for index = 1, #file.path - 1 do
		local nextFolder = folder:FindFirstChild(file.path[index])
		if not nextFolder then
			nextFolder = Instance.new("Folder")
			nextFolder.Name = file.path[index]
			nextFolder.Parent = folder
		end
		folder = nextFolder
	end
	local script = Instance.new(file.className)
	script.Name = file.path[#file.path]
	script.Source = file.source
	script.Parent = folder
	made += 1
end
return made
'''


def long_string(text):
    """A Luau long string literal holding `text` exactly."""
    level = 3
    while (']' + '=' * level + ']') in text:
        level += 1
    return '[' + '=' * level + '[' + text + ']' + '=' * level + ']'


def sync(studio):
    total = 0
    for directory, target in MAPPING:
        files = collect(directory)
        batches = [files[i:i + 6] for i in range(0, len(files), 6)] or [[]]
        for number, batch in enumerate(batches):
            job = {'target': target, 'reset': number == 0,
                   'files': [{'path': path, 'className': class_name, 'source': source} for path, class_name, source in batch]}
            made = studio.luau(SYNC_LUAU % long_string(json.dumps(job)))
            total += int(float(made or 0))
        print('%-12s -> %s: %d scripts' % (directory, '.'.join(target), len(files)))
    print('synced %d scripts into the open place' % total)


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return
    command = sys.argv[1]
    studio = Studio()
    try:
        if command == 'tools':
            for tool in studio.request('tools/list').get('tools', []):
                print('%-28s %s' % (tool['name'], ' '.join((tool.get('description') or '').split())[:130]))
        elif command == 'state':
            print('\n'.join(studio.call('get_studio_state')))
        elif command == 'sync':
            sync(studio)
        elif command == 'run':
            code = io.open(sys.argv[2], encoding='utf-8').read()
            print(studio.luau(code, sys.argv[3] if len(sys.argv) > 3 else 'Edit'))
        elif command in ('play', 'stop'):
            print('\n'.join(studio.call('start_stop_play', {'is_start': command == 'play'})))
        elif command == 'console':
            print('\n'.join(studio.call('get_console_output')))
        elif command == 'shot':
            texts = studio.call('screen_capture', {'capture_id': 'ScreenCapture_1'})
            if studio.images:
                with open(sys.argv[2], 'wb') as out:
                    out.write(base64.b64decode(studio.images[0]))
                print('saved', sys.argv[2])
            else:
                print('no picture came back:', '\n'.join(texts)[:500])
        elif command == 'key':
            actions = []
            for key in sys.argv[2:]:
                actions += [{'action': 'keyPress', 'key_code': key}, {'action': 'wait', 'wait_time_ms': 150}]
            print(' '.join(studio.call('user_keyboard_input', {'datamodel_type': 'Client', 'actions': actions})))
        elif command == 'click':
            where, button = sys.argv[2], (sys.argv[3] if len(sys.argv) > 3 else 'left')
            move = {'action': 'moveTo'}
            if where.replace(',', '').replace('.', '').isdigit():
                move['x'], move['y'] = [float(part) for part in where.split(',')]
            else:
                move['instance_path'] = where
            actions = [move, {'action': 'wait', 'wait_time_ms': 100},
                       {'action': 'mouseButtonClick', 'mouse_button': button}, {'action': 'wait', 'wait_time_ms': 150}]
            print(' '.join(studio.call('user_mouse_input', {'datamodel_type': 'Client', 'actions': actions})))
        elif command == 'call':
            arguments = json.loads(sys.argv[3]) if len(sys.argv) > 3 else {}
            print('\n'.join(studio.call(sys.argv[2], arguments, needs_studio=sys.argv[2] != 'list_roblox_studios')))
            for index, image in enumerate(getattr(studio, 'images', [])):
                print('[image %d: %d bytes of base64]' % (index + 1, len(image)))
        else:
            print(__doc__)
    finally:
        studio.close()


if __name__ == '__main__':
    main()
