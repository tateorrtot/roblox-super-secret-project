--!strict
--- Makes the RemoteEvents that the server and the clients talk through.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Messages = require(ReplicatedStorage:WaitForChild("Shared").requests.Messages)

local Remotes = {}

--- Makes one RemoteEvent for each name in `Messages.toServer` and `Messages.toClient`, puts them in
--- a Folder called `Remotes` in ReplicatedStorage, and returns them by name. Reading a name from
--- the table returned raises an error if no message has the name.
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
