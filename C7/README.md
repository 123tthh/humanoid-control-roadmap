# C7：GMR 运动重定向框架

本章只产生供 C8 AMP 使用的动作数据，不使用 Isaac Sim 或 Isaac Lab，也不自动运行重定向任务。

## 无计算预检

```bash
cd /home/gtk/UNITREE/C7
./scripts/c7.sh preflight
./scripts/c7.sh models
```

`models` 在三个 SMPL-X `.pkl` 文件放入 `gmr/assets/body_models/smplx/` 后通过。

## 后续显式环境安装

```bash
./scripts/c7.sh setup
```

此命令创建 C7 专有 Conda 环境。安装后，先用 GMR 原始脚本对单条 SMPL-X 动作作可视化验证；只有完整 AMP `.npz` 导出器实现并通过 `scripts/c7.sh validate` 后，才将数据交给 C8。

输出数据的根姿态四元数须按 PDF 从 GMR 内部 `wxyz` 转为 `xyzw`；框架的校验器检查形状与有限值，四元数语义和动作质量仍须在 GMR MuJoCo 可视化中人工确认。
