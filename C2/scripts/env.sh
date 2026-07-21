#!/usr/bin/env bash
# Local documentation references:
# - /home/gtk/UNITREE/C2/深蓝学院-人形机器人运动控制-第2章-课件_学员版.pdf

set -eo pipefail
C2_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source /home/gtk/UNITREE/common/env/isaaclab.sh
export C2_SOURCE_PATH="${C2_ROOT}/source"
export PYTHONPATH="${C2_SOURCE_PATH}${PYTHONPATH:+:${PYTHONPATH}}"
unset C2_ROOT
