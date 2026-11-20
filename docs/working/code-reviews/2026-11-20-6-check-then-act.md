# The seventh review: check then act, and no "And" in a name (2026-11-20)

The user answered Claude's report in twenty-five points. Their words on the code, and what Claude took from them. Their words on the game are in `docs/game/`.

## "And" in a name
Claude had renamed `setCharacter` to `setCharacterPositionAndFacing`.
> Thats a mouthful its like a java script. Why cant we just split the function up? Any function that gets that long should be flagged. Not always bad just... "verbNounAndNoun". Its weird to have "And" in a function that signals to me hey this method is doing the role of two methods. Maybe take a note.

Of `setCharacterTransform`, which Claude had offered:
> Actually is transform a defined solid thing? like a class? if not dont do transform just the split up functions that set[Property]. setCharacterTransform reads as "get the character, then set their "transform" property to this"

Of `pushGroundItemsOutOfTile`:
> I think pushGroundItemsOutOfTile is one of these times a mouthful may be okay? Unless you have a better idea.

- **`And` in a function's name is a flag: it is doing the work of two.** Split it into one function for each thing, as `set` plus the property.
- **A long name is a flag too, and not always wrong.** Look at it, and keep it if every word is doing something.
- **A word names a real thing in the code, or it is not used.** There is no transform in the rules, so nothing is called one.
- What it became: the rules no longer keep which way a character faces, so there is one setter, `setCharacterPosition`.

## Check, then act
Claude had offered to make the command that syncs code to Studio refuse when the checks fail.
> im confused why a script meant to sync ALSO judges if it gets synced. This goes for methods in the game too, if you say "jump" dont have a check inside that method. Check before you call the method like "can_jump" THEN "jump". A method should always do as it says so its intuitive. Never a check inside that may change it I feel. Sometimes we may never care about "can_jump" and just force a jump. Sometimes we may want to sync code without caring if it passed tests. Maybe take a note.

- **A function does what its name says, every time it is called.** It does not look first and quietly do nothing.
- **The check is a function of its own,** named `can...`, and the caller asks it first. A caller that does not care does not ask.
- **The same goes for a tool.** Sync syncs. Checking is another command.
- The rule is in `docs/code/conventions.md`, with the functions that do not yet follow it.

## Roblox first
Claude had proposed a `Signal` piece of its own for the rules.
> Uh what? Doesnt roblox have events? Why are we reinventing roblox's events? Am I misunderstanding? I think using signals/events is fantastic ... but Im concerned about having two parallel systems. This is a roblox game first, im just a godot dev so I try to understand things in a godot sense and take the strengths of godot that I love (like the ways for naming methods and classes)

- **Before proposing a thing of our own, say what Roblox has for it and why that will not do.** Claude did not, and the user had to ask.
- **Godot is how the user understands, not what is being built.** What they take from it is its naming and its clarity.
- The answer is in `docs/research/19-roblox-events.md`. Nothing is built.

## Do not make one mould for things that differ
Claude had named a furnace `Station`, as if every placed thing that works were one.
> a station is kinda like a black box. ... What is a station? Im actually a bit confused right now you mightve made something really rigid. ... We cant really predict what its going to be or "genericize" a lot of the time if that makes sense. I.e. its gonna be spaghettii but we gotta contain the spaghettii.

- **A general name on one example is a promise the code cannot keep.** `Station` is a furnace.
- **Each kind of thing keeps its own workings to itself.** The rest of the game knows only that it is a placed item which may open a screen.
- Their words in full, and what follows, are in `docs/game/placed-items.md`.

## Glue, again
> If we dont need to split our "autoload" World up and what youre doing is standard in a lot of games anyway we can leave it for now.

- `World` stays as it is.

## Prediction
> We had to do our own inventory and hotbar, so our own client side prediction makes sense. ... Im curious how it works though without spaghetti coding or baking more methods and functionality in pre-existing modules and scripts. This is essentially another whole set of modules ontop, no?

- They chose our own prediction over Roblox's Server Authority.
- **A new ability goes on top, as pieces of its own.** It does not get threaded through the pieces that are there.
