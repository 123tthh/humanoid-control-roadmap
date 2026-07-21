#!/usr/bin/env bash
# Local documentation reference:
# - /home/gtk/UNITREE/C4/实践4：蹲姿行走策略，G1速度+骨盆高度MDP设计.pdf

set -eo pipefail
C4_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${C4_ROOT}/scripts/env.sh"
command_name="${1:-help}"
if [[ $# -gt 0 ]]; then shift; fi

require_project() {
    command -v uv >/dev/null || { echo 'Missing uv. Install uv, then rerun.' >&2; return 1; }
    test -f "${UNITREE_C4_PROJECT_DIR}/pyproject.toml" || {
        echo "Missing C4 course project: ${UNITREE_C4_PROJECT_DIR}/pyproject.toml" >&2
        echo 'Extract HW4_蹲姿行走作业.zip into C4/project first.' >&2
        return 1
    }
}

case "${command_name}" in
    preflight) require_project; echo "C4 project ready: ${UNITREE_C4_PROJECT_DIR}" ;;
    setup) require_project; cd "${UNITREE_C4_PROJECT_DIR}"; exec uv sync --extra cu128 "$@" ;;
    test) require_project; cd "${UNITREE_C4_PROJECT_DIR}"; exec env PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 uv run python -m pytest tests/test_velocity_task.py -q "$@" ;;
    train) require_project; cd "${UNITREE_C4_PROJECT_DIR}"; exec uv run train Mjlab-VelocityHeight-Flat-Unitree-G1 --env.scene.num-envs 4096 "$@" ;;
    help|-h|--help) cat <<'EOF'
Usage: scripts/c4.sh <command> [args]
  preflight  verify the course archive and uv are available (no GPU work)
  setup      create C4's isolated uv environment from its lockfile
  test       run the course velocity task tests
  train      launch the documented crouch-walking task (never run automatically)
EOF
        ;;
    *) echo "Unknown command: ${command_name}" >&2; exit 2 ;;
esac
