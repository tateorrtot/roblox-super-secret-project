# Objects that are placed in the world, joined together, and broken off: what Roblox already has

Asked: what Roblox provides for placing, joining and breaking off objects, so the team does not rebuild it. Read by one reader on Sonnet, on 2026-11-21.
Each fact has its address in `[S#]`; the addresses are under Sources. Pages were read as plain text through the `.md` form.

## What Roblox has

### Assemblies (question 1)
- An assembly is "one or more parts welded by a rigid `WeldConstraint` or connected through movable joints, like `Motor6D`s". It is one rigid body. [S1]
- Joints that make assemblies are active only in `Workspace` or another `WorldModel`. Parts stored elsewhere are not joined. [S1]
- `BasePart.AssemblyRootPart` is the part chosen to represent the assembly. The root part cannot be set directly. [S1]
- `BasePart.AssemblyMass` is the sum of the parts' `Mass`. With an anchored part it counts as infinite. [S1]
- One anchored part in an assembly becomes the root part. Every other part is then implicitly anchored. [S1]
- Two or more anchored parts in one welded group: "the assembly will split". A `WeldConstraint` between two anchored assemblies deactivates. [S1]
- `WeldConstraint` joins two `BaseParts` through `Part0` and `Part1` and keeps their relative position and orientation. The parts need not touch. [S2][S3]
- `WeldConstraint` uses no attachments. Setting a part's `CFrame` moves all connected parts. Setting `Position` moves only that part, and the offset is recomputed. [S2][S3]
- `WeldConstraint` or any rigid joint can be disabled by a conflict: duplicate joints between the same two parts, or a cycle in the weld graph. A disabled joint may re-enable when other joints or parts are added or removed. [S2][S4]
- The joint is inactive when it or either part is not in `Workspace`. [S2]
- `Weld` (a `JointInstance`) holds `Part0` and `Part1` apart by `C0` and `C1`. Its class page recommends `RigidConstraint` in its place. [S5]
- `RigidConstraint` joins two `Attachment` or `Bone` instances at zero offset through `Attachment0` and `Attachment1`. [S6][S7]
- `BasePart:GetConnectedParts(recursive)` returns parts linked by rigid joints: `Weld`, `Snap`, `ManualWeld`, `Motor`, `Motor6D`, `WeldConstraint`. With `recursive` true it returns the whole assembly. [S8]
- `BasePart:GetJoints()` returns the active joints and constraints of a part. [S8]
- `BasePart:BreakJoints()` is deprecated. The page says to loop over `GetJoints()` and destroy the joints wanted. [S8]

### Moving and placing a Model (question 3)
- `PVInstance:PivotTo(cframe)` moves the model and all descendants to a `CFrame`. It does not lift the model when something is in the way. [S9]
- `PVInstance:GetPivot()` returns the pivot that `PivotTo` moves. [S9]
- `Model.PrimaryPart` defaults to nil. When set, the pivot follows it. It must be a descendant, or it resets to nil on the next simulation step. [S9]
- `Model.WorldPivot` is used only when `PrimaryPart` is nil. A new model's pivot is its bounding box centre until `WorldPivot` is first set. [S9]
- `Model:GetBoundingBox()` returns a `CFrame` and a `Vector3` size, oriented to the pivot. The size may be inaccurate at run time if constraints act on the parts. [S9]
- `Model:GetExtentsSize()` returns the size only. [S9]
- `Model:MoveTo(position)` lifts the model upward until nothing is in the way and does not keep rotation. `Model:TranslateBy(delta)` keeps orientation and ignores collisions. [S9]
- `Model:ScaleTo(factor)` and `Model:GetScale()` scale around the pivot. [S9]

### DragDetector (question 4)
- Put under a `BasePart` or `Model`, it makes the object draggable by mouse, touch, gamepad and VR with no code. [S10][S11]
- `DragStyle` values named: `TranslateLine`, `TranslatePlane`, `RotateAxis`, `RotateTrackball`, `Scriptable`. [S10]
- Limits: `MinDragTranslation`, `MaxDragTranslation`, `MinDragAngle`, `MaxDragAngle`. They impede motion and are not true constraints. [S10][S11]
- Events: `DragStart`, `DragContinue`, `DragEnd`. [S10]
- `SetDragStyleFunction(fn)` (with `Scriptable`) takes the cursor `Ray` and returns a world `CFrame`; nil leaves the object still. [S10]
- `AddConstraintFunction(priority, fn)` takes a proposed `CFrame` and returns a changed or unchanged one. Functions run from highest priority down. It returns a connection to `Disconnect`. [S10]
- The docs' sample snaps drag motion to a world grid of 4 studs by rounding in a constraint function. [S11]
- `ResponseStyle`: `Geometric`, `Physical`, `Custom`. `Physical` uses `MaxForce`, `MaxTorque`, `Responsiveness` on an unanchored parent. [S10][S11]
- `RunLocally` false (default): the client reads input and sends the drag to the server; event handlers go in server scripts. True: nothing replicates; handlers go in client scripts and remotes carry changes. [S11]
- `PermissionPolicy` defaults to `Everybody`; `Nobody` blocks all; `Scriptable` uses `SetPermissionPolicyFunction`, and blocks all if none is set. [S11]

### Attachment and constraints with two attachments (question 5)
- `Attachment` is a point and orientation relative to a parent `PVInstance`, `Bone` or `Attachment`. Properties: `CFrame`, `WorldCFrame`, `Axis`, `SecondaryAxis`. [S12]
- `Constraint` classes connect through `Attachment0` and `Attachment1`. `WeldConstraint` and `NoCollisionConstraint` are the exceptions and use `Part0` and `Part1`. [S13]
- `HingeConstraint`: rotation about one axis. `ActuatorType` of `Motor` or `Servo` powers it. `LimitsEnabled` with `LowerAngle` and `UpperAngle` limits it. [S14]
- `PrismaticConstraint`: sliding along one axis with no relative rotation. Options come from `SlidingBallConstraint` (`LowerLimit`, `UpperLimit`, `ActuatorType`). [S15]
- `RopeConstraint`: keeps the attachments no farther apart than `Length`; they may come closer and rotate freely. `WinchEnabled` makes it a winch. [S16]
- The mechanical-constraints page lists the others: `BallSocketConstraint`, `CylindricalConstraint`, `UniversalConstraint`, `PlaneConstraint`, `SpringConstraint`, `TorsionSpringConstraint`, `RodConstraint`. [S13]
- A weld holds a fixed pose. The other constraints allow motion, limits or forces. This is the page's description; it gives no rule for choosing. [S13]

### Network ownership (question 6)
- The engine assigns ownership of simulated `BaseParts` to the server or a client. [S17]
- Stated default: the server keeps ownership of any `BasePart`. The same page says the engine automatically assigns unanchored parts to a client by hardware and proximity to the player's character. [S17]
- `BasePart:SetNetworkOwner(player?)` gives ownership to a player for the part and all connected parts. The default argument nil means the server. It is not thread-safe. [S8]
- `BasePart:GetNetworkOwner()` returns the player, or nil for the server. [S8]
- `BasePart:SetNetworkOwnershipAuto()` and `GetNetworkOwnershipAuto()` return control to the engine and read that state. [S8]
- `BasePart:CanSetNetworkOwnership()` returns true, or false and a reason. [S8]
- The server always owns anchored parts and their ownership cannot be changed. [S17]
- Setting ownership on one assembly of a mechanism with no anchored part applies to every assembly of that mechanism. [S17]
- The page advises using `SetNetworkOwner` sparingly, because it can make client physics jitter. [S17]

### Grid and snapping tools (question 7)
- `DraggerService` holds the settings of Studio's Move, Scale and Rotate tools: `LinearSnapEnabled`, `LinearSnapIncrement` (grid spacing in studs), `AngleSnapEnabled`, `AngleSnapIncrement`, `JointsEnabled`, `CollisionsEnabled`. [S18]
- The class is `NotCreatable` and its properties describe Studio editing. The page does not state whether it works in a published game at run time. [S18]

## What it does not do
- The docs index lists no run-time building system for players: no placement grid, ghost preview, rotation keys or build mode. [S19]
- `DragDetector` has no built-in grid or snapping. Snapping is a function the game adds. Its limits are not constraints. [S10][S11]
- `DraggerService` is described only as Studio tool settings. Not found: whether a game can use it at run time. [S18]
- Not found: what happens to the two groups when a weld is destroyed (split time, root part choice). The assemblies and `WeldConstraint` pages do not say. [S1][S2]
- Not found: whether parts keep their velocity after a split. [S1][S2][S5]
- Not found: full `Weld.C0` and `Weld.C1` descriptions (page text was cut off). [S5]
- Sources disagree: the `Weld` page recommends `RigidConstraint` in its place, and the `RigidConstraint` page says to use `WeldConstraint` for two `BaseParts`. [S5][S7]
- Sources disagree: the ownership page says the server keeps ownership by default, and also that the engine assigns unanchored parts to a client. [S17]
- Sources differ: `GetConnectedParts` lists `Weld`, `Snap`, `ManualWeld`, `Motor`, `Motor6D`, `WeldConstraint`. The assemblies page names only `WeldConstraint` and `Motor6D`. [S1][S8]

## What a game must still build
- Not found in the docs: any rule for where a placed object may stand, or any check that a placement is allowed.
- Not found: any feature that saves, rebuilds or replicates players' structures by kind.
- Not found: any call that names which parts a break would separate. `GetConnectedParts(true)` returns the whole assembly. [S8]

## Sources
All under https://create.roblox.com/docs/ with `.md` added; read 2026-11-21.
- S1 physics/assemblies.md
- S2 reference/engine/classes/WeldConstraint.md
- S3 physics/constraints/weld.md
- S4 reference/engine/classes/JointInstance.md
- S5 reference/engine/classes/Weld.md
- S6 reference/engine/classes/RigidConstraint.md
- S7 physics/constraints/rigid.md
- S8 reference/engine/classes/BasePart.md
- S9 reference/engine/classes/Model.md
- S10 reference/engine/classes/DragDetector.md
- S11 ui/3D-drag-detectors.md
- S12 reference/engine/classes/Attachment.md
- S13 physics/mechanical-constraints.md
- S14 reference/engine/classes/HingeConstraint.md
- S15 reference/engine/classes/PrismaticConstraint.md
- S16 reference/engine/classes/RopeConstraint.md
- S17 physics/network-ownership.md
- S18 reference/engine/classes/DraggerService.md
- S19 llms.txt (index; only the first 100000 characters were read)

## Checked by a second reader
- Claims checked: 30. Read 2026-11-21 through the `.md` form of each page. Confirmed: 24. Wrong or overstated: 2. Sources disagree: 1. Unconfirmed: 5 (listed below).

### Wrong or overstated
- Line 19: "Its class page recommends `RigidConstraint` in its place." The `Weld` page says "See also RigidConstraint for a newer alternative using the constraints system that does not require C0 or C1". That is an alternative, not a replacement. It does not say `Weld` is deprecated. https://create.roblox.com/docs/reference/engine/classes/Weld.md
- Line 17: duplicate joints are listed as a conflict for `WeldConstraint`, citing [S2][S4]. The `WeldConstraint` page says "Duplicate WeldConstraints do not conflict", though the spanning tree may still disable a redundant one or one in a cycle. Only the `JointInstance` page says joints "between the same two parts" conflict. https://create.roblox.com/docs/reference/engine/classes/WeldConstraint.md and https://create.roblox.com/docs/reference/engine/classes/JointInstance.md

### Sources disagree (not stated in the brief)
- Duplicate welds: the `WeldConstraint` page and the `JointInstance` page differ, as above.

### Unconfirmed
- Line 58: that the engine assigns unanchored parts "by hardware and proximity to the player's character". The page says the engine "automatically assigns ownership of that part to the client". Hardware and proximity not found in the text read. https://create.roblox.com/docs/physics/network-ownership.md
- Line 40: that `SetDragStyleFunction` takes the cursor `Ray` and returns a world `CFrame`. Only the nil-return behaviour and the `Scriptable` requirement were found. https://create.roblox.com/docs/reference/engine/classes/DragDetector.md
- Line 41: that `AddConstraintFunction` returns a connection with `Disconnect`. Priority order ("Higher values take precedence") was found; the return value was not.
- Line 43: `MaxForce`, `MaxTorque` and `Responsiveness` as the `Physical` response properties. The guide says only that constraint forces move an unanchored object. https://create.roblox.com/docs/ui/3D-drag-detectors.md
- Line 72: that the docs index lists no run-time building system. This is a claim of absence. The index was not searched here.

### Notes on confirmed claims
- Line 37 lists five `DragStyle` values. The guide lists nine, including `TranslatePlaneOrLine`, `TranslateLineOrPlane`, `TranslateViewPlane` and `BestForDevice`. The brief's list is partial, not wrong.
- Line 78 (`RigidConstraint` page says use `WeldConstraint` for two `BaseParts`): found on https://create.roblox.com/docs/physics/constraints/rigid.md, not on the class page [S6].
- `DraggerService` also has read-only properties (`PartSnapEnabled`, `PivotSnapToGeometry`, `UseBoundingBoxes`) and `AlignDraggedObjects`, `DraggerMovementMode`. The page makes no run-time statement, as the brief says.
- `BasePart.BreakJoints` is marked deprecated, and the page's advice matches the brief.
