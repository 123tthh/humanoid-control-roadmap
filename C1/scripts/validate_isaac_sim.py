# Local documentation references:
# - /home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/python_scripting/manual_standalone_python.md
# - /home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_workstation.md
# - /home/gtk/ai_docs/docs.isaacsim.omniverse.nvidia.com/5.1.0/py/source/extensions/isaacsim.simulation_app/docs/api.md
# Isaac Lab example reference: /home/gtk/UNITREE_DEPS/IsaacLab/scripts/tutorials/00_sim/create_empty.py

"""Start Isaac Sim headless, initialize Isaac Lab physics, step, and close."""

from isaacsim import SimulationApp


simulation_app = SimulationApp({"headless": True})

try:
    from isaaclab.sim import SimulationCfg, SimulationContext

    simulation = SimulationContext(SimulationCfg(dt=0.01))
    simulation.reset()
    for _ in range(5):
        simulation.step()
    print(
        "RESULT: PASS - Isaac Sim 5.1 and Isaac Lab 2.3.0 completed five headless physics steps",
        flush=True,
    )
finally:
    # This short-lived validator does not need extension-by-extension cleanup.
    # The documented immediate-exit path also avoids a 5.1 shutdown hang seen
    # after the physics result had already passed.
    simulation_app.close(skip_cleanup=True)
