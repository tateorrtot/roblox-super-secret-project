# The vehicle gym

Tried on the night of 2026-11-21, after the user named vehicles as a next part of the game.

## What it tries
Whether a vehicle can be any body of welded blocks, with wheels at any places, driven by one small function that is handed what the driver wants. Nothing here has a fixed name such as `FL` or `RR`, which every chassis library found that night requires (`docs/research/25-library-audit-vehicles.md`).

## How to run it
With Studio open on the place: `python gyms/vehicles/run.py`. It starts a play test, builds two bodies on a floor 600 studs above the world, drives each through phases, and stops the play test. It does not take the mouse. `lune run gyms/vehicles/Drive.test` tests the function alone.

## The files
| File | What it is |
|---|---|
| `Drive.luau` | The function. Plain Luau, 80 lines with its comments. It is handed the wheels (where each is, whether it steers, whether it drives), a command (`throttle` and `steer`, each from `-1` to `1`), and the vehicle's numbers. It returns a spin and a steering angle for each wheel. If no wheel steers, it turns the body as a tank turns |
| `build.server.luau` | Builds the two bodies from parts, `WeldConstraint`s, and `HingeConstraint`s. A driving wheel hangs on one hinge that is a motor. A steering wheel hangs on a second hinge that is a servo, about the vertical |
| `drive.server.luau` | Calls `Drive.getWheelOutputs` every frame, writes each output to its hinge, and measures the body |
| `camera.client.luau` | Points the client's camera at a body |

## What was found
Measured on the server of a play test in Studio, on one PC, with the server as the owner of every part.

| Body | What it is | Result |
|---|---|---|
| A | A deck of 15 blocks with a cabin and a cargo block off its middle: 23 parts, mass 246. Two steering wheels ahead and two plain driving wheels behind, at uneven places | In 3.5 seconds at full throttle it went 97.35 studs ahead and 0.23 studs aside, and reached 29.94 studs a second against a top speed of 30. With full steer for 3 seconds it turned 59.33 degrees to the right. It never tilted more than 0.28 degrees |
| B | An uneven deck of 6 blocks with a tower: 11 parts, mass 98.7. Four driving wheels and none that steers | It went straight at 23.82 studs a second for a throttle of 0.8. With a steer of 0.8 it turned 310 degrees in 3 seconds, and with no throttle it spun on the spot. That is far too fast to drive, and is one number, `skidRatio`, to tune |

- **The idea holds.** One function of 80 lines drives both bodies, and knows no Roblox instance. A person's input and a helper's brain would hand it the same two numbers.
- **A wheel must not collide with the body that it is on.** In the first run, body A turned 1.91 degrees where it should have turned about 60. Each steering wheel had hit the edge of the deck at 18 degrees and rubbed on it. A `NoCollisionConstraint` between each wheel and each part of its body mended it. A game where players place wheels needs this for every wheel.
- **What is cut loose becomes a body of its own while the vehicle moves.** The gym destroyed the one weld of the cargo block at 18 studs a second. The block's `AssemblyRootPart` was at once no longer the vehicle's, and the vehicle drove on.
- **The two signs are turned over where the function meets the hinges.** A positive spin about an axle that points to the body's right rolls the body backwards, and a positive angle about the vertical turns a wheel to the left.

## What was not tried
- A player in a seat, and the player's client as the owner of the body, which is how Roblox makes driving feel immediate.
- Springs. Each wheel is on a rigid hinge, and the floor is flat.
- A body that changes while it drives: a wheel added, or the deck cut in two.
- More than two bodies, a slope, a phone.
- A screenshot. Each one came out empty, and the cause was not found.
