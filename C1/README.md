# C1：宇树 G1 仿真环境与基础验证

本章已构建一套与现有项目隔离的 Miniconda 环境，目标组合为：

| 组件 | 固定版本 / 位置 |
| --- | --- |
| Isaac Sim | 5.1.0，`/home/gtk/isaac-sim-5.1` |
| Isaac Lab | v2.3.0，`/home/gtk/UNITREE_DEPS/IsaacLab` |
| Unitree RL Lab | 0.2.1，`/home/gtk/UNITREE_DEPS/unitree_rl_lab` |
| Unitree USD 模型 | `/home/gtk/UNITREE_DEPS/unitree_model` |
| Miniconda 环境 | `env_isaaclab`，Python 3.11 |
| PyTorch | 2.7.0+cu128 |
| RSL-RL | 3.0.1 |

`/home/gtk/tianji_netwon_ws/external/IsaacLab`、`newton312` 和其他已有项目均未修改。C1 目录仅保存第一章资料、验证入口及后续训练输出。

## 快速验证

从本目录执行：

```bash
./scripts/c1.sh check
./scripts/c1.sh list
./scripts/c1.sh smoke
```

分别验证静态环境与宿主 GPU、Unitree 任务注册、Isaac Sim/Isaac Lab headless 物理步进。

如需进入交互式环境：

```bash
source scripts/env.sh
```

该脚本会从 Python 3.11 进程中移除外部 `/opt/ros/*` Python/动态库路径，避免系统 ROS 的 Python ABI 污染训练环境。

## 训练与回放

先做一次小规模启动验证：

```bash
./scripts/c1.sh train --num_envs 16 --max_iterations 1
```

该命令已在本机实测通过，完成 16 个 G1 环境、384 个仿真步和 1 次 PPO 迭代。

正式训练：

```bash
./scripts/c1.sh train
```

训练日志保存在本章的 `logs/rsl_rl/`。查看曲线与回放：

```bash
./scripts/c1.sh tensorboard
./scripts/c1.sh play
```

也可以显式指定 checkpoint：

```bash
./scripts/c1.sh play --checkpoint /absolute/path/to/model_*.pt
```

## 与实践 PDF 的差异

- PDF 前置要求写 Isaac Lab 2.2.0，但当前 Unitree RL Lab 官方 README 明确声明 Isaac Sim 5.1.0 + Isaac Lab 2.3.0；Isaac Lab v2.3.0 的官方发布说明也明确其基于 Isaac Sim 5.1。因此本环境固定为 2.3.0。
- PDF 的 TensorBoard 示例把 `latest.pt` 当作日志目录。当前代码实际写入 `logs/rsl_rl/<run>/`，TensorBoard 应指向 `logs/rsl_rl/`。
- 本机实际安装的是 ROS 2 Humble（`/opt/ros/humble`）。Isaac Sim 5.1 在 Ubuntu 22.04 上默认加载内置的 Humble/Python 3.11 Bridge；外部 Humble 节点在另一个终端使用系统安装，避免 Python 3.10 路径进入 Isaac Sim 进程。

详细检查结果见 [ENVIRONMENT.md](docs/ENVIRONMENT.md)。

工作站图形界面、Humble ROS 2 Bridge、训练、回放与 TensorBoard 的完整命令见 [OPERATIONS.md](docs/OPERATIONS.md)。

## 文档依据

- `/home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/requirements.md`
- `/home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_workstation.md`
- `/home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_ros.md`
- `/home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/python_scripting/manual_standalone_python.md`
- `/home/gtk/ai_docs/docs.ros.org/en/rolling/Installation/Ubuntu-Install-Debs.md`
- `/home/gtk/UNITREE_DEPS/IsaacLab/docs/source/setup/installation/binaries_installation.rst`
- `docs/course-materials/实践1：宇树G1仿真环境（Isaac Sim_Lab_MuJoCo）搭建与基础功能验证.pdf`
