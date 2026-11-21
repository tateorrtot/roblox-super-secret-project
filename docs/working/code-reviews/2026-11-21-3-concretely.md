# The seventeenth review: "concretley - what the hell are these things?" (2026-11-21)

The user read the comment that Claude had rewritten an hour before, for the method they had asked about. Their words, and what Claude took from them.

## Words that sound good, and point at nothing
Of "Moves the whole stack out of one slot of the player's open screen and into a run of other slots":
> Okay look I think you might've just done it again.

> Moves >THE WHOLE STACK< out of ONE SLOT of the PLAYER's open screen... What is the whole stack? What is one slot? [Didnt you literally define it as an argument!] What is THE PLAYER [didnt you literally define it as an argument]

> Its not just this one specific example - its this greater pattern where you say things that sound good at first glance but can be done so much more concretley.

> if I look at "one slot of the player's open screen..." - I might be able to intuitively understand what this means - but concretley - what the hell are these things?

- **Every noun in a comment is a thing the reader can point at:** an argument, a field, a type, or a literal value, written in backticks. "One slot" is `slot`. "The player" is `player`. "The player's open screen" is `player.screen`. "The whole stack" is the `ItemStack` in `slot`.
- **A sentence that reads well is not thereby a sentence that says something.** The first rewrite had taken the arguments out of the sentence to stop it repeating words, and put prose in their place. The user wants the arguments in.
- **A function says what each of its arguments is,** one to a line: its values or its type, and the field that it stands for.
- **The fault is Claude's habit, and not this one comment.** It was told so three times in one day: "lofty and abstract" twice in the sixteenth review, and here.

## A change they could not follow
Of "Shall I cut Shift-click's request to the slot alone, so the server chooses where the stack goes?":
> Wait no that would cause a delay on the client side I think dont do that!

> Im having a difficult time even understanding your code right now as I outlined above.

> Like... why are you saying cut this thing?

- **Declined, and not built.** They took the refusal back within the hour: "No dont drop it? Im still just not really understanding" (below). It is not decided.
- **Claude asked them to rule on a change to code that they could not yet read.** A proposal comes after the reader can follow what is there, and it says why in one plain sentence. Claude's reason was that they had called the signature "over the top", and it never said so.
- **On the delay:** it would add none, since the client sends one message and gets one answer either way. Claude said so and left the request as it is.

## What changed
- The comment of `InventoryRequests.moveFromSlotToInventory` is written again, with each argument on a line of its own and no noun that is not an argument, a field, a type, or a value. It is the sample: the other comments wait for the user's word on it.
- `docs/code/comments.md` has the rule, in their words.

## The same day, of the sample
The user read the rewritten comment, and then sent three messages while Claude worked.

> Ah right away this documentation is so much clearer I see what it does now! You give it an item stack, from some slot, and then it gets distrubited between toFirstSlot and toLastSlot.

> Why not just feed it like a list of slots to distrubite over? Slots may not be in perfect order like 2, 3, 4? What if the player drags diagonally?

Of "`world`: the `World`. This request does not read it.":
> Is that standard...? Seems redundant

Of `side: unknown, slot: unknown, toSide: unknown, toFirstSlot: unknown, toLastSlot: unknown`:
> Why are all these DataTypes unspecified?

> Yes lets refine this up to standard then we'll get the other comments, documentation, and code.

Of the request change that Claude had dropped:
> No dont drop it? Im still just not really understanding. You might be over abstracting?

Of whether the comment was concrete enough:
> its getting there

Then:
> Why not just do... Inventories Slots No sides? Something like moveFromSlotToInventory could be more so broken up as: "inside of inventory A, at this slot, grab this stack. now, in inventory B, distrubite it across these slots"

And then:
> Actually wait no thats two jobs I broke my own rules. "inside of inventory A, at this slot, grab this stack." Thats one function. "Inside inventory B, distribute an item stack across these slots" Thats another function. Dont bake it together

- **The comment worked: they could say what the function does.** They read "into the slots from `toFirstSlot` to `toLastSlot`" as sharing the items out, which it does not do. The comment now says so, and names the request that does.
- **A line for an argument that the function does not read is noise.** It is said once, in the module's description.
- **A signature of `unknown` tells a reader nothing.** The module's description now says why: a client can send any value, and the request checks each one. Each argument's line gives the type that the check wants. Godot has the same in `_can_drop_data(at_position: Vector2, data: Variant)`.
- **Their two functions exist:** `Inventory.takeFromSlot` and `Inventory.addStack`, which take an inventory and slots and know nothing of sides. `InventoryScreen.moveFromSlotToInventory` is the two baked into one, and it is to be taken apart. Not built: Claude showed how, and asked whether to do it now or after the comments.
- **`side` is needed in one place only:** where a client's request comes in, since a client cannot send an inventory and must say which of its player's open inventories it means.

