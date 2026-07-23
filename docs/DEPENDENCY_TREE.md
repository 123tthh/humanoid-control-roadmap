# Shared Dependency Tree

This document records the external dependencies used by C1--C8. They live
outside the Git working tree deliberately: simulator binaries, robot assets,
third-party source trees, compiled objects, and Git object databases should not
be copied into the course repository. Recreate them from the pinned public
sources instead.

## Directory roles

```text
/home/gtk/
├── UNITREE/                         # This Git repository: C1--C8, scripts, docs
├── UNITREE_DEPS/                    # Shared runtime/source dependencies (about 1.2 GiB)
│   ├── IsaacLab/                     # Isaac Lab source, linked to Isaac Sim 5.1
│   ├── unitree_model/                # Unitree USD robot asset dataset
│   ├── unitree_rl_lab/               # Unitree Isaac-Lab tasks and deployment source
│   ├── unitree_sdk2/                 # SDK2 source plus ignored build/install output
│   ├── unitree_mujoco/               # MuJoCo bridge source plus ignored build output
│   ├── mujoco-3.3.6-source/          # MuJoCo source/build used for the C2 plugin
│   └── mujoco_ray_caster/            # C2 terrain-raycaster plugin source
├── isaac-sim-5.1/                    # NVIDIA Isaac Sim workstation binary (separate)
└── UNITREE_git_metadata/             # Detached nested-Git metadata backups (about 279 MiB)
    ├── C8_unitree_lab_amp.git-20260721/
    └── GMR.git-20260721/
```

`UNITREE_DEPS` is used at runtime. `UNITREE_git_metadata` is **not** used at
runtime: it is only a preserved `.git` database from upstream packages that
were flattened into C7 and C8 so this repository does not contain nested Git
repositories.

## Pinned shared dependencies

| Directory | Purpose | Pinned revision | Official download/source |
| --- | --- | --- | --- |
| `IsaacLab/` | Isaac Sim RL framework | `v2.3.0` / `3c6e67bb5c7ada942a6d1884ab69338f57596f77` | [IsaacLab](https://github.com/isaac-sim/IsaacLab) |
| `unitree_rl_lab/` | G1 task, training, inference, deployment controller | `4960b84732b0c2ec593dccbfe963fda1bcd7b1e3` | [Unitree RL Lab](https://github.com/unitreerobotics/unitree_rl_lab) |
| `unitree_model/` | Unitree USD assets (G1, H1, Go2, etc.) | `323e350252b9c3aee9c40acbfdad84f6ce46a5ac` | [Unitree model dataset](https://huggingface.co/datasets/unitreerobotics/unitree_model) |
| `unitree_sdk2/` | DDS transport and controller SDK used by C1 Sim2Sim | `21d0a3b2c46ee48c8fdf2783becb6be3beb0a59b` | [Unitree SDK2](https://github.com/unitreerobotics/unitree_sdk2) |
| `unitree_mujoco/` | MuJoCo G1 simulation and SDK2 bridge used by C1 Sim2Sim | `ae6a8403e272733e9996ef59990880330496177f` | [Unitree MuJoCo](https://github.com/unitreerobotics/unitree_mujoco) |
| `/home/gtk/.mujoco/mujoco-3.3.6/` | MuJoCo runtime required by `unitree_mujoco` | `3.3.6` | [MuJoCo 3.3.6 release](https://github.com/google-deepmind/mujoco/releases/tag/3.3.6) |
| `mujoco-3.3.6-source/` | Source build used to compile the C2 raycaster ABI | `3.3.6` / `eacad44a1a67afe520b263c9b15dab82f62a10aa` | [MuJoCo source](https://github.com/google-deepmind/mujoco/tree/3.3.6) |
| `mujoco_ray_caster/` | C2 MuJoCo height-scanner plugin | `c190b951b559b9f46157d559e5347c06aad20256` | [mujoco_ray_caster](https://github.com/Albusgive/mujoco_ray_caster) |
| `/home/gtk/isaac-sim-5.1/` | NVIDIA simulator binary, not a source dependency | `5.1.0` | [NVIDIA Isaac Sim](https://developer.nvidia.com/isaac-sim) |

The first three rows are the C1--C8 common Isaac Lab baseline. The SDK2,
Unitree MuJoCo, and MuJoCo runtime rows are needed specifically by C1 section
4.4 Sim2Sim.

## Bootstrap on another workstation

Install Ubuntu 22.04 prerequisites, Isaac Sim 5.1.0, Miniconda, and an NVIDIA
driver separately. Do not install them inside this repository. Then clone the
pinned sources into any chosen shared directory:

```bash
export UNITREE_DEPS=/opt/unitree-deps
export ISAACSIM_PATH=/opt/isaac-sim-5.1
mkdir -p "${UNITREE_DEPS}"

git clone https://github.com/isaac-sim/IsaacLab.git "${UNITREE_DEPS}/IsaacLab"
git -C "${UNITREE_DEPS}/IsaacLab" checkout v2.3.0
git -C "${UNITREE_DEPS}/IsaacLab" rev-parse HEAD
ln -s "${ISAACSIM_PATH}" "${UNITREE_DEPS}/IsaacLab/_isaac_sim"

git clone https://github.com/unitreerobotics/unitree_rl_lab.git "${UNITREE_DEPS}/unitree_rl_lab"
git -C "${UNITREE_DEPS}/unitree_rl_lab" checkout 4960b84732b0c2ec593dccbfe963fda1bcd7b1e3

git lfs install
git clone https://huggingface.co/datasets/unitreerobotics/unitree_model "${UNITREE_DEPS}/unitree_model"
git -C "${UNITREE_DEPS}/unitree_model" checkout 323e350252b9c3aee9c40acbfdad84f6ce46a5ac

git clone https://github.com/unitreerobotics/unitree_sdk2.git "${UNITREE_DEPS}/unitree_sdk2"
git -C "${UNITREE_DEPS}/unitree_sdk2" checkout 21d0a3b2c46ee48c8fdf2783becb6be3beb0a59b

git clone https://github.com/unitreerobotics/unitree_mujoco.git "${UNITREE_DEPS}/unitree_mujoco"
git -C "${UNITREE_DEPS}/unitree_mujoco" checkout ae6a8403e272733e9996ef59990880330496177f

# C2 rough-terrain Sim2Sim: keep the Python package and plugin on MuJoCo 3.3.6.
conda activate env_isaaclab
python -m pip install mujoco==3.3.6
git clone --branch 3.3.6 --depth 1 https://github.com/google-deepmind/mujoco.git \
  "${UNITREE_DEPS}/mujoco-3.3.6-source"
git clone --depth 1 https://github.com/Albusgive/mujoco_ray_caster.git \
  "${UNITREE_DEPS}/mujoco_ray_caster"
```

For Isaac Lab Conda setup and the remote/headless Docker option, use
[REPRODUCIBLE_ENVIRONMENT.md](REPRODUCIBLE_ENVIRONMENT.md). For the SDK2,
MuJoCo, controller build, policy export, and G1 Sim2Sim two-terminal flow, use
[C1 Sim2Sim documentation](../C1/docs/SIM2SIM_MUJOCO.md).

## Expected local build products

These are machine-specific generated files and are intentionally not committed:

```text
UNITREE_DEPS/unitree_sdk2/build/
UNITREE_DEPS/unitree_sdk2/install/
UNITREE_DEPS/unitree_mujoco/simulate/build/
UNITREE_DEPS/unitree_rl_lab/deploy/robots/g1_29dof/build-c1-sim2sim/
UNITREE/C1/sim2sim/bin/g1_ctrl
UNITREE_DEPS/mujoco-3.3.6-source/build/
UNITREE_DEPS/mujoco-3.3.6-source/plugin/mujoco_ray_caster/lib/libsensor_raycaster.so
```

The C1 `scripts/sim2sim.sh build` command recreates the last four outputs from
the pinned sources. The final policy export is generated from the tracked C1
`model_49999.pt` with `scripts/sim2sim.sh export`.

For C2, link the plugin into `mujoco-3.3.6-source/plugin/mujoco_ray_caster`,
add `add_subdirectory(plugin/mujoco_ray_caster)` after the built-in plugin
entries in MuJoCo's top-level `CMakeLists.txt`, then configure and build the
`sensor_raycaster` target. The exact C2 command and expected output are in
[`C2/docs/ASSIGNMENT_REPORT.md`](../C2/docs/ASSIGNMENT_REPORT.md).

## Local state that must not be mistaken for upstream

At the time this tree was recorded, these worktrees intentionally differ from
their pinned commits:

| Dependency | Local status | Handling rule |
| --- | --- | --- |
| `unitree_rl_lab/` | `source/.../assets/robots/unitree.py` is modified | Existing user/site configuration. Do not reset it; capture any desired change as a separate patch before moving machines. |
| `unitree_mujoco/` | `simulate/config.yaml` is modified | C1 Sim2Sim writes the G1/domain-0/elastic-band/joystick configuration to this dedicated clone. Reapply with `C1/scripts/sim2sim.sh simulator`. |
| `unitree_sdk2/` | `install/` is untracked | User-prefix SDK2 installation generated by CMake; recreate with `C1/scripts/sim2sim.sh build`. |

Use this audit command before changing or sharing a machine:

```bash
for repo in "${UNITREE_DEPS}"/*; do
  test -d "${repo}/.git" || continue
  printf '\n[%s]\n' "$(basename "${repo}")"
  git -C "${repo}" rev-parse HEAD
  git -C "${repo}" status --short
done
```

## `UNITREE_git_metadata` provenance backups

These directories are extracted `.git` administrative databases, not checked-out
source code. They were retained after flattening course source into chapter
directories, so their upstream origin and commit can still be audited offline:

| Metadata directory | Chapter/source role | Commit | Reconstructible source |
| --- | --- | --- | --- |
| `C8_unitree_lab_amp.git-20260721/` | Original metadata for C8 AMP source | `7171a81c8e82cbd9a44789d11e4da96326f7e73a` | [HeYee03/unitree_lab_amp](https://github.com/HeYee03/unitree_lab_amp) |
| `GMR.git-20260721/` | Original metadata for C7 GMR source | `bb1bbe40774794fceb2a7c579a3464a28e68c844` | [YanjieZe/GMR](https://github.com/YanjieZe/GMR) |

They are useful for offline provenance or inspecting original commits, but are
not needed to run C1--C8 and must not be committed to this repository. On a new
machine, clone the public source and check out the listed commit instead:

```bash
git clone https://github.com/HeYee03/unitree_lab_amp.git
git -C unitree_lab_amp checkout 7171a81c8e82cbd9a44789d11e4da96326f7e73a

git clone https://github.com/YanjieZe/GMR.git
git -C GMR checkout bb1bbe40774794fceb2a7c579a3464a28e68c844
```
