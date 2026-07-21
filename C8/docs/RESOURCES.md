# C8 Resources and Interfaces

Reference: `course-materials/实践8：基于 AMP 的拟人走跑策略复现.pdf`.

## Runtime boundary

C8 reads the shared Isaac Sim 5.1 / Isaac Lab 2.3 environment through
`scripts/env.sh`. It overlays its own `source/`, `rsl_rl_amp/`, and `rsl_rl-main/`
on `PYTHONPATH`; it does not install into or modify C1's external dependencies.
Do not run `unitree_rl_lab.sh --install` in C1's active Conda environment.

## Expert motion input

The default local data root is `C8/resources/motions/`, which is ignored by Git.
Override it with `UNITREE_AMP_MOTION_ROOT` when data is stored outside the
repository. The WalkToRun profile expects these files under `mixed/`:

```text
B3_-_walk1_stageii.npz
B5_-_walk_backwards_stageii.npz
B9_-_walk_turn_left_(90)_stageii.npz
B12_-_walk_turn_right_(90)_stageii.npz
C3_-_Run_stageii.npz
C5_-_walk_to_run_stageii.npz
C2_-_Run_to_stand_stageii.npz
C6_-_stand_to_run_backwards_stageii.npz
C11_-__run_turn_left_(90)_stageii.npz
C14_-__run_turn_right__(90)_stageii.npz
```

These are C7 GMR outputs, not source-code assets. The supplied `B1` sample is
intentionally ignored and is insufficient for WalkToRun training. Validate a
complete collection with:

```bash
cd /home/gtk/UNITREE/C8
./scripts/c8.sh data
```

## AMP contract

Both simulator and expert data use this exact 80-D frame order:

```text
base_lin_vel(3), base_ang_vel(3), projected_gravity(3), base_height(1),
joint_pos(29), joint_vel(29), key_links_pos_b(4 x 3)
```

The discriminator receives three chronological frames, therefore its input
width is 240. `preflight` validates this contract and checks the declared
`Unitree-G1-29dof-AMP-WalkToRun-FullPlay` registration without launching Isaac
Sim or consuming GPU resources.
