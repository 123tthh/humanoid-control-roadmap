#!/usr/bin/env bash
# Local documentation reference:
# - /home/gtk/UNITREE/C5/实践5：基于分层强化学习的人形机器人导航.pdf
# C5 reads the shared Isaac Sim 5.1 runtime and keeps course code in its own overlay.

set -eo pipefail
C5_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${C5_ROOT}/../common/env/isaaclab.sh"
export UNITREE_C5_ROOT="${C5_ROOT}"
export UNITREE_C5_PROJECT_DIR="${UNITREE_C5_PROJECT_DIR:-${C5_ROOT}/unitree_rl_lab_student/unitree_rl_lab}"
export UNITREE_RL_LAB_PATH="${UNITREE_C5_PROJECT_DIR}"
export PYTHONPATH="${UNITREE_C5_PROJECT_DIR}/source/unitree_rl_lab:${PYTHONPATH}"
unset C5_ROOT
