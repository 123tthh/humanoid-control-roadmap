# Local documentation references:
# - /home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/requirements.md
# - /home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_workstation.md
# - /home/gtk/ai_docs/docs.ros.org/en/rolling/Installation/Ubuntu-Install-Debs.md
# Practice reference: /home/gtk/UNITREE/C1/docs/course-materials/实践1：宇树G1仿真环境（Isaac Sim_Lab_MuJoCo）搭建与基础功能验证.pdf

"""Check the isolated C1 Isaac Sim / Isaac Lab / Unitree environment."""

from __future__ import annotations

import importlib.metadata
import os
import platform
import subprocess
import sys
from pathlib import Path


ISAAC_SIM = Path("/home/gtk/isaac-sim-5.1")
ISAAC_LAB = Path("/home/gtk/UNITREE_DEPS/IsaacLab")
UNITREE_RL_LAB = Path("/home/gtk/UNITREE_DEPS/unitree_rl_lab")
UNITREE_MODEL = Path("/home/gtk/UNITREE_DEPS/unitree_model")
G1_USD = UNITREE_MODEL / "G1/29dof/usd/g1_29dof_rev_1_0/g1_29dof_rev_1_0.usd"
G1_BASE_USD = UNITREE_MODEL / "G1/29dof/usd/g1_29dof_rev_1_0/configuration/g1_29dof_rev_1_0_base.usd"
INTERNAL_ROS_LIB = ISAAC_SIM / "exts/isaacsim.ros2.bridge/humble/lib"
EXTERNAL_ROS_SETUP = Path("/opt/ros/humble/setup.bash")


class Report:
    def __init__(self) -> None:
        self.failures = 0

    def pass_(self, label: str, detail: str) -> None:
        print(f"PASS  {label:<24} {detail}")

    def warn(self, label: str, detail: str) -> None:
        print(f"WARN  {label:<24} {detail}")

    def fail(self, label: str, detail: str) -> None:
        self.failures += 1
        print(f"FAIL  {label:<24} {detail}")

    def require(self, condition: bool, label: str, detail: str) -> None:
        (self.pass_ if condition else self.fail)(label, detail)


def first_line(path: Path) -> str:
    return path.read_text(encoding="utf-8").splitlines()[0]


def command_output(*args: str) -> str:
    return subprocess.run(args, check=True, capture_output=True, text=True).stdout.strip()


def main() -> int:
    report = Report()

    report.require(platform.system() == "Linux", "operating system", platform.platform())
    report.require(sys.version_info[:2] == (3, 11), "Python", sys.version.split()[0])
    report.require(os.environ.get("CONDA_DEFAULT_ENV") == "env_isaaclab", "Conda isolation", os.environ.get("CONDA_PREFIX", "unset"))

    for label, path in (
        ("Isaac Sim path", ISAAC_SIM),
        ("Isaac Lab path", ISAAC_LAB),
        ("Unitree RL Lab path", UNITREE_RL_LAB),
        ("Unitree model path", UNITREE_MODEL),
    ):
        report.require(path.is_dir(), label, str(path))

    sim_version = first_line(ISAAC_SIM / "VERSION")
    lab_version = first_line(ISAAC_LAB / "VERSION")
    report.require(sim_version.startswith("5.1.0"), "Isaac Sim version", sim_version)
    report.require(lab_version == "2.3.0", "Isaac Lab version", lab_version)
    report.require((ISAAC_LAB / "_isaac_sim").resolve() == ISAAC_SIM, "Isaac Lab symlink", str((ISAAC_LAB / "_isaac_sim").resolve()))

    for distribution, expected in (
        ("isaaclab", "0.47.2"),
        ("unitree_rl_lab", "0.2.1"),
        ("rsl-rl-lib", "3.0.1"),
    ):
        actual = importlib.metadata.version(distribution)
        report.require(actual == expected, distribution, actual)

    report.require(G1_USD.is_file(), "G1 root USD", str(G1_USD))
    report.require(G1_BASE_USD.is_file() and G1_BASE_USD.stat().st_size > 1_000_000, "G1 base USD", f"{G1_BASE_USD.stat().st_size if G1_BASE_USD.exists() else 0} bytes")
    if G1_USD.exists():
        report.require(G1_USD.read_bytes()[:8] == b"PXR-USDC", "G1 USD format", "binary USDC (not an LFS pointer)")

    try:
        smi = command_output("nvidia-smi", "--query-gpu=name,driver_version,memory.total", "--format=csv,noheader")
        report.pass_("NVIDIA driver", smi)
    except (FileNotFoundError, subprocess.CalledProcessError) as exc:
        report.fail("NVIDIA driver", f"nvidia-smi failed: {exc}")

    try:
        import torch

        report.require(torch.__version__ == "2.7.0+cu128", "PyTorch", torch.__version__)
        report.require(torch.cuda.is_available(), "CUDA available", str(torch.cuda.is_available()))
        if torch.cuda.is_available():
            value = torch.ones(4, device="cuda:0").sum().item()
            report.require(value == 4.0, "CUDA tensor", f"{torch.cuda.get_device_name(0)}; sum={value}")
    except Exception as exc:
        report.fail("PyTorch/CUDA", repr(exc))

    ros_python_paths = [entry for entry in sys.path if entry.startswith("/opt/ros/")]
    report.require(not ros_python_paths, "ROS path isolation", "no /opt/ros Python path in the Python 3.11 process")
    report.require(INTERNAL_ROS_LIB.is_dir(), "internal ROS 2 Humble", str(INTERNAL_ROS_LIB))
    report.require(EXTERNAL_ROS_SETUP.is_file(), "installed ROS 2 Humble", str(EXTERNAL_ROS_SETUP))

    try:
        commit = command_output("git", "-C", str(UNITREE_RL_LAB), "rev-parse", "--short", "HEAD")
        report.pass_("Unitree revision", commit)
    except subprocess.CalledProcessError as exc:
        report.fail("Unitree revision", str(exc))

    print()
    if report.failures:
        print(f"RESULT: FAIL ({report.failures} failed checks)")
        return 1
    print("RESULT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
