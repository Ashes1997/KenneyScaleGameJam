# Kenney Scale Game Jam — Project Context

2D platformer built in **Godot 4.7** (GDScript), built for a **2-day game jam**. Two people, two PCs, working in parallel:

- **You** — the **Hand** (`entities/hand/`)
- **Brother** — the **Blob** (`entities/blob/`)

Neither of you has done game dev before but both can code — the Godot-specific sections below exist to translate game-dev concepts into terms a regular programmer already knows.

## Gameplay loop

The player is a ball ("Blob") with two hands that can reach out around it.

- **WASD** — move the blob (A/D roll or move horizontally; W/S currently unused, see "possible future change" below)
- **Spacebar** — jump
- **LMB** — extend a hand to grab whatever is under the cursor, as long as it's within the hand's reach radius of the blob (ledges, walls, other objects)
- **RMB** — slingshot: pull the blob's body toward the grabbed hand's anchor point

**Possible future change:** repurpose W/S to grow/shrink the ball instead of (or in addition to) movement. Not committed yet — don't build anything that assumes a fixed ball size if it's easy to avoid.

### Open design questions (not yet decided — flag if you hit one)
- Exact reach radius for the hand (in pixels/units)
- Slingshot physics: instant velocity set, one-shot impulse, or a spring/rope joint that pulls over time?
- Does grabbing freeze the hand's anchor in world space, or does it track the surface (e.g. a moving platform)?
- If/when ball resizing lands: does it change collision radius, mass, move speed, or just visuals?

## Team split & integration seam

- `entities/blob/` — brother's scene + script. Blob movement, jump, physics body.
- `entities/hand/` — your scene + script. Hand reach, grab detection, slingshot trigger.
- `player/player.tscn` + `player.gd` — **the integration point.** This scene instances both Blob and Hand as children and is where their scripts talk to each other (signals). Treat this file like a merge-conflict hotspot: agree on the signal contract below before both touching it, and pull before you edit it.

**Suggested signal contract** (adjust as needed, just keep each other in sync):
- `Hand` emits something like `grabbed(anchor_position: Vector2)` when LMB successfully grabs a surface, and `released()` on let-go.
- `Hand` emits `slingshot_requested(anchor_position: Vector2)` on RMB while grabbed.
- `Blob` (or `Player`) listens for `slingshot_requested` and applies the pull toward `anchor_position`.
- Each of you can build and test your own scene in isolation (see `levels/test_level/` below) without waiting on the other — just keep the signal names/payloads stable once agreed.

## Godot concepts, explained for programmers

- **Scene (`.tscn`)** — a saved tree of nodes, roughly like a reusable component/prefab class. `player.tscn` "instancing" `blob.tscn` and `hand.tscn` is like composition: it embeds a copy of that scene as a child, and changes to the original `blob.tscn` propagate to every place it's instanced (like editing a shared class vs. a copy-pasted one).
- **Node** — the base building block; everything in a scene tree is a node. Every node has a `position`, a `parent`, and optionally a script attached.
- **`Node2D`** — a generic 2D node with a transform (position/rotation/scale) but no physics or collision. Good for things that are just "a thing in space" — e.g. the Hand itself might be `Node2D` with child nodes doing the actual grab detection.
- **`CharacterBody2D`** — a physics body meant for player/enemy-style movement you drive by code (not the physics engine). You set `velocity` and call `move_and_slide()` each physics frame; Godot handles collision response for you. This is almost certainly what the Blob is.
- **`Area2D`** — a zone that detects overlaps but doesn't physically collide/push anything. Useful for "is the hand currently touching a grabbable surface?" checks — connect its `body_entered` / `body_exited` signals.
- **`RayCast2D`** — casts a line and reports what it hits. Useful for "can the hand actually reach this point" or aiming checks, especially combined with the reach-radius constraint.
- **`CollisionShape2D`** — a child node that defines the actual collision geometry (circle, rectangle, etc.) for a physics/area body. A body with no `CollisionShape2D` child collides with nothing.
- **Script (`.gd`)** — attached to exactly one node, extends that node's class (e.g. `extends CharacterBody2D`), and defines its behavior. Roughly equivalent to a class instance where `self` is the node.
- **Signals** — Godot's built-in observer/pub-sub pattern. A node declares `signal grabbed(position: Vector2)`, calls `grabbed.emit(pos)` when the event happens, and any other node can `connect()` to it (in code or in the editor) without the emitter knowing who's listening. This is how Hand and Blob should talk to each other instead of reaching into each other's internals directly.
- **`_process(delta)` vs `_physics_process(delta)`** — `_process` runs once per rendered frame (variable timing, good for visuals/UI/camera). `_physics_process` runs at a fixed timestep (default 60Hz) and is where you should put movement, velocity changes, and anything physics-related — using `_process` for movement causes frame-rate-dependent bugs.
- **Input actions** — Project Settings → Input Map lets you name an action (e.g. `"move_left"`, `"grab"`) and bind it to one or more physical keys/buttons. In code you check `Input.is_action_pressed("move_left")` rather than hardcoding `KEY_A`, so rebinding later doesn't touch script code. Worth setting these up early for WASD/space/LMB/RMB rather than hardcoding key names.
- **`position` vs `global_position`** — `position` is relative to the parent node; `global_position` is world space. Since Hand will be a child of Player which is a child of the level, grab-target math almost certainly wants `global_position`.
- **Note on physics engines**: `project.godot` has `3d/physics_engine="Jolt Physics"` set, but that setting only affects **3D** physics. This is a 2D game, so it's irrelevant here — 2D physics (`CharacterBody2D`, `Area2D`, etc.) always uses Godot's built-in 2D physics engine regardless of that setting.

## Directory structure

```
res://
├── entities/
│   ├── blob/           brother's scene + script
│   │   └── blob.tscn
│   └── hand/            your scene + script
│       └── hand.tscn
├── player/               integration point — instances Blob + Hand, wires signals
│   └── player.tscn
├── levels/
│   └── test_level/       sandbox scene for testing movement/grab in isolation
│       └── testLevel.tscn
├── assets/
│   ├── sprites/
│   └── tiles/
└── project.godot
```

All scenes above are currently empty placeholder `Node2D`s — no scripts attached yet, no logic written. This is the skeleton to build into.

## 2-day jam plan (suggested)

- **Day 1** — build and test each piece in isolation inside `levels/test_level/`: blob movement/jump, hand reach + grab detection. Don't wire the slingshot yet.
- **Day 2** — integrate in `player.tscn` (signal wiring), get the slingshot feeling right, then move on to real level content, art pass, and playtesting. Leave buffer time at the end — game jams always run over on polish.

## Workflow notes

- Repo is shared via git remote between both PCs — pull before editing shared files (`player.tscn` especially), commit/push often in small chunks to avoid conflicts.
- Keep Blob-only changes inside `entities/blob/`, Hand-only changes inside `entities/hand/`, so the two of you rarely touch the same file.
