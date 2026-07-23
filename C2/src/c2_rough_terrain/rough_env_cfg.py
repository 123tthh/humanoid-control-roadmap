# Local documentation references:
# - /home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/robot_simulation/ext_isaacsim_robot_policy_example.md
# - /home/gtk/UNITREE/C2/docs/course-materials/实践2：设计感知与动作空间，实现宇树G1粗糙地形行走策略7.12版.pdf
"""Isolated C2 G1 rough-terrain configuration with a terrain height scan."""

from __future__ import annotations

from importlib import import_module
from typing import TYPE_CHECKING, Sequence

import gymnasium as gym
import torch

from isaaclab.managers import ManagerTermBase, ManagerTermBaseCfg
from isaaclab.managers import ObservationTermCfg as ObsTerm
from isaaclab.managers import RewardTermCfg as RewTerm
from isaaclab.managers import SceneEntityCfg, TerminationTermCfg as DoneTerm
from isaaclab.sensors import ContactSensor
from isaaclab.terrains.config.rough import ROUGH_TERRAINS_CFG
from isaaclab.utils import configclass

from unitree_rl_lab.tasks.locomotion import mdp

if TYPE_CHECKING:
    from isaaclab.envs import ManagerBasedRLEnv


RobotEnvCfg = import_module(
    "unitree_rl_lab.tasks.locomotion.robots.g1.29dof.velocity_env_cfg"
).RobotEnvCfg


class illegal_reset_contact(ManagerTermBase):
    """Terminate only after repeated non-foot contact, avoiding reset transients."""

    def __init__(self, cfg: ManagerTermBaseCfg, env: ManagerBasedRLEnv):
        super().__init__(cfg, env)
        self.illegal_contact_counter = torch.zeros(env.num_envs, device=env.device, dtype=torch.int)

    def __call__(
        self,
        env: ManagerBasedRLEnv,
        threshold: float,
        sensor_cfg: SceneEntityCfg,
        print_reason: bool = False,
        episode_length_threshold: int = 1,
    ) -> torch.Tensor:
        contact_sensor: ContactSensor = env.scene.sensors[sensor_cfg.name]
        net_contact_forces = contact_sensor.data.net_forces_w_history
        contacts = torch.any(
            torch.max(torch.norm(net_contact_forces[:, :, sensor_cfg.body_ids], dim=-1), dim=1)[0] > threshold,
            dim=1,
        )
        self.illegal_contact_counter += contacts.int()
        reset_envs = torch.logical_and(
            self.illegal_contact_counter >= episode_length_threshold,
            env.episode_length_buf >= episode_length_threshold,
        )
        if reset_envs.any() and print_reason:
            print(f"illegal_reset_contact: {reset_envs.sum()}")
        return reset_envs

    def reset(self, env_ids: Sequence[int] | slice | None = None) -> None:
        if env_ids is None:
            env_ids = slice(None)
        self.illegal_contact_counter[env_ids] = 0


@configclass
class C2G1RoughEnvCfg(RobotEnvCfg):
    """C1 G1 velocity task extended with rough terrain and height-scan observations."""

    def __post_init__(self):
        super().__post_init__()
        # Keep the course-required 29-DoF joint-position action contract
        # explicit even though it is inherited from RobotEnvCfg.
        self.actions.JointPositionAction.scale = 0.25
        self.actions.JointPositionAction.use_default_offset = True
        self.scene.terrain.terrain_generator = ROUGH_TERRAINS_CFG.replace(curriculum=True)
        self.scene.terrain.max_init_terrain_level = self.scene.terrain.terrain_generator.num_rows - 1
        self.scene.height_scanner.debug_vis = True
        height_scan = ObsTerm(
            func=mdp.height_scan,
            params={"sensor_cfg": SceneEntityCfg("height_scanner")},
            clip=(-1.0, 5.0),
        )
        self.observations.policy.height_scanner = height_scan
        self.observations.critic.height_scanner = height_scan

        self.rewards.base_height.params["sensor_cfg"] = SceneEntityCfg("height_scanner")
        self.rewards.feet_clearance = None
        self.rewards.feet_air_time = RewTerm(
            func=mdp.feet_air_time_positive_biped,
            weight=0.5,
            params={
                "command_name": "base_velocity",
                "sensor_cfg": SceneEntityCfg("contact_forces", body_names=".*_ankle_roll_link"),
                "threshold": 0.5,
            },
        )

        self.terminations.base_height = None
        self.terminations.illegal_reset_contact = DoneTerm(
            func=illegal_reset_contact,
            time_out=True,
            params={
                "sensor_cfg": SceneEntityCfg("contact_forces", body_names=["torso_link"]),
                "threshold": 1.0,
                "episode_length_threshold": 5,
                "print_reason": False,
            },
        )


@configclass
class C2G1RoughPlayEnvCfg(C2G1RoughEnvCfg):
    """Low-memory C2 rough-terrain play configuration."""

    def __post_init__(self):
        super().__post_init__()
        self.scene.num_envs = 1
        self.scene.terrain.max_init_terrain_level = None
        if self.scene.terrain.terrain_generator is not None:
            self.scene.terrain.terrain_generator.num_rows = 5
            self.scene.terrain.terrain_generator.num_cols = 5
            self.scene.terrain.terrain_generator.curriculum = False
        self.observations.policy.enable_corruption = False


def register_c2_task() -> None:
    """Register the C2 task once without changing the shared Unitree RL Lab tree."""
    task_id = "Unitree-G1-29dof-Velocity-Rough"
    if task_id in gym.registry:
        return
    gym.register(
        id=task_id,
        entry_point="isaaclab.envs:ManagerBasedRLEnv",
        disable_env_checker=True,
        kwargs={
            "env_cfg_entry_point": "c2_rough_terrain.rough_env_cfg:C2G1RoughEnvCfg",
            "play_env_cfg_entry_point": "c2_rough_terrain.rough_env_cfg:C2G1RoughPlayEnvCfg",
            "rsl_rl_cfg_entry_point": "unitree_rl_lab.tasks.locomotion.agents.rsl_rl_ppo_cfg:BasePPORunnerCfg",
        },
    )
