#!/usr/bin/env bash
# Local documentation references:
# - /home/gtk/UNITREE/C2/docs/course-materials/实践2：设计感知与动作空间，实现宇树G1粗糙地形行走策略7.12版.pdf

set -eo pipefail
C2_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source /home/gtk/UNITREE/common/env/isaaclab.sh
export C2_SOURCE_PATH="${C2_ROOT}/src"
export PYTHONPATH="${C2_SOURCE_PATH}${PYTHONPATH:+:${PYTHONPATH}}"
unset C2_ROOT
