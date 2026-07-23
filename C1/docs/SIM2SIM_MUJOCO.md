# C1 Sim2Sim (MuJoCo) Validation

References:

- `course-materials/实践1：宇树G1仿真环境（Isaac Sim_Lab_MuJoCo）搭建与基础功能验证.pdf`, section 4.4
- <https://github.com/unitreerobotics/unitree_rl_lab>
- <https://github.com/unitreerobotics/unitree_mujoco>
- <https://github.com/unitreerobotics/unitree_sdk2>

## Isolated dependencies

The C1 Sim2Sim additions do not modify Isaac Sim, Isaac Lab, or the existing
Unitree RL Lab checkout. Their separate dependency roots are:

| Component | Location | Revision / version |
| --- | --- | --- |
| Unitree SDK2 | `/home/gtk/UNITREE_DEPS/unitree_sdk2` | `21d0a3b2c46ee48c8fdf2783becb6be3beb0a59b` |
| MuJoCo simulator | `/home/gtk/UNITREE_DEPS/unitree_mujoco` | `ae6a8403e272733e9996ef59990880330496177f` |
| MuJoCo runtime | `/home/gtk/.mujoco/mujoco-3.3.6` | 3.3.6 |
| G1 controller build | `.../unitree_rl_lab/deploy/robots/g1_29dof/build-c1-sim2sim` | built without changing source |

SDK2 is installed under its own `install/` prefix rather than `/usr/local`.
The controller is copied to the ignored `C1/sim2sim/bin/` directory so its C1
configuration can select the final policy without changing shared RL-Lab files.

## Final-policy deployment contract

`model_49999.pt` is the only retained training checkpoint. Run `export` once to
produce `exported/policy.onnx` and `exported/policy.pt` adjacent to it. The
script installs the upstream G1 velocity `deploy.yaml`; it matches the current
task's 29 joint-position actions, action scale `0.25`, and five-frame 480-D
policy observation layout.

```bash
cd /home/gtk/UNITREE/C1
./scripts/sim2sim.sh preflight
./scripts/sim2sim.sh export
./scripts/sim2sim.sh prepare
```

## Run the two-process validation

Use two terminals. The simulator uses the loopback DDS interface and domain 0,
so it is isolated from a physical robot network.

```bash
# Terminal A
cd /home/gtk/UNITREE/C1
./scripts/sim2sim.sh simulator
```

```bash
# Terminal B
cd /home/gtk/UNITREE/C1
./scripts/sim2sim.sh controller
```

The simulator configuration intentionally follows the handout: G1,
`scene_29dof.xml`, domain 0, elastic band enabled, and Xbox-compatible
`/dev/input/js0`. With the MuJoCo window focused, press `L2 + Up` for stand,
press `8` to lower the robot, then `R1 + X` to enter the velocity-policy state.
Press `9` to toggle the elastic band. If no suitable gamepad is attached, the
controller still validates policy loading and DDS connectivity, but the manual
FSM transitions cannot be triggered.

## Validation boundary

`preflight` and all three C++ binaries have been built successfully. The local
validation has also started the MuJoCo G1-29dof scene and connected `g1_ctrl`
over DDS: Passive, FixStand, and Velocity FSM states initialized, and Velocity
resolved the final exported policy directory. A walking trial still requires the
manual controller/window sequence above and a working controller mapping at
`/dev/input/js0`; it is intentionally not inferred from a build-only check.
