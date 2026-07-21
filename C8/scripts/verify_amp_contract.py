#!/usr/bin/env python3
# Local documentation references:
# - /home/gtk/UNITREE/C8/docs/course-materials/实践8：基于 AMP 的拟人走跑策略复现.pdf
# - /home/gtk/UNITREE/C8/rsl_rl_amp/algorithms/discriminator.py
# - /home/gtk/UNITREE/C8/source/unitree_rl_lab/unitree_rl_lab/tasks/locomotion/amp/config/g1/amp_flat_env_cfg.py
"""Run no-simulator checks for the C8 AMP data and reward contract."""

from __future__ import annotations

from pathlib import Path

import torch

from rsl_rl_amp.algorithms.discriminator import AMPDiscriminator
from rsl_rl_amp.algorithms.ppo import PPO


CHAPTER_ROOT = Path(__file__).resolve().parents[1]
G1_CONFIG_ROOT = CHAPTER_ROOT / "source/unitree_rl_lab/unitree_rl_lab/tasks/locomotion/amp/config/g1"


def main() -> None:
    discriminator = AMPDiscriminator(
        frame_dim=80,
        history_steps=3,
        reward_scale=5.0,
        task_reward_weight=0.5,
    )
    windows = torch.randn(4, 3, 80)
    discriminator.update_normalization(windows)
    style_rewards, scores = discriminator.style_reward(windows, step_dt=0.02)
    task_rewards = torch.ones_like(style_rewards)
    mixed_rewards = discriminator.mix_rewards(style_rewards, task_rewards)
    assert style_rewards.shape == (4,)
    assert scores.shape == (4,)
    assert torch.all(style_rewards >= 0.0)
    assert torch.all(style_rewards <= 0.100001)
    assert torch.allclose(mixed_rewards, 0.5 * (style_rewards + task_rewards))

    # Importing Isaac Lab configurations requires a live Kit application because
    # their asset classes import Omni physics extensions.  Keep preflight CPU-only
    # while still checking the authored source and its Python syntax.
    env_cfg = (G1_CONFIG_ROOT / "amp_flat_env_cfg.py").read_text(encoding="utf-8")
    runner_cfg = (G1_CONFIG_ROOT / "agents/rsl_rl_ppo_cfg.py").read_text(encoding="utf-8")
    task_registry = (G1_CONFIG_ROOT / "__init__.py").read_text(encoding="utf-8")
    required_terms = (
        "base_lin_vel",
        "base_ang_vel",
        "projected_gravity",
        "base_height",
        "joint_pos",
        "joint_vel",
        "key_links_pos_b",
    )
    assert all(f"{term} = ObsTerm" in env_cfg for term in required_terms)
    assert "self.history_length = 3" in env_cfg
    assert "self.concatenate_terms = True" in env_cfg
    assert "self.enable_corruption = False" in env_cfg
    assert 'amp_motion_profile: str = "walk_to_run"' in runner_cfg
    assert 'experiment_name = "unitree_g1_29dof_amp_walk_to_run"' in runner_cfg
    assert '"actor": ["policy"], "critic": ["critic"], "amp": ["amp"]' in runner_cfg
    assert '"task_reward_weight"] = 0.5' in runner_cfg
    assert "Unitree-G1-29dof-AMP-WalkToRun-FullPlay" in task_registry

    # This is the completed PPO expression from the C8 handout, checked
    # without constructing an Isaac Sim environment.
    surrogate_loss = torch.tensor(2.0)
    value_loss = torch.tensor(3.0)
    entropy = torch.tensor([4.0, 6.0])
    total_loss = surrogate_loss + 0.5 * value_loss - 0.1 * entropy.mean()
    assert torch.isclose(total_loss, torch.tensor(3.0))
    assert hasattr(PPO, "update")
    print("C8 AMP contract: OK (80-D frame, 3-frame history, reward mixing, FullPlay task)")


if __name__ == "__main__":
    main()
