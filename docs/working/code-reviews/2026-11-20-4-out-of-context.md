# The fifth review: tangled, and unreadable out of context (2026-11-20)

The user played the first build of dropped items and read what Claude had changed. Their words, and what Claude took from them.

## A function tied to a thing that is not its own
Claude's summary had ended by asking whether to rename `World.setPlayerPosition`, "which now also takes the way the character faces".
> Yes? But.. why do we have setPlayerPosition? Like what the hell is this method inside of World? Whys it inside of World? And why is it ALSO now taking rotation when you just changed the way items work? Why is this method tied to that? Spaghetti!

> And just review this codebase since that one scare about setPlayerPosition is making me think we got unmaintainable super coupled spaghettii

- The function recorded a position and also worked out and stored how the player's drops set off. Claude had built it so to keep the change small.
- **A small change is not worth a tangled function.** Keep the plain facts, and work the rest out where it is used.
- The review they asked for is `docs/code/reviews/16-coupling-review-2026-11-20.md`.

## Glue, and what must not break
> So world is... 100% of glue code? That sounds dangerous. I like to draw my code out as a giant chart / graph. All the coupling between directories / modules, scripts, etc gets drawn. If you say have an inventory directory and all the sudden deleting the vehicles directory makes it break youve failed.

> Same for the big glue code if you delete a module instead of it throwing some big weird error I think its good to have asserts or warnings like "uh hey this entire big module is missing?" ... This might be handled well by the current debugger though so feel free to push back.

- **Deleting one directory must not break the one beside it.** `python tools/delete_directory_test.py` runs that test.
- Claude pushed back on the asserts, with the messages the checks already give. See "What was found" below.

## What matters most
> Again... maintainable straightforward easy to understand with no context decoupled code is much. much. much. more important than getting it to work right now.

## Out of context
Claude had named a class `Throw`, and then offered `StartingMotion`.
> Im confused on "Throw". Thats just a verb as a class? ... Something like "PlayerState" I see and go "ah its [Noun][Noun]" The state of the player! ... You get some weird things like "Throw.new". Verb.new. What?

> So I see starting motion out of context. No idea what this game is. I see just the class. And you land on... starting motion. What the hell is starting motion? I look in the class. newFromCharacter. newSpill. newPush. newAtRest. these are my methods. what the heck? is a starting motion a karate kit? a car being pushed? the first electron in a line being moved? i think to myself.
>
> If it doesnt work out of context. It doesnt work.
>
> This goes for *all* code. Not just Throw. Not just the class names. Even to a degree, not just the methods or properties.

- **A class is read alone: its name and its members' names, and nothing else.** Not its first line, not its neighbours, not what the game is.
- **A class is a noun.** `PlayerState` is their example of a good one.
- **When no noun works, the class is wrong, not the name.** `Throw` was a position and a velocity with four rules of the game hung on it as constructors. It went: a ground item has a position and a velocity, and each rule is a named function where it is used.

## Not only the stove
Claude had described one fault as `removePlacedItem` deleting "the stove's fire".
> For removePlacedItem remember its a lot more than just the stove that this might be happening to. Dont couple this issue to just the stove its going to be found elsewhere. Any placed item that has storage and a menu.

- **Name a fix for the general thing.** A placed item that has storage and a menu, not a stove.

## What was found
- **The names test was too easy.** Readers had been given each file's first line. Run on bare names, two readers got none of 345 names wrong, and 28 right only by guessing. The user could make nothing of a class those readers passed. A guess now counts as a failure (`docs/code/names.md`).
- **The delete test:** `players`, `plots` and `stations` do not break one another. Only `world`, `requests` and the Roblox side require them.
- **The check's errors are already plain.** A missing directory: `src/shared/world/World.luau(17,24): TypeError: Unknown require: ...\stations\RecipeRegistry.lua`. A missing function: `Probe.luau(5,1): TypeError: Key 'dropStackAt' not found in table 'World'`. Both name the file that asked and the thing that is missing, and both come from `lune run tools/check` before the game runs. `tools/members.py` does the same for the server's and the client's scripts, which are not type-checked.
- **At run time the error is the vague one the user expected:** `Probe:5: attempt to call a nil value`, with the file and the line and no name. An assert in the glue would say the same thing the check says sooner. What would close the gap is running the check before the code reaches Studio, which is an idea put to the user and not built.
