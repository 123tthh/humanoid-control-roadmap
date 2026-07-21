#!/usr/bin/env bash
# Shared MuJoCo runtime for UNITREE C3.
# Local documentation references:
# - /home/gtk/UNITREE/C3/实践3：人形机器人动作空间 HoST Sim2Sim 部署.pdf

# This file must be sourced.  C3 uses an environment separate from C1 training.
set -eo pipefail

export CONDA_NO_PLUGINS=true
source /home/gtk/miniconda3/etc/profile.d/conda.sh
conda activate /home/gtk/UNITREE/.conda/envs/unitree_mujoco

export PYTHONNOUSERSITE=1
export MUJOCO_GL=glfw
