#!/usr/bin/env bash
# Local documentation reference:
# - /home/gtk/UNITREE/C7/实践7：使用 GMR 完成人体动作到 G1 的运动重定向.pdf

set -eo pipefail
C7_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${C7_ROOT}/scripts/env.sh"
command_name="${1:-help}"
if [[ $# -gt 0 ]]; then shift; fi

require_sources() {
    test -f "${UNITREE_C7_GMR_DIR}/setup.py" || { echo "Missing GMR source: ${UNITREE_C7_GMR_DIR}" >&2; return 1; }
    test -f "${UNITREE_C7_GMR_DIR}/general_motion_retargeting/ik_configs/smplx_to_g1.json" || {
        echo 'GMR unitree_g1 SMPL-X mapping is missing.' >&2; return 1; }
    test -f "${UNITREE_C7_ASSET_DIR}/B12_-_walk_turn_right_(90)_stageii.npz" || {
        echo "Missing C7 sample SMPL-X motion: ${UNITREE_C7_ASSET_DIR}" >&2; return 1; }
    test -f "${UNITREE_C7_ASSET_DIR}/vis_robot_motion_npz.py" || {
        echo 'Missing C7 visualizer supplement.' >&2; return 1; }
}

require_smplx_models() {
    local model_dir="${UNITREE_C7_GMR_DIR}/assets/body_models/smplx"
    local model_name
    for model_name in SMPLX_NEUTRAL.pkl SMPLX_FEMALE.pkl SMPLX_MALE.pkl; do
        test -s "${model_dir}/${model_name}" || {
            echo "Missing required SMPL-X model: ${model_dir}/${model_name}" >&2
            return 1
        }
    done
    printf 'C7 SMPL-X models: OK (%s)\n' "${model_dir}"
}

activate_gmr() {
    source /home/gtk/miniconda3/etc/profile.d/conda.sh
    conda activate "${UNITREE_C7_CONDA_ENV}"
    export PYTHONNOUSERSITE=1
}

case "${command_name}" in
    preflight)
        require_sources
        printf 'C7 GMR source: %s\nC7 sample motion: %s\n' "${UNITREE_C7_GMR_DIR}" "${UNITREE_C7_ASSET_DIR}"
        ;;
    models)
        require_smplx_models
        ;;
    setup)
        require_sources
        source /home/gtk/miniconda3/etc/profile.d/conda.sh
        conda create --prefix "${UNITREE_C7_CONDA_ENV}" python=3.10 -y
        activate_gmr
        cd "${UNITREE_C7_GMR_DIR}"
        python -m pip install 'numpy==1.26.4' 'scipy==1.15.3'
        exec python -m pip install -e . "$@"
        ;;
    validate)
        activate_gmr
        exec python "${C7_ROOT}/scripts/validate_motion_npz.py" "$@"
        ;;
    help|-h|--help) cat <<'EOF'
Usage: scripts/c7.sh <command> [args]
  preflight          validate source, mapping, and supplied motion files (no GPU)
  models             verify the three licensed SMPL-X .pkl model files
  setup              create isolated gmr310 and install GMR's declared dependencies
  validate FILE.npz  validate an AMP-compatible 29-DoF motion file (no simulation)
EOF
        ;;
    *) echo "Unknown command: ${command_name}" >&2; exit 2 ;;
esac
