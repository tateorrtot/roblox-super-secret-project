--!strict
--- A thing's way of telling others that something has happened to it.
---
--- The thing keeps a signal for each kind of happening, and fires it when it happens. Anything
--- that wants to know connects a function, its callback, with `connect`. `fire` calls every
--- callback there and then, before it returns, in the order they were connected, and gives each
--- what it was given. A signal is plain Luau: it is not a Roblox event, and it needs no Roblox to
--- run.
local Signal = {}

--- A signal whose callbacks are given values of the types `T...`.
export type Signal<T...> = {
	--- Every function connected, in the order they were connected.
	read connections: { (T...) -> () },
}

--- Returns a new signal with nothing connected to it.
function Signal.new<T...>(): Signal<T...>
	return { connections = {} }
end

--- Connects `callback` to the signal: from now on `fire` calls it. A function connected twice is
--- called twice.
function Signal.connect<T...>(signal: Signal<T...>, callback: (T...) -> ())
	table.insert(signal.connections, callback)
end

--- Calls every callback of the signal with the values given, in the order they were connected,
--- and returns when the last has returned. A callback connected while the signal is being fired
--- is not called until it is next fired. If a callback fails, so does `fire`, and the callbacks
--- after it are not called.
function Signal.fire<T...>(signal: Signal<T...>, ...: T...)
	local connections = signal.connections
	for index = 1, #connections do
		connections[index](...)
	end
end

return Signal
