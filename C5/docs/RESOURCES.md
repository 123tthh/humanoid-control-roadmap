# C5 分层导航：课程资源与环境接口

参考：`course-materials/实践5：基于分层强化学习的人形机器人导航.pdf`。

C5 复用 `/home/gtk/isaac-sim-5.1`、现有 `env_isaaclab`、以及只读的 `/home/gtk/UNITREE_DEPS/IsaacLab` 和 `unitree_rl_lab`。它不安装新 Isaac Lab，也不改变 C1 训练。

完整课程包已经整理到 `C5/`，其导航源码、7 个 TODO、原始入口、配置和低层策略均保持课程原样。预检：

```bash
cd /home/gtk/UNITREE/C5
./scripts/c5.sh preflight
```

默认预检确认 `pretrained/g1_29dof_lowlevel/policy.pt`、导航任务/训练配置和对应 Python 包。任务标识应包括：

- `Unitree-G1-29dof-LowLevel`
- `Unitree-G1-29dof-Navigation-HRL-Baseline`
- `Unitree-G1-29dof-Navigation-HRL-Extension`

若移动课程包，可用 `UNITREE_C5_PROJECT_DIR` 覆盖默认位置；其训练脚本 API 仍以包内 `unitree_rl_lab.sh`、`scripts/rsl_rl/train.py` 和 `play.py` 为准。
