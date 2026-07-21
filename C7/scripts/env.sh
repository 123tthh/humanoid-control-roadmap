#!/usr/bin/env bash
# Local documentation reference:
# - /home/gtk/UNITREE/C7/docs/course-materials/实践7：使用 GMR 完成人体动作到 G1 的运动重定向.pdf
# GMR uses a dedicated Python 3.10 Conda environment and never modifies C1's Isaac Lab runtime.

set -eo pipefail
C7_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export UNITREE_C7_ROOT="${C7_ROOT}"
export UNITREE_C7_GMR_DIR="${UNITREE_C7_GMR_DIR:-${C7_ROOT}/gmr}"
export UNITREE_C7_ASSET_DIR="${UNITREE_C7_ASSET_DIR:-${C7_ROOT}/resources/course_files}"
export UNITREE_C7_CONDA_ENV="${UNITREE_C7_CONDA_ENV:-/home/gtk/UNITREE/.conda/envs/gmr310}"
unset C7_ROOT
