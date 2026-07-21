#!/usr/bin/env bash
# Local documentation reference:
# - /home/gtk/UNITREE/C6/实践6：基于教师-学生蒸馏的全身运动跟踪.pdf
# C6 is an isolated course-provided uv project and never activates C1's Conda environment.

set -eo pipefail
C6_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export UNITREE_C6_ROOT="${C6_ROOT}"
export UNITREE_C6_PROJECT_DIR="${UNITREE_C6_PROJECT_DIR:-${C6_ROOT}/shanlan_HW6/HW6_student_final/shenlan_humanoid_hw6}"
unset C6_ROOT
