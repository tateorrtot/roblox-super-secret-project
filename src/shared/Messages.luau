--!strict
--[=[
	The name of every message that a player's machine and the server send
	each other. Nothing else crosses between them, apart from what Roblox
	itself copies, such as the parts in the world.

	The server makes one RemoteEvent for each name. A player's machine may
	send anything at all under these names, so the server checks every
	message before acting on it, and ignores one that makes no sense.

	From a player's machine to the server (`toServer`):

	| Name | Sent with | Asks the server to |
	|---|---|---|
	| `askForInventory` | nothing | send `inventoryChanged` again, whether or not anything changed |
	| `openPack` | nothing | open the inventory screen on the player's pack alone |
	| `closeInventory` | nothing | close the inventory screen |
	| `clickSlot` | side, slot, button | do a mouse click on a slot of the open screen, as `InventorySession.click` does |
	| `quickMoveSlot` | side, slot | send a slot's stack to the other inventory, as `InventorySession.quickMove` does |
	| `dropCarried` | count, or nothing for all | drop carried items on the ground |
	| `selectHotbarSlot` | slot | select a hotbar slot |
	| `dropSelected` | nothing | drop one item from the selected hotbar slot on the ground |

	From the server to one player's machine (`toClient`):

	| Name | Sent with | Says |
	|---|---|---|
	| `inventoryChanged` | pack, screen | what the player's inventories hold now |

	In `inventoryChanged`, `pack` is the player's pack as `Inventory.encode`
	makes it. `screen` is `nil` when no inventory screen is open. When one is
	open it is a table of three things, each of which may be `nil`:
	- `other`: the other inventory that is open beside the pack, encoded;
	- `otherItemId`: the id of the item whose inventory that is, such as
	  `"crate"`;
	- `carried`: the stack being carried.
]=]

return table.freeze({
	toServer = table.freeze({
		"askForInventory",
		"openPack",
		"closeInventory",
		"clickSlot",
		"quickMoveSlot",
		"dropCarried",
		"selectHotbarSlot",
		"dropSelected",
	}),
	toClient = table.freeze({
		"inventoryChanged",
	}),
})
