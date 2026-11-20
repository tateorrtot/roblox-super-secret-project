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
