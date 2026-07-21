#!/usr/bin/env python3
# Local documentation references:
# - /home/gtk/UNITREE/C8/docs/course-materials/实践8：基于 AMP 的拟人走跑策略复现.pdf
# - /home/gtk/UNITREE/C8/source/unitree_rl_lab/unitree_rl_lab/tasks/locomotion/amp/config/g1/motion_cfg.py
"""Validate that a WalkToRun AMP motion root contains the configured clips."""

from __future__ import annotations

import argparse
import ast
from pathlib import Path


CHAPTER_ROOT = Path(__file__).resolve().parents[1]
MOTION_CFG_PATH = (
    CHAPTER_ROOT / "source/unitree_rl_lab/unitree_rl_lab/tasks/locomotion/amp/config/g1/motion_cfg.py"
)


def configured_walk_to_run_clips() -> tuple[str, ...]:
    """Read the configured literal weights without importing Omni extensions."""
    module = ast.parse(MOTION_CFG_PATH.read_text(encoding="utf-8"), filename=str(MOTION_CFG_PATH))
    for node in module.body:
        if not isinstance(node, ast.ClassDef) or node.name != "G1WalkToRunMotionCfg":
            continue
        for statement in node.body:
            if not isinstance(statement, ast.AnnAssign) or not isinstance(statement.target, ast.Name):
                continue
            if statement.target.id != "clip_weights" or not isinstance(statement.value, ast.Call):
                continue
            factory = next((keyword.value for keyword in statement.value.keywords if keyword.arg == "default_factory"), None)
            if isinstance(factory, ast.Lambda):
                weights = ast.literal_eval(factory.body)
                return tuple(weights)
    raise RuntimeError(f"Could not read G1WalkToRunMotionCfg.clip_weights from {MOTION_CFG_PATH}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("motion_root", type=Path, help="directory containing the mixed/ WalkToRun clips")
    args = parser.parse_args()
    root = args.motion_root.expanduser().resolve()
    missing = [name for name in configured_walk_to_run_clips() if not (root / "mixed" / f"{name}.npz").is_file()]
    if missing:
        raise SystemExit("Missing WalkToRun clips:\n  " + "\n  ".join(missing))
    print(f"C8 AMP motion data: OK ({root / 'mixed'})")


if __name__ == "__main__":
    main()
