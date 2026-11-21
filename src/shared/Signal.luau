--!strict
--- A list of callbacks that a thing calls to tell others that something happened to it.
---
--- A thing holds one signal for each change that it tells others about. `connect` adds a callback
--- to a signal. `fire` calls every callback connected, in the order they were connected, and
--- passes each the values that `fire` received. A signal is plain Luau, and needs no Roblox.
local Signal = {}

--- A signal whose callbacks each receive values of the types `T...`.
export type Signal<T...> = {
	--- The callbacks connected to the signal, in the order they were connected.
	read connections: { (T...) -> () },
}

--- Returns a new signal with no callback connected.
function Signal.new<T...>(): Signal<T...>
	return { connections = {} }
end

--- Adds `callback` to the end of the signal's `connections`, so that `fire` calls it. A function
--- that is connected twice is called twice.
function Signal.connect<T...>(signal: Signal<T...>, callback: (T...) -> ())
	table.insert(signal.connections, callback)
end

--- Calls every callback in the signal's `connections`, in the order they were connected, and passes
--- each the values `...`. Returns after the last callback returns. Skips a callback that another
--- callback connects during the call: the next `fire` calls it. Raises an error if a callback
--- raises one, and does not call the callbacks after it.
function Signal.fire<T...>(signal: Signal<T...>, ...: T...)
	local connections = signal.connections
	for index = 1, #connections do
		connections[index](...)
	end
end

return Signal
