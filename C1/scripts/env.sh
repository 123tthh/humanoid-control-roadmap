#!/usr/bin/env bash
# Local documentation references:
# - /home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/requirements.md
# - /home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_ros.md

# This file is intended to be sourced, but it is also safe to source from c1.sh.
_C1_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export CONDA_NO_PLUGINS=true
source /home/gtk/miniconda3/etc/profile.d/conda.sh
conda activate env_isaaclab

export ISAACSIM_PATH=/home/gtk/isaac-sim-5.1
export ISAACSIM_PYTHON_EXE="${ISAACSIM_PATH}/python.sh"
export ISAACLAB_PATH=/home/gtk/UNITREE_DEPS/IsaacLab
export UNITREE_RL_LAB_PATH=/home/gtk/UNITREE_DEPS/unitree_rl_lab
export UNITREE_MODEL_DIR=/home/gtk/UNITREE_DEPS/unitree_model
export PYTHONNOUSERSITE=1

# Isaac Sim 5.1 embeds Python 3.11 ROS libraries. A system ROS installation built
# for another Python version must not leak into this training process.
_c1_strip_ros_paths() {
    local input="${1:-}"
    local output=""
    local entry
    local old_ifs="${IFS}"
    IFS=:
    for entry in ${input}; do
        if [[ -n "${entry}" && "${entry}" != /opt/ros/* ]]; then
            output="${output:+${output}:}${entry}"
        fi
    done
    IFS="${old_ifs}"
    printf '%s' "${output}"
}

export PYTHONPATH="$(_c1_strip_ros_paths "${PYTHONPATH:-}")"
export LD_LIBRARY_PATH="$(_c1_strip_ros_paths "${LD_LIBRARY_PATH:-}")"
unset AMENT_PREFIX_PATH COLCON_PREFIX_PATH ROS_DISTRO ROS_PYTHON_VERSION ROS_VERSION RMW_IMPLEMENTATION
unset _C1_ROOT

