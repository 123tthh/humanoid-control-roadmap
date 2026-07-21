#!/usr/bin/env bash
# Local documentation reference:
# - /home/gtk/UNITREE/C6/docs/course-materials/实践6：基于教师-学生蒸馏的全身运动跟踪.pdf

set -eo pipefail
C6_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${C6_ROOT}/scripts/env.sh"
command_name="${1:-help}"
if [[ $# -gt 0 ]]; then shift; fi

require_project() {
    command -v uv >/dev/null || { echo 'Missing uv. Install uv, then rerun.' >&2; return 1; }
    test -f "${UNITREE_C6_PROJECT_DIR}/pyproject.toml" || {
        echo "Missing C6 course project: ${UNITREE_C6_PROJECT_DIR}/pyproject.toml" >&2
        echo 'C6 root must contain the supplied teacher-student pyproject.toml.' >&2
        return 1
    }
}

case "${command_name}" in
    preflight) require_project; test -d "${UNITREE_C6_PROJECT_DIR}/checkpoints"; echo "C6 project ready: ${UNITREE_C6_PROJECT_DIR}" ;;
    setup) require_project; cd "${UNITREE_C6_PROJECT_DIR}"; exec uv sync --dev "$@" ;;
    help|-h|--help) cat <<'EOF'
Usage: scripts/c6.sh <command> [args]
  preflight  verify course project, checkpoints, and uv (no GPU work)
  setup      create C6's isolated environment from the supplied lockfile
EOF
        ;;
    *) echo "Unknown command: ${command_name}" >&2; exit 2 ;;
esac
