# UNITREE 公共运行时

本目录是 C1、C2、C3 共享启动配置的唯一入口，不复制或修改下列外部依赖：

- `/home/gtk/isaac-sim-5.1`
- `/home/gtk/miniconda3/envs/env_isaaclab`
- `/home/gtk/UNITREE_DEPS/IsaacLab`
- `/home/gtk/UNITREE_DEPS/unitree_rl_lab`
- `/home/gtk/UNITREE_DEPS/unitree_model`

`env/isaaclab.sh` 服务 C1/C2；`env/mujoco.sh` 服务 C3 的独立 MuJoCo 环境。这样 C3 安装 MuJoCo 依赖时不会改动 C1 的 Isaac Lab 环境或正在进行的训练。

## 章节边界

| 章节 | 运行时 | 课程工程位置 | 与 C1 的关系 |
| --- | --- | --- | --- |
| C1/C2/C5 | Isaac Sim 5.1 + `env_isaaclab` | 外部依赖只读；章节自己的源码树 | 不修改当前版本 |
| C3 | `unitree_mujoco` 独立 Conda 环境 | `C3/` | 与 C1 环境隔离 |
| C4/C6 | 各自课程包的 `uv`/`.venv` | 课程原始目录 | 与 C1 环境隔离 |
| C7 | 独立 Conda `gmr310` | `C7/gmr` | 与 C1/C3 环境隔离 |

所有章节脚本只改变调用它们的 shell；它们不会暂停、恢复或修改任何正在运行的训练进程。
