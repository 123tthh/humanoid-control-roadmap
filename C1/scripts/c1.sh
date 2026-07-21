#!/usr/bin/env bash
# Local documentation references:
# - /home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/python_scripting/manual_standalone_python.md
# - /home/gtk/UNITREE_DEPS/IsaacLab/docs/source/setup/installation/binaries_installation.rst

# Isaac Sim's supplied setup_conda_env.sh probes optional shell variables without
# defaults, so nounset cannot be enabled while sourcing the official environment.
set -eo pipefail

C1_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${C1_ROOT}/scripts/env.sh"
cd "${C1_ROOT}"

command_name="${1:-help}"
if [[ $# -gt 0 ]]; then
    shift
fi

case "${command_name}" in
    check)
        python "${C1_ROOT}/scripts/check_environment.py" "$@"
        ;;
    smoke)
        python "${C1_ROOT}/scripts/validate_isaac_sim.py" "$@"
        ;;
    list)
        python "${UNITREE_RL_LAB_PATH}/scripts/list_envs.py" "$@"
        ;;
    train)
        python "${UNITREE_RL_LAB_PATH}/scripts/rsl_rl/train.py" \
            --headless --task Unitree-G1-29dof-Velocity "$@"
        ;;
    play)
        python "${UNITREE_RL_LAB_PATH}/scripts/rsl_rl/play.py" \
            --task Unitree-G1-29dof-Velocity "$@"
        ;;
    tensorboard)
        tensorboard --logdir "${C1_ROOT}/logs/rsl_rl" "$@"
        ;;
    help|-h|--help)
        printf '%s\n' \
            "Usage: scripts/c1.sh <command> [args]" \
            "" \
            "Commands:" \
            "  check        Check versions, paths, model files, CUDA, and ROS isolation" \
            "  smoke        Run five headless Isaac Sim / Isaac Lab physics steps" \
            "  list         List Unitree Gymnasium tasks" \
            "  train        Train Unitree-G1-29dof-Velocity (pass extra train.py args)" \
            "  play         Play a checkpoint (pass extra play.py args)" \
            "  tensorboard  Serve C1 training logs"
        ;;
    *)
        printf 'Unknown command: %s\n' "${command_name}" >&2
        exit 2
        ;;
esac
