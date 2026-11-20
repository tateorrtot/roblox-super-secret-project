# Research

What was looked up, and by whom. These files are large, and are read only for the question each answers. Every one has a caveat: read it before relying on the file.

| File | What it is | Caveat |
|---|---|---|
| `01-research.md` | Market and tooling research. Section 9 has 13 design criteria | 24 details were found wrong or stale and not corrected in the file. Its "verb + noun title" rule is rejected. Its criteria come second to `docs/game/brief.md` |
| `02-concept-research.md` | Restaurant Tycoon, Retail Tycoon, the cozy audience, precedents, platform limits, and how tower defense, colony, war and card-duel games fared | Read each brief with its independent check |
| `03-concept-options.md` | Five single-activity concepts | **Rejected by the user as slop.** Kept as a record of what not to do |
| `04-activity-research.md` | Fishing, factory and sea-trade games | Reference on single activities only |
| `05-core-rule-design.md` | Four designs of the core rule-set, three judges, and research on physical objects and on how systemic sandboxes are built | The user rejected its slot-centred framing. Use its parts, its list of what the designs missed, and its grounding briefs |
| `06-interaction-rating-transport.md` | In-world interaction, what the Mild rating allows, transport and roads | Read each brief with its independent check |
| `12-grounding-for-the-first-pieces.md` | How Godot shapes its classes, how FoxFabric is written, exactly how Minecraft's inventory behaves on PC and on phones, what Luau and Roblox do with tables that have gaps, and what readers with no context expected of the first pieces | Each brief is one agent's work: the second-agent checks did not run. Nothing was run in Godot, Minecraft or Roblox |
| `13-existing-libraries.md` | What already exists for what is built and what is coming: saving, messages, screens and inventories, placing and plots, helpers and vehicles, testing. A recommendation for each area, and Claude's short reading at the top | Six readers and three checkers, all on Sonnet. The checkers found a wrong or unconfirmed detail in most entries; each is listed. Nothing was installed or run |
| `16-dropped-items.md` | How a dropped item behaves in Minecraft, with numbers; how ours behaves today; what Roblox's physics did in three measured experiments; what Roblox's documentation and developers say | Minecraft's launch speeds are from 1.12 code. The measurements are from Studio on one PC with one player, not a phone or a real server |

The research on the architecture is in `docs/architecture/`, and the reviews of the code are in `docs/code/reviews/`.
