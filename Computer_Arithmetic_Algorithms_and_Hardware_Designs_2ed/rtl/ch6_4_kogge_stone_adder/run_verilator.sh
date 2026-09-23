#!/usr/bin/env bash
# Verilator 一键编译+仿真（需 Verilator 5.x，推荐 Linux/WSL）
set -euo pipefail
cd "$(dirname "$0")"
if ! command -v verilator >/dev/null 2>&1; then
    echo "ERROR: verilator not found (install Verilator 5.x, e.g. under WSL)" >&2
    exit 127
fi
verilator --binary --timing -j 0 -Wno-fatal -Wno-WIDTH \
    --top-module tb -o sim ./*.sv
./obj_dir/sim
