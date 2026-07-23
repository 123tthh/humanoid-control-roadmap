# Reproducible Environment

This document recreates the project runtime without committing proprietary
simulator binaries, GPU drivers, course handouts, checkpoints, or licensed
SMPL-X assets. It is deliberately separate from the chapter code so a new
machine can rebuild the external dependencies under its own `UNITREE_DEPS/`.

The exact shared-directory tree, download links, local build products, and
metadata-backup policy are recorded in [DEPENDENCY_TREE.md](DEPENDENCY_TREE.md).

## Locked baseline

| Component | Required version or revision | Source |
| --- | --- | --- |
| Host OS | Ubuntu 22.04, x86_64 | Host installation |
| NVIDIA driver | Host-managed; do not install it in Conda or Docker | GPU vendor / system administrator |
| Isaac Sim | `5.1.0` | NVIDIA download or `nvcr.io/nvidia/isaac-sim:5.1.0` |
| Isaac Lab | tag `v2.3.0`, commit `3c6e67bb5c7ada942a6d1884ab69338f57596f77` | `isaac-sim/IsaacLab` |
| Unitree RL Lab | commit `4960b84732b0c2ec593dccbfe963fda1bcd7b1e3` | `unitreerobotics/unitree_rl_lab` |
| Unitree model dataset | commit `323e350252b9c3aee9c40acbfdad84f6ce46a5ac` | Hugging Face `unitreerobotics/unitree_model` |
| C7 SMPL-X assets | `SMPLX_NEUTRAL.pkl`, `SMPLX_FEMALE.pkl`, `SMPLX_MALE.pkl` | Official SMPL-X site after accepting its license |

The working copy of Unitree RL Lab on the original machine had local changes.
The listed commit is the reproducible upstream base; preserve any site-specific
patch as a separate patch file instead of modifying the pinned dependency in
place.

## Option A — workstation binary (recommended for Isaac Sim GUI)

This matches the original workstation layout and supports the Isaac Sim GUI.
Download the Linux x86_64 Isaac Sim **5.1.0** archive from NVIDIA, then unzip it
outside this repository. The local Isaac Sim 5.1 documentation specifies
`post_install.sh` and `isaac-sim.selector.sh` after unpacking.

```bash
# Example external dependency layout. Do not put these directories in Git.
export UNITREE_DEPS=/opt/unitree-deps
export ISAACSIM_PATH=/opt/isaac-sim-5.1
export ISAACSIM_PYTHON_EXE="${ISAACSIM_PATH}/python.sh"

mkdir -p "${UNITREE_DEPS}"
git clone --branch v2.3.0 --depth 1 https://github.com/isaac-sim/IsaacLab.git \
  "${UNITREE_DEPS}/IsaacLab"
git clone https://github.com/unitreerobotics/unitree_rl_lab.git \
  "${UNITREE_DEPS}/unitree_rl_lab"
git -C "${UNITREE_DEPS}/unitree_rl_lab" checkout 4960b84732b0c2ec593dccbfe963fda1bcd7b1e3
git lfs install
git clone https://huggingface.co/datasets/unitreerobotics/unitree_model \
  "${UNITREE_DEPS}/unitree_model"
git -C "${UNITREE_DEPS}/unitree_model" checkout 323e350252b9c3aee9c40acbfdad84f6ce46a5ac

cd "${UNITREE_DEPS}/IsaacLab"
ln -s "${ISAACSIM_PATH}" _isaac_sim
./isaaclab.sh --conda unitree_isaaclab_23
conda activate unitree_isaaclab_23
./isaaclab.sh --install rsl_rl
```

Use the resulting environment by exporting paths rather than installing course
code into Isaac Lab:

```bash
export ISAACSIM_PATH=/opt/isaac-sim-5.1
export ISAACLAB_PATH=/opt/unitree-deps/IsaacLab
export UNITREE_RL_LAB_PATH=/opt/unitree-deps/unitree_rl_lab
export UNITREE_MODEL_PATH=/opt/unitree-deps/unitree_model
```

Verify the simulator before running any training:

```bash
"${ISAACSIM_PATH}/isaac-sim.compatibility_check.sh" --/app/quitAfter=10 --no-window
```

The first simulator launch populates shader caches and is expected to be slower.
Keep its cache outside the repository so subsequent runs are faster.

## Option B — remote headless training container

[`bootstrap/Dockerfile.headless-training`](../bootstrap/Dockerfile.headless-training)
is for remote servers that run training without a display. It inherits NVIDIA's
official Isaac Sim `5.1.0` image, clones only the pinned public source
repositories, and deliberately excludes the large Unitree model dataset and
licensed SMPL-X files. It does not configure X11, VNC, or WebRTC.

Its paired [`.dockerignore`](../.dockerignore) excludes local logs,
checkpoints, course files, and model assets from the build context.

Authenticate to NGC before building, then build and run with the NVIDIA
Container Toolkit already installed on the host:

```bash
docker login nvcr.io
docker build -f bootstrap/Dockerfile.headless-training \
  -t unitree-isaacsim-headless:5.1.0 .

mkdir -p "$HOME/docker/isaac-sim/cache/main" "$HOME/docker/isaac-sim/cache/computecache"
docker run --rm -it --gpus all --network=host \
  -e ACCEPT_EULA=Y -e PRIVACY_CONSENT=Y \
  -v "$PWD:/workspace" \
  -v "$HOME/docker/isaac-sim/cache/main:/isaac-sim/.cache:rw" \
  -v "$HOME/docker/isaac-sim/cache/computecache:/isaac-sim/.nv/ComputeCache:rw" \
  -v /opt/unitree-deps/unitree_model:/opt/unitree_model:ro \
  unitree-isaacsim-headless:5.1.0
```

Inside the container, install only the required Isaac Lab learning framework:

```bash
cd /opt/IsaacLab
./isaaclab.sh --install rsl_rl
```

This image is intentionally terminal-only. `ACCEPT_EULA=Y` accepts the NVIDIA
Omniverse license for that run. Do not bake host GPU drivers, private NGC
credentials, model weights, or SMPL-X files into an image.

## Option C — local GUI or remote WebRTC container

[`bootstrap/Dockerfile.gui-streaming`](../bootstrap/Dockerfile.gui-streaming)
is a thin second image built on Option B. It supports two display modes:

1. **Local GUI:** X11 forwarding plus `/isaac-sim/runapp.sh`. NVIDIA documents
   this as less reliable than the native workstation binary, so use Option A
   when a full local GUI is required.
2. **Remote WebRTC:** Isaac Sim's built-in streaming service via
   `/isaac-sim/runheadless.sh`; no separate VNC or remote-desktop server is
   installed.

Build it after Option B:

```bash
docker build -f bootstrap/Dockerfile.gui-streaming \
  --build-arg BASE_IMAGE=unitree-isaacsim-headless:5.1.0 \
  -t unitree-isaacsim-gui:5.1.0 .
```

For a local Linux desktop, run the image with X11 access, then start the GUI:

```bash
xhost +local:
docker run --rm -it --gpus all --network=host \
  -e ACCEPT_EULA=Y -e PRIVACY_CONSENT=Y \
  -e DISPLAY -v "$HOME/.Xauthority:/isaac-sim/.Xauthority:ro" \
  -v "$HOME/docker/isaac-sim/cache/main:/isaac-sim/.cache:rw" \
  -v "$HOME/docker/isaac-sim/cache/computecache:/isaac-sim/.nv/ComputeCache:rw" \
  unitree-isaacsim-gui:5.1.0 /isaac-sim/runapp.sh
```

For a remote server, use WebRTC instead. Open TCP `49100` and UDP `47998` only
to the intended client IP, then replace `PUBLIC_IP` with the server's reachable
public address:

```bash
docker run --rm -it --gpus all --network=host \
  -e ACCEPT_EULA=Y -e PRIVACY_CONSENT=Y \
  -v "$HOME/docker/isaac-sim/cache/main:/isaac-sim/.cache:rw" \
  -v "$HOME/docker/isaac-sim/cache/computecache:/isaac-sim/.nv/ComputeCache:rw" \
  unitree-isaacsim-gui:5.1.0 \
  /isaac-sim/runheadless.sh \
  --/app/livestream/publicEndpointAddress=PUBLIC_IP \
  --/app/livestream/port=49100
```

Wait for `Isaac Sim Full Streaming App is loaded`, then connect with NVIDIA's
Isaac Sim WebRTC Streaming Client using that address. WebRTC requires an
x86_64 GPU with NVENC; it is not supported on A100 or aarch64 in Isaac Sim
5.1.0. Only one streaming client may connect to an Isaac Sim instance at once.

## C7 licensed model placement

After acquiring the official SMPL-X v1.1 package, extract only the three PKL
models to the following ignored local directory:

```text
C7/gmr/assets/body_models/smplx/
  SMPLX_NEUTRAL.pkl
  SMPLX_FEMALE.pkl
  SMPLX_MALE.pkl
```

Then verify them without running simulation:

```bash
cd C7
./scripts/c7.sh models
```

## Sources consulted

- `/home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_workstation.md`
- `/home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_container.md`
- `/home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/manual_livestream_clients.md`
- `/home/gtk/UNITREE_DEPS/IsaacLab/docs/source/setup/installation/binaries_installation.rst`
- `/home/gtk/UNITREE_DEPS/IsaacLab/docs/source/setup/installation/include/src_python_virtual_env.rst`
- `/home/gtk/UNITREE_DEPS/IsaacLab/docs/source/setup/installation/include/src_build_isaaclab.rst`
