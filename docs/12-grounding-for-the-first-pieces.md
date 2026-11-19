# Grounding for the First Pieces, November 2026

Compiled 2026-11-19, after the user rejected the first code piece and explained what they wanted instead: pieces designed from the top down that make sense with no context, where nothing stands in for nothing. This file records what was looked up and tested before the five inventory pieces were rewritten, and what readers with no context would call the pieces that come next.

**How far to trust it.**
- Each of the four research briefs is one agent's work. A second agent was to check every brief; those checks did not run, because the account's usage limit was reached overnight.
- Nothing was run in Godot, in Minecraft or in the Roblox engine. The Luau brief ran its own code on this machine with the project's tools.
- Claude confirmed these points itself by running code: the old type solver rejects the `read` keyword and the new one accepts it and reports writes; a frozen table refuses a write at run time; reading a slot directly from the slot table is typed as never `nil`, which is why the pieces type the slot table's values as optional.
- The briefs' full lists of findings (238 in all, each with its source) were in the session's temporary files and are not reproduced here. Each brief names its sources.

## What was decided from this

| Question | Answer | From |
|---|---|---|
| What is an empty slot? | No entry at all. An inventory is `{ slotCount, slots }` and a slot that holds nothing has no key | Godot's sparse classes; Luau; every reader |
| Is there an empty stack? | No. A stack holds 1 or more; where there is nothing, `nil` | Every reader; Minecraft's own save format cannot express one |
| Where does the stack size come from? | The item type, looked up by id. Never passed per call | Every reader |
| What are functions called? | Verb, then what it works on: `getStack`, `putInSlot`, `addItems` | Godot's `set_item_text` shape; readers found `put`, `add` and `set` alike |
| What is the carried stack? | A field of one player's open screen, `InventorySession.carried` | Minecraft's menu; four of five readers named it InventorySession |
| What are the actions called? | `take`, `place`, `swap`, `quickMove`. A mouse click is turned into those | Minecraft on phones has no right click |
| How is an inventory saved or sent? | Not as it is. As a list of occupied slots: `{ slotCount, stacks = { { slot, itemId, count } } }` | Roblox drops or re-keys tables with gaps; Minecraft saves the same way |
| Which type solver? | The new one only | `read` fields are a syntax error under the old one |
| Where do tests live? | Outside the pieces, in `tests/` | FoxFabric keeps tests outside the addon folder |

## The reader tests

Readers were agents given no context, used as test subjects and not as judges: the question was always "what would you expect?", never "is this good?".

**Test 1: what do you expect from the names?** Four readers (a Godot developer, a Minecraft modder, a Roblox developer, a backend programmer) saw only six file names and answered seventeen questions. Four more saw only plain descriptions and proposed names.
- All four expected `{ slotCount = 3, slots = {} }` for an empty 3-slot inventory, and `{ slotCount = 3, slots = { [2] = { item = "log", count = 5 } } }` after 5 logs go into slot 2.
- All four expected `nil` for an empty slot, "not false, not a stack with count 0, not an item called empty".
- All four expected an error, not `nil`, for a slot number that does not exist, "because nil already means this slot exists and is empty".
- All four said the stack size should not be passed when adding: "16 is a fact about logs, not about this call".
- All four expected `add` to put in what fits and return the number that did not fit, though none was sure.
- `Inventory`, `ItemStack` and `Hotbar` were unanimous names. `ItemRegistry` beat `ItemCatalog`, which "reads as a shop". Bare `Item` and `Container` were called ambiguous by nearly all. `ItemCursor` was the name every reader stumbled on.

**Test 2: predict what the code does.** Four readers predicted what 66 calls return. Two saw the comments and two saw only function names.
- With the comments: 66 of 66, both readers.
- From names alone: 63 and 64 of 66, with no prediction that was both confident and wrong.
- Their written answers were more useful than the scores. Both readers who saw the comments said, separately: `put`, `add` and `set` are three near-synonyms and nothing says "one slot" against "anywhere"; `CursorStack` "is not a stack, it is a holder"; `leftClick` and `rightClick` are "named after mouse buttons that the comment then spends a paragraph saying they are not"; `canMerge` is true for two full stacks, so it really means "same item"; a stack's `item` is an id, not an item type; and the header's claim that no function makes or loses an item was wrong for `set` and `clear`.

**Test 3: the same, after the renames.** Three fresh readers predicted 78 calls against the renamed pieces. The reader who had the comments got 78 of 78. The two who had only the function names and types each got 73, and missed the same five: three on what `addItems` returns (it returned how many did not fit, while every other number meant how many moved), one on merging stacks of different items (it raised an error), and one on counting an item that does not exist (it raised an error). Those five led to a third pass: `addItems` now returns how many were added, `merge` of different items returns both stacks as they were, `countItems` and `hasItems` answer 0 and `false` for an unknown id, and `take`, `place` and `takeCarried` became `pickUp`, `putDown` and `drop`. The third pass has not been put to readers.

**Test 4: the pieces added overnight (2026-11-19).** Two fresh readers predicted 35 calls on GroundItems and PlayerState, and on `ItemStack.validate` and `InventorySession.hasSlot`. Both ran on the cheaper Sonnet model. The reader who had the comments got 35 of 35. Its one doubt was the tie rule: "the one dropped first" was unclear for a ground item that had been joined later, so the comments now say "the one with the lower id". The reader who had only names and types got 31 of 35. All four misses came from two rules that names cannot carry: a stack dropped beside its own kind joins it only if the whole stack fits, and then counts as dropped at the later time (it guessed the stack would top the other up and keep the older time); and opening a second inventory screen is an error (it guessed the open one would be returned). Plot was written after this test.

**Test 5: Plot (2026-11-19).** Two more fresh readers, again on Sonnet, predicted 30 calls on Plot. The reader who had the comments got 30 of 30; it noted that the text never showed the arithmetic of `tileAt`, so both tile functions now carry a worked example. The reader who had only names and types got 29 of 30. Its miss: it expected `place` on a tile that is off the plot to return `nil`, as `place` does for a tile that is taken. It raises an error, as naming a slot that does not exist does in an inventory, and `hasTile` is the check to make first. That is one reader against the rule the first test's readers all expected for slots, so the rule stands, but it is the place to look if the user finds it odd.

**Test 6: the pieces added later that night (2026-11-19).** Two more readers on Sonnet predicted 32 calls on InventoryRequests and SaveData, and on `gather`, `doubleClick`, `swapWithHotbar` and `quickMove` with the pack open alone. The reader who had the comments got 32 of 32, but said the text never told it what each request does: InventoryRequests showed one function and a list of names, and sent the reader to Messages. Its header now has a table of the ten requests, what each is sent with and what each does. The reader who had only names and types got 22 of 32. Five of the ten misses followed from one rule, that `dropSelected` was ignored while a screen was open; the rule did no good and was removed. Three were its guess that a request with a slot that does not exist raises an error, as everywhere else in the code; here it is ignored, because this is the one piece whose input is not trusted, and only the comments can say so. One was `SaveData.encode` refusing while a screen is open.

---

# The four research briefs

## How Godot shapes its classes

Scope. I read the class reference for the sixteen classes named, plus TileMapPattern, AStar2D, MultiMesh, MeshLibrary, BitMap, PackedInt32Array and MeshInstance3D, from the XML on Godot's 4.7 branch (the source of the stable pages), and the engine C++ wherever the reference was silent. I also read the contributor best practices, the C++ naming rule, the documentation writing guidelines, the class reference primer, the GDScript style guide and the error-macro page.

The question that started this. No Godot class I read keeps a stand-in object for an empty slot or cell. Sparse structures have no entry. GridMap and TileMapLayer are hash maps from coordinates to cell data; clearing a cell erases the key; get_used_cells() returns the keys; a getter on an empty cell returns the 'none' of its return type (INVALID_CELL_ITEM, -1, Vector2i(-1, -1) or null). Where there is a bound, it is a separate number: TileMapPattern stores a size beside its cell map, and get_size() and get_used_cells() or is_empty() are different questions. ConfigFile goes one step further: deleting the last key of a section deletes the section. Where Godot does keep a dense, fixed set of slots (MeshInstance3D's material overrides), an unused slot is null and the count method is named for slots. One honest caveat: Godot's own Array has the trap the owner objected to. An Array resized to one null element reports size() 1. Godot avoids the confusion by choosing the sparse form and by naming the two counts apart.

Luau forces the same choice harder. A table cannot hold nil and # is undefined with holes, which is the only reason a false placeholder appeared. So a container is a record with a size and a map from slot index to stack, and an absent key means empty.

What makes a Godot class guessable.
- Names are verb_element_attribute with the handle first, as in set_item_text(idx, text), so one method predicts its siblings.
- A small verb set, one job each: add (put in), create (make and return), remove (take one out), clear (take everything out), has (entry exists), is (state), can (allowed), find (search, with a defined not-found result), pop (remove and return), move, rename.
- Position and identity are separate handles, index and id, with lookups both ways.
- The thing that knows where things are stores only ids; a shared resource says what an id means (GridMap with MeshLibrary, TileMapLayer with TileSet).
- Mutators check everything, then change, then signal; setting an equal value does nothing.
- A bad argument prints an error naming the value and returns a harmless default; ordinary failures are return values. The error-macro page tells contributors to "always try to return processable data so the engine can keep running well".
- Signals are past-tense facts carrying the smallest handle, as in animation_added(anim_name).
- Every class opens with one sentence saying what it is; every method description opens with its verb and states the return and the failure case.
- Contributor rules: a real problem first, one solution per problem, keep the solution local.

What not to copy. Godot never wrote down what its verbs mean. I found no such document, and its rename tracker (issue 16863) is a list of repairs. The results are visible: add_item returns an index on ItemList and nothing on PopupMenu; erase returns nothing on Array and a bool on Dictionary; remove and erase are interchangeable across classes; idx, index and position name the same parameter; counts are size(), length(), get_x_count() and get_x_list_size(); -1 means not found, none, last, append, automatic and all; some signals fire on changes made from code and some do not; adding under an existing name renames, replaces or errors depending on the class. Each of these is a place where a reader must look something up.

Recommendation. Before rewriting the inventory, write a one-page glossary for the whole codebase: the verbs and what each returns, the parameter order and names, the failure policy, the two count names (slot count and used slot count) and the doc-comment formula. Then build the container as a sparse record with an explicit size, and make the Minecraft-style screen a view that asks the module for the slot count and each slot's stack. Godot's consistency comes from many people repeating a few habits; its inconsistencies come from never fixing the vocabulary in writing. Starting from zero, this project can do the second part better than Godot did.

### What follows for the design

- A container record is { size: number, stacks: { [number]: Stack } }. An empty slot is an absent key: no false, no placeholder table, no stack with count 0.
- A one-slot container with nothing in it is { size = 1, stacks = {} }: slot count 1, used slot count 0, is_empty true.
- Never apply the length operator to the stacks table; loop from 1 to size and read each slot.
- Expose two named counts, get_slot_count and get_used_slot_count. No bare size, count or length that could mean either.
- get_stack(container, index) returns Stack? and gives nil for an empty slot. No sentinel numbers; Godot's -1 exists only because its typed returns cannot be null.
- A stack reduced to zero is removed by the same function that reduced it.
- A stack holds an item id and a count. Stack limit, name and everything else are read from the item definition, as a GridMap cell holds only an index into its MeshLibrary.
- Slot index (where) and item id (what) are separate handles; provide a lookup each way and never encode one in the other.
- Write the verb glossary before more modules: one meaning and one return rule per verb, the record as first parameter, the handle second, and one parameter name per concept (always index, never idx or position).
- can_x takes exactly the arguments of x, never mutates, and x must never disagree with it.
- State the failure policy once and repeat it in every doc comment: failures that are part of play are returned values; contract violations raise an error that includes the offending value; every check comes before the first write because there is no rollback.
- Setting a value equal to the current one produces no change record.
- Change records are past tense, carry the container and slot index only, and are issued after the state is final. Decide once whether a replacement is one record or a removal followed by an addition.
- The inventory screen is a separate client view that calls get_slot_count and get_stack; the rules module never touches an Instance.
- Every module file opens with one sentence a reader with no context can understand; every exported function's comment starts with its verb and says what it returns and what happens on an empty slot or an out-of-range index.
- Indices are 1-based with valid range 1 to size; no negative indices; nil instead of -1 for none.
- Do not add capacity reservation, metadata fields or no-signal variants until a caller needs them.
- When a function must change, add the replacement and mark the old one deprecated with a pointer to the new one, as Godot does with AStarGrid2D.size and TileMap.

### What the brief could not establish

- An official Godot document that defines the meaning of API verbs (add, remove, erase, clear, has, is, can) or boolean prefixes. The written rules stop at case, signal tense and documentation wording; the nearest project artifact is GitHub tracker issue 16863, which is an issue, not documentation.
- The standalone Code style guidelines page at its old address: docs.godotengine.org/en/stable/contributing/development/best_practices_for_engine_contributors.html and its siblings now return 404. The contributing docs moved to contributing.godotengine.org, where the naming rule is a four-line section of C++ rules and guidelines. I read only the headings of the old 4.4-branch code style page.
- An official statement on whether a signal should fire when the change is made from code. The class reference differs by class (Range, LineEdit, ItemList.select) and I found no rule.
- A built-in Godot class that is a fixed-size inventory. The nearest models are TileMapPattern (bounded and sparse) and MeshInstance3D's surface override materials (dense, null for unused).
- Documented failure results for several methods; these were taken from source instead: PopupMenu.get_item_index when no item has the id, ResourcePreloader.get_resource for a missing name, the meaning of Curve.add_point's return value, AnimationLibrary.add_animation on an existing name, InputMap.add_action on an existing action, TileMapPattern getters on a missing cell.
- What Tree.get_item_at_position returns when no item is at the position: the description does not say and I did not check the source.
- Runtime confirmation. Nothing was run in Godot; behaviour claims rest on the reference and on reading the C++ on branch 4.7. In particular I did not test that an Array resized to one element reports size 1, or that TileMapPattern.set_cell with default arguments makes has_cell return true.
- Whether TileMapLayer's saved data can include a cell that was erased but not yet removed by the batched update.
- A Luau-specific statement of the length operator's behaviour with holes. I relied on the Lua 5.1 manual and the Roblox tables page.
- Full coverage of Tree, TreeItem and Node: I read filtered subsets of their methods (creation, children, selection, buttons, groups, tree signals), not every member. Godot's internal C++ container templates (HashMap, Vector, LocalVector) were not read.

---

## FoxFabric: the user's own standard for a piece

WHAT THERE IS. FoxFabric is eight days old and nearly empty, so read this as one worked example plus a written philosophy, not a body of practice. Three public repositories carry the name. `foxfabric` is a hub: README, diagram, licence and one shared CI workflow, with no addon code. `foxfabric-template` holds the only addon, whose only class is `Adder`. `foxfabric-state-machine` is not linked from the README and is a byte-identical copy generated from the template; no state machine has been published. All the GDScript comes to 106 lines: adder.gd 24, demo.gd 39, tests.gd 43.

THE EXAMPLE IS THE STANDARD. The class comment in adder.gd says it is "A template showing how scripts in FoxFabric should be written." Its whole interface is: `class_name Adder` (extends Node); `signal added(result: float)`; `@export var offset := 0.0`; `@export var rounded := false`; `func add(x: float, y: float) -> float`.

WHAT IT SHOWS.
1. The name predicts the members: a noun for the thing (Adder), the bare verb (add), that verb in the past tense for the event (added), a noun for a quantity (offset), an adjective for a boolean (rounded). No project prefix.
2. Every value is typed and real. All 12 functions in the three scripts declare a return type. No script contains null, an untyped value, a sentinel or a placeholder, and no function returns a status code. A property at rest holds an ordinary value of its own type.
3. A method hands back its answer as a plain typed value and announces the same value by signal. The demo calls down (`adder.add(...)`) and listens up (`adder.added.connect(_on_adder_added)`). Wiring is written in code in `_ready`; the scene files hold no connections. Adder never mentions who uses it.
4. The piece stands alone. The tests do `Adder.new()`, call it, check, `free()`. No scene tree, autoload, plugin.cfg, base class of the owner's or other addon is needed. Setting a property only sets it; work happens when the verb is called.
5. Bad input is dealt with at the edge. Text becomes a number in the demo, behind an explicit `is_valid_float()` check with 0.0 as the fallback. The addon only ever receives floats.
6. Documentation is Godot's class reference to the letter: one `##` sentence per public member in four fixed forms ("A node that...", "Emitted when...", "If [code]true[/code], ...", "Returns ..."), cross-referencing members by name. Seven of adder.gd's 24 lines are these. No script has any other comment; private code is explained by its names and by test messages such as "3.5 should round up to 4".
7. Tests are a plain script with no framework: one function per behaviour, a four-line `_check(condition, message)` that counts and logs, and an exit code equal to the number of failures. The owner first committed a wrong value on purpose ("# this is intentional for rn") to watch CI fail, then fixed it. Tests and demo sit outside the addon folder, which carries its own README and LICENSE so that copying one folder is the whole install.

WHAT THE README ADDS. Three aims (simple, easy to maintain, fast to prototype) and one dislike (heavy frameworks and bloat). Pieces should combine because each has a very specific job, not because they know each other. The diagram draws a framework as a scribbled CORE tied to every module, with fused "integration" blobs, a DEPRECATED part still wired in and version-gated features; FoxFabric is six whole shapes and one arrow. The owner's edits across commits move one way, towards the concrete and the verified: "Modular systems" became "Micro-addons", "Adds numbers together." became "A node that adds numbers together.", and "Godot 4.7 or above" became "Tested on Godot 4.7".

WHAT IT DOES NOT TELL YOU. FoxFabric has no collection, no optional value, no lookup that can miss and no operation that can be refused. It sets no precedent for an empty slot, a missing item or a failed move. The rule for emptiness is the owner's own sentence in this project ("If something is empty... it is empty!"); FoxFabric agrees only in that nothing in it stands in for nothing. Take the forms for absence and refusal from Godot's own classes, whose conventions the template follows, then use one form everywhere.

ONE TENSION. The diagram mocks a central core, and the owner has also asked this game for "a solid core with lots of XML". Both hold if every piece can be built, read and tested alone, as Adder can, and the kernel is only where pieces are assembled, never something a piece needs in order to make sense.

### What follows for the design

- Treat adder.gd as the owner's written standard for the shape of a piece: a noun for the thing, typed properties with real defaults, verbs that return typed values, past-tense events with typed payloads.
- A reader who sees only a piece's name should be able to guess its members; a member that would surprise them belongs in a different piece.
- Nothing may stand in for nothing. FoxFabric contains no placeholder of any kind; an empty slot is an absent entry, and a count of things counts things.
- Type everything: Luau strict mode, every parameter and return annotated, no `any`. The template types 12 of 12 functions and is stricter than Godot's own documentation examples.
- When an operation cannot be refused, return the answer itself as a plain typed value that the next piece can consume directly.
- FoxFabric offers no pattern for a refused or failed operation. Choose one from Godot's classes, write it down once, and use the same form in every piece.
- A state-changing verb returns what happened and emits one past-tense event carrying the same data; consumers connect in code, in one visible place.
- A piece never names its consumers. Rules are called down into and listened to; presentation subscribes and is never referenced by rules.
- Setting data only sets it; work happens when a verb is called. No hidden reactions to a changed field (evidence: one class).
- Check untrusted input where it enters (client requests, saved data), so that rule functions only ever receive well-typed values.
- Every piece must construct and run with nothing else present. If its test needs the kernel booted, it is not yet a standalone piece.
- One thing per file, the file named after the thing; tests and demos beside the pieces and not inside them; a piece's directory can be lifted out whole.
- Tests are plain scripts: one function per behaviour, a message that states what should be true, every failure counted and logged, a non-zero exit code on failure. The owner's standard needs no test framework.
- Make each new test fail once on purpose before trusting it, as the owner did with CI.
- Document each public member with one sentence in a fixed form: 'A <thing> that...', 'Returns...', 'If true, ...', 'Emitted when...'. Do not comment private code; rename it.
- Give each piece a three-line usage example with its expected output, kept in exactly one place: the template's two README copies already disagree.
- State only what was verified ('Tested on...'), in documentation and in reports to the owner.
- Names are plain nouns and verbs with no project prefix.
- Draw dependencies the way the owner's diagram does: whole pieces and few direct arrows, no piece whose only job is to join two others, and nothing deprecated left wired in.
- Add behaviour by adding a piece, not by reaching into an existing one ('Add don't overwrite').
- Build nothing for a need that has not appeared: the owner lists Godot's rules that the problem comes first and must already exist.
- Keep this game's Claude-written code separate from FoxFabric and never present it as FoxFabric; its README states that all FoxFabric code is human-made.
- Weigh all of this as one 24-line example. Where FoxFabric is silent, the owner's direct statements in this project and Godot's class reference outrank inference from it.

### What the brief could not establish

- Any FoxFabric addon other than the template. The README lists one, and foxfabric-state-machine is an unmodified copy of the template, so no state machine interface could be reported.
- Any collection, optional value, null, or lookup that can miss in FoxFabric code. There is no direct evidence of how the owner represents an empty container or slot; that rule comes only from their statement in this project.
- Any operation that can fail or be refused inside an addon, and so any convention for reporting failure from a rule (error value, signal, log or assertion).
- Enums, constants, static functions, inner classes, custom resources, autoloads, editor plugins, multi-file addons, or one addon depending on another. None exists, so how the owner would write them is unknown. The diagram permits one arrow between pieces, but no code shows it.
- A test of a signal, or any asynchronous test.
- A documentation site, changelog, tag or release. Version numbers appear only as a line in each README, and the two copies disagree (v0.1.0 and v1.0.0).
- A source on the Fabric site for the owner's bullets 'Rapid Updates' and 'Add don't overwrite'. The front page supports 'modular' and 'lightweight' only; I did not search further.
- Whether the absences I list (no setters, no prefixes, no optional parameters and so on) are rules the owner holds or accidents of a 24-line example.
- Other Godot repositories on the same account, older than FoxFabric and not linked from it, appeared in the account listing and were not read, because the brief is limited to FoxFabric. They may show more of the owner's habits, with the caution that FoxFabric was started to replace logic the owner was tired of rewriting.
- The stable documentation pages for Timer, String and @GlobalScope. I read those three class references from the XML on the engine repository's master branch, so wording on the stable site may differ slightly.

---

## How Minecraft's inventory behaves, on PC and on phones

Minecraft's inventory is five small things, and the screen behaviour falls out of them. Mojang's names come first, with Fabric's older Yarn names in brackets, because the sources use both.

1. ItemStack. An item type, a count and per-stack data. Two stacks are the same item only if type and data both match. In memory, empty is one shared constant (EMPTY) that you test with isEmpty(); before 1.11 it was a null reference (modders' accounts from the time; I found no Mojang statement). Outside memory Minecraft never writes an empty stack. On the wire an empty slot is a count of zero and nothing else. On disk a chest saves only its occupied slots, each tagged with its slot number, and a saved item may not be air or have a count below 1.

2. Container [Inventory]. A fixed number of numbered slots: get, set, remove N, is-empty (every slot empty), a per-slot limit. The player's is 36 slots plus an equipment map and one integer, the selected slot. The hotbar is simply indices 0 to 8. The item in your hand is not stored anywhere; it is whatever is in the selected slot.

3. Slot. A view of one index of one container that carries the rules for that position: may this item go in, may the player take it, what is the limit. An output slot is just a slot that accepts nothing. Minecraft's Slot also carries its pixel position, which is the one part not to copy.

4. Menu [ScreenHandler]. Not a data holder. It is one player's session over some containers: an ordered list of slots (the container's own first, then the 27 storage slots, then the 9 hotbar slots), the cursor stack, and a revision number. The cursor stack belongs to the session and lives on the server; when the screen closes it goes back into the inventory or is dropped, never deleted.

5. Screen. Client only. It draws, and it turns input into one of seven action kinds (plain click, quick move, hotbar swap, clone, throw, drag, gather) with a slot number and a button. Double-click and drag detection live here, not in the rules.

Mouse and keyboard behaviour. The decision table in the findings is the whole of plain clicking. Left click moves everything. Right click takes half when picking up (the larger half goes to the cursor) and puts down one. The same item merges up to the limit and a full slot refuses. A different item swaps, on either button. Left-drag divides the held stack equally over the dragged slots and keeps the remainder on the cursor; right-drag places one in each. Double click fills the cursor stack from the whole screen. Shift-click sends the stack to the other section, topping up existing stacks first and then using the first empty slot; into a container it fills from the top left, back to the player it starts from the last hotbar slot. Number keys and F swap the hovered slot with a hotbar slot or the off-hand. Q drops one from the hovered slot and Ctrl+Q the whole stack. Clicking outside the window drops the cursor stack: left all, right one.

Phone behaviour is Bedrock's, and it is a different model. You select a stack in place and then name a destination: tap the item, tap the slot. Tapping an occupied slot swaps. Long-press a stack to choose an amount on a small bar that starts at half and slides, then tap the destination. Tap a stack and slide across empty slots to divide it equally. Tap outside the window, or long-press a hotbar slot, to drop. There is no hover, so names appear on selection, and no right click, so partial amounts come only from the long-press bar. Finger drag-and-drop was added later as an alternative. Bedrock's controller hints give ready names for the actions: Take, Take Half, Take One, Place, Place One, Swap, Quick Move, Drop.

Authority. The server, in both editions. Java replays input: the client runs the click itself, then sends the click, the revision it last saw and what it believes changed; the server runs the same click on its own copy and sends back only the slots where the client was wrong, or the whole window if the revision was stale. Bedrock sends intent instead: take N from this slot of this container to that one. There the cursor is just another named container, and each request gets a success or a named error.

Evidence quality. Mojang publishes no source for the Java click logic. The table rests on the Minecraft Wiki, the protocol documentation, the Fabric and NeoForge documentation, and CraftBukkit's branch-by-branch mirror of the vanilla code inside Paper's repository. Mojang's own published Bedrock language file and protocol definitions back the touch and request findings. What I could not confirm is listed separately; the main items are the internals of double click, whether Q is ignored while something is on the cursor, what double tap does on current Bedrock, and the touch timings.

Nothing under the project folder was changed and nothing was installed.

### What follows for the design

- A slot is either empty or holds a stack with a count of at least 1. A zero-count or placeholder stack must never be stored, saved or sent; Minecraft's own save format cannot express one.
- Minecraft's EMPTY constant is Java's stand-in for absence. In Luau absence is nil. Copy the contract (callers ask whether a slot is empty and never compare against a marker value), not the marker.
- Capacity and contents are separate facts. Keep the number of slots as an explicit number fixed for the container's life; never derive it from the length of the contents table, and do not call it the size of the contents.
- Saved and replicated containers should be a list of occupied slots, each with its index, as Minecraft's are.
- The hotbar is not a second container. It is a named range (the first nine indices) of the player's one container, plus a selected index.
- The held item is read from the selected index every time; it is never stored as its own field.
- Put the rules for a position (accepts this item, may be taken from, limit) on the slot, so click code has no per-container special cases. An output slot is a slot that accepts nothing.
- Keep screen position out of the slot rules. Minecraft's Slot mixes the two; this project's rule is that logic never knows about visuals.
- The cursor stack is session state owned by the server-side session, not by a container and not by the client. Closing the session must return it to the inventory or drop it into the world.
- Plain clicking is one pure function from (button, cursor stack, slot stack, slot rules) to (new cursor stack, new slot stack). The decision table is its test suite.
- What 'the same item' means (type plus per-stack data) should be decided once, in one function that every merge uses.
- The effective limit is the smaller of the item's stack size and the slot's limit. This is the same single knob the project already wants for bulky items.
- Quick move needs only data per screen: ordered destination ranges and a direction. The algorithm is fixed: top up equal stacks in scan order, then the first empty slot that accepts the item.
- Gesture recognition (double click, drag, long press, tap then tap) belongs to the client presentation. The rules receive discrete actions only.
- Java replays input (seven click kinds); Bedrock sends transfers with amounts (take, place, swap, drop). Mouse and touch can share one rule set only if the server API is the transfer form, with the cursor as one more addressable place. This choice should be made before the remote API is written.
- For phones, copy Bedrock and do not port right click: tap to select and tap to place, long press for an amount that starts at half, slide across slots to divide, and show the item name on selection because there is no hover.
- Every container update from the server should carry a revision and every client request the revision it was based on; a stale request gets a full resend. Minecraft documents its one update message without a revision as race-prone.
- Out-of-range slot access should have one defined behaviour. Minecraft's containers disagree with each other (some throw, some return empty).
- One open screen per player, with the player's own inventory implicitly always available, keeps server validation to a single question: is this the session this player has open, and is it still valid for them.

### What the brief could not establish

- Mojang's own source or documentation for the Java click algorithm. None is published. Per-cell results rest on the Minecraft Wiki, the protocol documentation, Fabric and NeoForge documentation, and CraftBukkit's mirror of the vanilla branches in Paper's repository (the Bukkit API itself calls its action value an estimation).
- Double click internals: the order in which stacks are drained (recollection: partial stacks before full ones, from the first slot upward) and the time window for a double click (recollection: 250 ms on the same slot with the same button).
- Whether the drop key is ignored while a stack is on the cursor (recollection: yes).
- Whether left click into an empty slot is capped at the slot's limit with the excess left on the cursor, and refused when the slot does not accept the item (recollection: yes to both). Only the same-item case is visible in sources.
- The exact rounding of the left-drag share. Sources say equal shares with the remainder on the cursor; integer division is implied, not shown.
- Whether hotbar scrolling wraps round at the ends.
- Which slot an item picked up from the world lands in.
- The limit on shift-click crafting: the wiki says up to one stack; NeoForge describes quick move repeating until the slot is exhausted or there is no room.
- Any statement from Mojang that stacks were null before 1.11. The evidence is two modder sources from November 2016 and a fan wiki; the Minecraft Wiki's 1.11 page records only the visible zero-count fixes.
- The network slot format before 1.20.5. The old wiki revision that documents it is behind a bot check, which I did not attempt to pass.
- Mojang's own pages for Bedrock touch changes: feedback.minecraft.net returned 403 and the legacy bug tracker refused connections. I used the wiki's transcriptions of the changelogs, Mojang's published language file and protocol definitions, the Minecraft Education help page, and the current bug tracker.
- Bedrock touch: whether a selected stack stays in its slot until a destination is tapped; whether tapping it again deselects; whether a highlight square is drawn. These appear only in an unconfirmed player bug report.
- Bedrock touch: what a double tap does on current versions when a chest is open (the wiki says consolidate; a player report says it moves the stack into the chest), and whether touch has any equivalent of shift-click.
- Bedrock touch timings: the long-press duration for splitting and for dropping from the hotbar (the wiki's 2 seconds is flagged there as unverified), and the default of the stack-splitting-time option whose string exists in the language file.
- How an odd count rounds when a Bedrock long press starts at half.
- Exact pixel offsets beyond those in the documentation (for example the hotbar row's offset) and the rule for when and how the count number is drawn on a slot.

---

## What Luau and Roblox do with tables that have gaps

Scope. Everything about Luau below was run on this machine (Lune 0.11.1; luau-lsp 1.70.1 under the old and the new solver). Nothing was run in the Roblox engine: what remotes, data stores and JSONEncode do rests on Roblox's documentation and staff posts.

1. No entry is how Luau says empty. Roblox's table guide says a table stores "values of any type that isn't nil", and that a pair is erased by setting it to nil. After slots[4] = nil, rawget and next find nothing, while { false } holds one entry. A slot table with missing keys is a Godot Dictionary[int, ItemStack]: slots[slot] is get(), assigning nil is erase(), next(slots) == nil is is_empty(). Two differences from Godot: there is no size() (count with a loop) and no insertion order.

2. Array tools give wrong answers on such a table, silently. For the same keys 1, 3 and 7, # returned 1, 3 or 7 depending on how the table had been built. ipairs and table.find stop at the first gap. table.insert and table.remove work from #: table.remove(t) deleted key 1 in one build and key 7 in another. for slot, stack in slots visits every entry, but in slot order only by accident: a 9-slot table came out of order in 7 of 5,000 random states, a 36-slot table in 4,865. The checker cannot help: { T } and { [number]: T } are one type, and it accepts every one of these calls. So keep slotCount (nothing else knows it), touch the table only by key, and walk it with for slot = 1, slotCount whenever order matters. A table has no bounds either: writing slot 99 or 2.5 creates an entry.

3. The checker does not know a slot may be empty. slots[slot] is typed ItemStack, not ItemStack?, in both solvers and through a read-only indexer, so slots[slot].count passes and fails at run time. A function declared to return ItemStack? restores the check, and if stack then narrows it. Narrowing does not carry across two writings of slots[slot]: take a local.

4. Frozen values work, with catches. A write to a frozen table is an error at the line of the write. Freezing is shallow: through a frozen stack I changed its definition's stackSize, so definitions need their own freeze. Freezing twice is an error. Two equal frozen stacks are not ==. The solvers disagree about types. The project's check already runs the new solver with read fields, and that combination holds together: a frozen literal gets read-only fields, a factory needs no cast, writes are reported, and a record holding a richer definition is accepted where one holding a smaller type is expected. Its costs: table.clone of a read-only value stays read-only to the checker, so build a new literal instead of clone-and-edit; and the old solver rejects the syntax ("read keyword is illegal here"), which Studio would show for strict scripts if the place still runs the old solver.

5. Definitions as tables. A richer definition is accepted where { id, stackSize } is expected, whether it comes from a literal, a typed variable or a module export. Under the new solver a frozen one is refused unless the expected fields are marked read. The stack's item is then seen as the smaller type; a generic StackOf<T> keeps the caller's type. Callers name a module's types through their own local: Items.ItemType.

6. The slot table must never be handed to a remote, a bindable, a data store or JSONEncode. Roblox staff: replication "only supports string->Variant maps and arrays without gaps"; data stores support "arrays (integer keys without any nil gaps) and maps with string keys. Anything else ... is undefined behavior." The data store page: "Numeric keys are translated into strings if the length of the table is 0." So with slot 1 empty the keys come back as the strings "2" and "5" and every slots[2] lookup finds nothing; with slot 1 filled the list is cut at a gap. Ten of eleven publicly reported outcomes are consistent with # computed here for the same tables. Which failure appears depends on which slots are filled, so it can pass a test and fail in play. Copies also lose identity, metatables and functions, so a definition table cannot cross either.

7. The plain form. { slotCount = 9, stacks = { { slot = 2, item = "apple", count = 3 }, ... } }. Every table in it is a gap-free list or a string-keyed record; values are strings, booleans and finite numbers; items go by id. Reading it back is validation, not a cast: a typed parameter checks nothing at run time, and NaN is a "number" that fails every comparison. A prototype, (session scratchpad), passes both solvers, Selene and StyLua under the project's settings, and a run that round-trips through JSON and refuses seven kinds of bad entry.

Every script is kept, with its output in (session scratchpad) and (session scratchpad) Nothing under the project folder was changed.

### What follows for the design

- Keep slotCount in the record: nothing else knows how many slots there are. #slots returned 0 for stacks in slots 2 and 5, and 1 for stacks in slots 1 and 5.
- Touch the slot table only by key: read slots[slot], write slots[slot] = stack, empty with slots[slot] = nil. Never use #, ipairs, table.insert, table.remove, table.find, table.unpack or table.sort on it. The type checker accepts all of them without complaint, so only the rule and the tests stop a mistake.
- Where order matters (drawing slots, first free slot, lowest slot first) use for slot = 1, slotCount. for slot, stack in slots is correct only where order does not matter, such as a total.
- Empty is next(slots) == nil. The number of used slots is a loop; there is no built-in count.
- The piece must check the slot number itself (a whole number from 1 to slotCount). A table accepts any key, so slot 99 or 2.5 would otherwise be stored without error.
- Give callers a function that returns ItemStack? for a slot. Indexing the table directly is typed as never nil under both solvers, so the checker will not ask for the check.
- Make stacks in one factory that returns table.freeze({ item = ..., count = ... }). With read fields under the new solver no cast is needed and the checker reports writes. With plain fields the factory needs :: ItemStack and a write is caught only at run time.
- To change a stack, build a new literal. Do not table.clone and edit: the new solver reports the edit.
- Freeze each item definition when it is registered, including any tables inside it, testing table.isfrozen first because freezing twice is an error. A frozen stack does not protect the definition it points at.
- Compare stacks with a function (same item, same count). == is identity, and every replaced stack is a new table.
- If stacks point at definition tables, the plain form must carry the item's id. A table that crosses a remote or a data store is a copy: identity and metatable are lost, frozenness cannot be relied on, and functions inside a definition arrive as nil. Both sides register the same definitions and look them up by id.
- Convert to and from the plain form in one place. Nothing else may hand an inventory, its slot table, a stack or a definition to a RemoteEvent, RemoteFunction, BindableEvent, data store or JSONEncode.
- Plain form: { slotCount = n, stacks = { { slot = 2, item = "apple", count = 3 }, ... } }, entries in ascending slot order, stored beside the save's version number. Every table is a gap-free list or a string-keyed record. No nil inside a list, no number keys other than 1..n, no table with both kinds of key, no functions, metatables, Instances, NaN or infinity, and only valid UTF-8 strings.
- An empty inventory is stacks = {} in the plain form, not a list of placeholders. JSONEncode writes an empty table as [].
- Reading the plain form is validation, not a cast: read each field as unknown, narrow it with type(), check whole numbers in range, no slot twice, a known item id and a count from 1 to the stack size, then rebuild frozen stacks. Under the new solver, cast to { [string]: unknown } after the type(x) == "table" test or the fields cannot be read.
- Tests of the plain form need one inventory with slot 1 empty and one with slot 1 filled and a later gap. Those are the two different ways the raw slot table fails. A test with slots 1 to n all filled proves nothing.
- If the slot table were ever saved raw, a load could return string keys, and slots[2] would then find nothing: the inventory would look empty and raise no error.
- The code uses read fields, which only the new solver accepts. Set Workspace.UseNewLuauTypeSolver to Enabled in the place; otherwise Studio's own analysis may report 'read keyword is illegal here' on every such module. Running the code is not affected by the type solver.
- If the inventory piece declares its own small item type, callers see stack.item as that small type. Choose on purpose between the small type (callers cast), a generic stack type (keeps the caller's type; checked under both solvers) and the registry's own type (the piece depends on the registry).
- One saved entry such as {"count":3,"item":"apple","slot":2} is 35 characters against a limit of 4,194,304 per key, so the readable record form is affordable. A denser form would solve a problem that does not exist yet.

### What the brief could not establish

- Nothing was run in the Roblox engine. Every statement about RemoteEvent, RemoteFunction, BindableEvent, data stores and HttpService:JSONEncode comes from documentation, Roblox staff posts and user reports. A short Studio test that sends each of the eight shapes through a RemoteEvent, a BindableEvent, JSONEncode and SetAsync/GetAsync and prints what arrives would settle them.
- The exact rule for a list with a gap sent through a remote today. Reports from 2023 follow the length operator; a 2025 report (keys 1 to 99 with 23 and 64 cleared arriving as 1 to 22) does not match the length computed here (99). The documentation no longer states a rule, only 'avoid nil values for any index'.
- Whether a frozen table arrives frozen through a remote or a bindable, and whether a table loaded from a data store is frozen. No documentation or staff statement was found.
- What HttpService:JSONEncode writes for a sparse number-keyed table. Its entry only says to avoid nil; the expected result is inferred from the data store rule about length 0.
- What JSONEncode and data stores do with a table that has a metatable. Not stated in the pages read.
- A current documentation sentence about nested tables in remote arguments. The older wording could not be retrieved: the public documentation repository's history for the remote page starts on 2023-08-29, after that section was rewritten.
- Whether NaN or infinity saved from the engine reads back as the same number through GetAsync. The documentation says not to store them and shows only how Open Cloud represents them.
- Whether Studio today runs the new solver for --!strict scripts by default. The 2025-11-20 announcement left strict mode on the old solver unless opted in and promised the old one 'through 2026'; the rollout state behind Workspace.UseNewLuauTypeSolver = Default was not checked, and Studio was not opened.
- Whether Roblox's own script compiler accepts the read keyword everywhere the project uses it. Lune 0.11.1 ran such a file; Roblox was not tried.
- Which Luau release luau-lsp 1.70.1 embeds, and whether Studio's analysis gives the same messages. Lune reports itself as 0.11.1+740; Roblox's VM version was not compared.
- Any guarantee that a slot table created with table.create(slotCount) iterates in ascending order. It did in 10,000 measured states, but the documentation promises order only for the gap-free run 1..#t.
- Size limits for the arguments of one remote call. Not looked up; the remote page points to the RemoteEvent and UnreliableRemoteEvent references for throttling and payload limits.

---

# Names for the next pieces

Five readers with no context (a Godot developer, a Minecraft modder, a Roblox developer, a backend programmer and a RimWorld modder) each read ten plain descriptions with no names, and said what they would call each thing, which functions they would expect, and how "nothing" should appear in it. They were told the five existing pieces by name.

| | The thing described | First choices | Second choices |
|---|---|---|---|
| I | One player's open inventory screen, rules only: which inventories are shown, the carried stack, what each click does, shift-click, and closing. | InventorySession (4), ContainerMenu (1) | ContainerMenu (2), OpenInventory (1), ScreenHandler (1), InventoryScreen (1) |
| J | All the stacks lying on the ground in the world, each at a position; picked up, dropped, and gone after a while. | GroundItems (3), DroppedItems (2) | DroppedItems (2), GroundItems (2), DroppedStacks (1) |
| K | The written list that says what every kind of item is: one row per kind, which people edit to add content. | ItemDefs (2), ItemDefinitions (2), Items (1) | Items (4), ItemDefinitions (1) |
| L | A player's piece of land: a grid of square tiles on which they place things. | Plot (5) | PlotGrid (3), Land (2) |
| M | One thing placed on that land: which kind of item, which tile, which way it faces. | PlacedItem (3), PlacedObject (1), PlacedThing (1) | Placement (3), PlacedItem (1), Building (1) |
| N | The rule that some inputs become some outputs after some time at a kind of station. | Recipe (5) | Recipes (3), RecipeRegistry (1), RecipeDef (1) |
| O | Everything in one running copy of the game world that the rules need to know about. | World (5) | GameState (4), WorldState (1) |
| P | One player, as far as the rules are concerned: pack, hotbar, what they have open, where they stand. | PlayerState (3), Player (2) | Player (3), PlayerState (2) |
| Q | Turning a player's pack and land into plain data that can be stored and loaded, with a version number. | SaveData (3), PlayerSave (2) | Serializer (3), PlayerSave (1), SaveData (1) |
| R | The space a kind of item takes up when placed, and how it turns to face four ways. | Footprint (5) | TileRect (1), Shape (1), GridSize (1), Dimensions (1), OccupiedRect (1) |

## I. One player's open inventory screen, rules only: which inventories are shown, the carried stack, what each click does, shift-click, and closing.

**Godot reader:** `InventorySession`, or `OpenInventory`, in `inventory`.

- `open(pack, other?) -> session : start a screen over the player's pack, plus a crate's inventory if one was opened; nothing carried yet`
- `click(session, which, slotIndex, button) -> boolean : left or right click on a slot of either inventory, handing the pick-up/put-down/split to CursorStack; true if anything changed`
- `quickMove(session, which, slotIndex) -> boolean : the shift-click; push that slot's stack into the other inventory (or between hotbar and the rest of the pack when only the pack is open), merging first, then empty slots; what does`
- `clickOutside(session, button) -> ItemStack? : click off the panel; returns the carried stack (or one of it) for the caller to drop on the ground`
- `getCursor(session) -> ItemStack? : the carried stack, so the client can draw it under the pointer`
- `close(session) -> ItemStack? : put the carried stack back into the pack; returns whatever did not fit so the caller can drop it`
- **Data as they would expect it printed:** { pack = <Inventory>, -- the player's own, always there other = <Inventory> or nil, -- the crate, when one is open otherSource = 17 or nil, -- id of the placed crate, so the screen can be shut if the crate is broken cursor = { itemId = "log", count = 12 }, -- or nil } I am guessing the stack's field names. I would not know whether click changes the tables in place or returns new ones; I would guess in place.
- **Nothing:** No screen open means there is no session at all (the player's 'open' field is nil), not a session showing zero inventories. Pack alone means other = nil. Nothing carried means cursor = nil, since there is no empty stack. After close the session is thrown away; close returns nil when the carried stack went back cleanly.
- **Would not expect to find here:** Anything drawn or pointed at: slot widgets, mouse position, the dragged icon, tooltips. Also not the check that the player is still standing near the crate; I would look for that in whatever accepts requests from clients.

**Minecraft reader:** `ContainerMenu`, or `ScreenHandler`, in `inventory`.

- `open(pack: Inventory, other: Inventory?) -> Menu -- starts a screen over the pack alone, or the pack plus one crate, with nothing carried`
- `click(menu, slot: number, button: "left" | "right") -> boolean -- an ordinary click on one slot: pick up, put down, swap, take half, place one; true if anything changed`
- `quickMove(menu, slot: number) -> boolean -- shift-click: sends that slot's stack to the other inventory, topping up matching stacks first and then empty slots; what does not fit stays where it was`
- `clickOutside(menu, button: "left" | "right") -> ItemStack? -- a click off the screen while carrying: hands back the carried stack (one item of it on a right click) for the caller to drop on the ground`
- `close(menu) -> ItemStack? -- the screen closes: the carried stack goes back into the pack; returns whatever did not fit so the caller can drop it`
- `stillValid(menu, player) -> boolean -- is the crate still there and the player still close enough; the server closes the screen when this turns false`
- **Data as they would expect it printed:** { id = 7, -- counts up each time this player opens a screen (Minecraft's window id) inventories = { <crate>, <pack> }, -- references to the live Inventory tables; just { <pack> } for the pack alone carried = { id = "log", count = 12 }, -- the CursorStack; nil when nothing is carried } -- Slot numbers run through the inventories in order: the crate's 1..27, then the pack's 28..63. That is how Minecraft numbers them (the other inventory first, the player's after). A pair of (which inventory, slot) would not surprise me either and would be easier to read.
- **Nothing:** Nothing carried: carried = nil, since there is no empty stack. My Minecraft reflex is ItemStack.EMPTY and I would have to unlearn it. Pack alone: the inventories list has one entry. Nothing open: there is no menu table at all and the player's 'open' field is nil. Minecraft never has 'nothing open' (the player's own inventory menu is always the current one) and I would half expect that trick here. A click off the screen is its own function, not a magic slot number like Minecraft's -999.
- **Would not expect to find here:** Anything about how the screen looks: slot positions in pixels, frames, icons, tooltips, drag highlighting. (Minecraft's Slot does carry x and y, and it is a known wart.) I would also be surprised to see the take-half and place-one arithmetic written out again here when CursorStack already has it; I expect this module to work out which slot was meant and call that.

**Roblox reader:** `InventorySession`, or `ContainerMenu`, in `Inventory`.

- `open(pack: Inventory, other: Inventory?) -> InventorySession -- start a screen showing the pack alone, or the pack plus one other inventory, with nothing carried`
- `click(session, side: "pack" | "other", slot: number, button: "left" | "right") -> boolean -- do what a Minecraft click on that slot does (pick up, put down, swap, take half, place one), leaning on CursorStack; true if anything cha`
- `quickMove(session, side: "pack" | "other", slot: number) -> boolean -- shift-click: send that slot's stack to the other inventory as far as it fits (with the pack alone, between the hotbar and the rest)`
- `close(session) -> ItemStack? -- put the carried stack back into the pack and end the session; returns whatever did not fit so the caller can drop it on the ground`
- `getCarried(session) -> ItemStack? -- the stack being carried, or nil`
- `getInventory(session, side: "pack" | "other") -> Inventory? -- the inventory behind a side; nil for "other" when the pack is open alone`
- **Data as they would expect it printed:** { pack = <Inventory>, -- the player's own pack table, not a copy other = <Inventory>, -- the crate's inventory; nil when the pack is open alone cursor = { itemId = "log", count = 5 }, -- the carried stack; nil when nothing is carried } -- I would not know whether the inventories are held by reference like this or by an id looked up in the world, nor whether cursor is a bare ItemStack? or a CursorStack wrapper table.
- **Nothing:** No screen open: there is no session table at all (the player's 'open' field is nil), not a session marked closed. Nothing carried: cursor = nil, never a stack with count 0. Pack open alone: other = nil. A click on an empty slot with nothing carried changes nothing and returns false.
- **Would not expect to find here:** Anything that draws or listens for input: a ScreenGui, Frames, drag visuals, UserInputService. The description says 'screen' but I expect rules only.

**General reader:** `InventorySession`, or `InventoryScreen`, in `inventory`.

- `open(pack, other) -> session. Starts a session showing the player's pack and, if given, a second inventory such as a crate. Nothing carried yet.`
- `click(session, which, slot, button) -> ok, reason. Applies a left or right click to slot N of the pack or the other inventory: pick up, put down, merge or swap with the carried stack.`
- `quickMove(session, which, slot) -> number moved. The shift-click: sends that slot's stack to the other inventory, as much as fits. With only the pack open I would guess it moves between the hotbar and the rest, but I would not kno`
- `close(session) -> leftover ItemStack or nil. Puts the carried stack back in the pack and returns whatever did not fit, so the caller can drop it on the ground.`
- `carried(session) -> ItemStack or nil. The stack on the cursor right now.`
- `inventories(session) -> list of Inventory. Which inventories are shown, pack first.`
- **Data as they would expect it printed:** { pack = <the player's Inventory>, other = <the crate's Inventory>, -- nil when only the pack is open cursor = { itemId = "log", count = 12 }, -- nil when nothing is carried } I would not know whether it holds the inventories themselves or only ids such as "crate 17".
- **Nothing:** Nothing open: no session exists at all (the player's 'open' field is nil), not a session with zero inventories. Pack alone: 'other' is nil. Nothing carried: cursor is nil, never a stack with count 0.
- **Would not expect to find here:** Pixel positions, mouse coordinates, which key means quick-move, or anything that draws slots. I would expect it to be told 'left click, pack, slot 5' and no more. I would also not expect the merge and split arithmetic itself, which I assume is already in CursorStack and ItemStack.

**Rimworld reader:** `InventorySession`, or `ContainerMenu`, in `inventory`.

- `open(pack, other) -> session; starts a screen on the pack alone (other = nil) or the pack plus a crate's inventory, with nothing carried`
- `click(session, which, slot, button) -> boolean (did anything change); a left or right click on one slot of one of the shown inventories, passed on to CursorStack for the pick up / put down / swap / split rules`
- `quickMove(session, which, slot) -> number moved; shift-click: sends that slot's stack to the other inventory (pack alone: between the hotbar and the rest), topping up matching stacks first and leaving behind what does not fit`
- `close(session) -> ItemStack or nil; puts the carried stack back in the pack and returns whatever did not fit, so the caller can drop it on the ground`
- `carried(session) -> ItemStack or nil; what is on the cursor right now`
- `inventories(session) -> pack, other or nil; which inventories this screen is showing`
- **Data as they would expect it printed:** { pack = <the player's Inventory>, other = <the crate's Inventory>, -- nil when the pack is open alone otherThingId = 17, -- which placed crate, so the screen can be shut if the crate is broken cursor = { itemId = "log", count = 6 }, -- nil when nothing is carried } I would expect it to point at the live inventories, not hold copies of them.
- **Nothing:** Nothing open: there is no session table at all (the player's 'open' field is nil), not a session with a closed flag. Nothing carried: cursor = nil, since there is no empty stack. Pack open alone: other = nil.
- **Would not expect to find here:** Anything about drawing: where slots sit on screen, icons, which pixel the mouse is on. (I would also expect the merge and split arithmetic to stay in ItemStack, Inventory and CursorStack and only be called from here.)

## J. All the stacks lying on the ground in the world, each at a position; picked up, dropped, and gone after a while.

**Godot reader:** `GroundItems`, or `DroppedItems`, in `world`.

- `new() -> ground : an empty collection`
- `drop(ground, stack, position, now) -> id : add a stack lying at a position, stamped with the time; might merge into a same-item stack right next to it`
- `inRange(ground, position, radius) -> { id } : what a player standing here could pick up`
- `get(ground, id) -> { stack, position, droppedAt }? : look one up`
- `take(ground, id, count?) -> ItemStack? : remove all or part of a lying stack so it can go into a pack; nil if someone else got it first`
- `expire(ground, now) -> { id } : remove stacks older than the lifetime and return the ids that vanished`
- **Data as they would expect it printed:** { nextId = 4, byId = { [1] = { id = 1, stack = { itemId = "log", count = 12 }, position = { x = 10.5, y = 0, z = 4.2 }, droppedAt = 1532.5 }, [3] = { id = 3, stack = { itemId = "raw_fish", count = 1 }, position = { x = 11.0, y = 0, z = 6.0 }, droppedAt = 1601.0 }, }, } I would not know what Roblox's vector type is called; in Godot the position would be a Vector3.
- **Nothing:** Nothing on the ground is an empty byId table, never nil. A stack that was picked up or timed out is simply gone: get returns nil. A half-taken stack stays with a smaller count; a zero-count stack never lies there.
- **Would not expect to find here:** The visible lying object: its model, bobbing, falling physics, or the 'pick up' prompt. I would also be surprised if it decided whether the player's pack has room; I would expect it to hand over a stack and take back the leftover.

**Minecraft reader:** `DroppedItems`, or `GroundItems`, in `world`.

- `drop(ground, stack: ItemStack, position: Vector3) -> number -- puts a stack on the ground at a spot and returns its id; I would half expect it to merge into a matching stack lying right there, as Minecraft does`
- `pickUp(ground, id: number, into: Inventory) -> number -- moves as much of that stack as fits into the inventory and returns how many went; removes the entry when none is left, otherwise the rest stays on the ground`
- `near(ground, position: Vector3, radius: number) -> { number } -- ids of the stacks within reach of a point`
- `get(ground, id: number) -> DroppedItem? -- one entry: its stack, position and age`
- `remove(ground, id: number) -> ItemStack? -- takes an entry off the ground and hands back its stack`
- `tick(ground, dt: number) -> { number } -- ages every stack, removes the ones left too long, returns the ids removed`
- **Data as they would expect it printed:** { nextId = 43, items = { [41] = { stack = { id = "log", count = 12 }, position = Vector3.new(10.5, 0, -3.2), age = 37.5 }, [42] = { stack = { id = "crate", count = 1 }, position = Vector3.new(4, 0, 9), age = 2.0, pickupDelay = 0.5 }, }, } -- I am assuming Roblox has a Vector3; otherwise { x, y, z }. Ages in seconds. Minecraft counts ticks and removes a dropped stack at 6000, which is five minutes.
- **Nothing:** Nothing on the ground: items = {}. A stack that is picked up or times out has its entry removed outright (the key goes to nil). I would not expect an entry left behind with count 0 or a 'removed' flag. get() on an id that is gone returns nil. No 'air' or placeholder stack anywhere.
- **Would not expect to find here:** Choosing which slot of the pack a picked-up stack goes into; that is Inventory's insert. Nor the bobbing, spinning model or any physics of the thing falling: this should only know where each stack rests.

**Roblox reader:** `DroppedItems`, or `GroundItems`, in `World`.

- `new() -> DroppedItems -- an empty collection`
- `drop(dropped, stack: ItemStack, position: Vector3, now: number) -> number -- add a stack lying at a position; returns its id`
- `pickUp(dropped, id: number, into: Inventory) -> ItemStack? -- move as much as fits into the inventory; removes the entry if all of it went, returns what stayed on the ground (nil if none)`
- `findNear(dropped, position: Vector3, radius: number) -> { number } -- ids of the stacks within reach of a point`
- `get(dropped, id: number) -> DroppedItem? -- one entry, or nil if it has gone`
- `expire(dropped, now: number) -> { number } -- remove every stack left too long; returns the removed ids so their visuals can be cleared`
- **Data as they would expect it printed:** { nextId = 4, items = { [1] = { stack = { itemId = "log", count = 12 }, position = Vector3.new(10, 0.5, -4), expiresAt = 1832.5 }, [3] = { stack = { itemId = "raw_fish", count = 1 }, position = Vector3.new(12, 0.5, 3), expiresAt = 1840 }, }, } -- I would not know whether position is a Vector3 or a plain { x, y, z }, or whether nearby stacks of the same kind merge.
- **Nothing:** Nothing on the ground: items = {} (an empty table, never nil). A stack fully picked up or timed out: its entry is removed, so the key reads nil; never an entry left behind with count 0. findNear returns {} and get returns nil.
- **Would not expect to find here:** Parts, ProximityPrompts or Touched connections for the stack lying there. That is the visible side; I expect only ids, stacks, positions and times here.

**General reader:** `GroundItems`, or `DroppedItems`, in `world`.

- `new() -> ground. An empty collection.`
- `drop(ground, stack, position, now) -> id. Puts a stack on the ground at a position, stamps it with the time, returns its id.`
- `pickUp(ground, id, inventory) -> leftover ItemStack or nil. Moves as much as fits into the inventory and removes the entry when all of it is taken.`
- `near(ground, position, radius) -> list of entries. What a player standing there could reach.`
- `get(ground, id) -> entry or nil. One ground stack by id.`
- `expire(ground, now) -> list of removed ids. Removes everything that has lain longer than the lifetime.`
- **Data as they would expect it printed:** { nextId = 43, entries = { [41] = { id = 41, stack = { itemId = "log", count = 12 }, position = { x = 10.5, y = 0, z = -3.2 }, droppedAt = 120.0 }, [42] = { id = 42, stack = { itemId = "raw_fish", count = 1 }, position = { x = 11, y = 0, z = -3 }, droppedAt = 131.5 }, }, } I would not know whether a position is a plain table like this or a built-in vector type, or which axis is up.
- **Nothing:** Nothing on the ground: entries is an empty table, never nil. A stack that was picked up or has expired has its entry deleted, and get(id) then gives nil. A partly picked-up stack stays with a smaller count; it never lies there with count 0.
- **Would not expect to find here:** Falling, bouncing or any physics, the 3D model, or its own timer. I would expect the caller to pass in the current time. I would also be surprised to find nearby stacks merging into one unless I had been told; Minecraft does it, but the description does not say so.

**Rimworld reader:** `GroundItems`, or `DroppedStacks`, in `world`.

- `drop(ground, stack, position, now) -> id; puts a stack on the ground at a position and remembers when (I would half expect it to merge into a matching stack lying close by, as Minecraft does)`
- `pickUp(ground, id, inventory) -> ItemStack or nil; moves as much as fits into the inventory, returns what is still on the ground, and removes the entry when all of it went`
- `near(ground, position, radius) -> list of entries; what a player standing there can reach`
- `get(ground, id) -> entry or nil; one lying stack by its id`
- `remove(ground, id) -> ItemStack or nil; takes one out whole`
- `expire(ground, now) -> list of ids removed; deletes stacks that have lain longer than the limit`
- **Data as they would expect it printed:** { nextId = 4, items = { [1] = { id = 1, stack = { itemId = "log", count = 12 }, position = { x = 10.5, y = 0, z = -3.2 }, droppedAt = 1532.0 }, [3] = { id = 3, stack = { itemId = "raw_fish", count = 1 }, position = { x = 11.0, y = 0, z = -3.0 }, droppedAt = 1540.5 }, }, } From RimWorld I would half expect whole-cell positions with one stack per cell; the words 'position' and 'walk up' tell me free positions as in Minecraft. I would not know what Roblox's own position type prints as.
- **Nothing:** Nothing on the ground is an empty items table ({}), never nil. A stack that was fully picked up or has expired is gone from the table; I would not expect an entry left behind with count 0 or a 'despawned' flag. Asking for an id that is not there gives nil.
- **Would not expect to find here:** The spinning or bobbing model, the pick-up sound or the on-screen prompt. This should be a list of stacks, places and times and nothing you can see.

## K. The written list that says what every kind of item is: one row per kind, which people edit to add content.

**Godot reader:** `ItemDefs`, or `Items`, in `data`.

- `(none expected) : I would expect the file to be just 'return { ...rows... }' with no functions`
- `all() -> { ItemDef } : if it has anything, the whole list in written order`
- `ItemRegistry.get(id) -> ItemType? : I would look for lookup by id in ItemRegistry, not here`
- `ItemRegistry.isPlaceable(id) -> boolean : 'can this kind do X' questions I would also look for on ItemRegistry`
- `ItemRegistry.fuelSeconds(id) -> number? : same; nil when the kind is not fuel`
- `validate(rows) -> boolean, { string } : duplicate ids, stackSize below 1, misspelled fields; I would half expect this in a separate checker run at startup or in tests`
- **Data as they would expect it printed:** { { id = "log", stackSize = 64, fuel = { seconds = 15 } }, { id = "raw_fish", stackSize = 16 }, { id = "crate", stackSize = 1, placeable = { width = 1, depth = 1 }, container = { slots = 27 } }, { id = "stove", stackSize = 1, placeable = { width = 1, depth = 1 }, station = { kind = "stove" } }, { id = "workbench", stackSize = 1, placeable = { width = 2, depth = 1 }, station = { kind = "workbench" } }, } A list of rows, because the description says each row has its id; a map keyed by id would not surprise me either. From Godot habit I would also half expect a display name and icon on each row.
- **Nothing:** A kind that cannot do something just lacks that field (nil), not 'placeable = false' and not an empty table. There is no row for 'nothing' or 'air'. Asking for an id that is not in the list gives nil, or an error if it is a typo in other content.
- **Would not expect to find here:** Code. No functions or callbacks on a row, and no recipes; I would expect only plain values that someone who does not program could edit.

**Minecraft reader:** `Items`, or `ItemDefinitions`, in `data (my datapack reflex; 'content', the description's own w`.

- `None in the list itself: I expect the file to be 'return { ...rows... }' and nothing else. The functions I expect sit on ItemRegistry, as follows.`
- `ItemRegistry.get(id: string) -> ItemType? -- the row for an id`
- `ItemRegistry.all() -> { ItemType } -- every row, in the order written`
- `ItemRegistry.load(rows) -> () -- reads the list once at startup, errors on a duplicate id or a malformed row, after which nothing can be added (Minecraft freezes its registries the same way)`
- `ItemRegistry.isPlaceable(id: string) -> boolean -- with siblings such as slotCount(id) -> number? and fuelSeconds(id) -> number?, one per thing a kind can do`
- `validate(rows) -> (boolean, { string }) -- a check run in tests: unique ids, stackSize at least 1, no unknown fields, a footprint only on rows that can be placed`
- **Data as they would expect it printed:** return { { id = "log", stackSize = 64, fuel = { seconds = 15 } }, { id = "raw_fish", stackSize = 16 }, { id = "cooked_fish", stackSize = 16 }, { id = "crate", stackSize = 16, placeable = { footprint = { 1, 1 } }, container = { slots = 27 } }, { id = "stove", stackSize = 1, placeable = { footprint = { 1, 1 } }, station = "stove" }, { id = "workbench", stackSize = 1, placeable = { footprint = { 2, 1 } }, station = "workbench" }, } -- ids as lower_snake_case strings; Minecraft would namespace them ("game:log"). A list of rows rather than a map keyed by id, so the written order is kept.
- **Nothing:** A kind that cannot do something simply has no field for it: no 'placeable' key means it cannot be placed, no 'fuel' key means it does not burn. I would not expect placeable = false or fuel = 0. An id with no row does not exist: ItemRegistry.get returns nil, and I would hope for a loud error at load time rather than Minecraft's habit of quietly handing back air for an unknown id. I would expect no 'air' or 'empty' row, since there is no empty stack.
- **Would not expect to find here:** Code. A row with a function in it (onUse = function ... end) would surprise me in a list people edit; I expect plain values only, with the behaviour in rules code that reads the row. Second surprise: the recipe that makes the item, which is N's list.

**Roblox reader:** `ItemDefinitions`, or `Items`, in `Data`.

- `(none of its own) the module returns the table of rows -> { ItemDefinition } -- I expect data here, not functions`
- `ItemRegistry.get(id: string) -> ItemType? -- the lookup I'd expect to sit over this list, not in it`
- `ItemRegistry.all() -> { ItemType } -- every kind, for menus and checks`
- `validate(rows) -> (boolean, { string }) -- at load or in a test: ids unique, stackSize at least 1, any ids referred to exist`
- `isPlaceable(itemType) -> boolean -- whether the kind can be put down (or callers just read itemType.placeable ~= nil)`
- `getFuelSeconds(itemType) -> number? -- how long it burns; nil if it is not fuel`
- **Data as they would expect it printed:** return { { id = "log", stackSize = 64, fuel = { seconds = 15 } }, { id = "raw_fish", stackSize = 16 }, { id = "cooked_fish", stackSize = 16 }, { id = "crate", stackSize = 1, placeable = { width = 1, depth = 1 }, container = { slots = 27 } }, { id = "stove", stackSize = 1, placeable = { width = 1, depth = 1 }, station = "stove" }, { id = "workbench", stackSize = 1, placeable = { width = 2, depth = 1 }, station = "workbench" }, } -- Lowercase snake_case string ids. A dictionary keyed by id would not surprise me either. With many kinds I'd expect several files of rows, not one.
- **Nothing:** An ability a kind lacks is an absent field (no placeable, no container, no fuel), not false and not an empty table. There is no row for 'air' or 'empty', since there is no empty stack. An unknown id gives nil from ItemRegistry.get; I would not know whether it errors instead.
- **Would not expect to find here:** Code in the rows: callbacks such as onUse or onPlaced. I expect each row to be plain data about the kind, checkable by a validator.

**General reader:** `ItemDefinitions`, or `Items`, in `data (second guess: items, next to ItemRegistry)`.

- `(none of its own) -> the module returns the list. I would expect this module to be only the rows, with no functions.`
- `ItemRegistry.get(id) -> item type or nil. I would look a kind up through the existing registry, not here.`
- `ItemRegistry.all() -> list of item types. For going over every kind.`
- `ItemRegistry.has(id) -> boolean. To check an id that came from a save or a recipe.`
- `validate(rows) -> list of error strings. Duplicate ids, stackSize below 1, misspelled field names. I would expect it in a test or a start-up check, perhaps in its own module.`
- `ItemRegistry.placeable(id) / fuel(id) / container(id) -> that part of the row or nil. Small readers for the optional parts, if they exist at all.`
- **Data as they would expect it printed:** { { id = "log", stackSize = 64, fuel = { seconds = 15 } }, { id = "raw_fish", stackSize = 16 }, { id = "crate", stackSize = 1, placeable = { width = 1, depth = 1 }, container = { slots = 27 } }, { id = "stove", stackSize = 1, placeable = { width = 1, depth = 1 }, station = "stove" }, } Possibly keyed by id instead of a plain list. I would guess a list, so that a duplicate id can be caught.
- **Nothing:** A kind that cannot do something simply lacks that field (no placeable = false, no fuel = 0), so 'can it be placed' is 'is the field there'. An id that is not in the list looks up as nil. I would not expect a row for 'air' or 'empty'.
- **Would not expect to find here:** Recipes, or any code: functions inside a row saying what happens when the item is used. Also nothing per player, such as counts or ownership. I would half expect display names and icons here, though whether those belong in a rules list I would not know.

**Rimworld reader:** `ItemDefs`, or `Items`, in `defs`.

- `(none expected in the list itself) I would expect this file to return a table of rows and nothing else, like an XML def file. The functions below are what I would expect on whatever reads it, which I take to be ItemRegistry`
- `get(id) -> item type or nil; lookup by id (DefDatabase.GetNamedSilentFail)`
- `getOrError(id) -> item type; the same but fails loudly on an unknown id (GetNamed)`
- `all() -> list of item types; every row, in file order`
- `withPart(partName) -> list of item types; every kind that is placeable, or every kind that is fuel`
- `validate(rows) -> list of error strings; duplicate ids, stack size below 1, a footprint on something not placeable; run once at load, like ConfigErrors`
- **Data as they would expect it printed:** { { id = "log", stackSize = 64, fuel = { burnSeconds = 15 } }, { id = "raw_fish", stackSize = 16 }, { id = "crate", stackSize = 1, placeable = { footprint = { width = 1, depth = 1 } }, container = { slots = 27 } }, { id = "workbench", stackSize = 1, placeable = { footprint = { width = 2, depth = 1 } }, station = { kind = "workbench" } }, } A list with the id inside each row, as in XML. I would also go looking for a label, a description, a parent row to inherit from and a picture or model path, because ThingDef has all four.
- **Nothing:** A kind that cannot do something simply has no such field (no placeable, no container, no fuel) rather than placeable = false. An id that is not in the list: lookup gives nil, and a recipe or a save that points at it is reported at load, not silently skipped. A missing stack size I would expect to default (RimWorld's stackLimit defaults to 1) but I would want that stated.
- **Would not expect to find here:** Code. A function inside a row saying what burning or placing does. Rows should be plain values, and the behaviour lives in whatever reads the 'fuel' or 'placeable' part.

## L. A player's piece of land: a grid of square tiles on which they place things.

**Godot reader:** `Plot`, or `PlotGrid`, in `plot`.

- `new(width, depth) -> plot : an empty grid of that many tiles`
- `contains(plot, tile) -> boolean : is this tile on the land`
- `canPlace(plot, itemId, tile, facing) -> boolean, reason? : inside the bounds and every covered tile free`
- `place(plot, itemId, tile, facing) -> placedId : add the thing and mark its tiles as taken`
- `remove(plot, placedId) -> PlacedItem? : take it off the land (breaking it), freeing its tiles; the caller turns it back into an item`
- `getAt(plot, tile) -> PlacedItem? : what stands on this tile`
- **Data as they would expect it printed:** { width = 24, depth = 24, nextId = 3, placed = { [1] = { id = 1, itemId = "crate", tile = { x = 4, y = 7 }, facing = 0 }, [2] = { id = 2, itemId = "workbench", tile = { x = 6, y = 7 }, facing = 1 }, }, occupied = { ["4,7"] = 1, ["6,7"] = 2, ["6,8"] = 2 }, -- tile -> id of what covers it } I would not know how a floor, a crate standing on that floor and a wall along the tile's edge share one tile. I would guess layers (floor, object, wall edges), which would make 'occupied' three maps.
- **Nothing:** An empty tile has no entry in the occupied map (nil); there is no 'empty' marker object. A fresh plot has empty placed and occupied tables. A player with no land yet has no plot (nil) rather than a zero-size plot.
- **Would not expect to find here:** The placement preview: the ghost model, snapping the pointer to a tile, green/red tinting. Also not where the plot sits in the 3D world; I would expect tiles here to be plain grid numbers.

**Minecraft reader:** `Plot`, or `Land`, in `plot (with M and R; 'world' would not surprise me)`.

- `new(ownerId: number, width: number, depth: number) -> Plot -- an empty plot of that many tiles`
- `canPlace(plot, itemId: string, tile: Tile, facing: Facing) -> (boolean, string?) -- true when every tile the thing would cover is on the plot and free; otherwise a reason`
- `place(plot, itemId: string, tile: Tile, facing: Facing) -> PlacedItem? -- puts the thing down and marks its tiles; nil if it cannot go there`
- `remove(plot, tile: Tile) -> PlacedItem? -- takes away whatever covers that tile and returns it, so the caller can turn it back into an item`
- `at(plot, tile: Tile) -> PlacedItem? -- what covers that tile`
- `inBounds(plot, tile: Tile) -> boolean -- is that tile on this plot`
- **Data as they would expect it printed:** { ownerId = 12345678, width = 16, depth = 16, -- in tiles nextId = 3, placed = { -- every placed thing once, by its own id [1] = { id = 1, item = "crate", tile = { x = 3, z = 5 }, facing = "north" }, [2] = { id = 2, item = "workbench", tile = { x = 6, z = 5 }, facing = "east" }, }, tiles = { -- which placed thing covers each tile; key = x + z * width [83] = 1, [86] = 2, [102] = 2, }, } -- x and z because Minecraft's ground plane is x/z; x/y on a flat grid would not surprise me.
- **Nothing:** An empty tile is a missing key (nil) in the tiles table. That is the opposite of Minecraft, where every position holds a block state and empty is the 'air' block, never null; I would not expect an air record here. A new plot is placed = {} and tiles = {}. at() returns nil for an empty tile; for a tile off the plot I would not know whether to expect nil or an error. I also would not know whether a floor and a crate can share a tile; if they can, I would expect a second table for the floor layer rather than two things in one cell.
- **Would not expect to find here:** Facts about particular kinds of item, such as 'a workbench is 2 wide' or 'a crate has 27 slots'. The plot should ask the item list or the footprint module. I would also not expect it to decide who is allowed to build; Minecraft keeps that check with the player's action, not in the world's set-block call.

**Roblox reader:** `Plot`, or `PlotGrid`, in `Building`.

- `new(width: number, depth: number) -> Plot -- an empty plot of that many tiles`
- `canPlace(plot, itemId: string, tile: Tile, facing: Facing) -> (boolean, string?) -- whether every tile the footprint would cover is on the plot and free; a reason when not`
- `place(plot, itemId: string, tile: Tile, facing: Facing) -> PlacedObject? -- put a thing down and mark its tiles; nil if it cannot go there`
- `remove(plot, placedId: number) -> PlacedObject? -- take a placed thing off and free its tiles; the caller turns it back into an item`
- `getAt(plot, tile: Tile) -> PlacedObject? -- what stands on a tile, or nil`
- `isInBounds(plot, tile: Tile) -> boolean -- whether a tile is on the plot`
- **Data as they would expect it printed:** { ownerId = 123456789, -- UserId width = 32, depth = 32, -- in tiles nextId = 3, placed = { [1] = { id = 1, itemId = "crate", tile = { x = 4, z = 2 }, facing = "north" }, [2] = { id = 2, itemId = "workbench", tile = { x = 6, z = 2 }, facing = "east" }, }, occupied = { ["4,2"] = 1, ["6,2"] = 2, ["6,3"] = 2 }, -- tile -> id of what stands on it } -- I would not know whether tiles count from 0 or 1, whether they are x/z or x/y, or how a floor and a crate share one tile.
- **Nothing:** An empty tile: no entry in the occupancy index (nil), and getAt returns nil; never a placeholder such as 0, false or "empty". An empty plot: placed = {} and occupied = {}. A plot spot nobody has: ownerId = nil, or no plot table at all; I would not know which.
- **Would not expect to find here:** Handing out plot spots to players as they join, or where the plot sits in the map (its CFrame). That is the server's job, not the grid's.

**General reader:** `Plot`, or `PlotGrid`, in `plot`.

- `new(width, depth) -> plot. An empty plot of that many tiles.`
- `canPlace(plot, itemId, x, y, facing) -> boolean, reason. Inside the plot, and every tile it would cover is free.`
- `place(plot, itemId, x, y, facing) -> placed thing, or nil and a reason. Adds it and marks its tiles as taken.`
- `remove(plot, placedId) -> placed thing or nil. Takes it off the plot so the caller can turn it back into an item.`
- `at(plot, x, y) -> placed thing or nil. What stands on a tile.`
- `all(plot) -> list of placed things. For saving or for drawing.`
- **Data as they would expect it printed:** { width = 32, depth = 32, nextId = 3, placed = { [1] = { id = 1, itemId = "crate", x = 4, y = 7, facing = "north" }, [2] = { id = 2, itemId = "workbench", x = 5, y = 7, facing = "east" }, }, occupied = { ["4,7"] = 1, ["5,7"] = 2, ["5,8"] = 2 }, -- tile -> id of what covers it }
- **Nothing:** An empty tile has no entry, so a lookup gives nil. I would not expect a full grid of zeros or 'empty' markers, though in Go I would have written exactly that. A new plot has placed = {} and occupied = {}. A player with no plot yet: nil, though I would not know whether that can happen.
- **Would not expect to find here:** What is inside a crate or how far along a stove is, and where the plot sits in the 3D world. I would expect the plot to know only what stands on which tile. I also could not tell from the description whether a floor and a crate standing on it share a tile; if they do, I would expect a layer field and be surprised not to find one.

**Rimworld reader:** `Plot`, or `Land`, in `plot`.

- `new(width, depth, ownerId) -> plot; an empty grid`
- `canPlace(plot, itemId, tile, facing) -> boolean, reason; every tile it would cover is inside the plot and free`
- `place(plot, itemId, tile, facing) -> placed thing, or nil and a reason; adds it and marks its tiles taken`
- `remove(plot, thingId) -> placed thing or nil; takes it off the grid and frees its tiles, so the caller can turn it back into an item`
- `thingAt(plot, tile) -> placed thing or nil; what stands on this tile`
- `things(plot) -> list of placed things; everything on the plot`
- **Data as they would expect it printed:** { ownerId = 1001, width = 16, depth = 16, nextThingId = 3, things = { [1] = { id = 1, itemId = "crate", tile = { x = 4, z = 7 }, facing = 0 }, [2] = { id = 2, itemId = "workbench", tile = { x = 6, z = 7 }, facing = 1 }, }, occupied = { ["4,7"] = 1, ["6,7"] = 2, ["6,8"] = 2 }, -- tile -> id of the thing covering it } RimWorld would keep 'occupied' as a flat array indexed z * width + x; either would not surprise me.
- **Nothing:** An empty tile has no entry in the lookup (nil). I would not expect an 'air' thing filling every tile as in Minecraft, nor a 0. An empty plot is things = {} and occupied = {}. A plot nobody has claimed: ownerId = nil, or no plot table at all; I would not know which.
- **Would not expect to find here:** The green or red ghost outline shown while choosing where to put something, or the conversion from a tile to a spot in the 3D world for drawing.

## M. One thing placed on that land: which kind of item, which tile, which way it faces.

**Godot reader:** `PlacedItem`, or `Placement`, in `plot`.

- `new(itemId, tile, facing) -> placed : make the record`
- `tiles(placed) -> { tile } : every tile it covers, using the kind's footprint and its facing`
- `turn(placed, quarterTurns) -> placed : face another of the four ways`
- `toStack(placed) -> ItemStack : the one item you get back when it is broken`
- `getInventory(placed) -> Inventory? : a crate's contents; nil for kinds that hold nothing`
- `(honestly) : with three fields I would expect this to be a type inside Plot more than a module with five functions`
- **Data as they would expect it printed:** { id = 2, itemId = "workbench", tile = { x = 6, y = 7 }, facing = 1 } -- facing 0..3, quarter turns clockwise from north -- a crate would also carry: inventory = <Inventory of 27 slots> -- a stove would also carry something like: work = { recipeId = "cooked_fish", startedAt = 1590.0 }, or nil when idle
- **Nothing:** There is no empty placed thing; when broken it is removed from the plot and becomes an ItemStack. Parts a kind does not have (inventory, station work) are nil. Facing is never nil; it defaults to 0.
- **Would not expect to find here:** The 3D model or a world-space position and rotation in degrees. I would expect only the tile and a 0..3 facing, with something on the visual side turning that into a model.

**Minecraft reader:** `PlacedItem`, or `Placement`, in `plot`.

- `new(itemId: string, tile: Tile, facing: Facing) -> PlacedItem -- the record for something just placed`
- `tiles(placed) -> { Tile } -- every tile it covers, from its kind's footprint and its facing`
- `withFacing(placed, facing: Facing) -> PlacedItem -- the same thing turned to face another way (the plot must still check that it fits)`
- `toStack(placed) -> ItemStack -- the item you get back when it is broken`
- `itemType(placed) -> ItemType -- its kind's row, looked up by id`
- `inventory(placed) -> Inventory? -- the slots inside it if its kind holds items, otherwise nil. This one is a guess: the description does not say where a placed crate's contents live. With only three fields I expect few functions a`
- **Data as they would expect it printed:** { id = 2, item = "stove", tile = { x = 4, z = 5 }, facing = "east" } -- facing as one of "north" | "east" | "south" | "west" (Minecraft's horizontal facing), or possibly 0..3 quarter turns. -- For a crate I would look for its contents here too: -- inventory = { size = 27, slots = { [1] = { id = "log", count = 12 } } }
- **Nothing:** There is no 'nothing' PlacedItem: an empty tile has no record, where Minecraft would have an air block state. facing is never nil; a thing that looks the same from every side still gets a default ("north"). Extras its kind does not have are simply absent (no inventory field on a wall). For a stove doing nothing I would guess a missing 'process' field rather than a progress of 0 against an empty recipe, but the description does not say a placed thing holds that at all.
- **Would not expect to find here:** Copies of what its kind can do (footprint, slot count, stack size). I expect only the item id and a lookup, the way a Minecraft block state points at its block. Also no reference to the 3D model that shows it.

**Roblox reader:** `PlacedObject`, or `PlacedItem`, in `Building`.

- `new(itemId: string, tile: Tile, facing: Facing) -> PlacedObject -- the record of one placed thing`
- `getTiles(placed) -> { Tile } -- every tile it covers, from its kind's footprint, its tile and its facing`
- `getItemType(placed) -> ItemType -- its kind, looked up in ItemRegistry`
- `setFacing(placed, facing: Facing) -> () -- turn it to face another way (Plot would have to re-check the tiles)`
- `toItemStack(placed) -> ItemStack -- the item you get back when it is broken`
- `getInventory(placed) -> Inventory? -- what is inside it if its kind holds items; nil otherwise`
- **Data as they would expect it printed:** { id = 2, itemId = "workbench", tile = { x = 6, z = 2 }, facing = "east" } -- facing as one of "north" | "east" | "south" | "west"; a number 0..3 of quarter turns would not surprise me. Degrees would. -- For a crate I'd also expect its contents to hang off this record: inventory = { size = 27, slots = { [1] = { itemId = "log", count = 12 } } }. The description does not say, so I would not know.
- **Nothing:** There is no empty placed thing: if nothing is placed there is no record at all. A kind that cannot hold items has no inventory field (nil); an empty crate has an Inventory whose slots are all nil. An idle station has no running job (nil), not a job at zero progress.
- **Would not expect to find here:** A reference to its Model or a CFrame in the Workspace. The record should be kind, tile and facing; what it looks like is drawn from that elsewhere.

**General reader:** `PlacedItem`, or `Placement`, in `plot`.

- `new(itemId, x, y, facing) -> placed item. Just builds the record.`
- `tiles(placed) -> list of tiles. Every tile it covers, from its kind's size and its facing.`
- `rotated(placed) -> placed item. The same thing turned a quarter turn.`
- `toStack(placed) -> ItemStack of 1. What you get back when it is broken.`
- `itemType(placed) -> item type. Its row, looked up in ItemRegistry.`
- `inventory(placed) -> Inventory or nil. The contents if it is a crate. I would not know whether contents hang off this record or live somewhere else.`
- **Data as they would expect it printed:** { id = 17, itemId = "stove", x = 5, y = 7, facing = "east" } Facing might equally be a number 0 to 3; I would guess a word.
- **Nothing:** There is no 'nothing' version of it. An empty tile is the absence of a placed item (nil), the same way there is no empty stack. I would expect facing always to be set, defaulting to one direction, never nil.
- **Would not expect to find here:** The 3D model, its position in world coordinates, or the check for whether its tiles are free, which is the plot's job. I would also be surprised if it carried the stack size or other facts copied from its kind instead of looking them up by id.

**Rimworld reader:** `PlacedThing`, or `Building`, in `plot`.

- `new(itemId, tile, facing) -> placed thing`
- `tiles(thing) -> list of tiles; every tile it covers, from its kind's footprint and its facing (RimWorld's OccupiedRect)`
- `turned(thing, facing) -> placed thing; the same thing facing another way`
- `fromItem(stack, tile, facing) -> placed thing; an item becoming a thing in the world, a crate bringing its contents with it`
- `toItem(thing) -> ItemStack of 1; what the player gets back when it is broken, a crate keeping what is inside`
- `kind(thing) -> item type; looks its itemId up in ItemRegistry`
- **Data as they would expect it printed:** { id = 2, itemId = "workbench", tile = { x = 6, z = 7 }, facing = 1 } -- facing 0..3 = north, east, south, west (Rot4's order) and I would expect extra fields only where they apply: { id = 1, itemId = "crate", tile = { x = 4, z = 7 }, facing = 0, inventory = { size = 27, slots = { [1] = { itemId = "log", count = 12 } } } } { id = 3, itemId = "stove", tile = { x = 9, z = 2 }, facing = 2, work = { recipeId = "cook_fish", elapsed = 3.5 } } The tile is one anchor tile; for a 2 by 1 thing I would need to be told which end it is.
- **Nothing:** There is no empty placed thing; an empty tile is the absence of one. A placed crate with nothing in it still has its inventory, with every slot nil. A thing that is not a container has no inventory field. A stove doing nothing has no work field (nil), not a recipe at zero progress.
- **Would not expect to find here:** Copies of what its kind can do (slot count, footprint, stack size). I would expect only the itemId and a lookup, the way a Thing carries its def and not the def's values.

## N. The rule that some inputs become some outputs after some time at a kind of station.

**Godot reader:** `Recipe`, or `Recipes`, in `crafting`.

- `get(recipeId) -> Recipe? : look one up by id`
- `forStation(stationKind) -> { Recipe } : every rule that runs at a stove`
- `find(stationKind, inventory) -> Recipe? : the first rule whose inputs are all present in the station's slots`
- `canStart(recipe, inventory) -> boolean : inputs present and room for the outputs`
- `takeInputs(recipe, inventory) -> boolean : remove the inputs when work begins`
- `giveOutputs(recipe, inventory) -> { ItemStack } : add the outputs when the time is up; returns what did not fit`
- **Data as they would expect it printed:** { id = "cooked_fish", station = "stove", inputs = { { itemId = "log", count = 2 }, { itemId = "raw_fish", count = 1 } }, outputs = { { itemId = "cooked_fish", count = 1 } }, seconds = 10, } I would expect the written list of these to sit in the data folder next to the item list, not in this module.
- **Nothing:** No rule matches what is in the station: find returns nil. An idle station has no current recipe (nil) and no timer, but that is the station's state, not the recipe's. A recipe with no inputs or no outputs I would expect to be rejected when the list is loaded.
- **Would not expect to find here:** The countdown of one particular stove (how far along it is, when it started). The rule is the same for every stove; progress belongs to the placed stove.

**Minecraft reader:** `Recipe`, or `Recipes`, in `recipe`.

- `find(station: string, available: Inventory) -> Recipe? -- the first recipe for that kind of station whose inputs are all present`
- `matches(recipe, available: Inventory) -> boolean -- are this recipe's inputs there in the needed numbers`
- `takeInputs(recipe, from: Inventory) -> boolean -- removes the inputs; false and nothing changed if any is short`
- `outputs(recipe) -> { ItemStack } -- fresh stacks of what it makes`
- `forStation(station: string) -> { Recipe } -- every recipe a kind of station can run`
- `get(id: string) -> Recipe? -- a recipe by id`
- **Data as they would expect it printed:** { id = "cooked_fish", station = "stove", inputs = { { id = "log", count = 2 }, { id = "raw_fish", count = 1 } }, outputs = { { id = "cooked_fish", count = 1 } }, seconds = 10, } -- Minecraft would write the time in ticks (200) and would not list the logs: fuel there is a property of the item, burned separately from the recipe.
- **Nothing:** find() returns nil when nothing matches; I would not expect a 'no recipe' placeholder. A recipe always has at least one input and one output, so no empty lists. An idle station is a station with no current recipe, which is the station's own state and not something this module holds.
- **Would not expect to find here:** The running state of any particular stove: what is in it and how many seconds have passed. In Minecraft that lives in the furnace's block entity and the recipe is only the rule. I would also not expect fuel burn times here.

**Roblox reader:** `Recipe`, or `Recipes`, in `Crafting`.

- `matches(recipe, inputs: Inventory) -> boolean -- whether the inventory holds every input in the needed amount`
- `findFor(station: string, inputs: Inventory) -> Recipe? -- the first recipe for that kind of station whose inputs are present (could as easily sit on a RecipeRegistry)`
- `takeInputs(recipe, from: Inventory) -> boolean -- remove the inputs; false and nothing changed if any is short`
- `canFitOutputs(recipe, into: Inventory) -> boolean -- whether there is room for the results before starting`
- `giveOutputs(recipe, into: Inventory) -> { ItemStack } -- add the results; returns whatever did not fit`
- `validate(recipe) -> (boolean, string?) -- every item id exists, counts are at least 1, the time is above zero, the station kind exists`
- **Data as they would expect it printed:** { id = "cooked_fish", station = "stove", inputs = { { itemId = "log", count = 2 }, { itemId = "raw_fish", count = 1 } }, outputs = { { itemId = "cooked_fish", count = 1 } }, seconds = 10, } -- inputs as a map ({ log = 2, raw_fish = 1 }) would not surprise me. I'd expect the rows themselves to live beside the item rows, with only the functions here.
- **Nothing:** No recipe fits what is in the station: findFor returns nil. A recipe itself is never empty: no empty inputs or outputs and no zero time (the validator rejects those). An idle station has no current recipe (nil), but I'd expect that to be stored with the station, not here.
- **Would not expect to find here:** The progress of one particular stove (which recipe is running, seconds elapsed). That is live state of a placed station; the recipe is the fixed rule.

**General reader:** `Recipe`, or `RecipeRegistry`, in `crafting (the list of recipes itself I would look for next t`.

- `forStation(stationKind) -> list of recipes. Every recipe a stove, say, can run.`
- `find(stationKind, inventory) -> recipe or nil. The first recipe whose inputs are all present.`
- `matches(recipe, inventory) -> boolean. Are the inputs there in the needed amounts.`
- `takeInputs(recipe, inventory) -> boolean. Removes the inputs; false and no change if any is short.`
- `outputs(recipe) -> list of ItemStack. What to hand out when the time is up.`
- `get(id) -> recipe or nil. One recipe by id.`
- **Data as they would expect it printed:** { id = "cooked_fish", station = "stove", inputs = { { itemId = "log", count = 2 }, { itemId = "raw_fish", count = 1 } }, outputs = { { itemId = "cooked_fish", count = 1 } }, seconds = 10, }
- **Nothing:** No matching recipe: find gives nil and the station stays idle. I would expect no recipe with an empty inputs or outputs list, and no 'null recipe'. An idle station, I assume, is one whose 'current recipe' field is nil, but that field would live with the station, not here.
- **Would not expect to find here:** The progress of one particular stove: what is in it, which recipe it is running, seconds left. That is the state of one placed station; this is only the rule. I would also not expect the timer itself.

**Rimworld reader:** `Recipe`, or `RecipeDef`, in `crafting`.

- `forStation(stationKind) -> list of recipes; every recipe that kind of station can do`
- `findMatch(stationKind, inventory) -> recipe or nil; the first recipe whose inputs are all present in the station's slots`
- `canStart(recipe, inventory) -> boolean; the inputs are there in the right amounts`
- `takeInputs(recipe, inventory) -> boolean; removes the inputs, all or nothing`
- `makeOutputs(recipe) -> list of ItemStack; fresh output stacks for the caller to put somewhere`
- `validate(recipe) -> list of error strings; unknown item ids, unknown station kind, zero time; checked at load`
- **Data as they would expect it printed:** { id = "cook_fish", station = "stove", inputs = { { itemId = "log", count = 2 }, { itemId = "raw_fish", count = 1 } }, outputs = { { itemId = "cooked_fish", count = 1 } }, seconds = 10, } I would expect a whole list of these in a data file sitting next to the item list. RimWorld would count the time as work in ticks, so 'seconds' I take from your example.
- **Nothing:** An idle station is one with no recipe running: its current recipe is nil and there is no progress number. Nothing in the station matches any recipe: findMatch gives nil. I would not expect a recipe with an empty outputs list standing in for 'nothing happens'.
- **Would not expect to find here:** The progress of one particular stove (seconds elapsed, whether it is lit). A recipe is the same for every stove; the timer belongs to the placed stove, as cook time belongs to the furnace and not to the smelting recipe.

## O. Everything in one running copy of the game world that the rules need to know about.

**Godot reader:** `World`, or `GameState`, in `world`.

- `new() -> world : empty: no players, nothing on the ground`
- `addPlayer(world, playerId, saved?) -> PlayerState : bring a player and their land in, from loaded data or defaults`
- `removePlayer(world, playerId) -> PlayerState? : take them out and hand back what needs saving`
- `getPlayer(world, playerId) -> PlayerState? : look one up`
- `getPlot(world, playerId) -> Plot? : that player's land`
- `step(world, now) -> { event } : advance time: finish station work, expire stacks on the ground; returns what happened`
- **Data as they would expect it printed:** { now = 1612.0, players = { [1001] = <PlayerState>, [1002] = <PlayerState> }, plots = { [1001] = <Plot>, [1002] = <Plot> }, ground = <GroundItems>, } Mostly a holder of the other modules' tables, keyed by player id.
- **Nothing:** An empty world is still a full table with empty players and plots and an empty ground collection; the world itself is never nil. A player who is not present is absent from players (lookup gives nil).
- **Would not expect to find here:** Networking: sending anything to clients or receiving their requests. Also not saving, and no references to engine objects.

**Minecraft reader:** `World`, or `GameState`, in `world`.

- `new() -> World -- an empty world: no players, no plots, nothing on the ground`
- `addPlayer(world, playerId: number, saved: table?) -> Player -- someone joins, with their pack and plot loaded, or fresh ones if they have no saved data`
- `removePlayer(world, playerId: number) -> Player? -- someone leaves; takes them and their plot out and hands back what has to be saved`
- `getPlayer(world, playerId: number) -> Player? -- someone present, by id`
- `getPlot(world, ownerId: number) -> Plot? -- that player's land`
- `tick(world, dt: number) -> () -- moves time on: stations progress, stacks on the ground age`
- **Data as they would expect it printed:** { time = 1234.5, -- seconds this copy has been running players = { [12345678] = { id = 12345678, pack = {...}, hotbar = {...}, open = nil, position = ... } }, plots = { [12345678] = { ownerId = 12345678, width = 16, depth = 16, placed = {...}, tiles = {...} } }, ground = { nextId = 43, items = { [41] = {...} } }, } -- Packs inside players and placed things inside plots, as Minecraft nests them. Flat tables side by side (players, packs, plots, placed, ground) would surprise me a little, though the description's wording could mean that.
- **Nothing:** An empty server is the same table with empty sub-tables: players = {}, plots = {}, ground.items = {}. The World itself always exists while the game runs and is never nil. A player who is not here has no key; I would not expect a record kept around and flagged offline.
- **Would not expect to find here:** The lists of item kinds and recipes. Those are the same on every server and never change while it runs, so they are not world state. Also nothing that sends updates to clients or writes saves.

**Roblox reader:** `World`, or `WorldState`, in `World`.

- `new() -> World -- an empty world: no players, no plots, nothing on the ground`
- `addPlayer(world, userId: number, saved: SaveData?) -> PlayerState -- a player arrives with their pack and plot, loaded or fresh`
- `removePlayer(world, userId: number) -> PlayerState? -- a player leaves; returns their state so it can be saved`
- `getPlayer(world, userId: number) -> PlayerState? -- one player, or nil if not present`
- `getPlot(world, userId: number) -> Plot? -- that player's land, or nil`
- `step(world, dt: number) -> () -- move time on: station timers, dropped stacks timing out (finding this in a separate module would not shock me)`
- **Data as they would expect it printed:** { time = 1532.5, players = { [123456789] = <PlayerState> }, -- keyed by UserId plots = { [123456789] = <Plot> }, -- keyed by owner; keyed by plot spot 1..8 would not surprise me dropped = { nextId = 4, items = { ... } }, } -- I would not know whether packs sit inside each player (my guess) or in a separate table of inventories keyed by id.
- **Nothing:** A fresh server: every collection is present and empty (players = {}, plots = {}, dropped.items = {}); the collections themselves are never nil. A player who is not here simply has no key, and getPlayer / getPlot return nil.
- **Would not expect to find here:** RemoteEvents, replication to clients or DataStore calls. I expect this to be the state itself, with that plumbing built around it elsewhere.

**General reader:** `World`, or `GameState`, in `world`.

- `new() -> world. Empty: no players, no plots, nothing on the ground.`
- `addPlayer(world, playerId, loaded) -> player. A player arrives, with a pack and plot from saved data or fresh ones.`
- `removePlayer(world, playerId) -> player and plot. A player leaves; returns what needs saving.`
- `player(world, playerId) -> player or nil. Look one up.`
- `plotOf(world, playerId) -> plot or nil. That player's land.`
- `step(world, now) -> list of things that happened. Moves time on: expires ground stacks, finishes cooking.`
- **Data as they would expect it printed:** { now = 131.5, players = { [1234] = { id = 1234, pack = {...}, hotbar = {...}, open = nil, position = {...} } }, plots = { [1234] = { width = 32, depth = 32, placed = {...} } }, ground = { nextId = 43, entries = {...} }, }
- **Nothing:** A world that has just started has every collection present and empty (players = {}, plots = {}, ground entries = {}), not nil. A player who is not here is simply missing from players.
- **Would not expect to find here:** Anything about the network, the database or Roblox itself: connections, sending updates to clients, save calls, 3D objects. I would also be surprised to find rules written here, such as how a click or cooking works. I would expect it to hold the data and hand it to the other modules.

**Rimworld reader:** `World`, or `GameState`, in `world`.

- `new() -> world; no players, no plots claimed, nothing on the ground`
- `addPlayer(world, playerId, saved) -> player; brings a player in with their pack and puts their land on a free plot`
- `removePlayer(world, playerId) -> player or nil; takes them and their land out and hands back what needs saving`
- `getPlayer(world, playerId) -> player or nil`
- `plotOf(world, playerId) -> plot or nil; the land that player owns`
- `tick(world, seconds) -> nothing; moves time on: station timers, ground stacks expiring`
- **Data as they would expect it printed:** { time = 1532.0, players = { [1001] = { id = 1001, pack = { size = 27, slots = { ... } }, hotbar = { size = 9, selected = 1 }, open = nil, position = { x = 10.5, y = 0, z = -3.2 } }, }, plots = { [1001] = { ownerId = 1001, width = 16, depth = 16, things = { ... }, occupied = { ... } }, }, ground = { nextId = 4, items = { ... } }, } Packs inside players and placed things inside plots, not as separate top-level lists.
- **Nothing:** A world that has just started is a complete table with empty parts: players = {}, plots = {}, ground items = {}. Never nil. A player who has left is gone from the players table, not kept with a 'left' flag.
- **Would not expect to find here:** The item list and the recipes. Those are the same in every copy of the world, the way DefDatabase is separate from the running Game; I would expect the world to hold only what differs between one running copy and another.

## P. One player, as far as the rules are concerned: pack, hotbar, what they have open, where they stand.

**Godot reader:** `PlayerState`, or `Player`, in `player`.

- `new(playerId, pack) -> player : a present player with a pack, nothing open`
- `getHeldStack(player) -> ItemStack? : the stack in the selected hotbar slot`
- `selectHotbar(player, index) -> boolean : change which hotbar slot is selected`
- `setPosition(player, position) -> () : record where they stand`
- `setOpen(player, session?) -> () : record the open inventory screen, or nil to clear it`
- `canReach(player, position) -> boolean : close enough to a crate, a station or a stack on the ground`
- **Data as they would expect it printed:** { id = 1001, pack = <Inventory of 36 slots>, hotbar = { size = 9, selected = 1 }, open = nil, -- or <InventorySession> position = { x = 10.5, y = 0, z = 4.2 }, } 'Player' is what the words suggest, but I would assume the engine already owns that name, so I expect a qualified one.
- **Nothing:** Nothing open is open = nil. An empty selected hotbar slot means the held stack is nil; 'selected' itself is always a number. I would not know what position is before the character has appeared in the world; I would guess nil.
- **Would not expect to find here:** The avatar: its model, animations, health bar, camera or input. Also not the player's land, since the description lists pack, hotbar, open screen and position only.

**Minecraft reader:** `Player`, or `PlayerState`, in `player`.

- `new(id: number, pack: Inventory?) -> Player -- a player with a loaded or empty pack, the first hotbar slot selected, nothing open`
- `heldStack(player) -> ItemStack? -- the stack in the selected hotbar slot`
- `open(player, crate: Inventory?) -> Menu -- opens the pack alone or with a crate and records it as what they have open`
- `close(player) -> ItemStack? -- closes whatever is open; the carried stack goes back in the pack and anything that will not fit is returned to be dropped`
- `give(player, stack: ItemStack) -> ItemStack? -- adds to the pack and returns what did not fit`
- `canReach(player, position: Vector3) -> boolean -- standing close enough to use a crate or pick something up`
- **Data as they would expect it printed:** { id = 12345678, -- I assume Roblox's number for the account; Minecraft would use a UUID pack = { size = 36, slots = { [1] = { id = "log", count = 12 }, [5] = { id = "crate", count = 1 } } }, hotbar = { size = 9, selected = 1 }, open = nil, -- or the open screen: { inventories = { <crate>, <pack> }, carried = nil } position = Vector3.new(10.5, 0, -3.2), }
- **Nothing:** Nothing open: open = nil. Empty hand: heldStack returns nil, not an empty stack. Empty pack: slots = {} with size still 36, so I expect the size to be stored and not counted from the slots. Position before the character exists: I would not know; nil is my guess.
- **Would not expect to find here:** The engine's own player or character object, the network connection, camera or input. Minecraft's ServerPlayer mixes all of that in; 'as far as the rules are concerned' tells me this one does not. I would also not expect the saved form of the player here.

**Roblox reader:** `PlayerState`, or `Player`, in `World`.

- `new(userId: number) -> PlayerState -- a player with an empty pack, the first hotbar slot selected and nothing open`
- `getPack(player) -> Inventory -- their pack`
- `getHeld(player) -> ItemStack? -- the stack in the selected hotbar slot, or nil`
- `setOpen(player, session: InventorySession?) -> () -- record what they have open; nil means nothing`
- `setPosition(player, position: Vector3) -> () -- update where they stand, copied in from the character by something outside the rules`
- `isWithinReach(player, position: Vector3, reach: number) -> boolean -- whether they are close enough to use or pick up something`
- **Data as they would expect it printed:** { userId = 123456789, pack = { size = 36, slots = { [1] = { itemId = "log", count = 12 }, [3] = { itemId = "crate", count = 1 } } }, hotbar = { size = 9, selected = 1 }, open = nil, -- or an InventorySession while a screen is open position = Vector3.new(104.5, 3, -22), }
- **Nothing:** Nothing open: open = nil. Nothing in hand: the selected hotbar slot of the pack is nil, while 'selected' is always a number and never nil. An empty pack: slots = {} with size still set. Not spawned yet: position = nil would be my guess; I would not know.
- **Would not expect to find here:** The Roblox Player Instance, the Character model or the Humanoid (health, WalkSpeed). I'd expect the UserId to be the only link to the engine's player.

**General reader:** `PlayerState`, or `Player`, in `player`.

- `new(playerId, pack) -> player. A player with that pack, the first hotbar slot selected, nothing open.`
- `heldStack(player) -> ItemStack or nil. The stack in the selected hotbar slot.`
- `selectSlot(player, index) -> boolean. Changes the selected hotbar slot.`
- `openInventory(player, other) -> session. Opens the pack, or the pack with a crate. Fails if something is already open.`
- `closeInventory(player) -> leftover ItemStack or nil. Closes whatever is open and returns what could not go back in the pack.`
- `canReach(player, position) -> boolean. Is the player close enough to a crate, a tile or a stack on the ground.`
- **Data as they would expect it printed:** { id = 1234, pack = { size = 27, slots = { [1] = { itemId = "log", count = 12 }, [3] = { itemId = "crate", count = 1 } } }, hotbar = { size = 9, selected = 1 }, open = nil, -- or the open-screen table from I position = { x = 10.5, y = 0, z = -3.2 }, }
- **Nothing:** Nothing open: open = nil. Selected hotbar slot empty: heldStack gives nil. A new player still has a pack with every slot empty, never a nil pack. Position before they have appeared in the world: I would not know; I would guess nil.
- **Would not expect to find here:** The network connection, the account or display name, how the avatar looks, or anything on screen. I would also be a little surprised to find their plot in here, since the world description lists land separately from players.

**Rimworld reader:** `Player`, or `PlayerState`, in `player`.

- `new(playerId, packSlots) -> player; empty pack, first hotbar slot selected, nothing open`
- `heldStack(player) -> ItemStack or nil; the stack in the selected hotbar slot`
- `selectHotbar(player, index) -> nothing; changes which hotbar slot is selected`
- `open(player, otherInventory) -> session, or nil and a reason; opens the pack alone or with a crate, refusing if something is already open`
- `close(player) -> ItemStack or nil; shuts the screen and returns a carried stack that did not fit back in the pack`
- `give(player, stack) -> ItemStack or nil; adds to the pack and returns what did not fit`
- **Data as they would expect it printed:** { id = 1001, pack = { size = 27, slots = { [1] = { itemId = "log", count = 12 }, [3] = { itemId = "crate", count = 1 } } }, hotbar = { size = 9, selected = 1 }, open = nil, position = { x = 10.5, y = 0, z = -3.2 }, } and while a crate is open: open = { other = <the crate's Inventory>, otherThingId = 17, cursor = { itemId = "log", count = 6 } }
- **Nothing:** Nothing open: open = nil. Holding nothing: the selected hotbar slot is empty (nil); the selection itself is always a valid slot number, never 0 or nil. A player who is not in this world is not in the table at all. I would not know what 'standing nowhere' looks like; I would expect a position to always be there while the player is present.
- **Would not expect to find here:** The avatar, name tag, camera, or which keys are down. (I would also expect the land to be found through the world by owner, with the player holding at most its id.)

## Q. Turning a player's pack and land into plain data that can be stored and loaded, with a version number.

**Godot reader:** `SaveData`, or `Serializer`, in `save`.

- `CURRENT_VERSION : a constant, not a function; the version new data is written with`
- `encode(pack, plot) -> data : plain numbers, strings and lists only, stamped with the version`
- `decode(data) -> pack, plot : rebuild the live tables; assumes the data is already at the current version`
- `migrate(data) -> data : run each upgrade step from data.version up to the current one`
- `default() -> data : what a first-time player gets (empty pack, empty land)`
- `check(data) -> boolean, reason? : reject nonsense before decoding (missing fields, unknown item ids)`
- **Data as they would expect it printed:** { version = 3, pack = { size = 36, slots = { ["1"] = { itemId = "log", count = 12 }, ["5"] = { itemId = "crate", count = 1 } } }, plot = { width = 24, depth = 24, placed = { { itemId = "crate", x = 4, y = 7, facing = 0, contents = { ["1"] = { itemId = "raw_fish", count = 3 } } }, { itemId = "stove", x = 6, y = 7, facing = 1 }, }, }, } I would not know whether a Luau list with gaps survives being stored, which is why I wrote the slots as keyed entries.
- **Nothing:** No saved data (first visit) arrives as nil, and the module answers with default(). Empty slots are left out, not written as a null or a zero-count stack. An empty crate has contents = {} or no contents field. I would not know what happens to data with no version field; I would guess it is treated as the oldest version.
- **Would not expect to find here:** The actual reading and writing to Roblox's storage, with retries and failures. I would expect this module to turn tables into tables and nothing else. Also not the open screen, carried stack or position, which I assume are not saved.

**Minecraft reader:** `SaveData`, or `PlayerSave`, in `save`.

- `encode(pack: Inventory, plot: Plot) -> table -- plain tables, strings and numbers only, stamped with the current version`
- `decode(data: table) -> (Inventory, Plot) -- brings old data up to date, then rebuilds the live pack and plot`
- `migrate(data: table) -> table -- runs each upgrade step in turn from data.version to the current version; plain data in, plain data out`
- `default() -> table -- the data of someone who has never played: empty pack, empty plot, current version`
- `encodeInventory(inventory: Inventory) -> table, with decodeInventory(data: table) -> Inventory -- the piece reused for the pack and for a crate's contents`
- `validate(data: table) -> (boolean, string?) -- refuses data of the wrong shape before anything is built from it`
- **Data as they would expect it printed:** { version = 3, pack = { size = 36, selected = 1, slots = { { slot = 1, id = "log", count = 12 }, { slot = 5, id = "crate", count = 1 }, }, }, plot = { width = 16, depth = 16, placed = { { item = "crate", x = 3, z = 5, facing = "north", contents = { size = 27, slots = { { slot = 1, id = "raw_fish", count = 4 } } } }, { item = "stove", x = 4, z = 5, facing = "east" }, }, }, } -- Stacks as a list where each entry names its slot, the way Minecraft writes a "Slot" number per stack, so an array never has gaps. I would also expect a constant such as SaveData.VERSION = 3.
- **Nothing:** No saved data (a first visit) comes back from storage as nil and default() is used; not an error. Empty slots are left out of the list. An empty plot is placed = {}. Data with no version field I would treat as the oldest version. A saved item id that no longer exists: Minecraft silently loses the stack; I would not know what to expect here, but I would want it logged.
- **Would not expect to find here:** The calls to Roblox's storage service: reading, writing, retrying, deciding when to autosave. This should only turn tables into other tables. I would also not expect it to save things that do not outlast a session: the carried stack, what is open, where the player stands, stacks on the ground.

**Roblox reader:** `SaveData`, or `Serializer`, in `Save`.

- `serialize(player: PlayerState, plot: Plot) -> SaveData -- a plain table that is safe to store, stamped with the current version`
- `deserialize(data: SaveData) -> (Inventory, Plot) -- rebuild the pack and the land from current-version data`
- `migrate(data: any) -> SaveData -- run the upgrade steps one version at a time until the data is current`
- `default() -> SaveData -- what a brand-new player starts with when nothing is stored`
- `validate(data: any) -> (boolean, string?) -- check shape and version before trusting what came back from storage`
- `CURRENT_VERSION: number -- a constant, not a function, but I'd look for it here`
- **Data as they would expect it printed:** { version = 3, pack = { size = 36, slots = { { slot = 1, itemId = "log", count = 12 }, { slot = 3, itemId = "crate", count = 1 } } }, plot = { width = 32, depth = 32, placed = { { itemId = "crate", x = 4, z = 2, facing = "north", contents = { { slot = 1, itemId = "log", count = 12 } } }, { itemId = "stove", x = 6, z = 2, facing = "east" }, }, }, } -- Only strings, numbers, booleans and gap-free arrays: no Vector3, and no arrays with nil holes (they do not survive storage reliably), so slots are listed with their slot number. No open screen and no carried stack: I'd expect those to be put back before saving.
- **Nothing:** No saved data: nil from storage, meaning a new player, answered with default(); that is different from a saved empty pack. An empty slot is left out of the list, with no null, false or count-0 placeholder. An empty plot: placed = {}. A missing version field: treated as the oldest version or rejected; I would not know which.
- **Would not expect to find here:** DataStoreService or ProfileStore calls, session locking, retries and autosave timing. Those belong on the server; this should be table in, table out.

**General reader:** `PlayerSave`, or `Serializer`, in `save`.

- `encode(player, plot) -> plain table. Pack and land as plain data, stamped with the current version.`
- `decode(data) -> pack and plot, or nil and an error. Rebuilds them, upgrading first if the version is old.`
- `migrate(data) -> data. Applies each upgrade step in turn until the version is current.`
- `newPlayer() -> plain table. The starting data for someone with nothing saved.`
- `validate(data) -> boolean, error. Wrong shapes, item ids that no longer exist.`
- `CURRENT_VERSION. A constant, not a function.`
- **Data as they would expect it printed:** { version = 3, pack = { size = 27, slots = { ["1"] = { id = "log", count = 12 }, ["3"] = { id = "crate", count = 1 } } }, plot = { width = 32, depth = 32, placed = { { item = "crate", x = 4, y = 7, facing = "north", contents = { size = 27, slots = { ["2"] = { id = "raw_fish", count = 5 } } } }, { item = "stove", x = 5, y = 7, facing = "east" }, }, }, } Only strings, numbers, lists and maps, as it would be in JSON.
- **Nothing:** No saved data: nil comes in, and exactly one function turns nil into a starter save. I would want 'nothing saved' (nil) kept clearly apart from 'loading failed' (an error), because treating a failed load as a new player overwrites someone's save. Empty slots are left out, not written as null. Data with no version field I would treat as version 1 or reject; I would not know which.
- **Would not expect to find here:** The call that actually reads or writes Roblox's storage, retries, or autosave timing. I would expect only table in, table out. I would also not expect the carried stack, the open screen, the player's position or the stacks on the ground in the saved data.

**Rimworld reader:** `PlayerSave`, or `SaveData`, in `save`.

- `encode(player, plot) -> plain table; pack and land as numbers, strings and lists only, stamped with the current version`
- `decode(data) -> pack, plot; brings the data up to date first, then rebuilds the live tables`
- `migrate(data) -> data; runs each numbered step from data.version up to the current version`
- `blank() -> data; what a first-time player starts with`
- `check(data) -> boolean, list of problems; item ids that no longer exist, things outside the plot, stacks above their stack size`
- `CURRENT_VERSION -> number; a constant, not a function`
- **Data as they would expect it printed:** { version = 3, pack = { size = 27, slots = { { slot = 1, itemId = "log", count = 12 }, { slot = 3, itemId = "crate", count = 1 } } }, hotbarSelected = 1, plot = { width = 16, depth = 16, things = { { itemId = "crate", x = 4, z = 7, facing = 0, contents = { size = 27, slots = { { slot = 1, itemId = "raw_fish", count = 5 } } } }, { itemId = "stove", x = 6, z = 7, facing = 1 }, }, }, } Slots as a list that names the slot number, so there are no holes. No ids of live things, no position in the world, no open screen.
- **Nothing:** No saved data (a first visit) is nil from whatever fetches it, and that has to be different from 'the fetch failed', or a real save gets overwritten by a blank one. Empty slots are left out of the list. An empty plot is things = {}. A missing version field I would read either as version 1 or as an error; I would not know which is intended.
- **Would not expect to find here:** The call that actually stores or fetches the data (I do not know what Roblox calls it). This should only turn live tables into plain data and back, and be testable with no game running.

## R. The space a kind of item takes up when placed, and how it turns to face four ways.

**Godot reader:** `Footprint`, or `TileRect`, in `plot`.

- `of(itemId) -> footprint? : read the width and depth from the item kind; nil if it cannot be placed`
- `size(footprint, facing) -> width, depth : swapped on the two sideways facings`
- `tiles(footprint, originTile, facing) -> { tile } : every tile covered when it stands with its anchor on originTile`
- `rotate(facing, quarterTurns) -> facing : the next of the four ways; I would half expect this in a separate small Facing helper`
- `fits(footprint, originTile, facing, gridWidth, gridDepth) -> boolean : stays inside a grid of that size`
- **Data as they would expect it printed:** { width = 2, depth = 1 } -- a workbench, as written on its item kind -- Footprint.tiles({ width = 2, depth = 1 }, { x = 6, y = 7 }, 1) -> { { x = 6, y = 7 }, { x = 6, y = 8 } } I would not know which tile is the pivot when a 2 by 1 turns; I would guess the tile you clicked stays covered.
- **Nothing:** A kind that cannot be placed has no footprint (nil), not a 0 by 0 one. A placeable kind with no size written I would guess defaults to 1 by 1.
- **Would not expect to find here:** Whether those tiles are free on a particular piece of land. That needs the plot, so I would look for it in Plot.canPlace. Also not the model's visual size.

**Minecraft reader:** `Footprint`, or `Shape`, in `plot`.

- `of(itemId: string) -> Footprint? -- the footprint written on that kind's row; nil if the kind cannot be placed`
- `size(footprint, facing: Facing) -> (number, number) -- tiles across and deep once turned: 2 by 1 becomes 1 by 2 on a quarter turn`
- `tiles(footprint, origin: Tile, facing: Facing) -> { Tile } -- every tile covered when it stands on origin facing that way`
- `rotate(footprint, facing: Facing) -> Footprint -- the turned footprint as a new value`
- `covers(footprint, origin: Tile, facing: Facing, tile: Tile) -> boolean -- does it take up this tile`
- `clockwise(facing: Facing) -> Facing -- the next of the four ways round; I would look for this in a separate Facing or Direction module first`
- **Data as they would expect it printed:** { width = 2, depth = 1 } -- a workbench as it stands when facing the default way; a crate is { width = 1, depth = 1 } -- Possibly a list of tile offsets instead, { { 0, 0 }, { 1, 0 } }, which would allow L-shapes, but the description only talks about rectangles. -- I would not know which tile is the anchor or which corner stays put when it turns. My guess: the anchor is the tile you clicked and the rest extends from it, the way a Minecraft bed extends from its foot in the direction it faces.
- **Nothing:** There is no empty footprint. The smallest is 1 by 1, and I would expect 1 by 1 to be assumed when a placeable row does not say. A kind that cannot be placed has no footprint at all (nil or absent), never 0 by 0.
- **Would not expect to find here:** Whether those tiles are actually free on someone's plot; that is the plot's canPlace. Also nothing measured in world units: no height, no collision box, no model size.

**Roblox reader:** `Footprint`, or `GridSize`, in `Building`.

- `new(width: number, depth: number) -> Footprint -- a size in tiles`
- `rotated(footprint, facing: Facing) -> Footprint -- the size as it lies when facing that way (width and depth swap on a quarter turn)`
- `getTiles(footprint, origin: Tile, facing: Facing) -> { Tile } -- every tile covered when placed at origin facing that way`
- `forItem(itemId: string) -> Footprint? -- the footprint of a kind of item; nil if that kind cannot be placed`
- `turnClockwise(facing: Facing) -> Facing -- the next of the four ways (might be in a small Facing module instead)`
- `overlaps(a: { Tile }, b: { Tile }) -> boolean -- whether two sets of tiles share a tile`
- **Data as they would expect it printed:** { width = 2, depth = 1 } -- as authored, facing north -- rotated to face east: { width = 1, depth = 2 } -- getTiles at origin { x = 6, z = 2 } facing east: { { x = 6, z = 2 }, { x = 6, z = 3 } } -- I would not know which tile stays put when a 2 by 1 turns (the origin corner or the middle); it is the first thing I would check.
- **Nothing:** A kind of item that cannot be placed has no footprint at all (nil, or no placeable field in its row). A placeable kind that states no size defaults to 1 by 1. There is never a 0 by 0 footprint.
- **Would not expect to find here:** Anything about a particular plot: whether the tiles are free or inside the plot's edge. That is Plot.canPlace; this should be shape and turning only, in tiles and not studs.

**General reader:** `Footprint`, or `Dimensions`, in `plot`.

- `of(itemId) -> footprint or nil. The size of that kind when placed; nil if it cannot be placed.`
- `rotated(footprint, facing) -> footprint. Width and depth swapped when facing east or west.`
- `tiles(footprint, x, y, facing) -> list of tiles. Every tile covered when its anchor tile is x, y.`
- `size(footprint, facing) -> width, depth. The two numbers after turning.`
- `overlaps(a, ax, ay, aFacing, b, bx, by, bFacing) -> boolean. Do two placed footprints share a tile. This might belong to the plot instead.`
- `turn(facing) -> facing. The next of the four ways, clockwise. I would half expect this in a separate small Facing or Direction module.`
- **Data as they would expect it printed:** { width = 2, depth = 1 } -- a workbench tiles(fp, 5, 7, "north") -> { {x=5,y=7}, {x=6,y=7} } tiles(fp, 5, 7, "east") -> { {x=5,y=7}, {x=5,y=8} } I would not know which tile it turns around, or whether facing south runs the other way from facing north.
- **Nothing:** A kind that cannot be placed has no footprint (nil, or the field missing from its row), not a 0 by 0 one. I would expect 1 by 1 to be written out for a crate instead of implied by a missing value, but I could believe a default.
- **Would not expect to find here:** Whether the tiles are actually free on somebody's plot, or where the plot's edges are. I would expect pure arithmetic on sizes and directions that knows nothing about any particular plot. Also not the measurements of the 3D model.

**Rimworld reader:** `Footprint`, or `OccupiedRect`, in `plot`.

- `new(width, depth) -> footprint`
- `turned(footprint, facing) -> footprint; width and depth swapped when facing east or west`
- `tiles(footprint, anchorTile, facing) -> list of tiles; every tile covered when placed there facing that way`
- `bounds(footprint, anchorTile, facing) -> minX, minZ, maxX, maxZ; the same answer as a rectangle`
- `contains(footprint, anchorTile, facing, tile) -> boolean; does it cover this tile`
- `overlaps(a, anchorA, facingA, b, anchorB, facingB) -> boolean; do two placed footprints share a tile`
- **Data as they would expect it printed:** { width = 2, depth = 1 } -- as written in the workbench's row of the item list tiles(fp, { x = 6, z = 7 }, 0) -> { { x = 6, z = 7 }, { x = 7, z = 7 } } -- facing north tiles(fp, { x = 6, z = 7 }, 1) -> { { x = 6, z = 7 }, { x = 6, z = 8 } } -- facing east I would want to be told which tile is the anchor and where it goes on a turn, because RimWorld's even-sized buildings shift when rotated and it catches everyone.
- **Nothing:** A kind that cannot be placed has no footprint (the field is absent). There is no 0 by 0 footprint. A placeable kind with no footprint written I would expect to be 1 by 1, as ThingDef's size defaults to (1,1).
- **Would not expect to find here:** Whether those tiles are free or inside the plot. That is the land's question; this should be pure arithmetic on a width, a depth, a tile and a facing, knowing nothing about any plot or any item.

## Names the readers would avoid

- **Godot reader:** Names that already mean something to me, mostly from Godot: - Container: a UI layout node in Godot. For I or for a crate it would make me think of layout. - Control, Node, Scene, Tree, Resource, Signal, Object, Viewport, Window: all Godot built-ins. "InventoryWindow" or "PlacedObject" would read wrong. - InventoryScreen for I: I would assume it is the drawn screen, not the rules. - ItemList for K: that is a Godot UI control. ItemDatabase would feel natural, but ItemRegistry already seems to be that. - TileMap, TileSet, GridMap for L: Godot's rendered tile layers. Area for the land or the footprint: Godot's physics trigger. Shape for R: collision shapes. - Process for N: _process(delta) is the per-frame callback in Godot, so I would read it as an update function. Station for N would read as the placed stove, not the rule. - Player on its own for P: I assume the engine has one. PlayerState has a smaller risk: in Godot it often means one state of a state machine (Idle, Walking). PlayerData would read as the saved data. - World for O: I picked it, but in Minecraft a world is the saved thing and in RimWorld it is the planet, not the local map. If O is one running copy that is not saved, the name misleads slightly. Server would read as networking. - Block and Entity (Minecraft) and Thing (RimWorld's word for items and buildings alike): each would blur item versus placed thing. Building or Structure for M would exclude a crate in my head. - Pack as the player's inventory: I read pack/unpack as serialising, and Godot has packed scenes. In the save module a function called pack would be confusing. - Cursor alone (the mouse pointer), Drop alone (loot tables), Save as both noun and verb, Stack alone (the data structure). - Manager, as in SaveManager: I would expect it to do the storage itself.
- **Minecraft reader:** These already mean something specific to me from Minecraft's code, so I would assume the wrong thing: - Container: three meanings. In Mojang's names it is the plain slot-holding interface (what this game calls Inventory). In the older MCP names it was the open-screen logic (thing I). Since 1.20.5 it is also the contents stored inside an item. I could not guess which one a module called Container was. That is also why my own first guess for I, ContainerMenu, is not a name I would recommend. - Menu, Screen, Gui: Menu is Mojang's word for exactly thing I, but everyone else reads it as a pause or main menu. Screen is always the client-side drawing class to me, so a rules module called InventoryScreen would send me looking for buttons. InventoryMenu is specifically the player's own inventory screen, not the general one. ScreenHandler is Yarn's word for I and reads as UI to anyone who does not know Yarn. - Slot: in Minecraft a Slot is a menu-side object (which inventory, which index, what may go in, where it is drawn), not the storage cell. - Item on its own: Item is the kind (one shared object per kind) and ItemStack is the pile. A table called Item with a count in it would throw me. Items in the plural is the written list of kinds (K). - Pack: a resource pack or data pack, meaning a bundle of content files. A module called Pack, sitting near a list "people edit to add content", I would open expecting content loading and not the player's backpack. Backpack or PlayerInventory would not have that problem. - data as a folder name: in a mod it is where the JSON content lives; next to a save module it reads as saved data. I guessed it for K and would not be sure. - Block, BlockState, BlockEntity, TileEntity, Chunk, Level: all imply a voxel world with a separate list of blocks. TileEntity is tempting for M on a tile grid, but it means only the placed things that carry extra data (chest, furnace), never a plain wall. A Chunk loads and unloads. Level is Mojang's word for the world and everyone else's word for a stage. - Entity, ItemEntity: an entity moves, ticks and has physics, and ItemEntity is one dropped stack, not all of them. - Drops, Loot: what a block or mob gives when broken or killed, decided by a loot table. Not what is lying on the ground. - Structure, Feature, Placement, PlacedFeature: world generation. Placement also reads as the act of placing rather than the thing left standing. - Component: since 1.20.5 a data component is per-stack data that two stacks of the same item can differ in, and Component is also chat text. If "what a kind can do" were called components I would assume one stack could override them. - Tag (a saved-data value, or a named group of items such as #logs), Capability (on Forge and NeoForge, an interface you query on one particular block or item), Handler and Storage (NeoForge's IItemHandler and Fabric's Storage are inventories with simulate and transaction rules). - Registry: frozen after startup. I expect the list people edit to be a different file from the thing called Registry. - Ingredient: a set of acceptable items, often a tag, with no count. If a recipe input is one exact item and a number, it is a stack. RecipeType is the kind of station (smelting versus crafting). - Fuel: a property of the item, burned separately from any recipe. - Codec, DataFixer, SavedData, PlayerData: Codec converts one type both ways and is built from other codecs; DataFixer is the versioned upgrade machinery; SavedData is miscellaneous per-world data; PlayerData is the saved player file. So PlayerData for the live player (P) would mislead me, and Codec for the whole of Q would too. - Shape, BoundingBox: collision geometry inside one block, or a structure piece's box. Bare Shape for R I would read as collision, even though it is the second name that came to mind. - Direction, Rotation, Facing: Direction has six values including up and down. Rotation is a relative turn (none, 90, 180, 270). For "one of four ways" I expect the word facing with north, east, south, west. Rotation used for an absolute facing would confuse me. - tick / ticks: a twentieth of a second. A field called ticks holding seconds would mislead me. - id: an item id is a readable string to me. If placed things and ground stacks also carry an id that is a counter, I would want a different word for it. - World: fine for O, though in Minecraft one server holds several worlds (dimensions), so it does not quite say "the whole running copy". - Player, Instance, Model: I believe Roblox has its own Player object, calls engine objects Instances and 3D groups Models. I have not worked in Roblox, so I would not know which Player a function wanted.
- **Roblox reader:** Player: the engine's Player class and type, and the Players service. It is my natural name for P, which is exactly why I expect PlayerState instead. PlayerData, Profile, and a folder called Data: to me these mean the saved DataStore profile, not live state. I answered Data as the folder for K because that is where I would look first, but I would look there for saves too, so I'd rather the lists sat in something like Content or Definitions. Session: also a DataStore session lock. I still reached for InventorySession, so treat that name as a mild risk. Screen, Gui, View, Window, Menu, and Minecraft's own ScreenHandler: under src/shared I would open any of them expecting a ScreenGui. Backpack and Tool: the engine's own Backpack and Tool instances ('pack' is fine). Character, Humanoid, Avatar: the avatar model. Model, Part, Instance, Object, Server, Place: engine words. Instance or Server for one running copy of the world, and Place for a placed thing, would mislead (a Place is a Roblox place file). Game and GameState: the DataModel global, and GameState reads as round state (lobby, in round). World is fine, though ECS libraries such as Matter and jecs use it for their entity store. Debris: the engine's timed clean-up service; tempting for J and wrong. Loot: implies random enemy drops. Floor for the ground: floors are placeable here. Size, Bounds, Extents, Rotation, Orientation: studs and degrees on Parts, hence Footprint and facing. Face: Enum.NormalId faces. Tag and Attribute for what a kind of item can do: CollectionService tags and Instance attributes. Catalog: the avatar shop. Store: a DataStore, a shop or a Rodux-style store. Service, Controller, Manager, Handler as suffixes: Knit-style singletons with a lifecycle, not plain modules. Task and Job: the task library and a server's JobId. Cell, Region, Zone: old terrain cells, Region3, ZonePlus. Entity and Component: ECS meanings.
- **General reader:** Names that already mean something else to me as a Go and Python backend person: - Cursor: a database or pagination cursor. CursorStack made me stumble for a second before I thought of the mouse. - Stack: the call stack, or a last-in-first-out list. It is already taken here in the Minecraft sense, so I would not use it for anything else. - Session: a login or network session with a token. InventorySession is my own first guess for I, but a plain Session would mislead me. - Container: Docker, or a dependency-injection container. I understand "a crate is a container", but ContainerManager or similar would send me the wrong way. - Store, Storage, DataStore, Repository, Persistence: a database layer. I would not use them for crates, and I would expect any module with those names to do real reads and writes, which Q does not. - Registry: a service or image registry. Fine for ItemRegistry since it is taken, but then I would not also call K a registry. - Model: a database model to me, and I assume a 3D model to game people. Entity and Instance: a database row and a running server to me; I gather they mean other things in games. - Plot: matplotlib. I accept it because the game says "plot of land", but Plot.draw or plot(x, y) would read as charting. - Map: a dictionary to me, the level to a player. Table: a database table, and I am told it is also Lua's word for its data structure, so not for the item list and not for furniture. - Pack as a verb: serialise to bytes (struct.pack, msgpack). "Pack" for the backpack is fine as a noun, but I would not name the save functions pack and unpack. - Process: an operating-system process. Server, Game, Context, Channel, Node: all taken in my head. - Manager, Service, Handler, Controller: either vague, or they suggest network code. - Screen, View, Window, Menu: I would expect drawing code, so they are wrong for the rules side of I. - Drops, Loot: what a monster drops, a loot list, not stacks lying on the ground. Block: Minecraft's cube, and a blocking call. - Rotation: suggests angles in degrees. For four ways I would expect Facing or Direction. - Player, Item, Object, Thing, State, Save on their own: too broad, and I would guess the platform already has its own Player. - A bare "id" or "type" field: there are item ids ("log"), ids of placed things (17) and player ids. I would want itemId, placedId and playerId. "type" looks like a keyword.
- **Rimworld reader:** Thing (on its own): in RimWorld a Thing is everything that exists on a map, items and pawns included, and it is the same object whether carried or placed. Here it would mean only the placed state, so I would misread it until told. Def and Comp: if the rows are called defs I will assume XML-def behaviour: a parent row to inherit from, cross-references checked at load, other people patching them. If the "can be placed / holds items / burns" parts are called comps or components, I will go looking for the second half, a per-thing object with its own state and tick, because that is what CompProperties plus ThingComp means to me. Container: in Minecraft modding it is the open-screen logic (description I); to a player it is a chest; in RimWorld it is the inner holder of a thing. Three meanings, so I would not use it for I. Screen, Menu, Window, Dialog for I: I would open the file expecting drawing code. Bill, Job, Work for N: a Bill is the order a player leaves at a bench (make 10, do forever) and a Job is what one pawn is doing right now. Neither is the recipe. Blueprint: in RimWorld the not-yet-built ghost of a building; in Lumber Tycoon 2 the build plans you buy and fill with wood. Not for the footprint or the placed thing. Map and World: a RimWorld Map is the local area things stand on and World is the planet view, so World for O makes me hesitate for a second (and "map" also just means a lookup table). Game and Player: I would assume the engine already owns those words, but I would not know. Property and Base for L: Lumber Tycoon 2's words for the land, but in code they mean a field and a parent class. Tile: fine for a square, though RimWorld calls a square a cell and uses tile for a world hex. TileEntity would send me to Minecraft's chest-and-furnace data. Block, Chunk: this is not a voxel world. Drops for J: in Minecraft that is what a block or mob gives when it breaks or dies (loot rules), not stacks lying around. Entity: too wide. Item on its own: I could not tell the kind (Minecraft's Item, RimWorld's ThingDef) from the amount (ItemStack, a Thing with a stack count). Slot for saved data: Lumber Tycoon 2 has save slots; here a slot is a cell of an inventory. Store or Storage for Q: storage already means crates. Scribe: I would expect one ExposeData-style function that both saves and loads. Size for R: could be stack size or slot count. Zone, Stockpile, Pawn: all carry RimWorld meanings. Session (my own pick for I) could be read as a login or play session; I would accept a better word. Casing: I do not know Luau's habits or whether folders are lower case. From C# my hands type PascalCase and a Try prefix with a true/false result for anything that can fail (TryPlace, TryPickUp), so the camelCase names returning nil on failure in my answers are a guess.

## Whether any description is really two things, or two descriptions are one

- **Godot reader:** Read as one thing described twice, or overlapping: - K and the existing ItemRegistry. Both are "every kind of item". I would guess K is the edited list and ItemRegistry the lookup built from it, but I would not know which one defines the row's shape ({ id, stackSize } versus a row with extras) or which to open to add an item. - I and the existing CursorStack. CursorStack was described as the carried stack with left and right click; I "holds the stack being carried" and "decides what a click does". I would expect I to own a CursorStack and add which inventories are shown, the quick move and closing. As written they sound like the same job. - O against P, L, M and J. O is the root holding the others. Its list says "the players, their packs" as if packs sat beside players, while P says the pack is in the player. Land is in O's list and not in P's, yet Q saves "a player's pack and land" together. So I am unsure whether land hangs off the player or off the world. - P's "their pack, their hotbar". Hotbar was described as the first slots of the pack plus which is selected, so that is one inventory and one number, not two things. - L, M and R all answer "which tiles does this thing cover". Read as two or more things: - M. Kind, tile and facing is a three-field record I would expect as a type inside Plot. It only earns a module if it also carries live state (a crate's contents, a stove's progress), and then it is two things: the placement and the state. - Missing between M and N: nothing describes a stove that is currently cooking (which recipe, when it started, its input and output slots). N is only the rule. I would expect an eleventh thing. - N. The shape of a recipe plus matching it against an inventory is one thing; the written list of recipes that people edit is another, parallel to K. Also the example lists 2 logs as an input while K says a kind can "burn as fuel". That looks like two ways of saying fuel; in Minecraft fuel is separate from ingredients. - Q. Turning live tables into plain data and back is one thing; upgrading old data step by step is another. The storage call itself is a third and I would not expect it under shared. - R. The footprint (a size on the item kind, which I would expect written in K's row) and the four facings with how to turn between them. I would expect a tiny Facing helper used by M and R. - I. Possibly the session record (which inventories, what is carried) and the pure click and quick-move rules. - J reads as one thing. "Where dropped things land" could hide a second job (choosing the landing spot against terrain), which sounds like engine work; I would expect J only to record the position it is given.
- **Minecraft reader:** Two descriptions of one thing, or nearly: - K and the existing ItemRegistry. "Every kind of item, by id" and "the written list that says what every kind of item is" sound like the same content. I would resolve it the Minecraft way: K is the list as written (Items) and ItemRegistry is the lookup built from it. But then an item type of { id, stackSize } and a row with more fields are two shapes for one kind, and I would expect one. - I and the existing CursorStack. Both are described as owning the carried stack and the left and right click rules. In Minecraft the carried stack is just a field of the menu and the click logic is in the same class. If both stay, I would expect CursorStack to be the arithmetic between one carried stack and one slot, and I to be everything about the screen as a whole: which inventories, which slot was meant, quick move, closing. - P's "their pack, their hotbar". The hotbar is the first slots of the pack plus one number, so it reads as one thing listed twice. Likewise O lists "the players" and "their packs" separately although P says the pack is part of the player. - L and M. M is three fields, and I would expect it to be a record declared inside the plot module unless it also carries the thing's own state. Reads as two things: - M, if a placed crate's contents and a stove's progress live on it. Minecraft splits this into the block state (kind and facing, which is all M describes) and the block entity (inventory, progress). None of the ten descriptions says where a placed crate's slots or a running stove's timer live; N is only the rule. So either M is bigger than described, or there is an eleventh thing, a station's running state, that I was not shown. - N. The example puts 2 logs in the inputs, while K says a kind of item can "burn as fuel". In Minecraft those are two separate rules: a recipe (ingredient, result, time) and fuel (item, burn time), consumed independently. I cannot tell whether the logs here are an ingredient or fuel. N is also both one rule and, presumably, the list of all rules plus the search by station; I would expect the same split as for items, whatever that turns out to be. - Q. Turning live tables into plain data and back is one job; bringing old plain data up to date is another (Minecraft: codecs versus the data fixer). One module is fine if it is small, but I would expect migrate to work on plain data only and never touch a live Inventory or Plot. I would also expect Inventory and Plot each to know their own plain form, with Q stitching them together and stamping the version. - R. The size is a field on the item's row; turning is general four-way direction arithmetic that M and the placing action need as well. I would expect the facing helpers (next clockwise, opposite) in their own small module, with Footprint using them. - I. It holds state (which inventories, the carried stack) and three sets of rules (click, quick move, close). That is one class in Minecraft and I would keep it as one. One gap: with the pack open alone there is no "other inventory" for a quick click. Minecraft moves between the hotbar and the rest, and I would guess the same. - L. "Crates, stoves, walls and floors" on one tile grid. In Minecraft a floor is just the block underneath. On a flat grid, if a crate can stand on a floor, the plot has two layers, and walls might sit on tile edges rather than in tiles. I would not know; it could be three kinds of placing under one description. One thing falls between J, K and M. A crate is an item that can lie on the ground or sit in a pack. If it keeps its contents when broken (a Minecraft shulker box), a stack needs data of its own and two crates no longer stack; if it spills them (a Minecraft chest), J has to take the spill. The descriptions do not say which. I assumed the chest behaviour throughout.
- **Roblox reader:** K and the existing ItemRegistry read as one thing told twice: the list is what the registry holds. I'd expect K to be a pure data table with no functions and ItemRegistry to be the functions over it, sharing one row type (the registry's { id, stackSize } and K's fuller row should be the same type). That is why I could not honestly name five functions for K. I overlaps the existing CursorStack: both are described as holding the carried stack and deciding what a click does. I'd expect CursorStack to be the arithmetic of one click between the carried stack and one slot, and I to be which inventories are shown, shift-click and closing. As written I could not say where the line is. P's pack and hotbar are one inventory plus a selected number, not two things, and P's 'what they have open' is I. O's 'their packs' are P's pack; I'd expect them in one place. M reads like a row type inside L, not its own module, unless it carries live state. And that is the gap: none of the ten says where a placed crate's contents or a stove's running job (4 of 10 seconds done) live. I guessed M, which would make M two things: the placement record (kind, tile, facing) and the live state of that thing. L reads as two: things that stand on a tile (crate, stove) and structure (floors under them, walls along tile edges). One occupancy grid cannot hold a floor and a crate on the same tile, so I'd expect layers or separate handling. N is only the fixed rule; running it at one stove is a separate thing that is not described. The list of all recipes (content, like K) and the functions over one recipe are also two, mirroring K and ItemRegistry. And the example makes logs an input while K gives items a 'burn as fuel' ability: that reads as two ways of saying fuel. Q reads as two: the save shape with its encode and decode, and the migration steps, which I'd expect to grow in their own file. R reads as two small things: a size that is really a field of K's row, and the facing and turning maths that M also needs. I'd half expect a tiny Facing module both use. J is one thing, but 'where dropped things land' needs the map's geometry, which a rules module will not have; I'd expect the caller to pass the resting position. On folders: I answered in PascalCase by habit and lowercase would not surprise me. For L, M and R I'd equally expect Plot or Placement. For K I'd also look in Content, Definitions or Items.
- **General reader:** Read to me as more than one thing: - I. Two jobs: "what is open" (which inventories are shown, the carried stack, what happens on close) and "what a click does". The second overlaps CursorStack, which was introduced as already having left and right click as in Minecraft. I cannot tell from the words where CursorStack ends and I begins. My guess: CursorStack is one carried stack against one slot; I chooses the inventory and slot, and does quick-move and close. - Q. Converting to and from plain data, and upgrading old versions, are two jobs to me. Same folder, but I would look for the upgrade steps as their own list. Actually storing the data is a third job that I would expect outside shared. - R. The size of a kind is data I would expect as a field in K's row. The turning is arithmetic. The four ways themselves (their names, turning clockwise) feel like a third tiny thing that M and R both need. - N. The example lists 2 logs as an input, while K says an item can "burn as fuel". I would not know whether fuel is just an ingredient or a separate rule. If it is separate, N is two things. Read to me as two descriptions of one thing: - K and the existing ItemRegistry. I would expect K to be the data and ItemRegistry the lookup over it, but ItemRegistry was introduced with an item type of only { id, stackSize } while K's rows have more. If both are modules I would not know which one to open to add an item. - L and M. M is a record that lives inside L. I would expect it to be a type with one or two helpers, not a module of its own. L, M and R together read as one feature split three ways; R on its own, as pure arithmetic, I would accept. - O and P. P is one entry in O. Packs are named in both. And the land is listed beside the players in O, while Q calls it "a player's pack and land", so I cannot tell whether a plot belongs to the world or to the player. - P and I. "What they have open" in P is the thing I describes, so I would expect P to point at it and hold nothing more. Missing, which left me unsure where things go: - A station that is running: one particular stove, what is in it, which recipe it is on, seconds left. N is only the rule. The question asks how an idle station appears, but none of the ten is the station. - What is inside a placed crate. M has only kind, tile and facing, so the contents must live somewhere else and I could not say where. - Who owns "pick up": J has the stacks, P has the position, Inventory has the room. Assumptions behind my answers: lower-case folder names (a Go habit) with PascalCase modules like the existing five; x and y for tile coordinates because I do not know which axis is up; returning a value plus a reason instead of raising errors; a missing key meaning "nothing", which I take to be how a Lua table behaves.
- **Rimworld reader:** Two descriptions of one thing: - K and the existing ItemRegistry. "Every kind of item, by id" and "the written list of what every kind is" are the def file and the def database to me. I would expect K to be the data and ItemRegistry the lookup over it, and the item type to stop being just { id, stackSize } once K adds placeable, container and fuel. As written I would not know which of the two to ask "can this be placed?". - I and the existing CursorStack. Both are described as holding the carried stack and knowing left and right click. My guess is that CursorStack is the rule for one click on one slot, and I is the part that knows which inventory the slot belongs to, plus shift-click and closing. But the two descriptions overlap as written. - I and P's "what they have open". I expect P's field to be I's table, or nil. - O against P, L and M. O lists the players, "their packs", the land and "what is placed on it" as if they were four lists. From P and L I expect packs inside players and placed things inside plots, so O is really players plus plots plus ground stacks. - M's "which way it faces" and R's "four ways" are one small thing (RimWorld's Rot4) that both need. I would expect it defined once, possibly as its own tiny module. One description that is really several: - M. As written it is only where a thing is: kind, tile, facing. But a placed crate has slots with things in them, and a placed stove has something cooking. That per-thing state has to hang somewhere and M is the obvious place. So either M is a three-field record that barely needs a module (it could be a row inside L), or it is the real "thing in the world" and much bigger than described. - N. The recipe is one thing: data (inputs, outputs, seconds, station kind), a second list people edit, like K. A particular stove part-way through cooking is another: which recipe, seconds elapsed, where the inputs sit, where the output lands, what happens when the output slot is full. None of the ten descriptions covers that second thing. In RimWorld those are RecipeDef versus the Bill and the work table; in Minecraft the smelting recipe versus the furnace's own cook time. - R. The size (2 by 1) is a field of the item's row in K. The turning and "which tiles does it cover" is a handful of pure functions. I expect the numbers in K and the functions in a small module, not a separate list of footprints. - Q. Three jobs: turning live tables into plain data and back; the numbered upgrade steps for old data; and (not described, but it will sit nearby) actually storing it. RimWorld keeps the first two apart (ExposeData and BackCompatibility). I would expect them in one folder with the upgrade steps as their own list. - L, slightly. "Crates, stoves, walls and floors" on one grid: in RimWorld floors are a separate terrain layer under the things, because a crate stands on a floor in the same tile. And I would not know whether a wall fills a tile (RimWorld) or sits on the edge between two tiles (most house-building games). If floors under things or edge walls are meant, "which tile it stands on" in M does not cover them. Other things I tripped on: - N's example uses up 2 logs as an input, while K says an item can "burn as fuel". In both Minecraft and RimWorld fuel is separate from ingredients, so I cannot tell whether the logs here are an ingredient or the stove's fuel. - J says "position", so I assume free positions as in Minecraft, not one stack per tile as in RimWorld. I would not know whether a stack dropped on someone's plot belongs to J or to L. - Q saves "pack and land". I would also wonder about the selected hotbar slot, and about a stack still on the cursor if the player vanishes with a screen open (I says closing deals with it, so I assume it is put back first). - P's "where they are standing": I assume the rules need it for reach checks, but I would not know who keeps it up to date.
