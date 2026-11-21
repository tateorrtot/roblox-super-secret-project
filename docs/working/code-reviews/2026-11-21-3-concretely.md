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

- **Declined, and not built.** The request keeps its seven values.
- **Claude asked them to rule on a change to code that they could not yet read.** A proposal comes after the reader can follow what is there, and it says why in one plain sentence. Claude's reason was that they had called the signature "over the top", and it never said so.
- **On the delay:** it would add none, since the client sends one message and gets one answer either way. Claude said so and left the request as it is.

## What changed
- The comment of `InventoryRequests.moveFromSlotToInventory` is written again, with each argument on a line of its own and no noun that is not an argument, a field, a type, or a value. It is the sample: the other comments wait for the user's word on it.
- `docs/code/comments.md` has the rule, in their words.
