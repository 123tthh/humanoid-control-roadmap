#!/usr/bin/env bash
# Local documentation reference:
# - /home/gtk/UNITREE/C5/实践5：基于分层强化学习的人形机器人导航.pdf

set -eo pipefail
C5_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${C5_ROOT}/scripts/env.sh"
command_name="${1:-help}"
if [[ $# -gt 0 ]]; then shift; fi

case "${command_name}" in
    preflight)
        test -d "${UNITREE_C5_PROJECT_DIR}" || { echo "Missing C5 course project: ${UNITREE_C5_PROJECT_DIR}" >&2; exit 1; }
        test -f "${UNITREE_C5_PROJECT_DIR}/pretrained/g1_29dof_lowlevel/policy.pt" || {
            echo 'C5 low-level policy.pt was not found in the extracted course package.' >&2; exit 1; }
        printf 'C5 shared runtime: %s\nC5 course project: %s\n' "${ISAACSIM_PATH}" "${UNITREE_C5_PROJECT_DIR}"
        ;;
    list)
        exec "${UNITREE_C5_PROJECT_DIR}/unitree_rl_lab.sh" --list "$@"
        ;;
    play)
        exec "${UNITREE_C5_PROJECT_DIR}/unitree_rl_lab.sh" --play "$@"
        ;;
    train)
        exec "${UNITREE_C5_PROJECT_DIR}/unitree_rl_lab.sh" --train "$@"
        ;;
    help|-h|--help) cat <<'EOF'
Usage: scripts/c5.sh <command> [args]

  preflight  verify the student package and the low-level policy (no GPU)
  list       list the student package task registrations
  play       use the student package playback entry point
  train      use the student package training entry point (never run automatically)
EOF
        ;;
    *) echo "Unknown command: ${command_name}" >&2; exit 2 ;;
esac
