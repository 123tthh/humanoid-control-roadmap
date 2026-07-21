# C5：基于分层强化学习的人形机器人导航框架

本章的共享运行时由 `scripts/env.sh` 载入；该脚本仅改变当前 shell 的环境变量，不会影响运行中的 C1。

## 目录约定

```
C5/
  source/unitree_rl_lab/ # 已解压的完整课程包源码（不纳入共享依赖）
  scripts/       # 本章隔离入口
  资源清单.md
```

执行 `./scripts/c5.sh preflight` 可以在不运行 Isaac Sim、不使用 GPU 的情况下确认课程包和低层策略已就位。`scripts/env.sh` 把学生源码目录放在 `PYTHONPATH` 最前并将 `UNITREE_RL_LAB_PATH` 指向学生包；因此无需向 C1 的 `env_isaaclab` 执行 `pip install -e`，也不会改变已安装的基线包。

课程原有入口已通过封装保留：`./scripts/c5.sh list`、`play`、`train`。它们从不自动执行。
