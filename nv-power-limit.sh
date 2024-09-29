#!/usr/bin/env bash

# Set power limits on all NVIDIA GPUs
# Reference: https://www.pugetsystems.com/labs/hpc/quad-rtx3090-gpu-power-limiting-with-systemd-and-nvidia-smi-1983/

# How to set the power limit on the fly:
# 1. sudo-execute this file with a target power limit (280W is the target in the example below)
#   sudo bash ./nv-power-limit.sh 280
#
# How to have this file loaded at system boot:
# Assuming this file is placed under $HOME/workspace/dotfiles/,
# 1. Change the permission of the file
#   sudo chmod 744 $HOME/workspace/dotfiles/nv-power-limit.sh
# 2. Symbolic-link the file
#   sudo ln -s $HOME/workspace/dotfiles/nv-power-limit.sh /usr/local/sbin/nv-power-limit.sh
# 3. Follow the instruction of ../nv-power-limit.service

# Make sure nvidia-smi exists
command -v nvidia-smi &> /dev/null || { echo >&2 "nvidia-smi not found ... exiting."; exit 1; }

# Set default POWER_LIMIT
POWER_LIMIT=280  # Stack: 350, Max: 400

# Override default if argument is provided
if [ $# -eq 1 ]; then
  POWER_LIMIT=$1
fi

MAX_POWER_LIMIT=$(nvidia-smi -q -d POWER | grep 'Max Power Limit' | tr -s ' ' | cut -d ' ' -f 6)

if [[ ${POWER_LIMIT%.*}+0 -lt ${MAX_POWER_LIMIT%.*}+0 ]]; then
    /usr/bin/nvidia-smi --persistence-mode=1
    /usr/bin/nvidia-smi  --power-limit=${POWER_LIMIT}
else
    echo 'FAIL! POWER_LIMIT set above MAX_POWER_LIMIT ... '
    exit 1
fi

exit 0
