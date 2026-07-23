#!/usr/bin/env bash
# Local documentation references:
# - /home/gtk/UNITREE/C2/docs/course-materials/实践2：设计感知与动作空间，实现宇树G1粗糙地形行走策略7.12版.pdf

# Isaac Sim's environment setup probes optional shell variables that may be
# unset under bash, so do not enable nounset before sourcing env.sh.
set -eo pipefail
C2_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${C2_ROOT}/scripts/env.sh"
# env.sh intentionally unsets C2_ROOT after exporting PYTHONPATH.
C2_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${C2_ROOT}/sim2sim"
exec python sim2sim_raycaster.py "$@"
