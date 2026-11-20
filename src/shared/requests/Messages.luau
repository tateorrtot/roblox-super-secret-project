--!strict
--- The name of every message that crosses between a player's machine and the server.
local Requests = require("./Requests")

local Messages = {}

local toServer = table.clone(Requests.NAMES)
table.insert(toServer, "askForView")

--- The messages a player's machine sends: every request in `Requests.NAMES`, and `askForView`,
--- which asks the server to send `viewChanged` again.
Messages.toServer = table.freeze(toServer)

--- The messages the server sends: `viewChanged`, with what `PlayerView.encode` returns for the
--- player it is sent to.
Messages.toClient = table.freeze({ "viewChanged" })

return Messages
