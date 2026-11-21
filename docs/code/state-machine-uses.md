# Where a state machine might be used

A draft for the user to strike through. They said on 2026-11-21, of the state-machine library: "I think they might come in handy but id want to identity their uses first". So the library is not built: the folder `state-machine`, beside this repo, holds a brief and no code. Every row is Claude's guess, taken from the user's own design notes in `docs/game/decisions.md` and `docs/game/core-rule.md`. Nothing here is built or decided.

The two machines are the user's own designs for FoxFabric (`docs/research/21-foxfabric-drafts.md`). In an explicit machine one state is active and code switches it. In a priority machine nobody switches: each state is asked whether it wants control, and the first in order that does is active.

| Thing | Its states, as a guess | Which machine | Would a plain field and an `if` do? |
|---|---|---|---|
| A helper | Seeing to a need (eating, resting), working at its job, walking to its work, idle. From "one job each plus two needs (food, rest)" | Priority: an urgent need takes control from the job, and the job is taken up again after | No. This is the case that the priority machine is for |
| A helper's delivery | Loading, on the road, unloading, going back. From "Deliveries are real" | Explicit, inside the helper's working state | Perhaps. It may be the steps of a job, and no machine |
| A character's way of moving | On foot, swimming, falling, riding | Priority | Roblox's `Humanoid` already keeps such states (`HumanoidStateType`), so perhaps nothing of ours |
| What a carrier travels on | Ground, water, air. From "a separate movement controller per medium" | Priority or explicit | Perhaps a field: a carrier may only ever have one |
| The stove | Cold, burning, working | Explicit | Yes. Today it is two times and no named state |
| A screen | None open, the pack open, the pack and others open | Explicit | Yes. Today it is `nil` or a screen |
| A creature being tamed | Wild, being fed, tame. From "one creature tamed by feeding" | Explicit | Yes |
| A body in a fight | Up, knocked out, dead. From "bodies take conditions and are knocked out or killed" | Explicit | Yes |
| A raid on a town | Calm, warned, attacked, afterwards. From "having to prep a town or their base aganist a raid" | Explicit | Not known: nothing of it is designed |

## Claude's reading
- **One clear use: a helper.** It is the only row where a plain field would not do, because a need must interrupt a job and the job must be taken up again.
- **Seven of the nine rows are a field and an `if`.** A library for them would be a thing made before its problem.
- **So the library can wait until helpers are designed.** That is the entities branch, which the user parked.
- **If it is built, the one problem it solves would be this:** deciding which of several behaviours runs now, when more than one wants to.
