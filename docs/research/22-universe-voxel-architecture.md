# Universe Voxel Simulation — Technical Architecture Summary

## 1. Core Design Philosophy
* **Unified `VoxelBody` Everything:** There are no separate classes for terrain, trees, pebbles, cars, airships, stations, planets, or stars. Every object in the universe is a single `VoxelBody` class differentiated only by scale (`VoxelScale`), voxel composition, and mass.
* **True Unified Rigid-Body Physics:** No artificial split between "grid-locked contraptions" and dynamic physics bodies. Static structures are simply pinned/sleeping `VoxelBody` instances; detaching or launching them transitions them seamlessly into dynamic rigid bodies.
* **Zero Upper Scale Limit:** Infinite universe scale with lossless precision from sub-millimeter bolts to intergalactic distances.

---

## 2. Tech Stack & Engine Architecture
* **Engine:** **Godot 4.x (C#)** paired with **Jolt Physics** (`PhysicsServer3D`).
* **Hybrid Data-Oriented Core + Thin Godot Shell:**
  * **Pure C# Simulation Layer:** All `VoxelBody` data, sparse octrees, kinetic power graphs, fluid/gas grids, and orbital mechanics live in pure C# structs/arrays—completely decoupled from Godot's `Node` tree.
  * **Thin Godot I/O Layer:** Godot acts strictly as a camera-centered rendering and physics viewport. Active visible bodies draw from a pooled set of `MeshInstance3D`, `MultiMeshInstance3D`, and Jolt `PhysicsServer3D` RIDs.

---

## 3. Infinite Universe Precision (The `(0, 0, 0)` Camera Bubble)
* **Hierarchical 128-Bit Coordinates:** Every `VoxelBody` stores its true universe position using 128-bit precision (`Int128` sector coordinates + `double` local offsets) inside a hierarchical spatial tree (`Universe -> Star System -> Local Sphere of Influence`).
* **Camera Permanently at `(0, 0, 0)`:**
  * Only bodies inside the active local physics bubble (~10 km radius around the camera) are instantiated in Jolt Physics and rendered at full resolution.
  * Each frame, local render positions are computed via exact 128-bit subtraction before casting down to 32-bit floats:
    ```csharp
    Vector3 localPos = (Vector3)(body.UniversePos - camera.UniversePos);
    ```
* **Scaled-Space Distant Rendering:** Celestial bodies outside the local physics bubble render as low-poly LOD proxy spheres at a fixed far distance, scaled proportionally by apparent angular size until the player flies within transition range.

---

## 4. `VoxelBody` Storage, Pooling & Destruction
* **Tiered Memory Storage:**
  * **Small Bodies (≤ 64 voxels, e.g., pebbles, debris, small props):** Stored in a pooled inline flat array (`SmallVoxelArray`) to avoid chunk/octree overhead.
  * **Large Bodies (Ships, 16k Quad-Planets, Stars):** Stored in a **Sparse Voxel Octree (SVO)** or chunk hashmap with run-length compression so deep underground rock or empty space uses minimal RAM.
* **6-Face Quad-Sphere Planets:** Planets use a 6-face cube-sphere layout with orthogonal face-aligned gravity (`max(|x|, |y|, |z|)`), keeping all voxel blocks, buildings, and machinery 100% orthogonal without curved-grid distortion.
* **Bounded Connectivity & Structural Splitting:**
  * Chopping a tree, crashing a car, or blasting a crater triggers a **radius-bounded 3D flood-fill / disjoint-set check** around the damaged voxels.
  * Disconnected voxel islands split off into independent `VoxelBody` instances inheriting the parent's linear and angular velocity at their offset (`v = v_cm + ω × r`).
  * **Sleep & Re-Merge Pooling:** Settled debris and fallen trees sleep after ~2 seconds of near-zero velocity, releasing their Jolt physics bodies back to the pool (or merging back into the parent terrain grid).

---

## 5. Rendering Pipeline (GPU-Driven)
* **Static Hulls & Terrain:** Greedy-meshed on background C# worker threads into single `ArrayMesh` surfaces per chunk/body, paired with greedy-merged compound box colliders via `PhysicsServer3D.BodyAddShape()`.
* **Spinning Machinery (Zero CPU Frame Cost):** Cogs, shafts, and propellers use chunk-scoped `MultiMeshInstance3D` buffers. Rotation axis, RPM, and phase are written *once* into `INSTANCE_CUSTOM`, and a custom vertex shader rotates vertices/normals on the GPU.
* **Culling & LOD:** Frustum culling (via per-chunk `MultiMesh` AABBs), Godot `OccluderInstance3D` occlusion culling, and distance-based shader/LOD cutoffs halt animation math for distant or hidden machinery.

---

## 6. Sub-Systems & Simulation Tick Rates
Simulation loops are decoupled by frequency to protect frame times:
* **60 Hz (Jolt Physics Step):**
  * Rigid-body collisions, sub-grid mechanical joints (`HingeJoint3D` / `SliderJoint3D` with parent-child collision exceptions), aerodynamic/buoyancy force vectors (`apply_force` at local block offsets), and player velocity inheritance on moving decks (`v_player += v_grid + ω_grid × r`).
* **20 TPS (Deterministic C# Simulation Loop):**
  * **Create Kinetic Networks:** Event-driven graph traversal (BFS/DFS) calculating RPM ratios, gear direction flips, cycle jams, and stress capacity vs. load.
  * **Belt & Pipe Logistics:** Contiguous C# struct arrays advancing item positions and 1D fluid/gas pipe flow (`ΔP` pressure gradients) with bulk `RenderingServer.MultimeshSetBuffer()` uploads.
* **5–10 TPS (Atmosphere & N-Body Gravity):**
  * **Pressurized Rooms & Hull Breaches:** 3D voxel flood-fill gas/liquid diffusion (`PV = nRT` + discrete divergence), applying impulse forces (`F = P × Area`) when pressurized interiors vent to vacuum or flood underwater.
  * **Dynamic N-Body Orbits:** Symplectic Velocity Verlet integration across massive celestial `VoxelBody` instances—mining away planet mass or strapping thrusters to moons dynamically alters orbital trajectories in real time.

---

## 7. Key Math Foundations
* **Linear Algebra (Daily Core):** Basis transforms (world ↔ local grid space), cross products (`v = ω × r`, torque `τ = r × F`), dot products (angle of attack, face alignment), and quaternions.
* **Discrete Math (Simulation Core):** Graph theory (BFS/DFS connected components, cycle detection for gear jams), spatial hashing, and bitwise voxel state packing.
* **Calculus / Physics Concepts:** Discrete sums for center of mass and inertia tensors (`Σ m_i * r_i²`), pressure gradients/divergence (`∇ · F`) for voxel atmospheres, and symplectic integration for N-body orbits.
