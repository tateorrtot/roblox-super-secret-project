--!strict
--- The RemoteEvents that the server and the players' machines talk through, on a player's side.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Messages = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("requests"):WaitForChild("Messages"))

local Remotes = {}

--- Waits until the server has made the RemoteEvents, one for each name in Messages, and returns
--- them by name. Reading a name that no message has fails.
function Remotes.find(): { [string]: RemoteEvent }
	local folder = ReplicatedStorage:WaitForChild("Remotes")
	local remotes: { [string]: RemoteEvent } = {}
	for _, names in { Messages.toServer, Messages.toClient } do
		for _, name in names do
			remotes[name] = folder:WaitForChild(name) :: RemoteEvent
		end
	end
	return setmetatable(remotes, {
		__index = function(_, name)
			error(`no message is called "{name}"`, 2)
		end,
	}) :: any
end

return Remotes
