#!/usr/bin/env bash
# Local documentation references:
# - /home/gtk/UNITREE/C1/docs/course-materials/实践1：宇树G1仿真环境（Isaac Sim_Lab_MuJoCo）搭建与基础功能验证.pdf
# - /home/gtk/UNITREE_DEPS/unitree_rl_lab/README.md
# - /home/gtk/UNITREE_DEPS/unitree_mujoco/readme.md

set -eo pipefail

C1_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDK_ROOT="/home/gtk/UNITREE_DEPS/unitree_sdk2"
SDK_PREFIX="${SDK_ROOT}/install"
MUJOCO_ROOT="/home/gtk/UNITREE_DEPS/unitree_mujoco"
RL_LAB_ROOT="/home/gtk/UNITREE_DEPS/unitree_rl_lab"
CONTROLLER_SOURCE="${RL_LAB_ROOT}/deploy/robots/g1_29dof"
CONTROLLER_BUILD="${CONTROLLER_SOURCE}/build-c1-sim2sim"
CONTROLLER_BINARY="${C1_ROOT}/sim2sim/bin/g1_ctrl"
FINAL_RUN="${C1_ROOT}/logs/rsl_rl/unitree_g1_29dof_velocity/2026-07-21_16-15-36"
FINAL_MODEL="${FINAL_RUN}/model_49999.pt"
DEPLOY_TEMPLATE="${CONTROLLER_SOURCE}/config/policy/velocity/v0/params/deploy.yaml"

runtime_library_path() {
    printf '%s:%s:%s' \
        "${SDK_PREFIX}/lib" \
        "${RL_LAB_ROOT}/deploy/thirdparty/onnxruntime-linux-x64-1.22.0/lib" \
        "${LD_LIBRARY_PATH:-}"
}

prepare_policy() {
    test -f "${FINAL_MODEL}"
    test -f "${FINAL_RUN}/exported/policy.onnx" || {
        echo "Missing exported ONNX policy. Run: ./scripts/sim2sim.sh export" >&2
        exit 1
    }
    mkdir -p "${FINAL_RUN}/params"
    install -m 0644 "${DEPLOY_TEMPLATE}" "${FINAL_RUN}/params/deploy.yaml"
}

prepare_controller() {
    test -x "${CONTROLLER_BUILD}/g1_ctrl" || {
        echo "Missing G1 controller. Run: ./scripts/sim2sim.sh build" >&2
        exit 1
    }
    mkdir -p "${C1_ROOT}/sim2sim/bin"
    install -m 0755 "${CONTROLLER_BUILD}/g1_ctrl" "${CONTROLLER_BINARY}"
}

case "${1:-help}" in
    preflight)
        test -f "${FINAL_MODEL}"
        test -x "${MUJOCO_ROOT}/simulate/build/unitree_mujoco"
        test -x "${CONTROLLER_BUILD}/g1_ctrl"
        test -e /dev/input/js0
        echo "C1 Sim2Sim preflight: SDK2, MuJoCo, G1 controller, final checkpoint, and /dev/input/js0 are ready."
        ;;
    export)
        "${C1_ROOT}/scripts/c1.sh" play --headless --video --video_length 1 --num_envs 1 --checkpoint "${FINAL_MODEL}"
        prepare_policy
        echo "C1 Sim2Sim policy export: ${FINAL_RUN}/exported/policy.onnx"
        ;;
    prepare)
        prepare_policy
        prepare_controller
        echo "C1 Sim2Sim controller prepared: ${CONTROLLER_BINARY}"
        ;;
    build)
        cmake -S "${SDK_ROOT}" -B "${SDK_ROOT}/build" -DBUILD_EXAMPLES=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${SDK_PREFIX}"
        cmake --build "${SDK_ROOT}/build" --parallel 8
        cmake --install "${SDK_ROOT}/build"
        test -e "${MUJOCO_ROOT}/simulate/mujoco" || ln -s /home/gtk/.mujoco/mujoco-3.3.6 "${MUJOCO_ROOT}/simulate/mujoco"
        cmake -S "${MUJOCO_ROOT}/simulate" -B "${MUJOCO_ROOT}/simulate/build" -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="${SDK_PREFIX}/lib/cmake"
        cmake --build "${MUJOCO_ROOT}/simulate/build" --parallel 8
        cmake -S "${CONTROLLER_SOURCE}" -B "${CONTROLLER_BUILD}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-I${SDK_PREFIX}/include -I${SDK_PREFIX}/include/ddscxx" -DCMAKE_EXE_LINKER_FLAGS="-L${SDK_PREFIX}/lib -Wl,-rpath,${SDK_PREFIX}/lib -Wl,-rpath,${RL_LAB_ROOT}/deploy/thirdparty/onnxruntime-linux-x64-1.22.0/lib"
        cmake --build "${CONTROLLER_BUILD}" --parallel 8
        prepare_controller
        ;;
    simulator)
        test -x "${MUJOCO_ROOT}/simulate/build/unitree_mujoco"
        install -m 0644 "${C1_ROOT}/sim2sim/mujoco-config.yaml" "${MUJOCO_ROOT}/simulate/config.yaml"
        export LD_LIBRARY_PATH="$(runtime_library_path)"
        exec "${MUJOCO_ROOT}/simulate/build/unitree_mujoco" -i 0 -n lo -r g1 -s scene_29dof.xml
        ;;
    controller)
        prepare_policy
        prepare_controller
        export LD_LIBRARY_PATH="$(runtime_library_path)"
        exec "${CONTROLLER_BINARY}" --network lo
        ;;
    help|-h|--help)
        cat <<'EOF'
Usage: scripts/sim2sim.sh <command>
  preflight   Check the G1 Sim2Sim prerequisites without using GPU
  export      Export model_49999.pt as ONNX/JIT via one headless Isaac Sim inference step
  build       Build isolated SDK2, MuJoCo, and G1 controller dependencies
  prepare     Install deployment parameters and stage the local controller binary
  simulator   Start the G1 MuJoCo simulator (terminal A)
  controller  Start the final-policy G1 controller (terminal B)
EOF
        ;;
    *) echo "Unknown command: ${1}" >&2; exit 2 ;;
esac
