#!/usr/bin/env bash
# Local documentation references:
# - /home/gtk/UNITREE/C8/docs/course-materials/实践8：基于 AMP 的拟人走跑策略复现.pdf

set -eo pipefail
C8_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${C8_ROOT}/scripts/env.sh"
# scripts/env.sh intentionally cleans its temporary C8_ROOT variable.  Restore
# the chapter root from its exported value because this file is sourced.
C8_ROOT="${UNITREE_C8_ROOT}"
command_name="${1:-help}"
if [[ $# -gt 0 ]]; then shift; fi

case "${command_name}" in
    preflight)
        test -f "${C8_ROOT}/rsl_rl_amp/algorithms/amp.py"
        test -f "${C8_ROOT}/source/unitree_rl_lab/unitree_rl_lab/tasks/locomotion/amp/amp_env.py"
        python "${C8_ROOT}/scripts/verify_amp_contract.py"
        ;;
    data)
        exec python "${C8_ROOT}/scripts/verify_amp_data.py" "${UNITREE_AMP_MOTION_ROOT}" "$@"
        ;;
    list)
        exec python "${C8_ROOT}/scripts/list_amp_tasks.py" "$@"
        ;;
    train)
        exec python "${C8_ROOT}/scripts/rsl_rl/train.py" --headless "$@"
        ;;
    play)
        exec python "${C8_ROOT}/scripts/rsl_rl/play.py" "$@"
        ;;
    help|-h|--help)
        cat <<'EOF'
Usage: scripts/c8.sh <command> [args]
  preflight  validate AMP reward, PPO loss, observation groups, and FullPlay registration (no GPU)
  data       validate AMP motion directory and required WalkToRun clip names (no simulator)
  list       list registered AMP tasks (no simulator)
  train      train a selected AMP task headlessly; do not run while C1 is training
  play       replay a selected AMP checkpoint
EOF
        ;;
    *) echo "Unknown command: ${command_name}" >&2; exit 2 ;;
esac
