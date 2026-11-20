# The eighth review: the item decides, and no invented words (2026-11-20)

The user answered Claude's report on the day's work. Their words, and what Claude took from them. How far each fault runs through the code is in `docs/code/reviews/17-audit-after-the-eighth-review-2026-11-20.md`.

## Roblox's word, or Godot's, and never one of ours
Claude had described `Signal.fire` to them as Godot's `emit`.
> Why fire and not emit? Whys it not follow godot conventions? Are you following roblox conventions? If youre following roblox conventions stick to it. If youre following invented conventions - go with godots

- **Where Roblox has a word for a thing, use it, and keep to it.** `connect` and `fire` are Roblox's: `RBXScriptSignal:Connect` and `BindableEvent:Fire`. They stay.
- **Where Roblox has none, use Godot's.** A convention of Claude's own is the last choice, and is said to be one.
- **Explain by the Godot counterpart, and say which is which.** Claude wrote "Godot's `signal`, `connect`, `emit`" beside functions named for Roblox's, and the user took the names for a mistake.

## "Did you fix what they found?"
Claude had reported that seven cold readers and two reviewers found six small things, "all fixed".
> Did you fix what they found?

- **No.** The readers marked 56 members as ones they would not bet on. Claude changed one, `movedIds`, and passed over the rest as doubts about a type or an amount. Of the reviewers' ten findings, eight were fixed and two were left and noted.
- **A reader's doubt is fixed, or it is listed with the reason it stands.** It is never passed over out of sight. This is the rule of the sixth review again: "When a cold reader doubts a name, change it."
- **A report says what was left.** "All fixed" was not true.

## Breaking a placed item
Claude had asked whether "a crate knocked off the plot" should spill what is in it or keep it inside.
> okay so im assuming you mean a crate in ITEM form right..? or do you mean an item that was placed you knock it off the plot? like break it? yes if you break it, it should spill contents.

> Im a bit confused though, what are the methods to detect a placed item to break? Is placed item the best name for it across the codebase? Whats the full method "pipeline" of how a crate gets broken and it along with its items end up on the ground.

> Shouldnt it be the item itself that determines what happens when it breaks? For example obsidian in minecraft doesnt drop its item unless you got a diamond pickaxe or netherite pickaxe. its the strategy pattern basically. you just made the contact that "breaking a placed item always drops some item [its version of itself in normal item form] along with its contents [you just made the contract for placed items to always or be assumed to maybe have contents?]"

> are you doing this too with "place items" as a whole? like when you left click with somethings it not actually determined if its going to "place" it in item form. its more like a component. for example a wand and a log are both just plain inventory items (specifiying inventory here since placed item exists, this is a bit confusing...). if you interact with a log over a valid plot spot it places. if you do the same with a wand it might cast a spell. see how that works? it sounds like youre favoring inheritance over composition - thats bad! you end up with functions like "throwPlacedItemAndContents". What script is that even in? Why does it know about placed item and contents? Bit weird. A placed item and "contents" dont really have anything to do with eachother unless specified.

And of the question itself:
> Dude. This is going to be spaghetii. Its per placed item (or whatever were calling it). Who knows if a crate does it. Id say a crate SPECIFICALLY shouldnt do it. What if we have a sack like from the mod supplementaries? You break it and the items stay inside like a shulker box. Or just a shulker box. What if we break it and the items transform. What if we break it and theres not items in there. What if we break it and its like a cage thats containing an entity so now the entity should actually pop out say a bunny rabbit.

- **The item decides what happens to it.** What using it does, and what breaking it leaves, belong to that kind of item. The rest of the game knows that a thing was used or broken, and nothing of what follows.
- **The game makes no promise for every item.** Today it makes several: a hit takes any placed item off the plot and drops it with every stack inside it; using any placed item opens its inventory; a click on a tile with a placeable item in hand places it. Each is a contract nobody asked for.
- **Composition, not inheritance.** A kind of item is put together from parts, and each part brings its own behaviour: one that places, one that holds stacks, one that casts a spell.
- **A question that offers two answers for all items is the wrong question.** A crate spills. A sack keeps what is in it. A cage lets a creature out.
- **Say "break", and "interact".** "Knocked off the plot" was Claude's phrase, and the user had to ask what it meant. Their words are the ones in the names.
- This is the seventh review's "contain the spaghettii" again (`docs/game/placed-items.md`). Claude wrote it down then, left the code as it was, and built a question on the old shape.

## Names that cannot be read
Of the class `UseAndHit`, and of `PlotControls`, which Claude had offered in its place:
> Okay both those names i cant tell what the heck this thing is. Plot Controls? UseAndHit is pretty bad VerbAndVerb. And plot controls like, controling a plot? Im confused? Theres a class / object somewhere whose job it is to control a plot? isnt that the plots job?

> are you doing a pattern of this across the codebase? any of these issues im bringing up?

- **A noun that can be read two ways is a failed name.** "Controls" was meant as the keys and buttons a player uses. It reads as a thing that controls.
- **A class's name says what the thing is,** to someone who does not know what the program does.

## "what are due items"
Claude had offered `mergeDueItems` as another name for `GroundItems.mergeItems`.
> what are due items. did you just invent that. Heres the thing. You cant just... invent nouns out of nowhere that dont exist in the codebase does that make sense? Like what the heck is a due item? I know what an item is. I as a human understand the verb merge. But a "DueItem". is that a class? What is that? Are you using it like an adjective like "Items (that are due)" in the same way youd say "MergeRedItems"?

- **Every word in a name is a thing in the code, or a plain word nobody could doubt.** "Due" was neither. It was an adjective of Claude's for "the ground items whose turn it is", and read as a kind of item.
- The seventh review had the same rule for `Transform`: "is transform a defined solid thing? like a class? if not dont do transform". Claude wrote the rule down and broke it the same day.
- The word was in the code as well, in a private function. It is gone.

## What Claude did the same day
- Took "due" out of the code.
- Had the whole of `src` audited for the four faults, by readers checked by skeptics. The result is `docs/code/reviews/17-audit-after-the-eighth-review-2026-11-20.md`.
- Wrote the rules into `docs/code/names.md` and `docs/code/conventions.md`.
- Showed the user the pipeline of a break as it is, and a shape in which the item decides, and built none of it. It is shared machinery.
