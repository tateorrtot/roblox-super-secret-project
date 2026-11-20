--!strict
-- Tests for Signal. Run from the repository root: lune run tests/Signal.test.luau

local Check = require("./Check")
local Signal = require("../src/shared/Signal")

local check = Check.that

do -- a signal with no listeners
	local signal: Signal.Signal<number> = Signal.new()
	check(#signal.listeners == 0, "new: a new signal has no listeners")
	Signal.fire(signal, 1)
	check(#signal.listeners == 0, "fire: firing a signal with no listeners does nothing")
end

do -- connecting and firing
	local signal: Signal.Signal<string, number> = Signal.new()
	local heard: { string } = {}
	Signal.connect(signal, function(name: string, count: number)
		table.insert(heard, `first {name} {count}`)
	end)
	check(#heard == 0, "connect: connecting calls nothing")
	Signal.fire(signal, "log", 3)
	check(#heard == 1 and heard[1] == "first log 3", "fire: the listener is called with the values given")

	Signal.connect(signal, function(name: string, count: number)
		table.insert(heard, `second {name} {count}`)
	end)
	Signal.fire(signal, "fish", 2)
	check(
		#heard == 3 and heard[2] == "first fish 2" and heard[3] == "second fish 2",
		"fire: every listener is called, in the order they were connected"
	)
	check(#signal.listeners == 2, "connect: the signal keeps each listener")
end

do -- firing is done before fire returns
	local signal: Signal.Signal<> = Signal.new()
	local count = 0
	Signal.connect(signal, function()
		count += 1
	end)
	Signal.fire(signal)
	Signal.fire(signal)
	check(count == 2, "fire: each firing has called the listeners by the time it returns")
end

do -- the same function connected twice
	local signal: Signal.Signal<> = Signal.new()
	local count = 0
	local function listener()
		count += 1
	end
	Signal.connect(signal, listener)
	Signal.connect(signal, listener)
	Signal.fire(signal)
	check(count == 2, "connect: a function connected twice is called twice")
end

do -- connecting while the signal is being fired
	local signal: Signal.Signal<> = Signal.new()
	local late = 0
	Signal.connect(signal, function()
		Signal.connect(signal, function()
			late += 1
		end)
	end)
	Signal.fire(signal)
	check(late == 0, "fire: a listener connected while the signal is being fired is not called in that firing")
	Signal.fire(signal)
	check(late == 1, "fire: it is called from the next firing on")
end

do -- a listener that fails
	local signal: Signal.Signal<> = Signal.new()
	local after = 0
	Signal.connect(signal, function()
		error("the listener failed")
	end)
	Signal.connect(signal, function()
		after += 1
	end)
	local problem = Check.errorFrom(function()
		Signal.fire(signal)
	end)
	check(
		problem ~= nil and string.find(problem, "the listener failed", 1, true) ~= nil,
		"fire: fails if a listener fails"
	)
	check(after == 0, "fire: and the listeners after it are not called")
end

do -- two signals
	local one: Signal.Signal<number> = Signal.new()
	local other: Signal.Signal<number> = Signal.new()
	local heard = 0
	Signal.connect(one, function(value: number)
		heard += value
	end)
	Signal.fire(other, 5)
	check(heard == 0, "fire: a signal calls only its own listeners")
	Signal.fire(one, 5)
	check(heard == 5, "fire: and the one that was connected to hears it")
end

Check.finish("Signal")
