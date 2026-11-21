# The user's reviews of the code

The user has reviewed the code eighteen times. Each file here is one review, in their words, with what Claude took from it. Read this page before showing them code; read a review when you need their exact words.

In a file's name, the number counts the reviews of that day. For 2026-11-20 it is one less than the review's place in this list.

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
| 11 | `2026-11-20-10-who-said.md` | "who said an item was always going to be tied to a player. Or a hotbar?" Things stay dumb. The tool in the hand is not the item. Glue is fine; one module requiring another is not. "who said tiles werent 3D?" Two sentences they could not read |
| 12 | `2026-11-20-11-where-is-the-item.md` | "Does CrateItem not like, extend Item?" An item's id, stack size and look were not in its file. "what is a station...? ... Is it defined in the codebase? If it is, where? Why?" A crate composed with an inventory: "fantastic". The rigid grid is "Bloxburg's greatest flaw" |
| 13 | `2026-11-20-12-content-in-one-place.md` | "Systems being decoupled - fantastic. Pieces of content being scattered - not great." A stove is not every station: "youve now contracted all "stations" to have its spaghetii". "I dont see tileY". Free placement, and the worry about helpers and machines. "I thought you already did this?" |
| 14 | `2026-11-20-13-contained-spaghetti.md` | "who said colour? Are you coupling visuals to logic?" How a thing looks is a black box. "so i said the plots are 3D did i not...?" One noun for one thing. Systems, and content that glues them "in a messy frenzy". "again making up a lot of words to say other simple already defined things" |
| 15 | `2026-11-21-1-grids-on-bodies.md` | "why is there a colour..? Im confused" An item looks like a 2D texture or a 3D model, and no contract says which. "VoxelGrids on PhysicsBodies": a tree cut through falls. "who said we cant place things mid air? Or that Y is always up?" No floors or levels in the code |
| 16 | `2026-11-21-2-what-is-a-side.md` | "What is "a look piece". be more concrete youre talking very lofty and abstract." One page of the reference, read for the first time: "what the hell is a side", code that looked like "broken hyperlinks", each word said twice. "this is slop lol". A request of seven values: "Why so over the top." |
| 17 | `2026-11-21-3-concretely.md` | "I think you might've just done it again." A comment whose nouns point at nothing: "What is one slot? [Didnt you literally define it as an argument!]" "you say things that sound good at first glance but can be done so much more concretley." A change they could not follow: "why are you saying cut this thing?" |
| 18 | `2026-11-21-4-who-said-two.md` | "Who said only two open inventories wtf? What about panels of inventories open." A hopper, a funnel: inventories that work on each other with no player. "You make things that DONT know about eachother. You dont make up some random concepts like "side"." "Side is awful." |

Their message between the seventh and the eighth was answers and not a review: signals approved, merging to follow Minecraft, and "quality is a lot more important than speed!" (`docs/working/engineering-rules.md`).

Their message after the ninth was direction and not a review: "Good. Good. and good." to the three steps of the split, "I like PlacedObject!", and a script for each kind of placed object (`docs/game/placed-objects.md`). The tenth came from the report on that work, not from the code. The eleventh came from reading one script, `CrateItem`: the first of the new code they have read. The twelfth came from Claude's answers to the eleventh, and the thirteenth from its answers to the twelfth. The fourteenth and the fifteenth came the same way, each from Claude's report on the work before. Their message after the fifteenth was direction and not a review: the reading of a plot confirmed, building and physics as two systems, and "The documentation must be *good*" (`docs/game/decisions.md`, `docs/code/comments.md`).

## What to check before showing them code
These are Claude's readings of the eighteen reviews. The quotes are in the files.

- **Count what a type has room for, and ask who said so.** `InventoryScreen` had two inventories, `pack` and `otherInventory`, because the one case Claude was building had two: "Who said only two open inventories wtf?" One of a thing, two of a thing, and "a player is there" are each a contract. Write the least code, and not the least world.
- **Run the thing with no player.** A hopper took a stack from a crate and added it to a stove with `Inventory`'s two functions, and the stove's rule for its slots did not apply, because the rule was a field of a player's screen. A rule of a thing lives with the thing.

- **Every noun points at a real thing.** In a comment, and in a message to them: an argument, a field, a type, a file, a value. "One slot of the player's open screen" is `slot`, `player`, and `player.screen`. A sentence that reads well and names nothing is the fault they have found three times in one day.
- **No proposal to change code that they cannot yet read.** Claude asked whether to cut a request down, in words that took the code as known: "why are you saying cut this thing?" First make what is there readable. Then say why, in one plain sentence.

- **Say the kind of thing, then one case with real numbers.** Claude wrote "a look piece" for a ModuleScript, and "takes the stack" where it meant the 12 logs in slot 1 of the pack: "be more concrete youre talking very lofty and abstract". A script, a function, a table, a part: name it as that first.
- **A count comes with its list.** "Ten doubts stand" told them nothing: "Faults? What faults?" The count was wrong too.
- **Open the page, and have a cold reader read it.** Claude checked 53 pages against rules and against the code, and opened none. The first page the user opened used a word it never explained, drew code as broken links, and said each word twice. A fresh helper is shown one page and nothing else, and a guess is a failure (`docs/code/comments.md`).
- **A word that sounds like UI, in the rules, will be read as UI.** `screen` and `side` are Claude's words for what a player has open, and they read them as a GUI and as a side of the player.

- **A stand-in is plain, and is kept out of the content.** Claude wrote a colour on every item so that plain blocks could be told apart, and it read as a rule of the game: "why is there a colour..? Im confused". Where there is no art, say "there is no art".
- **Say what a thing is before why it is there.** "I left it because you said an item has a texture" left out that the colour was a stand-in block's.
- **Ask "who said?" of every argument of a signature, as of every require.** Claude built a flat floor of tiles on the second day and never went back to it: "who said we cant place things mid air? Or that Y is always up?"

- **Use the defined word.** Client, server, content, stove, Model. Not "the player's machine", "the game's own things", or a title of Claude's own. Godot's writing guidelines hold for comments and notes (`docs/code/conventions.md`).
- **How a thing looks is a black box.** No rule, and no general drawing code, says what a thing looks like: not a colour, not a cube.
- **"Who said X?" is a decision.** They asked who said tiles were not 3D, Claude filed it as a question, and two reviews later: "so i said the plots are 3D did i not...?"

- **Say of each thing whether it is built or only proposed, in those words.** Claude wrote "What I'd change" beside work that was done, and they took it as done: "I thought you already did this?" When they have said yes to a direction, build it.
- **Decouple the systems. Keep each piece of content in one place.** "Systems being decoupled - fantastic. Pieces of content being scattered - not great." A content file may be long and coupled; a system may not know another system.

- **Say where every fact of a thing lives.** They looked in `CrateItem` for the crate item's stack size, and it was a row in another file. A thing spread over files and joined by a string is hard to find, however decoupled the files are.
- **No noun for a category before the category has things in it.** Claude named one furnace `Station`. They asked what a station is in the seventh review and again in the twelfth, because Claude had written the fault down and left the name: "the noun station would be more like a vague idea than actually in the codebase?" Name a piece for what it is, and mend what they ask about the first time.

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
- **Measure before showing:** `python tools/comments.py`, `python tools/metrics.py --functions`, `python tools/unused.py`, and a names test on a fresh reader (`docs/code/names.md` says how).
- **Have a helper apply their latest review to the result,** told to assume the author thinks it is mended and to quote the words each finding goes against. After the tenth, that helper found twelve things where the two ordinary reviewers found none of them.
- **Explain Roblox by its Godot counterpart** (`docs/roblox/explained-for-godot.md`).

Each of the eighteen reviews found something the checks before it had passed. Expect a nineteenth.
