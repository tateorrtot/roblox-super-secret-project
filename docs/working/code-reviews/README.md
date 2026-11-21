# The user's reviews of the code

The user has reviewed the code twelve times. Each file here is one review, in their words, with what Claude took from it. Read this page before showing them code; read a review when you need their exact words.

The number in a file's name counts the reviews of 2026-11-20, so it is one less than the review's place in this list.

| | Review | What they found |
|---|---|---|
| 1 | `2026-11-19-the-first-piece.md` | An empty slot stored as `false`. "If something is empty... it is empty!" Pieces must make sense with no context |
| 2 | `2026-11-20-1-first-read.md` | They could not judge the code. Files too long, too many comments, names that said nothing: "What is SlotMouse?" |
| 3 | `2026-11-20-2-the-sample.md` | Comments that leaned on Minecraft and on a mouse. A function named `drop` that did not drop. "you can and should break it up!" |
| 4 | `2026-11-20-3-the-names.md` | Function names with no object. "gather... what?" They guessed wrongly what `moveStack` took |
| 5 | `2026-11-20-4-out-of-context.md` | A function tied to a thing that is not its own: "Spaghetti!" A class named with a verb. "If it doesnt work out of context. It doesnt work." Delete a directory, and its neighbour must not break |
| 6 | `2026-11-20-5-events-and-glue.md` | "setCharacter what?" A thing that is removed should say so, and the pieces that care do the rest. A big glue service is fine. One exception to a name's promise, "here and HERE ONLY", which was lifted the same day |
| 7 | `2026-11-20-6-check-then-act.md` | "verbNounAndNoun": a name with `And` is two functions. "Check before you call the method like can_jump THEN jump." "Doesnt roblox have events?" A station is a black box: "contain the spaghettii" |
| 8 | `2026-11-20-7-the-item-decides.md` | "Shouldnt it be the item itself that determines what happens when it breaks?" Composition, not inheritance. "You cant just... invent nouns out of nowhere". Roblox's word, or Godot's. "Did you fix what they found?" |
| 9 | `2026-11-20-8-two-systems.md` | Items and placed objects are "two v e r y different systems that shouldnt rely on or mention eachother". Glue lives outside both. Roblox's style. "Why? Just why this class name?" A question they could not read: "Uh what? Im confused" |
| 10 | `2026-11-20-9-simple-things-and-glue.md` | "why do PlaceableItems still exist". Items, and events that code is attached to: "Just keep it generic." "Systems shouldnt know about eachother. Dont pull out abstractions." Compose with glue; the FoxFabric-addon test; "You dont make something for every combination" |
| 12 | `2026-11-20-11-where-is-the-item.md` | "Does CrateItem not like, extend Item?" An item's id, stack size and look were not in its file. "what is a station...? ... Is it defined in the codebase? If it is, where? Why?" A crate composed with an inventory: "fantastic". The rigid grid is "Bloxburg's greatest flaw" |
| 11 | `2026-11-20-10-who-said.md` | "who said an item was always going to be tied to a player. Or a hotbar?" Things stay dumb. The tool in the hand is not the item. Glue is fine; one module requiring another is not. "who said tiles werent 3D?" Two sentences they could not read |

Their message between the seventh and the eighth was answers and not a review: signals approved, merging to follow Minecraft, and "quality is a lot more important than speed!" (`docs/working/engineering-rules.md`).

Their message after the ninth was direction and not a review: "Good. Good. and good." to the three steps of the split, "I like PlacedObject!", and a script for each kind of placed object (`docs/game/placed-objects.md`). The tenth came from the report on that work, not from the code. The eleventh came from reading one script, `CrateItem`: the first of the new code they have read. The twelfth came from Claude's answers to the eleventh.

## What to check before showing them code
These are Claude's readings of the twelve reviews. The quotes are in the files.

- **Say where every fact of a thing lives.** They looked in `CrateItem` for the crate item's stack size, and it was a row in another file. A thing spread over files and joined by a string is hard to find, however decoupled the files are.
- **No noun for a category before the category has things in it.** `Station` was their word for an idea, and Claude made it a folder and a type for one furnace: "the noun station would be more like a vague idea than actually in the codebase?" Name a piece for what it is.

- **Read each class alone,** as `python tools/bare_names.py <Module>` prints it: its name and its members' names, and nothing else. Each name must say what it is, or what it acts on and where. If you would have to ask "... what?", so will they. A guess is a failure.
- **A class is a noun.** If no noun works, the class is wrong.
- **A name is a promise.** A function does the thing its name says: all of it, nothing else, and every time it is called. If it also sets, stores or works out something for another concern, that is the tangle they called spaghetti. If it looks first and quietly does nothing, the check belongs in a function of its own, `can...`, called first.
- **A setter names the thing it sets:** `set` and the property. "setCharacter what?"
- **`And` in a name is two functions.** A long name is a flag, and not always wrong.
- **Every word in a name is a real thing in the code, or a plain word nobody could doubt.** No invented noun, and no invented adjective: "what are due items. did you just invent that."
- **A noun that can be read two ways is a failed name.** "Plot Controls? ... controling a plot?"
- **Roblox's word first, then Godot's, never one of ours.** And when explaining by Godot, say which word is whose.
- **The item decides what happens to it.** No function does the same to every item whatever it is. A question that offers two answers for all items is the wrong question.
- **Items and placed objects are two systems that do not know each other.** What joins them is glue, outside both.
- **Many simple things, not a few clever ones.** A system does one job and knows no other. Ask of each folder: could it ship by itself as a FoxFabric addon? `python tools/delete_directory_test.py`.
- **The general code never asks what sort of thing a thing is.** No table, flag or type that says an item places or a placed object holds things. Look for one before showing them code: Claude kept `PlaceableItems` through a whole split and reported it as glue.
- **A generic hook is not building ahead of need. A shared helper is.** "Just keep it generic. You cant pull out and abstract ... until you have a pattern of it." The hook is what lets the next thing be added without touching general code.
- **No combination gets a piece of its own.** "What we dont do is go ah we need cat and grep. Lets make catgrep".
- **Read each thing's requires and ask "who said?" of each.** Who said this thing is held by a player, kept in a hotbar, stands on a flat tile? If nobody did, the script is handed too much. `lune run tools/requires` lists them.
- **Things stay dumb.** A script is handed only what it uses and answers whoever called it. The caller acts on the answer.
- **When saying a thing is wrong, say the file, the function and one example.** "Picking up is one function across ground items and inventories" left them asking where it lives and whether it meant merging.
- **Say whether a list is how things are, or what was done.** They asked: "are you stating the issues currently and that youve fixed them?"
- **A question to them is in plain words and can be read alone.** No label coined a page earlier.
- **Use their words for the game:** "interact" and "break", not Claude's "use", "hit" or "knocked off the plot".
- **A reader's doubt is fixed, or listed with the reason it stands.** A report says what was left: "Did you fix what they found?"
- **Say what Roblox has before proposing ours.** "This is a roblox game first."
- **A general name on one example is a promise the code cannot keep.** Each kind of thing keeps its workings to itself.
- **When a cold reader doubts a name, change it.** Two readers doubted `setCharacter`, Claude kept it, and the user asked the readers' question word for word.
- **The function that removes a thing does not know what else must happen.** The thing says it is going, and each piece that cares does its part.
- **Glue may be big. It holds no rules of its own.**
- **Say the cost of a cleaner design with the proposal.** They turned one down for its cost and allowed an exception instead.
- **Maintainable and plain comes before working.** "much. much. much. more important than getting it to work right now."
- **A comment says completely what a thing does, in its own words.** It never points at another game, a device, the caller or another comment. Godot's class reference is the model.
- **Short was never the point. Explicit was.**
- **Empty is empty.** No placeholder or sentinel stands in for nothing.
- **Break it up:** directory, file, function, block. The work is deciding where to cut, what to name each part, and which layer it sits on.
- **Few indents.** Nothing nests more than two deep.
- **The rules know nothing of the mouse, the keys or a touch screen.**
- **Measure before showing:** `python tools/metrics.py --functions`, `python tools/unused.py`, and a names test on a fresh reader (`docs/code/names.md` says how).
- **Have a helper apply their latest review to the result,** told to assume the author thinks it is mended and to quote the words each finding goes against. After the tenth, that helper found twelve things where the two ordinary reviewers found none of them.
- **Explain Roblox by its Godot counterpart** (`docs/roblox/explained-for-godot.md`).

Each of the eleven reviews found something the checks before it had passed. Expect a twelfth.
