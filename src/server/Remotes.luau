--!strict
--- The RemoteEvents that the server and the players' machines talk through, on the server's side.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Messages = require(ReplicatedStorage:WaitForChild("Shared").requests.Messages)

local Remotes = {}

--- Makes one RemoteEvent for each name in Messages, in a folder called `Remotes` in
--- ReplicatedStorage, and returns them by name. Reading a name that no message has fails.
function Remotes.create(): { [string]: RemoteEvent }
	local folder = Instance.new("Folder")
	folder.Name = "Remotes"
	local remotes: { [string]: RemoteEvent } = {}
	for _, names in { Messages.toServer, Messages.toClient } do
		for _, name in names do
			local remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = folder
			remotes[name] = remote
		end
	end
	folder.Parent = ReplicatedStorage
	return setmetatable(remotes, {
		__index = function(_, name)
			error(`no message is called "{name}"`, 2)
		end,
	}) :: any
end

return Remotes
