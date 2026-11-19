--!strict
--[=[
	The RemoteEvents that the server and the players' machines talk through,
	on a player's side.

	[method find] waits for the RemoteEvents the server made, one for each
	name in Messages, and returns them by name.

	```lua
	local remotes = Remotes.find()
	remotes.clickSlot:FireServer("pack", 3, "left")
	remotes.inventoryChanged.OnClientEvent:Connect(function(pack, screen) end)
	```
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Messages = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Messages"))

local Remotes = {}

--[=[
	Waits until the server has made the RemoteEvents, and returns them by message name.

	Reading a name that is not in Messages from the table returned raises an error.
]=]
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
			error(
				string.format('Remotes: no message is called "%s"; the names are listed in Messages', tostring(name)),
				2
			)
		end,
	}) :: any
end

return Remotes
