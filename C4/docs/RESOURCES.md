# C4 蹲姿行走：课程资源与环境接口

参考：`course-materials/实践4：蹲姿行走策略，G1速度+骨盆高度MDP设计.pdf`。

完整课程附件已经整理到 `C4/`，框架默认使用该路径。其 mjlab 实现、锁文件和 TODO 保持课程原样，不以猜测版本替代。关键文件为：

```
C4/pyproject.toml
C4/uv.lock
C4/.python-version
C4/src/mjlab/
C4/tests/test_velocity_task.py
```

随后执行：

```bash
cd /home/gtk/UNITREE/C4
./scripts/c4.sh preflight
./scripts/c4.sh setup
./scripts/c4.sh test
```

`setup` 使用附件的 `uv.lock` 和 `--extra cu128` 创建仅属于 C4 的 `.venv`；不会安装到 C1 的 Conda 环境，也不会启动训练。`train` 已写好入口，但不会由框架自动执行。若移动了附件，用 `UNITREE_C4_PROJECT_DIR` 覆盖默认位置。
