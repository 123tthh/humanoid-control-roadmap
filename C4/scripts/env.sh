#!/usr/bin/env bash
# Local documentation reference:
# - /home/gtk/UNITREE/C4/实践4：蹲姿行走策略，G1速度+骨盆高度MDP设计.pdf
# C4 is a course-provided mjlab/uv project; it must not reuse or alter C1's Conda runtime.

set -eo pipefail
C4_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export UNITREE_C4_ROOT="${C4_ROOT}"
export UNITREE_C4_PROJECT_DIR="${UNITREE_C4_PROJECT_DIR:-${C4_ROOT}/HW4_蹲姿行走作业/mjlab}"
unset C4_ROOT
