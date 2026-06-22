#!/usr/bin/env bash
set -euo pipefail

A2DP="a2dp-sink"
HEADSET="headset-head-unit"

card=$(pactl list cards short | awk '/bluez/{print $2; exit}')

if [[ -z "$card" ]]; then
    notify-send "BT Profile" "No Bluetooth audio device found"
    exit 1
fi

bt_addr=$(echo "$card" | sed 's/bluez_card\.//;s/_/:/g')
if ! bluetoothctl info "$bt_addr" 2>/dev/null | grep -q "Connected: yes"; then
    notify-send "BT Profile" "Bluetooth device not connected"
    exit 1
fi

current=$(pactl list cards 2>/dev/null \
    | awk -v card="$card" '
        $0 ~ "Name: " card { found=1 }
        found && /Active Profile:/ { print $NF; exit }
    ')

case "$current" in
    a2dp-sink*)
        pactl set-card-profile "$card" "$HEADSET"
        notify-send "BT Profile" "Headset (HSP/HFP)"
        ;;
    headset-head-unit*)
        pactl set-card-profile "$card" "$A2DP"
        notify-send "BT Profile" "High Quality (A2DP)"
        ;;
    *)
        notify-send "BT Profile" "Unknown profile: $current"
        exit 1
        ;;
esac
