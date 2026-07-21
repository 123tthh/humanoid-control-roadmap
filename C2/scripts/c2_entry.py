# Local documentation references:
# - /home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/robot_simulation/ext_isaacsim_robot_policy_example.md
# - /home/gtk/UNITREE/C2/docs/course-materials/实践2：设计感知与动作空间，实现宇树G1粗糙地形行走策略7.12版.pdf
"""Launch the upstream Unitree RSL-RL scripts after registering only the C2 task."""

from __future__ import annotations

import os
import runpy
import sys
from pathlib import Path


def main() -> None:
    if len(sys.argv) < 2 or sys.argv[1] not in {"train", "play"}:
        raise SystemExit("usage: c2_entry.py {train|play} [upstream arguments]")
    mode = sys.argv[1]
    unitree_rl_lab_path = Path(os.environ["UNITREE_RL_LAB_PATH"])
    upstream = unitree_rl_lab_path / "scripts" / "rsl_rl" / f"{mode}.py"
    source = upstream.read_text(encoding="utf-8")
    task_import = "import unitree_rl_lab.tasks  # noqa: F401"
    replacement = f"{task_import}\nimport c2_rough_terrain  # noqa: F401"
    if task_import not in source:
        raise RuntimeError(f"Cannot inject C2 task registration into upstream launcher: {upstream}")
    sys.argv = [str(upstream), "--task", "Unitree-G1-29dof-Velocity-Rough", *sys.argv[2:]]
    exec(compile(source.replace(task_import, replacement, 1), str(upstream), "exec"), {"__name__": "__main__", "__file__": str(upstream)})


if __name__ == "__main__":
    main()
