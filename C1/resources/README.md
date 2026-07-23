# C1 Shared Resources

C1 intentionally does not vendor Isaac Sim, Isaac Lab, Unitree RL Lab, or robot
assets. They are shared, version-locked dependencies managed outside every
chapter directory:

| Resource | Shared path | C1 interface |
| --- | --- | --- |
| Isaac Sim 5.1.0 | `/home/gtk/isaac-sim-5.1` | `scripts/env.sh` exports `ISAACSIM_PATH` |
| Isaac Lab 2.3.0 | `/home/gtk/UNITREE_DEPS/IsaacLab` | `scripts/env.sh` exports `ISAACLAB_PATH` |
| Unitree RL Lab | `/home/gtk/UNITREE_DEPS/unitree_rl_lab` | `scripts/c1.sh` calls its train/play entry points |
| Unitree G1 assets | `/home/gtk/UNITREE_DEPS/unitree_model` | `scripts/env.sh` exports `UNITREE_MODEL_DIR` |
| Python runtime | `/home/gtk/miniconda3/envs/env_isaaclab` | activated by `scripts/env.sh` |

Do not run package installation commands from this chapter. This keeps C1--C8
isolated from the shared runtime and preserves compatibility with the other
course projects. Training logs remain under `../logs/` because RSL-RL expects
that layout; they are ignored except for the two deliberately versioned C1
checkpoints.
