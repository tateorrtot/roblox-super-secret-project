--!strict
--[=[
	The RemoteEvents that the server and the players' machines talk through,
	on the server's side.

	[method create] makes one RemoteEvent for each name in Messages, in a
	folder called `Remotes` in ReplicatedStorage, and returns them by name.
	Call it once, when the server starts.

	```lua
	local remotes = Remotes.create()
	remotes.clickSlot.OnServerEvent:Connect(function(player, side, slot, button) end)
	remotes.inventoryChanged:FireClient(player, pack, screen)
	```
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Messages = require(ReplicatedStorage:WaitForChild("Shared").Messages)

local Remotes = {}

--[=[
	Makes the RemoteEvents and returns them by message name.

	Reading a name that is not in Messages from the table returned raises an error.
]=]
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
			error(
				string.format('Remotes: no message is called "%s"; the names are listed in Messages', tostring(name)),
				2
			)
		end,
	}) :: any
end

return Remotes
