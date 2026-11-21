# Vehicles: existing libraries (all)
Asked: does a library drive a player-built welded assembly (wheels, seat, anything) from throttle and steer intent, with the driver as network owner? Searched GitHub (repo search and trees), DevForum, Roblox docs. Date 2026-11-21, one reader on Sonnet.

Checklist: 1 arbitrary assembly, 2 input separate from drive, 3 constraints or VehicleSeat plus driver owner, 4 tuning is data, 5 touch or input left to caller, 6 beyond cars, 7 commercial licence and maintained, 8 no framework.

## Candidates

### 1. A-Chassis 1.7.2
Address: https://github.com/lisphm/A-Chassis. Licence MPL-2.0. Last commit 2026-10-31. Tests: none. Brings along: gauges, sounds, G-forces, aerodynamics, ignition, tire plugins, an interface GUI, a tune UI.
1. No. `local seat = car.DriveSeat`; `for _, v in car.Wheels:GetChildren() do`; `if v.Name == "FL" or v.Name == "FR" or v.Name == "F" or v.Name == "RL"` (Scripts/Initialize.luau). Also needs `SuspensionGeometry` with `Hub` and `Spring` in each wheel.
2. No. Drive.luau reads the keyboard itself: `UserInputService.InputBegan:Connect(DealWithInput)`. A `VirtualInput` event exists, but the key state is read in the same script.
3. Yes. `local rotationHinge = Instance.new("HingeConstraint")`; `local sp = Instance.new("SpringConstraint")`; `car.DriveSeat:SetNetworkOwner(player)` (Initialize.luau).
4. Yes. `A-Chassis Tune` ModuleScript.
5. Yes. `if _Tune.Mobile then` (Drive.luau).
6. No. Wheeled cars and bikes only. A DevForum reply says the author of one A-Chassis plane had imperfect physics (https://devforum.roblox.com/t/a-chassi-for-planes-and-boats/3072245).
7. Yes, licence and maintained.
8. Yes. It is a model with scripts, but it needs its own folder layout (`Plugins`, `Interface`).
Verdict: missing: 1, 2, 6.

### 2. Project Roadwork fork of A-Chassis
Address: https://github.com/project-roadwork/chassis (mirror of codeberg.org/project-roadwork/chassis). Licence MPL-2.0 ("this fork is licensed under the Mozilla Public License 2.0"). Last commit: not shown (83 commits). Tests: none. Changes listed: `RunService:BindToSimulation()`, `--!native`, `task.defer`. Same files as A-Chassis (README).
Source not read apart from the README. Its folders match A-Chassis.
Verdict: missing: 1, 2, 6 (same layout as A-Chassis; not independently read).

### 3. Entity RA (continues A-Chassis 6C)
Address: https://github.com/totallyahuman445/Roblox-Entity-RA. Licence GPL-3.0. Pushed 2026-10-07. Tests: none seen. The repo holds a model file `RA.rbxmx`, not readable source. README: "land vehicles".
Verdict: unsuitable: source is inside a binary-style model file (not opened), land vehicles only, GPL-3.0.

### 4. Patch-The-Dev/car-chassis-system
Address: https://github.com/Patch-The-Dev/car-chassis-system. Licence: none (no LICENSE file in the tree). Pushed 2026-10-01, 13 commits. Tests: yes, Studio suites (README: 162 structural and 46 multiplayer checks passed; Studio CI workflow disabled) plus StyLua, Selene, Luau analysis in GitHub Actions. Brings along: a driver input script, input rate limit, a registry, a bootstrap script.
1. No. `requires a VehicleSeat named DriveSeat`; `requires a Model named Body`; `local WHEEL_NAMES = { "FL", "FR", "RL", "RR" }` (src/server/VehicleChassis.luau). docs/VEHICLE_CONTRACT.md: "a direct child `Wheels` model or folder with `FL`, `FR`, `RL`, and `RR` BaseParts."
2. Partly. `function VehicleChassis.ApplyInput(` takes throttle, steer, brake, so drive reads values set elsewhere. It checks `self.driver.UserId ~= player.UserId`, so an AI with no player cannot call it as written.
3. Yes. `Instance.new("PrismaticConstraint")`, `Instance.new("SpringConstraint")`, `steering.ActuatorType = Enum.ActuatorType.Servo`, `motor.ActuatorType = Enum.ActuatorType.Motor`, `descendant:SetNetworkOwner(player)`.
4. Yes. `src/shared/ChassisConfig.luau`, copied and frozen: `local tune = ConfigCopy.copy(config or Config)`.
5. Partly. README: the driver uses the standard VehicleSeat input, so Roblox's own touch controls apply. `DriverInput.client.luau` not opened.
6. No. Four wheels only. The approach (server builds constraints from a contract) could be copied.
7. No. No licence means no right to use it. Active (last push 2026-10-01).
8. Yes. README: "no runtime packages".
Verdict: missing: 1, 2, 6, 7.

### 5. Raycer
Address: https://github.com/Ransomwave/Raycer. Licence MIT. Last commit 2026-11-04 (3 commits). Tests: none. Brings along: a flip-recovery timer, wheel visuals via `Motor6D`, a collision hull built from `Body`.
1. No. `const seat = car:WaitForChild("DriveSeat") :: VehicleSeat`; README: "a `Wheels` folder with exactly four parts named FL, FR, RL, and RR".
2. No. Input is read from the seat inside the same function: `ThrottleFloat and SteerFloat` as the source; the drive applies only when `driving`.
3. No on constraints: "Each car is one rigid body held up by a raycast spring"; uses `workspace:Raycast`. VehicleSeat: yes. `if seat:CanSetNetworkOwnership() then seat:SetNetworkOwner(player) end`.
4. Yes. `DefaultConfig.luau` plus a `Config` ObjectValue pointing at a ModuleScript.
5. Yes, by VehicleSeat.
6. No. README: "Four wheels only."
7. Yes licence, active. Very new and small.
8. Yes. `azul.package.json` is a sync file only.
Verdict: missing: 1, 2, 3, 6.

### 6. VanillaEdge/Server-Authoritive-Vehicle
Address: https://github.com/VanillaEdge/Server-Authoritive-Vehicle. Licence MIT. Pushed 2026-07-30 (15 commits). Tests: none. Brings along: gearbox, clutch, differential, engine, a client predictor.
1. No. `local seat = vehicle:WaitForChild("Driver", 5)`; needs a `Tune` ModuleScript, a `Wheels` folder with `Wheel`, `Mount`, `Welded`, and a `CarContext` object (src/CarSystemServer.luau).
2. Partly. Input comes from an InputContext cloned to the player.
3. No. Uses `WeldConstraint`, `VectorForce`, `AlignOrientation`. Network owner: `-- seat:SetNetworkOwner(...)` is commented out. README requires `Workspace.AuthorityMode` set to `Server`, which is the opposite of the driver-owned design.
4. Yes. `Tune` ModuleScript.
5. Not found.
6. No.
7. Licence yes. Four known bugs in README.
8. Yes.
Verdict: missing: 1, 3, 5, 6.

### 7. Apex Dynamics
Address: https://github.com/arthurffht/apex-dynamics. Licence MIT. Pushed 2026-11-02. Tests: yes (`tests/run.luau`, Studio multiplayer suites). Brings along: PowerShell scripts, Serena and agent tooling, research archive, a laboratory place, SI unit conversion.
1. No. `VehicleFactory` builds a fixed model: one chassis, one seat, four wheels; `assert(not chassis.Anchored, "Vehicle chassis must be unanchored")`.
2. Yes. `export type Command = { throttle: number, brake: number, steering: number }` (src/core/Input.luau).
3. No constraints: `chassis:ApplyImpulseAtPosition(contactImpulse.impulse, contactImpulse.position)` with `Workspace:Raycast`. `chassis:SetNetworkOwner(nil)`: the server owns the chassis.
4. Yes, a preset table (`ReferenceSedan`).
5. Left to the caller; no touch.
6. No. README lists no aircraft or boats.
7. Licence yes. README: "project foundation and laboratory" phase, no vehicle spawned by default.
8. Yes, but a heavy toolchain around it.
Verdict: missing: 1, 3, 6. Also not finished.

### 8. MotorVehicle
Address: https://github.com/Daw588/motor-vehicle (from the DevForum post, https://devforum.roblox.com/t/motorvehicle-chassis-programming-made-easy/2136669). Not opened: the GitHub address returned 404. Licence: MIT per a later post by the author (post 16, as summarised). Last commit not found. Tests not found.
From the post: `compute(deltaTime, config)` returns values to apply; "doesn't drive the wheels for you". It needs a VehicleSeat and wheel parts.
Verdict: missing: 3 (it computes only), 7 (source not opened, dates not found). Based on the post, not source.

### 9. raycastsuspensionwheel
Address: https://github.com/LeehamsonThe3rd/raycastsuspensionwheel. Licence MIT. 16 commits, last commit not shown. Tests: none. Files: `wheel.lua`, `exampleplace.rbxl`.
1. Partly. Each wheel needs children `Attachment`, `VectorForce`, `Weld`, and the model a `PrimaryPart`.
2. No. wheel.lua: "no drive, steering, or throttle logic". Suspension only.
3. No. `self.VectorForce.Force = self.SuspensionForce + ...`; no `SetNetworkOwner`.
4. Yes. Attributes: `Model:GetAttribute("SuspensionHeight")`.
5. Not found.
6. No.
Verdict: unsuitable: suspension only, no drive.

### 10. Repulsyn
Address: https://github.com/Kaminoan-Engineers/repulsyn. Licence Apache-2.0 (search listing). Pushed 2025-07-26, 23 commits. Tests: none ("TODO: Describe and show how to build your code and run the tests."). Hover lift for land, sea and air. Source not opened.
Verdict: unsuitable: hover lift only, no wheels; Getting Started is a TODO.

### 11. OverEngineered
Address: https://github.com/anywaymachines/overengineered (archived 2025-12-06). Licence Apache-2.0 ("licensed under a Apache License 2.0"). A whole sandbox game with player-built planes and cars, roblox-ts. README does not mention wheels or seats. Source of the vehicle code not opened. A second address, programthat/overengineered, was listed by search as a non-commercial licence; it returned 404 on fetch.
Verdict: unsuitable: a whole game, archived, vehicle code not opened.

### 12. Constraint Chassis (DevForum, 2019)
Address: https://devforum.roblox.com/t/constraint-chassis/221717. Source is a place file only (`ConstraintChassis (DampFix).rbxl`), not opened. Licence not stated ("open sourced" only). Post says it has suspension, mobile controls, real-time configuration, automatic network ownership.
Verdict: unsuitable: not opened, no licence, wheeled only, 2019.

### 13. Roblox VehicleSeat (engine)
Address: https://create.roblox.com/docs/reference/engine/classes/VehicleSeat.md. Licence: part of the engine. Tests: n/a.
1. Partly. "Movement control will only detect motors connected directly to the vehicle seat, or through another rigid connection." You add the motors yourself.
2. Partly. `ThrottleFloat` and `SteerFloat`: "resets to `0` unless it is set continuously." A script can set them, so an AI can drive.
3. Yes. It forwards inputs "to any connected motor joints".
4. Fields on the seat (`MaxSpeed`, `Torque`, `TurnSpeed`).
5. Roblox's default touch controls apply.
6. No.
Verdict: missing: 1 (no suspension or steering rig), 6. It is a primitive, not a library.

### 14. StarryDrive 2.0, boat system
StarryDrive: https://devforum.roblox.com/t/starrydrive-20-build-stable-vehicles-in-minutes/4750344. Paid ($7.99), raycast suspension, boats listed, closed source.
Verdict: unsuitable: paid, not open source.
Realistic Boat System: https://devforum.roblox.com/t/realistic-boat-system-floats-on-terrain-water-optimized-free/3541235. A place file, no licence, author says no further updates.
Verdict: unsuitable: place file, no licence, not maintained.

### 15. N-Chassis, MotorVehicle-era others
https://github.com/NoodleDeveloper/N-Chassis: README only, 3 commits, no licence.
Verdict: unsuitable: no code.

## What was searched and found nothing
- A Wally or pesde package for vehicles: not found. The search tool returned none; wally.run and pesde.dev were not opened.
- An open-source plane or aircraft system with a licence: not found. Only a DevForum reply pointing at Roblox's Aerodynamic Forces beta (https://devforum.roblox.com/t/introducing-aerodynamic-forces-studio-beta/2569269, not opened).
- A boat library with source and a licence: not found. Repulsyn and StarryDrive are the only ones that mention sea.
- Roblox's own vehicle sample or racing template: the docs page `create.roblox.com/docs/physics/vehicles.md` returned 404. The racing template thread was not opened.
- Plane Crazy and Build a Boat: no published description of their method found.
- GitHub topic pages, awesome-roblox lists, Creator Store: not opened. GitHub API search was used until it returned 403.
- Creator Store free models with source: not opened.

## The nearest miss, and what it lacks
Patch-The-Dev/car-chassis-system. It uses `HingeConstraint`, `SpringConstraint` and `PrismaticConstraint`. The driver or the server owns the physics. Tuning is a frozen table. It has real tests and no packages.
It lacks:
- 1: needs `DriveSeat`, `Body`, and a `Wheels` model with `FL`, `FR`, `RL`, `RR`. It does not accept an arbitrary assembly.
- 2: `ApplyInput` rejects any caller that is not the seated player's `UserId`. An AI has no entry.
- 6: four-wheeled cars only.
- 7: no licence file.
It is 13 commits old with one author, so it is also unproven.
