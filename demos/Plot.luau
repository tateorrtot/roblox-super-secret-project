--!strict
-- A plot with two placed objects on it, printed as text.
-- Run from the repository root: lune run demos/Plot

local Plot = require("../src/shared/plots/Plot")
local Position = require("../src/shared/Position")
local Signal = require("../src/shared/Signal")

local plot = Plot.new(4, 3)
print("A plot of 4 by 3 tiles.\n")

Signal.connect(plot.placedObjectAdded, function(id, placedObject)
	print(
		`  placedObjectAdded: {id}, a {placedObject.kindId} on the tile at {placedObject.tileX}, {placedObject.tileZ}`
	)
end)
Signal.connect(plot.placedObjectRemoved, function(id, placedObject)
	print(`  placedObjectRemoved: {id}, a {placedObject.kindId}`)
end)

print("Place a bench on the tile at 2, 1:")
local benchId = Plot.placeObject(plot, { kindId = "bench", tileX = 2, tileZ = 1 })

print("\nPlace a lamp on the tile at 4, 3, with a field of its own:")
local lampId = Plot.placeObject(plot, { kindId = "lamp", tileX = 4, tileZ = 3, lit = true })
local lamp = plot.placedObjectsById[lampId] :: Plot.PlacedObject & { lit: boolean }
print(`  the plot kept the lamp's own field: lit = {lamp.lit}`)

print(`\nCan an object be placed on the tile at 2, 1?  {Plot.canPlaceObject(plot, 2, 1)}, the bench stands there`)
print(`Can an object be placed on the tile at 3, 1?  {Plot.canPlaceObject(plot, 3, 1)}`)
print(`Can an object be placed on the tile at 5, 1?  {Plot.canPlaceObject(plot, 5, 1)}, the plot has no such tile`)

print("\nRemove the bench:")
Plot.removePlacedObject(plot, benchId)
print(`Can an object be placed on the tile at 2, 1?  {Plot.canPlaceObject(plot, 2, 1)}`)

local corner = Position.new(100, 0, 200)
local tileX, tileZ = Plot.getTileAt(corner, Position.new(113, 0, 209))
print(`\nA tile is {Plot.TILE_SIZE} studs wide. With the plot's corner at 100, 0, 200:`)
print(`  the position 113, 0, 209 is over the tile at {tileX}, {tileZ}`)
local center = Plot.getTileCenter(corner, 4, 3)
print(`  the middle of the tile at 4, 3 is at {center.x}, {center.y}, {center.z}`)
