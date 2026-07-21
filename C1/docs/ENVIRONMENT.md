# C1 环境检查报告

检查日期：2026-07-20（Asia/Shanghai）

## 已完成

- 主机：Ubuntu 22.04.5 LTS，Linux 6.8.0-111-generic。
- GPU：NVIDIA GeForce RTX 5090 D v2，24 GiB；驱动 580.126.09；宿主 `nvidia-smi` 正常。
- 内存：125 GiB；构建前磁盘可用空间约 164 GiB。
- Isaac Sim 5.1 的 `python.sh` 能导入 `isaacsim`。
- 独立 Miniconda 环境 `env_isaaclab` 已创建，Python 3.11。
- Isaac Lab v2.3.0、Unitree RL Lab 0.2.1、RSL-RL 3.0.1 已可编辑安装。
- PyTorch 2.7.0+cu128 能识别 RTX 5090，并已完成实际 CUDA 张量运算。
- G1 29-DOF USD 及其 LFS 基础层已下载并验证为二进制 USDC 文件。
- `Unitree-G1-29dof-Velocity` 等 5 个任务已成功注册。
- Isaac Sim headless 已初始化 Vulkan/PhysX，并完成 5 个 Isaac Lab 物理步进。
- G1 端到端训练冒烟测试已通过：16 个环境、29 维动作，完成 384 个仿真步和 1 次 PPO 迭代，退出码为 0。
- 本机 ROS 2 Humble 与 Isaac Sim 自带的 Humble/Python 3.11 Bridge 动态库均已验证存在。

## 隔离边界

- 共享依赖统一位于 `/home/gtk/UNITREE_DEPS`，不放在 C1 内。
- Isaac Lab 固定在 tag `v2.3.0`；未修改其他项目依赖的 Isaac Lab。
- 只创建 `env_isaaclab`；未修改 `newton312`、`lerobot_viz` 等 Conda 环境。
- Unitree 的模型路径支持 `UNITREE_MODEL_DIR` 环境变量，默认指向共享模型目录。

## 已识别问题与处理

1. `isaac_ros2_docs` MCP 当前开放的 Isaac Sim 根目录是 `6.0.1`，并非要求的 `5.1.0`。Isaac Sim 相关结论因此直接锁定本机 `/home/gtk/ai_docs/.../5.1.0` 文档；ROS 2 Rolling 文档仍通过 MCP 读取。
2. Isaac Lab v2.3.0 的 `environment.yml` 没有显式安装 `pip`；已仅在 `env_isaaclab` 中补装。
3. `flatdict==4.0.1` 无法用 setuptools 83 的隔离构建；已仅在该环境中固定 setuptools 80.10.2，并以非隔离方式安装 flatdict，随后完成 Isaac Lab 核心安装。
4. Miniconda base 的两个可选插件缺少 `pydantic_core`，普通命令会打印 entry-point 警告。为避免修改共享 base，本章命令设置 `CONDA_NO_PLUGINS=true`；环境功能不受影响。
5. ROS 2 使用本机已经安装的 Humble，不再假设 Jazzy 或 Rolling 路径。外部 Humble 节点从 `/opt/ros/humble` 启动；Isaac Sim 进程使用安装包内置的 Humble/Python 3.11 库。
6. 首次 headless 验证在物理步进完成并打印 PASS 后卡在扩展逐项清理；验证脚本按 5.1 `SimulationApp.close(skip_cleanup=True)` 官方接口使用即时退出。该选项仅用于短生命周期验收脚本，不改变训练/回放脚本的退出逻辑。
7. 在加载 Isaac Sim 自带 `pip_prebundle` 后，`pip check` 会报告其 URDF 导出、云认证组件的可选依赖元数据不完整，以及预置 `lxml`/`packaging` 与声明范围不一致。核心 C1 链路已通过 CUDA、物理步进和实际训练验收；未用 PyPI 包覆盖 NVIDIA 的预置库，以免破坏 Isaac Sim 5.1 的受控运行时。

## 验收命令

```bash
./scripts/c1.sh check
./scripts/c1.sh list
./scripts/c1.sh smoke
./scripts/c1.sh train --num_envs 16 --max_iterations 1
```

前三项用于环境验收；最后一项会启动一次最小 G1 训练迭代，用于端到端训练入口验收。上述四项均已在本机实测通过。
