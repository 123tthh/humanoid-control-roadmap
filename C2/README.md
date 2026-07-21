# C2：粗糙地形感知与动作空间

参考：`docs/course-materials/实践2：设计感知与动作空间，实现宇树G1粗糙地形行走策略7.12版.pdf`。

本章实现采用 `src/c2_rough_terrain` 的隔离注册任务 `Unitree-G1-29dof-Velocity-Rough`：保留 Unitree G1 29-DOF 的关节位置动作接口，在原有本体感知上添加 187 点 `height_scanner`，并替换为 Isaac Lab 的 `ROUGH_TERRAINS_CFG`。policy 与 critic 单帧观测均为 283 维，保留 5 帧历史时 policy 输入为 1415 维。不会修改 `/home/gtk/UNITREE_DEPS/unitree_rl_lab`。

```bash
cd /home/gtk/UNITREE/C2
./scripts/c2.sh check
./scripts/c2.sh smoke
./scripts/c2.sh train
```

`smoke` 与 `train` 会启动 Isaac Sim 并占用 GPU。C1 训练进行中时只可运行 `check`；待 C1 暂停或结束后再做仿真验证。

粗糙地形环境已按 PDF 将 base-height 改为相对 height scanner 的高度、移除以世界坐标为基准的 foot-clearance，并加入双足 air-time 奖励与延迟非法接触终止。C2 Sim2Sim 还需要课程附件 `ch2_sim2sim.zip` 和 MuJoCo raycaster 插件；未提供这些资源前不会伪造验证结果。
