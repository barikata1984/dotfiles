#!/usr/bin/env bash
set -euo pipefail

A2DP="a2dp-sink"
HEADSET="headset-head-unit"

card_info=$(pactl list cards 2>/dev/null \
    | awk '/Name: bluez_card/{card=$2} card && /api.bluez5.connection/{conn=$3} card && /Active Profile:/{prof=$NF; print card, conn, prof; card=""; exit}')

card=$(echo "$card_info" | awk '{print $1}')
connection=$(echo "$card_info" | awk '{gsub(/"/, "", $2); print $2}')
current=$(echo "$card_info" | awk '{print $3}')

if [[ -z "$card" ]]; then
    notify-send "BT Profile" "No Bluetooth audio device found"
    exit 1
fi

if [[ "$connection" != "connected" ]]; then
    notify-send "BT Profile" "Bluetooth device not connected"
    exit 1
fi

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
