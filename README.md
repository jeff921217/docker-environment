# docker-environment

Docker environment for AISLab Summer Training 2026 Lab 1.

This repository builds a development container with common CLI tools, C/C++
toolchains, Python, Verilator, and SystemC. It also provides helper scripts for
building/running the container and checking the environment with tutorial
examples.

## Files

- `Dockerfile`: multi-stage Docker build for the final development image.
- `docker.sh`: helper script for building, running, cleaning, and rebuilding the Docker environment.
- `eman`: Environment MANager script used inside the container to test tools and examples.
- `.gitignore`: ignores local notes, runtime files, and cloned tutorial repositories.

## Docker Image

Default image name:

```bash
aoc2026-env
```

The final image includes:

- Ubuntu 26.04
- non-root user `developer`
- `vim`, `git`, `curl`, `wget`
- `gcc`, `g++`, `make`
- Python and pip
- Verilator `v5.032`
- SystemC `2.3.4`

## Build And Run

Build the image:

```bash
./docker.sh build
```

Run or enter the container:

```bash
./docker.sh run
```

Clean the container and image:

```bash
./docker.sh clean
```

Rebuild from a clean state:

```bash
./docker.sh rebuild
```

Mount the current Lab1 directory into the container:

```bash
./docker.sh run --mount "$PWD:/workspace"
```

## Frontend Test Script

Clone the AOC Lab0 tutorial repository for test examples:

```bash
git clone ssh://git@gitlab.aislab.ee.ncku.edu.tw:3175/aislab-internal/course/aoc/aoc2026/lab-0-tutorial.git lab-0-tutorial
```

The `lab-0-tutorial/` directory is ignored by Git because it is only used as a
local test input.

Start the container with the Lab1 directory mounted:

```bash
./docker.sh clean
./docker.sh build
./docker.sh run --mount "$PWD:/workspace"
```

Inside the container, run:

```bash
eman help
eman c-compiler
eman c-compiler-example
eman verilator
eman verilator-example
```

Expected checks:

- `eman c-compiler` prints `gcc`, `g++`, and `make` versions.
- `eman c-compiler-example` compiles and runs `lab-0-tutorial/c_cpp/arrays/multidim_array`.
- `eman verilator` prints Verilator version and executable path.
- `eman verilator-example` compiles and runs `lab-0-tutorial/verilog/counter`.

## Verilator Version Switching

The default Verilator path points to:

```bash
/opt/verilator/current
```

Switch to an installed Verilator version:

```bash
eman change-verilator v5.032
```

If the requested version is not installed, `eman` will try to build it from
source inside the container.
