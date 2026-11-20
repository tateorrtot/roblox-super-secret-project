# Architecture notes

Reference only. They are not a plan, and nothing in them awaits a signature. The architecture grows from the pieces as they are joined (`docs/working/with-the-user.md`).

**In force from them:**
- What requires what runs one way (rule A1). `lune run tools/requires` checks it.
- Everything outside `server` and `client` is plain Luau with no Roblox calls (rule A6).

| File | What it is | Caveat |
|---|---|---|
| `07-architecture.md` | The code architecture, draft 5, in four parts | Part B may contradict itself. None of it is checked against code |
| `08-architecture-grounding.md` | Engine and replication, persistence, tooling and testing facts the architecture rests on | Read each brief with its independent check. These facts change quickly |
| `09-architecture-review-draft2.md` | The independent review that failed draft 2: findings, referee rulings, proposed fixes | Section numbers refer to draft 2. Minor findings were not refereed |
| `10-architecture-review-draft3.md` | The check that failed draft 3: what was closed, what the fixes broke, and a cold read | Section numbers refer to draft 3. Not refereed |
| `11-architecture-check-draft4.md` | The check of draft 4: a sign-off reader, closure of the second review, and 96 platform claims tested, 87 confirmed. **Read its platform facts before a piece touches Rojo, streaming, RemoteEvents, saving or the type checker** | Section numbers refer to draft 4. Not refereed. Nobody confirmed that draft 5 applies every finding |

## What five drafts taught
The user asked for an architecture they could see was not a spider web. Claude wrote five drafts on paper, and sent three of them to panels of reviewing agents, before any code existed. The user stopped it: "Why are you trying to make the entire architecture / game at once?"

- The user asked "one last check you absolutely confident and happy with this architecture?" Claude answered that it was confident in the structure. **Draft 2 then failed independent review:** all three reviewers refused to sign, with about 45 findings upheld and three blocking (`docs/architecture/09-architecture-review-draft2.md`). The six-directory shape and the platform foundation held; the feature mechanism did not. Do not tell the user an architecture is sound before it has been reviewed.
- **Draft 3 also failed.** It closed most findings, but all four checkers declined to approve: the fixes opened new gaps, and a cold reader found 37 problems, two blocking (`docs/architecture/10-architecture-review-draft3.md`). No reviewer in either round found a reason to change the six-directory shape or the kernel-plus-features split.
- **Lesson from three failed drafts:** hand-written tables of which module requires which were incomplete every time, and mechanisms described only on paper contradicted their own examples. Stop specifying module-level detail on paper. Approve the shape and rules, build a small skeleton, and let a tool print the module graph from real code.
- **Draft 4 was checked by three agents and not approved either,** but the check narrowed the problem (`docs/architecture/11-architecture-check-draft4.md`). Platform facts: 87 of 96 claims confirmed, none blocking. The closure checker called it close. The sign-off reader would sign the shape, and would not sign the kernel mechanism, the screen or saving. Its advice: no fifth paper round; prove the mechanism in code with two made-up features.
- **Draft 5 is in four parts and is now reference only** (see `docs/working/with-the-user.md`). Part A is the shape: six directories with one-way dependencies (`lib`, `content`, `protocol`, `rules`, `server`, `client`); where they live in Roblox; definitions as rows of components checked by a validator, with component shapes and types in `protocol`; the checks, with the edge check built on `luau-lsp require-graph`; a Studio place file as the source for the map and models; eight invariants. Part B is a working design and **not for signature**: `rules` as a small kernel plus features installed in order, an action as the only way state changes, features "call down" and "react to records", no rollback (tested in code at step 2b); how state reaches the screen, with solid things as server-made Instances (a hypothesis, measured at step 4f); saving (decided at step 7a). Part C was a plan of 28 small steps, now superseded. Part D holds thirteen game-rule questions and six approvals, to be asked one at a time when a piece needs the answer. **Still in force from it:** the one-way dependency rule (A1), and everything outside `server` and `client` being pure Luau with no Roblox calls (A6).
- **No more paper review rounds and no more drafts.** Draft 5 was not sent for a design review. A narrower check of it against its own fix list was started, then stopped unfinished when the user redirected the work, so Part B may contradict itself in places. That is acceptable for reference notes.

**The lesson:** hand-written tables of which module requires which were incomplete every time, and mechanisms described only on paper contradicted their own examples. Do not specify module-level detail on paper. Do not tell the user an architecture is sound before it has been reviewed. Build small pieces, and let a tool print the module graph from real code.
