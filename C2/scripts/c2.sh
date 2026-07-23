#!/usr/bin/env bash
# Local documentation references:
# - /home/gtk/UNITREE/C2/docs/course-materials/实践2：设计感知与动作空间，实现宇树G1粗糙地形行走策略7.12版.pdf

set -eo pipefail
C2_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${C2_ROOT}/scripts/env.sh"
# env.sh deliberately keeps its project-local variables private.  Restore the
# root needed by this wrapper after sourcing it.
C2_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${C2_ROOT}"

command_name="${1:-help}"
if [[ $# -gt 0 ]]; then
    shift
fi

case "${command_name}" in
    check)
        python "${C2_ROOT}/scripts/c2_static_check.py"
        ;;
    smoke)
        python "${C2_ROOT}/scripts/c2_entry.py" train --headless --num_envs 16 --max_iterations 1 "$@"
        ;;
    train)
        python "${C2_ROOT}/scripts/c2_entry.py" train --headless "$@"
        ;;
    play)
        python "${C2_ROOT}/scripts/c2_entry.py" play "$@"
        ;;
    help|-h|--help)
        printf '%s\n' \
            'Usage: scripts/c2.sh <command> [args]' \
            '' \
            '  check  Validate the C2 assignment contract without starting Isaac Sim' \
            '  smoke  Run one headless C2 rough-terrain learning iteration' \
            '  train  Train C2 rough-terrain policy headlessly' \
            '  play   Launch C2 rough-terrain policy playback'
        ;;
    *)
        printf 'Unknown command: %s\n' "${command_name}" >&2
        exit 2
        ;;
esac
