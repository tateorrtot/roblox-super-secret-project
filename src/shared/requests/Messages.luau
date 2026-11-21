--!strict
--- The name of every message that passes between the client and the server.
local Requests = require("./Requests")

local Messages = {}

local toServer = table.clone(Requests.NAMES)
table.insert(toServer, "askForSnapshot")

--- The messages that the client sends: every request in `Requests.NAMES`, and `askForSnapshot`,
--- which asks the server to send `snapshotChanged` again.
Messages.toServer = table.freeze(toServer)

--- The messages that the server sends: `snapshotChanged`, with what `PlayerSnapshot.encode` returns
--- for the player it is sent to, and then the time on the world's clock when it was sent, in
--- seconds.
Messages.toClient = table.freeze({ "snapshotChanged" })

return Messages
