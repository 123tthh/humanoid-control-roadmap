#!/usr/bin/env bash
# Local documentation references:
# - /home/gtk/UNITREE/C8/docs/course-materials/实践8：基于 AMP 的拟人走跑策略复现.pdf
# - /home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/isaac_lab_tutorials/index.md

set -eo pipefail
C8_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${C8_ROOT}/../common/env/isaaclab.sh"

# The chapter shadows neither the shared Isaac Lab nor Unitree RL Lab trees.
export UNITREE_C8_ROOT="${C8_ROOT}"
export UNITREE_RL_LAB_PATH="${UNITREE_C8_ROOT}"
export UNITREE_AMP_MOTION_ROOT="${UNITREE_AMP_MOTION_ROOT:-${UNITREE_C8_ROOT}/resources/motions}"
export PYTHONPATH="${UNITREE_C8_ROOT}:${UNITREE_C8_ROOT}/source:${UNITREE_C8_ROOT}/rsl_rl-main${PYTHONPATH:+:${PYTHONPATH}}"
unset C8_ROOT
