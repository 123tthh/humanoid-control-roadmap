# Rough Raycaster Sim2Sim

训练完成后，使用本目录的 MuJoCo sim2sim 验证。它不走 DDS 通信，而是直接在 Python 中加载 MuJoCo、读取 raycaster `sensordata`、拼接观测并运行 policy。课程所需的 G1、粗糙地形和 raycaster 资产已在本目录中。

视频演示链接：【【sim2sim】宇树机器人g1 粗糙地形带感知行走 mujoco】 https://www.bilibili.com/video/BV1n4jw6nExJ/


### 1 下载并编译 MuJoCo raycaster 插件

sim2sim 中的 height scanner 依赖 MuJoCo raycaster 插件：

- 插件仓库：`https://github.com/Albusgive/mujoco_ray_caster.git`
- 编译步骤：直接参考插件仓库 README。

需要注意：编译插件时使用的 MuJoCo 版本应和 Python 运行时加载的 MuJoCo 版本一致，否则可能出现 `plugin mujoco.sensor.ray_caster not found` 或 ABI 不兼容问题。

编译成功后，需要找到生成的动态库路径，例如：

```text
/path/to/mujoco/build/lib/libsensor_raycaster.so
```

默认路径已配置为 `/home/gtk/UNITREE_DEPS/mujoco-3.3.6-source/plugin/mujoco_ray_caster/lib/libsensor_raycaster.so`。若依赖目录不同，以环境变量覆盖：`export C2_RAYCASTER_PLUGIN_LIBRARY=/actual/path/libsensor_raycaster.so`。

### 2 配置 sim2sim/config.py

打开：

```text
/path/to/sim2sim/config.py
```

至少需要检查以下几项：

```python
SIM2SIM_DIR = "/path/to/sim2sim"
ASSETS_DIR = os.path.join(SIM2SIM_DIR, "assets")

TRAIN_RUN_DIR = (
    "/path/to/unitree_rl_lab/logs/rsl_rl/"
    "unitree_g1_29dof_velocity_rough/<run_time>"
)

ROBOT_SCENE = os.path.join(ASSETS_DIR, "scene_terrain_raycaster.xml")

RAYCASTER_PLUGIN_LIBRARY = "/path/to/mujoco/build/lib/libsensor_raycaster.so"

POLICY_PATH = os.path.join(TRAIN_RUN_DIR, "model_14000.pt")
DEPLOY_CONFIG = os.path.join(TRAIN_RUN_DIR, "params", "deploy.yaml")
```

其中最重要的是：

- `RAYCASTER_PLUGIN_LIBRARY` 指向真实存在的 `libsensor_raycaster.so`。
- `ROBOT_SCENE` 指向 `sim2sim/assets/` 下的 `scene_terrain_raycaster.xml`。
- `TRAIN_RUN_DIR` 指向本次粗糙地形训练产生的日志目录。
- `POLICY_PATH` 指向实际要测试的 checkpoint。
- `DEPLOY_CONFIG` 指向该 run 目录下的 `params/deploy.yaml`。

如果路径不对，常见报错包括：

- `plugin mujoco.sensor.ray_caster not found`
- `Error opening file scene_terrain_raycaster.xml`
- `No such file or directory: model_xxxx.pt`
- 观测维度和策略输入维度不一致

### 3 运行 sim2sim

先运行无窗口快速检查：

```bash
cd /home/gtk/UNITREE/C2
./scripts/c2_sim2sim.sh --no-viewer --steps 20
```

如果无窗口检查正常，再启动可视化键盘控制：

```bash
./scripts/c2_sim2sim.sh
```

键盘控制：

- `方向键 ↑/↓` 或 `小键盘 8/2`：前进/后退速度
- `方向键 ←/→` 或 `小键盘 4/6`：左右转向角速度
- `Space` 或 `小键盘 5`：停止
- `R`：重置仿真
