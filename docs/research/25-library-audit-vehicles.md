# Vehicles: existing libraries, and whether to use one
Asked: does a library drive a player-built welded assembly (wheels, seat, anything) from throttle and steer intent, with the driver as network owner? Made from the readers' file `25-library-audit-vehicles-all.md`, then this skeptic, 2026-11-21, all on Sonnet.

Checklist: 1 arbitrary assembly, 2 input separate from drive, 3 constraints or VehicleSeat plus driver owner, 4 tuning is data, 5 touch or input left to caller, 6 beyond cars, 7 commercial licence and maintained, 8 no framework.

## The answer
**Write our own.**
- No candidate passes 1. Every one that drives wheels hard-codes names and a count of wheels: `FL`, `FR`, `RL`, `RR` (Patch-The-Dev, Raycer), or `FL FR F RL RR R` (A-Chassis). (1)
- A-Chassis has no setter for throttle or steer. Its only outside hook is an optional `VirtualInput` event that carries keyboard-shaped input. Patch-The-Dev's `ApplyInput` rejects any caller that is not the seated player. (2)
- The one library that takes an array of wheels, MotorVehicle, does not drive them: you apply its output yourself, and its repository returns 404. (1, 3, 7)
- The only candidate with constraints, a licence and a recent commit is A-Chassis (MPL-2.0, 2026-10-31). It is a whole car kit (gauges, sounds, tires, a GUI), wheeled only. (6, 8)
- Nothing found handles boats or aircraft with source and a licence. (6)
- Patch-The-Dev has the best structure (typed, tested, frozen tuning table) and no licence file, so we may not use it. (7)

## Each candidate, after the second reading
| Name | Address | Licence | Last commit | Fails | What was wrong in the first reading |
|---|---|---|---|---|---|
| A-Chassis 1.7.2 | https://github.com/lisphm/A-Chassis | MPL-2.0 (LICENSE opened) | 2026-10-31 (readers; not shown on the page) | 1, 2, 6 | Line 2 is "partly", not "no": `VirtualInput.Event:Connect(DealWithInput)` exists, but the script does not create it, it takes InputObject-shaped data, and `DealWithInput` ignores it while chat or a text box has focus. Line 1 confirmed, and worse: front and rear wheel counts are divided by, so one axle likely divides by zero (inference). |
| Project Roadwork fork | https://github.com/project-roadwork/chassis | MPL-2.0 (README) | not shown | 1, 2, 6 | Not re-read. Still only the README. |
| Entity RA | https://github.com/totallyahuman445/Roblox-Entity-RA | GPL-3.0 | 2026-10-07 | 1?, 6, 7 | Search listing confirms "Land vehicle chassis system", GPL-3.0. Source still not opened. Dismissal stands on licence and scope. |
| Patch-The-Dev/car-chassis-system | https://github.com/Patch-The-Dev/car-chassis-system | none (29-file tree has no LICENSE) | 2026-10-01 | 1, 2, 6, 7 | Confirmed. Contract: "a direct child `Wheels` model or folder with `FL`, `FR`, `RL`, and `RR` BaseParts". `ApplyInput` returns false unless `self.driver.UserId ~= player.UserId` is false. Line 5 is "partly". No `GetAttribute` anywhere. |
| Raycer | https://github.com/Ransomwave/Raycer | MIT | 2026-11-04 | 1, 2, 3, 6 | Confirmed. `WHEEL_NAMES = { "FL", "FR", "RL", "RR" }`; `local throttle, steerInput = seat.ThrottleFloat, seat.SteerFloat`; no setter on the public API (`new`, `Init`, `Destroy`, `initClient`). Uses `workspace:Raycast`, not constraints. Line 2 can be worked round by setting `ThrottleFloat` on the seat, but the module is one rigid body on a ray spring. |
| VanillaEdge/Server-Authoritive-Vehicle | https://github.com/VanillaEdge/Server-Authoritive-Vehicle | MIT | 2026-07-30 | 1, 3, 5, 6 | Not re-read. |
| Apex Dynamics | https://github.com/arthurffht/apex-dynamics | MIT | 2026-11-02 | 1, 3, 6 | Not re-read. Its `Command` type is the cleanest input split of any candidate. |
| MotorVehicle | https://github.com/Daw588/motor-vehicle (404) | MIT, said by the author on 2023-01-26 | not found | 3, 6, 7 | Now read from the DevForum post: `MotorVehicle.new({root, wheels, torque, maxSteerAngle, turnSpeed, gearRatio})` and `bus:compute(deltaTime, {steerFloat, throttleFloat})`. It returns values and "doesn't drive the wheels for you". So line 1 is a near-yes (any array of wheels) and line 2 is a yes. It fails 3 because we write the constraints, and 7 because the source is unreachable and the post dates from 2023. API renamed in release 2.0.0 (2023-01-15). |
| raycastsuspensionwheel | https://github.com/LeehamsonThe3rd/raycastsuspensionwheel | MIT | not shown | 2, 3 | Not re-read. |
| Repulsyn | https://github.com/Kaminoan-Engineers/repulsyn | Apache-2.0 | 2025-07-26 | 1, 6 | Not re-read. Hover only. |
| OverEngineered | https://github.com/anywaymachines/overengineered | Apache-2.0 (LICENSE exists) | archived 2025-12-06 | 3, 8 | Tree read. Wheels, seats, motors, hinges, engines and wings are `.rbxmx` block files under `game/Assets/Placeable`. The `.ts` files seen are client and server controllers. No .ts file with a vehicle name was visible in the 200,000 of 294,000 characters read. So the vehicle behaviour sits in model files or in unread paths. Dismissal stands: a whole game. |
| Constraint Chassis (2019) | https://devforum.roblox.com/t/constraint-chassis/221717 | none stated: "open sourced" | post edited 2020-11-11 | 1, 6, 7 | Confirmed from the post. Needs a Model with `Body` and `Wheel`. Source is a place file. No licence terms. |
| VehicleSeat (engine) | https://create.roblox.com/docs/reference/engine/classes/VehicleSeat.md | engine | n/a | 1, 6 | Not re-read. A primitive. |
| StarryDrive 2.0, boat system | see readers' file | paid; none | n/a | 7 | Not re-read. |
| N-Chassis | https://github.com/NoodleDeveloper/N-Chassis | none | n/a | no code | Not re-read. |
| Y90G7IYO0987/CarSystem (new) | https://github.com/Y90G7IYO0987/CarSystem | none (tree has no LICENSE) | 2026-08-18 | 1, 2, 6, 7 | Found by this skeptic. Needs a Model with a `VehicleSeat` and a `PrimaryPart`; the script only spawns the car, sets `SetNetworkOwner(player)` and leaves driving to `VehicleSeat`. No drive logic of its own. |
| NGChassis | https://devforum.roblox.com/t/introducing-ngchassis-102-open-source-simple-realistic/986580 | not found | not found | not checked | Named by a search result as open source and 51 lines. The page text did not load. |

## What our own library should take from these
- Patch-The-Dev: build the constraints from a stated contract and refuse to start if it is broken (`VEHICLE_CONTRACT.md`, https://github.com/Patch-The-Dev/car-chassis-system). We would replace the fixed names with a scan for wheels.
- Patch-The-Dev: tuning copied and frozen at start (`ConfigCopy`, `ChassisConfig`), and tests that run in Studio.
- Apex Dynamics: `export type Command = { throttle, brake, steering }` as the one input type (`src/core/Input.luau`, https://github.com/arthurffht/apex-dynamics). A player and an AI both produce one.
- MotorVehicle: one pure function, `compute(deltaTime, {steerFloat, throttleFloat})`, returning the motor values (https://devforum.roblox.com/t/motorvehicle-chassis-programming-made-easy/2136669). It is testable with no Studio.
- A-Chassis: `SetNetworkOwner(player)` when the `SeatWeld` is added, and a `Tune` ModuleScript (https://github.com/lisphm/A-Chassis, `Scripts/Initialize.luau`).
- Raycer: `if seat:CanSetNetworkOwnership() then seat:SetNetworkOwner(player) end`, and the owner cleared when the seat empties (https://github.com/Ransomwave/Raycer).
- Raycer and VehicleSeat: default touch controls arrive free through `ThrottleFloat` and `SteerFloat`, so a driver client needs no touch code (check 5).

## What was not checked
- Source of Project Roadwork, Entity RA (inside `RA.rbxmx`), Constraint Chassis (place file), StarryDrive (closed) and the boat place file: not opened.
- VanillaEdge, Apex Dynamics, raycastsuspensionwheel, Repulsyn, N-Chassis: the readers' claims were not re-opened.
- A-Chassis last commit date: the page shows none. Only the README's 82 commits and the readers' date.
- MotorVehicle source: 404; judged from the DevForum post only. Posts 17 to 46 of its thread: not read.
- OverEngineered: the last ~94,000 characters of its file tree, and every `.rbxmx` block: not read.
- NGChassis: page did not load.
- pesde.dev and wally.run: the package search returned 404 or no pages. No Wally or pesde vehicle package: not found.
- Creator Store free models with source, awesome-roblox lists: not opened.
- GitHub topic `roblox-vehicle`: empty. GitHub API search (Luau, "roblox vehicle"; boat, aircraft, buoyancy, flight): read, nothing with a licence beyond the entries above. The second query returned only the first 17 of 78 results.
- Aircraft: only a DevForum reply pointing to Roblox's Aerodynamic Forces beta. Not opened.
