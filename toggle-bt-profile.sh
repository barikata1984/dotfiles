#!/usr/bin/env bash
set -uo pipefail

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
        pactl set-card-profile "$card" off
        sleep 0.3
        pactl set-card-profile "$card" "$A2DP"
        # Wait for the A2DP sink (stereo, 48kHz) to appear
        bt_sink=""
        for _ in $(seq 1 20); do
            sink_spec=$(pactl list sinks short 2>/dev/null | grep bluez)
            if echo "$sink_spec" | grep -q "2ch 48000Hz"; then
                bt_sink=$(echo "$sink_spec" | awk '{print $2}')
                break
            fi
            sleep 0.2
        done
        if [[ -n "$bt_sink" ]]; then
            pactl set-default-sink "$bt_sink"
            pactl list sink-inputs short | awk '{print $1}' | while read -r id; do
                pactl move-sink-input "$id" "$bt_sink" 2>/dev/null || true
            done
        fi
        xdotool key XF86AudioPause
        sleep 0.3
        xdotool key XF86AudioPlay
        notify-send "BT Profile" "High Quality (A2DP)"
        ;;
    *)
        notify-send "BT Profile" "Unknown profile: $current"
        exit 1
        ;;
esac
