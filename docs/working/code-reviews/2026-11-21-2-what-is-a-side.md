# The sixteenth review: "what the hell is a side" (2026-11-21)

The user opened the class reference for the first time after the comment pass, at one method, and read Claude's report beside it. Their words, and what Claude took from them.

## Lofty words
Of "One look piece for each item":
> What is "a look piece". be more concrete youre talking very lofty and abstract.

> A look piece? Is that a script? Like: "A slot [on the client]" -> talks to -> "A look piece [a script]" -> talks to -> "Flat texture [shown in a slot]"

Of "takes the stack out of its slot before it checks the target slots, so a bad slot list loses the stack":
> Takes THE stack. You mean a specified stack? Hold on lemme pull up the documentation. Once again lofty and abstract not using concrete things...

Of "Ten doubts stand, mostly facts about Roblox that the code cannot show":
> Faults? What faults?

- **"A look piece" was a noun Claude made up, for a thing that has a plain name: a ModuleScript.** They had to guess what it was, and guessed right.
- **Say the kind of thing first:** a script, a function, a table, a part. Then what it does. Then one case with real values: which slot, how many of what.
- **A count with no list is not a report.** "Ten doubts stand" told them nothing.

## Examples
Of "No page has an example":
> yeah examples would be nice. as a human and for you to see if the API holds up / makes sense right?

- **An example is also a test of the interface.** Writing one shows whether a function can be used without knowing its insides.

## The page they opened
`InventoryRequests.moveFromSlotToInventory`, in the reference.

> wow thats a lot of parameters in a signle scrollable list i have to go through.

> Wait looking at this what the hell is a side. I understand a slot

> I... cant click on what these are they look like broken hyperlinks. That repeat the word before them sometimes?

> Dude what the hell have you been writing this is slop lol

- **The page used a word it never said the meaning of.** `side` is which of an open screen's two inventories, `"pack"` or `"other"`. That is written on another page, and this one did not link to it.
- **The red boxes were code, not links.** The theme draws code in red with a border, and Claude had not looked at a page as a reader would.
- **"The slot `slot` on the side `side`" says each word twice.** Claude's own guide and its model module wrote that way, and twelve helpers copied it into 52 modules. Godot writes the argument alone: "can be dropped at `at_position`".
- **Claude had checked the comments against the rules and against the code, and never against a reader.** A script counted banned words. Helpers checked truth. Nobody was shown one page cold and asked what a word meant, which is the user's own test for names.

## The method itself
> What even is this method signature Why so over the top. This one method looks cooked with so much functionality built in.

> Like... move something from a specified slot to another inventory? Am I reading that right? ... Ah I see moveFrom a specified slot to a given inventory! Nope... wait its from a slot to another player. And... the side of the player.. wait what why is UI being brought up here whats going on

> K just hold on what the heck is going on with the codebase

- **Three readings, all wrong, from the signature and the name.** `player` is who asked, and it read as where the stack goes. `side` read as a side of the player. "The open screen" read as the UI, in a module of the rules.
- **The request is what Shift and a click does,** and it takes five values from the client where two would do: the client works out which slots the stack should go to, and the server only checks that they exist.
- **`screen` and `side` are Claude's words for a thing in the rules:** what a player has open, which is their pack, perhaps another inventory, and the stack they carry. The thing is real and belongs on the server. The words sound like UI.

## What changed
- **How a page is drawn:** code is plain and a link is blue and underlined, a signature has one parameter to a line with each type linked, and an unused parameter loses its underscore.
- **The comments:** 138 places that said a word and then the argument of the same name now give the argument alone. "Fails" is "Raises an error". Each request that takes a `side` says what a side is and links to its type. No line of code changed.
- **Examples:** `Plot`, `Inventory`, `InventoryScreen` and `InventoryRequests` each have a file in `demos` that runs, shown on the page with what it prints.
- **A cold reader is now part of how comments are checked** (`docs/code/comments.md`). Four read one page each, before and after the mends: sure of 31 of 47 functions, and then of 29. The pages are still hard to read cold (`docs/status/now.md`).
- **Not changed:** the request's seven values, and the words `screen` and `side`. Both are asked of them (`docs/status/asked-of-the-user.md`).
