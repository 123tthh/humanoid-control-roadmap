# C2 assignment report: terrain-aware G1 rough-terrain locomotion

Reference: `docs/course-materials/实践2：设计感知与动作空间，实现宇树G1粗糙地形行走策略7.12版.pdf`.

## Delivered implementation

The isolated task ID is `Unitree-G1-29dof-Velocity-Rough`.  It subclasses the
shared 29-DoF velocity environment without modifying
`/home/gtk/UNITREE_DEPS/unitree_rl_lab`.

| PDF requirement | Implementation |
| --- | --- |
| Generator terrain using `ROUGH_TERRAINS_CFG` | `C2G1RoughEnvCfg` replaces the inherited terrain generator and enables its curriculum. |
| 187-point terrain scan | The inherited `RayCasterCfg` is attached to `torso_link`, scans `/World/ground`, has 0.1 m resolution and a 1.6 m x 1.0 m grid (17 x 11). |
| Terrain scan in actor and critic observations | `height_scanner = mdp.height_scan`, clipped to `[-1.0, 5.0]`, is added to both groups. |
| Keep 29-DoF position action | The inherited `JointPositionActionCfg` retains all joints, `scale=0.25`, and the default pose offset. |
| Rough-terrain rewards | Base height is measured relative to the scanner; world-frame foot-clearance reward is removed; biped air-time reward is added. |
| Robust termination | Absolute base-height termination is disabled and delayed torso-contact termination is added. |

The policy frame has `3 + 3 + 3 + 29 + 29 + 29 + 187 = 283` elements.
With the inherited five-frame policy history, the actor input is 1415 elements.

## Existing policy artifact

The local, intentionally Git-ignored run used for Sim2Sim is
`sim2sim/policy/2026-06-12_10-36-30/`.  It contains `model_14999.pt`, exported
`policy.pt`, and the matching `params/deploy.yaml`.  Checkpoints are excluded
from version control by project policy; source, configuration, and commands are
reproducible from this repository.

## Commands

```bash
cd /home/gtk/UNITREE/C2

# Static task registration followed by one Isaac Lab training iteration.
./scripts/c2.sh check
./scripts/c2.sh smoke

# Course-scale training (adjust --num_envs for available VRAM).
./scripts/c2.sh train --num_envs 4096 --max_iterations 15000

# Verify the local policy and MuJoCo raycaster without opening a window.
./scripts/c2_sim2sim.sh --no-viewer --steps 20

# Open keyboard-controlled Sim2Sim after the headless check succeeds.
./scripts/c2_sim2sim.sh
```

The Sim2Sim runner uses the same height-scan offset (`0.5`), clipping range,
joint ordering, observation order, and per-term history specified in the
exported `deploy.yaml`.  The wrapper defaults to the shared plugin path
`/home/gtk/UNITREE_DEPS/mujoco-3.3.6-source/plugin/mujoco_ray_caster/lib/libsensor_raycaster.so`;
set `C2_RAYCASTER_PLUGIN_LIBRARY` to override it.

Keyboard controls are Up/Down (or keypad 8/2) for longitudinal velocity,
Left/Right (or keypad 4/6) for yaw, Space/keypad 5 to stop, and `R` to reset.
