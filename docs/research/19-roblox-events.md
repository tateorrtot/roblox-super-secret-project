# Roblox's own events, and why its developers write their own signal

Researched on 2026-11-20. Claude had proposed a small `Signal` piece for the rules, so that a plot could say when a placed item is removed. The user asked the question Claude should have answered first.

**Caveats.** One reader on Sonnet, checked by a second who fetched the sources again. Nothing was run. No official source says outright that deferred signals apply to a BindableEvent; the announcement speaks of event handlers in general.

## What the user asked, in their words
> Uh what? Doesnt roblox have events? Why are we reinventing roblox's events? Am I misunderstanding? I think using signals/events is fantastic and also helps decoupling and adding features to know when something is happening but Im concerned about having two parallel systems. This is a roblox game first

## What Roblox has
| | What the sources say | From |
|---|---|---|
| The thing | `BindableEvent`. One script connects a function to its `Event`, another calls `Fire`. It is for scripts on the same side, server or player's machine | Events overview; BindableEvent reference |
| What it is | An Instance, made in the data model like a part or a folder | BindableEvent reference |
| What a listener gets | A copy. "Tables passed as arguments to bindable events and callbacks are copied", and a table's metatable is lost | Bindable events guide |
| The order listeners run in | Not promised: "Luau executes them in an unpredictable order". Each runs in a thread of its own | Bindable events guide |
| When they run | It depends on `Workspace.SignalBehavior`. Under `Deferred` a listener is "added to the back of a queue and run later", not inside the call that fired it | Deferred events page |
| Which is the default | Places made from templates are set to `Deferred`. The old default acts as `Immediate` and "will eventually switch", with no date | Deferred events page |
| What Roblox suggests | "module scripts are often a better alternative for situations in which you need to share data between scripts" | Bindable events guide |

## What Roblox developers use
A signal written in Luau, with no Instance behind it. The readers found three, all under the MIT licence.
- **GoodSignal**, by stravant. Its README promises "full API and behavioral parity with Roblox' RBXScriptSignal", built on the `task` library and not on a BindableEvent.
- **Signal in RbxUtil**, by sleitnick. Its own header says it is a direct copy of GoodSignal.
- **LemonSignal**, described as a pure Luau signal that is faster than most.

So a signal of our own would not be a second system brought over from Godot. It is what Roblox's own developers do when the listener must get the real thing, at once, in a known order.

## What a BindableEvent would cost the rules
- **The rules could no longer be tested outside Roblox.** They are plain Luau, and a BindableEvent is an Instance.
- **A listener would get a copy** of the placed item, not the placed item.
- **Under `Deferred`, listeners run after the caller has moved on.** A hit removes a placed item and then throws what was in it. The screens open on it must close before that throw, so that a carried stack goes back to its owner's pack and not out with the contents. A deferred listener would close them too late.

## What follows
- **One kind of event for one kind of thing.** Roblox's events where Roblox speaks to us: a player joins, a key is pressed, a RemoteEvent arrives. A plain Luau signal, if the rules get one, where one rule tells another.
- **Nothing is built.** The user chose to leave `World` as it is for now. The question comes back with the second kind of placed thing that acts (`docs/game/placed-objects.md`).
- **The choice then:** about 20 lines of our own, which run each listener at once and in the order they were connected; or GoodSignal, which needs Roblox's `task` library and so could not run in our tests, and whose download needs the user's yes.
