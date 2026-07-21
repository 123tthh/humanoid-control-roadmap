#!/usr/bin/env bash
# Local documentation references:
# - /home/gtk/UNITREE/C2/docs/course-materials/实践2：设计感知与动作空间，实现宇树G1粗糙地形行走策略7.12版.pdf

set -eo pipefail
C2_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${C2_ROOT}/scripts/env.sh"
cd "${C2_ROOT}"

command_name="${1:-help}"
if [[ $# -gt 0 ]]; then
    shift
fi

case "${command_name}" in
    check)
        python -c 'import c2_rough_terrain; import gymnasium as gym; assert "Unitree-G1-29dof-Velocity-Rough" in gym.registry; print("C2 rough-terrain task registration: OK")'
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
            '  check  Validate isolated C2 task registration (no GPU simulation)' \
            '  smoke  Run one headless C2 rough-terrain learning iteration' \
            '  train  Train C2 rough-terrain policy headlessly' \
            '  play   Launch C2 rough-terrain policy playback'
        ;;
    *)
        printf 'Unknown command: %s\n' "${command_name}" >&2
        exit 2
        ;;
esac
