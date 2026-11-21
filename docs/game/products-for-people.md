# Products for People: the game as another agent summed it up

On 2026-11-21 the user talked the game over with a Gemini model, which wrote a brief of it. The user showed the brief to Claude the same day and said of it: "I did not write it. The other agent did", and "it sounds like everything is good and accurate". This file keeps what that brief says of the game, its look, and its code. It is the first written statement of the game's working title, its inspirations as one list, and its art direction. The brief's words are quoted. What Claude adds is marked as Claude's.

## The game
- **Working title:** "Products for People".
- **Inspirations:** "Lumber Tycoon 2, Retail Tycoon, Minecraft, RimWorld, Scrap Mechanic, Terraria, and ARK."
- **What a player does:** "A non-linear, systemic "rags-to-riches" sandbox. Players collect multi-use resources, build modular vehicles and trains, use hand-authored tools with emergent physics interactions (e.g., a magic wand that grows giant climbable plant ramps), and haul goods across dangerous landmarks (like volcanoes) to sell in dynamic markets (like a Robot City)."
- **The design rule, "Everything Needs Several Uses":** "Hand-author the nouns and verbs (items, vehicles, landmarks, NPCs), never linear scripted solutions. Items interact systemically across crafting, fuel, electricity, combat, building, and dynamic regional economy demand."
- **Claude's note:** the brief calls the second point a "Core Loop". The rule of `brief.md` stands: no one activity is named as the core. Hauling and selling is one thing a player does among several.

## The platform and the look
- **Roblox,** "chosen over Godot/Steam for zero-friction click-to-play multiplayer, free servers, cross-platform reach, and built-in algorithmic discovery".
- **Every asset is made by hand, in Blockbench:** the world, vehicles, tools, NPCs, and the players' own character rigs, with "crisp pixel-art textures (ResampleMode = Pixelated in Roblox Studio) and stepped keyframe animations". No default Roblox avatar and no stock asset. A player's character is customised in the same style: fur patterns, hats, backpacks, hazard suits.
- **Claude's note:** this agrees with the rule that no AI-generated art reaches the public. It also means that a character is a custom rig, so no code may assume Roblox's R6 or R15 body.

## What the brief says of the code
These are the other agent's proposals. The user has not adopted them: they showed them to Claude on the day they were written.
- "Use a Data-Driven Tag + Attribute Architecture (CollectionService tags like Fuel, Sellable, Conductive, Mountable + Instance Attributes) instead of hardcoded item-name checks or bloated OOP/ECS boilerplate."
- "Keep centralized server-authoritative ModuleScript services in ServerScriptService, lightweight Lua dictionary inventories (persisted via ProfileStore), and simple invisible box colliders welded to Blockbench visual meshes for smooth vehicle/train physics."
- "Stop refactoring invisible systems and immediately shift to building Region 1 (Vertical Slice): a safe hub (shop, garage, buyers), a nearby resource zone, 15–20 multi-use items, 1 basic vehicle chassis, and a clear 60-second new-player onboarding flow."

## What a second Gemini model added, in the same talk
- **Fewer items first:** five or six, each with at least three uses, in place of 15 to 20.
- **The hard part is physics:** loose cargo in the bed of a moving vehicle, and who owns each part on the network.
- **Two decisions it says come before content:** whether an item is a thing in the world, a thing in a pocket, or both; and whether cargo is welded to the bed or rides loose.
- **Its six items:** a pine log, a coal chunk, a copper coil, tree resin, a vine pod, and a salvage battery. The user has not said yes to these.

## One thing in the brief that is wrong
"Inventory and building systems exist in library-template." They do not. The folder `library-template`, beside this repo, is the empty start of a new library. The inventory is the library in the folder `inventory`, and this repo's `src` holds an older inventory of its own and the code for placing objects.
