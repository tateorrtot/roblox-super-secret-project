# The sixth review: events, glue, and a setter of nothing (2026-11-20)

The user read Claude's report on the untangle and answered it point by point. Their words, and what Claude took from them. Not all of it is built: what is waiting is in `docs/status/asked-of-the-user.md`.

## One exception to a name's promise
`World.spawnStack` and `World.setGroundItemPosition` also merge ground items, which their names do not say. Claude had proposed moving the merge, at the cost of checking every ground item ten times a second.
> Okay yeah those merges are okay I think, that cost would insane and ineffecient for the sake of the API. ... As long as its specified that it will merge in documentation I think its okay to break that method naming standard here and HERE ONLY

- **An exception to a rule is the user's to grant.** It is written where the rule is, with its reason, and it covers that one place.
- **A clean name is not worth a cost in play.** Say the cost with the proposal, and they will weigh it.

## A thing that is removed says so
> Love the removing removePlacedItem that was so much behaviour I wouldnt never guessed by the name alone. I feel like if you do removePlacedItem the placedItem itself should signal / event "hey im getting deleted!" and that end up cascading into the items splling and the inventory closing elsewhere. i.e. less coupling. that one function should not know what an inventory is, a placed item, spilling items, etc wayy to much if thats what it was doing!

- **The function that removes a thing does not know what else must happen.** The thing says that it is going, and each piece that cares does its own part. This is Godot's signals.
- The rules have no such mechanism yet. It is shared machinery, so it is shown to the user before it is written.

## Glue
> Is World bloated / needs to be split up or is it good. What are its responsibilities right now. In Godot, Im used to Autoloads basically being big "glue" services

They said yes to moving the push out of a tile out of `World`, and to `World` no longer naming stations: "Yeah this is what I was saying before."

- **A big glue service is fine,** as an autoload is in Godot. What it must not hold is rules of its own.
- The push is now `PlotCollision`. Stations wait for the signal.

## "setCharacter what?"
> Uh what? Theres a method called setCharacter? setCharacter what? Youre making it sound like the characters transform? (does it include scale too like in godot?)

- **A setter names the thing it sets.** `setCharacter` sets nothing a reader can name. Two of Claude's own cold readers had said the same, and Claude had kept the name.
- **When a cold reader and the user's own rule agree, the name goes.** It is now `setCharacterPositionAndFacing`, with `removeCharacter` for a player who has none.
- **A word borrowed from an engine carries that engine's promise.** "Transform" made them ask about scale. What the rules hold is a position and a facing along the ground, so the name says those.

## The player's machine first
> why are we doing it so the server is always synced. Cant we do more predictive client stuff. Like how players move they dont actually wait for the server ... if the client moves but the server doesnt see you get a "rubberband" right? Cant it be like that for physics and for hotbars, inventories, etc. Then theres no delay yet we stay server authoritive.

> Why is there even a delay at all when throwing an item? ... This is a tiny thing of polish but I feel its important if easy

- **They want the player's own machine to act at once, with the server still in charge.** What Roblox does and offers is in `docs/research/18-client-first.md`.
- **A wait that cannot be felt in Studio is still a wait.** They took the hotbar's delay for fixed because Studio has none. Claude must say which things only show on a real server.
