#!/usr/bin/env bash
# Local documentation references:
# - /home/gtk/UNITREE/C3/实践3：人形机器人动作空间 HoST Sim2Sim 部署.pdf

set -eo pipefail
C3_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${C3_ROOT}/scripts/env.sh"
cd "${C3_ROOT}"

command_name="${1:-help}"
if [[ $# -gt 0 ]]; then
    shift
fi

case "${command_name}" in
    check)
        python -c 'import imageio, imageio_ffmpeg, mujoco, numpy, torch, yaml; print("C3 MuJoCo runtime imports: OK")'
        test -f "${C3_ROOT}/deploy_mujoco_host_student.py"
        test -f "${C3_ROOT}/policies/pretrained_humanoid_standup.pt"
        test -f "${C3_ROOT}/robots/g1/g1_23dof.xml"
        printf '%s\n' 'C3 course resources: OK'
        ;;
    run)
        exec python "${C3_ROOT}/deploy_mujoco_host_student.py" "$@"
        ;;
    help|-h|--help)
        printf '%s\n' \
            'Usage: scripts/c3.sh <command> [args]' \
            '' \
            '  check  Verify isolated MuJoCo runtime and the required course assets' \
            '  run    Run deploy_mujoco_host_student.py after the course archive is extracted'
        ;;
    *)
        printf 'Unknown command: %s\n' "${command_name}" >&2
        exit 2
        ;;
esac
