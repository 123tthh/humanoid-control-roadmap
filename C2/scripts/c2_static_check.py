# Local documentation references:
# - /home/gtk/UNITREE/C2/docs/course-materials/实践2：设计感知与动作空间，实现宇树G1粗糙地形行走策略7.12版.pdf
# - /home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/robot_simulation/ext_isaacsim_robot_policy_example.md
"""Validate C2's file-level assignment contract without launching Isaac Sim."""

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ROUGH_CFG = ROOT / "src" / "c2_rough_terrain" / "rough_env_cfg.py"
DEPLOY_CFG = ROOT / "sim2sim" / "policy" / "2026-06-12_10-36-30" / "params" / "deploy.yaml"
ROUGH_SCENE = ROOT / "sim2sim" / "assets" / "scene_rough.xml"


def require_text(path: Path, *terms: str) -> None:
    text = path.read_text(encoding="utf-8")
    missing = [term for term in terms if term not in text]
    if missing:
        raise SystemExit(f"{path.relative_to(ROOT)} missing: {', '.join(missing)}")


def main() -> None:
    require_text(
        ROUGH_CFG,
        "ROUGH_TERRAINS_CFG",
        "height_scanner",
        "mdp.height_scan",
        "JointPositionAction",
        "feet_air_time_positive_biped",
        "illegal_reset_contact",
        "Unitree-G1-29dof-Velocity-Rough",
    )
    require_text(DEPLOY_CFG, "height_scanner", "history_length: 5", "step_dt: 0.02")
    require_text(
        ROUGH_SCENE,
        'plugin="mujoco.sensor.ray_caster"',
        'name="height_scanner"',
        'value="0.1"',
        'value="1.0 1.6"',
    )
    print("C2 rough-terrain static contract: OK (187 scan points; 283 x 5 actor input)")


if __name__ == "__main__":
    main()
