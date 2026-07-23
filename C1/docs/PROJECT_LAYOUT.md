# C1 Project Layout

Reference: `course-materials/实践1：宇树G1仿真环境（Isaac Sim_Lab_MuJoCo）搭建与基础功能验证.pdf`.

```text
C1/
├── docs/                 # Course material and operational documentation
├── logs/                 # Local RSL-RL runs; two selected checkpoints are versioned
├── resources/            # Pointers to shared, version-locked dependencies
├── scripts/              # Check, train, play, and TensorBoard commands
├── sim2sim/              # MuJoCo G1 configuration and controller launch interface
└── README.md             # Chapter entry point
```

This chapter is an environment-validation and policy-training chapter, so it
has no local `src/` package. The production task implementation remains in the
shared `/home/gtk/UNITREE_DEPS/unitree_rl_lab` dependency. C2 and later chapters
add a local `src/` or `source/` tree only where they introduce their own task or
deployment implementation.
