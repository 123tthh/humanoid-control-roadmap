# C3：HoST Sim2Sim 部署

参考：`docs/course-materials/实践3：人形机器人动作空间 HoST Sim2Sim 部署.pdf`。

C3 使用 `/home/gtk/UNITREE/.conda/envs/unitree_mujoco`，与 C1 的 `env_isaaclab` 分离。课程资源已经整理到本章根目录：

```text
deploy_mujoco_host_student.py
configs/g1.yaml
policies/pretrained_humanoid_standup.pt
robots/g1/g1_23dof.xml
```

环境与资源齐全后执行：

```bash
cd /home/gtk/UNITREE/C3
./scripts/c3.sh check
./scripts/c3.sh run
```

PDF 指定 HoST 的关键映射是 `q_target = current_joint_positions + action_scale * policy_action`；不可替换为以 `default_angles` 为基准的残差动作空间。
