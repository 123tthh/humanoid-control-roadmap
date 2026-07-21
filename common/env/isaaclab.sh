#!/usr/bin/env bash
# Shared Isaac Lab runtime for UNITREE C1/C2.
# Local documentation references:
# - /home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/robot_simulation/ext_isaacsim_robot_policy_example.md
# - /home/gtk/UNITREE/C2/实践2：设计感知与动作空间，实现宇树G1粗糙地形行走策略7.12版.pdf

# This file must be sourced.  It does not alter a running Isaac Sim process.
set -eo pipefail

UNITREE_COMMON_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export CONDA_NO_PLUGINS=true
source /home/gtk/miniconda3/etc/profile.d/conda.sh
conda activate env_isaaclab

export ISAACSIM_PATH=/home/gtk/isaac-sim-5.1
export ISAACSIM_PYTHON_EXE="${ISAACSIM_PATH}/python.sh"
export ISAACLAB_PATH=/home/gtk/UNITREE_DEPS/IsaacLab
export UNITREE_RL_LAB_PATH=/home/gtk/UNITREE_DEPS/unitree_rl_lab
export UNITREE_MODEL_DIR=/home/gtk/UNITREE_DEPS/unitree_model
export PYTHONNOUSERSITE=1

_unitree_strip_ros_paths() {
    local unitree_input="${1:-}"
    local unitree_output=""
    local unitree_entry
    local unitree_old_ifs="${IFS}"
    IFS=:
    for unitree_entry in ${unitree_input}; do
        if [[ -n "${unitree_entry}" && "${unitree_entry}" != /opt/ros/* ]]; then
            unitree_output="${unitree_output:+${unitree_output}:}${unitree_entry}"
        fi
    done
    IFS="${unitree_old_ifs}"
    printf '%s' "${unitree_output}"
}

export PYTHONPATH="$(_unitree_strip_ros_paths "${PYTHONPATH:-}")"
export LD_LIBRARY_PATH="$(_unitree_strip_ros_paths "${LD_LIBRARY_PATH:-}")"
unset AMENT_PREFIX_PATH COLCON_PREFIX_PATH ROS_DISTRO ROS_PYTHON_VERSION ROS_VERSION RMW_IMPLEMENTATION
unset UNITREE_COMMON_ROOT
