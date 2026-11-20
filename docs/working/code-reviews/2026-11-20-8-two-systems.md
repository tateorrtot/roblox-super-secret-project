# The ninth review: two systems that do not know each other (2026-11-20)

The user answered Claude's report on their eighth review. Their words, and what Claude took from them.

## Roblox's style
Claude had kept `fire` and said two helpers argued for Godot's `emit`.
> no lets keep things more styled to roblox / in tune to it

- **`fire` stays, and the code is styled to Roblox.** Where there is a choice, the Roblox way is the one to take.

## "Why? Just why this class name?"
Of `UseAndHit`:
> Why? Just why this class name? Im confused.

- Claude named the class for the two things it listens for, and "Use" and "Hit" were Claude's own words for them. It does three jobs: it finds what the pointer is over, draws two markers, and tells two clicks apart. No noun fitted, because the class is not one thing.
- **Roblox has a way of its own for input:** the Input Action System, in which an action such as "interact" is an Instance with its keys, buttons and touches bound to it. Roblox's own skill for Studio calls it the default. The client reads `UserInputService` by hand today.

## "who said a placed item has an inventory"
Claude had listed what the code does for every item, meaning the faults as they stand.
> so who said it would open its inventory. who said a placed item has an inventory. you just make the contract... that placed items have inventories. or are likely to have them so its assumed...

> Oh wait are you stating the issues currently and that youve fixed them?

- **Claude said it.** On 2026-11-19, building the crate, it gave every placed item a field for an inventory. Nobody asked for that.
- **A list says whether it is how things are or what was done.** The user could not tell which this one was. It was how things are: none of it was fixed.

## Two systems
Claude had asked whether to call the thing a placed item or a block.
> Well really its "a physical object thats placed". So maybe just PlacedObject. Or Structure.  What do other games call this? It might not always be a block i dont want to call it that. PlacedItem sounds a bit odd. Who said it had anything to do with an item. (Sorry of I made that contract). the item in the inventories, and the placed object should be entirely seperate and decoupled. they are two    v e r y    different systems that shouldnt rely on or mention eachother i feel. Glue code for them should exist outside of them.

> Essentially, we should have a "inventory items hotbar storage" etc module and a "placed objects, plots" etc modules that dont know about eachother. if they can be broken up further great.

- **Items and placed objects are two systems.** Neither requires the other, and neither mentions the other.
- **What joins them is glue, kept outside both:** that an item in the hand puts an object down, that an object broken leaves items, that an object holds an inventory.
- **The name is not "block", and not "placed item".** `PlacedObject` or `Structure`, to be settled with what other games call it.
- The contract was Claude's. The user had said that everything can be an item and that many things can be placed. Claude turned that into "a placed thing is an item".
- Today `plots` requires both `items` and `inventory`.

## The question in the box
Claude's summary had ended: "The item-decides shape is drawn but not built ... Build the item-decides shape first, starting with break, before prediction?"
> Uh what? Im confused

- **A question to the user is in plain words, and can be read alone.** "The item-decides shape" was a label Claude had coined a page earlier.

## Skills and tools
> Copy them and put them in skills in this repo.

> No idea what roblox-dev is or how it got there youre free to check it out and load it if it looks useful. Same for the stuff in Roblox. Youre free to grab and load whatever you need.

Of the one skill Claude had meant to leave out, `roblox-simulator-economy`:
> mm so this is a simulator and an economy.

- **Claude may fetch and load the tools and skills it needs,** without asking each time. What still needs a yes: anything that spends Robux, saving or publishing the place, and anything that puts the account or the user into a web request.
- All eight Roblox skills were copied, the economy one too.
