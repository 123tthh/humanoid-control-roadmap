#!/usr/bin/env python3
# Local documentation references:
# - /home/gtk/UNITREE/C7/docs/course-materials/实践7：使用 GMR 完成人体动作到 G1 的运动重定向.pdf
# - /home/gtk/UNITREE/C7/gmr/scripts/smplx_to_robot.py
"""Validate the safe AMP motion-data contract described in the C7 PDF."""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np


REQUIRED_KEYS = {
    "fps",
    "root_pos",
    "root_rot",
    "dof_pos",
    "local_body_pos",
    "link_body_list",
}


def validate(path: Path) -> None:
    with np.load(path, allow_pickle=False) as data:
        missing = REQUIRED_KEYS - set(data.files)
        if missing:
            raise ValueError(f"missing fields: {sorted(missing)}")

        fps = float(np.asarray(data["fps"]).item())
        root_pos = np.asarray(data["root_pos"])
        root_rot = np.asarray(data["root_rot"])
        dof_pos = np.asarray(data["dof_pos"])
        local_body_pos = np.asarray(data["local_body_pos"])
        link_body_list = np.asarray(data["link_body_list"]).astype(str)

    if fps <= 0:
        raise ValueError("fps must be greater than zero")
    if root_pos.ndim != 2 or root_pos.shape[1] != 3:
        raise ValueError(f"root_pos must have shape (T, 3), got {root_pos.shape}")
    frames = root_pos.shape[0]
    if root_rot.shape != (frames, 4):
        raise ValueError(f"root_rot must have shape ({frames}, 4), got {root_rot.shape}")
    if dof_pos.shape != (frames, 29):
        raise ValueError(f"dof_pos must have shape ({frames}, 29), got {dof_pos.shape}")
    if local_body_pos.ndim != 3 or local_body_pos.shape[0] != frames or local_body_pos.shape[2] != 3:
        raise ValueError("local_body_pos must have shape (T, links, 3)")
    if local_body_pos.shape[1] != len(link_body_list):
        raise ValueError("local_body_pos link dimension must match link_body_list")
    for name, array in (
        ("root_pos", root_pos),
        ("root_rot", root_rot),
        ("dof_pos", dof_pos),
        ("local_body_pos", local_body_pos),
    ):
        if not np.isfinite(array).all():
            raise ValueError(f"{name} contains NaN or infinity")

    print(f"C7 motion contract: OK ({path})")
    print(f"frames={frames}, fps={fps:g}, links={len(link_body_list)}, dof=29")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("motion", type=Path, help="AMP-compatible G1 .npz motion")
    args = parser.parse_args()
    validate(args.motion)


if __name__ == "__main__":
    main()
