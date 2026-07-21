#!/usr/bin/env python3
# Local documentation references:
# - /home/gtk/UNITREE/C8/docs/course-materials/实践8：基于 AMP 的拟人走跑策略复现.pdf
# - /home/gtk/UNITREE/C8/source/unitree_rl_lab/unitree_rl_lab/tasks/locomotion/amp/config/g1/__init__.py
"""List C8 AMP Gym task IDs without launching Isaac Sim."""

from __future__ import annotations

import ast
from pathlib import Path


REGISTRY_PATH = (
    Path(__file__).resolve().parents[1]
    / "source/unitree_rl_lab/unitree_rl_lab/tasks/locomotion/amp/config/g1/__init__.py"
)


def main() -> None:
    module = ast.parse(REGISTRY_PATH.read_text(encoding="utf-8"), filename=str(REGISTRY_PATH))
    tasks = next(
        (
            ast.literal_eval(statement.value)
            for statement in module.body
            if isinstance(statement, ast.Assign)
            and any(isinstance(target, ast.Name) and target.id == "G1_AMP_TASKS" for target in statement.targets)
        ),
        None,
    )
    if not tasks:
        raise RuntimeError(f"G1_AMP_TASKS is missing from {REGISTRY_PATH}")
    for task_id, train_cfg, play_cfg, runner_cfg in tasks:
        print(f"{task_id}\ttrain={train_cfg}\tplay={play_cfg}\trunner={runner_cfg}")


if __name__ == "__main__":
    main()
