--!strict
--- A thing's way of telling others that something has happened to it.
---
--- The thing keeps a signal for each kind of happening, and fires it when it happens. Anything
--- that wants to know connects a function, called a listener, with `connect`. `fire` calls every
--- listener there and then, before it returns, in the order they were connected, and gives each
--- what it was given. A signal is plain Luau: it is not a Roblox event, and it needs no Roblox to
--- run.
local Signal = {}

--- A signal whose listeners are given values of the types `T...`.
export type Signal<T...> = {
	--- Every function connected, in the order they were connected.
	read listeners: { (T...) -> () },
}

--- Returns a new signal with no listeners.
function Signal.new<T...>(): Signal<T...>
	return { listeners = {} }
end

--- Connects `listener` to the signal: from now on `fire` calls it. A function connected twice is
--- called twice.
function Signal.connect<T...>(signal: Signal<T...>, listener: (T...) -> ())
	table.insert(signal.listeners, listener)
end

--- Calls every listener of the signal with the values given, in the order they were connected,
--- and returns when the last has returned. A listener connected while the signal is being fired
--- is not called until it is next fired. If a listener fails, so does `fire`, and the listeners
--- after it are not called.
function Signal.fire<T...>(signal: Signal<T...>, ...: T...)
	local listeners = signal.listeners
	for index = 1, #listeners do
		listeners[index](...)
	end
end

return Signal
