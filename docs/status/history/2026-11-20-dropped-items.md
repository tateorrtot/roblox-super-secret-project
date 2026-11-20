# 2026-11-20: dropped items rebuilt

What happened when dropped items were rebuilt to behave as Minecraft's do. Where they stand now is in `docs/game/dropped-items.md`.

- **The user asked for it** after playing the first build: a dropped stack appeared on the ground 6 studs ahead and never moved, and could land on top of a block, out of reach.
- **Researched first,** at their word: how Minecraft does it, and what Roblox's physics does by itself (`docs/research/16-dropped-items.md`). They approved a five-line outline and said "Go ahead and build it."
- **Built in four commits on the branch `dropped-items`:** `Throw` and `Direction`; `GroundItems`; `World` and the requests; the server. Each passes `lune run tools/check`. The third is rules only, and the game is not playable at it.
- **Roblox's physics does all the motion.** A ground item is a plain unanchored part, owned by the server, thrown once. The rules decide how it sets off and are told where it has got to.
- **The user stopped Claude twice while it worked.** First when its notes said "physics experiment", which they read as Claude writing a physics engine. Then to say that an idea beyond what was asked should be said, not built, while they are sitting there. Claude cut a lighter gravity, custom friction, a constraint to keep items upright, a second tuning experiment, a check on every moving item, and a rename. What was cut is listed in `docs/game/dropped-items.md`. The rule is in `docs/working/with-the-user.md`.
- **Checked by readers with no context,** on Sonnet: one given only the names, four given one file each, and two reviewers, each checked by a skeptic.
  - The rules reviewer found no defect, and confirmed with a script of its own that no item is made or lost by a push or a spill.
  - The Roblox reviewer found one loose comment, and that a block which falls out of the world is not noticed. That cannot happen on the placeholder map.
  - The readers understood each piece from its file alone. They could not tell what `LIFT`, `SPILL_TURN`, `MOVE_NOTICED` and two private constants were, and two comments promised more than the code does. All were renamed or reworded.
  - They also said that `World.setPlayerPosition` does more than its name says, since it takes the way the character faces. That is left for the user to decide.
- **Mutation testing found gaps in Claude's own tests of the push:** nothing checked two of the four sides, or an item lying under a block. Checks were added.

## The same day: the user played it, and the untangle
- **The user played it and read some of the code.** They felt "a big delay when throwing", asked why Claude had switched off Roblox's ownership of the parts, called `World.setPlayerPosition` spaghetti because it also worked out the throw, and could make nothing of the class `Throw` out of context. Their words are in `docs/working/code-reviews/2026-11-20-4-out-of-context.md`.
- **The delay was measured before anything was changed,** at their word. A part the server owns is first seen moving 250 to 370 milliseconds after the throw, against about 140 when Roblox chooses the owner (`docs/research/16-dropped-items.md`).
- **The coupling was reviewed** by ten agents on Sonnet. Not spaghetti, and ten faults worth acting on (`docs/code/reviews/16-coupling-review-2026-11-20.md`).
- **They approved four things, done in one commit:** ground items handed back to Roblox's ownership; a player's state holds a `character` and the throw is worked out when a stack is dropped, so `Throw` is gone; removing a placed item is split into taking it off the plot and throwing it; only `PlayerState` assigns a player's fields; the server alone keeps the selected hotbar slot.
- **The names test was run their way first,** on bare names with no first line. Two readers got none of 345 names wrong and 28 right only by guessing, which showed the readers are more forgiving than the user. The new names were then chosen from candidates by readers shown names alone.
- **Their delete test was run:** `players`, `plots` and `stations` do not break one another (`python tools/delete_directory_test.py`).
- **The fixes were reviewed** by three readers of bare names and two reviewers, each reviewer checked by a skeptic.
  - Nothing breaks in play, and no item is made or lost.
  - `World.spawnStack` and `World.setGroundItemPosition`, both new, also merge ground items, which their names do not say. Left for the user to choose, since the fix changes when stacks merge.
  - Fix 4 made the hotbar's highlight wait for the server. Claude had not told the user that cost when proposing the fix.
  - A reader took `PUSHED_GROUND_ITEM_SPEED` for a character pushing an item, and could not tell whether `CHARACTER_THROW_HEIGHT` was where a throw starts or how high it goes. Both were renamed, and a second reader read them correctly.
  - Three comments promised more than the code does, and were corrected. Mutation testing found that no test checked the selected slot in a snapshot, or the order a placed item and its stacks are thrown in. Both have checks now.
  - Left as known problems in `docs/status/now.md`: a pushed item is not checked where it lands, and a block placed under an item in flight can miss it.

## The same day: the user's answer to the report
Their words are in `docs/working/code-reviews/2026-11-20-5-events-and-glue.md`.
- **The merge stays where it is,** as the one exception to a name's promise, because the clean way would have checked every ground item ten times a second.
- **`setCharacter` failed their read:** "setCharacter what?" It is now `setCharacterPositionAndFacing` and `removeCharacter`, in `World` and in `PlayerState`.
- **The push out of a tile left `World`,** at their yes, for a piece of its own: `PlotCollision`. `World` went from 420 lines to 357.
- **`lune run tools/requires --chart` draws the chart of requires,** and the check fails when the chart is out of date.
- **They proposed signals:** a placed item that is removed says so, and the pieces that care do their part. Shown to them as a plan, since it is shared machinery.
- **They asked why everything waits for the server.** Four readers checked what Roblox does and offers (`docs/research/18-client-first.md`). A plan for acting on the player's machine first was shown to them.
- **Checked:** every check, the play test at 71 of 71, mutation testing of the three pieces changed, three cold readers, and a reviewer checked by a skeptic.
- **The reviewer found four things, all fixed:** two comments that left a case out, one promise no test checked, and that the chart tool crashed if a require ever looped. Nothing in play had changed.

## The same day: twenty-five points
Their words are in `docs/working/code-reviews/2026-11-20-6-check-then-act.md` and in `docs/game/`.
- **Merging moved into `World.advanceTo`,** once it could be done at no more cost: the ground items remember which of them moved. The exception to a name's promise, allowed that morning, was lifted.
- **A throw goes the way the camera looks along the ground.** The three drop requests carry the direction. The rules stopped keeping which way a character faces, which left one setter, `setCharacterPosition`, and answered their objection to `setCharacterPositionAndFacing`.
- **Two rules:** a function does what its name says and the check is kept apart, and `And` in a name means two functions.
- **They asked why Claude would reinvent Roblox's events.** Claude had not said what Roblox has. The answer is `docs/research/19-roblox-events.md`, and nothing is built.
- **They said what a station is to them:** a black box. `Station` in the code is a furnace (`docs/game/placed-items.md`).
- **They chose our own prediction,** and asked how it stays out of the existing pieces. The plan is in `docs/status/next.md`.
- **They gave much more of the game:** more of what they draw on, more examples, plots with owners, walls and floors, three kinds of process, and helpers who do what a player can.
