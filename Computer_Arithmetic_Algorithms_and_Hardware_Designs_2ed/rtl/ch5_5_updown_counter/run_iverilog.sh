#!/usr/bin/env bash
# Icarus Verilog 一键编译+仿真
set -euo pipefail
cd "$(dirname "$0")"
if ! command -v iverilog >/dev/null 2>&1; then
    echo "ERROR: iverilog not found in PATH" >&2
    exit 127
fi
iverilog -g2012 -o sim.vvp ./*.sv
vvp sim.vvp
