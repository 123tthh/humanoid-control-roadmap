# C8 AMP Walk-Run Policy

This chapter completes the AMP assignment from
`docs/course-materials/实践8：基于 AMP 的拟人走跑策略复现.pdf` using the course repository
at upstream commit `7171a81c8e82cbd9a44789d11e4da96326f7e73a`.

The implementation provides the 80-D AMP frame, 3-frame discriminator history,
bounded style reward, task/style reward mixing, PPO loss, WalkToRun profile,
and a registered FullPlay task. It does not start training automatically.

```bash
cd /home/gtk/UNITREE/C8
./scripts/c8.sh preflight
./scripts/c8.sh data                         # after C7 expert motions are supplied
./scripts/c8.sh list
```

Only when C1 is paused or finished and the full expert dataset passes `data`:

```bash
./scripts/c8.sh train --task Unitree-G1-29dof-AMP-WalkToRun --num_envs 1024
./scripts/c8.sh play --task Unitree-G1-29dof-AMP-WalkToRun-FullPlay --checkpoint /path/to/model.pt --num_envs 1
```

See [RESOURCES.md](docs/RESOURCES.md) for the motion-data contract and
environment boundary.
