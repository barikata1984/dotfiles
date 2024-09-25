#!/usr/bin/env bash

# Set power limits on all NVIDIA GPUs
# Reference: https://www.pugetsystems.com/labs/hpc/quad-rtx3090-gpu-power-limiting-with-systemd-and-nvidia-smi-1983/

# How to use:
# Assuming this file is placed under $HOME/workspace/dotfiles/,
# 1. Change the permission of the file
#   sudo chmod 744 $HOME/workspace/dotfiles/nv-power-limit.sh
# 2. Symbolic-link the file
#   sudo ln -s $HOME/workspace/dotfiles/nv-power-limit.sh /usr/local/sbin/nv-power-limit.sh

# Make sure nvidia-smi exists 
command -v nvidia-smi &> /dev/null || { echo >&2 "nvidia-smi not found ... exiting."; exit 1; }

POWER_LIMIT=280
MAX_POWER_LIMIT=$(nvidia-smi -q -d POWER | grep 'Max Power Limit' | tr -s ' ' | cut -d ' ' -f 6)

if [[ ${POWER_LIMIT%.*}+0 -lt ${MAX_POWER_LIMIT%.*}+0 ]]; then
    /usr/bin/nvidia-smi --persistence-mode=1
    /usr/bin/nvidia-smi  --power-limit=${POWER_LIMIT}
else
    echo 'FAIL! POWER_LIMIT set above MAX_POWER_LIMIT ... '
    exit 1
fi

exit 0
